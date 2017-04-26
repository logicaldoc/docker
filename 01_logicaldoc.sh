#!/bin/bash
set -eo pipefail
if [ ! -d /opt/logicaldoc/tomcat ]; then
 printf "Installing LogicalDOC\n"
 j2 /opt/logicaldoc/auto-install.j2 > /opt/logicaldoc/auto-install.xml
 java -jar /opt/logicaldoc/logicaldoc-installer.jar /opt/logicaldoc/auto-install.xml
 # replace ulimit in logicaldoc start script because in docker that can be set-up from outside using parameters
 # http://docs.oracle.com/cd/E52668_01/E75728/html/ch04s16.html
 # https://docs.docker.com/engine/reference/commandline/dockerd/#default-ulimits
 # http://stackoverflow.com/questions/24318543/how-to-set-ulimit-file-descriptor-on-docker-container-the-image-tag-is-phusion
 sed -i "s/ulimit/\#ulimit/g" /opt/logicaldoc/bin/logicaldoc.sh
else
 printf "LogicalDOC already installed\n"
fi


