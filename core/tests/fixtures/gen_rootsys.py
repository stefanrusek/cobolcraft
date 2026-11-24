#!/usr/bin/env python3
"""Writes the data features of core/tests/test_feat_35_4_10.cob (root_system) into core/tests/fixtures/rootsys/data/minecraft/worldgen/feature."""
import json, os
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rootsys", "data", "minecraft", "worldgen", "feature")
os.makedirs(root, exist_ok=True)
def put(name, d):
    with open(os.path.join(root, name + ".json"), "w") as f: json.dump(d, f)
put("rs_tree", {"type": "minecraft:simple_block", "to_place": {"id": "minecraft:diamond_block"}})
AIR = {"type": "minecraft:matching_blocks", "blocks": ["minecraft:air"]}
STONE_BELOW = {"type": "minecraft:matching_blocks", "offset": [0, -1, 0], "blocks": ["minecraft:stone"]}
def feat(name, **kw):
    d = {"type": "minecraft:root_system",
         "feature": {"feature": "minecraft:rs_tree", "placement": []},
         "required_vertical_space_for_tree": 3, "allowed_vertical_water_for_tree": 2,
         "level_test_distance": 0, "max_level_deviation": 0,
         "root_radius": 3, "root_placement_attempts": 20, "root_column_max_height": 20,
         "hanging_root_radius": 3, "hanging_roots_vertical_span": 2, "hanging_root_placement_attempts": 8,
         "root_replaceable": ["minecraft:stone"],
         "root_state_provider": {"id": "minecraft:dirt"},
         "hanging_root_state_provider": {"id": "minecraft:gold_block"},
         "allowed_tree_position": {"type": "minecraft:all_of", "predicates": [AIR, STONE_BELOW]}}
    d.update(kw)
    for k in [k for k, v in d.items() if v is None]: del d[k]
    put(name, d)
feat("rs_t")
feat("rs_air", allowed_tree_position=AIR)
feat("rs_level", level_test_distance=2, max_level_deviation=1)
feat("rs_short", root_column_max_height=5)
feat("rs_badrange", root_radius=0)
feat("rs_badspace", required_vertical_space_for_tree=65)
feat("rs_noattempts", root_placement_attempts=None)
feat("rs_noreplaceable", root_replaceable=None)
feat("rs_noprovider", root_state_provider=None)
feat("rs_nopred", allowed_tree_position=None)
feat("rs_notree", feature=None)
