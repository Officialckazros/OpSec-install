# OpSec Install

Automated Debian/Ubuntu packaging repository for installing privacy and operational security software via `sudo apt install opsec-software`.

## Included Software

- **Mullvad VPN**: Official Mullvad VPN APT package and repository configuration.
- **Mullvad Browser**: Privacy-focused web browser binary, system integration, and `.desktop` shortcut.
- **Proton Mail**: Desktop client for Proton Mail.

## Installation

### Quick Setup

Clone the repository and run the setup script:

```bash
git clone https://github.com/Officialckazros/OpSec-install.git
cd OpSec-install
sudo ./setup.sh
```

After running `setup.sh`, install the suite using standard `apt`:

```bash
sudo apt install opsec-software
```

Alternatively, to build, configure the repository, and install in a single step:

```bash
sudo ./install.sh
```

## CLI Status Verification

After installation, verify installed tools using the included CLI utility:

```bash
opsec-software
```

## Building Manually

To manually build the `.deb` package:

```bash
make build
```

