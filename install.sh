#!/bin/bash

#install.sh

PACKAGES=$(cat packages.txt)

if [[ $EUID -ne 0 ]]; then
   echo "Run this script as root" 
   exit 1
fi

# Update and upgrade the system, install dependencies

echo "Running apt update and apt upgrade, this will take a while"
apt update
apt upgrade -y

echo "Installing dependencies..."

apt install -y $PACKAGES

echo "Reinstalling kernel headers so we can compile drivers..."

# "Repair" raspberry pi kernel headers - work in  progress
apt --reinstall install raspberrypi-kernel raspberrypi-kernel-headers -y
rm -rf /lib/modules/*/build
apt --reinstall install raspberrypi-kernel-headers -y
#reboot

##
#idk if this works, needs testing
#this needs to be moved into another script to be executed after reboot after kernel "repair"

# Clone and install hcxdumptool

sudo -u pi bash -c 'cd ~;git clone https://github.com/ZerBea/hcxdumptool.git;cd hcxdumptool;make;sudo make install'

# Clone and install hcxtools

sudo -u pi bash -c 'cd ~;git clone https://github.com/ZerBea/hcxtools.git;cd hcxtools;sudo make install'

# Clone and install realtek_rtwifi
# Blacklist 8188eu, r8188eu and rtl8xxxu

printf "blacklist 8188eu\nblacklist r8188eu\nblacklist rtl8xxxu" > /etc/modprobe.d/realtek.conf
sudo -u pi bash -c 'cd ~;git clone https://github.com/kimocoder/realtek_rtwifi;cd realtek_wifi;make;sudo make install'

##

cp Scripts/* /usr/bin/

# Create wardriving directory

mkdir -p /opt/wardriving/logs

# Copy services

cp Services/* /etc/systemd/system/
systemctl daemon-reload

# Disable services taking over wireless interfaces

systemctl --now disable avahi-daemon
