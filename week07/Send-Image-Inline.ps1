param(
  [string]$To        = "wu.dong@mymail.champlain.edu",
  [string]$ImagePath = "C:\Users\Wu\Pictures\LOL.jpg",
  [string]$Subject   = "League of Legends Battle!"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$From        = "wu.dong@mymail.champlain.edu"
$AppPassword = "sjeaorbhchwklmqq"  # your Gmail app password (no spaces)

$Secure = $AppPassword | ConvertTo-SecureString -AsPlainText -Force
$Cred   = New-Object System.Management.Automation.PSCredential ($From, $Secure)

# Create mail components
$smtp               = New-Object System.Net.Mail.SmtpClient("smtp.gmail.com",587)
$smtp.EnableSsl     = $true
$smtp.Credentials   = $Cred

$mail               = New-Object System.Net.Mail.MailMessage
$mail.From          = $From
$mail.To.Add($To)
$mail.Subject       = $Subject
$mail.IsBodyHtml    = $true

# Build HTML body with inline image (use larger display size)
$cid   = [Guid]::NewGuid().ToString()
$html  = @"
<html>
  <body style="font-family: Arial; background-color: #f4f4f4; padding: 20px;">
    <h2>LEAGUE OF LEGEND BEST GAME</h2>
    <p>Hey Joe, check out this awesome spam:</p>
    <img src="cid:$cid" style="width:100%; max-width:900px; border-radius:10px;"/>
    <p>– Sent from my PowerShell script ??</p>
  </body>
</html>
"@

# Embed the image into the email body
$altView = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($html, $null, "text/html")
$link    = New-Object System.Net.Mail.LinkedResource($ImagePath)
$link.ContentId = $cid
$altView.LinkedResources.Add($link)
$mail.AlternateViews.Add($altView)

# Send
$smtp.Send($mail)
Write-Host "Sent inline image (full size) to $To" -ForegroundColor Green
