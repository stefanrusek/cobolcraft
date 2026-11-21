*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-7-woodland-mansion.md section 3, the structure start): in a standard world of seed 12345 the first
*> chunk of a scan for each of the four rotations is started by MAN-FIND-POINT and compared with the rule rebuilt here from the text: the start random is seeded by setLargeFeatureSeed (step 1),
*> the position is (16 cx + 7, y0, 16 cz + 7) (step 2), the first draw is the rotation nextInt(4) (step 4), the four corners of the 5 by 5 box are turned by it (step 5: +5 +5, -5 +5, -5 -5, +5 -5
*> for NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90), y0 is the lowest surface (WORLD_SURFACE_WG height minus 1) of the four corners and at least 60 (step 6, so the start is valid),
*> and the grid and the layout are built from the same random after that one draw (step 7: generateMansion = MansionGrid, then the placer). The steps the loader cannot show: step 3 (the biome test
*> belongs to the caller's stub test) and step 6's refusal (a lowest corner under y 60 cannot occur, the heights never go below the sea level).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-7-3.
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
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-WANT-ROT            BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 4.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-SUM2                BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-CASE                PIC X(200).
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
         MOVE "acceptance US12 36-7§3 The structure start: no generated packs here, skipped" TO TL-CASE
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
     MOVE CW-SEED TO WS-SEED
     COMPUTE WS-USEED = FUNCTION MOD(WS-SEED + WS-M64, WS-M64)
     PERFORM VARYING WS-WANT-ROT FROM 0 BY 1 UNTIL WS-WANT-ROT > 3
*>       the first chunk of the scan along z = 40 whose rotation draw is the wanted one
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 400 OR WS-FOUND = 1
             MOVE 40 TO WS-CZ
             CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED WS-CX WS-CZ
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
             IF WS-ROT = WS-WANT-ROT
                 MOVE 1 TO WS-FOUND
                 SUBTRACT 1 FROM WS-CX
             END-IF
         END-PERFORM
         MOVE WS-WANT-ROT TO WS-ED
         MOVE SPACES TO WS-CASE
         STRING "acceptance US12 36-7§3 a chunk with the rotation draw " FUNCTION TRIM(WS-ED) " exists in the scan" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-FOUND TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-FOUND = 1
             PERFORM CHECK-START
         END-IF
     END-PERFORM
     STOP RUN.

*> CHECK-START: MAN-FIND-POINT of the chunk (WS-CX, WS-CZ) against the rule of the text
 CHECK-START.
     CALL "MAN-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE WS-WANT-ROT TO WS-ED
*>   steps 2 and 4: the position of the chunk's middle column and the rotation draw
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 36-7§3 rotation " FUNCTION TRIM(WS-ED) ": x = 16 cx + 7, z = 16 cz + 7 and the layout is turned by the first draw" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     COMPUTE TL-EXPECTED-N = (WS-CX * 16 + 7) * 10 + WS-WANT-ROT
     COMPUTE TL-OBSERVED-N = WS-X * 10 + MN-ROT
     IF WS-Z NOT = WS-CZ * 16 + 7
         ADD 1000000 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   step 5: the corners of the box, turned by the rotation
     MOVE 5 TO WS-DX
     MOVE 5 TO WS-DZ
     EVALUATE WS-WANT-ROT
         WHEN 1
             MOVE -5 TO WS-DX
         WHEN 2
             MOVE -5 TO WS-DX
             MOVE -5 TO WS-DZ
         WHEN 3
             MOVE -5 TO WS-DZ
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     COMPUTE WS-X2 = WS-X + WS-DX
     COMPUTE WS-Z2 = WS-Z + WS-DZ
     CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND WS-H
     COMPUTE WS-MIN = WS-H - 1
     CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z2 WS-KIND WS-H
     IF WS-H - 1 < WS-MIN
         COMPUTE WS-MIN = WS-H - 1
     END-IF
     CALL "STRUCT-BASE-HEIGHT" USING WS-X2 WS-Z WS-KIND WS-H
     IF WS-H - 1 < WS-MIN
         COMPUTE WS-MIN = WS-H - 1
     END-IF
     CALL "STRUCT-BASE-HEIGHT" USING WS-X2 WS-Z2 WS-KIND WS-H
     IF WS-H - 1 < WS-MIN
         COMPUTE WS-MIN = WS-H - 1
     END-IF
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 36-7§3 rotation " FUNCTION TRIM(WS-ED) ": y0 is the lowest WORLD_SURFACE_WG height minus 1 of the four turned corners" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-MIN TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   step 6: no start under y 60; the heights never are, so the start is valid
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 36-7§3 rotation " FUNCTION TRIM(WS-ED) ": y0 is 60 or more, so the start is valid" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-Y >= 60 AND WS-VALID = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the piece position is the start position with no height shift (step 7): the entrance is placed from (x, y0, z)
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 36-7§3 rotation " FUNCTION TRIM(WS-ED) ": the layout origin is the start position (x, y0, z), no moveInsideHeights" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION ABS(MN-OX - WS-X) + FUNCTION ABS(MN-OY - WS-Y) + FUNCTION ABS(MN-OZ - WS-Z)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   step 7: generateMansion draws the grid from the same random after the rotation draw: the base grid equals that of a fresh seeding, one draw and MNG-BUILD
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
         COMPUTE WS-SUM = FUNCTION MOD(WS-SUM * 7 + MN-CELL(1, WS-I), 999983)
     END-PERFORM
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED WS-CX WS-CZ
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
     CALL "MNG-BUILD"
     MOVE 0 TO WS-SUM2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
         COMPUTE WS-SUM2 = FUNCTION MOD(WS-SUM2 * 7 + MN-CELL(1, WS-I), 999983)
     END-PERFORM
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 36-7§3 rotation " FUNCTION TRIM(WS-ED) ": the grid is built from the structure-start random right after the rotation draw" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-SUM2 TO TL-EXPECTED-N
     MOVE WS-SUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-STRUCT-36-7-3.

 COPY NOSPAWN.
 COPY CORETEST.
