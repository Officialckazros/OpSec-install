#!/bin/bash
# Enforce strict firewall rules (UFW + iptables).
# Must run as root (launched via pkexec/sudo from the control center).
# Uses set +e so a single failing rule (e.g. no systemd for ufw) doesn't
# abort the whole enforcement.
set +e

fail=0

if command -v ufw >/dev/null 2>&1; then
    ufw --force reset >/dev/null 2>&1
    ufw default deny incoming >/dev/null 2>&1 || fail=1
    ufw default allow outgoing >/dev/null 2>&1 || fail=1
    ufw allow out 53/udp >/dev/null 2>&1
    ufw allow out 53/tcp >/dev/null 2>&1
    ufw allow out 1194/udp >/dev/null 2>&1
    ufw allow out 51820/udp >/dev/null 2>&1
    ufw --force enable >/dev/null 2>&1 || fail=1
fi

if command -v iptables >/dev/null 2>&1; then
    iptables -F 2>/dev/null
    iptables -X 2>/dev/null
    iptables -P INPUT DROP 2>/dev/null || fail=1
    iptables -P FORWARD DROP 2>/dev/null || fail=1
    iptables -P OUTPUT ACCEPT 2>/dev/null || fail=1
    iptables -A INPUT -i lo -j ACCEPT 2>/dev/null
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
fi

if [ "$fail" -ne 0 ]; then
    echo "Firewall enforced with warnings (some rules may not apply)." >&2
    exit 1
fi

echo "Strict firewall rules enforced."
exit 0
