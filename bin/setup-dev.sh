#!/usr/bin/env bash
source ../bash-scripts/lib/functions.sh
source ../bash-scripts/lib/app-management.sh

# ToDo break each step into individual files

# Install snap store
f_app_install "snapd"

# Install Node.js
## REF: https://nodejs.org/en/download/package-manager/#snap

f_app_install_from_snap "node" --classic --channel=16
f_app_install_from_npm npm@8.17.0
echo "node version: $(node -v)"
echo "npm version: $(npm -v)"
echo "yarn version: $(yarn -v)"

# Install angular
## REF: https://angular.io/guide/setup-local

f_app_install_from_npm @angular/cli

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

# Install portainer
# REF: https://docs.portainer.io/v/ce-2.6/start/install/server/docker/linux
mkdir -p $HOME/dev/docker/volumes/portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/dev/docker/volumes/portainer_data:/data portainer/portainer-ce:2.11.1
