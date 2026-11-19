 *> Implementation test of sneaking (T6200; docs/protocol/53 sections 2, 3, 5, 6, 7; 13 section 1.1; client/src/physics.cob, controls.cob):
*> Left Shift sends Player Input (05c 0x2B, flag 0x20) and the crouching pose; a sneaking Player moves at 0.3 of the walking speed, its eye
*> sinks (camera 7: half the gap a tick) and its box is 1.5 high; it cannot walk off an edge (53 section 5: the box would have no support
*> within 0.6 below) but does walk down a half block; with a top slab 1.5 above the floor only the sneaking Player gets under it, and
*> it stays crouched there after releasing the key (53 section 3.2: the standing box does not fit).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SNEAK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-TICKS               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BLOCK               PIC X(40).
 01 WS-P1                  PIC X(80).
 01 WS-P2                  PIC X(80).
 01 WS-P3                  PIC X(80).
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-DX                 FLOAT-LONG.
 01 WS-DZ                 FLOAT-LONG.
 01 WS-SHIFT-ARG          BINARY-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 1 TO CT-OPEN
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

*>   Shift down for a tick, then W for ten ticks: Player Input once, 0.06 a tick, crouched, eye sinking toward 1.25.
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 9 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "sneak shift sends Player Input 0x20 once and ten ticks of W move 0.6 (0.06 a tick)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED(1:4)
     MOVE "2b20" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sneak ten ticks of W move the Player 0.6" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "0.5000/10.0000/1.1000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sneak the pose is crouching (5)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE "sneak the camera eye is within 0.01 of 1.25 after ten ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-EYE > 1.24 AND PL-EYE < 1.26
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "sneak releasing shift sends Player Input 0x00" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED(1:4)
     MOVE "2b00" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sneak released the pose is standing (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   A pit: air from x 3 to 8, z -4 to 4, y 5 to 9. Sneaking along +X stops at the edge; walking drops in.
     MOVE 270 TO PL-YAW
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Z FROM -4 BY 1 UNTIL WS-Z > 4
             PERFORM VARYING WS-Y FROM 5 BY 1 UNTIL WS-Y > 9
                 CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO PL-X PL-Z
     MOVE 10 TO PL-Y
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 90 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sneak at an edge: the Player stops with the box still over the floor (x between 3.0 and 3.35)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-X > 3.0 AND PL-X < 3.3501 AND PL-Y > 9.99
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE "sneak at an edge: the Player is on the ground" TO TL-CASE
     MOVE PL-ON-GROUND TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "walking on from the edge (shift released) the Player falls into the pit" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y < 9.5 AND PL-X > 3.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP

*>   Bottom slabs in the pit (top 9.5 against feet 10: a drop of 0.5, under the 0.6 probe): sneaking walks down onto them.
     MOVE "oak_slab" TO WS-BLOCK
     MOVE "type=bottom,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Z FROM -4 BY 1 UNTIL WS-Z > 4
             MOVE 9 TO WS-Y
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO PL-X PL-Z
     MOVE 10 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 90 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sneak beside a drop of 0.5 (a slab): no clamp, the Player walks down onto it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-X > 4.0 AND PL-Y > 9.4 AND PL-Y < 9.6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP

*>   A top slab ceiling (underside 11.5) over x 3 to 8: 1.5 above the feet at 10. Standing does not fit (1.8 with the standard set), crouched does (1.5).
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Z FROM -4 BY 1 UNTIL WS-Z > 4
             MOVE 9 TO WS-Y
             MOVE "stone" TO WS-BLOCK
             MOVE SPACES TO WS-P1
             PERFORM FIND-STATE
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE "oak_slab" TO WS-BLOCK
     MOVE "type=top,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Z FROM -4 BY 1 UNTIL WS-Z > 4
             MOVE 11 TO WS-Y
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO PL-X PL-Z
     MOVE 10 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 60 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "standing: the Player stops at the low ceiling (box 1.8 does not fit)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-X < 2.71 AND PL-X > 2.4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 60 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sneaking: the Player goes in under the ceiling (box 1.5 fits)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-X > 3.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "under the ceiling with shift released the pose stays crouching (forced)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   A pit along z (x -10 to -6, z 3 to 8): sneaking along +Z (yaw 0) stops at its edge, z under 3.35.
     PERFORM VARYING WS-X FROM -10 BY 1 UNTIL WS-X > -6
         PERFORM VARYING WS-Z FROM 3 BY 1 UNTIL WS-Z > 8
             PERFORM VARYING WS-Y FROM 5 BY 1 UNTIL WS-Y > 9
                 CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO PL-YAW PL-POSE PL-VY PL-VX PL-VZ
     MOVE -7.5 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 90 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sneak at an edge along z: the Player stops with the box over the floor (z between 2.5 and 3.35)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Z > 2.5 AND PL-Z < 3.3501 AND PL-Y > 9.99
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP

*>   A pit corner (x 10 to 14, z 10 to 14): sneaking diagonally (yaw 315 is +X and +Z) toward it stops at the corner.
     PERFORM VARYING WS-X FROM 10 BY 1 UNTIL WS-X > 14
         PERFORM VARYING WS-Z FROM 10 BY 1 UNTIL WS-Z > 14
             PERFORM VARYING WS-Y FROM 5 BY 1 UNTIL WS-Y > 9
                 CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 315 TO PL-YAW
     MOVE 8.5 TO PL-X PL-Z
     MOVE 10 TO PL-Y
     MOVE 0 TO PL-VY
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 120 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "sneak diagonally at a corner: the Player stays on the floor with the box still over it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-X > 9.0 AND PL-Z > 9.0 AND PL-Y > 9.99 AND (PL-X < 10.3501 OR PL-Z < 10.3501)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP

*>   A gap 1.0 high (stone cells at y 11 over x 20 to 22): neither the standing nor the crouching box fits, so the pose is swimming (3),
*>   the camera eye heads for 0.4; a spectator keeps the pose it wants (standing) there.
     MOVE "stone" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     PERFORM VARYING WS-X FROM 20 BY 1 UNTIL WS-X > 22
         PERFORM VARYING WS-Z FROM -1 BY 1 UNTIL WS-Z > 1
             MOVE 11 TO WS-Y
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 0 TO PL-YAW PL-POSE PL-VY PL-VX PL-VZ
     MOVE 21.5 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     MOVE 1.6 TO PL-EYE
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "a gap 1.0 high: the pose is swimming (3, crawling)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE "a gap 1.0 high: the camera eye is on its way down to 0.4 (below 1.0 after two ticks)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-EYE < 1.0 AND PL-EYE > 0.4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE 0 TO WS-YAW WS-PITCH
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE "the camera is placed at the feet plus the camera eye height" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-EYE(2) - (PL-Y + PL-EYE)) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE 3 TO PL-MODE
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "a spectator in the gap keeps the standing pose" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0 TO PL-MODE

