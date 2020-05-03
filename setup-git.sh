#!/bin/bash

source functions.sh

if ! f_apt_package_is_installed "git"; then
    
    f_printLn "git isn't installed can't set it up"
    exit 1

else

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