#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 05-07-2026 12.14.24
#


applname='sxhkd'
applLog="/tmp/${applname}_start.log"
# applLog="/tmp/${applname}_start.log"; echo >>$applLog
#- mi serve per variabili che potrebbero essere all'interno di file e voglio che sublime le risolva...
source ${HOME}/filu/lnEnv/.config_secret/loretoVariables.sh   >>$applLog 2>&1




myAppl="/usr/bin/${applname}"

applArgs="-c ${ln_SXHKD_CONFIG_FILE} -r /tmp/${applname}.log -s /tmp/${applname}_status.fifo"


#- scrivi su log
DATE=$(date +'%d-%m-%Y %H:%M:%S')
echo -e "\n--- $DATE - start"                           >>$applLog 2>&1



if [[ -f "${myAppl}" ]]; then
    # se c'è qualche parametro ...
    if [[ "$@" ]]; then
        echo -e "editing file: $@"                     >>$applLog 2>&1
    else
        echo "ln_ZED_CONFIG_DIR:    ${ln_ZED_CONFIG_DIR}"       >>$applLog 2>&1
        echo "ln_SXHKD_CONFIG_FILE: ${ln_SXHKD_CONFIG_FILE}"   >>$applLog 2>&1
        echo -e "launching: [${myAppl} ${applArgs} $@]"               >>$applLog 2>&1
    fi

    "${myAppl}" ${applArgs} $@ &                        #----     >>$applLog 2>&1 &
    pid=$!
    echo -e "Lanciato PID ${pid}\n"                    >>$applLog 2>&1
    echo -e "\n\n--- program output --------\n"        >>$applLog 2>&1
else
    echo -e "[${myAppl}] NOT FOUND"                >>$applLog
fi


