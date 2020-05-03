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

    # Getting lsb-release to have information on distro
    # To-Do find another way to know which distro before installing 
    #sudo apt-get update && sudo apt-get install lsb-core -y

    source /etc/lsb-release
    RELEASE=$DISTRIB_RELEASE
    CODENAME=$DISTRIB_CODENAME

    now=`date +%F`
    last_apt_update="$(date -d "1970-01-01 + $(stat -c '%Z' /var/lib/apt/periodic/update-success-stamp ) secs" '+%F')"

    days_since_last_apt_update=$(f_dateDiff $now $last_apt_update)
    if (( $(echo "$days_since_last_apt_update > 1" | bc -l) )); then
        sudo apt-get update    
    fi
    
    sudo apt-get install git xclip -y
        
    gitUserName=`git config --get user.name`
    gitUserEmail=`git config --get user.email`

    readGitUserName() {
        gitUserName=`f_readP "What's your name ? [This will be use as your git user name] :"`

        # ToDo - Improve validation for white spaces and invalid char
        while [ "$gitUserName" = "" ]; do read gitUserName; done
    }

    if [ "$gitUserName" != "" ]; then
        f_readYesNo "Your git user.name is already set to $gitUserName. Would you like to change it ? (y/N)"
        if [ "$yes_no" = "Y" ]; then
            readGitUserName
        fi
    else
        readGitUserName
    fi

    readGitUserEmail() {
        gitUserEmail=`f_readP "What's your e-mail ? [This will be use as your git user email] :"`

        # ToDo - Improve validation for white spaces and invalid char
        while [ "$gitUserEmail" = "" ]; do read gitUserEmail; done
    }

    if [ "$gitUserEmail" != "" ]; then
        f_readYesNo "Your git user.email is already set to $gitUserEmail. Would you like to change it ? (y/N)"
        if [ "$yes_no" = "Y" ]; then
            readGitUserEmail
        fi
    else
        readGitUserEmail
    fi

    # git
    git config --global user.email "$gitUserEmail"
    git config --global user.name "$gitUserName"

    f_readYesNo "Would you like to connect to your GitHub account with an SSH key ? (y/N)"
    if [ "$yes_no" = "Y" ]; then
        
        source connect-github-ssh.sh $gitUserEmail
        
        f_readYesNo "If you cloned this repo using https, now that you have SSH enabled, would you like to change this repo authentication to ssh ? (y/N)"
        if [ "$yes_no" = "Y" ]; then
            git remote set-url origin git@github.com:frohlichcortezh/ubuntu-based-scripts.git            
        fi

    fi
fi
