#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 13-12-2025 15.36.24
#
# --------------------------------------------------------------
# - crea i link logici per alcuni moduli presenti nella LnPyLib
# --------------------------------------------------------------
#

function setVars() {
    source "${ln_SET_LORETO_ENVIRONMENT}"

    # LNLIB_DIR="${ln_GIT_REPO_DIR}/LnPyLib"
    # destDIR="Source/LnLib"
    project_link_list='./project_links.lst'
    project_link_list='./@project_links.lst'

        : ' esempio del file lnlib_modules.txt - notare le variabili
            "$sourcelibDIR/Logger/ColoredLogger.py"     =
            "$sourcelibDIR/Utils/fileUtils.py"          =
            "$sourcelibDIR/Utils/keyboard_prompt.py"    =
            "$sourcelibDIR/Dictionary/read_ini_file.py" =
            "$sourcelibDIR/System/subprocessPopen.py"   =
            "$sourcelibDIR/System/subprocessRun.py"     =
        '
}



#############################################
# -
#############################################
function parseInput() {
    args=$@
    g_GO=0
    g_GO=0 && dry_run="[DRY-RUN]"
    fEXECUTE='--dry-run'

    # parse and remove parameters-key from input arguments
    word='--go';      [[ " $args " == *" $word "* ]] && args=${args//$word/} && fEXECUTE='--go'
    word='--edit';    [[ " $args " == *" $word "* ]] && "/usr/bin/subl" "${real_script_FullPath}" && exit

    g_args=$(echo $args)
}


#############################################
# -
#############################################
function read_file_definitions() {
    local file=$1

    if [[ -f "${file}" ]]; then
        @lnLog "${purpleH}reading file: $file"
        readarray -t g_aLinkList < "$file"  # read file data
    else
        @lnLog "${redH}${file} NOT FOUND!"
        exit 1
    fi
}
#############################################################
#           M A I N
#############################################################
    setVars
    set -u
    parseInput $@
    read_file_definitions $project_link_list
    prj_dir="${PWD}"
    cd $prj_dir
    destDIR=''
    sourceDIR=''

    export fLOG='1'
    export fEXECUTE
    if ! declare -F @createLink > /dev/null; then
        source create_links.functions
    fi




    for line in "${g_aLinkList[@]}"; do
        line=$(eval echo $line)          ## resolve vars && strip line
        firstChar=${line: 0:1}
        [[ "$firstChar" == "#" || "$firstChar" == "" ]] && continue

        IFS=' ' read -r _sourceFile destlink <<< $line

        # string prima dell'='
        _key_name="${_sourceFile%=*}"
        # echo "key_name: ${_key_name}"

        # echo $_key_name  $_sourceFile $_var_name
        if [[ "${_key_name,,}" == "source_dir" ]]; then
            sourceDIR=$(eval echo "${_sourceFile##*=}") # resolve variable
            if [[ -z "$sourceDIR" ]]; then
                sourceDIR=''
            elif [[ ! -d "$sourceDIR" ]]; then
                @lnLog "${redH}sourceDIR: ${sourceDIR} NOT FOUND!"
                exit 1
            fi
            continue

        elif [[ "${_key_name,,}" == "dest_dir" ]]; then
            destDIR=$(eval echo "${_sourceFile##*=}") # resolve variable
            if [[ -z "$destDIR" ]]; then
                destDIR=''
            elif [[ ! -d "$destDIR" ]]; then
                @lnLog "${redH}destDIR: ${destDIR} NOT FOUND!"
            fi
            continue
        fi

            # - gestisco eventuali variabili di ambiente....
        _var_name="${_sourceFile%@*}"
        if [[ "${_var_name,,}" == "set_var" ]]; then
            variable=$(eval echo "${_sourceFile##*@}") # resolve variable
            @lnLog "${purpleH}.... setting variable: [${variable}]"
            eval "export ${variable}"
            # echo "__${PRJ_ENV}__"
            continue
        fi

        if [[ $firstChar == "/" ]]; then ### absolute path
            source_file="${_sourceFile}"
        else
            source_file="${sourceDIR}/${_sourceFile}"
        fi

        sourceFile=$(eval echo "$source_file") # resolve variable
        # [[ -z $sourceFile ]] && continue

        real_sourceFile="$(readlink -fvs  $sourceFile)" # resolve links if any
        if [[  -z $sourceFile || ! -e "$real_sourceFile" || ! -e $sourceFile ]]; then
            @lnLog "${redH}.... file not found: [$sourceFile]"
            continue
        fi

        destlink=$(eval echo "${destlink%*#}") # remove inline comment and trim
        if [[ "$destlink" == "=" || "$destlink" == "" ]]; then
            destlink=$(basename $sourceFile)
        fi

        link_name=${destDIR}/${destlink}


        # ------------------------
        # @lnLog "${purpleH}.... creating link:"
        # @lnLog "${purpleH}.... source $real_sourceFile"
        # @lnLog "${purpleH}.... dest   $link_name"
        @createLink "$real_sourceFile" "$link_name"
    done


if [[ ! "$fEXECUTE"  == "--go" ]]; then
    @lnLog "${purpleH}enter --go to execute.${colorReset}\n"
fi

