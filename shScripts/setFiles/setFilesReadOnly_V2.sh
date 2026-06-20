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

    local regex=""

    # Costruisce (py|cpp|h)
    for pattern in "$@"; do
        @lnLog "pattern: $pattern"

        # rimuove "*.ext" → "ext"
        ext="${pattern#*.}"

        if [[ -z "$regex" ]]; then
            regex="$ext"
        else
            regex="${regex}|${ext}"
        fi
    done

    if [[ -z "$regex" ]]; then
        find_command="find ${sq}${topdir}${sq} -type f"
    else
        find_command="find ${sq}${topdir}${sq} -type f -print0 | grep -zE '\\.(${regex})$'"
    fi

    export find_command
}

function buildFindCommand() {

    local regex=""
    local use_regex=1
    local total_pattern=""

    for pattern in "$@"; do
        @lnLog "pattern: $pattern"

        # verifica se è del tipo *.ext
        if [[ "$pattern" == "*."* && "$pattern" != *"/"* ]]; then
            ext="${pattern#*.}"

            if [[ -z "$regex" ]]; then
                regex="$ext"
            else
                regex="${regex}|${ext}"
            fi
        else
            use_regex=0
        fi
    done

    # ------------------------------------------------------------
    # modalità regex (veloce per estensioni)
    # ------------------------------------------------------------
    if [[ $use_regex -eq 1 && -n "$regex" ]]; then

        find_command="find ${sq}${topdir}${sq} -type f -print0 | grep -zE '\\.(${regex})$'"

    # ------------------------------------------------------------
    # modalità classica find -name (pattern generici)
    # ------------------------------------------------------------
    else

        for pattern in "$@"; do
            if [[ -z "$total_pattern" ]]; then
                total_pattern="-name '$pattern'"
            else
                total_pattern="$total_pattern -o -name '$pattern'"
            fi
        done

        if [[ -z "$total_pattern" ]]; then
            find_command="find ${sq}${topdir}${sq} -type f"
        else
            find_command="find ${sq}${topdir}${sq} -type f '(' ${total_pattern} ')'"
        fi
    fi

    export find_command
}


function help() {
    echo -e ${white}
cat << 'EOF'
        Uso:
          script.sh [opzioni] [argomenti...]

        DESCRIZIONE
          Tool avanzato per cercare file e applicare azioni in modo sicuro.
          Supporta pattern multipli, regex raggruppate e preset per azioni comuni.

        OPZIONI DI RICERCA
          --pattern P1 [P2…]
              Uno o più pattern consecutivi (fino alla prossima opzione)

              Modalità automatica:
                • Se tutti i pattern sono del tipo "*.ext"
                  → usa regex raggruppata veloce:
                    find ... -print0 | grep -zE '\.(ext1|ext2)$'

                • Se presente almeno un pattern generico (es. "test_*")
                  → usa metodo classico find -name

              Esempi:
                --pattern "*.py" "*.cpp" "*.h"
                --pattern "test_*" "*.log"

          --topdir DIR
              Directory di partenza (default: .)

          --all
              Include tutti i file (ignora i pattern)

        OPZIONI AZIONE
          --action CMD
              Comando personalizzato da eseguire sui file trovati

          Preset rapidi:

          --chmod MODE
              Equivalente a: --action "chmod MODE"
              Esempio: --chmod u+w

          --chown USER:GROUP
              Equivalente a: --action "chown USER:GROUP"

          --delete
              Cancella i file trovati (find -delete)

          --exec CMD
              Esegue comando generico sui file trovati

        ESECUZIONE
          --go
              Esegue realmente il comando
              (default: dry-run — mostra solo il comando)

          --log
              Abilita logging dettagliato

        ALTRO

          --edit
              Apre lo script nell'editor configurato

          --help, -h
              Mostra questo help


        NOTE
          • Le opzioni possono essere in qualsiasi ordine
          • I nomi file con spazi sono gestiti in modo sicuro
          • Senza --go il comando NON viene eseguito
          • Metodo regex è più veloce con molte estensioni


        ESEMPI
          Dry-run con estensioni multiple:
            script.sh --pattern "*.py" "*.cpp"

          Cambiare permessi:
            script.sh --chmod u+w --pattern "*.sh" --go

          Cambiare proprietario:
            script.sh --chown loreto:loreto --pattern "*.cpp" --go

          Eliminare file temporanei:
            script.sh --delete --pattern "*.tmp" --go

          Pattern misti:
            script.sh --pattern "test_*" "*.log"

EOF
    echo -e ${resetColor}

}




require_value() {
    local opt="$1"
    local val="$2"

    if [[ -z "$val" || "$val" == --* ]]; then
        echo "Errore: $opt richiede un valore"
        exit 1
    fi
}


function parseInput() {
    args=("$@")
    remaining_args=()
    patterns=()

    # default
    ActionCmd="-ls"
    fEXECUTE="--dry-run"
    fALL=""
    topdir="."
    fLOG=0
    sq="'"

    for ((i=0; i<${#args[@]}; i++)); do
        key="${args[i]}"
        @lnLog "current: ${key}"

        case "$key" in

            --help|-h)
                help
                exit
                ;;

            --edit)
                sublime_start.sh "${BASH_SOURCE}"
                exit
                ;;

            --log)
                fLOG=1
                ;;

            --all)
                fALL="all"
                ;;

            --go)
                fEXECUTE="--go"
                ;;

            --action)
                require_value "$key" "${args[i+1]}"
                ActionCmd="${args[i+1]}"
                ((i++))
                ;;

            --topdir)
                require_value "$key" "${args[i+1]}"
                topdir="${args[i+1]}"
                ((i++))
                ;;

            --pattern)
                while [[ $((i+1)) -lt ${#args[@]} && "${args[i+1]}" != --* ]]; do
                    patterns+=("${args[i+1]}")
                    ((i++))
                done
                ;;

            --chmod)
                require_value "$key" "${args[i+1]}"
                ActionCmd="chmod $val"
                ((i++))
                ;;

            --chown)
                require_value "$key" "${args[i+1]}"
                ActionCmd="chown $val"
                ((i++))
                ;;

            --delete)
                ActionCmd="-delete"
                ;;

            --exec)
                require_value "$key" "${args[i+1]}"
                ActionCmd="$val"
                ((i++))
                ;;

            --*)
                echo "Opzione sconosciuta: $key"
                exit 1
                ;;

            *)
                remaining_args+=("$key")
                ;;
        esac
    done

    @lnLog "action: $ActionCmd"
    @lnLog "patterns: ${patterns[*]}"
    @lnLog "Remaining arguments:"
    for arg in "${remaining_args[@]}"; do
        @lnLog "- $arg"
    done
    echo ".... ${patterns[*]}"
}

####################################################################
#       MAIN - MAIN - MAIN - MAIN - MAIN - MAIN - MAIN -
####################################################################
    set -u
    parseInput "$@"
    # echo $patterns
    # exit
    find_command="find . -type f"
    set -f  # Disable globbing{
    [[ "$fALL" != '--all' ]] && buildFindCommand ${patterns[*]}
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