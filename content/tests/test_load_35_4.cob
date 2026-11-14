*> Test of the loader of docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md (worldgen features, part 4: tree decorators and the vegetation features). LOAD-35-4 USING root (PIC X(1100)), status out: the fixture tree
*> content/tests/fixtures/load-35-4 loads (CT-OK, 22 elements, each of its type row); each reject case writes one bad file
*> into a fresh copy of the tree and expects CT-BAD-DATA with nothing kept (23 section 3.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-35-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COMMAND             PIC X(1200).
 01 WS-BODY                PIC X(720).
 01 WS-DIRNAME             PIC X(48).
 01 WS-LABEL               PIC X(60).
 01 WS-ELEMENTS.
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:tree_all_decorators".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:tree_attached".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:grass".
    05 FILLER PIC X(48) VALUE "simple_block".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:flower".
    05 FILLER PIC X(48) VALUE "simple_block".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:kelp".
    05 FILLER PIC X(48) VALUE "block_column".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:bamboo".
    05 FILLER PIC X(48) VALUE "bamboo".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:vines".
    05 FILLER PIC X(48) VALUE "vines".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:pillar".
    05 FILLER PIC X(48) VALUE "single_block_pillar".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:pillar_full".
    05 FILLER PIC X(48) VALUE "single_block_pillar".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:glowstone_extra".
    05 FILLER PIC X(48) VALUE "random_neighbor_spread".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:weeping_vines".
    05 FILLER PIC X(48) VALUE "overlay".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:replace".
    05 FILLER PIC X(48) VALUE "replace_single_block".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:basalt_pillar".
    05 FILLER PIC X(48) VALUE "projected_random_patchy_square".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:glow_lichen".
    05 FILLER PIC X(48) VALUE "multiface_growth".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:glow_lichen_min".
    05 FILLER PIC X(48) VALUE "multiface_growth".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:moss_patch".
    05 FILLER PIC X(48) VALUE "vegetation_patch".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:clay_pool".
    05 FILLER PIC X(48) VALUE "waterlogged_vegetation_patch".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:azalea".
    05 FILLER PIC X(48) VALUE "root_system".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:brown".
    05 FILLER PIC X(48) VALUE "huge_brown_mushroom".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:red".
    05 FILLER PIC X(48) VALUE "huge_red_mushroom".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:crimson_fungus".
    05 FILLER PIC X(48) VALUE "huge_fungus".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:other_part".
    05 FILLER PIC X(48) VALUE "unregistered".
 01 WS-ELEMENT-TABLE REDEFINES WS-ELEMENTS.
    05 WS-E OCCURS 22 TIMES.
       10 WS-E-REGISTRY      PIC X(48).
       10 WS-E-KEY           PIC X(112).
       10 WS-E-TYPE          PIC X(48).
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "trunk_vine as a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[1]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a decorator without a type".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"p'.
    05 FILLER PIC X(60) VALUE 'robability":0.5}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "leave_vine without probability".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:leave_vine"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "leave_vine probability 2".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:leave_vine","probability":2}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "cocoa probability negative".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:cocoa","probability":-0.1}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "beehive probability a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:beehive","probability":"1"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "shelf_mushroom without probability".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:shelf_mushroom"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "alter_ground without provider".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:alter_ground"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "attached_to_logs without directions".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:attached_to_logs","probability":0.5,"block_p'.
    05 FILLER PIC X(60) VALUE 'rovider":{"id"  :"a"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "attached_to_logs directions bad id".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:attached_to_logs","probability":0.5,"block_p'.
    05 FILLER PIC X(60) VALUE 'rovider":{"id"  :"a"},"directions":["Up"]}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "attached_to_leaves exclusion_radius_xz 17".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:attached_to_leaves","probability":0.1,"exclu'.
    05 FILLER PIC X(60) VALUE 'sion_radius_xz":17,"exclusion_radius_y":0,"block_provider":{'.
    05 FILLER PIC X(60) VALUE '"id"  :"a"},"required_empty_blocks":2,"directions":["down"]}'.
    05 FILLER PIC X(60) VALUE ']}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "attached_to_leaves required_empty_blocks 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:attached_to_leaves","probability":0.1,"exclu'.
    05 FILLER PIC X(60) VALUE 'sion_radius_xz":1,"exclusion_radius_y":0,"block_provider":{"'.
    05 FILLER PIC X(60) VALUE 'Name":"a"},"required_empty_blocks":0,"directions":["down"]}]'.
    05 FILLER PIC X(60) VALUE '}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "place_on_ground tries 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:place_on_ground","tries":0,"block_state_prov'.
    05 FILLER PIC X(60) VALUE 'ider":{"id"  :"a"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "place_on_ground radius negative".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:place_on_ground","radius":-1,"block_state_pr'.
    05 FILLER PIC X(60) VALUE 'ovider":{"id"  :"a"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "place_on_ground without a provider".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:place_on_ground"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "pale_moss without ground_probability".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","decorators":[{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:pale_moss","leaves_probability":0.1,"trunk_p'.
    05 FILLER PIC X(60) VALUE 'robability":0.1}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "simple_block without to_place".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:simple_block"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "simple_block schedule_tick a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:simple_block","to_place":{"id"  :"a"},"sc'.
    05 FILLER PIC X(60) VALUE 'hedule_tick":1}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "block_column without layers".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:block_column","direction":"up","allowed_p'.
    05 FILLER PIC X(60) VALUE 'lacement":{"type":"minecraft:true"},"prioritize_tip":true}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "block_column layer without height".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:block_column","layers":[{"provider":{"Nam'.
    05 FILLER PIC X(60) VALUE 'e":"a"}}],"direction":"up","allowed_placement":{"type":"mine'.
    05 FILLER PIC X(60) VALUE 'craft:true"},"prioritize_tip":true}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "block_column direction sideways".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:block_column","layers":[],"direction":"le'.
    05 FILLER PIC X(60) VALUE 'ft","allowed_placement":{"type":"minecraft:true"},"prioritiz'.
    05 FILLER PIC X(60) VALUE 'e_tip":true}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "block_column without allowed_placement".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:block_column","layers":[],"direction":"up'.
    05 FILLER PIC X(60) VALUE '","prioritize_tip":true}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "block_column without prioritize_tip".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:block_column","layers":[],"direction":"up'.
    05 FILLER PIC X(60) VALUE '","allowed_placement":{"type":"minecraft:true"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "bamboo probability 1.5".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:bamboo","probability":1.5}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "bamboo without probability".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:bamboo"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "single_block_pillar direction north".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:single_block_pillar","block":{"id"  :"a"}'.
    05 FILLER PIC X(60) VALUE ',"direction":"north"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "single_block_pillar chance_to_continue 2".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:single_block_pillar","block":{"id"  :"a"}'.
    05 FILLER PIC X(60) VALUE ',"direction":"up","chance_to_continue":2}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "single_block_pillar cap_feature bad".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:single_block_pillar","block":{"id"  :"a"}'.
    05 FILLER PIC X(60) VALUE ',"direction":"up","cap_feature":3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "random_neighbor_spread without attempts".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:random_neighbor_spread","block":{"id"  :"'.
    05 FILLER PIC X(60) VALUE 'a"},"accepted_neighbors":"minecraft:a","can_replace":{"type"'.
    05 FILLER PIC X(60) VALUE ':"minecraft:true"},"xz_offset":1,"y_offset":1}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "random_neighbor_spread without can_replace".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:random_neighbor_spread","block":{"id"  :"'.
    05 FILLER PIC X(60) VALUE 'a"},"accepted_neighbors":"minecraft:a","attempts":1,"xz_offs'.
    05 FILLER PIC X(60) VALUE 'et":1,"y_offset":1}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "overlay without features".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:overlay"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "overlay features a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:overlay","features":3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "replace_single_block without targets".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:replace_single_block"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a replace target without state".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:replace_single_block","targets":[{"target'.
    05 FILLER PIC X(60) VALUE '":{"predicate_type":"minecraft:always_true"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "projected_random_patchy_square without size".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:projected_random_patchy_square","block":{'.
    05 FILLER PIC X(60) VALUE '"id"  :"a"},"project_through":{"type":"minecraft:true"},"max'.
    05 FILLER PIC X(60) VALUE '_projection_height":3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "max_projection_height negative".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:projected_random_patchy_square","block":{'.
    05 FILLER PIC X(60) VALUE '"id"  :"a"},"project_through":{"type":"minecraft:true"},"siz'.
    05 FILLER PIC X(60) VALUE 'e":3,"max_projection_height":-1}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "multiface_growth without block".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:multiface_growth","can_be_placed_on":"min'.
    05 FILLER PIC X(60) VALUE 'ecraft:a"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "multiface_growth search_range 65".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:multiface_growth","block":"minecraft:a","'.
    05 FILLER PIC X(60) VALUE 'search_range":65,"can_be_placed_on":"minecraft:a"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "multiface_growth search_range 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:multiface_growth","block":"minecraft:a","'.
    05 FILLER PIC X(60) VALUE 'search_range":0,"can_be_placed_on":"minecraft:a"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "multiface_growth chance_of_spreading 2".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:multiface_growth","block":"minecraft:a","'.
    05 FILLER PIC X(60) VALUE 'chance_of_spreading":2,"can_be_placed_on":"minecraft:a"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "multiface_growth flag a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:multiface_growth","block":"minecraft:a","'.
    05 FILLER PIC X(60) VALUE 'can_place_on_wall":1,"can_be_placed_on":"minecraft:a"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "multiface_growth without can_be_placed_on".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:multiface_growth","block":"minecraft:a"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "vegetation_patch surface wall".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:vegetation_patch","replaceable":"#minecra'.
    05 FILLER PIC X(60) VALUE 'ft:moss_replaceable","ground_state":{"id"  :"minecraft:moss_'.
    05 FILLER PIC X(60) VALUE 'block"},"vegetation_feature":"minecraft:moss_vegetation","su'.
    05 FILLER PIC X(60) VALUE 'rface":"wall","depth":1,"extra_bottom_block_chance":0.0,"ver'.
    05 FILLER PIC X(60) VALUE 'tical_range":5,"vegetation_chance":0.8,"xz_radius":{"type":"'.
    05 FILLER PIC X(60) VALUE 'minecraft:uniform","min_inclusive":4,"max_inclusive":7},"ext'.
    05 FILLER PIC X(60) VALUE 'ra_edge_column_chance":0.3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "vegetation_patch vertical_range 257".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:vegetation_patch","replaceable":"#minecra'.
    05 FILLER PIC X(60) VALUE 'ft:moss_replaceable","ground_state":{"id"  :"minecraft:moss_'.
    05 FILLER PIC X(60) VALUE 'block"},"vegetation_feature":"minecraft:moss_vegetation","su'.
    05 FILLER PIC X(60) VALUE 'rface":"floor","depth":1,"extra_bottom_block_chance":0.0,"ve'.
    05 FILLER PIC X(60) VALUE 'rtical_range":257,"vegetation_chance":0.8,"xz_radius":{"type'.
    05 FILLER PIC X(60) VALUE '":"minecraft:uniform","min_inclusive":4,"max_inclusive":7},"'.
    05 FILLER PIC X(60) VALUE 'extra_edge_column_chance":0.3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "vegetation_patch vegetation_chance 2".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:vegetation_patch","replaceable":"#minecra'.
    05 FILLER PIC X(60) VALUE 'ft:moss_replaceable","ground_state":{"id"  :"minecraft:moss_'.
    05 FILLER PIC X(60) VALUE 'block"},"vegetation_feature":"minecraft:moss_vegetation","su'.
    05 FILLER PIC X(60) VALUE 'rface":"floor","depth":1,"extra_bottom_block_chance":0.0,"ve'.
    05 FILLER PIC X(60) VALUE 'rtical_range":5,"vegetation_chance":2,"xz_radius":{"type":"m'.
    05 FILLER PIC X(60) VALUE 'inecraft:uniform","min_inclusive":4,"max_inclusive":7},"extr'.
    05 FILLER PIC X(60) VALUE 'a_edge_column_chance":0.3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "vegetation_patch without depth".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:vegetation_patch","replaceable":"#minecra'.
    05 FILLER PIC X(60) VALUE 'ft:moss_replaceable","ground_state":{"id"  :"minecraft:moss_'.
    05 FILLER PIC X(60) VALUE 'block"},"vegetation_feature":"minecraft:moss_vegetation","su'.
    05 FILLER PIC X(60) VALUE 'rface":"floor","extra_bottom_block_chance":0.0,"vertical_ran'.
    05 FILLER PIC X(60) VALUE 'ge":5,"vegetation_chance":0.8,"xz_radius":{"type":"minecraft'.
    05 FILLER PIC X(60) VALUE ':uniform","min_inclusive":4,"max_inclusive":7},"extra_edge_c'.
    05 FILLER PIC X(60) VALUE 'olumn_chance":0.3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "vegetation_patch without replaceable".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:waterlogged_vegetation_patch","ground_sta'.
    05 FILLER PIC X(60) VALUE 'te":{"id"  :"minecraft:moss_block"},"vegetation_feature":"mi'.
    05 FILLER PIC X(60) VALUE 'necraft:moss_vegetation","surface":"floor","depth":1,"extra_'.
    05 FILLER PIC X(60) VALUE 'bottom_block_chance":0.0,"vertical_range":5,"vegetation_chan'.
    05 FILLER PIC X(60) VALUE 'ce":0.8,"xz_radius":{"type":"minecraft:uniform","min_inclusi'.
    05 FILLER PIC X(60) VALUE 've":4,"max_inclusive":7},"extra_edge_column_chance":0.3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "root_system root_radius 65".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:root_system","feature":"minecraft:oak","r'.
    05 FILLER PIC X(60) VALUE 'equired_vertical_space_for_tree":2,"level_test_distance":2,"'.
    05 FILLER PIC X(60) VALUE 'max_level_deviation":3,"root_radius":65,"root_replaceable":"'.
    05 FILLER PIC X(60) VALUE '#minecraft:azalea_root_replaceable","root_state_provider":{"'.
    05 FILLER PIC X(60) VALUE 'Name":"minecraft:rooted_dirt"},"root_placement_attempts":20,'.
    05 FILLER PIC X(60) VALUE '"root_column_max_height":100,"hanging_root_radius":3,"hangin'.
    05 FILLER PIC X(60) VALUE 'g_roots_vertical_span":2,"hanging_root_state_provider":{"Nam'.
    05 FILLER PIC X(60) VALUE 'e":"minecraft:hanging_roots"},"hanging_root_placement_attemp'.
    05 FILLER PIC X(60) VALUE 'ts":20,"allowed_vertical_water_for_tree":2,"allowed_tree_pos'.
    05 FILLER PIC X(60) VALUE 'ition":{"type":"minecraft:true"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "root_system level_test_distance 17".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:root_system","feature":"minecraft:oak","r'.
    05 FILLER PIC X(60) VALUE 'equired_vertical_space_for_tree":2,"level_test_distance":17,'.
    05 FILLER PIC X(60) VALUE '"max_level_deviation":3,"root_radius":3,"root_replaceable":"'.
    05 FILLER PIC X(60) VALUE '#minecraft:azalea_root_replaceable","root_state_provider":{"'.
    05 FILLER PIC X(60) VALUE 'Name":"minecraft:rooted_dirt"},"root_placement_attempts":20,'.
    05 FILLER PIC X(60) VALUE '"root_column_max_height":100,"hanging_root_radius":3,"hangin'.
    05 FILLER PIC X(60) VALUE 'g_roots_vertical_span":2,"hanging_root_state_provider":{"Nam'.
    05 FILLER PIC X(60) VALUE 'e":"minecraft:hanging_roots"},"hanging_root_placement_attemp'.
    05 FILLER PIC X(60) VALUE 'ts":20,"allowed_vertical_water_for_tree":2,"allowed_tree_pos'.
    05 FILLER PIC X(60) VALUE 'ition":{"type":"minecraft:true"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "root_system without feature".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:root_system","required_vertical_space_for'.
    05 FILLER PIC X(60) VALUE '_tree":2,"level_test_distance":2,"max_level_deviation":3,"ro'.
    05 FILLER PIC X(60) VALUE 'ot_radius":3,"root_replaceable":"#minecraft:azalea_root_repl'.
    05 FILLER PIC X(60) VALUE 'aceable","root_state_provider":{"id"  :"minecraft:rooted_dir'.
    05 FILLER PIC X(60) VALUE 't"},"root_placement_attempts":20,"root_column_max_height":10'.
    05 FILLER PIC X(60) VALUE '0,"hanging_root_radius":3,"hanging_roots_vertical_span":2,"h'.
    05 FILLER PIC X(60) VALUE 'anging_root_state_provider":{"id"  :"minecraft:hanging_roots'.
    05 FILLER PIC X(60) VALUE '"},"hanging_root_placement_attempts":20,"allowed_vertical_wa'.
    05 FILLER PIC X(60) VALUE 'ter_for_tree":2,"allowed_tree_position":{"type":"minecraft:t'.
    05 FILLER PIC X(60) VALUE 'rue"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "root_system without allowed_tree_position".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:root_system","feature":"minecraft:oak","r'.
    05 FILLER PIC X(60) VALUE 'equired_vertical_space_for_tree":2,"level_test_distance":2,"'.
    05 FILLER PIC X(60) VALUE 'max_level_deviation":3,"root_radius":3,"root_replaceable":"#'.
    05 FILLER PIC X(60) VALUE 'minecraft:azalea_root_replaceable","root_state_provider":{"N'.
    05 FILLER PIC X(60) VALUE 'ame":"minecraft:rooted_dirt"},"root_placement_attempts":20,"'.
    05 FILLER PIC X(60) VALUE 'root_column_max_height":100,"hanging_root_radius":3,"hanging'.
    05 FILLER PIC X(60) VALUE '_roots_vertical_span":2,"hanging_root_state_provider":{"Name'.
    05 FILLER PIC X(60) VALUE '":"minecraft:hanging_roots"},"hanging_root_placement_attempt'.
    05 FILLER PIC X(60) VALUE 's":20,"allowed_vertical_water_for_tree":2}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "root_system attempts 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:root_system","feature":"minecraft:oak","r'.
    05 FILLER PIC X(60) VALUE 'equired_vertical_space_for_tree":2,"level_test_distance":2,"'.
    05 FILLER PIC X(60) VALUE 'max_level_deviation":3,"root_radius":3,"root_replaceable":"#'.
    05 FILLER PIC X(60) VALUE 'minecraft:azalea_root_replaceable","root_state_provider":{"N'.
    05 FILLER PIC X(60) VALUE 'ame":"minecraft:rooted_dirt"},"root_placement_attempts":0,"r'.
    05 FILLER PIC X(60) VALUE 'oot_column_max_height":100,"hanging_root_radius":3,"hanging_'.
    05 FILLER PIC X(60) VALUE 'roots_vertical_span":2,"hanging_root_state_provider":{"id"  '.
    05 FILLER PIC X(60) VALUE ':"minecraft:hanging_roots"},"hanging_root_placement_attempts'.
    05 FILLER PIC X(60) VALUE '":20,"allowed_vertical_water_for_tree":2,"allowed_tree_posit'.
    05 FILLER PIC X(60) VALUE 'ion":{"type":"minecraft:true"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "huge mushroom without cap_provider".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:huge_brown_mushroom","stem_provider":{"Na'.
    05 FILLER PIC X(60) VALUE 'me":"b"},"can_place_on":{"type":"minecraft:true"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "huge mushroom foliage_radius fractional".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:huge_red_mushroom","cap_provider":{"id"  '.
    05 FILLER PIC X(60) VALUE ':"a"},"stem_provider":{"id"  :"b"},"foliage_radius":2.5,"can'.
    05 FILLER PIC X(60) VALUE '_place_on":{"type":"minecraft:true"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "huge mushroom without can_place_on".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:huge_brown_mushroom","cap_provider":{"Nam'.
    05 FILLER PIC X(60) VALUE 'e":"a"},"stem_provider":{"id"  :"b"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "huge_fungus without stem_state".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:huge_fungus","valid_base_block":{"id"  :"'.
    05 FILLER PIC X(60) VALUE 'minecraft:crimson_nylium"},"hat_state":{"id"  :"minecraft:ne'.
    05 FILLER PIC X(60) VALUE 'ther_wart_block"},"decor_state":{"id"  :"minecraft:shroomlig'.
    05 FILLER PIC X(60) VALUE 'ht"},"replaceable_blocks":{"type":"minecraft:true"},"planted'.
    05 FILLER PIC X(60) VALUE '":true}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "huge_fungus planted a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:huge_fungus","valid_base_block":{"id"  :"'.
    05 FILLER PIC X(60) VALUE 'minecraft:crimson_nylium"},"stem_state":{"id"  :"minecraft:c'.
    05 FILLER PIC X(60) VALUE 'rimson_stem"},"hat_state":{"id"  :"minecraft:nether_wart_blo'.
    05 FILLER PIC X(60) VALUE 'ck"},"decor_state":{"id"  :"minecraft:shroomlight"},"replace'.
    05 FILLER PIC X(60) VALUE 'able_blocks":{"type":"minecraft:true"},"planted":1}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 57 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-DIR      PIC X(48).
       10 WS-CASE-BODY     PIC X(720).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-35-4" TO WS-DIR
     CALL "LOAD-35-4" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 35-4 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 35-4 every file is an element" TO TL-CASE
     MOVE 22 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22
         CALL "SHAPE-FIND" USING WS-E-REGISTRY(WS-I) WS-E-KEY(WS-I) WS-ROW
         PERFORM ASSERT-ELEMENT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 57
         MOVE WS-CASE-LABEL(WS-I) TO WS-LABEL
         MOVE WS-CASE-DIR(WS-I) TO WS-DIRNAME
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 ASSERT-ELEMENT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-4 " FUNCTION TRIM(WS-E-KEY(WS-I)) " in " FUNCTION TRIM(WS-E-REGISTRY(WS-I)) " is a " FUNCTION TRIM(WS-E-TYPE(WS-I))
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-E-TYPE(WS-I) TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW > 0
         IF SH-E-TYPE(WS-ROW) > 0
             MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
         ELSE
             MOVE "unregistered" TO TL-OBSERVED
         END-IF
     ELSE
         MOVE "not found" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     CALL "SHAPE-FREE"
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/load-35-4 2>/dev/null; rm -rf build/content-test/load-35-4; mkdir -p build/content-test/load-35-4 && cp -R content/tests/fixtures/load-35-4 build/content-test/load-35-4/t"
     MOVE "build/content-test/load-35-4/t" TO WS-DIR
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/load-35-4/t/data/minecraft/" FUNCTION TRIM(WS-DIRNAME) " && printf '%s' '"
         FUNCTION TRIM(WS-BODY) "' > build/content-test/load-35-4/t/data/minecraft/" FUNCTION TRIM(WS-DIRNAME) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-35-4" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-4 reject: " FUNCTION TRIM(WS-LABEL) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-4 reject: " FUNCTION TRIM(WS-LABEL) " keeps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
