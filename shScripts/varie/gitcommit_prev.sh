#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 19-02-2026 19.21.53
# Updates:
#
# #########################################################


####################Ã 
# Colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
redH='\033[1;31m'
cyanH='\033[1;36m'
yellowH='\033[1;33m'
purpleH='\033[1;35m'
colorReset='\033[0m' # No Color



####################################################
#
####################################################
function esegui() {
    CMD_DESCR=$1
    cmd=$2
    exit_on_error=${3:-exit_on_error}

    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        action="${purpleH} [executing]: "
    else
        action="${purpleH} [dry-run]: [${exit_on_error}] "
    fi

    echo -ne "${action}${cyanH} ${CMD_DESCR}${colorReset} "
    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        echo -e "$yellowH $cmd ${colorReset}"
        eval "$cmd"
        rCode=$?
        if [[ ! "$rCode" -eq 0 ]]; then
            echo "rcode=$rCode"
            [[ "$exit_on_error" == "exit" ]] && exit $rCode
        fi
    else
        echo -e "$yellowH $cmd ${colorReset}"
    fi
    CMD_DESCR=
}


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
    esegui "adding to git" "git add --all"

    esegui "committing..." "git commit -a -m ${sq}${comment}${sq}"
    if [[ ${g_TAG} == "1" ]]; then
        esegui "setting tag.." "git tag -a ${sq}${TAG_VERSION}${sq} -m ${dq}$comment${dq}"
        esegui "pushing......" "git push --tag"
    elif [[ "$g_PUSH" == "1" ]]; then
        esegui "pushing......" "git push"
    fi
    echo -e ${colorReset}
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
    g_fEXECUTE=0

    sq="'"
    dq='"'

    g_TAG="0"
    args=$@

    [[ -z $args ]] && syntax && exit


    word='--subl';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && { ${ln_SUBLIME_START} $scriptFullPath; exit 1; }
    word='--edit';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && { ${EDITOR} $scriptFullPath; exit 1; }
    word='--push';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_PUSH=1
    word='--tag';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_TAG=1
    word='--go';    [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE="1"

    args=$(echo $args) # trim string
    comment="${args:-update ${DATE} }" # ciÃ² che resta con default == update
    comment=$(echo $comment) # trim string

    echo -e "${TAB}${cyanH}update comment: ${dq}${comment}${dq}${colorReset}" # ciÃ² che restaq

    echo
    git status
    echo
    if [[ -f "zipLibraries.sh" ]]; then
        esegui "creazione dello zip con le librerie" "zipLibraries.sh"
    fi
    echo

    processDIR

    if [[ -e "./__main__.py" && -d ../lnPyLib ]]; then
        echo -e "\n\n${TAB}${cyan}-------------------------------------------${colorReset}"
        cd ../lnPyLib
        processDIR
        echo -e "${TAB}${yellowH}lnPyLib has been updated too!${colorReset}\n"
    fi

