*> Implementation test of the on-ground flag of a landing tick (CC-0011; docs/protocol 18 section 3: Entity.move goes along y first, then x and z, and sets onGround when
*> the vertical movement was blocked while moving down): a Player walking, then sprinting, down a descent of six one-block steps (full blocks) strides off a step in
*> the same tick it lands on it, so a probe under the final position finds nothing. The tick still reports the ground: the Player is never more than six ticks in a
*> row off the ground (the fall of a block takes five ticks) and the descent counts landings (walking five, sprinting two or more: a sprinting Player skips steps).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LAND-GROUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-AIR                 BINARY-LONG.
 01 WS-MAX-AIR             BINARY-LONG.
 01 WS-LANDINGS            BINARY-LONG.
 01 WS-TICK                BINARY-LONG.
 01 WS-TOPC                BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-D1                  PIC 99.
 01 WS-D2                  PIC 99.
 01 WS-D3                  PIC 99.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 1 TO CT-OPEN
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "T" TO TL-MODE
*>   A platform (cells y 10 to 15, top 16) over z -2 to 2 and six steps from z 3: step j (0 to 5) stands to the cell y 15 - j, its top at 16 - j; x -1 to 1 wide.
     PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 1
         PERFORM VARYING WS-Z FROM -2 BY 1 UNTIL WS-Z > 8
             MOVE 15 TO WS-TOPC
             IF WS-Z > 2
                 COMPUTE WS-TOPC = 15 - (WS-Z - 3)
             END-IF
             PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > WS-TOPC
                 CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-RUN FROM 0 BY 1 UNTIL WS-RUN > 1
         MOVE 0.5 TO PL-X
         MOVE 2.5 TO PL-Z
         MOVE 16 TO PL-Y
         MOVE 0 TO PL-YAW PL-PITCH PL-VX PL-VY PL-VZ PL-POSE PL-SENT-YAW
         MOVE 3 TO WS-TICK
         CALL "TEST-TICKS" USING CLIENT-STATE WS-TICK
         MOVE 0.5 TO PL-X
         MOVE 2.5 TO PL-Z
         MOVE 16 TO PL-Y
         MOVE 0 TO PL-VX PL-VY PL-VZ
         IF WS-RUN = 1
             MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
             CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
         END-IF
         MOVE CC-KEY-W TO WS-KEY
         CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
         MOVE 0 TO WS-AIR WS-MAX-AIR WS-LANDINGS
         PERFORM VARYING WS-TICK FROM 1 BY 1 UNTIL WS-TICK > 60
             CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
             IF PL-ON-GROUND = 0
                 ADD 1 TO WS-AIR
                 IF WS-AIR > WS-MAX-AIR
                     MOVE WS-AIR TO WS-MAX-AIR
                 END-IF
             ELSE
                 IF WS-AIR > 0 AND PL-Y > 10.5
                     ADD 1 TO WS-LANDINGS
                 END-IF
                 MOVE 0 TO WS-AIR
             END-IF
         END-PERFORM
         MOVE WS-MAX-AIR TO WS-D1
         MOVE WS-LANDINGS TO WS-D2
         MOVE WS-RUN TO WS-D3
         MOVE SPACES TO TL-CASE
         STRING "land ground run " WS-D3 " (0 walking, 1 sprinting) down six one-block steps the Player never stays off the ground for more than six ticks in a row and lands at least twice on the way down"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE SPACES TO TL-OBSERVED
         IF WS-MAX-AIR <= 6 AND WS-LANDINGS >= 2
             MOVE "ok" TO TL-OBSERVED
         ELSE
             STRING "longest air " WS-D1 " landings " WS-D2 DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE CC-KEY-W TO WS-KEY
         CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
         IF WS-RUN = 1
             MOVE CC-KEY-LEFT-CONTROL TO WS-KEY
             CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
         END-IF
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-LAND-GROUND.
 COPY CLTEST.
