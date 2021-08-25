#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" || { echo -e "\e[91mERROR\e[0m: Script path cannot be found" ; exit; } >/dev/null 2>&1 ; pwd -P )"

#install.sh

PACKAGES=$(cat packages.txt)

if [[ $EUID -ne 0 ]]; then
   echo "Run this script as root" 
   exit 1
fi

echo "Warning: This script will only work on Raspberry Pi OS and possibly other Debian based systems."

# Check internet connectivity

if (curl -s google.com > /dev/null); then
   :
else
   echo "Error, can't reach Google. Make sure you have internet connectivity before running this script."
fi

# Fix mt7610u drivers, see https://github.com/raspberrypi/firmware/issues/1563

# echo "Checking if the correct version (1:20190114-2+rpt1) of firmware-misc-nonfree is installed... "

# if (apt list firmware-misc-nonfree | grep 20190114-2 > /dev/null); then
#    echo "Success, skipping reinstall"
# else
#    echo "Correct version not found, installing the correct one..."
#    sudo -u pi bash -c 'wget http://ftp.uk.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-misc-nonfree_20190114-2_all.deb'
#    dpkg -i firmware-misc-nonfree_20190114-2_all.deb
# fi

# Check doesn't work

apt update

sudo -u pi bash -c 'wget http://ftp.uk.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-misc-nonfree_20190114-2_all.deb'
dpkg -i firmware-misc-nonfree_20190114-2_all.deb
apt-mark hold firmware-misc-nonfree

echo "Reinstalling kernel headers so we can compile drivers... (this might take a while)"

# Remount /boot as read-write

mount -o remount,rw /boot

# "Repair" raspberry pi kernel headers - work in  progress
apt --reinstall install raspberrypi-kernel raspberrypi-kernel-headers -y
rm -rf /lib/modules/*/build
apt --reinstall install raspberrypi-kernel-headers -y

# Update and upgrade the system, install dependencies

echo "Running apt upgrade, this will take a while"
apt upgrade -y

echo "Installing dependencies..."

apt install -y $PACKAGES

echo "To finish the kernel-headers fix, please reboot. Then run $SCRIPTPATH/finalize.sh"

##
#idk if this works, needs testing
#this needs to be moved into another script to be executed after reboot after kernel "repair"

printf "\n----------\nTo finish pidrive-install, please run $SCRIPTPATH/finalize.sh\n----------\n" >> /etc/motd
