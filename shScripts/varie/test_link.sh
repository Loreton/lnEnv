#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Version ......: 07-12-2020 16.07.59
#
# cd /home/pi/PiProd/shProc && ff="wrLog.sh" && chmod +w $ff && cp _devel/$ff . && chmod -w $ff && cd -
#
###############################################
LORETO_RC="${HOME}/filu/lnEnv/init/main/Loretorc"
loretorc_path="$(readlink -fvs  "$HOME/.loretorc")"
# if [[ ! -fs $loretorc_path ]]; then
if [[ ! "$loretorc_path" == "$LORETO_RC" ]]; then
    ln -sf "$LORETO_RC" "$HOME/.loretorc"
else
    echo "...sono uguali"
fi