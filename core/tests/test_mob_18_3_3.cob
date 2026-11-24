*> Acceptance test (lane p49a; docs/protocol/18-mob-framework.md section 3.3 Collision, push and block effects, applyEffectsFromBlocks): a cactus in the mob's box does
*> 1.0 cactus damage, a magma block under a mob on the ground 1.0 hot_floor damage, a sweet berry bush 1.0 when it is grown and the mob moved more than 0.003 on x
*> or z since its previous position; none of them hurt a mob that is not touching them (the cobweb slowdown is asserted in test_mob_18_3_cobweb).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-3-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY RULES.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-PAIRS              PIC X(160).
 01 WS-COW                BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-FX                 BINARY-LONG.
 01 WS-FZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 9.
 01 WS-KIND               BINARY-LONG VALUE 1.
 01 WS-STATE              BINARY-LONG.
 01 WS-AIR                BINARY-LONG VALUE 0.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-CX                 BINARY-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 6000 TO CW-TIME
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-ON-GROUND(WS-ROW)

*>   Nothing around it: no damage.
     PERFORM TICK-COW
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: a mob touching nothing takes no block damage" TO WS-CASE
     MOVE 10 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   A cactus in the cell it stands in: 1.0.
     MOVE "minecraft:cactus" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     PERFORM TICK-COW
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: a cactus in the box does 1.0 damage" TO WS-CASE
     MOVE 9 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
*>   A magma block under it, on the ground: 1.0; in the air: none.
     MOVE "minecraft:magma_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-FY WS-BZ WS-STATE
     MOVE 0 TO EN-ON-GROUND(WS-ROW)
     PERFORM TICK-COW
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: a magma block does nothing to a mob that is not on the ground" TO WS-CASE
     MOVE 9 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     PERFORM TICK-COW
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: standing on a magma block does 1.0 hot_floor damage" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-FY WS-BZ WS-STATE
*>   A sweet berry bush: young and moving, none; grown and still, none; grown and moving, 1.0.
     MOVE "minecraft:sweet_berry_bush" TO WS-KEY
     MOVE "age=0" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE EN-PREV-X(WS-ROW) = EN-X(WS-ROW) - 0.1
     PERFORM TICK-COW
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: a young berry bush does no damage" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "age=3" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE EN-X(WS-ROW) TO EN-PREV-X(WS-ROW)
     PERFORM TICK-COW
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: a grown bush does no damage to a mob that did not move" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     COMPUTE EN-PREV-X(WS-ROW) = EN-X(WS-ROW) - 0.1
     PERFORM TICK-COW
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: a grown bush does 1.0 when the mob moved more than 0.003" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   A mob at 1 health in a cactus cell dies of it in the environment tick (which then ends).
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE "minecraft:cactus" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 1 TO EN-HEALTH(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW) EN-HEALTH-MILLI(WS-ROW)
     CALL "M182-ENV-TICK" USING WS-ROW
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: a cactus kills a mob of 1 health in the environment tick" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 TICK-COW.
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "M183-TICK" USING WS-ROW.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-3-3.
 COPY CORETEST.
 COPY MOBSPTEST.
