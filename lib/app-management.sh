#!/usr/bin/env bash

#-----------------------------------------------------------------------------------
# Package manager functions
# ToDo run different package managers according to distro
#-----------------------------------------------------------------------------------

f_app_install() {
    #ToDo run different package managers according to distro
    #if debian based
    sudo apt install "$@" -y

    #if arch based
    #sudo pacman -S "$@" -y
    
    #if fedora based
    #sudo dnf install "$@" -y

    #if opensuse based
    #sudo zypper install "$@" -y


}

f_app_install_from_snap() {
    #ToDo check for classic argument
    #sudo snap install --classic code
    sudo snap install "$@"
}

f_app_install_from_pip() {
    sudo python3 -m pip install "$@"
}

f_app_install_from_npm() {
    sudo npm install --location=global "$@"
}

f_app_is_installed() {
    package_info="$(dpkg -s $1)"

    if [ -z "$package_info" ] || [ "$package_info" = *"not installed"* ]; then
        false
    else
        true
    fi
}

f_pip_app_is_installed() {
	package_info="$(pip3 show $1)"
	
	if [ "$package_info" = *"not installed"* ]; then
        false
    else
        true
    fi
}

f_repository_is_installed() {
    repository_list=`egrep -v '^#|^ *$' /etc/apt/sources.list /etc/apt/sources.list.d/*`

    if [ "$package_info" = *"$1"* ]; then
        false
    else
        true
    fi
}

f_pkg_manager_update() {
    # update
	sudo apt update -y
}

f_pkg_manager_upgrade() {
    # upgrade
	sudo apt upgrade -y
}

f_pkg_manager_updateAndUpgrade() {
    # update and upgrade
	sudo apt update -y && sudo apt upgrade -y
}

f_repository_add() {
    sudo apt-add-repository $1
    repo_added=1
}