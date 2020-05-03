f_printLn() {
    echo "$(tput setaf 6)$1$(tput setaf 7)"
}

f_readP() { 
    read -p "$(tput setaf 6)$1 $(tput setaf 7)" userInput
    if [ "$userInput" = "" ] && [ "$2" != "" ]; then
        echo $2
    else
        echo $userInput
    fi
}

f_readUpper() {    
    local upper=`f_readP "$1"`
    echo "${upper^^}"
}

f_readYesNo() {
    yes_no=`f_readUpper "$1"`
    if [ "$yes_no" != "Y" ]; then
        yes_no="N"
    fi
}

f_dateDiff() {
    echo "( `date -d "$1" +%s` - `date -d "$2" +%s`) / (24*3600)" | bc -l
}