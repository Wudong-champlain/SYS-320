#!/bin/bash
# finalC2.bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 <access_log> <ioc_file>"
    exit 1
fi

logfile="$1"
iocfile="$2"

if [ ! -f "$logfile" ]; then
    echo "Log file not found: $logfile"
    exit 1
fi

if [ ! -f "$iocfile" ]; then
    echo "IOC file not found: $iocfile"
    exit 1
fi

# ---- create / empty report.txt ----
: > report.txt

# ---- for each IOC, grep the log and extract fields ----
while IFS= read -r ioc; do
    # skip empty lines
    [ -z "$ioc" ] && continue

    # Find all log lines that contain this IOC indicator
    # Example log format:
    # 10.0.17.5 - - [04/Mar/2024:14:43:50 -0500] "GET /index.php?cmd=etc/passwd HTTP/1.1" ...
    grep -- "$ioc" "$logfile" | \
    awk '{
        ip=$1
        gsub(/\[/, "", $4)   # remove leading '[' from date
        datetime=$4
        page=$7
        print ip, datetime, page
    }' >> report.txt

done < "$iocfile"

echo "Report written to report.txt"
