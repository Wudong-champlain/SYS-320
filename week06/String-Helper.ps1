<# String-Helper
*************************************************************
   This script contains functions that help with String/Match/Search
   operations. 
************************************************************* 
#>


<# ******************************************************
   Functions: Get Matching Lines
   Input:   1) Text with multiple lines  
            2) Keyword
   Output:  1) Array of lines that contain the keyword
********************************************************* #>
function Get-MatchingLines {
    param(
        [Parameter(Mandatory)] [string]$Contents,
        [Parameter(Mandatory)] [string]$Pattern
    )
    $lines = @()
    $split = $Contents -split [Environment]::NewLine
    foreach ($ln in $split) {
        if (-not [string]::IsNullOrWhiteSpace($ln)) {
            if ($ln -ilike $Pattern) { $lines += $ln }
        }
    }
    return $lines
}