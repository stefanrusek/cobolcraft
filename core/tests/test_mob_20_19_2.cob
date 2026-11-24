*> Acceptance test (002-lane-p49b; docs/protocol/20 section 19.2): structure-bound spawns (spawn_overrides, category monster). pillager_outpost: the whole box ("full") draws
*> pillager 1 x 1 in place of the biome list; swamp_hut: per piece box, witch 1 x 1 (and cat 1 x 1 in the creature category), a point between two pieces gets no override;
*> trial_chambers: empty lists in every category (nothing spawns naturally inside; each category's lookup finds a list and the list draws nothing); a mineshaft has no
*> override (nothing is registered, the lookup finds none). Fortress and monument entries are document 21.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-19-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTOVR.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-KEY                 PIC X(24).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "XORO-SEED" USING WS-SEED WS-STATE
     MOVE 0 TO SO-COUNT SO-NEXT
*>   Pillager outpost: the full box 0..40 x 60..80 x 0..15 of one chunk record.
     MOVE 3 TO WS-KIND
     MOVE 0 TO WS-X0 WS-Z0
     MOVE 60 TO WS-Y0
     MOVE 15 TO WS-X1 WS-Z1
     MOVE 80 TO WS-Y1
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 7 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 7 TO WS-Z
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     CALL "SO-PICK" USING WS-STATE WS-LIST WS-ENTRY
     MOVE "acceptance US15 20§19.2 the outpost's monster list draws the pillager" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ENTRY > 0
         MOVE SO-E-KEY(WS-ENTRY) TO WS-KEY
         IF WS-KEY = "pillager"
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SO-PACK-SIZE" USING WS-STATE WS-ENTRY WS-N
     MOVE "acceptance US15 20§19.2 the pillager entry is weight 1, count 1" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 111
     COMPUTE TL-OBSERVED-N = SO-E-WEIGHT(WS-ENTRY) * 100 + WS-N * 10 + SO-E-MIN(WS-ENTRY)
     IF SO-E-MAX(WS-ENTRY) NOT = 1
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US15 20§19.2 the outpost has no creature list (the biome's applies)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-CAT
     MOVE 90 TO WS-Y
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US15 20§19.2 above the outpost box the biome list applies" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Swamp hut: two piece boxes, 0..4 and 10..14 along x.
     MOVE 0 TO SO-COUNT SO-NEXT
     MOVE 4 TO WS-KIND
     MOVE 60 TO WS-Y0
     MOVE 70 TO WS-Y1
     MOVE 0 TO WS-X0 WS-Z0
     MOVE 4 TO WS-X1 WS-Z1
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 10 TO WS-X0
     MOVE 14 TO WS-X1
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 2 TO WS-X
     MOVE 65 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     CALL "SO-PICK" USING WS-STATE WS-LIST WS-ENTRY
     MOVE "acceptance US15 20§19.2 a swamp hut piece draws the witch in the monster category" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ENTRY > 0
         MOVE SO-E-KEY(WS-ENTRY) TO WS-KEY
         IF WS-KEY = "witch" AND SO-E-WEIGHT(WS-ENTRY) = 1 AND SO-E-MIN(WS-ENTRY) = 1 AND SO-E-MAX(WS-ENTRY) = 1
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     CALL "SO-PICK" USING WS-STATE WS-LIST WS-ENTRY
     MOVE "acceptance US15 20§19.2 a swamp hut piece draws the cat in the creature category" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ENTRY > 0
         MOVE SO-E-KEY(WS-ENTRY) TO WS-KEY
         IF WS-KEY = "cat" AND SO-E-WEIGHT(WS-ENTRY) = 1 AND SO-E-MIN(WS-ENTRY) = 1 AND SO-E-MAX(WS-ENTRY) = 1
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-X
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US15 20§19.2 between two hut pieces there is no override (per piece)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-X
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US15 20§19.2 the second hut piece has the override" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LIST > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Trial chambers: every category has a list and it is empty.
     MOVE 0 TO SO-COUNT SO-NEXT
     MOVE 6 TO WS-KIND
     MOVE 0 TO WS-X0 WS-Z0
     MOVE 15 TO WS-X1 WS-Z1
     MOVE 20 TO WS-Y0
     MOVE 40 TO WS-Y1
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 5 TO WS-X
     MOVE 30 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-CAT FROM 1 BY 1 UNTIL WS-CAT > 7
         CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
         MOVE -1 TO WS-ENTRY
         IF WS-LIST > 0
             CALL "SO-PICK" USING WS-STATE WS-LIST WS-ENTRY
         END-IF
         IF WS-LIST > 0 AND WS-ENTRY = 0
             ADD 1 TO WS-SEEN
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§19.2 trial chambers: all 7 categories find an empty list" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-SEEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Mineshaft: no override, nothing registered.
     MOVE 0 TO SO-COUNT SO-NEXT
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US15 20§19.2 mineshaft: no override list" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-19-2.
 COPY CORETEST.
