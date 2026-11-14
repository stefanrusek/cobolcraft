#!/usr/bin/env python3
"""Writes the structure template fixtures of core/tests/test_struct_36_2_*.cob into core/tests/fixtures/tpl/data/<ns>/structure
(gzip NBT in the layout of docs/protocol/36-structures-2 section 1.2), built by hand from the schema: synthetic values."""
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
def state(id_=None, props=None, odd=False):
    ch = []
    if id_ is not None: ch.append(string("id", id_))
    if props: ch.append(comp("properties", *[string(k, v) for k, v in props], *([integer("n", 3)] if odd else [])))
    if odd: ch.append(integer("extra", 1))
    return body_comp(*ch)
def block(pos, st, nbt=False, extra=False):
    ch = [int_list("pos", pos), integer("state", st)]
    if extra: ch.append(integer("extra", 5))
    if nbt: ch.append(comp("nbt", string("id", "minecraft:chest")))
    return body_comp(*ch)

root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tpl", "data")
def write(ns, path, *children, raw=None):
    full = os.path.join(root, ns, "structure", path + ".nbt")
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with gzip.GzipFile(full, "wb", mtime=0) as f:
        f.write(raw if raw is not None else comp("", *children))

G, C, L = "cobolcraft:greystone", "cobolcraft:cardstack", "cobolcraft:lucite"
write("minecraft", "tiny",
      integer("DataVersion", 5023),
      int_list("size", [3, 2, 2]),
      lst("entities", 10, [body_comp(lst("pos", 6, [struct.pack(">d", 1.5)] * 3), comp("nbt", string("id", "minecraft:pig"))),
                            body_comp(lst("pos", 6, [struct.pack(">d", 0.5)] * 3))]),
      lst("blocks", 10, [block([0, 0, 0], 0), block([1, 0, 0], 1), block([0, 1, 0], 2), block([2, 0, 1], 0, True),
                         block([1, 1, 1], 0), block([0, 0, 1], 7)]),
      lst("palette", 10, [state(G), state(C, [("punched", "true"), ("axis", "z")]), state(L)]))
write("minecraft", "multi",
      int_list("size", [2, 1, 1]),
      lst("blocks", 10, [block([0, 0, 0], 0, extra=True), block([1, 0, 0], 1)]),
      lst("palettes", 9, [bytes([10]) + struct.pack(">i", 2) + state(G) + state(L),
                          bytes([10]) + struct.pack(">i", 2) + state(L) + state(G)]),
      lst("palette", 10, [state("cobolcraft:loam")]))
# partial and invalid properties, a state with no id, an unknown block, an unsupported property value
write("minecraft", "props",
      int_list("size", [1, 1, 7]),
      lst("blocks", 10, [block([0, 0, i], i) for i in range(7)]),
      lst("palette", 10, [state(C, [("punched", "true")]),
                          state(C, [("bogus", "x"), ("axis", "x")]),
                          state(C, [("axis", "q")]),
                          state(),
                          state("cobolcraft:nothing"),
                          state(G, [("axis", "z")]),
                          state(C, [("axis", "x")], odd=True)]))
write("minecraft", "sub/deep", int_list("size", [1, 1, 1]), lst("blocks", 10, [block([0, 0, 0], 0)]), lst("palette", 10, [state(G)]))
write("cobolcraft", "other", int_list("size", [1, 1, 1]), lst("blocks", 10, []), lst("palette", 10, [state(G)]))
write("minecraft", "short", int_list("size", [2, 3]), lst("blocks", 10, []), lst("palette", 10, [state(G)]))
write("minecraft", "outside", int_list("size", [1, 1, 1]), lst("blocks", 10, [block([0, 0, 1], 0)]), lst("palette", 10, [state(G)]))
write("minecraft", "negative", int_list("size", [1, 1, 1]), lst("blocks", 10, [block([-1, 0, 0], 0)]), lst("palette", 10, [state(G)]))
write("minecraft", "huge", int_list("size", [100, 100, 100]), lst("blocks", 10, []), lst("palette", 10, [state(G)]))
write("minecraft", "negsize", int_list("size", [-1, 4, 4]), lst("blocks", 10, []), lst("palette", 10, [state(G)]))
write("minecraft", "sizestr", lst("size", 8, [name("a")]), lst("blocks", 10, []))
write("minecraft", "posstr", int_list("size", [1, 1, 1]), lst("blocks", 10, [body_comp(lst("pos", 8, [name("a")]), integer("state", 0))]))
write("minecraft", "manypal", int_list("size", [1, 1, 1]), lst("blocks", 10, []),
      lst("palettes", 9, [bytes([10]) + struct.pack(">i", 1) + state(G)] * 17))
write("minecraft", "bigpal", int_list("size", [1, 1, 1]), lst("blocks", 10, []),
      lst("palette", 10, [state(G)] * 1025))
write("minecraft", "notnbt", raw=b"\x01\x02\x03 not an nbt tree")
write("minecraft", "empty", int_list("size", [1, 1, 1]))
write("minecraft", "manyblocks", int_list("size", [1, 1, 1]), lst("blocks", 10, [block([0, 0, 0], 0)] * 65537), lst("palette", 10, [state(G)]))
