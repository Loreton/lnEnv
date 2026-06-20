#!/bin/bash
# ---------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 14-05-2024 08.14.39
# ---------------------------------------


#############################################
# prevede almeno APPL_NAME definita
#############################################
function setEnvars() {
    set -u
    local host=$(hostname -s)
    host_name=${host,,} # in lower case

    appl_name="${PRJ_NAME,,}"
    service_name="${appl_name}@${USER}.service"

    # solo per evitare errore di vriabile non definita
    SYSTEMD='dummy'
    LOG_CONSOLE='dummy'
    LOG_LEVEL='dummy'
    # solo per evitare errore di vriabile non definita

    LOGGER_DIR="/tmp/${PRJ_NAME}"
    pidFile="${LOGGER_DIR}/${PRJ_NAME}.pid"

    /bin/mkdir -m 740 -p ${LOGGER_DIR}
    StandardOutput="${LOGGER_DIR}/stdout_py.log"
    StandardError="${LOGGER_DIR}/stderr_py.log"
}



#############################################
#
#############################################
function parseInput() {
    local args=$*
    local saved_args=$*
    # [[ -z $args ]] && syntax
    g_fEXECUTE=0
    # g_DRY_RUN='--dry-run'

    # check rhe word and remove it from args
    # word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1

    # if [[ "${fMaintainGO}" -eq "1" ]]; then
    # word='--go';       [[ " $args " == *" $word "* ]] && g_fEXECUTE=1 && g_DRY_RUN=''  ### do not delete word
    # else
    # fi


    g_Args=$(echo $args) # remove BLANKs

    if [[ "g_fEXECUTE" -eq "0" ]]; then
        echo -e "${TABpurple}args passed on command line:      $saved_args"
        echo -e "${TABpurple}args will be forwaded to program: $g_Args"
        echo
    fi
}



#############################################
#
#############################################
function displayCommand() {
    echo -e "${TAByellow}The following command will be executed:
    ${cyanH}
    ${programExecStart}
    ${colorReset} "
    # [[ "g_fEXECUTE" -eq "0" ]] && echo -e "${TAByellowH} enter --go argument to execute the command\n\n"
}



# #############################################
# #
# #############################################
function zip_project() {
    local dir=$1

    if [ -d "$dir" ]; then
        saved_dir=$PWD
        dir_name=$(basename $dir)
        parent_dir=$(dirname $dir)
        zipName="${parent_dir}/${dir_name}.zip"
        cd "$parent_dir"
        for name in *; do
            zip -ur --latest-time $zipName $(basename $dir)
        done
        cd "$saved_dir" # ritorna alla previos dir
    fi
}




############################################
#               M A I N
############################################

function checkAction() {
    action=$1
    case ${action} in
        --liveprod) # used by systemctl ma non è affidabile
            SYSTEMD=''
            LOG_CONSOLE='critical'
            LOG_LEVEL='notify'

            savedDir=$PWD
            cd /tmp ### per fare il run fuori dalla dir del progetto

            pyProgram=$production_Program
            setProgram $g_Args
            displayCommand
            [[ "g_fEXECUTE" -eq "1" ]] && exec $programExecStart
            cd $savedDir ### ripristina la directory originale
            ;;

        --compiled) # test start
            SYSTEMD=''
            LOG_CONSOLE='notify'
            LOG_LEVEL='info'

            savedDir=$PWD
            cd $g_prj_dir ### per fare la compilazione
            $ln_LIVE_PRODUCTION/python_ZipProject.lnk.sh
            cd /tmp ### per fare il run fuori dalla dir del progetto

            pyProgram=$compiled_Program
            setProgram $g_Args
            displayCommand
            [[ "g_fEXECUTE" -eq "1" ]] && exec $programExecStart
            cd $savedDir ### ripristina la directory originale
            ;;

        --main)
            SYSTEMD=''
            LOG_CONSOLE='info'
            LOG_LEVEL='notify'
            cd $g_prj_dir ### altrimenti non va...
            pyProgram=$devel_Program
            setProgram $g_Args
            displayCommand
            [[ "g_fEXECUTE" -eq "1" ]] && exec $programExecStart
            ;;

        --stop) # used by systemctl, carefull using it manually
            setProgram
            get_PID
            echo
            echo  "killing process: $g_PID"
            echo
            [[ "g_fEXECUTE" -eq "1" ]] && echo $g_PID | xargs kill
            ;;

        --status) # used by systemctl do not use it manually
            setProgram
            echo -e "${yellowH}"
            get_PID
            echo -e "${colorReset}"
            g_fEXECUTE=1 # force it
            ;;

        *)
            # ${yellowH}--systemd_start    ${colorReset}utilizzato dal comando di systemctl start $service_name
            echo -e "${TAB}Options:
            ${yellowH}--main             ${colorReset} __main__.py
            ${yellowH}--compiled         ${colorReset} /tmp/compiled/app.zip
            ${yellowH}--stop             ${colorReset} vale per tutte le options
            ${yellowH}--status           ${colorReset} vale per tutte le options
            "

            exit 3
            ;;
    esac
}


