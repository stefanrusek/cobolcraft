*> Implementation test of the aquifer (core/src/aquifer.cob; T0420; docs/protocol/10 section 9): similarity and pressure (the worked
*> examples of 9.6 and the branches of the formula, the expected doubles from a Python evaluation of the formulas, the barrier noise
*> undefined so it reads 0 where it is sampled), the skipSamplingAboveY of a preliminary surface level of 70 (maxSurface 70: gridY(90) = 7,
*> (7 - 1) * 12 + 11 - 1 = 82), the grid cell centres (within their cell offsets 0 to 9, 0 to 8, 0 to 9, the same on a second call),
*> and the decisions of computeSubstance on a hand-authored fixture (core/tests/fixtures/aquifer: surface level 70, no noises, so there is no
*> aquifer fluid anywhere): lava below y -54, no fluid (cave air) from there to y 82 and global water below 63 not used, air above; a
*> whole chunk then is lava from y -64 to -55 and air above. The noise-driven decisions (floodedness, spread, lava noise, the barrier
*> value) need the real noise data: a Convergence test.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-AQUIFER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY GENSTEPS.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/aquifer".
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-C                  BINARY-LONG.
 01 WS-Z                  BINARY-LONG.
 01 WS-LA                 BINARY-LONG.
 01 WS-LB                 BINARY-LONG.
 01 WS-T1                 BINARY-LONG.
 01 WS-T2                 BINARY-LONG.
 01 WS-LEVEL                BINARY-LONG.
 01 WS-LAVAS               BINARY-LONG.
 01 WS-SRC                 PIC X(304640) BASED.
 01 WS-COPY                PIC X(304640).
 01 WS-COPY-2              PIC X(304640).
 01 WS-CUT                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-IDX2                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-D                   FLOAT-LONG VALUE -1.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40) VALUE "minecraft:plains".
 01 WS-WATER-TYPE          BINARY-LONG VALUE 1.
 01 WS-LAVA-TYPE           BINARY-LONG VALUE 2.
 01 WS-A-LEVEL             BINARY-LONG VALUE 70.
 01 WS-B-LEVEL             BINARY-LONG VALUE 70.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "0" TO CS-SEED-TEXT
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
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     CALL "GEN-QUEUE-RESET"

*>   similarity and the flowing constant
     MOVE 36 TO WS-A
     MOVE 50 TO WS-B
     CALL "AQ-SIMILARITY" USING WS-A WS-B WS-R
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-R WS-GOT
     MOVE "test aquifer similarity(36, 50) is 1 - 14 / 25.0" TO TL-CASE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE 4601597955262077992 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-A
     MOVE 144 TO WS-B
     CALL "AQ-SIMILARITY" USING WS-A WS-B WS-R
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-R WS-GOT
     MOVE "test aquifer FLOWING is similarity(10 squared, 12 squared) = -0.76" TO TL-CASE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE -4618351345875896238 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   pressure: the worked examples of 9.6 and the branches
     MOVE 0 TO T-AQ-BARRIER
     PERFORM PRESSURE-CASE-1
     PERFORM PRESSURE-CASE-2
     PERFORM PRESSURE-CASE-3
     PERFORM PRESSURE-CASE-4
     PERFORM PRESSURE-CASE-5
     PERFORM PRESSURE-CASE-6

