#!/usr/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 22-02-2026 15.17.01
# Updates:
#
# #########################################################



if ! declare -F @setColors    > /dev/null; then source colors.functions; fi
if ! declare -F @lnEsegui     > /dev/null; then source esegui.functions; fi
if ! declare -F @lnLog        > /dev/null; then source ln_log.functions; fi



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
        @lnLog "${redH}logging level is mandatory:"
        @lnLog "${yellowH}--error, --warn, --info, --notify, --debug, --trace"
        @lnLog "${colorReset}"
        exit 1
    fi

    if [[ "$g_BOARD_TYPE" == "undefined" ]]; then
        @lnLog "${redH}board type is mandatoory:"
        @lnLog "${yellowH} --32e --32e_2relay"
        @lnLog "${colorReset}"
        exit 1
    fi


    if [[ "$g_RELEASE" == "undefined" ]]; then
        @lnLog "${redH}release is mandatory:"
        @lnLog "${yellowH} --prod --test"
        @lnLog "${colorReset}"
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

    @lnLog "executing: source $local_dflags_file"
    source $local_dflags_file

    parseInput $@

    # variabili referenziate da platformio.ini
    myExtra_DFLAGS="-DlnLOG_LEVEL_DEFAULT=${LOG_LEVEL_MAP[${g_log_level_default}]}"
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
    @lnLog "------ Riepilogo ------------------------------------------"
    @lnLog "---    lnLOG_LEVEL_DEFAULT:           ${cyanH}$g_log_level_default"
    @lnLog "---    UPLOAD:                      ${cyanH}$g_fUPLOAD"
    @lnLog "---    COMPILE:                     ${cyanH}$g_fCOMPILE"
    @lnLog "---    MONITOR:                     ${cyanH}$g_fMONITOR"
    @lnLog "---    build_flags:${cyan}"
        for item in $ln_PIORUN_BUILD_FLAGS; do
            if [[ "$item" == *"DlnLOG_LEVEL_DEFAULT"* || "$item" == *"Dln_ESP32_BOARD_TYPE"* || "$item" == *"Dln_RELEASE_TYPE"* ]]; then
                @lnLog "           ${yellow}${item}"
            else
                @lnLog "           ${cyan}${item}"
            fi
        done

    echo -en "${cyanH}"
    @lnLog "-------------"
    @lnLog "---    Porta seriale selezionata:   ${g_SELECTED_PORT:-${redH}NOT AVAILABLE}$colorReset"
    @lnLog "------ Fine Riepilogo --------------------------------------"
    @lnLog "------ in caso di errore durante il caricamento: --------------------------------------"
    @lnLog "------ sudo usermod -a -G dialout $USER (oppure sudo adduser $USER dialout) -----------"
    @lnLog "------ rifare login -----------"
    @lnLog "------ verificare: id -nG (oppure groups) -----------"
    @lnLog "------ Vedi chi la usa: sudo lsof /dev/ttyUSB0 oppure sudo fuser -v /dev/ttyUSB0 -----------"
    echo

    #--- prepara per upload se richiesto e lancia la compilazione
    if [[ "$g_fCOMPILE" == "true" ]]; then
        EXTRA_ARGS="-j1";
        echo -e "\t\t${yellowH}Assicurarsi che in platformio sia presente:"
        echo -e "\t\t${yellowH}build_flags= " '${sysenv.ln_PIORUN_BUILD_FLAGS}'
        echo -e "${resetColor}\n"
        @lnEsegui "platformio run $EXTRA_ARGS"
    fi


    #--- prepara per upload se richiesto e lancia la compilazione
    if [[ "$g_fUPLOAD" == "true" ]]; then
        if [[ -z "$g_SELECTED_PORT" ]]; then
            echo "Operazione annullata o nessuna porta selezionata."
            return 1
        fi

        EXTRA_ARGS="--target upload --upload-port $g_SELECTED_PORT";
        @lnLog "🚀 Flash del firmware su $g_SELECTED_PORT..."
        @lnEsegui "platformio run -j1 $EXTRA_ARGS" "exit_on_error"

    fi



    #--- chiude il miniterm se attivo e poi lo lancia
    if [[ "$g_fMONITOR" == "true" ]]; then
        if [[ -z "$g_SELECTED_PORT" ]]; then
            echo "Operazione annullata o nessuna porta selezionata."
            return 1
        fi
        @lnLog "🛑 Chiudo eventuali miniterm attivi..."
        @lnEsegui "killall -q -w miniterm.py 2>/dev/null" "no_exit"

        BAUD=115200
        @lnEsegui "python3 -m serial.tools.miniterm $g_SELECTED_PORT $BAUD --raw" "exit_on_error"
    fi
}






##########################################################
#               M A I N
##########################################################
    # script_dir="${BASH_SOURCE%/*}" ###. get parent dir
    set -u
    script_path="$(readlink -fvs  $BASH_SOURCE)"
    script_dir=$(dirname $script_path)
    fLOG=1

    echo -e "$green"

    ### ===================================================
    ### per catturare lo stack trace dell'errore
    if [[ " $1 " == " stack"*  ]]; then
        shift 1
        cd "/media/loreto/LnDisk_SD_ext4/Filu/GIT-REPO/ESP32/esp/esp-idf"
        source ./export.sh
        # @lnLog "$TAByellowH xtensa-esp32-elf-addr2line -e .pio/build/esp32_littleFS/firmware.elf [.... stack_trace 0x4008ac8e:0x3ffb1a40 0x4015ec4d:0x3ffb1a50 0x401637ba:0x3ffb1d60 .... ]"
        # /home/loreto/.espressif/tools/xtensa-esp-elf/esp-15.1.0_20250607/xtensa-esp-elf/bin/xtensa-esp32-elf-addr2line -e .pio/build/esp32_littleFS/firmware.elf "$@"
        xtensa-esp32-elf-addr2line -e .pio/build/esp32_littleFS/firmware.elf "$@"
        exit 0
    fi
    ### ===================================================

    main_dflags_file="${script_dir}/piorun_dflags.sh" ### dove trovare dflags.sh
    local_dflags_file="./project_dflags.sh" ### dove trovare dflags.sh
    if [ "$main_dflags_file" -nt "$local_dflags_file" ]; then ## -nt: newer than, -ot_ older than
        @lnEsegui "cp -p "${main_dflags_file}" "${local_dflags_file}" "
        chmod u+x "$local_dflags_file"
    fi

    # [[ -z $dflags ]] && { @lnLog "${redH}ERROR: dflags files: [$dflags_sh] were not found\n"; exit 1; }
    # [[ ! -x $dflags_file ]] && { @lnLog "${redH}ERROR: $dflags is not executable\n"; exit 1; }


    _start_platformio $@


    echo -e "$colorReset"

