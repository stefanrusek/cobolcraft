*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-3-jigsaw-assembly.md section 9, JigsawPlacement.addPieces and 8.2): the start of the assembly. The
*> ancient city (start_jigsaw_name city_anchor, absolute start height -27, no heightmap: 9.3, 9.4 worked example, 9.6) and the trial chambers (uniform start height, pool aliases, dimension padding
*> 10: 8.2, 7, 9.5) are assembled for world seed 12345 over the synthetic surface of TJ-SURFACE and compared with core/tests/fixtures/gen_jigsaw.py --digest (an independent model of the text):
*> the stub position, the first piece's origin and box, the piece and junction counts and a digest of every piece (origin, rotation, box, ground level delta, projection) and junction. Then the
*> rules of 9 on edited structure rows: the named jigsaw lies on the start position before the move and ends at y -28 (the worked example), a start jigsaw name no jigsaw has gives no structure,
*> a decoded dimension padding too large for the piece gives none while an absent one is never checked, the start pool of an alias is the one that is used and an alias to a missing pool falls
*> back to the structure's own pool (9.2 step 1), and size 0 gives none (9.7 step 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-3-9.
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
 COPY JSONDOC.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CITY                BINARY-LONG.
 01 WS-TRIAL               BINARY-LONG.
 01 WS-PLAINS              BINARY-LONG.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-M                   BINARY-LONG VALUE 1000000007.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-STUB                BINARY-LONG.
 01 WS-NP                  BINARY-LONG.
 01 WS-NJ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ED1                 PIC -(9)9.
 01 WS-ED2                 PIC -(9)9.
 01 WS-LABEL               PIC X(80).
 01 WS-CASE                PIC X(240).
 01 WS-NAME                PIC X(96).
 01 WS-SAVE-NAMED          BINARY-LONG.
 01 WS-SAVE-NAME           PIC X(80).
 01 WS-SAVE-PADSET         BINARY-LONG.
 01 WS-SAVE-PADB           BINARY-LONG.
 01 WS-SAVE-PADT           BINARY-LONG.
 01 WS-SAVE-SIZE           BINARY-LONG.
 01 WS-SAVE-ALF            BINARY-LONG.
 01 WS-SAVE-ALN            BINARY-LONG.
 01 WS-SAVE-ALC            BINARY-LONG.
 01 WS-ANCHOR-Y            BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-TEXT                PIC X(1200).
 01 WS-LEN                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CASES.
    05 FILLER PIC X(24) VALUE "ancient_city".
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 95.
    05 FILLER BINARY-LONG VALUE 188.
    05 FILLER BINARY-LONG VALUE 22037331.
    05 FILLER BINARY-LONG VALUE 48.
    05 FILLER BINARY-LONG VALUE -27.
    05 FILLER BINARY-LONG VALUE 68.
    05 FILLER PIC X(24) VALUE "ancient_city".
    05 FILLER BINARY-LONG VALUE -9.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 98.
    05 FILLER BINARY-LONG VALUE 194.
    05 FILLER BINARY-LONG VALUE 576584207.
    05 FILLER BINARY-LONG VALUE -139.
    05 FILLER BINARY-LONG VALUE -27.
    05 FILLER BINARY-LONG VALUE 80.
    05 FILLER PIC X(24) VALUE "trial_chambers".
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 287.
    05 FILLER BINARY-LONG VALUE 572.
    05 FILLER BINARY-LONG VALUE 203397520.
    05 FILLER BINARY-LONG VALUE -9.
    05 FILLER BINARY-LONG VALUE -21.
    05 FILLER BINARY-LONG VALUE -9.
    05 FILLER PIC X(24) VALUE "trial_chambers".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -2.
    05 FILLER BINARY-LONG VALUE 240.
    05 FILLER BINARY-LONG VALUE 478.
    05 FILLER BINARY-LONG VALUE 23423363.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE -23.
    05 FILLER BINARY-LONG VALUE -41.
    05 FILLER PIC X(24) VALUE "trial_chambers".
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 285.
    05 FILLER BINARY-LONG VALUE 568.
    05 FILLER BINARY-LONG VALUE 877552409.
    05 FILLER BINARY-LONG VALUE 71.
    05 FILLER BINARY-LONG VALUE -35.
    05 FILLER BINARY-LONG VALUE 89.
    05 FILLER PIC X(24) VALUE "trial_chambers".
    05 FILLER BINARY-LONG VALUE -4.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 270.
    05 FILLER BINARY-LONG VALUE 538.
    05 FILLER BINARY-LONG VALUE 458433270.
    05 FILLER BINARY-LONG VALUE -73.
    05 FILLER BINARY-LONG VALUE -25.
    05 FILLER BINARY-LONG VALUE 39.
 01 WS-CASE-TAB REDEFINES WS-CASES.
    05 WC-REC OCCURS 6 TIMES.
       10 WC-NAME          PIC X(24).
       10 WC-CX            BINARY-LONG.
       10 WC-CZ            BINARY-LONG.
       10 WC-NP            BINARY-LONG.
       10 WC-NJ            BINARY-LONG.
       10 WC-DIGEST        BINARY-LONG.
       10 WC-SX            BINARY-LONG.
       10 WC-SY            BINARY-LONG.
       10 WC-SZ            BINARY-LONG.
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
         MOVE "acceptance US12 36-3§9 Starting the assembly: no generated packs here, skipped" TO TL-CASE
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
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 6
         PERFORM MODEL-CASE
     END-PERFORM
     PERFORM TRIAL-PREFIX
     PERFORM WORKED-EXAMPLE
     PERFORM EDIT-CASES
     MOVE 0 TO TJ-SURFACE
     STOP RUN.

