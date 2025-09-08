# List processes whose name starts with C
Get-Process |
  Where-Object { $_.ProcessName -like 'C*' } |
  Sort-Object ProcessName |
  Select-Object ProcessName, Id, Path
