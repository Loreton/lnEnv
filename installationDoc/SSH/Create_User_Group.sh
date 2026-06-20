#!/bin/bash

# create group
    # sudo addgroup lesla      --gid 1101

# create user silvia
    # ID=1012;user='laura'; sudo addgroup ${user}  --gid ${ID}; sudo adduser  ${user} --uid ${ID} --gid ${ID}; sudo adduser {user} sftp_users


# add user to group
    # sudo adduser pi lesla


set -u  # Treat unset variables as an error when substituting.

silvia_ID=1011
laura_ID=1012

function getGroupID() {
    [[ "$group_name" == "lesla" ]] &&       GID=1101
    [[ "$group_name" == "sftp_users" ]] &&  GID=1102
    echo $GID
}

function create_Lesla_User() {
    username=$1
    id=$2
    group_name='lesla'
    sudo addgroup ${username} --gid ${ID}
    sudo useradd  ${username} --uid ${ID} -g ${group_name}
    sudo chown -R ${username}:${group_name} /home/${username}
}

function create_sFtp_User() {
    username=$1
    id=$2
    group_name='sftpuser'
    sudo addgroup ${username} --gid ${ID}
    sudo useradd  ${username} --uid ${ID} -g ${group_name}
    sudo chown -R ${username}:${group_name} /home/${username}
}


function createUser_02() {
    username=$1
    id=$2
    gid=$id
    sudo addgroup ${username} --gid ${ID}
    sudo adduser  ${username} --uid ${ID} --gid ${ID}
}

# less /etc/group
function createGroup() {
    group_name=$1
    gid=$2
    sudo addgroup ${group_name} --gid ${gid}
}


################ MAIN
    group='lesla';       echo sudo addgroup $group --gid $(getGroupID)
    group='sftp_users'; echo sudo addgroup $group --gid $(getGroupID)
    # createGroup         sftp_users  1102
    # createGroup         lesla 1101
    # createLeslaUser     laura 1012
    # sudo adduser    laura sftp_users
    # createLeslaUser      silvia 1013
    # sudo adduser    silvia sftp_users