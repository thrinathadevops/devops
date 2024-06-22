#!/bin/bash

# Directories containing the logs
LOG_DIRS="/opt/alert" # Modify as needed
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

# Function to delete logs older than 7 days
delete_old_logs() {
    local log_dir=$1
    local errors=""
    local deleted_logs=""
    local logs_deleted=false

    while IFS= read -r -d '' LOG_FILE; do
        LOG_FILENAME=$(basename "$LOG_FILE")
        LOG_FILE_EPOCH=$(log_filename_to_epoch "$LOG_FILENAME")
        if [ "$LOG_FILE_EPOCH" -ne "0" ]; then
            TIME_DIFF=$((CURRENT_TIME - LOG_FILE_EPOCH))
            if [ $TIME_DIFF -gt 604800 ]; then # 604800 seconds in 7 days
                if rm "$LOG_FILE"; then
                    deleted_logs+="$LOG_FILENAME\n"
                    logs_deleted=true
                else
                    errors+="Failed to delete $LOG_FILE. Ensure you have the correct permissions. "
                fi
            fi
        else
            errors+="Failed to parse date from $LOG_FILENAME. "
        fi
    done < <(find "$log_dir" -type f \( -name "SystemOut_*.log" -o -name "SystemErr_*.log" \) -print0)

    if [ "$logs_deleted" = true ]; then
        echo -e "Deleted logs:\n$deleted_logs"
    else
        echo "No logs were deleted."
    fi

    if [ -n "$errors" ]; then
        echo "Log deletion process completed with errors: $errors"
    fi
}

# Main loop to delete old logs
for LOG_DIR in $LOG_DIRS; do
    delete_old_logs "$LOG_DIR"
done

# Final message
echo "Log deletion process completed."
