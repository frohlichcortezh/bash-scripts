#!/usr/bin/env bash

# Update and upgrade
sudo apt update -y
sudo apt upgrade -y

# GUI for user management
sudo apt install gnome-system-tools -y

# Fish Shell
sudo apt install fish -y

# PiBooth - https://github.com/pibooth/pibooth

mkdir $HOME/apps
mkdir $HOME/apps/PiBooth

# Optionally install the last stable gPhoto2 version (required only for DSLR camera):
wget -O $HOME/apps/PiBooth/gphoto2-updater.sh raw.github.com/gonzalo/gphoto2-updater/master/gphoto2-updater.sh
sudo chmod 755 $HOME/apps/PiBooth/gphoto2-updater.sh
sudo $HOME/apps/PiBooth/gphoto2-updater.sh

# Optionally install CUPS to handle printers (more instructions to add a new printer can be found here):

sudo apt-get install cups libcups2-dev -y

# Optionally install OpenCV to improve images generation efficiency or if a Webcam is used:

sudo apt-get install python3-opencv -y

# Install pibooth from the pypi repository:
# sudo pip3 install pibooth[dslr,printer]

# Install pibooth from main branch - https://github.com/pibooth/pibooth/blob/master/docs/dev.rst
mkdir -p $HOME/dev/code/python && 
cd $HOME/dev/code/python
git clone https://github.com/pibooth/pibooth.git
cd pibooth
sudo pip3 install -e .[dslr,printer]

