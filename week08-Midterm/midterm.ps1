# Challenge 1: Grab IOC patterns (PS7-safe)
function Get-IOCTable {
    param([string]$Path = ".\IOC-1.html")
    if (-not (Test-Path $Path)) { throw "IOC HTML not found: $Path" }

    $html = Get-Content -Path $Path -Raw

    # Helper to decode HTML entities in both PS7 and WinPS5
    function _Decode([string]$s) {
        return [System.Net.WebUtility]::HtmlDecode($s)
    }

    $rows = [regex]::Matches(
        $html,
        '<tr>\s*<td>\s*(?<Pattern>.*?)\s*</td>\s*<td>\s*(?<Desc>.*?)\s*</td>\s*</tr>',
        'Singleline,IgnoreCase'
    )

    foreach ($m in $rows) {
        $p = (_Decode $m.Groups['Pattern'].Value.Trim())
        $d = (_Decode $m.Groups['Desc'].Value.Trim())
        if ($p -match '^\s*Pattern\s*$') { continue }   # skip header
        [pscustomobject]@{ Pattern = $p; Explanation = $d }
    }
}

#Challenge 2: Parse access.log
function Get-ApacheAccessLog {
    param([string]$Path = ".\access.log")
    if (-not (Test-Path $Path)) { throw "Log not found: $Path" }

    $rx = '^(?<IP>\S+)\s+\S+\s+\S+\s+\[(?<Time>[^\]]+)\]\s+"(?<Method>\S+)\s+(?<Page>\S+)\s+(?<Protocol>[^"]+)"\s+(?<Response>\d{3})\s+\S+\s+"(?<Referrer>[^"]*)"\s+"(?<UA>[^"]*)"'

    Get-Content -Path $Path | ForEach-Object {
        $m = [regex]::Match($_, $rx)
        if ($m.Success) {
            [pscustomobject]@{
                IP        = $m.Groups['IP'].Value
                Time      = $m.Groups['Time'].Value
                Method    = $m.Groups['Method'].Value
                Page      = $m.Groups['Page'].Value
                Protocol  = $m.Groups['Protocol'].Value
                Response  = [int]$m.Groups['Response'].Value
                Referrer  = $m.Groups['Referrer'].Value
            }
        }
    }
}

# Challenge 3: Filter logs by IOC in Page
function Find-IOCRequests {
    param(
        [Parameter(Mandatory=$true)][object[]]$Logs,
        [Parameter(Mandatory=$true)][object[]]$Indicators
    )
    $alts = $Indicators |
      Where-Object { $_.Pattern } |
      ForEach-Object { [regex]::Escape($_.Pattern) } |
      Where-Object { $_ }

    if (-not $alts) { return @() }
    $rx = '(' + ($alts -join '|') + ')'
    $Logs | Where-Object { $_.Page -match $rx }
}

# helpers
function Demo-Challenge1 { Get-IOCTable | Format-Table -AutoSize }
function Demo-Challenge2 { Get-ApacheAccessLog | Format-Table IP,Time,Method,Page,Protocol,Response,Referrer -AutoSize }
function Demo-Challenge3 {
    $ind  = Get-IOCTable
    $logs = Get-ApacheAccessLog
    Find-IOCRequests -Logs $logs -Indicators $ind |
      Format-Table IP,Time,Method,Page,Protocol,Response,Referrer -AutoSize
}
