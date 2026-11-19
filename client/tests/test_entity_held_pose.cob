*> T28400 (lane 002-lane-p70d): the item a mob holds, posed as ItemInHandLayer places it (34-1 section 8.3; display contexts 12 section 8.2). ENTITY-ARM-LOCAL and ENTITY-HAND-FRAME
*> recover the frame of an arm part from its baked cuboid (checked on a box moved by a known rotation and translation); a zombie drawn with an item in each hand has the pivots of its arms
*> as frame origins (the shoulder at (-+0.3125, 1.376, 0) of the entity, 34-7 1.6: translate (0, -1.501, 0) then the flips) and axes a block long at right angles; ENTITY-HELD-POSED puts
*> the item in the frame: rotate X -90, Y 180, translate (+-1, 2, -10) / 16 (a baby (0, 1, -4.5) / 16), the display transform (right and left entries, the right one mirrored for the left arm,
*> the defaults), the unit cube of a block item or the icon's front and back quads. Expected vertices from an independent script (the frame of the identity axes at the origin (0.5, 1, 0.25)
*> of an entity (0.5, 0, 0.5) from the eye): stick right (0, 3, 1) / 0.55, stick left its own entry (rotation 0 90 -55, translation 0 4 0.5, scale 0.85), stone right (75, 45, 0) / 0.375 and left
*> the mirrored entry (75, -45, 0), a baby's offset, the defaults of the stand-in set's cube.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-HELD-POSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-BOX.
    05 WS-B                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-LOCAL.
    05 WS-L                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-FRAME.
    05 WS-F                FLOAT-LONG OCCURS 12 TIMES.
 01 WS-CORNERS.
    05 WS-CP OCCURS 8 TIMES.
       10 WS-CX            FLOAT-SHORT.
       10 WS-CY            FLOAT-SHORT.
       10 WS-CZ            FLOAT-SHORT.
 01 WS-EXPECT.
    05 WS-EX               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NAME                PIC X(100).
 01 WS-LEN1                FLOAT-LONG.
 01 WS-LEN2                FLOAT-LONG.
 01 WS-LEN3                FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)
     MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE "stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STONE WS-ITEM-ROW WS-STATUS
     MOVE "dirt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DIRT WS-ITEM-ROW WS-STATUS
     MOVE "chest" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
*>   ENTITY-ARM-LOCAL: the wide arm's box (origin -3 -2 -2, size 4 x 12 x 4), mirrored, and grown by 0.5.
     MOVE -3 TO WS-B(1)
     MOVE -2 TO WS-B(2) WS-B(3)
     MOVE 4 TO WS-B(4) WS-B(6)
     MOVE 12 TO WS-B(5)
     MOVE 0 TO WS-B(7) WS-B(8) WS-B(9) WS-B(10)
     CALL "ENTITY-ARM-LOCAL" USING WS-BOX WS-LOCAL
     MOVE "T28400 the local place and extents of the wide arm's box" TO WS-NAME
     MOVE -3 TO WS-EX(1)
     MOVE -2 TO WS-EX(2) WS-EX(3)
     MOVE 4 TO WS-EX(4) WS-EX(6)
     MOVE 12 TO WS-EX(5)
     PERFORM CHECK-LOCAL
     MOVE 1 TO WS-B(10)
     CALL "ENTITY-ARM-LOCAL" USING WS-BOX WS-LOCAL
     MOVE "T28400 a mirrored box starts at its far x with a negative extent" TO WS-NAME
     MOVE 1 TO WS-EX(1)
     MOVE -4 TO WS-EX(4)
     PERFORM CHECK-LOCAL
     MOVE 0.5 TO WS-B(7) WS-B(8) WS-B(9)
     MOVE 0 TO WS-B(10)
     CALL "ENTITY-ARM-LOCAL" USING WS-BOX WS-LOCAL
     MOVE "T28400 a grown box starts 0.5 outside and is 1 larger in every extent" TO WS-NAME
     MOVE -3.5 TO WS-EX(1)
     MOVE -2.5 TO WS-EX(2) WS-EX(3)
     MOVE 5 TO WS-EX(4) WS-EX(6)
     MOVE 13 TO WS-EX(5)
     PERFORM CHECK-LOCAL