# -----
# ToDo - move to create a hotspot configuration script
# | Create a hotspot -
# | https://www.raspberryconnect.com/projects/65-raspberrypi-hotspot-accesspoints/158-raspberry-pi-auto-wifi-hotspot-switch-direct-connection
# -----
<<COMMENT

		sudo apt-get install hostapd dnsmasq -y

		sudo systemctl unmask hostapd
		sudo systemctl disable hostapd
		sudo systemctl disable dnsmasq

		sudo rm /etc/hostapd/hostapd.conf

		sudo echo "
		#2.4GHz setup wifi 80211 b,g,n
		interface=wlan0
		driver=nl80211
		# Change your network name here
		ssid=Party_WiFi
		hw_mode=g
		channel=8
		wmm_enabled=0
		macaddr_acl=0
		auth_algs=1
		ignore_broadcast_ssid=0
		wpa=2
		# Change your password here
		wpa_passphrase=Braziu2020
		wpa_key_mgmt=WPA-PSK
		wpa_pairwise=CCMP TKIP
		rsn_pairwise=CCMP

		#80211n - Change FR to your WiFi country code
		country_code=FR
		ieee80211n=1
		ieee80211d=1" >> /etc/hostapd/hostapd.conf

		# Now the defaults file needs to be updated to point to where the config file is stored.
		sudo sed -i 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

		sudo echo "
		#AutoHotspot Config
		#stop DNSmasq from using resolv.conf
		no-resolv
		#Interface to use
		interface=wlan0
		bind-interfaces
		dhcp-range=10.0.0.50,10.0.0.150,12h" >> /etc/dnsmasq.conf

		sudo cp /etc/network/interfaces /etc/network/interfaces-backup
		sudo rm /etc/network/interfaces

		sudo echo "
		# interfaces(5) file used by ifup(8) and ifdown(8) 
		# Please note that this file is written to be used with dhcpcd 
		# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf' 
		# Include files from /etc/network/interfaces.d: 
		source-directory /etc/network/interfaces.d" >> /etc/network/interfaces

		sudo echo "
		nohook wpa_supplicant" >> /etc/dhcpcd.conf

		sudo echo "[Unit]
		Description=Automatically generates an internet Hotspot when a valid ssid is not in range
		After=multi-user.target
		[Service]
		Type=oneshot
		RemainAfterExit=yes
		ExecStart=/usr/bin/autohotspot
		[Install]
		WantedBy=multi-user.target" > /etc/systemd/system/autohotspot.service

		sudo systemctl enable autohotspot.service

		sudo echo "#!/bin/bash
		#version 0.95-41-N/HS

		#You may share this script on the condition a reference to RaspberryConnect.com 
		#must be included in copies or derivatives of this script. 

		#A script to switch between a wifi network and a non internet routed Hotspot
		#Works at startup or with a seperate timer or manually without a reboot
		#Other setup required find out more at
		#http://www.raspberryconnect.com

		wifidev="wlan0" #device name to use. Default is wlan0.
		#use the command: iw dev ,to see wifi interface name 

		IFSdef=$IFS
		cnt=0
		#These four lines capture the wifi networks the RPi is setup to use
		wpassid=$(awk '/ssid="/{ print $0 }' /etc/wpa_supplicant/wpa_supplicant.conf | awk -F'ssid=' '{ print $2 }' ORS=',' | sed 's/\"/''/g' | sed 's/,$//')
		wpassid=$(echo "${wpassid//[$'\r\n']}")
		IFS=","
		ssids=($wpassid)
		IFS=$IFSdef #reset back to defaults


		#Note:If you only want to check for certain SSIDs
		#Remove the # in in front of ssids=('mySSID1'.... below and put a # infront of all four lines above
		# separated by a space, eg ('mySSID1' 'mySSID2')
		#ssids=('mySSID1' 'mySSID2' 'mySSID3')

		#Enter the Routers Mac Addresses for hidden SSIDs, seperated by spaces ie 
		#( '11:22:33:44:55:66' 'aa:bb:cc:dd:ee:ff' ) 
		mac=()

		ssidsmac=("${ssids[@]}" "${mac[@]}") #combines ssid and MAC for checking

		createAdHocNetwork()
		{
		    echo "Creating Hotspot"
		    ip link set dev "$wifidev" down
		    ip a add 10.0.0.5/24 brd + dev "$wifidev"
		    ip link set dev "$wifidev" up
		    dhcpcd -k "$wifidev" >/dev/null 2>&1
		    systemctl start dnsmasq
		    systemctl start hostapd
		}

		KillHotspot()
		{
		    echo "Shutting Down Hotspot"
		    ip link set dev "$wifidev" down
		    systemctl stop hostapd
		    systemctl stop dnsmasq
		    ip addr flush dev "$wifidev"
		    ip link set dev "$wifidev" up
		    dhcpcd  -n "$wifidev" >/dev/null 2>&1
		}

		ChkWifiUp()
		{
			echo "Checking WiFi connection ok"
		        sleep 20 #give time for connection to be completed to router
			if ! wpa_cli -i "$wifidev" status | grep 'ip_address' >/dev/null 2>&1
		        then #Failed to connect to wifi (check your wifi settings, password etc)
			       echo 'Wifi failed to connect, falling back to Hotspot.'
		               wpa_cli terminate "$wifidev" >/dev/null 2>&1
			       createAdHocNetwork
			fi
		}


		FindSSID()
		{
		#Check to see what SSID's and MAC addresses are in range
		ssidChk=('NoSSid')
		i=0; j=0
		until [ $i -eq 1 ] #wait for wifi if busy, usb wifi is slower.
		do
		        ssidreply=$((iw dev "$wifidev" scan ap-force | egrep "^BSS|SSID:") 2>&1) >/dev/null 2>&1 
		        echo "SSid's in range: " $ssidreply
		        echo "Device Available Check try " $j
		        if (($j >= 10)); then #if busy 10 times goto hotspot
		                 echo "Device busy or unavailable 10 times, going to Hotspot"
		                 ssidreply=""
		                 i=1
			elif echo "$ssidreply" | grep "No such device (-19)" >/dev/null 2>&1; then
		                echo "No Device Reported, try " $j
				NoDevice
		        elif echo "$ssidreply" | grep "Network is down (-100)" >/dev/null 2>&1 ; then
		                echo "Network Not available, trying again" $j
		                j=$((j + 1))
		                sleep 2
			elif echo "$ssidreply" | grep "Read-only file system (-30)" >/dev/null 2>&1 ; then
				echo "Temporary Read only file system, trying again"
				j=$((j + 1))
				sleep 2
			elif echo "$ssidreply" | grep "Invalid exchange (-52)" >/dev/null 2>&1 ; then
				echo "Temporary unavailable, trying again"
				j=$((j + 1))
				sleep 2
			elif ! echo "$ssidreply" | grep "resource busy (-16)"  >/dev/null 2>&1 ; then
		               echo "Device Available, checking SSid Results"
				i=1
			else #see if device not busy in 2 seconds
		                echo "Device unavailable checking again, try " $j
				j=$((j + 1))
				sleep 2
			fi
		done

		for ssid in "${ssidsmac[@]}"
		do
		     if (echo "$ssidreply" | grep "$ssid") >/dev/null 2>&1
		     then
			      #Valid SSid found, passing to script
		              echo "Valid SSID Detected, assesing Wifi status"
		              ssidChk=$ssid
		              return 0
		      else
			      #No Network found, NoSSid issued"
		              echo "No SSid found, assessing WiFi status"
		              ssidChk='NoSSid'
		     fi
		done
		}

		NoDevice()
		{
			#if no wifi device,ie usb wifi removed, activate wifi so when it is
			#reconnected wifi to a router will be available
			echo "No wifi device connected"
			wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1
			exit 1
		}

		FindSSID

		#Create Hotspot or connect to valid wifi networks
		if [ "$ssidChk" != "NoSSid" ] 
		then
		       if systemctl status hostapd | grep "(running)" >/dev/null 2>&1
		       then #hotspot running and ssid in range
		              KillHotspot
		              echo "Hotspot Deactivated, Bringing Wifi Up"
		              wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1
		              ChkWifiUp
		       elif { wpa_cli -i "$wifidev" status | grep 'ip_address'; } >/dev/null 2>&1
		       then #Already connected
		              echo "Wifi already connected to a network"
		       else #ssid exists and no hotspot running connect to wifi network
		              echo "Connecting to the WiFi Network"
		              wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1
		              ChkWifiUp
		       fi
		else #ssid or MAC address not in range
		       if systemctl status hostapd | grep "(running)" >/dev/null 2>&1
		       then
		              echo "Hostspot already active"
		       elif { wpa_cli status | grep "$wifidev"; } >/dev/null 2>&1
		       then
		              echo "Cleaning wifi files and Activating Hotspot"
		              wpa_cli terminate >/dev/null 2>&1
		              ip addr flush "$wifidev"
		              ip link set dev "$wifidev" down
		              rm -r /var/run/wpa_supplicant >/dev/null 2>&1
		              createAdHocNetwork
		       else #"No SSID, activating Hotspot"
		              createAdHocNetwork
		       fi
		fi" > /usr/bin/autohotspot

	sudo chmod +x /usr/bin/autohotspot
COMMENT

# ----------
# | ToDo - move to Spotify Connect Config file
# | SpoCon - SpoCon is a Spotify Connect for Debian package and associated repository which thinly wraps the awesome librespot-java library 
# | by Gianluca Altomani and others. It works out of the box on all three revisions of the Pi, immediately after installation. 
# ----------
curl -sL https://spocon.github.io/spocon/install.sh | sh

# view available mixers
sudo journalctl -u spocon | grep -i "available mixers"

# changing quality audio to very high
sudo sed -i 's/preferredAudioQuality = "VORBIS_160"/preferredAudioQuality = "VERY_HIGH"/g' /opt/spocon/config.toml

# using Headphones (Jack output) by default
sudo sed -i 's/mixerSearchKeywords = ""/mixerSearchKeywords = "Headphones"/g' /opt/spocon/config.toml


