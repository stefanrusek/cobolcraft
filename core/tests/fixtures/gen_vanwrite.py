#!/usr/bin/env python3
"""usage: gen_vanwrite.py DIR. Writes into DIR the folder an old CobolCraft build left behind after it opened a real 26.3
world: a flat level.dat (WorldType standard, no Data compound) and the real file as level.dat_old (Data with a key the core
does not model). Synthetic values."""
import gzip, os, struct, sys

def name(s):
    b = s.encode()
    return struct.pack(">H", len(b)) + b
def tag(t, n, payload): return bytes([t]) + name(n) + payload
def string(n, v): return tag(8, n, name(v))
def integer(n, v): return tag(3, n, struct.pack(">i", v))
def long_(n, v): return tag(4, n, struct.pack(">q", v))
def flt(n, v): return tag(5, n, struct.pack(">f", v))
def byte(n, v): return tag(1, n, bytes([v]))
def ints(n, vs): return tag(11, n, struct.pack(">i", len(vs)) + b"".join(struct.pack(">i", v) for v in vs))
def strings(n, vs): return tag(9, n, bytes([8]) + struct.pack(">i", len(vs)) + b"".join(name(v) for v in vs))
def intlist(n, vs): return tag(9, n, bytes([3]) + struct.pack(">i", len(vs)) + b"".join(struct.pack(">i", v) for v in vs))
def comp(n, *c): return tag(10, n, b"".join(c) + b"\x00")

out = sys.argv[1]
os.makedirs(out, exist_ok=True)
files = {
 "level.dat": comp("", integer("DataVersion", 5023), string("LevelName", "Flat Standard"), string("WorldType", "standard"),
    long_("Seed", 424242), integer("GameMode", 0), long_("Time", 500)),
 "level.dat_old": comp("", comp("Data",
    comp("Version", integer("Id", 5015), string("Name", "26.3 Snapshot 10"), string("Series", "main"), byte("Snapshot", 1)),
    integer("DataVersion", 5015), integer("GameType", 0), intlist("version_history", [5015]),
    byte("initialized", 1), byte("allowCommands", 1), byte("WasModded", 0), strings("ServerBrands", ["vanilla"]),
    comp("difficulty_settings", string("difficulty", "normal"), byte("hardcore", 0), byte("locked", 0)),
    comp("DataPacks", strings("Enabled", ["vanilla"]), strings("Disabled", ["trade_rebalance"])),
    comp("spawn", string("dimension", "minecraft:overworld"), flt("pitch", 0.0), ints("pos", [2, -60, 2]), flt("yaw", 0.0)),
    long_("Time", 10946), string("LevelName", "Flat Standard"), integer("version", 19133),
    comp("UnknownBlock", integer("keep", 77)))),
}
for path, data in files.items():
    with gzip.GzipFile(os.path.join(out, path), "wb", mtime=0) as f:
        f.write(data)
