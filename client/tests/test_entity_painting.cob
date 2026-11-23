*> Paintings (docs/protocol/34-entity-models-9-non-living-entities.md section 11; 44 part 9 section 5.4; T51207): the replica keeps a painting's direction (entry 8, DIRECTION) and
*> variant (entry 9, PAINTING_VARIANT: the Holder VarInt, registry id + 1; 0 until told), and ENTITIES-MESH draws its cells: front quad from the variant's sprite, back and edge quads
*> from back.png, turned about Y by 180 - data2D x 90 (north 0, east -90, south 180, west 90), the cell's brightness from the block EF9-PAINTING-BLOCK names. The pack is
*> client/tests/fixtures/mini-vanilla (textures/painting: back 16 x 16, kebab 16 x 16, skeleton 64 x 48); the registry is built here: kebab 1 x 1, skeleton 4 x 3, placeholder
*> 2 x 1 (namespace cobolcraft: no sprite path, the back image is drawn in its place).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-PAINTING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-KEY                 PIC X(112).
 01 WS-MKEY                PIC X(24).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ID                  BINARY-LONG VALUE 7.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DIR                 BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-PATH                PIC X(64).
 01 WS-D                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BACK                BINARY-LONG.
 01 WS-FRONT               BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-CHUNK-ROW           BINARY-LONG.
 01 WS-CHUNK-X             BINARY-LONG VALUE 0.
 01 WS-CHUNK-Z             BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SKYKIND             BINARY-LONG VALUE 0.
 01 WS-BLOCKKIND           BINARY-LONG VALUE 1.
 01 WS-LY                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-WORLD-Y             BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-SLOTS-BEFORE        BINARY-LONG.
 01 WS-ONE-ROW             BINARY-LONG VALUE 1.
 01 WS-PZ                  BINARY-LONG.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(12) VALUE "north".
    05 FILLER PIC X(12) VALUE "south".
    05 FILLER PIC X(12) VALUE "west".
    05 FILLER PIC X(12) VALUE "east".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-NM               PIC X(12) OCCURS 4 TIMES.
*> Expected eye-relative front vertex 1 (x1, y0, -z of the cell, turned) of a 1 x 1 painting at (12, 65, 14) seen from (10, 64, 10), per direction 2 to 5.
 01 WS-EXPECT-DATA.
    05 FILLER FLOAT-LONG VALUE 2.5.
    05 FILLER FLOAT-LONG VALUE 3.96875.
    05 FILLER FLOAT-LONG VALUE 1.5.
    05 FILLER FLOAT-LONG VALUE 4.03125.
    05 FILLER FLOAT-LONG VALUE 1.96875.
    05 FILLER FLOAT-LONG VALUE 3.5.
    05 FILLER FLOAT-LONG VALUE 2.03125.
    05 FILLER FLOAT-LONG VALUE 4.5.
 01 WS-EXPECT REDEFINES WS-EXPECT-DATA.
    05 WS-EX               OCCURS 4 TIMES.
       10 WS-EX-X          FLOAT-LONG.
       10 WS-EX-Z          FLOAT-LONG.
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
     CALL "PT-REGISTRY" USING CLIENT-STATE
     MOVE "painting" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS

