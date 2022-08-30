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


if [ "$MY_ID" = "1" ]; then
    source ${SD_MGMT}/sd_set.env 2
else
    source ${SD_MGMT}/sd_set.env 1
fi

echo "########## server start : \$MY_ID = $MY_ID"
SERVER_START_RESULT=$( server start )
echo "########## SERVER_START_RESULT :" $SERVER_START_RESULT

SERVER_START_OK=$( echo $SERVER_START_RESULT | grep 'STARTUP Process SUCCESS' )
echo "########## SERVER_START_OK :" $SERVER_START_OK

if [ "x$SERVER_START_OK" = "x" ]; then
    echo "########## server start failure"
    echo "########## Delete virtual IP : \$MY_ID = $MY_ID , \$MY_VIRTUAL_IP = $MY_VIRTUAL_IP"
    ${SD_MGMT}/vip_change.sh down
    exit 1
fi

echo "########## server start success : \$MY_ID = $MY_ID"
echo "########## Add virtual IP : \$MY_ID = $MY_ID , \$MY_VIRTUAL_IP = $MY_VIRTUAL_IP"
${SD_MGMT}/vip_change.sh up
sleep 10
FAILBACK_RESULT=$(isql -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -silent -noprompt << 'EOF'
    ALTER DATABASE SHARD JOIN;
    ALTER DATABASE SHARD FAILBACK;
EOF
)
echo "########## FAILBACK_RESULT :" $FAILBACK_RESULT

FAILBACK_OK=$( echo $FAILBACK_RESULT | grep 'Alter success' )
echo "########## FAILBACK_OK :" $FAILBACK_OK

if [ "x$FAILBACK_OK" = "x" ]; then
    echo "########## FAILBACK failure... server kill"
    server kill

    echo "########## Delete virtual IP : \$MY_ID = $MY_ID , \$MY_VIRTUAL_IP = $MY_VIRTUAL_IP"
    ${SD_MGMT}/vip_change.sh down
    exit 1
fi

exit 0
