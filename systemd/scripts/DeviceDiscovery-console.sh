#!/bin/bash
# ---------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 27-08-2023 17.33.14
# ---------------------------------------



#=====================================
#=
#=====================================
function setEnvars() {
    source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors mariadb" >/dev/null

    # dopo le altre vars altrimenti fanno override
    local scriptFullPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
    scriptDir="$(dirname $scriptFullPath)"
    local scriptName="$(basename $scriptFullPath)"

    APPL_NAME='DeviceDiscovery'
    LOGGER_DIR="/tmp/${APPL_NAME}"
    /bin/mkdir -m 740 -p ${LOGGER_DIR}


    logger_console='info'
    logger_level='warning'

    g_pythonProgram=
    update_DB=

}


#=====================================
#=
#=====================================
function setProgram() {

    [[ -z "$g_pythonProgram" ]] && help

    commandLineString="/usr/bin/python \
                "${g_pythonProgram}" \
                --appl-name "${APPL_NAME}" \
                --logger-dir "${LOGGER_DIR}" \
                --runtime-dir "${ln_RUNTIME_DIR}" \
                --dbexport-dir "${ln_RUNTIME_DIR}/mariadb_exported" \
                --logger-console "${logger_console}" \
                --logger-level "${logger_level}" \
                --max-threads 50 \
                $update_DB \
                "

    commandLineString=$(echo "$commandLineString" | tr -s " ") # Remove extra BLANK
}




##################################
#
#############################################
function parseInput() {
    #-------------------------------------------
    #
    #-------------------------------------------
    function help() {
        echo -e "$TAByellowH    syntax $(basename $BASH_SOURCE) profile_name [options..]"
        echo -e "${cyanH}"
        echo "${TAB}Options:
            -h|--help           this help
            --main              run source code calling __main__.py module
            --prod              run production zip program
            --compiled          run compiled.zip program
            --go                really execute commands
            --update-db         to modify DBase
            --xxx               extra options for program
            "

        echo -e "${colorReset}"
        echo
        exit 2
    }


    local args=$*
    echo "${TAB}command line: $args"
    [[ -z $args ]] && help && exit 1
    g_fEXECUTE=0
    g_Action='main'


    # check rhe word and remove it from args
    word='-h';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax 1 && exit 1
    word='--help';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax 1 && exit 1
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1
    word='--main';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_Action=$word
    word='--prod';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_Action=$word
    word='--compiled'; [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_Action=$word

    g_Rest=$(echo $args) # remove BLANKs
    echo "${TAB}input args:   $g_Rest"
    echo
}





################################
# M A I N
################################
TAB='    '

set -u

setEnvars

parseInput $*

case $g_Action in

    --main)
        logger_console='info'
        logger_level='debug'
        g_pythonProgram="${HOME}/GIT-REPO/${APPL_NAME}/__main__.py"
        ;;

    --prod)
        g_pythonProgram="${ln_LIVE_PRODUCTION}/${APPL_NAME}.zip"
        ;;

    --compiled)
        logger_console='info'
        logger_level='debug'
        zip_file="/tmp/compiled/${APPL_NAME}.zip"
        source ${scriptDir}/createPythonPrjZipFile.sh "$APPL_NAME" "$zip_file"
        g_pythonProgram="$zip_file"
        echo
        ;;

    *)
        help
        ;;
esac

    setProgram
    echo -e "${TAByellowH}${commandLineString} ${g_Rest}${colorReset}"
    [[ "$g_fEXECUTE" -eq '1' ]] && ${commandLineString} ${g_Rest} || echo -e "${TABcyanH}enter --go to execute"
    echo



