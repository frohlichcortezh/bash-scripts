#!/bin/bash
# https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
# https://help.github.com/en/github/authenticating-to-github/checking-for-existing-ssh-keys

source functions.sh

email=$1

if [ "$email" = "" ]; then
    email=`f_readP "Please inform the e-mail adress that will be associated with your ssh key: "`
    while [ "$email" = "" ]; do read email; done
fi

ssh_keygen() {
    ssh-keygen -t rsa -b 4096 -C "$email"    
}

if [ -d "~/.ssh" ]; then
    f_printLn "These are your current ssh keys."    
    ls -al ~/.ssh
    
    f_readYesNo "Would you like to add a new one ? (y/N)"
    if [ "$yes_no" = "Y" ]; then
        ssh_keygen
    fi
else
    ssh_keygen
fi

# start the ssh-agent in the background
eval $(ssh-agent -s)

file_key=`f_readP "What's the file name of your key ? [Leave empty to default ~/.ssh/id_rsa.pub] :" "~/.ssh/id_rsa.pub"`

ssh-add "$file_key"
xclip -sel clip < "$file_key"

f_printLn "If you're running this on a X server your SSH key should be in your clipboard."
f_printLn "Otherwise copy it from below"
cat "$file_key"
f_printLn "You must go now to your GitHub account to add it."
f_printLn "1. In the upper-right corner of any page on GitHub, click your profile photo, then click Settings."
f_printLn "2. In the user settings sidebar, click SSH and GPG keys. "
f_printLn "3. Click New SSH key or Add SSH key. "
f_printLn "4. In the ""Title"" field, add a descriptive label for the new key. For example, if you're using your personal computer, you might call this key ""My PC""."
f_printLn "5. Paste your key into the ""Key"" field. "
f_printLn "6. Click Add SSH key."
f_printLn "7. If prompted, confirm your GitHub password. "

f_printLn "If you can't find any of the information on these steps, you might try to check https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account"

yes_no="N"

while [ "$yes_no" != "Y" ]; do read f_readYesNo "Did you add it ? (y/N)"; done

f_printLn "Ok then. If you've succesfully added your key will be testing it."
f_printLn "Check https://help.github.com/en/github/authenticating-to-github/testing-your-ssh-connection to see if the fingerprint showed below matches the official one."
f_printLn "If it does your safe to type yes and connect. "
f_printLn "You should then see a message with your username. "

ssh -T git@github.com