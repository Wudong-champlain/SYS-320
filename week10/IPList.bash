#!/bin/bash
# List all the IPs in the given network prefix (/24 only)
# Usage: bash IPList.bash 10.0.17

# If no input was given, print usage and exit
[ -z "$1" ] && echo "Usage: IPList.bash <Prefix>" && exit 1

# Prefix is the first input taken (e.g., 10.0.17)
prefix="$1"

# Verify input length (at least 5 chars, e.g., "10.0.")
if [ ${#prefix} -lt 5 ]; then
  printf "Prefix length is too short\nPrefix example: 10.0.17\n"
  exit 1
fi

# Print every IP address from .1 to .254 in that /24
for i in {1..254}
do
  echo "$prefix.$i"
done

