*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 5.8): the skeletons of the Nether. Skeletons spawn in soul_sand_valley (weight 20, groups of 5) and, as the fortress override's
*> skeleton, with weight 2 x5; wither skeletons only through the fortress override (weight 8 x5): no biome list holds a wither_skeleton; piglins spawn in nether_wastes (15, 4) and crimson_forest
*> (5, 3 to 4). Both skeleton kinds have a standard mob row (the monster category).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STDMOBS.
 COPY MOBSPAWN.
 COPY STRUCTOVR.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-WANT                PIC X(32).
 01 WS-CAT                 BINARY-LONG.
 01 WS-SKELETON            BINARY-LONG.
 01 WS-WITHER              BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-TEXT                PIC X(60).
 01 WS-W                   PIC ZZ9.
 01 WS-A                   PIC ZZ9.
 01 WS-Z                   PIC ZZ9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-ENTRIES
         IF SPE-KEY(WS-I) = "wither_skeleton"
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.8 no biome list holds a wither skeleton" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "T" TO TL-MODE
     MOVE "soul_sand_valley" TO WS-WANT
     MOVE "skeleton" TO WS-KEY
     MOVE 1 TO WS-CAT
     PERFORM FIND-ENTRY
     MOVE "acceptance US15 21§5.8 soul_sand_valley: skeleton weight 20, groups of 5" TO TL-CASE
     MOVE "20:5-5" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "nether_wastes" TO WS-WANT
     MOVE "piglin" TO WS-KEY
     PERFORM FIND-ENTRY
     MOVE "acceptance US15 21§5.8 nether_wastes: piglin weight 15, groups of 4" TO TL-CASE
     MOVE "15:4-4" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "crimson_forest" TO WS-WANT
     MOVE "acceptance US15 21§5.8 crimson_forest: piglin weight 5, groups of 3 to 4" TO TL-CASE
     MOVE "5:3-4" TO TL-EXPECTED
     PERFORM FIND-ENTRY
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The fortress list: kind 1 category 1, entries skeleton (2, 5) and wither_skeleton (8, 5).
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-OVERRIDE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SO-LISTS
         IF SO-L-KIND(WS-I) = 1 AND SO-L-CAT(WS-I) = 1
             MOVE WS-I TO WS-OVERRIDE
         END-IF
     END-PERFORM
     MOVE 0 TO WS-SKELETON WS-WITHER
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SO-L-COUNT(WS-OVERRIDE)
         IF SO-E-KEY(SO-L-FIRST(WS-OVERRIDE) + WS-J) = "skeleton" AND SO-E-WEIGHT(SO-L-FIRST(WS-OVERRIDE) + WS-J) = 2
                 AND SO-E-MIN(SO-L-FIRST(WS-OVERRIDE) + WS-J) = 5 AND SO-E-MAX(SO-L-FIRST(WS-OVERRIDE) + WS-J) = 5
             ADD 1 TO WS-SKELETON
         END-IF
         IF SO-E-KEY(SO-L-FIRST(WS-OVERRIDE) + WS-J) = "wither_skeleton" AND SO-E-WEIGHT(SO-L-FIRST(WS-OVERRIDE) + WS-J) = 8
                 AND SO-E-MIN(SO-L-FIRST(WS-OVERRIDE) + WS-J) = 5 AND SO-E-MAX(SO-L-FIRST(WS-OVERRIDE) + WS-J) = 5
             ADD 1 TO WS-WITHER
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.8 the fortress override has the skeleton (2, 5)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SKELETON TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§5.8 and the wither skeleton (8, 5)" TO TL-CASE
     MOVE WS-WITHER TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   Rows.
     MOVE 0 TO WS-SKELETON WS-WITHER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-COUNT
         IF SM-KEY(WS-I) = "skeleton" AND SM-KIND(WS-I) = 1
             MOVE 1 TO WS-SKELETON
         END-IF
         IF SM-KEY(WS-I) = "wither_skeleton" AND SM-KIND(WS-I) = 1 AND SM-HEALTH(WS-I) = 20
             MOVE 1 TO WS-WITHER
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.8 the skeleton has a monster row" TO TL-CASE
     MOVE WS-SKELETON TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§5.8 the wither skeleton has a monster row (20 health)" TO TL-CASE
     MOVE WS-WITHER TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
*> FIND-ENTRY: WS-TEXT = "weight:min-max" of the entry WS-KEY of category WS-CAT in the biome WS-WANT ("none" when absent).
 FIND-ENTRY.
     MOVE "none" TO WS-TEXT
     MOVE 0 TO WS-B
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SP-BIOMES
         IF SPB-NAME(WS-J) = WS-WANT
             MOVE WS-J TO WS-B
         END-IF
     END-PERFORM
     COMPUTE WS-LAST = SPB-FIRST(WS-B) + SPB-COUNT(WS-B)
     PERFORM VARYING WS-J FROM SPB-FIRST(WS-B) BY 1 UNTIL WS-J >= WS-LAST
         IF SPE-KEY(WS-J + 1) = WS-KEY AND SPE-CAT(WS-J + 1) = WS-CAT
             MOVE SPE-WEIGHT(WS-J + 1) TO WS-W
             MOVE SPE-MIN(WS-J + 1) TO WS-A
             MOVE SPE-MAX(WS-J + 1) TO WS-Z
             MOVE SPACES TO WS-TEXT
             STRING FUNCTION TRIM(WS-W, LEADING) DELIMITED BY SIZE ":" DELIMITED BY SIZE FUNCTION TRIM(WS-A, LEADING) DELIMITED BY SIZE
                 "-" DELIMITED BY SIZE FUNCTION TRIM(WS-Z, LEADING) DELIMITED BY SIZE INTO WS-TEXT
         END-IF
     END-PERFORM.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-5-8.
