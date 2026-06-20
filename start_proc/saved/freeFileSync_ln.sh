#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 10-11-2025 17.32.26
#

# fa partire sublime impostando le variabili di ambiente in modo che
# posso utilizzare alt-f8 su linee che contengono variabilie
# source "${HOME}/lnprofile/init/setLoretoEnvironment" "$0" "variables" >/dev/null

# ln_hostname=$(hostname -s)
# ln_hostnameLC=${hostname_lc}

source "${ln_SET_LORETO_ENVIRONMENT}"

# export ulauncher_local=${HOME}/.config/ulauncher;                  export ulauncher_copy=${HOME}/lnprofile/appls_Config/${hostname_lower}/ulauncher
# export sublime_local=${HOME}/.config/sublime-text/Packages/User;   export sublime_copy=${HOME}/lnprofile/appls_Config/${hostname_lower}/sublime-text/Packages/User
# export freefilesync_local=${HOME}/.config/FreeFileSync;            export freefilesync_copy=${HOME}/lnprofile/appls_Config/${hostname_lower}/FreeFileSync
# export doublcecmd_local=${HOME}/.config/doublecmd;                 export doublcecmd_copy=${HOME}/lnprofile/appls_Config/${hostname_lower}/doublecmd

# export lndata_local=${HOME}/lnData

/usr/local/bin/freefilesync