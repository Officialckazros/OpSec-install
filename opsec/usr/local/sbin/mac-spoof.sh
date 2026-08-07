#!/bin/bash
# Randomize the MAC address of every physical network interface.
# Must run as root (launched via pkexec/sudo from the control center).
set +e

if ! command -v macchanger >/dev/null 2>&1; then
    echo "macchanger is not installed." >&2
    exit 1
fi

found=0
for iface in $(ip -o link show 2>/dev/null | grep -E ' (en|eth|wlan|wifi|wwan)' | awk -F': ' '{print $2}' | awk '{print $1}'); do
    ip link set "$iface" down 2>/dev/null || continue
    if macchanger -r "$iface" >/dev/null 2>&1; then
        echo "Randomized MAC on $iface"
        found=1
    fi
    ip link set "$iface" up 2>/dev/null
done

if [ "$found" -eq 1 ]; then
    echo "MAC addresses randomized."
    exit 0
fi

echo "No physical interfaces found to randomize." >&2
exit 1
