# Run me to (a) send the alert now, and (b) schedule future runs.

# ----- include local scripts -----
. (Join-Path $PSScriptRoot 'Configuration.ps1')
. (Join-Path $PSScriptRoot 'Email.ps1')
. (Join-Path $PSScriptRoot 'Scheduler.ps1')

# ----- include your week06 functions (already on your machine) -----
$root    = Split-Path -Parent $PSScriptRoot       # ...\SYS-320
$week06  = Join-Path $root 'week06'
. (Join-Path $week06 'Event-Logs.ps1')
. (Join-Path $week06 'Users.ps1')
. (Join-Path $week06 'String-Helper.ps1')  # if Users.ps1 depends on it

# ----- settings you can tweak -----
$Threshold = 3   # how many failed logins counts as "at risk"

# ----- do the work -----
$config = Read-Configuration

# call your function from Users.ps1 (name may differ; adjust if needed)
# expected to return objects with Name and Count (or similar)
$failed = Get-AtRiskUsers -Days $config.Days -Threshold $Threshold

if (-not $failed) {
    $body = "No at-risk users found in the last $($config.Days) day(s)."
} else {
    $body = ($failed | Sort-Object Count -Descending | Format-Table -AutoSize | Out-String)
}

# send the alert now
Send-AlertEmail -Body $body

# (re)create the scheduled task to run this same script daily
Choose-TimeToRun -Time $config.ExecutionTime -ScriptPath $PSCommandPath

Write-Host "All set. Sent an email and (re)scheduled daily run at $($config.ExecutionTime)." -ForegroundColor Green