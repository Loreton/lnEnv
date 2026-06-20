#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 30-08-2023 16.14.21
#========================================
function xxx() {
    scriptDir='/home/loreto/lnprofile/profile/init'
    for filename in ${scriptDir}/functions/*.function; do
        [ -e "$filename" ] || continue
        echo $filename
    done
}


# cd "${scriptDir}/functions"
function xxx2() {
    files=$(ls "${scriptDir}/functions/*.function") # sorted by name
    # files=$("ls") # sorted by name
    for file in ${files}; do
        filename="${scriptDir}/${file}"
        [ -e "$filename" ] || continue
        echo $filename
        # . "${filename}"
    done
}

function envars_01() {
    envars=$(env | grep -E -i "^g_|^ln_" | tr ' ' '\n' | sort)
    # echo $envars
    for var in $envars; do
        echo "..... $var"
    done
}
function envars_02() {
    envars=$(env | grep -E -i "^g_|^ln_") # torna un'unica stringa BLANK separator
    while IFS=' ' read -ra VAR; do
         for var in "${VAR[@]}"; do
            echo "..... $var"
         done
    done <<< "$envars" | sort

}
envars_02