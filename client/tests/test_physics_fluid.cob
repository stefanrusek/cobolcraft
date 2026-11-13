*> Implementation test of the fluid movement of client/src/physics.cob and physics-fluid.cob (PHYS-FLUID; 13 section 1.3
*> "Swimming and water", "Lava"; 18 section 3.2 travelInWater, travelInLava; 29a section 8.2 heights): a liquid cell is not solid;
*> a Player whose box touches water accelerates by 0.02 a tick, is dragged by 0.8 (horizontal and vertical), sinks by the falling
*> adjustment (0.005 a tick before the drag of the next), gains 0.04 a tick up from Space deeper than 0.4 (down from sneak), jumps
*> from the ground in shallow water, hops out over a ledge (0.3); in lava the drag is 0.5 and 0.02 is taken off the fall; the eye
*> flags say whether the eye is inside a fluid. Expected positions are the sequences of those rules computed outside the program.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PHYSICS-FLUID.
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
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-EDIT                PIC -(4)9.9(4).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
*>   State 4 is water (a source), state 5 lava (rows are state + 1).
     MOVE 1 TO ST-FLUID(5)
     MOVE 2 TO ST-FLUID(6)
     MOVE 0 TO ST-LEVEL(5) ST-LEVEL(6) ST-OPAQUE(5) ST-OPAQUE(6)
*>   A pool of water over x -3 to 3, z -3 to 3, y 6 to 9 (the surface at 9.8889), one of lava over x 10 to 13, z 10 to 13.
     MOVE 4 TO WS-STATE
     PERFORM VARYING WS-X FROM -3 BY 1 UNTIL WS-X > 3
         PERFORM VARYING WS-Z FROM -3 BY 1 UNTIL WS-Z > 3
             PERFORM VARYING WS-Y FROM 6 BY 1 UNTIL WS-Y > 9
                 CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 5 TO WS-STATE
     PERFORM VARYING WS-X FROM 10 BY 1 UNTIL WS-X > 13
         PERFORM VARYING WS-Z FROM 10 BY 1 UNTIL WS-Z > 13
             PERFORM VARYING WS-Y FROM 6 BY 1 UNTIL WS-Y > 9
                 CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM

     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-X WS-Z
     MOVE 8 TO WS-Y
     CALL "PHYS-SOLID" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SOLID
     MOVE FUNCTION CHAR(WS-SOLID + 49) TO TL-OBSERVED(1:1)
     MOVE 11 TO WS-X
     MOVE 11 TO WS-Z
     CALL "PHYS-SOLID" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SOLID
     MOVE FUNCTION CHAR(WS-SOLID + 49) TO TL-OBSERVED(2:1)
     MOVE 0 TO WS-X WS-Z
     MOVE 5 TO WS-Y
     CALL "PHYS-SOLID" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SOLID
     MOVE FUNCTION CHAR(WS-SOLID + 49) TO TL-OBSERVED(3:1)
     MOVE "physics fluid a water cell and a lava cell are not solid, the stone under the pool is" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "001" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Sinking: 10 ticks from rest at y 8, no keys: vy x 0.8 less 0.005 each tick; the eye (y + 1.6) is in the water.
     MOVE 8 TO PL-Y
     MOVE 0 TO PL-VY PL-ON-GROUND
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     MOVE "physics fluid in water at rest the Player sinks slowly: 10 ticks from y 8 to 7.8616, the eye in the water"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING PL-EYE-WATER PL-IN-WATER PL-IN-LAVA DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "110 0.5000/7.8616/0.5000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Standing on stone beside the pool: not in water, the eye flags clear.
     MOVE 8.5 TO PL-X
     MOVE 10 TO PL-Y
     MOVE 0 TO PL-VY
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     MOVE "physics fluid on dry ground the Player is in no fluid" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING PL-EYE-WATER PL-IN-WATER PL-IN-LAVA DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Rising: a key event runs a tick with the key as it is then, so Space is held for 1 + 6 ticks and the release is one tick more.
     MOVE 0.5 TO PL-X
     MOVE 7 TO PL-Y
     MOVE 0 TO PL-VY PL-ON-GROUND PL-VX PL-VZ
     MOVE CC-KEY-SPACE TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-SIX
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "physics fluid Space held in deep water adds 0.04 of vertical speed a tick: 7 held ticks and one free from y 7 to 7.8942" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "0.5000/7.8942/0.5000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Sneaking: 3 ticks from y 8, -0.04 a tick.
     MOVE 0.5 TO PL-X PL-Z
     MOVE 8 TO PL-Y
     MOVE 0 TO PL-VY PL-ON-GROUND PL-VX PL-VZ
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-THREE
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "physics fluid sneaking in water takes 0.04 off the vertical speed a tick: 4 held ticks and one free from y 8 to 7.5369" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "0.5000/7.5369/0.5000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Swimming forward (yaw 0 faces +Z): +0.02 of speed a tick, drag 0.8: z 0.5 to 1.3075 in 12 ticks.
     MOVE 0.5 TO PL-X PL-Z
     MOVE 8 TO PL-Y
     MOVE 0 TO PL-VY PL-ON-GROUND PL-VX PL-VZ
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "physics fluid swimming forward accelerates by 0.02 a tick under a drag of 0.8: 11 held ticks and one free move 0.8075" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "0.5000/7.8164/1.3075" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Shallow water on the ground: a jump is a jump from the ground (0.42, then the water drag 0.8).
     MOVE 0.5 TO PL-X PL-Z
     MOVE 9.6 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ
     MOVE 1 TO PL-ON-GROUND
     MOVE CC-KEY-SPACE TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE "physics fluid Space in water not deeper than 0.4 on the ground is a jump from the ground: y 10.0200, speed 0.3360"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = PL-VY
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "0.3360 0.5000/10.0200/0.5000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP

