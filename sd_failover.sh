. ~/altibase_home_2/set.env
server start
(server start 성공한 경우) alter database shard failback;
(server start 성공한 경우) virtual IP add $VIP
(server start 실패한 경우) virtual IP delete $VIP
