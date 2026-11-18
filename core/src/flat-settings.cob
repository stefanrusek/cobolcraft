*> The flat generator settings of a superflat world (docs/protocol/56-superflat-world.md sections 2 and 3; docs/design/world-types.md superflat;
*> FLATSET.cpy). The settings are the EXTERNAL record FLAT-SETTINGS.
*>
*>   FLAT-PRESET-SET USING name (PIC X(40)), status out (BINARY-LONG): selects a preset by name, with or without minecraft: (the nine presets of
*>     56 section 3.2 and the world preset `flat` of 56 section 2.6); status 0, or 1 for an unknown name (the settings stay). It marks the choice
*>     as pending for the world about to be created (FS-PENDING): a host calls it before CORE-WORLD-OPEN.
*>   FLAT-SETTINGS-DEFAULT: the settings are the world preset `flat` (bedrock 1, dirt 2, grass_block 1, plains, no lakes, no features, structure
*>     overrides strongholds and villages); nothing is pending.
*>   FLAT-SETTINGS-OPEN: CORE-WORLD-OPEN of a world of any type: for a superflat world, the pending preset, else data/minecraft/world_gen_settings.dat of
*>     the folder, else the default; for any other type nothing is kept (nothing stays pending).
*>   FLAT-SETTINGS-SAVE: WORLD-SAVE: writes the saved-data file of 56 section 2.5 for a superflat world (nothing for any other type).
*>   FLAT-SETTINGS-LOAD USING status out: reads that file into the settings: 0 read, 1 the overworld generator is not flat (settings unchanged), 2 no readable file.
*>   FLAT-SETTINGS-PREPARE: builds the expanded layers (FS-KIND, FS-STATE, FS-VOID) from the layers and the open block table; 56 section 2.4.
*>   FLAT-BASE-HEIGHT USING heightmap ordinal, height out: getBaseHeight of 56 section 4.6 (ordinals of F351-HEIGHTMAP-ORDINAL: 0 WORLD_SURFACE_WG, 1
*>     WORLD_SURFACE, 2 OCEAN_FLOOR_WG, 3 OCEAN_FLOOR, 4 MOTION_BLOCKING, 5 MOTION_BLOCKING_NO_LEAVES).
*>   FLAT-SPAWN-HEIGHT USING y out: getSpawnHeight of 56 section 4.6 for the overworld (min y -64, height 384).
*>   FLAT-STRUCT-SET-OK USING structure set key (PIC X(80)), flag out: 1 when the structure set may generate in the open world: always for another type
*>     than superflat, else per structure_overrides (56 section 2.3 and 4.7).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-PRESET-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FLATSET.
*> One row per preset: name, biome, features, lakes, layer count, six layer slots (block, height), override count, five override slots.
*> The tenth row is the world preset `flat` (56 section 2.6). Names without minecraft:.
 01 WS-PRESETS.
    05 FILLER PIC X(20) VALUE "classic_flat".
    05 FILLER PIC X(20) VALUE "plains".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(20) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 2.
    05 FILLER PIC X(20) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC X(20) VALUE "villages".
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE "tunnelers_dream".
    05 FILLER PIC X(20) VALUE "windswept_hills".
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(20) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 230.
    05 FILLER PIC X(20) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(20) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(20) VALUE "mineshafts".
    05 FILLER PIC X(20) VALUE "strongholds".
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE "water_world".
    05 FILLER PIC X(20) VALUE "deep_ocean".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(20) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE "deepslate".
    05 FILLER PIC 9(4) VALUE 64.
    05 FILLER PIC X(20) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(20) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(20) VALUE "gravel".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(20) VALUE "water".
    05 FILLER PIC 9(4) VALUE 90.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(20) VALUE "ocean_ruins".
    05 FILLER PIC X(20) VALUE "shipwrecks".
    05 FILLER PIC X(20) VALUE "ocean_monuments".
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE "overworld".
    05 FILLER PIC X(20) VALUE "plains".
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(20) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 59.
    05 FILLER PIC X(20) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(20) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC 9 VALUE 5.
    05 FILLER PIC X(20) VALUE "villages".
    05 FILLER PIC X(20) VALUE "mineshafts".
    05 FILLER PIC X(20) VALUE "pillager_outposts".
    05 FILLER PIC X(20) VALUE "ruined_portals".
    05 FILLER PIC X(20) VALUE "strongholds".
    05 FILLER PIC X(20) VALUE "snowy_kingdom".
    05 FILLER PIC X(20) VALUE "snowy_plains".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 5.
    05 FILLER PIC X(20) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 59.
    05 FILLER PIC X(20) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(20) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE "snow".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(20) VALUE "villages".
    05 FILLER PIC X(20) VALUE "igloos".
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE "bottomless_pit".
    05 FILLER PIC X(20) VALUE "plains".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(20) VALUE "cobblestone".
    05 FILLER PIC 9(4) VALUE 2.
    05 FILLER PIC X(20) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(20) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC X(20) VALUE "villages".
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE "desert".
    05 FILLER PIC X(20) VALUE "desert".
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(20) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(20) VALUE "sandstone".
    05 FILLER PIC 9(4) VALUE 52.
    05 FILLER PIC X(20) VALUE "sand".
    05 FILLER PIC 9(4) VALUE 8.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(20) VALUE "villages".
    05 FILLER PIC X(20) VALUE "desert_pyramids".
    05 FILLER PIC X(20) VALUE "mineshafts".
    05 FILLER PIC X(20) VALUE "strongholds".
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE "redstone_ready".
    05 FILLER PIC X(20) VALUE "desert".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(20) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(20) VALUE "sandstone".
    05 FILLER PIC 9(4) VALUE 116.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE "the_void".
    05 FILLER PIC X(20) VALUE "the_void".
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC X(20) VALUE "air".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE "flat".
    05 FILLER PIC X(20) VALUE "plains".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(20) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 2.
    05 FILLER PIC X(20) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(20) VALUE "strongholds".
    05 FILLER PIC X(20) VALUE "villages".
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
    05 FILLER PIC X(20) VALUE SPACES.
 01 WS-TABLE REDEFINES WS-PRESETS.
    05 WS-ROW OCCURS 10 TIMES.
       10 PR-NAME             PIC X(20).
       10 PR-BIOME            PIC X(20).
       10 PR-FEATURES         PIC 9.
       10 PR-LAKES            PIC 9.
       10 PR-LAYER-COUNT      PIC 9.
       10 PR-LAYER OCCURS 6 TIMES.
          15 PR-KEY           PIC X(20).
          15 PR-HEIGHT        PIC 9(4).
       10 PR-OVR-COUNT        PIC 9.
       10 PR-OVR              PIC X(20) OCCURS 5 TIMES.
 01 WS-NAME                PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-STATUS.
     MOVE 1 TO L-STATUS
     MOVE L-NAME TO WS-NAME
     IF L-NAME(1:10) = "minecraft:"
         MOVE SPACES TO WS-NAME
         MOVE L-NAME(11:30) TO WS-NAME
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR L-STATUS = 0
         IF PR-NAME(WS-I) = WS-NAME
             MOVE 0 TO L-STATUS
             MOVE 0 TO FS-TOTAL
             MOVE PR-LAYER-COUNT(WS-I) TO FS-LAYER-COUNT
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > FS-LAYER-COUNT
                 MOVE SPACES TO FS-L-KEY(WS-J)
                 STRING "minecraft:" DELIMITED BY SIZE PR-KEY(WS-I, WS-J) DELIMITED BY SPACE INTO FS-L-KEY(WS-J)
                 MOVE PR-HEIGHT(WS-I, WS-J) TO WS-H
                 MOVE WS-H TO FS-L-HEIGHT(WS-J)
                 ADD WS-H TO FS-TOTAL
             END-PERFORM
             MOVE SPACES TO FS-BIOME
             STRING "minecraft:" DELIMITED BY SIZE PR-BIOME(WS-I) DELIMITED BY SPACE INTO FS-BIOME
             MOVE PR-FEATURES(WS-I) TO FS-FEATURES
             MOVE PR-LAKES(WS-I) TO FS-LAKES
             MOVE 1 TO FS-OVR-MODE
             MOVE PR-OVR-COUNT(WS-I) TO FS-OVR-COUNT
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > FS-OVR-COUNT
                 MOVE SPACES TO FS-OVR(WS-J)
                 STRING "minecraft:" DELIMITED BY SIZE PR-OVR(WS-I, WS-J) DELIMITED BY SPACE INTO FS-OVR(WS-J)
             END-PERFORM
             MOVE 1 TO FS-LOADED FS-PENDING FS-GEN-STRUCT
             MOVE -1 TO FS-STAMP
             CALL "FLAT-STRUCT-RESET"
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FLAT-PRESET-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-STRUCT-RESET.
*> No parameters: forgets what the structure code remembered for the settings before (the cached starts of the chunks, the possible sets, the ring
*> rows of the strongholds): they depend on the settings' biome and structure_overrides.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-S                   BINARY-LONG.
 PROCEDURE DIVISION.
     ADD 1 TO SD-EPOCH
     MOVE 0 TO SD-POSS-DONE SD-RING-COUNT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         MOVE 0 TO SS-RING-ROW(WS-S)
     END-PERFORM
     GOBACK.
 END PROGRAM FLAT-STRUCT-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-SETTINGS-DEFAULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FLATSET.
 01 WS-NAME                PIC X(40) VALUE "flat".
 01 WS-STATUS              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     MOVE 0 TO FS-PENDING
     GOBACK.
 END PROGRAM FLAT-SETTINGS-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-SETTINGS-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY FLATSET.
 01 WS-STATUS              BINARY-LONG.
 PROCEDURE DIVISION.
     IF CW-WORLD-TYPE = "superflat"
         IF FS-PENDING = 1
             MOVE 0 TO FS-PENDING
             MOVE -1 TO FS-STAMP
         ELSE
             CALL "FLAT-SETTINGS-LOAD" USING WS-STATUS
             IF WS-STATUS NOT = 0
                 CALL "FLAT-SETTINGS-DEFAULT"
             END-IF
         END-IF
     ELSE
         MOVE 0 TO FS-PENDING
     END-IF
     GOBACK.
 END PROGRAM FLAT-SETTINGS-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-SETTINGS-SAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY FLATSET.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-VALUE               PIC X(48).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-SUFFIX              PIC X(128).
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     IF CW-WORLD-TYPE NOT = "superflat"
         GOBACK
     END-IF
     IF FS-LOADED = 0
         CALL "FLAT-SETTINGS-DEFAULT"
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE "/data" TO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "CBL_CREATE_DIR" USING WS-PATH
     MOVE "/data/minecraft" TO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "CBL_CREATE_DIR" USING WS-PATH
     MOVE 0 TO RETURN-CODE
