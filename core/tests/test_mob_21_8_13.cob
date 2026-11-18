*> Thrown experience bottle and ExperienceOrb.awardWithDirection (docs/protocol/21 sections 8.13 and 8.2, 44-8 section 10.4, 25-6 section 10.1; lane p49f, T21000 to T21020): the amount 3 + nextInt(5)
*> + nextInt(5), the direction of a spawned orb (reversed against the direction, moved 0.25 along its velocity), the throw by a player (offset -20 degrees, speed 0.7, one bottle used), the flight
*> (gravity 0.07), a hit of the floor (level events 2002 and 1053, orbs worth 3 to 11 along the face normal, the bottle gone) and of a wall.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROJSTATE.
 01 WS-CASE                PIC X(120).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BOTTLE-ITEM         BINARY-LONG.
 01 WS-BOTTLE-TYPE         BINARY-LONG.
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DISTINCT            BINARY-LONG.
 01 WS-SEEN                BINARY-LONG OCCURS 12 TIMES.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-PJ                  BINARY-LONG VALUE 40.
 01 WS-ORBS                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-POSITIVE            BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STACK-BEFORE        BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HELD                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     CALL "XP-ORB-TYPE" USING WS-ORB-TYPE
     MOVE "minecraft:experience_bottle" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BOTTLE-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BOTTLE-ITEM WS-ITEM-ROW WS-STATUS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
*>   The amount: 3 + nextInt(5) + nextInt(5) is 3 to 11 and uses more than four values over many draws.
     MOVE 99 TO WS-MIN
     MOVE 0 TO WS-MAX WS-DISTINCT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE 0 TO WS-SEEN(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         CALL "XP-BOTTLE-AMOUNT" USING WS-AMOUNT
         IF WS-AMOUNT < WS-MIN
             MOVE WS-AMOUNT TO WS-MIN
         END-IF
         IF WS-AMOUNT > WS-MAX
             MOVE WS-AMOUNT TO WS-MAX
         END-IF
         IF WS-AMOUNT >= 1 AND WS-AMOUNT <= 12
             MOVE 1 TO WS-SEEN(WS-AMOUNT)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         ADD WS-SEEN(WS-I) TO WS-DISTINCT
     END-PERFORM
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 the amount is never below 3" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MIN >= 3
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 the amount is never above 11" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAX <= 11
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 the amount takes at least six of its nine values" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DISTINCT >= 6
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   awardWithDirection: the spawn velocity points along the direction.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 10
     COMPUTE WS-Y = WS-FY + 2
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 10
     MOVE 0 TO WS-DX WS-DZ
     MOVE -1 TO WS-DY
     MOVE 1 TO WS-POSITIVE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "XP-ORB-SPAWN-DIR" USING WS-DIM WS-X WS-Y WS-Z WS-I WS-DX WS-DY WS-DZ WS-ROW
         IF EN-VY(WS-ROW) > 0.0000001
             MOVE 0 TO WS-POSITIVE
         END-IF
         COMPUTE WS-DIST = FUNCTION SQRT((EN-X(WS-ROW) - WS-X) ** 2 + (EN-Y(WS-ROW) - WS-Y) ** 2 + (EN-Z(WS-ROW) - WS-Z) ** 2)
         IF FUNCTION ABS(WS-DIST - 0.25) > 0.000001
             MOVE 2 TO WS-POSITIVE
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§8.2 awardWithDirection: against a downward direction no orb rises (velocity reversed)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-POSITIVE TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-POSITIVE
     MOVE 1 TO WS-DY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "XP-ORB-SPAWN-DIR" USING WS-DIM WS-X WS-Y WS-Z WS-I WS-DX WS-DY WS-DZ WS-ROW
         IF EN-VY(WS-ROW) < 0
             MOVE 0 TO WS-POSITIVE
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§8.2 awardWithDirection: along an upward direction every orb keeps rising" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-POSITIVE TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.2 awardWithDirection: the orb is moved 0.25 along its velocity (30 orbs)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 1 TO WS-O
     MOVE -1 TO WS-DY
     CALL "XP-ORB-SPAWN-DIR" USING WS-DIM WS-X WS-Y WS-Z WS-AMOUNT WS-DX WS-DY WS-DZ WS-ROW
     COMPUTE WS-DIST = FUNCTION SQRT((EN-X(WS-ROW) - WS-X) ** 2 + (EN-Y(WS-ROW) - WS-Y) ** 2 + (EN-Z(WS-ROW) - WS-Z) ** 2)
     IF FUNCTION ABS(WS-DIST - 0.25) > 0.000001
         MOVE 0 TO WS-O
     END-IF
     CALL "ENTITY-REMOVE" USING WS-ROW
     PERFORM CHECK-N
*>   Without a direction the orb stays where it is.
     MOVE 0 TO WS-DY
     CALL "XP-ORB-SPAWN-DIR" USING WS-DIM WS-X WS-Y WS-Z WS-AMOUNT WS-DX WS-DY WS-DZ WS-ROW
     MOVE "acceptance US15 21§8.2 awardWithDirection: the zero vector leaves the orb at the position" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-ROW) = WS-X AND EN-Y(WS-ROW) = WS-Y AND EN-Z(WS-ROW) = WS-Z
         MOVE 1 TO WS-O
     END-IF
     CALL "ENTITY-REMOVE" USING WS-ROW
     PERFORM CHECK-N
