#! /bin/sh
# Copyright (c) 2008 LogicalDOC
# All rights reserved.
#
### BEGIN INIT INFO
# Provides:       logicaldoc     
# Required-Start: 
# Should-Start:   
# Required-Stop:
# Default-Start:  3 5
# Default-Stop:   0 1 2 6
# Description:    LogicalDOC Document Management System
### END INIT INFO

#ulimit -Hn 6000
#ulimit -Sn 6000
#ulimit -v unlimited

HOME=/LogicalDOC
export CATALINA_HOME="$HOME/tomcat"
export CATALINA_PID="$HOME/bin/pid"
#export JAVA_OPTS="-Xmx3000m -Dfile.encoding=UTF-8 -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -XX:+IgnoreUnrecognizedVMOptions -Dsolr.disable.shardsWhitelist=true"
export JAVA_OPTS="-Xmx3000m -Dfile.encoding=UTF-8 -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -XX:+IgnoreUnrecognizedVMOptions -Dsolr.disable.shardsWhitelist=true --add-opens=java.desktop/java.awt.font=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.text=ALL-UNNAMED  --add-opens=java.activation/*=ALL-UNNAMED --add-opens=java.transaction/*=ALL-UNNAMED --add-opens=java.xml.ws.annotation/*=ALL-UNNAMED --add-opens=java.xml.ws/*=ALL-UNNAMED --add-opens=java.xml.bind/*=ALL-UNNAMED --add-opens=java.corba/*=ALL-UNNAMED --add-opens=java.sql/*=ALL-UNNAMED"



#-Djava.security.egd=file:/dev/./urandom
#-Dcom.sun.jndi.ldap.object.disableEndpointIdentification=true
#export JDK_JAVA_OPTIONS="--add-opens=java.base/*=ALL-UNNAMED --add-opens=java.activation/*=ALL-UNNAMED --add-opens=java.transaction/*=ALL-UNNAMED --add-opens=java.xml.ws.annotation/*=ALL-UNNAMED --add-opens=java.xml.ws/*=ALL-UNNAMED --add-opens=java.xml.bind/*=ALL-UNNAMED --add-opens=java.corba/*=ALL-UNNAMED --add-opens=java.sql/*=ALL-UNNAMED"

case $1 in
start)   if [ -e $CATALINA_PID ]
         then
            kill -9 `tail $CATALINA_PID`
            rm -rf $CATALINA_PID
         fi
         "$CATALINA_HOME/bin/catalina.sh" start
         ;;
restart) "$CATALINA_HOME/bin/catalina.sh" stop -force
         if [ -e $CATALINA_PID ]
         then
            kill -9 `tail $CATALINA_PID`
            rm -rf $CATALINA_PID
         fi
         "$CATALINA_HOME/bin/catalina.sh" start
         ;;
stop)   "$CATALINA_HOME/bin/catalina.sh" stop -force
         if [ -e $CATALINA_PID ]
         then
            kill -9 `tail $CATALINA_PID`
            rm -rf $CATALINA_PID
         fi
         ;;
*) "$CATALINA_HOME/bin/catalina.sh" $1
   ;;
esac
