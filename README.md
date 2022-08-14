### Servers
- 192.168.1.108 : NFS server, Zookeeper server
- 192.168.1.105 : SHARD-1, NFS client, Zookeeper client
- 192.168.1.106 : SHARD-2, NFS client, Zookeeper client
- user-name(user-id) : hess(555)
- group-name(group-id) : hess(555)

### nfs setup
- Setup all servers(nfs server and clients) with same user name, user id, group name, group id.
- Execute following commands in all servers(nfs server and clients).
```
#It is just as an example.
usermod -u 555 hess
groupmod -g 555 hess
chown -R hess:hess /home/hess
# Edit "/etc/idmapd.conf" add line "Domain = localdomain"
nfsidmap -c
```
