*> Implementation test (coverage lane D2; core/src/minecart-44.cob): a minecart cannot be spawned while the projectile table is full (THROWN-SPAWN returns row 0), so MINECART-SPAWN
*> returns row 0 and the table stays at its limit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVD2-MINECART.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-USED                BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW
     END-PERFORM
     MOVE "test covd2 minecart the projectile table is full after PJ-MAX spawns" TO TL-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) NOT = 0
             ADD 1 TO WS-USED
         END-IF
     END-PERFORM
     MOVE PJ-MAX TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE "test covd2 minecart a spawn with the table full returns row 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVD2-MINECART.

 COPY CORETEST.
 COPY MOBSPTEST.
