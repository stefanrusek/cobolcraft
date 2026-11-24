*> Implementation test (lane covB; docs/protocol/17 section 3.11, 44 part 8 section 10.1): the fishing bobber paths the acceptance test leaves out: a hooked entity followed
*> and lost, a hit on a mob and on another player, the retrieve costs of a hooked item and a hooked mob, a hook whose owner is gone, the bobbing in water (the correction towards
*> the surface, the nibble pull), a flying hook entering water, the hook dropped after 1200 ticks on the ground, the table rolls (junk and treasure) and the rod paying for a
*> retrieve from the use packet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-FISHING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PLAYPKT.
 COPY PROJSTATE.
 COPY CITEMS.
 COPY COREAPI.
 COPY PROTO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER2             BINARY-LONG.
 01 WS-CONN2               BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alex".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 4.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROD-ITEM            BINARY-LONG.
 01 WS-STICK-ITEM          BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PJ                  BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-COST                BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-WK                  BINARY-LONG.
 01 WS-ZA                  FLOAT-LONG VALUE 0.
 01 WS-ZB                  FLOAT-LONG VALUE 0.
 01 WS-ZC                  FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-PITCH               FLOAT-LONG VALUE 0.
 01 WS-SYAW                FLOAT-SHORT VALUE 0.
 01 WS-OPEN                BINARY-LONG VALUE 1.
 01 WS-LUCK                BINARY-LONG VALUE 3.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-VY1                 BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 48
     COMPUTE WS-FZ = WS-Z0 - 48
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-KIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:fishing_rod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ROD-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     COMPUTE WS-SLOT = PL-HELD(WS-PLAYER) + 1
     MOVE WS-ROD-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-SLOT)
     MOVE 0 TO PSB-HAND PSB-YAW PSB-PITCH
