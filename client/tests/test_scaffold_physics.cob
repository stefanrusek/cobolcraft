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
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-BH                  FLOAT-LONG.
 01 WS-BHT                 FLOAT-LONG.
 01 WS-BHIT                BINARY-LONG.
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

*>   The interaction shape refines the face of a hit (51 section 1.8.3 item 3). A cauldron at (0, 9, 3), the eye at (0.5, 12.6, 0.7) looking 45 degrees down along +Z: the ray
*>   crosses the top of the cell at z 3.3 over the open inside and hits the inner far wall (outline, entered through the north side, face 2) at (0.5, 9.425, 3.875); the
*>   inside box (2, 4, 2, 14, 16, 14) is entered earlier, through its top, so the reported face is the top (1) and the hit point stays on the wall.
     MOVE 11 TO PL-Y
     MOVE 0.5 TO PL-X
     MOVE 0.7 TO PL-Z
     MOVE 45 TO PL-PITCH
     MOVE 0 TO PL-YAW
     MOVE 9 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE "cauldron" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "R4 raycast into a cauldron hits the inner wall" TO TL-CASE
     COMPUTE TL-OBSERVED-N = TG-HIT * 1000 + TG-X * 100 + TG-Y * 10 + TG-Z
     MOVE 1093 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE "R4 raycast into a cauldron: the interaction shape gives the face (top), not the wall's north side" TO TL-CASE
     MOVE TG-FACE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE "R4 raycast into a cauldron: the cursor stays on the wall (y 0.425)" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = TG-CY * 1000
     MOVE 425 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE "composter" TO WS-BLOCK
     MOVE "level=0" TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "R4 raycast into a composter: the full-cube interaction shape gives the top face" TO TL-CASE
     MOVE TG-FACE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE "stone" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "R4 raycast into a stone block: the ray enters through the top face" TO TL-CASE
     MOVE TG-FACE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     MOVE 0 TO PL-PITCH
     MOVE 11 TO WS-Y
     MOVE 3 TO WS-Z

*>   A shulker box facing up at (0, 9, 3) with its lid fully open (31-1 13.2: ticks 10) is the box (0,0,0,16,24,16) (51 section 3.8.8): a thin box at y 10.2 to 10.3 over it collides,
*>   it does not over a closed one; the 45 degree ray from the eye (0.5, 12.6, 0.7) enters the extension through its north side (face 2) at y 10.3, a closed one through its top.
     MOVE 11 TO PL-Y
     MOVE 0.5 TO PL-X
     MOVE 0.7 TO PL-Z
     MOVE 45 TO PL-PITCH
     MOVE 0 TO PL-YAW
     MOVE 9 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE "shulker_box" TO WS-BLOCK
     MOVE "facing=up" TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "SHULKER-NOTE" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.5 TO WS-BX
     MOVE 10.2 TO WS-BY
     MOVE 3.5 TO WS-BZ
     MOVE 0.1 TO WS-BH
     MOVE 0.1 TO WS-BHT
     CALL "PHYS-COLLIDES-BOX" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-BH WS-BHT WS-BHIT
     MOVE "R4 shulker box: a closed lid ends at the cell top" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BHIT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "R4 raycast a closed shulker box is entered through its top" TO TL-CASE
     COMPUTE TL-OBSERVED-N = TG-HIT * 10 + TG-FACE
     MOVE 11 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE "R4 shulker box: the client keeps the box (count, used, face up)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SB-COUNT * 1000 + SB-USED(1) * 100 + SB-FACE(1) * 10 + SB-READY
     MOVE 1111 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE 10 TO SB-T(1) SB-TOLD(1)
     MOVE 2 TO SB-STATUS(1)
     CALL "PHYS-COLLIDES-BOX" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-BH WS-BHT WS-BHIT
     MOVE "R4 shulker box: an open lid (up 24 pixels) collides at y 10.2" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-BHIT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "RAYCAST" USING CLIENT-STATE
     MOVE "R4 raycast an open shulker box is entered through its north side (face 2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = TG-HIT * 10 + TG-FACE
     MOVE 12 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE 0 TO SB-USED(1)
     SUBTRACT 1 FROM SB-COUNT
     MOVE "stone" TO WS-BLOCK
     MOVE SPACES TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO PL-PITCH

*>   The collision of a fence reaches 1.5 blocks (24 pixels, 51 section 3.2): a Player dropped on a fence post lands on its top at y 11.5 (the cell below the feet is a collider too).
     MOVE 10 TO WS-Y
     MOVE "oak_fence" TO WS-BLOCK
     MOVE "north=false,east=false,south=false,west=false,waterlogged=false" TO WS-P1
     PERFORM FIND-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.5 TO PL-X
     MOVE 3.5 TO PL-Z
     MOVE 14.0 TO PL-Y
     MOVE 0 TO PL-VY
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "R4 fence: a falling Player stands on the 24 pixel collision of a post (y 11.5)" TO TL-CASE
     MOVE "0.5000/11.5000/3.5000" TO TL-EXPECTED
     PERFORM ASSERT-POSITION
     MOVE "R4 fence: standing on the post counts as on the ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-ON-GROUND TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     MOVE 0.5 TO PL-X PL-Z
     MOVE 10 TO PL-Y
     MOVE 11 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 0 TO PL-VY

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
