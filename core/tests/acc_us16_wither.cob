*> Acceptance test, the Wither (docs/protocol/21 section 7; lane 002-lane-mobsb6, T9012): the build pattern (three skulls over three soul sand over a soul sand base with air beside it), not in Peaceful,
*> the 220 tick spawn (health 100, heals 10 every 10 ticks, immune, an explosion of power 7 at the end), regeneration, the powered state (health at most 150: arrows do nothing), damage side effects
*> (destroyBlocksTick 20, idle head updates + 3), flight toward a target, the skull (8 damage, Wither II for 200 ticks on Normal) and the nether star on death.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-WITHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY BRWORLD.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-SKULL               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WITHER-T            BINARY-LONG.
 01 WS-STAR                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-DIFF                BINARY-LONG.
 01 WS-HP                  FLOAT-SHORT.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WITHER-FX           BINARY-LONG VALUE 19.
 01 WS-CAUSE-ARROW         BINARY-LONG VALUE CAUSE-ARROW.
 01 WS-CAUSE-PLAYER        BINARY-LONG VALUE CAUSE-PLAYER.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-HEAD                BINARY-LONG VALUE 0.
 01 WS-DANGEROUS           BINARY-LONG VALUE 0.
 01 WS-SK                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 14
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 40
     COMPUTE WS-FZ = WS-Z0 - 40
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-FKIND
     MOVE "minecraft:soul_sand" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SAND
     MOVE "minecraft:wither_skeleton_skull" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SKULL
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:nether_star" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STAR WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:wither" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WITHER-T WS-ENTITY-ROW WS-STATUS
     MOVE BW-DIFFICULTY TO WS-DIFF
