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

# Fix mt7610u drivers, see https://github.com/raspberrypi/firmware/issues/1563

sudo -u pi bash -c 'wget http://ftp.uk.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-misc-nonfree_20190114-2_all.deb'
dpkg -i firmware-misc-nonfree_20190114-2_all.deb
apt-mark hold firmware-misc-nonfree

echo "Reinstalling kernel headers so we can compile drivers..."

# Remount /boot as read-write

mount -o remount,rw /boot

# "Repair" raspberry pi kernel headers - work in  progress
apt --reinstall install raspberrypi-kernel raspberrypi-kernel-headers -y
rm -rf /lib/modules/*/build
apt --reinstall install raspberrypi-kernel-headers -y

echo "To finish the kernel-headers fix, please reboot"

##
#idk if this works, needs testing
#this needs to be moved into another script to be executed after reboot after kernel "repair"
