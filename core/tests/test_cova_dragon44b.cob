*> Implementation test (coverage lane A; docs/protocol/21 section 6.4.3, 44 part 9 section 1): the strafe phase with a vanished player, the target put on the player when the path is done, the new
*> target when the old one is reached and the charge falling while the player is far; the holding pattern that keeps its target; the next ring node of a strafing dragon; the breath cloud that
*> lands on the first solid cell; the fireball's own step until it bursts into a cloud; the approach with a player near; the takeoff's second tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-DRAGON44B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY DRAGSTATE.
 COPY FIGHTRT.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CLOUDS0             BINARY-LONG.
 01 WS-CLOUDS1             BINARY-LONG.
 01 WS-BALL                BINARY-LONG.
 01 WS-BROW                BINARY-LONG.
 01 WS-BSLOT               BINARY-LONG.
 01 WS-YO                  FLOAT-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND1               BINARY-LONG VALUE 1.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
*>   The podium column and the dragon.
     MOVE 0 TO WS-SX WS-SZ
     MOVE 200 TO WS-SY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STONE
     MOVE 0 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "DRAGON-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE 0 TO FR-CRYSTALS
     MOVE 900 TO PL-X(WS-PLAYER)
     MOVE 900 TO PL-Z(WS-PLAYER)
