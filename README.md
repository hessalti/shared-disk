### Machines
- 192.168.1.108 : NFS server, Zookeeper server
- 192.168.1.105 : SHARD-1, NFS client, Zookeeper client
- 192.168.1.106 : SHARD-2, NFS client, Zookeeper client
- 192.168.1.95 : application client
- Setup all servers(nfs server and clients) with same user name, user id, group name, group id and home directory path.
  - user-name(user-id) : hess(555)
  - group-name(group-id) : hess(555)
- $ALTIBASE_HOME path of SHARD-1 and SHARD-2 should same in both servers.
  - SHARD-1 $ALTIBASE_HOME : /home1/hess/altibase_home_1
  - SHARD-2 $ALTIBASE_HOME : /home1/hess/altibase_home_2

### nfs setup
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

#zk client test
${ALTIBASE_HOME}/ZookeeperServer/bin/zkCli.sh -server 192.168.1.108:2181
```

### SHARD-1 and SHARD-2 setup
```
#connect
ssh 192.168.1.105 #SHARD-1 
ssh 192.168.1.106 #SHARD-2 

#move to user directory
git clone https://github.com/hessalti/shared-disk.git sd_mgmt
cd sd_mgmt
chmod +x *.sh

#preparation for dynamic virtual change
#execute "sudo visudo" command in linux terminal
#append "hess ALL = NOPASSWD: /sbin/ifconfig" as a last line of the editing file

#environment setting
source ~/sd_mgmt/sd_set.env 1 #SHARD-1
source ~/sd_mgmt/sd_set.env 1 #SHARD-2

#create db & add shard node
~/sd_mgmt/sd_prepare_database.sh
```
