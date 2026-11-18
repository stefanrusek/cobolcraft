*> Implementation test of delta_feature, stepped_column_cluster (the basalt columns), single_block_pillar with projected_random_patchy_square and simple_block (the basalt_pillar overlay of the data) and
*> random_neighbor_spread (glowstone_extra) (docs/protocol/35-worldgen-features-7-nether-end-misc.md sections 3 to 5, 35-4 section 7; core/src/feat-nether.cob): each feature of the data runs on a window of a
*> real block table from 24 seeds and an independent model of the document's text with its own random stream applies the same rules to a copy of the window; every cell and the stream position must agree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-7-NETHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY TREEWORK.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/nether7".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-PAIRS               PIC X(160).
 01 WS-PROPS               PIC X(160).
 01 WS-FTKEY               PIC X(80).
 01 WS-FT                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ONE2                BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LAYOUT              BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-TAG-REG             PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-N               BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 12 TIMES.
 01 WS-TAG-STATUS          BINARY-LONG.
*> block indices (1-based) and states
 01 WS-B-AIR               BINARY-LONG.
 01 WS-B-LOG               BINARY-LONG.
 01 WS-B-LEAF              BINARY-LONG.
 01 WS-B-GRASS             BINARY-LONG.
 01 WS-B-DIRT              BINARY-LONG.
 01 WS-B-STONE             BINARY-LONG.
 01 WS-B-WATER             BINARY-LONG.
 01 WS-B-SHELF             BINARY-LONG.
 01 WS-B-VINE              BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG.
 01 WS-S-LOG               BINARY-LONG.
 01 WS-S-LEAF              BINARY-LONG.
 01 WS-S-GRASS             BINARY-LONG.
 01 WS-S-DIRT              BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-WATER             BINARY-LONG.
 01 WS-S-PODZOL            BINARY-LONG.
 01 WS-S-SHORT             BINARY-LONG.
 01 WS-S-FERN              BINARY-LONG.
 01 WS-S-NEST              BINARY-LONG.
 01 WS-S-HEART             BINARY-LONG.
 01 WS-S-MOSS              BINARY-LONG.
 01 WS-S-TIP               BINARY-LONG.
