#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 16-05-2026 09.14.30
#


# scriptFullPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
# this_dir="${scriptFullPath%/*}" ###. get parent dir
# cd ${this_dir}

# ln -sf ./findAndReplace/findReplaceTextInFiles.py                  findReplaceTextInFiles.lnk.py
# ln -sf ./xClip/xClip.py                                            xClip.lnk.py
# ls -sf /home/loreto/filu/lnEnv/start_proc/doublecmd_start.sh       doublecmd_start.lnk.sh



#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 16-05-2026 09.14.30
#



fEXECUTE="${1:---dryrun}"
source ${HOME}/filu/lnEnv/init/commonFunctions/@load_common_functions.sh
set -u
export fLOG=1


files="
    "${ln_PY_SCRIPTS_DIR}/findAndReplace/findReplaceTextInFiles.py"
    "${ln_PY_SCRIPTS_DIR}/xClip/xClip.py"
    "${ln_PY_SCRIPTS_DIR}/py_env/ln_venv_activate_master.sh"

    "${ln_SH_SCRIPTS_DIR}/iconv/ln_iconv.sh"
    "${ln_SH_SCRIPTS_DIR}/ddns/ddns_update_wLog.sh"
    "${ln_SH_SCRIPTS_DIR}/mount/ln_mount.sh"

    "${ln_SH_SCRIPTS_DIR}/varie/gitcommit.sh"
    "${ln_SH_SCRIPTS_DIR}/varie/myIP.sh"
    "${ln_SH_SCRIPTS_DIR}/varie/project_links.sh"
    "${ln_SH_SCRIPTS_DIR}/varie/tar_CurrentDir.sh"
    "${ln_SH_SCRIPTS_DIR}/device_list/deviceList.sh"

    "${ln_START_PROC_DIR}/doublecmd_start.sh"
    "${ln_START_PROC_DIR}/sublime_start.sh"
    "${ln_START_PROC_DIR}/piorun.sh"
"






###########################################################
#      M A I N
###########################################################
    _sourceScript="$(readlink -fvs  $BASH_SOURCE)"
    _thisPath=$(dirname $_sourceScript)

    fEXECUTE=${1:---dry-run} #... ..go to execute
    [[ -z "$fEXECUTE" ]] && fEXECUTE='--dry-run'


    dest_link_path="${ln_ENV_DIR}/utils_lnk"
    cd ${dest_link_path}


    @lnLog "working in directory: $PWD"
    for source_filepath in $files; do
        filename_ext=$(basename $source_filepath)
        fname="${filename_ext%.*}"            # name_wo_ext
        fext="${filename_ext##*.}"            # extension
        @lnEsegui "ln -sf ${source_filepath}  ${dest_link_path}/${fname}.lnk.${fext}"

    done

    [[ "$fEXECUTE" != "--go" ]] && echo "enter: --go to execute"