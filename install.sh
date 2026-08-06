#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run with sudo: curl -fsSL ... | sudo bash"
    exit 1
fi

mkdir -p /etc/apt/sources.list.d

echo "deb [trusted=yes] https://officialckazros.github.io/OpSec-install/apt-repo ./" > /etc/apt/sources.list.d/opsec.list

apt-get update -o Dir::Etc::sourcelist="sources.list.d/opsec.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" || apt-get update || true
apt-get install -y --allow-unauthenticated opsec

exit 0
