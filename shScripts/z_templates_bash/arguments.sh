#!/bin/bash

# updated by ...: Loreto Notarantonio
# Date .........: 19-06-2023 12.15.34


echo
echo "# arguments called with ---->  ${@}     "
echo "# \$1 ---------------------->  $1       "
echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo "# my name ------------------>  ${0##*/} "
echo "# my name ------------------>  $(basename -- "$0")"
echo "# my name ------------------>  "; printf '$0 is: %s\n$BASH_SOURCE is: %s\n' "$0" "$BASH_SOURCE"
echo
exit

# ------------- CALLED ------------- #

# Notice on the next line, the first argument is called within double,
# and single quotes, since it contains two words

#  /home/loreto/lnprofile/sh_scripts/z_templates_bash/arguments.sh "'hello there'" "'loreto'"

# ------------- RESULTS ------------- #

# arguments called with --->  'hello there' 'william'
# $1 ---------------------->  'hello there'
# $2 ---------------------->  'william'
# path to me -------------->  /misc/shell_scripts/check_root/show_parms.sh
# parent path ------------->  /misc/shell_scripts/check_root
# my name ----------------->  show_parms.sh

# ------------- END ------------- #