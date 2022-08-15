### Servers
- 192.168.1.108 : NFS server, Zookeeper server
- 192.168.1.105 : SHARD-1, NFS client, Zookeeper client
- 192.168.1.106 : SHARD-2, NFS client, Zookeeper client
- user-name(user-id) : hess(555)
- group-name(group-id) : hess(555)
- home directory : /home1/hess

### nfs setup
- Setup all servers(nfs server and clients) with same user name, user id, group name, group id and home directory path.
- Execute following commands in all servers(nfs server and clients).
```
#It is just as an example.
usermod -u 555 hess
groupmod -g 555 hess
chown -R hess:hess /home/hess
#Edit "/etc/idmapd.conf" add line "Domain = localdomain"
nfsidmap -c
```

### Zookeeper setup
```
#setup zoo.cfg in all zk server and clients
#Edit $ALTIBASE_HOME/ZookeeperServer/conf/zoo.cfg add line "server.1=192.168.1.108:2888:3888"

#execute following command in zk server (192.168.1.108)
echo 1 > /tmp/zookeeper/myid
${ALTIBASE_HOME}/ZookeeperServer/bin/zkServer.sh --config ${ALTIBASE_HOME}/ZookeeperServer/conf start
```
