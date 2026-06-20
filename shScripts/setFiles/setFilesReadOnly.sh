#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 25-11-2025 16.39.25
#


if ! declare -F @lnLog > /dev/null;     then source ln_log.functions; fi
if ! declare -F @setColors > /dev/null; then source colors.functions; fi



# ##########################################################################################
# - creazione del pattern da inserire nel comando fi find
#       --- raggruppati
#       find /path/to/dir -type f -print0 | grep -zE '\.(py|cpp|h)$' | xargs -0 chmod 444  <-- best
#       find /path/to/dir -type f | grep -E '\.(py|cpp|h)$' -exec chmod 444 {} \;
#
#       find /path/to/dir -type f \( -name "*.py" -o -name "*.cpp" -o -name "*.h" \) -print0 | xargs -0 chmod 444  <-- best
#       find /path/to/dir -type f \( -name "*.py" -o -name "*.cpp" -o -name "*.h" \) -exec chmod 444 {} \;
#       find /path/to/dir -type f \( -name "*.py" -o -name "*.cpp" -o -name "*.h" \) -ls
#
#   -print0 e xargs -0 - metodo più sicuro se i nomi contengono spazi
# ##########################################################################################
function buildFindCommand() {
    local patterns="$*"

    local total_pattern=''
    for pattern in $patterns; do
        @lnLog "pattern: $pattern"
        if [[ -z $total_pattern ]]; then
            total_pattern="-name '$pattern'"
        else
            total_pattern="$total_pattern -o -name '$pattern'"
        fi
    done

    if [[ -z $total_pattern ]]; then
        find_command="find ${sq}${topdir}${sq} -type f"
    else
        find_command="find ${sq}${topdir}${sq} -type f '(' ${total_pattern} ')'"
    fi
    export find_command
}



function help() {
cat << 'EOF'
    Uso:
      script.sh [opzioni] [argomenti...]

    Opzioni principali:
      --action CMD        Imposta il comando di azione (default: -ls)

      --pattern P1 [P2…]  Uno o più pattern consecutivi (fino alla prossima opzione)
                          Esempio: --pattern "*.txt" "*.log"

      --topdir DIR        Directory di partenza (default: .)

      --all               Modalità "all"

      --go                Esegue realmente (disabilita --dry-run)

      --log               Abilita logging

      --edit              Apre lo script nell'editor configurato

      --help, -h          Mostra questo help

    Note:
      • Le opzioni possono essere in qualsiasi ordine
      • Gli argomenti non riconosciuti vengono conservati
      • Se --go NON è specificato, viene usato --dry-run

    Esempi:

      Dry-run con pattern multipli:
        script.sh --pattern "*.txt" "*.md"

      Esecuzione reale su directory specifica:
        script.sh --go --topdir /home/user --pattern "*.log"

      Specifica azione:
        script.sh --action "-rm" --pattern "*.tmp"

EOF
}


function parseInput() {
    args=("$@")  # Capture all arguments as an array
    remaining_args=()
    patterns=()  # Initialize an array for patterns

    ActionCmd="-ls"
    fEXECUTE="--dry-run"
    fALL=""
    topdir="."
    fLOG=0
    sq="'"

    for ((i=0; i<${#args[@]}; i++)); do
        local key=${args[i]}
        @lnLog "current: ${key}"

        if [[ "${args[i]}" == --* ]]; then
            echo "Opzione sconosciuta: ${args[i]}"
            exit 1
        fi
        # [[ "${args[i]}" == "--action" ]] && { ActionCmd="${args[i+1]}"; i=$(( i + 1 )); continue; }
        [[ "${args[i]}" == "--action" ]] && {
            [[ -z "${args[i+1]}" || "${args[i+1]}" == --* ]] && {
                echo "Errore: --action richiede un valore"
                exit 1
            }
            ActionCmd="${args[i+1]}"
            i=$(( i + 1 ))
            continue
        }
        [[ "${args[i]}" == "--all" ]] &&    { fALL='all'; continue; }
        [[ "${args[i]}" == "--topdir" ]] && { topdir=${args[i + 1]}; i=$(( i + 1 )); continue; }
        [[ "${args[i]}" == "--go" ]] &&     { fEXECUTE='--go'; continue; }
        [[ "${args[i]}" == "--log" ]] &&    { fLOG=1; continue; }
        [[ "${args[i]}" == "--edit" ]] &&   { sublime_start.sh ${BASH_SOURCE}; exit; }
        [[ "${args[i]}" == "--help" ]] &&   { help; exit; }
        [[ "${args[i]}" == "-h" ]] &&   { help; exit; }

        if [[ "${args[i]}" == "--pattern" ]]; then # Loop to capture all patterns until the next flag
            while [[ $((i + 1)) -lt ${#args[@]} && "${args[i + 1]}" != "--"* ]]; do
                patterns+=("${args[i + 1]}")  # Add the next argument to patterns
                i=$(( i + 1 ))  # Move to the next argument
            done
            continue
        fi

        remaining_args+=("${args[i]}")
    done

    # Output the captured values and the remaining arguments
    @lnLog "action: $ActionCmd"
    @lnLog "patterns: ${patterns[*]}"  # Join array elements for output
    @lnLog "Remaining arguments:"
    for arg in "${remaining_args[@]}"; do
        @lnLog "- $arg"
    done
}


####################################################################
#       MAIN - MAIN - MAIN - MAIN - MAIN - MAIN - MAIN -
####################################################################
    set -u
    parseInput "$@"

    find_command="find . -type f"
    set -f  # Disable globbing{
    [[ "$fALL" != '--all' ]] && buildFindCommand $patterns
    set +f  # Enable globbing{

    @lnLog "find_command : $find_command"

    if [[ "$ActionCmd" == '-ls' ]]; then
        cmd="${find_command} -ls"
    else
        cmd="${find_command} -print0 | xargs -0 $ActionCmd"
    fi


    if [[ "$fEXECUTE" != '--go' ]]; then
        fLOG=1
        @lnLog "${green}Sample syntax:"
        @lnLog "${green}     --log --topdir dirname --pattern ${sq}*.py *.cpp${sq} --action -ls"
        @lnLog "${green}     --log --topdir dirname --pattern ${sq}*.py *.cpp${sq} --action ${sq}chown loreto:loreto${sq} "
        @lnLog "${green}     --log --topdir dirname --pattern ${sq}*.py *.cpp${sq} --action ${sq}chmod u+w${sq} "
        @lnLog "${green} topdir default='.'"
        @lnLog "${green} action default='-ls"
        echo
        # non metto l'execute perchè è meglio controllare il comando prima di eseguirlo..
        # non metto l'execute perchè è meglio controllare il comando prima di eseguirlo..
        # non metto l'execute perchè è meglio controllare il comando prima di eseguirlo..
        # non metto l'execute perchè è meglio controllare il comando prima di eseguirlo..
        # @lnLog "${cyan}final command: $cmd"
        # echo
        # @lnLog "${yellow}please enter --go to execute command"
        # read -r choice
        # [[ "${choice}" == '--go' ]] && fEXECUTE='--go'
    fi
    echo
    fLOG=1
    # if [[ "$fEXECUTE" == '--go' ]]; then
        @lnLog "${redH}- controlla il comando prima di eseguirlo"
        @lnLog "${yellowH}command: $cmd"
        @lnLog "${redH}- controlla il comando prima di eseguirlo"
        # echo -e $resetColor
        # eval $cmd
    # fi

    @lnLog "${redH}....exiting!"