*>   56 section 2.5: root, data { seed, generate_structures, bonus_chest, dimensions { minecraft:overworld { type, generator { type, settings } } } }
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "data" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "seed" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL CW-SEED
     MOVE "generate_structures" TO WN MOVE 19 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL FS-GEN-STRUCT
     MOVE "bonus_chest" TO WN MOVE 11 TO WL
     MOVE 0 TO WS-INT
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     MOVE "dimensions" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:overworld" TO WN MOVE 19 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "generator" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "settings" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "layers" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND FS-LAYER-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FS-LAYER-COUNT
         MOVE SPACES TO WN
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
         MOVE "height" TO WN MOVE 6 TO WL
         MOVE FS-L-HEIGHT(WS-I) TO WS-INT
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
         MOVE "block" TO WN MOVE 5 TO WL
         MOVE FS-L-KEY(WS-I) TO WS-VALUE
         COMPUTE WS-VALUE-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-VALUE))
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-VALUE WS-VALUE-LENGTH
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-PERFORM
     CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     MOVE "biome" TO WN MOVE 5 TO WL
     MOVE FS-BIOME TO WS-VALUE
     COMPUTE WS-VALUE-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-VALUE))
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-VALUE WS-VALUE-LENGTH
     MOVE "lakes" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL FS-LAKES
     MOVE "features" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL FS-FEATURES
     IF FS-OVR-MODE = 1
         MOVE "structure_overrides" TO WN MOVE 19 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-STRING FS-OVR-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FS-OVR-COUNT
             MOVE FS-OVR(WS-I) TO WS-VALUE
             COMPUTE WS-VALUE-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-VALUE))
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WS-ELEMENT WS-VALUE WS-VALUE-LENGTH
         END-PERFORM
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "type" TO WN MOVE 4 TO WL
     MOVE "minecraft:flat" TO WS-VALUE
     MOVE 14 TO WS-VALUE-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-VALUE WS-VALUE-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "type" TO WN MOVE 4 TO WL
     MOVE "minecraft:overworld" TO WS-VALUE
     MOVE 19 TO WS-VALUE-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-VALUE WS-VALUE-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "/data/minecraft/world_gen_settings.dat" TO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     GOBACK.
 END PROGRAM FLAT-SETTINGS-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-READ-SETTINGS.
