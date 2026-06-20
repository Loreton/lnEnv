#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 20-06-2026 12.24.49
#

myAppl="/usr/bin/sxhkd"
applName='sxhkd'
applLog="/tmp/${applName}_start.log"
applArgs="-c ${HOME}/filu/lnEnv/config/appls/sxhkd/sxhkdrc -r /tmp/sxhkd.log -s /tmp/sxhkd_status.fifo"

# LORETO_ENVIRONMENT="${HOME}/filu/lnEnv/init/main/setLoretoEnvironment"
# LORETO_ENVIRONMENT="${ln_ENV_DIR}/init/main/setLoretoEnvironment"

#- scrivi su log
DATE=$(date +'%d-%m-%Y %H:%M:%S')
echo -e "\n--- $DATE - start"                           >>$applLog 2>&1

#- mi serve per variabili che potrebbero essere all'interno di file e voglio che sublime le risolva...
source ${HOME}/filu/lnEnv/.config_secret/loretoVariables.sh   >>$applLog 2>&1


if [[ -f "${myAppl}" ]]; then
    # se c'è qualche parametro ...
    if [[ "$@" ]]; then
        echo -e "editing file: $@"                     >>$applLog 2>&1
    else
        echo -e "launching: [${myAppl} ${applArgs} $@]"               >>$applLog 2>&1
    fi

    "${myAppl}" ${applArgs} $@ &                        #----     >>$applLog 2>&1 &
    pid=$!
    echo -e "Lanciato PID ${pid}\n"                    >>$applLog 2>&1
    echo -e "\n\n--- program output --------\n"        >>$applLog 2>&1
else
    echo -e "[${myAppl}] NOT FOUND"                >>$applLog
fi


