*> Acceptance test US11-2 (T0430; docs/protocol/11 sections 6 to 8): the ores of the standard overworld. The placed feature table of
*> 8.1 and 8.2 (count, size, height kind and range, biome limit), the height providers (uniform and triangle, 4), the biome limits
*> (8.3), the blob geometry of the worked example 7.4, blobs placed on stone, deepslate and tuff (7.3: the stone variant, the deepslate
*> variant, tuff by height), air exposure (buried ores never touch air), a blob across a chunk border placed identically from either
*> chunk (T0432), and the whole stage on a chunk of stone and deepslate (a count of ore blocks, the diamond depth limit, the same
*> bytes twice). Block table of the test: air 0, stone 1, granite 2, diorite 3, andesite 4, tuff 5, deepslate 6, then the ores.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US11-ORES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CARVER.
 COPY ORE.
 COPY GENSTAGE.
 COPY GENSTEPS.
 COPY CLIMATE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-U64                 BINARY-DOUBLE UNSIGNED.
 01 WS-D                   BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-PEAK                BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-FLAG                BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-BIOME               PIC X(40).
 01 WS-F                   FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-DIAMOND-BAD         BINARY-LONG.
 01 WS-REF                 PIC X(304640).
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/terrain".
 01 WS-STATUS              BINARY-LONG.
 01 WS-EMERALDS            BINARY-LONG.
 01 WS-BNAME               PIC X(40).
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-MINS.
    05 WS-MINV             BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAXV             BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-BLOCKS.
    05 WS-B-KEY            PIC X(40) OCCURS 24 TIMES.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM BUILD-BLOCKS
     CALL "CARVER-SETUP" USING WS-SEED
     CALL "ORE-TABLE-BUILD"

     MOVE "acceptance US11-2 given the table of 11 section 8.2 then it holds 30 placed ore features" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE OT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ore_diamond" TO WS-NAME
     PERFORM FIND-ROW
     MOVE "acceptance US11-2 diamond is count 7, size 4, air 50, triangle -144 to 16" TO TL-CASE
     COMPUTE TL-OBSERVED-N = OT-N(WS-ROW) * 1000000000 + OT-SIZE(WS-ROW) * 100000000 + OT-AIR(WS-ROW) * 1000000
         + OT-HKIND(WS-ROW) * 100000 + (OT-LO(WS-ROW) + 200) * 100 + OT-HI(WS-ROW)
     MOVE 7410000000 TO TL-EXPECTED-N
     COMPUTE TL-EXPECTED-N = 7 * 1000000000 + 4 * 100000000 + 50 * 1000000 + 2 * 100000 + 56 * 100 + 16
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ore_emerald" TO WS-NAME
     PERFORM FIND-ROW
     MOVE "acceptance US11-2 emerald is count 100, size 3, triangle -16 to 480, in the emerald biomes only" TO TL-CASE
     COMPUTE TL-OBSERVED-N = OT-N(WS-ROW) * 100000000 + OT-SIZE(WS-ROW) * 10000000 + OT-HKIND(WS-ROW) * 1000000
         + (OT-LO(WS-ROW) + 100) * 1000 + OT-HI(WS-ROW) - 400 + OT-BIOME(WS-ROW) * 10000000000
     COMPUTE TL-EXPECTED-N = 1 * 10000000000 + 100 * 100000000 + 3 * 10000000 + 2 * 1000000 + 84 * 1000 + 80
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ore_coal_upper" TO WS-NAME
     PERFORM FIND-ROW
     MOVE "acceptance US11-2 upper coal is count 30, size 17, uniform 136 to 319" TO TL-CASE
     COMPUTE TL-OBSERVED-N = OT-N(WS-ROW) * 100000000 + OT-SIZE(WS-ROW) * 1000000 + OT-HKIND(WS-ROW) * 100000000000
         + OT-LO(WS-ROW) * 1000 + OT-HI(WS-ROW)
     COMPUTE TL-EXPECTED-N = 30 * 100000000 + 17 * 1000000 + 1 * 100000000000 + 136 * 1000 + 319
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ore_iron_upper" TO WS-NAME
     PERFORM FIND-ROW
     MOVE "acceptance US11-2 upper iron is count 90, size 9, triangle 80 to 384" TO TL-CASE
     COMPUTE TL-OBSERVED-N = OT-N(WS-ROW) * 100000000 + OT-SIZE(WS-ROW) * 1000000 + OT-HKIND(WS-ROW) * 100000000000
         + OT-LO(WS-ROW) * 1000 + OT-HI(WS-ROW)
     COMPUTE TL-EXPECTED-N = 90 * 100000000 + 9 * 1000000 + 2 * 100000000000 + 80 * 1000 + 384
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ore_granite_upper" TO WS-NAME
     PERFORM FIND-ROW
     MOVE "acceptance US11-2 upper granite is a rarity filter of 1 in 6" TO TL-CASE
     COMPUTE TL-OBSERVED-N = OT-MOD(WS-ROW) * 100 + OT-N(WS-ROW)
     MOVE 306 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the height providers
     MOVE 0 TO WS-U64
     CALL "WGR-SET-SEED" USING WS-XR WS-U64
     MOVE 1000 TO WS-MIN
     MOVE -1000 TO WS-MAX
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2000
         MOVE 1 TO WS-K
         MOVE 0 TO WS-J
         MOVE 160 TO WS-Y
         CALL "ORE-HEIGHT" USING WS-XR WS-K WS-J WS-Y WS-STATE
         IF WS-STATE < 0 OR WS-STATE > 160
             ADD 1 TO WS-BAD
         END-IF
         IF WS-STATE < WS-MIN
             MOVE WS-STATE TO WS-MIN
         END-IF
         IF WS-STATE > WS-MAX
             MOVE WS-STATE TO WS-MAX
         END-IF
     END-PERFORM
     MOVE "acceptance US11-2 uniform 0 to 160 stays in range and reaches both ends" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-BAD = 0 AND WS-MIN < 6 AND WS-MAX > 154
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-SUM
     MOVE 0 TO WS-LOW
     MOVE 0 TO WS-PEAK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000
         MOVE 2 TO WS-K
         MOVE -144 TO WS-J
         MOVE 16 TO WS-Y
         CALL "ORE-HEIGHT" USING WS-XR WS-K WS-J WS-Y WS-STATE
         IF WS-STATE < -144 OR WS-STATE > 16
             ADD 1 TO WS-BAD
         END-IF
         ADD WS-STATE TO WS-SUM
         IF WS-STATE < -124 OR WS-STATE > -4
             ADD 1 TO WS-LOW
         END-IF
         IF WS-STATE >= -74 AND WS-STATE <= -54
             ADD 1 TO WS-PEAK
         END-IF
     END-PERFORM
     MOVE "acceptance US11-2 triangle -144 to 16 stays in range with the mean at the peak -64" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE WS-SUM = WS-SUM / 4000
     IF WS-BAD = 0 AND WS-SUM >= -68 AND WS-SUM <= -60
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US11-2 triangle: the ends are rarer than the peak" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-LOW * 3 < WS-PEAK
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   decoration seeding (10.4): the seed of feature 11 of step 6 is the decoration seed + 60011
     MOVE 3 TO WS-CX
     MOVE -2 TO WS-CZ
     MOVE 48 TO WS-I
     MOVE -32 TO WS-J
     CALL "ORE-DECOR-SEED" USING WS-SEED WS-I WS-J WS-XR WS-D
     MOVE 11 TO WS-K
     MOVE 6 TO WS-Y
     CALL "ORE-FEATURE-SEED" USING WS-D WS-K WS-Y WS-U64
     COMPUTE TL-OBSERVED-N = WS-U64 - WS-D
     MOVE "acceptance US11-2 the seed of feature 11 of step 6 is the decoration seed plus 60011" TO TL-CASE
     MOVE 60011 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   biome limits (8.3)
     MOVE 1 TO WS-K
     MOVE "minecraft:meadow" TO WS-BIOME
     CALL "ORE-BIOME-OK" USING WS-K WS-BIOME WS-FLAG
     MOVE WS-FLAG TO WS-BAD
     MOVE "minecraft:plains" TO WS-BIOME
     CALL "ORE-BIOME-OK" USING WS-K WS-BIOME WS-FLAG
     COMPUTE WS-BAD = WS-BAD * 10 + WS-FLAG
     MOVE 2 TO WS-K
     MOVE "minecraft:eroded_badlands" TO WS-BIOME
     CALL "ORE-BIOME-OK" USING WS-K WS-BIOME WS-FLAG
     COMPUTE WS-BAD = WS-BAD * 10 + WS-FLAG
     MOVE 3 TO WS-K
     MOVE "minecraft:dripstone_caves" TO WS-BIOME
     CALL "ORE-BIOME-OK" USING WS-K WS-BIOME WS-FLAG
     COMPUTE WS-BAD = WS-BAD * 10 + WS-FLAG
     MOVE 4 TO WS-K
     MOVE "minecraft:lush_caves" TO WS-BIOME
     CALL "ORE-BIOME-OK" USING WS-K WS-BIOME WS-FLAG
     COMPUTE WS-BAD = WS-BAD * 10 + WS-FLAG
     MOVE 5 TO WS-K
     CALL "ORE-BIOME-OK" USING WS-K WS-BIOME WS-FLAG
     COMPUTE WS-BAD = WS-BAD * 10 + WS-FLAG
     MOVE "minecraft:dripstone_caves" TO WS-BIOME
     CALL "ORE-BIOME-OK" USING WS-K WS-BIOME WS-FLAG
     COMPUTE WS-BAD = WS-BAD * 10 + WS-FLAG
     MOVE 0 TO WS-K
     CALL "ORE-BIOME-OK" USING WS-K WS-BIOME WS-FLAG
     COMPUTE WS-BAD = WS-BAD * 10 + WS-FLAG
     MOVE "acceptance US11-2 emerald meadow yes, plains no; badlands, dripstone, lush; copper not in dripstone; any biome for 0" TO TL-CASE
     MOVE 10111101 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the worked example 7.4: size 9 at (100, 12, -40), angle 0.5 * pi, y offsets 1 and 0
     MOVE 9 TO WS-I
     MOVE 100 TO WS-CX
     MOVE 12 TO WS-Y
     MOVE -40 TO WS-CZ
     MOVE 1.5707964 TO WS-F
     MOVE 1 TO WS-J
     MOVE 0 TO WS-K
     CALL "ORE-BLOB-GEOM" USING WS-I WS-CX WS-Y WS-CZ WS-F WS-J WS-K
     MOVE "acceptance US11-2 blob 7.4: axis ends x 101.125 and 98.875" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = OB-X0 * 1000
     MOVE 101125 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE TL-OBSERVED-N ROUNDED = OB-X1 * 1000
     MOVE 98875 TO TL-EXPECTED-N
     MOVE "acceptance US11-2 blob 7.4: axis end x1 98.875" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US11-2 blob 7.4: y ends 11 and 10" TO TL-CASE
     COMPUTE TL-OBSERVED-N = OB-Y0 * 100 + OB-Y1
     MOVE 1110 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US11-2 blob 7.4: box start (96, 8, -44), width 8, height 8, radius term 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (OB-START-X + 100) * 100000000 + (OB-START-Y + 100) * 1000000 + (OB-START-Z + 100) * 10000
         + OB-WIDTH * 100 + OB-HEIGHT * 10 + OB-RR
     COMPUTE TL-EXPECTED-N = 196 * 100000000 + 108 * 1000000 + 56 * 10000 + 8 * 100 + 8 * 10 + 2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   blobs on stone, deepslate and tuff (7.3), size 17 coal at (8, 30, 8)
     MOVE "ore_coal_upper" TO WS-NAME
     PERFORM FIND-ROW
     MOVE 1 TO WS-STATE
     MOVE 103 TO WS-EXPECT
     MOVE 30 TO WS-Y
     PERFORM BLOB-ON-FILL
     MOVE "acceptance US11-2 a coal blob in stone places a few blocks of coal ore" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF OB-PLACED >= 1 AND OB-PLACED <= 40 AND WS-COUNT = OB-PLACED AND WS-BAD = 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-STATE
     MOVE 104 TO WS-EXPECT
     PERFORM BLOB-ON-FILL
     MOVE "acceptance US11-2 a coal blob in deepslate places deepslate coal ore only" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF OB-PLACED >= 1 AND WS-COUNT = OB-PLACED AND WS-BAD = 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-STATE
     MOVE 103 TO WS-EXPECT
     MOVE 30 TO WS-Y
     PERFORM BLOB-ON-FILL
     MOVE "acceptance US11-2 tuff at y 30 becomes the stone variant of coal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF OB-PLACED >= 1 AND WS-COUNT = OB-PLACED AND WS-BAD = 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -30 TO WS-Y
     MOVE 104 TO WS-EXPECT
     PERFORM BLOB-ON-FILL
     MOVE "acceptance US11-2 tuff at y -30 becomes the deepslate variant of coal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF OB-PLACED >= 1 AND WS-COUNT = OB-PLACED AND WS-BAD = 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ore_dirt" TO WS-NAME
     PERFORM FIND-ROW
     MOVE 6 TO WS-STATE
     MOVE 101 TO WS-EXPECT
     MOVE 30 TO WS-Y
     PERFORM BLOB-ON-FILL
     MOVE "acceptance US11-2 a dirt blob replaces any base stone, deepslate too" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF OB-PLACED >= 1 AND WS-COUNT = OB-PLACED AND WS-BAD = 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the whole stage on a chunk of deepslate (y below 0), stone (0 to 62) and air
     PERFORM MAKE-JOB
     PERFORM FILL-LAYERS
     MOVE 0 TO T-CX
     MOVE 0 TO T-CZ
     INITIALIZE GEN-STAGES
     PERFORM RUN-STAGE
     MOVE WS-A TO WS-REF
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-DIAMOND-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         IF CE-STATE(WS-I) >= 100
             ADD 1 TO WS-COUNT
             COMPUTE WS-Y = (WS-I - 1) / 256 - 64
             IF (CE-STATE(WS-I) = 117 OR CE-STATE(WS-I) = 118) AND WS-Y > 19
                 ADD 1 TO WS-DIAMOND-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US11-2 the stage puts hundreds of ore blocks into the chunk" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-COUNT > 300
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US11-2 no diamond above y 19" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIAMOND-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US11-2 GS-ORE counted the 270 steps" TO TL-CASE
     MOVE 270 TO TL-EXPECTED-N
     MOVE GS-ORE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     PERFORM MAKE-JOB
     PERFORM FILL-LAYERS
     MOVE 0 TO T-CX
     MOVE 0 TO T-CZ
     PERFORM RUN-STAGE
     MOVE "acceptance US11-2 the same seed and chunk give the same bytes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-A = WS-REF
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
*>   emeralds only in the emerald biomes: the climate says meadow everywhere, then plains everywhere (the biome cells of the chunk
*>   and the biome source outside it both come from it)
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-SETUP" USING WS-SEED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MINV(WS-I)
         MOVE 10000 TO WS-MAXV(WS-I)
     END-PERFORM
     MOVE 1 TO CBI-COUNT
     MOVE "minecraft:meadow" TO CBI-KEY(1)
     MOVE 16 TO CBI-KEY-LENGTH(1)
     MOVE "minecraft:meadow" TO WS-BNAME
     CALL "CLIMATE-POINTS-RESET"
     CALL "CLIMATE-POINT-ADD" USING WS-BNAME WS-MINS WS-MAXS WS-OFFSET
     PERFORM MAKE-JOB
     PERFORM FILL-LAYERS
     PERFORM RUN-STAGE
     PERFORM COUNT-EMERALDS
     MOVE "acceptance US11-2 in meadow (an emerald biome) the stage places emerald ore" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-EMERALDS > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     MOVE "minecraft:plains" TO CBI-KEY(1)
     MOVE 16 TO CBI-KEY-LENGTH(1)
     MOVE "minecraft:plains" TO WS-BNAME
     CALL "CLIMATE-POINTS-RESET"
     CALL "CLIMATE-POINT-ADD" USING WS-BNAME WS-MINS WS-MAXS WS-OFFSET
     PERFORM MAKE-JOB
     PERFORM FILL-LAYERS
     PERFORM RUN-STAGE
     PERFORM COUNT-EMERALDS
     MOVE "acceptance US11-2 in plains the stage places no emerald ore" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EMERALDS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     MOVE "acceptance US11-2 the ore stage has 270 steps (9 chunks, 30 placed features)" TO TL-CASE
     MOVE 270 TO TL-EXPECTED-N
     MOVE GJ-STEPS-ORES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIND-ROW.
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OT-COUNT
         IF OT-NAME(WS-I) = WS-NAME
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM.

 ADD-BLOCK.
     ADD 1 TO CB-BLOCK-COUNT
     MOVE WS-NAME TO CB-KEY(CB-BLOCK-COUNT)
     MOVE 0 TO WS-K
     INSPECT WS-NAME TALLYING WS-K FOR CHARACTERS BEFORE INITIAL SPACE
     MOVE WS-K TO CB-KEY-LENGTH(CB-BLOCK-COUNT)
     MOVE WS-STATE TO CB-DEFAULT-STATE(CB-BLOCK-COUNT).

