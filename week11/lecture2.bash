#!/bin/bash
file="/var/log/apache2/access.log"

countingCurlAccess(){
  # Count curl accesses grouped by IP and curl user-agent
  # Output looks like: 21 10.0.17.6 "curl/7.81.0"
  grep -h 'curl/' "$file" | awk '{print $1, $NF}' | sort | uniq -c | sort -nr
}

countingCurlAccess
