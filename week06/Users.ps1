<# Users.ps1
*************************************************************
   Functions that manage local users
************************************************************* #>

function Get-EnabledUsers {
    Get-LocalUser | Where-Object Enabled | Select-Object Name,SID
}

function Get-DisabledUsers {
    Get-LocalUser | Where-Object { -not $_.Enabled } | Select-Object Name,SID
}

function New-LocalUserSafe {
    param(
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [securestring]$Password
    )
    if (Get-LocalUser -Name $Name -ErrorAction SilentlyContinue) {
        throw "User '$Name' already exists."
    }
    New-LocalUser -Name $Name -Password $Password -FullName $Name -PasswordNeverExpires:$true
}

function Remove-LocalUserSafe {
    param([Parameter(Mandatory)] [string]$Name)
    $u = Get-LocalUser -Name $Name -ErrorAction SilentlyContinue
    if (-not $u) { throw "User '$Name' not found." }
    Remove-LocalUser -Name $Name
}

function Disable-LocalUserSafe {
    param([Parameter(Mandatory)] [string]$Name)
    $u = Get-LocalUser -Name $Name -ErrorAction SilentlyContinue
    if (-not $u) { throw "User '$Name' not found." }
    Disable-LocalUser -Name $Name
}

function Enable-LocalUserSafe {
    param([Parameter(Mandatory)] [string]$Name)
    $u = Get-LocalUser -Name $Name -ErrorAction SilentlyContinue
    if (-not $u) { throw "User '$Name' not found." }
    Enable-LocalUser -Name $Name
}