*>   the aquifer stage
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     MOVE GJ-STAGE-AQUIFER TO T-STAGE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= GJ-STEPS-AQUIFER
         MOVE WS-I TO T-SUB
         CALL "AQUIFER-PREP" USING WS-JOB
     END-PERFORM
     MOVE "test aquifer the surface scan finds maxSurface 70 and skipSamplingAboveY 82" TO TL-CASE
     COMPUTE TL-OBSERVED-N = T-AQ-MAX-SURFACE * 1000 + T-AQ-SKIP-Y
     MOVE 70082 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test aquifer the aquifer of the fixture is ready" TO TL-CASE
     MOVE T-AQ-READY TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "AQ-CENTER" USING WS-JOB WS-A WS-B WS-C WS-IDX
     MOVE T-AQ-PX(WS-IDX) TO WS-I
     CALL "AQ-CENTER" USING WS-JOB WS-A WS-B WS-C WS-IDX2
     MOVE "test aquifer a cell centre lies in its cell (offsets 0-9, 0-8, 0-9) and is the same on a second call" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF T-AQ-PX(WS-IDX) >= 0 AND T-AQ-PX(WS-IDX) <= 9 AND T-AQ-PY(WS-IDX) >= 0 AND T-AQ-PY(WS-IDX) <= 8
         AND T-AQ-PZ(WS-IDX) >= 0 AND T-AQ-PZ(WS-IDX) <= 9 AND WS-IDX = WS-IDX2 AND T-AQ-PX(WS-IDX2) = WS-I
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     MOVE -1 TO WS-A
     MOVE 0 TO WS-C
     CALL "AQ-CENTER" USING WS-JOB WS-A WS-B WS-C WS-IDX
     MOVE "test aquifer the centre of the cell (-1, 0, 0) is shifted by the cell's own origin" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF T-AQ-PX(WS-IDX) >= -16 AND T-AQ-PX(WS-IDX) <= -7
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   computeSubstance
     MOVE 5 TO WS-A
     MOVE 5 TO WS-B
     MOVE -60 TO WS-Y
     CALL "AQUIFER-SUBSTANCE" USING WS-JOB WS-A WS-Y WS-B WS-D WS-KIND
     MOVE "test aquifer y -60 is global lava (below -54, before any sampling)" TO TL-CASE
     MOVE WS-KIND TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -30 TO WS-Y
     CALL "AQUIFER-SUBSTANCE" USING WS-JOB WS-A WS-Y WS-B WS-D WS-KIND
     MOVE "test aquifer y -30 below the surface has no fluid in the fixture: air" TO TL-CASE
     MOVE WS-KIND TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-Y
     CALL "AQUIFER-SUBSTANCE" USING WS-JOB WS-A WS-Y WS-B WS-D WS-KIND
     MOVE "test aquifer y 40 (below the sea level, in the sampled band) is air in the fixture" TO TL-CASE
     MOVE WS-KIND TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 120 TO WS-Y
     CALL "AQUIFER-SUBSTANCE" USING WS-JOB WS-A WS-Y WS-B WS-D WS-KIND
     MOVE "test aquifer y 120 above skipSamplingAboveY is the global status at 120: air" TO TL-CASE
     MOVE WS-KIND TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO T-AQ-SKIP-Y
     MOVE 50 TO WS-Y
     CALL "AQUIFER-SUBSTANCE" USING WS-JOB WS-A WS-Y WS-B WS-D WS-KIND
     MOVE "test aquifer above a lowered skipSamplingAboveY y 50 is the global status: water" TO TL-CASE
     MOVE WS-KIND TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   statuses forced: cells alternate between (level 63, water) and (level 45, water); the density is just below 0, so where the two
*>   nearest centres differ in level the pressure keeps the block solid (kind 0) and where they agree the block is water below 63
     MOVE 1000 TO T-AQ-SKIP-Y
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 315
         MOVE 1 TO T-AQ-STAT(WS-I)
         MOVE 1 TO T-AQ-TYPE(WS-I)
         IF FUNCTION MOD(WS-I, 2) = 0
             MOVE 63 TO T-AQ-LEVEL(WS-I)
         ELSE
             MOVE 45 TO T-AQ-LEVEL(WS-I)
         END-IF
     END-PERFORM
     MOVE -0.0001 TO WS-D
     MOVE 0 TO WS-SOLID
     MOVE 0 TO WS-WET
     PERFORM VARYING WS-A FROM 0 BY 3 UNTIL WS-A > 15
         PERFORM VARYING WS-B FROM 0 BY 3 UNTIL WS-B > 15
             PERFORM VARYING WS-Y FROM 30 BY 2 UNTIL WS-Y > 62
                 CALL "AQUIFER-SUBSTANCE" USING WS-JOB WS-A WS-Y WS-B WS-D WS-KIND
                 IF WS-KIND = 0
                     ADD 1 TO WS-SOLID
                 END-IF
                 IF WS-KIND = 2
                     ADD 1 TO WS-WET
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "test aquifer unequal neighbouring statuses give solid blocks and equal ones water (both occur)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SOLID > 0 AND WS-WET > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB

