#!/bin/bash
#
# ----------------------------------------------
# ---  by Loreto
# updated by ...: Loreto Notarantonio
# Date .........: 16-12-2025 11.39.45
# ----------------------------------------------
#

function set_desktopLinks() {
    # cd ${HOME}
    local source_desktop_dir="${HOME}/filu/lnEnv/start_proc/.desktop"
    local dest_link_path="${HOME}/.local/share/applications"

    local fname=""

    desktop_files=$(find "${source_desktop_dir}"  -type f -name '*.desktop' | sort) # *.function potrebbe essere sotto diverse directories
    for filename in ${desktop_files}; do
        [ -f "$filename" ] || continue
        fname=$(basename ${filename})
        @createLink "${filename}" "${dest_link_path}/$fname"
    done
}


##########################################################
#               M A I N
##########################################################
    # echo -e "\n${TABwhiteH}-------- creating links: $BASH_SOURCE -------------------"
    source ${ln_SET_LORETO_ENVIRONMENT} 0
    source create_links.functions
    fEXECUTE=${1:---no-go}

    set -u
    set_desktopLinks
