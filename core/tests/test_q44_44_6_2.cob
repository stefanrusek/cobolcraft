*> Piglin hostility engine (docs/protocol/44-residual-mob-questions-6-nether.md section 2.9; lane 002-lane-p49c, T15510): angerNearbyPiglins takes every idle Piglin
*> (not a brute) inside the player's box inflated by 16, with line of sight for containers and none for a broken guarded block, and angers it for 600 ticks at the
*> player; block tag guarded_by_piglins; a survival break of a guarded block and the opening of a container run it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY48               PIC X(48).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-BTYPE               BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 60.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-STONE               BINARY-LONG.
 01 WS-GOLD                BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Bob".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 3.
 01 WS-CONN2               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-RNAME                PIC X(40) VALUE "universal_anger".
 01 WS-RINDEX              BINARY-LONG.
 01 WS-RVALUE              BINARY-DOUBLE.
 01 WS-LOS                 BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
*>   Block tag guarded_by_piglins.
     MOVE "gold_block" TO WS-KEY48
     CALL "PIGLIN-GUARDED" USING WS-KEY48 WS-G
     MOVE "acceptance US15 44-6§2.9 gold_block is guarded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "blue_shulker_box" TO WS-KEY48
     CALL "PIGLIN-GUARDED" USING WS-KEY48 WS-G
     MOVE "acceptance US15 44-6§2.9 a coloured shulker box is guarded" TO TL-CASE
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "deepslate_gold_ore" TO WS-KEY48
     CALL "PIGLIN-GUARDED" USING WS-KEY48 WS-G
     MOVE "acceptance US15 44-6§2.9 a gold ore is guarded" TO TL-CASE
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "waxed_oxidized_copper_chest" TO WS-KEY48
     CALL "PIGLIN-GUARDED" USING WS-KEY48 WS-G
     MOVE "acceptance US15 44-6§2.9 a copper chest of any state is guarded" TO TL-CASE
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "stone" TO WS-KEY48
     CALL "PIGLIN-GUARDED" USING WS-KEY48 WS-G
     MOVE "acceptance US15 44-6§2.9 stone is not guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "copper_block" TO WS-KEY48
     CALL "PIGLIN-GUARDED" USING WS-KEY48 WS-G
     MOVE "acceptance US15 44-6§2.9 a copper block is not guarded" TO TL-CASE
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   World: a stone floor 60 x 60 around the player.
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 30
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 30
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:gold_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-GOLD
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:piglin_brute" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BTYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-Y(WS-PLAYER) TO WS-Y
*>   A: 6 blocks east in the open; B: 6 blocks west behind a stone wall; C: 20 blocks east (out of the box? no: 16 inflate, 20 is out);
*>   D: a brute 5 blocks south; E: a piglin 5 blocks north that is admiring.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 6
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-A
     COMPUTE WS-X = PL-X(WS-PLAYER) - 6
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-B
     COMPUTE WS-X = PL-X(WS-PLAYER) + 20
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-C
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-BTYPE WS-X WS-Y WS-Z WS-YAW WS-D
     COMPUTE WS-Z = PL-Z(WS-PLAYER) - 5
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-E
     MOVE 50 TO EN-ADMIRE(WS-E)
     COMPUTE WS-WX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 3
     COMPUTE WS-WZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         COMPUTE WS-WY = WS-FY + 1 + WS-I
         PERFORM VARYING WS-LOS FROM -2 BY 1 UNTIL WS-LOS > 2
             COMPUTE WS-D = WS-WZ + WS-LOS
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-D WS-STONE
         END-PERFORM
     END-PERFORM
*>   Opening a container needs line of sight: A is angered (600 ticks at the player), B behind the wall, C too far, the brute and the admiring piglin not.
     CALL "PIGLIN-CONTAINER-OPENED" USING WS-PLAYER
     MOVE "acceptance US15 44-6§2.9 a container opened: the idle piglin in view is angry for 600 ticks" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.9 and its target is the player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.9 a piglin behind a wall does not see the player: no anger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.9 a piglin 20 blocks away is outside the box" TO TL-CASE
     MOVE EN-ANGER(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.9 a piglin brute is not affected" TO TL-CASE
     MOVE EN-ANGER(WS-D) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.9 a piglin that is not idle (admiring) is not affected" TO TL-CASE
     MOVE EN-ANGER(WS-E) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Breaking a guarded block needs no line of sight: B is angered now. Real survival break of a gold block.
     MOVE 0 TO EN-ANGER(WS-A) EN-TARGET(WS-A)
     COMPUTE WS-WX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 1
     COMPUTE WS-WY = WS-FY + 1
     COMPUTE WS-WZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-GOLD
     CALL "BREAK-FINISH" USING WS-PLAYER WS-DIM WS-WX WS-WY WS-WZ
     MOVE "acceptance US15 44-6§2.9 breaking a gold block angers the piglin behind the wall (no line of sight needed)" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.9 and the piglin in the open too" TO TL-CASE
     MOVE EN-ANGER(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Breaking stone angers nobody.
     MOVE 0 TO EN-ANGER(WS-A) EN-TARGET(WS-A)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
     CALL "BREAK-FINISH" USING WS-PLAYER WS-DIM WS-WX WS-WY WS-WZ
     MOVE "acceptance US15 44-6§2.9 breaking stone angers nobody" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A creative player angers nobody (not attackable).
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO WS-LOS
     CALL "PIGLIN-ANGER-NEARBY" USING WS-PLAYER WS-LOS
     MOVE "acceptance US15 44-6§2.9 a creative player angers nobody" TO TL-CASE
     MOVE EN-ANGER(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   universal_anger on: the piglin takes the nearest attackable player (Bob stands next to it), not the one who opened the container.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EN-ANGER(WS-A) EN-TARGET(WS-A)
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-BOB
     COMPUTE PL-X(WS-BOB) = EN-X(WS-A) - 1
     MOVE EN-Y(WS-A) TO PL-Y(WS-BOB)
     MOVE EN-Z(WS-A) TO PL-Z(WS-BOB)
     MOVE 0 TO PL-MODE(WS-BOB)
     CALL "BR-RULE-FIND" USING WS-RNAME WS-RINDEX
     MOVE 1 TO WS-RVALUE
     CALL "BR-RULE-SET" USING WS-RINDEX WS-RVALUE
     CALL "PIGLIN-CONTAINER-OPENED" USING WS-PLAYER
     MOVE "acceptance US15 44-6§2.9 universal_anger: the piglin is angry at the nearest player" TO TL-CASE
     MOVE WS-BOB TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-RVALUE
     CALL "BR-RULE-SET" USING WS-RINDEX WS-RVALUE
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-2.
 COPY CORETEST.
 COPY MOBSPTEST.
