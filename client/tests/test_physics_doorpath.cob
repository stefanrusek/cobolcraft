*> Implementation test of the player walking through a door whose floor is a few pixels lower than the floor before it
*> (docs/protocol/13 section 1.4 step height 0.6; docs/protocol/51 door and dirt_path shapes; client/src/physics.cob PHYS-STEP-UP). A one
*> wide doorway (stone walls, a lintel at y 12) stands at x 0, z 3 on the test world (floor at y 9); the door above the doorway cell is
*> open or closed and the floor block of that cell is stone or a dirt_path (top 1/16 lower). The Player walks +Z from (0.6, 10, 0.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PHYSICS-DOORPATH.
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
 01 WS-FLOOR               PIC X(40).
 01 WS-OPEN                PIC X(5).
 01 WS-LEDGE               BINARY-LONG.
 01 WS-FLOOR-STATE         BINARY-LONG.
 01 WS-LOWER-STATE         BINARY-LONG.
 01 WS-UPPER-STATE         BINARY-LONG.
 01 WS-STONE-STATE         BINARY-LONG.
 01 WS-PATH-STATE          BINARY-LONG.
 01 WS-PY                  BINARY-LONG VALUE 9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 0 TO PL-YAW

     MOVE "stone" TO WS-FLOOR
     MOVE "true" TO WS-OPEN
     PERFORM BUILD-DOORWAY
     PERFORM WALK-THROUGH
     MOVE "doorpath an open door over a full block floor lets the Player through" TO TL-CASE
     PERFORM ASSERT-PASSED

     MOVE "dirt_path" TO WS-FLOOR
     PERFORM BUILD-DOORWAY
     PERFORM WALK-THROUGH
     MOVE "doorpath an open door over a dirt_path floor lets the Player through" TO TL-CASE
     PERFORM ASSERT-PASSED

     MOVE "false" TO WS-OPEN
     PERFORM BUILD-DOORWAY
     PERFORM WALK-THROUGH
     MOVE "doorpath a closed door over a dirt_path floor stops the Player" TO TL-CASE
     PERFORM ASSERT-STOPPED

     MOVE "stone" TO WS-FLOOR
     PERFORM BUILD-DOORWAY
     PERFORM WALK-THROUGH
     MOVE "doorpath a closed door over a full block floor stops the Player" TO TL-CASE
     PERFORM ASSERT-STOPPED

*>   A dirt_path in the way of a Player on the full floor, with no door: the 1/16 drop and rise are no obstacle.
     MOVE "dirt_path" TO WS-FLOOR
     MOVE "true" TO WS-OPEN
     PERFORM BUILD-DOORWAY
     MOVE 0 TO WS-X
     PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 11
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     END-PERFORM
     PERFORM WALK-THROUGH
     MOVE "doorpath a dirt_path cell without a door lets the Player through" TO TL-CASE
     PERFORM ASSERT-PASSED

*>   The path in front of the door: the Player stands on dirt_path cells (z 0 to 2) and walks up the 1/16 step into the doorway.
     MOVE "stone" TO WS-FLOOR
     MOVE "true" TO WS-OPEN
     PERFORM BUILD-DOORWAY
     MOVE "dirt_path" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-PATH-STATE
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 2
         PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 1
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-PY WS-Z WS-PATH-STATE
         END-PERFORM
     END-PERFORM
     PERFORM WALK-THROUGH
     MOVE "doorpath an open door after a dirt_path approach lets the Player through" TO TL-CASE
     PERFORM ASSERT-PASSED

*>   The same approach to a closed door: the step is made, the door still stops the Player.
     MOVE "false" TO WS-OPEN
     PERFORM BUILD-DOORWAY
     PERFORM WALK-THROUGH
     MOVE "doorpath a closed door after a dirt_path approach stops the Player" TO TL-CASE
     PERFORM ASSERT-STOPPED
     STOP RUN.

*> The doorway cell (0, 10..11, 3) over WS-FLOOR at (0, 9, 3), walls on both sides and a lintel; the Player back at the start.
 BUILD-DOORWAY.
     MOVE 3 TO WS-Z
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     MOVE "stone" TO WS-BLOCK
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-STONE-STATE
     PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 12
         MOVE -1 TO WS-X
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE-STATE
         MOVE 1 TO WS-X
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE-STATE
     END-PERFORM
     MOVE 0 TO WS-X
     MOVE 12 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE-STATE
     MOVE WS-FLOOR TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     MOVE 9 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "oak_door" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     STRING "facing=north,half=lower,hinge=left,open=" FUNCTION TRIM(WS-OPEN) ",powered=false" DELIMITED BY SIZE INTO WS-P1
     PERFORM FIND-STATE
     MOVE 10 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO WS-P1
     STRING "facing=north,half=upper,hinge=left,open=" FUNCTION TRIM(WS-OPEN) ",powered=false" DELIMITED BY SIZE INTO WS-P1
     PERFORM FIND-STATE
     MOVE 11 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE.

*> The Player on the floor at the start, W held for 60 ticks (0.2 a tick: 12 blocks).
 WALK-THROUGH.
     MOVE 0.6 TO PL-X
     MOVE 10 TO PL-Y
     MOVE 0.5 TO PL-Z
     MOVE 0 TO PL-VY
     MOVE 0 TO PL-YAW
     MOVE 60 TO WS-TICKS
     PERFORM WALK.

 ASSERT-PASSED.
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Z > 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N.

 ASSERT-STOPPED.
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Z < 3.9
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N.

 FIND-STATE.
     CALL "DPATH-TEST-FIND" USING WS-BLOCK WS-P1 WS-P2 WS-P3 WS-STATE.

*> W held for WS-TICKS client ticks.
 WALK.
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PHYSICS-DOORPATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DPATH-TEST-FIND.
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
 END PROGRAM DPATH-TEST-FIND.
 COPY CLTEST.
