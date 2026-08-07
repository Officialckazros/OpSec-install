#!/usr/bin/env python3
"""Generate the opsecDE default wallpaper (1920x1080) using only the stdlib.

Writes a dark navy-to-teal gradient with a soft radial glow and a subtle
diagonal sheen — privacy-themed, calm on the eyes. Output is a PNG.

Usage: python3 tools/make-wallpaper.py [output.png]
"""

import os
import struct
import sys
import zlib

W, H = 1920, 1080


def lerp(a, b, t):
    return a + (b - a) * t


def clamp(v, lo=0.0, hi=1.0):
    return max(lo, min(hi, v))


def make_pixel(x, y):
    # Vertical gradient: deep navy (top) -> slate teal (bottom)
    t = y / (H - 1)
    r = lerp(0x0B, 0x16, t)
    g = lerp(0x12, 0x2A, t)
    b = lerp(0x20, 0x3A, t)

    # Soft radial glow near the top-center (teal accent)
    gx, gy, gr = W * 0.5, H * 0.32, H * 0.62
    dx = (x - gx) / gr
    dy = (y - gy) / gr
    d = (dx * dx + dy * dy) ** 0.5
    if d < 1.0:
        glow = (1.0 - d) ** 2 * 0.22
        r += 0x38 * glow * 0.18
        g += 0xBD * glow
        b += 0xF8 * glow

    # Subtle horizon glow near the bottom
    hy, hh = H * 0.82, H * 0.45
    hd = abs(y - hy) / hh
    if hd < 1.0:
        hglow = (1.0 - hd) ** 2 * 0.10
        r += 0x0E * hglow
        g += 0x3B * hglow
        b += 0x5E * hglow

    # Faint diagonal sheen (top-right to bottom-left)
    sheen = clamp(((x + y) / (W + H)) * 1.6 - 0.35)
    if sheen > 0:
        sheen *= 0.05
        r += 0x38 * sheen
        g += 0xBD * sheen
        b += 0xF8 * sheen

    # Very subtle vignette
    vx = (x - W / 2) / (W / 2)
    vy = (y - H / 2) / (H / 2)
    v = (vx * vx + vy * vy) ** 0.5 * 0.5
    v = clamp(v)
    factor = 1.0 - v * 0.18

    return (int(clamp(r / 255.0) * 255 * factor),
            int(clamp(g / 255.0) * 255 * factor),
            int(clamp(b / 255.0) * 255 * factor),
            255)


def write_png(path):
    rows = []
    for y in range(H):
        row = bytearray([0])  # filter type 0
        for x in range(W):
            row.extend(make_pixel(x, y))
        rows.append(bytes(row))

    raw = b"".join(rows)

    def chunk(tag, data):
        c = tag + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")

    with open(path, "wb") as f:
        f.write(png)
    print(f"Wrote {path} ({os.path.getsize(path)} bytes)")


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else "wallpaper.png"
    write_png(out)
