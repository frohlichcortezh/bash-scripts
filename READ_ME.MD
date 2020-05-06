# bash-scripts

## Collection of bash scripts to automate repetitive tasks

* `setup-distro.sh`
    intended to be run after clean install to set things up, installing favourites packages.

* `setup-git.sh`
    executed during `setup-distro.sh`, it'll exec git config with input from user. 
    can setup github ssh-keys - see `connect-github-ssh.sh`

* `connect-github-ssh.sh`
    will create ssh-keys if none are present and give instructions on how to added it your GitHub account
    uses one argument, that should be your e-mail. if not passed as an argument, user will be prompted for input

* `functions.sh`
    common functions used by the scripts