*>   The texture paths of the variants' front sprites.
     MOVE "T" TO TL-MODE
     MOVE 1 TO WS-CODE
     CALL "PAINTING-TEX-PATH" USING CLIENT-STATE WS-CODE WS-PATH
     MOVE "painting: texture code 1 (kebab) is textures/painting/kebab.png" TO TL-CASE
     MOVE "textures/painting/kebab.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-CODE
     CALL "PAINTING-TEX-PATH" USING CLIENT-STATE WS-CODE WS-PATH
     MOVE "painting: texture code 2 (skeleton) is textures/painting/skeleton.png" TO TL-CASE
     MOVE "textures/painting/skeleton.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-CODE
     CALL "PAINTING-TEX-PATH" USING CLIENT-STATE WS-CODE WS-PATH
     MOVE "painting: an asset of another namespace (cobolcraft:placeholder) has no path" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-CODE
     CALL "PAINTING-TEX-PATH" USING CLIENT-STATE WS-CODE WS-PATH
     MOVE "painting: a texture code outside the registry has no path" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The replica: north and the first variant until told; then entries 8 and 9.
     MOVE "N" TO TL-MODE
     MOVE 12 TO WS-X
     MOVE 65 TO WS-Y
     MOVE 14 TO WS-Z
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "painting: a new painting is north (2) with variant 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-FDIR(1) * 100 + EN-X1(1)
     MOVE 200 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-DIR
     MOVE 3 TO WS-VAR
     CALL "PT-DATA" USING CLIENT-STATE WS-ID WS-DIR WS-VAR
     MOVE "painting: entry 8 west (4) and entry 9 Holder 3 give direction 4 and variant 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-FDIR(1) * 100 + EN-X1(1)
     MOVE 402 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-VAR
     CALL "PT-DATA" USING CLIENT-STATE WS-ID WS-DIR WS-VAR
     MOVE "painting: entry 9 Holder 2 is variant 1" TO TL-CASE
     MOVE 401 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-FDIR(1) * 100 + EN-X1(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A 1 x 1 kebab in each direction: six quads (front, back, top, bottom, two edges... the cell is the whole painting: front, back, top, bottom, edge x1, edge x0).
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         COMPUTE WS-DIR = WS-D + 1
         MOVE 1 TO WS-VAR
         CALL "PT-DATA" USING CLIENT-STATE WS-ID WS-DIR WS-VAR
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         PERFORM FIND-SLOTS
         MOVE "painting: a 1 x 1 painting draws six quads" TO TL-CASE
         IF WS-D = 1
             MOVE 36 TO TL-EXPECTED-N
             MOVE RL-EN-COUNT TO TL-OBSERVED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "painting: " FUNCTION TRIM(WS-NM(WS-D)) " front vertex 1 is the turned corner (x1, y0, -z) of the cell, eye-relative"
             DELIMITED BY SIZE INTO TL-CASE
         COMPUTE WS-DIFF = FUNCTION ABS(RL-EN-X(1) - WS-EX-X(WS-D)) + FUNCTION ABS(RL-EN-Y(1) - 0.5)
             + FUNCTION ABS(RL-EN-Z(1) - WS-EX-Z(WS-D))
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-DIFF < 0.00001
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-D = 1
             COMPUTE WS-U = EA-MT-X(WS-FRONT) / EA-W
             COMPUTE WS-V = (EA-MT-Y(WS-FRONT) + EA-MT-H(WS-FRONT)) / EA-H
             COMPUTE WS-DIFF = FUNCTION ABS(RL-EN-U(1) - WS-U) + FUNCTION ABS(RL-EN-V(1) - WS-V)
             MOVE "painting: front vertex 1 takes the sprite's left (uB 0) and bottom (vA 1) of the variant's image" TO TL-CASE
             MOVE 0 TO TL-OBSERVED-N
             IF WS-DIFF < 0.00001
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>           Back vertex 1 (quad 2, vertex 7): (x1, y1, +z) with the back image's right and top.
             COMPUTE WS-U = (EA-MT-X(WS-BACK) + EA-MT-W(WS-BACK)) / EA-W
             COMPUTE WS-V = EA-MT-Y(WS-BACK) / EA-H
             COMPUTE WS-DIFF = FUNCTION ABS(RL-EN-U(7) - WS-U) + FUNCTION ABS(RL-EN-V(7) - WS-V)
                 + FUNCTION ABS(RL-EN-X(7) - 2.5) + FUNCTION ABS(RL-EN-Y(7) - 1.5) + FUNCTION ABS(RL-EN-Z(7) - 4.03125)
             MOVE "painting: the back quad is at +z (4.03125) with the back image's right (u1) and top (v0)" TO TL-CASE
             MOVE 0 TO TL-OBSERVED-N
             IF WS-DIFF < 0.00001
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             MOVE "painting: no light here: the brightness is the 0.1 floor" TO TL-CASE
             MOVE 0 TO TL-OBSERVED-N
             IF RL-EN-B(1) > 0.0999 AND RL-EN-B(1) < 0.1001
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM

*>   A 4 x 3 skeleton, north: 12 cells of front and back, edges along the top row (4), bottom row (4) and the two sides (3 each).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 2 TO WS-DIR
     MOVE 2 TO WS-VAR
     CALL "PT-DATA" USING CLIENT-STATE WS-ID WS-DIR WS-VAR
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM FIND-SLOTS
     MOVE "painting: a 4 x 3 painting draws 38 quads (12 front, 12 back, 4 top, 4 bottom, 3 + 3 sides)" TO TL-CASE
     MOVE 228 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Cell (0, 0) front vertex 1: x1 = -2 + 0 + 1 = -1, y0 = -1.5 (rel 1, -0.5, 3.96875); uB = 3/4 of the sprite, vA = the whole height.
     COMPUTE WS-U = (EA-MT-X(WS-FRONT) + 0.75 * EA-MT-W(WS-FRONT)) / EA-W
     COMPUTE WS-V = (EA-MT-Y(WS-FRONT) + EA-MT-H(WS-FRONT)) / EA-H
     COMPUTE WS-DIFF = FUNCTION ABS(RL-EN-X(1) - 1) + FUNCTION ABS(RL-EN-Y(1) + 0.5) + FUNCTION ABS(RL-EN-Z(1) - 3.96875)
         + FUNCTION ABS(RL-EN-U(1) - WS-U) + FUNCTION ABS(RL-EN-V(1) - WS-V)
     MOVE "painting: the skeleton's cell (0, 0) front vertex 1 is (-1, -1.5, -z) with u 3/4 and v 1 of its 64 x 48 sprite" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "painting: the skeleton's sprite is its own 64 x 48 image of the atlas" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 64 * 1000 + 48
     COMPUTE TL-OBSERVED-N = EA-MT-W(WS-FRONT) * 1000 + EA-MT-H(WS-FRONT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A variant the registry does not hold, and a painting that has no variant row: nothing is drawn.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 2 TO WS-DIR
     MOVE 10 TO WS-VAR
     CALL "PT-DATA" USING CLIENT-STATE WS-ID WS-DIR WS-VAR
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "painting: variant 9 is not in the registry (4 entries): nothing is drawn" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EA-MT-COUNT TO WS-SLOTS-BEFORE
     MOVE 4 TO WS-VAR
     CALL "PT-DATA" USING CLIENT-STATE WS-ID WS-DIR WS-VAR
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "painting: a variant sent without data (0 x 0) draws nothing and takes no slot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-EN-COUNT + EA-MT-COUNT - WS-SLOTS-BEFORE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A painting whose sprites have no atlas slot (every slot taken in the pass: ENTITY-SLOT-ENSURE gave none) draws nothing.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 1 TO WS-VAR
     CALL "PT-DATA" USING CLIENT-STATE WS-ID WS-DIR WS-VAR
     MOVE 0 TO EA-MT-COUNT RL-EN-COUNT
     CALL "ENTITY-PAINTING-EMIT" USING CLIENT-STATE WS-ONE-ROW WS-EYE-TABLE
     MOVE "painting: a painting without atlas slots for its sprites draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The light of each cell: a 2 x 1 painting (the placeholder, north, centred on x 12) takes the blocks (11, 65, 14) and (12, 65, 14): block light 12 and 6 (0.8 and 0.4).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 65 TO WS-WORLD-Y
     MOVE 11 TO WS-PX
     MOVE 14 TO WS-PZ
     MOVE 1 TO WS-LEVEL
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-PX WS-WORLD-Y WS-PZ WS-LEVEL
     MOVE 12 TO WS-PX
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-PX WS-WORLD-Y WS-PZ WS-LEVEL
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CHUNK-X WS-CHUNK-Z WS-CHUNK-ROW
     COMPUTE WS-LY = WS-WORLD-Y - PL-MIN-Y
     MOVE 11 TO WS-LX
     MOVE 14 TO WS-LZ
     MOVE 12 TO WS-LEVEL
     CALL "LIGHT-SET" USING WR-ADDR(WS-CHUNK-ROW) WS-BLOCKKIND WS-LY WS-LX WS-LZ WS-LEVEL
     MOVE 12 TO WS-LX
     MOVE 6 TO WS-LEVEL
     CALL "LIGHT-SET" USING WR-ADDR(WS-CHUNK-ROW) WS-BLOCKKIND WS-LY WS-LX WS-LZ WS-LEVEL
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 2 TO WS-DIR
     MOVE 3 TO WS-VAR
     CALL "PT-DATA" USING CLIENT-STATE WS-ID WS-DIR WS-VAR
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "painting: a 2 x 1 painting draws ten quads (two cells of front, back, top, bottom and one side)" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "painting: the first cell (block x 11, block light 12) is 0.8, the second (x 12, light 6) is 0.4" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ok" TO TL-EXPECTED
     MOVE "bad" TO TL-OBSERVED
     IF RL-EN-B(1) > 0.7999 AND RL-EN-B(1) < 0.8001 AND RL-EN-B(31) > 0.3999 AND RL-EN-B(31) < 0.4001
         MOVE "ok" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
*> The atlas slots of the painting row: its back image (code 0) and the front sprite of the variant WS-VAR - 1 (code WS-VAR).
 FIND-SLOTS.
     MOVE 0 TO WS-BACK WS-FRONT
     MOVE "painting" TO WS-MKEY
     CALL "ENTITY-MODEL-FIND" USING WS-MKEY WS-MODEL
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = WS-MODEL AND EA-MT-TEX(WS-S) = 0
             MOVE WS-S TO WS-BACK
         END-IF
         IF EA-MT-MODEL(WS-S) = WS-MODEL AND EA-MT-TEX(WS-S) = WS-VAR
             MOVE WS-S TO WS-FRONT
         END-IF
     END-PERFORM
     IF WS-BACK = 0 OR WS-FRONT = 0
         MOVE 1 TO WS-BACK WS-FRONT
     END-IF.
 END PROGRAM TEST-ENTITY-PAINTING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PT-REGISTRY.
*> USING CLIENT-STATE: Registry Data of minecraft:painting_variant with kebab 1 x 1, skeleton 4 x 3 and cobolcraft:placeholder 2 x 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NAME                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-NEG2                BINARY-LONG VALUE -2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-INT                 BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TABLE-DATA.
    05 FILLER PIC X(24) VALUE "minecraft:kebab".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(24) VALUE "minecraft:skeleton".
    05 FILLER PIC 99 VALUE 18.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(24) VALUE "cobolcraft:placeholder".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 99 VALUE 1.
 01 WS-TABLE REDEFINES WS-TABLE-DATA.
    05 WS-T OCCURS 3 TIMES.
       10 WS-T-NAME        PIC X(24).
       10 WS-T-LEN         PIC 99.
       10 WS-T-W           PIC 99.
       10 WS-T-H           PIC 99.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:painting_variant" TO WS-NAME
     MOVE 26 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FOUR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE SPACES TO WS-NAME
         MOVE WS-T-NAME(WS-I) TO WS-NAME
         MOVE WS-T-LEN(WS-I) TO WS-LEN
         CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
         MOVE SPACE TO WS-KEY
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-NEG2
         MOVE "width" TO WS-KEY
         MOVE 5 TO WS-KEY-LENGTH
         MOVE WS-T-W(WS-I) TO WS-INT
         CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT
         MOVE "height" TO WS-KEY
         MOVE 6 TO WS-KEY-LENGTH
         MOVE WS-T-H(WS-I) TO WS-INT
         CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-INT
         MOVE "asset_id" TO WS-KEY
         MOVE 8 TO WS-KEY-LENGTH
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-NAME WS-LEN
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-PERFORM
*>   Entry 3: sent without data (0 x 0).
     MOVE "minecraft:nodata" TO WS-NAME
     MOVE 16 TO WS-LEN
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-NAME WS-LEN
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "REGISTRY-READ" USING CLIENT-STATE PB-BUFFER
     GOBACK.
 END PROGRAM PT-REGISTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PT-DATA.
*> USING CLIENT-STATE, entity id, direction, Holder value (VarInt; 0 sends no entry 9): Set Entity Data with entry 8 (DIRECTION) and entry 9 (PAINTING_VARIANT, the VarInt bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-DATA                BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-HOLDER               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-DIR L-HOLDER.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE 8 TO MD-MX-INDEX
     MOVE 12 TO MD-MX-SERIALIZER
     MOVE L-DIR TO MD-MX-INT
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE 9 TO MD-MX-INDEX
     MOVE 34 TO MD-MX-SERIALIZER
     MOVE 1 TO MD-MX-PRESENT
     MOVE 1 TO MD-MX-DATA-LENGTH
     MOVE FUNCTION CHAR(L-HOLDER + 1) TO MD-MX-DATA(1:1)
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE MD-MD-END TO MD-MX-INDEX
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-DATA
     GOBACK.
 END PROGRAM PT-DATA.

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
