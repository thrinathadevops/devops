# -----------------------------------------------------------------------------------
# File Name    : Automating_Tomcat_Server_Restart
# Author       : Thrinatha Reddy
# Description  : Ensuring that the Tomcat server is always running and can be restarted smoothly during deployments.
# Call Syntax  : ./tomcat_server_restart.sh
# Last Modified: 22-JUN-2024
# -----------------------------------------------------------------------------------



#!/bin/bash

# Configuration
TOMCAT_PATH="/opt/tomcat/bin"
START_SCRIPT="startup.sh"
STOP_SCRIPT="shutdown.sh"
LOG_FILE="/var/log/tomcat_restart.log"

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
    if sh "$TOMCAT_PATH/$START_SCRIPT"; then
        sleep 3 # Give it a moment to start
        local pid=$(get_tomcat_pid)
        if [[ -n $pid ]]; then
            log_message "Tomcat started with PID $pid."
        else
            log_message "Failed to start Tomcat."
        fi
    else
        log_message "Error executing $START_SCRIPT."
    fi
}

stop_tomcat() {
    local pid=$(get_tomcat_pid)
    if [[ -n $pid ]]; then
        log_message "Stopping Tomcat with PID $pid..."
        if sh "$TOMCAT_PATH/$STOP_SCRIPT"; then
            log_message "Tomcat stopped."
            # Wait for Tomcat to stop before restarting
            while [[ -n $(get_tomcat_pid) ]]; do
                sleep 1
            done
        else
            log_message "Error executing $STOP_SCRIPT."
        fi
    else
        log_message "Tomcat is not running."
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
    if [[ -z $old_pid ]]; then 
        log_message "Tomcat is not running."
        start_tomcat
    else 
        log_message "Tomcat is running with PID $old_pid."
        restart_tomcat
    fi
} || {
    log_message "An error occurred during the execution of the script."
}
