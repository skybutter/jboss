#!/bin/sh
#
# Redeploy application
#
# Usage: redeploy domain application-package
if [ $# -ne 2 ]
then
        echo "Usage: `basename $0` env package"
                echo "Example: `basename $0` dev1 application.ear"
                echo "Example: `basename $0` dev1 application.war"
        exit 1
fi

export ENV=$1
export SCRIPTS=$HOME/scripts
. ${SCRIPTS}/etc/setenv.sh
. ${SCRIPTS}/etc/setenv_${ENV}.sh

PACKAGE=$2

finalname=${PACKAGE}
RELEASE_DIR=${DOMAIN_DIR}/releases

# check file
if [ ! -f ${RELEASE_DIR}/${PACKAGE} ]; then
        echo "Error: cannot find file ${RELEASE_DIR}/${PACKAGE}"
        exit 2
fi

##############
## Undeploy
##############
${JBOSS_HOME}/bin/jboss-cli.sh -c --controller=${JBOSS_MGMT} --command="undeploy $finalname --server-groups=${SERVER_GROUP}"

##############
## Deploy
##############
${JBOSS_HOME}/bin/jboss-cli.sh -c --controller=${JBOSS_MGMT} --command="deploy ${RELEASE_DIR}/$finalname --unmanaged --server-groups=${SERVER_GROUP}"
