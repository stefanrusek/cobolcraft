*> The loaders of the noise settings, the surface rules and conditions, the carvers and the ore features (docs/protocol/
*> 10-world-generation-terrain.md sections 5, 9.1 and 10, 11 sections 5.1 and 7, 23 sections 7.1 to 7.3, 37-nether-2
*> section 2, 37-nether-4 section 6). Load behaviour, errors and the store are those of worldgen-density.cob (WG-LOAD);
*> the types and fields are those of worldgen-types.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-SETTINGS-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the noise settings of data/<namespace>/worldgen/
*> noise_settings (function kind 6, domain 11 nodes). WGN-INT 1 sea_level, 2 noise.min_y, 3 noise.height, 4
*> legacy_random_source, 5 disable_mob_generation (false when left out); WGN-TEXT-1 default_block and WGN-TEXT-2
*> default_fluid (a block state: its name, then " name=value" per property); WGN-CHILD 1 the surface rule
*> (material_rule: a reference or a rule), 2 to 9 the noise router functions temperature, vegetation, continents,
*> erosion, depth, ridges, chunk_surface_level, final_density, 10 to 15 the aquifer functions barrier,
*> fluid_level_floodedness, fluid_level_spread, lava, exclusion, surface_level (0 when there are no aquifers), 16
*> the chain of spawn_target boxes (domain 12: WGN-NUM 1 and 2 continentalness, 3 and 4 erosion, 5 and 6
*> temperature, 7 and 8 vegetation, 9 and 10 ridges; the minimum, then the maximum).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 6.
 01 WS-LAST                BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "WG-LOAD" USING L-DIR WS-KIND WS-LAST L-STATUS
     GOBACK.
 END PROGRAM NOISE-SETTINGS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MATERIAL-RULES-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the surface rules of data/<namespace>/worldgen/
*> material_rule (function kind 2, domain 2 nodes) and the named conditions of worldgen/material_condition (kind 3,
*> domain 3 nodes), as one load. A rule or condition may be a reference by id; the anchors are WGN-INT pairs (kind 1
*> absolute, 2 above_bottom, 3 below_top, 4 relative_to_sea_level, then the value).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FROM                BINARY-LONG VALUE 2.
 01 WS-TO                  BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "WG-LOAD" USING L-DIR WS-FROM WS-TO L-STATUS
     GOBACK.
 END PROGRAM MATERIAL-RULES-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CARVERS-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the carvers of data/<namespace>/worldgen/carver
*> (function kind 4, domain 8 nodes of the types cave and canyon with their value providers, domains 5 to 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 4.
 01 WS-LAST                BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "WG-LOAD" USING L-DIR WS-KIND WS-LAST L-STATUS
     GOBACK.
 END PROGRAM CARVERS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ORE-FEATURES-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the configured features of data/<namespace>/worldgen/
*> feature that are of type minecraft:ore (function kind 5, domain 9 nodes: WGN-INT(1) size, WGN-NUM(1)
*> discard_chance_on_air_exposure, WGN-CHILD(1) the chain of targets, domain 10 nodes with the state in WGN-TEXT-1 and
*> the rule test in WGN-CHILD(1)); the other features are left out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 5.
 01 WS-LAST                BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "WG-LOAD" USING L-DIR WS-KIND WS-LAST L-STATUS
     GOBACK.
 END PROGRAM ORE-FEATURES-LOAD.
