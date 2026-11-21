*> Real-data acceptance test (US12-1 "lakes appear"; skipped as a pass without the generated packs; docs/protocol/35-worldgen-features-5-water-and-surface.md section 3,
*> 35-1 section 4.1; core/src/feat-lake.cob): the lava lakes of the lakes step (lake_lava_underground, lake_lava_surface) are made in a standard world. Before the fix a lake
*> whose pool reached the border of the chunk failed its validity pass (a cell outside the chunk read as air), which was nearly every placement: a scan of 144 chunks found none.
*> A lake shows as lava with cave air directly above it (nothing else of the generator makes cave air over lava). A scan of the 144 chunks (-6..5, -6..5) of seed 12345 takes
*> minutes, so the test generates the chunk (-2, -3) of that scan, the only one that holds a lake (the pool cut at the chunk border, the lava top at y 44), and a second world
*> of the same seed gives the same lava and cave air cells there (deterministic). The data has no water lake outside the sulfur_caves biome (sulfur_pool).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-LAKES-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE -2.
 01 WS-CZ                  BINARY-LONG VALUE -3.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BLK                 BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-CAVE                BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-LOW-Y               BINARY-LONG.
 01 WS-CELLS-1             BINARY-LONG.
 01 WS-LOW-Y-1             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance lakes standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     PERFORM OPEN-AND-SCAN
     MOVE WS-CELLS TO WS-CELLS-1
     MOVE WS-LOW-Y TO WS-LOW-Y-1
     MOVE "acceptance lakes standard: chunk (-2, -3) of seed 12345 holds a lava lake (lava under cave air)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CELLS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance lakes standard: the lake's lava top layer is at world y 44 (an underground lake)" TO TL-CASE
     MOVE 44 TO TL-EXPECTED-N
     MOVE WS-LOW-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "lake cells " WS-CELLS
     PERFORM OPEN-AND-SCAN
     MOVE "acceptance lakes standard: a second world of the same seed has the same lake (deterministic)" TO TL-CASE
     MOVE WS-CELLS-1 TO TL-EXPECTED-N
     MOVE WS-CELLS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Opens a new world of the seed and counts, in chunk (WS-CX, WS-CZ), the lava cells with cave air directly above (WS-CELLS) and the world y of the lowest one (WS-LOW-Y).
 OPEN-AND-SCAN.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Lakes" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "lava" TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-BLK
     MOVE CB-DEFAULT-STATE(WS-BLK) TO WS-LAVA
     MOVE "cave_air" TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-BLK
     MOVE CB-DEFAULT-STATE(WS-BLK) TO WS-CAVE
     MOVE 0 TO WS-CELLS
     MOVE -999 TO WS-LOW-Y
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 380
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 COMPUTE WS-INDEX = WS-Y * 256 + WS-Z * 16 + WS-X + 1
                 COMPUTE WS-ABOVE = WS-INDEX + 256
                 IF CE-STATE(WS-INDEX) = WS-LAVA AND CE-STATE(WS-ABOVE) = WS-CAVE
                     ADD 1 TO WS-CELLS
                     IF WS-LOW-Y = -999
                         COMPUTE WS-LOW-Y = WS-Y - 64
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 END PROGRAM ACC-LAKES-STANDARD.

 COPY NOSPAWN.
 COPY CORETEST.
