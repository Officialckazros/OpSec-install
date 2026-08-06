#!/bin/bash
set -e

# Build the opsecOS live ISO on macOS (or any host) using a Debian container.
# This is the local equivalent of the GitHub Actions workflow; it produces a
# real, bootable, multi-GB ISO at <repo>/opsecOS-1.0.0-amd64.iso.
#
# Requirements: Docker (Docker Desktop or colima). No Linux VM needed.
#
# Usage:
#   brew install --cask docker        # then start Docker Desktop
#   # or: brew install colima docker && colima start
#   ./iso-builder/docker-build-iso.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_ISO="${ROOT_DIR}/opsecOS-1.0.0-amd64.iso"

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker not found."
    echo "Install Docker Desktop:  brew install --cask docker"
    echo "  or colima + docker:    brew install colima docker && colima start"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon is not running."
    echo "Start Docker Desktop or run: colima start"
    exit 1
fi

echo "Building opsecOS ISO inside a Debian trixie container..."
echo "This downloads ~2 GB of packages and can take 20-60 minutes."
echo "Output will be written to: ${OUTPUT_ISO}"

docker run --rm --privileged \
    -v "${ROOT_DIR}:/src" \
    -w /src \
    debian:trixie \
    bash -c '
        set -e
        export DEBIAN_FRONTEND=noninteractive
        echo "== Installing live-build dependencies =="
        apt-get update
        apt-get install -y --no-install-recommends \
            live-build debootstrap xorriso isolinux syslinux-efi \
            grub-pc-bin grub-efi-amd64-bin mtools dosfstools squashfs-tools \
            ca-certificates curl gnupg python3 fakeroot apt-utils
        echo "== Building .deb packages =="
        /src/build-repo.sh
        echo "== Building ISO (lb build) =="
        /src/iso-builder/build-iso.sh
    '

if [ -f "${OUTPUT_ISO}" ]; then
    echo ""
    echo "SUCCESS: ISO built locally: ${OUTPUT_ISO}"
    echo "Size: $(du -h "${OUTPUT_ISO}" | cut -f1)"
else
    echo "ERROR: ISO build failed - no ISO produced."
    exit 1
fi
