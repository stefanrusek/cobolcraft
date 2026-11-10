*> Implementation test of the surface rules (core/src/surface.cob; T0422; docs/protocol/10 sections 7.7 and 10): the zoom seed
*> (SHA-256 of the seed) and the fuzzy biome lookup (expected ids from an independent Python evaluation of 7.7), the 192
*> terracotta bands (10.6; same Python source: the counts of each block and seven sample positions), the vertical gradient
*> conditions of bedrock and deepslate at positions whose random float was computed independently (10.4), and the rule tree of
*> core/tests/fixtures/surface (the structure of 10.9 reduced to plains, desert, badlands and jagged peaks, with the surface noises of
*> amplitude 0, so surfaceDepth is 3 and the secondary depth 0 everywhere): the grass and dirt of the default, the floor of shallow and
*> deep water, desert sand with sandstone under it and on a ceiling, the badlands bands and terracotta, a steep slope; the pillars
*> of eroded badlands (10.7; their noises are real, so the checks are the invariants of the rule: stone from the first free block up
*> to a top, nothing under water); and the whole surface stage over a chunk of the single-biome climate source.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SURFACE-RULES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY SURFACE.
 COPY GENSTEPS.
 COPY GENSTAGE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/surface".
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-ROOT                BINARY-LONG.
 01 WS-KIND-RULE           BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:overworld".
 01 WS-KEY48               PIC X(48).
 01 WS-KIND-COND           BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-BIOME-ID            BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-WATER-TOP           BINARY-LONG.
 01 WS-LEVEL               FLOAT-LONG.
 01 WS-GOT-ID              BINARY-LONG.
 01 WS-TEXT                PIC X(16).
 01 WS-COUNT               BINARY-LONG.
 01 WS-MAX-TOP             BINARY-LONG.
 01 WS-COLS                BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40) VALUE "minecraft:plains".
 01 WS-BLOCKS.
    05 FILLER PIC X(48) VALUE "minecraft:air".
    05 FILLER PIC X(48) VALUE "minecraft:stone".
    05 FILLER PIC X(48) VALUE "minecraft:water".
    05 FILLER PIC X(48) VALUE "minecraft:lava".
    05 FILLER PIC X(48) VALUE "minecraft:grass_block".
    05 FILLER PIC X(48) VALUE "minecraft:dirt".
    05 FILLER PIC X(48) VALUE "minecraft:bedrock".
    05 FILLER PIC X(48) VALUE "minecraft:deepslate".
    05 FILLER PIC X(48) VALUE "minecraft:sand".
    05 FILLER PIC X(48) VALUE "minecraft:sandstone".
    05 FILLER PIC X(48) VALUE "minecraft:gravel".
    05 FILLER PIC X(48) VALUE "minecraft:red_sand".
    05 FILLER PIC X(48) VALUE "minecraft:red_sandstone".
    05 FILLER PIC X(48) VALUE "minecraft:terracotta".
    05 FILLER PIC X(48) VALUE "minecraft:orange_terracotta".
    05 FILLER PIC X(48) VALUE "minecraft:yellow_terracotta".
    05 FILLER PIC X(48) VALUE "minecraft:brown_terracotta".
    05 FILLER PIC X(48) VALUE "minecraft:red_terracotta".
    05 FILLER PIC X(48) VALUE "minecraft:white_terracotta".
    05 FILLER PIC X(48) VALUE "minecraft:light_gray_terracotta".
 01 WS-BLOCK-TABLE REDEFINES WS-BLOCKS.
    05 WS-BLOCK            PIC X(48) OCCURS 20 TIMES.
