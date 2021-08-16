#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Run this script as root" 
   exit 1
fi

# This script should be executed after rebooting after finishing install.sh

# Remove warning in motd

if (grep "To finish pidrive-install" /etc/motd > /dev/null); then
	head -n -4 /etc/motd > /etc/motd
fi

# Clone and install hcxdumptool
if (which hcxdumptool); then
	echo "hcxdumptool is already installed"
else
	echo "hcxdumptool not found, installing..."
	sudo -u pi bash -c 'cd ~;git clone https://github.com/ZerBea/hcxdumptool.git;cd hcxdumptool;make;sudo make install'
fi

# Clone and install hcxtools
if (which hcxpcapngtool); then
	echo "hcxtools are already installed"
else
	echo "hcxtools not found, installing..."
	sudo -u pi bash -c 'cd ~;git clone https://github.com/ZerBea/hcxtools.git;cd hcxtools;sudo make install'
fi

# Clone and install realtek_rtwifi
# Blacklist 8188eu, r8188eu and rtl8xxxu

if (test -f /etc/modprobe.d/realtek.conf); then
	echo "/etc/modprobe.d/realtek.conf exists, not modifying"
else
	echo "adding realtek blacklist to /etc/modprobe.d/realtek.conf ..."
	printf "blacklist 8188eu\nblacklist r8188eu\nblacklist rtl8xxxu" > /etc/modprobe.d/realtek.conf
fi

# idk how to check for presence of this driver so it's going to be compiled and installed regardless

echo "installing realtek_rtwifi by Kimocoder..."

sudo -u pi bash -c 'cd ~;git clone https://github.com/kimocoder/realtek_rtwifi;cd realtek_rtwifi;make;sudo make install'

cp Scripts/* /usr/bin/

# Create wardriving directory

mkdir -p /opt/wardriving/logs

# Copy services

cp Services/* /etc/systemd/system/
systemctl daemon-reload

# Disable services taking over wireless interfaces

systemctl --now disable avahi-daemon.service
systemctl --now disable avahi-daemon.socket
# Not sure if this is necessary? Needs testing
#systemctl --now disable wpa_supplicant

echo "All done."
