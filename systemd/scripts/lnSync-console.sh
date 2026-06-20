#!/bin/bash
# ---------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 07-02-2024 16.16.37
# ---------------------------------------

#=============================================
# Richiamato dal systemctl service
# /home/loreto/lnprofile/systemd/templates/mqttMonitor@user.service.tpl
# ed usato anche per testare da command line
#=============================================



function setProgram() {
    extra=$@
    if [[ ! $action == "--status" ]]; then
        [[ ! -f $pyProgram &&  ! $action == "--status" ]] && echo "python program [$pyProgram] NOT found!" && exit 2
    fi

    CONFIG_FILE=conf/@lnSync_config.yaml
    ### override commons-service.sh
    LOG_CONSOLE='info'
    LOG_LEVEL='info'

                # --logging-dir ${LOGGER_DIR} \
                # --runtime-dir $ln_RUNTIME_DIR/lnSync \
                # --file-logger-level $LOG_LEVEL \
    programExecStart="/usr/bin/python ${pyProgram}\
                --console-logger-level $LOG_CONSOLE \
                --config-file $CONFIG_FILE \
                ${extra}"
                # --pid-file ${pidFile} \

    programExecStart=$(echo "$programExecStart" | tr -s " ") # Remove extra BLANK

}


function get_PID() {
    # AND non esiste con il grep quindi li faccio separati
    ps_cmd="ps -ef | grep -v 'grep' | grep -i -- python | grep -i '${LOGGER_DIR}' | grep -iE -- '--rsync|--rclone'  | grep -i '$CONFIG_FILE' "
    echo "      $ps_cmd"
    g_process=$(eval $ps_cmd)
    g_PID=$(echo $g_process | awk '{print $2}')

    echo -e "${TABcyanH}process PID: $g_PID"

    ### display process
    [[ ! -z "$g_PID" ]] && ps -p $g_PID -lF | grep $g_PID
}



############################################
#               M A I N
############################################
    action="${1}"
    shift 1
    # [[ -d '/home/loreto/.ln' ]] && export HOME='/home/loreto'
    # [[ -d '/home/pi/.ln' ]] && export HOME='/home/pi'

    source "${ln_SET_LORETO_ENVIRONMENT}" "$0" >/dev/null

    APPL_NAME="lnSync"
    PRJ_NAME="lnSync"

    g_prj_dir="${ln_GIT_REPO_DIR}/${PRJ_NAME}"
    g_productionProgram="${ln_LIVE_PRODUCTION}/${APPL_NAME}.zip"
    g_tempCompiledProgram="/tmp/compiled/${APPL_NAME}.zip"

    devel_Program="${ln_GIT_REPO_DIR}/${PRJ_NAME}/__main__.py"
    compiled_Program="/tmp/compiled/${PRJ_NAME}.zip"
    production_Program="${ln_LIVE_PRODUCTION}/${PRJ_NAME}.zip"


    source "${scriptDir}/common-service.sh"

    setEnvars $*

    ### skip ParseInput ... non mi serve per questa applicazione
    g_fEXECUTE=1
    g_Args="$@"

    pyProgram=$devel_Program # default per lo status
    checkAction "$action"
    echo