*> USING PB-BUFFER (at the first child of the compound `settings` of a flat generator, 56 section 2.1): reads layers, biome, lakes, features and
*> structure_overrides (a bare String or a List of Strings, 56 section 2.3) into FLAT-SETTINGS; an absent member has its codec default (56 section 2.1).
*> The compound is consumed to its end.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FLATSET.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 48.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     MOVE 0 TO FS-LAYER-COUNT FS-LAKES FS-FEATURES FS-OVR-COUNT FS-OVR-MODE FS-TOTAL
     MOVE SPACES TO FS-BIOME
     MOVE "minecraft:plains" TO FS-BIOME
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "layers" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     MOVE SPACES TO WS-KEY
                     MOVE 0 TO WS-HEIGHT
                     PERFORM UNTIL PB-ERROR = 1
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-NAME-CAPACITY WL
                         IF WS-INNER-TYPE = 0
                             EXIT PERFORM
                         END-IF
                         EVALUATE TRUE
                             WHEN WN = "block" AND WS-INNER-TYPE = 8
                                 MOVE SPACES TO WS-KEY
                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-LENGTH
                             WHEN WN = "height" AND WS-INNER-TYPE = 3
                                 CALL "PB-GET-INT" USING PB-BUFFER WS-HEIGHT
                             WHEN OTHER
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                         END-EVALUATE
                     END-PERFORM
                     IF FS-LAYER-COUNT < FS-MAX-LAYERS AND WS-KEY NOT = SPACES AND PB-ERROR = 0
                         ADD 1 TO FS-LAYER-COUNT
                         MOVE WS-KEY TO FS-L-KEY(FS-LAYER-COUNT)
                         MOVE WS-HEIGHT TO FS-L-HEIGHT(FS-LAYER-COUNT)
                         ADD WS-HEIGHT TO FS-TOTAL
                     END-IF
                 END-PERFORM
             WHEN WN = "biome" AND WS-TYPE = 8
                 MOVE SPACES TO FS-BIOME
                 CALL "NBT-READ-STRING" USING PB-BUFFER FS-BIOME WS-KEY-CAPACITY WS-LENGTH
             WHEN WN = "lakes" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER FS-LAKES
             WHEN WN = "features" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER FS-FEATURES
             WHEN WN = "structure_overrides" AND WS-TYPE = 8
                 MOVE 1 TO FS-OVR-MODE FS-OVR-COUNT
                 MOVE SPACES TO FS-OVR(1)
                 CALL "NBT-READ-STRING" USING PB-BUFFER FS-OVR(1) WS-KEY-CAPACITY WS-LENGTH
             WHEN WN = "structure_overrides" AND WS-TYPE = 9
                 MOVE 1 TO FS-OVR-MODE
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     MOVE SPACES TO WS-KEY
                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-LENGTH
                     IF FS-OVR-COUNT < FS-MAX-OVERRIDES AND PB-ERROR = 0
                         ADD 1 TO FS-OVR-COUNT
                         MOVE WS-KEY TO FS-OVR(FS-OVR-COUNT)
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM FLAT-READ-SETTINGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-READ-GENERATOR.
*> USING PB-BUFFER (at the first child of a `generator` compound), flat out (BINARY-LONG): 1 when its type is minecraft:flat and the settings were read
*> (FLAT-READ-SETTINGS), else 0 with the settings untouched. The compound is consumed to its end: the type is looked up first by a scan, whatever the
*> order of the members.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 48.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HOME                BINARY-LONG.
 01 WS-IS-FLAT             BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-VALUE               PIC X(48).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-FLAT                 BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-FLAT.
     MOVE 0 TO L-FLAT WS-IS-FLAT
     MOVE PB-POS TO WS-HOME
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "type" AND WS-TYPE = 8
             MOVE SPACES TO WS-VALUE
             CALL "NBT-READ-STRING" USING PB-BUFFER WS-VALUE WS-KEY-CAPACITY WS-LENGTH
             IF WS-VALUE = "minecraft:flat"
                 MOVE 1 TO WS-IS-FLAT
             END-IF
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     IF WS-IS-FLAT = 1 AND PB-ERROR = 0
         MOVE WS-HOME TO PB-POS
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             IF WN = "settings" AND WS-TYPE = 10
                 CALL "FLAT-READ-SETTINGS" USING PB-BUFFER
                 MOVE 1 TO L-FLAT
             ELSE
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FLAT-READ-GENERATOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-SETTINGS-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FLATSET.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-OUTCOME             BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DATA-TYPE           BINARY-LONG.
 01 WS-DIM-TYPE            BINARY-LONG.
 01 WS-STEM-TYPE           BINARY-LONG.
 01 WS-GEN                 BINARY-LONG.
 01 WS-FLAT                BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/data/minecraft/world_gen_settings.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATUS.
     MOVE 2 TO L-STATUS
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "NBT-FILE-READ" USING WS-PATH WS-PATH-LENGTH PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME NOT = 0
         GOBACK
     END-IF
     MOVE 1 TO L-STATUS
     MOVE 1 TO WS-GEN
     MOVE 0 TO WS-FLAT
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "data" AND WS-TYPE = 10
             PERFORM UNTIL PB-ERROR = 1
                 MOVE SPACES TO WN
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-DATA-TYPE WN WS-NAME-CAPACITY WL
                 IF WS-DATA-TYPE = 0
                     EXIT PERFORM
                 END-IF
                 EVALUATE TRUE
                     WHEN WN = "generate_structures" AND WS-DATA-TYPE = 1
                         CALL "PB-GET-BYTE" USING PB-BUFFER WS-GEN
                     WHEN WN = "dimensions" AND WS-DATA-TYPE = 10
                         PERFORM UNTIL PB-ERROR = 1
                             MOVE SPACES TO WN
                             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-DIM-TYPE WN WS-NAME-CAPACITY WL
                             IF WS-DIM-TYPE = 0
                                 EXIT PERFORM
                             END-IF
                             IF WN = "minecraft:overworld" AND WS-DIM-TYPE = 10
                                 PERFORM UNTIL PB-ERROR = 1
                                     MOVE SPACES TO WN
                                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-STEM-TYPE WN WS-NAME-CAPACITY WL
                                     IF WS-STEM-TYPE = 0
                                         EXIT PERFORM
                                     END-IF
                                     IF WN = "generator" AND WS-STEM-TYPE = 10
                                         CALL "FLAT-READ-GENERATOR" USING PB-BUFFER WS-FLAT
                                     ELSE
                                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-STEM-TYPE
                                     END-IF
                                 END-PERFORM
                             ELSE
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-DIM-TYPE
                             END-IF
                         END-PERFORM
                     WHEN OTHER
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-DATA-TYPE
                 END-EVALUATE
             END-PERFORM
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     IF WS-FLAT = 1
         MOVE 0 TO L-STATUS
         MOVE WS-GEN TO FS-GEN-STRUCT
         MOVE 1 TO FS-LOADED
         MOVE -1 TO FS-STAMP
         CALL "FLAT-STRUCT-RESET"
     END-IF
     GOBACK.
 END PROGRAM FLAT-SETTINGS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-BLOCK-MOTION.
