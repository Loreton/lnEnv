#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 21-06-2026 15.11.30
#

applLog="/tmp/sublime_start.log"; echo >$applLog

#- caricamento variabili di ambiente personali
source ${HOME}/filu/lnEnv/.config_secret/loretoVariables.sh   >>$applLog 2>&1




myAppl="${ln_LINUX_PORTABLE_DIR}/SublimeText4/sublime_text"



#- scrivi su log
DATE=$(date +'%d-%m-%Y %H:%M:%S')
echo -e "\n--- $DATE - start"                           >>$applLog 2>&1



if [[ -f "${myAppl}" ]]; then
    # se c'è qualche parametro ...
    if [[ "$@" ]]; then
        echo -e "editing file: $@"                     >>$applLog 2>&1
    else
        echo -e "launching: [${myAppl}]"               >>$applLog 2>&1
    fi

    "${myAppl}" $@ &                        #----     >>$applLog 2>&1 &
    pid=$!
    echo -e "Lanciato PID ${pid}\n"                    >>$applLog 2>&1
    echo -e "\n\n--- program output --------\n"        >>$applLog 2>&1
else
    echo -e "[${myAppl}] NOT FOUND"                >>$applLog
fi


