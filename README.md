# OpSec Install, opsecOS & opsecDE

Automated Debian/Ubuntu repository for installing privacy and operational security software via `sudo apt install opsec`, featuring `opsecOS` security Linux distribution and `opsecDE` (OpSec Desktop Environment).

## opsecOS Live ISO

Download the latest bootable ISO from [GitHub Releases](https://github.com/Officialckazros/OpSec-install/releases).

### Write to USB

```bash
sudo dd if=opsecOS-1.0.0-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Or use [Balena Etcher](https://etcher.balena.io/) for a graphical tool.

**Default credentials:** user / live

### What's Inside

- Debian 12 (Bookworm) base with live-boot
- opsecDE desktop environment (Openbox, opsec-panel, opsec-control-center)
- Mullvad VPN (auto-configured repository)
- Mullvad Browser (privacy-focused web browser)
- Proton Mail (desktop client)
- Kernel sysctl hardening (99-opsec-security.conf)
- UFW firewall (deny incoming, allow VPN ports)
- MAC address randomization on boot
- Auto-login to opsecDE session

## Included Software Suite

- **Mullvad VPN**: Official Mullvad VPN APT package and repository configuration.
- **Mullvad Browser**: Privacy-focused web browser binary, system integration, and `.desktop` shortcut.
- **Proton Mail**: Desktop client for Proton Mail.

## opsecDE (OpSec Desktop Environment)

`opsecDE` is a custom Linux Desktop Environment designed specifically for operational security:

- **opsec-session**: Custom X11 session launcher registered in `/usr/share/xsessions/opsecde.desktop`.
- **opsec-panel**: Top desktop status bar featuring real-time Mullvad VPN indicator, strict firewall shield indicator, launcher shortcuts, and resource monitor.
- **opsec-control-center**: Graphical security control dashboard for managing VPN connections, randomizing MAC addresses, and enforcing strict lockdown rules.

---

## Direct APT Installation (Without Git Clone)

### One-Line Automated Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Officialckazros/OpSec-install/main/install.sh | sudo bash
```

### Install opsecDE Desktop Environment via APT

```bash
curl -fsSL https://raw.githubusercontent.com/Officialckazros/OpSec-install/main/add-repo.sh | sudo bash
sudo apt install opsec-de
```

---

## Building opsecOS Live ISO

The ISO is automatically built by GitHub Actions when a version tag is pushed:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow can also be triggered manually from the [Actions tab](https://github.com/Officialckazros/OpSec-install/actions).

### Local Build (Linux Only)

```bash
sudo apt install live-build debootstrap xorriso isolinux syslinux-efi grub-pc-bin grub-efi-amd64-bin mtools dosfstools squashfs-tools
sudo ./iso-builder/build-iso.sh
```

### Local Build on macOS (Docker)

No Linux VM needed — builds the real ISO inside a Debian container:

```bash
brew install --cask docker   # or: brew install colima docker && colima start
./iso-builder/docker-build-iso.sh
# or: make docker-iso
```

Output: `opsecOS-1.0.0-amd64.iso`
