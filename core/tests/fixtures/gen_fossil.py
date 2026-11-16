#!/usr/bin/env python3
"""Writes the fixtures of core/tests/test_feat_35_6_10.cob (the fossil feature) into core/tests/fixtures/fossil: structure templates (gzip NBT, layout of
docs/protocol/36-structures-2 section 1.2, synthetic values) f1 (3 x 2 x 5), f2 (2 x 1 x 3) and their overlays o1, o2 of the same sizes, and the data features."""
import gzip, json, os, struct

def name(s):
    b = s.encode()
    return struct.pack(">H", len(b)) + b
def tag(t, n, payload): return bytes([t]) + name(n) + payload
def string(n, v): return tag(8, n, name(v))
def integer(n, v): return tag(3, n, struct.pack(">i", v))
def comp(n, *c): return tag(10, n, b"".join(c) + b"\x00")
def body_comp(*c): return b"".join(c) + b"\x00"
def lst(n, et, items): return tag(9, n, bytes([et]) + struct.pack(">i", len(items)) + b"".join(items))
def int_list(n, vs): return lst(n, 3, [struct.pack(">i", v) for v in vs])
def state(id_): return body_comp(string("id", id_))
def block(pos, st): return body_comp(int_list("pos", pos), integer("state", st))

base = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fossil", "data", "minecraft")
sroot = os.path.join(base, "structure", "fossil")
froot = os.path.join(base, "worldgen", "feature")
os.makedirs(sroot, exist_ok=True)
os.makedirs(froot, exist_ok=True)

def write(path, size, blocks):
    with gzip.GzipFile(os.path.join(sroot, path + ".nbt"), "wb", mtime=0) as f:
        f.write(comp("", integer("DataVersion", 5023), int_list("size", size),
                     lst("blocks", 10, [block(p, s) for p, s in blocks]),
                     lst("palette", 10, [state("minecraft:iron_block"), state("minecraft:diamond_block")])))

# palette 0 iron, 1 diamond
write("f1", [3, 2, 5], [([0, 0, 0], 0), ([2, 1, 4], 1), ([1, 0, 2], 0)])
write("o1", [3, 2, 5], [([1, 1, 2], 1), ([0, 1, 0], 0)])
write("f2", [2, 1, 3], [([0, 0, 0], 0), ([1, 0, 2], 0)])
write("o2", [2, 1, 3], [([1, 0, 0], 1)])

def rule(frm, to):
    return {"processors": [{"processor_type": "minecraft:rule", "rules": [{
        "input_predicate": {"predicate_type": "minecraft:block_match", "block": "minecraft:" + frm},
        "location_predicate": {"predicate_type": "minecraft:always_true"},
        "output_state": "minecraft:" + to}]}]}

def feat(fname, **kw):
    d = {"type": "minecraft:fossil", "fossil_structures": ["minecraft:fossil/f1", "minecraft:fossil/f2"],
         "overlay_structures": ["minecraft:fossil/o1", "minecraft:fossil/o2"],
         "fossil_processors": rule("iron_block", "gold_block"), "overlay_processors": rule("diamond_block", "emerald_block"),
         "max_empty_corners_allowed": 4}
    d.update(kw)
    for k in [k for k, v in d.items() if v is None]: del d[k]
    with open(os.path.join(froot, fname + ".json"), "w") as f: json.dump(d, f)

feat("fossil_t")
feat("fossil_t1", max_empty_corners_allowed=1)
feat("fossil_badlen", overlay_structures=["minecraft:fossil/o1"])
feat("fossil_missing", fossil_structures=["minecraft:fossil/f1", "minecraft:fossil/nope"])
feat("fossil_badproc", fossil_processors="minecraft:no_such_list")
feat("fossil_badmax", max_empty_corners_allowed=8)
feat("fossil_nooverlay", overlay_structures=None)
feat("fossil_empty", fossil_structures=[], overlay_structures=[])
feat("fossil_noproc", overlay_processors=None)
feat("fossil_nonstring", fossil_structures=[5, 6])