*> default states: air 0, stone 1, water 86, lava 102, then 10 to 25 in the order above from grass_block
 01 WS-BIOMES.
    05 FILLER PIC X(48) VALUE "minecraft:plains".
    05 FILLER PIC X(48) VALUE "minecraft:desert".
    05 FILLER PIC X(48) VALUE "minecraft:badlands".
    05 FILLER PIC X(48) VALUE "minecraft:eroded_badlands".
    05 FILLER PIC X(48) VALUE "minecraft:jagged_peaks".
    05 FILLER PIC X(48) VALUE "minecraft:grove".
 01 WS-BIOME-TABLE REDEFINES WS-BIOMES.
    05 WS-BIOME-KEY        PIC X(48) OCCURS 6 TIMES.
 01 WS-PROFILE.
    05 WS-P-COUNT          BINARY-LONG.
    05 WS-P-ITEM OCCURS 12 TIMES.
       10 WS-P-Y           BINARY-LONG.
       10 WS-P-STATE       BINARY-LONG.
 01 WS-BAND-KEYS.
    05 FILLER PIC X(32) VALUE "terracotta".
    05 FILLER PIC X(32) VALUE "orange_terracotta".
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "0" TO CS-SEED-TEXT
     MOVE 0 TO CW-SEED
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE 20 TO CB-BLOCK-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-BLOCK(WS-I) TO CB-KEY(WS-I)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-BLOCK(WS-I))) TO CB-KEY-LENGTH(WS-I)
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I + 7
     END-PERFORM
     MOVE 0 TO CB-DEFAULT-STATE(1)
     MOVE 1 TO CB-DEFAULT-STATE(2)
     MOVE 86 TO CB-DEFAULT-STATE(3)
     MOVE 102 TO CB-DEFAULT-STATE(4)
     MOVE 6 TO CBI-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-BIOME-KEY(WS-I) TO CBI-KEY(WS-I)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-BIOME-KEY(WS-I))) TO CBI-KEY-LENGTH(WS-I)
     END-PERFORM
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     CALL "MATERIAL-RULES-LOAD" USING WS-DIR WS-STATUS
     MOVE "test surface rules the fixture material rules load" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     CALL "WG-FIND" USING WS-KIND-RULE WS-KEY WS-ROOT

*>   the zoom seed of world seed 0 (SHA-256 of eight zero bytes, first eight bytes read little-endian)
     MOVE "test surface rules the zoom seed of the world seed 0" TO TL-CASE
     MOVE SF-ZOOM-SEED TO TL-OBSERVED-N
     MOVE 8794265229978523055 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   fuzzy biome lookup over a checkerboard of cells (id = (qx + qz) mod 2) at y 70, z 5, x 0 to 15
     PERFORM FILL-CHECKERBOARD
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         MOVE -999 TO SC-BIO-Q
         MOVE 70 TO WS-Y
         MOVE 5 TO WS-LZ
         CALL "SURFACE-BIOME-AT" USING WS-JOB WS-I WS-Y WS-LZ WS-GOT-ID
         MOVE FUNCTION CHAR(WS-GOT-ID + 49) TO WS-TEXT(WS-I + 1:1)
     END-PERFORM
     MOVE "test surface rules the zoomed biome of 16 columns of a checkerboard" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "0111000011000001" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE

