*> T9903 (54 section 19.3): the glint of the items that mobs hold. A held item whose stack has the foil (EN-EQ-FOIL of its slot: the main hand is the right arm's, a left-handed mob holds it in the
*> left) adds its quads to the glint mesh RL-WG-VERTEX through HAND-QUAD mode 6: a flat icon one quad of each opaque texel on the front and the back, a block its six faces, the glint coordinates
*> through GLINT-UV at the item scale 8 and the glint strength as brightness; the item's own quads stay in the ground item mesh. An item without the foil adds none. The render list draws the mesh
*> additive (the glint pipeline, texture 5) after the ground items.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-HELD-GLINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SAVED-SW            BINARY-LONG.
 01 WS-GI-AT               BINARY-LONG.
 01 WS-HELD-AT             BINARY-LONG.
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
 01 WS-STICK               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-OPAQUE              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-GU                  FLOAT-LONG.
 01 WS-GV                  FLOAT-LONG.
 01 WS-AU                  FLOAT-SHORT.
 01 WS-AV                  FLOAT-SHORT.
 01 WS-SCALE               FLOAT-LONG VALUE 8.
 01 WS-STRENGTH            FLOAT-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-GMODE               BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-MM.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-TXG.
    05 WS-TXV              FLOAT-SHORT OCCURS 8 TIMES.
 01 WS-N3.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-QQ.
    05 WS-QV               FLOAT-LONG OCCURS 9 TIMES.
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
     MOVE "N" TO TL-MODE
