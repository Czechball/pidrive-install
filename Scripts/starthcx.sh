#!/bin/bash
if (iw dev | grep wlan1); then
	while true; do
		if (iw dev | grep wlan1); then
			hcxdumptool --error_max=1 -i wlan1 -o /path/to/capture.pcapng --disable_client_attacks --enable_status=95 >> /var/log/hcxdumptool.log
			echo "hcxdumptool stopped" >> /var/log/hcxdumptool.log
			echo "hcxdumptool stopped, waiting for 5 seconds..."
			sleep 5
		fi
	done
else
	sleep 10
	exit
fi

