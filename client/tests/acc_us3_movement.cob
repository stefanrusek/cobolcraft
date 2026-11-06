*> Acceptance test of US3-1 on the client (client-surface §3; standin-content §11.4 walking speed
*> 0.2 blocks per tick; client/src/physics.cob): given the Player in the world on a flat floor, W, S,
*> A and D walk forward, back and sideways relative to the facing, the mouse turns and looks up and
*> down (cursor captured), and Space jumps: the Player rises above the floor and lands again.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US3-MOVEMENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PEAK                FLOAT-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(4)9.9(4).
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 FILLER              PIC X(12).
    05 WS-DX               FLOAT-SHORT.
    05 WS-DY               FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE SPACES TO WS-TEXT
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-WALK" USING CLIENT-STATE WS-KEY WS-TEXT
     MOVE CC-KEY-S TO WS-KEY
     CALL "TEST-WALK" USING CLIENT-STATE WS-KEY WS-TEXT
     MOVE CC-KEY-A TO WS-KEY
     CALL "TEST-WALK" USING CLIENT-STATE WS-KEY WS-TEXT
     MOVE CC-KEY-D TO WS-KEY
     CALL "TEST-WALK" USING CLIENT-STATE WS-KEY WS-TEXT
     MOVE "acceptance US3-1 given the Player facing +Z when W, S, A and D are each held for five "
         & "ticks then they walk 1 block forward, back, left (+X) and right at 0.2 blocks per tick"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0.5000/10.0000/1.5000 0.5000/10.0000/0.5000 1.5000/10.0000/0.5000 "
         & "0.5000/10.0000/0.5000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Mouse: 600 pixels right turns to yaw 90 (facing -X); W then walks toward -X.
     INITIALIZE WS-EVENT
     MOVE CC-EV-CURSOR TO WS-KIND
     MOVE 600 TO WS-DX
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-ANGLES" USING CLIENT-STATE WS-TEXT
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-WALK" USING CLIENT-STATE WS-KEY WS-TEXT
     MOVE "acceptance US3-1 given the Player facing +Z when the mouse moves 600 pixels right then "
         & "they turn to yaw 90 (0.15 degrees per pixel) and W walks toward -X" TO TL-CASE
     MOVE "90.0/0.0 -0.5000/10.0000/0.5000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-DX
     MOVE -200 TO WS-DY
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     CALL "TEST-ANGLES" USING CLIENT-STATE WS-TEXT
     MOVE 400 TO WS-DY
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     CALL "TEST-ANGLES" USING CLIENT-STATE WS-TEXT
     MOVE 2000 TO WS-DY
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     CALL "TEST-ANGLES" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US3-1 when the mouse moves up then down then they look up (pitch -30) and "
         & "down (pitch 30), at most straight down (pitch 90)" TO TL-CASE
     MOVE "90.0/-30.0 90.0/30.0 90.0/90.0" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Jump: Space pressed once on the floor.
     MOVE CC-KEY-SPACE TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE PL-Y TO WS-PEAK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
         IF PL-Y > WS-PEAK
             MOVE PL-Y TO WS-PEAK
         END-IF
     END-PERFORM
     MOVE "acceptance US3-1 when Space is pressed on the floor then the Player jumps above a block "
         & "height (peak above 11.2) and lands on the floor again" TO TL-CASE
     MOVE "jumped landed 10.0000 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-PEAK > 11.2 AND WS-PEAK < 11.3
         MOVE "jumped" TO TL-OBSERVED
     ELSE
         MOVE "no jump" TO TL-OBSERVED
     END-IF
     COMPUTE WS-EDIT ROUNDED = PL-Y
     STRING FUNCTION TRIM(TL-OBSERVED) " landed " FUNCTION TRIM(WS-EDIT) " " PL-ON-GROUND
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US3-MOVEMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WALK.
*> USING CLIENT-STATE, key, text (appended): the key held for five ticks (down in the first, up in
*> the sixth), then the position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-TEXT.
     CALL "TEST-KEY-TICK" USING CLIENT-STATE L-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-FOUR
     CALL "TEST-KEY-TICK" USING CLIENT-STATE L-KEY WS-UP
     CALL "TEST-POSITION" USING CLIENT-STATE L-TEXT
     GOBACK.
 END PROGRAM TEST-WALK.
 COPY CLTEST.
