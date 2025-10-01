. (Join-Path $PSScriptRoot 'String-Helper.ps1')

<# Logon/Logoff (System log, Winlogon source) #>
function Get-LogInAndOffs {
    param([Parameter(Mandatory)] [int]$Days)
    $after = (Get-Date).AddDays(-$Days)
    $events = Get-EventLog -LogName System `
                           -Source 'Microsoft-Windows-Winlogon' `
                           -After $after

    $out = @()
    foreach ($e in $events) {
        $evt = switch ($e.InstanceId) {
            7001 { 'Logon'  }
            7002 { 'Logoff' }
            default { $null }
        }
        if ($evt) {
            # The user string is usually in ReplacementStrings[1] for these events
            $user = $e.ReplacementStrings | Select-Object -Index 1
            if (-not $user) { $user = '' }
            $out += [pscustomobject]@{
                Time  = $e.TimeGenerated
                Id    = $e.InstanceId
                Event = $evt
                User  = $user
            }
        }
    }
    $out
}

<# Failed Logins (Security 4625) #>
function Get-FailedLogins {
    param([Parameter(Mandatory)] [int]$Days)
    $start = (Get-Date).AddDays(-$Days)
    $evts = Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4625; StartTime=$start } -ErrorAction SilentlyContinue

    $out = @()
    foreach ($e in $evts) {
        # You can parse via Message + helper (as assignment suggests)
        # Build DOMAIN\user from the message lines
        $usrLines = Get-MatchingLines -Contents $e.Message -Pattern '*Account Name*'
        $dmnLines = Get-MatchingLines -Contents $e.Message -Pattern '*Account Domain*'

        # pick a sensible instance (skip the first which is often 'Security ID' block)
        $usr = ''
        $dmn = ''
        if ($usrLines.Count -ge 1) {
            $usr = ($usrLines[-1] -split ':',2)[-1].Trim()
        }
        if ($dmnLines.Count -ge 1) {
            $dmn = ($dmnLines[-1] -split ':',2)[-1].Trim()
        }
        $user = if ($dmn) { "$dmn\$usr" } else { $usr }

        $out += [pscustomobject]@{
            Time  = $e.TimeCreated
            Id    = $e.Id
            Event = 'Failed'
            User  = $user
        }
    }
    $out
}

<# Users with > Threshold failed logins in last N days #>
function Get-AtRiskUsers {
    param(
        [Parameter(Mandatory)] [int]$Days,
        [Parameter(Mandatory)] [int]$Threshold = 10
    )
    $fails = Get-FailedLogins -Days $Days
    $fails | Group-Object User | Where-Object { $_.Count -gt $Threshold } |
        Sort-Object Count -Descending |
        Select-Object @{n='Count';e={$_.Count}}, @{n='User';e={$_.Name}}
}
