#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Version ......: 31-08-2020 09.23.07
#

function vEnv_Creation() { # https://github.com/pyenv/pyenv
    local VER=$1
    local this_path="${PWD}"
    local cur_dirname="$(basename "${this_path}")"

    # costruisci il percorso di default (ultima assegnazione è quella voluta)
    installPath="${this_path}/.venv_${cur_dirname,,}_$VER"
    local venvPath=${2:-$installPath}

    export PYENV_ROOT="${ln_PYENV_ROOT}"
    if [[ ! -d "${PYENV_ROOT}/bin" ]]; then
        echo -e "${TABredH}envar: PYENV_ROOT not set"
        return 1
    fi

    # Imposto il nome della venv subito, così è sempre disponibile all'esterno
    export venv_name="$(basename "${venvPath}")"

    if [[ -d "${venvPath}/bin" ]]; then
        echo -e "${TABred}${venvPath} already exists!!"
        return 99
    fi

    #... chiedere conferma per l'installazione
    local top_dir
    top_dir="$(dirname "${venvPath}")"
    echo -e "${TABpurple}Vuoi installare il venv nella directory:"
    echo -e "${TAByellowH}${venvPath}?"
    echo -en "${TABgray}y[es] (any other key to exit): ${colorReset}"
    read -r choice
    [[ "${choice}" != 'y' ]] && { echo -e "${TABredH}....exiting!"; return 2; }

    echo -e "${TABwhiteH}installing..."
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    cd "${top_dir}" || return 3

    # crea la venv usando il percorso completo (più chiaro e sicuro)
    "${PYENV_ROOT}/versions/${VER}/bin/python3" -m venv "${venvPath}"
    rcode=$?

    # se la creazione è andata a buon fine torniamo 99 (come nel tuo flusso originale)
    [[ ${rcode} -eq 0 ]] && return 99

    return ${rcode}
}

source "${ln_SET_LORETO_ENVIRONMENT}"
vEnv_Creation "$@"; rcode=$?

if [[ ${rcode} -eq 99 ]]; then
    my_cmd='.set_env'
    my_path="$(basename ${installPath})"
    my_template="${ln_SETUP_DIR}/aliases/python-pyEnv/ln_venv_activate_master"
    echo "source "${my_template}" ${my_path}" >$my_cmd

    echo -e "${TABcyanH} use one of following command to activate environment:"
    echo -e "${TABcyanH}     source ${venv_name}/bin/activate${colorReset}"
    echo -e "${TABcyanH}     source ${my_cmd}"
fi
unset -f vEnv_Creation
echo ""