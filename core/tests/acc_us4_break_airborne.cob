*> Acceptance test (spec 002 polish; docs/protocol/13 section 2.1 step 7 and 2.4; operator playtest, digging straight down):
*> the destroy progress is accumulated every tick from the player's state of that tick (the rate is divided by 5 only for the
*> ticks the player is airborne), not frozen at the start. A dig that starts while the player is falling onto the block and
*> goes on after landing finishes by the ground time: loam by hand (0.0667 a tick) started airborne, 3 airborne ticks, 11
*> ticks on the ground, then Stop is accepted (progress 0.787 >= 0.7). A dig on the ground all the time is accepted at 12 ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-BREAK-AIRBORNE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LOAM                BINARY-LONG VALUE 3.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW

     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOAM
     MOVE 0 TO PL-ON-GROUND(WS-ROW)
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO PL-ON-GROUND(WS-ROW)
     MOVE 11 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance dig straight down given a dig started while falling and 11 ticks on the ground after "
         & "3 airborne when Stop is sent then the block breaks (progress is accumulated per tick)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOAM
     MOVE 1 TO PL-ON-GROUND(WS-ROW)
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance dig with the feet on the ground all the time given 12 ticks when Stop is sent then "
         & "the block breaks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Falling for the whole time: 12 ticks at a fifth of the rate (0.16) are far from 0.7: the block stays.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LOAM
     MOVE 0 TO PL-ON-GROUND(WS-ROW)
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance dig while airborne all the time given 12 ticks when Stop is sent then the block stays"
         TO TL-CASE
     MOVE WS-LOAM TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.
 END PROGRAM ACC-US4-BREAK-AIRBORNE.

 COPY CORETEST.
