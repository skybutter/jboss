#!/bin/sh
#
if [ $# -lt 1 ]
then
    echo "Usage: `basename $0`"
    echo "Usage: `basename $0` jboss-host"
    echo "  Example: `basename $0` host1"
    echo "  Example: `basename $0` host2"
    exit 1
fi

if [ -z "$2" ]; then
    # Figure out the host by hostname
    mynode=$(uname -n)
    servernum=${mynode: -1}
    if [ $servernum -gt 3 ];  then
        servernum=`expr $servernum - 3`
    fi
    export JBOSS_HOST=host${servernum}
else
    export JBOSS_HOST=$2
fi

BASEDIR=$(dirname $0)
. ${BASEDIR}/setenv.sh

export HOST_NUM=$(echo ${JBOSS_HOST} | sed -e "s/^.*\(.\)$/\1/")
NUM=`expr ${HOST_NUM} - 1`
NUM=`expr ${NUM} \* 2`
export SERVER0=`expr ${NUM} + 1`
export SERVER1=`expr ${SERVER0} + 1`
export JBOSS_PIDFILE=${DOMAIN_DIR}/logs/${JBOSS_HOST}.pid
export JBOSS_LOGFILE=${JBOSS_HOST}.log
export JBOSS_CONSOLE_LOG=${DOMAIN_DIR}/logs/${JBOSS_LOGFILE}
export STDOUT=${DOMAIN_DIR}/logs/stop-${JBOSS_HOST}.log

echo "Stopping JBoss ${JBOSS_HOST} server ${SERVER0} ${SERVER1} ..."
echo "Stopping JBoss ${JBOSS_HOST} ...`date`" > ${STDOUT}
$JBOSS_HOME/bin/jboss-cli.sh --connect controller=$JBOSS_MGMT /host=${JBOSS_HOST}:shutdown 2>&1 | /usr/bin/tee -a ${STDOUT}

waitForStop()
{
  waitsecs=60
  logfile=$JBOSS_CONSOLE_LOG
  num=`/usr/bin/wc -l $logfile|/usr/bin/cut -d/ -f1|/usr/bin/tr -d " " `
  count=0
  while (true)
     do
        printf ".";
        if grep "Failed to connect to the controller" ${STDOUT}
        then
           echo "Failed to connect to the controller."
           break
        fi
        if
         /usr/bin/tail -n +$num $logfile |grep "JBAS012015: All processes finished; exiting"
        then
           break
        else
           sleep 1
        fi
        if [ $count -gt "$waitsecs" ];  then
            echo "Server did not stop in $waitsecs seconds"
            break
        fi
        count=`expr $count + 1`
     done
}
waitForStop

sleep 2
# double check if the server process is still running
if [ -f ${JBOSS_PIDFILE} ]  
then
  ppid=`cat ${JBOSS_PIDFILE}`
  echo "${JBOSS_PIDFILE} exist. Server did not stop completely (pid=$ppid)." 
  node=`uname -n`
#  if [ "$mynode" = "$node" ];  then
     if [ "$ppid" != "" ]; then
        sleep 1
        /bin/ps -ef | grep " $ppid " | grep -v grep > /dev/null
        if [ $? -eq 0 ]; then
                echo "Killing JBoss server (pid=$ppid)"
                pids=$(pgrep -P $ppid)
                pids=$(echo $pids $ppid)
                echo "Killing JBoss server (pid=$pids)"
                /usr/bin/kill -9 $pids
        fi
        echo "Stopped JBoss ${JBOSS_HOST} server"
        rm ${JBOSS_PIDFILE}
     fi
#  else
#     echo "Stop script not run on ${JBOSS_HOST}. Please run on ${JBOSS_HOST} node."
#  fi
else
  echo "Stopped JBoss ${JBOSS_HOST} server"
fi
echo "Cleaning up files for JBoss ${JBOSS_HOST} server ${SERVER0} ${SERVER1} ..."
rm -rf ${DOMAIN_DIR}/servers/${SERVER_NAME}${SERVER0}/tmp ${DOMAIN_DIR}/servers/${SERVER_NAME}${SERVER1}/tmp
echo "Finished Cleaning up files for JBoss ${JBOSS_HOST} server ${SERVER0} ${SERVER1} ..."
