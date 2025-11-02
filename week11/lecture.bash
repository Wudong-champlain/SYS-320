#!/bin/bash
allLogs=""
file="/var/log/apache2/access.log"

getAllLogs(){
  allLogs=$(cat "$file" | cut -d' ' -f1,4,7 | tr -d "[")
}

ips(){
  ipsAccessed=$(echo "$allLogs" | cut -d' ' -f1)
  echo "$ipsAccessed"
}

pageCount(){
  pages=$(echo "$allLogs" | awk '{print $3}')        # field 3 is the path like /index.html
  echo "$pages" | sort | uniq -c | sort -nr
}

getAllLogs
echo "IP list:"
ips
echo
echo "Page counts:"
pageCount

