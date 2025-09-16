. (Join-Path $PSScriptRoot 'Event-Logs.ps1')
Clear-Host

# A) Login / Logoff
$loginoutsTable = Get-UserLogonLogoff -Days 14
$loginoutsTable | Select Time, Id, Event, User | Format-Table -AutoSize
""

# B) Shutdowns
$shutdownsTable = Get-ShutdownEvents -Days 25
$shutdownsTable | Select Time, Id, Event, User | Format-Table -AutoSize
""

# C) Startups
$startupsTable = Get-StartupEvents -Days 25
$startupsTable | Select Time, Id, Event, User | Format-Table -AutoSize