*> the window of the model: x 16..31, z 32..47, y 58..80
 01 WS-SNAP.
    05 WS-SN               BINARY-LONG OCCURS 5888 TIMES.
 01 WS-MOD.
    05 WS-MD               BINARY-LONG OCCURS 5888 TIMES.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-MB                  BINARY-LONG.
 01 WS-MI                  BINARY-LONG.
 01 WS-MAIR                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-F1                  FLOAT-LONG VALUE 1.0.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-SIXTH               FLOAT-LONG VALUE 0.6.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 01 WS-D                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-LIST.
    05 WS-LI               BINARY-LONG OCCURS 3000 TIMES.
 01 WS-NC                  BINARY-LONG.
 01 WS-CAND.
    05 WS-CD OCCURS 64 TIMES.
       10 WS-CD-X          BINARY-LONG.
       10 WS-CD-Y          BINARY-LONG.
       10 WS-CD-Z          BINARY-LONG.
 01 WS-XC.
    05 WS-XCE OCCURS 200 TIMES.
       10 WS-XC-X          BINARY-LONG.
       10 WS-XC-Y          BINARY-LONG.
       10 WS-XC-Z          BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-LOWLOG              BINARY-LONG.
 01 WS-HIGHLOG             BINARY-LONG.
 01 WS-LOWLEAF             BINARY-LONG.
 01 WS-MY2                 BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-FACE-NAMES.
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "east".
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west".
 01 WS-FACE-T REDEFINES WS-FACE-NAMES.
    05 WS-FACE-N           PIC X(5) OCCURS 4 TIMES.
 01 WS-FN                  PIC X(5).
 01 WS-PAIR-D.
    05 WS-PD               BINARY-LONG OCCURS 2 TIMES.
 01 WS-FALLEN              BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-AGE-T               PIC 9.
 01 WS-BASE                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-AA                  BINARY-LONG.
 01 WS-BB                  BINARY-LONG.
 01 WS-CCX                 BINARY-LONG.
 01 WS-CCZ                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-NLL                 BINARY-LONG.
 01 WS-LAY-Y               BINARY-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MAXX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-MAXZ                BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-EXPECT-TEXT         PIC X(160).
 01 WS-B-LAVA             BINARY-LONG.
 01 WS-B-MAGMA            BINARY-LONG.
 01 WS-B-NETH             BINARY-LONG.
 01 WS-B-BASALT           BINARY-LONG.
 01 WS-B-GLOW             BINARY-LONG.
 01 WS-S-LAVA             BINARY-LONG.
 01 WS-S-MAGMA            BINARY-LONG.
 01 WS-S-NETH             BINARY-LONG.
 01 WS-S-BASALT           BINARY-LONG.
 01 WS-S-GLOW             BINARY-LONG.
 01 WS-CPO.
    05 WS-CP               BINARY-LONG OCCURS 4 TIMES.
 01 WS-MODE               BINARY-LONG.
 01 WS-OX                 BINARY-LONG.
 01 WS-OY                 BINARY-LONG.
 01 WS-OZ                 BINARY-LONG.
 01 WS-HT                 BINARY-LONG.
 01 WS-RUSE               BINARY-LONG.
 01 WS-RX                 BINARY-LONG.
 01 WS-RZ                 BINARY-LONG.
 01 WS-SIZEX              BINARY-LONG.
 01 WS-SIZEZ              BINARY-LONG.
 01 WS-RACT               BINARY-LONG.
 01 WS-AD                 BINARY-LONG.
 01 WS-AX                 BINARY-LONG.
 01 WS-LIM                BINARY-LONG.
 01 WS-SIGN               BINARY-LONG.
 01 WS-OK1                BINARY-LONG.
 01 WS-REACH              BINARY-LONG.
 01 WS-CNT                BINARY-LONG.
 01 WS-REM                BINARY-LONG.
 01 WS-RR                 BINARY-LONG.
 01 WS-HH                 BINARY-LONG.
 01 WS-CHD                BINARY-LONG.
 01 WS-CHR                BINARY-LONG.
 01 WS-RMIN               BINARY-LONG.
 01 WS-RMAX               BINARY-LONG.
 01 WS-CX2                BINARY-LONG.
 01 WS-CY2                BINARY-LONG.
 01 WS-CZ2                BINARY-LONG.
 01 WS-DIST               BINARY-LONG.
 01 WS-CUR                BINARY-LONG.
 01 WS-NN                 BINARY-LONG.
 01 WS-LX                 BINARY-LONG.
 01 WS-LY                 BINARY-LONG.
 01 WS-LZ                 BINARY-LONG.
 01 WS-PCHANCE            FLOAT-LONG.
 01 WS-PDIR               BINARY-LONG.
 01 WS-S3                 BINARY-LONG.
 01 WS-DF                FLOAT-LONG.
 01 WS-P09                FLOAT-LONG VALUE 0.9.
 01 WS-DY                 BINARY-LONG.
 01 WS-NLIM               BINARY-LONG.
 01 WS-ACT                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     PERFORM LOOK-UP
     PERFORM PUT-TAGS-N

     MOVE "minecraft:n7_delta" TO WS-FTKEY
     MOVE 1 TO WS-MODE
     PERFORM RUN-SEEDS-N
     MOVE "acceptance US12 35-7§3 `delta_feature`: of the data: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT-N
     MOVE "minecraft:n7_small_5" TO WS-FTKEY
     MOVE 2 TO WS-MODE
     PERFORM RUN-SEEDS-N
     MOVE "acceptance US12 35-7§4 `stepped_column_cluster`: stepped_column_cluster (small columns, reach 5, 50 columns): every cell and the stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT-N
     MOVE "minecraft:n7_small_8" TO WS-FTKEY
     PERFORM RUN-SEEDS-N
     MOVE "acceptance US12 35-7§4 `stepped_column_cluster`: stepped_column_cluster (small columns, reach 8, 15 columns): the same" TO WS-CASE
     PERFORM ASSERT-RESULT-N
     MOVE "minecraft:n7_large_5" TO WS-FTKEY
     PERFORM RUN-SEEDS-N
     MOVE "acceptance US12 35-7§4 `stepped_column_cluster`: stepped_column_cluster (large columns, reach 5): the same" TO WS-CASE
     PERFORM ASSERT-RESULT-N
     MOVE "minecraft:n7_pillar" TO WS-FTKEY
     MOVE 3 TO WS-MODE
     PERFORM RUN-SEEDS-N
     MOVE "acceptance US12 35-7§5 `single_block_pillar`, `overlay`, `projected_random_patchy_square`: the basalt pillar: every cell and the stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT-N
     MOVE "minecraft:n7_spread" TO WS-FTKEY
     MOVE 4 TO WS-MODE
     PERFORM RUN-SEEDS-N
     MOVE "35-4§7.3 random_neighbor_spread (glowstone_extra): every cell and the stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT-N
     STOP RUN.

 LOOK-UP.
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-AIR
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     MOVE "lava" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-LAVA
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-LAVA
     MOVE "magma_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-MAGMA
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-MAGMA
     MOVE "netherrack" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-NETH
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-NETH
     MOVE "glowstone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-GLOW
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GLOW
     MOVE "basalt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BASALT
     MOVE "axis=y" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-BASALT
     .
 PUT-TAGS-N.
     MOVE 1 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-AIR - 1
     MOVE "minecraft:air" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE 2 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-LAVA - 1
     COMPUTE WS-TAG-ID(2) = WS-B-MAGMA - 1
     MOVE "minecraft:cannot_place_basalt_pillar_on" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE WS-B-LAVA TO WS-CP(1)
     MOVE WS-B-MAGMA TO WS-CP(2)
     .
