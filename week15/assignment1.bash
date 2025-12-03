#!/bin/bash
clear

# Always regenerate courses.txt when the script starts
bash Courses.bash

courseFile="courses.txt"

# -------- Helper to print one course line nicely --------
printCourse() {
    local line="$1"
    local num title days time instr room

    num=$(echo "$line"   | cut -d';' -f1)
    title=$(echo "$line" | cut -d';' -f2)
    days=$(echo "$line"  | cut -d';' -f5)
    time=$(echo "$line"  | cut -d';' -f6)
    instr=$(echo "$line" | cut -d';' -f7)
    room=$(echo "$line"  | cut -d';' -f10)

    echo "$num | $title | $days | $time | $instr | $room"
}

# -------- [1] Display courses of an instructor --------
displayCoursesOfInst() {
    echo -n "Please input an Instructor Full Name: "
    read instName
    echo
    echo "Courses of $instName :"

    grep -i "$instName" "$courseFile" | while read -r line; do
        printCourse "$line"
    done
    echo
}

# -------- [2] Display course count of instructors --------
courseCountOfInsts() {
    echo
    echo "Course-Instructor Distribution"
    echo

    cut -d';' -f7 "$courseFile" \
      | grep -vi "^Instructor" \
      | sort \
      | uniq -c \
      | sort -nr

    echo
}

# -------- [3] Display courses of a classroom --------
displayCoursesOfClassroom() {
    echo -n "Please input a Class Name (e.g., JOYC 310): "
    read className
    echo
    echo "Courses in $className :"

    grep -i "$className" "$courseFile" | while read -r line; do
        printCourse "$line"
    done
    echo
}

# -------- [4] Display available courses of a subject --------
displayCoursesOfSubject() {
    echo -n "Please input a Subject Name (e.g., SEC): "
    read subj
    echo
    echo "Available courses in $subj :"

    grep -i "^${subj} " "$courseFile" | while read -r line; do
        printCourse "$line"
    done
    echo
}

# ---------------- Main Menu Loop ----------------
while true; do
    echo "Please select an option:"
    echo "[1] Display courses of an instructor"
    echo "[2] Display course count of instructors"
    echo "[3] Display courses of a classroom"
    echo "[4] Display available courses of subject"
    echo "[5] Exit"
    echo
    echo -n "Your choice: "
    read choice
    echo

    case "$choice" in
        1) displayCoursesOfInst ;;
        2) courseCountOfInsts ;;
        3) displayCoursesOfClassroom ;;
        4) displayCoursesOfSubject ;;
        5) echo "Goodbye."; exit 0 ;;
        *) echo "Invalid option, please try again."; echo ;;
    esac
done

