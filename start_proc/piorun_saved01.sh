#!/usr/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 22-11-2025 16.04.02
# Updates:
#
# #########################################################


####################à
# Colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
cyan='\033[0;36m'

redH='\033[1;31m'
cyanH='\033[1;36m'
yellowH='\033[1;33m'
purpleH='\033[1;35m'
colorReset='\033[0m' # No Color
TAB='    '
TABredH="${TAB}${redH}"
TAByellowH="${TAB}${yellowH}"




####################################################
#
####################################################
function esegui() {
    CMD_DESCR=$1
    cmd=$2
    # exit_on_error=${3:-exit}
    exit_on_error=${3:-no_exit_on_error}

    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        action="${purpleH} [executing]: "
    else
        action="${purpleH} [dry-run]: [${exit_on_error}] "
    fi

    echo -e "${TAB}${action}${cyanH} ${CMD_DESCR}${colorReset} "
    echo -e "${TAB}${TAB}${yellowH} ${cmd} ${colorReset}"
    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        eval $cmd
        rCode=$?
        if [[ "$rCode" -ne 0 ]]; then
            echo -e "${TAB}❌ [${rCode}] command  failed!\n"
            [[ "$exit_on_error" == "exit" ]] && exit $rCode
        fi
    fi
    CMD_DESCR=
    echo
}

#############################################
#
#############################################
function syntax() {
    g_script_name=$(basename ${BASH_SOURCE[0]})
    echo " $g_script_name:  arguments:"
    echo
    echo "${TAB}edit          ### edit this script: $g_script_name"
    echo "${TAB}stack[trace]  ### debug command to capture program line causing esp32 restart!"
    echo
    echo "$TAB--complile    ### compile program"
    echo "$TAB--monitor     ### start miniterm to monitor serial port"
    echo "$TAB--upload      ### compile and upload firmware and start monitor"
    echo "$TAB--clean       ### platformio clean compilation area"
    echo
    echo "$TAB--32e         ### ESP32 board senza relays"
    echo "$TAB--32e_2relay  ### ESP32 board con due relay a bordo"
    echo
    echo "$TAB--warn|info|notify|debug|trace    ### select default log level"
    echo
    echo "$TAB--go          ### to execute commands"
    echo
    exit
}


#############################################
#
#############################################
function parseInput() {
    local args=$*

    [[ -z $args ]] && syntax && exit


    g_log_level_default="undefined"
    g_fUPLOAD="false"
    g_fMONITOR="false"
    g_fCOMPILE="false"
    g_RELEASE="undefined"
    g_BOARD_TYPE="undefined"
    # ln_test=1
    # ln_PRODUCTION=2

    g_fEXECUTE=0
    g_DRY_RUN='--dry-run'

    # check rhe word and remove it from args
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''

    word='--error';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_log_level_default="error"; }
    word='--warning';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_log_level_default="warn"; }
    word='--info';          [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_log_level_default="info"; }
    word='--notify';        [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_log_level_default="notify"; }
    word='--debug';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_log_level_default="debug"; }
    word='--trace';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_log_level_default="trace"; }

    word='--test';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_RELEASE=$ln_TEST; }
    word='--prod';          [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_RELEASE=$ln_PRODUCTION; }

    word='--32e';           [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_BOARD_TYPE=$ln_ESP32_WROOM_32E_MODULE; }
    word='--32e_2relay';    [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_BOARD_TYPE=$ln_ESP32_WROOM_32E_MODULE_2RELAY; }

    word='--compile';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_fCOMPILE="true"; }
    word='--upload';        [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_fUPLOAD="true"; g_fMONITOR="true"; }
    word='--monitor';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_fMONITOR="true"; }
    word='--clean';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && { platformio run --target clean; exit 0; }

    g_Args=$(echo $args) # remove BLANKs

    if [[ "$g_log_level_default" == "undefined" ]]; then
        echo -e "${TABredH}logging level is mandatory:"
        echo -e "${TAByellowH}--error, --warn, --info, --notify, --debug, --trace"
        echo -e "${colorReset}"
        exit 1
    fi

    if [[ "$g_BOARD_TYPE" == "undefined" ]]; then
        echo -e "${TABredH}board type is mandatoory:"
        echo -e "${TAByellowH} --32e --32e_2relay"
        echo -e "${colorReset}"
        exit 1
    fi


    if [[ "$g_RELEASE" == "undefined" ]]; then
        echo -e "${TABredH}release is mandatory:"
        echo -e "${TAByellowH} --prod --test"
        echo -e "${colorReset}"
        exit 1
    fi




}

