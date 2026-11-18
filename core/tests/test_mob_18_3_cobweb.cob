*> Acceptance test (lane p49a; docs/protocol/18-mob-framework.md section 3.3): a cobweb in a mob's box is a makeStuckInBlock (0.25, 0.05, 0.25): the move of the tick
*> is a quarter on x and z and a twentieth on y, against the full move of the same mob without the web.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-3-COBWEB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-COW                BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-AIR                BINARY-LONG VALUE 0.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-HX                 FLOAT-LONG VALUE 0.2.
 01 WS-HZ                 FLOAT-LONG VALUE 0.
 01 WS-DX                 FLOAT-LONG.
 01 WS-DY                 FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 2
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 5
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 2
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE 6000 TO CW-TIME
     MOVE "N" TO TL-MODE

*>   Free: the full move.
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE -0.5 TO EN-VY(WS-ROW)
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     COMPUTE WS-DY = WS-Y - EN-Y(WS-ROW)
     COMPUTE WS-DX = EN-X(WS-ROW) - WS-X
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: free in the air the mob falls 0.5 and moves 0.2" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DY > 0.49 AND WS-DY < 0.51 AND WS-DX > 0.19 AND WS-DX < 0.21
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   In a cobweb: 0.025 down, 0.05 sideways.
     MOVE "minecraft:cobweb" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0.2 TO WS-HX
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE -0.5 TO EN-VY(WS-ROW)
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     COMPUTE WS-DY = WS-Y - EN-Y(WS-ROW)
     COMPUTE WS-DX = EN-X(WS-ROW) - WS-X
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: in a cobweb the fall is a twentieth (0.025)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DY > 0.024 AND WS-DY < 0.026
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 18§3.3 Collision, push and block effects: and the sideways move a quarter (0.05)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DX > 0.049 AND WS-DX < 0.051
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-3-COBWEB.
 COPY CORETEST.
 COPY MOBSPTEST.
