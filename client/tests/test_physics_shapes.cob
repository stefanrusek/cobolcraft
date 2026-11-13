*> Implementation test of the collision and outline shapes in the client (T4502, T4503; docs/protocol/51-block-shapes.md;
*> client/src/physics.cob, raycast.cob, render-list.cob HIGHLIGHT-MESH): the standard set's shape tables are built over the test
*> world (floor at y 9). A Player walks onto bottom slabs (step-up 0.6), is stopped by a full block, walks through a torch and
*> climbs a ladder; the target ray passes over a bottom slab and hits a torch where it is; the outline mesh has the boxes of the shape.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PHYSICS-SHAPES.
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
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 270 TO PL-YAW
     MOVE 0 TO WS-Z
     MOVE 10 TO WS-Y
     MOVE SPACES TO WS-P1 WS-P2 WS-P3

*>   Bottom slabs from x 3 to 6: the Player steps up onto them (0.5 is under the step height 0.6) and walks on.
     MOVE "oak_slab" TO WS-BLOCK
     MOVE "type=bottom,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 6
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     END-PERFORM
     MOVE 22 TO WS-TICKS
     PERFORM WALK
     MOVE "physics walking onto bottom slabs steps up to y 10.5 and goes on" TO TL-CASE
     MOVE "5.1000/10.5000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     MOVE 1 TO TL-EXPECTED-N
     MOVE "physics standing on a slab counts as on the ground" TO TL-CASE
     MOVE PL-ON-GROUND TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 270 TO PL-YAW

*>   Walking back (yaw 90) drops from the slabs to the floor again.
     MOVE 90 TO PL-YAW
     MOVE 40 TO WS-TICKS
     PERFORM WALK
     MOVE "physics walking off the slabs drops back to the floor" TO TL-CASE
     MOVE "-3.1000/10.0000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     MOVE 270 TO PL-YAW

*>   A full block one high is not climbed: the Player stops at its face.
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 6
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     END-PERFORM
     MOVE "stone" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     MOVE 3 TO WS-X
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.5 TO PL-X
     MOVE 40 TO WS-TICKS
     PERFORM WALK
     MOVE "physics a one block high wall stops the Player at its face" TO TL-CASE
     MOVE "2.6500/10.0000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION

*>   A torch has no collision: the Player walks through it.
     MOVE "torch" TO WS-BLOCK
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.5 TO PL-X
     MOVE 22 TO WS-TICKS
     PERFORM WALK
     MOVE "physics a torch does not stop the Player" TO TL-CASE
     MOVE "5.1000/10.0000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION

*>   A ladder (facing west: the panel at the east edge of the cell): the Player walks up to it and climbs.
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     MOVE "ladder" TO WS-BLOCK
     MOVE "facing=west,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 16
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     END-PERFORM
     MOVE 0.5 TO PL-X
     MOVE 10 TO PL-Y
     MOVE 40 TO WS-TICKS
     PERFORM WALK
     MOVE "physics walking into a ladder climbs it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y > 12 AND PL-Y < 17 AND PL-X < 3.9
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-N
*>   Sneaking on the ladder holds the Player where it is for the 10 ticks (only the tick after the key is lifted sinks it, by 0.08).
     MOVE 13 TO PL-Y
     MOVE 0 TO PL-VY
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     MOVE "physics sneaking on a ladder does not sink" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y > 12.9 AND PL-Y < 13.01
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 16
         CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     END-PERFORM
     MOVE 10 TO WS-Y
     MOVE 10 TO PL-Y
     MOVE 0 TO PL-VY

*>   Targeting: eye (0.5, 11.6, 0.5) looking along +Z (yaw 0). A bottom slab at (0, 11, 3) is under the ray.
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 0.5 TO PL-X PL-Z
     MOVE 10 TO PL-Y
     MOVE 3 TO WS-Z
     MOVE 0 TO WS-X
     MOVE 11 TO WS-Y
     MOVE "oak_slab" TO WS-BLOCK
     MOVE "type=bottom,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "raycast the ray passes over a bottom slab" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE TG-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE "stone" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "raycast the ray hits a stone block at z 3 on its north face" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = TG-HIT * 100 + TG-Z * 10 + TG-FACE
     COMPUTE TL-EXPECTED-N = 1 * 100 + 3 * 10 + 2
     PERFORM ASSERT-N
     MOVE "torch" TO WS-BLOCK
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "raycast the ray hits a torch where its outline is (z 3.375, north face)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = TG-HIT * 100 + TG-Z * 10 + TG-FACE
     COMPUTE TL-EXPECTED-N = 1 * 100 + 3 * 10 + 2
     PERFORM ASSERT-N
     MOVE "raycast the torch cursor is on its outline face" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = TG-CZ * 1000
     MOVE 375 TO TL-EXPECTED-N
     PERFORM ASSERT-N
*>   Off to the side of the torch the ray goes through the cell.
     MOVE 0.1 TO PL-X
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "raycast a ray beside the torch misses it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE TG-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0.5 TO PL-X

*>   A cell with no outline (technical air) is not a target.
     MOVE "void_air" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "raycast the ray goes through technical air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE TG-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   The outline mesh: one box for a torch (144 vertices), two for a straight stair (288).
     MOVE 64 TO UA-W UA-H
     MOVE 0 TO WS-STATE
     MOVE 0 TO WS-EYE(1) WS-EYE(2) WS-EYE(3)
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE 0.5 TO PL-X
     MOVE 1 TO TG-HIT
     MOVE 0 TO TG-X
     MOVE 11 TO TG-Y
     MOVE 3 TO TG-Z
     CALL "HIGHLIGHT-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "highlight a torch has one box of 144 vertices" TO TL-CASE
     MOVE RL-HL-COUNT TO TL-OBSERVED-N
     MOVE 144 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE "oak_stairs" TO WS-BLOCK
     MOVE "facing=north,half=bottom,shape=straight,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     MOVE 0 TO WS-X
     MOVE 11 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "HIGHLIGHT-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "highlight a straight stair has two boxes of 144 vertices" TO TL-CASE
     MOVE RL-HL-COUNT TO TL-OBSERVED-N
     MOVE 288 TO TL-EXPECTED-N
     PERFORM ASSERT-N
*>   A cell with no outline shape (air) falls back to the cube.
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     CALL "HIGHLIGHT-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "highlight an empty cell is drawn as the cube, 144 vertices" TO TL-CASE
     MOVE RL-HL-COUNT TO TL-OBSERVED-N
     MOVE 144 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     STOP RUN.

 FIND-STATE.
     CALL "BSH-TEST-FIND" USING WS-BLOCK WS-P1 WS-P2 WS-P3 WS-STATE.

*> W held for WS-TICKS client ticks.
 WALK.
     MOVE CC-KEY-W TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP.

 ASSERT-POSITION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PHYSICS-SHAPES.

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
