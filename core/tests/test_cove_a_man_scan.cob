*> Coverage of the woodland mansion start over many chunks (docs/protocol/36-structures-7 section 3; core/src/struct-man-start.cob MAN-FIND-POINT, struct-place.cob STRUCT-FIND-POINT; skipped as a pass without
*> the generated packs): the start of the structure row "minecraft:mansion" is asked of chunks of a row until every rotation has had a start and each of the box corners after the first has been the lowest one; every rotation 0 to 3 occurs among the valid starts (the box corners turned by it), the start's y is the lowest corner minus one, and a start leaves the whole layout as template pieces (no start is refused: the heights are never under the sea level).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-A-MAN-SCAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(80).
 01 WS-ON                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROWS-SEEN         BINARY-LONG OCCURS 4 TIMES.
 01 WS-USEED             BINARY-DOUBLE UNSIGNED.
 01 WS-M64               PIC 9(20) VALUE 18446744073709551616.
 01 WS-BOUND              BINARY-LONG VALUE 4.
 01 WS-ROT                BINARY-LONG.
 01 WS-FLAG-SEEN          BINARY-LONG OCCURS 3 TIMES.
 01 WS-SURFACE            BINARY-LONG VALUE 0.
 01 WS-DX                 BINARY-LONG.
 01 WS-DZ                 BINARY-LONG.
 01 WS-X2                 BINARY-LONG.
 01 WS-Z2                 BINARY-LONG.
 01 WS-H1                 BINARY-LONG.
 01 WS-H2                 BINARY-LONG.
 01 WS-H3                 BINARY-LONG.
 01 WS-H4                 BINARY-LONG.
 01 WS-LOW                BINARY-LONG.
 01 WS-NEW                BINARY-LONG.
 01 WS-F2                 BINARY-LONG.
 01 WS-F3                 BINARY-LONG.
 01 WS-F4                 BINARY-LONG.
 01 WS-STRUCT-ROW         BINARY-LONG.
 01 WS-ACCEPTED           BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
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
         MOVE "test cove a man scan no generated packs here, skipped" TO TL-CASE
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
     MOVE "minecraft:mansion" TO WS-KEY
     MOVE 0 TO WS-STRUCT-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-STRUCT-ROW
         END-IF
     END-PERFORM
     MOVE "test cove a man scan the mansion structure row exists" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STRUCT-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-STRUCT-ROW = 0
         STOP RUN
     END-IF
     MOVE CW-SEED TO WS-SEED
     MOVE 0 TO WS-BAD WS-ACCEPTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO WS-ROWS-SEEN(WS-I)
     END-PERFORM
     MOVE 0 TO WS-FLAG-SEEN(1) WS-FLAG-SEEN(2) WS-FLAG-SEEN(3)
     MOVE 40 TO WS-CZ
     MOVE 0 TO WS-CX
     COMPUTE WS-USEED = FUNCTION MOD(WS-SEED + WS-M64, WS-M64)
     PERFORM UNTIL WS-CX > 399 OR (WS-ROWS-SEEN(1) > 0 AND WS-ROWS-SEEN(2) > 0 AND WS-ROWS-SEEN(3) > 0 AND WS-ROWS-SEEN(4) > 0
             AND WS-FLAG-SEEN(1) > 0 AND WS-FLAG-SEEN(2) > 0 AND WS-FLAG-SEEN(3) > 0)
*>       the rotation of the chunk's start is drawn first (a cheap Java LCG) and the four corner heights of the box are read in the order of the start (36-7 section 3 step 5): the start itself (which
*>       builds a whole mansion) is only asked for while it adds a rotation or a corner order not yet seen
         CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED WS-CX WS-CZ
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
         MOVE 5 TO WS-DX WS-DZ
         EVALUATE WS-ROT
             WHEN 1
                 MOVE -5 TO WS-DX
             WHEN 2
                 MOVE -5 TO WS-DX WS-DZ
             WHEN 3
                 MOVE -5 TO WS-DZ
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
         COMPUTE WS-X = WS-CX * 16 + 7
         COMPUTE WS-Z = WS-CZ * 16 + 7
         COMPUTE WS-X2 = WS-X + WS-DX
         COMPUTE WS-Z2 = WS-Z + WS-DZ
         CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-SURFACE WS-H1
         CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z2 WS-SURFACE WS-H2
         CALL "STRUCT-BASE-HEIGHT" USING WS-X2 WS-Z WS-SURFACE WS-H3
         CALL "STRUCT-BASE-HEIGHT" USING WS-X2 WS-Z2 WS-SURFACE WS-H4
         COMPUTE WS-LOW = WS-H1 - 1
         MOVE 0 TO WS-NEW WS-F2 WS-F3 WS-F4
         IF WS-H2 - 1 < WS-LOW
             COMPUTE WS-LOW = WS-H2 - 1
             MOVE 1 TO WS-F2
         END-IF
         IF WS-H3 - 1 < WS-LOW
             COMPUTE WS-LOW = WS-H3 - 1
             MOVE 1 TO WS-F3
         END-IF
         IF WS-H4 - 1 < WS-LOW
             COMPUTE WS-LOW = WS-H4 - 1
             MOVE 1 TO WS-F4
         END-IF
         COMPUTE WS-I = WS-ROT + 1
         IF WS-ROWS-SEEN(WS-I) = 0 OR (WS-F2 = 1 AND WS-FLAG-SEEN(1) = 0) OR (WS-F3 = 1 AND WS-FLAG-SEEN(2) = 0) OR (WS-F4 = 1 AND WS-FLAG-SEEN(3) = 0)
             CALL "STRUCT-FIND-POINT" USING WS-STRUCT-ROW WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
             ADD 1 TO WS-ACCEPTED
             ADD 1 TO WS-ROWS-SEEN(WS-I)
             IF WS-F2 = 1
                 ADD 1 TO WS-FLAG-SEEN(1)
             END-IF
             IF WS-F3 = 1
                 ADD 1 TO WS-FLAG-SEEN(2)
             END-IF
             IF WS-F4 = 1
                 ADD 1 TO WS-FLAG-SEEN(3)
             END-IF
             IF WS-VALID NOT = 1 OR SP-COUNT NOT = MN-COUNT OR SP-COUNT = 0 OR WS-Y NOT = WS-LOW OR MN-CROT(1) NOT = WS-ROT
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
         ADD 1 TO WS-CX
     END-PERFORM
     DISPLAY "PROBE mansion scan asked " WS-ACCEPTED " of " WS-CX " chunks, rotations " WS-ROWS-SEEN(1) " " WS-ROWS-SEEN(2) " " WS-ROWS-SEEN(3) " " WS-ROWS-SEEN(4)
             " corners " WS-FLAG-SEEN(1) " " WS-FLAG-SEEN(2) " " WS-FLAG-SEEN(3)
     MOVE "test cove a man scan each start is valid, whole, as low as its lowest corner minus one and turned by the drawn rotation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE "test cove a man scan every rotation occurs among the valid starts" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-ROWS-SEEN(WS-I) > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE "test cove a man scan each of the three later corners was the lowest of some start" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-FLAG-SEEN(WS-I) > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-COVE-A-MAN-SCAN.

 COPY CORETEST.