*> MODEL-CASE: the case row WS-ROW built and compared with the model's counts, stub, first piece and digest
 MODEL-CASE.
     MOVE SPACES TO WS-NAME
     STRING "minecraft:" FUNCTION TRIM(WC-NAME(WS-ROW)) DELIMITED BY SIZE INTO WS-NAME
     MOVE 0 TO WS-STRUCT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-NAME
             MOVE WS-I TO WS-STRUCT
         END-IF
     END-PERFORM
     MOVE WC-CX(WS-ROW) TO WS-CX
     MOVE WC-CZ(WS-ROW) TO WS-CZ
     MOVE WS-CX TO WS-ED1
     MOVE WS-CZ TO WS-ED2
     MOVE SPACES TO WS-LABEL
     STRING FUNCTION TRIM(WC-NAME(WS-ROW)) " chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO WS-LABEL
     CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-3§9 " FUNCTION TRIM(WS-LABEL) ": a start exists (and, where the model's counts are given, has its piece and junction counts)" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-EXPECTED-N = WC-NP(WS-ROW) * 10000 + WC-NJ(WS-ROW) + 1000000000
     IF WC-NP(WS-ROW) = 0
         MOVE 1000000000 TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = WS-VALID * 1000000000
     ELSE
         COMPUTE TL-OBSERVED-N = SP-COUNT * 10000 + JJ-COUNT + WS-VALID * 1000000000
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-3§9.6 " FUNCTION TRIM(WS-LABEL) ": the stub is (centre x, y plus the jigsaw's offset, centre z) of the model" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION ABS(WS-X - WC-SX(WS-ROW)) + FUNCTION ABS(WS-Y - WC-SY(WS-ROW)) + FUNCTION ABS(WS-Z - WC-SZ(WS-ROW))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-HASH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         MOVE SP-T-X(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-T-Y(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-T-Z(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-T-ROT(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-X0(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-Y0(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-Z0(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-X1(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-Y1(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-Z1(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-F2(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE SP-T-AUX(WS-I) TO WS-V
         PERFORM ADD-HASH
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JJ-COUNT
         MOVE JJ-OWNER(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE JJ-X(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE JJ-Y(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE JJ-Z(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE JJ-DELTA(WS-I) TO WS-V
         PERFORM ADD-HASH
         MOVE JJ-PROJ(WS-I) TO WS-V
         PERFORM ADD-HASH
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-3§9 " FUNCTION TRIM(WS-LABEL) ": every piece (origin, rotation, box, ground level delta, projection) and junction equals the model's (digest)"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE WC-DIGEST(WS-ROW) TO TL-EXPECTED-N
     MOVE WS-HASH TO TL-OBSERVED-N
     IF WC-NP(WS-ROW) = 0
         MOVE 0 TO TL-EXPECTED-N TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 ADD-HASH.
     COMPUTE WS-HASH = FUNCTION MOD(WS-HASH * 31 + FUNCTION MOD(WS-V, WS-M), WS-M)
     .

*> the first five pieces of the trial chambers at chunk (0, 0), against the model (element, origin, rotation): the uniform start height, the aliased expansion and the padding agree up to here
 TRIAL-PREFIX.
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "STRUCT-FIND-POINT" USING WS-TRIAL CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE SP-F1(WS-I) TO WS-ROW
         MOVE JE-LOC(WS-ROW) TO WS-NAME
         EVALUATE WS-I
             WHEN 1
                 IF WS-NAME(1:40) NOT = "minecraft:trial_chambers/corridor/end_2" OR SP-T-X(WS-I) NOT = 0 OR SP-T-Y(WS-I) NOT = -22
                    OR SP-T-Z(WS-I) NOT = 0 OR SP-T-ROT(WS-I) NOT = 2
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 2
                 IF WS-NAME(1:40) NOT = "minecraft:trial_chambers/chamber/slanted" OR SP-T-X(WS-I) NOT = 5 OR SP-T-Y(WS-I) NOT = -21
                    OR SP-T-Z(WS-I) NOT = -19 OR SP-T-ROT(WS-I) NOT = 2
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 3
                 IF WS-NAME(1:50) NOT = "minecraft:trial_chambers/corridor/second_plate" OR SP-T-X(WS-I) NOT = 0 OR SP-T-Y(WS-I) NOT = -22
                    OR SP-T-Z(WS-I) NOT = 20 OR SP-T-ROT(WS-I) NOT = 2
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 4
                 IF WS-NAME(1:50) NOT = "minecraft:trial_chambers/reward/ominous_vault" OR SP-T-X(WS-I) NOT = -8 OR SP-T-Y(WS-I) NOT = -21
                    OR SP-T-Z(WS-I) NOT = -15 OR SP-T-ROT(WS-I) NOT = 2
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN OTHER
                 IF WS-NAME(1:40) NOT = "minecraft:trial_chambers/reward/vault" OR SP-T-X(WS-I) NOT = -11 OR SP-T-Y(WS-I) NOT = -8
                    OR SP-T-Z(WS-I) NOT = -10 OR SP-T-ROT(WS-I) NOT = 1
                     ADD 1 TO WS-BAD
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US12 36-3§9 trial_chambers chunk 0,0: the first five pieces (element, origin, rotation) are the model's" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> 9.4's worked example: the named jigsaw lies on pos before the move, ends at y -28 (the start jigsaw's y -27, less the ground level delta 1)
 WORKED-EXAMPLE.
     MOVE 3 TO WS-CX
     MOVE 4 TO WS-CZ
     CALL "STRUCT-FIND-POINT" USING WS-CITY CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE SP-F1(1) TO WS-ROW
     CALL "JIG-EL-JIGS" USING WS-ROW SP-T-X(1) SP-T-Y(1) SP-T-Z(1) SP-T-ROT(1)
     MOVE 0 TO WS-ANCHOR-Y
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JW-COUNT
         MOVE JW-TAG(WS-I) TO WS-J
         IF WS-J > 0
             IF TN-NAME(WS-J) = "minecraft:city_anchor"
                 MOVE JW-Y(WS-I) TO WS-ANCHOR-Y
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-3§9.4 ancient city: the city_anchor jigsaw ends at y -28 and the stub y is -27" TO TL-CASE
     COMPUTE TL-EXPECTED-N = -28 * 100 + -27
     COMPUTE TL-OBSERVED-N = WS-ANCHOR-Y * 100 + WS-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> the rules of 9 on edited rows
 EDIT-CASES.
     MOVE SDT-JIG-NAMED(WS-CITY) TO WS-SAVE-NAMED
     MOVE SDT-JIG-NAME(WS-CITY) TO WS-SAVE-NAME
     MOVE "minecraft:no_such_anchor" TO SDT-JIG-NAME(WS-CITY)
     PERFORM FIND-CITY
     MOVE "acceptance US12 36-3§9.3 a start jigsaw name that no jigsaw of the start element has gives no structure" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SAVE-NAME TO SDT-JIG-NAME(WS-CITY)
     PERFORM FIND-CITY
     MOVE "acceptance US12 36-3§9.3 with the real start jigsaw name the same start exists again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   9.5: a decoded padding that the start piece does not fit, an absent one that is never checked, a decoded zero that fits
     MOVE SDT-JIG-PADSET(WS-CITY) TO WS-SAVE-PADSET
     MOVE SDT-JIG-PADB(WS-CITY) TO WS-SAVE-PADB
     MOVE SDT-JIG-PADT(WS-CITY) TO WS-SAVE-PADT
     MOVE 1 TO SDT-JIG-PADSET(WS-CITY)
     MOVE 30 TO SDT-JIG-PADB(WS-CITY)
     MOVE 0 TO SDT-JIG-PADT(WS-CITY)
     PERFORM FIND-CITY
     MOVE "acceptance US12 36-3§9.5 a decoded bottom padding of 30 (piece from y -52, limit -34) gives no structure" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO SDT-JIG-PADSET(WS-CITY)
     PERFORM FIND-CITY
     MOVE "acceptance US12 36-3§9.5 the same padding values with no decoded padding (the shared zero) are not checked" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO SDT-JIG-PADSET(WS-CITY)
     MOVE 0 TO SDT-JIG-PADB(WS-CITY)
     MOVE 0 TO SDT-JIG-PADT(WS-CITY)
     PERFORM FIND-CITY
     MOVE "acceptance US12 36-3§9.5 a decoded padding of 0 and 0 is checked and the piece, inside the dimension, passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 345 TO SDT-JIG-PADT(WS-CITY)
     PERFORM FIND-CITY
     MOVE "acceptance US12 36-3§9.5 a top padding of 345 (limit y 319 - 345 = -26 < the piece's top -22) gives no structure" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SAVE-PADSET TO SDT-JIG-PADSET(WS-CITY)
     MOVE WS-SAVE-PADB TO SDT-JIG-PADB(WS-CITY)
     MOVE WS-SAVE-PADT TO SDT-JIG-PADT(WS-CITY)
     MOVE WS-SAVE-NAMED TO SDT-JIG-NAMED(WS-CITY)
*>   9.7 step 1: size 0 gives no structure at all
     MOVE SDT-JIG-SIZE(WS-CITY) TO WS-SAVE-SIZE
     MOVE 0 TO SDT-JIG-SIZE(WS-CITY)
     PERFORM FIND-CITY
     MOVE "acceptance US12 36-3§9.7 size 0 gives no structure (no piece is added)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SAVE-SIZE TO SDT-JIG-SIZE(WS-CITY)
     PERFORM ALIAS-CASES
     .
 FIND-CITY.
     CALL "JIG-RESET"
     MOVE 3 TO WS-CX
     MOVE 4 TO WS-CZ
     CALL "STRUCT-FIND-POINT" USING WS-CITY CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     .

*> 9.2 step 1: the start pool of the village_plains row is aliased to another pool, to a missing pool (the own pool is used), to nothing
 ALIAS-CASES.
     MOVE SDT-JIG-AL-FIRST(WS-PLAINS) TO WS-SAVE-ALF
     MOVE SDT-JIG-AL-N(WS-PLAINS) TO WS-SAVE-ALN
     MOVE SD-AL-COUNT TO WS-SAVE-ALC
     MOVE 5 TO WS-CX
     MOVE 7 TO WS-CZ
     PERFORM FIND-PLAINS
     MOVE JE-LOC(SP-F1(1)) TO WS-NAME
     MOVE "acceptance US12 36-3§9.2 without aliases the village_plains start piece is from the plains town_centers pool" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NAME(1:34) = "minecraft:village/plains/town_cent"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '[{"type": "minecraft:direct", "alias": "minecraft:village/plains/town_centers", "target": "minecraft:village/desert/town_centers"}]' TO WS-TEXT
     PERFORM READ-ALIASES
     PERFORM FIND-PLAINS
     MOVE JE-LOC(SP-F1(1)) TO WS-NAME
     MOVE "acceptance US12 36-3§9.2 an alias of the start pool to the desert town_centers gives a desert start piece" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NAME(1:33) = "minecraft:village/desert/town_cen"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '[{"type": "minecraft:direct", "alias": "minecraft:village/plains/town_centers", "target": "minecraft:village/no_such_pool"}]' TO WS-TEXT
     PERFORM READ-ALIASES
     PERFORM FIND-PLAINS
     MOVE JE-LOC(SP-F1(1)) TO WS-NAME
     MOVE "acceptance US12 36-3§9.2 an alias to a pool the registry lacks falls back to the structure's own start pool" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NAME(1:34) = "minecraft:village/plains/town_cent"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '[{"type": "minecraft:direct", "alias": "minecraft:a", "target": "minecraft:b"}, {"type": "minecraft:direct", "alias": "minecraft:a", "target": "minecraft:c"}]' TO WS-TEXT
     PERFORM READ-ALIASES
     PERFORM FIND-PLAINS
     MOVE "acceptance US12 36-3§7.2 an alias bound twice in one resolution is an error: no structure" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SAVE-ALF TO SDT-JIG-AL-FIRST(WS-PLAINS)
     MOVE WS-SAVE-ALN TO SDT-JIG-AL-N(WS-PLAINS)
     MOVE WS-SAVE-ALC TO SD-AL-COUNT
     .

*> READ-ALIASES: the JSON array in WS-TEXT becomes the alias bindings of the plains row (read as the pool_aliases member of an object)
 FIND-PLAINS.
     CALL "JIG-RESET"
     CALL "STRUCT-FIND-POINT" USING WS-PLAINS CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     .
 READ-ALIASES.
     MOVE SPACES TO WS-FILE
     STRING '{"pool_aliases": ' FUNCTION TRIM(WS-TEXT) '}' DELIMITED BY SIZE INTO WS-FILE
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-FILE))
     CALL "JSON-PARSE" USING JSON-DOC WS-FILE WS-LEN
     MOVE WS-SAVE-ALC TO SD-AL-COUNT
     CALL "JIG-ALIAS-READ" USING JSON-DOC WS-PLAINS WS-OK
     .
 END PROGRAM TEST-STRUCT-36-3-9.

 COPY JIGSEAM.

 COPY NOSPAWN.
 COPY CORETEST.
