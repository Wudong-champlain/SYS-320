. (Join-Path $PSScriptRoot 'ApacheLogs1.ps1')

$stableRecords = ApacheLogs1
$stableRecords | Format-Table IP, Time, Method, Page, Protocol, Response, Referrer -AutoSize -Wrap
