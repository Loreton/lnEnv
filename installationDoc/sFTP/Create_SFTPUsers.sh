#!/bin/bash

    # sudo groupadd sftp_users -gid 1201
    # sudo useradd  extuser --uid 1201 -g extgroup -s /sbin/nologin -d /dev/null


# https://www.techrepublic.com/article/how-to-set-up-an-sftp-server-on-linux/

# Create the SFTP group and user
# Now we're going to create a special group for SFTP users. This is done with the following command:
    sudo addgroup sftp_users  -gid 1202

# Now we're going to create a special user that doesn't have regular login privileges,
#   but does belong to our newly created sftp_users group. What you call that user is up to you.
#   The command for this is:
    USERNAME='laura';
    USERNAME='silvia';
    sudo useradd ${USERNAME} --uid 1012 -g sftp_users -d /data -s /sbin/nologin ; Laura.1998
    sudo useradd ${USERNAME} --uid 1012 -g lesla -d /home/${username} -s /bin/bash ; Laura.1998

# Next, give the new user a password.
# This password will be the password the new users use to log in with the sftp command.
# To set up the password, issue the command:
    passwd ${USERNAME}

# Where USERNAME is the name of the user created above.

# Create the new user SFTP directory
# Now we're going to create an upload directory, specific to the new user, and then give the directory the proper permissions.
# This is handled with the following commands:

    user_dir="/mnt/Laura"
    sudo mkdir -p ${user_dir}/data
    sudo chown -R root:sftp_users ${user_dir}
    sudo chown -R ${USERNAME}:sftp_users /${user_dir}/data
    sudo chmod 2750 ${user_dir}   # https://raspberrypi.stackexchange.com/questions/112296/sftp-match-multiple-users


# Configure sshd
# Open up the SSH daemon configuration file with the command:

    sudo vi /etc/ssh/sshd_config

# At the bottom of that file, add the following:
    Match Group sftp_users
    ChrootDirectory /mnt/Toshiba_1TB_LnDisk/sFTP/%u
    ForceCommand internal-sftp

# Save and close that file. Restart SSH with the command:
    systemctl restart sshd