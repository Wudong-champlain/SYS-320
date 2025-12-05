#!/bin/bash

link="10.0.17.23/IOC.html"

curl=$(curl -sL $link)

toolOutput1=$(echo "$curl" | \
	xmlstarlet sel -t -m "//table/tr[td]" -v "td[1]" -n)

echo "$toolOutput1" > IOC.txt

