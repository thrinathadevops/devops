#!/bin/bash

# Server IPs or hostnames
TARGET_SERVER="192.168.1.12"
# Directories containing the logs
LOG_DIRS="/opt/alert" # Modify as needed
# Directory where archives will be stored temporarily in the local server before transfer
ARCHIVE_DIR="/opt"
# Date format
DATE=$(date +"%Y%m%d")
# Temporary directory for intermediate operations
TEMP_DIR_ROOT="/opt/log_archives_$DATE"
mkdir -p "$TEMP_DIR_ROOT"

# Get the current IP address and extract the last segment
IP_LAST_SEGMENT=$(hostname -I | awk '{split($1, a, "."); print a[4]}')

# Check if TEMP_DIR_ROOT was created successfully
if [ ! -d "$TEMP_DIR_ROOT" ]; then
    echo "Error: Failed to create temporary directory $TEMP_DIR_ROOT"
    exit 1
fi

# Get current time in seconds since epoch
CURRENT_TIME=$(date +%s)

# Function to convert log filename to seconds since epoch
log_filename_to_epoch() {
    local filename=$1
    local datetime_part=$(echo "$filename" | grep -oP '\d{2}\.\d{2}\.\d{2}_\d{2}\.\d{2}\.\d{2}')
    if [[ -n $datetime_part ]]; then
        local log_time=$(date -d "${datetime_part:0:2}-${datetime_part:3:2}-${datetime_part:6:2} ${datetime_part:9:2}:${datetime_part:12:2}:${datetime_part:15:2}" +%s 2>/dev/null)
        echo $log_time
    else
        echo "0"
    fi
}

# Function to handle failures
handle_failure() {
    local message=$1
    local reasons=$2
    echo "Error: $message"
    echo "Reasons: $reasons"
    exit 1
}

# Function to check network issues
check_network_issues() {
    local server=$1
    local issues=""

    # Ping check
    if ping -c 3 "$server" > /dev/null 2>&1; then
        issues+="Ping to $server: Success\n"
    else
        issues+="Ping to $server failed.\n"
    fi

    # Telnet check on port 22 (SSH)
    if command -v telnet &> /dev/null; then
        telnet_output=$(echo "exit" | telnet "$server" 22 2>&1)
        if echo "$telnet_output" | grep -q "Connected to"; then
            issues+="Telnet to $server on port 22: Success\n"
        else
            issues+="Telnet to $server on port 22 failed.\n"
        fi
    else
        issues+="Telnet command not found.\n"
    fi

    echo "$issues"
}

# Main loop to archive and transfer logs
errors=""
for LOG_DIR in $LOG_DIRS; do
    if [ ! -d "$LOG_DIR" ]; then
        echo "Warning: Log directory $LOG_DIR does not exist. Skipping."
        continue
    fi
    LOG_TYPE=$(basename "$LOG_DIR")
    ARCHIVE_NAME="${LOG_TYPE}_logs_${DATE}_${IP_LAST_SEGMENT}.tar.gz"
    TEMP_DIR="$TEMP_DIR_ROOT/$LOG_TYPE"
    mkdir -p "$TEMP_DIR"

    if [ ! -d "$TEMP_DIR" ]; then
        echo "Error: Failed to create temporary directory $TEMP_DIR"
        continue
    fi

    find "$LOG_DIR" -type f \( -name "SystemOut_*.log" -o -name "SystemErr_*.log" \) | while read -r LOG_FILE; do
        LOG_FILENAME=$(basename "$LOG_FILE")
        LOG_FILE_EPOCH=$(log_filename_to_epoch "$LOG_FILENAME")
        if [ "$LOG_FILE_EPOCH" -ne "0" ]; then
            TIME_DIFF=$((CURRENT_TIME - LOG_FILE_EPOCH))
            if [ $TIME_DIFF -le 86400 ]; then # 86400 seconds in 24 hours
                cp "$LOG_FILE" "$TEMP_DIR"
                if [[ $? -ne 0 ]]; then
                    errors+="Failed to copy $LOG_FILE to $TEMP_DIR. "
                fi
            fi
        fi
    done

    if [ "$(ls -A $TEMP_DIR)" ]; then
        tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" -C "$TEMP_DIR" .
        if [[ $? -ne 0 ]]; then
            handle_failure "Failed to create archive $ARCHIVE_NAME" "$errors"
        fi

        network_issues=$(check_network_issues "$TARGET_SERVER")

        if echo "$network_issues" | grep -q "Ping to $TARGET_SERVER: Success" && echo "$network_issues" | grep -q "Telnet to $TARGET_SERVER on port 22: Success"; then
            echo "Network connectivity to $TARGET_SERVER is stable."
        else
            handle_failure "Network issues detected" "$network_issues"
        fi

        scp_error_log="/opt/scp_error.log"
        scp -q "$ARCHIVE_DIR/$ARCHIVE_NAME" root@"$TARGET_SERVER":/opt/ > "$scp_error_log" 2>&1
        if [[ $? -ne 0 ]]; then
            scp_error=$(cat "$scp_error_log")
            errors+="Failed to transfer $ARCHIVE_NAME to $TARGET_SERVER. SCP error: $scp_error "
            continue  # Skip deletion and final message if SCP failed
        fi
    else
        echo "No log files to archive for $LOG_TYPE"
    fi

    rm -rf "$TEMP_DIR"
done

rm -rf "$TEMP_DIR_ROOT"

if [ -z "$errors" ]; then
    echo "Log archival and transfer process completed successfully."
else
    echo "Log archival and transfer process completed with errors: $errors"
fi
