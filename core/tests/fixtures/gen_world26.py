#!/usr/bin/env python3
"""Writes the small level.dat and world_gen_settings.dat of a world in the 26.3 layout (docs/protocol/33 section 10):
the root compound holds one compound `Data`; the seed lives in data/minecraft/world_gen_settings.dat. Synthetic values."""
import gzip, os, struct, sys

def name(s):
    b = s.encode()
    return struct.pack(">H", len(b)) + b

def tag(t, n, payload):
    return bytes([t]) + name(n) + payload

def string(n, v): return tag(8, n, name(v))
def integer(n, v): return tag(3, n, struct.pack(">i", v))
def long_(n, v): return tag(4, n, struct.pack(">q", v))
def flt(n, v): return tag(5, n, struct.pack(">f", v))
def byte(n, v): return tag(1, n, bytes([v]))
def ints(n, vs): return tag(11, n, struct.pack(">i", len(vs)) + b"".join(struct.pack(">i", v) for v in vs))
def comp(n, *children): return tag(10, n, b"".join(children) + b"\x00")

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "world26")
level = comp("", comp("Data",
    integer("DataVersion", 5023), integer("GameType", 1), string("LevelName", "Vanilla Fixture"),
    long_("Time", 76520),
    comp("spawn", string("dimension", "minecraft:overworld"), flt("pitch", 0.0), ints("pos", [12, 70, -34]), flt("yaw", 90.0)),
    comp("Version", integer("Id", 5023), string("Name", "26.3"))))
gen = comp("", integer("DataVersion", 5023), comp("data", byte("bonus_chest", 0), long_("seed", 7891309618905890105)))
for path, data in (("level.dat", level), ("data/minecraft/world_gen_settings.dat", gen)):
    with gzip.GzipFile(os.path.join(out, path), "wb", mtime=0) as f:
        f.write(data)

# A level.dat with neither WorldType nor Data (a refused world when the folder holds dimensions/minecraft).
os.makedirs(os.path.join(out, "..", "world26-untyped"), exist_ok=True)
with gzip.GzipFile(os.path.join(out, "..", "world26-untyped", "level.dat"), "wb", mtime=0) as f:
    f.write(comp("", string("LevelName", "Untyped"), integer("GameMode", 0)))
