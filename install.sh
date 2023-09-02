#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" || { echo -e "\e[91mERROR\e[0m: Script path cannot be found" ; exit; } >/dev/null 2>&1 ; pwd -P )"

#install.sh

set -e

PACKAGES=$(cat packages.txt)

if [[ $EUID -ne 0 ]]; then
   echo "Run this script as root" 
   exit 1
fi

echo "Warning: This script will only work on Raspberry Pi OS and possibly other Debian based systems."

NON_ROOT_USERS=$(awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd)

echo "Select non-root user:"

select NON_ROOT_USER in "${NON_ROOT_USERS[@]}"; do
   [ -n "${NON_ROOT_USER}" ] && break
done

echo "Selected user ${NON_ROOT_USER}, continuing with that..."

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

sudo -u ${NON_ROOT_USER} bash -c 'wget http://ftp.uk.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-misc-nonfree_20190114-2_all.deb'
dpkg -i firmware-misc-nonfree_20190114-2_all.deb
apt-mark hold firmware-misc-nonfree

# echo "Reinstalling kernel headers so we can compile drivers... (this might take a while)"

# Remount /boot as read-write

mount -o remount,rw /boot

## "Repair" raspberry pi kernel headers
## Disabled, the preffered way is to build kernel headers from Linux source
# apt --reinstall install raspberrypi-kernel raspberrypi-kernel-headers -y
# rm -rf /lib/modules/*/build
# apt --reinstall install raspberrypi-kernel-headers -y

## TODO - Build and install kernel headers from Linux source
## (detect current kernel version, clone the proper branch, build and install kernel headers)
# sudo -u pi bash -c "cd ~;git clone \"https://github.com/raspberrypi/linux\" linux-source;cd linux-source;make bcm2711_defconfig;sudo make headers_install INSTALL_HDR_PATH=/usr"

# Update and upgrade the system, install dependencies

echo "Running apt upgrade, this will take a while"
apt upgrade -y

echo "Installing dependencies..."

apt install -y $PACKAGES

echo "To finish the kernel-headers fix, please reboot. Then run $SCRIPTPATH/finalize.sh"

printf "\n----------\nTo finish pidrive-install, please run $SCRIPTPATH/finalize.sh\n----------\n" >> /etc/motd
