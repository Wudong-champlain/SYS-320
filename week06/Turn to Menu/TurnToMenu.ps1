<#  TurnToMenu.ps1
    Week06 “Turn to Menu” – uses earlier labs via dot-sourcing
    Works with YOUR folder layout shown in your screenshots.
#>

# --- Resolve paths based on this script location ---
$here        = $PSScriptRoot                                 # ...\week06\Turn to Menu
$week06Root  = Split-Path -Parent $here                      # ...\week06
$courseRoot  = Split-Path -Parent $week06Root                # ...\SYS-320
$week04Root  = Join-Path $courseRoot 'week04'

# Scripts that live next to week06
$UsersScript       = Join-Path $week06Root 'Users.ps1'
$EventLogsScript   = Join-Path $week06Root 'Event-Logs.ps1'
$StringHelperScript= Join-Path $week06Root 'String-Helper.ps1'

# Script that lives in week04
$ApacheLogsScript  = Join-Path $week04Root 'Parsing Apache Logs\ApacheLogs1.ps1'

function Require-Script([string]$Path) {
    if (-not (Test-Path $Path)) {
        throw "Required script not found: `"$Path`""
    }
    . $Path
}

# --- Dot-source required scripts (loads their functions into this session) ---
Require-Script $StringHelperScript   # String helpers used by Event-Logs.ps1
Require-Script $EventLogsScript      # getLogInAndOffs, getFailedLogins (from your lab)
Require-Script $UsersScript          # Get-AtRiskUsers (from your lab)
Require-Script $ApacheLogsScript     # ApacheLogs1 (from week04)

# --- Default knobs you can tweak ---
$ApacheAccessLog   = 'C:\xampp\apache\logs\access.log'
$DefaultFailedDays = 14      # lookback window for failed logins
$DefaultRiskDays   = 14      # lookback window for “at-risk”
$DefaultThreshold  = 10      # failed attempts threshold for “at-risk”

function Show-Menu {
@"
============================
        Turn to Menu
============================
 1 - Display last 10 apache logs
 2 - Display last 10 failed logins (Security 4625)
 3 - Display at-risk users (failed > threshold in last N days)
 4 - Start Chrome and navigate to champlain.edu (only if not running)
 5 - Exit
"@
}

# --- Menu Loop ---
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter 1-5"
    if ($choice -notmatch '^[1-5]$') {
        Write-Host "Please enter a number 1 through 5." -ForegroundColor Yellow
        continue
    }

    switch ($choice) {

        '1' {
            try {
                # ApacheLogs1: your week04 function that parses access.log and returns objects
                $rows = ApacheLogs1 -Path $ApacheAccessLog 2>$null
                if (-not $rows) { Write-Host "No rows returned from ApacheLogs1." -ForegroundColor Yellow; break }
                $rows | Select-Object -First 10 | Format-Table -AutoSize
            } catch {
                Write-Host "Error running ApacheLogs1: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        '2' {
            try {
                # From Event-Logs.ps1 in your week06: function name per lab handout
                # If your function name is slightly different, change here.
                $failed = getFailedLogins -Days $DefaultFailedDays 2>$null
                if (-not $failed) { Write-Host "No failed login events found." -ForegroundColor Yellow; break }
                $failed | Select-Object -First 10 | Format-Table -AutoSize
            } catch {
                Write-Host "Error running getFailedLogins: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        '3' {
            try {
                # From Users.ps1 in your week06 – expected lab name Get-AtRiskUsers
                # If yours differs, change the call below.
                $atRisk = Get-AtRiskUsers -Days $DefaultRiskDays -Threshold $DefaultThreshold 2>$null
                if (-not $atRisk) { Write-Host "No at-risk users for the selected window." -ForegroundColor Yellow; break }
                $atRisk | Format-Table -AutoSize
            } catch {
                Write-Host "Error running Get-AtRiskUsers: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        '4' {
            try {
                $chrome = Get-Process chrome -ErrorAction SilentlyContinue
                if ($chrome) {
                    Write-Host "Chrome is already running. (As required, I won't start another.)" -ForegroundColor Cyan
                } else {
                    Start-Process 'chrome.exe' 'https://www.champlain.edu'
                    Write-Host "Chrome started to https://www.champlain.edu" -ForegroundColor Green
                }
            } catch {
                Write-Host "Error launching Chrome: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        '5' {
            Write-Host "Exiting. Bye!" -ForegroundColor Cyan
            break
        }
    }

    # small spacer between actions
    Write-Host ""
    [void](Read-Host "Press Enter to return to menu")
    Clear-Host
}