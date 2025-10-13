$taskName = "SYS320_SendEvery10Min_3Days"
$scriptToRun = "C:\Users\Wu\SYS-320\week07\SendOnce.ps1"
#do the Send-Image-Attachment.ps1 for an image or Send-Image-Inline.ps1 for html image

# Run first trigger one minute from now, repeat every 10 min, for 3 days
$start   = (Get-Date).AddMinutes(1)
$trigger = New-ScheduledTaskTrigger -Once -At $start `
           -RepetitionInterval (New-TimeSpan -Minutes 10) `
           -RepetitionDuration (New-TimeSpan -days 3)

$action  = New-ScheduledTaskAction -Execute "powershell.exe" `
           -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptToRun`""


$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal | Out-Null

Write-Host "Ready. A message will be sent every 10 minutes for the next 1 hour." -ForegroundColor Green
Get-ScheduledTask -TaskName $taskName | Select-Object TaskName, State, LastRunTime, NextRunTime
