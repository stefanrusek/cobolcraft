*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.12 with 19 section 12 and the Turtle row of 19 section 1.4): the turtle's row (health 30, creature), its spawn entry (beach,
*> weight 5, group 2 to 5) and its spawn predicate: y below sea level + 4, sand below, raw brightness above 8.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY DIMENSIONS.
 COPY MOBSPAWN.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-TURTLE              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-SEA                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-REASON              BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:turtle" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TURTLE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TURTLE WS-M
     MOVE "acceptance US15 21§4.12 the turtle (19 section 12) has 30 health" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE SM-HEALTH(WS-M) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.12 and is a creature (category 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     CALL "MS6-ROW-CAT" USING WS-M TL-OBSERVED-N
     PERFORM CHECK-N
*>   The beach entry: turtle weight 5, group 2 to 5.
     MOVE 0 TO WS-B
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SP-BIOMES
         IF SPB-NAME(WS-J) = "beach"
             MOVE WS-J TO WS-B
         END-IF
     END-PERFORM
     MOVE 0 TO WS-FOUND
     COMPUTE WS-LAST = SPB-FIRST(WS-B) + SPB-COUNT(WS-B)
     PERFORM VARYING WS-J FROM SPB-FIRST(WS-B) BY 1 UNTIL WS-J >= WS-LAST
         IF SPE-KEY(WS-J + 1) = "turtle" AND SPE-CAT(WS-J + 1) = 2 AND SPE-WEIGHT(WS-J + 1) = 5 AND SPE-MIN(WS-J + 1) = 2 AND SPE-MAX(WS-J + 1) = 5
             ADD 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§4.12 the beach spawns turtles: weight 5, group 2 to 5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   The predicate on a column cleared to the sky at day, at the sea level of the dimension.
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:sand" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SAND
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-GRASS
     MOVE DM-SEA-LEVEL(WS-DIM) TO WS-SEA
     COMPUTE WS-BX = WS-X0 + 4
     COMPUTE WS-BZ = WS-Z0 + 14
     PERFORM VARYING WS-CELL FROM WS-SEA BY 1 UNTIL WS-CELL > WS-SEA + 120
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-AIR
     END-PERFORM
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     COMPUTE WS-CELL = WS-SEA + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-SAND
     COMPUTE WS-BY = WS-SEA + 2
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 19§1.4 turtle: sand below, y = sea level + 2, bright: passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     COMPUTE WS-CELL = WS-SEA + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-SAND
     COMPUTE WS-BY = WS-SEA + 4
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 19§1.4 turtle: y = sea level + 4 is not below sea level + 4: fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     COMPUTE WS-CELL = WS-SEA + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-AIR
     COMPUTE WS-CELL = WS-SEA + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-SAND
     COMPUTE WS-BY = WS-SEA + 3
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 19§1.4 turtle: y = sea level + 3 passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     COMPUTE WS-CELL = WS-SEA + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-AIR
     COMPUTE WS-CELL = WS-SEA + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-GRASS
     COMPUTE WS-BY = WS-SEA + 2
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 19§1.4 turtle: grass below is not sand: fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-SAND
*>   Since lane genlimits (T33320) the sky light of a cell is read with the sideways spread (LIGHT-SKY-SPREAD): a cell under a roof with open sides is lit by the sky beside it, as in
*>   the game. A cell shut in by a roof and four walls of sand stays dark.
     COMPUTE WS-CELL = WS-SEA + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-SAND
     ADD 1 TO WS-BX
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SAND
     SUBTRACT 2 FROM WS-BX
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SAND
     ADD 1 TO WS-BX
     ADD 1 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SAND
     SUBTRACT 2 FROM WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SAND
     ADD 1 TO WS-BZ
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 19§1.4 turtle: under a solid roof the raw brightness is not above 8: fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-12.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
