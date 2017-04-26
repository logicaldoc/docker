#!/bin/bash
set -eo pipefail

# it is possible that setup left logicadoc running, we need to stop it and run catalina in window
# so that my_init will keep the process ruinning
/opt/logicaldoc/update-wd/update-wd.sh stop
sleep 5

/opt/logicaldoc/update-wd/update-wd.sh start
