#!/usr/bin/env bash
source ../bash-scripts/lib/functions.sh

hostname=$1

inputHostname() {
    f_dialog_input "How would like to call this machine ?"
    if [ $? -eq 0 ]; hostname email=$f_dialog_RETURNED_VALUE; fi
    
    while [ "$hostname" = "" ]; do read hostname; done
}

inputHostname
