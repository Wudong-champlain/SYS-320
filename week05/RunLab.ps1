# Load functions from same folder
. .\Functions.ps1

# Point to your file (or use localhost if Apache is running)
$source = "C:\xampp\htdocs\Courses2025FA.html"
# $source = "http://localhost/Courses2025FA.html"

# Build table and convert days
$FullTable = Gather-Classes -Uri $source
$FullTable = Convert-DaysToArray -FullTable $FullTable

# (i) & (ii) – show a clean view
$FullTable |
  Select-Object 'Class Code','Title','Days','Time Start','Time End','Instructor','Location' |
  Format-Table -AutoSize

# (iii) – instructors teaching SYS/NET/SEC/FOR/CSI/DAT
$prefixes = 'SYS','NET','SEC','FOR','CSI','DAT'
$prefixRegex = '^(?:' + ($prefixes -join '|') + ')\s'

"`n--- Instructors teaching SYS/NET/SEC/FOR/CSI/DAT ---"
$ITSInstructors =
    $FullTable |
    Where-Object { $_.'Class Code' -match $prefixRegex } |
    Select-Object -ExpandProperty Instructor |
    Sort-Object -Unique
$ITSInstructors

# (iv) – count of classes per instructor (desc by count, then name)
"`n--- ITS Instructors by number of classes ---"
$FullTable |
    Where-Object  { $_.'Class Code' -match $prefixRegex } |
    Group-Object  Instructor |
    Sort-Object   -Property @{Expression='Count';Descending=$true}, @{Expression='Name';Descending=$false} |
    Select-Object Count, Name |
    Format-Table -AutoSize
