#!/bin/bash

# Configuration
SERVICE_NAME="tomcat"
LOG_FILE="/var/log/tomcat_service.log"

# Logging function
log_message() {
    echo "$(date): $1" | tee -a $LOG_FILE
}

# Functions
get_tomcat_pid() {
    echo $(ps -ef | grep '[o]rg.apache.catalina.startup.Bootstrap' | awk '{print $2}')
}

start_tomcat() {
    log_message "Starting Tomcat..."
    if sudo systemctl start $SERVICE_NAME; then
        sleep 3 # Give it a moment to start
        local pid=$(get_tomcat_pid)
        if [[ -n $pid ]]; then
            log_message "Tomcat started with PID $pid."
        else
            log_message "Failed to start Tomcat."
        fi
    else
        log_message "Error executing systemctl start $SERVICE_NAME."
    fi
}

stop_tomcat() {
    local pid=$(get_tomcat_pid)
    log_message "Stopping Tomcat with PID $pid..."
    if sudo systemctl stop $SERVICE_NAME; then
        log_message "Tomcat stopped."
        # Wait for Tomcat to stop before restarting
        while sudo systemctl is-active --quiet $SERVICE_NAME; do
            sleep 1
        done
    else
        log_message "Error executing systemctl stop $SERVICE_NAME."
    fi
}

restart_tomcat() {
    local old_pid=$(get_tomcat_pid)
    stop_tomcat
    log_message "Waiting 60 seconds before attempting to start Tomcat..."
    sleep 60
    start_tomcat
    local new_pid=$(get_tomcat_pid)
    log_message "Tomcat restarted. Old PID was $old_pid. Current PID is $new_pid."
}

# Main script
{
    old_pid=$(get_tomcat_pid)
    if ! sudo systemctl is-active --quiet $SERVICE_NAME; then 
        log_message "Tomcat is not running."
        start_tomcat
    else 
        log_message "Tomcat is running with PID $old_pid."
        restart_tomcat
    fi
} || {
    log_message "An error occurred during the execution of the script."
}
