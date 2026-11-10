*> End-to-end test of the tint channel on the chunk mesh path (docs/protocol/43-tint-sources.md sections 1
*> to 4; shim-abi section 9: every vertex carries a tint rgb): a model face's tintindex is parsed and
*> baked (QD-TINT), the biome registry fills the biome colour table (REGISTRY-READ -> TINT-BIOME-SET),
*> and MESH-SECTION gives the vertices of a face whose block has a tint source the colour of the biome of
*> its cell (the biome blend average of radius 2, section 4): grass_block's top face the biome's grass
*> colour, oak_leaves the foliage colour, water the water colour; a face with tintindex -1 and a block
*> without a source stay white (1, 1, 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-TINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY JSONDOC.
 COPY CLMODEL.
 COPY CLQUAD.
 COPY CLTINT.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SECTION             BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PATH                PIC X(256)
     VALUE "contract/fixtures/wire/config-s2c-07-registry-data-worldgen-biome.hex".
 01 WS-ID                  BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG VALUE 1.
 01 WS-FACE-UP             BINARY-LONG VALUE DIR-UP.
 01 WS-FACE-DOWN           BINARY-LONG VALUE DIR-DOWN.
 01 WS-T                   COMP-2.
 01 WS-D                   COMP-2.
 01 WS-WATER               BINARY-DOUBLE.
 01 WS-GRASS               BINARY-DOUBLE.
 01 WS-FOLIAGE             BINARY-DOUBLE.
 01 WS-DRY                 BINARY-DOUBLE VALUE -1.
 01 WS-MOD                 PIC X(16) VALUE "none".
 01 WS-BIOME               BINARY-LONG.
 01 WS-X                   FLOAT-SHORT.
 01 WS-Y                   FLOAT-SHORT.
 01 WS-Z                   FLOAT-SHORT.
 01 WS-FOUND               BINARY-LONG.
 01 WS-B                   FLOAT-SHORT.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 WS-SKY                 FLOAT-SHORT.
 01 WS-R                   FLOAT-SHORT.
 01 WS-G                   FLOAT-SHORT.
 01 WS-BLUE                FLOAT-SHORT.
 01 WS-RGB                 PIC X(40).
 01 WS-E1                  PIC Z(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC Z(9)9.
 01 WS-CX                  BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 1000 TO SK-U

*>   A face's tintindex is parsed and baked: -1 when absent.
     INITIALIZE MODEL-RESOLVED
     MOVE '{"elements":[{"from":[0,0,0],"to":[16,16,16],"faces":{"up":{"texture":"#a","tintindex":0},'
         & '"down":{"texture":"#a"}}}]}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
     MOVE "elements" TO WS-KEY
     MOVE 8 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY WS-KEY-LENGTH WS-NODE
     MOVE JN-FIRST(WS-NODE) TO WS-NODE
     CALL "MODEL-ELEMENT-PARSE" USING JSON-DOC WS-NODE MODEL-RESOLVED WS-ONE
     MOVE 1 TO MR-ELEMENT-COUNT
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE-UP WS-SPRITE QUAD
     MOVE QD-TINT TO WS-E1
     CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-ONE WS-FACE-DOWN WS-SPRITE QUAD
     MOVE QD-TINT TO WS-E2
     MOVE MF-TINT(1, DIR-UP) TO WS-E3
     MOVE "mesher tint a face's tintindex 0 is parsed (MF-TINT) and baked (QD-TINT), a face without "
         & "one is -1" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "parsed 0 baked 0 and -1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "parsed " FUNCTION TRIM(WS-E3) " baked " FUNCTION TRIM(WS-E1) " and "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The biome registry (the stand-in's three biomes) fills the biome colour table.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "REGISTRY-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "mesher tint the biome registry sets the water, grass and foliage colours of the three "
         & "biomes (standin 4.3), no dry foliage override, and counts them" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF TT-BIOMES = 3 AND TB-WATER(1) = 4282019493 AND TB-GRASS(1) = 4283404090
             AND TB-FOLIAGE(1) = 4283404090 AND TB-DRY(1) = -1 AND TB-WATER(2) = 4281293964
             AND TB-GRASS(2) = 4285241941 AND TB-GRASS(3) = 4284107328 AND TB-WATER(3) = 4282003242
             AND TB-TEMP(1) > 0.59 AND TB-TEMP(1) < 0.61 AND TB-DOWN(3) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Biome 0 gets a foliage override of its own so the three colours differ.
     MOVE 0.6 TO WS-T
     MOVE 0.4 TO WS-D
     MOVE 4282349284 TO WS-WATER
     MOVE 4283404090 TO WS-GRASS
     MOVE 4284119852 TO WS-FOLIAGE
     MOVE 0 TO WS-BIOME
     CALL "TINT-BIOME-SET" USING WS-BIOME WS-T WS-D WS-WATER WS-GRASS WS-FOLIAGE WS-DRY WS-MOD
     MOVE 1 TO WS-BIOME
     MOVE 4281293964 TO WS-WATER
     MOVE 4285241941 TO WS-GRASS
     CALL "TINT-BIOME-SET" USING WS-BIOME WS-T WS-D WS-WATER WS-GRASS WS-FOLIAGE WS-DRY WS-MOD

*>   Two chunks: row A all biome 0, row B all biome 1; states 301 grass_block (top face tinted), 302
*>   oak_leaves and 303 water (all faces tinted) borrow the baked quads of greystone; greystone untinted.
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-ROW-A
     MOVE 1 TO WS-CX
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-ZERO2 WS-ROW-B
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE BM-STATE(3) TO BM-STATE(301) BM-STATE(302) BM-STATE(303)
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BM-QUAD-COUNT(301)
         MOVE -1 TO BM-TINT(301, WS-Q)
         IF BM-SHADE(301, WS-Q) = DIR-UP
             MOVE 0 TO BM-TINT(301, WS-Q)
         END-IF
         MOVE 0 TO BM-TINT(302, WS-Q) BM-TINT(303, WS-Q)
     END-PERFORM
     MOVE 1 TO ST-OPAQUE(301) ST-OPAQUE(302)
     MOVE 0 TO ST-OPAQUE(303)
     MOVE 77 TO ST-BLOCK(301)
     MOVE 78 TO ST-BLOCK(302)
     MOVE 79 TO ST-BLOCK(303)
     MOVE "grass_block" TO ST-BLOCK-NAME(78)
     MOVE "oak_leaves" TO ST-BLOCK-NAME(79)
     MOVE "water" TO ST-BLOCK-NAME(80)
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW-A)
     MOVE ALL X"FF" TO CE-SKYS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         MOVE 0 TO CE-BIOME(WS-I)
     END-PERFORM
     MOVE 300 TO CE-STATE(1 * 256 + 8 * 16 + 4 + 1)
     MOVE 301 TO CE-STATE(1 * 256 + 8 * 16 + 8 + 1)
     MOVE 302 TO CE-STATE(1 * 256 + 8 * 16 + 12 + 1)
     MOVE 2 TO CE-STATE(1 * 256 + 4 * 16 + 4 + 1)
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW-B)
     MOVE ALL X"FF" TO CE-SKYS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         MOVE 1 TO CE-BIOME(WS-I)
     END-PERFORM
     MOVE 300 TO CE-STATE(1 * 256 + 8 * 16 + 4 + 1)
     MOVE 302 TO CE-STATE(1 * 256 + 8 * 16 + 12 + 1)
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW-A WS-SECTION
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW-B WS-SECTION

