#!/usr/bin/env bash
source ../bash-scripts/lib/functions.sh
source ../bash-scripts/lib/app-management.sh

f_pkg_manager_updateAndUpgrade
f_app_install "fish" "python3" "python3-pip"

## REF: https://github.com/b-ryan/powerline-shell
f_app_install_from_pip "powerline-shell"

# Update bash profile

tee -a $HOME/.bashrc << END

function _update_ps1() {
    PS1=\$(powerline-shell \$?)
}

if [[ \$TERM != linux && ! \$PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; \$PROMPT_COMMAND"
fi

END

# Update fish profile

cat <<EOT >> $HOME/.config/fish/config.fish

function fish_prompt
    powerline-shell --shell bare \$status
end

EOT

echo "Installing Cascadia Code fonts"
echo "You'll may need to manually change in your terminal app preferences to use this font in other to see font ligatures"

mkdir $HOME/Downloads/Fonts/CascadiaCode
wget -O $HOME/Downloads/Fonts/CascadiaCode/CascadiaCode.zip https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
unzip -d $HOME/Downloads/Fonts/CascadiaCode/ $HOME/Downloads/Fonts/CascadiaCode/CascadiaCode.zip
mkdir -p ~/.local/share/fonts/
cp $HOME/Downloads/Fonts/CascadiaCode/ttf/Cascadia*.ttf ~/.local/share/fonts/
fc-cache -v