*>   A cow 4 blocks to the east at the player's own height, and a hook cast at it.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 4
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-X WS-Y WS-Z WS-SYAW WS-COW
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
*>   Hooked: the hook follows the cow at 0.8 of its height.
     MOVE 1 TO PJ-I1(WS-PJ)
     MOVE EN-ID(WS-COW) TO PJ-I2(WS-PJ)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 a hooked hook sits on the cow at 0.8 of its height (millimetres of y over the feet)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = ET-HEIGHT-MILLI(WS-COW-T + 1) * 0.8
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-Y(WS-ROW) - EN-Y(WS-COW)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 44-8 10.1 and at its x" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = EN-X(WS-COW) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Retrieving a hook on a mob costs 5.
     CALL "BOBBER-RETRIEVE" USING WS-PLAYER WS-ROW WS-COST
     MOVE "covB 17 3.11 retrieving a hook on a mob costs 5 durability" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-COST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Lost: the entity is gone and the hook flies again.
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     MOVE 1 TO PJ-I1(WS-PJ)
     MOVE 999999 TO PJ-I2(WS-PJ)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 a hook whose hooked entity is gone is free again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PJ-I1(WS-PJ) + PJ-I2(WS-PJ)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hooked item costs 3.
     MOVE "minecraft:stick" TO WS-KEY
     MOVE 0 TO WS-X WS-Y WS-Z
     COMPUTE WS-X = PL-X(WS-PLAYER) + 2
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ZA WS-ZB WS-ZC WS-STICK-ITEM WS-KIND WS-I WS-DROP
     MOVE 1 TO PJ-I1(WS-PJ)
     MOVE EN-ID(WS-DROP) TO PJ-I2(WS-PJ)
     CALL "BOBBER-RETRIEVE" USING WS-PLAYER WS-ROW WS-COST
     MOVE "covB 17 3.11 retrieving a hook on an item costs 3 durability" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An owner that does not exist: the hook is dropped by its step.
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     MOVE 987654 TO PJ-OWNER(WS-PJ)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 a hook with no owner in the world is discarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Bobbing in a water cell: a hook just under the surface level is pushed up, one above it is pulled down.
     COMPUTE WS-WX = WS-X0 + 4
     MOVE WS-Y0 TO WS-WY
     COMPUTE WS-WZ = WS-Z0 + 6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-WATER
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     COMPUTE EN-X(WS-ROW) = WS-WX + 0.5
     COMPUTE EN-Z(WS-ROW) = WS-WZ + 0.5
     CALL "BOAT-FLUID" USING WS-DIM WS-WX WS-WY WS-WZ WS-H WS-WK
     MOVE "covB 44-8 10.1 the water cell is fluid to the hook" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WK > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PJ-I1(WS-PJ)
     MOVE 0 TO PJ-I5(WS-PJ)
     COMPUTE EN-Y(WS-ROW) = WS-WY + WS-H + 0.1
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 a hook above the water surface is pulled down" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VY(WS-ROW) < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-Y(WS-ROW) = WS-WY + WS-H - 0.1
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 a hook below the water surface is pushed up" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VY(WS-ROW) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Right at the surface the correction is a fixed 0.1 either way.
     COMPUTE EN-Y(WS-ROW) = WS-WY + WS-H + 0.005
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 at the surface (just above) it still gets pulled down" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VY(WS-ROW) < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-Y(WS-ROW) = WS-WY + WS-H - 0.005
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 at the surface (just below) it still gets pushed up" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VY(WS-ROW) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A fish nibbling (count 5): the step counts it down and the hook is tugged.
     MOVE 5 TO PJ-I5(WS-PJ)
     COMPUTE EN-Y(WS-ROW) = WS-WY + WS-H
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 a nibbling fish's counter goes down one per step" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE PJ-I5(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A flying hook that enters the water slows down and turns bobbing.
     MOVE 0 TO PJ-I1(WS-PJ)
     MOVE 0 TO PJ-I5(WS-PJ)
     COMPUTE EN-Y(WS-ROW) = WS-WY + 0.2
     MOVE 1.0 TO EN-VX(WS-ROW)
     MOVE 1.0 TO EN-VY(WS-ROW)
     MOVE 1.0 TO EN-VZ(WS-ROW)
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 a hook flying into water starts bobbing (state 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PJ-I1(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
*>   A hook on the ground for 1200 ticks is dropped.
     MOVE 45 TO PSB-PITCH
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     CALL "BOBBER-FIND" USING PL-ENTITY-ID(WS-PLAYER) WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "THROWN-TICK"
     END-PERFORM
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     MOVE 1199 TO PJ-I6(WS-PJ)
     MOVE 0 TO WS-I
     CALL "BOBBER-STEP" USING WS-ROW
     MOVE "covB 44-8 10.1 a hook resting 1200 ticks on the ground is removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Using the rod with the hook on the ground retrieves it and the rod pays 2 durability.
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     CALL "BOBBER-FIND" USING PL-ENTITY-ID(WS-PLAYER) WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "THROWN-TICK"
     END-PERFORM
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE PL-SLOT-VAR(WS-PLAYER, WS-SLOT) TO WS-HANDLE
     CALL "SP-GET-DAMAGE" USING WS-ROD-ITEM WS-HANDLE WS-DAMAGE
     MOVE "covB 17 3.11 retrieving from the use packet damages the rod by 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-DAMAGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hook flying into a mob hooks it (yaw 0 casts along +z; the cow stands 3 blocks ahead at eye height).
     MOVE 0 TO PSB-PITCH
     COMPUTE EN-X(WS-COW) = PL-X(WS-PLAYER)
     COMPUTE EN-Y(WS-COW) = PL-Y(WS-PLAYER) + 0.5
     COMPUTE EN-Z(WS-COW) = PL-Z(WS-PLAYER) + 3
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR PJ-I1(WS-PJ) = 1
         CALL "BOBBER-STEP" USING WS-ROW
     END-PERFORM
     MOVE "covB 44-8 10.1 a hook that hits a mob hooks it" TO TL-CASE
     MOVE EN-ID(WS-COW) TO TL-EXPECTED-N
     MOVE PJ-I2(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
     MOVE 0 TO EN-HEALTH(WS-COW)
*>   And into another player.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-PLAYER2
     MOVE 0 TO PL-MODE(WS-PLAYER2)
     MOVE PL-X(WS-PLAYER) TO PL-X(WS-PLAYER2)
     MOVE PL-Y(WS-PLAYER) TO PL-Y(WS-PLAYER2)
     COMPUTE PL-Z(WS-PLAYER2) = PL-Z(WS-PLAYER) + 3
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR PJ-I1(WS-PJ) = 1
         CALL "BOBBER-STEP" USING WS-ROW
     END-PERFORM
     MOVE "covB 44-8 10.1 a hook that hits another player hooks that player" TO TL-CASE
     MOVE PL-ENTITY-ID(WS-PLAYER2) TO TL-EXPECTED-N
     MOVE PJ-I2(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A row without a projectile record is not a hook: its step does nothing.
     MOVE EN-X(WS-COW) TO WS-X
     CALL "BOBBER-STEP" USING WS-COW
     MOVE "covB 44-8 10.1 the step of a row that is no hook leaves it alone" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-X * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-COW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The table rolls: many catches reach the junk and the treasure tables.
     MOVE 0 TO WS-ITEMS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
         CALL "BOBBER-LOOT" USING WS-PLAYER WS-ROW WS-OPEN WS-LUCK
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM
     MOVE "covB 17 3.11 150 catches drop items" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ITEMS > 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-FISHING.
 COPY CORETEST.
 COPY MOBSPTEST.
