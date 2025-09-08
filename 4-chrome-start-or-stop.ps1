$chrome = Get-Process -Name 'chrome' -ErrorAction SilentlyContinue

if (-not $chrome) {
    Start-Process 'chrome.exe' 'https://www.champlain.edu'
    Write-Host 'Chrome was not running. Started it to champlain.edu.'
} else {
    Stop-Process -Name 'chrome' -Force
    Write-Host 'Chrome was running. Stopped it.'
}
