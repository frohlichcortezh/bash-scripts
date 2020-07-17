#!/bin/bash

source functions.sh

    if ! f_app_is_installed "fish"; then
        f_app_install "fish"
    fi

    # Install powerline-shell -> https://github.com/b-ryan/powerline-shell
    pip3 install powerline-shell

    # back-ups current bash profile
    cp ~/.bashrc ~/.bashrc-bak
    cp ~/.bash_profile ~/.bash_profile-bak

    # makes powerline-shell default prompt for bash

    echo 'PATH=$PATH:~/.local/bin' >> ~/.bash_profile

    echo '

# setup-terminal.sh
# makes powerline-shell default prompt for bash

function _update_ps1() {
    PS1=$($HOME/.local/bin/powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi' >> ~/.bashrc

     # re-load bash config
     source ~/.bashrc
     source ~/.bash_profile

    # back-ups current bash profile
    cp ~/.config/fish/config.fish ~/.config/fish/config-bak.fish

    # makes powerline-shell default prompt for fish
    if [ ! -d "$HOME/.config/fish/" ]; then
        mkdir ~/.config/fish/
    fi

    echo '
    function fish_prompt
            powerline-shell --shell bare $status
    end' >> ~/.config/fish/config.fish

    fish -c "set -U fish_user_paths ~/.local/bin"
    makedir ~/.config/fish/functions

    source setup-fonts.sh

    f_app_install bash-completion
