#!/usr/bin/env bash

if [ "x$SD_MGMT" = "x" ]; then
    echo "Error: SD_MGMT environment variable is not set."
    echo "Find sd_set.env and execute this command first : source sd_set.env [1|2]"
    exit 1
fi

if [ "$MY_ID" != "1" ] && [ "$MY_ID" != "2" ]; then
    echo "########## Error: MY_ID environment variable is not set."
    echo "########## Execute this command first : source ${SD_MGMT}/sd_set.env [1|2]"
    exit 1
fi

${SD_MGMT}/vip_change.sh down

exit 0