*>   Row A (biome 0): grass_block at x 4, oak_leaves at x 8, water at x 12 (z 8, y 1), greystone at (4, 1, 4).
     MOVE WS-ROW-A TO WS-CUR
     MOVE SPACES TO TL-OBSERVED
     MOVE 4.5 TO WS-X
     MOVE 2.0 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM ADD-FACE
     MOVE 4.5 TO WS-X
     MOVE 1.5 TO WS-Y
     MOVE 8.0 TO WS-Z
     PERFORM ADD-FACE
     MOVE "mesher tint a grass_block in biome 0: its top face (tintindex 0) is the grass colour "
         & "#4F8F3A (79 143 58), its side face (tintindex -1) white" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "79 143 58 | 255 255 255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO TL-OBSERVED
     MOVE 8.5 TO WS-X
     MOVE 2.0 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM ADD-FACE
     MOVE "mesher tint oak_leaves in biome 0: the foliage colour of the biome (#5A7B2C, 90 123 44)"
         TO TL-CASE
     MOVE "90 123 44" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO TL-OBSERVED
     MOVE 12.5 TO WS-X
     MOVE 2.0 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM ADD-FACE
     MOVE "mesher tint water in biome 0: the biome's water colour (#3F76E4, 63 118 228)" TO TL-CASE
     MOVE "63 118 228" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO TL-OBSERVED
     MOVE 4.5 TO WS-X
     MOVE 2.0 TO WS-Y
     MOVE 4.5 TO WS-Z
     PERFORM ADD-FACE
     MOVE "mesher tint a block without a tint source (greystone) stays white (255 255 255)" TO TL-CASE
     MOVE "255 255 255" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Row B (biome 1): the same blocks take that biome's colours.
     MOVE WS-ROW-B TO WS-CUR
     MOVE SPACES TO TL-OBSERVED
     MOVE 4.5 TO WS-X
     MOVE 2.0 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM ADD-FACE
     MOVE "mesher tint the same grass_block in biome 1 (upland) is its grass colour #6B9A55 "
         & "(107 154 85)" TO TL-CASE
     MOVE "107 154 85" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADD-FACE.
     CALL "TEST-MESH-VERTEX" USING WR-OP-ADDR(WS-CUR, 1) WR-OP-COUNT(WS-CUR, 1) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V WS-SKY WS-R WS-G WS-BLUE
     COMPUTE WS-E1 ROUNDED = WS-R * 255
     COMPUTE WS-E2 ROUNDED = WS-G * 255
     COMPUTE WS-E3 ROUNDED = WS-BLUE * 255
     MOVE SPACES TO WS-RGB
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO WS-RGB
     IF TL-OBSERVED = SPACES
         MOVE WS-RGB TO TL-OBSERVED
     ELSE
         MOVE SPACES TO WS-TEXT
         STRING FUNCTION TRIM(TL-OBSERVED) " | " FUNCTION TRIM(WS-RGB) DELIMITED BY SIZE
             INTO WS-TEXT
         MOVE WS-TEXT TO TL-OBSERVED
     END-IF
     EXIT PARAGRAPH.
 END PROGRAM TEST-MESHER-TINT.
 COPY CLTEST.
