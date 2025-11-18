#! /bin/bash

authfile="/var/log/auth.log"

function getLogins(){
 logline=$(cat "$authfile" | grep "systemd-logind" | grep "New session")
 dateAndUser=$(echo "$logline" | cut -d' ' -f1,2,11 | tr -d '\.')
 echo "$dateAndUser"
}

# Todo - 1: Get failed logins
function getFailedLogins(){
 # Grab lines with failed password attempts
 fails=$(grep "Failed password" "$authfile")

 # Show: Month Day Username IP (fields 1,2,9,11 in auth.log)
 echo "$fails" | awk '{print $1, $2, $9, $11}' | tr -d '\.'
}

# Sending logins as email
echo "To: wu.dong@mymail.champlain.edu" > emailform.txt
echo "Subject: Logins" >> emailform.txt
getLogins >> emailform.txt
cat emailform.txt | ssmtp wu.dong@mymail.champlain.edu

# Todo - 2: Send failed logins as email to yourself
echo "To: wu.dong@mymail.champlain.edu" > failedform.txt
echo "Subject: Failed Logins" >> failedform.txt
getFailedLogins >> failedform.txt
cat failedform.txt | ssmtp wu.dong@mymail.champlain.edu
