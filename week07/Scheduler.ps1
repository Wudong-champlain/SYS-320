function Convert-TimeString {
    param([string]$Time)
    $fmts = @('h:mm tt','hh:mm tt','h:mmtt','hh:mmtt')
    foreach ($f in $fmts) {
        try { return [datetime]::ParseExact($Time, $f, $null) } catch {}
    }
    throw "Time '$Time' is not in h:mm AM/PM format"
}

function Disable-AutoRun {
    $t = Get-ScheduledTask | Where-Object { $_.TaskName -eq 'myTask' }
    if ($t) {
        Write-Host "Unregistering the task..." | Out-String
        Unregister-ScheduledTask -TaskName 'myTask' -Confirm:$false
    } else {
        Write-Host "The task is not registered." | Out-String
    }
}

function Choose-TimeToRun {
    param(
        [Parameter(Mandatory)][string]$Time,
        [Parameter(Mandatory)][string]$ScriptPath
    )

    $dt = Convert-TimeString $Time  # returns a DateTime whose time-of-day we use

    # If a task exists, remove it first
    Disable-AutoRun | Out-Null

    Write-Host "Creating new task." | Out-String

    $action    = New-ScheduledTaskAction -Execute "powershell.exe" `
                   -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
    $trigger   = New-ScheduledTaskTrigger -Daily -At $dt
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
    $settings  = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable `
                    -WakeToRun -AllowStartIfOnBatteries

    Register-ScheduledTask -TaskName 'myTask' -Action $action `
        -Trigger $trigger -Principal $principal -Settings $settings -Force
}