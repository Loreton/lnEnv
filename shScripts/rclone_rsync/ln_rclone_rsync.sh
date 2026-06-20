#!/bin/bash
# needs pip3 install -U niet

########################################
# updated by ...: Loreto Notarantonio
# Date .........: 13-08-2022 19.42.10
#
# program: ln_rclone_V102.sh
########################################


#########################################################
# trap ctrl-c and call ctrl_c()
#########################################################
trap ctrl_c INT
function ctrl_c() {
    echo "** Trapped CTRL-C"
    rCode=1
    exit 1
}


#########################################################
# variabili di base e lettura profile
#########################################################
function set_base_vars() {
    scriptFPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
    scriptDir="$(dirname $scriptFPath)"
    scriptName="$(basename $scriptFPath .sh)" # remove extension
    # scriptName="$(basename $scriptFPath)" # contiene extension
    g_ETH0_IP=$(hostname -I | cut -d' ' -f1)
    # host_name=$(hostname -s | tr '[:upper:]' '[:lower:]')
    host_name=$(hostname -s)
    g_hostname=${host_name,,}

    #-------------------------------
    # -  P R O F I L E S
    #-------------------------------
    local profiles="lnprofile myData lnDisk ${scriptName}"
    for profile in $profiles; do
        filename="${scriptDir}/${profile}.profiles"
        [[ ! -f "$filename" ]] && echo "profile $filename not found!" && exit 1
        echo -e "${TAByellowH}loading $filename"
        source $filename
    done
}




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
function set_colors() {
    TAB='    '
       red='\033[0;31m';    redH='\033[1;31m';    TABred="${TAB}${red}";       TABredH="${TAB}${redH}"
     green='\033[0;32m';  greenH='\033[1;32m';  TABgreen="${TAB}${green}";   TABgreenH="${TAB}${greenH}"
    yellow='\033[0;33m'; yellowH='\033[1;33m'; TAByellow="${TAB}${yellow}"; TAByellowH="${TAB}${yellowH}"
      blue='\033[0;34m';   blueH='\033[1;34m';   TABblue="${TAB}${blue}";     TABblueH="${TAB}${blueH}"
    purple='\033[0;35m'; purpleH='\033[1;35m'; TABpurple="${TAB}${purple}"; TABpurpleH="${TAB}${purpleH}"
      cyan='\033[0;36m';   cyanH='\033[1;36m';   TABcyan="${TAB}${cyan}";     TABcyanH="${TAB}${cyanH}"
      gray='\033[0;37m';   white='\033[1;37m';   TABgray="${TAB}${gray}";     TABgrayH="${TAB}${grayH}"
    colorReset='\033[0m' # No Color
}
set_colors




#-------------------------------
# read profile and display it
#-------------------------------
function displayProfile() {
    # $profile;rCode=$?
    if [ $rCode -eq 0 ] ; then
        echo -e "${TAB} ${cyanH} configuration file   : $rclone_config"
        echo
        echo -e "${TAB} ${cyanH} sync_options         : $sync_options"
        echo
        echo -e "${TAB} ${cyanH} local_root_dir       : $local_root_dir"

        if [[ "$remote_type" == "gmail" ]]; then
            echo -e "${TAB} ${cyanH} remote_root_dir      : remote_node:_@REMOTE_NODE"
        else
            echo -e "${TAB} ${cyanH} remote_root_dir      : $remote_root_dir"
        fi
        echo
        my_folders=$(echo $folders| tr '\n' ' ')
        echo -e "${TAB} ${cyanH} folders              : $my_folders"
        echo -e "${TAB} ${cyanH} remote_node          : $remote_node"
        echo -e "${TAB} ${cyanH} remote_type          : $remote_type"
        echo -e "${TAB} ${cyanH} fEXECUTE             : $g_fEXECUTE"
        echo
        # echo -e "${TAB} $purpleH enter to continue....(ctrl-c to exit)"; read
    else
        echo "      ERROR - Profile [$profile] not found"
        exit $rCode
    fi
}


#############################################
# https://stackabuse.com/how-to-parse-command-line-arguments-in-bash/
# https://www.baeldung.com/linux/bash-parse-command-line-arguments
#############################################
function parseInput() {
    #############################################
    #
    #############################################
    function help() {
        echo -e "$TAByellowH    syntax $(basename $BASH_SOURCE) profile_name [options..]"
        echo -e "${cyanH}"
        echo "${TAB}Options:
            -h|--help           this help
            --profile           profile name to be synched
            --progress          show progress
            --log               set log
            --verbose           show details
            --delete            delete excluded
            --no-prompt         do not ask for confirmation
            "
            # --go                really execute commands
            # --dry-run           dry-run execution

        echo -e "${colorReset}"
        echo
        exit 2
    }


    N_ARGUMENTS=$# # Returns the count of arguments that are in short or long options
    [[ "$N_ARGUMENTS" -eq 0 ]] && help
    g_profile_name='dummy'
    EXCLUDE=""
    g_fEXECUTE=0
    g_SingleSTEP="yes"
    g_VERBOSE='-v'


    # ':' argument is expected otherwise it's just a flag
    SHORT='dr,h,p:'
    LONG='profile:,verbose,go,no-prompt,help'
    VALID_ARGS=$(getopt -a -n ParseInput --options $SHORT --longoptions $LONG -- "$@")
    if [[ $? -ne 0 ]]; then
        exit 1;
    fi

    eval set -- "$VALID_ARGS"
    while [ : ]; do
        case "$1" in
            -p | --profile)
                shift
                g_profile_name=$1
                ;;

            --no-prompt)
                g_SingleSTEP='no'
                ;;

            --verbose)
                g_VERBOSE='-vv'
                ;;

            -h | --help)
                help; ;;

            --)
                shift
                break
                ;;
            *)
                echo "Unexpected option: $1"; help; ;;
        esac

        shift
    done

    echo "remaining args are: $@"
}


