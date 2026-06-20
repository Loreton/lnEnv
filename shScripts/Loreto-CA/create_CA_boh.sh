#!/bin/bash
# come input chiede due interfacce di rete ... eth0 wlan1
#
# updated by ...: Loreto Notarantonio
# Date .........: 27-08-2023 17.26.52
#
# ref: https://gist.github.com/jmhertlein/22a6d678d01cb7ca529e
#


#=====================================
#=
#=====================================
function setEnvars() {
    local ca_name="$1"
    source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" # >/dev/null

    g_prj_dir=$(dirname $scriptDir)
    g_prj_dir=$scriptDir
    set -u


    g_CA_NAME=${ca_name}
    echo $g_prj_dir

    g_signing_DIR="${g_prj_dir}/signing";  mkdir -p $g_signing_DIR
    g_hosts_DIR="${g_prj_dir}/host";       mkdir -p $g_hosts_DIR
    g_CA_DIR="${g_prj_dir}/rootCA";            mkdir -p $g_CA_DIR

    g_rootCA_key="${g_CA_DIR}/${ca_name}.key"
    g_rootCA_pem="${g_CA_DIR}/${ca_name}.pem"

    g_CA_sign_key="${g_signing_DIR}/${g_CA_NAME}.sign.key"
    g_CA_sign_pem="${g_signing_DIR}/${g_CA_NAME}.sign.pem"
    g_CA_sign_csr="${g_signing_DIR}/${g_CA_NAME}.sign.csr"

    g_key_bits='4096'

}


##################################################
# for generating your root CA private key and cert
##################################################
function createRootCA() {
    local ca_cert_expire_days="36660" # 100 anni


    if [[ -f "${g_rootCA_key}" ]]; then
        echo -e "${TABcyanH}${g_rootCA_key} already exists${colorReset}"
    else
        echo
        echo -e "${TABcyanH}Generating root CA private key: ${g_rootCA_key}${colorReset}"
        openssl genpkey -algorithm rsa -out ${g_rootCA_key} -AES-256-CBC -pkeyopt rsa_keygen_bits:"${g_key_bits}"
    fi


    if [[ -f "${g_rootCA_pem}" ]]; then
        echo -e "${TABcyanH}${g_rootCA_pem} already exists${colorReset}"
    else
        SUBJECT="/C=IT/ST=Italy/L=Rome/O=LoretoNet/OU=root/CN=Casetta.duckdns.org/emailAddress=loreto.n@gmil.com"
        echo
        echo -e "${TABcyanH}Signing root CA certificate: ${g_rootCA_pem}${colorReset}"
        openssl req -x509 -new -key "${g_rootCA_key}" -days "${ca_cert_expire_days}" -out "${g_rootCA_pem}" -sha512 -subj ${SUBJECT}
    fi
}



################################################################
#
# If you want to use intermediate/signing keys
# (so your root CA's private key can stay in offline
# storage except for when you re-sign your signing keys)...
#
# ...then generate them here.
#
################################################################
function createRootCA_signed() {
    local days="36660" # 100 anni
    # local csr_req="${g_signing_DIR}/${g_CA_NAME}.sign.csr"
    local SUBJECT="/C=IT/ST=Italy/L=Rome/O=LoretoNet/OU=root/CN=Casetta.duckdns.org/emailAddress=loreto.n@gmil.com"


    if [[ -f "${g_CA_sign_key}" ]]; then
        echo -e "${TABcyanH}${g_CA_sign_key} already exists${colorReset}"
    else
        echo -e "${TABcyanH}Generating root signing private key: ${g_CA_sign_key}${colorReset}"
        openssl genpkey -algorithm rsa -out "${g_CA_sign_key}" -AES-256-CBC -pkeyopt rsa_keygen_bits:"$g_key_bits"
    fi

    if [[ -f "${g_CA_sign_csr}" ]]; then
        echo -e "${TABcyanH}${g_CA_sign_csr} already exists${colorReset}"
    else
        echo -e "${TABcyanH}Generating root Signing Cert Request${colorReset}"
        openssl req -new -key "${g_CA_sign_key}" -out "${g_CA_sign_csr}" -subj ${SUBJECT}
    fi

    if [[ -f "${g_CA_sign_pem}" ]]; then
        echo -e "${TABcyanH}${g_CA_sign_pem} already exists${colorReset}"
    else
        echo -e "${TABcyanH}Fulfilling root signing cert request${colorReset}"
        openssl x509 -req -in "${g_CA_sign_csr}" -CA "${g_rootCA_pem}" -CAkey ${g_rootCA_key} -out "${g_CA_sign_pem}" -days $days -sha512 -CAcreateserial -subj ${SUBJECT}
        cat "${g_CA_sign_pem}" ${g_rootCA_pem} > "${g_CA_sign_pem}"
    fi
}

