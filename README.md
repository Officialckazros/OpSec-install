# OpSec Install

Automated Debian/Ubuntu repository for installing privacy and operational security software via `sudo apt install opsec`.

## Included Software

- **Mullvad VPN**: Official Mullvad VPN APT package and repository configuration.
- **Mullvad Browser**: Privacy-focused web browser binary, system integration, and `.desktop` shortcut.
- **Proton Mail**: Desktop client for Proton Mail.

## Direct Installation (Without Git Clone)

### One-Line Automated Installation

To install `opsec` directly in a single command without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/Officialckazros/OpSec-install/main/install.sh | sudo bash
```

### Register Repository for `sudo apt install opsec`

To add the online APT repository so `sudo apt install opsec` works natively in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/Officialckazros/OpSec-install/main/add-repo.sh | sudo bash
```

Then install anytime via standard `apt`:

```bash
sudo apt install opsec
```

*(Note: `sudo apt install opsec-software` is also supported as an alias package).*

---

## Installation via Git Clone

If you cloned the repository locally:

```bash
git clone https://github.com/Officialckazros/OpSec-install.git
cd OpSec-install
sudo ./install.sh
```

## CLI Status Verification

After installation, verify installed tools using the included CLI utility:

```bash
opsec
```

## Building Repository

To rebuild `.deb` packages and the APT index:

```bash
make build
```
