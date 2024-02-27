#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Run this script as root" 
   exit 1
fi

NON_ROOT_USERS=$(awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd)

echo "Select non-root user:"

select NON_ROOT_USER in "${NON_ROOT_USERS[@]}"; do
   [ -n "${NON_ROOT_USER}" ] && break
done

echo "Selected user ${NON_ROOT_USER}, continuing with that..."

TEMPFILE=$(mktemp)

make-git()
{
	# set environment variable for ALL software, some might need it and it's much simpler to just universally have it
	export ARCH=arm

	### Software-specific settings go in this section
	# compile hcxdumptool without GPS and refresh-display support, see https://github.com/ZerBea/hcxdumptool/issues/301#issuecomment-1508011763
	if [ "$2" = "hcxdumptool"]; do
		cd \"$2\"; sed -i '/DSTATUSOUT/ s/./#&/' Makefile
	fi

	# compile hcxtools without refresh-display support, see https://github.com/ZerBea/hcxdumptool#solve-dependencies
	if [ "$2" = "hcxtools"]; do
		cd \"$2\"; sed -i '/DSTATUSOUT/ s/./#&/' Makefile
	fi

	# TODO: recognize platform and set proper Makefile settings according to https://github.com/aircrack-ng/rtl8812au#for-raspberry-rpi
	# depends on raspberrypi-kernel-headers, which we are trying to compile but it's broken/not implemented yet?

	# compile rtl88x2bu for Raspberry pi, according to https://github.com/cilynx/rtl88x2bu#raspberry-pi-access-point, lines 16-17
	if [ "$2" = "rtl88x2bu"]; do
		cd \"$2\"; sed -i 's/I386_PC = y/I386_PC = n/' Makefile; sed -i 's/ARM_RPI = n/ARM_RPI = y/' Makefile
	fi

	# clone the repo, compile and install
	sudo -u ${NON_ROOT_USER} bash -c "cd ~;git clone \"$1\";cd \"$2\";make;sudo make install"
}

# This script should be executed after rebooting after finishing install.sh

# Remove warning in motd

if (grep "To finish pidrive-install" /etc/motd > /dev/null); then
	head -n -4 /etc/motd > "$TEMPFILE" && mv "$TEMPFILE" /etc/motd
fi

# Clone and install hcxdumptool
if (which hcxdumptool); then
	echo "hcxdumptool is already installed"
else
	echo "hcxdumptool not found, installing..."
	make-git "https://github.com/ZerBea/hcxdumptool.git" hcxdumptool
fi

# Clone and install hcxtools
if (which hcxpcapngtool); then
	echo "hcxtools are already installed"
else
	echo "hcxtools not found, installing..."
	make-git "https://github.com/ZerBea/hcxtools.git" hcxtools
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

## Disabled realtek_rtwifi build, currently broken
# echo "installing realtek_rtwifi by Kimocoder..."

# make-git "https://github.com/kimocoder/realtek_rtwifi.git" realtek_rtwifi

echo "installing rtl8812au..."

make-git "https://github.com/aircrack-ng/rtl8812au.git" rtl8812au

echo "installing rtl88x2bu..."

make-git "https://github.com/cilynx/rtl88x2bu.git" rtl88x2bu

cp Scripts/* /usr/bin/

# Create wardriving directory

mkdir -p /opt/wardriving/logs

# Copy services

cp Services/* /etc/systemd/system/
systemctl daemon-reload
systemctl enable hcx-session

# Disable services taking over wireless interfaces

systemctl --now disable avahi-daemon.service
systemctl --now disable avahi-daemon.socket

# Create whitelist file

touch /opt/wardriving/whitelist.txt
touch /opt/wardriving/whitelist-client.txt

echo "All done."
