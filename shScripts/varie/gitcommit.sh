#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 16-05-2026 09.14.35
#
# #########################################################


redH='\033[1;31m'
cyanH='\033[1;36m'
yellowH='\033[1;33m'
purpleH='\033[1;35m'
colorReset='\033[0m' # No Color

source "${ln_ENV_DIR}/init/commonFunctions/@load_common_functions.sh"


#############################################
#
#############################################
function syntax() {
    dq='"'
    g_script_name=$(basename ${BASH_SOURCE[0]})
    echo " $g_script_name:  examples:"
    echo
    echo "$TAB$g_script_name --go                                       ### local commit (default_comment = {dq}update $DATE{dq}"
    echo "$TAB$g_script_name ${dq}comment data${dq}  --go               ### local commit"
    echo "$TAB$g_script_name ${dq}comment data${dq}  --go --push        ### commit and push to remote"
    echo "$TAB$g_script_name ${dq}comment data${dq}  --go --push --tag  ### commit and push+tag to remote"
    echo
    echo "$TAB --------- Comandi utili --------------------------"
    echo "$TAB git checkout other_branch filename                       ### --- copy file from another branch"
    echo
    echo "$TAB --- TAGs"
    echo "$TAB git tag -n                               [show tags and message]"
    echo "$TAB git tag -l -n9                           [show tags and message]"
    echo "$TAB git tag -a ${dq}${g_date}${dq} -m ${dq}Tag note${dq}"
    echo "$TAB git clone -b [tag_name] [repository_url] [clone specific TAG]"
    echo
    echo "$TAB --- create new Branch (solo se non è stato fatto il commit)"
    echo "$TAB BR='devel' && git checkout -b \${BR} && git push -u gitHub \${BR}"
    echo
    echo "$TAB --- MOVE BRANCH (changes to a new one)"
    echo "$TAB BR='newBranch' && git checkout -b \${BR} && git add --all && git commit -a -m 'starting new branch'"
    echo "$TAB --- return to previos BRANCH (se necessario"
    echo "$TAB BR='prevBranch' && git checkout \${BR} && git restore . && git clean -fd"
    echo
    echo "$TAB --- DELETE BRANCH (-D -> --delete --force)"
    echo "$TAB BR='old_branch' && git branch -d \${BR} && git push gitHub --delete \${BR}"
    echo
    echo "$TAB --- CREATE DIRECTORY for specific BRANCH"
    echo "$TAB git worktree add ../pressControl-devel01 devel01"
    echo
    echo "$TAB # Rimuovere il file dalla storia git"
    echo "$TAB git filter-branch --tree-filter 'rm -f .pio/build/esp32_littleFS/src/main.cpp.o' HEAD"
    echo "$TAB # Forzare il push (ATTENZIONE: modifica la storia!)"
    echo "$TAB git push origin main --force-with-lease"
    echo
    echo "$TAB --- RENAME BRANCH"
    echo "$TAB oldName='name'; newName='name';git checkout main && git branch -m \${oldName} \${newName} && git push gitHub :\${oldName} \${newName}"
    echo
    echo "$TAB --- Muoversi nei commit e Tags"
    echo "$TAB git tag -n                               [show tags and message]"
    echo "$TAB git tag -l -n9                           [show tags and message]"
    echo "$TAB git log --oneline                        [show all commits and messages]"
    echo "$TAB git checkout V.1.3.2                     [checkout to specific Tag]"
    echo "$TAB git checkout 7a2b3c4                     [checkout to specific commit]"
    echo "$TAB git checkout main                        [Tornare all'ultima versione]"
    echo
    echo "$TAB git checkout -b nuovo-branch-dal-tag v1.0.2 [create a nuew branch from tagxxx]"
    echo
    echo "$TAB --------------------------------------------------"
    echo
    if [[ -f "zipLibraries.sh" ]]; then
        echo -e "\n${TAB}verrÃ  anche creato uno zip con lo script: zipLibraries.sh, presente nella current directory.\n\n"
    fi
    exit
}





function processDIR() {
    @lnEsegui "git add --all"

    @lnEsegui "git commit -a -m ${sq}${comment}${sq}"
    if [[ ${g_TAG} == "1" ]]; then
        @lnEsegui  "git tag -a ${sq}${TAG_VERSION}${sq} -m ${dq}$comment${dq}"
        @lnEsegui  "git push --tag"
    elif [[ "$g_PUSH" == "1" ]]; then
        @lnEsegui "git push"
    fi
    # echo -e ${colorReset}
}




# ######### M A I N #########
# ######### M A I N #########
# ######### M A I N #########
# ######### M A I N #########
# ######### M A I N #########
# ######### M A I N #########
    ${ln_SET_LORETO_ENVIRONMENT} 0

    scriptFullPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
    DATE=$(date +'D%Y-%m-%dT%H.%M')
    g_date=$(date +'D%Y-%m-%dT%H.%M')
    # TAG_VERSION=$(date +'Tag%Y.%m.%d')
    # TAG_VERSION=$(date +'Tag-D%Y-%m-%dT%H.%M')
    # yy_julianDay=$(date +'%y.%j')
    # TAG_VERSION="tag_v${yy_julianDay}" ### non deve avere BLANKs
    yy_date=$(date +'%y.%m.%d')
    TAG_VERSION="tag_v${yy_date}" ### non deve avere BLANKs
    fEXECUTE="--dry-run"

    sq="'"
    dq='"'

    g_TAG="0"
    args=$@

    [[ -z $args ]] && syntax && exit

    word='--subl';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && { ${ln_SUBLIME_START} $scriptFullPath; exit 1; }
    word='--edit';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && { ${EDITOR} $scriptFullPath; exit 1; }
    word='--push';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_PUSH=1
    word='--tag';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_TAG=1
    word='--go';    [[ " $args " == *" $word "* ]] && args=${args//$word/} && fEXECUTE="--go"


    args=$(echo $args) # trim string
    comment="${args:-update ${DATE} }" # ciÃ² che resta con default == update
    comment=$(echo $comment) # trim string
    # export $fEXECUTE

    @lnLog "${cyanH}update comment: ${dq}${comment}${dq}${colorReset}" # ciÃ² che restaq

    echo
    git status
    echo
    if [[ -f "zipLibraries.sh" ]]; then
        @lnEsegui "zipLibraries.sh"
    fi
    echo

    processDIR

    if [[ -e "./__main__.py" && -d ../lnPyLib ]]; then
        @lnLog "${cyan}-------------------------------------------${colorReset}"
        cd ../lnPyLib
        processDIR
        @lnLog "${TAB}${yellowH}lnPyLib has been updated too!${colorReset}\n"
    fi