################################################################
#
# Create Server Certificate
#
################################################################
function createServerCertificate() {
    local device_name="$1"

    local URL="Casetta.duckdns.org"
    local SUBJECT="/C=IT/ST=Italy/L=Rome/O=LoretoNet/OU=server/CN=${URL}/emailAddress=loreto.n@gmil.com"
    local host_key="${g_hosts_DIR}/${device_name}.key"
    local host_csr="${g_hosts_DIR}/${device_name}.csr"
    local host_crt="${g_hosts_DIR}/${device_name}.crt"
    local host_chain_crt="${g_hosts_DIR}/${device_name}_chain.crt"

    if [[ ! -f "${host_key}"  || ${g_FORCE} == 'force' ]]; then
        echo -e "${TABcyanH}Generating host private key: ${host_key}${colorReset}"
        openssl genrsa -out "${host_key}" 2048
    else
        echo -e "${TABcyanH}${host_key} already exists${colorReset}"
    fi

    if [[ ! -f "${host_csr}"  || ${g_FORCE} == 'force' ]]; then
        echo -e "${TABcyanH}Generating host cert request: ${host_csr} ${colorReset}"
        openssl req -new -key "${host_key}" -out "${host_csr}" --subj $SUBJECT
        openssl req -in "${host_csr}"  -text
    else
        echo -e "${TABcyanH}${host_csr} already exists${colorReset}"
    fi

    if [[ ! -f "${host_crt}"  || ${g_FORCE} == 'force' ]]; then
        echo -e "${TABcyanH}Fulfilling host cert request: ${host_chain_crt}${colorReset}"
        openssl x509 -req -in ${host_csr} -CA ${g_rootCA_pem} -CAkey ${g_rootCA_key} -out ${host_crt} -days 365 -sha512 -CAcreateserial --subj $SUBJECT
    else
        echo -e "${TABcyanH}${host_crt} already exists${colorReset}"
    fi

    if [[ ! -f "${host_chain_crt}"  || ${g_FORCE} == 'force' ]]; then
        cat ${g_CA_sign_pem} ${host_crt} > "${host_chain_crt}"
    else
        echo -e "${TABcyanH}${host_chain_crt} already exists${colorReset}"
    fi

}



#############################################
#
#############################################
function parseInput() {
    function syntax() {
        echo
        echo '  arguments:'
        echo '     domain.name (mandatory)'
        echo '     --force to override domain certificates'
        echo
        echo '  Ex.: loreto.duckdns.org --force'
        echo
        exit
    }

    local args=$*
    echo "${TAB}command line: $args"
    [[ -z $args ]] && syntax 1 && exit 1
    g_FORCE=''


    # check rhe word and remove it from args
    word='--force';    [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_FORCE='force'

    g_Args=$(echo $args) # remove BLANKs
    echo "${TAB}input args:   $g_Args"
    echo
}


##################################################
#               M A I N
##################################################
    parseInput "$*"
    domain="$1"
    ca_name='loretoCA'
    setEnvars $ca_name
    echo -e "${TAByellowH}CA name:   $g_CA_NAME"
    echo
    createRootCA
    echo
    createRootCA_signed
    echo
    createServerCertificate "$domain"
    echo


