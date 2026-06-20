#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 13-12-2025 15.36.24
#



if ! declare -F @lnLog > /dev/null; then source ln_log.functions; fi
if ! declare -F @setColors > /dev/null; then source colors.functions; fi
if ! declare -F @lnEsegui > /dev/null; then source esegui.functions; fi




##################################
#
#############################################
function parseInput() {
    function syntax() {
        echo -e "$TAByellowH    syntax $(basename $BASH_SOURCE) profile_name [options..]"
        echo -e "${cyanH}"
        echo "${TAB}Options:
            -h|--help           this help
            --go                really execute commands
            --log               display log output
            --delete            delete zip file if exists
            "

        echo -e "${colorReset}"
        echo
        exit 2
    }

    local fDEBUG=0
    local args=$@
    [[ "$fDEBUG" == '1' ]] && echo "${TAB}command line: $args"
    [[ -z $args ]] && args="test"
    fEXECUTE='--dry-run'
    fLOG=0
    fReplace=0

    # check rhe word and remove it from args
    word='-h';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax 1 && exit 1
    word='--help';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax 1 && exit 1
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && fEXECUTE="--go"
    word='--log';      [[ " $args " == *" $word "* ]] && args=${args//$word/} && fLOG=1
    word='--replace';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && fReplace=1

    g_Rest=$(echo $args) # remove BLANKs

    if [[ "$fDEBUG" == '1' ]]; then
        echo -e "${TAB}input args:   ${g_Rest}\n"
        echo "fLOG:      $fLOG"
        echo "fEXECUTE:  $fEXECUTE"
        echo "fReplace:  $fReplace"
    fi
}





# #############################################
# #############################################
function create_LnLib_zip() {
    local libdir="$1"
    local zipname="$2"
    # assumiamo che ci troviamo nella prj_dir

    if [ -d "$libdir" ]; then
        cd "$libdir"
        # echo
        # [[ -f ${zipname} ]] && { @lnLog "${purpleH}removing file $zipname"; @lnEsegui "rm -f ${zipname}"; }

        @lnLog "${yellow}source dir:    ${libdir}"
        @lnLog "${yellow}building file: ${zipname}"

        @lnEsegui "cd "$libdir" && zip -ur --latest-time $zipname *"

        @lnLog "${purpleH}${zipname}  has been created."
        # echo
    else
        echo
        @lnLog "${redH}${libdir} NOT found"
        echo
        # exit 1
    fi


}



#############################################################################
#               M A I N
#############################################################################
    # export fEXECUTE=${1:---dry-run}
    set -u
    parseInput $@


    # export fVERBOSE
    export fEXECUTE
    export fLOG
    saved_dir="$PWD"
    libraries="$saved_dir/Source/lnLib_lnk $saved_dir/Source/lnModules_lnk ${HOME}/filu/Programming/gitREPO/lnModules"
    libraries="$saved_dir/Source/lnLib_lnk"
    libraries="$saved_dir/pyLnLib_lnk"
    for lib in $libraries; do
        name=$(basename $lib)
        fname="${name%_*}"            # name before '_'
        zipname="$saved_dir/Source/${fname}.zip"
        if [[ -f ${zipname} && $fReplace == "1" ]]; then
            @lnLog "${purpleH}removing file $zipname"
            @lnEsegui "rm -f ${zipname}"
        fi
        create_LnLib_zip "$lib" "${zipname}"
    done
    cd "$saved_dir" # ritorna alla top
    echo
    [[ "$fLOG" == '0' ]] && echo -e "${fEXECUTE} - ${purpleH}${zipname}  has been created.\n"
    unset -f @lnEsegui
    unset -f @lnLog
    unset -f @lnLogv