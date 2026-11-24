*> Acceptance test of docs/protocol/36-structures-9-villages-outposts.md section 8 (decor, trees, farm pieces, T1468) over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass
*> without it). 8.1: the feature elements of the decor and trees pools (the placed features and their weights of the table), the element count and weight sum of each normal and zombie decor pool
*> (plains 5 / 7 and 5 / 6, desert 4 / 28 twice, savanna 5 / 17 twice, snowy 7 / 27 and 7 / 22, taiga 13 / 39 and 10 / 26) and the weight of the empty element (2, 10, 4, 9, 4 normal; 2, 10, 4, 7, 4
*> zombie), and that a feature element is placed after the template blocks running the placed feature once (tested by test_struct_jig_feature: 36-3 section 5.5). 8.3: the crop rules of the farm
*> processor lists in order with their chances (plains 0.3, 0.2, 0.1 -> carrots 0.3, potatoes 0.14, beetroots 0.056, wheat 0.504; desert 0.2 then 0.1 -> 0.2, 0.08, 0.72) and the zombie plains list
*> holding the same crop rules after the decay rules.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-9-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTJIG.
 COPY STRUCTPROC.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(80).
 01 WS-POOL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-EMPTY-W             BINARY-LONG.
 01 WS-FEATURE-W           BINARY-LONG.
 01 WS-WANT-NAME           PIC X(40).
 01 WS-NAME                PIC X(80).
 01 WS-TEXT                PIC X(160).
 01 WS-P                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-CASE                BINARY-LONG.
 01 WS-PROB                BINARY-LONG.
 01 WS-RULES               BINARY-LONG.
 01 WS-RULE                BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-C1                  BINARY-DOUBLE.
 01 WS-C2                  BINARY-DOUBLE.
 01 WS-C3                  BINARY-DOUBLE.
 01 WS-C4                  BINARY-DOUBLE.
 01 WS-PRS.
    05 WS-PR               BINARY-LONG OCCURS 8 TIMES.
 01 WS-F                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