*> the block table: the six base blocks and, from state 101, the blocks the table of ores places (in the order of the paragraph)
 BUILD-BLOCKS.
     MOVE 0 TO CB-BLOCK-COUNT
     MOVE "minecraft:air" TO WS-NAME
     MOVE 0 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:stone" TO WS-NAME
     MOVE 1 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:granite" TO WS-NAME
     MOVE 2 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:diorite" TO WS-NAME
     MOVE 3 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:andesite" TO WS-NAME
     MOVE 4 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:tuff" TO WS-NAME
     MOVE 5 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate" TO WS-NAME
     MOVE 6 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:dirt" TO WS-NAME
     MOVE 101 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:gravel" TO WS-NAME
     MOVE 102 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:coal_ore" TO WS-NAME
     MOVE 103 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_coal_ore" TO WS-NAME
     MOVE 104 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:iron_ore" TO WS-NAME
     MOVE 105 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_iron_ore" TO WS-NAME
     MOVE 106 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:gold_ore" TO WS-NAME
     MOVE 107 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_gold_ore" TO WS-NAME
     MOVE 108 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:redstone_ore" TO WS-NAME
     MOVE 109 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_redstone_ore" TO WS-NAME
     MOVE 110 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:lapis_ore" TO WS-NAME
     MOVE 111 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_lapis_ore" TO WS-NAME
     MOVE 112 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:copper_ore" TO WS-NAME
     MOVE 113 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_copper_ore" TO WS-NAME
     MOVE 114 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:emerald_ore" TO WS-NAME
     MOVE 115 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_emerald_ore" TO WS-NAME
     MOVE 116 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:diamond_ore" TO WS-NAME
     MOVE 117 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:deepslate_diamond_ore" TO WS-NAME
     MOVE 118 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:infested_stone" TO WS-NAME
     MOVE 119 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:infested_deepslate" TO WS-NAME
     MOVE 120 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE "minecraft:clay" TO WS-NAME
     MOVE 121 TO WS-STATE
     PERFORM ADD-BLOCK
     MOVE 0 TO CBI-COUNT.

 MAKE-JOB.
     INITIALIZE WS-JOB
     MOVE 1 TO T-ACTIVE
     MOVE 3 TO T-DIM
     MOVE 0 TO T-CX
     MOVE 0 TO T-CZ
     MOVE 0 TO T-AQ-READY
     MOVE LOW-VALUES TO T-CV
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING T-ADDR
     SET ADDRESS OF WS-A TO T-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE -65 TO T-HM-OCEAN(WS-I)
         MOVE -65 TO T-HM-SURFACE(WS-I)
     END-PERFORM.

 FILL-ALL-STONE.
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         MOVE 1 TO CE-STATE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE 100 TO T-HM-OCEAN(WS-I)
     END-PERFORM.

 FILL-LAYERS.
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         COMPUTE WS-Y = (WS-I - 1) / 256 - 64
         EVALUATE TRUE
             WHEN WS-Y < 0
                 MOVE 6 TO CE-STATE(WS-I)
             WHEN WS-Y < 63
                 MOVE 1 TO CE-STATE(WS-I)
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE 62 TO T-HM-OCEAN(WS-I)
     END-PERFORM.

