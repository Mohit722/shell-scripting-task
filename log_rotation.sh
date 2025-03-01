#!/bin/bash

# Log Rotation & Archiving
LOG_DIR="/var/log/myapp"
ROTATION_LOG="/var/log/log_rotation.log"
MAX_SIZE=1073741824  # 1GB in bytes
RETENTION_DAYS=3
S3_BUCKET="s3://our-bucket-name"

# Check if log directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "$(date): Log directory $LOG_DIR does not exist." >> $ROTATION_LOG
    exit 1
fi

rotate_logs() {
    find $LOG_DIR -type f -name "*.log" | while read log_file; do
        size=$(stat -c %s "$log_file")
        if [ "$size" -gt "$MAX_SIZE" ]; then
            mv "$log_file" "$log_file.1"
            echo "$(date): Rotated $log_file" >> $ROTATION_LOG
        fi
    done
}

archive_old_logs() {
    if ! command -v aws &> /dev/null; then
        echo "$(date): AWS CLI not found. Cannot upload logs." >> $ROTATION_LOG
        exit 1
    fi

    find $LOG_DIR -type f -mtime +$RETENTION_DAYS -name "*.log*" | tar -czf /tmp/logs_archive.tar.gz -T - && \
    if aws s3 cp /tmp/logs_archive.tar.gz $S3_BUCKET; then
        echo "$(date): Successfully uploaded logs to S3." >> $ROTATION_LOG
    else
        echo "$(date): Upload to S3 failed." >> $ROTATION_LOG
    fi
    
    find $LOG_DIR -type f -mtime +$RETENTION_DAYS -delete
    echo "$(date): Archived and deleted old logs." >> $ROTATION_LOG
}

rotate_logs
archive_old_logs
