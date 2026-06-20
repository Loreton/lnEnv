#!/bin/bash


# PROGRAM_FILE='/home/pi/production/Telegram-Mqtt.zip'
# SERVICE_COMMAND="/usr/local/bin/python3.9 $PROGRAM_FILE telegram --bot-name LnBot --pass Loreto.Secret"

# redH='\033[1;31m'
# cyanH='\033[1;36m'
# yellowH='\033[1;33m'
# purpleH='\033[1;35m'
# colorReset='\033[0m' # No Color

####################################################
# Colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
####################################################
function set_colors() {
    redH='\033[1;31m'
    greenH='\033[1;32m'
    yellowH='\033[1;33m'
    blueH='\033[1;34m'
    purpleH='\033[1;35m'
    cyanH='\033[1;36m'
    grayH='\033[0;37m'
    colorReset='\033[0m' # No Color

    TAB='    '
    TABredH="${TAB}${redH}"
    TABgreenH="${TAB}${greenH}"
    TAByellowH="${TAB}${yellowH}"
    TABblueH="${TAB}${blueH}"
    TABpurpleH="${TAB}${purpleH}"
    TABcyanH="${TAB}${cyanH}"
    TABgrayH="${TAB}${grayH}"
}
set_colors



g_GO=false
g_LIST=false
g_DISABLE=false
g_REMOVE=false
g_ENABLE=false
g_UPDATE=false
# g_CREATE=false
g_EXIT=true  # exit if command in error
g_MQTT=false
g_TELEGRAM=false
g_serviceDir='/lib/systemd/system'


function getPaths() {
    scriptFullPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
    scriptDir="$(dirname $scriptFullPath)"
    scriptName="$(basename $scriptFullPath)"
    # echo $scriptName
    # prj_dir=${PWD}
}


