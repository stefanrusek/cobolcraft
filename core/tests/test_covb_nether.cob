*> Implementation test (lane covB; docs/protocol/35-worldgen-features-7-nether-end-misc.md sections 3 to 5): Nether features on terrain chosen to reach their less common branches, without the
*> random model of test_feat_35_7_nether: a delta cell that cannot be replaced (a nether brick) or has a solid roof is not clear, a stepped column cluster whose origin hangs over air
*> places nothing, a column that stops at a repellent block, passes through its continue_through block and ends at a block that is neither, and a patchy square projecting down through air.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-NETHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/covb-nether".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-PAIRS               PIC X(160).
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
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 7.
 01 WS-FLAG                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-H                   BINARY-LONG VALUE 3.
 01 WS-R                   BINARY-LONG VALUE 1.
 01 WS-S-BASALT            BINARY-LONG.
 01 WS-B-AIR               BINARY-LONG.
 01 WS-B-LAVA              BINARY-LONG.
 01 WS-B-MAGMA             BINARY-LONG.
 01 WS-B-BASALT            BINARY-LONG.
 01 WS-TAG-REG             PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-N               BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 12 TIMES.
 01 WS-TAG-STATUS          BINARY-LONG.
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
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-AIR
     MOVE "lava" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-LAVA
     MOVE "magma_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-MAGMA
     MOVE "basalt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BASALT
     MOVE "axis=y" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-BASALT
*>   The tags the features of the data name: air, and the blocks a column may not stand on.
     MOVE 1 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-AIR - 1
     MOVE "minecraft:air" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE 2 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-LAVA - 1
     COMPUTE WS-TAG-ID(2) = WS-B-MAGMA - 1
     MOVE "minecraft:cannot_place_basalt_pillar_on" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
*>   The window: netherrack from y 58 to 61 over the whole chunk.
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 58 TO WS-Y0
     MOVE 61 TO WS-Y1
     MOVE "netherrack" TO WS-KEY
     PERFORM FILL-BOX
*>   isClear of the delta: a nether brick at the cell is in CANNOT_REPLACE; a solid roof makes it not clear; a free roof over a closed ground is clear.
     MOVE "minecraft:n7_delta" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE FT-A(WS-FT) TO WS-ROW
     MOVE 24 TO WS-X
     MOVE 61 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "nether_bricks" TO WS-KEY
     PERFORM PUT-AT
     CALL "FR-DELTA-CLEAR" USING WS-ROW WS-X WS-Y WS-Z WS-FLAG
     MOVE "covB 35-7 3 a nether brick cell is not clear (it cannot be replaced)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-FLAG TO WS-OBS
     PERFORM ASSERT-N
     MOVE 26 TO WS-X
     MOVE "netherrack" TO WS-KEY
     MOVE 62 TO WS-Y
     PERFORM PUT-AT
     MOVE 61 TO WS-Y
     CALL "FR-DELTA-CLEAR" USING WS-ROW WS-X WS-Y WS-Z WS-FLAG
     MOVE "covB 35-7 3 a cell with a solid block above it is not clear" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-FLAG TO WS-OBS
     PERFORM ASSERT-N
     MOVE 28 TO WS-X
     CALL "FR-DELTA-CLEAR" USING WS-ROW WS-X WS-Y WS-Z WS-FLAG
     MOVE "covB 35-7 3 a netherrack cell with air above and solid sides and ground is clear" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-FLAG TO WS-OBS
     PERFORM ASSERT-N
*>   A column cluster whose origin hangs over air is not placed.
     MOVE "minecraft:n7_small_5" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE 9 TO WS-RESULT
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "covB 35-7 4 a column cluster over air (nothing to stand on) places nothing" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-RESULT TO WS-OBS
     PERFORM ASSERT-N
*>   The columns around the centre (24, 62, 40): east a basalt cell to pass through and netherrack on top of it, west a magma block that stops the search for air.
     MOVE FT-A(WS-FT) TO WS-ROW
     MOVE 25 TO WS-X
     MOVE 63 TO WS-Y
     MOVE "basalt" TO WS-KEY
     MOVE "axis=y" TO WS-PAIRS
     PERFORM PUT-PAIRS
     MOVE 64 TO WS-Y
     MOVE "netherrack" TO WS-KEY
     PERFORM PUT-AT
     MOVE 23 TO WS-X
     MOVE 62 TO WS-Y
     MOVE "magma_block" TO WS-KEY
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     MOVE 62 TO WS-Y
     CALL "FR-STEP-COLUMN" USING XR-STATE WS-ROW WS-X WS-Y WS-Z WS-H WS-R WS-PLACED
     MOVE "covB 35-7 4 the column east of the centre is placed on the ground (basalt at its first cell)" TO WS-CASE
     MOVE 25 TO WS-X
     MOVE 62 TO WS-Y
     MOVE "basalt" TO WS-KEY
     PERFORM ASSERT-BLOCK
     MOVE "covB 35-7 4 it kept the basalt it passed through" TO WS-CASE
     MOVE 63 TO WS-Y
     PERFORM ASSERT-BLOCK
     MOVE "covB 35-7 4 and stopped below the netherrack it could not pass" TO WS-CASE
     MOVE 64 TO WS-Y
     MOVE "netherrack" TO WS-KEY
     PERFORM ASSERT-BLOCK
     MOVE "covB 35-7 4 the magma block in the west column is left (the search for air stops there)" TO WS-CASE
     MOVE 23 TO WS-X
     MOVE 62 TO WS-Y
     MOVE "magma_block" TO WS-KEY
     PERFORM ASSERT-BLOCK
*>   A patchy square at (24, 70, 40) projects down through air by at most 3 and puts the basalt there.
     MOVE "minecraft:c_patchy" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "covB 35-4 7.6 the centre of a patchy square lands 3 blocks under its origin (basalt at y 67)" TO WS-CASE
     MOVE 67 TO WS-Y
     MOVE "basalt" TO WS-KEY
     PERFORM ASSERT-BLOCK
     STOP RUN.
 COPY FWTEST.
 END PROGRAM TEST-COVB-NETHER.
 COPY NOSPAWN.
 COPY CORETEST.
