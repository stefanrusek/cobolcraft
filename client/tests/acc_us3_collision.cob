*> Acceptance test of US3-2 on the client (client-surface §3; standin-content §1.1 solid blocks, §3
*> operator box 0.7 x 1.75; client/src/physics.cob): walking into a solid block stops the Player at
*> its face (horizontal collision reported), and without a block beneath they fall until they land.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US3-COLLISION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG VALUE CC-KEY-W.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THIRTY              BINARY-LONG VALUE 30.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 3.
 01 WS-STATE               BINARY-LONG VALUE 16.
 01 WS-TEXT                PIC X(1024).
 01 WS-START               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
*>   A ledger_tile wall two blocks high across the Player's path at z = 3.
     PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 11
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     END-PERFORM
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TWENTY
     MOVE SPACES TO WS-TEXT
     CALL "TEST-POSITION" USING CLIENT-STATE WS-TEXT
     STRING FUNCTION TRIM(WS-TEXT) " " PL-COLLIDED DELIMITED BY SIZE INTO WS-TEXT
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "acceptance US3-2 given a solid block ahead when the Player walks into it for 20 ticks "
         & "then they stop with their box against its face (z 3 - 0.35) and do not pass through"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0.5000/10.0000/2.6500 1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   No block beneath: the Player 5 blocks above the floor.
     MOVE 15 TO PL-Y
     MOVE 0 TO PL-ON-GROUND
     MOVE PL-Y TO WS-START
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     MOVE SPACES TO TL-OBSERVED
     IF PL-Y < WS-START AND PL-ON-GROUND = 0
         MOVE "falling" TO TL-OBSERVED
     ELSE
         MOVE "not falling" TO TL-OBSERVED
     END-IF
     CALL "TEST-TICKS" USING CLIENT-STATE WS-THIRTY
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     STRING FUNCTION TRIM(TL-OBSERVED) " " PL-ON-GROUND DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US3-2 given no block beneath the Player when time passes then they fall "
         & "until they land on the floor (y 10, on the ground)" TO TL-CASE
     MOVE "falling 0.5000/10.0000/2.6500 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US3-COLLISION.
 COPY CLTEST.
