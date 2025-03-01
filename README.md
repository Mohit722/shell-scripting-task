# shell-scripting-task
This repository have 2 shell scripts for disk usage monitoring and log rotation.

# 1. Disk Usage Monitoring (`disk_monitor.sh`)

Features:
- Checks disk usage for all partitions.
- Sends an email or Slack alert if usage exceeds a configurable threshold.
- Logs script activity to `/var/log/disk_alert.log`.


How to Run:

$ chmod +x disk_monitor.sh

$ ./disk_monitor.sh


To set a custom threshold:

$ DISK_THRESHOLD=80 ./disk_monitor.sh

To schedule it via cron (**Runs every hour**):

$ crontab -e

Add this line:

0 * * * * /path/to/disk_monitor.sh




# 2️. Log Rotation & Archiving (`log_rotation.sh`)

Features:
- Rotates logs larger than 1GB.
- Archives logs older than 3 days and uploads to AWS S3.
- Logs operations to `/var/log/log_rotation.log`.

 How to Run:

$ chmod +x log_rotation.sh

$ ./log_rotation.sh

To schedule it via cron (**Runs daily at midnight**):

$ crontab -e


Add this line:

0 0 * * * /path/to/log_rotation.sh


# Dependencies:
- AWS CLI (for log archiving)
- Slack Webhook (for disk alerts)


