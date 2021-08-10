#!/bin/bash

DIRECTORY="/opt/wardriving"
INTERFACE="$1"

if (iw dev | grep "$INTERFACE"); then
        hcxdumptool --error_max=1 -i "$INTERFACE" -o "$DIRECTORY/$HOSTNAME-$INTERFACE-capture.pcapng" --disable_client_attacks --enable_status=95 >> "$DIRECTORY"/logs/hcxdumptool-"$INTERFACE".log
        echo "hcxdumptool stopped" >> "$DIRECTORY"/logs/hcxdumptool-"$INTERFACE".log
fi