#######################################################################
# Funzione per selezionare la porta seriale e gestire i flag di build
#######################################################################
function  selectUsbPort() {
    echo "🔍 Porte seriali disponibili:"
    local PORTS=($(ls /dev/ttyUSB* /dev/ttyACM* /dev/tty.SLAB* 2>/dev/null))
    g_SELECTED_PORT="" # Variabile per la porta selezionata

    if [[ ${#PORTS[@]} -eq 0 ]]; then
        echo "❌ Nessuna porta trovata."
        return 1
    elif [[ ${#PORTS[@]} -eq 1 ]]; then
        g_SELECTED_PORT="${PORTS[0]}"

        echo "✅ Trovata una sola porta: $g_SELECTED_PORT. Selezionata automaticamente."
    else
        echo "available: ${PORTS[@]}"
        select P in "${PORTS[@]}"; do
            [[ -n "$P" ]] && g_SELECTED_PORT="$P" && break
            echo "Selezione non valida"
        done
    fi
}



#######################################################################
#
#######################################################################
function _start_platformio() { # verificare nel file /home/loreto/GIT-REPO/ESP32/esp32LnLibrary/lnLibrary/lnLogger_Class/lnLogger_Class.h
    # Dizionario Bash: nome livello → valore
    # --- definito in dflags.sh
    # --- definito in dflags.sh
    # --- definito in dflags.sh
    # declare -A LOG_LEVEL_MAP=(
    #       ["none"]=0
    #      ["error"]=1
    #       ["warn"]=2
    #    ["special"]=3
    #     ["notify"]=4
    #       ["info"]=5
    #      ["debug"]=6
    #      ["trace"]=7
    # )


    declare -A TRUE_FALSE_MAP=(
        ["false"]=0
        ["true"]=1
    )

    set -u
    parseInput $@



    # variabile letta da platformio.ini
    myExtra_DFLAGS="-DLOG_LEVEL_DEFAULT=${LOG_LEVEL_MAP[${g_log_level_default}]}"
    myExtra_DFLAGS="${myExtra_DFLAGS} -Dln_ESP32_BOARD_TYPE=${g_BOARD_TYPE}"
    myExtra_DFLAGS="${myExtra_DFLAGS} -Dln_RELEASE_TYPE=${g_RELEASE}"

    export ln_PIORUN_BUILD_FLAGS="${myDFLAGS} ${myExtra_DFLAGS}"

    if [[ ! -z "$g_Args" ]]; then
        echo "      ---- remaining args: $g_Args"
        echo
        return 1
    fi

    selectUsbPort # NON facciamo controllo perchè viene fatto dopo; [[ "$?" != 0 ]] && exit 1
    dq='"'

    echo ""
    echo -e "      ------ Riepilogo ------------------------------------------"
    echo -e "      ---    LOG_LEVEL_DEFAULT:           ${cyanH}$g_log_level_default"
    echo -e "      ---    UPLOAD:                      ${cyanH}$g_fUPLOAD"
    echo -e "      ---    COMPILE:                     ${cyanH}$g_fCOMPILE"
    echo -e "      ---    MONITOR:                     ${cyanH}$g_fMONITOR"
    echo -e "      ---    build_flags:${cyan}"
        for item in $ln_PIORUN_BUILD_FLAGS; do
            echo -e "                 $item"
        done

    echo -en "${cyanH}"
    echo -e "      -------------"
    echo -e "      ---    Porta seriale selezionata:   ${g_SELECTED_PORT:-${redH}NOT AVAILABLE}$colorReset"
    echo -e "      ------ Fine Riepilogo --------------------------------------"
    echo -e "      ------ in caso di errore durante il caricamento: --------------------------------------"
    echo -e "      ------ sudo usermod -a -G dialout $USER (oppure sudo adduser $USER dialout) -----------"
    echo -e "      ------ rifare login -----------"
    echo -e "      ------ verificare: id -nG (oppure groups) -----------"
    echo -e "      ------ Vedi chi la usa: sudo lsof /dev/ttyUSB0 oppure sudo fuser -v /dev/ttyUSB0 -----------"
    echo

    #--- prepara per upload se richiesto e lancia la compilazione
    if [[ "$g_fCOMPILE" == "true" ]]; then
        EXTRA_ARGS="-j1";

        esegui "🚀 Compiling ..." "platformio run $EXTRA_ARGS" "exit"
    fi


    #--- prepara per upload se richiesto e lancia la compilazione
    if [[ "$g_fUPLOAD" == "true" ]]; then
        if [[ -z "$g_SELECTED_PORT" ]]; then
            echo "Operazione annullata o nessuna porta selezionata."
            return 1
        fi

        EXTRA_ARGS="--target upload --upload-port $g_SELECTED_PORT";
        esegui "🚀 Flash del firmware su $g_SELECTED_PORT..." "platformio run -j1 $EXTRA_ARGS" "exit"
    fi



    #--- chiude il miniterm se attivo e poi lo lancia
    if [[ "$g_fMONITOR" == "true" ]]; then
        if [[ -z "$g_SELECTED_PORT" ]]; then
            echo "Operazione annullata o nessuna porta selezionata."
            return 1
        fi
        esegui "🛑 Chiudo eventuali miniterm attivi..." "killall -q -w miniterm.py 2>/dev/null" "no_exit"

        BAUD=115200
        esegui "🖥️  Avvio monitor seriale su $g_SELECTED_PORT a $BAUD baud (colori ANSI)" "python3 -m serial.tools.miniterm "$g_SELECTED_PORT" "$BAUD" --raw" "exit"
    fi
}




function getGitProjectDir() {
    # Parti dalla directory corrente
    DIR="$PWD"
    GIT_DIR=

    while [[ "$DIR" != "/" ]]; do
        if [[ -e "$DIR/.git" ]]; then
            # .git esiste: può essere directory o file
            if [[ -d "$DIR/.git" ]]; then
                # .git è una directory: repo principale
                GITDIR="$DIR"
            elif [[ -f "$DIR/.git" ]]; then
                # .git è un file (worktree), estraggo il percorso reale
                GITDIR=$(awk -F': ' '/^gitdir:/ {print $2}' "$DIR/.git")
                # GITDIR può essere relativo, lo rendo assoluto se serve
                [[ "$GITDIR" != /* ]] && GITDIR="$DIR/$GITDIR"
            fi
            GIT_DIR=$DIR


        fi
        # Salgo di una directory
        DIR="$(dirname "$DIR")"
    done

    if [[ -z $GIT_DIR ]]; then
        echo "Directory .git non trovata"
        exit 1
    fi

}


##########################################################
#               M A I N
##########################################################
if [[ "$1" == "edit" || "$1" == "subl" ]]; then
    /home/loreto/lnprofile/sh_scripts/start_proc/sublimeStart.sh $BASH_ARGV0
    exit 0
fi

# if [[ "$1" == "stacktrace" ]]; then
if [[ " $1 " == " stack"*  ]]; then
    shift 1
    cd "/media/loreto/LnDisk_SD_ext4/Filu/GIT-REPO/ESP32/esp/esp-idf"
    source ./export.sh
    # echo -e "$TAByellowH xtensa-esp32-elf-addr2line -e .pio/build/esp32_littleFS/firmware.elf [.... stack_trace 0x4008ac8e:0x3ffb1a40 0x4015ec4d:0x3ffb1a50 0x401637ba:0x3ffb1d60 .... ]"
    # /home/loreto/.espressif/tools/xtensa-esp-elf/esp-15.1.0_20250607/xtensa-esp-elf/bin/xtensa-esp32-elf-addr2line -e .pio/build/esp32_littleFS/firmware.elf "$@"
    xtensa-esp32-elf-addr2line -e .pio/build/esp32_littleFS/firmware.elf "$@"
    exit 0
fi


# set -x
dflags_sh="./project_dflags.sh" ### guarda nell dir locale
# if [[ ! -f "$dflags_sh" ]]; then
    # getGitProjectDir NON ricordo a cosa serve
    # echo $GIT_DIR
    # dflags_sh="$GIT_DIR/project_dflags.sh" ### altrimenti mnella dir di git del progetto
    # echo $dflags_sh
    # set +x
    # read
# fi
[[ -f "$dflags_sh" ]] && [[ ! -x "$dflags_sh" ]] && "echo $dflags_sh non è eseguibile" && exit 1
echo -e "executing $dflags_sh"

source "$dflags_sh"
_start_platformio $@

