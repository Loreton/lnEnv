#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 09-02-2026 08.36.09
#

# if ! declare -F @removePath > /dev/null; then source manage_paths.functions; fi
if ! declare -F @setColors  > /dev/null; then source colors.functions; fi
# export fLOG=0


function show_help() {

    # if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e ${yellow}
        cat <<EOF
        Usage:
          @lnIconv <file> [options]

        Description:
          Automatically repairs UTF-8 mojibake caused by multiple
          UTF8→Latin1→UTF8 mis-encodings.
          Stops automatically when file no longer changes.

        Options:
          --inplace        Overwrite original file
          --backup         Create <file>.bak when used with --inplace
          --max=N          Maximum iterations (default: 10)
          -h, --help       Show this help

        Examples:
          @lnIconv file.sh
          @lnIconv file.sh --inplace
          @lnIconv file.sh --inplace --backup
          @lnIconv file.sh --max=5
EOF
        echo -e ${colorReset}
        return 0
    # fi
}


function @lnIconv() {

    local tmp_file="/tmp/repaired_$(basename "$source_file")"
    local prev_file
    local iteration=0

    cp "$source_file" "$tmp_file"

    while (( iteration < max_iter )); do
        iteration=$((iteration+1))
        prev_file="${tmp_file}.prev"

        cp "$tmp_file" "$prev_file"

        iconv -f utf-8 -t latin1 "$prev_file" \
        | iconv -f utf-8 -t utf-8 \
        > "$tmp_file"

        if cmp -s "$prev_file" "$tmp_file"; then
            rm -f "$prev_file"
            break
        fi

        rm -f "$prev_file"
    done

    if (( iteration == max_iter )); then
        echo "Warning: reached max iterations ($max_iter)"
    fi

    if (( inplace )); then
        if (( backup )); then
            cp "$source_file" "${source_file}.bak"
            echo "Backup created: ${source_file}.bak"
        fi
        mv "$tmp_file" "$source_file"
        echo "File repaired in place: $source_file"
    else
        echo "Final file created: $tmp_file"
    fi

    echo "Iterations performed: $iteration"
}




#########################################################
#     M A I N - M A I N - M A I N - M A I N - M A I N -
#########################################################
    local max_iter=10
    local inplace=0
    local backup=0

    if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi

    local source_file="$1"
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --inplace) inplace=1 ;;
            --backup)  backup=1 ;;
            --max=*)   max_iter="${1#*=}" ;;
            -h|--help) ;; # già gestito sopra
            *) echo "Unknown option: $1"; return 2 ;;
        esac
        shift
    done

    if [[ -z "$source_file" || ! -f "$source_file" ]]; then
        echo "File not found!"
        return 1
    fi

    @lnIconv "$@"

