*> Acceptance test (T0439; US11-1, docs/protocol/10 section 11 and 11 section 1): the standard world generates a chunk through its pipeline
*> (the world type selects it: WORLD-CHUNK, no other call) whose columns equal the worked example of the veins fixture (core/tests/fixtures/veins,
*> test_ore_veins.cob): sea water from y 0 to 62 and air above in every column, stone and the vein states below (with the fixture's seven-block
*> table the ore features place only those states or air). The world seed is the persisted numeric Seed (CW-SEED 7) and not the seed text
*> ("999" here): the veins of the chunk equal the independent evaluation of expected.py for seed 7 and differ for seed 8.
*> Status order (10 section 11.1): the job runs the stages biomes, density, aquifer, fill, surface, carvers, ores, finish in this order, each
*> once. Neighbour requirements (10 section 11.2, no structures): a chunk generated alone equals the same chunk generated after its
*> neighbours (every shared value is a pure function of the seed and the coordinates: no state of an earlier chunk reaches a later one).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US11-WORLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENSTEPS.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CTWORLDGEN.
 COPY SURFACE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/veins".
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG VALUE -1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-CHECK               BINARY-DOUBLE.
 01 WS-CHECK-7             BINARY-DOUBLE.
 01 WS-CHECK-ALONE         BINARY-DOUBLE.
 01 WS-LAST                BINARY-LONG.
 01 WS-ORDER-BAD           BINARY-LONG.
 01 WS-STAGES-SEEN         BINARY-LONG.
 01 WS-BUF                 PIC X(304640).
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
     MOVE "999" TO CS-SEED-TEXT
     MOVE 7 TO CW-SEED
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE 7 TO CB-BLOCK-COUNT
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 13 TO CB-KEY-LENGTH(1)
     MOVE 0 TO CB-DEFAULT-STATE(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 15 TO CB-KEY-LENGTH(2)
     MOVE 1 TO CB-DEFAULT-STATE(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 15 TO CB-KEY-LENGTH(3)
     MOVE 86 TO CB-DEFAULT-STATE(3)
     MOVE 86 TO CB-FIRST-STATE(3)
     MOVE 16 TO CB-STATES(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 14 TO CB-KEY-LENGTH(4)
     MOVE 102 TO CB-DEFAULT-STATE(4)
     MOVE "minecraft:copper_ore" TO CB-KEY(5)
     MOVE 20 TO CB-KEY-LENGTH(5)
     MOVE 50 TO CB-DEFAULT-STATE(5)
     MOVE "minecraft:raw_copper_block" TO CB-KEY(6)
     MOVE 26 TO CB-KEY-LENGTH(6)
     MOVE 51 TO CB-DEFAULT-STATE(6)
     MOVE "minecraft:granite" TO CB-KEY(7)
     MOVE 17 TO CB-KEY-LENGTH(7)
     MOVE 52 TO CB-DEFAULT-STATE(7)
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
     CALL "MATERIAL-RULES-LOAD" USING WS-DIR WS-STATUS
     CALL "GEN-QUEUE-RESET"

*>   the world's chunk through the world type's pipeline
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 319
         IF WS-Y < 63
             MOVE 86 TO WS-WANT
         ELSE
             MOVE 0 TO WS-WANT
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
             IF CE-STATE(WS-CELL) NOT = WS-WANT
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acc f2us11 world every column has sea water from y 0 to 62 and air above" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > -1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
             MOVE CE-STATE(WS-CELL) TO WS-STATE
             IF WS-STATE NOT = 0 AND WS-STATE NOT = 1 AND WS-STATE NOT = 50 AND WS-STATE NOT = 51 AND WS-STATE NOT = 52
                 AND WS-STATE NOT = 86 AND WS-STATE NOT = 102
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acc f2us11 world below y 0 only stone, the vein states, carved air, water and lava" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the numeric seed: the chunk of the terrain pipeline up to the carvers (which carve some vein cells, and the feature stage adds
*>   copper ore and granite) has the 728 raw copper cells of the independent evaluation for seed 7 (expected.py; the seed text is "999")
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     PERFORM UNTIL T-ACTIVE NOT = 1 OR T-STAGE >= GJ-STAGE-CARVERS
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 98304
         IF CE-STATE(WS-CELL) = 51
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     CALL "GEN-JOB-FREE" USING WS-JOB
     MOVE "acc f2us11 world the persisted seed 7 gives the vein cells of the independent evaluation (728 raw copper)" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 728 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   status order of the job
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     MOVE 0 TO WS-LAST WS-ORDER-BAD WS-STAGES-SEEN
     PERFORM UNTIL T-ACTIVE NOT = 1
         IF T-STAGE < WS-LAST
             ADD 1 TO WS-ORDER-BAD
         END-IF
         IF T-STAGE > WS-LAST
             ADD 1 TO WS-STAGES-SEEN
             MOVE T-STAGE TO WS-LAST
         END-IF
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     CALL "GEN-JOB-FREE" USING WS-JOB
     MOVE "acc f2us11 world the stages run in order biomes to finish (the feature stage before it), each once" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-ORDER-BAD * 100 + WS-STAGES-SEEN * 10 + WS-LAST
     MOVE 99 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   neighbours: the chunk alone, after its neighbours, and with another seed
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-BUF
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-BUF WS-MARKER
     PERFORM CHECKSUM
     MOVE WS-CHECK TO WS-CHECK-ALONE
     COMPUTE WS-CX = WS-CX + 1
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-BUF WS-MARKER
     COMPUTE WS-CZ = WS-CZ - 1
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-BUF WS-MARKER
     MOVE -1 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-BUF WS-MARKER
     PERFORM CHECKSUM
     MOVE "acc f2us11 world a chunk generated after its neighbours equals the chunk generated alone" TO TL-CASE
     MOVE WS-CHECK TO TL-OBSERVED-N
     MOVE WS-CHECK-ALONE TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-CHECK TO WS-CHECK-7
     MOVE 8 TO CW-SEED
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-BUF WS-MARKER
     PERFORM CHECKSUM
     MOVE "acc f2us11 world another seed gives another chunk" TO TL-CASE
     IF WS-CHECK NOT = WS-CHECK-7
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECKSUM.
     MOVE 0 TO WS-CHECK
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 98304
         COMPUTE WS-CHECK = FUNCTION MOD(WS-CHECK * 31 + CE-STATE(WS-CELL), 1000000007)
     END-PERFORM.
 END PROGRAM ACC-F2US11-WORLD.
 COPY CORETEST.
