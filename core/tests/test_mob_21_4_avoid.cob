*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.1 with 18 section 4.2 AvoidEntityGoal): the fish's avoid-player goal, AvoidEntityGoal(Player, radius 8, walk 1.6, sprint 1.4):
*> a survival or adventure player within 8 blocks makes a fish swim away (the move speed lerps toward attribute 0.7 x 1.4 within 7 blocks and 0.7 x 1.6 beyond), a creative player or one more than 8
*> blocks away does not, and a fish that is hurt panics first. The fish moves away from the player over 40 ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-AVOID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-COD                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-START               FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-MILLI               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COD WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-Y(WS-PLAYER) = WS-Y0 + 3.5
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 4.5
*>   A survival player 6 blocks away (within 7): the speed after one tick is 0.125 x 0.7 x 1.4.
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 1.5
     COMPUTE WS-X = WS-X0 + 7.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.1 a survival player within 7 blocks: the fish swims off at modifier 1.4 (move speed 0.1225 after one tick)" TO TL-CASE
     MOVE 1225 TO TL-EXPECTED-N
     COMPUTE WS-MILLI = EN-SWIM-SPEED(WS-ROW) * 10000 + 0.5
     MOVE WS-MILLI TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   7.5 blocks away: modifier 1.6.
     COMPUTE WS-X = WS-X0 + 9.0
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.1 between 7 and 8 blocks: modifier 1.6 (0.14)" TO TL-CASE
     MOVE 1400 TO TL-EXPECTED-N
     COMPUTE WS-MILLI = EN-SWIM-SPEED(WS-ROW) * 10000 + 0.5
     MOVE WS-MILLI TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   It moves away: the fish at 3 blocks from the player (x0 + 4.5) is farther after 40 ticks.
     COMPUTE WS-X = WS-X0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     COMPUTE WS-START = EN-X(WS-ROW) - PL-X(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     COMPUTE WS-DIST = EN-X(WS-ROW) - PL-X(WS-PLAYER)
     MOVE "acceptance US15 21§4.1 the fish is at least 1.5 blocks farther from the player after 40 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIST > WS-START + 1.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A creative player and a player more than 8 blocks away do not scare it.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-X = WS-X0 + 7.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.1 a creative player does not scare it: move speed 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE WS-MILLI = EN-SWIM-SPEED(WS-ROW) * 10000 + 0.5
     MOVE WS-MILLI TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 - 5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.1 a player 12 blocks away does not scare it: move speed 0" TO TL-CASE
     COMPUTE WS-MILLI = EN-SWIM-SPEED(WS-ROW) * 10000 + 0.5
     MOVE WS-MILLI TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-AVOID.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