*>   the terracotta bands
     CALL "SURFACE-BANDS-ENSURE"
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 192
         IF SF-BAND(WS-I) = 22
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "test surface rules 27 of the 192 bands are orange terracotta" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 27 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 192
         IF SF-BAND(WS-I) = 21
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "test surface rules 94 of the 192 bands are plain terracotta" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 94 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 192
         IF SF-BAND(WS-I) = 23 OR SF-BAND(WS-I) = 24 OR SF-BAND(WS-I) = 25
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "test surface rules 20 yellow, 17 brown and 15 red bands" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 52 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 192
         IF SF-BAND(WS-I) = 26 OR SF-BAND(WS-I) = 27
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "test surface rules 9 white and 10 light grey bands" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 19 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test surface rules band 0 is white, 58 white, 59 plain, 60 red, 191 red" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SF-BAND(1) - 21) * 100000000 + (SF-BAND(59) - 21) * 1000000 + (SF-BAND(60) - 21) * 10000
         + (SF-BAND(61) - 21) * 100 + SF-BAND(192) - 21
     COMPUTE TL-EXPECTED-N = 5 * 100000000 + 5 * 1000000 + 0 * 10000 + 4 * 100 + 4
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   plains: grass, dirt, stone, deepslate, bedrock (zero noises: surfaceDepth 3, minSurfaceLevel 65)
     MOVE 0 TO WS-BIOME-ID
     MOVE 69 TO WS-TOP
     MOVE 0 TO WS-WATER-TOP
     MOVE 70 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     MOVE 0 TO WS-LX
     MOVE 0 TO WS-LZ
     PERFORM RUN-COLUMN
     MOVE 1 TO WS-LX
     MOVE 2 TO WS-LZ
     PERFORM RUN-COLUMN
     MOVE 3 TO WS-LX
     MOVE 5 TO WS-LZ
     PERFORM RUN-COLUMN
     MOVE 4 TO WS-LX
     MOVE 7 TO WS-LZ
     PERFORM RUN-COLUMN
     MOVE 5 TO WS-LX
     MOVE 9 TO WS-LZ
     PERFORM RUN-COLUMN
     MOVE 10 TO WS-P-COUNT
     MOVE 69 TO WS-P-Y(1)
     MOVE 12 TO WS-P-STATE(1)
     MOVE 68 TO WS-P-Y(2)
     MOVE 13 TO WS-P-STATE(2)
     MOVE 66 TO WS-P-Y(3)
     MOVE 13 TO WS-P-STATE(3)
     MOVE 65 TO WS-P-Y(4)
     MOVE 1 TO WS-P-STATE(4)
     MOVE 8 TO WS-P-Y(5)
     MOVE 1 TO WS-P-STATE(5)
     MOVE 0 TO WS-P-Y(6)
     MOVE 15 TO WS-P-STATE(6)
     MOVE -59 TO WS-P-Y(7)
     MOVE 15 TO WS-P-STATE(7)
     MOVE -64 TO WS-P-Y(8)
     MOVE 14 TO WS-P-STATE(8)
     MOVE 70 TO WS-P-Y(9)
     MOVE 0 TO WS-P-STATE(9)
     MOVE 64 TO WS-P-Y(10)
     MOVE 1 TO WS-P-STATE(10)
     MOVE 0 TO WS-LX
     MOVE 0 TO WS-LZ
     MOVE "test surface rules plains: grass, three dirt, stone, deepslate to y 0, bedrock at -64" TO TL-CASE
     PERFORM CHECK-PROFILE
*>   the gradients: (x, y, z) with the random float computed independently
     MOVE 1 TO WS-P-COUNT
     MOVE -63 TO WS-P-Y(1)
     MOVE 14 TO WS-P-STATE(1)
     MOVE "test surface rules bedrock at (0, -63, 0): float 0.64 < 0.8" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 1 TO WS-P-Y(1)
     MOVE 15 TO WS-P-STATE(1)
     MOVE "test surface rules deepslate at (0, 1, 0): float 0.169 < 0.875" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 1 TO WS-LX
     MOVE 2 TO WS-LZ
     MOVE -62 TO WS-P-Y(1)
     MOVE 14 TO WS-P-STATE(1)
     MOVE "test surface rules bedrock at (1, -62, 2): float 0.427 < 0.6" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 4 TO WS-P-Y(1)
     MOVE 15 TO WS-P-STATE(1)
     MOVE "test surface rules deepslate at (1, 4, 2): float 0.409 < 0.5" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 3 TO WS-LX
     MOVE 5 TO WS-LZ
     MOVE -61 TO WS-P-Y(1)
     MOVE 15 TO WS-P-STATE(1)
     MOVE "test surface rules no bedrock at (3, -61, 5): float 0.503 >= 0.4, deepslate" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 7 TO WS-P-Y(1)
     MOVE 1 TO WS-P-STATE(1)
     MOVE "test surface rules stone at (3, 7, 5): float 0.572 >= 0.125" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 4 TO WS-LX
     MOVE 7 TO WS-LZ
     MOVE -60 TO WS-P-Y(1)
     MOVE 15 TO WS-P-STATE(1)
     MOVE "test surface rules no bedrock at (4, -60, 7): float 0.518 >= 0.2, deepslate" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 2 TO WS-P-Y(1)
     MOVE 1 TO WS-P-STATE(1)
     MOVE "test surface rules stone at (4, 2, 7): float 0.997 >= 0.75" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 5 TO WS-LX
     MOVE 9 TO WS-LZ
     MOVE -63 TO WS-P-Y(1)
     MOVE 15 TO WS-P-STATE(1)
     MOVE "test surface rules no bedrock at (5, -63, 9): float 0.809 >= 0.8, deepslate" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 6 TO WS-P-Y(1)
     MOVE 1 TO WS-P-STATE(1)
     MOVE "test surface rules stone at (5, 6, 9): float 0.318 >= 0.25" TO TL-CASE
     PERFORM CHECK-PROFILE

