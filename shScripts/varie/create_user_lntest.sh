#!/bin/bash

#  adduser --group [--gid ID] GROUP
#  addgroup [--gid ID] GROUP
#     Add a user group
#
#  addgroup --system [--gid ID] GROUP
#     Add a system group
#
#  adduser USER GROUP
#     Add an existing user to an existing group

# set -u  # Treat unset variables as an error when substituting.

username="lntest"

:'
Questo comando:
    Crea l’utente
    Crea la sua home directory (/home/nomeutente)
    Imposta la shell predefinita (di solito /bin/bash)
    Chiede una password
    Chiede alcune info opzionali (nome, telefono, ecc.)
'
sudo adduser ${username}

# add to sudo group (facoltativo)
sudo usermod -aG sudo ${username}

# verfity
groups ${username}

# Assicurati che Zsh sia installata:
sudo apt install zsh

# Imposta la shell per il nuovo utente:
sudo chsh -s $(which zsh) ${username}

# Copiare configurazioni iniziali (opzionale)
# sudo cp /etc/skel/.bashrc /home/nomeutente/
sudo cp /etc/.bashrc /home/${username}/
sudo chown ${username}:${username} /home/${username}/.bashrc

# Creare .ssh e autorizzare accesso (opzionale ma utile per SSH)
sudo mkdir /home/${username}/.ssh
sudo cp ~/.ssh/authorized_keys /home/${username}/.ssh/
sudo chown -R ${username}:${username} /home/${username}/.ssh
sudo chmod 700 /home/${username}/.ssh
sudo chmod 600 /home/${username}/.ssh/authorized_keys
