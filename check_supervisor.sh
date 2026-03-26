#!/bin/bash

# Nagios plugin to check if Supervisor is running

SERVICE="supervisord"


# First, try systemd
if systemctl list-units --type=service | grep -q "^$SERVICE"; then
    STATUS=$(systemctl is-active $SERVICE)
    if [ "$STATUS" = "active" ]; then
        echo "OK: Supervisor service is running."
        exit 0
    else
        echo "CRITICAL: Supervisor service exists but is $STATUS."
        exit 2
    fi
else
    # Fallback: check for process
    if pgrep -x $SERVICE >/dev/null 2>&1; then
        echo "OK: Supervisor process is running."
        exit 0
    else
        echo "CRITICAL: Supervisor is not running."
        exit 2
    fi
fi
