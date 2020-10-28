#!/usr/bin/env bash

NEW_HOSTNAME=$(whiptail --inputbox "Please enter a hostname" 20 60 "$CURRENT_HOSTNAME" 3>&1 1>&2 2>&3)

if [ $? -eq 0 ]; then
    echo $NEW_HOSTNAME > /etc/hostname
    sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts
    ASK_TO_REBOOT=1
fi

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install git fish -y

mkdir $HOME/dev
# https://github.com/snorre-k/musicbox

cd $HOME/dev
git clone https://github.com/snorre-k/musicbox.git
cd musicbox/scripts
source start_install.sh