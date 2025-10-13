param(
    [string]$To = "jeastman@champlain.edu"
)

. "$PSScriptRoot\Email.ps1" 

$stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$body  = "Automated message from SYS-320 at $stamp"
$subj  = "SYS-320 check-in ($stamp)"

Send-AlertEmail -To $To -Subject $subj -Body $body
