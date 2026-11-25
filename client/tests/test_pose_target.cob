*> Implementation test of the pick ray at every pose (CC-0010; docs/protocol/53 section 2.1 eye heights, 13 section 2 break): a Player crawling in a gap
*> 1.0 high (pose 3, eye 0.4 above the feet) or swimming under water with pitch 0 aims at the block in front of it at the eye's own height, never
*> the block above its head; pressing the left button sends Start Destroy for that block, and Use Item On on the right button names it too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-POSE-TARGET.
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
 01 WS-ED-X                PIC -(4)9.
 01 WS-ED-Y                PIC -(4)9.
 01 WS-ED-Z                PIC -(4)9.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-EX                  FLOAT-LONG VALUE 21.5.
 01 WS-EY                  FLOAT-LONG VALUE 10.0.
 01 WS-EZ                  FLOAT-LONG VALUE 2.0.
 01 WS-WATER               BINARY-LONG VALUE 4.
 01 WS-STONE               BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 1 TO CT-OPEN
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE WS-STONE TO WS-STATE
     MOVE 1 TO PL-MODE
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "N" TO TL-MODE

*>   A tunnel 1.0 high: stone over the cells y 11 of x 20 to 22, z -1 to 6, the floor is the world's (y 9 and below), a wall block in the cell (21, 10, 3).
     PERFORM VARYING WS-X FROM 20 BY 1 UNTIL WS-X > 22
         PERFORM VARYING WS-Z FROM -1 BY 1 UNTIL WS-Z > 6
             MOVE 11 TO WS-Y
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 21 TO WS-X
     MOVE 10 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 21.5 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     MOVE 0 TO PL-YAW PL-PITCH PL-VX PL-VY PL-VZ PL-POSE
     MOVE 6 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "pose target: the player crawls in a gap 1.0 high (pose 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-POSE TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE "pose target: crawling with pitch 0 the target is the wall block in front (21, 10, 3), not the ceiling above" TO TL-CASE
     MOVE "1 21 10 3" TO TL-EXPECTED
     PERFORM TARGET-TEXT
     PERFORM ASSERT-T

*>   Start Destroy (left button) names the block in front: Player Action 0x29, status 0, position (21, 10, 3), face north (2), sequence 1.
     CALL "TEST-LEFT" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "pose target: crawling, the left button sends Start Destroy for the block in front (21, 10, 3)" TO TL-CASE
     MOVE "2900000005400000300a0201" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:24) TO TL-OBSERVED
     PERFORM ASSERT-T

*>   A boat (type 90, 0.5625 high) on the tunnel floor in front: the crawling player's ray passes through its box at the eye's own height, so the left
*>   button sends Attack with its id (a ray from 1.6 above the feet would pass over it).
     MOVE 43 TO WS-ID
     MOVE 90 TO WS-TYPE
     CALL "TEST-ADD-TYPED" USING CLIENT-STATE WS-CONN WS-ID WS-TYPE WS-EX WS-EY WS-EZ
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-LEFT" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "pose target: crawling, the left button attacks the boat on the floor of the tunnel (Attack with id 43)" TO TL-CASE
     MOVE "012b" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     PERFORM ASSERT-T
     CALL "TEST-REMOVE-ENTITY" USING CLIENT-STATE WS-CONN WS-ID

*>   Swimming (pose 3) in a pool of water (state 4 is a water source: the cells x 3 to 12, z -4 to 4, y 7 to 9) towards its stone wall at x 13: the ray runs
*>   along the water at the eye's height (7.9) into the wall block (13, 7, 0), not into the block above it (13, 9, 0).
     MOVE 1 TO ST-FLUID(5)
     MOVE 0 TO ST-LEVEL(5) ST-OPAQUE(5)
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 12
         PERFORM VARYING WS-Z FROM -4 BY 1 UNTIL WS-Z > 4
             PERFORM VARYING WS-Y FROM 7 BY 1 UNTIL WS-Y > 9
                 CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-WATER
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 9.5 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 7.5 TO PL-Y
     MOVE 270 TO PL-YAW
     MOVE 0 TO PL-PITCH
     MOVE 3 TO PL-POSE
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "pose target: swimming with pitch 0 the target is the pool wall in front (13, 7, 0), not the block above (13, 9, 0)" TO TL-CASE
     MOVE "1 13 7 0" TO TL-EXPECTED
     PERFORM TARGET-TEXT
     PERFORM ASSERT-T
     STOP RUN.

 TARGET-TEXT.
     MOVE SPACES TO TL-OBSERVED
     IF TG-HIT = 1
         MOVE TG-X TO WS-ED-X
         MOVE TG-Y TO WS-ED-Y
         MOVE TG-Z TO WS-ED-Z
         STRING "1 " FUNCTION TRIM(WS-ED-X) " " FUNCTION TRIM(WS-ED-Y) " " FUNCTION TRIM(WS-ED-Z)
             DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         MOVE "0" TO TL-OBSERVED
     END-IF.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-T.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-POSE-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LEFT.
*> USING CLIENT-STATE: one CL-STEP with the left button going down, then one with it going up.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 WS-B                BINARY-LONG.
    05 WS-C                BINARY-LONG.
    05 WS-X                FLOAT-SHORT.
    05 WS-Y                FLOAT-SHORT.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     INITIALIZE WS-EVENT
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     MOVE CC-BUTTON-LEFT TO WS-A
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     GOBACK.
 END PROGRAM TEST-LEFT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ADD-TYPED.
*> USING CLIENT-STATE, connection, entity id, entity type, x, y, z: feeds Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID.
    05 WS-UUID-HI          PIC X(8).
    05 WS-UUID-LO          PIC X(8).
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-LONG-X REDEFINES WS-LONG PIC X(8).
 01 WS-I                   BINARY-LONG.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-ANGLE               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-ID L-TYPE L-X L-Y L-Z.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE LOW-VALUES TO WS-UUID
     MOVE L-ID TO WS-LONG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-LONG-X(9 - WS-I:1) TO WS-UUID-LO(WS-I:1)
     END-PERFORM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     PERFORM 3 TIMES
         CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-ANGLE
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM TEST-ADD-TYPED.

 COPY CLTEST.
