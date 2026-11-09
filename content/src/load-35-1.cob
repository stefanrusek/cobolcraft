*> Loader of docs/protocol/35-worldgen-features-1-model-and-placement.md (worldgen features, part 1: the feature model, placement modifiers and the generic features).
*> LOAD-35-1 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). It registers the type rows of
*> this document part (group, type, member list: the forms of CTSHAPE.cpy) and loads, through SHAPE-LOAD (the registry loader and
*> JSON-STRICT of 23 sections 1 and 3, then the shape check), the registries this part defines the file shapes of:
*>   worldgen/placed_feature (group placed_feature, strict)
*>   worldgen/feature (group feature)
*> Sections 1.1 (element shapes), 3.1 and 3.2 (type names), 7 (placement modifiers), 9 (generic features).
*> Groups: placed_feature (typeless: feature, placement), placement_modifier (the 18 types), feature (the six generic types here; the
*> others are registered by 35-2 to 35-7, so the feature registry is loaded with strict 0), weighted_placed_feature, weighted_entry.
*> Forms: block predicates (35-2) are objects of the group block_predicate, checked when 35-2 has registered them. Providers are
*> int_provider (23 7.1), height_provider (23 7.3.2; kept as any value X because a bare anchor object has no type).
*> The heightmap name is a string S (the enum argument of CTSHAPE.cpy holds 40 bytes: the six names of section 4.2 do not fit).
*> Ranges the codecs bound on providers ([0, 4096], [-16, 16], [1, 16]) are not checked here (an engine gap).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-35-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "placed_feature".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "R feature=feature;L placement=placement_modifier".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "weighted_placed_feature".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "R feature=placed_feature;N chance=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "weighted_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "R data=placed_feature;I weight=0..".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "no_op".
    05 FILLER PIC X(100) VALUE "x type".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "random_selector".
    05 FILLER PIC X(100) VALUE "L features=weighted_placed_feature;R default=placed_feature".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "simple_random_selector".
    05 FILLER PIC X(100) VALUE "H features=placed_feature".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "random_boolean_selector".
    05 FILLER PIC X(100) VALUE "R feature_true=placed_feature;R feature_false=placed_feature".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "weighted_random_selector".
    05 FILLER PIC X(100) VALUE "L features=weighted_entry".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "sequence".
    05 FILLER PIC X(100) VALUE "H features=placed_feature".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "count".
    05 FILLER PIC X(100) VALUE "V count=int_provider".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "in_square".
    05 FILLER PIC X(100) VALUE "x type".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "biome".
    05 FILLER PIC X(100) VALUE "x type".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "block_predicate_filter".
    05 FILLER PIC X(100) VALUE "T predicate=block_predicate".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "rarity_filter".
    05 FILLER PIC X(100) VALUE "I chance=1..".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "random_chance".
    05 FILLER PIC X(100) VALUE "N chance=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "surface_relative_threshold_filter".
    05 FILLER PIC X(100) VALUE "S heightmap;i min_inclusive;i max_inclusive".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "surface_water_depth_filter".
    05 FILLER PIC X(100) VALUE "I max_water_depth".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "noise_based_count".
    05 FILLER PIC X(100) VALUE "I noise_to_count_ratio;N noise_factor;n noise_offset".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "noise_threshold_count".
    05 FILLER PIC X(100) VALUE "N noise_level;I below_noise;I above_noise".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "count_on_every_layer".
    05 FILLER PIC X(100) VALUE "V count=int_provider".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "cuboid".
    05 FILLER PIC X(100) VALUE "V xz_size=int_provider;V y_size=int_provider;b include_edges;b include_interior".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "environment_scan".
    05 FILLER PIC X(100) VALUE "E direction_of_search=up|down;T target_condition=block_predicate;t allowed_search_condition=block_pr".
    05 FILLER PIC X(100) VALUE "edicate;I max_steps=1..32".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "heightmap".
    05 FILLER PIC X(100) VALUE "S heightmap".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "height_range".
    05 FILLER PIC X(100) VALUE "X height".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "offset".
    05 FILLER PIC X(100) VALUE "V x=int_provider;V y=int_provider;V z=int_provider".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "randomly_selected".
    05 FILLER PIC X(100) VALUE "L placements=placement_modifier".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "fixed_placement".
    05 FILLER PIC X(100) VALUE "A positions".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
 01 WS-ROW-COUNT           BINARY-LONG VALUE 27.
 01 WS-REG-1              PIC X(48) VALUE "worldgen/placed_feature".
 01 WS-GROUP-1            PIC X(24) VALUE "placed_feature".
 01 WS-STRICT-1           BINARY-LONG VALUE 1.
 01 WS-REG-2              PIC X(48) VALUE "worldgen/feature".
 01 WS-GROUP-2            PIC X(24) VALUE "feature".
 01 WS-STRICT-2           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REG-1 WS-GROUP-1 WS-STRICT-1
     CALL "SHAPE-LOAD" USING L-DIR WS-REG-2 WS-GROUP-2 WS-STRICT-2
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-35-1.
