function Convert-Time {
    param([string]$s)
    if ([string]::IsNullOrWhiteSpace($s)) { return $null }
    $s = $s.Trim()
    # handle 1PM, 11:45AM, 1 PM, 11:45 AM
    $fmts = @('h:mmtt','htt','h tt','h:mm tt')
    foreach ($f in $fmts) {
        try { return [datetime]::ParseExact($s, $f, $null) } catch {}
    }
    try { return [datetime]::Parse($s) } catch { return $null }
}

function Get-CoursesTable {
    [CmdletBinding()]
    param(
        [string]$Url = 'http://localhost/Courses2025FA.html',
        [int]$HeaderRowIndex = 0
    )

    $page = Invoke-WebRequest -TimeoutSec 5 $Url
    $trs  = $page.ParsedHtml.getElementsByTagName('tr')

    # helper to fetch a cell safely
    function Get-CellText([object]$tds, [int]$i) {
        if ($null -eq $tds) { return '' }
        if ($i -lt 0 -or $i -ge $tds.length) { return '' }
        $cell = $tds.item($i)
        if ($null -eq $cell) { return '' }
        ($cell.innerText) -as [string]
    }

    $rows = @()

    # start after the header row
    for ($i = [math]::Max($HeaderRowIndex+1,1); $i -lt $trs.length; $i++) {

        $tds = $trs.item($i).getElementsByTagName('td')
        if ($null -eq $tds -or $tds.length -lt 7) { continue }   # too few cells

        # Choose indexes robustly. Location = last cell in the row.
        $idxNum        = 0
        $idxTitle      = 1
        $idxCredit     = 2
        $idxDays       = 4
        $idxTimes      = 5
        $idxInstructor = 6
        $idxLocation   = $tds.length - 1

        $classCode = (Get-CellText $tds $idxNum).Trim()
        $title     = (Get-CellText $tds $idxTitle).Trim()
        $credit    = (Get-CellText $tds $idxCredit).Trim()
        $daysText  = (Get-CellText $tds $idxDays).Trim()
        $timesText = (Get-CellText $tds $idxTimes).Trim()
        $instructor= (Get-CellText $tds $idxInstructor).Trim()
        $location  = (Get-CellText $tds $idxLocation).Trim()

        if (-not $classCode) { continue }  # skip non-data rows

        # Split Times -> start/end (defensive)
        $timeStart,$timeEnd = $null,$null
        if ($timesText -match '-') {
            $parts = $timesText -split '\s*-\s*', 2
            if ($parts.Count -ge 1) { $timeStart = $parts[0] }
            if ($parts.Count -ge 2) { $timeEnd   = $parts[1] }
        } else {
            $timeStart = $timesText
        }

        $rows += [pscustomobject]@{
            'Class Code' = $classCode
            'Title'      = $title
            'Credit'     = $credit
            'Days'       = $daysText
            'Time Start' = $timeStart
            'Time End'   = $timeEnd
            'Instructor' = $instructor
            'Location'   = $location
            '_StartDT'   = Convert-Time $timeStart
            '_EndDT'     = Convert-Time $timeEnd
        }
    }

    return $rows
}
