#!/bin/bash

###########################################
# updated by ...: Loreto Notarantonio
# Date .........: 27-12-2023 08.28.19
# scope: scan della directory MP3.
#        Per ogni autore scan delle subdir
#        Nella dest_dir verra creata una dir per authore con i link alle conzoni ma senza l'album
###########################################


fGO=""
fGO="$1"

set +x
set +u


#############################################
# -
#############################################
function esegui() {
    cmd=$1
    echo -e "       $dry_run $cmd"
    if [[ "$fGO" == "--go" ]]; then
        eval $cmd
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && exit $rCode
        echo
    fi
}


function lStrip() {
    base_string="$1"
    left_part="$2"
    echo ${base_string#"${left_part}"*}
}

function rStrip() {
    base_string="$1"
    right_part="$2"
    echo ${base_string%"${right_part}"*}
}




# Loop through files in the target directory
function iterate() {
    local dir="$1"
    echo "  reading: $dir"
    seq_number=1
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file") # just filename
            local fname="${filename%.*}"            # name_wo_et
            local fext="${filename##*.}"            # extension

            if [[ "${fext,,}" != "mp3" ]]; then
                echo -e "${TAByellowH}skipping: $file"
                continue

            elif [[ "$fRELATIVE" -eq 1 ]]; then
                cd "${dest_dir}"
                # dest_fname="${filename}"
                relative_source_path=$(lStrip "$file" "${root_directory}")
                source_path="${relative_up_level}/${relative_source_path}"
                # dest_file=""
                # file="${source_directory}/${author_name}/${filename}"
                # source_path="${relative_up_level}/${file}"
            else
                dest_file="${root_directory}/${dest_dir}/${filename}"
                source_path="${root_directory}/${file}"
            fi


            if [[ ! -f "${source_path}" ]]; then
                echo -e "${TABredH}source file NOT exists: $source_path"
                exit 1

            elif [[ -f "$dest_file" ]]; then
                curr_ptr="$(readlink -f ${dest_file})"
                dest_fname=$(basename "$dest_file")
                source_fname=$(basename "$source_path")
                if [ "$curr_ptr" == "${source_path}" ]; then
                    [[ "$verbose" == "yes" ]] && echo -e "${TAByellowH}OK --> ${cyanH}${dest_file} ${greenH}${source_path}${colorReset}"
                elif [ "$source_fname" == "${dest_fname}" ]; then
                    # seq_number=$(($seq_number + 1))
                    ((seq_number++))
                    dest_file="${root_directory}/${dest_dir}/${fname}_${seq_number}.${fext}"

                else
                    echo -e "${TABredH}wrong pointer (oppure duplicato) ${cyanH}${dest_file} ${colorReset}"
                    esegui "rm -f ${dest_file}"
                fi

                [[ "$verbose" == "yes" ]] && echo -e "${TABpurpleH}already exists: ${dest_file}"
            else
                # echo -e "${TAByellowH}creating:       ${source_path} ${dest_file}"
                esegui "ln -s "${source_path}" "${dest_file}""
            fi

        elif [ -d "$file" ]; then
            iterate "$file"
        fi
  done
}






source "${ln_SET_LORETO_ENVIRONMENT}"  >/dev/null



root_directory="$PWD"
fRELATIVE=0
relative_up_level="../../.."
verbose="yesx"

# Loop through dirs in the target directory
# sourceFPath="${root_directory}/${source_directory}"
# cd "$root_directory"
# echo "moved to directory: $PWD"

subdirs="Italiani Stranieri"
base_source="MP3"
base_dest="MP3_LINKS"
# Loop through dirs in the target directory
for subdir in $subdirs; do
    # source_directory="${PWD}/MP3/${subdir}"
    # dest_directory="${PWD}/MP3_LINKS_2/${subdir}"
    source_directory="${base_source}/${subdir}"
    dest_directory="${base_dest}/${subdir}"
    echo "working on $source_directory"
    for dir in "$source_directory/"*; do
        if [ -d "$dir" ]; then
            author_name=$(basename "$dir")
            dest_dir="${dest_directory}/${author_name}"
            [[ ! -d $dest_dir ]] && esegui "mkdir --parents "$dest_dir""
            echo -e "${TABcyanH}destination dir: $dest_dir"
            iterate "$dir"
        fi
    done
done
