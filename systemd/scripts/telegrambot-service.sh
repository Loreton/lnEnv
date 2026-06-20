#!/bin/bash
# ---------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 14-05-2024 08.16.05
# ---------------------------------------

#=============================================
# Richiamato dal systemctl service
# /home/loreto/lnprofile/systemd/templates/mqttMonitor@user.service.tpl
# ed usato anche per testare da command line
#=============================================






function setProgram() {
    extra=$@
    [[ ! -f $pyProgram ]] && echo "python program [$pyProgram] NOT found!" && exit 2

    programExecStart="/usr/bin/python ${pyProgram}\
                --console-logger-level $LOG_CONSOLE \
                --file-logger-level $LOG_LEVEL \
                --logging-dir ${LOGGER_DIR} \
                --pid-file ${pidFile} \
                --broker-name ${BROKER_NAME} \
                --telegram-group-name ${TG_GROUP_NAME} \
                $SYSTEMD \
                ${extra}"

    programExecStart=$(echo "$programExecStart" | tr -s " ") # Remove extra BLANK

}


function get_PID() {
    # AND non esiste con il grep quindi li faccio separati
    g_process=$(ps -ef | grep -v 'grep' | grep -i -- "/usr/bin/python" | grep -i -- "--logging-dir ${LOGGER_DIR}" | grep -i "topics" | grep -i $pidFile )
    g_PID=$(echo $g_process | awk '{print $2}')

    [[ -f "${pidFile}" ]] && g_PID2=$(<$pidFile) || g_PID2='[no pid file found]'
    echo -e "${TABcyanH}process PID: $g_PID"
    echo -e "${TABcyanH}pid_file:    $g_PID2" # dovrebbero essere uguali....

    ### display process
    [[ ! -z "$g_PID" ]] && ps -p $g_PID -lF | grep $g_PID
}



############################################
#               M A I N
############################################
    action="${1}"
    shift 1

    # APPL_NAME="telegramBot"
    PRJ_NAME="telegramBot"
    TG_GROUP_NAME="LnCasettaBot_Client"
    BROKER_NAME="LnMqtt"


    g_prj_dir="${ln_GIT_REPO_DIR}/${PRJ_NAME}"
    g_productionProgram="${ln_LIVE_PRODUCTION}/${PRJ_NAME}.zip"
    g_tempCompiledProgram="/tmp/compiled/${PRJ_NAME}.zip"

    devel_Program="${ln_GIT_REPO_DIR}/${PRJ_NAME}/__main__.py"
    compiled_Program="/tmp/compiled/${PRJ_NAME}.zip"
    production_Program="${ln_LIVE_PRODUCTION}/${PRJ_NAME}.zip"



    source "${ln_SET_LORETO_ENVIRONMENT}" "$0" >/dev/null
    source "${scriptDir}/common-service.sh"

    setEnvars $*

    parseInput $*
    pyProgram=$devel_Program # default per lo status
    checkAction "$action"
    [[ "g_fEXECUTE" -eq "0" ]] && echo -e "${TAByellowH}enter --go to execute the command"
    echo