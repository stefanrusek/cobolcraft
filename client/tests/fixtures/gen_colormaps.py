#!/usr/bin/env python3
"""Writes the three 256 x 256 RGB colormap fixtures of mini-vanilla (test infrastructure): the pixel at
column x, row y is (x, y, k) with k 1 for grass, 2 for foliage and 3 for dry foliage."""
import struct, zlib, os
out = os.path.join(os.path.dirname(__file__), "mini-vanilla/assets/minecraft/textures/colormap")
def chunk(t, d):
    c = struct.pack(">I", len(d)) + t + d
    return c + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
for name, k in (("grass", 1), ("foliage", 2), ("dry_foliage", 3)):
    raw = b"".join(b"\x00" + b"".join(bytes((x, y, k)) for x in range(256)) for y in range(256))
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 256, 256, 8, 2, 0, 0, 0)) \
        + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b"")
    open(os.path.join(out, name + ".png"), "wb").write(png)
