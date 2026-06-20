#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 28-11-2025 08.45.54
#


myApplicationLog='/tmp/pycharm_start.log'
DATE=$(date +'%d-%m-%Y %H:%M:%S')

echo "--- $DATE - start"                          >>$myApplicationLog 2>&1

set -u
source ${HOME}/lnEnv/setup/setLoretoEnvironment 0 >>$myApplicationLog 2>&1


myApplication="${ln_LINUX_PORTABLE_DIR}/pycharm-2025.2.4/bin/pycharm"

echo "launching: [${myApplication}]"                    >>$myApplicationLog
"${myApplication}"                                      >>$myApplicationLog 2>&1 &
pid=$!
echo "Lanciato PID ${pid}\n"                        >>$myApplicationLog
echo "\n\n--- program output --------\n"           >>$myApplicationLog