#############################################
#
#############################################
function get_remote_root_dir() {

    case $remote_type in
        "gmail")
            remote_root_dir="${node}:_@${node^^}${base_remote_root_dir}"
            ;;
        "sftp")
            remote_root_dir="${node}:${base_remote_root_dir}"

            check_cmd="${rcloneCMD} --config=${rclone_config} lsd ${remote_root_dir}"
            echo
            echo "     [CMD]  ${check_cmd}"
            echo

            ${check_cmd}; rCode=$?
            if [ "$rCode" -gt 0 ]; then
                echo
                echo "$rCode: Forse la directory remota non esiste...."
                echo
                exit 1
            fi
            ;;

        "*")
            remote_root_dir="${base_remote_root_dir}"
            ;;
    esac

}


#############################################
#
#############################################
function get_source_dest_dir() {
    if [[ "$dir_name" == '.' ]]; then
        source="$local_root_dir"
        remote="${remote_root_dir}"
        dir_name=''
    else
        source="$local_root_dir/$dir_name"
        remote="${remote_root_dir}/${dir_name}"
    fi
}


#############################################
#
#############################################
function set_pause() {
    local msg=$1
    if [[ "$g_SingleSTEP" == 'yes' ]]; then
        echo -e "${TABcyanH}
        choices....:
                x|q:        exit|quit
                p:          process/sync this folder
                all:        process this and all the rest
                any key:    skip this
        ${TABpurpleH}  please enter your choice for....:
                $msg ${colorReset}"
        read choice
        # choice='all'
    else
        choice='process_all'
    fi


    case "$choice" in
        '')
            choice='skip'
            ;;
        'p')
            choice='process'
            ;;
        all)
            choice='process_all'
            g_SingleSTEP='no'
            ;;
        # s)
        #     choice='s'
        #     g_SingleSTEP='yes'
        #     ;;
        x|q)
            exit 1
            ;;
        *)
            echo "[${choice}]: skipping"
            ;;

    esac

}


################################################
# M A I N
#################################################
    set_base_vars
    set -u # check undefined variables

    # Parse input
    parseInput $@

    #-------------------------------
    # read profile and display it
    #-------------------------------
    project_exclude_files=""
    read_profile_data $g_profile_name
    [[ ! -f $rclone_config ]] && echo "Configuration file: $rclone_config does not exists!" && exit 1


    # ------------------- EXCLUDE
    # create temp exclude file and add project files... if any
    # EXCLUDE='--exclude *.log --exclude *.bak --exclude sync.ffs_db --exclude /__pycache__/**'
    work_exclude_filename="${log_dir}/exclude_files.txt"
    cp -p "${scriptDir}/conf/exclude-file.txt" "$work_exclude_filename"

    for item in $project_exclude_files; do
        echo $item >>$work_exclude_filename
    done
    # ------------------- EXCLUDE

    sync_options="$g_VERBOSE $rclone_options --exclude-from "${work_exclude_filename}" $g_DELETE_EXCLUDED"
    echo $sync_options


    #-------------------------------
    # display profile
    #-------------------------------
    displayProfile


    #-------------------------------
    # process profile
    #-------------------------------
    base_remote_root_dir=$remote_root_dir
    log_dir='/tmp/rclone/rclone_rsync'
    mkdir -p $log_dir
    for node in $remote_node; do
        get_remote_root_dir

        echo "----------------------------------------------"
        echo "-    Working with node $node "
        echo "-    [Local]   $local_root_dir "
        echo "-    [Remote]  $remote_root_dir "

        for dir_name in $folders; do
            get_source_dest_dir

            CMD="${rcloneCMD} --config=$rclone_config sync $sync_options $source $remote"
            echo
            echo -e "${cyanH}     Folder:  ${remote}"
            echo
            echo -e "${yellowH}     CMD:  ${CMD}${colorReset}"
            echo

            g_fEXECUTE=1

            # con dry-run e senza log
            if [[ "$g_SingleSTEP" == 'yes' ]]; then
                _dir_name=$(echo $dir_name |tr '/' '-')
                log_file="${log_dir}/${g_profile_name}_${_dir_name}.log"
                echo "" >$log_file

                LOG="--log-file=$log_file"
                g_DRY_RUN='--dry-run'
                echo -e "${TAByellowH} working on dir: ${remote}${colorReset}" && ${CMD} $g_DRY_RUN $LOG
                skip_it=$(grep 'nothing to transfer' $log_file)
                echo -e "${TABredH} ${skip_it}${colorReset}"
                [[ "$skip_it" != '' ]] && continue
                cat $log_file
                g_DRY_RUN=''
            fi

            set_pause $remote

            # Senza dry-run e senza log
            if [[ "$choice" == "process" || "$choice" == "process_all" ]]; then
                echo -e "${TAByellowH} working on dir: ${remote}${colorReset}"
                ${CMD}
            fi

        done

        echo "---------------------------------------------"

    echo -e "${TAByellowH}Processed diretories:"
    for dir_name in $folders; do
        echo -e "${TAB}${TABcyanH}${local_root_dir}/${dir_name} --> ${remote_root_dir}/${dir_name}"
    done
    echo
    # sample call:
    # LnLaunch.sh LnDisk_to_gmail -v --progress
    # LnLaunch.sh f_Antonietta -v --progress

    : ' Esempio di commento multiline
        Comandi di comodo:
            rclone about nloreto:
            rclone lsd nloreto:
            rclone ls nloreto:_@NLORETO/Lesla/Case/Loreto/2020/C946
    '