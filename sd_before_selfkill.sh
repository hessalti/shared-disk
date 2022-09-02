#!/usr/bin/env bash

if [ "x$SHARED_DISK_MGMT" = "x" ]; then
    echo "Error: SHARED_DISK_MGMT environment variable is not set."
    echo "Find sd_set.env and execute this command first : source sd_set.env [1|2]"
    exit 1
fi

if [ "$SHARED_DISK_MY_ID" != "1" ] && [ "$SHARED_DISK_MY_ID" != "2" ]; then
    echo "########## Error: SHARED_DISK_MY_ID environment variable is not set."
    echo "########## Execute this command first : source ${SHARED_DISK_MGMT}/sd_set.env [1|2]"
    exit 1
fi

${SHARED_DISK_MGMT}/vip_change.sh down

exit 0
