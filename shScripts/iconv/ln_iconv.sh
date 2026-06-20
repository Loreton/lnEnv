#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 09-02-2026 08.36.09
#

# if ! declare -F @removePath > /dev/null; then source manage_paths.functions; fi
if ! declare -F @setColors  > /dev/null; then source colors.functions; fi
# export fLOG=0

#!/usr/bin/env bash

#######################################
show_help() {
#######################################
    echo -e ${yellow}
    cat <<EOF
        Usage:
          $(basename "$0") <file>

        Description:
          Automatically repairs UTF-8 mojibake caused by multiple
          UTF8 ↔ Latin1 mis-encodings.
          Stops automatically when file no longer changes.

        Examples:
          $(basename "$0") test_file.txt
EOF
    echo -e ${colorReset}
}



#######################################
lnIconv() {
#######################################
    local source_file="$1"

    if [[ ! -f "$source_file" ]]; then
        echo "File not found!"
        return 1
    fi

    local tmp_file="/tmp/repaired_$(basename "$source_file")"
    local prev_file
    local iteration=0
    local max_iter=3

    cp "$source_file" "$tmp_file"

    while (( iteration < max_iter )); do
        ((iteration++))
        prev_file="${tmp_file}.prev"

        cp "$tmp_file" "$prev_file"

        # pipeline che “srotola” un livello di mojibake
        if iconv -f utf-8 -t latin1 "$prev_file" | iconv -f latin1 -t utf-8  > "${tmp_file}.new"; then
            # se non cambia → stop
            if cmp -s "$prev_file" "${tmp_file}.new"; then
                rm -f "$prev_file" "${tmp_file}.new"
                break
            fi

            mv "${tmp_file}.new" "$tmp_file"
        else
            echo "iconv error at iteration $iteration — stopping."
            rm -f "$prev_file" "${tmp_file}.new"
            break
        fi

        rm -f "$prev_file"
    done

    echo "Final file created: $tmp_file"
    echo "Iterations performed: $iteration"
}





#######################################
main() {
#######################################
    # -h come primo parametro → help
    if [[  $# -eq 0  || "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi

    lnIconv "$@"
}

main "$@"
# @lnIconv "$@"
