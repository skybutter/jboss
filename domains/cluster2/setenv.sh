#
# Set and check environmeonts
export JBOSS_HOME=${HOME}/jboss-eap-6.3
export LAUNCH_JBOSS_IN_BACKGROUND=1
export SERVER_GROUP=server-group
node=`uname -n`

export JBOSS_MGMT=${node}:9999
#export DOMAIN=cluster2
export DOMAIN_DIR=$PWD
# This gets the current directory the script resides
#export DOMAIN_DIR=$(dirname $0)
