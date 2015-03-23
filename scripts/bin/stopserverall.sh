#!/bin/sh
#
if [ $# -lt 1 ]
then
    echo "Usage: `basename $0` env"
    echo "  Example: `basename $0` dev1"
    exit 1
fi
export ENV=$1

export SCRIPTS=$HOME/scripts
. ${SCRIPTS}/etc/setenv.sh
. ${SCRIPTS}/etc/setenv_${ENV}.sh

$JBOSS_HOME/bin/jboss-cli.sh --connect controller=$JBOSS_MGMT /server-group=${SERVER_GROUP}:stop-servers
