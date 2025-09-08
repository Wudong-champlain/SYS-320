$csv = Join-Path $PSScriptRoot 'stopped-services.csv'

Get-Service |
  Where-Object Status -eq 'Stopped' |
  Sort-Object DisplayName |
  Select-Object Name, DisplayName, Status |
  Export-Csv -Path $csv -NoTypeInformation

Write-Host "Saved:" $csv
