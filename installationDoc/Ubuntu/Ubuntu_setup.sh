#!/bin/bash


function Ulauncher() {
    # https://www.omgubuntu.co.uk/2019/08/best-app-launcher-for-ubuntu-linux
    # https://ulauncher.io
    sudo add-apt-repository ppa:agornostal/ulauncher && sudo apt update && sudo apt install ulauncher
    
}

function vivaldi() {
    # https://www.linuxcapable.com/how-to-install-vivaldi-browser-on-ubuntu-22-04-lts/
    sudo apt update
    sudo apt install software-properties-common apt-transport-https wget ca-certificates gnupg2 ubuntu-keyring -y

    # import GPGkey
    wget -O- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vivaldi.gpg

    # import and add repository
    echo deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi.gpg] https://repo.vivaldi.com/archive/deb/ stable main | sudo tee /etc/apt/sources.list.d/vivaldi.list

    sudo apt update && sudo apt install vivaldi-stable -y
    # vivaldi --version
}





# key gen
function sshfs() {
    return 0
    sudo apt update && sudo apt install sshfs

    # mp='/mnt/lnpi31' && sudo mkdir $mp && sudo sshfs -o allow_other,default_permissions pi@192.168.1.31:~/ $mp
    # mp='/mnt/lnpi23' && sudo mkdir $mp && sudo sshfs -o allow_other,default_permissions pi@192.168.1.23:~/ $mp
    # mp='/mnt/lnpi22' && sudo mkdir $mp && sudo sshfs -o allow_other,default_permissions pi@192.168.1.22:~/ $mp

    # sudo umount /mnt/droplet
}


# key gen
function sshgen() {
    return 0
    ssh-keygen -o -a 100 -t ed25519 -f $HOME/.ssh/id_ed25519 -C "aspire5750g.ed25519"
    ssh-keygen -t rsa -b 2048 -f $HOME/.ssh/id_rsa -C "aspire5750g.rsa"
}

function others() {
    return 0
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
    sudo apt install gnome-software gnome-software-plugin-flatpak flatpak
}

function sysUpdate() {
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
}

function network_rename_interfaces() {
    # https://askubuntu.com/questions/1317036/how-to-rename-a-network-interface-in-20-04
    lshw -C network # display network interfaces
    
}

########################################################
#           M A I N
########################################################
    sudoers

    sysUpdate

    ln -sf /media/loreto/LnDisk/Filu/LnDisk/GIT-REPO/ /home/loreto
    findmnt / -o UUID # get UUID of root disk

# ssh server
    sudo apt install openssh-server -y

    sshgen

    sshfs

# make a r/o backup of your sshd_config:
    # bkup_file='/etc/ssh/sshd_config.factory-defaults' && sudo cp /etc/ssh/sshd_config $bkup_file && sudo chmod a-w $bkup_file

# gParted
    sudo apt install gparted -y

# PartitionManager
    sudo apt install partitionmanager -y # "KDE Partition Manager" via software intallation

# Telegram
    sudo apt install telegram-desktop -y
    sudo snap install telegram-desktop




# Sublime-text
    sudo snap install sublime-text --classic

    sysUpdate

# ubuntu release:
    lsb_release -a





    # - pip3 install pyaml
    # - pip3 install python-benedict
    # - pip3 install ssh2-python



exit

IPv6:
    ref: https://linuxconfig.org/how-to-disable-ipv6-address-on-ubuntu-18-04-bionic-beaver-linux
    check: ip a
    temporary:
        - sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
        - sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

    permanent:
        sudo vi /etc/sysctl.conf
        ... add the following lines
            - net.ipv6.conf.all.disable_ipv6=1
            - net.ipv6.conf.default.disable_ipv6=1
        oppure forse il seguente comando lo scrive per me
            sudo sysctl -p /etc/sysctl.conf



sudo umount /mnt/droplet






Youtube problem:
    1:
        killall pulseaudio; rm -r ~/.config/pulse/*
        pulseaudio -k
    2:
        sudo apt-get install ffmpeg

    3:
        sudo apt install ubuntu-restricted-extras

        https://help.ubuntu.com/stable/ubuntu-help/video-sending.html.en
        Disable Hardware Acceleration on browser