*>   Shift held in the same gap: the crouching box (1.5) does not fit either, so the wanted crouching pose becomes swimming (3).
     MOVE 0 TO PL-POSE PL-SWIMMING PL-FLYING
     MOVE 21.5 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     MOVE 1 TO WS-SHIFT-ARG
     CALL "PHYS-POSE" USING CLIENT-STATE WS-SHIFT-ARG
     MOVE "shift held in a gap 1.0 high: the pose is swimming (3), the crouching box does not fit" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N
*>   A solid cell in the player's own cell: the swimming box (0.6) does not fit, so the pose is left as it was.
     MOVE 21 TO WS-X
     MOVE 10 TO WS-Y
     MOVE 0 TO WS-Z
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO PL-POSE
     MOVE 0 TO WS-SHIFT-ARG
     CALL "PHYS-POSE" USING CLIENT-STATE WS-SHIFT-ARG
     MOVE "a solid cell around the player (the swimming box does not fit): the pose is left as it was" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR

*>   The pit is dug again (air over y 9) for it.
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Z FROM -4 BY 1 UNTIL WS-Z > 4
             MOVE 9 TO WS-Y
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
         END-PERFORM
     END-PERFORM
*>   The sneak edge clamp on its own (PHYS-BACKOFF; the pit of x 3 to 8, z -4 to 4 is still there): a 1.0 step along +x from the floor
*>   edge at x 2.6 would end wholly over the pit, so it is cut back in steps of 0.05 until the box keeps its footing; likewise along -z
*>   from the floor at z 5.6.
     MOVE 2.6 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     MOVE 1.0 TO WS-DX
     MOVE 0 TO WS-DZ
     CALL "PHYS-BACKOFF" USING CLIENT-STATE WS-DX WS-DZ
     MOVE "the edge clamp cuts a 1.0 step along +x back to less than 0.8" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DX > 0 AND WS-DX < 0.8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
