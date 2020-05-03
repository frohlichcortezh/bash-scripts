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

f_apt_package_is_installed() {
    package_info=`dpkg -s $1`

    if [ "$package_info" = *"not installed"* ]; then
        false
    else
        true
    fi
}

f_apt_repository_installed() {
    repository_list=`egrep -v '^#|^ *$' /etc/apt/sources.list /etc/apt/sources.list.d/*`

    if [ "$package_info" = *"$1"* ]; then
        false
    else
        true
    fi
}