. (Join-Path $PSScriptRoot 'Users.ps1')
. (Join-Path $PSScriptRoot 'Event-Logs.ps1')

Clear-Host

function Show-Menu {
@"
===========================================
 Local User Management Menu
===========================================
 1 - List Enabled Users
 2 - List Disabled Users
 3 - Create a User
 4 - Remove a User
 5 - Enable a User
 6 - Disable a User
 7 - Get Logon/Logoff (last N days)
 8 - Get Failed Logins (last N days)
 9 - List At-Risk Users (failed > threshold in last N days)
 0 - Exit
-------------------------------------------
"@
}

while ($true) {
    Show-Menu
    $choice = Read-Host -Prompt 'Enter a choice (0-9)'

    # basic validation
    if (-not ($choice -match '^\d+$')) {
        Write-Host "Invalid input. Please enter a number 0-9.`n" -ForegroundColor Yellow
        continue
    }

    switch ([int]$choice) {

        0 { break }

        1 {
            $enabled = Get-EnabledUsers
            if ($enabled) { $enabled | Format-Table -AutoSize | Out-String | Write-Host }
            else { Write-Host "No enabled users found." -ForegroundColor Yellow }
        }

        2 {
            $disabled = Get-DisabledUsers
            if ($disabled) { $disabled | Format-Table -AutoSize | Out-String | Write-Host }
            else { Write-Host "No disabled users found." -ForegroundColor Yellow }
        }

        3 {
            try {
                $name = Read-Host -Prompt 'New username'
                $pwd  = Read-Host -AsSecureString -Prompt 'New password'
                New-LocalUserSafe -Name $name -Password $pwd
                Write-Host "User '$name' created." -ForegroundColor Green
            } catch { Write-Host $_.Exception.Message -ForegroundColor Red }
        }

        4 {
            try {
                $name = Read-Host -Prompt 'Username to remove'
                Remove-LocalUserSafe -Name $name
                Write-Host "User '$name' removed." -ForegroundColor Green
            } catch { Write-Host $_.Exception.Message -ForegroundColor Red }
        }

        5 {
            try {
                $name = Read-Host -Prompt 'Username to enable'
                Enable-LocalUserSafe -Name $name
                Write-Host "User '$name' enabled." -ForegroundColor Green
            } catch { Write-Host $_.Exception.Message -ForegroundColor Red }
        }

        6 {
            try {
                $name = Read-Host -Prompt 'Username to disable'
                Disable-LocalUserSafe -Name $name
                Write-Host "User '$name' disabled." -ForegroundColor Green
            } catch { Write-Host $_.Exception.Message -ForegroundColor Red }
        }

        7 {
            $days = Read-Host -Prompt 'How many days back?'
            if ($days -match '^\d+$') {
                Get-LogInAndOffs -Days ([int]$days) |
                    Sort-Object Time |
                    Format-Table -AutoSize | Out-String | Write-Host
            } else {
                Write-Host "Enter a valid integer for days." -ForegroundColor Yellow
            }
        }

        8 {
            $days = Read-Host -Prompt 'How many days back?'
            if ($days -match '^\d+$') {
                Get-FailedLogins -Days ([int]$days) |
                    Sort-Object Time |
                    Format-Table -AutoSize | Out-String | Write-Host
            } else {
                Write-Host "Enter a valid integer for days." -ForegroundColor Yellow
            }
        }

        9 {
            $days = Read-Host -Prompt 'How many days back?'
            $th   = Read-Host -Prompt 'Failed-login threshold (default 10)'
            if (-not ($days -match '^\d+$')) { Write-Host "Enter a valid integer for days." -ForegroundColor Yellow; continue }
            if (-not ($th -match '^\d+$')) { $th = 10 }
            Get-AtRiskUsers -Days ([int]$days) -Threshold ([int]$th) |
                Format-Table -AutoSize | Out-String | Write-Host
        }

        Default {
            Write-Host "Unknown selection. Please choose 0–9.`n" -ForegroundColor Yellow
        }
    } # switch
} # while

Write-Host "`nExiting. Bye!" -ForegroundColor Cyan