*>   ENTITY-HAND-FRAME: the box moved by rotation about Z by 90 degrees (x to y, y to -x) and the translation (1, 2, 3), /16 for the pixels.
     MOVE 1.125 TO WS-CX(1)
     MOVE 1.8125 TO WS-CY(1)
     MOVE 2.875 TO WS-CZ(1)
     MOVE 1.125 TO WS-CX(2)
     MOVE 2.0625 TO WS-CY(2)
     MOVE 2.875 TO WS-CZ(2)
     MOVE 0.375 TO WS-CX(4)
     MOVE 1.8125 TO WS-CY(4)
     MOVE 2.875 TO WS-CZ(4)
     MOVE 1.125 TO WS-CX(5)
     MOVE 1.8125 TO WS-CY(5)
     MOVE 3.125 TO WS-CZ(5)
     MOVE -3 TO WS-L(1)
     MOVE -2 TO WS-L(2) WS-L(3)
     MOVE 4 TO WS-L(4) WS-L(6)
     MOVE 12 TO WS-L(5)
     CALL "ENTITY-HAND-FRAME" USING WS-CORNERS WS-LOCAL WS-FRAME
     MOVE "T28400 the frame of the moved box: origin (1, 2, 3), axes (0, 1, 0), (-1, 0, 0), (0, 0, 1)" TO WS-NAME
     MOVE 1 TO WS-EX(1)
     MOVE 2 TO WS-EX(2)
     MOVE 3 TO WS-EX(3)
     MOVE 0 TO WS-EX(4) WS-EX(6) WS-EX(8) WS-EX(9) WS-EX(10) WS-EX(11)
     MOVE 1 TO WS-EX(5) WS-EX(12)
     MOVE -1 TO WS-EX(7)
     PERFORM CHECK-FRAME
*>   A zombie holding a stick in each hand: ENTITIES-MESH finds both frames.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE WS-STICK TO EN-EQ(1, 1) EN-EQ(1, 2)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T28400 a zombie with items in both hands has both frames" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-HAND-FOK(1, 1) + EN-HAND-FOK(1, 2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-HAND FROM 1 BY 1 UNTIL WS-HAND > 2
         MOVE 0 TO WS-BAD
*>       The pivot of the arm: x = -+ 0.3125 (5 pixels), y = 1.376, z = 0 relative to the entity.
         IF FUNCTION ABS(EN-HAND-F(1, WS-HAND, 2) - 1.376) > 0.005 OR FUNCTION ABS(EN-HAND-F(1, WS-HAND, 3)) > 0.005
             ADD 1 TO WS-BAD
         END-IF
         IF WS-HAND = 1 AND FUNCTION ABS(EN-HAND-F(1, WS-HAND, 1) + 0.3125) > 0.005
             ADD 1 TO WS-BAD
         END-IF
         IF WS-HAND = 2 AND FUNCTION ABS(EN-HAND-F(1, WS-HAND, 1) - 0.3125) > 0.005
             ADD 1 TO WS-BAD
         END-IF