*>   The pattern along x: skulls at y0 + 2, soul sand at y0 + 1 and the base at y0 under the middle.
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-CX = WS-X0 + WS-I
         COMPUTE WS-CY = WS-Y0 + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-Z0 WS-SAND
         COMPUTE WS-CY = WS-Y0 + 2
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-Z0 WS-SKULL
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-SAND
*>   Peaceful: nothing happens.
     MOVE 0 TO BW-DIFFICULTY
     CALL "WITHER-BUILD" USING WS-DIM WS-X0 WS-CY WS-Z0
     MOVE WS-DIFF TO BW-DIFFICULTY
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-WITHER-T
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 7.1 in Peaceful the pattern makes no wither" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A broken pattern (the base missing) makes none either.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-AIR
     CALL "WITHER-BUILD" USING WS-DIM WS-X0 WS-CY WS-Z0
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-WITHER-T
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 7.1 without the base block the pattern does not match" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The full pattern, built by placing the last skull.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-SAND
     CALL "WITHER-BUILD" USING WS-DIM WS-X0 WS-CY WS-Z0
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-WITHER-T
             ADD 1 TO WS-COUNT
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 7.1 the full pattern makes one wither" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-STATE
     MOVE "acceptance US16 21 7.1 the pattern blocks are cleared (base air)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X0 WS-CY WS-Z0 WS-STATE
     MOVE "acceptance US16 21 7.1 and the middle skull is air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 7.1 the wither stands at the base block's centre + 0.55 (y in millimetres)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-Y0 * 1000 + 550
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Y(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 21 7.2 it starts with 220 invulnerable ticks and 100 health (max / 3)" TO TL-CASE
     MOVE 220100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PJ-I1(WS-SLOT) * 1000 + EN-HEALTH(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-HEALTH(WS-ROW) TO WS-H
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-H WS-CAUSE-PLAYER WS-PLAYER
     MOVE "acceptance US16 21 7.2 damage during the spawn is ignored" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "WITHER-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US16 21 7.2 at tick 10 of the spawn it heals 10" TO TL-CASE
     MOVE 110 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 11 BY 1 UNTIL WS-I > 220
         CALL "WITHER-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US16 21 7.2 after 220 ticks the invulnerable counter is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 7.2 and the spawn healing has filled the health to 300" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Regeneration: 1 every 20 ticks after the spawn (health 200: one beat in 20 ticks); the player is a spectator so nothing is targeted.
     MOVE 3 TO PL-MODE(WS-PLAYER)
     MOVE 200 TO EN-HEALTH(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "WITHER-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US16 21 7.2 it regenerates 1 health per 20 ticks" TO TL-CASE
     MOVE 201 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Powered (health 150): arrows do nothing; above 150 they hurt; a hit starts the block destruction timer and raises the idle counters.
     MOVE 150 TO EN-HEALTH(WS-ROW)
     MOVE 5 TO WS-DAMAGE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE-ARROW WS-NONE
     MOVE "acceptance US16 21 7.2 a powered wither ignores arrows" TO TL-CASE
     MOVE 150 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 151 TO EN-HEALTH(WS-ROW)
     MOVE 0 TO PJ-I3(WS-SLOT) PJ-I6(WS-SLOT) PJ-I7(WS-SLOT)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE-ARROW WS-NONE
     MOVE "acceptance US16 21 7.2 above half health an arrow hurts it" TO TL-CASE
     MOVE 146 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 7.2 a damaging hit sets destroyBlocksTick 20 and both idle counters to 3" TO TL-CASE
     MOVE 20033 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PJ-I3(WS-SLOT) * 1000 + PJ-I6(WS-SLOT) * 10 + PJ-I7(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Flight toward the player 14 blocks away: vy 0.3 and a horizontal speed 0.3 after one step.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 300 TO EN-HEALTH(WS-ROW)
     COMPUTE EN-X(WS-ROW) = PL-X(WS-PLAYER) + 14
     COMPUTE EN-Y(WS-ROW) = PL-Y(WS-PLAYER) + 0.55
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-ROW)
     MOVE 100000 TO PJ-I4(WS-SLOT) PJ-I5(WS-SLOT)
     MOVE 1000 TO PJ-DUR(WS-SLOT)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     MOVE EN-ID(WS-ROW) TO WS-I
     CALL "WITHER-STEP" USING WS-ROW
     MOVE "acceptance US16 21 7.2 flight: vertical velocity 0.3 toward a target above the wither's feet + 5" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 7.2 flight: horizontal speed 0.3 toward the target (squared, ten-thousandths 900)" TO TL-CASE
     MOVE 900 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-VX(WS-ROW) * EN-VX(WS-ROW) + EN-VZ(WS-ROW) * EN-VZ(WS-ROW)) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A skull from head 0 at the player: 8 damage and Wither II for 200 ticks on Normal.
     MOVE 2 TO BW-DIFFICULTY
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HP
     CALL "WITHER-SHOOT" USING WS-ROW WS-HEAD PL-X(WS-PLAYER) PL-Y(WS-PLAYER) PL-Z(WS-PLAYER) WS-DANGEROUS WS-SK
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-I >= 80 OR EN-USED(WS-SK) = 0
         CALL "WSKULL-STEP" USING WS-SK
         ADD 1 TO WS-I
     END-PERFORM
     MOVE WS-DIFF TO BW-DIFFICULTY
     MOVE "acceptance US16 21 7.2 a skull from the wither reaches the player and is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-SK) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 7.2 the hit costs at least 8 health points (the explosion of radius 1 adds more)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HP - PL-HEALTH(WS-PLAYER) >= 8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-WITHER-FX WS-LEVEL WS-TICKS
     MOVE "acceptance US16 21 7.2 and gives Wither II for 200 ticks on Normal" TO TL-CASE
     MOVE 2200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-LEVEL * 1000 + WS-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Death drops a nether star and the wither is gone.
     MOVE 1000 TO WS-DAMAGE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE-PLAYER WS-PLAYER
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-STAR AND EN-ITEM-COUNT(WS-I) = 1
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 7.4 dying drops one nether star" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 7.4 and the wither is removed (its row may be reused)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = WS-WITHER-T
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-WITHER.
 COPY CORETEST.
 COPY MOBSPTEST.
