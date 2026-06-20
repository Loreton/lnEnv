#!/bin/bash
# come input chiede due interfacce di rete ... eth0 wlan1
#
# updated by ...: Loreto Notarantonio
# Date .........: 27-08-2023 17.26.42
#
# ref: https://gist.github.com/kevinadi/96090f6f9973ff8c2d019bbe0d9a0f70
#
##################################################
# for generating your root CA private key and cert
##################################################


#=====================================
#=
#=====================================
function setEnvars() {
    local ca_name="$1"
    source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" # >/dev/null

    g_prj_dir=$(dirname $scriptDir)
    g_prj_dir=$scriptDir
    set -u

    CA_DIR="${g_prj_dir}/${ca_name}-CA"
    root_DIR="${CA_DIR}/root";       mkdir -p $root_DIR

    g_key_bits='4096'

}


##################################################
# for generating your root CA private key and cert
##################################################
function createRootCA() {
    local ca_name="$1"
    local ca_cert_expire_days="36660" # 100 anni

    # in modo a aggiungere solo l'ext
    rootCA="${root_DIR}/${ca_name}"

    # Generate self signed root CA cert
    SUBJECT="/C=AU/ST=NSW/L=Sydney/O=MongoDB/OU=root/CN=`hostname -f`/emailAddress=kevinadi@mongodb.com"
    SUBJECT="/C=IT/ST=Italy/L=Rome/O=LoretoNet/OU=root/CN=Loreto.root.CA/emailAddress=loreto.n@gmil.com"
    if [[ -f "${rootCA}.key" ]]; then
        echo -e "${TABcyanH}${rootCA}.key already exists${colorReset}"
    else
        # echo
        # echo -e "${TABcyanH}Generating root CA private key: ${rootCA}.key ${colorReset}"
        CMD="openssl req -nodes -x509 -days "${ca_cert_expire_days}" -newkey rsa:2048 -keyout "${rootCA}.key" -out "${rootCA}.crt" -subj ${SUBJECT}"
        @_esegui "Generating root CA private key: ${rootCA}.key" "$CMD"
    fi

}


################################################################
#
# Create Server Certificate
#
################################################################
function createServerCertificate() {
    # local service_name="$1"
    local server_name="$1"
    server_DIR="${CA_DIR}/${server_name}";       mkdir -p $server_DIR

    # in modo a aggiungere solo l'ext
    server="${server_DIR}/${server_name}"

    if [[ ! -f "${server}.key"  || ${g_FORCE} == 'true' ]]; then
        # Generate server cert to be signed
        local SUBJECT="/C=IT/ST=Italy/L=Rome/O=LoretoNet/OU=server/CN=${server_name}/emailAddress=loreto.n@gmil.com"
        CMD="openssl req -nodes -newkey rsa:2048 -keyout ${server}.key -out "${server}.csr" -subj $SUBJECT"
        @_esegui "Generating host private key: ${server}.key" "$CMD"

        # Sign the server cert
        CMD="openssl x509 -req -in "${server}.csr" -CA "${rootCA}.crt" -CAkey "${rootCA}.key" -CAcreateserial -out "${server}.crt""
        @_esegui "Sign the server cert: ${server}.crt" "$CMD"

        # Create server PEM file
        CMD="cat "${server}.key" "${server}.crt" > "${server}.p12""
        @_esegui "Create server p12 file: ${server}.p12" "$CMD"

    else
        echo -e "${TABcyanH}${server}.key already exists${colorReset}"
    fi
}



#############################################
#
#############################################
function @_esegui() {
    CMD_DESCR=$1
    cmd=$2

    echo -e "${TABcyanH} ${CMD_DESCR}${colorReset}"
    echo -e "${TABpurpleH} [$g_DRY_RUN]$yellowH: $cmd ${colorReset}"
    if [[ "$g_EXECUTE" -eq "1" ]]; then
        eval $cmd
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && echo "rcode=$rCode" && exit $rCode
    fi
    echo
    CMD_DESCR=
}


#############################################
# https://stackabuse.com/how-to-parse-command-line-arguments-in-bash/
# called by:     parseInput "$@"
#############################################
function parseInput() {
    help() {
        echo "Usage: $(basename $0)
                [ -ca | --ca_name ]     CA name
                [ -d | --domain ]       domain_name/server_name
                [ --force ]             force new certificate creation if exists
                [ --go ]                NOT dry-run
                [ --copy ]              copy server certificate+key to loreto_etc_dir
                [ -h | --help  ]        this help"
        exit 2
    }

    SHORT='ca:,d:,h'
    LONG='domain:,ca_name:,copy,force,go,help'
    VALID_OPTS=$(getopt -a -n ParseInput --options $SHORT --longoptions $LONG -- "$@")

    N_ARGUMENTS=$# # Returns the count of arguments that are in short or long options
    [[ "$N_ARGUMENTS" -eq 0 ]] && help
    g_DomainName=
    g_EXECUTE=0
    g_FORCE=0
    g_COPY=0
    g_DRY_RUN='--dry-run'

    eval set -- "$VALID_OPTS"
    while :; do
        case "$1" in
            -d | --domain )
                g_DomainName="$2"
                shift # past argument
                shift # past value
                ;;

            -ca | --ca_name )
                g_CA_Name="$2"
                shift # past argument
                shift # past value
                ;;

            -h | --help)
                help
                ;;

            --force)
                g_FORCE='true'
                shift 1
                ;;

            --copy)
                g_COPY=1
                shift 1
                ;;

            --go)
                g_EXECUTE=1
                g_DRY_RUN='execute'
                shift 1
                ;;

            --)
                shift 1
                break
                ;;

            *)
                echo "Unexpected option: $1"; help; ;;
        esac
    done

    _test=${g_DomainName:?"domain_name is mandatory argument"}
    _test=${g_CA_Name:?"ca_name is mandatory argument"}
}


##################################################
#               M A I N
##################################################
    parseInput "$@"
    echo -e "${TAByellowH}CA name:      $g_CA_Name"
    echo -e "${TAByellowH}domain name:  $g_DomainName"
    echo
    setEnvars "$g_CA_Name"
    echo
    createRootCA "$g_CA_Name"
    echo
    createServerCertificate "$g_DomainName"
    echo

    loreto_cert_dir='/etc/loreto/cert'
    [[ ${g_COPY} -eq 1 ]] && g_EXECUTE=1 && g_DRY_RUN='execute' || g_EXECUTE=0
    @_esegui "creazione directory"      "sudo mkdir -p $loreto_cert_dir"
    @_esegui "copy server certificate"  "sudo cp "${server}.key" /etc/loreto/cert/"
    @_esegui "copy server key"          "sudo cp "${server}.p12" /etc/loreto/cert/"

