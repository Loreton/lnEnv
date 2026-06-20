#!/bin/bash

# updated by ...: Loreto Notarantonio
# Date .........: 16-05-2026 14.42.51

# string manipulation
https://www.howtogeek.com/812494/bash-string-manipulation/
# output alignement
https://unix.stackexchange.com/questions/396223/bash-shell-script-output-alignment
# run local script to remote server
https://www.howtogeek.com/825102/how-to-run-a-local-script-on-a-remote-linux-server/

_SIMPLE_ARRAY_="
        duckdns: lncasetta.duckdns.org          98fa7c37-21c7-43b2-92d2-822560984579
        # freedns: lncasetta.crabdance.com        NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjM2
        # freedns: lnmqtt.crabdance.com           NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4Njgx
        # freedns: nsilvia.crabdance.com          NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjMy

        # freedns: lncasetta.mooo.com             NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4NjIy
        # freedns: nloreto.mooo.com               NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjY5

        # put as last because could be found also as a local ip address. see fUPDATE flag
        duckdns: lnmqtt.duckdns.org             98fa7c37-21c7-43b2-92d2-822560984579
    "

readarray -t array < /path/to/filename
readarray -t array < /path/to/filename
mapfile -t arrayDomains <<< "$_SIMPLE_ARRAY_"
readarray -t arrayDomains <<< "$_SIMPLE_ARRAY_"

# ----- get indirect/expansion of variable
x1="${!config_type}" # outputs 'this is the real value'

# or...
eval "x2=\$$config_type"
# or...
declare -n xx=$config_type


#############################################
# -
#############################################
function parseInput() { # solo per console
    g_EXECUTE=0
    # g_username=$1; shift 1 # positional argument
    args="$@"
    echo $args

    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_EXECUTE=1
    word='--host';   [[ " $args " == *" $word"* ]] && args=${args//$word/} && HOST=${word: 6}

    g_rest_arguments=$(echo $args) # strip text
    echo "g_rest_arguments: $g_rest_arguments"
    echo "HOST:             $HOST"
    exit
}


#############################################
# -
#############################################
function parseInput2() { # solo per console
    valid_args=$(getopt -o o: --long option: -- "$@")
    eval set -- "$valid_args"

    while :; do
        case "$1" in
            -o|--option)
                shift
                OPTION=$1
                ;;
            --)
                shift
                break
                ;;
        esac

        shift
    done

    echo "got option: $OPTION"
    echo "remaining args are: $@"
}

#############################################
# https://stackabuse.com/how-to-parse-command-line-arguments-in-bash/
#############################################
function parseInput3() {
    help() {
        echo "Usage: ParseInput
                [ -r | --remotehost ]
                [ -s | --script ]
                [ --go ]
                [ -h | --help  ]"
        exit 2
    }

    N_ARGUMENTS=$# # Returns the count of arguments that are in short or long options
    [[ "$N_ARGUMENTS" -eq 0 ]] && help
    g_RemoteHost=
    g_Script=
    g_GO=

    SHORT='r:,s:,h'
    LONG='remotehost:,script:,go,help'
    VALID_OPTS=$(getopt -a -n ParseInput --options $SHORT --longoptions $LONG -- "$@")

    eval set -- "$VALID_OPTS"
    while :; do
        case "$1" in
            -r | --remotehost )
                g_RemoteHost="$2";
                shift # past argument
                shift # past value
                ;;

            -s | --script )
                g_Script="$2"; shift 2; ;;

            -h | --help)
                help; ;;

            --go)
                shift; g_GO="true"; ;;

            --)
                shift; break; ;;
            *)
                echo "Unexpected option: $1"; help; ;;
        esac
    done

    echo "remote_host: $g_RemoteHost"
    echo "script: $g_Script"
    echo "GO: $g_GO"
    echo "remaining args are: $@"
}





COMMENTS.....
https://www.cyberciti.biz/faq/bash-comment-out-multiple-line-code/
<<'comment'
    https://unix.stackexchange.com/questions/129072/whats-the-difference-between-and
    call example:
        string_vs_arrays one two "three four"
comment

    : ' esempio del file lnlib_modules.txt
        "$sourcelibDIR/Logger/ColoredLogger.py"     =
        "$sourcelibDIR/Utils/fileUtils.py"          =
        "$sourcelibDIR/Utils/keyboard_prompt.py"    =
        "$sourcelibDIR/Dictionary/read_ini_file.py" =
        "$sourcelibDIR/System/subprocessPopen.py"   =
        "$sourcelibDIR/System/subprocessRun.py"     =
    '
<<comment1
        esempio del file lnlib_modules.txt
        "$sourcelibDIR/Logger/ColoredLogger.py"     =
        "$sourcelibDIR/Utils/fileUtils.py"          =
        "$sourcelibDIR/Utils/keyboard_prompt.py"    =
        "$sourcelibDIR/Dictionary/read_ini_file.py" =
        "$sourcelibDIR/System/subprocessPopen.py"   =
        "$sourcelibDIR/System/subprocessRun.py"     =
