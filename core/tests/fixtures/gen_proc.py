#!/usr/bin/env python3
"""Writes the processor list fixtures of core/tests/test_struct_36_2_7.cob into core/tests/fixtures/proc/data/test/worldgen/processor_list
(the JSON forms of docs/protocol/36-structures-2 sections 7 to 9, written by hand from the schema)."""
import json, os

root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "proc", "data", "test", "worldgen", "processor_list")
os.makedirs(root, exist_ok=True)
M = "minecraft:"
def write(name, doc, raw=None):
    with open(os.path.join(root, name + ".json"), "w") as f:
        f.write(raw if raw is not None else json.dumps(doc, indent=1))
def lst(*ps): return {"processors": list(ps)}
def rule(*rules): return {"processor_type": M + "rule", "rules": list(rules)}
def pt(t, **kw): d = {"predicate_type": M + t}; d.update(kw); return d
def r(inp, loc, out, pos=None, mod=None):
    d = {"input_predicate": inp, "location_predicate": loc, "output_state": out}
    if pos: d["position_predicate"] = pos
    if mod: d["block_entity_modifier"] = mod
    return d
T = pt("always_true")
def bm(b): return pt("block_match", block=M + b)
def rbm(b, p): return pt("random_block_match", block=M + b, probability=p)

write("rules", lst(rule(r(rbm("stone", 0.5), T, M + "cobblestone"), r(rbm("stone", 0.5), T, M + "mossy_cobblestone"))))
write("combo", lst(rule(
    r(pt("all_of", rules=[bm("oak_planks"), pt("height_match", min_inclusive=60, max_inclusive=70)]), T, M + "birch_planks"),
    r(pt("any_of", rules=[bm("dirt"), bm("stone_bricks")]), T, M + "coarse_dirt"),
    r(pt("tag_match", tag="#minecraft:wool"), T, M + "white_concrete"),
    r(pt("blockstate_match", block_state={"Name": M + "oak_stairs", "Properties": {"facing": "east"}}), T,
      {"Name": M + "spruce_stairs", "Properties": {"facing": "north"}}, mod={"type": M + "append_loot", "loot_table": M + "chests/x"}),
    r(pt("random_blockstate_match", block_state={"Name": M + "oak_log", "Properties": {"axis": "x"}}, probability=1.0), T, M + "birch_log"),
    r(pt("tag_match", tag="minecraft:logs"), T, M + "stripped_oak_log"),
    r(rbm("sand", 0.0), T, M + "red_sand"),
    r(bm("gold_block"), T, M + "iron_block", mod={"type": M + "clear"}),
    r(bm("iron_block"), T, M + "gold_block", mod={"type": M + "append_static", "data": {"a": 1}}),
    r(bm("copper_block"), T, M + "gold_block", mod={"type": M + "passthrough"}),
    r(bm("emerald_block"), T, M + "gold_block", mod={"type": M + "no_such_modifier"}),
    r(pt("not", rule=bm("gravel")), pt("block_match", block=M + "air"), M + "glass"))))
write("linear", lst(rule(r(T, T, M + "air", pos={"predicate_type": M + "linear_pos", "min_chance": 0.0, "max_chance": 1.0, "min_dist": 0, "max_dist": 8}))))
write("axis", lst(rule(r(T, T, M + "air", pos={"predicate_type": M + "axis_aligned_linear_pos", "max_chance": 0.05, "max_dist": 100}))))
write("axisz", lst(rule(r(T, T, M + "air", pos={"predicate_type": M + "axis_aligned_linear_pos", "axis": "z", "min_chance": 0.0, "max_chance": 1.0, "min_dist": 0, "max_dist": 10}))))
write("axisx", lst(rule(r(T, T, M + "air", pos={"predicate_type": M + "axis_aligned_linear_pos", "axis": "x", "min_chance": 1.0, "max_chance": 1.0, "min_dist": 0, "max_dist": 10}))))
write("unknownpos", lst(rule(r(T, T, M + "air", pos={"predicate_type": M + "no_such_position_test"}))))
write("capped2", lst({"processor_type": M + "capped", "limit": 2, "delegate": rule(r(bm("stone"), T, M + "cobblestone"))}))
write("capped_uniform", lst({"processor_type": M + "capped", "limit": {"type": M + "uniform", "min_inclusive": 1, "max_inclusive": 3},
                             "delegate": rule(r(bm("stone"), T, M + "cobblestone"))}))
