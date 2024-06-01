#!/bin/bash
set -e

# check machine configuration
echo -e "Checking system requirements"

cpus=$(nproc)
memory=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')

echo "This machine has ${cpus} CPUs and ${memory}KB of Memory"
if [ "$IGNORE_MINIMAL_REQS" != true ] && ([ "${cpus}" -lt 16 ] || [ "${memory}" -lt 64000000 ]); then
	echo "Insufficient resources. Requires a minimum of 16 processors and 64Gb RAM."
	exit 1
fi

echo "Setting global config..."
wget ${GLOBAL_CONFIG_URL:-https://ton.org/testnet-global.config.json} -O /usr/bin/ton/global.config.json

echo "Setting processor cores"
CPUS=$(expr $(nproc) - 1)
sed -i -e "s/--threads\s[[:digit:]]\+/--threads ${CPUS}/g" /etc/systemd/system/validator.service

echo "Starting validator"
systemctl start validator
echo "Starting mytoncore"
systemctl start mytoncore

echo "Service started!"
exec /usr/bin/systemctl
