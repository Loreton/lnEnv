#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Version ......: 31-08-2020 09.23.07
#

####################################################
# Colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
####################################################
function _ln_set_colors() {
    export TAB='    '
       red='\033[0;31m';    redH='\033[1;31m';    TABred="${TAB}${red}";       TABredH="${TAB}${redH}"
     green='\033[0;32m';  greenH='\033[1;32m';  TABgreen="${TAB}${green}";   TABgreenH="${TAB}${greenH}"
    yellow='\033[0;33m'; yellowH='\033[1;33m'; TAByellow="${TAB}${yellow}"; TAByellowH="${TAB}${yellowH}"
      blue='\033[0;34m';   blueH='\033[1;34m';   TABblue="${TAB}${blue}";     TABblueH="${TAB}${blueH}"
    purple='\033[0;35m'; purpleH='\033[1;35m'; TABpurple="${TAB}${purple}"; TABpurpleH="${TAB}${purpleH}"
      cyan='\033[0;36m';   cyanH='\033[1;36m';   TABcyan="${TAB}${cyan}";     TABcyanH="${TAB}${cyanH}"
      gray='\033[0;37m';   white='\033[1;37m';   TABgray="${TAB}${gray}";     TABgrayH="${TAB}${white}"
    colorReset='\033[0m' # No Color
}

_ln_set_colors

function _create_dir_link_ok() {
    local src_dir="$1"
    local link_path="$2"
    savedDir="$PWD"

    dest_dir=$(dirname $link_path)
    link_name=$(basename $link_path)
    if [[ -d "${src_dir}" ]]; then
        if [[ -d "${dest_dir}" ]]; then
            cd $dest_dir
            unlink "${link_name}" 2>/dev/null
            ln -vsf "${src_dir}" "$link_name"
        else
            echo "dest dir $dest_dir not exists"
        fi
    else
        echo "source dir $src_dir not exists"
    fi
    cd "${savedDir}"
}


function _create_dir_link() {
    local TAB="    "
    local src_path="$1"
    local link_path=$(eval echo "${2%*#}") # remove inline comment and trim

    [[ -z $src_path ]] && echo -e "${TABredH}source path is not valid. skipping" && return
    [[ -z $link_path ]] && echo -e "${TABredH}link path is not valid. skipping" && return

    real_sourcePath="$(readlink -fvs  $src_path)" # resolve links if any
    real_destPath="$(readlink -fvs  $link_path)" # resolve links if any

    if [[ "$real_sourcePath" == "$real_destPath" ]]; then
        echo -e "${TABcyanH}${link_path}${greenH} already pointing to: ${cyanH}$real_sourcePath"
        return
    fi

    echo -e "${TABredH}wrong pointer ${cyanH}${link_path} ${colorReset}"

    dest_dir=$(dirname $link_path)
    link_name=$(basename $link_path)

    # ------------------------
    # - se è una dir devo cancellarla altrimenti mi crea
    # - un'infinità di sub-dirs nel sorgente
    # - è giusto perché di fatto va a scrivere nel source
    # ------------------------
    if [ -d "${real_sourcePath}" ]; then
        echo -e "${TABcyanH} - it's a directory. ${redH}current logicalLink will be removed!${colorReset}"
        unlink ${link_path}
    fi

    ln -sf "${real_sourcePath}" "$link_path"

}


# ----------------------------------------------
# ---  by Loreto
# updated by ...: Loreto Notarantonio
# Date .........: 23-12-2024 14.30.17
# ----------------------------------------------
function set_LoretoLinks() {

    cd ${HOME}
    _create_dir_link "/media/loreto/LnDisk_SD_ext4/"        "${HOME}/ext_disk"
    _create_dir_link "${HOME}/ext_disk/Filu/GIT-REPO/"       "${HOME}/GIT-REPO"
    _create_dir_link "${HOME}/ext_disk/Filu/ln-eBooks/"      "${HOME}/ln-eBooks"
    _create_dir_link "${HOME}/ext_disk/Filu/ln-eBooks/Ln_Library/authorsLibrary/" "${HOME}/calibreLibrary/authorsLibrary"
}


set_LoretoLinks

