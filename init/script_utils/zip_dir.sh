#/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 16-05-2026 14.42.06
#

<<'COMMENT'
    # if [ -d "$dirPath" ]; then
    #     echo
    #     # zipName="${curr_dir}/${zip_name}.zip"
    #     [[ -f ${zipName} ]] && echo -e "$TABpurpleH removing file $zipName" && rm -f ${zipName}

    #     echo -e "${TABpurpleH}- building file: ${zipName}"

    #     cd "$dirPath"
    #     zip -ur --latest-time $zipName *

    #     echo -e "\n${TAByellowH}- ${zipName}     has been created."
    #     echo
    # else
    #     echo
    #     echo -e "${TABredH} ${dirPath} NOT found"
    #     echo
    #     exit 1
    # fi
COMMENT
# #############################################
# # Per le candidate_directories cerchiamo di
# #     risolvere tutti i link inglobando il vero
# #     file in modo da avere, su git, il progetto completo.
# #############################################
function zip_directory() {
    dirPath=${1:-}
    zipName=${2:-}

    echo $zipName

    if [ -d "$dirPath" ]; then
        parent_dir=$(dirname $dirPath)
        cd "$parent_dir"
        for name in *; do
            zip -ur --latest-time $zipName $(basename $dirPath)
        done
    fi
    # cd "$saved_dir" # ritorna alla top



}

set -u
dir_path=${1:-}
zip_name=${2:-}
[[ -z $dir_path ]] && { echo "please enter path to be zipped"; exit 1 ; }

[[ ${zip_name} == '=' ]] && zip_name="${PWD}/$(basename $dir_path).zip"
[[ -z $zip_name ]] && { echo -e "\n${TAByellowH}please enter zip_name or = (basename of dir_path will be taken)\n"; exit 1; }
zip_directory $dir_path $zip_name

