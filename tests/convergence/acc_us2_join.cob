*> Convergence acceptance test of US2-3 (spec.md US2; standin-content §5.2 spawn point, markers):
*> a first-time Player joins a running server (the server program's loop on loopback, in process)
*> through the client's server list, and the client's camera and world replica show the world
*> spawn point: feet at (4.5, 54, 8.5) in cobolcraft:main facing east (yaw -90, pitch 0) on turf,
*> the marker pillar (cardstack, cardstack, punched cardstack, lucite, lit glowtube) at
*> (8, 55-59, 8), four blocks ahead.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US2-JOIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us2-join".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 19.
 01 WS-CONF                PIC X(1024)
     VALUE "view-distance=2|hostile-mobs=false|default-game-mode=survival".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-F1                  PIC -(4)9.9.
 01 WS-F2                  PIC -(4)9.9.
 01 WS-F3                  PIC -(4)9.9.
 01 WS-F4                  PIC -(4)9.9.
 01 WS-F5                  PIC -(4)9.9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     CALL "CV-JOIN" USING CONVH WS-ALICE CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "CV-STEPS" USING CONVH WS-TEN
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

     MOVE "acceptance US2-3 given a running server and a first-time Player when the Player joins "
         & "then they are at the world spawn point in the main dimension facing east" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "joined 1 screen 5 cobolcraft:main at 4.5/54.0/8.5 yaw -90.0 pitch 0.0" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     COMPUTE WS-F1 ROUNDED = PL-X
     COMPUTE WS-F2 ROUNDED = PL-Y
     COMPUTE WS-F3 ROUNDED = PL-Z
     COMPUTE WS-F4 ROUNDED = PL-YAW
     COMPUTE WS-F5 ROUNDED = PL-PITCH
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "joined " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE SM-SCREEN TO WS-E1
     STRING " screen " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(PL-DIM-NAME)
         " at " FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/" FUNCTION TRIM(WS-F3)
         " yaw " FUNCTION TRIM(WS-F4) " pitch " FUNCTION TRIM(WS-F5)
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The replica: turf under the feet, the pillar four blocks ahead (east, +X).
     MOVE "acceptance US2-3 the Player stands on turf with the marker pillar (two unpunched "
         & "cardstacks, a punched cardstack, lucite, a lit glowtube) four blocks ahead" TO TL-CASE
     MOVE "feet 4 pillar 9 9 8 12 13 above 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 4 TO WS-X
     MOVE 53 TO WS-Y
     MOVE 8 TO WS-Z
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E1
     STRING "feet " FUNCTION TRIM(WS-E1) " pillar" DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE 8 TO WS-X
     PERFORM VARYING WS-Y FROM 55 BY 1 UNTIL WS-Y > 60
         CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
         MOVE WS-STATE TO WS-E1
         IF WS-Y = 60
             STRING " above" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CV-SERVER-STOP" USING CONVH
     STOP RUN.
 END PROGRAM ACC-US2-JOIN.
