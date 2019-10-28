#!/bin/bash
# Some global variables
CONFIGURATOR_FIRMWARE_DIR="~/Library/Group Containers/K36BKF7T3D.group.com.apple.configurator/Library/Caches/Firmware/"
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IDENTIFIER_FILE=$WORKING_DIR/identifiers.txt

echo "Starting IPSW firmware check $(date)"

while read identifier; do
   echo "Checking for new firmware for $identifier"
   
   # Get latest firmware file name for this device
   LATEST_FIRMWARE_NAME="$(wget -qO- http://api.ipsw.me/v2.1/$identifier/latest/filename)"
   echo "Latest firmware for $identifier is $LATEST_FIRMWARE_NAME"

   # See if this latest firmware is in the Configurator cache
   if [ ! -f "$CONFIGURATOR_FIRMWARE_DIR/$LATEST_FIRMWARE_NAME" ]; then
      echo "Need $LATEST_FIRMWARE_NAME. Downloading..."
      # Ask IPSW.me what the Apple server download URL is
      LATEST_FIRMWARE_URL="$(wget -qO- http://api.ipsw.me/v2.1/$identifier/latest/url)"
      # Download latest firmware to the Configurator cache
      wget $LATEST_FIRMWARE_URL -P "$CONFIGURATOR_FIRMWARE_DIR"
   else
      echo "Already have latest firmware for $identifier"
   fi

   # Sleep for a second as a courtesy to IPSW.me
   sleep 1
done < $IDENTIFIER_FILE

echo "Finished IPSW firmware check $(date)"
