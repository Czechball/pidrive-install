#!/bin/bash
NUM=0

if [[ $EUID -ne 0 ]]; then
   echo "Run this script as root" 
   exit 1
fi

read_interface()
{
   read -r -p "Enter a name for your interface (no spaces or special chars) (default $INTERFACE): " INTERFACE_NAME
   INTERFACE_NAME=${INTERFACE_NAME:-$INTERFACE}
}

INTERFACES=$(hcxdumptool -I | tail -n +2 | cut -d " " -f 2)

for ITEM in $INTERFACES; do
   NUM=$((NUM + 1))
   MAC=$(macchanger "$ITEM" | head -n1 | cut -d " " -f 5)
   if (grep "$MAC" /opt/wardriving/interfaces.txt > /dev/null); then
      STATUS="already added"
   else
      STATUS="available"
   fi
   echo "[$NUM] $ITEM - MAC: $MAC, $STATUS"
done

read -r -p "Select interface (1 - $NUM): "
SELECTION=$((REPLY - 1))
if [ $SELECTION -lt $NUM ]; then
   echo "Selected interface: ${INTERFACES[$SELECTION]}"
else
   echo "Select a valid number between 1 and $NUM"
   exit
fi

INTERFACE=${INTERFACES[$SELECTION]}
MAC=$(macchanger ${INTERFACES[$SELECTION]} | head -n1 | cut -d " " -f 5)

read_interface

if (grep $INTERFACE_NAME /opt/wardriving/interfaces.txt); then
   echo "Error, name already chosen. Please enter a new one."
fi

echo "Adding interface $INTERFACE_NAME"

echo "Adding dhcpcd exclusion"
echo "denyinterfaces $INTERFACE" >> /etc/dhcpcd.conf

echo "Creating udev rule"
echo "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$MAC\", ATTR{type}==\"1\", KERNEL==\"wlan*\", NAME=\"$INTERFACE_NAME\", ENV{NM_UNMANAGED}=\"1\", RUN+=\"systemctl start hcx@$INTERFACE_NAME\"" >> /etc/udev/rules.d/10-wardrive.rules
echo "SUBSYSTEM==\"net\", ACTION==\"remove\", ATTR{address}==\"$MAC\", ATTR{type}==\"1\", KERNEL==\"wlan*\", NAME=\"$INTERFACE_NAME\", RUN+=\"systemctl stop hcx@$INTERFACE_NAME\"" >> /etc/udev/rules.d/10-wardrive.rules

echo "Writing info to config"
echo "$MAC,$INTERFACE_NAME" >> /opt/wardriving/interfaces.txt

echo "Enabling service"
systemctl enable hcx@"$INTERFACE_NAME"

echo "Reĺoading udev rules..."
udevadm control --reload-rules
udevadm trigger --attr-match="subsystem=net"
echo "Done, interface $INTERFACE_NAME was added. You should reconnect the interface now, just to be sure"
