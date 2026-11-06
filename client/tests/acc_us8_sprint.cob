*> Acceptance test of US8-2, the client half (client-surface §3 "Run (sprint): hold Left Control
*> while moving forward"; standin-content §11.4 sprint speed 0.28 blocks per tick, walking 0.2;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Player Command 0x2A actions 1 START_SPRINTING and 2
*> STOP_SPRINTING, entity id the player's own, data 0): holding Left Control while moving forward
*> sends start sprinting and moves at the sprint speed; releasing Left Control or stopping forward
*> movement sends stop sprinting and the walking speed returns. Left Control while walking back
*> sends nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US8-SPRINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-CTRL                BINARY-LONG VALUE CC-KEY-LEFT-CONTROL.
 01 WS-W                   BINARY-LONG VALUE CC-KEY-W.
 01 WS-S                   BINARY-LONG VALUE CC-KEY-S.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 PROCEDURE DIVISION.
*>   Survival on the flat floor at (0.5, 10, 0.5) facing +Z; the player's entity id is 1.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

*>   Left Control down (one tick, standing), then W held for five ticks.
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-CTRL WS-DOWN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-W WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-FOUR
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-POSITION" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US8-2 client half: given Left Control held when W is held for five ticks "
         & "then Player Command start sprinting (entity 1) is sent once and the Player runs 1.4 "
         & "blocks (0.28 blocks per tick)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "2a010100 0.5000/10.0000/1.9000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-W WS-UP
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-POSITION" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US8-2 client half: when forward movement stops (W released, Left Control "
         & "still held) then Player Command stop sprinting is sent and the Player stops"
         TO TL-CASE
     MOVE "2a010200 0.5000/10.0000/1.9000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   W again (running one tick), then Left Control released: two more ticks walking.
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-W WS-DOWN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-CTRL WS-UP
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-POSITION" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US8-2 client half: when W is held again then start sprinting is sent; when "
         & "Left Control is released then stop sprinting is sent and the Player walks at 0.2 "
         & "blocks per tick (0.28 + 0.2 + 0.2)" TO TL-CASE
     MOVE "2a010100 2a010200 0.5000/10.0000/2.5800" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-W WS-UP

     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-CTRL WS-DOWN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-S WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-S WS-UP
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-CTRL WS-UP
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-POSITION" USING CLIENT-STATE WS-TEXT
     MOVE "US8-2 client half: given Left Control held when the Player walks back (S) then nothing "
         & "is sent and they walk at 0.2 blocks per tick" TO TL-CASE
     MOVE "0.5000/10.0000/2.1800" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US8-SPRINT.
 COPY CLTEST.
