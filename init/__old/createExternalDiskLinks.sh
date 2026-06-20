#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Version ......: 31-08-2020 09.23.07
#



# ----------------------------------------------
# ---  by Loreto
# updated by ...: Loreto Notarantonio
# Date .........: 15-11-2025 17.38.29
# ----------------------------------------------
function set_externalDiskLinks() {
    cd ${HOME}
    local external_disk="${HOME}/ext_disk"

    if [[ "${hostname_lc}" == "asusp2520l" || "${hostname_lc}" == "aspire5750g" ]]; then
        @createLink "/media/loreto/LnDisk_SD_ext4"    "${external_disk}"

    elif [[ "${hostname_lc}" == "ezbook-silvia" ]]; then
        @createLink "/media/loreto/LnDisk_SD_ext4"     "${external_disk}"

    elif [[ "${hostname_lc}" == "lnpi41" ]]; then
        @createLink "/media/pi/Ln1TB_41"               "${external_disk}"

    elif [[ "${hostname_lc}" == "lnpi51" ]]; then
        @createLink "/media/pi/Ln1TB_51"               "${external_disk}"

    fi

    local base_dest="${external_disk}/Filu"
    if [[ -d "${base_dest}" ]]; then
        # @createLink "${base_dest}/gitREPO"         "${HOME}/gitREPO"
        @createLink "${base_dest}/ln-eBooks"       "${HOME}/ln-eBooks"
        @createLink "${base_dest}/Programming"     "${HOME}/Programming"
    else
        @lnLog "${cyanH}destination path ${base_dest} NOT found. Skipping related links."
    fi
}


##########################################################
#               M A I N
##########################################################
    source ${ln_SET_LORETO_ENVIRONMENT} 0
    source create_links.functions
    fEXECUTE=${1:---no-go}

    set -u
    set_externalDiskLinks
