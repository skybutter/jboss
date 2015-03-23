#!/bin/sh
#
if [ $# -lt 2 ]
then
    echo "Usage: `basename $0` env jboss-server"
    echo "Usage: `basename $0` env jboss-server jboss-host"
    echo "  Example: `basename $0` dev1 server3"
    echo "  Example: `basename $0` dev2 server1 host1"
    exit 1
fi
export ENV=$1
export JBOSS_SERVER=$2

if [ -z "$3" ]; then
    # Figure out the host by hostname
    mynode=$(uname -n)
    servernum=${mynode: -1}
    if [ $servernum -gt 3 ];  then
        servernum=`expr $servernum - 3`
    fi
    export JBOSS_HOST=host${servernum}
else
    export JBOSS_HOST=$3
fi

export SCRIPTS=$HOME/scripts
. ${SCRIPTS}/etc/setenv.sh
. ${SCRIPTS}/etc/setenv_${ENV}.sh

export JBOSS_LOGFILE=${JBOSS_HOST}.log
export JBOSS_CONSOLE_LOG=${DOMAIN_DIR}/logs/${JBOSS_LOGFILE}
export JBOSS_SERVER_LOG=${DOMAIN_DIR}/logs/${JBOSS_HOST}_${JBOSS_SERVER}.log
export STDOUT=${DOMAIN_DIR}/logs/stop-${JBOSS_HOST}-${JBOSS_SERVER}.log

echo "Calling JBoss CLI to stop ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER}..."
$JBOSS_HOME/bin/jboss-cli.sh --connect controller=$JBOSS_MGMT /host=${JBOSS_HOST}/server-config=${JBOSS_SERVER}:stop 2>&1 | /usr/bin/tee ${STDOUT}

waitForOutcome()
{
  logfile=${STDOUT}
#  num=`/usr/bin/wc -l $logfile|/usr/bin/cut -d/ -f1|/usr/bin/tr -d " " `
        if grep "JBAS012174" ${logfile}
        then
           exit 0 
        fi
        if grep "Failed to connect to the controller" ${logfile}
        then
           exit 0
        fi
           outcome=$(grep -o '"outcome" => [^, }]*' $logfile | sed 's/^.*=> //' | sed 's/"//g')
           if [ "$outcome" = "success" ]; then
               result=$(grep -o '"result" => [^, }]*' $logfile | sed 's/^.*=> //' | sed 's/"//g')
               printf "\n";
               if [ "$result" = "STOPPING" ]; then
                   echo "$result JBoss ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER}..."
                   break
               elif [ "$result" = "STOPPED" ]; then
                   echo "JBoss ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER} already $result"
                   exit 0
               else
                   echo "Fail to stop JBoss ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER}. result=$result"
                   exit 1
               fi
           elif [ "$result" = "failed" ]; then
               desc=$(grep -A 4 -i '"failure-description" => [^, }]*' $logfile)
               echo "$desc"
               exit 2
           else
               exit 2
           fi
}

waitForStop()
{
  waitsecs=50
  logfile=$JBOSS_CONSOLE_LOG
  num=`/usr/bin/wc -l $logfile|/usr/bin/cut -d/ -f1|/usr/bin/tr -d " " `
  count=0
  while (true)
     do
        printf ".";
        if
         /usr/bin/tail -n +$num $logfile |grep -E "^\[Server:${JBOSS_SERVER}\](.*)JBAS015950: JBoss EAP 6\.[0-9]\.[0-9]\.GA \(AS 7\.[0-9]\.[0-9]\.Final\-redhat\-[0-9]+\) stopped(.*)"
        then
           exit 0
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
waitForOutcome
waitForStop

pid=$(ps axf | grep jboss.domain.name=${ENV} | grep ${JBOSS_SERVER} | grep -v grep | awk '{print $1}')
if [ "$pid" != "" ]; then
    echo "JBoss Process pid=$pid found for ${JBOSS_SERVER}.  Killing..."
    /usr/bin/kill -9 $pid
    echo "Stopped JBoss ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER} server"
else
    echo "No process pid found for ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER}"
fi
