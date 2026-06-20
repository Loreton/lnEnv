#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Version ......: 07-12-2020 16.07.59
#
# cd /home/pi/PiProd/shProc && ff="wrLog.sh" && chmod +w $ff && cp _devel/$ff . && chmod -w $ff && cd -
#
###############################################
gScriptFPath=${1}
gScriptName="$(basename $gScriptFPath .sh)" # remove extension
MAX_LOGFILE_SIZE=10000000
gHostNAME="$(hostname -s)"

if [ -z ${2} ]; then
    LOGNAME="/tmp/${gScriptName}.log"
else
    LOGNAME=${2}
fi

###############################################
#


###############################################
#
###############################################
function check_param() {
    inp_args=$@
    fCONSOLE=0
    fINIT=0
    fSYSLOG=0
    msg=
    # remove parameters-key from input arguments
    for word in $@ ; do

        if [ $word == '--console' ]; then
            fCONSOLE=1
            inp_args=${inp_args//$word/}

        elif [ $word == '--init' ]; then # force push
            fINIT=1
            inp_args=${inp_args//$word/}

        elif [ $word == '--syslog' ]; then # force push
            fSYSLOG=1
            inp_args=${inp_args//$word/}
        fi

    done
    # strip text
    inp_args=$(echo $inp_args)
}



###############################################
#
###############################################
wrLog() {
    lineNO=$1; shift
    check_param $@

    DATE=$(date +"%Y/%m/%d %H:%M:%S")
    f_outLine="[$gHostNAME] $DATE $gScriptName[$lineNO] - "
    f_outLine="[$DATE]-[$LINENO]:"
    f_outLine="$DATE [${gScriptName}:${lineNO}] - "
    c_outLine="[$lineNO]:"

    if [[ "$fSYSLOG" -eq 1 ]]; then
        logger -t ${gScriptName} " $inp_args"

    elif [[ "$fINIT" -eq 1 ]]; then
        # check if rotate...
        if [[ -f $LOGNAME ]]; then
            fileSize=$(stat -c %s $LOGNAME)
            rCode=$?
            [[ $rCode -ne 0 ]] && fileSize=0
        else
            fileSize=0
        fi
        if [ ${fileSize} -gt ${MAX_LOGFILE_SIZE} ]; then
            echo "[${f_outLine}] ${LOGNAME} exceeds max threshold"
            savelog -u pi -l -p -n -c 7 ${LOGNAME}
        fi

        # - intestazione
        for i in {1..5}; do wrLog "$LINENO" ""; done
        Pounds="=========================================================================="
        ProgState="= [$gHostNAME] START Script: $gScriptName on:  $( date +"%c")"
        wrLog "$LINENO" "${Pounds}"
        wrLog "$LINENO" "${ProgState}"
        wrLog "$LINENO" "${Pounds}"
    else
        echo "$f_outLine $inp_args" >>$LOGNAME
        [[ $fCONSOLE -eq 1 ]] && echo "$c_outLine $inp_args"
    fi
}
