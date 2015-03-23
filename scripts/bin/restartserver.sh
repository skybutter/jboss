#!/bin/sh
#
if [ $# -lt 3 ]
then
    echo "Usage: `basename $0` env jboss-host server"
    echo "  Example: `basename $0` dev01 host1 server1"
    echo "  Example: `basename $0` dev01 host2 server2"
    exit 1
fi
export ENV=$1
export JBOSS_HOST=$2
export JBOSS_SERVER=$3

export SCRIPTS=$HOME/scripts
. ${SCRIPTS}/etc/setenv.sh
. ${SCRIPTS}/etc/setenv_${ENV}.sh

$JBOSS_HOME/bin/jboss-cli.sh --connect controller=$JBOSS_MGMT /host=${JBOSS_HOST}/server-config=${JBOSS_SERVER}:restart
