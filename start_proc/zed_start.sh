#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 03-07-2026 12.12.21
#

applLog="/tmp/zed_start.log"; echo >>$applLog
#- mi serve per variabili che potrebbero essere all'interno di file e voglio che sublime le risolva...
source ${HOME}/filu/lnEnv/.config_secret/loretoVariables.sh   >>$applLog 2>&1

#!/bin/bash
if [[ -d "${ln_ZED_CONFIG_DIR}" ]]; then
    /home/loreto/.local/zed.app/bin/zed --user-data-dir "${ln_ZED_CONFIG_DIR}" "$@"
else
   echo "user-data-dir  ${ln_ZED_CONFIG_DIR} not found!"
fi

