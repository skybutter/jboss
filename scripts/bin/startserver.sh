#!/bin/sh
#
if [ $# -lt 2 ]
then
    echo "Usage: `basename $0` env jboss-server"
    echo "Usage: `basename $0` env jboss-server jboss-host"
    echo "  Example: `basename $0` dev1 server1"
    echo "  Example: `basename $0` dev1 server1 host1"
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
export STDOUT=${DOMAIN_DIR}/logs/start-${JBOSS_HOST}-${JBOSS_SERVER}.log

echo "Calling JBoss CLI to start ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER}..."
$JBOSS_HOME/bin/jboss-cli.sh --connect controller=$JBOSS_MGMT /host=${JBOSS_HOST}/server-config=${JBOSS_SERVER}:start 2>&1 | /usr/bin/tee ${STDOUT}

waitForOutcome()
{
  logfile=${STDOUT}
#  num=`/usr/bin/wc -l $logfile|/usr/bin/cut -d/ -f1|/usr/bin/tr -d " " `
        if grep "JBAS012174" ${logfile}
        then
           exit 4
        fi
        if grep "Failed to connect to the controller" ${logfile}
        then
           exit 3
        fi
           outcome=$(grep -o '"outcome" => [^, }]*' $logfile | sed 's/^.*=> //' | sed 's/"//g')
           if [ "$outcome" = "success" ]; then
               result=$(grep -o '"result" => [^, }]*' $logfile | sed 's/^.*=> //' | sed 's/"//g')
               printf "\n";
               if [ "$result" = "STARTING" ]; then
                   echo "$result JBoss ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER}..."
                   break
               elif [ "$result" = "STARTED" ]; then
                   echo "JBoss ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER} already $result" 
                   exit 0
               else
                   echo "Fail to start JBoss ${ENV} ${JBOSS_HOST} ${JBOSS_SERVER}. result=$result" 
                   exit 1
               fi
           elif [ "$result" = "failed" ]; then
               desc=$(grep -A 4 -i '"failure-description" => [^, }]*' $logfile)
               echo "$desc"
               exit 2
           else
               exit 2
           fi
           sleep 1
}

waitForStart()
{
  waitsecs=100
  logfile=$JBOSS_CONSOLE_LOG
  num=`/usr/bin/wc -l $logfile|/usr/bin/cut -d/ -f1|/usr/bin/tr -d " " `
  count=0
  while (true)
     do
        printf ".";
        if /usr/bin/tail -n +$num $logfile | grep -E "^\[Server:${JBOSS_SERVER}\](.*)JBAS015950: JBoss EAP 6\.[0-9]\.[0-9]\.GA \(AS 7\.[0-9]\.[0-9]\.Final\-redhat\-[0-9]+\) stopped"
                then
                        printf "\n";
                        echo "Server did not start up properly"
                        exit 8
                fi
        if /usr/bin/tail -n +$num $logfile | grep -E "^\[Server:${JBOSS_SERVER}\](.*)JBAS012016: Shutting down process controller"
           then
                printf "\n";
                echo "Server did not start up properly"
                exit 7
        fi
        if /usr/bin/tail -n +$num $logfile | grep -E "^\[Server:${JBOSS_SERVER}\](.*)JBAS015875: JBoss EAP"
           then
                printf "\n";
                echo "Server started with errors."
                exit 5
        fi
        if /usr/bin/tail -n +$num $logfile | grep -E "^\[Server:${JBOSS_SERVER}\](.*)JBAS012006: Failed to"
           then
                printf "\n";
                echo "Server started with errors."
                exit 6
        fi
        if /usr/bin/tail -n +$num $logfile | grep -E "JBAS010344: Failed to start "
           then
                printf "\n";
                echo "Server started with errors."
                exit 7
        fi
        if
         /usr/bin/tail -n +$num $logfile |grep -E "^\[Server:${JBOSS_SERVER}\](.*)JBAS015874: JBoss EAP 6\.[0-9]\.[0-9]\.GA \(AS 7\.[0-9]\.[0-9]\.Final\-redhat\-[0-9]+\) started"
        then
           exit 0
        else
           sleep 1
        fi
        if [ $count -eq 20 ];  then
           if /usr/bin/tail -n 4 $logfile |grep '(Controller Boot Thread) JBAS015874:'
           then
              printf "\n";
              echo "Host Controller started.  But no server set to autostart."
              exit 0
           fi
        fi
        if [ $count -gt "$waitsecs" ];  then
            printf "\n";
            echo "Server did not start in $waitsecs seconds"
            exit 1
        fi
        count=`expr $count + 1`
     done
}

waitForOutcome
waitForStart

