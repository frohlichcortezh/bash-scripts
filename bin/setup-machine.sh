#!/usr/bin/env bash
source ../bash-scripts/lib/functions.sh

hostname=$1

inputHostname() {
    f_dialog_input "How would like to call this machine ?"
    if [ $? -eq 0 ]; hostname email=$f_dialog_RETURNED_VALUE; fi
    
    while [ "$hostname" = "" ]; do read hostname; done
}

inputHostname

# Install Nala
# REF: https://gitlab.com/volian/nala/-/wikis/Installation

echo "deb https://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null

echo "deb-src https://deb.volian.org/volian/ scar main" | sudo tee -a /etc/apt/sources.list.d/volian-archive-scar-unstable.list

sudo apt update -y && sudo apt install nala -y

sudo nala update -y
sudo nala upgrade -y

sudo nala install gnome-shell-extension-manager -y

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/frohboni/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo apt-get install build-essential
brew install gcc

echo "brew version: $(brew -v)"