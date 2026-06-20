#!/bin/bash

sudo addgroup ftpgroup -gid 1200
sudo useradd  ftpuser --uid 1200 -g ftpgroup -s /sbin/nologin -d /dev/null




user='Loreto'
FTP_DIR='/mnt/Toshiba_1TB_LnDisk/FTP/$user'
# FTP Home Directory, Virtual User, and User Group For instance, make a new directory named FTP for the first user:
    sudo mkdir ${FTP_DIR}  #  by Loreto:  13-06-2020 07.53.15
# Make sure the directory is accessible for ftpuser:
    sudo chown -R ftpuser:ftpgroup ${FTP_DIR} #  by Loreto:  13-06-2020 07.54.45

# Create a virtual user named $user,
# mapping the virtual user to ftpuser and ftpgroup setting home directory /home/pi/FTP, and record password of the user in database:
    sudo pure-pw useradd $user -u ftpuser -g ftpgroup -d ${FTP_DIR} -m

# A password of that virtual user will be required after this command line is entered. And next, set up a virtual user database by typing:
    sudo pure-pw mkdb


# Restart the program:
    sudo service pure-ftpd restart




