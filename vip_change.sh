#!/bin/bash

#Preparation
#Execute "sudo visudo" command in linux terminal
#Append "hess ALL = NOPASSWD: /sbin/ifconfig" as a last line of the editing file

if [ "x$SHARED_DISK_MGMT" = "x" ]; then
    echo "Error: SHARED_DISK_MGMT environment variable is not set."
    echo "Find sd_set.env and execute this command first : source sd_set.env [1|2]"
    exit 1
fi

if [ "$SHARED_DISK_MY_ID" != "1" ] && [ "$SHARED_DISK_MY_ID" != "2" ]; then
    echo "Error: SHARED_DISK_MY_ID environment variable is not set."
    echo "Execute this command first : source ${SHARED_DISK_MGMT}/sd_set.env [1|2]"
    exit 1
fi

echo "\$SHARED_DISK_MY_ID = $SHARED_DISK_MY_ID"
echo "\$SHARED_DISK_MY_NETWORK_INTERFACE = $SHARED_DISK_MY_NETWORK_INTERFACE"
echo "\$SHARED_DISK_MY_VIRTUAL_IP = $SHARED_DISK_MY_VIRTUAL_IP"

if   [ "$1" = "up" ]; then
    sudo ifconfig ${SHARED_DISK_MY_NETWORK_INTERFACE} ${SHARED_DISK_MY_VIRTUAL_IP} up
elif [ "$1" = "down" ]; then
    sudo ifconfig ${SHARED_DISK_MY_NETWORK_INTERFACE} down
else
    echo "Usage: vip_change.sh [up|down]"
    exit 1
fi

exit 0
