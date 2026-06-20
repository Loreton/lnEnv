#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 29-11-2025 15.56.56
#

myApplicationLog='/tmp/sublime_start.log'
# echo -n >$myApplicationLog NON lo initializzo perhé potrebbero partire più comandi

DATE=$(date +'%d-%m-%Y %H:%M:%S')

set -u
echo -e "\n\n--- $DATE - start"                          >>$myApplicationLog 2>&1
#... NON posso usare la variabile $ln_SET_LORETO_ENVIRONMENT
#... perché non impostata se lanciata da sistema
#... allora l'ho definita manualmente in ${HOME}/.pam_environment ma non funziona ancora
# source ${ln_SET_LORETO_ENVIRONMENT} 0   >>$myApplicationLog 2>&1
source ${HOME}/filu/lnEnv/init/main/setLoretoEnvironment 0    >>$myApplicationLog 2>&1

myAppl="${ln_SUBLIME_BIN}"

if [[ -f "${myAppl}" ]]; then
    if [[ "$@" ]]; then
        echo -e "editing file: $@"                     >>$myApplicationLog 2>&1
    else
        echo -e "launching: [${myAppl}]"           >>$myApplicationLog 2>&1
    fi

    "${myAppl}" $@ &                        #----     >>$myApplicationLog 2>&1 &
    pid=$!
    echo -e "Lanciato PID ${pid}\n"                    >>$myApplicationLog 2>&1
    echo -e "\n\n--- program output --------\n"        >>$myApplicationLog 2>&1
else
    echo -e "[${myAppl}] NOT FOUND"                >>$myApplicationLog
fi

