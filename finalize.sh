#!/bin/bash

# This script should be executed after rebooting after finishing install.sh

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
