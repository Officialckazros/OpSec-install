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

> **Note on testing:** the desktop features below (dock, control center, app
> launchers, firewall/MAC controls) were validated in the **live ISO**
> environment rather than a full install to disk, because earlier builds had no
> installer. That is fixed now — the ISO ships a **full graphical installer**
> ("Install opsecOS" on the desktop / dock), so you can install to disk and the
> same opsecDE experience is carried over.

### Install to disk (full GUI)

Boot the ISO and click **"Install opsecOS"** on the desktop (or the dock/panel).
The complete Debian GTK installer launches — pick your language, disk layout,
user account and password. When it finishes, the opsec suite (`opsec`,
`opsec-de`) is installed automatically into the new system.

### What's Inside

- Debian 13 (Trixie) base with live-boot
- opsecDE desktop environment (Openbox + opsec-panel + opsec-control-center)
- **Plank dock** with pinned launchers (browser, mail, terminal, files, …)
- **Conky** live system monitor and **Dunst** notifications ("alive" desktop)
- Mullvad VPN (auto-configured repository)
- Mullvad Browser (privacy-focused web browser)
- Proton Mail (desktop client)
- Kernel sysctl hardening (99-opsec-security.conf)
- UFW firewall (deny incoming, allow VPN ports)
- MAC address randomization on boot
- Auto-login to opsecDE session
- Pre-installed **debugging & security tools**: `gdb`, `strace`, `ltrace`,
  `htop`, `btop`, `nmap`, `tcpdump`, `wireshark`, `nikto`, `hydra`, `sqlmap`,
  `netcat`, `socat`, `dnsutils`, `whois`, `git`, `vim`, `ripgrep`, `jq`, `tmux`,
  and more.

## Included Software Suite

- **Mullvad VPN**: Official Mullvad VPN APT package and repository configuration.
- **Mullvad Browser**: Privacy-focused web browser binary, system integration, and `.desktop` shortcut.
- **Proton Mail**: Desktop client for Proton Mail.

## opsecDE (OpSec Desktop Environment)

`opsecDE` is a custom Linux Desktop Environment designed specifically for operational security:

- **opsec-session**: Custom X11 session launcher registered in `/usr/share/xsessions/opsecde.desktop`.
- **opsec-panel**: Top desktop status bar featuring real-time Mullvad VPN indicator, strict firewall shield indicator, launcher shortcuts, and an "Install opsecOS" button.
- **opsec-control-center**: Graphical security control dashboard for managing VPN connections, randomizing MAC addresses, enforcing strict lockdown rules, launching apps and refreshing the software suite.
- **Plank dock**: bottom dock with pinned launchers for the browser, mail, terminal, file manager, status scan and installer.
- **Conky + Dunst + welcome notification**: live system monitor, notification daemon and a first-login greeting to make the desktop feel alive.
- **Wallpaper**: custom dark privacy-themed wallpaper shipped in the package.

---

## Direct APT Installation (Without Git Clone)

The APT repository is served from GitHub Pages at
`https://officialckazros.github.io/OpSec-install/apt-repo`.

### One-Line Automated Installation

```bash
curl -fsSL https://officialckazros.github.io/OpSec-install/install.sh | sudo bash
```

Adds the opsec APT repository and installs the `opsec` meta-package.

### Install Individual Packages via APT

```bash
curl -fsSL https://officialckazros.github.io/OpSec-install/add-repo.sh | sudo bash
sudo apt install opsec          # OpSec suite (Mullvad VPN, Mullvad Browser, Proton Mail)
sudo apt install opsec-de       # opsecDE desktop environment
sudo apt install opsec-software # OpSec software suite
```

### Install Directly from a .deb (No Repo, No Git, No One-Liner)

Grab the package file and install it — dependencies are pulled from the distro's
normal repositories, so nothing else is needed:

```bash
wget https://officialckazros.github.io/OpSec-install/apt-repo/opsec_1.0.0_all.deb
sudo apt install ./opsec_1.0.0_all.deb
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