*>   A ledge: pushing +X (yaw 270) into the stone at x 4 from y 9.4: blocked at x 3.65, then a free box 0.6 higher sets 0.3.
     MOVE 3.64 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 9.4 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ PL-ON-GROUND
     MOVE 270 TO PL-YAW
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE "physics fluid against a ledge a Player in water hops out: stopped at x 3.65 with vertical speed 0.3" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = PL-VY
     STRING FUNCTION TRIM(WS-EDIT) " " PL-COLLIDED DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "0.3000 1 3.6500/9.4000/0.5000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE 0 TO PL-YAW

*>   The same ledge to the south (yaw 0 faces +Z) from z 3.64: the stone at z 4 stops the Z move at 3.65 and the speed on that axis.
     MOVE 0.5 TO PL-X
     MOVE 3.64 TO PL-Z
     MOVE 9.4 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ PL-ON-GROUND
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE "physics fluid against a ledge to the south the Z move stops at 3.65 and its speed is 0 (a hop out: 0.3)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = PL-VZ
     STRING FUNCTION TRIM(WS-EDIT) " " PL-COLLIDED DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "0.0000 1 0.5000/9.4000/3.6500" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP

*>   Sprinting in water drags by 0.9: one tick forward from rest leaves 0.02 x 0.9.
     MOVE 0.5 TO PL-X PL-Z
     MOVE 8 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ PL-ON-GROUND
     MOVE 1 TO PL-SPRINTING
     MOVE KB-CODE(KB-FORWARD) TO WS-KEY
     MOVE 1 TO IN-KEY-DOWN(WS-KEY + 1)
     CALL "PHYS-TICK" USING CLIENT-STATE
     MOVE 0 TO IN-KEY-DOWN(WS-KEY + 1)
     MOVE "physics fluid sprinting in water drags by 0.9: one tick forward from rest leaves a speed of 0.0180" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = PL-VZ
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0.0180" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SPRINTING

*>   Shallow lava (not deeper than 0.4, the feet at 9.6): the drag is (0.5, 0.8, 0.5), 0.005 off a fall and 0.02 off.
     MOVE 11.5 TO PL-X PL-Z
     MOVE 9.6 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ PL-ON-GROUND
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     MOVE "physics fluid in lava not deeper than 0.4 the vertical speed is x 0.8 less 0.005 and 0.02: from rest -0.0250"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = PL-VY
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "-0.0250" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Lava: drag 0.5 on every axis and 0.02 off the vertical speed: 5 ticks from y 8 to 7.8775.
     MOVE 11.5 TO PL-X PL-Z
     MOVE 8 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ PL-ON-GROUND
     CALL "TEST-TICKS" USING CLIENT-STATE WS-FIVE
     MOVE "physics fluid in deep lava the speed is halved and 0.02 is taken off each tick: 5 ticks from y 8 to 7.8775"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING PL-EYE-LAVA PL-IN-LAVA PL-IN-WATER DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "110 11.5000/7.8775/11.5000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PHYSICS-FLUID.
 COPY CLTEST.
