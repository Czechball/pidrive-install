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

apt install -y "$PACKAGES"

# Clone hcxdumptool from github, compile it and install

git clone https://github.com/ZerBea/hcxdumptool.git
cd hcxdumptool
make
sudo make install
cd ..

# TODO: Prompt user to select from connected wireless interfaces
# Right now, will always use wlan0 for hcxdumptool

cp "Misc/"

mkdir -p /media/wardrive-usb
mkdir -p /opt/wardriving
