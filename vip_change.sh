#!/bin/bash

#Preparation
#Execute "sudo visudo" command in linux terminal
#Append "hess ALL = NOPASSWD: /home1/hess/vip_change.sh" as a last line of the editing file

#Modify network interface name and IP according to your environment

if   [ "$1" = "1" ] && [ "$2" = "up" ]; then
    sudo ifconfig eth0:1 192.168.1.225 up
elif [ "$1" = "2" ] && [ "$2" = "up" ]; then
    sudo ifconfig eth0:2 192.168.1.226 up
elif [ "$1" = "1" ] && [ "$2" = "down" ]; then
    sudo ifconfig eth0:1 down
elif [ "$1" = "2" ] && [ "$2" = "down" ]; then
    sudo ifconfig eth0:2 down
else
    echo "Usage: vip_change.sh [1|2] [up|down]"
    exit 1
fi

exit 0
