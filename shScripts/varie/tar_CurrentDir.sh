#!/bin/bash

# updated by ...: Loreto Notarantonio
# Date .........: 23-10-2025 15.29.54




#########################################################
# tar current directory
#   destRealPath: path di destinazione del file.tgz
#   curr_dir: path da includere nel file.tgz
#   dir_name: nome della current dir e del dir_name_DATA_TIME.tgz
#########################################################
function tarCurrentDir() {
    dest_path=${1:-${PWD}}

    # --- preleviamo subito il nome della directory
    local dir_name="$(basename ${PWD})"
    local DATE=$(date +"%Y%m%d_%H%M%S")
    local HOST_NAME=$(hostname -s)

    if [[ $dest_path == ${PWD} ]]; then ### --- scriviamo a livello superiore
        local destRealPath="$(dirname ${dest_path})" ###...prendiamo il parent_dir
    else
        local destRealPath="$(readlink -fvs  "${dest_path}")"
    fi

    local parentDir=$(dirname ${PWD})
    local tarFilePath="${destRealPath}/${dir_name}_${DATE}.tgz"
    local g_userNAME="$USER"
    local g_userID=$( id -g $g_userNAME )
    local g_groupID=$( id -u $g_userNAME )
    local g_groupNAME=$( id -gn $g_userNAME )

    local EXCLUDE=' --exclude=*/.aMule/copied/*
                    --exclude=*/.aMule/Incoming/*
                    --exclude=*/.aMule/Temp/*
                    --exclude=*/.pio/*
                    --exclude=*/__pycache__/*
                    --exclude=*/.git/* '



    # [[ "$currDirName" == '.lnProfile' ]] && dir_name='lnProfile' || dir_name=$currDirName
    # local tarFilePath="${parentPath}/${dir_name}_${DATE}.tgz"

    # Make sure to put --exclude before the source and destination items.
    cmd="sudo tar --absolute-names
            ${EXCLUDE}
            -czvf ${tarFilePath} ./${dir_name}"



    echo -e "${TABcyanH}dir name:       ${yellowH}${dir_name}"
    echo -e "${TABcyanH}target dir:     ${yellowH}${destRealPath}"
    echo -e "${TABcyanH}tar filename:   ${yellowH}${tarFilePath}"
    echo
    echo -e "${TABcyanH}operating dir:  ${yellowH}${parentDir}" ### ... dir da cui lanciare il programma
    echo
    echo -e "${TABcyanH}command:        ${yellowH}${cmd}"
    echo
    echo -en "${TABcyanH}press 'c' to continue (any other to exit): "
    read choice
    [[ "$choice" != 'c' ]] && { echo -e "${TABredH}....exiting!"; return; }

    cd $parentDir
    echo $PWD
    echo -e "${TABgreen}moving to $parentDir directory"

    echo -e "${TABblue}executing:\n${TAB}$cmd"
    echo -e "${TABgreen}files.....:${gray}"
    $cmd
    rcode=$?

    if [[ $rcode == 0 ]]; then
        echo -e "${TAByellowH}$tarFilePath has been created"

        ### test file
        logFile='/tmp/tar_file.log'
        echo -e "${TABpurpleH}testing tar file... ${yellow}(see ${logFile} for log)"
        tar -tzvf $tarFilePath >$logFile
        echo
    else
        echo -e "${TABredH}ERROR: executing command"
    fi

    echo -e "${TABgreenH}command executed:\n${TAB}$cmd"

}

# set -x
# caller_script="${BASH_SOURCE[0]}"
# echo $caller_script
# caller_script="${BASH_SOURCE[1]}"
# echo $caller_script
# caller_script_name=$(basename $caller_script)

source ${ln_SET_LORETO_ENVIRONMENT} 0
tarCurrentDir $@
echo -e "${colorReset}"