write("capped_none", lst({"processor_type": M + "capped", "limit": 3, "delegate": rule(r(bm("dirt"), T, M + "cobblestone"))}))
write("capped_zero", lst({"processor_type": M + "capped", "limit": 0, "delegate": rule(r(bm("stone"), T, M + "cobblestone"))}))
write("capped_ignore", lst({"processor_type": M + "capped", "limit": 1, "delegate": {"processor_type": M + "block_ignore", "blocks": [M + "stone"]}}))
for n, t, a, b, c in (("biased", "biased_to_bottom", 2, 12, None), ("verybiased", "very_biased_to_bottom", 0, 10, None)):
    write("capped_" + n, lst({"processor_type": M + "capped", "limit": {"type": M + t, "min_inclusive": a, "max_inclusive": b},
                              "delegate": rule(r(bm("stone"), T, M + "cobblestone"))}))
write("capped_trap", lst({"processor_type": M + "capped", "limit": {"type": M + "trapezoid", "min": -4, "max": 4, "plateau": 2},
                          "delegate": rule(r(bm("stone"), T, M + "cobblestone"))}))
write("capped_trap0", lst({"processor_type": M + "capped", "limit": {"type": M + "trapezoid", "min": -4, "max": 4, "plateau": 0},
                           "delegate": rule(r(bm("stone"), T, M + "cobblestone"))}))
write("capped_trapflat", lst({"processor_type": M + "capped", "limit": {"type": M + "trapezoid", "min": 1, "max": 5, "plateau": 4},
                              "delegate": rule(r(bm("stone"), T, M + "cobblestone"))}))
write("gravity", lst({"processor_type": M + "gravity", "heightmap": "WORLD_SURFACE", "offset": 1}))
write("gravity_default", lst({"processor_type": M + "gravity"}))
for n, hm in (("ocean", "OCEAN_FLOOR_WG"), ("oceanfloor", "OCEAN_FLOOR"), ("motion", "MOTION_BLOCKING"), ("noleaves", "MOTION_BLOCKING_NO_LEAVES")):
    write("gravity_" + n, lst({"processor_type": M + "gravity", "heightmap": hm}))
write("rot_half", lst({"processor_type": M + "block_rot", "integrity": 0.5, "rottable_blocks": M + "stone"}))
write("rot_all", lst({"processor_type": M + "block_rot", "integrity": 1.0}))
write("rot_none", lst({"processor_type": M + "block_rot", "integrity": 0.0}))
write("rot_tag", lst({"processor_type": M + "block_rot", "integrity": 0.5, "rottable_blocks": ["#minecraft:wool", M + "stone"]}))
write("protected", lst({"processor_type": M + "protected_blocks", "value": [M + "bedrock", M + "obsidian"]}))
write("protected_tag", lst({"processor_type": M + "protected_blocks", "value": "#minecraft:features_cannot_replace"}))
write("ignore", lst({"processor_type": M + "block_ignore", "blocks": [{"Name": M + "air"}, M + "oak_log"]}))
write("blackstone", lst({"processor_type": M + "blackstone_replace"}))
write("age", lst({"processor_type": M + "block_age", "mossiness": 0.3}))
write("nop", lst({"processor_type": M + "nop"}))
write("bare", [{"processor_type": M + "nop"}, {"processor_type": M + "nop"}])
write("empty", {"processors": []})
write("simple", lst(rule(r(bm("stone"), T, M + "cobblestone"))))
write("stairsout", lst(rule(r(bm("stone"), T, {"Name": M + "oak_stairs", "Properties": {"facing": "north"}}))))
write("stairmatch", lst(rule(r(pt("blockstate_match", block_state={"Name": M + "oak_stairs", "Properties": {"facing": "east"}}), T,
                               {"Name": M + "spruce_stairs", "Properties": {"facing": "east"}}))))
