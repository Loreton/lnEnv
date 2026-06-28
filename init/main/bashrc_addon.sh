#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-06-2026 20.37.29



########################################################
#
########################################################
function setUpTerminal() {
    # if [[ -z "$GNOME_TERMINAL_SCREEN" ]]; then

    # ref.: https://www.digitalocean.com/community/tutorials/
    # how-to-use-bash-history-commands-and-expansions-on-a-linux-vps#:~:text=Bash%20includes%20search%20functionality%20for,part%20of%20the%20previous%20command.
    # append to the history file, don't overwrite it
    # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

    shopt -s histappend
    HISTSIZE=5000
    HISTFILESIZE=10000
    stty -ixon # enable ctrl-s to move backward in history (ctrl-r)

    loretorc_link="$HOME/.loreto_setup"
    loretorc_file="/home/loreto/filu/lnEnv/init/main/loretorc"
    loretorc_path="$(readlink -fvs  "${loretorc_link}")"

    if [[ -f "${loretorc_file}" ]]; then ###. se esiste
        if [[ "${loretorc_path}" != "${loretorc_file}" ]]; then ## #. non sono uguali
            ln -sf "$loretorc_file" "$HOME/.loreto_setup" ###. ricrealo
        else
            echo "sono uguali"
        fi
        source $loretorc_link 1
        ln -sfn ${ln_BATCH_VARIABLES_FILE} "$HOME/.loreto_variables"
    fi
    # fi
}

########################################################
#
########################################################
function loretoPYENV() {
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - bash)"
   #  eval "$(pyenv virtualenv-init -)"
}


########################################################
# MAIN
########################################################

    if [[ $GNOME_TERMINAL_SCREEN ]]; then
    	echo "LinuxMint default TERMINAL progam. skipping loretorc setup.."

    elif [[ $TERM_PROGRAM == 'zed' ]]; then
        echo "ZED-TERMINAL, skipping loretorc setup.."

    else
        echo "Terminator-TERMINAL, starting loretorc setup.."
        setUpTerminal
        myHOSTNAME=$(hostname)
        if [[ "${myHOSTNAME}" == 'IdeaPadSlim3' ]]; then
            loretoPYENV
            #- uv python
            eval "$(direnv hook bash)"
            eval "$(starship init bash)"
        fi
    fi
