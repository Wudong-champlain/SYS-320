#!/bin/bash

# Course scraping script
# It reads the local Courses-1.html file and creates courses.txt
# in a semicolon-separated format:
# Number;Course Title;Credits;Seats;Days;Times;Instructor;Dates;Prereqs;Location;

HTML_FILE="Courses-1.html"
OUT_FILE="courses.txt"

# Safety check
if [ ! -f "$HTML_FILE" ]; then
  echo "Error: $HTML_FILE not found in $(pwd)"
  exit 1
fi

# Clean up HTML and extract table rows as ';' separated text
cat "$HTML_FILE" \
  | xmlstarlet fo --html --recover --dropdtd 2>/dev/null \
  | xmlstarlet sel -T -t \
      -m "//table//tr" \
        -m "th|td" -v "normalize-space()" -o ";" -b \
        -n \
  > "$OUT_FILE"
