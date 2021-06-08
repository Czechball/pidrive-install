#!/bin/bash

DIRECTORY="/opt/wardriving"
INTERFACE="$1"

if [[ $(iw dev | grep "$INTERFACE") != "" ]]; then
        while true; do
                if (iw dev | grep "$INTERFACE"); then
                        hcxdumptool --error_max=1 -i "$INTERFACE" -o "$DIRECTORY/$HOSTNAME-$INTERFACE-capture.pcapng" --disable_client_attacks --enable_status=95 >> /var/log/hcxdumptool-"$INTERFACE".log
                        echo "hcxdumptool stopped" >> /var/log/hcxdumptool.log
                        echo "hcxdumptool stopped, waiting for 5 seconds..."
                        sleep 5
                        exit
                fi
        done
else
        sleep 5
        exit
fi