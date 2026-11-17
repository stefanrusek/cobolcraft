*> Implementation test (lane covB; 21 section 7): the Wither paths the acceptance tests leave out: the pattern along z, side head shots (head angle, a zero length
*> aim), Hard and mob targets of the skull's hit, a dangerous skull's inertia, the head updates (idle shot, aimed shot), the block destruction after a hit and the
*> main head's aimed shot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-WITHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY BRWORLD.
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
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-SKULL-STATE         BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BEDROCK             BINARY-LONG.
 01 WS-WITHER-T            BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HEAD                BINARY-LONG.
 01 WS-DANGEROUS           BINARY-LONG.
 01 WS-SK                  BINARY-LONG.
 01 WS-SK2                 BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WITHER-FX           BINARY-LONG VALUE 19.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-DIFF                BINARY-LONG.
 01 WS-SPEED1              BINARY-LONG.
 01 WS-SPEED2              BINARY-LONG.
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
     CALL "MS-TEST-STATE" USING WS-KEY WS-SKULL-STATE
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:bedrock" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-BEDROCK
     MOVE "minecraft:wither" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WITHER-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
     MOVE BW-DIFFICULTY TO WS-DIFF
*>   The pattern along z: skulls at y0 + 2, soul sand at y0 + 1 and the base at y0 under the middle.
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-CZ = WS-Z0 + WS-I
         COMPUTE WS-CY = WS-Y0 + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-CY WS-CZ WS-SAND
         COMPUTE WS-CY = WS-Y0 + 2
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-CY WS-CZ WS-SKULL-STATE
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-SAND
     CALL "WITHER-BUILD" USING WS-DIM WS-X0 WS-CY WS-Z0
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-WITHER-T
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "covB 21 7.1 the pattern along z makes one wither" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X0 WS-CY WS-Z0 WS-STATE
     MOVE "covB 21 7.1 and the middle skull of the z row is cleared" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A wither of our own, 10 blocks east of the player, which is a spectator (no target) for the first cases.
     MOVE 3 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-X = PL-X(WS-PLAYER) + 10
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "WITHER-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 0 TO PJ-I1(WS-SLOT)
     MOVE 100000 TO PJ-I4(WS-SLOT) PJ-I5(WS-SLOT)
     MOVE 1000 TO PJ-DUR(WS-SLOT)
