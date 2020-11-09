#!/bin/bash

source functions.sh

    if ! f_app_is_installed "git"; then
        
        f_dialog_yes_no "Git isn't installed, would you like to install it ?"

        if [ $? -eq 0 ]; then 
            f_app_install "git"
        else
            exit 1
        fi

    fi

    gitUserName=`git config --get user.name`
    gitUserEmail=`git config --get user.email`

    readGitUserName() {
        f_dialog_input "What's your name ? [This will be use as your git user name] : "
        if [ $? -eq 0 ]; then gitUserName=$f_dialog_RETURNED_VALUE; fi

        # ToDo - Improve validation for white spaces and invalid char
        while [ "$gitUserName" = "" ]; do readGitUserName; done
    }

    if [ "$gitUserName" != "" ]; then
        f_dialog_yes_no "Your git user.name is already set to $gitUserName. Would you like to change it ?"
        if [ $? -eq 0 ]; then readGitUserName; fi
    else
        readGitUserName
    fi

    readGitUserEmail() {
        f_dialog_input "What's your e-mail ? [This will be use as your git user email] :"
        if [ $? -eq 0 ]; then gitUserEmail=$f_dialog_RETURNED_VALUE; fi

        # ToDo - Improve validation for white spaces and invalid char
        while [ "$gitUserEmail" = "" ]; do readGitUserEmail; done
    }

    if [ "$gitUserEmail" != "" ]; then
        f_dialog_yes_no "Your git user.email is already set to $gitUserEmail. Would you like to change it ?"
        if [ $? -eq 0 ]; then readGitUserEmail; fi
    else
        readGitUserEmail
    fi

    git config --global user.email "$gitUserEmail"
    git config --global user.name "$gitUserName"

    f_dialog_yes_no "Would you like to connect to your GitHub account with an SSH key ?"

    if [ $? -eq 0 ]; then
        
        source connect-github-ssh.sh $gitUserEmail
        
        f_dialog_yes_no  "If you cloned this repo using https, now that you have SSH enabled, would you like to change this repo authentication to ssh ?"
        if [ $? -eq 0 ]; then
            git remote set-url origin git@github.com:frohlichcortezh/bash-scripts.git            
        fi

    fi