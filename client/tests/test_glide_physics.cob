*> Implementation test (lane p46f, T27501; docs/protocol/17 section 3.13 elytra and fireworks, 05c Player Command 6 START_FALL_FLYING, 53 section 2.1 FALL_FLYING box and eye, 05b 0x67):
*> the local player glides. Space pressed in the air with an elytra worn in the chest slot (the inventory menu's slot IX 2) that the next point of damage would not break starts
*> the glide and sends Player Command START_FALL_FLYING once; without an elytra, with a worn-out one or on the ground it does not. While gliding PHYS-TICK replaces the walking
*> step by the five steps of 3.13 (the velocity is the glider's PL-VX, PL-VY, PL-VZ; the look vector from yaw and pitch): the positions after 1, 5 and 20 ticks at the pitches
*> 0, -40 and 45 degrees, a firework rocket's Set Entity Motion (the boosted velocity) after tick 5, and the landing (the ground ends the glide on the next tick; taking the elytra
*> off ends it too). Expected values are the output of the independent model client/tests/fixtures/glide_model.py (run it to see the tables); the glide starts at (0.5, 100, -12.5)
*> facing +Z with the velocity (0, -0.3, 0.6) of a Set Entity Motion, over the floor of TEST-PLAY (top at y = 10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GLIDE-PHYSICS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-SPACE               BINARY-LONG VALUE CC-KEY-SPACE.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-DIR                 PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "elytra".
 01 WS-ROW                 PIC X(270).
 01 WS-ELYTRA              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-STEPS               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-WALL                BINARY-LONG VALUE 2.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE -0.3.
 01 WS-VZ                  FLOAT-LONG VALUE 0.6.
 01 WS-RX                  FLOAT-LONG VALUE 0.
 01 WS-RY                  FLOAT-LONG VALUE -0.11491480678020177.
 01 WS-RZ                  FLOAT-LONG VALUE 1.1982143939865355.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-NX                  PIC X(12).
 01 WS-NY                  PIC X(12).
 01 WS-NZ                  PIC X(12).
 01 WS-TEXT-X              PIC -(3)9.999.
 01 WS-TEXT-Y              PIC -(3)9.999.
 01 WS-TEXT-Z              PIC -(3)9.999.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
*>   The standard content set (the elytra's item id and durability).
     MOVE SPACES TO WS-DIR
     MOVE "content/tests/fixtures/std" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ELYTRA WS-ROW WS-STATUS
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "N" TO TL-MODE

*>   Without an elytra in the chest slot Space in the air starts nothing and sends nothing.
     MOVE 0 TO WS-PITCH
     PERFORM SET-AIR
     MOVE 0 TO IX-COUNT(2)
     PERFORM PRESS-SPACE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "test glide: no elytra worn, Space in the air does not glide" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-GLIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "test glide: no elytra worn, no Player Command is sent" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE

*>   An elytra the next point of damage would break (432 - 1 used) does not start a glide either.
     PERFORM SET-AIR
     MOVE 431 TO IX-DAMAGE(2)
     PERFORM PRESS-SPACE
     MOVE "test glide: an elytra the next damage would break does not glide" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-GLIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   On the ground Space jumps (no glide).
     PERFORM SET-AIR
     MOVE 10 TO PL-Y
     MOVE 1 TO PL-ON-GROUND
     PERFORM PRESS-SPACE
     MOVE "test glide: Space on the ground jumps, it does not glide" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-GLIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STEPS
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-UP
     MOVE 30 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

*>   A worn elytra: Space in the air glides and tells the server once; the pose is fall flying.
     PERFORM SET-AIR
     PERFORM PRESS-SPACE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "test glide: elytra worn, Space in the air glides" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-GLIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "test glide: Player Command START_FALL_FLYING (entity 1, action 6) is sent" TO TL-CASE
     MOVE "2a010600" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "test glide: the pose is fall flying (1) and the camera eye drops" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-POSE * 10 + 1
     IF PL-EYE >= 1.6
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Space again while gliding sends nothing more.
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-UP
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-DOWN
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "T" TO TL-MODE
     MOVE "test glide: Space while gliding sends no second Player Command" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE

*>   Level flight, climbing and diving: the model's positions after 1, 5 and 20 ticks.
     MOVE 0 TO WS-PITCH
     PERFORM START-GLIDE
     MOVE 1 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 99.718 -11.877" TO TL-EXPECTED
     MOVE "test glide: pitch 0, tick 1" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 4 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 98.728 -9.195" TO TL-EXPECTED
     MOVE "test glide: pitch 0, tick 5" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 15 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 95.976 2.681" TO TL-EXPECTED
     MOVE "test glide: pitch 0, tick 20" TO TL-CASE
     PERFORM CHECK-POSITION

     MOVE -40 TO WS-PITCH
     PERFORM START-GLIDE
     MOVE 1 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 99.730 -11.902" TO TL-EXPECTED
     MOVE "test glide: pitch -40 (looking up), tick 1" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 4 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 98.906 -9.554" TO TL-EXPECTED
     MOVE "test glide: pitch -40, tick 5" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 15 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 97.590 -2.009" TO TL-EXPECTED
     MOVE "test glide: pitch -40, tick 20" TO TL-CASE
     PERFORM CHECK-POSITION

     MOVE 45 TO WS-PITCH
     PERFORM START-GLIDE
     MOVE 1 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 99.674 -11.890" TO TL-EXPECTED
     MOVE "test glide: pitch 45 (diving), tick 1" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 4 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 98.146 -9.336" TO TL-EXPECTED
     MOVE "test glide: pitch 45, tick 5" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 15 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 90.352 2.489" TO TL-EXPECTED
     MOVE "test glide: pitch 45, tick 20" TO TL-CASE
     PERFORM CHECK-POSITION

*>   A firework rocket after tick 5 (level flight): its Set Entity Motion carries the boosted velocity (speed 0.696 -> 1.198).
     MOVE 0 TO WS-PITCH
     PERFORM START-GLIDE
     MOVE 5 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     CALL "TEST-MOTION" USING CLIENT-STATE WS-CONN PL-ENTITY-ID WS-RX WS-RY WS-RZ
     MOVE 1 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 98.609 -7.997" TO TL-EXPECTED
     MOVE "test glide: a rocket's boost after tick 5, tick 6 moves 1.198 forward" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 6 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.500 97.833 -0.790" TO TL-EXPECTED
     MOVE "test glide: a rocket's boost, tick 12" TO TL-CASE
     PERFORM CHECK-POSITION

*>   Landing: from 4 blocks up, diving at 45 degrees, the box rests on the floor on tick 10 (still gliding), the next tick ends the glide.
     MOVE 45 TO WS-PITCH
     PERFORM START-GLIDE
     MOVE 14 TO PL-Y
     MOVE 9 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "test glide: still in the air on tick 9" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-GLIDING * (1 - PL-ON-GROUND)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "test glide: on the floor on tick 10, the glide has not ended yet" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-GLIDING * 10 + PL-ON-GROUND
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "0.500 10.000 -5.825" TO TL-EXPECTED
     MOVE "test glide: the landing position" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 1 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "test glide: the next tick ends the glide (landed)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-GLIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 30 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "test glide: standing again after the landing (pose 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Taking the elytra off ends the glide on the next tick.
     MOVE 0 TO WS-PITCH
     PERFORM START-GLIDE
     MOVE 0 TO IX-COUNT(2)
     MOVE 1 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "test glide: without the elytra the glide ends" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-GLIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Levitation (effect id 24) takes the elytra's use away: no glide.
     MOVE 0 TO WS-PITCH
     PERFORM SET-AIR
     MOVE 1 TO EF-COUNT
     MOVE 24 TO EF-ID(1)
     PERFORM PRESS-SPACE
     MOVE 0 TO EF-COUNT
     MOVE "test glide: with Levitation Space in the air does not glide" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-GLIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A wall across the way along Z: the glider stops against it (a blocked axis loses its speed), 0.3 off the face of the block at z = -9.
     PERFORM VARYING WS-WY FROM 95 BY 1 UNTIL WS-WY > 105
         MOVE 0 TO WS-WX
         MOVE -9 TO WS-WZ
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-WX WS-WY WS-WZ WS-WALL
     END-PERFORM
     PERFORM START-GLIDE
     MOVE 15 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "test glide: a wall ahead along Z stops the glider (z -9.3, no speed along Z)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(PL-Z + 9.3) < 0.001 AND PL-VZ = 0 AND PL-GLIDING = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A wall across the way along X (facing east, yaw -90): the glider stops 0.3 off the face of the block at x = 3.
     PERFORM VARYING WS-WY FROM 95 BY 1 UNTIL WS-WY > 105
         MOVE 3 TO WS-WX
         MOVE -13 TO WS-WZ
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-WX WS-WY WS-WZ WS-WALL
     END-PERFORM
     MOVE -90 TO WS-YAW
     MOVE 0.6 TO WS-VX
     MOVE 0 TO WS-VZ
     PERFORM START-GLIDE
     MOVE 15 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "test glide: a wall ahead along X stops the glider (x 2.7, no speed along X)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(PL-X - 2.7) < 0.001 AND PL-VX = 0 AND PL-GLIDING = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The player in the air at (0.5, 100, -12.5) facing +Z at pitch WS-PITCH, a fresh elytra in the chest slot, no glide, no velocity.
 SET-AIR.
     MOVE 0 TO PL-GLIDING PL-ON-GROUND PL-VX PL-VY PL-VZ PL-KB-X PL-KB-Z PL-MOVE-X PL-MOVE-Z PL-POSE PL-EYE
     MOVE 0.5 TO PL-X
     MOVE 100 TO PL-Y
     MOVE -12.5 TO PL-Z
     MOVE WS-YAW TO PL-YAW
     MOVE WS-PITCH TO PL-PITCH
     MOVE 1 TO IX-COUNT(2)
     MOVE WS-ELYTRA TO IX-ITEM(2)
     MOVE 0 TO IX-DAMAGE(2)
     .

*> Space pressed (down, one tick) and released (one tick).
 PRESS-SPACE.
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-DOWN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-UP
     .

*> A glide at the start position with the Set Entity Motion velocity (0, -0.3, 0.6).
 START-GLIDE.
     PERFORM SET-AIR
     PERFORM PRESS-SPACE
     MOVE 0.5 TO PL-X
     MOVE 100 TO PL-Y
     MOVE -12.5 TO PL-Z
     MOVE 0 TO PL-ON-GROUND
     CALL "TEST-MOTION" USING CLIENT-STATE WS-CONN PL-ENTITY-ID WS-VX WS-VY WS-VZ
     .

*> The position to three decimals, or the expected text when it is within 0.002 of it (so that rounding at the last digit does not decide).
 CHECK-POSITION.
     MOVE "T" TO TL-MODE
     COMPUTE WS-TEXT-X ROUNDED = PL-X
     COMPUTE WS-TEXT-Y ROUNDED = PL-Y
     COMPUTE WS-TEXT-Z ROUNDED = PL-Z
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT-X) " " FUNCTION TRIM(WS-TEXT-Y) " " FUNCTION TRIM(WS-TEXT-Z)
         DELIMITED BY SIZE INTO TL-OBSERVED
     UNSTRING TL-EXPECTED DELIMITED BY SPACE INTO WS-NX WS-NY WS-NZ
     MOVE FUNCTION NUMVAL(WS-NX) TO WS-EX
     MOVE FUNCTION NUMVAL(WS-NY) TO WS-EY
     MOVE FUNCTION NUMVAL(WS-NZ) TO WS-EZ
     IF FUNCTION ABS(PL-X - WS-EX) < 0.002 AND FUNCTION ABS(PL-Y - WS-EY) < 0.002 AND FUNCTION ABS(PL-Z - WS-EZ) < 0.002
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     .
 END PROGRAM TEST-GLIDE-PHYSICS.
 COPY CLTEST.
