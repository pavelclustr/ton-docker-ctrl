#!/bin/bash
set -e

echo "Setting global config..."
wget $GLOBAL_CONFIG_URL -O /usr/bin/ton/global.config.json
 
echo "Starting validator and mytoncore"
systemctl start validator
systemctl start mytoncore

echo "Check logs, wait for Accept"
cat /var/ton-work/log

while [ 1 ]
do
    echo "Running!"
    sleep 60
done
