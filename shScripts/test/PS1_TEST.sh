#!/bin/bash
# This file must be used with "source bin/activate" *from bash*
# You cannot run it directly

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
# function @setColors1() {
#     export TAB='    '
#     export    red='\033[0;31m'; export    redH='\033[1;31m'; export    TABred="${TAB}${red}";    export    TABredH="${TAB}${redH}"
#     export  green='\033[0;32m'; export  greenH='\033[1;32m'; export  TABgreen="${TAB}${green}";  export  TABgreenH="${TAB}${greenH}"
#     export yellow='\033[0;33m'; export yellowH='\033[1;33m'; export TAByellow="${TAB}${yellow}"; export TAByellowH="${TAB}${yellowH}"
#     export   blue='\033[0;34m'; export   blueH='\033[1;34m'; export   TABblue="${TAB}${blue}";   export   TABblueH="${TAB}${blueH}"
#     export purple='\033[0;35m'; export purpleH='\033[1;35m'; export TABpurple="${TAB}${purple}"; export TABpurpleH="${TAB}${purpleH}"
#     export   cyan='\033[0;36m'; export   cyanH='\033[1;36m'; export   TABcyan="${TAB}${cyan}";   export   TABcyanH="${TAB}${cyanH}"
#     export   gray='\033[0;37m'; export  whiteH='\033[1;37m'; export   TABgray="${TAB}${gray}";   export  TABwhiteH="${TAB}${whiteH}"

#     export colorReset='\033[0m' # No Color
#     export resetColor=$colorReset # No Color
#     unset -f ${FUNCNAME[0]}
# }

function @setColors() {

    # Helper: crea sequenze safe per PS1
    __mk_ps1() { echo "\[\033[$1m\]"; }
    __mk_raw() { echo "\033[$1m"; }

    # reset
    export colorReset="$(__mk_raw 0)"
    export colorReset_PS1="$(__mk_ps1 0)"

    # Definizione colori (coppie codici â nomi)
    local codes=(
        "0;30 black"
        "1;30 blackH"
        "0;31 red"
        "1;31 redH"
        "0;32 green"
        "1;32 greenH"
        "0;33 yellow"
        "1;33 yellowH"
        "0;34 blue"
        "1;34 blueH"
        "0;35 purple"
        "1;35 purpleH"
        "0;36 cyan"
        "1;36 cyanH"
        "0;37 gray"
        "1;37 whiteH"
    )

    # Loop corretto
    local entry code name
    for entry in "${codes[@]}"; do
        code="${entry%% *}"
        name="${entry#* }"

        export ${name}="$(__mk_raw "$code")"
        export ${name}_PS1="$(__mk_ps1 "$code")"
    done

    unset -f __mk_ps1 __mk_raw
    unset -f ${FUNCNAME[0]}
}


@setColors


# yellowH='\[\033[1;33m\]'
# colorReset='\[\033[0m\]' # No Color
venv_name="ciao.Loreto"
echo $venv_name

# ln_VIRTUAL_ENV_PROMPT="${yellowH_PS1}${venv_name}${colorReset_PS1}"

# PS1="["${ln_VIRTUAL_ENV_PROMPT}"]_${PS1:-}" ### <---- # --- @Loreto:  21-10-2025 12:42:14
# export PS1

# export _OLD_VIRTUAL_PS1="${PS1:-}"
#PS1="${_OLD_VIRTUAL_PS1:-}"