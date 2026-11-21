*> Implementation test (lane covB; docs/protocol/21 section 6.4, 44 part 9 section 1; 11.1 end crystal item): the dragon's remaining paths: the ceiling of a fractional health, the nearest
*> part without an attacker, rescanning for a healing crystal, the crystal destroyed hook finding the nearest player itself, wing contact pushing and hurting a mob, the first kill's
*> death sequence telling the fight, a step of a row that is not the dragon, and crystal placement refused by a block or a solid cell above the base.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-DRAGON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY DRAGSTATE.
 COPY FIGHTRT.
 COPY ENDFIGHT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CRYSTAL-ITEM        BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-NO                  BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE WS-DIM TO FR-DIM
     MOVE 1 TO FR-SCANNED
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 48
     COMPUTE WS-FZ = WS-Z0 - 48
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-KIND
     MOVE "minecraft:end_crystal" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CRYSTAL-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:obsidian" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-OBSIDIAN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-X = PL-X(WS-PLAYER) + 20
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 4
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "DRAGON-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
*>   The tracker health is the ceiling of the exact health.
     MOVE 150.5 TO DG-HP
     CALL "DRAGON-HEALTH-SYNC" USING WS-ROW
     MOVE "covB 21 6.4 a fractional exact health shows rounded up on the tracker row" TO TL-CASE
     MOVE 151 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 200 TO DG-HP
*>   Without an attacker the nearest part is the body.
     CALL "DRAGON-PART-NEAR" USING WS-ROW WS-NO WS-PART
     MOVE "covB 21 6.4 with no attacker the body (part 3) takes the damage" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-PART TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A crystal 5 blocks from the dragon: the rescan (1 in 10 per tick) finds it as the nearest.
     COMPUTE WS-X = EN-X(WS-ROW) + 5
     MOVE EN-Y(WS-ROW) TO WS-Y
     MOVE EN-Z(WS-ROW) TO WS-Z
     CALL "CRYSTAL-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-NO WS-CROW
     MOVE 0 TO DG-CRYSTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR DG-CRYSTAL > 0
         CALL "DRAGON-HEAL" USING WS-ROW
     END-PERFORM
     MOVE "covB 21 6.4 the dragon's rescan finds the crystal within 32 blocks" TO TL-CASE
     MOVE EN-ID(WS-CROW) TO TL-EXPECTED-N
     MOVE DG-CRYSTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Destroying that crystal with no destroyer: the nearest player within 64 is the one who gets strafed.
     MOVE 0 TO DG-PHASE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "DRAGON-CRYSTAL-DESTROYED" USING EN-ID(WS-CROW) WS-NO WS-X WS-Y WS-Z
     MOVE "covB 44-9 1.1 a circling dragon strafes the nearest player when nobody is named" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Wing contact: a cow standing in the left wing box is pushed up and away, and hurt.
     MOVE 0 TO DG-PHASE
     MOVE 100 TO DG-TICK
     MOVE 0 TO DG-HURT-T
     MOVE 3 TO PL-MODE(WS-PLAYER)
     CALL "DRAGON-PARTS" USING WS-ROW
     MOVE DG-PART-X(7) TO WS-X
     MOVE DG-PART-Y(7) TO WS-Y
     MOVE DG-PART-Z(7) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-X WS-Y WS-Z WS-YAW WS-COW
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     MOVE 0 TO EN-VX(WS-COW) EN-VY(WS-COW) EN-VZ(WS-COW)
     CALL "DRAGON-CONTACT" USING WS-ROW
     MOVE "covB 21 6.4 a mob in a wing box is hurt" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HEALTH(WS-COW) < WS-HEALTH0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 21 6.4 and pushed up by 0.2" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-COW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A row that is not the dragon is not stepped.
     MOVE DG-TICK TO WS-I
     CALL "DRAGON-STEP" USING WS-COW
     MOVE "covB 21 6.4 the dragon step ignores another row" TO TL-CASE
     MOVE WS-I TO TL-EXPECTED-N
     MOVE DG-TICK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The death of the dragon of a fight whose dragon was never killed before: the fight is told at tick 200.
     INITIALIZE END-FIGHT
     MOVE 20 TO EF-GATEWAY-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         COMPUTE EF-GATEWAY(WS-I) = WS-I - 1
     END-PERFORM
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     MOVE 1 TO DG-FIGHT
     MOVE 199 TO DG-DEATH-T
     CALL "DRAGON-DEATH" USING WS-ROW
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "covB 21 6.4.4 the first kill's death sequence ends by telling the fight (killed 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EF-KILLED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Placing a crystal: a block above the base, or a solid cell two above it, refuses.
     COMPUTE WS-BX = WS-X0 - 10
     MOVE WS-Y0 TO WS-BY
     MOVE WS-Z0 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-OBSIDIAN
     COMPUTE WS-SLOT = PL-HELD(WS-PLAYER) + 1
     MOVE WS-CRYSTAL-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-SLOT)
     COMPUTE WS-BY = WS-Y0 + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE WS-Y0 TO WS-BY
     CALL "CRYSTAL-PLACE" USING WS-PLAYER WS-BX WS-BY WS-BZ WS-PLACED
     MOVE "covB 11.1 a block directly above the base refuses the crystal" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-Y0 + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-Y0 + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE WS-Y0 TO WS-BY
     CALL "CRYSTAL-PLACE" USING WS-PLAYER WS-BX WS-BY WS-BZ WS-PLACED
     MOVE "covB 11.1 a solid cell two above the base refuses it too" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-DRAGON.
 COPY CORETEST.
 COPY MOBSPTEST.