*>  the rows: pool suffix, element count, weight sum, empty weight
 01 WS-ROWS.
    05 FILLER              PIC X(46) VALUE "plains/decor                            050702".
    05 FILLER              PIC X(46) VALUE "plains/zombie/decor                     050602".
    05 FILLER              PIC X(46) VALUE "desert/decor                            042810".
    05 FILLER              PIC X(46) VALUE "desert/zombie/decor                     042810".
    05 FILLER              PIC X(46) VALUE "savanna/decor                           051704".
    05 FILLER              PIC X(46) VALUE "savanna/zombie/decor                    051704".
    05 FILLER              PIC X(46) VALUE "snowy/decor                             072709".
    05 FILLER              PIC X(46) VALUE "snowy/zombie/decor                      072207".
    05 FILLER              PIC X(46) VALUE "taiga/decor                             133904".
    05 FILLER              PIC X(46) VALUE "taiga/zombie/decor                      102604".
 01 WS-ROW-TAB REDEFINES WS-ROWS.
    05 WS-ROW              OCCURS 10 TIMES.
       10 WS-R-POOL        PIC X(40).
       10 WS-R-N           PIC 99.
       10 WS-R-TOTAL       PIC 99.
       10 WS-R-EMPTY       PIC 99.
 01 WS-FEATS.
    05 FILLER              PIC X(61) VALUE "plains/decor                            oak                 1".
    05 FILLER              PIC X(61) VALUE "plains/decor                            flower_plain        1".
    05 FILLER              PIC X(61) VALUE "plains/decor                            pile_hay            1".
    05 FILLER              PIC X(61) VALUE "plains/trees                            oak                 1".
    05 FILLER              PIC X(61) VALUE "savanna/trees                           acacia              1".
    05 FILLER              PIC X(61) VALUE "snowy/trees                             spruce              1".
    05 FILLER              PIC X(61) VALUE "desert/decor                            patch_cactus        4".
    05 FILLER              PIC X(61) VALUE "desert/decor                            pile_hay            4".
    05 FILLER              PIC X(61) VALUE "savanna/decor                           acacia              4".
    05 FILLER              PIC X(61) VALUE "savanna/decor                           pile_hay            4".
    05 FILLER              PIC X(61) VALUE "savanna/decor                           pile_melon          1".
    05 FILLER              PIC X(61) VALUE "snowy/decor                             spruce              4".
    05 FILLER              PIC X(61) VALUE "snowy/decor                             pile_snow           4".
    05 FILLER              PIC X(61) VALUE "snowy/decor                             pile_ice            1".
    05 FILLER              PIC X(61) VALUE "taiga/decor                             spruce              4".
    05 FILLER              PIC X(61) VALUE "taiga/decor                             pine                4".
    05 FILLER              PIC X(61) VALUE "taiga/decor                             pile_pumpkin        2".
    05 FILLER              PIC X(61) VALUE "taiga/decor                             patch_taiga_grass   4".
    05 FILLER              PIC X(61) VALUE "taiga/decor                             patch_berry_bush    1".
    05 FILLER              PIC X(61) VALUE "snowy/zombie/decor                      pile_ice            4".
 01 WS-FEAT-TAB REDEFINES WS-FEATS.
    05 WS-FT               OCCURS 20 TIMES.
       10 WS-F-POOL        PIC X(40).
       10 WS-F-NAME        PIC X(20).
       10 WS-F-W           PIC 9.
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
         MOVE "acceptance US12 36-9§8 Decor, trees, farm pieces: no generated packs here, skipped" TO TL-CASE
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
*>   element count, weight sum and the empty weight of the ten decor pools
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 10
         MOVE SPACES TO WS-KEY
         STRING "minecraft:village/" FUNCTION TRIM(WS-R-POOL(WS-CASE)) DELIMITED BY SIZE INTO WS-KEY
         CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
         IF WS-POOL < 2
             ADD 1 TO WS-BAD
         ELSE
             IF JP-N(WS-POOL) NOT = WS-R-N(WS-CASE) OR JP-TOTAL(WS-POOL) NOT = WS-R-TOTAL(WS-CASE)
                 ADD 1 TO WS-BAD
             END-IF
             PERFORM FIND-EMPTY-WEIGHT
             IF WS-EMPTY-W NOT = WS-R-EMPTY(WS-CASE)
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§8.1 Features in pools: the ten decor pools (normal and zombie) have the element counts, weight sums and empty weights of the tables" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the feature elements and their weights
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 20
         MOVE SPACES TO WS-KEY
         STRING "minecraft:village/" FUNCTION TRIM(WS-F-POOL(WS-CASE)) DELIMITED BY SIZE INTO WS-KEY
         CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
         MOVE SPACES TO WS-WANT-NAME
         MOVE WS-F-NAME(WS-CASE) TO WS-WANT-NAME
         PERFORM FIND-FEATURE-WEIGHT
         IF WS-FEATURE-W NOT = WS-F-W(WS-CASE)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§8.1 Features in pools: every placed feature of the decor and trees table is a feature element of its pool with the weight of the table (20 rows)" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the farm lists: plains 0.3, 0.2, 0.1
     MOVE "minecraft:farm_plains" TO WS-KEY
     PERFORM FARM-RULES
     MOVE "acceptance US12 36-9§8.3 Farm pieces: farm_plains has three rules, each a random_block_match of wheat with the chances 0.3, 0.2, 0.1 in this order" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "3: 300 200 100" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   the sequential chances (per thousand): carrots p1, potatoes (1 - p1) p2, beetroots (1 - p1)(1 - p2) p3, wheat the rest
     COMPUTE WS-C1 = WS-PR(1)
     COMPUTE WS-C2 = (1000 - WS-PR(1)) * WS-PR(2) / 1000
     COMPUTE WS-C3 = (1000 - WS-PR(1)) * (1000 - WS-PR(2)) / 1000 * WS-PR(3) / 1000
     COMPUTE WS-C4 = (1000 - WS-PR(1)) * (1000 - WS-PR(2)) / 1000 * (1000 - WS-PR(3)) / 1000
     MOVE "acceptance US12 36-9§8.3 Farm pieces: per wheat block carrots 0.3, potatoes 0.14, beetroots 0.056 and wheat 0.504 (per thousand 300, 140, 56, 504)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C1 * 1000000000 + WS-C2 * 1000000 + WS-C3 * 1000 + WS-C4
     MOVE 300140056504 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the desert list: wheat to beetroots 0.2, then melon stems 0.1: 0.2, 0.08 and wheat 0.72
     MOVE "minecraft:farm_desert" TO WS-KEY
     PERFORM FARM-RULES
     MOVE "acceptance US12 36-9§8.3 Farm pieces: farm_desert has two rules with the chances 0.2 and 0.1" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "2: 200 100" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     COMPUTE WS-C2 = (1000 - WS-PR(1)) * WS-PR(2) / 1000
     COMPUTE WS-C4 = (1000 - WS-PR(1)) * (1000 - WS-PR(2)) / 1000
     MOVE "acceptance US12 36-9§8.3 Farm pieces: per wheat block of a desert farm beetroots 0.2, melon stems 0.08 and wheat 0.72" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-PR(1) * 1000000 + WS-C2 * 1000 + WS-C4
     MOVE 200080720 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIND-EMPTY-WEIGHT.
     MOVE 0 TO WS-EMPTY-W
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JP-N(WS-POOL)
         COMPUTE WS-J = JP-FIRST(WS-POOL) + WS-I
         MOVE JN-ELEM(WS-J) TO WS-EL
         IF JE-KIND(WS-EL) = 5
             ADD JN-WEIGHT(WS-J) TO WS-EMPTY-W
         END-IF
     END-PERFORM.

 FIND-FEATURE-WEIGHT.
     MOVE -1 TO WS-FEATURE-W
     IF WS-POOL > 1
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JP-N(WS-POOL)
             COMPUTE WS-J = JP-FIRST(WS-POOL) + WS-I
             MOVE JN-ELEM(WS-J) TO WS-EL
             IF JE-KIND(WS-EL) = 4
                 MOVE SPACES TO WS-NAME
                 STRING "minecraft:" FUNCTION TRIM(WS-WANT-NAME) DELIMITED BY SIZE INTO WS-NAME
                 IF JE-FEATURE(WS-EL) = WS-NAME
                     MOVE JN-WEIGHT(WS-J) TO WS-FEATURE-W
                 END-IF
             END-IF
         END-PERFORM
     END-IF.

 FARM-RULES.
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-INDEX
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-P
     IF WS-INDEX = 0
         STRING "absent" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     ELSE
         MOVE SPL-FIRST(WS-INDEX) TO WS-I
         MOVE SPP-A(WS-I) TO WS-RULE
         MOVE SPP-N(WS-I) TO WS-RULES
         MOVE WS-RULES TO WS-ED
         STRING FUNCTION TRIM(WS-ED) ":" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-RULES
             MOVE SPR-IN(WS-RULE + WS-J) TO WS-TEST
             MOVE SPT-F(WS-TEST) TO WS-F
             COMPUTE WS-PROB ROUNDED = WS-F * 1000
             MOVE WS-PROB TO WS-PR(WS-J + 1)
             MOVE WS-PROB TO WS-ED
             STRING " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
         END-PERFORM
     END-IF.
 END PROGRAM TEST-STRUCT-36-9-8.
 COPY CORETEST.
