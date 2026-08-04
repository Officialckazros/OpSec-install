#!/bin/bash
set -e

if command -v ufw >/dev/null 2>&1; then
    ufw --force reset || true
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow out 53/udp
    ufw allow out 53/tcp
    ufw allow out 1194/udp
    ufw allow out 51820/udp
    ufw --force enable || true
fi

if command -v iptables >/dev/null 2>&1; then
    iptables -F
    iptables -X
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
fi

exit 0
