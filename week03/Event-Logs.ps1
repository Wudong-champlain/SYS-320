<# -----------------------------------------------------------
   - Get-UserLogonLogoff  (Application\Winlogon 7001/7002; fallback Security 4624/4634)
   - Get-ShutdownEvents   (System 6006)
   - Get-StartupEvents    (System 6005)
   Returns objects with: Time, Id, Event, User
----------------------------------------------------------- #>

function Get-UserLogonLogoff {
    [CmdletBinding()]
    param([Parameter(Mandatory)][int]$Days)

    $after = (Get-Date).AddDays(-[math]::Abs($Days))

# Winlogon 7001/7002
    $loginouts = Get-EventLog -LogName Application `
                               -Source 'Microsoft-Windows-Winlogon' `
                               -After $after -ErrorAction SilentlyContinue
    if (-not $loginouts) {
        # some boxes use plain "Winlogon" as the source
        $loginouts = Get-EventLog -LogName Application `
                                   -Source 'Winlogon' `
                                   -After $after -ErrorAction SilentlyContinue
    }

    $loginoutsTable = @() 

    for ($i = 0; $i -lt $loginouts.Count; $i++) {
        $eventName = ""
        if ($loginouts[$i].InstanceId -eq 7001) { $eventName = "Logon"  }
        if ($loginouts[$i].InstanceId -eq 7002) { $eventName = "Logoff" }

        if (-not $eventName) { continue }  # ignore non-7001/7002 rows

# Get SID from ReplacementStrings and translate to DOMAIN\User
        $sidString = $loginouts[$i].ReplacementStrings |
                     Where-Object { $_ -match '^S-\d-\d+(-\d+){1,}$' } |
                     Select-Object -First 1

        $user = $null
        if ($sidString) {
            try {
                $sid  = New-Object System.Security.Principal.SecurityIdentifier($sidString)
                $user = $sid.Translate([System.Security.Principal.NTAccount]).Value
            } catch { $user = $sidString }          # fallback to showing SID
        }

# custom object
        $loginoutsTable += [pscustomobject]@{
            "Time"  = $loginouts[$i].TimeGenerated
            "Id"    = $loginouts[$i].InstanceId
            "Event" = $eventName
            "User"  = $user
        }
    }

# fallback to Security 4624/4634
    if (-not $loginoutsTable -or $loginoutsTable.Count -eq 0) {
        $raw = Get-WinEvent -FilterHashtable @{
            LogName   = 'Security'
            Id        = 4624,4634
            StartTime = $after
        } -ErrorAction SilentlyContinue

        foreach ($ev in ($raw | Sort-Object TimeCreated)) {
            $xml = [xml]$ev.ToXml()
            $kv  = @{}
            foreach ($d in $xml.Event.EventData.Data) { $kv[$d.Name] = $d.'#text' }

            $isLogon  = ($ev.Id -eq 4624)
            $isLogoff = ($ev.Id -eq 4634)
            if (-not ($isLogon -or $isLogoff)) { continue }

         
            $logonType = [int]($kv['LogonType'])
            if ($logonType -notin 2,7,10) { continue }

            $name = $kv['TargetUserName']
            $dom  = $kv['TargetDomainName']
            if (-not $name -or $name -match '\$$' -or $name -eq 'SYSTEM') { continue }

            $loginoutsTable += [pscustomobject]@{
                Time  = $ev.TimeCreated
                Id    = $ev.Id
                Event = if ($isLogon) { 'Logon' } else { 'Logoff' }
                User  = if ($dom) { "$dom\$name" } else { $name }
            }
        }
    }

    $loginoutsTable | Sort-Object Time -Descending
}

function Get-ShutdownEvents {
    [CmdletBinding()]
    param([Parameter(Mandatory)][int]$Days)

    $after = (Get-Date).AddDays(-[math]::Abs($Days))
    Get-WinEvent -FilterHashtable @{
        LogName   = 'System'
        Id        = 6006
        StartTime = $after
    } -ErrorAction SilentlyContinue |
    ForEach-Object {
        [pscustomobject]@{
            Time  = $_.TimeCreated
            Id    = $_.Id
            Event = 'Shutdown'
            User  = 'System'
        }
    } | Sort-Object Time -Descending
}

function Get-StartupEvents {
    [CmdletBinding()]
    param([Parameter(Mandatory)][int]$Days)

    $after = (Get-Date).AddDays(-[math]::Abs($Days))
    Get-WinEvent -FilterHashtable @{
        LogName   = 'System'
        Id        = 6005
        StartTime = $after
    } -ErrorAction SilentlyContinue |
    ForEach-Object {
        [pscustomobject]@{
            Time  = $_.TimeCreated
            Id    = $_.Id
            Event = 'Startup'
            User  = 'System'
        }
    } | Sort-Object Time -Descending
}