*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-3-jigsaw-assembly.md section 8, the structure type JigsawStructure, findGenerationPoint 8.2): the draws
*> and the start position, checked against the start random drawn here from setLargeFeatureSeed (JRAND-LARGE-FEATURE-SEED) and not against the assembler. For the trial chambers (a uniform start
*> height from -40 to -20) the first draw of the start random is nextInt(21), the stub's y is -40 plus it (8.2 step 2) and the second draw is the start piece's rotation nextInt(4) (9.1); for the
*> ancient city (an absolute height) the first draw is the rotation. The start position is the south-west corner of the start chunk (8.2 step 3): the plains village's start piece has its origin at
*> (16 cx, y, 16 cz) and the named jigsaw of the ancient city's start piece lies on x = 16 cx and z = 16 cz. The structure's fields (8.1) are the ones of 3.1 (test_struct_36_3_3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-3-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 COPY JIGTEST.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CITY                BINARY-LONG.
 01 WS-TRIAL               BINARY-LONG.
 01 WS-PLAINS              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DRAW2               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ED1                 PIC -(9)9.
 01 WS-ED2                 PIC -(9)9.
 01 WS-CHUNKS.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -2.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE -4.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE -7.
    05 FILLER BINARY-LONG VALUE -11.
    05 FILLER BINARY-LONG VALUE 6.
 01 WS-CHUNK-TAB REDEFINES WS-CHUNKS.
    05 WC-REC OCCURS 6 TIMES.
       10 WC-CX            BINARY-LONG.
       10 WC-CZ            BINARY-LONG.
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
         MOVE "acceptance US12 36-3§8 The structure type JigsawStructure: no generated packs here, skipped" TO TL-CASE
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
     CALL "GEN-WORLD-SETUP"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         EVALUATE SDT-KEY(WS-I)
             WHEN "minecraft:ancient_city"
                 MOVE WS-I TO WS-CITY
             WHEN "minecraft:trial_chambers"
                 MOVE WS-I TO WS-TRIAL
             WHEN "minecraft:village_plains"
                 MOVE WS-I TO WS-PLAINS
         END-EVALUATE
     END-PERFORM
     CALL "JIG-RESET"
     MOVE 1 TO TJ-SURFACE
     COMPUTE WS-USEED = FUNCTION MOD(CW-SEED + WS-M64, WS-M64)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE WC-CX(WS-K) TO WS-CX
         MOVE WC-CZ(WS-K) TO WS-CZ
         MOVE WS-CX TO WS-ED1
         MOVE WS-CZ TO WS-ED2
*>       the two first draws of the start random of the chunk
         CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED WS-CX WS-CZ
         MOVE 21 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         MOVE 4 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW2
         CALL "STRUCT-FIND-POINT" USING WS-TRIAL CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-3§8.2 trial chambers chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) ": the stub y is -40 + nextInt(21), the first draw (uniform start height)"
             DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = -40 + WS-DRAW
         MOVE WS-Y TO TL-OBSERVED-N
         IF WS-VALID NOT = 1
             MOVE 99999 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-3§9.1 trial chambers chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) ": the start piece's rotation is the next draw nextInt(4)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-DRAW2 TO TL-EXPECTED-N
         MOVE SP-T-ROT(1) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       the ancient city: no height draw, the rotation is the first draw; the named jigsaw is on the start column
         CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED WS-CX WS-CZ
         MOVE 4 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         CALL "STRUCT-FIND-POINT" USING WS-CITY CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-3§8.2 ancient city chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) ": the first draw is the rotation (an absolute height draws nothing)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-DRAW TO TL-EXPECTED-N
         MOVE SP-T-ROT(1) TO TL-OBSERVED-N
         IF WS-VALID NOT = 1
             MOVE 99999 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SP-F1(1) TO WS-ROW
         CALL "JIG-EL-JIGS" USING WS-ROW SP-T-X(1) SP-T-Y(1) SP-T-Z(1) SP-T-ROT(1)
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JW-COUNT
             MOVE JW-TAG(WS-I) TO WS-TAG
             IF WS-TAG > 0
                 IF TN-NAME(WS-TAG) = "minecraft:city_anchor"
                     IF JW-X(WS-I) = WS-CX * 16 AND JW-Z(WS-I) = WS-CZ * 16
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-3§8.2 ancient city chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2)
             ": the start position is the south-west corner of the chunk: the city_anchor jigsaw lies on (16 cx, 16 cz)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       the plains village without a start jigsaw name: the origin is the corner
         CALL "STRUCT-FIND-POINT" USING WS-PLAINS CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-3§8.2 village_plains chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2)
             ": the start piece's origin x and z are the chunk's minimum corner (16 cx, 16 cz)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = FUNCTION ABS(SP-T-X(1) - WS-CX * 16) + FUNCTION ABS(SP-T-Z(1) - WS-CZ * 16)
         IF WS-VALID NOT = 1
             MOVE 99999 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 0 TO TJ-SURFACE
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-3-8.

 COPY JIGSEAM.

 COPY NOSPAWN.
 COPY CORETEST.
