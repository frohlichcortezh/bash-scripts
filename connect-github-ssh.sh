#!/usr/bin/env bash
# https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
# https://help.github.com/en/github/authenticating-to-github/checking-for-existing-ssh-keys

source ../bash-scripts/functions.sh

    email=$1

    inputEmail() {
        f_dialog_input "Please inform the e-mail adress that will be associated with your ssh key: "
        if [ $? -eq 0 ]; then email=$f_dialog_RETURNED_VALUE; fi
        
        while [ "$email" = "" ]; do read email; done
    }

    if [ "$email" = "" ]; then
        inputEmail
    fi

    ssh_keygen() {
        ssh-keygen -t rsa -b 4096 -C "$email"    
    }

    ssh_key_menu() {
        dialog_menu_array=('' '●─ Choose one of the existing keys ')
        dialog_menu_array+=($(ls ~/.ssh/*.pub) '')
        dialog_menu_array+=('Add new' ': Create a new ssh key and use it.')
        f_dialog_menu        
        
        if [ "$f_dialog_RETURNED_VALUE" = "Add new" ]; then
            ssh_keygen
        else
            file_key=$f_dialog_RETURNED_VALUE
        fi
    }

    if [ -d "~/.ssh" ]; then
        ssh_key_menu
    else
        ssh_keygen
    fi    

    file_key=`f_readP "What's the file name of your key ? [Leave empty to default ~/.ssh/id_rsa.pub] :" "~/.ssh/id_rsa.pub"`

    # start the ssh-agent in the background
    eval $(ssh-agent -s)
    
    ssh-add "$file_key"
    # ToDo use f_install
    sudo apt install xclip
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