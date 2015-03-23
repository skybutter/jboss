#!/bin/sh
#
if [ $# -lt 1 ]
then
    echo "Usage: `basename $0`"
    echo "Usage: `basename $0` jboss-host"
    echo "  Example: `basename $0`"
    echo "  Example: `basename $0` host1"
    echo "  Example: `basename $0` --cached-dc"
    echo "  Example: `basename $0` host1 --cached-dc"
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
elif [ "$2" = "--cached-dc" ]; then
    export CACHE_DC=--cached-dc
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

export JBOSS_PIDFILE=${DOMAIN_DIR}/logs/${JBOSS_HOST}.pid
export JBOSS_LOGFILE=${JBOSS_HOST}.log
export JBOSS_CONSOLE_LOG=${DOMAIN_DIR}/logs/${JBOSS_LOGFILE}

#
# Check if any pid file exist
#
if [ -f ${JBOSS_PIDFILE} ]
then
   ppid=`cat ${JBOSS_PIDFILE}`
   echo "${JBOSS_PIDFILE} exist. Checking if server is running (pid=$ppid)."
   if [ "$ppid" != "" ]; then
      /bin/ps -ef | grep " $ppid " | grep -v grep > /dev/null
      if [ $? -eq 0 ]; then
          echo "Server with pid $ppid is running.  Please stop server first before starting."
          exit 2
      fi
   fi
fi

## Roll log
if [ -f ${JBOSS_CONSOLE_LOG} ]
then
  echo "Log File ${JBOSS_CONSOLE_LOG} exist. Rolling..."
  ROLLED_FILE=$DOMAIN_DIR/logs/`date +%Y_%m_%d_%H_%M_%S`${JBOSS_LOGFILE}
  mv $JBOSS_CONSOLE_LOG ${ROLLED_FILE}
fi

if [ "$3" = "--cached-dc" ]
then
   export CACHE_DC=--cached-dc
fi

#################################
## Start JBoss in background
#################################
$JBOSS_HOME/bin/domain.sh --domain-config=domain.xml --host-config=${JBOSS_HOST}.xml ${CACHE_DC} -P ${DOMAIN_DIR}/configuration/${JBOSS_HOST}.properties 2>&1 > $JBOSS_CONSOLE_LOG &

pid=$!
echo "Starting JBoss ${JBOSS_HOST} ...(pid=$pid)"

sleep 2

waitForStart()
{
  waitsecs=180
  logfile=$JBOSS_CONSOLE_LOG
  num=`/usr/bin/wc -l $logfile|/usr/bin/cut -d/ -f1|/usr/bin/tr -d " " `
  count=0
  while (true)
     do
        printf ".";
        if /usr/bin/tail -n +$num $logfile | grep -E 'JBAS015950: JBoss EAP 6\.[0-9]\.[0-9]\.GA \(AS 7\.[0-9]\.[0-9]\.Final\-redhat\-[0-9]+\) stopped'
                then
                        echo "Server did not start up properly"
                        exit 3
                fi
        if /usr/bin/tail -n +$num $logfile | grep -E 'JBAS012016: Shutting down process controller'
           then
                echo "Server did not start up properly"
                exit 4
        fi
        if /usr/bin/tail -n +$num $logfile | grep -E 'JBAS015875: JBoss EAP'
           then
                echo "Server started with errors."
                exit 5
        fi
        if /usr/bin/tail -n +$num $logfile | grep -E 'JBAS012006: Failed to'
           then
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
         /usr/bin/tail -n +$num $logfile |grep -E 'JBAS015874: JBoss EAP 6\.[0-9]\.[0-9]\.GA \(AS 7\.[0-9]\.[0-9]\.Final\-redhat\-[0-9]+\) started'
        then
           exit 0
        else
           sleep 1
        fi
        if [ $count -eq 10 ];  then
           if /usr/bin/tail -n 4 $logfile |grep '(Controller Boot Thread) JBAS015874:'
           then
              echo "Host Controller started.  But no server set to autostart."
              exit 0
           fi
        fi
        if [ $count -gt "$waitsecs" ];  then
            echo "Server did not start in $waitsecs seconds"
            exit 1
        fi
        count=`expr $count + 1`
     done
}
waitForStart
