[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Send-AlertEmail {
    param(
        [Parameter(Mandatory)][string]$To,
        [Parameter(Mandatory)][string]$Body,
        [string]$Subject = "SYS-320 Notification"
    )

    $From = "wu.dong@mymail.champlain.edu"
    $AppPassword = "sjeaorbhchwklmqq"

    $SecurePassword = $AppPassword | ConvertTo-SecureString -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential ($From, $SecurePassword)

    try {
        Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body `
            -SmtpServer "smtp.gmail.com" -Port 587 -UseSsl -Credential $Cred
        Write-Host "Email sent to $To successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to send email to $To" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
