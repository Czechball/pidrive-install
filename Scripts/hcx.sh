#!/bin/bash

DIRECTORY="/opt/wardriving"
INTERFACE="$1"
if test -f "/opt/wardriving/sessions.txt"; then
        SESSION=$(tail -n1 "/opt/wardriving/sessions.txt")
else
        SESSION="0000"
fi

ip link set "$INTERFACE" down
iw dev "$INTERFACE" set type monitor
ip link set "$INTERFACE" up

wardrive()
{
        HCX_OPTS=$(grep "$INTERFACE" /opt/wardriving/interfaces.txt | cut -d ";" -f 3)
        if [[ $HCX_OPTS == "" ]]; then
                hcxdumptool --error_max=1 -i $INTERFACE -o $DIRECTORY/$SESSION/$INTERFACE-capture.pcapng --disable_client_attacks --enable_status=95

        else
                hcxdumptool --error_max=1 -i $INTERFACE -o $DIRECTORY/$SESSION/$INTERFACE-capture.pcapng --disable_client_attacks --enable_status=95 $HCX_OPTS
        fi
}

if (iw dev | grep "$INTERFACE"); then
        wardrive >> "$DIRECTORY"/logs/hcxdumptool-"$INTERFACE".log
        echo "hcxdumptool stopped" >> "$DIRECTORY"/logs/hcxdumptool-"$INTERFACE".log
fi
