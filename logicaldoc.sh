#!/bin/bash
set -eo pipefail

# it is possible that setup left logicadoc running, we need to stop it and run catalina in window
# so that my_init will keep the process ruinning
/opt/logicaldoc/bin/logicaldoc.sh stop
sleep 10
#/opt/logicaldoc/tomcat/bin/catalina.sh run
/opt/logicaldoc/bin/logicaldoc.sh run
