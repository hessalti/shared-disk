#!/usr/bin/env bash

if [ "x$SD_MGMT" = "x" ]; then
    echo "Error: SD_MGMT environment variable is not set."
    echo "Find sd_set.env and execute this command first : source sd_set.env [1|2]"
    exit 1
fi

if [ "$MY_ID" != "1" ] && [ "$MY_ID" != "2" ]; then
    echo "Error: MY_ID environment variable is not set."
    echo "Execute this command first : source ${SD_MGMT}/sd_set.env [1|2]"
    exit 1
fi

echo "########## Restart Altibase server : \$MY_ID = $MY_ID"
echo "########## Add virtual IP : \$MY_ID = $MY_ID , \$MY_VIRTUAL_IP = $MY_VIRTUAL_IP"
${SD_MGMT}/vip_change.sh up
sleep 10

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

isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${SD_MGMT}/base_schema.sql
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -noprompt << EOF
    EXEC DBMS_SHARD.CREATE_META();
    EXEC DBMS_SHARD.SET_LOCAL_NODE(${MY_ID}, 'NODE${MY_ID}', '${MY_VIRTUAL_IP}', ${ALTIBASE_PORT_NO}, '${MY_VIRTUAL_IP}', ${ALTIBASE_PORT_NO}, '${MY_VIRTUAL_IP}', ${ALTIBASE_REPLICATION_PORT_NO} );
    EXEC DBMS_SHARD.SET_REPLICATION(0);
EOF

isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/utl_shard_online_rebuild.sql
isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -f ${ALTIBASE_HOME}/packages/utl_shard_online_rebuild.plb

isql -silent -s 127.0.0.1 -u ${SYS_USER_ID} -p ${SYS_USER_PASSWD} -noprompt << EOF
    ALTER DATABASE SHARD ADD;
EOF

exit 0
