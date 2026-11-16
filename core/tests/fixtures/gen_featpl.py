#!/usr/bin/env python3
"""Writes the structure template fixtures of core/tests/test_feat_35_5_17.cob (the template feature) into core/tests/fixtures/featpl/data/minecraft/structure/featpl:
gzip NBT in the layout of docs/protocol/36-structures-2 section 1.2, synthetic values. a: 3 x 1 x 5 with four blocks (asymmetric, so every rotation shows); b: 1 x 2 x 1."""
import gzip, os, struct

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

root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "featpl", "data", "minecraft", "structure", "featpl")
os.makedirs(root, exist_ok=True)
def write(path, *children):
    with gzip.GzipFile(os.path.join(root, path + ".nbt"), "wb", mtime=0) as f:
        f.write(comp("", *children))

write("a", integer("DataVersion", 5023), int_list("size", [3, 1, 5]),
      lst("blocks", 10, [block([0, 0, 0], 0), block([2, 0, 0], 1), block([0, 0, 4], 2), block([1, 0, 2], 0)]),
      lst("palette", 10, [state("minecraft:gold_block"), state("minecraft:iron_block"), state("minecraft:diamond_block")]))
write("b", integer("DataVersion", 5023), int_list("size", [1, 2, 1]),
      lst("blocks", 10, [block([0, 0, 0], 0), block([0, 1, 0], 1)]),
      lst("palette", 10, [state("minecraft:iron_block"), state("minecraft:diamond_block")]))
