#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Version ......: 31-08-2020 09.23.07
#



#########################################################################
#
#########################################################################
function @createLink() {
    local source_path=$1
    local dest_link_path=$2


    local real_sourcePath="$(readlink -fvs  $source_path)" # resolve links if any
    local real_destPath="$(readlink -fvs  $dest_link_path)" # resolve links if any


    if [[ ! -e "$source_path" ]]; then
        @lnLog "${cyanH}${source_path}: ${redH}not exists!${colorReset}"
        return 1

    elif [[ ! -d "$source_path" ]] && [[ ! -f "$source_path" ]]; then
        @lnLog "${cyanH}${source_path}: ${redH}is NOT a file or Directory, cannot proceed!${colorReset}"
        return 1

    elif [ ! -e "${dest_link_path}" ]; then
        echo -en "${yellowH}"
        @lnEsegui "ln -sf ${real_sourcePath} ${dest_link_path}"
        @lnEsegui "chmod -w ${real_sourcePath}"


    #... fare il test di -L prima di -d e -f
    elif [[ -L "${dest_link_path}"  ]]; then
        if [ "$real_destPath" == "${real_sourcePath}" ]; then
            [[ -d $real_sourcePath ]] && cmnt='dirLink' || cmnt='fileLink'
            @lnLog "${yellowH}${cmnt} OK --> ${cyanH}${dest_link_path} ${greenH}${real_sourcePath}${colorReset}"
        else
            @lnLog "${cyanH}${real_destPath} - ${redH}wrong pointer, creating new one ${colorReset}"
            @lnEsegui "ln -sf ${real_sourcePath} ${dest_link_path}"
        fi

    #... controlli messi per aiutare il debug,,,,
    elif [[ -f "${dest_link_path}"  ]]; then
        @lnLog "${cyanH}${dest_link_path} - ${redH}already exists as FILE. Please remove it manually${colorReset}"
        return 1

    elif [[ -d "${dest_link_path}"  ]]; then
        @lnLog "${cyanH}${dest_link_path} - ${redH}already exists as Directory. Please remove it manually${colorReset}"
        return 1

    else
        @lnLog "${purpleH}${source_path}    unManaged${colorReset}"
        @lnLog "${purpleH}${dest_link_path} unManaged${colorReset}"
    fi
    # echo
}




# ----------------------------------------------
# ---  by Loreto
# updated by ...: Loreto Notarantonio
# Date .........: 15-11-2025 16.58.50
# ----------------------------------------------
function set_desktopLinks() {
    cd ${HOME}
    local source_desktop_dir="${HOME}/filu/lnEnv/start_proc/.desktop"
    local dest_link_path="${HOME}/.local/share/applicationszz"

    local fname=""

    desktop_files=$(find "${source_desktop_dir}"  -type f -name '*.desktop' | sort) # *.function potrebbe essere sotto diverse directories
    for filename in ${desktop_files}; do
        [ -f "$filename" ] || continue
        fname=$(basename ${filename})
        @createLink "${filename}" "${dest_link_path}/$fname" "${fEXECUTE}"
    done

    source_path='/home/loreto/filu/lnEnv/shScripts'; dirname=$(basename $source_path)
    @createLink ${source_path} "${dest_link_path}/${dirname}" "${fEXECUTE}"
}

source esegui.functions
fEXECUTE=${1:---no-go}

set -u
# echo $BASH_SOURCE
# set_externalDiskLinks
set_desktopLinks