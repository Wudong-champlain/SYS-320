#!/bin/bash
# Ping every IP in the given /24 and print ONLY the active IP addresses (one per line)
# Usage: bash ActiveIPList.bash 10.0.17

# If no input was given, print usage and exit
[ -z "$1" ] && echo "Usage: ActiveIPList.bash <Prefix>" && exit 1

prefix="$1"

# Verify input length (≥ 5 characters)
if [ ${#prefix} -lt 5 ]; then
  printf "Prefix length is too short\nPrefix example: 10.0.17\n"
  exit 1
fi

for i in {1..254}
do
  ip="$prefix.$i"
  # -c 1 : send 1 packet
  # -W 1 : wait 1 second max for a reply
  # -n   : numeric output (no DNS)
  if ping -c 1 -W 1 -n "$ip" > /dev/null 2>&1; then
    echo "$ip"
    # Alternative using grep -oE (as hinted): 
    # ping -c 1 -W 1 -n "$ip" | grep -m1 -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1
  fi
done
