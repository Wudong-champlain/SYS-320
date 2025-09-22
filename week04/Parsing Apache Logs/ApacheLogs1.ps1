function ApacheLogs1 {
    [CmdletBinding()]
    param(
      [string]$LogPath = 'C:\xampp\apache\logs\access.log'
    )

    if (-not (Test-Path $LogPath)) {
        Write-Warning "Log not found: $LogPath"
        return @()
    }

    $logsNotFormatted = Get-Content -LiteralPath $LogPath
    $tableRecords = @()

    for ($i = 0; $i -lt $logsNotFormatted.Count; $i++) {

        $words = $logsNotFormatted[$i] -split ' '

        if ($words.Count -lt 12) { continue }

        $tableRecords += [pscustomobject]@{
            "IP"       = $words[0]
            "Time"     = ($words[3].Trim('[') + ' ' + $words[4].Trim(']'))
            "Method"   = $words[5].Trim('"')
            "Page"     = $words[6]
            "Protocol" = $words[7].Trim('"')
            "Response" = $words[8]
            "Referrer" = $words[10].Trim('"')
            "Client"   = ($words[11..($words.Count-1)] -join ' ').Trim('"')
        }
    }

    $tableRecords | Where-Object { $_.IP -like '10.*' }
}
