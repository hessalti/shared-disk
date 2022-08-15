(자동 Restart) 상황에서는 자동 재구동 및 클러스터 재접속이 필요함.
server start
(server start 성공한 경우) alter database shard failback;
(server start 성공한 경우) VIP설정(virtual IP add)
(server start 실패한 경우) VIP설정해제(virtual IP delete)
(자동 Restart) 와 (자동 Failover) 가 경쟁하면서, 다른 서버에서 먼저 startup 된 경우에는, 여기서는 server start 가 실패할 수 있다.
(자동 Failover) 상황에서는 재구동은 하지 않고, VIP설정해제(virtual IP delete)한다.(해당 VIP를 다른 Server에서 설정하여 사용할 것이므로)
(자동 Failover) 상황에 대한 판단은 Zookeeper 에 설정한 cluster meta 정보를 보고 판단한다.
