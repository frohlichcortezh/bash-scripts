# Road map

* [x] Setup git
* [x] Use whiptail instead of echo/read
* [x] Install and config powerline-shell 
* [ ] Setup `sqlite` db for storing user preferences
* [ ] Implement check list to choose type of installation: mininmal (CLI), desktop, WebServer (headless) or WebServer (Graphical)
* [ ] Implement check list to install favourite apps on `setup-distro.sh`
* [ ] On `functions.sh` change f_app_* functions to work with different package managers
* [ ] Set refind theme
* [ ] Make it testable ? -- Use LXC to spin up distros to test. In this case must change whiptail commands on `functions.sh` to deal with non interactive shells and make `setup-distro.sh` accept arguments.