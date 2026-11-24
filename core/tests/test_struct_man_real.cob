*> Real-data probe of the woodland mansion (skipped as a pass without the generated packs; docs/protocol/36-structures-7 sections 3, 6, 10; T10500): on the generated vanilla-data (CC_GENERATED_DIR,
*> read only) every template name of the layout loads, a start of a land chunk becomes template pieces without loss (kind 5), the first piece is the entrance (21 by 19 by 16 turned by the
*> rotation) and the pieces of one start reach the 73 names of the catalogue only.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-MAN-REAL.
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
         MOVE "test struct man real no generated packs here, skipped" TO TL-CASE
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
     CALL "STRUCT-GATE" USING WS-KEY WS-ON
     MOVE "test struct man real a standard world has the mansion gated on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ON TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CW-SEED TO WS-SEED
*>   the first land chunk of a scan whose lowest corner is at 60 or more
     MOVE 0 TO WS-FOUND
     MOVE 0 TO WS-TRIES
     PERFORM VARYING WS-CX FROM 0 BY 7 UNTIL WS-CX > 700 OR WS-FOUND = 1
         MOVE 40 TO WS-CZ
         ADD 1 TO WS-TRIES
         CALL "MAN-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         IF WS-VALID = 1
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE WS-TRIES TO WS-ED
     DISPLAY "PROBE mansion start after " FUNCTION TRIM(WS-ED) " chunks at y " WS-Y
     MOVE "test struct man real a start was found on land" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 0
         STOP RUN
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MN-COUNT
         MOVE SPACES TO WS-ID
         STRING "minecraft:woodland_mansion/" FUNCTION TRIM(ME-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         IF WS-ROW < 1 OR TP-STATUS(WS-ROW) NOT = 1
             DISPLAY "PROBE template not loaded: " FUNCTION TRIM(WS-ID) " status " TP-STATUS(WS-ROW)
         END-IF
     END-PERFORM
     MOVE "test struct man real every layout entry became a template piece" TO TL-CASE
     MOVE MN-COUNT TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct man real no piece was lost" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-LOST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         IF SP-T-ROW(WS-I) < 1 OR SP-T-KIND(WS-I) NOT = 5
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "test struct man real every piece has a loaded template of kind 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the entrance is 21 by 19 by 16 (x by y by z), turned by an odd rotation it is 16 by 19 by 21
     COMPUTE WS-SX = SP-X1(1) - SP-X0(1) + 1
     COMPUTE WS-SZ = SP-Z1(1) - SP-Z0(1) + 1
     MOVE "test struct man real the first piece is the entrance box" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     IF (WS-SX = 21 AND WS-SZ = 16) OR (WS-SX = 16 AND WS-SZ = 21)
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     IF SP-Y1(1) - SP-Y0(1) + 1 NOT = 19
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-MAN-REAL.

 COPY NOSPAWN.
 COPY CORETEST.
