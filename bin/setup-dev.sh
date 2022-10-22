#!/usr/bin/env bash
source ../bash-scripts/lib/functions.sh
source ../bash-scripts/lib/app-management.sh

# ToDo break each step into individual files

# Install snap store
f_app_install "snapd"

# Install Node.js
## REF: https://nodejs.org/en/download/package-manager/#snap

f_app_install_from_snap "node" --classic --channel=16
f_app_install_from_npm npm@8.17.0 @angular-devkit/build-angular
f_app_install_from_npm typescript --save-dev

echo "node version: $(node -v)"
echo "npm version: $(npm -v)"
echo "yarn version: $(yarn -v)"

# Install angular
## REF: https://angular.io/guide/setup-local

f_app_install_from_npm @angular/cli
echo "angular version: $(ng version)"
# Install ionic
## REF: 
f_app_install_from_npm @ionic/cli

# Install docker
## REF: https://docs.docker.com/engine/install/ubuntu/

sudo apt-get remove docker docker-engine docker.io containerd runc

f_app_install "ca-certificates" "curl" "gnupg" "lsb-release"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

f_pkg_manager_update

f_app_install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# REF: https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker 

echo "docker version: $(docker -v && docker ps)"
echo "docker compose version: $(docker compose version)"

#TOdo check docker compose broken after portainer installation

# Install portainer
# REF: https://docs.portainer.io/v/ce-2.6/start/install/server/docker/linux
mkdir -p $HOME/dev/docker/volumes/portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/dev/docker/volumes/portainer_data:/data portainer/portainer-ce:2.11.1

yourIpAddress=$(hostname  -I | cut -f1 -d' ')
echo Go to http://$yourIpAddress:9443
echo Configure admin user and choose local

# Install VS Code
# REF: https://code.visualstudio.com/docs/setup/linux
mkdir -p $HOME/Downloads/Apps/ 
wget -O $HOME/Downloads/Apps/VSCode.deb https://go.microsoft.com/fwlink/?LinkID=760868
f_app_install $HOME/Downloads/Apps/VSCode.deb

# Install VS COde extensions
code --install-extension ahmadawais.shades-of-purple
code --install-extension cyrilletuzi.angular-schematics
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension firefox-devtools.vscode-firefox-debug
code --install-extension formulahendry.auto-close-tag
code --install-extension GrapeCity.gc-excelviewer
code --install-extension hediet.vscode-drawio
code --install-extension Ionic.ionic
code --install-extension johnpapa.Angular2
code --install-extension mechatroner.rainbow-csv
code --install-extension miguelsolorio.fluent-icons
code --install-extension mikestead.dotenv
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.csharp
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-ssh-edit
code --install-extension RapidAPI.vscode-rapidapi-client
code --install-extension redhat.vscode-yaml
code --install-extension ritwickdey.LiveServer
code --install-extension VisualStudioExptTeam.intellicode-api-usage-examples
code --install-extension VisualStudioExptTeam.vscodeintellicode
code --install-extension Zignd.html-css-class-completion

# Install .NET lts/stable (as of 16/08 it's 6.0)
## REF: https://docs.microsoft.com/en-us/dotnet/core/install/linux-snap

f_app_install_from_snap "dotnet-sdk" --classic --channel=lts/stable
sudo snap alias dotnet-sdk.dotnet dotnet
echo "dotnet version: $(dotnet --version)"
echo "export DOTNET_ROOT=/snap/dotnet-sdk/current" >> $HOME/.bashrc 

# Install GO
curl -OL https://go.dev/dl/go1.19.linux-amd64.tar.gz