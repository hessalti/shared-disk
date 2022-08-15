(자동 Restart) 상황
server start
(server start 성공한 경우) alter database shard failback;
(server start 성공한 경우) virtual IP add $VIP
(server start 실패한 경우) virtual IP delete $VIP
(자동 Failover) 상황
virtual IP delete $VIP
