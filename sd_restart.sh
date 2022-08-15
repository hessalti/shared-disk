(자동 Restart) 상황
server start
(server start 성공한 경우) alter database shard failback;
(server start 성공한 경우) virtual IP add $VIP
(server start 실패한 경우) virtual IP delete $VIP
(자동 Failover) 상황
virtual IP delete $VIP


########## working on 192.168.1.105:~
#!/usr/bin/env bash

if [ "$MYID" != "1" ] && [ "$MYID" != "2" ]; then
    echo "Error: MYID environment variable is not set."
    exit 1
fi

CONNECT_RESULT=$( ${ALTIBASE_HOME}/ZookeeperServer/bin/zkCli.sh -server 192.168.1.106:2181 quit | grep 'Session establishment complete' )

if [ "x$CONNECT_RESULT" = "x" ]; then
    #virtual IP delete $VIP
else
    server start

fi

echo "CONNECT_RESULT :" $CONNECT_RESULT
exit 0
