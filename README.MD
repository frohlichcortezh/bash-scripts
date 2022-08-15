# **bash-scripts (#WIP Work in progress)**
## Collection of bash scripts to automate repetitive tasks


## **Usage**

Clone this repo with HTTP
```
git clone https://github.com/frohlichcortezh/bash-scripts.git
```

## **Connect to github with ssh**

  Adds a new ssh key and give instructions on how to add it to github.
  ```
  . ../bash-scripts/bin/connect-github-ssh.sh
  ```

  or 
  ```
  . ../bash-scripts/bin/connect-github-ssh.sh "your-email@domain.com"
  ```

## **Setup terminal**

Installs fish, python3, python3-pip, powerline-shell and Cascadia Code font

  ```
  . ../bash-scripts/bin/setup-terminal.sh
  ```

## **Setup DEV**

Installs node, npm, yarn, angular, docker, portainer

  ```
  . ../bash-scripts/bin/setup-dev.sh
  ```