*> RUN-SEEDS-N: 24 seeds of the feature WS-FTKEY on the world of WS-MODE at the origin (WS-OX, WS-OY, WS-OZ)
 RUN-SEEDS-N.
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE 0 TO WS-BAD WS-ACTIVE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD-N
         PERFORM SNAPSHOT
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-OK
         PERFORM MODEL-N
         MOVE 0 TO WS-DIFF
         PERFORM COMPARE-WINDOW
         MOVE 1000000 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-P1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-P2
         IF WS-DIFF > 0 OR WS-P1 NOT = WS-P2
             ADD 1 TO WS-BAD
         END-IF
         PERFORM COUNT-CHANGES
     END-PERFORM
     .
 ASSERT-RESULT-N.
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-7 the run changed cells over the seeds (the model is not trivially empty)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-ACTIVE > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     .
 NEW-WORLD-N.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE "netherrack" TO WS-KEY
     MOVE 24 TO WS-OX
     MOVE 40 TO WS-OZ
     IF WS-MODE = 1 OR WS-MODE = 2
         MOVE 58 TO WS-Y0
         MOVE 61 TO WS-Y1
         PERFORM FILL-BOX
         COMPUTE WS-OY = 61 + WS-MODE - 1
         IF WS-MODE = 1
             MOVE 61 TO WS-OY
         END-IF
     ELSE
         MOVE 58 TO WS-Y0
         MOVE 60 TO WS-Y1
         PERFORM FILL-BOX
         MOVE 76 TO WS-Y0
         MOVE 80 TO WS-Y1
         PERFORM FILL-BOX
         MOVE 75 TO WS-OY
     END-IF
     .
 MODEL-N.
     EVALUATE WS-MODE
         WHEN 1
             PERFORM N-DELTA
         WHEN 2
             PERFORM N-STEP
         WHEN 3
             PERFORM N-PILLAR-ALL
         WHEN OTHER
             PERFORM N-SPREAD
     END-EVALUATE
     .
*> the model cell helpers: WS-MX, WS-MY, WS-MZ; MGET sets WS-MB (block) and WS-MAIR
 N-AIR-AT.
     PERFORM MGET
     .
*> delta_feature (3): the data contents lava, rim magma_block, size uniform 3..7, rim_size uniform 0..2
 N-DELTA.
     CALL "WGR-NEXT-DOUBLE" USING XR2-STATE WS-DF
     MOVE WS-DF TO WS-F
     MOVE 0 TO WS-RX WS-RZ
     MOVE 0 TO WS-RUSE
     IF WS-F < WS-P09
         MOVE 1 TO WS-RUSE
         MOVE 3 TO WS-N
         PERFORM MDRAW
         MOVE WS-D TO WS-RX
         PERFORM MDRAW
         MOVE WS-D TO WS-RZ
     END-IF
     MOVE 0 TO WS-RACT
     IF WS-RUSE = 1 AND WS-RX NOT = 0 AND WS-RZ NOT = 0
         MOVE 1 TO WS-RACT
     END-IF
     MOVE 5 TO WS-N
     PERFORM MDRAW
     COMPUTE WS-SIZEX = 3 + WS-D
     PERFORM MDRAW
     COMPUTE WS-SIZEZ = 3 + WS-D
     COMPUTE WS-HH = FUNCTION MAX(WS-SIZEX, WS-SIZEZ)