*>   A player throws a bottle: Use Item with it in the main hand.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
     MOVE WS-BOTTLE-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-BOTTLE-TYPE
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 minecraft:experience_bottle 25§10.1 Use Item throws one bottle entity" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-ROW > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:experience_bottle 25§10.1 the throw uses one bottle of the stack" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD) TO WS-O
     PERFORM CHECK-N
     IF WS-ROW > 0
         COMPUTE WS-DIST = FUNCTION SQRT(EN-VX(WS-ROW) ** 2 + EN-VY(WS-ROW) ** 2 + EN-VZ(WS-ROW) ** 2)
         MOVE "acceptance US15 minecraft:experience_bottle 25§10.1 the throw speed is 0.7 (millionths)" TO WS-CASE
         MOVE 700000 TO WS-E
         COMPUTE WS-O = FUNCTION INTEGER(WS-DIST * 1000000 + 0.5)
         PERFORM CHECK-N
         MOVE "acceptance US15 minecraft:experience_bottle 25§10.1 the bottle is a PJ-KIND 40 entry" TO WS-CASE
         MOVE 40 TO WS-E
         CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
         MOVE 0 TO WS-O
         IF WS-SLOT > 0
             MOVE PJ-KIND(WS-SLOT) TO WS-O
         END-IF
         PERFORM CHECK-N
         CALL "PJ-DROP" USING WS-ROW
     END-IF
*>   Flight: gravity 0.07 then drag 0.99 on a bottle that was thrown level.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 10
     COMPUTE WS-Y = WS-FY + 20
     COMPUTE WS-Z = PL-Z(WS-PLAYER)
     MOVE 0 TO WS-VX WS-VY WS-VZ
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-OWNER
     CALL "THROWN-SPAWN" USING WS-PJ WS-KEY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     CALL "XP-BOTTLE-STEP" USING WS-ROW
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 gravity 0.07 then drag 0.99: the first tick's vertical speed is -0.0693 (ten-thousandths)" TO WS-CASE
     MOVE -693 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VY(WS-ROW) * 10000 + 0.5)
     PERFORM CHECK-N
     CALL "PJ-DROP" USING WS-ROW
*>   A hit of the floor: drop the bottle onto the stone floor, one cell above it.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 10
     COMPUTE WS-Y = WS-FY + 1.9
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 10
     MOVE 0 TO WS-VX WS-VZ
     MOVE -0.5 TO WS-VY
     CALL "THROWN-SPAWN" USING WS-PJ WS-KEY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-LEFT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "THROWN-TICK"
     END-PERFORM
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 the viewer gets the two level events (2002 and 1053)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     MOVE 0 TO WS-J
     INSPECT WS-IDS TALLYING WS-J FOR ALL "47x2"
     IF WS-J > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 a hit removes the bottle and its PROJSTATE entry" TO WS-CASE
     MOVE 0 TO WS-E
     CALL "PJ-FIND" USING WS-LEFT WS-SLOT
     MOVE WS-SLOT TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-ORBS WS-TOTAL WS-POSITIVE
     MOVE 1 TO WS-POSITIVE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE AND EN-DIM(WS-I) = WS-DIM
             ADD 1 TO WS-ORBS
             COMPUTE WS-TOTAL = WS-TOTAL + EN-ITEM(WS-I) * EN-ITEM-COUNT(WS-I)
             IF EN-VY(WS-I) < 0
                 MOVE 0 TO WS-POSITIVE
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 the orbs of a hit are worth 3 to 11 together" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TOTAL >= 3 AND WS-TOTAL <= 11
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 a floor hit directs the orbs up (none falls)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-POSITIVE TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
*>   A wall: a stone column east of the bottle; the bottle flies east and hits its west face (normal -x).
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 6
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
         COMPUTE WS-BY = WS-FY + WS-J
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     END-PERFORM
     COMPUTE WS-X = WS-BX - 2.3
     COMPUTE WS-Y = WS-FY + 3.5
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE 0.6 TO WS-VX
     MOVE 0 TO WS-VY WS-VZ
     MOVE "minecraft:experience_bottle" TO WS-KEY
     CALL "THROWN-SPAWN" USING WS-PJ WS-KEY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "THROWN-TICK"
     END-PERFORM
     MOVE 1 TO WS-POSITIVE
     MOVE 0 TO WS-ORBS WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE AND EN-DIM(WS-I) = WS-DIM
             ADD 1 TO WS-ORBS
             COMPUTE WS-TOTAL = WS-TOTAL + EN-ITEM(WS-I) * EN-ITEM-COUNT(WS-I)
             IF EN-VX(WS-I) > 0.0000001
                 MOVE 0 TO WS-POSITIVE
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 a wall hit also pays 3 to 11" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TOTAL >= 3 AND WS-TOTAL <= 11
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:experience_bottle 21§8.13 a hit on a west face directs the orbs west (none flies east)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-POSITIVE TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-13.
 COPY CORETEST.
 COPY MOBSPTEST.
