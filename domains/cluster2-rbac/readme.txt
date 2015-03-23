This sample contains a working copy of JBoss Domain cluster configuration.
1.  Domain cluster is setup with 2 machines: host1, host2
2.  1 node per machine(host), server1 on host1, server3 on host2
3.  JMS Hornetq is setup as a cluster
4.  Management Realm user "jms" is added to run the HornetQ cluster
5.  JBoss environment properties substitution is used.
6.  Properties are specified in host1.properties and host2.properties
7.  host*.xml is used for each JBoss host.  Default host-master and host-slave from installation are removed.
8.  JBoss Profile full-ha is used.
9.  Use Unicast for jgroups.  Default is multicast.
10. Management Realm user "admin" is added to access Management Console
11. Changed to use JBoss Role based access control (rbac)
12. Management Realm user "monitor" is added to access Management Console with read only access


