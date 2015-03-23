#!/bin/sh
#
if [ $# -lt 2 ]
then
    echo "Usage: `basename $0` env jboss-host"
    echo "  Example: `basename $0` dev1 host1"
    echo "  Example: `basename $0` qa1 host2"
    exit 1
fi
export ENV=$1
export JBOSS_HOST=$2

export SCRIPTS=$HOME/scripts
. ${SCRIPTS}/etc/setenv.sh
. ${SCRIPTS}/etc/setenv_${ENV}.sh

$JBOSS_HOME/bin/jboss-cli.sh --connect controller=$JBOSS_MGMT "/host=${JBOSS_HOST}:shutdown(restart=true)"
