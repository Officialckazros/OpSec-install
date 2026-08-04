#!/bin/bash
set -e

if command -v macchanger >/dev/null 2>&1; then
    for iface in $(ip link show | grep -E '^[0-9]+: (en|eth|wlan|wifi)' | awk -F': ' '{print $2}'); do
        ip link set "$iface" down 2>/dev/null || true
        macchanger -r "$iface" 2>/dev/null || true
        ip link set "$iface" up 2>/dev/null || true
    done
fi

exit 0
