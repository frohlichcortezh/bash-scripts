#!/usr/bin/env bash
# https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
# https://help.github.com/en/github/authenticating-to-github/checking-for-existing-ssh-keys

source ../bash-scripts/lib/functions.sh

    email=$1

    inputEmail() {
        f_dialog_input "Please inform the e-mail adress that will be associated with your ssh key: "
        if [ $? -eq 0 ]; then email=$f_dialog_RETURNED_VALUE; fi
        
        while [ "$email" = "" ]; do read email; done
    }

    #ToDo if email is not passed check if git email was already set up "git config --global user.email"
    # if there's a value, use it. If there's not, set up at the end

    if [ "$email" = "" ]; then
        inputEmail
    fi

    #ToDo check if git user.name was set up
    # Prompt to set up user name and give it a default value from git user.name config

    # https://docs.github.com/en/get-started/getting-started-with-git/setting-your-username-in-git
    # ToDo set git username and email

    ssh_keygen() {
        # ToDo give option for which algo to use
        ssh-keygen -t ed25519 -C "$email"
        #ssh-keygen -t rsa -b 4096 -C "$email"    
    }

    ssh_key_menu() {
        dialog_menu_array=('' '●─ Choose one of the existing keys ')
        dialog_menu_array+=($(ls $HOME/.ssh/*.pub) '')
        dialog_menu_array+=('Add new' ': Create a new ssh key and use it.')
        f_dialog_menu        
        
        if [ "$f_dialog_RETURNED_VALUE" = "Add new" ]; then
            ssh_keygen
        else
            file_key=$f_dialog_RETURNED_VALUE
        fi
    }

    if [ -d "$HOME/.ssh" ]; then
        ssh_key_menu
    else
        ssh_keygen
    fi    

    #file_key=`f_readP "What's the file name of your key ? [Leave empty to default $HOME/.ssh/id_rsa.pub] :" "$HOME/.ssh/id_rsa.pub"`
    file_key=`f_readP "What's the file name of your key ? [Leave empty to default $HOME/.ssh/id_ed25519.pub] :" "$HOME/.ssh/id_ed25519.pub"`
    
    f_printLn "File key:"
    f_printLn $file_key

    chmod 400 $file_key
    echo "${file_key/.pub/}"
    chmod 400 "${file_key/.pub/}"
    
    # start the ssh-agent in the background
    eval $(ssh-agent -s)
    
    ssh-add $file_key
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

    #while [ "$yes_no" != "Y" ]; do read f_readYesNo "Did you add it ? (y/N)"; done
    f_readP "[Enter] once you added it"

    f_printLn "Ok then. If you've succesfully added your key will be testing it."
    f_printLn "Check https://help.github.com/en/github/authenticating-to-github/testing-your-ssh-connection to see if the fingerprint showed below matches the official one."
    f_printLn "If it does your safe to type yes and connect. "
    f_printLn "You should then see a message with your username. "

    ssh -T git@github.com
