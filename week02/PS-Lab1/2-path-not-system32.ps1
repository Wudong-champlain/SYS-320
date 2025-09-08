# List processes whose executable path does NOT contain system32
Get-Process -ErrorAction SilentlyContinue |
  Where-Object { $_.Path -and $_.Path -notmatch '(?i)system32' } |
  Sort-Object ProcessName |
  Select-Object ProcessName, Id, Path