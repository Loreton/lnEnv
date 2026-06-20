#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 22-02-2023 09.24.30
#




### traverse only directories
# for dir in /home/loreto/lnprofile/*/; do
#     echo "$filepath"
# done

source="${HOME}/.ln_test"
source="${HOME}/.ln"
TAB='    '
conuter=0


### traverse files and directories
shopt -s globstar
for filepath in ${source}/**/*; do
    [[ "$filepath" == *"appl_config"* ]] && continue
    ((counter++))
    res=$((counter%250))
    [[ $res -eq 0 ]] && echo "\n\nprocessed line: ${counter}\n\n"
    _ch_mod=''

    if [[ -L $filepath ]]; then
        filetype="${TAB}link     "

    elif [[ -f "$filepath" ]]; then
        is_binary=$(file "$filepath" | grep -iE 'compiled|executable|BuildID|64-bit|linked|archive' | wc -l)
        is_script=$(file "$filepath" | grep -iE 'shell script|python script' | wc -l)
        is_text=$(file "$filepath" | grep -iE 'text|json data|INItialization|PDF document|Excel|empty' | wc -l)
        is_link=$(file "$filepath" | grep -iE 'symbolic link' | wc -l)

        if [[ $is_script -eq 1 ]]; then
            filetype="${TAB}script   "
            _ch_mod='u=rx,g=rx,o=rx'

        elif [[ $is_text -eq 1 ]]; then
            filetype="${TAB}text     "
            _ch_mod='u=r,g=r,o=r'

        elif [[ $is_binary -eq 1 ]]; then
            filetype="${TAB}binary   "
            _ch_mod='u=rx,g=rx,o=rx'

        elif [[ $is_link -eq 1 ]]; then
            filetype="${TAB}link     "

        else
            filetype="${TAB}unknown  "
            _ch_mod='u=r,g=r,o=r'
        fi
    else
        echo "directory - ${filepath}"
        filetype=
        _ch_mod='755'
    fi

    if [[ ! -z "$_ch_mod" ]]; then
        chmod $_ch_mod "$filepath"
        rcode=$?
        [[ $rcode -ne 0 ]] && exit 1
        if [[ "${filetype}" == *'directory'* ]]; then
            echo -n "$filetype " && ls -ld "$filepath"
        elif [[ -z "${filetype}" ]]; then
            _=
        else
            echo -n "$filetype " && ls -l "$filepath"
        fi
    fi


done
