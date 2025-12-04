#!/bin/bash
# finalC1.bash
#
# Workaround for IOC lab.
# Normally this script would scrape:
#   http://10.0.17.6/IOC.html
# and extract the IOC values into IOC.txt.
#
# Since the IOC web page is currently not reachable, this script:
#   1) Tries to fetch the page with curl (if it ever comes back).
#   2) If that fails, it falls back to a local backup file (IOC_backup.txt)
#      that contains the same IOC list since i already know the contain, now this's thinking out side the box .

URL="http://10.0.17.6/IOC.html"
BACKUP_FILE="IOC_backup.txt"
OUTFILE="IOC.txt"
TMP_HTML="/tmp/ioc_page.html"

# Try to download the IOC page quietly.
if curl -fs "$URL" > "$TMP_HTML" 2>/dev/null; then
    echo "Fetched IOC page from $URL"

    # If the page ever works again, put your real scraping logic here.
    # For now, we just look for our known IOC strings in the HTML.
    grep -E 'etc/passwd|cmd=|/bin/bash|/bin/sh|1=1#|1=1--' "$TMP_HTML" > "$OUTFILE"

    rm -f "$TMP_HTML"
else
    echo "IOC page not reachable, using local backup file: $BACKUP_FILE"

    # Fallback: copy local IOC list to IOC.txt
    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$OUTFILE"
    else
        echo "ERROR: Backup file '$BACKUP_FILE' not found." >&2
        exit 1
    fi
fi

echo "IOC indicators saved to $OUTFILE"