write("twice", lst({"processor_type": M + "block_ignore", "blocks": [M + "oak_log"]}, rule(r(bm("stone"), T, M + "cobblestone"))))
# lists that do not compile
write("bad_lava", lst({"processor_type": M + "lava_submerged_block"}))
write("bad_type", lst({"processor_type": M + "no_such_processor"}))
write("bad_notype", lst({"foo": 1}))
write("bad_nolocation", lst(rule({"input_predicate": T, "output_state": M + "air"})))
write("bad_testtype", lst(rule(r(pt("no_such_test"), T, M + "air"))))
write("bad_posrule", lst(rule(r(T, pt("linear_pos", min_dist=0, max_dist=4), M + "air"))))
write("bad_posrange", lst(rule(r(T, T, M + "air", pos={"predicate_type": M + "linear_pos", "min_dist": 8, "max_dist": 8}))))
write("bad_block", lst(rule(r(bm("no_such_block"), T, M + "air"))))
write("bad_output", lst(rule(r(T, T, M + "no_such_block"))))
write("bad_state", lst(rule(r(pt("blockstate_match", block_state={"Name": M + "no_such_block"}), T, M + "air"))))
write("bad_noprob", lst(rule(r({"predicate_type": M + "random_block_match", "block": M + "stone"}, T, M + "air"))))
write("bad_rules", lst({"processor_type": M + "rule", "rules": 7}))
write("bad_nolimit", lst({"processor_type": M + "capped", "delegate": rule(r(bm("stone"), T, M + "air"))}))
write("bad_limit", lst({"processor_type": M + "capped", "limit": {"type": M + "weighted_list", "distribution": [{"data": 1, "weight": 1}]},
                        "delegate": rule(r(bm("stone"), T, M + "air"))}))
write("bad_nodelegate", lst({"processor_type": M + "capped", "limit": 2}))
write("bad_heightmap", lst({"processor_type": M + "gravity", "heightmap": "NOT_A_MAP"}))
write("bad_integrity", lst({"processor_type": M + "block_rot"}))
write("bad_rottable", lst({"processor_type": M + "block_rot", "integrity": 0.5, "rottable_blocks": [7]}))
write("bad_protected", lst({"processor_type": M + "protected_blocks"}))
write("bad_ignore", lst({"processor_type": M + "block_ignore", "blocks": [{"Name": M + "no_such_block"}]}))
write("bad_ignore2", lst({"processor_type": M + "block_ignore", "blocks": 5}))
write("bad_ignore3", lst({"processor_type": M + "block_ignore"}))
write("bad_protected2", lst({"processor_type": M + "protected_blocks", "value": "minecraft:no_such_block"}))
write("bad_age", lst({"processor_type": M + "block_age"}))
write("bad_alloftests", lst(rule(r({"predicate_type": M + "all_of", "rules": 3}, T, M + "air"))))
write("bad_height", lst(rule(r(pt("height_match", min_inclusive=1), T, M + "air"))))
write("bad_blockstatematch", lst(rule(r({"predicate_type": M + "blockstate_match"}, T, M + "air"))))
write("bad_probability", lst(rule(r(T, T, M + "air", pos=None), r({"predicate_type": M + "random_blockstate_match", "block_state": M + "stone"}, T, M + "air"))))
write("bad_tag", lst(rule(r({"predicate_type": M + "tag_match"}, T, M + "air"))))
write("bad_list", {"notprocessors": []})
write("bad_json", None, raw="{ this is not json")
write("bad_rootnum", None, raw="5")

# capacity: the pool (59 lists of the 552 blocks of a big tag fill it), the processor rows, the rule rows, the test rows
for i in range(70):
    write("big%02d" % i, lst({"processor_type": M + "protected_blocks", "value": "#minecraft:mineable/pickaxe"}))
write("toomany", lst(*[{"processor_type": M + "nop"}] * 1025))
write("nops1023", lst(*[{"processor_type": M + "nop"}] * 1023))
write("capped_full", lst({"processor_type": M + "capped", "limit": 2, "delegate": {"processor_type": M + "nop"}}))
cheap = {"input_predicate": {"predicate_type": M + "always_true"}, "location_predicate": {"predicate_type": M + "always_true"}, "output_state": M + "air"}
for i in range(5):
    write("rules400_%d" % i, lst(rule(*[cheap] * 400)), raw=json.dumps(lst(rule(*[cheap] * 400)), separators=(",", ":")))
write("tests_over", lst(rule(r({"predicate_type": M + "all_of", "rules": [T] * 120}, T, M + "air"))))
write("rules_over", lst(rule(*[cheap] * 100)))
write("protected_notag", lst({"processor_type": M + "protected_blocks", "value": "#minecraft:no_such_tag"}))
write("posalways", lst(rule(r(T, T, M + "air", pos={"predicate_type": M + "always_true"}))))
write("linear_min", lst(rule(r(T, T, M + "air", pos={"predicate_type": M + "linear_pos", "min_chance": 1.0, "max_chance": 0.0, "min_dist": 4, "max_dist": 8}))))
write("bad_height2", lst(rule(r(pt("height_match", max_inclusive=1), T, M + "air"))))
write("bad_norules", lst({"processor_type": M + "rule"}))
