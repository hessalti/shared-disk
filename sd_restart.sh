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

CONNECT_RESULT=$( ${ALTIBASE_HOME}/ZookeeperServer/bin/zkCli.sh -server ${ZK_SERVER_1}:2181 quit | grep 'Session establishment complete' )

#If you have multiple zk servers then check other zk servers
#if [ "x$CONNECT_RESULT" = "x" ]; then
#    CONNECT_RESULT=$( ${ALTIBASE_HOME}/ZookeeperServer/bin/zkCli.sh -server ${ZK_SERVER_2}:2181 quit | grep 'Session establishment complete' )
#
#    if [ "x$CONNECT_RESULT" = "x" ]; then
#        CONNECT_RESULT=$( ${ALTIBASE_HOME}/ZookeeperServer/bin/zkCli.sh -server ${ZK_SERVER_3}:2181 quit | grep 'Session establishment complete' )
#    fi
#fi

if [ "x$CONNECT_RESULT" = "x" ]; then
    echo "########## ZK connection failure"
    echo "########## Delete virtual IP : \$SHARED_DISK_MY_ID = $SHARED_DISK_MY_ID , \$SHARED_DISK_MY_VIRTUAL_IP = $SHARED_DISK_MY_VIRTUAL_IP"
    ${SHARED_DISK_MGMT}/vip_change.sh down
    exit 1
fi

echo "########## Restart Altibase server : \$SHARED_DISK_MY_ID = $SHARED_DISK_MY_ID"
SERVER_START_RESULT=$( server start )
echo "########## SERVER_START_RESULT :" $SERVER_START_RESULT

SERVER_START_OK=$( echo $SERVER_START_RESULT | grep 'STARTUP Process SUCCESS' )
echo "########## SERVER_START_OK :" $SERVER_START_OK

if [ "x$SERVER_START_OK" = "x" ]; then
    echo "########## server start failure"
    echo "########## Delete virtual IP : \$SHARED_DISK_MY_ID = $SHARED_DISK_MY_ID , \$SHARED_DISK_MY_VIRTUAL_IP = $SHARED_DISK_MY_VIRTUAL_IP"
    ${SHARED_DISK_MGMT}/vip_change.sh down
    exit 1
fi

echo "########## Add virtual IP : \$SHARED_DISK_MY_ID = $SHARED_DISK_MY_ID , \$SHARED_DISK_MY_VIRTUAL_IP = $SHARED_DISK_MY_VIRTUAL_IP"
${SHARED_DISK_MGMT}/vip_change.sh up
sleep 4
FAILBACK_RESULT=$(isql -s 127.0.0.1 -u ${SHARED_DISK_SYS_USER_ID} -p ${SHARED_DISK_SYS_USER_PASSWD} -silent -noprompt << 'EOF'
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

    echo "########## Delete virtual IP : \$SHARED_DISK_MY_ID = $SHARED_DISK_MY_ID , \$SHARED_DISK_MY_VIRTUAL_IP = $SHARED_DISK_MY_VIRTUAL_IP"
    ${SHARED_DISK_MGMT}/vip_change.sh down
    exit 1
fi

exit 0
