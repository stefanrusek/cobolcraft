*> Implementation test (002-lane-mobsfull-h20; docs/protocol/19-mobs-land-friendly-and-neutral.md section 12): the turtle. A new turtle has its home at its spawn block; seagrass is its food; two
*> turtles in love do not make a baby: the one that breeds gets an egg (metadata 18), both get age 6000 and lose love, and a turtle with an egg cannot fall in love; a baby that grows
*> up drops a scute (gameplay/turtle_grow); a turtle with an egg and its home within 9 blocks walks home and lays after more than 200 ticks (turtle egg block of 1 to 4 eggs, love time 600).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY CBLOCKS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SPECIES             PIC X(24).
 01 WS-ITEM                PIC X(24).
 01 WS-FOUND               BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-LOVE                BINARY-LONG.
 01 WS-TAME                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEAGRASS            BINARY-LONG.
 01 WS-SCUTE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PAIRS               PIC X(160).
 01 WS-EGG-STATE           BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-D                   PIC 9.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:turtle" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:seagrass" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SEAGRASS WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:turtle_scute" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SCUTE WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE

*>   Home: the block of the spawn position.
     COMPUTE WS-X = WS-PX + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-PZ)
     MOVE "acceptance US15 19§12 Turtle: a new turtle has its home at its spawn block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HOME-SET(WS-A) = 1 AND EN-HOME-X(WS-A) = WS-BX AND EN-HOME-Y(WS-A) = WS-BY AND EN-HOME-Z(WS-A) = WS-BZ
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Food and breeding.
     MOVE "turtle" TO WS-SPECIES
     MOVE "seagrass" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     CALL "M188-BREEDS" USING WS-SPECIES WS-OK
     MOVE "acceptance US15 19§12 Turtle: seagrass is its food and it can mate" TO TL-CASE
     MOVE 111 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FOUND * 100 + WS-LOVE * 10 + WS-OK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "kelp" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "acceptance US15 19§12 Turtle: kelp is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO PL-MODE(WS-PLAYER) PL-HELD(WS-PLAYER)
     MOVE WS-SEAGRASS TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 1 TO EN-TURTLE-EGG(WS-A)
     CALL "MOB-FEED-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 19§12 Turtle: a turtle with an egg cannot fall in love" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 1000
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(WS-PLAYER, 1) * 1000 + EN-LOVE(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TURTLE-EGG(WS-A)
     CALL "MOB-FEED-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 19§12 Turtle: without an egg seagrass brings love" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 1000 + 600
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(WS-PLAYER, 1) * 1000 + EN-LOVE(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     COMPUTE WS-X = WS-PX + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-B
     MOVE 600 TO EN-LOVE(WS-A) EN-LOVE(WS-B)
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     CALL "MOB-BREED" USING WS-A WS-B
     MOVE 0 TO WS-I
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE
             SUBTRACT 1 FROM WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§12 Turtle: breeding makes no baby" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§12 Turtle: the breeding one has the egg, the other not" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-TURTLE-EGG(WS-A) * 10 + EN-TURTLE-EGG(WS-B)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§12 Turtle: both are 6000 old and out of love" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 6000 * 6000
     COMPUTE TL-OBSERVED-N = (EN-MOBAGE(WS-A) + EN-LOVE(WS-A)) * (EN-MOBAGE(WS-B) + EN-LOVE(WS-B))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§12 Turtle: an egg is entity data to send" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-B

*>   A baby that grows up drops a scute.
     MOVE 0 TO EN-TURTLE-EGG(WS-A)
     COMPUTE WS-X = WS-PX - 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-B
     MOVE 1 TO EN-VARIANT(WS-B)
     MOVE -1 TO EN-MOBAGE(WS-B)
     PERFORM COUNT-SCUTES
     MOVE WS-N TO WS-I
     CALL "MOB-STEP" USING WS-B
     PERFORM COUNT-SCUTES
     MOVE "acceptance US15 19§12 Turtle: growing up drops one scute" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N - WS-I
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§12 Turtle: and is an adult" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-B

*>   Laying: home 5 blocks away is within 9; the turtle walks there, lays after more than 200 ticks.
     MOVE 1 TO EN-TURTLE-EGG(WS-A)
     COMPUTE EN-X(WS-A) = WS-PX
     COMPUTE EN-Z(WS-A) = WS-PZ + 0.5
     MOVE 0 TO EN-LOVE(WS-A)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120 OR EN-TURTLE-LAY(WS-A) > 0
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§12 Turtle: it walks home and starts laying (metadata 19)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-TURTLE-LAY(WS-A) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§12 Turtle: laying is entity data to send" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 199 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§12 Turtle: after 200 ticks of laying no egg yet" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 200 * 10 + 1
     COMPUTE TL-OBSERVED-N = EN-TURTLE-LAY(WS-A) * 10 + EN-TURTLE-EGG(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§12 Turtle: beyond 200 ticks the egg is laid, laying ends, love time is 600" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-TURTLE-EGG(WS-A) * 10000 + EN-TURTLE-LAY(WS-A) * 1000 + EN-LOVE(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM EN-HOME-X(WS-A) EN-HOME-Y(WS-A) EN-HOME-Z(WS-A) WS-STATE
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE "acceptance US15 19§12 Turtle: a turtle egg block of 1 to 4 eggs is at home" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 4
         MOVE SPACES TO WS-PAIRS
         MOVE WS-N TO WS-D
         STRING "eggs=" WS-D ",hatch=0" DELIMITED BY SIZE INTO WS-PAIRS
         MOVE "turtle_egg" TO WS-KEY
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-EGG-STATE
         IF WS-EGG-STATE = WS-STATE
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The home block is taken (water now): laying again places nothing but ends the same way.
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM EN-HOME-X(WS-A) EN-HOME-Y(WS-A) EN-HOME-Z(WS-A) WS-STATE
     MOVE 1 TO EN-TURTLE-EGG(WS-A)
     COMPUTE EN-X(WS-A) = EN-HOME-X(WS-A) + 0.5
     COMPUTE EN-Z(WS-A) = EN-HOME-Z(WS-A) + 0.5
     COMPUTE EN-Y(WS-A) = EN-HOME-Y(WS-A)
     PERFORM 202 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§12 Turtle: a taken home block is not overwritten, the egg is still gone" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-TURTLE-EGG(WS-A) = 0 AND EN-TURTLE-LAY(WS-A) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "WORLD-GET-BLOCK" USING WS-DIM EN-HOME-X(WS-A) EN-HOME-Y(WS-A) EN-HOME-Z(WS-A) WS-BLOCK
     IF WS-BLOCK NOT = WS-STATE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A home farther than 9 blocks: no laying.
     MOVE 1 TO EN-TURTLE-EGG(WS-A)
     COMPUTE EN-HOME-X(WS-A) = EN-HOME-X(WS-A) + 15
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§12 Turtle: a home beyond 9 blocks does not start laying" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TURTLE-LAY(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-SCUTES.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-X0 FROM 1 BY 1 UNTIL WS-X0 > EN-COUNT
         IF EN-USED(WS-X0) = 1 AND EN-ITEM(WS-X0) = WS-SCUTE AND EN-ITEM-COUNT(WS-X0) > 0
             ADD EN-ITEM-COUNT(WS-X0) TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-19-12.
 COPY CORETEST.
 COPY MOBSPTEST.
