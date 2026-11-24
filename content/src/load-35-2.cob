*> Loader of docs/protocol/35-worldgen-features-2-predicates-and-providers.md (worldgen features, part 2: block predicates and block state providers).
*> LOAD-35-2 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). It registers the type rows of
*> this document part (group, type, member list: the forms of CTSHAPE.cpy) and loads, through SHAPE-LOAD (the registry loader and
*> JSON-STRICT of 23 sections 1 and 3, then the shape check), the registries this part defines the file shapes of:
*>   worldgen/block_state_provider (group block_state_provider, strict)
*>   worldgen/placed_feature (group placed_feature, strict)
*> Sections 3 (block predicates: 16 types, offsets, combinators), 4 (the ten block state provider types, the weighted entry,
*> rule_based rules), 5.1 (the NormalNoise parameter object of the noise providers).
*> Groups: block_predicate (16 types), block_state_provider (10 types, the registry worldgen/block_state_provider holds nothing else,
*> so strict), noise_parameters, weighted_state, rule_entry (typeless). Predicates occur inside other files, so the placed_feature
*> registry is loaded too, through the host rows placed_feature and block_predicate_filter (the same rows as 35-1: a row that exists
*> is kept).
*> Gaps of the engine: an offset is an array A (its length of 3 and the bound of 16 per component are not checked); a block state
*> (a bare id or {Name/id, properties}) and a nested provider (Id-or-inline, where the inline form may be a full block state object
*> without a type) and the vertical anchors are kept as any value X; the range of a positive float (scale) is 0.000001 and up.
*> The two typed forms of BlockStateProvider (a full state object, 4.1) are not accepted as a registry file here: a file needs a type.
*> 48 2.7 and 3.9: the 8 files of worldgen/block_state_provider are typed provider objects (type of every file), so a file needs a type. A provider slot inside other files is a provider id, an untyped {id, properties?} state or a typed provider (form G of CTSHAPE.cpy); a plain block id of a state slot is form Q.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-35-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "placed_feature".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R feature=feature;L placement=placement_modifier".
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "block_predicate_filter".
    05 FILLER PIC X(600) VALUE "T predicate=block_predicate".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "matching_blocks".
    05 FILLER PIC X(600) VALUE "H blocks=block;a offset".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "matching_block_tag".
    05 FILLER PIC X(600) VALUE "D tag;a offset".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "matching_fluids".
    05 FILLER PIC X(600) VALUE "H fluids=fluid;a offset".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "matching_biomes".
    05 FILLER PIC X(600) VALUE "H biomes=biome".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "has_sturdy_face".
    05 FILLER PIC X(600) VALUE "E direction=down|up|north|south|west|east;a offset".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "solid".
    05 FILLER PIC X(600) VALUE "a offset".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "replaceable".
    05 FILLER PIC X(600) VALUE "a offset".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "would_survive".
    05 FILLER PIC X(600) VALUE "Q state;a offset".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "inside_world_bounds".
    05 FILLER PIC X(600) VALUE "a offset".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "any_of".
    05 FILLER PIC X(600) VALUE "L predicates=block_predicate".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "all_of".
    05 FILLER PIC X(600) VALUE "L predicates=block_predicate".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "not".
    05 FILLER PIC X(600) VALUE "T predicate=block_predicate".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "true".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "unobstructed".
    05 FILLER PIC X(600) VALUE "a offset".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "height_range".
    05 FILLER PIC X(600) VALUE "O min_inclusive;O max_inclusive".
    05 FILLER PIC X(24) VALUE "block_predicate".
    05 FILLER PIC X(48) VALUE "volume_match".
    05 FILLER PIC X(600) VALUE "A min;A max;T match=block_predicate".
    05 FILLER PIC X(24) VALUE "noise_parameters".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "I base_octave=-32..32;n base_amplitude=0.00001..1000000;i octave_count=1..32;x" &
        " normalize;a amplitude_modifiers".
    05 FILLER PIC X(24) VALUE "weighted_state".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "X data;I weight=0..".
    05 FILLER PIC X(24) VALUE "rule_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "T if_true=block_predicate;X then".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "simple".
    05 FILLER PIC X(600) VALUE "X state".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "weighted".
    05 FILLER PIC X(600) VALUE "L entries=weighted_state".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "random_block".
    05 FILLER PIC X(600) VALUE "H blocks=block".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "rotated".
    05 FILLER PIC X(600) VALUE "G state=block_state_provider;e direction=down|up|north|south|west|east".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "copy_properties".
    05 FILLER PIC X(600) VALUE "X source".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "randomized_int".
    05 FILLER PIC X(600) VALUE "G source=block_state_provider;S property;V values=int_provider".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "rule_based".
    05 FILLER PIC X(600) VALUE "q fallback;L rules=rule_entry".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "noise".
    05 FILLER PIC X(600) VALUE "I seed;T noise=noise_parameters;N scale=0.000001..;K states".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "dual_noise".
    05 FILLER PIC X(600) VALUE "A variety;T slow_noise=noise_parameters;N slow_scale=0.000001..;I seed;T noise" &
        "=noise_parameters;N scale=0.000001..;K states".
    05 FILLER PIC X(24) VALUE "block_state_provider".
    05 FILLER PIC X(48) VALUE "noise_threshold".
    05 FILLER PIC X(600) VALUE "I seed;T noise=noise_parameters;N scale=0.000001..;N threshold=-1..1;N high_ch" &
        "ance=0..1;D default_state;K low_states;K high_states".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 31.
 01 WS-REG-1              PIC X(48) VALUE "worldgen/block_state_provider".
 01 WS-GROUP-1            PIC X(24) VALUE "block_state_provider".
 01 WS-STRICT-1           BINARY-LONG VALUE 1.
 01 WS-REG-2              PIC X(48) VALUE "worldgen/placed_feature".
 01 WS-GROUP-2            PIC X(24) VALUE "placed_feature".
 01 WS-STRICT-2           BINARY-LONG VALUE 1.
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
 END PROGRAM LOAD-35-2.
