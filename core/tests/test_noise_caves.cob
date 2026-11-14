*> Implementation test of the noise caves in the terrain fill (T0427; docs/protocol/11 section 2): the caves are part of final_density
*> (cheese, spaghetti, entrance, pillar and noodle terms; there is no separate noise-cave stage), so the fill of a chunk must be stone
*> exactly where the final density is above 0 and open (water, lava or air by the aquifer) where it is 0 or less. Fixture
*> core/tests/fixtures/final (hand-authored: the structure of 11 section 2.1 with every noise leaf a gradient or constant). The density at a
*> block is evaluated directly (DENSITY-EVAL, bit identical to the grid mode: test_density_final) and compared with the block the
*> job placed, in 8 columns of the chunk over the whole height. The fill must contain stone and open cells below y 0 (deep rock).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NOISE-CAVES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENSTAGE.
 COPY GENSTEPS.
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
 01 WS-D                   FLOAT-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:overworld/final_density".
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
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

     MOVE "core/tests/fixtures/final" TO WS-DIR
     PERFORM RUN-JOB
     MOVE "test noise caves: stone exactly where the final density is above 0, in 8 columns over the whole height" TO TL-CASE
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-OPEN
     MOVE 0 TO WS-STONE
     PERFORM VARYING WS-COL FROM 1 BY 1 UNTIL WS-COL > 8
         COMPUTE WS-I = (WS-COL - 1) * 31 + 1
         COMPUTE WS-X = WS-CX * 16 + FUNCTION MOD(WS-I - 1, 16)
         COMPUTE WS-Z = WS-CZ * 16 + (WS-I - 1) / 16
         PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 319
             CALL "DENSITY-EVAL" USING WS-KEY WS-X WS-Y WS-Z WS-D
             COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
             IF WS-D > 0
                 MOVE 1 TO WS-WANT
             ELSE
                 MOVE 0 TO WS-WANT
             END-IF
             IF (CE-STATE(WS-CELL) = 1 AND WS-WANT = 0) OR (CE-STATE(WS-CELL) NOT = 1 AND WS-WANT = 1)
                 ADD 1 TO WS-BAD
             END-IF
             IF WS-Y < 0
                 IF CE-STATE(WS-CELL) = 1
                     ADD 1 TO WS-STONE
                 ELSE
                     ADD 1 TO WS-OPEN
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test noise caves: deep rock (y below 0) has stone and open cells" TO TL-CASE
     IF WS-STONE > 0 AND WS-OPEN > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     STOP RUN.

 RUN-JOB.
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     PERFORM UNTIL T-ACTIVE NOT = 1 OR T-STAGE >= GJ-STAGE-CARVERS
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     SET ADDRESS OF CE-CHUNK TO T-ADDR.
 END PROGRAM TEST-NOISE-CAVES.
 COPY CORETEST.
