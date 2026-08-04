#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root (use sudo ./setup.sh)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="${SCRIPT_DIR}/opsec-software"
REPO_DIR="/var/lib/opsec-software/repo"

chmod 755 "${PACKAGE_DIR}/DEBIAN/postinst" "${PACKAGE_DIR}/DEBIAN/prerm" 2>/dev/null || true
chmod 755 "${PACKAGE_DIR}/usr/bin/opsec-software" 2>/dev/null || true

dpkg-deb --build "${PACKAGE_DIR}" "${SCRIPT_DIR}/opsec-software_1.0.0_all.deb"

mkdir -p "${REPO_DIR}"
cp "${SCRIPT_DIR}/opsec-software_1.0.0_all.deb" "${REPO_DIR}/"

cd "${REPO_DIR}"
if command -v dpkg-scanpackages >/dev/null 2>&1; then
    dpkg-scanpackages . /dev/null > Packages
    gzip -9c Packages > Packages.gz
else
    cat <<EOF > Packages
Package: opsec-software
Version: 1.0.0
Architecture: all
Maintainer: ckazros <officialckazros@gmail.com>
Filename: opsec-software_1.0.0_all.deb
Size: $(stat -c%s "${REPO_DIR}/opsec-software_1.0.0_all.deb" 2>/dev/null || echo "1024")
MD5sum: $(md5sum "${REPO_DIR}/opsec-software_1.0.0_all.deb" 2>/dev/null | awk '{print $1}' || echo "")
SHA256: $(sha256sum "${REPO_DIR}/opsec-software_1.0.0_all.deb" 2>/dev/null | awk '{print $1}' || echo "")
Description: Complete OpSec software suite containing Mullvad VPN, Mullvad Browser, and Proton Mail.
EOF
    gzip -9c Packages > Packages.gz
fi

echo "deb [trusted=yes] file:${REPO_DIR} ./" > /etc/apt/sources.list.d/opsec-software.list

apt-get update -o Dir::Etc::sourcelist="sources.list.d/opsec-software.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" || apt-get update || true

echo ""
echo "OpSec repository configured successfully."
echo "You can now run: sudo apt install opsec-software"
echo ""

if [ "$1" = "--install" ] || [ "$1" = "-i" ]; then
    apt-get install -y --allow-unauthenticated opsec-software
fi

exit 0
