$Script:ConfigPath = Join-Path $PSScriptRoot 'configuration.txt'

function Read-Configuration {
    if (-not (Test-Path $Script:ConfigPath)) {
        # create a sensible default if missing
        "14`n1:22 PM" | Set-Content -Path $Script:ConfigPath -Encoding UTF8
    }
    $lines = Get-Content -Path $Script:ConfigPath -TotalCount 2
    $daysTxt = ($lines | Select-Object -Index 0)
    $timeTxt = ($lines | Select-Object -Index 1)

    if ($daysTxt -notmatch '^\d+$') {
        throw "Invalid days value in configuration.txt (got '$daysTxt')."
    }
    if ($timeTxt -notmatch '^(?:[1-9]|1[0-2]):[0-5]\d\s?(?:AM|PM)$') {
        throw "Invalid time format in configuration.txt (got '$timeTxt')."
    }

    [pscustomobject]@{
        Days          = [int]$daysTxt
        ExecutionTime = ($timeTxt -replace '\s+', ' ').Trim().ToUpper()
    }
}

function Change-Configuration {
    param()

    do {
        $d = Read-Host "Enter the number of days to evaluate (digits only)"
    } until ($d -match '^\d+$')

    do {
        $t = Read-Host "Enter the daily execution time (e.g. 1:22 PM)"
    } until ($t -match '^(?:[1-9]|1[0-2]):[0-5]\d\s?(?:AM|PM)$')

    "$d`n$($t.ToUpper())" | Set-Content -Path $Script:ConfigPath -Encoding UTF8
    Write-Host "Configuration changed." -ForegroundColor Green
}

function Show-ConfigurationMenu {
@"
Please choose your operation:
1 - Show Configuration
2 - Change Configuration
3 - Exit
"@ | Write-Host -ForegroundColor Cyan

    while ($true) {
        $choice = Read-Host "Enter 1, 2, or 3"
        switch ($choice) {
            '1' {
                Read-Configuration | Format-Table -AutoSize
            }
            '2' { Change-Configuration }
            '3' { break }
            default { Write-Host "Please enter only 1, 2 or 3." -ForegroundColor Yellow }
        }
    }
}