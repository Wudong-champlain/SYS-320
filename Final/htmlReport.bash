#!/bin/bash
# htmlReport.bash
# Convert report.txt into an HTML table and move to /var/www/html/report.html

REPORT_TXT="report.txt"
HTML_TEMP="report.html"
HTML_DEST="/var/www/html/report.html"

if [ ! -f "$REPORT_TXT" ]; then
  echo "report.txt not found. Run finalC2.bash first."
  exit 1
fi

echo "[-] Building HTML report from $REPORT_TXT ..."

{
  echo "<html>"
  echo "<head><title>IOC Report</title></head>"
  echo "<body>"
  echo "<h3>Access logs with IOC indicators:</h3>"
  echo "<table border=\"1\">"

  while read -r ip dt path; do
    [ -z "$ip" ] && continue
    echo "  <tr><td>$ip</td><td>$dt</td><td>$path</td></tr>"
  done < "$REPORT_TXT"

  echo "</table>"
  echo "</body>"
  echo "</html>"
} > "$HTML_TEMP"

echo "[-] Moving $HTML_TEMP to $HTML_DEST ..."
mv "$HTML_TEMP" "$HTML_DEST"

echo "[+] Done. Open this in your browser:"
echo "    http://localhost/report.html"
