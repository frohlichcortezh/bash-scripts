#!/usr/bin/env bash

# install brew
sudo apt-get update -y
sudo apt-get install build-essential procps curl file git gcc -y

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/$USER/.profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/$USER/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install gcc
brew install jandedobbeleer/oh-my-posh/oh-my-posh