*> Acceptance test (lane p49r; docs/protocol/20 section 16.2): the spread of the breeze's shot. Projectile.shoot adds to the unit aim a triangular error of 0.0172275 x u per component, u = 5 - 4 x the
*> difficulty id (Easy 1, Normal -3, Hard -7), and scales by 0.699999988079071; 200 shots at each difficulty stay within the bound 0.0172275 |u| of every component and reach at least 40 percent of it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-16-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-DEV                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-BOUND               FLOAT-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-TEXT                PIC X(60).
 01 WS-DTEXT               PIC 9.
 01 WS-OK                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:breeze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X0 = WS-X - 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
         MOVE WS-D TO BW-DIFFICULTY
         COMPUTE WS-U = 5 - 4 * WS-D
         COMPUTE WS-BOUND = 0.0172275 * FUNCTION ABS(WS-U)
*>       The unit aim from the firing point (y + 0.885 + 0.3) to the target's (y + 0.54).
         COMPUTE WS-DX = PL-X(WS-PLAYER) - EN-X(WS-MOB)
         COMPUTE WS-DY = PL-Y(WS-PLAYER) + 0.54 - (EN-Y(WS-MOB) + 0.885 + 0.3)
         COMPUTE WS-DZ = PL-Z(WS-PLAYER) - EN-Z(WS-MOB)
         COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
         MOVE 0 TO WS-MAX WS-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
             CALL "BREEZE-FIRE" USING WS-MOB WS-PLAYER WS-CHARGE
             COMPUTE WS-DEV = FUNCTION ABS(EN-VX(WS-CHARGE) / 0.699999988079071 - WS-DX / WS-LEN)
             IF WS-DEV > WS-MAX
                 MOVE WS-DEV TO WS-MAX
             END-IF
             COMPUTE WS-DEV = FUNCTION ABS(EN-VY(WS-CHARGE) / 0.699999988079071 - WS-DY / WS-LEN)
             IF WS-DEV > WS-MAX
                 MOVE WS-DEV TO WS-MAX
             END-IF
             COMPUTE WS-DEV = FUNCTION ABS(EN-VZ(WS-CHARGE) / 0.699999988079071 - WS-DZ / WS-LEN)
             IF WS-DEV > WS-MAX
                 MOVE WS-DEV TO WS-MAX
             END-IF
             CALL "ENTITY-REMOVE" USING WS-CHARGE
         END-PERFORM
         MOVE WS-D TO WS-DTEXT
         MOVE SPACES TO WS-TEXT
         STRING "acceptance US15 20§16.2 Breeze difficulty " DELIMITED BY SIZE WS-DTEXT DELIMITED BY SIZE
             ": no component strays more than 0.0172275 |u|" DELIMITED BY SIZE INTO WS-TEXT
         MOVE WS-TEXT TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-MAX <= WS-BOUND + 0.0001
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO WS-TEXT
         STRING "acceptance US15 20§16.2 Breeze difficulty " DELIMITED BY SIZE WS-DTEXT DELIMITED BY SIZE
             ": the spread reaches 40 percent of its bound in 200 shots" DELIMITED BY SIZE INTO WS-TEXT
         MOVE WS-TEXT TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-MAX >= WS-BOUND * 0.4
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-20-16-3.
 COPY CORETEST.
 COPY MOBSPTEST.
