#!/bin/bash
# When userlogs.bash is accessed, this script appends a timestamp to fileaccesslog.txt
# and emails the contents (timestamps only) with subject "Access".

logdir="/home/Wu/SYS-320/week13"
logfile="$logdir/fileaccesslog.txt"

# timestamp using '-' instead of ':' for email safety (matches teacher note)
ts=$(date +"%a %b %d %I-%M-%S %p %Z %Y")

echo "File was accessed $ts" >> "$logfile"

# Email the timestamps only (strip the leading phrase)
# Use absolute path to mail so incron can find it
/usr/bin/sed 's/^File was accessed //' "$logfile" | /usr/bin/mail -s "Access" wu.dong@mymail.champlain.edu
