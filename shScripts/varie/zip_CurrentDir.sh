#!/bin/bash
curr_dir_name="$(basename ${PWD})" # remove extension
cd ..

g_userNAME="$USER"
g_userID=$( id -g $g_userNAME )
g_groupID=$( id -u $g_userNAME )
g_groupNAME=$( id -gn $g_userNAME )


EXCLUDE=
EXCLUDE='--exclude=*/.aMule/copied/* --exclude=*/.aMule/Incoming/* --exclude=*/.aMule/Temp/*'

DATE=$(date +'%Y-%m-%d')
HOST_NAME=$(hostname -s)

[[ "$curr_dir_name" == '.ln' ]] && dir_name='lnprofile' || dir_name=$curr_dir_name
zipFilePath="${HOME}/${dir_name}_${HOST_NAME,,}_${DATE}.zip"
echo
echo "creating file: $zipFilePath"
echo
echo "zip ${EXCLUDE} -ryTo ${zipFilePath} $curr_dir_name"

# Make sure to put --exclude before the source and destination items.
sudo zip ${EXCLUDE} -ryo ${zipFilePath} $curr_dir_name
sudo chown ${g_userNAME}:${g_groupNAME} ${zipFilePath}

### test file
tar -T $zipFilePath
echo
echo "$zipFilePath has been created"
echo