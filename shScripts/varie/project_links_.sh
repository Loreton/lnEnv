#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 26-10-2025 17.39.33
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
function esegui() {
    cmd=$1
    echo -e "       $dry_run $cmd"
    if [[ "$g_GO" -eq 1 ]]; then
        eval $cmd
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && exit $rCode
        echo
    fi
}

#############################################
# -
#############################################
function parseInput() {
    args=$@
    g_GO=0
    g_GO=0 && dry_run="[DRY-RUN]"

    # parse and remove parameters-key from input arguments
    word='--go';      [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_GO=1 dry_run=""
    word='--edit';    [[ " $args " == *" $word "* ]] && "/usr/bin/subl" "${real_script_FullPath}" && exit

    g_args=$(echo $args)
}


#############################################
# -
#############################################
function read_file_definitions() {
    local file=$1

    if [[ -f "${file}" ]]; then
        echo -e "${TABpurpleH}reading file: $file"
        readarray -t g_aLinkList < "$file"  # read file data
    else
        echo -e "${TABredH}${file} NOT FOUND!"
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




    for line in "${g_aLinkList[@]}"; do
        line=$(eval echo $line)          ## resolve vars && strip line
        firstChar=${line: 0:1}
        [[ "$firstChar" == "#" || "$firstChar" == "" ]] && continue

        IFS=' ' read -r _sourceFile destlink <<< $line

        # string prima dell'='
        _key_name="${_sourceFile%=*}"
        # echo "key_name: ${_key_name}"

        # echo $_key_name  $_sourceFile $_var_name
        set -x
        if [[ "${_key_name,,}" == "source_dir" ]]; then
            sourceDIR=$(eval echo "${_sourceFile##*=}") # resolve variable
            if [[ -z "$sourceDIR" ]]; then
                sourceDIR=''
            elif [[ ! -d "$sourceDIR" ]]; then
                lnExit "sourceDIR: ${sourceDIR} NOT FOUND!"
            fi
            continue

        elif [[ "${_key_name,,}" == "dest_dir" ]]; then
            destDIR=$(eval echo "${_sourceFile##*=}") # resolve variable
            if [[ -z "$destDIR" ]]; then
                destDIR=''
            elif [[ ! -d "$destDIR" ]]; then
                lnExit "destDIR: ${destDIR} NOT FOUND!"
            fi
            continue
        fi

            # - gestisco eventuali variabili di ambiente....
        _var_name="${_sourceFile%@*}"
        if [[ "${_var_name,,}" == "set_var" ]]; then
            variable=$(eval echo "${_sourceFile##*@}") # resolve variable
            echo -e "${TABpurpleH}.... setting variable: [${variable}]"
            eval "export ${variable}"
            # echo "__${PRJ_ENV}__"
            continue
        fi
        set +x
        read
        continue
        if [[ $firstChar == "/" ]]; then ### absolute path
            source_file="${_sourceFile}"
        else
            source_file="${sourceDIR}/${_sourceFile}"
        fi

        sourceFile=$(eval echo "$source_file") # resolve variable
        real_sourceFile="$(readlink -fvs  $sourceFile)" # resolve links if any

        destlink=$(eval echo "${destlink%*#}") # remove inline comment and trim

        [[ -z $sourceFile ]] && continue

        if [[ "$destlink" == "=" || "$destlink" == "" ]]; then
            destlink=$(basename $sourceFile)
        fi

        link_name=${destDIR}/${destlink}

        # ------------------------
        # - se ÃÂ¨ una dir devo cancellarla altrimenti mi crea
        # - un'infinitÃÂ  di sub-dirs nel sorgente
        # - ÃÂ¨ giusto perchÃÂ© di fatto va a scrivere nel source
        # - Per i file posso utilizzare il parametro --force
        # ------------------------
        if [ -d "${real_sourceFile}" ]; then
            curr_ptr="$(readlink -f ${link_name})"
            if [ "$curr_ptr" == "${real_sourceFile}" ]; then
                echo -e "${TAByellowH}OK --> ${cyanH}${link_name} ${greenH}${real_sourceFile}${colorReset}"
            else
                echo -e "${TABcyanH} - it's a directory. ${redH}current logicalLink will be removed!${colorReset}"
                esegui "rm -rf ${link_name}"
                esegui "ln -s ${real_sourceFile} ${link_name}"
            fi

        elif [[ ! -f "${real_sourceFile}"  ]]; then
            echo -e "${TABcyanH}${sourceFile}${TABredH}${real_sourceFile} doesn't exists${colorReset}"
            exit 1

        elif [[ -L "${link_name}"  ]]; then
            curr_ptr="$(readlink -f ${link_name})"
            # echo "$curr_ptr"
            # echo "$real_sourceFile"
            if [ "$curr_ptr" == "${real_sourceFile}" ]; then
                echo -e "${TAByellowH}OK --> ${cyanH}${link_name} ${greenH}${real_sourceFile}${colorReset}"
            else
                echo -e "${TABredH}wrong pointer ${cyanH}${link_name} ${colorReset}"
                esegui "ln -sf ${real_sourceFile} ${link_name}"
            fi


        elif [[ -f "${link_name}"  ]]; then
            echo -e "${TABcyanH}${link_name} ${redH}already exists as FILE. Please remove it manually${colorReset}"
            echo -e "${TABcyanH}....skipping${colorReset}"

        elif [ -f "${real_sourceFile}" ]; then
            echo -en "${yellowH}"
            esegui "chmod -w ${real_sourceFile}"
            esegui "ln -sf ${real_sourceFile} ${link_name}"

        else
            echo -e "${TABpurpleH}${real_sourceFile} NOT FOUND${colorReset}"

        fi
        # echo


    done

if [ $g_GO -eq 0 ]; then
    echo -e "${TABpurpleH}enter --go to execute.${colorReset}\n"
fi

