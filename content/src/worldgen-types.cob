*> The node type table of the world generation loaders (docs/protocol/10-world-generation-terrain.md sections 3.3, 4.2, 5, 7
*> and 10.4 to 10.5, 11 sections 5.1 and 7.3, 23 sections 7.1 to 7.3, 37-nether-2 section 2, 37-nether-3 section 6, 43
*> section 5, 04 section 6). Each row is a domain (CTWORLDGEN.cpy), a type name (without "minecraft:"; "-" for a domain
*> whose files carry no type) and the list of its fields, separated by ";", each a letter, a space and the JSON name (a
*> name with "." is a member of a member). The letter gives the form and the slot the value goes to (the slots of the
*> store, in the order the fields are listed): a capital is a required field, a small letter an optional one.
*>   D R K Q J L V   a child node of the domain density function, surface rule, surface condition, ore rule test, int
*>                   provider, float provider, height provider (WGN-CHILD); a string is a reference to the element of
*>                   that id, a bare number a constant (domains 1, 5, 6), a height provider may be an anchor object
*>   S U W Y Z       an array of surface rules, ore rule tests, ore targets, spawn boxes, density functions (WGN-CHILD: the
*>                   first, the others follow WGN-NEXT)
*>   M               an array of numbers (WGN-CHILD: the first constant node; WGN-INT the count)
*>   F               the placed features of a biome: an array per decoration step (domain 14 nodes in WGN-CHILD / WGN-NEXT)
*>   N G             a number, a pair of numbers (WGN-NUM); a G field may name a second spelling of its member after "="
*>   I B E C A       an integer, a boolean, an enum ("name=a|b|c": the 0-based position), a colour (24 bit RGB, -1 when
*>                   left out), an anchor (kind, value) (WGN-INT); "i name=n" is an integer that defaults to n
*>   T X H           a string, a block state ("name k=v k=v"), a string or a list of strings joined by spaces (WGN-TEXT)
*>   P               a spline (WGN-INT: its row of WSP)
*> WG-TYPE-AT USING index, domain out (0 outside the table), name out (PIC X(32)), field list out (PIC X(640)).
*> WG-TYPE-FIND (an entry of the same program) USING domain, name (PIC X(32)), row out (0 when there is none).
*> WG-KIND-AT USING kind (1 to 10, CTWORLDGEN.cpy), registry path out (PIC X(48)), label out (PIC X(32)), domain out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-TYPE-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPES.
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "constant".
    05 FILLER PIC X(640) VALUE "N value".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "add".
    05 FILLER PIC X(640) VALUE "D left;D right".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "sub".
    05 FILLER PIC X(640) VALUE "D left;D right".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "mul".
    05 FILLER PIC X(640) VALUE "D left;D right".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "div".
    05 FILLER PIC X(640) VALUE "D left;D right".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "min".
    05 FILLER PIC X(640) VALUE "D left;D right".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "max".
    05 FILLER PIC X(640) VALUE "D left;D right".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "abs".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "square".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "cube".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "negate".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "sqrt".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "reciprocal".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "log".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "sign".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "half_negative".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "quarter_negative".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "squeeze".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "cache".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "blend_density".
    05 FILLER PIC X(640) VALUE "D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "clamp".
    05 FILLER PIC X(640) VALUE "D input;N min;N max".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "lerp".
    05 FILLER PIC X(640) VALUE "D alpha;D first;D second".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "range_choice".
    05 FILLER PIC X(640) VALUE "D input;N min_inclusive;N max_exclusive;D when_in_range;D when_out_of_range".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "gradient".
    05 FILLER PIC X(640) VALUE "T axis;I from_coordinate;I to_coordinate;N from_value;N to_value".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "noise".
    05 FILLER PIC X(640) VALUE "T noise;N xz_scale;N y_scale;d shift_x;d shift_y;d shift_z".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "shift_a".
    05 FILLER PIC X(640) VALUE "T noise".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "shift_b".
    05 FILLER PIC X(640) VALUE "T noise".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "shift".
    05 FILLER PIC X(640) VALUE "T noise".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "spline".
    05 FILLER PIC X(640) VALUE "P spline".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "old_blended_noise".
    05 FILLER PIC X(640) VALUE "N xz_scale;N y_scale;N xz_factor;N y_factor;N smear_scale_multiplier".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "find_top_surface".
    05 FILLER PIC X(640) VALUE "D density;D upper_bound;I lower_bound;I cell_height".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "interpolated".
    05 FILLER PIC X(640) VALUE "I cell_size_xz;I cell_size_y;D input".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "blend_alpha".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "blend_offset".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "beardifier".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "interval_select".
    05 FILLER PIC X(640) VALUE "D input;Z thresholds;Z functions".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "slice".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "pow".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "end_outer_islands".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(32) VALUE "distance_to_point".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 02.
    05 FILLER PIC X(32) VALUE "sequence".
    05 FILLER PIC X(640) VALUE "S sequence".
    05 FILLER PIC 99 VALUE 02.
    05 FILLER PIC X(32) VALUE "condition".
    05 FILLER PIC X(640) VALUE "K if_true;R then_run".
    05 FILLER PIC 99 VALUE 02.
    05 FILLER PIC X(32) VALUE "block".
    05 FILLER PIC X(640) VALUE "X result_state".
    05 FILLER PIC 99 VALUE 02.
    05 FILLER PIC X(32) VALUE "bandlands".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 02.
    05 FILLER PIC X(32) VALUE "badlands".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 02.
    05 FILLER PIC X(32) VALUE "ore_vein".
    05 FILLER PIC X(640) VALUE "D density;D richness;D filler_gap;X ore_block;X raw_ore_block;X filler_block;N raw_ore_chance".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "biome".
    05 FILLER PIC X(640) VALUE "H biome_is".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "above_preliminary_surface".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "steep".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "hole".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "temperature".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "stone_depth".
    05 FILLER PIC X(640) VALUE "E surface_type=floor|ceiling;I offset;B add_surface_depth;I secondary_depth_range".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "water".
    05 FILLER PIC X(640) VALUE "I offset;I surface_depth_multiplier;B add_stone_depth".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "y_above".
    05 FILLER PIC X(640) VALUE "A anchor;I surface_depth_multiplier;B add_stone_depth".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "noise_threshold".
    05 FILLER PIC X(640) VALUE "T noise;N min_threshold;N max_threshold;b is_3d".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "vertical_gradient".
    05 FILLER PIC X(640) VALUE "T random_name;A true_at_and_below;A false_at_and_above".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(32) VALUE "not".
    05 FILLER PIC X(640) VALUE "K invert".
    05 FILLER PIC 99 VALUE 04.
    05 FILLER PIC X(32) VALUE "tag_match".
    05 FILLER PIC X(640) VALUE "T tag".
    05 FILLER PIC 99 VALUE 04.
    05 FILLER PIC X(32) VALUE "block_match".
    05 FILLER PIC X(640) VALUE "T block".
    05 FILLER PIC 99 VALUE 04.
    05 FILLER PIC X(32) VALUE "height_match".
    05 FILLER PIC X(640) VALUE "A min_inclusive;A max_inclusive".
    05 FILLER PIC 99 VALUE 04.
    05 FILLER PIC X(32) VALUE "all_of".
    05 FILLER PIC X(640) VALUE "U rules".
    05 FILLER PIC 99 VALUE 04.
    05 FILLER PIC X(32) VALUE "any_of".
    05 FILLER PIC X(640) VALUE "U rules".
    05 FILLER PIC 99 VALUE 04.
    05 FILLER PIC X(32) VALUE "not".
    05 FILLER PIC X(640) VALUE "Q rule".
    05 FILLER PIC 99 VALUE 04.
    05 FILLER PIC X(32) VALUE "always_true".
    05 FILLER PIC X(640) VALUE " ".
    05 FILLER PIC 99 VALUE 04.
    05 FILLER PIC X(32) VALUE "random_block_match".
    05 FILLER PIC X(640) VALUE "T block;N probability".
    05 FILLER PIC 99 VALUE 04.
    05 FILLER PIC X(32) VALUE "blockstate_match".
    05 FILLER PIC X(640) VALUE "X block_state".
    05 FILLER PIC 99 VALUE 05.
    05 FILLER PIC X(32) VALUE "constant".
    05 FILLER PIC X(640) VALUE "I value".
    05 FILLER PIC 99 VALUE 05.
    05 FILLER PIC X(32) VALUE "uniform".
    05 FILLER PIC X(640) VALUE "I min_inclusive;I max_inclusive".
    05 FILLER PIC 99 VALUE 05.
    05 FILLER PIC X(32) VALUE "biased_to_bottom".
    05 FILLER PIC X(640) VALUE "I min_inclusive;I max_inclusive".
    05 FILLER PIC 99 VALUE 05.
    05 FILLER PIC X(32) VALUE "very_biased_to_bottom".
    05 FILLER PIC X(640) VALUE "I min_inclusive;I max_inclusive".
    05 FILLER PIC 99 VALUE 05.
    05 FILLER PIC X(32) VALUE "trapezoid".
    05 FILLER PIC X(640) VALUE "I min;I max;I plateau".
    05 FILLER PIC 99 VALUE 06.
    05 FILLER PIC X(32) VALUE "constant".
    05 FILLER PIC X(640) VALUE "N value".
    05 FILLER PIC 99 VALUE 06.
    05 FILLER PIC X(32) VALUE "uniform".
    05 FILLER PIC X(640) VALUE "N min_inclusive;N max_exclusive".
    05 FILLER PIC 99 VALUE 06.
    05 FILLER PIC X(32) VALUE "trapezoid".
    05 FILLER PIC X(640) VALUE "N min;N max;N plateau".
    05 FILLER PIC 99 VALUE 06.
    05 FILLER PIC X(32) VALUE "clamped_normal".
    05 FILLER PIC X(640) VALUE "N mean;N deviation;N min;N max".
    05 FILLER PIC 99 VALUE 07.
    05 FILLER PIC X(32) VALUE "constant".
    05 FILLER PIC X(640) VALUE "A value".
    05 FILLER PIC 99 VALUE 07.
    05 FILLER PIC X(32) VALUE "uniform".
    05 FILLER PIC X(640) VALUE "A min_inclusive;A max_inclusive".
    05 FILLER PIC 99 VALUE 07.
    05 FILLER PIC X(32) VALUE "biased_to_bottom".
    05 FILLER PIC X(640) VALUE "A min_inclusive;A max_inclusive;i inner=1".
    05 FILLER PIC 99 VALUE 07.
    05 FILLER PIC X(32) VALUE "very_biased_to_bottom".
    05 FILLER PIC X(640) VALUE "A min_inclusive;A max_inclusive;i inner=1".
    05 FILLER PIC 99 VALUE 07.
    05 FILLER PIC X(32) VALUE "trapezoid".
    05 FILLER PIC X(640) VALUE "A min_inclusive;A max_inclusive;i plateau=0".
    05 FILLER PIC 99 VALUE 08.
    05 FILLER PIC X(32) VALUE "cave".
    05 FILLER PIC X(640) VALUE "N probability;V y;J count;L floor_level;L horizontal_radius_multiplier;L "
        & "vertical_radius_multiplier;L room_vertical_radius_multiplier;L thickness;b weird_thickness_bias;l "
        & "start_vertical_radius_multiplier".
    05 FILLER PIC 99 VALUE 08.
    05 FILLER PIC X(32) VALUE "canyon".
    05 FILLER PIC X(640) VALUE "N probability;V y;L vertical_rotation;L shape.distance_factor;L shape.horizontal_radius_factor;L "
        & "shape.thickness;L shape.vertical_radius_center_factor;L shape.vertical_radius_default_factor;I "
        & "shape.width_smoothness;L shape.y_scale".
    05 FILLER PIC 99 VALUE 09.
    05 FILLER PIC X(32) VALUE "ore".
    05 FILLER PIC X(640) VALUE "I size;N discard_chance_on_air_exposure;W targets".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "-".
    05 FILLER PIC X(640) VALUE "X state;Q target".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(32) VALUE "-".
    05 FILLER PIC X(640) VALUE "I sea_level;I noise.min_y;I noise.height;b legacy_random_source;b disable_mob_generation;X "
        & "default_block;X default_fluid;R material_rule;D noise_router.temperature;D noise_router.vegetation;D"
        & " noise_router.continents;D noise_router.erosion;D noise_router.depth;D noise_router.ridges;D "
        & "noise_router.chunk_surface_level;D noise_router.final_density;d aquifers.barrier;d "
        & "aquifers.fluid_level_floodedness;d aquifers.fluid_level_spread;d aquifers.lava;d "
        & "aquifers.exclusion;d aquifers.surface_level;y spawn_target".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "-".
    05 FILLER PIC X(640) VALUE "g minecraft:overworld/continents=minecraft:overworld_large_biomes/continents;g "
        & "minecraft:overworld/erosion=minecraft:overworld_large_biomes/erosion;g minecraft:overworld/temperature="
        & "minecraft:overworld_large_biomes/temperature;g minecraft:overworld/vegetation="
        & "minecraft:overworld_large_biomes/vegetation;G minecraft:overworld/ridges".
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC X(32) VALUE "-".
    05 FILLER PIC X(640) VALUE "N temperature;N downfall;B has_precipitation;e temperature_modifier=none|frozen;C "
        & "effects.water_color;c effects.foliage_color;c effects.dry_foliage_color;c effects.grass_color;e "
        & "effects.grass_color_modifier=none|dark_forest|swamp;c attributes.minecraft:visual/sky_color;c "
        & "attributes.minecraft:visual/fog_color;c attributes.minecraft:visual/water_fog_color;H carvers;F "
        & "features".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "-".
    05 FILLER PIC X(640) VALUE "I base_octave;i octave_count=1;N base_amplitude;m amplitude_modifiers;e "
        & "normalize=enabled|disabled|legacy".
    05 FILLER PIC 99 VALUE 16.
    05 FILLER PIC X(32) VALUE "-".
    05 FILLER PIC X(640) VALUE "E preset=minecraft:overworld|minecraft:nether".
    05 FILLER PIC 99 VALUE 17.
    05 FILLER PIC X(32) VALUE "-".
    05 FILLER PIC X(640) VALUE "b has_fixed_time;B has_skylight;B has_ceiling;B has_ender_dragon_fight;N coordinate_scale;I min_y;I "
        & "height;I logical_height;t infiniburn;N ambient_light;J monster_spawn_light_level;I "
        & "monster_spawn_block_light_limit;e skybox=overworld|none|end;e cardinal_light=default|nether".
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE OCCURS 90 TIMES.
       10 WS-T-DOMAIN        PIC 99.
       10 WS-T-NAME          PIC X(32).
       10 WS-T-SPEC          PIC X(640).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-DOMAIN               BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-SPEC                 PIC X(640).
 01 L-F-DOMAIN             BINARY-LONG.
 01 L-F-NAME               PIC X(32).
 01 L-F-ROW                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-DOMAIN L-NAME L-SPEC.
     MOVE 0 TO L-DOMAIN
     MOVE SPACES TO L-NAME L-SPEC
     IF L-INDEX >= 1 AND L-INDEX <= 90
         MOVE WS-T-DOMAIN(L-INDEX) TO L-DOMAIN
         MOVE WS-T-NAME(L-INDEX) TO L-NAME
         MOVE WS-T-SPEC(L-INDEX) TO L-SPEC
     END-IF
     GOBACK.
     ENTRY "WG-TYPE-FIND" USING L-F-DOMAIN L-F-NAME L-F-ROW.
     MOVE 0 TO L-F-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 90 OR L-F-ROW > 0
         IF WS-T-DOMAIN(WS-I) = L-F-DOMAIN AND WS-T-NAME(WS-I) = L-F-NAME
             MOVE WS-I TO L-F-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WG-TYPE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WG-KIND-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KINDS.
    05 FILLER PIC X(48) VALUE "worldgen/density_function".
    05 FILLER PIC X(32) VALUE "density function".
    05 FILLER PIC 99 VALUE 01.
    05 FILLER PIC X(48) VALUE "worldgen/material_rule".
    05 FILLER PIC X(32) VALUE "surface rule".
    05 FILLER PIC 99 VALUE 02.
    05 FILLER PIC X(48) VALUE "worldgen/material_condition".
    05 FILLER PIC X(32) VALUE "surface condition".
    05 FILLER PIC 99 VALUE 03.
    05 FILLER PIC X(48) VALUE "worldgen/carver".
    05 FILLER PIC X(32) VALUE "carver".
    05 FILLER PIC 99 VALUE 08.
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(32) VALUE "feature".
    05 FILLER PIC 99 VALUE 09.
    05 FILLER PIC X(48) VALUE "worldgen/noise_settings".
    05 FILLER PIC X(32) VALUE "noise settings".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "worldgen/biome".
    05 FILLER PIC X(32) VALUE "biome".
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC X(48) VALUE "worldgen/noise".
    05 FILLER PIC X(32) VALUE "noise".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(48) VALUE "worldgen/multi_noise_biome_source_parameter_list".
    05 FILLER PIC X(32) VALUE "biome source".
    05 FILLER PIC 99 VALUE 16.
    05 FILLER PIC X(48) VALUE "dimension_type".
    05 FILLER PIC X(32) VALUE "dimension type".
    05 FILLER PIC 99 VALUE 17.
 01 WS-KIND-TABLE REDEFINES WS-KINDS.
    05 WS-KIND OCCURS 10 TIMES.
       10 WS-K-NAME          PIC X(48).
       10 WS-K-LABEL         PIC X(32).
       10 WS-K-DOMAIN        PIC 99.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X(48).
 01 L-LABEL                PIC X(32).
 01 L-DOMAIN               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-NAME L-LABEL L-DOMAIN.
     MOVE WS-K-NAME(L-KIND) TO L-NAME
     MOVE WS-K-LABEL(L-KIND) TO L-LABEL
     MOVE WS-K-DOMAIN(L-KIND) TO L-DOMAIN
     GOBACK.
 END PROGRAM WG-KIND-AT.
