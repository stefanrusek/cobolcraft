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

# Vanilla-id templates of core/tests/test_struct_36_2_5.cob (the standard content set): placement, rotation, mirror, block entities, waterlogging, shape faces.
def v(name_, props=None): return state("minecraft:" + name_, props)
STAIRS = [("facing", "east"), ("half", "bottom"), ("shape", "straight"), ("waterlogged", "false")]
PIG = body_comp(lst("pos", 6, [struct.pack(">d", 0.5)] * 3), comp("nbt", string("id", "minecraft:pig")))
write("test", "stairs", int_list("size", [2, 2, 2]), lst("entities", 10, []),
      lst("blocks", 10, [block([0, 0, 0], 0), block([1, 0, 0], 1), block([0, 0, 1], 2, True), block([1, 0, 1], 4), block([0, 1, 0], 3)]),
      lst("palette", 10, [v("stone"), v("oak_stairs", STAIRS),
                          v("chest", [("facing", "north"), ("type", "single"), ("waterlogged", "false")]), v("air"),
                          v("oak_log", [("axis", "x")])]))
write("test", "wet", int_list("size", [1, 1, 1]), lst("blocks", 10, [block([0, 0, 0], 0)]), lst("palette", 10, [v("oak_stairs", STAIRS)]))
write("test", "pool", int_list("size", [2, 1, 1]), lst("blocks", 10, [block([0, 0, 0], 0), block([1, 0, 0], 1)]),
      lst("palette", 10, [v("water", [("level", "0")]), v("oak_stairs", STAIRS)]))
write("test", "two", int_list("size", [1, 1, 1]), lst("blocks", 10, [block([0, 0, 0], 0)]),
      lst("palettes", 9, [bytes([10]) + struct.pack(">i", 1) + v("stone"), bytes([10]) + struct.pack(">i", 1) + v("cobblestone")]))
write("test", "cube", int_list("size", [2, 2, 2]),
      lst("blocks", 10, [block([x, y, z], 0) for y in range(2) for x in range(2) for z in range(2)]), lst("palette", 10, [v("stone")]))
write("test", "onlyent", int_list("size", [0, 1, 1]), lst("entities", 10, [PIG]), lst("blocks", 10, []), lst("palette", 10, [v("stone")]))
write("test", "onlyent1", int_list("size", [1, 1, 1]), lst("entities", 10, [PIG]), lst("blocks", 10, []), lst("palette", 10, [v("stone")]))
write("test", "nothing", int_list("size", [1, 1, 1]), lst("entities", 10, []), lst("blocks", 10, []), lst("palette", 10, [v("stone")]))
write("test", "cube3", int_list("size", [3, 3, 3]),
      lst("blocks", 10, [block([x, y, z], 0) for y in range(3) for x in range(3) for z in range(3)]), lst("palette", 10, [v("stone")]))
write("test", "row5", int_list("size", [5, 1, 1]), lst("blocks", 10, [block([x, 0, 0], 0) for x in range(5)]), lst("palette", 10, [v("stone")]))

# Block entity tags and jigsaw records of core/tests/test_struct_36_2_11.cob (36-2 sections 1.5, 5.3, 6.2, 9.6).
def lng(n, v_): return tag(4, n, struct.pack(">q", v_))
def blk(pos, st, nbt): return body_comp(int_list("pos", pos), integer("state", st), nbt)
CHEST = [("facing", "north"), ("type", "single"), ("waterlogged", "false")]
write("test", "bes", int_list("size", [6, 1, 1]), lst("entities", 10, []),
      lst("blocks", 10, [
          blk([0, 0, 0], 0, comp("nbt", string("id", "minecraft:chest"), string("LootTable", "minecraft:chests/simple_dungeon"), lng("LootTableSeed", 7))),
          blk([1, 0, 0], 0, comp("nbt", string("id", "minecraft:chest"))),
          blk([2, 0, 0], 1, comp("nbt", string("id", "minecraft:mob_spawner"),
                                 comp("SpawnData", comp("entity", string("id", "minecraft:cave_spider"))))),
          blk([3, 0, 0], 2, comp("nbt", string("id", "minecraft:structure_block"), string("mode", "DATA"), string("metadata", "ChestEast"))),
          blk([4, 0, 0], 2, comp("nbt", string("id", "minecraft:structure_block"), string("mode", "SAVE"))),
          blk([5, 0, 0], 3, comp("nbt", string("id", "minecraft:sign"))),
      ]),
      lst("palette", 10, [v("chest", CHEST), v("spawner"), v("structure_block", [("mode", "data")]), v("oak_sign", [("rotation", "0"), ("waterlogged", "false")])]))
write("test", "jig", int_list("size", [3, 1, 1]), lst("entities", 10, []),
      lst("blocks", 10, [
          blk([0, 0, 0], 0, comp("nbt", string("id", "minecraft:jigsaw"), string("joint", "rollable"), string("name", "minecraft:bottom"),
                                 string("pool", "minecraft:foo/bar"), string("target", "minecraft:top"),
                                 integer("placement_priority", 3), integer("selection_priority", 4),
                                 string("final_state", "minecraft:stone"))),
          blk([1, 0, 0], 0, comp("nbt", string("id", "minecraft:jigsaw"))),
          blk([2, 0, 0], 0, comp("nbt", string("id", "minecraft:jigsaw"), string("joint", "aligned"))),
      ]),
      lst("palette", 10, [v("jigsaw", [("orientation", "up_north")])]))

# Template pieces of core/tests/test_struct_36_2_6.cob (36-2 section 6.2): data markers above chests, jigsaw markers.
def sb(meta): return comp("nbt", string("id", "minecraft:structure_block"), string("mode", "DATA"), string("metadata", meta))
CHESTNBT = comp("nbt", string("id", "minecraft:chest"))
write("test", "marker", int_list("size", [3, 2, 1]), lst("entities", 10, []),
      lst("blocks", 10, [
          blk([0, 0, 0], 0, CHESTNBT), blk([1, 0, 0], 0, CHESTNBT), blk([2, 0, 0], 3, comp("nbt", string("id", "minecraft:jigsaw"), string("final_state", "minecraft:stone"))),
          blk([0, 1, 0], 1, sb("treasure_chest")), blk([1, 1, 0], 1, sb("chest")),
          blk([2, 1, 0], 3, comp("nbt", string("id", "minecraft:jigsaw"), string("final_state", "minecraft:no_such_block"))),
      ]),
      lst("palette", 10, [v("chest", CHEST), v("structure_block", [("mode", "data")]), v("stone"), v("jigsaw", [("orientation", "up_north")])]))
write("test", "markerstone", int_list("size", [1, 2, 1]), lst("entities", 10, []),
      lst("blocks", 10, [block([0, 0, 0], 0), blk([0, 1, 0], 1, sb("treasure_chest"))]),
      lst("palette", 10, [v("stone"), v("structure_block", [("mode", "data")])]))
