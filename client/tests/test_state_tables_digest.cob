*> Equivalence test (lane perfsteady): STATE-TABLES-BUILD over the standard block table (every state of the set, about 30 000 through CONTENT-BLOCK-OF-STATE, whose answer was a binary search over text rows
*> a state, and the rule strings of the block searched again for every state) holds the same tables after the lane's change that it held before: the CRC-32 of the whole ST-STATE group (opacity, block, block names,
*> fluid, level, overlay, shape, likeness, the face classes of every state and the cover table) is the value taken from the code before the change. The build is timed (CPU, clock()).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STATE-TABLES-DIGEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-CRC                 BINARY-DOUBLE UNSIGNED.
 01 WS-ZERO                BINARY-DOUBLE VALUE 0.
 01 WS-PTR                 USAGE POINTER.
 01 WS-LEN                 BINARY-DOUBLE.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-E                   PIC Z(19)9.
 01 WS-EXPECT              PIC X(24) VALUE "1884831894".
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     CALL STATIC "clock" RETURNING WS-T0
     CALL "STATE-TABLES-BUILD" USING CLIENT-STATE
     CALL STATIC "clock" RETURNING WS-T1
     COMPUTE WS-US = WS-T1 - WS-T0
     SET WS-PTR TO ADDRESS OF ST-STATE
     MOVE FUNCTION BYTE-LENGTH(ST-STATE) TO WS-LEN
     CALL STATIC "crc32" USING BY VALUE WS-ZERO BY VALUE WS-PTR BY VALUE WS-LEN RETURNING WS-CRC
     MOVE WS-CRC TO WS-E
     DISPLAY "DIGEST state tables " FUNCTION TRIM(WS-E)
     MOVE WS-US TO WS-E
     DISPLAY "PERF STATE-TABLES-BUILD us " FUNCTION TRIM(WS-E)
     MOVE "T" TO TL-MODE
     MOVE "perfsteady: the state tables of the standard set are those taken before the change (CRC-32 of ST-STATE)" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     MOVE WS-CRC TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STATE-TABLES-DIGEST.
