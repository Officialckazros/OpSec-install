#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_ISO="${ROOT_DIR}/opsecOS-1.0.0-amd64.iso"

if [ "$(uname -s)" = "Darwin" ]; then
    echo "ERROR: Building the opsecOS ISO requires Linux (Debian/Ubuntu)."
    echo ""
    echo "Options:"
    echo "  1. Push a tag to trigger the GitHub Actions build:"
    echo "     git tag v1.0.0 && git push origin v1.0.0"
    echo ""
    echo "  2. Run the workflow manually from the Actions tab:"
    echo "     https://github.com/Officialckazros/OpSec-install/actions"
    echo ""
    echo "  3. Build on a Linux machine or VM:"
    echo "     sudo apt install live-build debootstrap xorriso syslinux-efi"
    echo "     ./iso-builder/build-iso.sh"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root: sudo ./iso-builder/build-iso.sh"
    exit 1
fi

for dep in lb debootstrap xorriso; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Missing dependency: $dep"
        echo "Install with: sudo apt install live-build debootstrap xorriso isolinux syslinux-efi grub-pc-bin grub-efi-amd64-bin mtools dosfstools squashfs-tools"
        exit 1
    fi
done

chmod +x "${ROOT_DIR}/build-repo.sh"
"${ROOT_DIR}/build-repo.sh"

BUILD_DIR="/tmp/opsec-live-build"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# live-build's auto security repo emits the legacy "<distro>/updates" suite
# (404s on current Debian); the hook below writes the correct trixie-security
# source into the image instead.
# live-build's auto security repo emits the legacy "<distro>/updates" suite
# (404s on current Debian); the hook below writes the correct trixie-security
# source into the image instead.
# Also: debootstrap base lacks full gpg, so install gnupg via
# --debootstrap-options so the first chroot apt-get update can verify signatures.
lb config \
    --architecture amd64 \
    --distribution trixie \
    --debootstrap-options "--include=gnupg,gpgv" \
    --archive-areas "main contrib non-free non-free-firmware" \
    --binary-images iso-hybrid \
    --bootloader syslinux \
    --debian-installer none \
    --memtest none \
    --security false \
    --iso-application "opsecOS" \
    --iso-publisher "ckazros" \
    --iso-volume "opsecOS-1.0.0" \
    --apt-indices false \
    --cache true

mkdir -p config/package-lists
cat > config/package-lists/opsec.list.chroot << 'EOF'
linux-image-amd64
live-boot
live-config
live-config-systemd
systemd-sysv
firmware-linux-free
xorg
xserver-xorg
xinit
openbox
picom
python3
python3-tk
feh
x11-xserver-utils
rofi
tint2
lightdm
lightdm-gtk-greeter
curl
wget
gnupg
apt-transport-https
ca-certificates
lsb-release
xz-utils
desktop-file-utils
ufw
iptables
macchanger
network-manager
network-manager-gnome
pulseaudio
pavucontrol
xfce4-terminal
thunar
sudo
EOF

mkdir -p config/packages.chroot
cp "${ROOT_DIR}/apt-repo/opsec_1.0.0_all.deb" config/packages.chroot/
cp "${ROOT_DIR}/apt-repo/opsec-software_1.0.0_all.deb" config/packages.chroot/
cp "${ROOT_DIR}/apt-repo/opsec-de_1.0.0_all.deb" config/packages.chroot/

mkdir -p config/includes.chroot/etc/sysctl.d
cp "${ROOT_DIR}/opsec-os/security/99-opsec-security.conf" config/includes.chroot/etc/sysctl.d/

mkdir -p config/includes.chroot/usr/local/sbin
cp "${ROOT_DIR}/opsec-os/security/opsec-firewall.sh" config/includes.chroot/usr/local/sbin/
cp "${ROOT_DIR}/opsec-os/security/mac-spoof.sh" config/includes.chroot/usr/local/sbin/
chmod +x config/includes.chroot/usr/local/sbin/*.sh

mkdir -p config/includes.chroot/etc/lightdm/lightdm.conf.d
cat > config/includes.chroot/etc/lightdm/lightdm.conf.d/90-autologin.conf << 'EOF'
[Seat:*]
autologin-user=user
autologin-session=opsecDE
user-session=opsecDE
EOF

mkdir -p config/hooks/normal
cat > config/hooks/normal/0500-opsec-setup.hook.chroot << 'HOOKEOF'
#!/bin/bash
set -e

sysctl --system 2>/dev/null || true

chmod +x /usr/local/sbin/opsec-firewall.sh 2>/dev/null || true
chmod +x /usr/local/sbin/mac-spoof.sh 2>/dev/null || true

useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev,cdrom user 2>/dev/null || true
echo "user:live" | chpasswd
echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/opsec-live
chmod 440 /etc/sudoers.d/opsec-live

mkdir -p /etc/skel/Desktop

cat > /etc/skel/Desktop/mullvad-browser.desktop << 'DTEOF'
[Desktop Entry]
Type=Application
Name=Mullvad Browser
Exec=/usr/bin/mullvad-browser %U
Icon=/opt/mullvad-browser/browser/chrome/icons/default/default128.png
Terminal=false
Categories=Network;WebBrowser;Security;
DTEOF

cat > /etc/skel/Desktop/opsec-control-center.desktop << 'DTEOF2'
[Desktop Entry]
Type=Application
Name=OpSec Control Center
Exec=/usr/bin/opsec-control-center
Icon=preferences-system
Terminal=false
Categories=System;Security;
DTEOF2

chmod +x /etc/skel/Desktop/*.desktop 2>/dev/null || true

if [ -d /home/user ]; then
    cp -r /etc/skel/Desktop /home/user/Desktop 2>/dev/null || true
    chown -R user:user /home/user 2>/dev/null || true
fi

# Correct apt sources for the installed image (trixie + updates + security).
cat > /etc/apt/sources.list << 'APTSRC'
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
APTSRC
cat > /etc/os-release << 'OSEOF'
PRETTY_NAME="opsecOS 1.0.0"
NAME="opsecOS"
VERSION_ID="1.0.0"
VERSION="1.0.0 (Trixie)"
ID=opsecos
ID_LIKE=debian
HOME_URL="https://github.com/Officialckazros/OpSec-install"
BUG_REPORT_URL="https://github.com/Officialckazros/OpSec-install/issues"
OSEOF

echo "opsecOS 1.0.0" > /etc/opsec-release
HOOKEOF
chmod +x config/hooks/normal/0500-opsec-setup.hook.chroot

lb build

ISO_FILE=$(ls *.iso 2>/dev/null | head -1)
if [ -n "${ISO_FILE}" ]; then
    cp "${ISO_FILE}" "${OUTPUT_ISO}"
    echo ""
    echo "ISO built successfully: ${OUTPUT_ISO}"
    echo "Size: $(du -h "${OUTPUT_ISO}" | cut -f1)"
    echo ""
    echo "Write to USB:"
    echo "  sudo dd if=${OUTPUT_ISO} of=/dev/sdX bs=4M status=progress oflag=sync"
else
    echo "ERROR: ISO build failed - no .iso file produced"
    exit 1
fi

rm -rf "${BUILD_DIR}"

exit 0
