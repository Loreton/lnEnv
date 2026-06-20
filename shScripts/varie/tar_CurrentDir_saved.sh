#!/bin/bash
curr_dir_name="$(basename ${PWD})" # remove extension
cd ..

g_userNAME="$USER"
g_userID=$( id -g $g_userNAME )
g_groupID=$( id -u $g_userNAME )
g_groupNAME=$( id -gn $g_userNAME )


EXCLUDE=
EXCLUDE='--exclude=*/.aMule/copied/* --exclude=*/.aMule/Incoming/* --exclude=*/.aMule/Temp/* --exclude=*/.pio/* --exclude=*/__pycache__/*'

DATE=$(date +'%Y-%m-%d')
HOST_NAME=$(hostname -s)

[[ "$curr_dir_name" == '.ln' ]] && dir_name='lnprofile' || dir_name=$curr_dir_name
# tarFilePath="${HOME}/${dir_name}_${HOST_NAME,,}_${DATE}.tgz"
tarFilePath="${PWD}/${dir_name}_${DATE}.tgz"


echo
echo "creating file: $tarFilePath"
echo
echo "press enter to coninue (ctrl-c to exit)"
read

# Make sure to put --exclude before the source and destination items.
# sudo tar --exclude='/home/pi/PiProd/.git' -czf $tarFile --absolute-names --files-from=$listFiles
cmd="sudo tar --absolute-names ${EXCLUDE} -czvf ${tarFilePath} $curr_dir_name"
echo "executing:\n  $cmd"
sudo tar --absolute-names ${EXCLUDE} -czvf ${tarFilePath} $curr_dir_name
sudo chown ${g_userNAME}:${g_groupNAME} ${tarFilePath}

### test file
tar -tzvf $tarFilePath
echo
echo "$tarFilePath has been created"
echo
echo "command executed:\n  $cmd"