#Zombie Process Cleanup Script
bash
Copy
Edit

#!/bin/bash

echo "=== Detecting Zombie Processes ==="
# Find zombie processes
zombies=$(ps aux | awk '$8=="Z" {print $2, $11, $1}')

if [[ -z "$zombies" ]]; then
    echo "No zombie processes found."
    exit 0
fi

echo "Zombie Processes Found:"
echo "PID   COMMAND   USER"
echo "$zombies"

echo "=== Identifying Parent Processes ==="
while read -r pid cmd user; do
    ppid=$(ps -o ppid= -p "$pid")

    if [[ -n "$ppid" ]]; then
        echo "Zombie PID: $pid (Command: $cmd) has Parent PID: $ppid"
        echo "Attempting to notify parent process (PPID: $ppid)..."
        
        # Send SIGCHLD signal to the parent process
        kill -SIGCHLD "$ppid" 2>/dev/null
        
        # Wait for a second and check if the zombie is still present
        sleep 1
        if ps -o stat= -p "$pid" | grep -q 'Z'; then
            echo "Parent process did not clean up the zombie. Killing Parent PID: $ppid..."
            kill -9 "$ppid"
        else
            echo "Zombie process $pid successfully cleaned up."
        fi
    fi
done <<< "$zombies"

echo "Zombie cleanup completed!"