*>   Side heads shoot from 1.3 blocks behind and in front of the body (yaw 0), 2.2 above its feet.
     MOVE 0 TO EN-YAW(WS-ROW)
     MOVE 1 TO WS-HEAD
     MOVE 0 TO WS-DANGEROUS
     CALL "WITHER-SHOOT" USING WS-ROW WS-HEAD PL-X(WS-PLAYER) PL-Y(WS-PLAYER) PL-Z(WS-PLAYER) WS-DANGEROUS WS-SK
     MOVE "covB 21 7.2 head 1 shoots from z + 1.3 (millimetres)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = (PL-Z(WS-PLAYER) + 1.3) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Z(WS-SK) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-HEAD
     CALL "WITHER-SHOOT" USING WS-ROW WS-HEAD PL-X(WS-PLAYER) PL-Y(WS-PLAYER) PL-Z(WS-PLAYER) WS-DANGEROUS WS-SK2
     MOVE "covB 21 7.2 head 2 shoots from z - 1.3 (millimetres)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = (PL-Z(WS-PLAYER) - 1.3) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Z(WS-SK2) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Aimed at its own head position the shot has no direction: the skull stands still (no division by zero).
     MOVE 0 TO WS-HEAD
     MOVE EN-X(WS-ROW) TO WS-X
     COMPUTE WS-Y = EN-Y(WS-ROW) + 3.0
     MOVE EN-Z(WS-ROW) TO WS-Z
     CALL "WITHER-SHOOT" USING WS-ROW WS-HEAD WS-X WS-Y WS-Z WS-DANGEROUS WS-SK
     MOVE "covB 21 7.2 a shot aimed at the head itself has no velocity" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (FUNCTION ABS(EN-VX(WS-SK)) + FUNCTION ABS(EN-VY(WS-SK)) + FUNCTION ABS(EN-VZ(WS-SK))) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A dangerous skull keeps less of its speed (inertia 0.73 against 0.95); a row that is no projectile is left alone.
     MOVE 0 TO WS-DANGEROUS
     CALL "WITHER-SHOOT" USING WS-ROW WS-HEAD PL-X(WS-PLAYER) PL-Y(WS-PLAYER) PL-Z(WS-PLAYER) WS-DANGEROUS WS-SK
     MOVE 1 TO WS-DANGEROUS
     CALL "WITHER-SHOOT" USING WS-ROW WS-HEAD PL-X(WS-PLAYER) PL-Y(WS-PLAYER) PL-Z(WS-PLAYER) WS-DANGEROUS WS-SK2
     CALL "WSKULL-STEP" USING WS-SK
     CALL "WSKULL-STEP" USING WS-SK2
     COMPUTE WS-SPEED1 ROUNDED = FUNCTION ABS(EN-VX(WS-SK)) * 10000
     COMPUTE WS-SPEED2 ROUNDED = FUNCTION ABS(EN-VX(WS-SK2)) * 10000
     MOVE "covB 21 7.2 a dangerous skull is slowed more by inertia" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SPEED2 > 0 AND WS-SPEED2 < WS-SPEED1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = PL-X(WS-PLAYER) + 3
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-X WS-Y WS-Z WS-YAW WS-COW
     MOVE EN-X(WS-COW) TO WS-X
     CALL "WSKULL-STEP" USING WS-COW
     CALL "WITHER-STEP" USING WS-COW
     MOVE "covB 21 7.2 skull and wither steps ignore a row without a projectile record" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-X * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-COW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The hit on Hard: Wither II for 800 ticks on a mob, and the mob loses health.
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     MOVE 3 TO BW-DIFFICULTY
     CALL "WSKULL-HIT" USING WS-SK WS-COW WS-NONE
     MOVE WS-DIFF TO BW-DIFFICULTY
     MOVE "covB 21 7.2 a skull's hit hurts a mob" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HEALTH(WS-COW) < WS-HEALTH0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MEF-LEVEL" USING EN-ID(WS-COW) WS-WITHER-FX WS-LEVEL WS-TICKS
     MOVE "covB 21 7.2 and on Hard it gets Wither II for 800 ticks" TO TL-CASE
     MOVE 2800 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-LEVEL * 1000 + WS-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Head updates with no target: after 15 idle updates a head shoots at a random point and its idle count restarts.
     MOVE 15 TO PJ-I6(WS-SLOT)
     MOVE 0 TO PJ-I4(WS-SLOT)
     MOVE 5 TO PJ-I7(WS-SLOT)
     MOVE 0 TO WS-NONE
     CALL "WITHER-HEADS" USING WS-ROW WS-SLOT WS-NONE
     MOVE "covB 21 7.2 the 16th idle update shoots and resets the idle count" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I6(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 21 7.2 the other head, not due yet, keeps its idle count" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PJ-I7(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With a target in sight a due head aims at it and waits 40 to 59 ticks.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 5 TO PJ-I6(WS-SLOT)
     MOVE 0 TO PJ-I4(WS-SLOT)
     MOVE 100 TO PJ-TICK(WS-SLOT)
     CALL "WITHER-HEADS" USING WS-ROW WS-SLOT WS-PLAYER
     MOVE "covB 21 7.2 a head aimed at a seen player resets idle and schedules 40 to 59 ticks on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I6(WS-SLOT) = 0 AND PJ-I4(WS-SLOT) >= 140 AND PJ-I4(WS-SLOT) <= 159
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The main head's shot every 40 ticks at a seen player within 20 blocks.
     MOVE 0 TO PJ-DUR(WS-SLOT)
     MOVE 100000 TO PJ-I4(WS-SLOT) PJ-I5(WS-SLOT)
     CALL "WITHER-STEP" USING WS-ROW
     MOVE "covB 21 7.2 the main head shot starts its 40 tick wait" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE PJ-DUR(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A damaging hit arms the destroy timer; when it runs out the blocks around the wither go, (the tag wither_immune is not part of the test content set).
     MOVE 3 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-ROW)) + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STONE
     MOVE 1 TO PJ-I3(WS-SLOT)
     CALL "WITHER-STEP" USING WS-ROW
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW))
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "covB 21 7.2 the destroy timer breaks a stone block next to the wither" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-WITHER.
 COPY CORETEST.
 COPY MOBSPTEST.
