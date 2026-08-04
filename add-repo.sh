#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root (e.g. curl -fsSL ... | sudo bash)"
    exit 1
fi

mkdir -p /etc/apt/sources.list.d

echo "deb [trusted=yes] https://raw.githubusercontent.com/Officialckazros/OpSec-install/main/apt-repo ./" > /etc/apt/sources.list.d/opsec.list

apt-get update -o Dir::Etc::sourcelist="sources.list.d/opsec.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" || apt-get update || true

echo ""
echo "OpSec repository added successfully."
echo "You can now run: sudo apt install opsec"
echo ""

exit 0
