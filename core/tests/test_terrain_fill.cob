*> Implementation test of the terrain fill (core/src/terrain.cob; T0418; docs/protocol/10 section 8.1): the stone, water, lava and
*> air of a chunk from the final density through the aquifer, and the two heightmaps. Worked example columns on two hand-authored
*> fixtures. terrain: the final density is the interpolated gradient 1.0 at y -64 to -1.0 at y 64, which is above 0 for y -64 to -1
*> (the cell from y -8 to 0 goes 0.125 to 0.0: at y -1 it is 0.015625) and 0 or less above: every column is stone at y -64 to -1,
*> sea water at y 0 to 62 (the sea level is 63), air from y 63; WORLD_SURFACE_WG 62 and OCEAN_FLOOR_WG -1 in every column.
*> terrain-flooded: a constant -1.0 (no solid at all): lava at y -64 to -55 (below the lava level -54), water at y -54 to 62, air from 63;
*> surface 62, ocean floor -65 (an empty column). The block table is the test's own (air 0, stone 1, water 86, lava 102).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TERRAIN-FILL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENSTAGE.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG VALUE -1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40) VALUE "minecraft:plains".
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "7" TO CS-SEED-TEXT
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE 4 TO CB-BLOCK-COUNT
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 13 TO CB-KEY-LENGTH(1)
     MOVE 0 TO CB-DEFAULT-STATE(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 15 TO CB-KEY-LENGTH(2)
     MOVE 1 TO CB-DEFAULT-STATE(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 15 TO CB-KEY-LENGTH(3)
     MOVE 86 TO CB-DEFAULT-STATE(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 14 TO CB-KEY-LENGTH(4)
     MOVE 102 TO CB-DEFAULT-STATE(4)
     MOVE 1 TO CBI-COUNT
     MOVE "minecraft:plains" TO CBI-KEY(1)
     MOVE 16 TO CBI-KEY-LENGTH(1)
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET

     MOVE "core/tests/fixtures/terrain" TO WS-DIR
     PERFORM RUN-JOB
     MOVE "test terrain fill the sea fixture: every column of 256 has stone from y -64 to -1" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 319
             COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
             EVALUATE TRUE
                 WHEN WS-Y < 0
                     MOVE 1 TO WS-WANT
                 WHEN WS-Y < 63
                     MOVE 86 TO WS-WANT
                 WHEN OTHER
                     MOVE 0 TO WS-WANT
             END-EVALUATE
             IF CE-STATE(WS-CELL) NOT = WS-WANT
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test terrain fill the sea fixture: surface 62 and ocean floor -1 in the corner and the middle column" TO TL-CASE
     COMPUTE TL-OBSERVED-N = T-HM-SURFACE(1) * 1000 + T-HM-OCEAN(1) + (T-HM-SURFACE(137) - 62) + (T-HM-OCEAN(256) + 1)
     MOVE 61999 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB

     MOVE "core/tests/fixtures/terrain-flooded" TO WS-DIR
     PERFORM RUN-JOB
     MOVE "test terrain fill the flooded fixture: lava below -54, water to 62, air above, no stone" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 319
             COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
             EVALUATE TRUE
                 WHEN WS-Y < -54
                     MOVE 102 TO WS-WANT
                 WHEN WS-Y < 63
                     MOVE 86 TO WS-WANT
                 WHEN OTHER
                     MOVE 0 TO WS-WANT
             END-EVALUATE
             IF CE-STATE(WS-CELL) NOT = WS-WANT
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test terrain fill the flooded fixture: surface 62, no ocean floor (-65)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = T-HM-SURFACE(5) * 1000 + T-HM-OCEAN(5)
     MOVE 61935 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     STOP RUN.

 RUN-JOB.
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     PERFORM UNTIL T-ACTIVE NOT = 1
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     SET ADDRESS OF CE-CHUNK TO T-ADDR.
 END PROGRAM TEST-TERRAIN-FILL.
 COPY CORETEST.
