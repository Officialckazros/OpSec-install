# OpSec Install & opsecOS

Automated Debian/Ubuntu repository for installing privacy and operational security software via `sudo apt install opsec`, plus `opsecOS` security-focused Linux Live ISO builder.

## Included Software Suite

- **Mullvad VPN**: Official Mullvad VPN APT package and repository configuration.
- **Mullvad Browser**: Privacy-focused web browser binary, system integration, and `.desktop` shortcut.
- **Proton Mail**: Desktop client for Proton Mail.

## opsecOS Distribution & Security Features

`opsecOS` is a security-hardened Linux OS image pre-loaded with the OpSec software suite:

- **Kernel Hardening**: ASLR level 2, `kptr_restrict=2`, `dmesg_restrict=1`, `yama.ptrace_scope=2`, TCP SYN cookie protection, ICMP redirect rejection, and filesystem link protection (`/etc/sysctl.d/99-opsec-security.conf`).
- **Firewall & Privacy**: Default-deny incoming firewall policy (UFW/iptables), DNS leak protection, and automated boot-time MAC address spoofing (`macchanger`).
- **Desktop Environment**: Lightweight XFCE desktop environment pre-configured with OpSec dark theme and desktop shortcuts.

---

## Direct APT Installation (Without Git Clone)

### One-Line Automated Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Officialckazros/OpSec-install/main/install.sh | sudo bash
```

### Register Repository for `sudo apt install opsec`

```bash
curl -fsSL https://raw.githubusercontent.com/Officialckazros/OpSec-install/main/add-repo.sh | sudo bash
```

Then install anytime via standard `apt`:

```bash
sudo apt install opsec
```

---

## Building opsecOS Live ISO

To build the bootable `opsecOS-1.0.0-amd64.iso` image:

```bash
make iso
```

Output: `opsecOS-1.0.0-amd64.iso`