*>   the diamond walk by Manhattan distance: all (dx, dz) with |dx| <= sizeX, |dz| <= sizeZ and |dx| + |dz| = d, in the order of 2.3
     PERFORM VARYING WS-AD FROM 0 BY 1 UNTIL WS-AD > WS-HH
         COMPUTE WS-LIM = FUNCTION MIN(WS-SIZEX, WS-AD)
         COMPUTE WS-NLIM = 0 - WS-LIM
         PERFORM VARYING WS-AX FROM WS-NLIM BY 1 UNTIL WS-AX > WS-LIM
             COMPUTE WS-DZ = WS-AD - FUNCTION ABS(WS-AX)
             IF WS-DZ <= WS-SIZEZ
                 MOVE WS-AX TO WS-DX
                 MOVE WS-DZ TO WS-QZ
                 PERFORM N-DELTA-AT
                 IF WS-DZ NOT = 0
                     COMPUTE WS-QZ = 0 - WS-DZ
                     PERFORM N-DELTA-AT
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     .
 N-DELTA-AT.
     COMPUTE WS-MX = WS-OX + WS-DX
     MOVE WS-OY TO WS-MY
     COMPUTE WS-MZ = WS-OZ + WS-QZ
     PERFORM N-DELTA-CLEAR
     IF WS-OK1 = 1
         IF WS-RACT = 1
             MOVE WS-S-MAGMA TO WS-MS
             PERFORM MPUT
         END-IF
         COMPUTE WS-MX = WS-OX + WS-DX + WS-RX
         COMPUTE WS-MZ = WS-OZ + WS-QZ + WS-RZ
         PERFORM N-DELTA-CLEAR
         IF WS-OK1 = 1
             MOVE WS-S-LAVA TO WS-MS
             PERFORM MPUT
         END-IF
     END-IF
     .
*> isClear at (WS-MX, WS-MY, WS-MZ): WS-OK1
 N-DELTA-CLEAR.
     MOVE 0 TO WS-OK1
     MOVE WS-MX TO WS-LX
     MOVE WS-MY TO WS-LY
     MOVE WS-MZ TO WS-LZ
     PERFORM MGET
     IF WS-MB NOT = WS-B-LAVA
         MOVE 1 TO WS-OK1
         PERFORM VARYING WS-NN FROM 1 BY 1 UNTIL WS-NN > 6
             MOVE WS-LX TO WS-MX
             MOVE WS-LY TO WS-MY
             MOVE WS-LZ TO WS-MZ
             EVALUATE WS-NN
                 WHEN 1 SUBTRACT 1 FROM WS-MY
                 WHEN 2 ADD 1 TO WS-MY
                 WHEN 3 SUBTRACT 1 FROM WS-MZ
                 WHEN 4 ADD 1 TO WS-MZ
                 WHEN 5 SUBTRACT 1 FROM WS-MX
                 WHEN OTHER ADD 1 TO WS-MX
             END-EVALUATE
             PERFORM MGET
             IF WS-NN = 2
                 IF WS-MAIR = 0
                     MOVE 0 TO WS-OK1
                 END-IF
             ELSE
                 IF WS-MAIR = 1
                     MOVE 0 TO WS-OK1
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-LX TO WS-MX
     MOVE WS-LY TO WS-MY
     MOVE WS-LZ TO WS-MZ
     .
