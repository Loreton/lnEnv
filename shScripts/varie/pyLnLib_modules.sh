#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 11-01-2024 18.20.04
#
# --------------------------------------------------------------
# - crea i link logici per alcuni moduli presenti nella LnPyLib
# --------------------------------------------------------------
#

function setVars() {
    source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" >/dev/null
        : ' ritorna le seguenti variabili:
                link_FullPath, ,
                real_FullPath,
                scriptDir,
                real_scriptName,
                link_scriptName,
                noext_scriptName,
        '
    LNLIB_DIR="${ln_GIT_REPO_DIR}/LnPyLib"
    destDIR="Source/LnLib"
    lib_link_data='./python_LnLib_modules.lst'

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


#############################################################
#           M A I N
#############################################################
    echo "sostituito da projects_links.sh"
    echo "sostituito da projects_links.sh"
    echo "sostituito da projects_links.sh"
    exit 0
    setVars
    set -u
    parseInput $@
    # - lib_link files
    if [[ -f "$lib_link_data" ]]; then
        prj_dir="${PWD}"
        prj_name=$(basename ${prj_dir})
        echo -e "${TABpurpleH}reading file: $lib_link_data"
        readarray -t arrayDomains < "$lib_link_data"  # read file data
    else
        echo -e "${TABredH}${lib_link_data} NOT FOUND!"
        exit 1
    fi

    if [[ ! -d "$destDIR" ]]; then
        echo -e "${TABredH}${destDIR} NOT FOUND!"
        exit 1
    fi


    for line in "${arrayDomains[@]}"; do
        IFS=' ' read -r _sourceFile _destlink <<< $line
        firstChar=${_sourceFile: 0:1}
        [[ "$firstChar" == "#" || "$firstChar" == "" ]] && continue

            # set -x
        sourceFile=$(eval echo "$_sourceFile") # resolve variable
        real_sourceFile="$(readlink -fvs  $sourceFile)" # resolve links if any
            # set +x
        destlink=$(eval echo "$_destlink")


        [[ -z $sourceFile ]] && continue
        if [ "$destlink" == "=" ]; then
            destlink=$(basename $sourceFile)
        else
            destlink=$(echo $destlink) # strip
        fi
        link_name=${destDIR}/${destlink}
        echo -e "${TABcyanH}${real_sourceFile}"

        # ------------------------
        # - se è una dir devo cancellarla altrimenti mi crea
        # - un'infinità di sub-dirs nel sorgente
        # - è giusto perché di fatto va a scrivere nel source
        # - Per i file posso utilizzare il parametro --force
        # ------------------------
        if [ -d "${real_sourceFile}" ]; then
            echo -e "${TABcyanH} - it's a directory. LogicalLink will be removed!${colorReset}"
            esegui "rm -rf ${link_name}"
            esegui "ln -s ${real_sourceFile} ${link_name}"

        elif [[ ! -f "${real_sourceFile}"  ]]; then
            echo -e "${TABredH}${real_sourceFile} doesn't exists${colorReset}"
            exit 1

        elif [[ -L "${link_name}"  ]]; then
            echo -e "${TABcyanH}${link_name} already exists as LINK${colorReset}"
            curr_ptr="$(readlink -f ${link_name})"
            if [ "$curr_ptr" == "${real_sourceFile}" ]; then
                echo -e "${TAB}${TABgreenH}...and points right${colorReset}"
            else
                echo -e "${TAB}${TABredH}but its pointer is wrong${colorReset}"
                esegui "ln -sf ${real_sourceFile} ${link_name}"
            fi


        elif [[ -f "${link_name}"  ]]; then
            echo -e "${TABredH}${link_name} already exists as FILE${colorReset}"
            echo -e "${TABcyanH}....skipping${colorReset}"

        elif [ -f "${real_sourceFile}" ]; then
            echo -en "${yellowH}"
            esegui "ln -sf ${real_sourceFile} ${link_name}"

        else
            echo -e "${TABpurpleH}${real_sourceFile} NOT FOUND${colorReset}"

        fi
        echo


    done

if [ $g_GO -eq 0 ]; then
    echo -e "${TABpurpleH}enter --go to execute.${colorReset}\n"
else
    ls -la --color ${destDIR}
fi

