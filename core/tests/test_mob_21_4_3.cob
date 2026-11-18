*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.3): pufferfish inflation, for a player. A survival player within 2 blocks of its box inflates it (state 0 to 1 at once,
*> to 2 when the counter passes 40); a creative player does not; without one it deflates (the timer above 60 turns 2 into 1, above 100 turns 1 into 0); with a state above 0 a player
*> touching it takes 1 + state damage and Poison for 60 x state ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY EFFECTS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-PUFFER              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-TEXT                PIC X(1024).
 01 WS-J                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:pufferfish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PUFFER WS-ENTITY-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     COMPUTE WS-X = WS-X0 + 5.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 5.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PUFFER WS-X WS-Y WS-Z WS-YAW WS-ROW
*>   A creative player beside it does nothing.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 7
     COMPUTE PL-Y(WS-PLAYER) = WS-Y0 + 3.5
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 5.5
     PERFORM TICK
     MOVE "acceptance US15 21§4.3 a creative player does not scare a pufferfish: state 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM TICK
     MOVE "acceptance US15 21§4.3 a survival player within 2 blocks: state 1 at once" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     PERFORM TICK 39 TIMES
     MOVE "acceptance US15 21§4.3 the counter at 40: still state 1 after 40 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     PERFORM TICK
     MOVE "acceptance US15 21§4.3 the counter above 40 and state 1: state 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   The player leaves: it deflates on the timer.
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 30
     PERFORM TICK 61 TIMES
     MOVE "acceptance US15 21§4.3 no player: after 61 ticks of the timer it is still state 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     PERFORM TICK
     MOVE "acceptance US15 21§4.3 the timer above 60: state 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     PERFORM TICK 40 TIMES
     PERFORM TICK
     MOVE "acceptance US15 21§4.3 the timer above 100: state 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   A touching player is stung (damage 1 + state, Poison 60 x state).
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-ROW) + 0.5
     MOVE EN-Y(WS-ROW) TO PL-Y(WS-PLAYER)
     MOVE EN-Z(WS-ROW) TO PL-Z(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     PERFORM TICK
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE FUNCTION CONCATENATE(" ", FUNCTION TRIM(WS-TEXT), " ") TO WS-TEXT
     MOVE 0 TO WS-J
     INSPECT WS-TEXT TALLYING WS-J FOR ALL " 39 " ALL " 39x"
     MOVE "acceptance US15 21§4.3 the stung player is sent Game Event 9 (packet 39; playerTouch, 4.3)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-J > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.3 a player touching an inflated pufferfish loses health" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) < WS-HEALTH
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.3 and is poisoned for 60 x state ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 60 * EN-VARIANT(WS-ROW)
     MOVE EF-DURATION(WS-PLAYER, 19) TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 TICK.
*>   The fish keeps its place: it would swim away from the player (the fish avoid goal, 21 section 4.1), out of the 2-block range this test sets up.
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE WS-X TO EN-X(WS-ROW)
     MOVE WS-Y TO EN-Y(WS-ROW)
     MOVE WS-Z TO EN-Z(WS-ROW)
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW).
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-3.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
