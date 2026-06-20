#!/bin/bash
# prevede di essre lanciato come root
userID=$1
homeDir=$2

if [ "$homeDir" == "-" ]; then
    baseDIR="/home/$userID/.ssh"
else
    baseDIR="$homeDir/.ssh"
fi

pubKey="$baseDIR/id_rsa.pub"
auth_Keys="$baseDIR/authorized_keys"
if [ ! -r "$pubKey" ]; then
    echo "$pubKey NOT found or NOT readable"
    mkdir "$baseDIR"
    chown "$userID:$userID" "$baseDIR"
    chmod 700 "$baseDIR"
    ssh-keygen -t rsa -b 1024 -N "" -f "$baseDIR/id_rsa"
    cd $baseDIR
fi



NewKEY='ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIBuRkIOoAFJ84oJw+QhZevde/BiFvSlpvJf1SO3hNMJwOv/hCzA4S2l9lYT8VqtZw2JnyAs3qBId5O7jyT52BTmNfdWs2zpY4mtx8TMbY8O4GIg/0MxzaV/IZsjgfmVUONoxOn9eRfTO55+IqjuN5KgPic0VIXx9gk7TEeWdLd7pQ== rsa-key-20080723 by FG'
echo "$NewKEY" >>$auth_Keys
chmod 600 "$auth_Keys"
chown -R "$userID:$userID" "$baseDIR"