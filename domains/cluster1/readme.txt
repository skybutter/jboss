This sample contains a working copy of JBoss Domain cluster configuration.
1.  Domain cluster is setup with 1 machine/host and 2 nodes/server/jvm
2.  JMS Hornetq is setup as a cluster
3.  Management Realm user "jms" is added to run the HornetQ cluster
4.  JBoss environment properties substitution is used.
5.  Properties are specified in host1.properties.
6.  host1.xml is used for the JBoss host.  host-master and host-slave are removed.
7.  JBoss Profile full-ha is used.
8.  Management Realm user "admin" is added to access Management Console
