#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

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
# Note: some live-build versions reject --debootstrap-options, so gnupg is not
# injected via debootstrap; the build uses --apt-secure false instead.
# The Debian GTK installer is embedded (--debian-installer live) so the live
# desktop has a full graphical "Install opsecOS" launcher, and the preseed at
# config/includes.installer/preseed.cfg (auto-detected by live-build) installs
# the opsec packages into the installed system.
lb config \
    --architecture amd64 \
    --distribution trixie \
    --archive-areas "main contrib non-free non-free-firmware" \
    --binary-images iso-hybrid \
    --bootloader grub-efi \
    --debian-installer live \
    --debian-installer-gui true \
    --debian-installer-distribution trixie \
    --memtest none \
    --security false \
    --iso-application "opsecOS" \
    --iso-publisher "ckazros" \
    --iso-volume "opsecOS-1.0.0" \
    --apt-indices false \
    --apt-secure false \
    --cache true

mkdir -p config/package-lists
cat > config/package-lists/opsec.list.chroot << 'EOF'
# --- Base system / session ---
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
lightdm
lightdm-gtk-greeter
sudo
polkitd
pkexec
desktop-file-utils
xdg-utils
x11-utils
xfce4-taskmanager
pcmanfm

# --- Dock / desktop polish ("alive") ---
plank
conky-std
dunst
libnotify-bin
papirus-icon-theme
i3lock
scrot
fonts-noto-core
fonts-noto-color-emoji

# --- Network / apps ---
network-manager
pulseaudio
pavucontrol
xfce4-terminal
curl
wget
gnupg
apt-transport-https
ca-certificates
lsb-release
xz-utils
git
openssh-client

# --- Security / OpSec tooling ---
ufw
iptables
macchanger
nmap
netcat-openbsd
tcpdump
tshark
nikto
hydra
sqlmap
bind9-dnsutils
whois
socat
net-tools
debian-installer-launcher

# --- Debugging / analysis ---
gdb
strace
ltrace
htop
btop
sysstat
lsof
file
binutils
tmux
ripgrep
fd-find
jq
vim
nano
tree
unzip
p7zip-full
EOF

# Install the opsec .debs via the chroot hook (dpkg -i) instead of live-build's
# local apt repo, which needs an unsigned repo to be trusted.
mkdir -p config/includes.chroot/root/opsec-debs
cp "${ROOT_DIR}/apt-repo/opsec_1.0.0_all.deb" config/includes.chroot/root/opsec-debs/
cp "${ROOT_DIR}/apt-repo/opsec-software_1.0.0_all.deb" config/includes.chroot/root/opsec-debs/
cp "${ROOT_DIR}/apt-repo/opsec-de_1.0.0_all.deb" config/includes.chroot/root/opsec-debs/

# Preseed for the embedded Debian installer: kept in config/includes.installer/
# (the documented location), so live-build auto-detects it and wires it into
# the installer. It keeps the GUI fully interactive while installing the opsec
# suite into the target system at the end.
mkdir -p config/includes.installer
cp "${ROOT_DIR}/iso-builder/preseed.cfg" config/includes.installer/preseed.cfg

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

# Install the opsec packages (deps are provided by the package list).
# The opsec-de package ships the opsecDE skel configs (/etc/skel), so the
# live user's home is populated from /etc/skel below.
if ls /root/opsec-debs/*.deb >/dev/null 2>&1; then
    dpkg -i /root/opsec-debs/opsec_1.0.0_all.deb \
           /root/opsec-debs/opsec-software_1.0.0_all.deb \
           /root/opsec-debs/opsec-de_1.0.0_all.deb || apt-get -f install -y
    rm -rf /root/opsec-debs
fi

sysctl --system 2>/dev/null || true

useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev,cdrom user 2>/dev/null || true
echo "user:live" | chpasswd
echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/opsec-live
chmod 440 /etc/sudoers.d/opsec-live

# Apply the skel config (DE, dock, wallpaper, desktop shortcuts) to the live user.
if [ -d /home/user ]; then
    cp -a /etc/skel/. /home/user/ 2>/dev/null || true
    chown -R user:user /home/user 2>/dev/null || true
fi

# Correct apt sources for the installed image (trixie + updates + security).
cat > /etc/apt/sources.list << 'APTSRC'
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
APTSRC
# Re-enable strict apt signature verification in the installed image
# (the build uses --apt-secure false to avoid needing gpg in-chroot).
cat > /etc/apt/apt.conf.d/99opsec-secure << 'APTCONF'
APT::Get::AllowUnauthenticated "false";
APTCONF
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
    # Always drop a copy of the finished ISO into the user's Downloads folder.
    if [ -d "${HOME}/Downloads" ] || mkdir -p "${HOME}/Downloads" 2>/dev/null; then
        cp -f "${OUTPUT_ISO}" "${HOME}/Downloads/" 2>/dev/null \
            && echo "Copied to: ${HOME}/Downloads/$(basename "${OUTPUT_ISO}")" || true
    fi
    echo ""
    echo "Write to USB:"
    echo "  sudo dd if=${OUTPUT_ISO} of=/dev/sdX bs=4M status=progress oflag=sync"
else
    echo "ERROR: ISO build failed - no .iso file produced"
    exit 1
fi

rm -rf "${BUILD_DIR}"

exit 0
