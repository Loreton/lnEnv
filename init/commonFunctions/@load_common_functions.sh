#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 16-05-2026 09.46.07
#


# commonFunction="${BASH_SOURCE}"
pwd="${BASH_SOURCE%/*}" ###. get parent dir
[[ "$fLOG" != "0" ]] && echo -e "\n${TABwhiteH}------------------ common functions -------------------"
if ! declare -F @setColors    > /dev/null; then source ${pwd}/colors.functions; fi
if ! declare -F @lnEsegui     > /dev/null; then source ${pwd}/esegui.functions; fi
if ! declare -F @lnLog        > /dev/null; then source ${pwd}/ln_log.functions; fi


if ! declare -F @isAbsolute   > /dev/null; then source ${pwd}/is_absolute.functions; fi
if ! declare -F @createLink   > /dev/null; then source ${pwd}/create_links.functions; fi
if ! declare -F @add_path     > /dev/null; then source ${pwd}/manage_paths.functions; fi
# if ! declare -F @vEnvCreation > /dev/null; then source ${pwd}/venv_creation.functions; fi
unset pwd


# [[ "$fLOG" != "0" ]] && echo -e "\n${TABwhiteH}------------------ common functions -------------------"
# function_files=$(find "${ln_INIT_DIR}/commonFunctions"  -type f -name '*.functions' | sort) # *.function potrebbe essere sotto diverse directories
# for filename in ${function_files}; do
#     [ -f "$filename" ] || continue
#     @lnLog "running: ${yellowH}${filename}${colorReset}"
#     source "${filename}"
# done