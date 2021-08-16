#!/bin/bash

if [[ $1 == "" ]]; then
	echo "Error, no interface name provided. Usage: $0 <interface name>"
fi

if [[ $EUID -ne 0 ]]; then
   echo "Run this script as root" 
   exit 1
fi

INTERFACE="$1"

echo "Adding interface $INTERFACE"

MAC=$(macchanger wlan3 | head -n1 | cut -d " " -f 5)
echo "MAC address: $MAC"

echo "Adding dhcpcd exclusion"
echo "denyinterfaces $INTERFACE" >> /etc/dhcpcd.conf