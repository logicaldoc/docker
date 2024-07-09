#!/bin/bash
set -eo pipefail
if [ ! -d /LogicalDOC/tomcat ]; then
	printf "Installing LogicalDOC\n"
	j2 /installer/auto-install.j2 > /installer/auto-install.xml
        cd /installer
        sudo -u logicaldoc java -jar /installer/logicaldoc-installer.jar /installer/auto-install.xml
	sed -i 's/ulimit/#ulimit/g' /LogicalDOC/bin/logicaldoc.sh
	/LogicalDOC/bin/logicaldoc-all.sh stop
	/LogicalDOC/tomcat/bin/catalina.sh stop
else
	printf "LogicalDOC already installed\n"
fi

#set -x
pid=0

# SIGUSR1-handler
my_handler() {
	echo "my_handler"
}

# SIGTERM-handler
term_handler() {
    echo "term_handler PID: $pid"
	if [ $pid -ne 0 ]; then
		timeout 30s /LogicalDOC/bin/logicaldoc-all.sh stop
		kill -SIGTERM "$pid"
		wait $pid
		killall tail
	fi
	exit 143; # 128 + 15 -- SIGTERM
}

case $1 in
run)     echo "run";
	 /LogicalDOC/bin/logicaldoc-all.sh run &
         ;;
start)   echo "start";
	 /LogicalDOC/bin/logicaldoc-all.sh start &
         ;;
stop)    echo "STOOP!!!";
         /LogicalDOC/bin/logicaldoc-all.sh stop
         ;;
*)       echo "other $1";
         /LogicalDOC/bin/logicaldoc-all.sh $1
         ;;
esac

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; my_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

# Start the sshd daemon without forking
sudo /usr/sbin/sshd -D

# wait indefinitely
#while true; do sleep 1; done
