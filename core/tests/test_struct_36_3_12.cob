*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-3-jigsaw-assembly.md section 9, JigsawPlacement.addPieces and 8.2): the start of the assembly. The
*> ancient city (start_jigsaw_name city_anchor, absolute start height -27, no heightmap: 9.3, 9.4 worked example, 9.6) and the trial chambers (uniform start height, pool aliases, dimension padding
*> 10: 8.2, 7, 9.5) are assembled for world seed 12345 over the synthetic surface of TJ-SURFACE and compared with core/tests/fixtures/gen_jigsaw.py --digest (an independent model of the text):
*> the stub position, the first piece's origin and box, the piece and junction counts and a digest of every piece (origin, rotation, box, ground level delta, projection) and junction. Then the
*> rules of 9 on edited structure rows: the named jigsaw lies on the start position before the move and ends at y -28 (the worked example), a start jigsaw name no jigsaw has gives no structure,
*> a decoded dimension padding too large for the piece gives none while an absent one is never checked, the start pool of an alias is the one that is used and an alias to a missing pool falls
*> back to the structure's own pool (9.2 step 1), and size 0 gives none (9.7 step 1).
*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-3-jigsaw-assembly.md section 12, projection, ground level and junctions): the consequences of the
*> table of 12.1 and of 12.2 and 12.3 on whole assemblies (world seed 12345, the synthetic surface of TJ-SURFACE): the plains village, the pillager outpost, the ancient city and the trial
*> chambers. The junctions come in pairs, the parent's then the child's: the child's delta is the negative of the parent's, each holds the other piece's projection as its destination (12.3), a
*> child's ground level delta is its parent's minus d for a rigid child and 1 for a terrain_matching one (12.1, 12.2), the start piece's is 1, and a terrain_matching piece's is 1 (12.2). The
*> junction positions and ground heights themselves are the digest of test_struct_36_3_9 and test_struct_jigsaw (gen_jigsaw.py).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-3-12.
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
 01 WS-K                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-M1                  BINARY-LONG VALUE 0.
 01 WS-M2                  BINARY-LONG VALUE 0.
 01 WS-M3                  BINARY-LONG VALUE 0.
 01 WS-M4                  BINARY-LONG VALUE 0.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-PAR                 BINARY-LONG.
 01 WS-CHD                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BAD-DELTA           BINARY-LONG.
 01 WS-BAD-PROJ            BINARY-LONG.
 01 WS-BAD-GROUND          BINARY-LONG.
 01 WS-BAD-TM              BINARY-LONG.
 01 WS-PAIRS               BINARY-LONG.
 01 WS-ODD                 BINARY-LONG.
 01 WS-MIX                 BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-LABEL               PIC X(40).
 01 WS-CASE-TAB.
    05 FILLER PIC X(24) VALUE "village_plains".
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER PIC X(24) VALUE "pillager_outpost".
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE -2.
    05 FILLER PIC X(24) VALUE "ancient_city".
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER PIC X(24) VALUE "trial_chambers".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
 01 WS-CASES REDEFINES WS-CASE-TAB.
    05 WC-REC OCCURS 4 TIMES.
       10 WC-NAME          PIC X(24).
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
         MOVE "acceptance US12 36-3§12 Projection, ground level, junctions: no generated packs here, skipped" TO TL-CASE
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
     CALL "JIG-RESET"
     MOVE 1 TO TJ-SURFACE
     MOVE 0 TO WS-MIX
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE SPACES TO WS-NAME
         STRING "minecraft:" FUNCTION TRIM(WC-NAME(WS-K)) DELIMITED BY SIZE INTO WS-NAME
         MOVE 0 TO WS-STRUCT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
             IF SDT-KEY(WS-I) = WS-NAME
                 MOVE WS-I TO WS-STRUCT
             END-IF
         END-PERFORM
         MOVE WC-CX(WS-K) TO WS-CX
         MOVE WC-CZ(WS-K) TO WS-CZ
         CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         MOVE WC-NAME(WS-K) TO WS-LABEL
         PERFORM CHECK-PAIRS
     END-PERFORM
     MOVE 0 TO TJ-SURFACE
     MOVE "acceptance US12 36-3§12.1 the four assemblies together hold rigid and terrain_matching pieces both as parents and as children (the table's four rows are reached)" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-MIX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> CHECK-PAIRS: the junction pairs of the assembly in the builder; WS-MIX collects the (parent, child) projection combinations seen as bits 1, 2, 4, 8
 CHECK-PAIRS.
     MOVE 0 TO WS-BAD-DELTA WS-BAD-PROJ WS-BAD-GROUND WS-BAD-TM
     COMPUTE WS-PAIRS = JJ-COUNT / 2
     COMPUTE WS-ODD = JJ-COUNT - WS-PAIRS * 2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-PAIRS
         PERFORM CHECK-PAIR
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         IF SP-T-AUX(WS-I) = 1 AND SP-F2(WS-I) NOT = 1
             ADD 1 TO WS-BAD-TM
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-3§12.3 " FUNCTION TRIM(WS-LABEL) ": junctions come in pairs, the child's delta is minus the parent's" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BAD-DELTA + WS-ODD
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-3§12.3 " FUNCTION TRIM(WS-LABEL) ": each junction's destination projection is the other piece's projection" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-PROJ TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-3§12.1 " FUNCTION TRIM(WS-LABEL) ": a rigid child's ground level delta is its parent's minus d, a terrain_matching child's is 1" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-GROUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-3§12.2 " FUNCTION TRIM(WS-LABEL) ": the start piece's ground level delta is 1, and a terrain_matching piece's is 1" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BAD-TM + 1
     IF SP-F2(1) NOT = 1
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
*> CHECK-PAIR: the pair WS-I (rows 2 * WS-I - 1 and 2 * WS-I)
 CHECK-PAIR.
     COMPUTE WS-PAR = WS-I * 2 - 1
     COMPUTE WS-CHD = WS-I * 2
     IF JJ-DELTA(WS-CHD) NOT = 0 - JJ-DELTA(WS-PAR)
         ADD 1 TO WS-BAD-DELTA
     END-IF
     MOVE JJ-OWNER(WS-PAR) TO WS-D
     MOVE JJ-OWNER(WS-CHD) TO WS-WANT
     IF JJ-PROJ(WS-PAR) NOT = SP-T-AUX(WS-WANT) OR JJ-PROJ(WS-CHD) NOT = SP-T-AUX(WS-D)
         ADD 1 TO WS-BAD-PROJ
     END-IF
     EVALUATE SP-T-AUX(WS-D) * 2 + SP-T-AUX(WS-WANT)
         WHEN 0
             MOVE 1 TO WS-M1
         WHEN 1
             MOVE 2 TO WS-M2
         WHEN 2
             MOVE 4 TO WS-M3
         WHEN OTHER
             MOVE 8 TO WS-M4
     END-EVALUATE
     COMPUTE WS-MIX = WS-M1 + WS-M2 + WS-M3 + WS-M4
     IF SP-T-AUX(WS-WANT) = 0
         COMPUTE WS-G = SP-F2(WS-D) - JJ-DELTA(WS-PAR)
     ELSE
         MOVE 1 TO WS-G
     END-IF
     IF SP-F2(WS-WANT) NOT = WS-G
         ADD 1 TO WS-BAD-GROUND
     END-IF
     .
 END PROGRAM TEST-STRUCT-36-3-12.

 COPY JIGSEAM.

 COPY NOSPAWN.
 COPY CORETEST.
