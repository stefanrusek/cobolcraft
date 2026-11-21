*> Real-data probe of the stronghold (skipped as a pass without the generated packs; docs/protocol/36-structures-5 section 3; 36-1 sections 5 and 7; T10001): on the generated vanilla-data
*> (CC_GENERATED_DIR, read only) the standard world has the stronghold gated on by WORLD-GEN-DATA-OPEN. The nearest ring chunk of the world seed (the locate of the eye of ender) is the chunk
*> of a start; that chunk is generated whole by the atomic path with and without the structure and by a worker process, the worker chunk equals the atomic chunk byte for byte, and the
*> costs are printed as evidence.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-SH-REAL.
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
 01 WS-NAME                PIC X(40).
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
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
         MOVE "test struct sh real no generated packs here, skipped" TO TL-CASE
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
     MOVE "minecraft:stronghold" TO WS-KEY
     CALL "STRUCT-GATE" USING WS-KEY WS-ON
     MOVE "test struct sh real a standard world has the stronghold gated on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ON TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the nearest ring chunk of the seed from the origin: the chunk of a start
     MOVE "strongholds" TO WS-NAME
     MOVE 0 TO WS-OX WS-OY WS-OZ
     CALL "STRUCT-NEAREST-NAMED" USING WS-NAME CW-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-FIRST-X WS-FIRST-Z WS-LX WS-LY WS-LZ
     MOVE WS-FOUND TO WS-STARTS
     MOVE WS-FIRST-X TO WS-EDIT
     MOVE WS-FIRST-Z TO WS-EDIT2
     DISPLAY "PROBE nearest stronghold chunk: " FUNCTION TRIM(WS-EDIT) "," FUNCTION TRIM(WS-EDIT2)
     MOVE "test struct sh real the ring list has a stronghold chunk" TO TL-CASE
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
     MOVE "minecraft:stronghold" TO WS-KEY
     MOVE WS-FIRST-X TO WS-CX
     MOVE WS-FIRST-Z TO WS-CZ
     PERFORM TIME-CHUNK
     MOVE WS-ON-TOTAL TO WS-EDIT
     MOVE WS-OFF-TOTAL TO WS-EDIT2
     DISPLAY "PROBE chunk of the first start: " FUNCTION TRIM(WS-EDIT) " ms with the stronghold, " FUNCTION TRIM(WS-EDIT2) " ms without"
     MOVE "test struct sh real the stronghold changes the chunk of its start" TO TL-CASE
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
         DISPLAY "PROBE chunk (" WS-CX ",60), no start near: " FUNCTION TRIM(WS-EDIT) " ms with the stronghold, " FUNCTION TRIM(WS-EDIT2) " ms without"
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
     MOVE "test struct sh real the chunk of the first start from a worker equals the atomic chunk byte for byte" TO TL-CASE
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
 END PROGRAM TEST-STRUCT-SH-REAL.

 COPY NOSPAWN.
 COPY CORETEST.
