#!/usr/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 08-08-2025 09.50.07
# Updates:




# === UNIVERSAL PYTHON VENV ACTIVATOR WITH AUTO-DETECT ===
# Usage:
#   source activate_venv.sh           # => cerca ./.venv
#   source activate_venv.sh /path/to/venv_name



####################################################
#
####################################################
# === ANSI color codes ===
# function defineColors() { #### NON FUNZIONA
    # declare -A COLORS=(
    #     [1]="\[\e[1;32m\]"   # Verde
    #     [2]="\[\e[1;34m\]"   # Blu
    #     [3]="\[\e[1;31m\]"   # Rosso
    #     [4]="\[\e[1;35m\]"   # Magenta
    #     [5]="\[\e[1;36m\]"   # Ciano
    #     [6]="\[\e[1;33m\]"   # Giallo
    # )
# }





####################################################
#
####################################################
function renameVENV() {
    local NEW_NAME="${1}"

    if [ -z "$NEW_NAME" ]; then
        read -p "✏️  Nuovo nome da visualizzare nel prompt: " NEW_NAME
        if [ -z "$NEW_NAME" ]; then
            echo -e "\t⚠️  Nessun nome inserito. Nessuna modifica fatta."
            return 1
        fi
    fi

    echo "$NEW_NAME" > "$VENV_NAME"
    echo -e "\t✅ Nome visualizzato aggiornato in: $NEW_NAME"
    # deactivateVENV
    echo -e "\n\t execute activate_venv to show new name\n\n"
}


function getChouìice() {

        case $CHOICE in
            1|2|3|4|5|6)
                echo "$CHOICE" > "$COLOR_FILE"
                echo "✅ Colore aggiornato per $VENV_DIR."
                ;;
            *)
                echo "⚠️  Scelta non valida. Nessuna modifica apportata."
                ;;
        esac
}


####################################################
#
####################################################
function setupColors() {
    # local color=${1:-1}
    declare -A COLORS=(
        [1]="\[\e[1;32m\]"   # Verde
        [2]="\[\e[1;34m\]"   # Blu
        [3]="\[\e[1;31m\]"   # Rosso
        [4]="\[\e[1;35m\]"   # Magenta
        [5]="\[\e[1;36m\]"   # Ciano
        [6]="\[\e[1;33m\]"   # Giallo
    )

    RESET="\[\e[0m\]"
    local color=$1
    # if [ ! -z "$color" ] && [ "$1" != "." ]; then
    # defineColors





    COLOR_FILE="$VENV_PATH/.venvcolor"
    COLOR_CODE=""    # === ANSI color codes ===

    # === Check if color is already saved ===
    if [  "$color" -gt 0 && $color -le 6 ]; then
        CHOICE=$color

    else if [ -f "$COLOR_FILE" ]; then
        CHOICE=$(cat "$COLOR_FILE")
        # COLOR_CODE="${COLORS[$CHOICE]}"
    else
        # === Ask user to choose and save ===
        echo
        echo -e "\t 🎨 Seleziona il colore per il nome dell'ambiente '$CUSTOM_NAME':"
        echo -e "\t   1) Verde    2) Blu    3) Rosso"
        echo -e "\t   4) Magenta  5) Ciano  6) Giallo"
        read -p "👉 Scelta (default 1): " CHOICE
        CHOICE=${CHOICE:-1}

    fi

    # if [[ ! ${COLORS[$CHOICE]+_} ]]; then
    #     echo -e "\t ⚠️  Scelta non valida, uso colore predefinito (verde)."
    #     CHOICE=1
    # fi
    # case $CHOICE in
    #     1|2|3|4|5|6)
    #         echo "$CHOICE" > "$COLOR_FILE"
    #         echo "✅ Colore aggiornato per $VENV_DIR."
    #         ;;
    #     *)
    #         echo -e "\t ⚠️  Scelta non valida, uso colore predefinito (verde)."
    #         CHOICE=1
    #         # echo "⚠️  Scelta non valida. Nessuna modifica apportata."
    #         ;;
    # esac


    if [ "$CHOICE" -lt 1 || $CHOICE -gt 6 ]; then
        echo -e "\t ⚠️  Scelta non valida, uso colore predefinito (verde)."
        CHOICE=1
    fi

    echo "$CHOICE" > "$COLOR_FILE"
    COLOR_CODE="${COLORS[$CHOICE]}"

}

