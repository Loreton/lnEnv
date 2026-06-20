#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 28-01-2025 09.18.58
#


apache_user="www-data"
curr_user="loreto"
_WWW_ROOT='/var/www'


function set_domain_rights() {
    local domain_name="$1"
    [[ $domain_name == '' ]] && { echo "missing domain name (Es.: website01)"; return 0; }
    local document_root="${_WWW_ROOT}/${domain_name}"

    [[ ! -d "$document_root" ]] && { echo "path: ${document_root} not found"; return 1; }
    sudo chown -R ${curr_user}:${apache_user} ${document_root}
}



##################################################
#
##################################################
function writeVhosts() {
    local file="${1}"
    [[ -f $file ]] && { echo "${file} file already exists ...."; return 1; }

    sudo /bin/cat >"${file}" <<EOM
# listen ${domain_name}:80

<VirtualHost ${domain_name}:80>
    # ref: /opt/lampp/etc/httpd.conf
    DocumentRoot "${document_root}"
    DirectoryIndex index.php

    #
    # LogLevel: Control the number of messages logged to the error_log.
    # Possible values include: debug, info, notice, warn, error, crit,
    # alert, emerg.
    # loreto: ho totato che il log vuol il percorso completo
    #
    LogLevel info
    ErrorLog "${document_root}/logs/error_log"
    CustomLog "${document_root}/logs/access_log" common

    <Directory "${document_root}">
        Options All
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOM
}

##################################################
#
##################################################
function writePhpIndex() {
    local file="${1}"

    [[ -f $file ]] && { echo "${file} file already exists ...."; return 1; }
    sudo /bin/cat >"${file}" <<EOM
<?php
    phpinfo( );
?>
EOM
}



##################################################
#
##################################################
function create_website() {
    local domain_name="$1"
    [[ $domain_name == '' ]] && { echo "missing domain name (Es.: website01)"; return 0; }
    local document_root="${_WWW_ROOT}/${domain_name}"

    local vhosts_list="${_WWW_ROOT}/httpd-vhosts_list.conf"
    sudo chown ${curr_user}:${apache_user} ${vhosts_list}
    local index_php="${document_root}/index.php"
    local vhosts="${document_root}/conf/virtual_hosts.conf"



    # [[ -d "$document_root" ]] && echo "path: $document_root already exists..." && return 0


    [[ ! -d ${document_root} ]] &&        sudo mkdir -p ${document_root}
    [[ ! -d ${document_root}/php ]] &&    sudo mkdir -p ${document_root}/php
    [[ ! -d ${document_root}/html ]] &&   sudo mkdir -p ${document_root}/html
    [[ ! -d ${document_root}/images ]] && sudo mkdir -p ${document_root}/images
    [[ ! -d ${document_root}/conf ]] &&   sudo mkdir -p ${document_root}/conf
    [[ ! -d ${document_root}/logs ]] &&   sudo mkdir -p ${document_root}/logs
    set_domain_rights "${domain_name}" # una prima volta...

    writePhpIndex "${index_php}"
    writeVhosts  "${vhosts}"
    sudo touch "${vhosts_list}"



    # # -----------
    : '
    echo "adding include vhost for domain ${domain_name}..."

    local include_line="IncludeOptional ${vhosts}"
    exists=$(grep "${include_line}" "${vhosts_list}" | wc -l)
    if [[ ${exists} -eq 0 ]]; then
        echo "${include_line}" >>${vhosts_list}
    fi
    '

    set_domain_rights "${domain_name}" # una seconda volta
    echo "la struttura web ${document_root} è stata creata"
}


create_website $*
