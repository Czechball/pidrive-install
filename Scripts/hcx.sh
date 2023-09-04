#!/bin/bash

DIRECTORY="/opt/wardriving"
INTERFACE="$1"
if test -f "/opt/wardriving/sessions.txt"; then
        SESSION=$(tail -n1 "/opt/wardriving/sessions.txt")
else
        SESSION="0000"
fi

mkdir -p "$DIRECTORY"/"$SESSION"

ip link set "$INTERFACE" down
iw dev "$INTERFACE" set type monitor
ip link set "$INTERFACE" up

wardrive()
{
        HCX_OPTS=$(grep -w "$INTERFACE" /opt/wardriving/interfaces.txt | cut -d ";" -f 3)
        # Added this, so in case of need to re-write the command or modify it, you only have to do it in one place
        START_HCXDUMPTOOL=$(hcxdumptool --errormax=1 --onerror=reboot -i $INTERFACE -w $DIRECTORY/$SESSION/$INTERFACE-capture.pcapng --disable_deauthentication)
        if [[ $HCX_OPTS == "" ]]; then
                $START_HCXDUMPTOOL
        else
                $START_HCXDUMPTOOL $HCX_OPTS
        fi
}

if (iw dev | grep "$INTERFACE"); then
        echo "--- Session $SESSION has started ---" | tee -a "$DIRECTORY"/logs/hcxdumptool-"$INTERFACE".log
        wardrive | tee -a "$DIRECTORY"/logs/hcxdumptool-"$INTERFACE".log
        echo "--- Session $SESSION has stopped ---" | tee -a "$DIRECTORY"/logs/hcxdumptool-"$INTERFACE".log
fi
