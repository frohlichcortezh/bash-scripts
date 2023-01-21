#!/usr/bin/env bash
# ref https://www.youtube.com/watch?v=WyikHs2Y7bM
# change ssh port
# todo CAT replace getting input from user
$NEW_SSH_PORT = 2222
# nano /etc/ssh/sshd_config

ufw default deny incoming
ufw default allow outgoing
ufw allow $NEW_SSH_PORT
ufw enable

# ToDo ufw enable 80 443 for nginx proxy mananger

$NORMAL_USER = 'jose'
adduser $NORMAL_USER

# ssh don't allow root ssh with password
# todo cat replace
# nano /etc/ssh/sshd_config
# PermitRootLogin no

# add know ssh public key to new user in order to disable access with password
mkdir /home/$USER/.ssh
cd /home/$USER/.ssh

# todo get public key from input
$ssh_key='ssh-ed25519 ....' 
cat $ssh_key >> authorized_keys
chmod 600 authorized_keys

cd ..
chmod 700 .ssh

# make sure you have access to your machine after these changes by trying to log in with a different terminal without leaving the current
# if everything is alright, continue

# todo cat replace
# PubkeyAuthentication yes
# PasswordAuthentication no

# nano /etc/ssh/sshd_config
systemctl restart sshd

apt install fail2ban -y

systemctl enable fail2ban
systemctl start fail2ban

