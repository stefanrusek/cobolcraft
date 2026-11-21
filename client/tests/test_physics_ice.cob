*> Implementation test of the slippery ground of client/src/physics.cob (lane fixa A3; 18 section 3.2, 13 section 1.3): over a block of friction
*> F above 0.6 (ice 0.98: BSH-SLIP, thousandths) the walk accelerates by speed x 0.21600002 / F^3 and keeps its velocity with a drag of F x 0.91 a
*> tick, so a player who lets go of W glides on; over a default block (0.6) the horizontal move stops at once, as before.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PHYSICS-ICE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CTBSHAPE.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-Z2                  FLOAT-LONG.
 01 WS-GLIDE               FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     MOVE CC-KEY-W TO WS-KEY
     MOVE 0 TO PL-YAW
*>   Default ground: W for 20 ticks, released: the next 10 ticks move nothing.
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TWENTY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     MOVE PL-Z TO WS-Z1
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     COMPUTE WS-GLIDE = (PL-Z - WS-Z1) * 1000
     MOVE "ice: on a default block the player stops when W is released (glide in thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-GLIDE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Ice floor (state 2 is the test floor): the same walk, then the glide.
     MOVE 980 TO BSH-SLIP(3)
     MOVE 0.5 TO PL-Z
     MOVE 0 TO PL-VX PL-VZ
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TWENTY
     MOVE PL-Z TO WS-Z0
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     COMPUTE WS-STEP = (PL-Z - WS-Z0) * 1000
     MOVE "ice: the walking speed on ice after 20 ticks is 0.17 to 0.2 a tick (thousandths)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STEP >= 150 AND WS-STEP <= 200
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     MOVE PL-Z TO WS-Z1
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     COMPUTE WS-GLIDE = (PL-Z - WS-Z1) * 1000
     MOVE "ice: after W is released the player glides on at least 0.7 block in 10 ticks (thousandths)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-GLIDE >= 700
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BSH-SLIP(3)
     STOP RUN.
 END PROGRAM TEST-PHYSICS-ICE.
 COPY CLTEST.
