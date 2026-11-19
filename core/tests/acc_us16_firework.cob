*> Acceptance test, the firework rocket (docs/protocol/21 section 8.7, 17 section 3.13; lane 002-lane-mobsb6, T9005): lifetime 10 x (flight duration + 1) + nextInt(6) + nextInt(7), initial velocity
*> (0, 0.05, 0), the explosion with Entity Event 17 after the lifetime, damage 5 + 2 per star to the attached entity and D x sqrt((5 - distance) / 5) within 5 blocks, none without stars.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-FIREWORK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PIG                 BINARY-LONG.
 01 WS-PIG2                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DURATION            BINARY-LONG VALUE 2.
 01 WS-STARS               BINARY-LONG VALUE 1.
 01 WS-ATTACHED            BINARY-LONG VALUE 0.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-H1                  BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-HP                  FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 12
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 10
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG
     COMPUTE WS-X = WS-X + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG2
     COMPUTE WS-X = WS-X - 4.5
     COMPUTE WS-Y = WS-Y + 0.225
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-ATTACHED WS-OWNER WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 21 8.7 flight duration 2 gives a lifetime of 30 to 41 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I2(WS-SLOT) >= 30 AND PJ-I2(WS-SLOT) <= 41
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 8.7 the rocket starts at vy 0.05" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Put it back at the pig's mid height, 1.5 blocks from the first pig, and let it run out.
     COMPUTE EN-X(WS-ROW) = EN-X(WS-PIG) + 1
     COMPUTE EN-Y(WS-ROW) = EN-Y(WS-PIG) + 0.45
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     MOVE EN-Z(WS-PIG) TO EN-Z(WS-ROW)
*>   Shot at an angle (PJ-I5 1): it does not accelerate (21 section 8.7), so it stays at the pig's height until it explodes.
     MOVE 1 TO PJ-I5(WS-SLOT)
     MOVE PJ-I2(WS-SLOT) TO WS-I
     MOVE EN-HEALTH(WS-PIG) TO WS-H1
     MOVE EN-HEALTH(WS-PIG2) TO WS-H2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-I2(WS-SLOT) OR EN-USED(WS-ROW) = 0
         CALL "FIREWORK-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US16 21 8.7 it is still flying at the lifetime" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FIREWORK-STEP" USING WS-ROW
     MOVE "acceptance US16 21 8.7 one tick later it explodes and is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 8.7 a pig 1 block away takes 7 x sqrt(0.8) = 6 (rounded)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H1 - EN-HEALTH(WS-PIG)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 8.7 a pig 2 blocks away takes 7 x sqrt(0.6) = 5 (rounded)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H2 - EN-HEALTH(WS-PIG2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 8.7 the player 12 blocks away is untouched" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without stars there is no damage; the attached entity takes the full amount and is skipped by the area pass.
     MOVE EN-HEALTH(WS-PIG) TO WS-H1
     MOVE 0 TO WS-STARS
     MOVE EN-X(WS-PIG) TO WS-X
     MOVE EN-Y(WS-PIG) TO WS-Y
     MOVE EN-Z(WS-PIG) TO WS-Z
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-ATTACHED WS-OWNER WS-ROW
     CALL "FIREWORK-EXPLODE" USING WS-ROW
     MOVE "acceptance US16 21 8.7 a rocket with no explosion star hurts nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H1 - EN-HEALTH(WS-PIG)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-STARS
     MOVE EN-ID(WS-PIG) TO WS-ATTACHED
     MOVE 10 TO EN-HEALTH(WS-PIG)
     MOVE EN-HEALTH(WS-PIG) TO WS-H1
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-ATTACHED WS-OWNER WS-ROW
     CALL "FIREWORK-EXPLODE" USING WS-ROW
     MOVE "acceptance US16 21 8.7 the attached pig takes the full 7 (5 + 2 x 1)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H1 - EN-HEALTH(WS-PIG)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A player in range is hurt by the same rule.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO WS-ATTACHED
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-ATTACHED WS-OWNER WS-ROW
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HP
     CALL "FIREWORK-EXPLODE" USING WS-ROW
     MOVE "acceptance US16 21 8.7 a player at the rocket is hurt (health drops)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) < WS-HP
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-FIREWORK.
 COPY CORETEST.
 COPY MOBSPTEST.
