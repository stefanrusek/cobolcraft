*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 3.5 with doc 44 part 2 section 8): the structure spawn overrides. Every row of the table: the fortress list (blaze 10
*> x2-3, zombified piglin 5 x4, wither skeleton 8 x5, skeleton 2 x5, magma cube 3 x4, in monsters and on nether bricks), the monument's guardian list and its two empty lists, the pillager outpost's
*> pillager, the swamp hut's cat and witch, and the empty lists of the trial chambers and the ancient city for every category; and the lookup inside and outside a registered box.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-3-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTOVR.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-X0                  BINARY-LONG VALUE 0.
 01 WS-Y0                  BINARY-LONG VALUE 0.
 01 WS-Z0                  BINARY-LONG VALUE 0.
 01 WS-X1                  BINARY-LONG VALUE 9.
 01 WS-Y1                  BINARY-LONG VALUE 9.
 01 WS-Z1                  BINARY-LONG VALUE 9.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TEXT                PIC X(240).
 01 WS-W                   PIC ZZ9.
 01 WS-A                   PIC ZZ9.
 01 WS-B                   PIC ZZ9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-KINDTEXT            PIC 9.
 01 WS-CATTEXT             PIC 9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
*>   Fortress (piece), kind 1 and 7: the same five entries in monster.
     PERFORM VARYING WS-KIND FROM 1 BY 6 UNTIL WS-KIND > 7
         MOVE WS-KIND TO WS-KINDTEXT
         MOVE 1 TO WS-CAT
         PERFORM FIND-LIST
         PERFORM LIST-TEXT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 21§3.5 fortress kind " WS-KINDTEXT " monster list" DELIMITED BY SIZE INTO TL-CASE
         MOVE "blaze:10:2-3;zombified_piglin:5:4-4;wither_skeleton:8:5-5;skeleton:2:5-5;magma_cube:3:4-4;" TO TL-EXPECTED
         MOVE WS-TEXT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   Monument (full): guardian w1 x2-4 in monsters; axolotls and underground water creatures empty.
     MOVE 2 TO WS-KIND
     MOVE 1 TO WS-CAT
     PERFORM FIND-LIST
     PERFORM LIST-TEXT
     MOVE "acceptance US15 21§3.5 monument monster list is the guardian" TO TL-CASE
     MOVE "guardian:1:2-4;" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-CAT
     PERFORM FIND-LIST
     PERFORM LIST-TEXT
     MOVE "acceptance US15 21§3.5 monument axolotls list is empty" TO TL-CASE
     MOVE "empty" TO TL-EXPECTED
     PERFORM EMPTY-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-CAT
     PERFORM FIND-LIST
     PERFORM LIST-TEXT
     MOVE "acceptance US15 21§3.5 monument underground water creature list is empty" TO TL-CASE
     PERFORM EMPTY-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Pillager outpost (full): pillager w1 x1. Swamp hut (piece): cat in creature, witch in monster.
     MOVE 3 TO WS-KIND
     MOVE 1 TO WS-CAT
     PERFORM FIND-LIST
     PERFORM LIST-TEXT
     MOVE "acceptance US15 21§3.5 pillager outpost monster list is the pillager" TO TL-CASE
     MOVE "pillager:1:1-1;" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-KIND
     PERFORM FIND-LIST
     PERFORM LIST-TEXT
     MOVE "acceptance US15 21§3.5 swamp hut monster list is the witch" TO TL-CASE
     MOVE "witch:1:1-1;" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-CAT
     PERFORM FIND-LIST
     PERFORM LIST-TEXT
     MOVE "acceptance US15 21§3.5 swamp hut creature list is the cat" TO TL-CASE
     MOVE "cat:1:1-1;" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Ancient city (5) and trial chambers (6): every category, empty.
     PERFORM VARYING WS-KIND FROM 5 BY 1 UNTIL WS-KIND > 6
         PERFORM VARYING WS-CAT FROM 1 BY 1 UNTIL WS-CAT > 7
             PERFORM FIND-LIST
             PERFORM LIST-TEXT
             MOVE WS-KIND TO WS-KINDTEXT
             MOVE WS-CAT TO WS-CATTEXT
             MOVE SPACES TO TL-CASE
             STRING "acceptance US15 21§3.5 structure kind " WS-KINDTEXT " category " WS-CATTEXT " list is empty" DELIMITED BY SIZE INTO TL-CASE
             PERFORM EMPTY-TEXT
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-PERFORM
     END-PERFORM
*>   The lookup: a registered fortress box answers monster, nothing outside it, nothing for a kind that has no list for the category (a fortress has no creature list).
     MOVE 1 TO WS-KIND
     MOVE 0 TO SO-COUNT SO-NEXT
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 5 TO WS-X WS-Y WS-Z
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US15 21§3.5 a position inside a fortress piece box takes the fortress monster list" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-X
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US15 21§3.5 a position outside the box takes the biome list" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     MOVE 2 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US15 21§3.5 a category the fortress has no list for keeps the biome list" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
*> FIND-LIST: WS-LIST = the SO-LIST row of kind WS-KIND and category WS-CAT or 0 (every category) when there is none.
 FIND-LIST.
     MOVE 0 TO WS-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SO-LISTS
         IF SO-L-KIND(WS-I) = WS-KIND AND (SO-L-CAT(WS-I) = WS-CAT OR SO-L-CAT(WS-I) = 0)
             MOVE WS-I TO WS-LIST
         END-IF
     END-PERFORM.
*> LIST-TEXT: WS-TEXT = "key:weight:min-max;" for each entry of the list, "empty" for a list of no entries, "none" for no list.
 LIST-TEXT.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     IF WS-LIST = 0
         MOVE "none" TO WS-TEXT
     ELSE
         IF SO-L-COUNT(WS-LIST) = 0
             MOVE "empty" TO WS-TEXT
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SO-L-COUNT(WS-LIST)
             MOVE SO-E-WEIGHT(SO-L-FIRST(WS-LIST) + WS-I) TO WS-W
             MOVE SO-E-MIN(SO-L-FIRST(WS-LIST) + WS-I) TO WS-A
             MOVE SO-E-MAX(SO-L-FIRST(WS-LIST) + WS-I) TO WS-B
             STRING FUNCTION TRIM(SO-E-KEY(SO-L-FIRST(WS-LIST) + WS-I)) DELIMITED BY SIZE ":" DELIMITED BY SIZE
                 FUNCTION TRIM(WS-W, LEADING) DELIMITED BY SIZE ":" DELIMITED BY SIZE
                 FUNCTION TRIM(WS-A, LEADING) DELIMITED BY SIZE "-" DELIMITED BY SIZE
                 FUNCTION TRIM(WS-B, LEADING) DELIMITED BY SIZE ";" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-PERFORM
     END-IF.
 EMPTY-TEXT.
     MOVE "empty" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED.
 END PROGRAM TEST-MOB-21-3-5.
