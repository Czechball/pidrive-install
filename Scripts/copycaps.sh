#!/bin/bash
if lsblk | grep sd; then
	mount -a
	if test -f /media/wardrive-usb/test; then
		cp -n /opt/wardriving/* /media/wardrive-usb/
		sleep 5
		umount -l /media/wardrive-usb/
	else
		echo "Error, test file not present on usb"
		exit
	fi
fi
