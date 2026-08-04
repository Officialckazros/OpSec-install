# OpSec Install, opsecOS & opsecDE

Automated Debian/Ubuntu repository for installing privacy and operational security software via `sudo apt install opsec`, featuring `opsecOS` security Linux distribution and `opsecDE` (OpSec Desktop Environment).

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

To build the bootable `opsecOS-1.0.0-amd64.iso` image containing `opsecDE`:

```bash
make iso
```

Output: `opsecOS-1.0.0-amd64.iso`
