#!/bin/bash

if test -f "/opt/wardriving/sessions.txt"; then
	LAST_SESSION=$(tail -n1 "/opt/wardriving/sessions.txt")
	LAST_SESSION_NOLEAD=${LAST_SESSION#0}
	CURRENT_SESSION=$((10#$LAST_SESSION_NOLEAD + 1))
	CURRENT_SESSION_WZERO=$(printf %04d%s ${CURRENT_SESSION%.*} ${i##*.})
	echo $CURRENT_SESSION_WZERO >> "/opt/wardriving/sessions.txt"
else
	echo "0000" >> "/opt/wardriving/sessions.txt"
fi
