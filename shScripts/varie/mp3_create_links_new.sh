#!/bin/bash

###########################################
# updated by ...: Loreto Notarantonio
# Date .........: 28-12-2023 12.18.12
# scope: scan della directory MP3.
#        Per ogni autore scan delle subdir
#        Nella dest_dir verra creata una dir per authore con i link alle conzoni ma senza l'album
###########################################




#############################################
# -
#############################################
function esegui() {
    cmd="$@"
    [[ "$fGO" == "--go" ]] && dry_run="" || dry_run="[dry-run]"
    echo -e "       $dry_run $cmd"
    if [[ "$fGO" == "--go" ]]; then
        eval $cmd
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && exit $rCode
        echo
    fi
}

function esegui_always() {
    cmd="$@"
    save_fGO=$fGO
    fGO="--go"
    esegui "$@"
    fGO=$save_fGO
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

function renameFile() {
    local curr_path=$1
    local filename=$(basename "$curr_path")      # just filename
    local fname="${filename%.*}"            # name w/o ext
    local fext="${filename##*.}"            # extension

    ### rename source file
    seq_number=0
    local source_path=$(dirname $curr_path)
    while true; do
        ((seq_number++))
        seqNum=$(printf "%02d" $seq_number) ## padding to 2 chars - oppure ---> seq_n=printf -v j "%02d" $seq_number
        new_fname="${fname}_${seqNum}.${fext}"
        [[ -f "$new_fname" ]] && continue ### if exists in the current dir increments seq_number
        new_source="${source_path}/${new_fname}"
        [[ -f "$new_source" ]] && continue ### if exists in the original dir increments seq_number
        esegui_always "mv ${source_rel_path_from_dest} ${new_source}" ### rename original filepath
        source_rel_path_from_dest=$new_source
        dest_fname=$new_fname
        [[ "$verbose" == "yes" ]] && echo -e "${TABpurpleH}already exists renaming to: ${new_fname}"
        break
    done
}


# Loop through files in the target directory
function iterate_on_relative_Author() {
    set -u
    local abs_dir="$1"
    echo -e "${cyanH}destination dir: $dest_dir"
    echo -e "${TAB}${TABcyanH}reading: $abs_dir"

    ### - moving to dest directory
    cd "${dest_dir}"

    seq_number=0 # azzerato per ogni autore
    for file in "$abs_dir"/*; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")      # just filename
            local dest_fname=$filename
            local fname="${dest_fname%.*}"            # name w/o ext
            local fext="${dest_fname##*.}"            # extension

            if [[ "${fext,,}" != "mp3" ]]; then
                echo -e "${TAByellowH}skipping: $file"
                continue
            fi


            local relative_source_path=$(lStrip "$file" "${root_directory}/")
            local source_rel_path_from_dest="${relative_up_level}/${relative_source_path}"


            if [[ ! -f "${source_rel_path_from_dest}" ]]; then
                echo -e "${TABredH}source file NOT exists: $source_rel_path_from_dest"
                exit 1
            fi

            ### --------------------------------------------------------
            ### se il link_name esiste di giÃ  verifichiamo se valido
            ### --------------------------------------------------------
            if [[ "$dest_fname" == "Amanti_2.mp3" ]]; then
                a=0
            fi

            if [[ -f "$dest_fname" ]]; then
                abs_curr_ptr="$(readlink -f ${dest_fname})"
                abs_new_ptr="$(readlink -f ${source_rel_path_from_dest})"

                ### - check if pointer is right
                if [ -f "$abs_curr_ptr" ]; then
                    # il link Ã¨ valido

                    if [ "$abs_curr_ptr" == "${abs_new_ptr}" ]; then
                        ### punta al file corrente
                        [[ "$verbose" == "yes" ]] && echo -e "${TAByellowH}OK --> ${cyanH}${dest_fname} ${greenH}${source_rel_path_from_dest}${colorReset}"
                        dest_fname=""

                    else
                        ### filename giÃ  esiste, quindi questo Ã¨ un duplicato
                        renameFile  $source_rel_path_from_dest





                     #   source_path=$(dirname $source_rel_path_from_dest)
                     #   ## punta ad un source diverso, creiamo un nuovo nome
                     #   ## okkio che in uno stato esistente potrebbe creare link con nomi diversi puntanti allo stesso sorgente
                     #   ## non mi vÃ  di complicare il programma
                     #   while true; do
                     #       ((seq_number++))
                     #       new_fname="${fname}_${seq_number}.${fext}"
                     #       [[ -f "$new_fname" ]] && continue
                     #       [[ "$verbose" == "yes" ]] && echo -e "${TABpurpleH}already exists renaming to: ${new_fname}"
                     #       new_source="${source_path}/${new_fname}"
                     #       esegui_always "mv ${source_rel_path_from_dest} ${new_source}"
                     #       source_rel_path_from_dest=$new_source
                     #       dest_fname=$new_fname
                     #       break
                     #   done
                    fi

                else
                    ### - link points to invalid source
                    echo -e "${TABredH}wrong pointer ${cyanH}${dest_fname} -> ${source_rel_path_from_dest} ${colorReset}"
                    esegui_always "rm -f ${dest_fname}"

                fi
            fi


            ### --------------------------------------------------------
            ### se abbiamo un dest_name creiamo il link
            ### --------------------------------------------------------
            if [[ ! -z "$dest_fname" ]]; then
                echo -e "${TAByellowH}creating: ${dest_fname} -> ${source_rel_path_from_dest} "
                esegui "ln -s "${source_rel_path_from_dest}" "${dest_fname}""
            fi

        ### loop next sub-directory
        elif [ -d "$file" ]; then
            iterate_on_relative_Author "$file"
        fi
    done
    set +u
}





function processAuthor() {
    local author_dir=$1
    # Loop through dirs in the target directory
    source_directory="${root_directory}/${base_source}/${author_dir}"
    dest_dir="${root_directory}/${base_dest}/${author_dir}"
    [[ ! -d $dest_dir ]] && esegui_always "mkdir --parents "$dest_dir""
    iterate_on_relative_Author "${source_directory}"
}




function elena() {
    local elena_mp3="elena_mp3.txt"
    content=$(cat $elena_mp3)
    base_dest="elena_MP3_LINKS"
}

function loreto() {
    local loreto_mp3="loreto_mp3.txt"
    content=$(cat $loreto_mp3)
    base_dest="loreto_MP3_LINKS"
}


##########################################################################################
# M A I N
##########################################################################################

    source "${ln_SET_LORETO_ENVIRONMENT}"  >/dev/null


    fGO=""
    fGO="$1"

    set +x
    set +u


    # -- lettura file degli autori
    root_directory="/media/loreto/LnDisk_SD_ext4/Filu/myData"
    root_directory="$PWD"
    [[ ! -d $root_directory ]] && echo -e "${TABredH} dir $root_directory not exists" && exit 1
    cd $root_directory


    loreto



    fRELATIVE=1
    relative_up_level="../../.."
    verbose="yes"
    base_source="MP3"

    set -u
    # ---- M A I N    L O O P -----
    while IFS= read -r line; do
        line=$(echo $line) # trim BLANKs
        [[ -z $line ]] && continue
        firstChar="${line:0:1}"
        [[ $firstChar == '#' ]] && continue
        first3Chars="${line:0:3}"
        [[ $first3Chars == 'end' ]] && exit
        processAuthor $line
    done < <(printf '%s\n' "$content")