*>   A strafing dragon at the end of its ring path takes the next ring node (the strafing direction flag is DG-SCW).
     MOVE 1 TO DG-PHASE
     MOVE 0 TO DG-HAS-PATH
     MOVE 0 TO DG-PATH-I
     CALL "DRAGON-FIND-NEW" USING WS-ROW
     MOVE "test cova dragon44b a strafing dragon without a path gets a ring path" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE DG-HAS-PATH TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The holding pattern keeps a target that is neither reached (10 blocks) nor beyond 150 nor in a wall.
     MOVE 0 TO DG-PHASE
     MOVE 0 TO DG-HAS-PATH
     MOVE 1 TO DG-HAS-TARGET
     MOVE 0 TO DG-WALL
     COMPUTE DG-TX = EN-X(WS-ROW) + 50
     MOVE EN-Y(WS-ROW) TO DG-TY
     MOVE EN-Z(WS-ROW) TO DG-TZ
     CALL "DRAGON-HOLD" USING WS-ROW
     MOVE "test cova dragon44b a holding dragon with a valid target keeps its phase and target" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF DG-PHASE = 0 AND DG-HAS-PATH = 0 AND DG-HAS-TARGET = 1
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The breath cloud lands on the first solid cell below the point 2.5 blocks ahead of the head.
     CALL "DRAGON-PARTS" USING WS-ROW
     COMPUTE WS-SX = FUNCTION INTEGER(DG-PART-X(1))
     COMPUTE WS-SZ = FUNCTION INTEGER(DG-PART-Z(1) - 2.5)
     COMPUTE WS-SY = FUNCTION INTEGER(DG-PART-Y(1)) - 6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STONE
     MOVE 0 TO EN-YAW(WS-ROW)
     MOVE 0 TO WS-CLOUDS0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-CLOUDS0
         END-IF
     END-PERFORM
     CALL "DRAGON-BREATH" USING WS-ROW
     MOVE 0 TO WS-CLOUDS1
     MOVE 0 TO WS-BSLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-CLOUDS1
             MOVE WS-I TO WS-BSLOT
         END-IF
     END-PERFORM
     MOVE "test cova dragon44b the breath makes one more cloud" TO WS-CASE
     COMPUTE WS-E = WS-CLOUDS0 + 1
     MOVE WS-CLOUDS1 TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO WS-BROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = PJ-ENT(WS-BSLOT)
             MOVE WS-I TO WS-BROW
         END-IF
     END-PERFORM
     MOVE "test cova dragon44b the cloud rests on the stone cell found below (y one above it, mm)" TO WS-CASE
     COMPUTE WS-E = (WS-SY + 1) * 1000
     COMPUTE WS-O ROUNDED = EN-Y(WS-BROW) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A fireball sent down at a player 20 blocks below accelerates and bursts into a cloud on the floor.
     COMPUTE WS-FY = FUNCTION INTEGER(DG-PART-Y(1)) - 22
     COMPUTE WS-FX = FUNCTION INTEGER(DG-PART-X(1)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(DG-PART-Z(1)) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND1
     COMPUTE PL-X(WS-PLAYER) = DG-PART-X(1) + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FY + 1
     COMPUTE PL-Z(WS-PLAYER) = DG-PART-Z(1) - 1.5
     MOVE 0 TO WS-CLOUDS0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-CLOUDS0
         END-IF
     END-PERFORM
     CALL "DRAGON-FIREBALL" USING WS-ROW WS-PLAYER
     MOVE 0 TO WS-BROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 18
             MOVE PJ-ENT(WS-I) TO WS-BALL
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = WS-BALL
             MOVE WS-I TO WS-BROW
         END-IF
     END-PERFORM
     MOVE 0 TO WS-BSLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-BSLOT = 1
         CALL "DFIRE-STEP" USING WS-BROW
         IF EN-USED(WS-BROW) = 0 OR EN-ID(WS-BROW) NOT = WS-BALL
             MOVE 1 TO WS-BSLOT
         END-IF
     END-PERFORM
     MOVE "test cova dragon44b a fireball that hits the floor is gone" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-BSLOT TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO WS-CLOUDS1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-CLOUDS1
         END-IF
     END-PERFORM
     MOVE "test cova dragon44b the burst fireball leaves a cloud" TO WS-CASE
     COMPUTE WS-E = WS-CLOUDS0 + 1
     MOVE WS-CLOUDS1 TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The strafe: a vanished player (slot not in use) ends it in the holding pattern.
     MOVE 1 TO DG-PHASE
     MOVE 2 TO DG-PROW
     CALL "DRAGON-STRAFE" USING WS-ROW
     MOVE "test cova dragon44b a strafe whose player slot is gone returns to the holding pattern" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = DG-PHASE + DG-PROW
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A player 70 blocks away with the path done: the target is above the player by min(0.4 + h / 80 - 1, 10); beyond 64 blocks the charge falls.
     MOVE 1 TO DG-PHASE
     MOVE WS-PLAYER TO DG-PROW
     MOVE 70 TO PL-X(WS-PLAYER)
     MOVE 100 TO PL-Y(WS-PLAYER)
     MOVE 0 TO PL-Z(WS-PLAYER)
     MOVE 0 TO EN-X(WS-ROW)
     MOVE 100 TO EN-Y(WS-ROW)
     MOVE 0 TO EN-Z(WS-ROW)
     MOVE 1 TO DG-HAS-PATH
     MOVE 3 TO DG-PATH-I
     MOVE 2 TO DG-PATH-N
     MOVE 3 TO DG-CHARGE
     CALL "DRAGON-STRAFE" USING WS-ROW
     MOVE "test cova dragon44b a strafe at the end of its path aims above the player (target y mm)" TO WS-CASE
     COMPUTE WS-YO = 0.4 + 70 / 80 - 1
     COMPUTE WS-E ROUNDED = (100 + WS-YO) * 1000
     COMPUTE WS-O ROUNDED = DG-TY * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova dragon44b a strafe with the player 70 blocks away lets the charge fall by one" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE DG-CHARGE TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A player 30 blocks away behind a stone wall is not seen: no charge is gained and an existing one falls.
     MOVE 15 TO WS-SX
     PERFORM VARYING WS-SY FROM 90 BY 1 UNTIL WS-SY > 110
         PERFORM VARYING WS-SZ FROM -10 BY 1 UNTIL WS-SZ > 10
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STONE
         END-PERFORM
     END-PERFORM
     MOVE 30 TO PL-X(WS-PLAYER)
     MOVE 100 TO PL-Y(WS-PLAYER)
     MOVE 0 TO PL-Z(WS-PLAYER)
     MOVE 1 TO DG-HAS-TARGET
     MOVE 50 TO DG-TX
     MOVE 100 TO DG-TY
     MOVE 0 TO DG-TZ
     MOVE 0 TO DG-HAS-PATH
     MOVE 3 TO DG-CHARGE
     MOVE 1 TO DG-PHASE
     CALL "DRAGON-STRAFE" USING WS-ROW
     MOVE "test cova dragon44b a strafe with the player behind a wall lets the charge fall by one" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE DG-CHARGE TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The strafe whose target is reached asks for a new one.
     MOVE 0 TO DG-HAS-PATH
     MOVE 0 TO DG-HAS-TARGET
     MOVE 0 TO DG-PATH-I
     CALL "DRAGON-STRAFE" USING WS-ROW
     MOVE "test cova dragon44b a strafe with no target gets a new ring path" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE DG-HAS-PATH TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The landing approach with a player near the podium aims the path away from the player.
     MOVE 2 TO DG-PHASE
     MOVE 0 TO DG-HAS-PATH
     MOVE 0 TO DG-HAS-TARGET
     MOVE 30 TO PL-X(WS-PLAYER)
     MOVE 201 TO PL-Y(WS-PLAYER)
     MOVE 0 TO PL-Z(WS-PLAYER)
     CALL "DRAGON-APPROACH" USING WS-ROW
     MOVE "test cova dragon44b a landing approach with a player near finds a path" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE DG-HAS-PATH TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The takeoff's second tick with no target left steers again and, far from the podium, ends in the holding pattern.
     MOVE 4 TO DG-PHASE
     MOVE 1 TO DG-CHARGE-T
     MOVE 0 TO DG-HAS-TARGET
     MOVE 0 TO EN-X(WS-ROW)
     MOVE 100 TO EN-Y(WS-ROW)
     MOVE 0 TO EN-Z(WS-ROW)
     CALL "DRAGON-TAKEOFF" USING WS-ROW
     MOVE "test cova dragon44b a takeoff 100 blocks under the podium sets the holding pattern" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE DG-PHASE TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-DRAGON44B.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
