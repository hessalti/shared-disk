#!/usr/bin/env bash

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

cp ${ALTIBASE_HOME}/conf/altibase.properties.shard ${ALTIBASE_HOME}/conf/altibase.properties

echo "########## Restart Altibase server : \$SHARED_DISK_MY_ID = $SHARED_DISK_MY_ID"

isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -sysdba -noprompt << EOF
    startup process;
    CREATE DATABASE mydb INITSIZE=${DB_INITSIZE}M ${DB_ARCH_MODE} CHARACTER SET ${DB_CHARSET} NATIONAL CHARACTER SET ${DB_NATIONAL_CHARSET};
    shutdown abort;
    quit
EOF

server start
sleep 3

# Prepare sharding
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/dbms_shard.sql
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/dbms_shard.plb
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/dbms_shard_get_diagnostics.sql
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/dbms_shard_get_diagnostics.plb
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/dbms_metadata.sql
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/dbms_metadata.plb
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/dbms_lock.sql
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/dbms_lock.plb

isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${SHARED_DISK_MGMT}/base_schema.sql
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -noprompt << EOF
    EXEC DBMS_SHARD.CREATE_META();
    EXEC DBMS_SHARD.SET_LOCAL_NODE(${SHARED_DISK_MY_ID}, 'NODE${SHARED_DISK_MY_ID}', '${SHARED_DISK_MY_VIRTUAL_IP}', ${ALTIBASE_PORT_NO}, '${SHARED_DISK_MY_VIRTUAL_IP}', ${ALTIBASE_PORT_NO}, '${SHARED_DISK_MY_VIRTUAL_IP}', ${ALTIBASE_REPLICATION_PORT_NO} );
    EXEC DBMS_SHARD.SET_REPLICATION(0);
EOF

isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/utl_shard_online_rebuild.sql
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/utl_shard_online_rebuild.plb

echo "########## Add virtual IP : \$SHARED_DISK_MY_ID = $SHARED_DISK_MY_ID , \$SHARED_DISK_MY_VIRTUAL_IP = $SHARED_DISK_MY_VIRTUAL_IP"
${SHARED_DISK_MGMT}/vip_change.sh up
sleep 4

echo "########## ALTER DATABASE SHARD ADD"
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -noprompt << EOF
    ALTER DATABASE SHARD ADD;
EOF

exit 0
