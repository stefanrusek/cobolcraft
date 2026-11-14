*> Real-data probe of the mineshaft (skipped as a pass without the generated packs; docs/protocol/36-structures-5 section 2; 36-1 sections 5 and 7): on the generated
*> vanilla-data (CC_GENERATED_DIR, read only) the standard world has the mineshaft gated on by WORLD-GEN-DATA-OPEN. The starts of a 24 x 24 chunk area of the world seed
*> are counted (STRUCT-CHUNK-STARTS: the biome rules of the data apply); the chunk of the first start (its stub chunk) is generated whole by the atomic path and by a worker
*> process and the two are equal byte for byte, and the cost of a chunk with the mineshaft decoration is measured against the same chunk with the structure off. The counts and
*> the times are printed as evidence (the mesa type stays refused: no base height).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-MS-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY GENQUEUE.
 COPY CELLS.
 COPY DIMENSIONS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-ON                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STARTS              BINARY-LONG.
 01 WS-FIRST-X             BINARY-LONG.
 01 WS-FIRST-Z             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WORKERS             BINARY-LONG VALUE 1.
 01 WS-SLEEP               PIC 9(2)V9(2) VALUE 0.05.
 01 WS-REF                 PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-REF2                PIC X(304640).
 01 WS-A                   PIC X(304640) BASED.
 01 WS-SAME                BINARY-LONG.
 01 WS-CLOCK               PIC X(21).
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-FAR-ON            BINARY-LONG.
 01 WS-FAR-OFF           BINARY-LONG.
 01 WS-ON-TOTAL            BINARY-LONG.
 01 WS-OFF-TOTAL           BINARY-LONG.
 01 WS-EDIT                PIC Z(7)9.
 01 WS-EDIT2               PIC Z(7)9.
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
         MOVE "test struct ms real no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     MOVE "minecraft:mineshaft" TO WS-KEY
     CALL "STRUCT-GATE" USING WS-KEY WS-ON
     MOVE "test struct ms real a standard world has the mineshaft gated on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ON TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:mineshaft_mesa" TO WS-KEY
     CALL "STRUCT-GATE" USING WS-KEY WS-ON
     MOVE "test struct ms real the mesa mineshaft stays off (no base height)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ON TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the starts of 24 x 24 chunks
     MOVE 0 TO WS-STARTS WS-FOUND
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     PERFORM VARYING WS-CX FROM -12 BY 1 UNTIL WS-CX > 11
         PERFORM VARYING WS-CZ FROM -12 BY 1 UNTIL WS-CZ > 11
             CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-CX WS-CZ WS-COUNT
             ADD WS-COUNT TO WS-STARTS
             IF WS-COUNT > 0 AND WS-FOUND = 0
                 MOVE 1 TO WS-FOUND
                 MOVE WS-CX TO WS-FIRST-X
                 MOVE WS-CZ TO WS-FIRST-Z
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-T1 = WS-T0 - WS-T1
     MOVE WS-T1 TO WS-EDIT2
     DISPLAY "PROBE 576 STRUCT-CHUNK-STARTS calls: " FUNCTION TRIM(WS-EDIT2) " ms"
     MOVE WS-STARTS TO WS-EDIT
     DISPLAY "PROBE mineshaft starts in 24x24 chunks (-12..11): " FUNCTION TRIM(WS-EDIT)
     MOVE "test struct ms real the 24 x 24 chunk area holds at least one mineshaft start" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STARTS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 0
         STOP RUN
     END-IF

*>   the atomic references; a chunk generated twice is faster the second time (the caches of the noises), so each chunk is first made once with the
*>   structure off (warm-up), then timed with it off and on
     MOVE "minecraft:mineshaft" TO WS-KEY
     MOVE WS-FIRST-X TO WS-CX
     MOVE WS-FIRST-Z TO WS-CZ
     PERFORM TIME-CHUNK
     MOVE WS-ON-TOTAL TO WS-EDIT
     MOVE WS-OFF-TOTAL TO WS-EDIT2
     DISPLAY "PROBE chunk of the first start: " FUNCTION TRIM(WS-EDIT) " ms with the mineshaft, " FUNCTION TRIM(WS-EDIT2) " ms without"
     MOVE "test struct ms real the mineshaft changes the chunk of its start" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-REF NOT = WS-REF2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-SAME FROM 1 BY 1 UNTIL WS-SAME > 3
         COMPUTE WS-CX = 50 + WS-SAME * 3
         MOVE 60 TO WS-CZ
         PERFORM TIME-CHUNK
         MOVE WS-ON-TOTAL TO WS-EDIT
         MOVE WS-OFF-TOTAL TO WS-EDIT2
         DISPLAY "PROBE chunk (" WS-CX ",60), no start near: " FUNCTION TRIM(WS-EDIT) " ms with the mineshaft, " FUNCTION TRIM(WS-EDIT2) " ms without"
     END-PERFORM

*>   the worker makes the same chunk
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-FIRST-X WS-FIRST-Z WS-REF WS-REF-Y
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-FIRST-X WS-FIRST-Z
     MOVE 0 TO WS-TICKS
     MOVE 0 TO WS-ROW
     PERFORM UNTIL WS-ROW > 0 OR WS-TICKS > 12000
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "C$SLEEP" USING WS-SLEEP
         CALL "WORLD-FIND" USING WS-DIM WS-FIRST-X WS-FIRST-Z WS-ROW
     END-PERFORM
     MOVE 0 TO WS-SAME
     IF WS-ROW > 0
         SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
         IF WS-A = WS-REF
             MOVE 1 TO WS-SAME
         END-IF
     END-IF
     MOVE WS-ROW TO WS-EDIT
     MOVE WS-TICKS TO WS-EDIT2
     DISPLAY "PROBE worker chunk row " FUNCTION TRIM(WS-EDIT) " after ticks " FUNCTION TRIM(WS-EDIT2)
     IF WS-ROW > 0 AND WS-SAME = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 304640 OR WS-A(WS-I:1) NOT = WS-REF(WS-I:1)
             CONTINUE
         END-PERFORM
         MOVE WS-I TO WS-EDIT
         DISPLAY "PROBE first difference at byte " FUNCTION TRIM(WS-EDIT)
     END-IF
     MOVE "test struct ms real the chunk of the first start from a worker equals the atomic chunk byte for byte" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     STOP RUN.

 TIME-CHUNK.
     CALL "STRUCT-GATE-RESET"
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF2 WS-REF-Y
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF2 WS-REF-Y
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-OFF-TOTAL = WS-T0 - WS-T1
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE WS-T0 TO WS-T1
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-ON-TOTAL = WS-T0 - WS-T1.

 CLOCK-MS.
     COMPUTE WS-T0 = FUNCTION NUMVAL(WS-CLOCK(9:2)) * 3600000 + FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60000
         + FUNCTION NUMVAL(WS-CLOCK(13:2)) * 1000 + FUNCTION NUMVAL(WS-CLOCK(15:2)) * 10.
 END PROGRAM TEST-STRUCT-MS-REAL.

 COPY CORETEST.
