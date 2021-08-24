#!/bin/bash

DIRECTORY="/opt/wardriving"
INTERFACE="$1"
WARDRIVE_COMMAND="hcxdumptool --error_max=1 -i \"$INTERFACE\" -o \"$DIRECTORY/$HOSTNAME-$INTERFACE-capture.pcapng\" --disable_client_attacks --enable_status=95"

wardrive()
{
        HCX_OPTS=$(grep "$INTERFACE" /opt/wardriving/interfaces.txt | cut -d ";" -f 3)
        if [[ $HCX_OPTS == "" ]]; then
                $WARDRIVE_COMMAND

        else
                $WARDRIVE_COMMAND $HCX_OPTS
        fi
}

if (iw dev | grep "$INTERFACE"); then
        wardrive >> "$DIRECTORY"/logs/hcxdumptool-"$INTERFACE".log
        echo "hcxdumptool stopped" >> "$DIRECTORY"/logs/hcxdumptool-"$INTERFACE".log
fi
