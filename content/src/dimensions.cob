*> The dimension loaders (docs/protocol/04-registry-sync.md section 6, 23 sections 7.3.3 and 9.5, 10 section 5,
*> 37-nether-1 sections 1 and 2, 38-end). Load behaviour, errors and the store are those of worldgen-density.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMENSION-TYPES-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the dimension types of data/<namespace>/dimension_type
*> (function kind 10, domain 17 nodes). WGN-INT 1 has_fixed_time, 2 has_skylight, 3 has_ceiling, 4
*> has_ender_dragon_fight, 5 min_y, 6 height, 7 logical_height, 8 monster_spawn_block_light_limit, 9 skybox (0
*> overworld, 1 none, 2 end), 10 cardinal_light (0 default, 1 nether); WGN-NUM(1) coordinate_scale, (2)
*> ambient_light; WGN-TEXT-1 infiniburn (left out: spaces); WGN-CHILD(1) monster_spawn_light_level (an int
*> provider node). The constructor checks of 04 section 6 are made (WG-CHECK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 10.
 01 WS-LAST                BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "WG-LOAD" USING L-DIR WS-KIND WS-LAST L-STATUS
     GOBACK.
 END PROGRAM DIMENSION-TYPES-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMENSION-DEFINITION-AT.
*> USING index (BINARY-LONG, 1 to 3), dimension key out, dimension type key out, biome source out, biome source preset
*> out, noise settings key out (each PIC X(40)): the three dimensions of the standard world preset "normal" (10 5,
*> 37-1 1, 38 section 1), every one with the noise generator: the overworld (dimension type minecraft:overworld,
*> multi_noise source with preset minecraft:overworld, noise settings minecraft:overworld), the Nether (the_nether,
*> multi_noise with preset minecraft:nether, minecraft:nether) and the End (the_end, source "the_end" without
*> preset, minecraft:end). An index outside gives spaces.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DEFINITIONS.
    05 FILLER PIC X(40) VALUE "minecraft:overworld".
    05 FILLER PIC X(40) VALUE "minecraft:overworld".
    05 FILLER PIC X(40) VALUE "multi_noise".
    05 FILLER PIC X(40) VALUE "minecraft:overworld".
    05 FILLER PIC X(40) VALUE "minecraft:overworld".
    05 FILLER PIC X(40) VALUE "minecraft:the_nether".
    05 FILLER PIC X(40) VALUE "minecraft:the_nether".
    05 FILLER PIC X(40) VALUE "multi_noise".
    05 FILLER PIC X(40) VALUE "minecraft:nether".
    05 FILLER PIC X(40) VALUE "minecraft:nether".
    05 FILLER PIC X(40) VALUE "minecraft:the_end".
    05 FILLER PIC X(40) VALUE "minecraft:the_end".
    05 FILLER PIC X(40) VALUE "the_end".
    05 FILLER PIC X(40) VALUE " ".
    05 FILLER PIC X(40) VALUE "minecraft:end".
 01 WS-DEFINITION-TABLE REDEFINES WS-DEFINITIONS.
    05 WS-DEFINITION OCCURS 3 TIMES.
       10 WS-D-KEY           PIC X(40).
       10 WS-D-TYPE          PIC X(40).
       10 WS-D-SOURCE        PIC X(40).
       10 WS-D-PRESET        PIC X(40).
       10 WS-D-SETTINGS      PIC X(40).
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-KEY                  PIC X(40).
 01 L-TYPE                 PIC X(40).
 01 L-SOURCE               PIC X(40).
 01 L-PRESET               PIC X(40).
 01 L-SETTINGS             PIC X(40).
 PROCEDURE DIVISION USING L-INDEX L-KEY L-TYPE L-SOURCE L-PRESET L-SETTINGS.
     MOVE SPACES TO L-KEY L-TYPE L-SOURCE L-PRESET L-SETTINGS
     IF L-INDEX >= 1 AND L-INDEX <= 3
         MOVE WS-D-KEY(L-INDEX) TO L-KEY
         MOVE WS-D-TYPE(L-INDEX) TO L-TYPE
         MOVE WS-D-SOURCE(L-INDEX) TO L-SOURCE
         MOVE WS-D-PRESET(L-INDEX) TO L-PRESET
         MOVE WS-D-SETTINGS(L-INDEX) TO L-SETTINGS
     END-IF
     GOBACK.
 END PROGRAM DIMENSION-DEFINITION-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMENSION-HEIGHTS.
*> USING index (BINARY-LONG, 1 to 3: DIMENSION-DEFINITION-AT), min_y out, height out, logical height out, sea level out
*> (BINARY-LONG), status out (BINARY-LONG): the dimension type row of the definition (DIMENSION-TYPES-LOAD) and the sea
*> level of its noise settings (NOISE-SETTINGS-LOAD). CT-OK; CT-NOT-FOUND for an index outside or when the noise
*> settings are not loaded; CT-NO-DIMENSION when the dimension type is not loaded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTWORLDGEN.
 01 WS-DIM-KEY             PIC X(40).
 01 WS-TYPE-KEY            PIC X(40).
 01 WS-SOURCE              PIC X(40).
 01 WS-PRESET              PIC X(40).
 01 WS-SETTINGS-KEY        PIC X(40).
 01 WS-KEY                 PIC X(112).
 01 WS-TYPE-KIND           BINARY-LONG VALUE 10.
 01 WS-SETTINGS-KIND       BINARY-LONG VALUE 6.
 01 WS-TYPE-ROOT           BINARY-LONG.
 01 WS-SETTINGS-ROOT       BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-LOGICAL              BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-MIN-Y L-HEIGHT L-LOGICAL L-SEA L-STATUS.
     MOVE 0 TO L-MIN-Y L-HEIGHT L-LOGICAL L-SEA WS-TYPE-ROOT WS-SETTINGS-ROOT
     MOVE CT-NOT-FOUND TO L-STATUS
     CALL "DIMENSION-DEFINITION-AT" USING L-INDEX WS-DIM-KEY WS-TYPE-KEY WS-SOURCE WS-PRESET WS-SETTINGS-KEY
     IF WS-DIM-KEY NOT = SPACES
         MOVE WS-TYPE-KEY TO WS-KEY
         CALL "WG-FIND" USING WS-TYPE-KIND WS-KEY WS-TYPE-ROOT
         MOVE WS-SETTINGS-KEY TO WS-KEY
         CALL "WG-FIND" USING WS-SETTINGS-KIND WS-KEY WS-SETTINGS-ROOT
         EVALUATE TRUE
             WHEN WS-TYPE-ROOT = 0
                 MOVE CT-NO-DIMENSION TO L-STATUS
             WHEN WS-SETTINGS-ROOT > 0
                 MOVE WGN-INT(WS-TYPE-ROOT, 5) TO L-MIN-Y
                 MOVE WGN-INT(WS-TYPE-ROOT, 6) TO L-HEIGHT
                 MOVE WGN-INT(WS-TYPE-ROOT, 7) TO L-LOGICAL
                 MOVE WGN-INT(WS-SETTINGS-ROOT, 1) TO L-SEA
                 MOVE CT-OK TO L-STATUS
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM DIMENSION-HEIGHTS.