*>   A diagonal step past the pit corner (x 3, z 5): each axis alone keeps the box over the floor, both together would fall, so both
*>   offsets are cut back together.
     MOVE 2.6 TO PL-X
     MOVE 5.6 TO PL-Z
     MOVE 1.0 TO WS-DX
     MOVE -1.0 TO WS-DZ
     CALL "PHYS-BACKOFF" USING CLIENT-STATE WS-DX WS-DZ
     MOVE "the edge clamp cuts a diagonal step (1.0, -1.0) back on both axes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DX > 0 AND WS-DX < 1.0 AND WS-DZ < 0 AND WS-DZ > -1.0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N

*>   Crawling (pose 3 on land) is moving slowly too: 0.06 a tick, and no sprint (53 sections 3.3, 6).
     MOVE 270 TO PL-YAW
     MOVE 20.5 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     MOVE 0 TO PL-VY PL-VX PL-VZ
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 9 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "crawling: ten ticks of W move 0.6 (not 2.0) and the Player is not sprinting" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-X > 21.0 AND PL-X < 21.2 AND PL-SPRINTING = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     STOP RUN.

 FIND-STATE.
     CALL "BSH-TEST-FIND" USING WS-BLOCK WS-P1 WS-P2 WS-P3 WS-STATE.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-SNEAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TEST-FIND.
*> USING block key, three texts of comma separated "name=value" constraints (spaces = none), state out: the first state of the block
*> that holds them all.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 CT-PROPS.
    05 CTP-COUNT            BINARY-LONG.
    05 CTP-ENTRY OCCURS 16 TIMES.
       10 CTP-NAME          PIC X(24).
       10 CTP-VALUE         PIC X(32).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(359).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 FILLER              PIC X(451).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-STATES              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-LIST                PIC X(250).
 01 WS-POINTER             BINARY-LONG.
 01 WS-WANT                PIC X(40).
 01 WS-HAVE                PIC X(60).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(40).
 01 L-P1                   PIC X(80).
 01 L-P2                   PIC X(80).
 01 L-P3                   PIC X(80).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-P1 L-P2 L-P3 L-STATE.
     MOVE L-KEY TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     COMPUTE WS-FIRST = FUNCTION NUMVAL(WS-R-FIRST)
     COMPUTE WS-STATES = FUNCTION NUMVAL(WS-R-COUNT)
     MOVE SPACES TO WS-LIST
     STRING FUNCTION TRIM(L-P1) "," FUNCTION TRIM(L-P2) "," FUNCTION TRIM(L-P3) "," DELIMITED BY SIZE INTO WS-LIST
     MOVE WS-FIRST TO L-STATE
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-STATES OR WS-OK = 1
         COMPUTE WS-STATE = WS-FIRST + WS-I
         CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
         MOVE 1 TO WS-OK
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL WS-POINTER > 250
             MOVE SPACES TO WS-WANT
             UNSTRING WS-LIST DELIMITED BY "," INTO WS-WANT WITH POINTER WS-POINTER
             IF WS-WANT NOT = SPACES
                 MOVE 0 TO WS-HAS
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CTP-COUNT
                     MOVE SPACES TO WS-HAVE
                     STRING FUNCTION TRIM(CTP-NAME(WS-J)) "=" FUNCTION TRIM(CTP-VALUE(WS-J)) DELIMITED BY SIZE INTO WS-HAVE
                     IF WS-HAVE = WS-WANT
                         MOVE 1 TO WS-HAS
                     END-IF
                 END-PERFORM
                 IF WS-HAS = 0
                     MOVE 0 TO WS-OK
                 END-IF
             END-IF
         END-PERFORM
         IF WS-OK = 1
             MOVE WS-STATE TO L-STATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-TEST-FIND.
 COPY CLTEST.