*>       The axes a block long and at right angles.
         COMPUTE WS-LEN1 = FUNCTION SQRT(EN-HAND-F(1, WS-HAND, 4) ** 2 + EN-HAND-F(1, WS-HAND, 5) ** 2 + EN-HAND-F(1, WS-HAND, 6) ** 2)
         COMPUTE WS-LEN2 = FUNCTION SQRT(EN-HAND-F(1, WS-HAND, 7) ** 2 + EN-HAND-F(1, WS-HAND, 8) ** 2 + EN-HAND-F(1, WS-HAND, 9) ** 2)
         COMPUTE WS-LEN3 = FUNCTION SQRT(EN-HAND-F(1, WS-HAND, 10) ** 2 + EN-HAND-F(1, WS-HAND, 11) ** 2 + EN-HAND-F(1, WS-HAND, 12) ** 2)
         COMPUTE WS-DOT = EN-HAND-F(1, WS-HAND, 4) * EN-HAND-F(1, WS-HAND, 7) + EN-HAND-F(1, WS-HAND, 5) * EN-HAND-F(1, WS-HAND, 8)
             + EN-HAND-F(1, WS-HAND, 6) * EN-HAND-F(1, WS-HAND, 9)
         IF FUNCTION ABS(WS-LEN1 - 1) > 0.005 OR FUNCTION ABS(WS-LEN2 - 1) > 0.005 OR FUNCTION ABS(WS-LEN3 - 1) > 0.005 OR FUNCTION ABS(WS-DOT) > 0.005
             ADD 1 TO WS-BAD
         END-IF
         MOVE "T28400 the arm's frame origin is its pivot and its axes are a block long and orthogonal" TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "T28400 the held items are quads in the ground item mesh (2 quads, 12 vertices, a hand)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     IF RL-GI-COUNT = 24
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The pose chain on a frame set by hand: the identity axes at (0.5, 1, 0.25).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     PERFORM VARYING WS-HAND FROM 1 BY 1 UNTIL WS-HAND > 2
         MOVE 1 TO EN-HAND-FOK(1, WS-HAND)
         MOVE 0.5 TO EN-HAND-F(1, WS-HAND, 1)
         MOVE 1 TO EN-HAND-F(1, WS-HAND, 2)
         MOVE 0.25 TO EN-HAND-F(1, WS-HAND, 3)
         MOVE 0 TO EN-HAND-F(1, WS-HAND, 4) EN-HAND-F(1, WS-HAND, 5) EN-HAND-F(1, WS-HAND, 6)
         MOVE 0 TO EN-HAND-F(1, WS-HAND, 7) EN-HAND-F(1, WS-HAND, 8) EN-HAND-F(1, WS-HAND, 9)
         MOVE 0 TO EN-HAND-F(1, WS-HAND, 10) EN-HAND-F(1, WS-HAND, 11) EN-HAND-F(1, WS-HAND, 12)
         MOVE 1 TO EN-HAND-F(1, WS-HAND, 4) EN-HAND-F(1, WS-HAND, 8) EN-HAND-F(1, WS-HAND, 12)
     END-PERFORM
