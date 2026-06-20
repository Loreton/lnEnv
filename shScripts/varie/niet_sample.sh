#!/bin/bash
# ---------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 27-08-2023 17.29.31
# ---------------------------------------

# needs pip3 install -U niet

source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" >/dev/null
    : ' ritorna le seguenti variabili:
            GROUP_ID, ,
            BOT_TOKEN,
    '


yaml_file='/home/loreto/lnprofile/secret/yaml/mariadb.yaml'
project=$(niet ".mariadb" $yaml_file)

for el in $project; do
  echo ${el};
done