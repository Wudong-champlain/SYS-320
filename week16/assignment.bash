#!/bin/bash

# assignment.bash
# Scrape temperature + pressure tables from 10.0.17.47/Assignment.html
# and print:  PRESSURE  TEMPERATURE  DATE-TIME  (one row per reading)


URL="http://10.0.17.47/Assignment.html"

# 1. Get the HTML from the web page
html=$(curl -s "$URL")

# 2. Use xmlstarlet to clean the HTML and make it easier to parse
clean_html=$(echo "$html" | xmlstarlet fo --html --recover --dropdtd 2>/dev/null)

# 3. Extract columns as separate newline-separated lists

# Temperatures: first table, first column (skip header row)
temps=$(
  echo "$clean_html" \
    | xmlstarlet sel -T -t \
        -m "//table[1]//tr[position()>1]/td[1]" \
        -v "normalize-space()" -n
)

# Date-Time values: first table, second column (skip header row)
dates=$(
  echo "$clean_html" \
    | xmlstarlet sel -T -t \
        -m "//table[1]//tr[position()>1]/td[2]" \
        -v "normalize-space()" -n
)

# Pressures: second table, first column (skip header row)
pressures=$(
  echo "$clean_html" \
    | xmlstarlet sel -T -t \
        -m "//table[2]//tr[position()>1]/td[1]" \
        -v "normalize-space()" -n
)

# 4. Count how many readings we have (number of lines in one of the lists)
count=$(echo "$dates" | wc -l)

# 5. Loop through each line and print: pressure temperature date-time
i=1
while [ "$i" -le "$count" ]; do
  temp_i=$(echo "$temps"     | head -n "$i" | tail -n 1)
  date_i=$(echo "$dates"     | head -n "$i" | tail -n 1)
  press_i=$(echo "$pressures"| head -n "$i" | tail -n 1)

  echo "$press_i $temp_i $date_i"

  i=$((i+1))
done

