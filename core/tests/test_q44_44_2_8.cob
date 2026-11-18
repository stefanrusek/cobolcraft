 *> Implementation test (docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 8.1 step 2b and 8.3, worked cases of 14.5; core/src/struct-override.cob): the lookup of the
 *> structure spawn overrides for the structures that test_struct_override leaves out. A pillager outpost's whole box gives the monster category the pillager list (count 1) and nothing for the
 *> other categories; the trial chambers' piece boxes give each of the seven categories the empty list; where two registered boxes hold a position the first registered that has a list for the
 *> category wins, and the entry drawn from the outpost list is the pillager.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-2-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTOVR.
 COPY XORO.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG.
 01 WS-X0                  BINARY-LONG VALUE 0.
 01 WS-Y0                  BINARY-LONG VALUE 0.
 01 WS-Z0                  BINARY-LONG VALUE 0.
 01 WS-X1                  BINARY-LONG VALUE 15.
 01 WS-Y1                  BINARY-LONG VALUE 60.
 01 WS-Z1                  BINARY-LONG VALUE 15.
 01 WS-X                   BINARY-LONG VALUE 7.
 01 WS-Y                   BINARY-LONG VALUE 30.
 01 WS-Z                   BINARY-LONG VALUE 7.
 01 WS-CAT                 BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-SUM                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO SO-COUNT SO-NEXT
*>   a pillager outpost (kind 3, whole box)
     MOVE 3 TO WS-KIND
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test q44-44-2-8: inside a pillager outpost's box the monster category has the outpost list (row 6)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "SO-PICK" USING XR-STATE WS-LIST WS-ENTRY
     MOVE "test q44-44-2-8: the only entry of the outpost list is the pillager (weight 1, count 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SO-E-KEY(WS-ENTRY) = "pillager" AND SO-E-MIN(WS-ENTRY) = 1 AND SO-E-MAX(WS-ENTRY) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the other six categories have no outpost list: the biome's applies
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-CAT FROM 2 BY 1 UNTIL WS-CAT > 7
         CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
         ADD WS-LIST TO WS-SUM
     END-PERFORM
     MOVE "test q44-44-2-8: the other six categories have no list inside an outpost" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   first registered wins: a trial chambers piece box over the same position registered later does not replace the outpost's monster list
     MOVE 6 TO WS-KIND
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test q44-44-2-8: two boxes hold the position: the first registered (outpost) wins the monster category" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test q44-44-2-8: and the creature category, which the outpost has no list for, falls to the trial chambers' empty list (row 10)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the trial chambers' empty list gives every category no entries and draws nothing
     MOVE 0 TO SO-COUNT SO-NEXT
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-CAT FROM 1 BY 1 UNTIL WS-CAT > 7
         CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
         IF WS-LIST = 10
             ADD 1 TO WS-SUM
         END-IF
     END-PERFORM
     MOVE "test q44-44-2-8: inside a trial chambers piece box all seven categories have the empty list (row 10)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-SUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SO-PICK" USING XR-STATE WS-LIST WS-ENTRY
     MOVE "test q44-44-2-8: an empty list draws no entry" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ENTRY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a box in another chunk does not hold the position
     MOVE 1 TO WS-CX
     MOVE 1 TO WS-CAT
     MOVE 16 TO WS-X
     MOVE 16 TO WS-Z
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test q44-44-2-8: a position in a chunk with no registered box has no list" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-2-8.
