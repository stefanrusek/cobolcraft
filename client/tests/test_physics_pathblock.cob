*> Implementation test (lane bugbed, operator report of try16: "path block in front of a door no longer blocks entry"; docs/protocol/13 section 1.4 step height 0.6, 51 block
*> shapes: dirt_path is 15/16 high): a dirt_path block standing on the floor, at the Player's feet level, is a step of 0.9375, more than the step height 0.6, so walking
*> into it stops the Player, in the open and in front of a doorway with an open door (the same as a full block); jumping over it works. A dirt_path as the floor of the doorway
*> cell (a step of 1/16) lets the Player through (the lane doorpath, test_physics_doorpath). The Player walks +Z from (0.6, 10, 0.5) on the test world (floor at y 9).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PHYSICS-PATHBLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-JUMP-KEY            BINARY-LONG.
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
 01 WS-STONE-STATE         BINARY-LONG.
 01 WS-PATH-STATE          BINARY-LONG.
 01 WS-BLOCK-STATE         BINARY-LONG.
 01 WS-JUMP                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 0 TO PL-YAW
     MOVE "stone" TO WS-BLOCK
     MOVE SPACES TO WS-P1 WS-P2 WS-P3
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-STONE-STATE
     MOVE "dirt_path" TO WS-BLOCK
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-PATH-STATE

     MOVE WS-PATH-STATE TO WS-BLOCK-STATE
     MOVE 0 TO WS-JUMP
     PERFORM BUILD-AND-WALK
     MOVE "pathblock a dirt_path block on the floor in the open stops the Player (0.9375 is more than the step)" TO TL-CASE
     PERFORM ASSERT-STOPPED

     MOVE WS-STONE-STATE TO WS-BLOCK-STATE
     PERFORM BUILD-AND-WALK
     MOVE "pathblock a full block on the floor stops the Player too" TO TL-CASE
     PERFORM ASSERT-STOPPED

     MOVE WS-PATH-STATE TO WS-BLOCK-STATE
     MOVE 1 TO WS-JUMP
     PERFORM BUILD-AND-WALK
     MOVE "pathblock jumping and walking gets over the dirt_path block" TO TL-CASE
     PERFORM ASSERT-PASSED

*>   In front of a doorway (stone walls, an open door, a lintel at z 5): the path block at z 3 still stops the Player before it.
     MOVE 0 TO WS-JUMP
     MOVE WS-PATH-STATE TO WS-BLOCK-STATE
     PERFORM BUILD-DOORWAY
     PERFORM BUILD-AND-WALK-DOOR
     MOVE "pathblock a dirt_path block on the floor before an open door stops the Player" TO TL-CASE
     PERFORM ASSERT-STOPPED
     MOVE 1 TO WS-JUMP
     PERFORM BUILD-AND-WALK-DOOR
     MOVE "pathblock jumping over the dirt_path block before an open door gets the Player through the door" TO TL-CASE
     PERFORM ASSERT-PASSED
     STOP RUN.

*> The cell (0, 10, 3) holds WS-BLOCK-STATE, nothing else is in the way (the doorway of the other case is cleared).
 BUILD-AND-WALK.
     MOVE 0 TO WS-X
     MOVE 3 TO WS-Z
     PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 12
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     END-PERFORM
     MOVE 10 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-BLOCK-STATE
     PERFORM WALK-FROM-START.

*> The doorway at z 5: stone on both sides and a lintel at y 12, an open oak door in the cell (0, 10..11, 5); the path block at (0, 10, 3).
 BUILD-DOORWAY.
     MOVE 5 TO WS-Z
     PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 12
         MOVE -1 TO WS-X
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE-STATE
         MOVE 1 TO WS-X
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE-STATE
     END-PERFORM
     MOVE 0 TO WS-X
     MOVE 12 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE-STATE
     MOVE "oak_door" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     MOVE "facing=north,half=lower,hinge=left,open=true,powered=false" TO WS-P1
     PERFORM FIND-STATE
     MOVE 10 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO WS-P1
     MOVE "facing=north,half=upper,hinge=left,open=true,powered=false" TO WS-P1
     PERFORM FIND-STATE
     MOVE 11 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE.

 BUILD-AND-WALK-DOOR.
     MOVE 0 TO WS-X
     MOVE 3 TO WS-Z
     MOVE 10 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-BLOCK-STATE
     PERFORM WALK-FROM-START.

*> The Player at the start, W (and Space when WS-JUMP is 1) held for 60 ticks (0.2 a tick: 12 blocks).
 WALK-FROM-START.
     MOVE 0.6 TO PL-X
     MOVE 10 TO PL-Y
     MOVE 0.5 TO PL-Z
     MOVE 0 TO PL-VY
     MOVE 0 TO PL-YAW
     MOVE 60 TO WS-TICKS
     MOVE CC-KEY-W TO WS-KEY
     MOVE CC-KEY-SPACE TO WS-JUMP-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     IF WS-JUMP = 1
         CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-JUMP-KEY WS-DOWN
     END-IF
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     IF WS-JUMP = 1
         CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-JUMP-KEY WS-UP
     END-IF
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP.

 ASSERT-PASSED.
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Z > 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N.

*> Stopped at the path block's face (z 3 less the half width 0.35).
 ASSERT-STOPPED.
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Z < 2.8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-N.

 FIND-STATE.
     CALL "DPATH-TEST-FIND" USING WS-BLOCK WS-P1 WS-P2 WS-P3 WS-STATE.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PHYSICS-PATHBLOCK.

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
