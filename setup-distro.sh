#!/bin/bash

source functions.sh

    G_PROGRAM_NAME="Setup Distro"

    stranger='stranger'

    f_dialog_input "Hello, ${stranger}. We'll be setting up your linux distro. \nHow'd you like to be called ?"

    if [ $? -gt 0 ]; then exit 1; fi

    stranger=$f_dialog_RETURNED_VALUE

    f_dialog_msg "Ok, ${stranger}. You might be asked for your password to run admin commands ..."

    now=`date +%F`
    last_apt_update="$(date -d "1970-01-01 + $(stat -c '%Z' /var/lib/apt/periodic/update-success-stamp ) secs" '+%F')"

    days_since_last_apt_update=$(f_dateDiff $now $last_apt_update)
    # ToDo re-check result after clean install
    if (( $(echo "$days_since_last_apt_update > 1" | bc -l) )); then
        sudo apt-get update    
    fi

    # Getting lsb-release to have information on distro
    # ToDo find another way to know which distro before installing 
    
    f_app_install sqlite3 lsb-core git xclip -y

    source /etc/lsb-release
    RELEASE=$DISTRIB_RELEASE
    CODENAME=$DISTRIB_CODENAME    

    repo_added=0

    if ! f_repository_is_installed "universe"; then
        sudo apt-add-repository universe
        repo_added=1
    fi

    if ! f_repository_is_installed "refind"; then
        sudo apt-add-repository ppa:rodsmith/refind
        repo_added=1
    fi

    if [ repo_added=1 ]; then
        sudo apt-get update
    fi
    
    f_app_install apt-transport-https dirmngr pcregrep python3 python3-pip fish quake -y

    f_dialog_yes_no "Would you like to setup git ?"

    if [ $? -eq 0 ]; then 
        source setup-git.sh
    fi

    source setup-terminal.sh
