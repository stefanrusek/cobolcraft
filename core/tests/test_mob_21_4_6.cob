*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.6 with doc 44 part 7 sections 4.2 and 6): the dolphin. It swims in water (accelerating 0.02 x speed 1.2 along its
*> heading), never attacks a player, dries out (moistness 2400: 1 damage a tick from the 2400th dry tick) and hops when dry on the ground (velocity + 0.5 up). Left open: babies, the
*> treasure, swim-with-player, jump and item goals, breathing, Dolphin's Grace.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-6.
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
 01 WS-DOLPHIN             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-LASTX               FLOAT-LONG.
 01 WS-LASTZ               FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-BIG                 FLOAT-LONG.
 01 WS-MAXVY               FLOAT-LONG.
 01 WS-HEALTH              FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:dolphin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-DOLPHIN WS-ENTITY-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     COMPUTE WS-X = WS-X0 + 5.0
     COMPUTE WS-Y = WS-Y0 + 3.0
     COMPUTE WS-Z = WS-Z0 + 5.0
     CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-X TO WS-MINX WS-MAXX WS-LASTX
     MOVE WS-Z TO WS-MINZ WS-MAXZ WS-LASTZ
     MOVE 0 TO WS-BIG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 500
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE WS-MINX = FUNCTION MIN(WS-MINX, EN-X(WS-ROW))
         COMPUTE WS-MAXX = FUNCTION MAX(WS-MAXX, EN-X(WS-ROW))
         COMPUTE WS-MINZ = FUNCTION MIN(WS-MINZ, EN-Z(WS-ROW))
         COMPUTE WS-MAXZ = FUNCTION MAX(WS-MAXZ, EN-Z(WS-ROW))
         COMPUTE WS-STEP = FUNCTION ABS(EN-X(WS-ROW) - WS-LASTX) + FUNCTION ABS(EN-Z(WS-ROW) - WS-LASTZ)
         COMPUTE WS-BIG = FUNCTION MAX(WS-BIG, WS-STEP)
         MOVE EN-X(WS-ROW) TO WS-LASTX
         MOVE EN-Z(WS-ROW) TO WS-LASTZ
     END-PERFORM
     MOVE "acceptance US15 21§4.6 a dolphin swims across its water, 3 blocks or more in 500 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF (WS-MAXX - WS-MINX) + (WS-MAXZ - WS-MINZ) >= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.6 and never faster than 0.5 blocks a tick" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BIG > 0.05 AND WS-BIG < 0.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
*>   It does not fight: standing in the player's cell for 60 ticks changes nothing.
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-ROW)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-ROW)
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-ROW)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§4.6 a dolphin has no target goal for players: the player's health is unchanged" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) = WS-HEALTH
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Dry on the ground: it hops, and the 2400th dry tick hurts.
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-Y0 + 3
     COMPUTE WS-Z = WS-Z0 + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO WS-MAXVY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE WS-MAXVY = FUNCTION MAX(WS-MAXVY, EN-VY(WS-ROW))
     END-PERFORM
     MOVE "acceptance US15 44-7§4.2 a dry dolphin on the ground hops: velocity + 0.5 up" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAXVY > 0.3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 2398 TO EN-DRY(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.6 moistness above 0: no damage yet (health 10)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.6 moistness 0: the dolphin takes 1 damage (10 to 9)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-6.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
