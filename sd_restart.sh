#!/usr/bin/env bash

if [ "$MY_ID" != "1" ] && [ "$MY_ID" != "2" ]; then
    echo "########## Error: MY_ID environment variable is not set."
    echo "########## Execute this command first : source ~/sd_mgmt/sd_set.env [1|2]"
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
    echo "########## Delete virtual IP : \$MY_ID = $MY_ID , \$MY_VIRTUAL_IP = $MY_VIRTUAL_IP"
    ~/sd_mgmt/vip_change.sh down
    exit 0
fi

echo "########## Restart Altibase server : \$MY_ID = $MY_ID"
echo "########## Add virtual IP : \$MY_ID = $MY_ID , \$MY_VIRTUAL_IP = $MY_VIRTUAL_IP"
~/sd_mgmt/vip_change.sh up
sleep 20
server start
sleep 3
FAILBACK_RESULT=$(isql -s 127.0.0.1 -u sys -p manager << 'EOF'
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
    ~/sd_mgmt/vip_change.sh down
fi

exit 0
