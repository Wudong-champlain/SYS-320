function Gather-Classes {
    param([Parameter(Mandatory)][string]$Uri)

    # Accept file path or URL
    if (Test-Path $Uri) {
        $Uri = (Resolve-Path $Uri).Path
        if ($Uri -notmatch '^[a-z]+://') { $Uri = "file:///$($Uri -replace '\\','/')" }
    }

    # Use Internet Explorer COM for a reliable DOM
    $ie = New-Object -ComObject 'InternetExplorer.Application'
    $ie.Visible = $false
    $ie.Navigate2($Uri)
    while ($ie.Busy -or $ie.ReadyState -ne 4) { Start-Sleep -Milliseconds 200 }
    $doc = $ie.Document
    if ($null -eq $doc) { $ie.Quit(); throw "Failed to load HTML from $Uri" }

    # helper: safe cell text
    function Get-TdText { param($tds, [int]$i)
        $cell = $tds.item($i)
        if ($null -ne $cell) { return ([string]$cell.innerText).Trim() }
        return ''
    }

    $trs = $doc.getElementsByTagName('tr')
    $results = @()

    # skip header row
    for ($i = 1; $i -lt $trs.length; $i++) {
        $tds = $trs.item($i).getElementsByTagName('td')
        if (-not $tds -or $tds.length -lt 9) { continue }   # ignore spacer/short rows

        $code       = Get-TdText $tds 0
        $title      = Get-TdText $tds 1
        $daysTxt    = Get-TdText $tds 4
        $timesTxt   = Get-TdText $tds 5
        $instructor = Get-TdText $tds 6
        $location   = Get-TdText $tds 9    # may be missing on some rows -> returns ''

        if ([string]::IsNullOrWhiteSpace($code) -and [string]::IsNullOrWhiteSpace($title)) { continue }

        # parse first time range safely
        $timeStart = $null; $timeEnd = $null
        if ($timesTxt -and $timesTxt -notmatch 'TBA') {
            $firstRange = ($timesTxt -split ",|\r|\n")[0].Trim()
            $parts = $firstRange -split '\s*-\s*'
            if ($parts.Count -eq 2) { $timeStart = $parts[0].Trim(); $timeEnd = $parts[1].Trim() }
        }

        $results += [pscustomobject]@{
            'Class Code' = $code
            'Title'      = $title
            'Days'       = $daysTxt
            'Time Start' = $timeStart
            'Time End'   = $timeEnd
            'Instructor' = $instructor
            'Location'   = $location
        }
    }

    $ie.Quit()
    return $results
}

function Convert-DaysToArray {
    param([Parameter(Mandatory)][object[]]$FullTable)

    for ($i=0; $i -lt $FullTable.Count; $i++) {
        $raw = [string]$FullTable[$i].Days
        $raw = $raw.ToUpper()

        if ([string]::IsNullOrWhiteSpace($raw) -or $raw -match 'TBA') {
            $FullTable[$i].Days = @()
            continue
        }

        $days = @()
        # Greedy TH first, then single letters
        while ($raw.Length -gt 0) {
            if ($raw.StartsWith('TH')) { $days += 'Thursday'; $raw = $raw.Substring(2); continue }
            switch ($raw[0]) {
                'M' { $days += 'Monday' }
                'T' { $days += 'Tuesday' }
                'W' { $days += 'Wednesday' }
                'F' { $days += 'Friday' }
                default { }
            }
            $raw = $raw.Substring(1)
        }
        $FullTable[$i].Days = $days
    }
    return $FullTable
}