comment1
<<'comment1'
        tra single quote evita la risoluzione delle variabili
        esempio del file lnlib_modules.txt
        "$sourcelibDIR/Logger/ColoredLogger.py"     =
        "$sourcelibDIR/Utils/fileUtils.py"          =
        "$sourcelibDIR/Utils/keyboard_prompt.py"    =
        "$sourcelibDIR/Dictionary/read_ini_file.py" =
        "$sourcelibDIR/System/subprocessPopen.py"   =
        "$sourcelibDIR/System/subprocessRun.py"     =
comment1
function string_vs_arrays() {
    TAB='   '
    echo
    echo "Using \"\$*\" [Case 1 (quoted) - the parameters are regarded as one long quoted string]:"
    for a in "$*"; do
        echo "${TAB}${a}";
    done
    # -----
    # one two three four
    # -----

    echo -e "\nUsing \$* [Case 2 (unquoted) - the string is broken into words by the for loop]:"
    for a in $*; do
        echo "${TAB}${a}";
    done
    # -----
    # one
    # two
    # three
    # four
    # -----

    echo -e "\nUsing \"\$@\" [Case 3 (quoted) - treats each element of $@ as a quoted string]:"
    for a in "$@"; do
        echo "${TAB}${a}";
    done
    # -----
    # one
    # two
    # three four
    # -----

    echo -e "\nUsing \$@ [Case 4 (unquoted) - treats each element as an unquoted string]:"
    for a in $@; do
        echo "${TAB}${a}";
    done
    # -----
    # one
    # two
    # three
    # four
    # -----
    echo
}

function strip_string() {
    string="@_ciao Loreto come stai@X"
    suffix='@X'
    prefix='@_'
    foo1=${string#"$prefix"} # remove prefix
    echo $foo1
    foo2=${string%"$suffix"} # remove suffix
    echo $foo2
    foo3=${foo1%"$suffix"} # both
    echo $foo3
}



function processLine() {
    local cur_line=$@
    firstChar="${cur_line:0:1}"
    [[ $firstChar == '#' ]] && echo "   skipping line: $cur_line" && return
    local provider=$1
    local domain=$2
    local token=$3

    echo "valid line: $cur_line" && return
}


function list_users() {
    _users="\
        laura       1012 ciao pippo
        silvia      1013
        elena       1014
        ale         1015
        printer     1021
    "

    while IFS= read -r line; do
        line=$(echo $line) # trim BLANKs
        [[ "$line" == "" ]] && continue

        IFS=': ' read g_user_name g_uid rest <<< $line
        if [[ "$g_user_name" == "#" ]]; then
            echo "skipping... $line"
            continue
        fi
        echo "$g_user_name $g_uid - [$rest]"

    done < <(printf '%s\n' "$_users")
}



function read_string_array2() {
    readarray arrayDomains < <(printf '%s\n' "$_SAMPLE_ARRAY_")
    for line in "${arrayDomains[@]}"; do
        line=$(echo $line) # trim BLANKs
        [[ ! -z $line ]] && processLine $line
    done
}


function stringToArray() {
    funclist="a b c d"
    declare -a list=( $funcsList )
    echo ${list[@]}
    echo
}

#############################################
#
#############################################
function backup_current_file() {
    local dest_file=$1
    local dest_dir=$2
    if [[ -f $dest_file ]]; then
        ftime=$(date "+%Y%m%d_%H%M%S" -r "${dest_file}")
        saved_file="${dest_dir}/${ff_fname}_${ftime}.${ff_ftype}"
        esegui "copying file adding datetime to target filename" "cp -p "${dest_file}" "${saved_file}""
    fi
}

#############################################
#
#############################################
function @_lnpi23_lnEtc() {
    part_of_func_name="${FUNCNAME[0]: 2:6}_site_data" # execute lnpixx_site_data
 }

#############################################
#
#############################################
function @check_integer() {
    if [[ "$1" =~ ^-?[0-9]+$ ]]; then
        echo "Argument is an integer"
    else
        echo "Argument is NOT an integer"
    fi
    If you want only positive integers (no negative)
    [[ "$1" =~ ^[0-9]+$ ]]


    Extra: reject leading zeros (optional strict check)
    If you want to reject things like 007:
    [[ "$1" =~ ^-?(0|[1-9][0-9]*)$ ]]
}




##################################
# M A I N
##################################
<<comment
    list_users
    read_string_array2
    subString
    split_filepath "/tmp/pippo.tt" "ff_"
    __PARSE_INPUT "$@"
    parseInput3 "$@"
comment
    echo 'one two "three four"'; string_vs_arrays one two "three four"






scriptFullName="$(readlink -fvs  ${BASH_SOURCE})"
scriptPath="${scriptFullName%/*}" ###. get current dir
echo $scriptFullName
echo $scriptPath


Varianti utili
${var^} → upper_case solo la prima lettera
${var^^} → upper_case tutte le lettere
${var,} → lower_case solo la prima lettera
${var,,} → lower_case tutte le lettere