#############################################
# -
#############################################
function parseInput() {
    inp_args=$@

    # remove parameters-key from input arguments
    for word in $@ ; do
        if [ $word == '--go' ]; then
            g_GO=true
            inp_args=${inp_args//$word/}

        elif [ $word == '--disable' ]; then
            g_DISABLE=true
            inp_args=${inp_args//$word/}

        elif [ $word == '--remove' ]; then
            g_REMOVE=true
            g_DISABLE=true
            inp_args=${inp_args//$word/}

        elif [ $word == '--list' ]; then
            g_LIST=true
            inp_args=${inp_args//$word/}

        elif [ $word == '--create' ]; then
            g_DISABLE=true
            g_REMOVE=true
            g_UPDATE=true
            g_ENABLE=true
            inp_args=${inp_args//$word/}

        elif [ $word == '--enable' ]; then
            g_DISABLE=true
            g_ENABLE=true
            inp_args=${inp_args//$word/}

        elif [ $word == '--update' ]; then
            g_DISABLE=true
            g_UPDATE=true
            inp_args=${inp_args//$word/}

        fi

    done

    # strip text
    inp_rest="$(echo $inp_args)" # ciò che rimane dell'input


}



#############################################
# -
#############################################
function esegui() {
    cmd=$*
    echo -n -e "${yellowH}      executing: $cmd ${colorReset}"
    if [[ $g_GO == true ]]; then
        eval sudo $cmd
        rCode=$?
        echo "rCode: $rCode"
        [[ ! "$rCode" -eq 0 ]] && [[ "$g_EXIT" == true ]] && exit $rCode
    fi
    echo

}



function list_services() {
    echo
    for dir in ${g_template_dirs}; do
        # echo -e "  $yellowH services on dir: \"$dir\" "
        cd ${dir}
        # yourfilenames=$(ls *.service.tpl)
        yourfilenames=$(ls *.tpl)

        suffix_len=${#g_suffix}
        tpl_suffix_len=${#g_tpl_suffix}
        # echo $suffix_len
        echo
        echo -e "  $cyanH available services on dir: $dir"
        for eachfile in $yourfilenames; do
            # echo $eachfile
            var1=${eachfile::-${suffix_len}} # remove .service.tpl
            var2=${eachfile::-${tpl_suffix_len}} # remove .tpl
            service_file="${g_serviceDir}/${var2}"
            # echo "Service file: $service_file"
            echo -n -e "      $purpleH $var1"
            if [[ -f ${service_file} ]];then
                echo -e "  $yellowH - ${service_file}"
            else
                echo -e " $cyan - service file does not exists"
            fi
        done
    done

    echo
}

function production() {
    # if [[ "$1" == *"@"* ]]; then
    #     local service_name="$1"
    # else
    #     local service_name="$1.service"
    # fi
    local service_name="$1"

    local service_file="${g_serviceDir}/${service_name}"

    g_EXIT=false
    if [[ $g_DISABLE == true ]]; then
        echo
        echo -e "  $cyanH ----- DISABLE:"
        esegui systemctl stop ${service_name}
        esegui systemctl disable ${service_name}
        esegui systemctl daemon-reload
    fi

    if [[ $g_REMOVE == true ]]; then
        echo
        echo -e "  $cyanH ----- REMOVE:"
        esegui systemctl stop ${service_name}
        esegui systemctl disable ${service_name}
        esegui rm -f ${service_file}
        esegui systemctl daemon-reload
    fi

    g_EXIT=true

    if [[ $g_UPDATE == true ]]; then
        echo
        echo -e "  $cyanH ----- UPDATE:"
        esegui systemctl stop ${service_name}
        esegui systemctl disable ${service_name}
        esegui cp "${g_service_template_file}" "${service_file}"
        esegui chmod 644 "${service_file}"
        esegui systemctl enable ${service_name}
        esegui systemctl daemon-reload
    fi

    if [[ $g_ENABLE == true ]]; then
        echo
        echo -e "  $cyanH ----- ENABLE:"
        esegui systemctl enable ${service_name}
        esegui systemctl daemon-reload
        echo -e "    $purpleH  systemctl start ${service_name}"
    fi

    if [[ -f ${service_file} ]]; then
        esegui cat "${service_file}"

    else
        echo
        echo "  Service file: ${service_file} NOT found"
        echo
        exit 1
    fi
}




############## M A I N  ################
    getPaths

    prj_bindir="$prj_dir/bin"

    cd $scriptDir

    # ---
    # parse input arguments
    # ---
    parseInput $@

    # ---
    # prepare service_name and template
    # ---
    g_service_name="${inp_rest}" # ciò che rimane lo consideriamo service_name

    g_suffix='.service.tpl'
    g_suffix='.tpl'
    g_tpl_suffix='.tpl'
    hostname=$(hostname -s)

    # remove
    #serv_name='mqtt-client_svil_sh.service' && sudo systemctl disable $serv_name && sudo systemctl daemon-reload &&  sudo rm -f /lib/systemd/system/$serv_name

    # g_template_dirs="${ln_SYSTEMD_DIR}/scripts/templates_for_scripts ${ln_SYSTEMD_DIR}/templates"
    # g_template_dirs="${ln_SYSTEMD_DIR}/templates/system ${ln_SYSTEMD_DIR}/templates/loreto ${ln_SYSTEMD_DIR}/templates/pi"
    g_template_dirs="${ln_SYSTEMD_DIR}/templates/system"
    if [[ "${hostname,,}" == *"lnpi"* ]]; then
        g_template_dirs="${g_template_dirs} ${ln_SYSTEMD_DIR}/templates/pi"
    else
        g_template_dirs="${g_template_dirs} ${ln_SYSTEMD_DIR}/templates/loreto"
    fi


    for dir in $g_template_dirs; do
        g_service_template_file="${dir}/${g_service_name}${g_suffix}"
        [[ -f $g_service_template_file ]] && break
    done

    [[ ! -f $g_service_template_file ]] && list_services && exit 1
    echo -e "  $yellowH template file: $g_service_template_file $colorReset"
    if [[ $g_DISABLE == false ]] && [[ $g_LIST == false ]]; then
        echo
        echo "  Please enter one or more of the following options:"
        echo "      --create   - create service file, enable"
        echo "      --disable  - stop, disable service, reload"
        echo "      --enable   - enable, reload, start service"
        echo "      --update   - stop, disable service, refresh service file, enable"
        echo "      --remove   - stop, disable service, remove service file"
        echo "      --list     - display service file"
        echo
        echo "      --go       - to execute "
        echo
        exit 1
    fi

    # if [[ $g_LIST == true ]]; then
    #     cat ${service_file}
    #     exit 0
    # fi
    # ---
    # prepare service_file and run
    # ---
    production $g_service_name


    echo
    # echo -e "     ${cyanH}to load aliases:         ${purpleH} source $alias_file"
    echo -e "     ${cyanH}to start service:         ${purpleH} sudo systemctl start ${g_service_name}"
    echo -e "     ${cyanH}to see journal service:   ${purpleH} sudo journalctl -f -u ${g_service_name}"
    echo

    # [[ $g_GO == true ]] && journalctl -fu ${g_service_name}