#!/bin/bash

source functions.sh

    if ! f_app_is_installed "fontconfig"; then
        f_app_install "fontconfig"
    fi

    # Setting up vs code font config
    if [ ! -d "~/.local/share/fonts/" ]; then
        mkdir -p ~/.local/share/fonts/
    fi

    # download Cascadia-Code fonts

    FILE="$HOME/.local/share/fonts/Cascadia.ttf"
    if [ ! -f "$FILE" ];  then
        echo "Downloading Cascadia font"
        curl https://github.com/microsoft/cascadia-code/releases/download/v1911.21/Cascadia.ttf -L -o $FILE --create-dirs
    fi

    FILE="$HOME/.local/share/fonts/CascadiaMono.ttf"
    if ! f_file_exists "$FILE"; then
        echo "Downloading Cascadia Mono font"
        curl https://github.com/microsoft/cascadia-code/releases/download/v1911.21/CascadiaMono.ttf -L -o $FILE --create-dirs
    fi    

    FILE="$HOME/.local/share/fonts/CascadiaMonoPL.ttf"
    if ! f_file_exists "$FILE"; then
        echo "Downloading Cascadia Mono PL"
        curl https://github.com/microsoft/cascadia-code/releases/download/v1911.21/CascadiaMonoPL.ttf -L -o $FILE --create-dirs
    fi        

    FILE="$HOME/.local/share/fonts/CascadiaPL.ttf"
    if ! f_file_exists "$FILE"; then
        echo "Downloading "
        curl https://github.com/microsoft/cascadia-code/releases/download/v1911.21/CascadiaPL.ttf -L -o $FILE --create-dirs
    fi     

    # Update font cache
    fc-cache -f -v
    
    # Setting up vs code font config
    if [ ! -d "$FILE" ]; then
        mkdir -p ~/.config/Code/User
    fi

    echo "
    {
        \"editor.fontFamily\": \"Cascadia Code PL\",
        \"terminal.integrated.fontFamily\": \"Cascadia Code PL\",
        \"editor.fontLigatures\": true
    }" >> "$HOME/.config/Code/User/settings.json"