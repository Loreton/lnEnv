#!/bin/bash
# ---------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 04-05-2024 08.52.31
# ---------------------------------------




source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors " >/dev/null

function esegui() {
    local CMD_DESCR=$1
    local cmd=$2
    local stacklevel=1
    local indent=$TAB
    # set +x
    caller="${FUNCNAME[stacklevel+1]}:${BASH_LINENO[stacklevel]}"
    printf "\n${indent}[${caller}]"
    printf "\n${indent}${cyanH} ${CMD_DESCR}${colorReset}\n"
    if [[ "$g_fEXECUTE" -eq "1" || "$g_fEXECUTE" == "go" ]]; then
        printf "${indent}${purpleH} [executing]$yellowH: ${cmd}${colorReset}\n"
        eval '$cmd'
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && printf "${indent}${redH} ${rCode}${colorReset}\n" && exit $rCode
    else
        printf "${indent}${purpleH} [dry-run]$yellowH: ${cmd}${colorReset}\n"
    fi
}



# #############################################
# # Per le candidate_directories cerchiamo di
# #     risolvere tutti i link inglobando il vero
# #     file in modo da avere, su git, il progetto completo.
# #############################################
function create_LnLib_zip() {
    # assumiamo che ci troviamo nella prj_dir
    saved_dir="$PWD"

    LnLibDir_1="$saved_dir/Source/lnLib"
    LnLibDir_2="$saved_dir/Source/LnLib"
    [[ -d "$LnLibDir_1" ]] && LnLibDir=$LnLibDir_1
    [[ -d "$LnLibDir_2" ]] && LnLibDir=$LnLibDir_2



    if [ -d "$LnLibDir" ]; then
        echo
        zipName="$saved_dir/Source/lnLib_source.zip"
        [[ -f ${zipName} ]] && echo -e "$TABpurpleH removing file $zipName" && rm -f ${zipName}

        echo -e "${TAByellowH}- building file: ${zipName}"

        cd "$LnLibDir"
        zip -ur --latest-time $zipName *

        echo -e "${TABpurpleH}- ${zipName}     has been created."
        echo
    else
        echo
        echo -e "${TABredH} Source/lnLib NOT found"
        echo
        exit 1
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

        OPT='-uor'  # update, latest filetime, recursive
        echo
        [ -d "./LnLib" ] &&       zip $OPT ${zip_fullpath} LnLib/       1>/dev/null 2>&1
        [ -d "./Source" ] &&      zip $OPT ${zip_fullpath} Source/      1>/dev/null 2>&1
        [ -d "./conf" ] &&        zip $OPT ${zip_fullpath} conf/        1>/dev/null 2>&1
        [ -d "./links_conf/" ] &&  zip $OPT ${zip_fullpath} links_conf/ 1>/dev/null 2>&1
        [ -e "./__main__.py" ] && zip $OPT ${zip_fullpath} __main__.py  1>/dev/null 2>&1
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
    # if [[ -z $g_aliasName ]]; then
    local prj_name=$(basename $prj_dir_name)
    # else
        # local prj_name=$g_aliasName
    # fi
    local g_tempCompiledProgram="/tmp/compiled/${prj_name}.zip"
    rm -f $g_tempCompiledProgram >/dev/null

    createZipFile "$prj_dir_name" "$g_tempCompiledProgram"
    ftime=$(date "+%Y%m%d_%H%M%S" -r "${g_tempCompiledProgram}")

    # create relative symlink

    file_with_date="${ln_LIVE_PRODUCTION}/history/${prj_name}_${ftime}.zip"
    file_with_date="${prj_name}_${ftime}.zip"

    if [[ $func_CALLED == 'no' ]]; then
        ### -
        cp_cmd="cp -p "${g_tempCompiledProgram}" "${ln_LIVE_PRODUCTION}/history/${file_with_date}""
        esegui "copying file to production..." "$cp_cmd"

        saved_dir=$PWD
        cd ${ln_LIVE_PRODUCTION}

        ### -
        if [[ "$save_LAST" == "yes" ]]; then
            ### fa il rename il link, ma non mi conviene..
            relative_file=$(realpath -L --relative-to=.  "${prj_name}.zip")
            saved_fname=$(basename $relative_file)
            ln_cmd="ln -sf "${relative_file}" "${saved_fname}.saved""
            # esegui "saving last symbolic link" "$ln_cmd"



            ### fa il rename del file
            _fname_noext="${relative_file%.*}"
            _ext="${relative_file##*.}"
            rename_cmd="mv "${relative_file}" "${_fname_noext}.saved.${_ext}""
            esegui "saving last program" "$rename_cmd"
        fi


        ### -
        ln_cmd="ln -sf "history/${file_with_date}" "${prj_name}.zip""
        esegui "creating symbolic link..." "$ln_cmd"

        ### -
        cd $saved_dir
        echo
    fi

}



#############################################
#
#############################################
function syntax() {
    echo
    printf "${TAByellowH}syntax %s\n" $(basename $BASH_SOURCE)
    printf "${TABcyanH}create zip fil for python project\n"
    echo
    printf "${TAByellowH}Options:\n"
    printf "${TAB}${TABcyanH}-h|--help    this help\n"
    printf "${TAB}${TABcyanH}--go         execute commands\n"
    printf "${TAB}${TABcyanH}--edit       edit this file\n"
    printf "${TAB}${TABcyanH}--save_last  create a backup of current production zip file\n"
    printf "${colorReset}\n"
    echo
    # lnExit 1
    exit 1
}


#############################################
# -
#############################################
function parseInput() {
    args=$@
    g_GO=0
    g_fEXECUTE=0 && dry_run="[DRY-RUN]"
    save_LAST='no'
    func_CALLED='no'

    # parse and remove parameters-key from input arguments
    word='--help';          [[ " $args " == *" $word "* ]] && syntax
    word='--h';             [[ " $args " == *" $word "* ]] && syntax
    word='--go';            [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1
    word='--edit';          [[ " $args " == *" $word "* ]] && "/usr/bin/subl" "${real_script_FullPath}" && exit
    word='--save_last';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && save_LAST='yes'
    word='--func_called';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && func_CALLED='yes'

    g_args=$(echo $args)
}



parseInput $@


going_to_create
unset g_fEXECUTE
unset func_CALLED # richiamata come funzione


exit

