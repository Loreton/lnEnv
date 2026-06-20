#!/bin/bash


# ##############

# this 3 checks (if) are not necessary but should be convenient
if [ "$1" == "-h" ]; then
  echo "Usage: $(basename $0) channel_name \"text message\""
  exit 0
fi


if [[ -z "$1" || -z "$2" ]]; then
    echo "    Usage: $(basename $0) channel_name \"text message\""
    exit 0
fi
channel_name=$1; shift 1

if [ "$#" -ne 1 ]; then
    echo "    ERROR: If the second argument contains spaces put it on quotes"
    exit 0
fi

source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "telegram_$channel_name" >/dev/null
    : ' ritorna le seguenti variabili:
            GROUP_ID, ,
            BOT_TOKEN,
    '

set -u

# per avere info ....
# CMD="https://api.telegram.org/bot${BOT_TOKEN}/getUpdates"; echo $CMD; exit
echo "    GROUP_ID:   $GROUP_ID"
echo "    BOT_TOKEN:  $BOT_TOKEN"

DATE=$(date +"%Y-%m-%d %H:%M:%S")
message="$DATE: $1"
CMD="curl -s --data text=\"$message\" --data chat_id=$GROUP_ID https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"
echo $CMD
eval $CMD >/dev/null
echo "rcode: $?"