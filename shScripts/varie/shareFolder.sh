#!/bin/bash




function createLink() {
    local user=$1
    local group=$2
    local link_name=${user}_disk
    cd /home/$user
    sudo ln -sf ${g_MountPoint}/${useer} $link_name
    sudo chown ${user}:${group} $link_name
}




cd /media
sudo mkdir /pi
sudo chown pi:lesla pi

g_MountPoint='/media/pi/LN1TB_31/sFTP'
createLink silvia lesla
createLink elena lesla
createLink ale lesla
createLink laura lesla

sudo passwd silvia remote.sftp
sudo passwd elena remote.sftp
sudo passwd laura remote.sftp
sudo passwd ale remote.sftp
Nonno.1925