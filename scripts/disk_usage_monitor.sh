#!/bin/bash



# -------------------------------------------

# Disk Usage Monitor Script

#

# By: SaiSampathC

# -------------------------------------------



# Threshold percentage (change as needed)

THRESHOLD=80

LOG_FILE="disk_usage.log"



echo "Checking disk usage..."

sleep 1



# Scan mounted filesystems, excluding tmpfs and devtmpfs

df -H --output=source,pcent,target -x tmpfs -x devtmpfs | tail -n +2 | while read -r line; do

    USAGE=$(echo "$line" | awk '{print $2}' | tr -d '%')

    MOUNT=$(echo "$line" | awk '{print $3}')

    FS=$(echo "$line" | awk '{print $1}')



    if (( USAGE >= THRESHOLD )); then

        ALERT="WARNING: $FS mounted on $MOUNT is at ${USAGE}% usage"

        echo "$ALERT"

        echo "$(date '+%Y-%m-%d %H:%M:%S') - $ALERT" >> "$LOG_FILE"

    else

        echo "$FS mounted on $MOUNT is at ${USAGE}% usage - OK"

    fi

done



echo "Disk check complete. Alerts (if any) logged in $LOG_FILE."
