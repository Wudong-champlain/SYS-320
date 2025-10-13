param(
  [string]$To       = "wu.dong@mymail.champlain.edu",
  [string]$ImagePath = "C:\Users\Wu\Pictures\lol.jpg",
  [string]$Subject   = "SYS-320 image"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$From        = "wu.dong@mymail.champlain.edu"
$AppPassword = "sjeaorbhchwklmqq" 

$Secure = $AppPassword | ConvertTo-SecureString -AsPlainText -Force
$Cred   = New-Object System.Management.Automation.PSCredential ($From, $Secure)

Send-MailMessage -From $From -To $To -Subject $Subject `
  -Body "See attached image." `
  -Attachments $ImagePath `
  -SmtpServer "smtp.gmail.com" -Port 587 -UseSsl -Credential $Cred

Write-Host "Sent with attachment to $To" -ForegroundColor Green
