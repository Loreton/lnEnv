#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 08-05-2026 17.02.40
#

myAppl="${HOME}/filu/Applications/linuxPortable/SublimeText4/sublime_text"
myApplName='sublime'
myApplicationLog="/tmp/${myApplName}_start.log"
# LORETO_ENVIRONMENT="${HOME}/filu/lnEnv/init/main/setLoretoEnvironment"
# LORETO_ENVIRONMENT="${ln_ENV_DIR}/init/main/setLoretoEnvironment"

#- scrivi su log
DATE=$(date +'%d-%m-%Y %H:%M:%S')
echo -e "\n--- $DATE - start"                           >>$myApplicationLog 2>&1

#- mi serve per variabili che potrebbero essere all'interno di file e voglio che sublime le risolva...
# source ${HOME}/filu/lnEnv/config_secret/loretoVariables.sh   >>$myApplicationLog 2>&1
source ${HOME}/filu/lnEnv/.config_secret/loretoVariables.sh   >>$myApplicationLog 2>&1


if [[ -f "${myAppl}" ]]; then
    # se c'è qualche parametro ...
    if [[ "$@" ]]; then
        echo -e "editing file: $@"                     >>$myApplicationLog 2>&1
    else
        echo -e "launching: [${myAppl}]"               >>$myApplicationLog 2>&1
    fi

    "${myAppl}" $@ &                        #----     >>$myApplicationLog 2>&1 &
    pid=$!
    echo -e "Lanciato PID ${pid}\n"                    >>$myApplicationLog 2>&1
    echo -e "\n\n--- program output --------\n"        >>$myApplicationLog 2>&1
else
    echo -e "[${myAppl}] NOT FOUND"                >>$myApplicationLog
fi