*> one blob of the row WS-ROW at (8, WS-Y or 30, 8) in a chunk filled with the state WS-STATE: WS-COUNT the ore blocks there are,
*> WS-BAD the cells that are neither the fill nor the stone and deepslate variants of the row
 BLOB-ON-FILL.
     PERFORM MAKE-JOB
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         MOVE WS-STATE TO CE-STATE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE 100 TO T-HM-OCEAN(WS-I)
     END-PERFORM
     MOVE 8 TO WS-CX
     MOVE 8 TO WS-CZ
     MOVE 0 TO WS-U64
     CALL "WGR-SET-SEED" USING WS-XR WS-U64
     MOVE 0 TO OB-LIST
     CALL "ORE-PLACE-BLOB" USING WS-JOB WS-XR WS-ROW WS-CX WS-Y WS-CZ
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         IF CE-STATE(WS-I) NOT = WS-STATE
             ADD 1 TO WS-COUNT
             IF CE-STATE(WS-I) NOT = WS-EXPECT
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     CALL "GEN-JOB-FREE" USING WS-JOB.

 COUNT-EMERALDS.
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     MOVE 0 TO WS-EMERALDS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         IF CE-STATE(WS-I) = 115 OR CE-STATE(WS-I) = 116
             ADD 1 TO WS-EMERALDS
         END-IF
     END-PERFORM.

 RUN-STAGE.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= GJ-STEPS-ORES
         MOVE WS-I TO T-SUB
         CALL "GEN-STAGE-ORES" USING WS-JOB
     END-PERFORM.
 END PROGRAM ACC-F2US11-ORES.
 COPY CORETEST.
