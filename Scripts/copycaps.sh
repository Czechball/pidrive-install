#!/bin/bash

if lsblk | grep sd; then
	mount -a
	if test -f /path/to/usb/test; then
		cp -n /path/to/captures/* /home/kali/usb-mnt/autodrive/
		sleep 5
		umount -l /path/to/usb/
	else
		echo "Error, test file not present on usb"
		exit
	fi
fi
