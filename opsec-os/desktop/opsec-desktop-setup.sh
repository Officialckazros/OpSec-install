#!/bin/bash
set -e

mkdir -p /etc/skel/Desktop /etc/skel/.config

cat <<EOF > /etc/skel/Desktop/mullvad-browser.desktop
[Desktop Entry]
Type=Application
Name=Mullvad Browser
Exec=/usr/bin/mullvad-browser %U
Icon=/opt/mullvad-browser/browser/chrome/icons/default/default128.png
Terminal=false
Categories=Network;WebBrowser;Security;
EOF

cat <<EOF > /etc/skel/Desktop/opsec-status.desktop
[Desktop Entry]
Type=Application
Name=OpSec Status
Exec=/usr/bin/opsec
Icon=utilities-terminal
Terminal=true
Categories=System;Security;
EOF

chmod +x /etc/skel/Desktop/*.desktop 2>/dev/null || true

exit 0
