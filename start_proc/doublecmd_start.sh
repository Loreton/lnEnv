#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 12-02-2026 17.06.35
#


myApplicationLog='/tmp/doublecmd_start.log'
myAppl="${HOME}/filu/Applications/linuxPortable/doublecmd_1.1.32/doublecmd"
# source ${HOME}/filu/lnEnv/config_secret/loretoVariables.sh

DATE=$(date +'%d-%m-%Y %H:%M:%S')
echo -e "\n--- $DATE - start"                          	>>$myApplicationLog 2>&1

echo -e "launching: [${myAppl}]"                    	>>$myApplicationLog
set -u
"${myAppl}"                                     		>>$myApplicationLog 2>&1 &
pid=$!
echo -e "Lanciato PID ${pid}\n"                        	>>$myApplicationLog
echo -e "\n\n--- program output --------\n"           	>>$myApplicationLog