####################################################
#
####################################################
function setupColors_() {
    local color=$1
    if [ ! -z "$color" ] && [ "$1" != "." ]; then
    # defineColors

    COLOR_FILE="$VENV_PATH/.venvcolor"
    COLOR_CODE=""    # === ANSI color codes ===

    # === Check if color is already saved ===
    if [ -f "$COLOR_FILE" ]; then
        CHOICE=$(cat "$COLOR_FILE")
        COLOR_CODE="${COLORS[$CHOICE]}"
    else
        # === Ask user to choose and save ===
        echo
        echo -e "\t 🎨 Seleziona il colore per il nome dell'ambiente '$CUSTOM_NAME':"
        echo -e "\t   1) Verde    2) Blu    3) Rosso"
        echo -e "\t   4) Magenta  5) Ciano  6) Giallo"
        read -p "👉 Scelta (default 1): " CHOICE
        CHOICE=${CHOICE:-1}

        if [[ ! ${COLORS[$CHOICE]+_} ]]; then
            echo -e "\t ⚠️  Scelta non valida, uso colore predefinito (verde)."
            CHOICE=1
        fi

        echo "$CHOICE" > "$COLOR_FILE"
        COLOR_CODE="${COLORS[$CHOICE]}"
    fi

}



####################################################
# definisco VENV_PATH e CUSTOM_NAME
####################################################
function getVenvProjectPath() {
    # === Gestione argomento mancante: usa ./.venv ===
    if [ ! -z "$1" ] && [ "$1" != "." ]; then
        # CUSTOM_NAME="$(basename "$1")"
        VENV_PATH="$1"
    else
        VENV_PATH="$PWD/.venv"
        # CUSTOM_NAME="$(basename "$PWD")"
    fi


    if [ -d "$VENV_PATH" ] && [ -f "$VENV_PATH/bin/activate" ]; then
        # echo -e "\t ✅ trovato virtualenv nel path: '$VENV_PATH'"
        # echo -e "\t ✅ virtualenv name:             '$CUSTOM_NAME'"
        echo
    else
        echo -e "\t ❌ '$VENV_PATH' non è un virtualenv valido."
        return 1
    fi

    # === Determine display name ===
    VENV_NAME="${VENV_PATH}/.venvname"

    if [ -f "${VENV_NAME}" ]; then
        CUSTOM_NAME="$(cat "$VENV_NAME")"
    else
        CUSTOM_NAME="$(basename "$VENV_PATH")"
        echo "$CUSTOM_NAME" > "$VENV_NAME"
    fi
    return 0

}


####################################################
#
####################################################
function deactivateVENV() {
    # Disattiva l'ambiente virtuale
    if type deactivate &>/dev/null; then
        deactivate
    fi

    # Ripristina il prompt originale, se disponibile
    if [ -n "$ORIGINAL_PS1" ]; then
        export PS1="$ORIGINAL_PS1"
        unset ORIGINAL_PS1
    fi
}




####################################################
# se viene passato il percorso della directory .venv (o altro nome) viene preso quello
# altrimenti viene presa la currDIR che abbia la sottodir .venv
####################################################
function activateVENV() {
    setupColors

    # === Salva il prompt originale la prima volta ===
    if [ -z "$ORIGINAL_PS1" ]; then
        export ORIGINAL_PS1="$PS1"
    fi

    # === Attiva ambiente ===
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    source "$VENV_PATH/bin/activate"

    # === Applica nuovo prompt senza duplicazioni ===
    export PS1="${COLOR_CODE}(${CUSTOM_NAME})${RESET} ${ORIGINAL_PS1}"

}

getVenvProjectPath $@
[[ $? -ne 0 ]] && return 1
deactivateVENV
activateVENV