*>   the memo of the surface levels: two columns of one hash slot, the slot 2048 wrapping to 1 (columns (-44, 80) and (24, -44))
     MOVE -44 TO WS-A
     MOVE 80 TO WS-B
     CALL "AQ-SURFACE-LEVEL" USING WS-JOB WS-A WS-B WS-LEVEL
     MOVE 24 TO WS-A
     MOVE -44 TO WS-B
     CALL "AQ-SURFACE-LEVEL" USING WS-JOB WS-A WS-B WS-LEVEL
     CALL "AQ-SURFACE-LEVEL" USING WS-JOB WS-A WS-B WS-LEVEL
     MOVE "test aquifer two columns in one hash slot (the slot wrapping round) both read 70" TO TL-CASE
     MOVE WS-LEVEL TO TL-OBSERVED-N
     MOVE 70 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   uniform statuses (63, water): at y -54 the block is water above the lava band, kept as water (9.2 step 7)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 315
         MOVE 63 TO T-AQ-LEVEL(WS-I)
     END-PERFORM
     MOVE -54 TO WS-Y
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > 15
         PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > 15
             CALL "AQUIFER-SUBSTANCE" USING WS-JOB WS-A WS-Y WS-B WS-D WS-KIND
             IF WS-KIND NOT = 2
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "test aquifer water directly above the lava band stays water at all 256 columns" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB

*>   a whole chunk through the job
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     PERFORM UNTIL T-ACTIVE NOT = 1
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 319
             COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
             IF WS-Y < -54
                 MOVE 102 TO WS-WANT
             ELSE
                 MOVE 0 TO WS-WANT
             END-IF
             IF CE-STATE(WS-CELL) NOT = WS-WANT
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "test aquifer the chunk of the fixture is lava below -54 and cave air above (the aquifer replaced the sea)" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB

