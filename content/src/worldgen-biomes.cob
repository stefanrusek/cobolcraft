*> The loaders of the biomes and the multi-noise biome source lists (docs/protocol/10-world-generation-terrain.md sections 7
*> and 7.8, 37-nether-3 sections 2 and 6, 43 section 5). Load behaviour, errors and the store are those of
*> worldgen-density.cob (WG-LOAD).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIOMES-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the biomes of data/<namespace>/worldgen/biome (function
*> kind 7, domain 13 nodes). WGN-NUM(1) temperature, (2) downfall; WGN-INT 1 has_precipitation, 2 temperature_modifier
*> (0 none, 1 frozen), 3 effects.water_color, 4 foliage_color, 5 dry_foliage_color, 6 grass_color (each the 24 bit RGB
*> value of the colour in any of its three forms, 43 section 5, or -1 when the file leaves it out), 7
*> grass_color_modifier (0 none, 1 dark_forest, 2 swamp), 8 the attribute minecraft:visual/sky_color, 9 fog_color, 10
*> water_fog_color (the colour, or the colour of its "argument", or -1); WGN-TEXT-1 the carvers (ids separated by
*> spaces); WGN-CHILD(1) the placed features as a chain of domain 14 nodes in listing order (WGN-INT(1) the decoration
*> step from 0, WGN-TEXT-1 the id). The remaining attributes (sounds, particles, mob spawns) and the other fields are
*> not read here.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 7.
 01 WS-LAST                BINARY-LONG VALUE 7.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "WG-LOAD" USING L-DIR WS-KIND WS-LAST L-STATUS
     GOBACK.
 END PROGRAM BIOMES-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIOME-SOURCES-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the lists of data/<namespace>/worldgen/
*> multi_noise_biome_source_parameter_list (function kind 9, domain 16 nodes: WGN-INT(1) the preset, 0
*> minecraft:overworld or 1 minecraft:nether; any other preset is an error, 37-3 2.1). The preset is code, not data.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 9.
 01 WS-LAST                BINARY-LONG VALUE 9.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "WG-LOAD" USING L-DIR WS-KIND WS-LAST L-STATUS
     GOBACK.
 END PROGRAM BIOME-SOURCES-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIOME-SOURCE-POINT-COUNT.
*> USING preset (BINARY-LONG: 0 minecraft:overworld, 1 minecraft:nether), count out (BINARY-LONG): the number of
*> parameter points the preset holds as a table here: 5 for the Nether (37-3 2.2); the overworld list is built by code
*> (10 7.4, 7594 points) and is not stored, so 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PRESET               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-PRESET L-COUNT.
     MOVE 0 TO L-COUNT
     IF L-PRESET = 1
         MOVE 5 TO L-COUNT
     END-IF
     GOBACK.
 END PROGRAM BIOME-SOURCE-POINT-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIOME-SOURCE-POINT.
*> USING preset (BINARY-LONG), index (BINARY-LONG, 1 to the count), biome out (PIC X(40), spaces when there is no
*> such point), values out (seven BINARY-LONG: temperature, humidity, continentalness, erosion, depth, weirdness,
*> offset, each quantised as in 10 7.1): the parameter points of the Nether preset in list order (37-3 2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POINTS.
    05 FILLER PIC X(40) VALUE "minecraft:nether_wastes".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(40) VALUE "minecraft:soul_sand_valley".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -5000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(40) VALUE "minecraft:crimson_forest".
    05 FILLER BINARY-LONG VALUE 4000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER PIC X(40) VALUE "minecraft:warped_forest".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 5000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 3750.
    05 FILLER PIC X(40) VALUE "minecraft:basalt_deltas".
    05 FILLER BINARY-LONG VALUE -5000.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1750.
 01 WS-POINT-TABLE REDEFINES WS-POINTS.
    05 WS-POINT OCCURS 5 TIMES.
       10 WS-P-BIOME         PIC X(40).
       10 WS-P-VALUE         BINARY-LONG OCCURS 7 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PRESET               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-BIOME                PIC X(40).
 01 L-VALUES.
    05 L-VALUE             BINARY-LONG OCCURS 7 TIMES.
 PROCEDURE DIVISION USING L-PRESET L-INDEX L-BIOME L-VALUES.
     MOVE SPACES TO L-BIOME
     INITIALIZE L-VALUES
     IF L-PRESET = 1 AND L-INDEX >= 1 AND L-INDEX <= 5
         MOVE WS-P-BIOME(L-INDEX) TO L-BIOME
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 7
             MOVE WS-P-VALUE(L-INDEX, WS-K) TO L-VALUE(WS-K)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BIOME-SOURCE-POINT.
