*> Test of the R4 collision contexts and targeting contexts of docs/protocol/51-block-shapes.md (sections 1.8.2, 1.8.3, 3.8.5; client/src/physics.cob, raycast.cob,
*> render-list.cob): a Player falls onto scaffolding and stands on its stable shape, a sneaking Player passes through it (and meets the plate of an unstable one),
*> a held scaffolding item makes the block a full cube for the ray, and the outline mesh of a cauldron (13 boxes) and of an offset flower.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCAFFOLD-PHYSICS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY CTBSHAPE.
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
 01 WS-I                   BINARY-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ITEM-STATUS         BINARY-LONG.
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
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 0 TO WS-X WS-Z
     MOVE 11 TO WS-Y
     MOVE SPACES TO WS-P1 WS-P2 WS-P3

*>   A scaffolding block (distance 0) at (0, 11, 0): a Player dropped from 13.5 lands on its top (y 12) and stands there (the stable shape is above the cell's top).
     MOVE "scaffolding" TO WS-BLOCK
     MOVE "distance=0,bottom=false,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     PERFORM DROP-PLAYER
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "R4 scaffolding: a falling Player lands on the stable shape and stands on top" TO TL-CASE
     MOVE "0.5000/12.0000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     MOVE 1 TO TL-EXPECTED-N
     MOVE "R4 scaffolding: standing on top counts as on the ground" TO TL-CASE
     MOVE PL-ON-GROUND TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   Sneaking (Left Shift held), the Player goes through the stable shape and down the scaffolding (no hold: only ladders hold a sneaking Player, 53 section 5.6) to the floor.
     PERFORM DROP-PLAYER
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 60 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "R4 scaffolding: a sneaking Player descends through it to the floor (y 10)" TO TL-CASE
     MOVE "0.5000/10.0000/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP

*>   An unstable scaffolding (distance 3, bottom): the sneaking Player lands on the plate (top y 11.125).
     MOVE "distance=3,bottom=true,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     PERFORM DROP-PLAYER
     MOVE CC-KEY-LEFT-SHIFT TO WS-KEY
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-DOWN
     MOVE 60 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "R4 scaffolding: a sneaking Player lands on the plate of an unstable one (y 11.125)" TO TL-CASE
     MOVE "0.5000/11.1250/0.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-KEY WS-UP
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR

*>   Targeting: eye (0.5, 11.6, 0.5) looking along +Z; scaffolding (distance 0) at (0, 11, 3) has posts at the corners and a top slab (y 14 to 16 pixels): the middle of the cell is
*>   open under the slab. The ray at height 11.6 goes through the open middle; with a scaffolding item held the block is a full cube and the ray hits it.
     MOVE 10 TO PL-Y
     MOVE 0.5 TO PL-X PL-Z
     MOVE 0 TO PL-VY
     MOVE 3 TO WS-Z
     MOVE "distance=0,bottom=false,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO PL-SLOT-COUNT(PL-HELD + 1)
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "R4 raycast a ray through the open middle of scaffolding misses it with an empty hand" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE TG-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE "scaffolding" TO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ITEM-ID WS-ITEM-ROW WS-ITEM-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "R4 raycast scaffolding is a full cube for a Player holding a scaffolding item" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE TG-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0 TO PL-SLOT-COUNT(PL-HELD + 1)
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR

*>   The outline mesh (08 section 10.8.6): a cauldron has 13 boxes (144 vertices each); a dandelion at (3, 11, 3) is drawn moved by its offset (-0.25, 0, 0.0167).
     MOVE 64 TO UA-W UA-H
     MOVE 0 TO WS-EYE(1) WS-EYE(2) WS-EYE(3)
     MOVE "cauldron" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 1 TO TG-HIT
     MOVE WS-X TO TG-X
     MOVE WS-Y TO TG-Y
     MOVE WS-Z TO TG-Z
     CALL "HIGHLIGHT-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "R4 highlight a cauldron has 13 boxes of 144 vertices" TO TL-CASE
     MOVE RL-HL-COUNT TO TL-OBSERVED-N
     MOVE 1872 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE 3 TO WS-X
     MOVE "dandelion" TO WS-BLOCK
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE WS-X TO TG-X
     CALL "HIGHLIGHT-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1.0E30 TO WS-MIN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-HL-COUNT
         MOVE RL-HL-X(WS-I) TO WS-V
         IF WS-V < WS-MIN
             MOVE WS-V TO WS-MIN
         END-IF
     END-PERFORM
     MOVE "R4 highlight a dandelion is drawn moved by its offset (x 3.0605 = 3 + 5/16 - 0.25 - 0.002)" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MIN * 10000
     MOVE 30605 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     MOVE "short_grass" TO WS-BLOCK
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "HIGHLIGHT-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1.0E30 TO WS-MIN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-HL-COUNT
         MOVE RL-HL-X(WS-I) TO WS-V
         IF WS-V < WS-MIN
             MOVE WS-V TO WS-MIN
         END-IF
     END-PERFORM
     MOVE "R4 highlight short grass stays in its cell (x 3.123 = 3 + 2/16 - 0.002, only the model moves)" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-MIN * 10000
     MOVE 31230 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     GOBACK.

*> The Player is put 3.5 above the scaffolding cell at (0.5, 13.5, 0.5), at rest.
 DROP-PLAYER.
     MOVE 0.5 TO PL-X PL-Z
     MOVE 13.5 TO PL-Y
     MOVE 0 TO PL-VY
     MOVE 0 TO PL-YAW.

 FIND-STATE.
     CALL "BSH-TEST-FIND" USING WS-BLOCK WS-P1 WS-P2 WS-P3 WS-STATE.

 ASSERT-POSITION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-SCAFFOLD-PHYSICS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TEST-FIND.
*> USING block key, three texts of comma separated "name=value" constraints (spaces = none), state out: the first state of the block
*> that holds them all.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTBSHAPE.
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
