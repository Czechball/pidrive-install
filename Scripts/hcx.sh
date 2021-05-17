#!/bin/bash

INTERFACE="wlan0"
DIRECTORY="/opt/wardriving"
LOGFILE="/var/log/hcxdumptool.log"

if (iw dev | grep "$INTERFACE"); then
	while true; do
		if (iw dev | grep "$INTERFACE"); then
			hcxdumptool --error_max=1 -i "$INTERFACE" -s 1 -o "$DIRECTORY/$HOSTNAME-capture.pcapng" --disable_client_attacks --enable_status=95 >> "$LOGFILE"
			echo "hcxdumptool stopped" >> "$LOGFILE"
			echo "hcxdumptool stopped, waiting for 5 seconds..."
			sleep 5
		fi
	done
else
	sleep 5
	exit
fi
