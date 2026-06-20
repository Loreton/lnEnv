#!/bin/bash
# ---------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 27-08-2023 17.33.53
# ---------------------------------------


# i colori sono già impostti dal caller

source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" >/dev/null
    : ' ritorna le seguenti variabili:
            link_FullPath, ,
            real_script_FullPath,
            scriptDir,
            real_scriptName,
            link_scriptName,
            noext_scriptName,
    '


# #############################################
# # Per le candidate_directories cerchiamo di
# #     risolvere tutti i link inglobando il vero
# #     file in modo da avere, su git, il progetto completo.
# #############################################
function create_LnLib_zip() {
    # assumiamo che ci troviamo nella prj_dir
    saved_dir="$PWD"
    LnLibDir="$saved_dir/Source/LnLib"
    zipName="$saved_dir/Source/LnLib.zip"

    echo -e "${TAByellowH}- building file: ${zipName}"

    if [ -d "$LnLibDir" ]; then
        cd "$LnLibDir"
        for name in *; do
            zip -ur --latest-time $zipName *
        done
        echo -e "${TABpurpleH}- ${zipName}     has been created."
        echo
    fi


    cd "$saved_dir" # ritorna alla top
}


#############################################
# ZIP Project
#############################################
function createZipFile() {
    local prj_dir_name=$1
    local zip_fullpath=$2


    local projectDir="${ln_GIT_REPO_DIR}/${prj_dir_name}"
    local projectDir="${prj_dir_name}"

    cd $projectDir

    create_LnLib_zip # solo per tenere i moduli raggruppati come backup

    if [[ ! -f "${prj_dir_name}/__main__.py" ]]; then
        echo -e "${TABredH}-----------------------------------------------------------------"
        echo -e "${TABredH}- ${prj_dir_name}/__main__.py not found"
        echo -e "${TABredH}-----------------------------------------------------------------"
        exit 1
    fi

    [[ -z "$zip_fullpath" ]] && zip_fullpath="/tmp/compiled/${prj_dir_name}.zip"
    local zip_path=$(dirname $zip_fullpath)
    mkdir -p $zip_path
    [[ -f ${zip_fullpath} ]] && rm -f ${zip_fullpath}

    if [[ -d $zip_path ]]; then
        echo -e "${TAByellowH}------------------------------------------------------"
        echo -e "${TAByellowH}- building file: ${zip_fullpath}"

        [[ -f $zip_fullpath ]] && rm -f $zip_fullpath && echo -e "${TABpurpleH}- ${zip_fullpath}     has been deleted.${colorReset}"
        OPT='-uor'  # update, latest filetime, recursive
        echo
        [ -d "./LnLib" ] &&       zip $OPT ${zip_fullpath} LnLib/
        [ -d "./Source" ] &&      zip $OPT ${zip_fullpath} Source/
        [ -d "./conf" ] &&        zip $OPT ${zip_fullpath} conf/
        [ -e "./__main__.py" ] && zip $OPT ${zip_fullpath} __main__.py
        echo
        echo -e "${TAByellowH}- ${zip_fullpath}     has been created."
        echo -e "${TAByellowH}------------------------------------------------------"
        echo
    else
        echo -e "${TABpurpleH}-----------------------------------------------------------------"
        echo -e "${TABpurpleH}- $zip_path not found"
        echo -e "${TABpurpleH}-----------------------------------------------------------------"
        exit 1
    fi
}


function going_to_create() {
    local prj_dir_name=$PWD
    if [[ -z $g_aliasName ]]; then
        local prj_name=$(basename $prj_dir_name)
    else
        local prj_name=$g_aliasName
    fi
    local g_tempCompiledProgram="/tmp/compiled/${prj_name}.zip"
    rm -f $g_tempCompiledProgram >/dev/null

    createZipFile "$prj_dir_name" "$g_tempCompiledProgram"
    ftime=$(date "+%Y%m%d_%H%M%S" -r "${g_tempCompiledProgram}")

    # file_with_date="${ln_LIVE_PRODUCTION}/history/${prj_name}_${ftime}.zip"
    # cp_cmd="cp -p "${g_tempCompiledProgram}" "${file_with_date}""
    # ln_cmd="ln -sf "${file_with_date}" "${ln_LIVE_PRODUCTION}/${prj_name}.zip""

    # update  #  by Loreto:  29-08-2022 08.20.12
    # create relative symlink
    file_with_date="${ln_LIVE_PRODUCTION}/history/${prj_name}_${ftime}.zip"

    file_with_date="${prj_name}_${ftime}.zip"


    if [[ $func_CALLED == 'no' ]]; then
        cp_cmd="cp -p "${g_tempCompiledProgram}" "${ln_LIVE_PRODUCTION}/history/${file_with_date}""
        echo -e "${TAByellowH}copying file to production..."
        echo -e "${TABcyanH}[${local_fEXECUTE}] - ${cp_cmd}"

        [[ $local_fEXECUTE == 'go' ]] && ${cp_cmd}

        saved_dir=$PWD

        cd ${ln_LIVE_PRODUCTION}
        echo -e "${TAByellowH}creating symbolic link"
        ln_cmd="ln -sf "history/${file_with_date}" "${prj_name}.zip""
        echo -e "${TABcyanH}[${local_fEXECUTE}] - ${ln_cmd}"
        [[ $local_fEXECUTE == 'go' ]] && ${ln_cmd}
        cd $saved_dir
        echo
    fi

}



function alias_name() {
    g_aliasName=$1
}

args=$@
local_fEXECUTE='dry-run'; word='--go';           [[ " $args " == *" $word "* ]] && args=${args//$word/} && local_fEXECUTE='go'
func_CALLED='no';         word='--func_called';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && func_CALLED='yes'

### se viene passsato un nome viene preso come alias del progetto.
### vedi ad esempio telegramBot con LnCasettaBot....s

alias_name $args


going_to_create
unset local_fEXECUTE
unset func_CALLED # richiamata come funzione