*>   A stick in the right hand (the pack's item/generated: translation (0, 3, 1), scale 0.55).
     MOVE WS-STICK TO WS-ITEM
     MOVE 1 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 a stick in the right hand: 12 vertices" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T28400 a stick in the right hand: the front quad's first three vertices and the back quad's first" TO WS-NAME
     MOVE 1.2125 TO WS-EX(1)
     MOVE 1.54531 TO WS-EX(2)
     MOVE 0.1625 TO WS-EX(3)
     MOVE 0.6625 TO WS-EX(4)
     MOVE 1.54531 TO WS-EX(5)
     MOVE 0.1625 TO WS-EX(6)
     MOVE 0.6625 TO WS-EX(7)
     MOVE 1.54531 TO WS-EX(8)
     MOVE 0.7125 TO WS-EX(9)
     MOVE 0.6625 TO WS-EX(10)
     MOVE 1.57969 TO WS-EX(11)
     MOVE 0.1625 TO WS-EX(12)
     PERFORM CHECK-VERTICES
     MOVE 1 TO TL-EXPECTED-N
     MOVE "T28400 the held stick is lit between 0.1 and 1" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF RL-GI-B(1) >= 0.0999 AND RL-GI-B(1) <= 1.0001 AND RL-GI-A(1) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The left hand: the stick's own thirdperson_lefthand entry (rotation 0 90 -55, translation 0 4 0.5, scale 0.85), the translate -1/16.
     MOVE 2 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 a stick in the left hand follows its own thirdperson_lefthand entry" TO WS-NAME
     MOVE 1.03594 TO WS-EX(1)
     MOVE 1.69812 TO WS-EX(2)
     MOVE -0.21691 TO WS-EX(3)
     MOVE 1.03594 TO WS-EX(4)
     MOVE 2.18566 TO WS-EX(5)
     MOVE 0.47937 TO WS-EX(6)
     MOVE 1.03594 TO WS-EX(7)
     MOVE 1.48938 TO WS-EX(8)
     MOVE 0.96691 TO WS-EX(9)
     MOVE 1.08906 TO WS-EX(10)
     MOVE 2.18566 TO WS-EX(11)
     MOVE 0.47937 TO WS-EX(12)
     PERFORM CHECK-VERTICES
*>   A baby's offset (0, 1, -4.5) / 16.
     MOVE 1 TO EN-BABY(1)
     MOVE 1 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 a baby holds the item at (0, 1, -4.5) / 16" TO WS-NAME
     MOVE 1.275 TO WS-EX(1)
     MOVE 1.20156 TO WS-EX(2)
     MOVE 0.225 TO WS-EX(3)
     MOVE 0.725 TO WS-EX(4)
     MOVE 1.20156 TO WS-EX(5)
     MOVE 0.225 TO WS-EX(6)
     MOVE 0.725 TO WS-EX(7)
     MOVE 1.20156 TO WS-EX(8)
     MOVE 0.775 TO WS-EX(9)
     MOVE 0.725 TO WS-EX(10)
     MOVE 1.23594 TO WS-EX(11)
     MOVE 0.225 TO WS-EX(12)
     PERFORM CHECK-VERTICES
     MOVE 0 TO EN-BABY(1)
*>   Stone: the cube (36 vertices), the right entry (75, 45, 0) / 0.375, and for the left arm that entry mirrored (75, -45, 0).
     MOVE WS-STONE TO WS-ITEM
     MOVE 1 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 a stone block is a cube of 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T28400 a stone in the right hand: the cube's first three vertices" TO WS-NAME
     MOVE 0.9375 TO WS-EX(1)
     MOVE 1.37526 TO WS-EX(2)
     MOVE 0.67635 TO WS-EX(3)
     MOVE 0.67233 TO WS-EX(4)
     MOVE 1.44389 TO WS-EX(5)
     MOVE 0.42022 TO WS-EX(6)
     MOVE 0.67233 TO WS-EX(7)
     MOVE 1.80611 TO WS-EX(8)
     MOVE 0.51728 TO WS-EX(9)
     MOVE 0 TO WS-EX(10) WS-EX(11) WS-EX(12)
     PERFORM CHECK-VERTICES-3
     MOVE 2 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 a stone in the left hand takes the right entry mirrored (rotation y negated)" TO WS-NAME
     MOVE 1.32767 TO WS-EX(1)
     MOVE 1.44389 TO WS-EX(2)
     MOVE 0.42022 TO WS-EX(3)
     MOVE 1.0625 TO WS-EX(4)
     MOVE 1.37526 TO WS-EX(5)
     MOVE 0.67635 TO WS-EX(6)
     MOVE 1.0625 TO WS-EX(7)
     MOVE 1.73748 TO WS-EX(8)
     MOVE 0.77341 TO WS-EX(9)
     PERFORM CHECK-VERTICES-3
*>   An item with no definition (dirt) takes the default of item/generated: the same pose as the stick's; a code-drawn chest draws nothing.
     MOVE WS-DIRT TO WS-ITEM
     MOVE 1 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 an item with no entry takes the default (0, 3, 1) / 0.55: the stick's first vertex" TO WS-NAME
     MOVE 1.2125 TO WS-EX(1)
     MOVE 1.54531 TO WS-EX(2)
     MOVE 0.1625 TO WS-EX(3)
     MOVE 0.6625 TO WS-EX(4)
     MOVE 1.54531 TO WS-EX(5)
     MOVE 0.1625 TO WS-EX(6)
     MOVE 0.6625 TO WS-EX(7)
     MOVE 1.54531 TO WS-EX(8)
     MOVE 0.7125 TO WS-EX(9)
     PERFORM CHECK-VERTICES-3
     MOVE WS-CHEST TO WS-ITEM
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 a code-drawn (special) item is not drawn" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The stand-in set: a block item is a cube with block/block's default; both hands.
     MOVE 0 TO CT-OPEN
     MOVE 1 TO WS-ITEM
     MOVE 1 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 a stand-in block item is the cube with the default (75, 45, 0) / 0.375: 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T28400 the stand-in cube in the right hand: the first three vertices" TO WS-NAME
     MOVE 0.9375 TO WS-EX(1)
     MOVE 1.37526 TO WS-EX(2)
     MOVE 0.67635 TO WS-EX(3)
     MOVE 0.67233 TO WS-EX(4)
     MOVE 1.44389 TO WS-EX(5)
     MOVE 0.42022 TO WS-EX(6)
     MOVE 0.67233 TO WS-EX(7)
     MOVE 1.80611 TO WS-EX(8)
     MOVE 0.51728 TO WS-EX(9)
     PERFORM CHECK-VERTICES-3
     MOVE 2 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 the stand-in cube in the left hand takes the mirrored default (rotation y -45)" TO WS-NAME
     MOVE 1.32767 TO WS-EX(1)
     MOVE 1.44389 TO WS-EX(2)
     MOVE 0.42022 TO WS-EX(3)
     MOVE 1.0625 TO WS-EX(4)
     MOVE 1.37526 TO WS-EX(5)
     MOVE 0.67635 TO WS-EX(6)
     MOVE 1.0625 TO WS-EX(7)
     MOVE 1.73748 TO WS-EX(8)
     MOVE 0.77341 TO WS-EX(9)
     PERFORM CHECK-VERTICES-3
*>   A cube needs the room of 36 vertices or is not drawn at all.
     COMPUTE RL-GI-COUNT = CL-MAX-GI-VERTICES - 30
     MOVE 1 TO WS-HAND
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-ITEM WS-EYE-TABLE
     MOVE "T28400 a cube that does not fit the vertex budget is not drawn" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CL-MAX-GI-VERTICES - 30
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CT-OPEN
     STOP RUN.

*> The six values WS-L equal WS-EX(1..6) (within 0.0001).
 CHECK-LOCAL.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF FUNCTION ABS(WS-L(WS-I) - WS-EX(WS-I)) > 0.0001
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-NAME TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The frame WS-F equals WS-EX(1..12) (within 0.0001).
 CHECK-FRAME.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         IF FUNCTION ABS(WS-F(WS-I) - WS-EX(WS-I)) > 0.0001
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-NAME TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Vertices 1, 2, 3 and 7 of the mesh equal WS-EX (x y z each; within 0.001).
 CHECK-VERTICES.
     MOVE 0 TO WS-BAD
     IF FUNCTION ABS(RL-GI-X(1) - WS-EX(1)) > 0.001 OR FUNCTION ABS(RL-GI-Y(1) - WS-EX(2)) > 0.001 OR FUNCTION ABS(RL-GI-Z(1) - WS-EX(3)) > 0.001
         ADD 1 TO WS-BAD
     END-IF
     IF FUNCTION ABS(RL-GI-X(2) - WS-EX(4)) > 0.001 OR FUNCTION ABS(RL-GI-Y(2) - WS-EX(5)) > 0.001 OR FUNCTION ABS(RL-GI-Z(2) - WS-EX(6)) > 0.001
         ADD 1 TO WS-BAD
     END-IF
     IF FUNCTION ABS(RL-GI-X(3) - WS-EX(7)) > 0.001 OR FUNCTION ABS(RL-GI-Y(3) - WS-EX(8)) > 0.001 OR FUNCTION ABS(RL-GI-Z(3) - WS-EX(9)) > 0.001
         ADD 1 TO WS-BAD
     END-IF
     IF FUNCTION ABS(RL-GI-X(7) - WS-EX(10)) > 0.001 OR FUNCTION ABS(RL-GI-Y(7) - WS-EX(11)) > 0.001 OR FUNCTION ABS(RL-GI-Z(7) - WS-EX(12)) > 0.001
         ADD 1 TO WS-BAD
     END-IF
     MOVE WS-NAME TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Vertices 1, 2 and 3 only (a cube's vertex 7 is of another quad).
 CHECK-VERTICES-3.
     MOVE RL-GI-X(7) TO WS-EX(10)
     MOVE RL-GI-Y(7) TO WS-EX(11)
     MOVE RL-GI-Z(7) TO WS-EX(12)
     PERFORM CHECK-VERTICES.
 END PROGRAM TEST-ENTITY-HELD-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MM-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM MM-SPAWN.

 COPY CLTEST.