*> USING block number (BINARY-LONG, the 1-based number in CORE-BLOCKS; 0 = air or unknown), known (BINARY-LONG, 1 when the block tag
*> minecraft:blocks_motion_in_heightmap exists in the open content set), kind out (BINARY-LONG): how a flat layer of that block answers the
*> MOTION_BLOCKING test of 56 section 2.4: 0 does not satisfy it (air, a snow layer, flowers: the layer is nulled), 1 a fluid (water, lava),
*> 2 a block of the tag. A set without the tag falls back to CB-SOLID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:blocks_motion_in_heightmap".
 01 WS-BARE                PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-KNOWN L-KIND.
     MOVE 0 TO L-KIND
     IF L-BLOCK = 0
         GOBACK
     END-IF
     CALL "KEY-BARE" USING CB-KEY(L-BLOCK) WS-BARE
     EVALUATE TRUE
         WHEN WS-BARE = "air" OR WS-BARE = "cave_air" OR WS-BARE = "void_air"
             CONTINUE
         WHEN WS-BARE = "water" OR WS-BARE = "lava"
             MOVE 1 TO L-KIND
         WHEN L-KNOWN = 1
             COMPUTE WS-ID = L-BLOCK - 1
             CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-ID WS-HAS
             IF WS-HAS = 1
                 MOVE 2 TO L-KIND
             END-IF
         WHEN OTHER
             IF CB-SOLID(L-BLOCK) = 1
                 MOVE 2 TO L-KIND
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FLAT-BLOCK-MOTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-SETTINGS-PREPARE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY FLATSET.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:blocks_motion_in_heightmap".
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 1 TIMES.
 01 WS-CAPACITY            BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 PROCEDURE DIVISION.
     IF FS-LOADED = 0
         CALL "FLAT-SETTINGS-DEFAULT"
     END-IF
     IF FS-STAMP = CB-EPOCH
         GOBACK
     END-IF
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-TAG-IDS WS-CAPACITY WS-STATUS
     MOVE 1 TO WS-KNOWN
     IF WS-STATUS = CT-NOT-FOUND OR WS-STATUS = CT-NOT-OPEN
         MOVE 0 TO WS-KNOWN
     END-IF
     MOVE 0 TO WS-N
     MOVE 1 TO FS-VOID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FS-LAYER-COUNT
         CALL "FD-BLOCK-INDEX" USING FS-L-KEY(WS-I) WS-IDX
         MOVE 0 TO WS-STATE
         IF WS-IDX > 0
             MOVE CB-DEFAULT-STATE(WS-IDX) TO WS-STATE
         END-IF
         CALL "FLAT-BLOCK-MOTION" USING WS-IDX WS-KNOWN WS-KIND
         IF WS-STATE NOT = 0 AND FS-L-HEIGHT(WS-I) > 0
             MOVE 0 TO FS-VOID
         END-IF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > FS-L-HEIGHT(WS-I) OR WS-N >= FS-MAX-STACK
             ADD 1 TO WS-N
             MOVE WS-KIND TO FS-KIND(WS-N)
             MOVE WS-STATE TO FS-STATE(WS-N)
         END-PERFORM
     END-PERFORM
     MOVE CB-EPOCH TO FS-STAMP
     GOBACK.
 END PROGRAM FLAT-SETTINGS-PREPARE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-BASE-HEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FLATSET.
 01 WS-TOP                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ORDINAL              BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ORDINAL L-HEIGHT.
     CALL "FLAT-SETTINGS-PREPARE"
     MOVE -64 TO L-HEIGHT
     MOVE 0 TO WS-DONE
     COMPUTE WS-TOP = FS-TOTAL - 1
     IF WS-TOP > 319
         MOVE 319 TO WS-TOP
     END-IF
     PERFORM VARYING WS-I FROM WS-TOP BY -1 UNTIL WS-I < 0 OR WS-DONE = 1
         COMPUTE WS-K = WS-I + 1
         IF FS-KIND(WS-K) NOT = 0
             IF (L-ORDINAL NOT = 2 AND L-ORDINAL NOT = 3) OR FS-KIND(WS-K) = 2
                 COMPUTE L-HEIGHT = -64 + WS-I + 1
                 MOVE 1 TO WS-DONE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FLAT-BASE-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-SPAWN-HEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FLATSET.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-Y.
     IF FS-LOADED = 0
         CALL "FLAT-SETTINGS-DEFAULT"
     END-IF
     COMPUTE L-Y = -64 + FUNCTION MIN(FS-TOTAL, 384)
     GOBACK.
 END PROGRAM FLAT-SPAWN-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-STRUCT-SET-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY FLATSET.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FLAG.
     MOVE 1 TO L-FLAG
     IF CW-WORLD-TYPE = "superflat"
         IF FS-LOADED = 0
             CALL "FLAT-SETTINGS-DEFAULT"
         END-IF
         IF FS-GEN-STRUCT = 0
             MOVE 0 TO L-FLAG
         END-IF
         IF FS-OVR-MODE = 1
             MOVE 0 TO L-FLAG
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FS-OVR-COUNT
                 IF FS-OVR(WS-I) = L-KEY
                     MOVE 1 TO L-FLAG
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FLAT-STRUCT-SET-OK.
