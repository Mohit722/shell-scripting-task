#!/bin/bash

# Default values
THRESHOLD=85
EMAIL="email@example.com"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/webhook/url"
LOG_FILE="/var/log/disk_alert.log"
DRY_RUN=false

# Parse command-line arguments
while getopts "t:e:s:l:d" opt; do
  case $opt in
    t) THRESHOLD="$OPTARG" ;;
    e) EMAIL="$OPTARG" ;;
    s) SLACK_WEBHOOK_URL="$OPTARG" ;;
    l) LOG_FILE="$OPTARG" ;;
    d) DRY_RUN=true ;;
    *) echo "Usage: $0 [-t threshold] [-e email] [-s slack_webhook] [-l log_file] [-d dry_run]" >&2
       exit 1 ;;
  esac
done

# Check dependencies
check_dependencies() {
  if ! command -v mail &> /dev/null; then
    echo "Error: 'mail' command not found. Please install it."
    exit 1
  fi
  if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' command not found. Please install it."
    exit 1
  fi
}

# Rotate logs
rotate_logs() {
  local max_size=1048576  # 1MB
  if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt $max_size ]; then
    mv "$LOG_FILE" "${LOG_FILE}.1"
  fi
}

# Alert function
alert() {
  message="$1"
  hostname=$(hostname)
  full_message="Host: $hostname\n$message"
  echo "$(date): $full_message" >> "$LOG_FILE"
  if [ "$DRY_RUN" = false ]; then
    echo -e "$full_message" | mail -s "Disk Usage Alert" "$EMAIL"
    curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$full_message\"}" "$SLACK_WEBHOOK_URL"
  else
    echo "Dry Run: Alert would be sent - $full_message"
  fi
}

# Check disk usage
check_disk_usage() {
  local alert_messages=()
  df -h | awk 'NR>1 && $1 !~ /tmpfs|devtmpfs/ {print $5 " " $6}' | while read output; do
    usage=$(echo $output | awk '{print $1}' | sed 's/%//')
    partition=$(echo $output | awk '{print $2}')
    if [ "$usage" -ge "$THRESHOLD" ]; then
      alert_messages+=("Disk usage is at $usage% on $partition")
    fi
  done

  if [ ${#alert_messages[@]} -gt 0 ]; then
    alert "Disk Usage Alerts:\n$(printf '%s\n' "${alert_messages[@]}")"
  fi
}

# Main
check_dependencies
rotate_logs
check_disk_usage





# The script is more flexible, user-friendly. It includes features like command-line arguments, error handling, log rotation, and dry run mode, making it suitable for production use.
