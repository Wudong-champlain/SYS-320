Get-Process -ErrorAction SilentlyContinue |
  Where-Object { $_.Path -and $_.Path -notmatch '(?i)system32' } |
  Sort-Object ProcessName |
  Select-Object ProcessName, Id, Path
