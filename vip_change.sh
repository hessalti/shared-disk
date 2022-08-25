#!/bin/bash

#Preparation
#Execute "sudo visudo" command in linux terminal
#Append "hess ALL = NOPASSWD: /sbin/ifconfig" as a last line of the editing file

if [ "$MY_ID" != "1" ] && [ "$MY_ID" != "2" ]; then
    echo "Error: MY_ID environment variable is not set."
    echo "Execute this command first : source ~/sd_mgmt/sd_set.env [1|2]"
    exit 1
fi

echo "\$MY_ID = $MY_ID"
echo "\$MY_NETWORK_INTERFACE = $MY_NETWORK_INTERFACE"
echo "\$MY_VIRTUAL_IP = $MY_VIRTUAL_IP"

if   [ "$1" = "up" ]; then
    sudo ifconfig ${MY_NETWORK_INTERFACE} ${MY_VIRTUAL_IP} up
elif [ "$1" = "down" ]; then
    sudo ifconfig ${MY_NETWORK_INTERFACE} down
else
    echo "Usage: vip_change.sh [up|down]"
    exit 1
fi

exit 0
