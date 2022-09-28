#!/bin/bash

touch ~/.uploaded
WARDRIVE_DIR="/opt/wardriving/"

loop()
{
        sleep 10m
        upload
}

upload()
{
        while read LINE; do
                if grep -Fxq "$LINE" ~/.uploaded; then
                        echo "Session $LINE was already uploaded, skipping.."
                else
                        echo "Session $LINE not uploaded yet, uploading.."
                        /home/pi/wpa-sec-api/upload-pcapng.sh "$WARDRIVE_DIR""$LINE"/* || retry
                        echo "Session $LINE uploaded succesfully"
                        echo "$LINE" >> ~/.uploaded
                fi
        done </opt/wardriving/sessions.txt
        loop
}

retry()
{
        echo "Upload failed, waiting 10m and trying again"
        sleep 10m
        upload
}

upload
