*> Implementation test of client/src/physics.cob (PHYS-TICK, PHYS-SOLID): off the world screen the
*> movement keys do nothing while gravity still acts; a jump under a low ceiling stops with the
*> head against it; a wall on the -X side stops the Player at its face; a cell of a chunk the client
*> does not have is solid; below the dimension nothing is solid.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PHYSICS.
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
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-SOLID               BINARY-LONG.
 01 WS-PEAK                FLOAT-LONG.
 01 WS-EDIT                PIC -(4)9.9(4).
 01 WS-ABILITIES           BINARY-LONG.
 01 WS-JUMPS               BINARY-LONG.
 01 WS-WAS-GROUND          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
*>   The pause menu: W held does not walk; lifted 0.5 above the floor the Player still falls.
     MOVE SCR-PAUSE TO SM-SCREEN
     MOVE 10.5 TO PL-Y
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "physics off the world screen the movement keys do nothing and gravity still acts"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0.5000/10.0000/0.5000" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SCR-WORLD TO SM-SCREEN

*>   A ceiling at y = 12 above the Player (head at 11.75): a jump rises only 0.25.
     MOVE 0 TO WS-X WS-Z
     MOVE 12 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE CC-KEY-SPACE TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE PL-Y TO WS-PEAK
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     MOVE "physics a jump under a ceiling stops with the head against it (feet 12 - 1.75), then "
         & "the Player falls back to the floor" TO TL-CASE
     COMPUTE WS-EDIT ROUNDED = WS-PEAK
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "10.2500 0.5000/10.0000/0.5000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A wall at x = -2: walking -X (yaw 90 faces -X) stops at -2 + 1 + 0.35.
     MOVE 0 TO WS-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 2 TO WS-STATE
     MOVE -2 TO WS-X
     PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 11
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     END-PERFORM
     MOVE 90 TO PL-YAW
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "physics walking -X into a wall stops the box at its face (x -1 + 0.35)" TO TL-CASE
     MOVE "-0.6500/10.0000/0.5000" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO TL-OBSERVED
     MOVE 100 TO WS-X
     MOVE 20 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "PHYS-SOLID" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SOLID
     MOVE FUNCTION CHAR(WS-SOLID + 49) TO TL-OBSERVED(1:1)
     MOVE 0 TO WS-X
     MOVE -1 TO WS-Y
     CALL "PHYS-SOLID" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SOLID
     MOVE FUNCTION CHAR(WS-SOLID + 49) TO TL-OBSERVED(2:1)
     MOVE 256 TO WS-Y
     CALL "PHYS-SOLID" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SOLID
     MOVE FUNCTION CHAR(WS-SOLID + 49) TO TL-OBSERVED(3:1)
     MOVE 5 TO WS-Y
     CALL "PHYS-SOLID" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SOLID
     MOVE FUNCTION CHAR(WS-SOLID + 49) TO TL-OBSERVED(4:1)
     MOVE "physics solid cells: an unloaded chunk 1, below the world 0, above it 0, greystone 1"
         TO TL-CASE
     MOVE "1001" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Held Space on the ground in survival (edge case): the jump repeats on landing and the Player
*>   never rises above one jump height (1.25) over the floor.
     MOVE 0 TO WS-X WS-Z
     MOVE 12 TO WS-Y
     MOVE 0 TO WS-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ABILITIES
     MOVE 0 TO PL-ABILITIES PL-FLYING
     MOVE 10 TO PL-Y
     MOVE 0 TO PL-VY
     MOVE 1 TO PL-ON-GROUND
     MOVE 0 TO WS-PEAK WS-JUMPS
     MOVE 1 TO WS-WAS-GROUND
     MOVE CC-KEY-SPACE TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         IF PL-Y - 10 > WS-PEAK
             COMPUTE WS-PEAK = PL-Y - 10
         END-IF
         IF PL-ON-GROUND = 0 AND WS-WAS-GROUND = 1
             ADD 1 TO WS-JUMPS
         END-IF
         MOVE PL-ON-GROUND TO WS-WAS-GROUND
         CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     END-PERFORM
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "physics held Space on the ground in survival repeats the jump (at least 3 jumps in 3 s) and "
         & "never rises above one jump height" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-OK
     IF WS-JUMPS >= 3 AND WS-PEAK <= 1.26 AND WS-PEAK > 1.0
         MOVE 1 TO WS-OK
     END-IF
     STRING "ok " WS-OK PL-FLYING DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "ok 10" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PHYSICS.
 COPY CLTEST.