*>   A zombie with a stick in each hand and no foil: no glint vertices, 24 item vertices.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE WS-STICK TO EN-EQ(1, 1) EN-EQ(1, 2)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 an item without the foil adds no glint vertex" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T9903 the two sticks are 24 vertices of the item mesh" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The foil on the main hand's stack (slot 1, the right arm): glint quads of the opaque texels of stick.png, 12 vertices (one texel quad each side) per opaque texel.
     MOVE 1 TO EN-EQ-FOIL(1, 1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     COMPUTE WS-OPAQUE = RL-WG-COUNT / 12
     MOVE "T9903 a foil stick in the main hand adds whole texel quads, front and back (a multiple of 12 vertices, more than 12)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION MOD(RL-WG-COUNT, 12) = 0 AND RL-WG-COUNT > 12
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T9903 the item's own mesh is unchanged by the glint" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Every glint vertex has the glint strength as brightness, alpha 1, no sky term, and coordinates inside the icon's quad volume (the same z as the item's front and back quads is not asserted).
     CALL "GLINT-STRENGTH" USING CLIENT-STATE WS-STRENGTH
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-WG-COUNT
         IF FUNCTION ABS(RL-WG-B(WS-I) - WS-STRENGTH) > 0.0001 OR RL-WG-A(WS-I) NOT = 1 OR RL-WG-SKY(WS-I) NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "T9903 every glint vertex has the glint strength as brightness, alpha 1 and no sky term" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The glint coordinates are GLINT-UV (scale 8) of the atlas coordinates of the stick's texel corners: every glint vertex matches one of the 17 x 17 corners of the 16 x 16 icon.
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-STICK WS-SPRITE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-WG-COUNT
         MOVE 0 TO WS-HIT
         PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX > 16 OR WS-HIT = 1
             PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY > 16 OR WS-HIT = 1
                 MOVE WS-PX TO WS-U16
                 MOVE WS-PY TO WS-V16
                 CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-AU WS-AV
                 MOVE WS-AU TO WS-GU
                 MOVE WS-AV TO WS-GV
                 CALL "GLINT-UV" USING WS-GU WS-GV WS-SCALE
                 IF FUNCTION ABS(RL-WG-U(WS-I) - WS-GU) < 0.0001 AND FUNCTION ABS(RL-WG-V(WS-I) - WS-GV) < 0.0001
                     MOVE 1 TO WS-HIT
                 END-IF
             END-PERFORM
         END-PERFORM
         IF WS-HIT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "T9903 every glint coordinate is GLINT-UV (scale 8) of a texel corner of the icon" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The foil on the other slot only: a right-handed mob's off hand (slot 2, the left arm) glints on its own.
     MOVE 0 TO EN-EQ-FOIL(1, 1)
     MOVE 1 TO EN-EQ-FOIL(1, 2)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 the glint of the off hand's stack is drawn for the left arm (the same count as the main hand's)" TO TL-CASE
     MOVE WS-OPAQUE TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-WG-COUNT / 12
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A left-handed mob (mob flags bit 2) holds the main hand's stack (slot 1) in the left arm: the foil of slot 1 glints once, slot 2's not at all.
     MOVE 2 TO EN-MOB-FLAGS(1)
     MOVE 1 TO EN-EQ-FOIL(1, 1)
     MOVE 0 TO EN-EQ-FOIL(1, 2)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 a left-handed mob's glint follows slot 1 to the left arm (one stick glints)" TO TL-CASE
     MOVE WS-OPAQUE TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-WG-COUNT / 12
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Both slots foil: twice.
     MOVE 1 TO EN-EQ-FOIL(1, 2)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 both hands foil glint twice" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-OPAQUE * 2
     COMPUTE TL-OBSERVED-N = RL-WG-COUNT / 12
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An icon wider than 32 texels glints on its first 32 x 32 texels only (the opaque table holds 1024).
     MOVE 1 TO EN-EQ-FOIL(1, 1)
     MOVE 0 TO EN-EQ-FOIL(1, 2)
     MOVE AT-SW(WS-SPRITE) TO WS-SAVED-SW
     MOVE 64 TO AT-SW(WS-SPRITE)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE WS-SAVED-SW TO AT-SW(WS-SPRITE)
     MOVE "T9903 an icon of 64 texels glints on a 32 x 32 table (the mesh is not empty and not overrun)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-WG-COUNT > 0 AND RL-WG-COUNT <= 8192
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A block in the hand: stone is a cube of six faces, 36 glint vertices, and 36 item vertices.
     MOVE 0 TO EN-MOB-FLAGS(1)
     MOVE 0 TO EN-EQ(1, 2) EN-EQ-FOIL(1, 2)
     MOVE WS-STONE TO EN-EQ(1, 1)
     MOVE 1 TO EN-EQ-FOIL(1, 1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 a foil block in the hand glints on its six faces" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T9903 the block's own six faces stay" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Room: with 8190 vertices in the glint mesh HAND-QUAD mode 6 adds nothing; with room it adds six.
     MOVE 8190 TO RL-WG-COUNT
     MOVE 0 TO WS-MV(1) WS-MV(2) WS-MV(3) WS-MV(4) WS-MV(5) WS-MV(6) WS-MV(7) WS-MV(8) WS-MV(9) WS-MV(10) WS-MV(11) WS-MV(12)
     MOVE 1 TO WS-MV(1) WS-MV(5) WS-MV(9)
     MOVE 0 TO WS-CP(1) WS-CP(2) WS-CP(3) WS-CP(6) WS-CP(7) WS-CP(8) WS-CP(9) WS-CP(10)
     MOVE 1 TO WS-CP(4) WS-CP(5) WS-CP(11) WS-CP(12)
     MOVE 0 TO WS-TXV(1) WS-TXV(2) WS-TXV(3) WS-TXV(4) WS-TXV(5) WS-TXV(6) WS-TXV(7) WS-TXV(8)
     MOVE 0 TO WS-NV(1) WS-NV(2)
     MOVE 1 TO WS-NV(3)
     MOVE 1 TO WS-QV(1) WS-QV(5) WS-QV(9)
     MOVE 0 TO WS-QV(2) WS-QV(3) WS-QV(4) WS-QV(6) WS-QV(7) WS-QV(8)
     MOVE 1 TO WS-LIGHT
     MOVE 6 TO WS-GMODE
     CALL "HAND-QUAD" USING CLIENT-STATE WS-MM WS-CORNERS WS-TXG WS-N3 WS-LIGHT WS-GMODE WS-QQ
     MOVE "T9903 a full glint mesh takes no more quads" TO TL-CASE
     MOVE 8190 TO TL-EXPECTED-N
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO RL-WG-COUNT
     CALL "HAND-QUAD" USING CLIENT-STATE WS-MM WS-CORNERS WS-TXG WS-N3 WS-LIGHT WS-GMODE WS-QQ
     MOVE "T9903 with room HAND-QUAD mode 6 adds the quad's six vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The hand mesh's own room (mode 0 with 2046 vertices in RL-HAND-VERTEX) takes no more quads.
     MOVE 0 TO WS-GMODE
     MOVE 2046 TO RL-HAND-COUNT
     CALL "HAND-QUAD" USING CLIENT-STATE WS-MM WS-CORNERS WS-TXG WS-N3 WS-LIGHT WS-GMODE WS-QQ
     MOVE "T9903 a full hand mesh takes no more quads" TO TL-CASE
     MOVE 2046 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO RL-HAND-COUNT
*>   The render list draws the glint of the held items additively after the ground items, with the item glint texture (5); without that texture it draws none.
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 1 TO GT-ITEM-W
*>   The player stands five blocks south of the zombie looking along +z (yaw 0), so that the view frustum holds it.
     MOVE 10.5 TO PL-X
     MOVE 62.4 TO PL-Y
     MOVE 5.5 TO PL-Z
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 1280 TO IN-WIN-W
     MOVE 720 TO IN-WIN-H
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-GI-AT WS-HELD-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-GROUND-ITEMS
             MOVE WS-I TO WS-GI-AT
         END-IF
         IF RL-D-SLOT(WS-I) = MESH-SLOT-GLINT-HELD
             MOVE WS-I TO WS-HELD-AT
         END-IF
     END-PERFORM
     MOVE "T9903 the render list draws the held items' glint after the ground items, glint pipeline, texture 5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-GI-AT > 0 AND WS-HELD-AT > WS-GI-AT
         IF RL-D-PIPELINE(WS-HELD-AT) = CC-PIPE-GLINT AND RL-D-TEX(WS-HELD-AT) = CC-TEX-GLINT
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO GT-ITEM-W
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-HELD-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-GLINT-HELD
             MOVE WS-I TO WS-HELD-AT
         END-IF
     END-PERFORM
     MOVE "T9903 without the item glint texture nothing is drawn for it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HELD-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-HELD-GLINT.
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
