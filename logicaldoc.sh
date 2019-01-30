#!/bin/bash
set -eo pipefail
if [ ! -d /LogicalDOC/tomcat ]; then
 printf "Installing LogicalDOC\n"
 j2 /LogicalDOC/auto-install.j2 > /LogicalDOC/auto-install.xml
 # cat /LogicalDOC/auto-install.xml
 java -jar /LogicalDOC/logicaldoc-installer.jar /LogicalDOC/auto-install.xml
 /LogicalDOC/bin/logicaldoc-all.sh stop
 /LogicalDOC/tomcat/bin/catalina.sh stop
else
 printf "LogicalDOC already installed\n"
fi

case $1 in
run)     echo "run";
	 /LogicalDOC/bin/logicaldoc-all.sh run
         ;;
start)   echo "start";
	 /LogicalDOC/bin/logicaldoc-all.sh start
         ;;
stop)    echo "STOOP!!!";
         /LogicalDOC/bin/logicaldoc-all.sh stop
         ;;
*) /LogicalDOC/bin/logicaldoc-all.sh $1
   ;;
esac



