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
#apt install --reinstall raspberrypi-kernel-headers
#rm /usr/lib/???
#apt install ???

# Clone hcxdumptool from github, compile it and install

#idk if this works, needs testing
sudo -u pi bash -c 'cd ~;git clone https://github.com/ZerBea/hcxdumptool.git;cd hcxdumptool; make; sudo make install'

cp Scripts/* /usr/bin/

# Create wardriving directory

mkdir -p /opt/wardriving/logs

# Copy services

cp Services/* /etc/systemd/system/
systemctl daemon-reload

# Disable services taking over wireless interfaces

systemctl --now disable avahi-daemon