*>   plains under 9 blocks of water: the floor is dirt (not grass), the water stays
     MOVE 60 TO WS-TOP
     MOVE 69 TO WS-WATER-TOP
     MOVE 60 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     MOVE 3 TO WS-LX
     MOVE 3 TO WS-LZ
     PERFORM RUN-COLUMN
     MOVE 6 TO WS-P-COUNT
     MOVE 60 TO WS-P-Y(1)
     MOVE 13 TO WS-P-STATE(1)
     MOVE 57 TO WS-P-Y(2)
     MOVE 13 TO WS-P-STATE(2)
     MOVE 56 TO WS-P-Y(3)
     MOVE 1 TO WS-P-STATE(3)
     MOVE 61 TO WS-P-Y(4)
     MOVE 86 TO WS-P-STATE(4)
     MOVE 69 TO WS-P-Y(5)
     MOVE 86 TO WS-P-STATE(5)
     MOVE 70 TO WS-P-Y(6)
     MOVE 0 TO WS-P-STATE(6)
     MOVE "test surface rules a shallow ocean floor is dirt, the water is left" TO TL-CASE
     PERFORM CHECK-PROFILE
*>   (the water state of the block table is 86: the fixture's CB table gives water its own default state 86 + 0)
     MOVE 20 TO WS-TOP
     MOVE 69 TO WS-WATER-TOP
     MOVE 20 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM RUN-COLUMN
     MOVE 3 TO WS-P-COUNT
     MOVE 20 TO WS-P-Y(1)
     MOVE 18 TO WS-P-STATE(1)
     MOVE 19 TO WS-P-Y(2)
     MOVE 1 TO WS-P-STATE(2)
     MOVE 21 TO WS-P-Y(3)
     MOVE 86 TO WS-P-STATE(3)
     MOVE "test surface rules a deep ocean floor is gravel" TO TL-CASE
     PERFORM CHECK-PROFILE

*>   desert: sand, sandstone down to the very deep floor, sandstone on a ceiling
     MOVE 1 TO WS-BIOME-ID
     MOVE 69 TO WS-TOP
     MOVE 0 TO WS-WATER-TOP
     MOVE 50 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM RUN-COLUMN
     MOVE 6 TO WS-P-COUNT
     MOVE 69 TO WS-P-Y(1)
     MOVE 16 TO WS-P-STATE(1)
     MOVE 66 TO WS-P-Y(2)
     MOVE 16 TO WS-P-STATE(2)
     MOVE 65 TO WS-P-Y(3)
     MOVE 17 TO WS-P-STATE(3)
     MOVE 51 TO WS-P-Y(4)
     MOVE 17 TO WS-P-STATE(4)
     MOVE 50 TO WS-P-Y(5)
     MOVE 1 TO WS-P-STATE(5)
     MOVE 40 TO WS-P-Y(6)
     MOVE 1 TO WS-P-STATE(6)
     MOVE "test surface rules desert: four sand, sandstone to depth 19, stone below" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 60 TO WS-TOP
     MOVE 30 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM CLEAR-GAP
     PERFORM RUN-COLUMN
     MOVE 3 TO WS-P-COUNT
     MOVE 60 TO WS-P-Y(1)
     MOVE 17 TO WS-P-STATE(1)
     MOVE 40 TO WS-P-Y(2)
     MOVE 16 TO WS-P-STATE(2)
     MOVE 39 TO WS-P-Y(3)
     MOVE 16 TO WS-P-STATE(3)
     MOVE "test surface rules desert: a one block ceiling is sandstone, the floor under it sand" TO TL-CASE
     PERFORM CHECK-PROFILE

*>   badlands
     MOVE 2 TO WS-BIOME-ID
     MOVE 70 TO WS-TOP
     MOVE 50 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM RUN-COLUMN
     MOVE 5 TO WS-P-COUNT
     MOVE 70 TO WS-P-Y(1)
     MOVE 19 TO WS-P-STATE(1)
     MOVE 69 TO WS-P-Y(2)
     MOVE 22 TO WS-P-STATE(2)
     MOVE 60 TO WS-P-Y(3)
     MOVE 25 TO WS-P-STATE(3)
     MOVE 59 TO WS-P-Y(4)
     MOVE 21 TO WS-P-STATE(4)
     MOVE 58 TO WS-P-Y(5)
     MOVE 26 TO WS-P-STATE(5)
     MOVE "test surface rules badlands: red sand, orange terracotta, then the bands (60 red, 59 plain, 58 white)" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 100 TO WS-TOP
     MOVE 80 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM RUN-COLUMN
     MOVE 1 TO WS-P-COUNT
     MOVE 100 TO WS-P-Y(1)
     MOVE 21 TO WS-P-STATE(1)
     MOVE "test surface rules badlands high up: terracotta where the surface noise is near 0" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 270 TO WS-TOP
     MOVE 270 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM RUN-COLUMN
     MOVE 270 TO WS-P-Y(1)
     MOVE 22 TO WS-P-STATE(1)
     MOVE "test surface rules badlands at y 270 is orange terracotta" TO TL-CASE
     PERFORM CHECK-PROFILE
     MOVE 60 TO WS-TOP
     MOVE 69 TO WS-WATER-TOP
     MOVE 60 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM RUN-COLUMN
     MOVE 60 TO WS-P-Y(1)
     MOVE 22 TO WS-P-STATE(1)
     MOVE "test surface rules badlands under water: orange terracotta" TO TL-CASE
     PERFORM CHECK-PROFILE

*>   a steep slope and a 3D noise condition (jagged peaks)
     MOVE 4 TO WS-BIOME-ID
     MOVE 70 TO WS-TOP
     MOVE 0 TO WS-WATER-TOP
     MOVE 50 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     MOVE 3 TO WS-LX
     MOVE 3 TO WS-LZ
     PERFORM RUN-COLUMN
     MOVE "test surface rules a flat jagged peak takes the 3D noise rule: sand" TO TL-CASE
     MOVE 1 TO WS-P-COUNT
     MOVE 70 TO WS-P-Y(1)
     MOVE 16 TO WS-P-STATE(1)
     PERFORM CHECK-PROFILE
     PERFORM BUILD-CHUNK
     COMPUTE WS-CELL = 3 * 16 + 2 + 1
     MOVE 80 TO T-HM-SURFACE(WS-CELL)
     MOVE 3 TO WS-LX
     MOVE 3 TO WS-LZ
     PERFORM RUN-COLUMN
     MOVE 70 TO WS-P-Y(1)
     MOVE 18 TO WS-P-STATE(1)
     MOVE "test surface rules a steep slope (west neighbour 10 higher): gravel" TO TL-CASE
     PERFORM CHECK-PROFILE

*>   pillars of eroded badlands
     MOVE 3 TO WS-BIOME-ID
     MOVE 70 TO WS-TOP
     MOVE 0 TO WS-WATER-TOP
     MOVE 50 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM RUN-PILLARS
     MOVE "test surface rules pillars: columns kept stone from y 71 to their top, none above, some raised" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test surface rules some columns of eroded badlands are raised and none above y 164" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT
     IF WS-COUNT > 0 AND WS-MAX-TOP <= 164
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-TOP
     MOVE 100 TO WS-WATER-TOP
     PERFORM BUILD-CHUNK
     PERFORM RUN-PILLARS
     MOVE "test surface rules pillars: under water nothing is raised" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT + WS-BAD
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a grove: the references that name nothing and the empty sequence give no block, the unknown rule type none, the anchors below the
*>   top and relative to the sea level are read (y >= 60 holds)
     MOVE 5 TO WS-BIOME-ID
     MOVE 70 TO WS-TOP
     MOVE 0 TO WS-WATER-TOP
     MOVE 50 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     MOVE 3 TO WS-LX
     MOVE 3 TO WS-LZ
     PERFORM RUN-COLUMN
     MOVE 1 TO WS-P-COUNT
     MOVE 70 TO WS-P-Y(1)
     MOVE 18 TO WS-P-STATE(1)
     MOVE "test surface rules a grove skips unresolved references, an empty sequence and an ore vein, then reads the anchors" TO TL-CASE
     PERFORM CHECK-PROFILE
*>   a column that reaches the top of the dimension
     MOVE 0 TO WS-BIOME-ID
     MOVE 319 TO WS-TOP
     MOVE 319 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM RUN-COLUMN
     MOVE 319 TO WS-P-Y(1)
     MOVE 12 TO WS-P-STATE(1)
     MOVE "test surface rules grass on the block at the top of the dimension" TO TL-CASE
     PERFORM CHECK-PROFILE
*>   an eroded badlands column runs the pillars first (its cells below 45 are stone either way)
     MOVE 3 TO WS-BIOME-ID
     MOVE 70 TO WS-TOP
     MOVE 50 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     PERFORM RUN-COLUMN
     MOVE 40 TO WS-P-Y(1)
     MOVE 1 TO WS-P-STATE(1)
     MOVE "test surface rules an eroded badlands column leaves y 40 stone" TO TL-CASE
     PERFORM CHECK-PROFILE
*>   the hole condition: surface depth 0 or less
     MOVE "minecraft:is_hole" TO WS-KEY
     MOVE 3 TO WS-KIND-COND
     CALL "WG-FIND" USING WS-KIND-COND WS-KEY WS-COND
     MOVE 0 TO SC-DEPTH
     CALL "SURFACE-COND" USING WS-JOB WS-COND WS-STATE
     MOVE "test surface rules hole holds at surface depth 0" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO SC-DEPTH
     CALL "SURFACE-COND" USING WS-JOB WS-COND WS-STATE
     MOVE "test surface rules hole does not hold at surface depth 3" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the whole stage over a chunk of grass (every cell of the biome source is plains)
     MOVE 0 TO WS-BIOME-ID
     MOVE 69 TO WS-TOP
     MOVE 0 TO WS-WATER-TOP
     MOVE 70 TO WS-LEVEL
     PERFORM BUILD-CHUNK
     MOVE 0 TO GS-SURFACE
     MOVE GJ-STAGE-SURFACE TO T-STAGE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= GJ-STEPS-SURFACE
         MOVE WS-I TO T-SUB
         CALL "GEN-STAGE-SURFACE" USING WS-JOB
     END-PERFORM
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-CELL = (69 + 64) * 256 + WS-I
         IF CE-STATE(WS-CELL) = 12
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "test surface rules the stage makes all 256 columns grass at y 69" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 256 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test surface rules the stage ran 164 steps and read the corner levels 70" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GS-SURFACE * 1000 + T-SF-CSL(1) + T-SF-CSL(4) - 140
     MOVE 164000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     STOP RUN.

*> A chunk of the job: stone to WS-TOP, water above it to WS-WATER-TOP (0: none), the biome WS-BIOME-ID in every cell and
*> ring cell, the corner levels WS-LEVEL, the heightmaps, the context states and rule root.
 BUILD-CHUNK.
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 319
         EVALUATE TRUE
             WHEN WS-Y <= WS-TOP
                 MOVE 1 TO WS-STATE
             WHEN WS-Y <= WS-WATER-TOP
                 MOVE 86 TO WS-STATE
             WHEN OTHER
                 MOVE 0 TO WS-STATE
         END-EVALUATE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
             MOVE WS-STATE TO CE-STATE(WS-CELL)
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         MOVE WS-BIOME-ID TO CE-BIOME(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3456
         COMPUTE T-SF-RING(WS-I) = WS-BIOME-ID + 1
     END-PERFORM
     MOVE WS-TOP TO WS-HEIGHT
     IF WS-WATER-TOP > WS-TOP
         MOVE WS-WATER-TOP TO WS-HEIGHT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE WS-HEIGHT TO T-HM-SURFACE(WS-I)
         MOVE WS-TOP TO T-HM-OCEAN(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-LEVEL TO T-SF-CSL(WS-I)
     END-PERFORM
     CALL "GEN-BLOCK-STATE" USING WS-BLOCK(2) SC-STONE-STATE
     CALL "GEN-BLOCK-STATE" USING WS-BLOCK(3) SC-WATER-STATE
     CALL "GEN-BLOCK-STATE" USING WS-BLOCK(4) SC-LAVA-STATE
     MOVE WS-ROOT TO SC-ROOT.

*> The ids of the fuzzy lookup test: cell (qx + qz) mod 2 for the chunk's cells and the ring.
 FILL-CHECKERBOARD.
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     PERFORM VARYING WS-LAYER FROM 0 BY 1 UNTIL WS-LAYER > 95
         PERFORM VARYING WS-QZ FROM -1 BY 1 UNTIL WS-QZ > 4
             PERFORM VARYING WS-QX FROM -1 BY 1 UNTIL WS-QX > 4
                 COMPUTE WS-J = FUNCTION MOD(WS-QX + WS-QZ, 2)
                 COMPUTE WS-CELL = WS-LAYER * 36 + (WS-QZ + 1) * 6 + WS-QX + 2
                 COMPUTE T-SF-RING(WS-CELL) = WS-J + 1
                 IF WS-QX >= 0 AND WS-QX <= 3 AND WS-QZ >= 0 AND WS-QZ <= 3
                     DIVIDE WS-LAYER BY 4 GIVING WS-I REMAINDER WS-Y
                     COMPUTE WS-CELL = WS-I * 64 + WS-Y * 16 + WS-QZ * 4 + WS-QX + 1
                     MOVE WS-J TO CE-BIOME(WS-CELL)
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.

*> Air from y 41 to 59 in the column (3, 3).
 CLEAR-GAP.
     PERFORM VARYING WS-Y FROM 41 BY 1 UNTIL WS-Y > 59
         COMPUTE WS-CELL = (WS-Y + 64) * 256 + 3 * 16 + 3 + 1
         MOVE 0 TO CE-STATE(WS-CELL)
     END-PERFORM.

 RUN-COLUMN.
     CALL "SURFACE-COLUMN" USING WS-JOB WS-LX WS-LZ.

*> The states at the y of WS-P-Y of the column WS-LX, WS-LZ against WS-P-STATE: the mismatches are counted.
 CHECK-PROFILE.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-P-COUNT
         COMPUTE WS-CELL = (WS-P-Y(WS-J) + 64) * 256 + WS-LZ * 16 + WS-LX + 1
         IF CE-STATE(WS-CELL) NOT = WS-P-STATE(WS-J)
             ADD 1 TO WS-BAD
             DISPLAY "  y " WS-P-Y(WS-J) " expected state " WS-P-STATE(WS-J) " found " CE-STATE(WS-CELL)
         END-IF
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The pillar extension on all 256 columns of a chunk of stone to 70 (and water above, perhaps): WS-COUNT columns raised, WS-BAD
*> columns that break the invariant (cells to 70 stone or water as built, the raised cells stone and contiguous, heights equal to the top).
 RUN-PILLARS.
     MOVE 0 TO WS-COUNT WS-BAD WS-MAX-TOP
     PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
             COMPUTE SC-X = WS-LX
             COMPUTE SC-Z = WS-LZ
             CALL "SURFACE-PILLARS" USING WS-JOB WS-LX WS-LZ
             COMPUTE WS-I = WS-LZ * 16 + WS-LX + 1
             MOVE WS-TOP TO WS-HEIGHT
             IF WS-WATER-TOP > WS-TOP
                 MOVE WS-WATER-TOP TO WS-HEIGHT
             END-IF
             COMPUTE WS-J = WS-HEIGHT + 1
             IF CE-STATE((WS-HEIGHT + 1 + 64) * 256 + WS-I) = 1
                 ADD 1 TO WS-COUNT
             END-IF
             PERFORM VARYING WS-Y FROM WS-J BY 1 UNTIL WS-Y > 319
                 COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
                 IF CE-STATE(WS-CELL) NOT = 1 AND CE-STATE(WS-CELL) NOT = 0
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
             IF T-HM-SURFACE(WS-I) > WS-MAX-TOP
                 MOVE T-HM-SURFACE(WS-I) TO WS-MAX-TOP
             END-IF
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-SURFACE-RULES.
 COPY CORETEST.