*> the cell (WS-MX, WS-MY, WS-MZ) can be replaced: air (the data's lava below the sea level is not in the test world); WS-OK1
 N-CANREP.
     PERFORM MGET
     MOVE WS-MAIR TO WS-OK1
     .
*> canPlaceAt: replaceable and the block below not air and not lava or magma; WS-OK1
 N-CPA.
     PERFORM N-CANREP
     IF WS-OK1 = 1
         SUBTRACT 1 FROM WS-MY
         PERFORM MGET
         ADD 1 TO WS-MY
         IF WS-MAIR = 1 OR WS-MB = WS-B-LAVA OR WS-MB = WS-B-MAGMA
             MOVE 0 TO WS-OK1
         END-IF
     END-IF
     .
*> stepped_column_cluster of the data (basalt, continue_through basalt, cannot_place_on lava and magma)
 N-STEP.
     MOVE WS-OX TO WS-MX
     MOVE WS-OY TO WS-MY
     MOVE WS-OZ TO WS-MZ
     PERFORM N-CPA
     IF WS-OK1 = 1
         PERFORM N-STEP-DRAW-H
         EVALUATE FUNCTION TRIM(WS-FTKEY)
             WHEN "minecraft:n7_small_5"
                 MOVE 5 TO WS-RMAX
                 MOVE 50 TO WS-CNT
             WHEN "minecraft:n7_large_5"
                 MOVE 5 TO WS-RMAX
                 MOVE 50 TO WS-CNT
             WHEN OTHER
                 MOVE 8 TO WS-RMAX
                 MOVE 15 TO WS-CNT
         END-EVALUATE
         COMPUTE WS-REACH = FUNCTION MIN(WS-HT, WS-RMAX)
         PERFORM WS-CNT TIMES
             COMPUTE WS-N = 2 * WS-REACH + 1
             PERFORM MDRAW
             COMPUTE WS-CX2 = WS-OX - WS-REACH + WS-D
             MOVE 1 TO WS-N
             PERFORM MDRAW
             COMPUTE WS-N = 2 * WS-REACH + 1
             PERFORM MDRAW
             COMPUTE WS-CZ2 = WS-OZ - WS-REACH + WS-D
             COMPUTE WS-REM = WS-HT - FUNCTION ABS(WS-CX2 - WS-OX) - FUNCTION ABS(WS-CZ2 - WS-OZ)
             IF WS-REM >= 0
                 IF FUNCTION TRIM(WS-FTKEY)(1:14) = "minecraft:n7_l"
                     MOVE 2 TO WS-N
                     PERFORM MDRAW
                     COMPUTE WS-RR = 2 + WS-D
                 ELSE
                     MOVE 1 TO WS-RR
                 END-IF
                 PERFORM N-STEP-COLUMN
             END-IF
         END-PERFORM
     END-IF
     .
 N-STEP-DRAW-H.
     IF FUNCTION TRIM(WS-FTKEY)(1:14) = "minecraft:n7_l"
         MOVE 6 TO WS-N
         PERFORM MDRAW
         COMPUTE WS-HT = 5 + WS-D
     ELSE
         MOVE 4 TO WS-N
         PERFORM MDRAW
         COMPUTE WS-HT = 1 + WS-D
     END-IF
     .
*> placeColumn at (WS-CX2, WS-OY, WS-CZ2), h WS-REM, r WS-RR
 N-STEP-COLUMN.
     COMPUTE WS-LIM = 0 - WS-RR
     PERFORM VARYING WS-QZ FROM WS-LIM BY 1 UNTIL WS-QZ > WS-RR
         PERFORM VARYING WS-DX FROM WS-LIM BY 1 UNTIL WS-DX > WS-RR
             COMPUTE WS-DIST = FUNCTION ABS(WS-DX) + FUNCTION ABS(WS-QZ)
             COMPUTE WS-MX = WS-CX2 + WS-DX
             MOVE WS-OY TO WS-MY
             COMPUTE WS-MZ = WS-CZ2 + WS-QZ
             MOVE WS-MX TO WS-LX
             MOVE WS-MZ TO WS-LZ
             PERFORM N-CANREP
             MOVE 0 TO WS-SIGN
             MOVE WS-OY TO WS-CUR
             IF WS-OK1 = 1
*>               findSurface: down, at most dist cells, while y > minY + 1
                 MOVE 0 TO WS-HIT
                 PERFORM VARYING WS-NN FROM 0 BY 1 UNTIL WS-NN >= WS-DIST OR WS-HIT = 1
                     MOVE WS-CUR TO WS-MY
                     MOVE WS-LX TO WS-MX
                     MOVE WS-LZ TO WS-MZ
                     PERFORM N-CPA
                     IF WS-OK1 = 1
                         MOVE 1 TO WS-HIT
                     ELSE
                         SUBTRACT 1 FROM WS-CUR
                     END-IF
                 END-PERFORM
             ELSE
*>               findAir: up, at most dist cells: lava or magma ends it, air is the answer
                 MOVE 0 TO WS-HIT
                 MOVE 0 TO WS-STOP
                 PERFORM VARYING WS-NN FROM 0 BY 1 UNTIL WS-NN >= WS-DIST OR WS-HIT = 1 OR WS-STOP = 1
                     MOVE WS-CUR TO WS-MY
                     MOVE WS-LX TO WS-MX
                     MOVE WS-LZ TO WS-MZ
                     PERFORM MGET
                     IF WS-MB = WS-B-LAVA OR WS-MB = WS-B-MAGMA
                         MOVE 1 TO WS-STOP
                     ELSE
                         IF WS-MAIR = 1
                             MOVE 1 TO WS-HIT
                         ELSE
                             ADD 1 TO WS-CUR
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
             IF WS-HIT = 1
                 COMPUTE WS-NN = WS-REM - FUNCTION INTEGER(WS-DIST / 2)
                 MOVE 0 TO WS-STOP
                 PERFORM UNTIL WS-NN < 0 OR WS-STOP = 1
                     MOVE WS-CUR TO WS-MY
                     MOVE WS-LX TO WS-MX
                     MOVE WS-LZ TO WS-MZ
                     PERFORM N-CANREP
                     IF WS-OK1 = 1
                         MOVE WS-S-BASALT TO WS-MS
                         PERFORM MPUT
                         ADD 1 TO WS-CUR
                     ELSE
                         IF WS-MB = WS-B-BASALT
                             ADD 1 TO WS-CUR
                         ELSE
                             MOVE 1 TO WS-STOP
                         END-IF
                     END-IF
                     SUBTRACT 1 FROM WS-NN
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     .
*> basalt_pillar of the data (5.2): the down pillar at O with the cap, then four side pillars with chance 0.9
 N-PILLAR-ALL.
     MOVE WS-OX TO WS-LX
     MOVE WS-OY TO WS-LY
     MOVE WS-OZ TO WS-LZ
     MOVE 1.0 TO WS-PCHANCE
     PERFORM N-PILLAR
*>   WS-CUR is the lowest pillar cell; the cap: the patchy square at y - 1, then the four rarity simple blocks
     MOVE WS-CUR TO WS-HH
     PERFORM N-PATCHY
     PERFORM VARYING WS-S3 FROM 1 BY 1 UNTIL WS-S3 > 4
         PERFORM MFLOAT
         IF WS-F < WS-HALF
             COMPUTE WS-MX = WS-OX
             MOVE WS-HH TO WS-MY
             MOVE WS-OZ TO WS-MZ
             EVALUATE WS-S3
                 WHEN 1 ADD 1 TO WS-MX
                 WHEN 2 SUBTRACT 1 FROM WS-MX
                 WHEN 3 ADD 1 TO WS-MZ
                 WHEN OTHER SUBTRACT 1 FROM WS-MZ
             END-EVALUATE
             MOVE WS-S-BASALT TO WS-MS
             PERFORM MPUT
         END-IF
     END-PERFORM
     MOVE 0.9 TO WS-PCHANCE
     PERFORM VARYING WS-S3 FROM 1 BY 1 UNTIL WS-S3 > 4
         MOVE WS-OX TO WS-LX
         MOVE WS-OY TO WS-LY
         MOVE WS-OZ TO WS-LZ
         EVALUATE WS-S3
             WHEN 1 ADD 1 TO WS-LX
             WHEN 2 SUBTRACT 1 FROM WS-LX
             WHEN 3 ADD 1 TO WS-LZ
             WHEN OTHER SUBTRACT 1 FROM WS-LZ
         END-EVALUATE
         PERFORM N-PILLAR
     END-PERFORM
     .
*> one down pillar from (WS-LX, WS-LY, WS-LZ) with chance WS-PCHANCE through air; ends with WS-CUR the lowest placed y (one step back)
 N-PILLAR.
     MOVE WS-LY TO WS-CUR
     MOVE 0 TO WS-STOP
     PERFORM UNTIL WS-STOP = 1
         MOVE WS-LX TO WS-MX
         MOVE WS-CUR TO WS-MY
         MOVE WS-LZ TO WS-MZ
         PERFORM MGET
         IF WS-MAIR = 0
             MOVE 1 TO WS-STOP
         ELSE
             PERFORM MFLOAT
             IF WS-F >= WS-PCHANCE
                 MOVE 1 TO WS-STOP
             ELSE
                 MOVE WS-S-BASALT TO WS-MS
                 PERFORM MPUT
                 SUBTRACT 1 FROM WS-CUR
             END-IF
         END-IF
     END-PERFORM
     ADD 1 TO WS-CUR
     .
*> projected_random_patchy_square: size 3, max_projection_height 3, through air, origin (O.x, WS-HH - 1, O.z); the provider: basalt when the cell below the cursor is not air
 N-PATCHY.
     PERFORM VARYING WS-DX FROM -3 BY 1 UNTIL WS-DX > 3
         PERFORM VARYING WS-DZ FROM -3 BY 1 UNTIL WS-DZ > 3
             MOVE 10 TO WS-N
             PERFORM MDRAW
             IF WS-D < 10 - FUNCTION ABS(WS-DX) * FUNCTION ABS(WS-DZ)
                 COMPUTE WS-CX2 = WS-OX + WS-DX
                 COMPUTE WS-CZ2 = WS-OZ + WS-DZ
                 COMPUTE WS-CY2 = WS-HH - 1
                 MOVE 3 TO WS-NN
                 MOVE 0 TO WS-STOP
                 PERFORM UNTIL WS-STOP = 1
                     MOVE WS-CX2 TO WS-MX
                     COMPUTE WS-MY = WS-CY2 - 1
                     MOVE WS-CZ2 TO WS-MZ
                     PERFORM MGET
                     IF WS-MAIR = 0
                         MOVE 1 TO WS-STOP
                     ELSE
                         SUBTRACT 1 FROM WS-CY2
                         SUBTRACT 1 FROM WS-NN
                         IF WS-NN <= 0
                             MOVE 1 TO WS-STOP
                         END-IF
                     END-IF
                 END-PERFORM
                 MOVE WS-CX2 TO WS-MX
                 COMPUTE WS-MY = WS-CY2 - 1
                 MOVE WS-CZ2 TO WS-MZ
                 PERFORM MGET
                 IF WS-MAIR = 0
                     MOVE WS-CX2 TO WS-MX
                     MOVE WS-CY2 TO WS-MY
                     MOVE WS-CZ2 TO WS-MZ
                     MOVE WS-S-BASALT TO WS-MS
                     PERFORM MPUT
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     .
*> random_neighbor_spread of glowstone_extra: glowstone at O; 1500 attempts, offsets trapezoid -7..7 plateau 0 (nextInt(8) - nextInt(8), 35-4 2.2), y uniform -11..0
 N-SPREAD.
     MOVE WS-OX TO WS-MX
     MOVE WS-OY TO WS-MY
     MOVE WS-OZ TO WS-MZ
     MOVE WS-S-GLOW TO WS-MS
     PERFORM MPUT
     PERFORM 1500 TIMES
         MOVE 8 TO WS-N
         PERFORM MDRAW
         MOVE WS-D TO WS-DX
         PERFORM MDRAW
         COMPUTE WS-DX = WS-DX - WS-D
         MOVE 12 TO WS-N
         PERFORM MDRAW
         COMPUTE WS-DY = WS-D - 11
         MOVE 8 TO WS-N
         PERFORM MDRAW
         MOVE WS-D TO WS-DZ
         PERFORM MDRAW
         COMPUTE WS-DZ = WS-DZ - WS-D
         COMPUTE WS-LX = WS-OX + WS-DX
         COMPUTE WS-LY = WS-OY + WS-DY
         COMPUTE WS-LZ = WS-OZ + WS-DZ
         MOVE WS-LX TO WS-MX
         MOVE WS-LY TO WS-MY
         MOVE WS-LZ TO WS-MZ
         PERFORM MGET
         IF WS-MAIR = 1
             MOVE 0 TO WS-ACT
             PERFORM VARYING WS-NN FROM 1 BY 1 UNTIL WS-NN > 6 OR WS-ACT > 1
                 MOVE WS-LX TO WS-MX
                 MOVE WS-LY TO WS-MY
                 MOVE WS-LZ TO WS-MZ
                 EVALUATE WS-NN
                     WHEN 1 SUBTRACT 1 FROM WS-MY
                     WHEN 2 ADD 1 TO WS-MY
                     WHEN 3 SUBTRACT 1 FROM WS-MZ
                     WHEN 4 ADD 1 TO WS-MZ
                     WHEN 5 SUBTRACT 1 FROM WS-MX
                     WHEN OTHER ADD 1 TO WS-MX
                 END-EVALUATE
                 PERFORM MGET
                 IF WS-MB = WS-B-GLOW
                     ADD 1 TO WS-ACT
                 END-IF
             END-PERFORM
             IF WS-ACT = 1
                 MOVE WS-LX TO WS-MX
                 MOVE WS-LY TO WS-MY
                 MOVE WS-LZ TO WS-MZ
                 MOVE WS-S-GLOW TO WS-MS
                 PERFORM MPUT
             END-IF
         END-IF
     END-PERFORM
     .
 WINDOW-INDEX.
     COMPUTE WS-MI = ((WS-MX - 16) * 16 + (WS-MZ - 32)) * 23 + (WS-MY - 58) + 1
     .
 SNAPSHOT.
     PERFORM VARYING WS-MX FROM 16 BY 1 UNTIL WS-MX > 31
         PERFORM VARYING WS-MZ FROM 32 BY 1 UNTIL WS-MZ > 47
             PERFORM VARYING WS-MY FROM 58 BY 1 UNTIL WS-MY > 80
                 CALL "FL-GET-STATE" USING WS-MX WS-MY WS-MZ WS-STATE
                 PERFORM WINDOW-INDEX
                 MOVE WS-STATE TO WS-SN(WS-MI)
                 MOVE WS-STATE TO WS-MD(WS-MI)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COMPARE-WINDOW.
     PERFORM VARYING WS-MX FROM 16 BY 1 UNTIL WS-MX > 31
         PERFORM VARYING WS-MZ FROM 32 BY 1 UNTIL WS-MZ > 47
             PERFORM VARYING WS-MY FROM 58 BY 1 UNTIL WS-MY > 80
                 CALL "FL-GET-STATE" USING WS-MX WS-MY WS-MZ WS-STATE
                 PERFORM WINDOW-INDEX
                 IF WS-MD(WS-MI) NOT = WS-STATE
                     ADD 1 TO WS-DIFF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COUNT-CHANGES.
     PERFORM VARYING WS-MI FROM 1 BY 1 UNTIL WS-MI > 5888
         IF WS-MD(WS-MI) NOT = WS-SN(WS-MI)
             ADD 1 TO WS-ACTIVE
         END-IF
     END-PERFORM
     .
*> model cell access: WS-MX, WS-MY, WS-MZ; MGET gives WS-MS (the state, air outside the window) and WS-MB (its block), MAIR WS-MAIR 1 when it is air; MPUT sets WS-MS (ignored outside the window)
 MGET.
     MOVE WS-S-AIR TO WS-MS
     IF WS-MX >= 16 AND WS-MX <= 31 AND WS-MZ >= 32 AND WS-MZ <= 47 AND WS-MY >= 58 AND WS-MY <= 80
         PERFORM WINDOW-INDEX
         MOVE WS-MD(WS-MI) TO WS-MS
     END-IF
     COMPUTE WS-MB = CB-S-BLOCK(WS-MS + 1) + 1
     MOVE 0 TO WS-MAIR
     IF WS-MB = WS-B-AIR
         MOVE 1 TO WS-MAIR
     END-IF
     .
 MPUT.
     IF WS-MX >= 16 AND WS-MX <= 31 AND WS-MZ >= 32 AND WS-MZ <= 47 AND WS-MY >= 58 AND WS-MY <= 80
         PERFORM WINDOW-INDEX
         MOVE WS-MS TO WS-MD(WS-MI)
     END-IF
     .
*> MDRAW N: WS-D = nextInt(WS-N) of the model stream
 MDRAW.
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-D
     .
 MFLOAT.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     .
*> MSHUFFLE: Collections.shuffle of WS-LI(1 .. WS-NC): for i = size down to 2 swap(i - 1, nextInt(i))
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-7-NETHER.
 COPY NOSPAWN.
 COPY CORETEST.