*>   the noisy fixture (a surface level of 40, an erosion gradient that excludes x < -7, depth 2, strong noises): the whole chunk (-1, 0)
*>   twice gives the same bytes, and it holds the fluids of all kinds in places the global picker alone would not put them
     MOVE "core/tests/fixtures/aquifer-noise" TO WS-DIR
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
*>   cell statuses over a wide sweep of centres: below -40 the randomized level is at most -10 so the lava noise may turn the fluid to lava;
*>   from y 0 to 36 the randomized level can exceed the smallest surface level 40 and is cut to it
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     MOVE 0 TO T-SUB
     MOVE GJ-STAGE-AQUIFER TO T-STAGE
     CALL "AQUIFER-PREP" USING WS-JOB
     MOVE 0 TO WS-LAVAS
     MOVE 0 TO WS-CUT
     MOVE 1 TO WS-IDX
     PERFORM VARYING WS-A FROM -640 BY 32 UNTIL WS-A > 640
         PERFORM VARYING WS-B FROM -640 BY 32 UNTIL WS-B > 640
             MOVE 1 TO T-AQ-HAVE(1)
             MOVE WS-A TO T-AQ-PX(1)
             MOVE WS-B TO T-AQ-PZ(1)
             MOVE -45 TO T-AQ-PY(1)
             MOVE 0 TO T-AQ-STAT(1)
             CALL "AQ-STATUS" USING WS-JOB WS-IDX WS-LEVEL WS-C
             IF WS-C = 2 AND WS-LEVEL <= -10
                 ADD 1 TO WS-LAVAS
             END-IF
             MOVE 20 TO T-AQ-PY(1)
             MOVE 0 TO T-AQ-STAT(1)
             CALL "AQ-STATUS" USING WS-JOB WS-IDX WS-LEVEL WS-C
             IF WS-LEVEL = 40
                 ADD 1 TO WS-CUT
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "test aquifer a sweep of cell centres finds lava turned by the lava noise and levels cut to the smallest surface level" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LAVAS > 0 AND WS-CUT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     MOVE -3 TO WS-CX
     PERFORM TWO-RUNS
     MOVE -1 TO WS-CX
     PERFORM TWO-RUNS
     MOVE "test aquifer a chunk with noisy aquifers is the same on a second run" TO TL-CASE
     IF WS-COPY = WS-COPY-2
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-COPY
     MOVE 0 TO WS-WET
     MOVE 0 TO WS-SOLID
     MOVE 0 TO WS-LAVAS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-STATE-CELLS
         COMPUTE WS-Y = (WS-I - 1) / 256 - 64
         IF CE-STATE(WS-I) = 86 AND WS-Y < 63
             ADD 1 TO WS-WET
         END-IF
         IF CE-STATE(WS-I) = 102 AND WS-Y >= -54
             ADD 1 TO WS-LAVAS
         END-IF
         IF CE-STATE(WS-I) = 1
             ADD 1 TO WS-SOLID
         END-IF
     END-PERFORM
     MOVE "test aquifer the noisy chunk holds aquifer water, lava above the lava level, and pressure-solid blocks" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WET > 0 AND WS-LAVAS > 0 AND WS-SOLID > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 TWO-RUNS.
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     PERFORM UNTIL T-ACTIVE NOT = 1
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     SET ADDRESS OF WS-SRC TO T-ADDR
     MOVE WS-SRC TO WS-COPY
     CALL "GEN-JOB-FREE" USING WS-JOB
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     PERFORM UNTIL T-ACTIVE NOT = 1
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     SET ADDRESS OF WS-SRC TO T-ADDR
     MOVE WS-SRC TO WS-COPY-2
     CALL "GEN-JOB-FREE" USING WS-JOB.

 PRESSURE-CASE-1.
     MOVE 63 TO WS-A
     MOVE 45 TO WS-B
     MOVE 50 TO WS-Y
     PERFORM PRESSURE-RUN
     MOVE "test aquifer pressure (63 water, 45 water) at y 50: off <= 0, q 2.8333 out of range, barrier 0: 5.6667 (9.6)" TO TL-CASE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE 4618066117899496107 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 PRESSURE-CASE-2.
     MOVE 63 TO WS-A
     MOVE 60 TO WS-B
     MOVE 62 TO WS-Y
     PERFORM PRESSURE-RUN
     MOVE "test aquifer pressure (63, 60) at y 62: off > 0, q 0.3333 in range, the barrier noise sampled (undefined: 0): 0.6667 (9.6)" TO TL-CASE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE 4604180019048437077 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 PRESSURE-CASE-3.
     MOVE 10 TO WS-A
     MOVE 30 TO WS-B
     MOVE 50 TO WS-Y
     PERFORM PRESSURE-RUN
     MOVE "test aquifer pressure (10, 30) at y 50: off > 0 and v <= 0 divides by 2.5: -16.4" TO TL-CASE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE -4598062629554592154 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 PRESSURE-CASE-4.
     MOVE 63 TO WS-A
     MOVE 45 TO WS-B
     MOVE 20 TO WS-Y
     PERFORM PRESSURE-RUN
     MOVE "test aquifer pressure (63, 45) at y 20: off <= 0 and v <= 0 divides by 10: -4.3" TO TL-CASE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE -4606844648827964621 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 PRESSURE-CASE-5.
     MOVE 63 TO WS-A
     MOVE 63 TO WS-B
     MOVE 20 TO WS-Y
     PERFORM PRESSURE-RUN
     MOVE "test aquifer pressure of two equal levels is 0.0" TO TL-CASE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 PRESSURE-CASE-6.
     MOVE 70 TO WS-A
     MOVE 70 TO WS-B
     MOVE -60 TO WS-Y
     MOVE WS-A TO WS-Z
     CALL "AQ-PRESSURE" USING WS-JOB WS-A WS-Y WS-Z WS-A-LEVEL WS-WATER-TYPE WS-B-LEVEL WS-LAVA-TYPE WS-R
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-R WS-GOT
     MOVE "test aquifer pressure of lava against water is 2.0" TO TL-CASE
     MOVE WS-GOT TO TL-OBSERVED-N
     MOVE 4611686018427387904 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 PRESSURE-RUN.
     MOVE WS-A TO WS-Z
     MOVE WS-A TO WS-LA
     MOVE WS-B TO WS-LB
     MOVE 1 TO WS-T1
     MOVE 1 TO WS-T2
     CALL "AQ-PRESSURE" USING WS-JOB WS-A WS-Y WS-Z WS-LA WS-T1 WS-LB WS-T2 WS-R
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-R WS-GOT.
 END PROGRAM TEST-AQUIFER.
 COPY CORETEST.
