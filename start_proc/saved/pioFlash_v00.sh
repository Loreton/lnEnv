#!/usr/bin/bash




#############################################
#
#############################################
function parseInput() {
    local args=$*
    g_fEXECUTE=0
    g_fUPLOAD=0
    g_DRY_RUN='--dry-run'
    # check rhe word and remove it from args
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''
    word='--warning';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && { LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_WARN}"; }
    word='--info';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && { LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_INFO}"; }
    word='--notify';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && { LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_NOTIFY}"; }
    word='--debug';    [[ " $args " == *" $word "* ]] && args=${args//$word/} && { LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_DEBUG}"; }
    word='--upload';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && { g_fUPLOAD=1; }

    # args=$(echo $args) # remove BLANKs
    g_Args=$(echo $args) # remove BLANKs

}


# Funzione per selezionare la porta seriale e gestire i flag di build
function  _selectPort() {
    echo "🔍 Porte seriali disponibili:"
    local PORTS=($(ls /dev/ttyUSB* /dev/ttyACM* /dev/tty.SLAB* 2>/dev/null))
    SELECTED_PORT="" # Variabile per la porta selezionata

    if [[ ${#PORTS[@]} -eq 0 ]]; then
        echo "❌ Nessuna porta trovata."
        return 1
    elif [[ ${#PORTS[@]} -eq 1 ]]; then
        SELECTED_PORT="${PORTS[0]}"
        echo "✅ Trovata una sola porta: $SELECTED_PORT. Selezionata automaticamente."
    else
        echo "available: ${PORTS[@]}"
        select P in "${PORTS[@]}"; do
            [[ -n "$P" ]] && SELECTED_PORT="$P" && break
            echo "Selezione non valida"
        done
    fi

    # Se non è stata selezionata alcuna porta (es. l'utente esce dalla selezione), esci.
    if [[ -z "$SELECTED_PORT" ]]; then
        echo "Operazione annullata o nessuna porta selezionata."
        return 1
    fi
}





function  setLogLevel() {
    local LOG_LEVEL_NONE=0
    local LOG_LEVEL_ERROR=1
    local LOG_LEVEL_WARN=2
    local LOG_LEVEL_INFO=3
    local LOG_LEVEL_NOTIFY=4
    local LOG_LEVEL_DEBUG=5
    local LOG_LEVEL_TRACE=6

    inp_args=$@
    LOG_LEVEL=""
    [[ -z "$inp_args" ]] && inp_args="info"

    # remove parameters-key from input arguments
    for word in $inp_args ; do
        case "$word" in
            warn)
                LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_WARN}"
                ;;
            info)
                LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_INFO}"
                ;;
            notify)
                LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_NOTIFY}"
                ;;
            debug)
                LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_DEBUG}"
                ;;
            trace)
                LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_TRACE}"
                ;;
            *)
                LOG_LEVEL=" -D LOG_LEVEL=${LOG_LEVEL_INFO}"
                ;;
        esac
    done

    # platformio.ini:
    #    build_flags=
    #        -D LOG_LEVEL=${sysenv.LOG_LEVEL} (singola variabile)
    #        ${sysenv.ADDITIONAL_BUILD_FLAGS}  (contenere anche più flags)
    #        ... altri
    #        -I Source/include
    #        -D __ln_MODULE_DEBUG_TEST__
    export ADDITIONAL_BUILD_FLAGS=$LOG_LEVEL
}


function _start_platformio() {
    _selectPort
    setLogLevel "$@"

    echo ""
    echo "      ------ Riepilogo ------------------------------------------"
    echo "      ---    Porta seriale selezionata: $SELECTED_PORT"
    echo "      ---    Flag di build aggiuntivi: \"$ADDITIONAL_BUILD_FLAGS\""
    echo "      ------ Fine Riepilogo --------------------------------------"


    echo "🛑 Chiudo eventuali miniterm attivi..."
    killall -q -w miniterm.py 2>/dev/null

    echo "🚀 Flash del firmware su $SELECTED_PORT..."
    # echo platformio run --target upload --upload-port "$SELECTED_PORT" -a "build_flags=$ADDITIONAL_BUILD_FLAGS" NON FUNZIONA
    platformio run --target upload --upload-port "$SELECTED_PORT"

    if [[ $? -ne 0 ]]; then
        echo "❌ Upload fallito"
        return 1
    else
        BAUD=115200
        echo "🖥️  Avvio monitor seriale su $SELECTED_PORT a $BAUD baud (colori ANSI)"
        python3 -m serial.tools.miniterm "$SELECTED_PORT" "$BAUD" --raw
    fi
}


_start_platformio $@