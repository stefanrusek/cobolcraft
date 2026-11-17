*> Implementation test of the structure spawn overrides (docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 8; STRUCTOVR.cpy, core/src/struct-override.cob and the
*> natural spawner's use of it in MS6-PACK): boxes are registered once per record and looked up by dimension, chunk and position for the category (the first qualifying record wins, a kind
*> without a list for the category does not qualify, the fortress's whole box applies on nether bricks only); a list is drawn by weight, an empty one draws nothing; a pack of the monster
*> category started inside a swamp hut piece box is made of the hut's witch and nothing else.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-OVERRIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY STRUCTOVR.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 COPY GENENT.
 COPY STRUCTPIECE.
 COPY MOBSPAWN.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 99.
 01 WS-KEY                 PIC X(80).
 01 WS-BOX.
    05 WS-B                BINARY-LONG OCCURS 6 TIMES.
 01 WS-SEEN                BINARY-LONG OCCURS 10 TIMES.
 01 WS-BRICKS              BINARY-LONG.
 01 WS-PAIRS               PIC X(160).
 01 WS-BKEY                PIC X(112).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "N" TO TL-MODE
     MOVE 3 TO WS-DIM
     MOVE 0 TO SO-COUNT SO-NEXT
     MOVE 4 TO WS-KIND
     MOVE 0 TO WS-CX WS-CZ
     MOVE 0 TO WS-X0 WS-Y0 WS-Z0
     MOVE 5 TO WS-X1
     MOVE 9 TO WS-Y1
     MOVE 7 TO WS-Z1
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE "test struct override: the same record registered twice is kept once" TO TL-CASE
     MOVE SO-COUNT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   lookups: a swamp hut piece box (kind 4) has a monster list (witch) and a creature list (cat)
     MOVE 3 TO WS-X
     MOVE 5 TO WS-Y
     MOVE 4 TO WS-Z
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: inside a hut box the monster category is list 7 (witch)" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 7 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: and the creature category is list 8 (cat)" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 8 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: a category the hut has no list for (ambient) keeps the biome's list: none" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-CAT
     MOVE 6 TO WS-X
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: one block outside the box: none" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     MOVE 10 TO WS-Y
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: one block above the box: none" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-X
     MOVE 5 TO WS-Y
     MOVE 4 TO WS-DIM
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: the same position in another dimension: none" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-DIM

*>   the overall box of an ancient city (kind 5) empties every category; a monument (kind 2) empties the axolotls and underground water creatures and has the guardian in the monster list
     MOVE 5 TO WS-KIND
     MOVE 0 TO WS-X0 WS-Z0
     MOVE 15 TO WS-X1 WS-Z1
     MOVE 40 TO WS-Y1
     MOVE 0 TO WS-Y0
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 12 TO WS-X
     MOVE 30 TO WS-Y
     MOVE 12 TO WS-Z
     MOVE 6 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: inside an ancient city every category has the empty list 9" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-KIND
     MOVE 100 TO WS-Y0
     MOVE 120 TO WS-Y1
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 110 TO WS-Y
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: inside a monument the monster category is list 3 (guardian)" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: and the axolotls list is the empty list 4" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: and the ambient category has no list there" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the whole box of a fortress (kind 7) counts on nether bricks only
     MOVE 7 TO WS-KIND
     MOVE 50 TO WS-Y0
     MOVE 90 TO WS-Y1
     CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     MOVE 3 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 1 TO WS-CAT
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: inside the fortress box on a block that is not nether bricks: no list" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:nether_bricks" TO WS-BKEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-BKEY WS-PAIRS WS-BRICKS
     COMPUTE WS-Y = 69
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-BRICKS
     MOVE 70 TO WS-Y
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "test struct override: with nether bricks below it is the fortress list 2" TO TL-CASE
     MOVE WS-LIST TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   drawing: the fortress list holds five entries; the draws cover them, the empty list draws nothing and takes no random draw
     CALL "XORO-SEED" USING WS-SEED WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE 0 TO WS-SEEN(WS-I)
     END-PERFORM
     MOVE 1 TO WS-LIST
     PERFORM 400 TIMES
         CALL "SO-PICK" USING WS-STATE WS-LIST WS-ENTRY
         ADD 1 TO WS-SEEN(WS-ENTRY)
     END-PERFORM
     MOVE "test struct override: 400 draws of the fortress list give each of its five entries and no other" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SEEN(1) > 0 AND WS-SEEN(2) > 0 AND WS-SEEN(3) > 0 AND WS-SEEN(4) > 0 AND WS-SEEN(5) > 0
             AND WS-SEEN(6) = 0 AND WS-SEEN(7) = 0 AND WS-SEEN(8) = 0 AND WS-SEEN(9) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct override: the weights show: blaze (10 of 28) is drawn more often than skeleton (2 of 28)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SEEN(1) > WS-SEEN(4)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-LIST
     CALL "SO-PICK" USING WS-STATE WS-LIST WS-ENTRY
     MOVE "test struct override: an empty list draws nothing" TO TL-CASE
     MOVE WS-ENTRY TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-LIST
     CALL "SO-PICK" USING WS-STATE WS-LIST WS-ENTRY
     MOVE "test struct override: the hut's monster list is the witch (entry 8) alone" TO TL-CASE
     MOVE WS-ENTRY TO TL-OBSERVED-N
     MOVE 8 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-ENTRY
     CALL "SO-PACK-SIZE" USING WS-STATE WS-ENTRY WS-N
     MOVE "test struct override: the blaze's count is 2 to 3" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 2 AND WS-N <= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-ENTRY
     CALL "SO-PACK-SIZE" USING WS-STATE WS-ENTRY WS-N
     MOVE "test struct override: the witch's count is the constant 1" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the registry is a ring: the 2049th record replaces the oldest
     MOVE 6 TO WS-KIND
     MOVE 1 TO WS-CX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2048
         MOVE WS-I TO WS-Z0
         CALL "SO-REGISTER" USING WS-DIM WS-CX WS-CZ WS-KIND WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     END-PERFORM
     MOVE "test struct override: a full registry holds 2048 records and the next ones overwrite the oldest" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SO-COUNT * 10 + SO-NEXT
     MOVE 20484 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   STRUCT-OVR-NOTE: what a generated chunk tells the entity channel (the swamp hut: its piece boxes that touch the chunk column; a monument: its whole box; a fortress: the pieces and the whole box)
     MOVE 0 TO GEL-BOX-COUNT GEL-BOX-LOST
     MOVE 2 TO SP-COUNT
     MOVE 0 TO SP-X0(1) SP-Y0(1) SP-Z0(1)
     MOVE 6 TO SP-X1(1)
     MOVE 9 TO SP-Y1(1)
     MOVE 8 TO SP-Z1(1)
     MOVE 40 TO SP-X0(2)
     MOVE 64 TO SP-Y0(2)
     MOVE 40 TO SP-Z0(2)
     MOVE 46 TO SP-X1(2)
     MOVE 70 TO SP-Y1(2)
     MOVE 48 TO SP-Z1(2)
     MOVE 0 TO WS-B(1) WS-B(2) WS-B(3)
     MOVE 46 TO WS-B(4)
     MOVE 70 TO WS-B(5)
     MOVE 48 TO WS-B(6)
     MOVE "minecraft:swamp_hut" TO WS-KEY
     MOVE 0 TO WS-CX WS-CZ
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-CX WS-CZ WS-BOX
     MOVE "test struct override: a hut start noted for chunk (0, 0) asks for its first piece box only (kind 4)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GEL-BOX-COUNT * 1000 + GEL-B-KIND(1) * 100 + GEL-B-MAX-X(1)
     MOVE 1406 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO GEL-BOX-COUNT
     MOVE "minecraft:monument" TO WS-KEY
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-CX WS-CZ WS-BOX
     MOVE "test struct override: a monument asks for its whole box once (kind 2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GEL-BOX-COUNT * 1000 + GEL-B-KIND(1) * 100 + GEL-B-MAX-X(1) - 40
     MOVE 1206 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO GEL-BOX-COUNT
     MOVE "minecraft:fortress" TO WS-KEY
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-CX WS-CZ WS-BOX
     MOVE "test struct override: a fortress asks for its whole box (kind 7) and the pieces that touch the chunk (kind 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GEL-BOX-COUNT * 100 + GEL-B-KIND(1) * 10 + GEL-B-KIND(2)
     MOVE 271 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO GEL-BOX-COUNT
     MOVE "minecraft:village_plains" TO WS-KEY
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-CX WS-CZ WS-BOX
     MOVE "test struct override: a structure without an override asks for nothing" TO TL-CASE
     MOVE GEL-BOX-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-CX
     MOVE "minecraft:monument" TO WS-KEY
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-CX WS-CZ WS-BOX
     MOVE "test struct override: a start whose box does not touch the chunk asks for nothing" TO TL-CASE
     MOVE GEL-BOX-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-CX
     MOVE "minecraft:pillager_outpost" TO WS-KEY
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-CX WS-CZ WS-BOX
     MOVE "minecraft:ancient_city" TO WS-KEY
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-CX WS-CZ WS-BOX
     MOVE "minecraft:trial_chambers" TO WS-KEY
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-CX WS-CZ WS-BOX
     MOVE "test struct override: an outpost (3) and an ancient city (5) ask once each, trial chambers (6) per piece touching the chunk: 3 boxes" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GEL-BOX-COUNT * 1000 + GEL-B-KIND(1) * 100 + GEL-B-KIND(2) * 10 + GEL-B-KIND(3)
     MOVE 3356 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 END PROGRAM TEST-STRUCT-OVERRIDE.
 COPY CORETEST.
