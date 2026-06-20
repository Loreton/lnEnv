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

message="$DATE:\n\r $1"
# message="{
#     'DATE:' ${DATE},
#     'msg:' ${1}
# }"

# TODO: Specify the recipient's number (NOT the gateway number) on line 10.
read -r -d '' jsonPayload << _EOM_
  {
    'DATE': ${DATE},
    'msg': ${1},
    "message": "Howdy! Is this exciting?",
    'DATE': ${DATE},
    'msg': ${1},
    "message": "Howdy! Is this exciting?",
  }
_EOM_


reply=$(cat <<-_EOF
{
    "inline_keyboard": [
        [
            {
                "text": "Button1",
                "callback_data": "lt"
            },
            {
                "text": "Button1",
                "callback_data": "rt"
            }
        ],
        [
            {
                "text": "Button3",
                "callback_data": "ls"
            }
        ]
    ]
}
_EOF
)


# https://gist.github.com/dideler/85de4d64f66c1966788c1b2304b9caf1
# OK: curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$(echo -e "Host: `hostname`\nUser: $USER\nHost: CIAO")"
URL="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"
CHAT_ID="${GROUP_ID}"

messaggio=$(echo -e "\
Host: $(hostname)
User: "$USER"
host: "CIAO3" ")

JSON_FMT='{"host":"%s","user":"%s","msg":"%s"}\n'
JSON_STRING=$(printf "$JSON_FMT" "$(hostname)" "$USER" "CIAO4")
echo $JSON_STRING

# multi-line NON funziona
# JSON_STRING="{\
# \"host\":$(hostname),
# \"user\":${USER},
# \"msg\":${1}
# }"



# DATE=$(date +"%Y-%m-%d %H:%M:%S")
# messaggio=$(echo -e "\
# Host: $(hostname)
# User: $USER
# DATE: $DATE
#     ")

# msg: "$*"\

# message="$DATE: $1"
# CMD="curl -s --data text=\"$message\" --data chat_id=$GROUP_ID https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"
# echo $CMD
# eval $CMD >/dev/null
# echo "rcode: $?"
# echo
# echo $messaggio
# echo
CMD="curl -s -X POST $URL -d chat_id=$CHAT_ID -d text=\"$JSON_STRING\""
echo $CMD
eval $CMD >/dev/null
echo "rcode: $?"
exit


