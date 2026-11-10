#!/usr/bin/env python3
"""Independent encoder of the chunk data of docs/protocol/06 (sections 3 to 6) for the chunk (-1, 2) of the veins fixture of
core/tests/test_ore_veins.cob: heightmaps (types 1, 4, 5), then the section buffer with its VarInt length. The states are the
fixture's worked example: stone below y -32, the vein rule of expected.py from -32 to -1 (copper ore 50, raw 51, granite 52),
sea water (86) from 0 to 62, air above; one biome (id 0). Writes chunk-data.hex (lowercase, 64 bytes a line after a comment line)."""
import expected as e
def varint(v):
    out = bytearray()
    while True:
        b = v & 0x7F
        v >>= 7
        if v: out.append(b | 0x80)
        else:
            out.append(b); return bytes(out)
def packed(values, bits):
    per = 64 // bits
    longs = []
    for i in range(0, len(values), per):
        w = 0
        for j, v in enumerate(values[i:i + per]):
            w |= v << (j * bits)
        longs.append(w)
    return b"".join(w.to_bytes(8, "big") for w in longs)
def state(fac, x, y, z):
    if y < -32: return 1
    if y < 0:
        v = e.rule(fac, x, y, z, e.f32(0.7), 0.5, -1.0, 0.25, 50, 51, 52)
        return v if v >= 0 else 1
    if y < 63: return 86
    return 0
def container(values, global_bits):
    distinct = []
    for v in values:
        if v not in distinct: distinct.append(v)
    if len(distinct) == 1:
        return bytes([0]) + varint(distinct[0]) + b""
    bits = max(4, (len(distinct) - 1).bit_length())
    if len(distinct) > 256:
        return bytes([global_bits]) + packed(values, global_bits)
    return bytes([bits]) + varint(len(distinct)) + b"".join(varint(d) for d in distinct) + packed([distinct.index(v) for v in values], bits)
fac = e.ore_factory(7)
sections = bytearray()
for s in range(24):
    vals = []
    for y in range(16):
        for z in range(16):
            for x in range(16):
                vals.append(state(fac, -16 + x, -64 + s * 16 + y, 32 + z))
    non_air = sum(1 for v in vals if v != 0)
    fluid = sum(1 for v in vals if v == 86)
    sections += non_air.to_bytes(2, "big") + fluid.to_bytes(2, "big")
    sections += container(vals, 15)
    sections += container([0] * 64, 6)
out = bytearray(varint(3))
hm = packed([127] * 256, 9)
for t in (1, 4, 5):
    out += varint(t) + varint(37) + hm
out += varint(len(sections)) + sections
h = out.hex()
open("chunk-data.hex", "w").write("# chunk data of the chunk (-1, 2) of the veins fixture (heightmaps, section buffer), 64 bytes a line\n"
    + "\n".join(h[i:i + 128] for i in range(0, len(h), 128)) + "\n")
print(len(out), "bytes")
