*> Acceptance test, the Wither boss bar (docs/protocol/21 section 7.3, 44 part 9 section 10; lane 002-lane-mobsb8, T9740): players within 160 blocks of the Wither are on its bar (Boss Event ADD),
*> progress 1 - remaining / 220 while it spawns then health / 300 (UPDATE_PROGRESS on change), a player out of range gets REMOVE and everybody does when it dies.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-WITHER-BAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HAS                 BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE 100 TO PL-X(WS-PLAYER)
     MOVE 150 TO PL-Y(WS-PLAYER)
     MOVE 100 TO PL-Z(WS-PLAYER)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 110 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 100 TO WS-Z
     CALL "WITHER-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     CALL "WITHER-STEP" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-HAS
     INSPECT WS-IDS TALLYING WS-HAS FOR ALL "9 "
     IF WS-IDS(1:1) = "9" AND (WS-IDS(2:1) = " " OR WS-IDS(2:1) = "x")
         MOVE 1 TO WS-HAS
     END-IF
     MOVE "acceptance US16 21 7.3 a player near the Wither is sent the boss bar (Boss Event 9)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HAS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 7.3 the bar has one member" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF PJ-V-ENT(WS-SLOT, WS-I) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Progress while spawning: 110 of 220 ticks left is 500.
     MOVE 111 TO PJ-I1(WS-SLOT)
     CALL "WITHER-STEP" USING WS-ROW
     MOVE "acceptance US16 21 7.3 progress during the spawn is 1 - remaining / 220 (500 at 110 left)" TO TL-CASE
     MOVE 501 TO TL-EXPECTED-N
     MOVE PJ-I8(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US16 21 7.3 a progress change is sent (Boss Event 9 again)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-IDS(1:1) = "9"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Afterwards the progress is health / 300.
     MOVE 0 TO PJ-I1(WS-SLOT)
     MOVE 150 TO EN-HEALTH(WS-ROW)
     CALL "WITHER-STEP" USING WS-ROW
     MOVE "acceptance US16 21 7.3 after the spawn progress is health / 300 (150 is 500)" TO TL-CASE
     MOVE 501 TO TL-EXPECTED-N
     MOVE PJ-I8(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
*>   Out of range: REMOVE.
     MOVE 2000 TO PL-X(WS-PLAYER)
     CALL "WITHER-STEP" USING WS-ROW
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF PJ-V-ENT(WS-SLOT, WS-I) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 7.3 a player beyond 160 blocks leaves the bar" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Death: everyone on the bar gets REMOVE.
     MOVE 100 TO PL-X(WS-PLAYER)
     CALL "WITHER-STEP" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "WITHER-DEATH" USING WS-ROW WS-HANDLED
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US16 21 7.3 the Wither's death removes the bar from its players (Boss Event sent)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-IDS(1:1) = "9"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-WITHER-BAR.
 COPY CORETEST.
 COPY MOBSPTEST.
