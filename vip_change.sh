#!/bin/bash

#Preparation
#Execute "sudo visudo" command in linux terminal
#Append "hess ALL = NOPASSWD: /home1/hess/vip_change.sh" as a last line of the editing file

if [ "$1" = "vip1" ] && [ "$2" = "up" ]; then
    sudo ifconfig eth0:1 192.168.1.225 up
fi

if [ "$1" = "vip2" ] && [ "$2" = "up" ]; then
    sudo ifconfig eth0:2 192.168.1.226 up
fi

if [ "$1" = "vip1" ] && [ "$2" = "down" ]; then
    sudo ifconfig eth0:1 down
fi

if [ "$1" = "vip2" ] && [ "$2" = "down" ]; then
    sudo ifconfig eth0:2 down
fi
