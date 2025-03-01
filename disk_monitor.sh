#!/bin/bash

# Disk Usage Monitoring & Alerting
LOG_FILE="/var/log/disk_alert.log"
THRESHOLD=${DISK_THRESHOLD:-85}  # We are configure threshold via environment variable
EMAIL="email@example.com"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/webhook/url"

check_disk_usage() {
    echo "$(date): Checking disk usage..." >> $LOG_FILE
    df -h | awk 'NR>1 {print $5 " " $6}' | while read output;
    do
        usage=$(echo $output | awk '{print $1}' | sed 's/%//')
        partition=$(echo $output | awk '{print $2}')
        if [ "$usage" -ge "$THRESHOLD" ]; then
            alert "Disk usage is at $usage% on $partition"
        fi
    done
}

alert() {
    message="$1"
    echo "$(date): $message" >> $LOG_FILE  # Logging the alert message
    echo "$message" | mail -s "Disk Usage Alert" $EMAIL
    curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$message\"}" $SLACK_WEBHOOK_URL
}

check_disk_usage
