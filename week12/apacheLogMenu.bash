#! /bin/bash

# Point to the active log. If your data is still in .1, change back to .1.
logFile="/var/log/apache2/access.log"

displayAllLogs(){
    cat "$logFile"
}

displayOnlyIPs(){
    cat "$logFile" | cut -d ' ' -f 1 | sort -n | uniq -c | sort -nr
}

# Display only pages (paths). Shows counts per path (most -> least).
displayOnlyPages(){
    # Typical combined log: path is field 7
    cat "$logFile" | awk '{print $7}' | sort | uniq -c | sort -nr
}

# Same as teacher's demo: build "IP DATE" rows, then count.
histogram(){
    local visitsPerDay
    visitsPerDay=$(cat "$logFile" | cut -d " " -f 4,1 | tr -d '[' | sort | uniq)

    :> newtemp.txt
    echo "$visitsPerDay" | while read -r line; do
        # date/time is first field; keep only date (no hour)
        local withoutHours
        withoutHours=$(echo "$line" | cut -d " " -f 1 | cut -d ":" -f 1)
        local IP
        IP=$(echo "$line" | cut -d " " -f 2)
        echo "$IP $withoutHours" >> newtemp.txt
    done

    # prints: COUNT IP DATE
    cat newtemp.txt | sort -n | uniq -c | sort -nr
}

# Only display IPs with >10 visits per day (format like histogram)
frequentVisitors(){
    # Reuse the same derivation as histogram, then filter count>10
    local visitsPerDay
    visitsPerDay=$(cat "$logFile" | cut -d " " -f 4,1 | tr -d '[' | sort | uniq)

    :> newtemp.txt
    echo "$visitsPerDay" | while read -r line; do
        local withoutHours
        withoutHours=$(echo "$line" | cut -d " " -f 1 | cut -d ":" -f 1)
        local IP
        IP=$(echo "$line" | cut -d " " -f 2)
        echo "$IP $withoutHours" >> newtemp.txt
    done

    # Keep rows where COUNT > 10 (adjust the threshold if needed)
    cat newtemp.txt | sort -n | uniq -c | sort -nr | awk '$1 > 10'
}

# Show unique count of IPs that triggered any IOC pattern
suspiciousVisitors(){
    local iocFile="$HOME/SYS-320/week12/ioc.txt"
    if [[ ! -f "$iocFile" ]]; then
        echo "IOC file not found at: $iocFile"
        echo "Create it first (one pattern per line)."
        return
    fi
    # Find log lines matching any IOC, extract IP, count unique per IP
    # Output: COUNT IP
    grep -i -E -f "$iocFile" "$logFile" | awk '{print $1}' | sort -n | uniq -c | sort -nr
}

# ---- Menu ----
while :; do
    echo "Please select an option:"
    echo "[1] Display all Logs"
    echo "[2] Display only IPS"
    echo "[3] Display only Pages"
    echo "[4] Histogram"
    echo "[5] Frequent Visitors"
    echo "[6] Suspicious Visitors"
    echo "[7] Quit"
    read -r userInput
    echo ""

    case "$userInput" in
        7)
            echo "Goodbye"
            break
            ;;
        1)
            echo "Displaying all logs:"
            displayAllLogs
            ;;
        2)
            echo "Displaying only IPS:"
            displayOnlyIPs
            ;;
        3)
            echo "Displaying only Pages:"
            displayOnlyPages
            ;;
        4)
            echo "Histogram:"
            histogram
            ;;
        5)
            echo "Frequent Visitors:"
            frequentVisitors
            ;;
        6)
            echo "Suspicious Visitors:"
            suspiciousVisitors
            ;;
        *)
            echo "Invalid option: $userInput"
            echo "Please enter a number from 1 to 7."
            ;;
    esac
    echo ""
done
