#!/usr/bin/env bash
# ToDo break each language installation in its on file
# Check for archictecture when installing, separate device or distro specific installation like Raspberry Pi or Raspbian

	makedir ~/dev

	cd ~/dev


	# VS code installation, raspbian specific
	# ToDo add arch validation

	wget https://packagecloud.io/headmelted/codebuilds/gpgkey -O - | sudo apt-key add -
	
	curl -L https://raw.githubusercontent.com/headmelted/codebuilds/master/docs/installers/apt.sh | sudo bash


	# |------
	# | Python installation
	# |------
	
	# ToDo use common installers source functions.sh
	sudo apt install python pip -y		

	python -m pip install --upgrade --user pip setuptools virtualenv
	
	# Install Kivy - https://kivy.org/doc/stable/installation/installation-linux.html

	python -m virtualenv ~/dev/kivy_venv
	source ~/dev/kivy_venv/bin/activate

	python -m pip install kivy
	python -m pip install kivy_examples
	python -m pip install ffpyplayer

	# Pi Specific
	# https://www.hackster.io/whitebank/rasbperry-pi-ffmpeg-install-and-stream-to-web-389c34
	
	cd /usr/src
 	git clone git://git.videolan.org/x264
 	cd x264
 	./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl
 	make
 	sudo make install

	cd /usr/src
 	git clone git://source.ffmpeg.org/ffmpeg.git
 	cd ffmpeg/
 	sudo ./configure --arch=armel --target-os=linux --enable-gpl --enable-libx264 --enable-nonfree
 	make
	
	sudo make install
	
	# Snap install of dotnet-sdk was broken at time of test 2020-07-04	
	#sudo snap install dotnet-sdk --classic
    #sudo snap install dotnet-sdk --channel=3.1/edge --classic

	# Installing manually - https://docs.microsoft.com/fr-fr/dotnet/core/install/linux-debian#manual-install
	# https://github.com/dotnet/core/blob/master/samples/RaspberryPiInstructions.md
	cd $HOME/dev/bin

	# Pi Specific check arch
	# use arch for download
	wget https://download.visualstudio.microsoft.com/download/pr/56691c4c-341a-4bca-9869-409803d23cf8/d872d7a0c27a6c5e9b812e889de89956/dotnet-sdk-3.1.302-linux-arm.tar.gz
		
	# use arch to extract
	mkdir -p "$HOME/dotnet" && tar zxf "$HOME/dev/bin/dotnet-sdk-3.1.302-linux-arm.tar.gz" -C "$HOME/dotnet"

	# back-ups current bash profile
    cp ~/.bashrc ~/.bashrc-bak
    cp ~/.bash_profile ~/.bash_profile-bak

    # makes powerline-shell default prompt for bash

    echo 'PATH=$PATH:~/.local/bin:$HOME/dotnet' >> ~/.bash_profile

    echo '
	# dotnet bin
	DOTNET_ROOT=$HOME/dotnet' >> ~/.bashrc

     # re-load bash config
     source ~/.bashrc
     source ~/.bash_profile

    # back-ups current bash profile
    cp ~/.config/fish/config.fish ~/.config/fish/config-bak.fish

    # makes powerline-shell default prompt for fish
    if [ ! -d "$HOME/.config/fish/" ]; then
        mkdir ~/.config/fish/
    fi

    fish -c "set -U fish_user_paths $HOME/dotnet"	
	fish -c "set -Ux DOTNET_ROOT $HOME/dotnet"	