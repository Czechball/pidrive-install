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

# Clone hcxdumptool from github, compile it and install

git clone https://github.com/ZerBea/hcxdumptool.git
(
cd hcxdumptool || exit
make
sudo make install
)

# TODO: Prompt user to select from connected wireless interfaces
# Right now, will always use wlan0 for hcxdumptool

cp Misc/10-wardrive.temp.rules /etc/udev/rules.d

# Add sda1 to fstab

cat Misc/fstab.example >> /etc/fstab

# Copy scripts to /usr/bin

cp Scripts/* /usr/bin/

# Create wardriving directories

mkdir -p /media/wardrive-usb
mkdir -p /opt/wardriving

# Copy services

cp Services/* /etc/systemd/system/
systemctl daemon-reload
systemctl unmask copycaps
systemctl enable copycaps
systemctl unmask hcx
systemctl enable hcx

# Disable services taking over wlan1

systemctl stop wpa_supplicant
systemctl disable wpa_supplicant
systemctl stop avahi-daemon
systemctl disable avahi-daemon
