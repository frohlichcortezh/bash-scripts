#!/bin/bash

source functions.sh

stranger='stranger'

f_printLn "Hello, ${stranger}. We'll be setting up your linux distro."
stranger=`f_readP "How'd you like to be called ?"`

f_printLn "Ok, ${stranger}. For this to work out I'll need your name and e-mail address. We'll be using git to launch scripts on your behalf."
f_readYesNo "Are you OK with this ? (y/N) :"

if [ "$yes_no" != "Y" ]; then

    f_printLn "No worries, bye."
    exit

else
    f_printLn "You might be asked for your password to run admin commands ..."

    now=`date +%F`
    last_apt_update="$(date -d "1970-01-01 + $(stat -c '%Z' /var/lib/apt/periodic/update-success-stamp ) secs" '+%F')"

    days_since_last_apt_update=$(f_dateDiff $now $last_apt_update)
    # ToDo re-check result after clean install
    if (( $(echo "$days_since_last_apt_update > 1" | bc -l) )); then
        sudo apt-get update    
    fi

    # Getting lsb-release to have information on distro
    # ToDo find another way to know which distro before installing 
    
    sudo apt-get install lsb-core git xclip -y

    source /etc/lsb-release
    RELEASE=$DISTRIB_RELEASE
    CODENAME=$DISTRIB_CODENAME    

    repo_added=0

    if ! f_apt_repository_installed "universe"; then
        sudo apt-add-repository universe
        repo_added=1
    fi
    if ! f_apt_repository_installed "refind"; then
        sudo apt-add-repository ppa:rodsmith/refind
        repo_added=1
    fi

    if [ repo_added=1 ]; then
        sudo apt-get update
    fi
    
    sudo apt-get install apt-transport-https dirmngr -y

    f_readYesNo "Would you like to setup git ? (y/N) :"

    if [ "$yes_no" = "Y" ]; then
        source setup-git.sh        
    fi
fi
