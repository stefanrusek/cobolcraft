*> Implementation test, lane signtext (client/src/sign-render.cob, sign-layout.cob, sign-mesh.cob; docs/protocol/52-block-entity-models-2-signs.md): the sign text renderer's arithmetic with the
*> project font (cobolcraft:default of the built-in pack, whose l is 5 wide; the document's advances H W e o r d 6, l 3, space 4 of 5.5 are set in the font table for the worked examples, widths 24,
*> 27 and 83); the line layout of 5.2 to 5.4 (offsets -20 -10 0 10
*> and -18 -9 0 9, centring by integer division toward zero, wrap at 90 or 60 with the first piece drawn only); the text plane transform of 4.1 to 4.3 for the four families, the 16 rotations and the
*> facings, front and back, against every corner of the worked examples of section 10 (to 7 decimals); the dye colours of 6.1 and the outline rules of 6.3; the glyph quads of 6.5 (bold, italic);
*> the obfuscated glyph; and the vertices of one drawn line (SGR-LINE-DRAW: quad counts, outline before fill, colours, positions, bias, capacity).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SIGN-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 COPY SGRPAINT.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-ADV                 BINARY-LONG.
 01 WS-OBS                 PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-N1                  PIC -(8)9.
 01 WS-N2                  PIC -(8)9.
 01 WS-N3                  PIC -(8)9.
 01 WS-N4                  PIC -(8)9.
 01 WS-N5                  PIC -(8)9.
 01 WS-TEXT                PIC X(80).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LINE                BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-POSE.
    05 WS-OX               FLOAT-LONG.
    05 WS-OY               FLOAT-LONG.
    05 WS-OZ               FLOAT-LONG.
    05 WS-AXX              FLOAT-LONG.
    05 WS-AXZ              FLOAT-LONG.
    05 WS-AZX              FLOAT-LONG.
    05 WS-AZZ              FLOAT-LONG.
    05 WS-SCALE            FLOAT-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-EXPECT              PIC X(120).
 01 WS-EXPECT-TABLE REDEFINES WS-EXPECT.
    05 WS-EXP-ENTRY OCCURS 12 TIMES.
       10 WS-EXP-NUM       PIC 9(8).
       10 FILLER           PIC X.
 01 WS-LABEL               PIC X(120).
 01 WS-NUM8                PIC 9(8).
 01 WS-HEXES               PIC X(6).
 01 WS-HEX-VALUE           BINARY-LONG.
 01 WS-HEX-DIGIT           BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-OUTLINE             BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-FEET.
    05 WS-FEET-X           FLOAT-LONG.
    05 WS-FEET-Y           FLOAT-LONG.
    05 WS-FEET-Z           FLOAT-LONG.
 01 WS-BLOCK-X             BINARY-LONG.
 01 WS-BLOCK-Y             BINARY-LONG.
 01 WS-BLOCK-Z             BINARY-LONG.
 01 WS-SCOPING             BINARY-LONG.
 01 WS-BOLD                BINARY-LONG.
 01 WS-ITALIC              BINARY-LONG.
 01 WS-COPY                BINARY-LONG.
 01 WS-CORNERS.
    05 WS-C                FLOAT-LONG OCCURS 8 TIMES.
 01 WS-Z                   FLOAT-LONG.
 01 WS-OUT-CP              BINARY-LONG.
 01 WS-SEEN                PIC X(127).
 01 WS-BAD                 BINARY-LONG.
 01 WS-DISTINCT            BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-DYE-TABLE.
    05 WS-DYE-FILL         PIC X(6) OCCURS 16 TIMES.
    05 WS-DYE-DARK         PIC X(6) OCCURS 16 TIMES.
 01 WS-AREA.
    05 WS-V                OCCURS 2000 TIMES.
       10 WS-VX            FLOAT-SHORT.
       10 WS-VY            FLOAT-SHORT.
       10 WS-VZ            FLOAT-SHORT.
       10 WS-VU            FLOAT-SHORT.
       10 WS-VV            FLOAT-SHORT.
       10 WS-VB            FLOAT-SHORT.
       10 WS-VA            FLOAT-SHORT.
       10 WS-VSKY          FLOAT-SHORT.
       10 WS-VR            FLOAT-SHORT.
       10 WS-VG            FLOAT-SHORT.
       10 WS-VBLUE         FLOAT-SHORT.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 2000.
 01 WS-OUTLINE-BIAS        FLOAT-LONG VALUE 0.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D3                  FLOAT-LONG.
 01 WS-SCALED              BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE

*>   5.5: the advances of the worked examples.
     MOVE "HWeordl " TO WS-TEXT
     PERFORM SHOW-ADVANCES
     MOVE "sign font the project font (standin-content section 18) gives H W e o r d 6, l 5 (its l is wider than the jar's), the space 4" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "66666654" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The worked examples of the document use the advances of the font it was read from (l = 3): the table of this client state is set to them, everything else is the code's.
     MOVE 3 TO FN-ADVANCE(77)
     PERFORM SHOW-ADVANCES
     MOVE "sign font with the document's advances H W e o r d are 6, l 3, the space 4 (52-2 5.5)" TO TL-CASE
     MOVE "66666634" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   5.2 to 5.4: the layout of lines on a sign (kind 1) and a hanging sign (kind 3).
     MOVE "Hello" TO WS-TEXT
     MOVE 5 TO WS-LEN
     MOVE 1 TO WS-KIND WS-LINE
     PERFORM LAYOUT-LINE
     MOVE "sign layout Hello on line 1 of a sign: x -12, y -20, one piece of 5 bytes, width 24" TO TL-CASE
     MOVE "-12 -20 5 24" TO TL-EXPECTED
     PERFORM SHOW-LAYOUT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "World" TO WS-TEXT
     MOVE 2 TO WS-LINE
     PERFORM LAYOUT-LINE
     MOVE "sign layout World on line 2 of a sign: the odd width 27 gives x -13 (toward zero), y -10" TO TL-CASE
     MOVE "-13 -10 5 27" TO TL-EXPECTED
     PERFORM SHOW-LAYOUT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-LINE FROM 1 BY 1 UNTIL WS-LINE > 4
         PERFORM LAYOUT-LINE
         MOVE WS-LY TO WS-N1
         STRING FUNCTION TRIM(WS-N1) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "sign layout the four line origins of a sign are -20 -10 0 10" TO TL-CASE
     MOVE "-20 -10 0 10" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-KIND
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-LINE FROM 1 BY 1 UNTIL WS-LINE > 4
         PERFORM LAYOUT-LINE
         MOVE WS-LY TO WS-N1
         STRING FUNCTION TRIM(WS-N1) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "sign layout the four line origins of a hanging sign are -18 -9 0 9" TO TL-CASE
     MOVE "-18 -9 0 9" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE "Hello World Hello" TO WS-TEXT
     MOVE 17 TO WS-LEN
     MOVE 1 TO WS-KIND WS-LINE
     PERFORM LAYOUT-LINE
     MOVE "sign layout Hello World Hello (83) on a sign stays one piece of 17 bytes, x -41" TO TL-CASE
     MOVE "-41 -20 17 83" TO TL-EXPECTED
     PERFORM SHOW-LAYOUT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-KIND
     PERFORM LAYOUT-LINE
     MOVE "sign layout the same line on a hanging sign (limit 60) ends at the last space: Hello World, 11 bytes, width 55, x -27, y -18" TO TL-CASE
     MOVE "-27 -18 11 55" TO TL-EXPECTED
     PERFORM SHOW-LAYOUT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A word wider than the limit breaks inside itself, before the first character that does not fit.
     MOVE "WWWWWWWWWWWWWWWWWW" TO WS-TEXT
     MOVE 18 TO WS-LEN
     MOVE 1 TO WS-KIND
     PERFORM LAYOUT-LINE
     MOVE "sign layout 18 W (108) on a sign: 15 fit in exactly 90 (not over), the 16th breaks the line, x -45" TO TL-CASE
     MOVE "-45 -20 15 90" TO TL-EXPECTED
     PERFORM SHOW-LAYOUT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "Hello" TO WS-TEXT
     MOVE 5 TO WS-LEN
     MOVE 24 TO WS-LIMIT
     CALL "SGR-WRAP" USING CLIENT-STATE WS-TEXT WS-LEN WS-LIMIT WS-PIECE
     MOVE "sign wrap a line of width 24 fits a limit of 24 (the test is strictly greater)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-PIECE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 23 TO WS-LIMIT
     CALL "SGR-WRAP" USING CLIENT-STATE WS-TEXT WS-LEN WS-LIMIT WS-PIECE
     MOVE "sign wrap the same line over a limit of 23 loses its last letter" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-PIECE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "HH" TO WS-TEXT
     MOVE 2 TO WS-LEN
     MOVE 1 TO WS-LIMIT
     CALL "SGR-WRAP" USING CLIENT-STATE WS-TEXT WS-LEN WS-LIMIT WS-PIECE
     MOVE "sign wrap the first glyph is always taken, even wider than the limit; the second breaks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PIECE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LIMIT
     CALL "SGR-WRAP" USING CLIENT-STATE WS-TEXT WS-LEN WS-LIMIT WS-PIECE
     MOVE "sign wrap a limit below 1 is taken as 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PIECE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7552 TO WS-STATE
     CALL "SGR-KIND" USING CLIENT-STATE WS-STATE WS-KIND WS-KEY
     MOVE "sign kind with no content set open nothing is a sign (kind 0, key 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-KIND * 100 + WS-KEY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE "ab" TO WS-TEXT(1:2)
     MOVE FUNCTION CHAR(11) TO WS-TEXT(3:1)
     MOVE "cd" TO WS-TEXT(4:2)
     MOVE 5 TO WS-LEN
     MOVE 90 TO WS-LIMIT
     CALL "SGR-WRAP" USING CLIENT-STATE WS-TEXT WS-LEN WS-LIMIT WS-PIECE
     MOVE "sign wrap a line feed ends the piece (ab)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-PIECE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE "H" TO WS-TEXT(1:1)
     MOVE FUNCTION CHAR(196) TO WS-TEXT(2:1)
     MOVE FUNCTION CHAR(170) TO WS-TEXT(3:1)
     MOVE "llo" TO WS-TEXT(4:3)
     MOVE 6 TO WS-LEN
     MOVE 1 TO WS-KIND WS-LINE
     PERFORM LAYOUT-LINE
     MOVE "sign layout a two-byte character counts one glyph (the missing glyph, advance 6): 6 bytes, width 6+6+3+3+6 = 24" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "-12 -20 6 24" TO TL-EXPECTED
     PERFORM SHOW-LAYOUT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   4.1 to 4.3 and section 10: every corner of the worked examples, to 7 decimals (the font box of a glyph from (fx, fy): top left, bottom left, bottom right, top right).
     MOVE "10.1 standing sign rotation 0 front, H of Hello" TO WS-LABEL
     MOVE 1 TO WS-KIND
     MOVE 0 TO WS-KEY
     MOVE 1 TO WS-SIDE
     MOVE -12 TO WS-FX
     MOVE -20 TO WS-FY
     MOVE "03750000 10416667 05466667 03750000 09583333 05466667 04583333 09583333 05466667 04583333 10416667 05466667" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.1 standing sign rotation 0 front, W of World" TO WS-LABEL
     MOVE -13 TO WS-FX
     MOVE -10 TO WS-FY
     MOVE "03645833 09375000 05466667 03645833 08541667 05466667 04479167 08541667 05466667 04479167 09375000 05466667" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.1 standing sign rotation 0 back, H of Hello" TO WS-LABEL
     MOVE 2 TO WS-SIDE
     MOVE -12 TO WS-FX
     MOVE -20 TO WS-FY
     MOVE "06250000 10416667 04533333 06250000 09583333 04533333 05416667 09583333 04533333 05416667 10416667 04533333" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.1 standing sign rotation 0 back, W of World" TO WS-LABEL
     MOVE -13 TO WS-FX
     MOVE -10 TO WS-FY
     MOVE "06354167 09375000 04533333 06354167 08541667 04533333 05520833 08541667 04533333 05520833 09375000 04533333" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.1 standing sign rotation 4 (front toward west) front, H: x 0.4533333, z runs +z" TO WS-LABEL
     MOVE 4 TO WS-KEY
     MOVE 1 TO WS-SIDE
     MOVE -12 TO WS-FX
     MOVE -20 TO WS-FY
     MOVE "04533333 10416667 03750000 04533333 09583333 03750000 04533333 09583333 04583333 04533333 10416667 04583333" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.1 standing sign rotation 8 (front toward north) front equals the back of rotation 0" TO WS-LABEL
     MOVE 8 TO WS-KEY
     MOVE "06250000 10416667 04533333 06250000 09583333 04533333 05416667 09583333 04533333 05416667 10416667 04533333" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.1 standing sign rotation 8 back equals the front of rotation 0" TO WS-LABEL
     MOVE 2 TO WS-SIDE
     MOVE "03750000 10416667 05466667 03750000 09583333 05466667 04583333 09583333 05466667 04583333 10416667 05466667" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.2 wall sign facing north front, H of Hello" TO WS-LABEL
     MOVE 2 TO WS-KIND
     MOVE 2 TO WS-KEY
     MOVE 1 TO WS-SIDE
     MOVE "06250000 07291667 08908333 06250000 06458333 08908333 05416667 06458333 08908333 05416667 07291667 08908333" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.2 wall sign facing north front, W of World" TO WS-LABEL
     MOVE -13 TO WS-FX
     MOVE -10 TO WS-FY
     MOVE "06354167 06250000 08908333 06354167 05416667 08908333 05520833 05416667 08908333 05520833 06250000 08908333" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.2 wall sign facing north back, H of Hello" TO WS-LABEL
     MOVE 2 TO WS-SIDE
     MOVE -12 TO WS-FX
     MOVE -20 TO WS-FY
     MOVE "03750000 07291667 09841667 03750000 06458333 09841667 04583333 06458333 09841667 04583333 07291667 09841667" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.2 wall sign facing north back, W of World" TO WS-LABEL
     MOVE -13 TO WS-FX
     MOVE -10 TO WS-FY
     MOVE "03645833 06250000 09841667 03645833 05416667 09841667 04479167 05416667 09841667 04479167 06250000 09841667" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.2 wall sign facing south front, H of Hello: z 0.1091667, text toward +x" TO WS-LABEL
     MOVE 0 TO WS-KEY
     MOVE 1 TO WS-SIDE
     MOVE -12 TO WS-FX
     MOVE -20 TO WS-FY
     MOVE "03750000 07291667 01091667 03750000 06458333 01091667 04583333 06458333 01091667 04583333 07291667 01091667" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.2 wall sign facing east front, H of Hello: x 0.1091667, text toward -z" TO WS-LABEL
     MOVE 3 TO WS-KEY
     MOVE "01091667 07291667 06250000 01091667 06458333 06250000 01091667 06458333 05416667 01091667 07291667 05416667" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.2 wall sign facing west front, H of Hello: x 0.8908333, text toward +z" TO WS-LABEL
     MOVE 1 TO WS-KEY
     MOVE "08908333 07291667 03750000 08908333 06458333 03750000 08908333 06458333 04583333 08908333 07291667 04583333" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.3 ceiling hanging sign rotation 0 front, H of Hello (h 9, y -18)" TO WS-LABEL
     MOVE 3 TO WS-KIND
     MOVE 0 TO WS-KEY
     MOVE -12 TO WS-FX
     MOVE -18 TO WS-FY
     MOVE "03312500 05581250 05730000 03312500 04456250 05730000 04437500 04456250 05730000 04437500 05581250 05730000" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.3 ceiling hanging sign rotation 0 back, H of Hello" TO WS-LABEL
     MOVE 2 TO WS-SIDE
     MOVE "06687500 05581250 04270000 06687500 04456250 04270000 05562500 04456250 04270000 05562500 05581250 04270000" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.4 wall hanging sign facing north front, H of Hello" TO WS-LABEL
     MOVE 4 TO WS-KIND
     MOVE 2 TO WS-KEY
     MOVE 1 TO WS-SIDE
     MOVE "06687500 05581250 04270000 06687500 04456250 04270000 05562500 04456250 04270000 05562500 05581250 04270000" TO WS-EXPECT
     PERFORM CHECK-BOX
     MOVE "10.4 wall hanging sign facing north back, H of Hello" TO WS-LABEL
     MOVE 2 TO WS-SIDE
     MOVE "03312500 05581250 05730000 03312500 04456250 05730000 04437500 04456250 05730000 04437500 05581250 05730000" TO WS-EXPECT
     PERFORM CHECK-BOX

*>   4.3: the front normal of the 16 rotations (the z axis of the pose over the scale, four decimals) and the four facings.
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     MOVE 1 TO WS-KIND
     MOVE 1 TO WS-SIDE
     PERFORM VARYING WS-KEY FROM 0 BY 1 UNTIL WS-KEY > 15
         CALL "SGR-POSE" USING WS-KIND WS-KEY WS-SIDE WS-POSE
         COMPUTE WS-Q ROUNDED = WS-AZX / WS-SCALE * 10000
         MOVE WS-Q TO WS-N1
         COMPUTE WS-Q ROUNDED = WS-AZZ / WS-SCALE * 10000
         MOVE WS-Q TO WS-N2
         STRING FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "sign pose the front normals of the 16 rotations: south by west first, clockwise (52-2 4.3)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0,10000 -3827,9239 -7071,7071 -9239,3827 -10000,0 -9239,-3827 -7071,-7071 -3827,-9239 0,-10000 3827,-9239 7071,-7071 9239,-3827 10000,0 9239,3827 7071,7071 3827,9239"
         TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     MOVE 2 TO WS-KIND
     PERFORM VARYING WS-KEY FROM 0 BY 1 UNTIL WS-KEY > 3
         CALL "SGR-POSE" USING WS-KIND WS-KEY WS-SIDE WS-POSE
         COMPUTE WS-Q ROUNDED = WS-AZX / WS-SCALE
         MOVE WS-Q TO WS-N1
         COMPUTE WS-Q ROUNDED = WS-AZZ / WS-SCALE
         MOVE WS-Q TO WS-N2
         STRING FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "sign pose a wall sign's front looks toward its facing: south (0,1), west (-1,0), north (0,-1), east (1,0)" TO TL-CASE
     MOVE "0,1 -1,0 0,-1 1,0" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   6.1: the dyes (glowing fill = the text colour, non-glowing fill = glowing outline = the colour at 40 %).
     MOVE "FFFFFF" TO WS-DYE-FILL(1)
     MOVE "666666" TO WS-DYE-DARK(1)
     MOVE "FF681F" TO WS-DYE-FILL(2)
     MOVE "66290C" TO WS-DYE-DARK(2)
     MOVE "FF00FF" TO WS-DYE-FILL(3)
     MOVE "660066" TO WS-DYE-DARK(3)
     MOVE "9AC0CD" TO WS-DYE-FILL(4)
     MOVE "3D4C52" TO WS-DYE-DARK(4)
     MOVE "FFFF00" TO WS-DYE-FILL(5)
     MOVE "666600" TO WS-DYE-DARK(5)
     MOVE "BFFF00" TO WS-DYE-FILL(6)
     MOVE "4C6600" TO WS-DYE-DARK(6)
     MOVE "FF69B4" TO WS-DYE-FILL(7)
     MOVE "662A48" TO WS-DYE-DARK(7)
     MOVE "808080" TO WS-DYE-FILL(8)
     MOVE "333333" TO WS-DYE-DARK(8)
     MOVE "D3D3D3" TO WS-DYE-FILL(9)
     MOVE "545454" TO WS-DYE-DARK(9)
     MOVE "00FFFF" TO WS-DYE-FILL(10)
     MOVE "006666" TO WS-DYE-DARK(10)
     MOVE "A020F0" TO WS-DYE-FILL(11)
     MOVE "400C60" TO WS-DYE-DARK(11)
     MOVE "0000FF" TO WS-DYE-FILL(12)
     MOVE "000066" TO WS-DYE-DARK(12)
     MOVE "8B4513" TO WS-DYE-FILL(13)
     MOVE "371B07" TO WS-DYE-DARK(13)
     MOVE "00FF00" TO WS-DYE-FILL(14)
     MOVE "006600" TO WS-DYE-DARK(14)
     MOVE "FF0000" TO WS-DYE-FILL(15)
     MOVE "660000" TO WS-DYE-DARK(15)
     MOVE "000000" TO WS-DYE-FILL(16)
     MOVE "000000" TO WS-DYE-DARK(16)
     PERFORM VARYING WS-DYE FROM 0 BY 1 UNTIL WS-DYE > 15
         MOVE 0 TO WS-GLOW WS-NEAR
         CALL "SGR-COLOR" USING WS-DYE WS-GLOW WS-NEAR WS-FILL WS-OUTLINE WS-FULL
         MOVE WS-DYE-DARK(WS-DYE + 1) TO WS-HEXES
         PERFORM HEX-VALUE
         COMPUTE WS-Q = WS-FILL - WS-HEX-VALUE
         MOVE WS-OUTLINE TO WS-N1
         MOVE WS-FULL TO WS-N2
         MOVE WS-DYE TO WS-N3
         MOVE SPACES TO TL-CASE
         STRING "sign colour dye " FUNCTION TRIM(WS-N3) " not glowing: fill " WS-DYE-DARK(WS-DYE + 1)
             " (the colour at 40 %), no outline, block light" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE "0 -1 0" TO TL-EXPECTED
         MOVE WS-Q TO WS-N4
         MOVE SPACES TO TL-OBSERVED
         STRING FUNCTION TRIM(WS-N4) " " FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) DELIMITED BY SIZE INTO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 1 TO WS-GLOW
         MOVE 0 TO WS-NEAR
         CALL "SGR-COLOR" USING WS-DYE WS-GLOW WS-NEAR WS-FILL WS-OUTLINE WS-FULL
         MOVE WS-DYE-FILL(WS-DYE + 1) TO WS-HEXES
         PERFORM HEX-VALUE
         COMPUTE WS-Q = WS-FILL - WS-HEX-VALUE
         MOVE WS-Q TO WS-N4
         MOVE WS-OUTLINE TO WS-N1
         MOVE WS-FULL TO WS-N2
         MOVE SPACES TO TL-CASE
         STRING "sign colour dye " FUNCTION TRIM(WS-N3) " glowing, far: fill " WS-DYE-FILL(WS-DYE + 1)
             " unscaled, full light, outline only for black (F0EBCC)" DELIMITED BY SIZE INTO TL-CASE
         MOVE SPACES TO TL-OBSERVED
         MOVE SPACES TO TL-EXPECTED
         IF WS-DYE = 15
             MOVE "0 15789004 1" TO TL-EXPECTED
         ELSE
             MOVE "0 -1 1" TO TL-EXPECTED
         END-IF
         STRING FUNCTION TRIM(WS-N4) " " FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) DELIMITED BY SIZE INTO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 1 TO WS-NEAR
         CALL "SGR-COLOR" USING WS-DYE WS-GLOW WS-NEAR WS-FILL WS-OUTLINE WS-FULL
         MOVE WS-DYE-DARK(WS-DYE + 1) TO WS-HEXES
         IF WS-DYE = 15
             MOVE "F0EBCC" TO WS-HEXES
         END-IF
         PERFORM HEX-VALUE
         COMPUTE WS-Q = WS-OUTLINE - WS-HEX-VALUE
         MOVE WS-Q TO WS-N4
         MOVE SPACES TO TL-CASE
         STRING "sign colour dye " FUNCTION TRIM(WS-N3) " glowing, near: the outline is the colour at 40 % (black: cream F0EBCC)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "0" TO TL-EXPECTED
         MOVE WS-N4 TO TL-OBSERVED
         MOVE FUNCTION TRIM(WS-N4) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 99 TO WS-DYE
     MOVE 0 TO WS-GLOW WS-NEAR
     CALL "SGR-COLOR" USING WS-DYE WS-GLOW WS-NEAR WS-FILL WS-OUTLINE WS-FULL
     MOVE "sign colour an id outside the 16 dyes is white (31-3 section 8): 666666 = 6710886" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 6710886 TO TL-EXPECTED-N
     MOVE WS-FILL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   6.3: the outline distance, from the feet to the block centre, strictly under 16 (squared 256), or scoping.
     MOVE 0.5 TO WS-FEET-X WS-FEET-Y WS-FEET-Z
     MOVE 0 TO WS-SCOPING
     MOVE 16 TO WS-BLOCK-X
     MOVE 0 TO WS-BLOCK-Y WS-BLOCK-Z
     CALL "SGR-OUTLINE-NEAR" USING WS-FEET-X WS-FEET-Y WS-FEET-Z WS-BLOCK-X WS-BLOCK-Y WS-BLOCK-Z WS-SCOPING WS-NEAR
     MOVE "sign outline a block centre exactly 16 from the feet is not near" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NEAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO WS-BLOCK-X
     CALL "SGR-OUTLINE-NEAR" USING WS-FEET-X WS-FEET-Y WS-FEET-Z WS-BLOCK-X WS-BLOCK-Y WS-BLOCK-Z WS-SCOPING WS-NEAR
     MOVE "sign outline a block centre 15 away is near" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BLOCK-X
     MOVE 11 TO WS-BLOCK-Y
     MOVE 11 TO WS-BLOCK-Z
     CALL "SGR-OUTLINE-NEAR" USING WS-FEET-X WS-FEET-Y WS-FEET-Z WS-BLOCK-X WS-BLOCK-Y WS-BLOCK-Z WS-SCOPING WS-NEAR
     MOVE "sign outline the distance is three-dimensional: (0, 11, 11) is 15.56 away, near" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-BLOCK-Y
     MOVE 12 TO WS-BLOCK-Z
     CALL "SGR-OUTLINE-NEAR" USING WS-FEET-X WS-FEET-Y WS-FEET-Z WS-BLOCK-X WS-BLOCK-Y WS-BLOCK-Z WS-SCOPING WS-NEAR
     MOVE "sign outline (0, 12, 12) is 16.97 away, not near" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NEAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-SCOPING
     MOVE 100 TO WS-BLOCK-X
     CALL "SGR-OUTLINE-NEAR" USING WS-FEET-X WS-FEET-Y WS-FEET-Z WS-BLOCK-X WS-BLOCK-Y WS-BLOCK-Z WS-SCOPING WS-NEAR
     MOVE "sign outline a scoping player sees every outline, whatever the distance" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   6.5: the glyph quads. Corners times ten (and z times 1000) to be exact.
     MOVE -12 TO WS-X
     MOVE -20 TO WS-Y
     MOVE 8 TO WS-W WS-H
     MOVE 0 TO WS-BOLD WS-ITALIC
     MOVE 1 TO WS-COPY
     PERFORM CORNERS-TEXT
     MOVE "sign glyph a plain glyph at (-12, -20) is the 8 x 8 box: (-12,-20) (-12,-12) (-4,-12) (-4,-20), z 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "-120,-200 -120,-120 -40,-120 -40,-200 z 0" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-BOLD
     PERFORM CORNERS-TEXT
     MOVE "sign glyph a bold glyph's quad grows by 0.1 on every side" TO TL-CASE
     MOVE "-121,-201 -121,-119 -39,-119 -39,-201 z 0" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-COPY
     PERFORM CORNERS-TEXT
     MOVE "sign glyph the second copy of a bold glyph is one pixel to the right and 0.001 nearer" TO TL-CASE
     MOVE "-111,-201 -111,-119 -29,-119 -29,-201 z 1" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BOLD
     MOVE 1 TO WS-ITALIC
     MOVE 1 TO WS-COPY
     PERFORM CORNERS-TEXT
     MOVE "sign glyph italic moves the top edge 1 to the right and the bottom edge 1 to the left" TO TL-CASE
     MOVE "-110,-200 -130,-120 -50,-120 -30,-200 z 0" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   6.5: an obfuscated character is another glyph of the same advance; the space stays.
     MOVE 32 TO WS-CP
     CALL "SGR-OBFUSCATE" USING CLIENT-STATE WS-CP WS-OUT-CP
     MOVE "sign obfuscated the space is not replaced" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-OUT-CP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD WS-DISTINCT
     MOVE SPACES TO WS-SEEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         MOVE 72 TO WS-CP
         IF FUNCTION MOD(WS-I, 2) = 0
             MOVE 108 TO WS-CP
         END-IF
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-WANT
         CALL "SGR-OBFUSCATE" USING CLIENT-STATE WS-CP WS-OUT-CP
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-OUT-CP WS-GX WS-GY WS-GW WS-GH WS-ADV
         IF WS-ADV NOT = WS-WANT OR WS-OUT-CP < 33 OR WS-OUT-CP > 126
             ADD 1 TO WS-BAD
         END-IF
         IF WS-SEEN(WS-OUT-CP:1) = SPACE
             MOVE "x" TO WS-SEEN(WS-OUT-CP:1)
             ADD 1 TO WS-DISTINCT
         END-IF
     END-PERFORM
     MOVE "sign obfuscated 60 replacements of H (6) and l (3) all keep the advance, in 33 to 126" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sign obfuscated the replacements vary (at least 8 different glyphs in 60)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DISTINCT >= 8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The vertices of a drawn line: a standing sign, rotation 0, front, Hello at (-12, -20).
     MOVE 1 TO WS-KIND
     MOVE 0 TO WS-KEY
     MOVE 1 TO WS-SIDE
     CALL "SGR-POSE" USING WS-KIND WS-KEY WS-SIDE WS-POSE
     MOVE "Hello" TO WS-TEXT
     MOVE 5 TO WS-LEN
     MOVE 6710886 TO SP-RGB
     MOVE 0 TO SP-BIAS SP-BOLD SP-ITALIC SP-OBF
     MOVE 0.6 TO SP-BRIGHT
     MOVE 0.8 TO SP-SKY
     MOVE 0 TO WS-COUNT
     MOVE -12 TO WS-X
     MOVE -20 TO WS-Y
     MOVE -1 TO WS-OUTLINE
     CALL "SGR-LINE-DRAW" USING CLIENT-STATE WS-POSE WS-TEXT WS-LEN WS-X WS-Y SGR-PAINT WS-OUTLINE WS-OUTLINE-BIAS
         WS-V(1) WS-COUNT WS-CAPACITY
     MOVE "sign mesh Hello, not glowing: five glyph quads of six vertices, no outline" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 72 TO WS-CP
     CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-ADV
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-SCALED ROUNDED = WS-VX(WS-I) * 1000000
         MOVE WS-SCALED TO WS-N1
         COMPUTE WS-SCALED ROUNDED = WS-VY(WS-I) * 1000000
         MOVE WS-SCALED TO WS-N2
         COMPUTE WS-SCALED ROUNDED = WS-VZ(WS-I) * 1000000
         MOVE WS-SCALED TO WS-N3
         STRING FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) "," FUNCTION TRIM(WS-N3) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "sign mesh the H quad's six vertices (top left, bottom left, bottom right, top left, bottom right, top right) in millionths of a block (float precision)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "375000,1041667,546667 375000,958333,546667 458333,958333,546667 375000,1041667,546667 458333,958333,546667 458333,1041667,546667"
         TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-OBS
     COMPUTE WS-SCALED ROUNDED = (WS-GX + 0.01) * 100
     MOVE WS-SCALED TO WS-N1
     COMPUTE WS-SCALED ROUNDED = WS-VU(1) * UA-W * 100
     MOVE WS-SCALED TO WS-N2
     COMPUTE WS-SCALED ROUNDED = (WS-GY + WS-GH - 0.01) * 100
     MOVE WS-SCALED TO WS-N3
     COMPUTE WS-SCALED ROUNDED = WS-VV(3) * UA-H * 100
     MOVE WS-SCALED TO WS-N4
     MOVE "sign mesh the H quad's texture rectangle is its font cell inset by 0.01 texel (u of the first vertex, v of the third)" TO TL-CASE
     MOVE "same" TO TL-EXPECTED
     MOVE "diff" TO TL-OBSERVED
     IF WS-N1 = WS-N2 AND WS-N3 = WS-N4
         MOVE "same" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-OBS
     COMPUTE WS-SCALED ROUNDED = WS-VR(1) * 255
     MOVE WS-SCALED TO WS-N1
     COMPUTE WS-SCALED ROUNDED = WS-VG(1) * 255
     MOVE WS-SCALED TO WS-N2
     COMPUTE WS-SCALED ROUNDED = WS-VBLUE(1) * 255
     MOVE WS-SCALED TO WS-N3
     COMPUTE WS-SCALED ROUNDED = WS-VB(1) * 10
     MOVE WS-SCALED TO WS-N4
     COMPUTE WS-SCALED ROUNDED = WS-VSKY(1) * 10
     MOVE WS-SCALED TO WS-N5
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N3) " b " FUNCTION TRIM(WS-N4) " sky " FUNCTION TRIM(WS-N5)
         DELIMITED BY SIZE INTO WS-OBS
     MOVE "sign mesh white text not glowing is tinted 0x66 (the colour at 40 %) with the light terms of the cell" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "102 102 102 b 6 sky 8" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sign mesh the alpha of every vertex is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VA(30) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The pen advances by the advances of the glyphs: l at 0 and 3, o at 6 (top left x of the 3rd, 4th and 5th quad).
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 13 BY 6 UNTIL WS-I > 25
         COMPUTE WS-SCALED ROUNDED = WS-VX(WS-I) * 1000000
         MOVE WS-SCALED TO WS-N1
         STRING FUNCTION TRIM(WS-N1) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "sign mesh the pen advances 6, 6, 3 and 3: l, l and o start at x 0.5, 0.53125 and 0.5625" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "500000 531250 562500" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Glowing with an outline: eight passes of five quads in the outline colour, then the fill, the offsets in the order of 6.4.
     MOVE 16711680 TO SP-RGB
     MOVE 1 TO SP-BRIGHT SP-SKY
     MOVE 0 TO WS-COUNT
     MOVE 6684672 TO WS-OUTLINE
     CALL "SGR-LINE-DRAW" USING CLIENT-STATE WS-POSE WS-TEXT WS-LEN WS-X WS-Y SGR-PAINT WS-OUTLINE WS-OUTLINE-BIAS
         WS-V(1) WS-COUNT WS-CAPACITY
     MOVE "sign mesh glowing Hello with an outline: 8 passes + the fill = 45 quads = 270 vertices" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 270 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-OBS
     COMPUTE WS-SCALED ROUNDED = WS-VR(1) * 255
     MOVE WS-SCALED TO WS-N1
     COMPUTE WS-SCALED ROUNDED = WS-VR(240) * 255
     MOVE WS-SCALED TO WS-N2
     COMPUTE WS-SCALED ROUNDED = WS-VR(241) * 255
     MOVE WS-SCALED TO WS-N3
     COMPUTE WS-SCALED ROUNDED = WS-VG(241) * 255
     MOVE WS-SCALED TO WS-N4
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N3) " " FUNCTION TRIM(WS-N4) DELIMITED BY SIZE INTO WS-OBS
     MOVE "sign mesh the first 240 vertices are the outline colour 0x660000 (red 102), the last 30 the fill 0xFF0000 (red 255, green 0)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "102 102 255 0" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Pass 1 is (-1, -1), pass 2 (-1, 0), pass 3 (-1, +1), pass 4 (0, -1): the top left x and y of each pass's first glyph (vertex 1 + 30 per pass), in 10^-6 of a block.
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
         COMPUTE WS-K = WS-I * 30 + 1
         COMPUTE WS-SCALED ROUNDED = (WS-VX(WS-K) - 0.375) * 96
         MOVE WS-SCALED TO WS-N1
         COMPUTE WS-SCALED ROUNDED = (WS-VY(WS-K) - 1.0416667) * 96
         MOVE WS-SCALED TO WS-N2
         STRING FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "sign mesh the eight outline passes are offset (dx,dy) -1,-1 -1,0 -1,1 0,-1 0,1 1,-1 1,0 1,1 font pixels (y up in the printout: dy -1 is up)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "-1,1 -1,0 -1,-1 0,1 0,-1 1,1 1,0 1,-1" TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The pull toward the eye scales the eye-relative position by 1 - bias.
     MOVE 6710886 TO SP-RGB
     MOVE 0.5 TO SP-BIAS
     MOVE 0 TO WS-COUNT
     MOVE -1 TO WS-OUTLINE
     CALL "SGR-LINE-DRAW" USING CLIENT-STATE WS-POSE WS-TEXT WS-LEN WS-X WS-Y SGR-PAINT WS-OUTLINE WS-OUTLINE-BIAS
         WS-V(1) WS-COUNT WS-CAPACITY
     COMPUTE WS-SCALED ROUNDED = WS-VX(1) * 1000000
     MOVE "sign mesh a pull of 0.5 halves the eye-relative position: x 0.375 becomes 0.1875" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 187500 TO TL-EXPECTED-N
     MOVE WS-SCALED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO SP-BIAS

*>   Bold: two quads a glyph, the second a pixel right and nearer, the pen advancing by one more; italic and the space.
     MOVE "HH" TO WS-TEXT
     MOVE 2 TO WS-LEN
     MOVE 1 TO SP-BOLD
     MOVE 0 TO WS-COUNT
     CALL "SGR-LINE-DRAW" USING CLIENT-STATE WS-POSE WS-TEXT WS-LEN WS-X WS-Y SGR-PAINT WS-OUTLINE WS-OUTLINE-BIAS
         WS-V(1) WS-COUNT WS-CAPACITY
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 6 UNTIL WS-I > 19
         COMPUTE WS-SCALED ROUNDED = (WS-VX(WS-I) - 0.375) * 96 * 10
         MOVE WS-SCALED TO WS-N1
         STRING FUNCTION TRIM(WS-N1) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE WS-COUNT TO WS-N2
     MOVE "sign mesh bold HH: four quads, left edges at tenths of a pixel -1, +9, +69, +79 from the first (the pen advances 6 + 1)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "-1 9 69 79 24" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-OBS) " " FUNCTION TRIM(WS-N2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-D1 = (WS-VZ(7) - WS-VZ(1)) * 10000000
     MOVE "sign mesh the second copy of a bold glyph is nearer the viewer by 0.001 font pixel (about 1.04e-5 block)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-D1 > 90 AND WS-D1 < 120
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO SP-BOLD
     MOVE 1 TO SP-ITALIC
     MOVE "H" TO WS-TEXT
     MOVE 1 TO WS-LEN
     MOVE 0 TO WS-COUNT
     CALL "SGR-LINE-DRAW" USING CLIENT-STATE WS-POSE WS-TEXT WS-LEN WS-X WS-Y SGR-PAINT WS-OUTLINE WS-OUTLINE-BIAS
         WS-V(1) WS-COUNT WS-CAPACITY
     COMPUTE WS-SCALED ROUNDED = (WS-VX(1) - WS-VX(2)) * 96
     MOVE "sign mesh an italic glyph's top edge is two font pixels right of its bottom edge" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-SCALED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO SP-ITALIC
     MOVE 1 TO SP-OBF
     MOVE "HH" TO WS-TEXT
     MOVE 2 TO WS-LEN
     MOVE 0 TO WS-COUNT
     CALL "SGR-LINE-DRAW" USING CLIENT-STATE WS-POSE WS-TEXT WS-LEN WS-X WS-Y SGR-PAINT WS-OUTLINE WS-OUTLINE-BIAS
         WS-V(1) WS-COUNT WS-CAPACITY
     MOVE "sign mesh obfuscated HH draws two quads, the second 6 pixels on" TO TL-CASE
     MOVE "12 6" TO TL-EXPECTED
     COMPUTE WS-SCALED ROUNDED = (WS-VX(7) - WS-VX(1)) * 96
     MOVE WS-SCALED TO WS-N1
     MOVE WS-COUNT TO WS-N2
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO SP-OBF
     MOVE "a b" TO WS-TEXT
     MOVE 3 TO WS-LEN
     MOVE 0 TO WS-COUNT
     CALL "SGR-LINE-DRAW" USING CLIENT-STATE WS-POSE WS-TEXT WS-LEN WS-X WS-Y SGR-PAINT WS-OUTLINE WS-OUTLINE-BIAS
         WS-V(1) WS-COUNT WS-CAPACITY
     COMPUTE WS-SCALED ROUNDED = (WS-VX(7) - WS-VX(1)) * 96
     MOVE WS-SCALED TO WS-N1
     MOVE WS-COUNT TO WS-N2
     MOVE "sign mesh a space draws no quad and advances 4: a b is two quads, b 10 pixels after a" TO TL-CASE
     MOVE "12 10" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "Hello" TO WS-TEXT
     MOVE 5 TO WS-LEN
     MOVE 0 TO WS-COUNT
     MOVE 12 TO WS-CAPACITY
     CALL "SGR-LINE-DRAW" USING CLIENT-STATE WS-POSE WS-TEXT WS-LEN WS-X WS-Y SGR-PAINT WS-OUTLINE WS-OUTLINE-BIAS
         WS-V(1) WS-COUNT WS-CAPACITY
     MOVE "sign mesh a full vertex area takes no partial quad: capacity 12 holds two quads of Hello" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-OBS = the advances of the eight characters of WS-TEXT as digits.
 SHOW-ADVANCES.
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE WS-CP = FUNCTION ORD(WS-TEXT(WS-I:1)) - 1
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-X WS-Y WS-W WS-H WS-ADV
         MOVE WS-ADV TO WS-N1
         STRING FUNCTION TRIM(WS-N1) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM.

*> Lays out WS-TEXT (WS-LEN bytes) on line WS-LINE of kind WS-KIND: WS-LX, WS-LY, WS-PIECE, WS-WIDTH.
 LAYOUT-LINE.
     CALL "SGR-LAYOUT" USING CLIENT-STATE WS-KIND WS-LINE WS-TEXT WS-LEN WS-LX WS-LY WS-PIECE WS-WIDTH.

*> TL-OBSERVED = "x y piece width" of the last layout.
 SHOW-LAYOUT.
     MOVE "T" TO TL-MODE
     MOVE WS-LX TO WS-N1
     MOVE WS-LY TO WS-N2
     MOVE WS-PIECE TO WS-N3
     MOVE WS-WIDTH TO WS-N4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N3) " " FUNCTION TRIM(WS-N4) DELIMITED BY SIZE INTO TL-OBSERVED.

*> The corners of the 8 x 8 font box from (WS-FX, WS-FY) under the pose of WS-KIND, WS-KEY, WS-SIDE as eight-digit millionths... ten-millionths of a block, joined by spaces,
*> checked against WS-EXPECT (the corner list of the worked example) under the case WS-LABEL.
 CHECK-BOX.
     CALL "SGR-POSE" USING WS-KIND WS-KEY WS-SIDE WS-POSE
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1
                 MOVE WS-FX TO WS-X
                 MOVE WS-FY TO WS-Y
             WHEN 2
                 MOVE WS-FX TO WS-X
                 COMPUTE WS-Y = WS-FY + 8
             WHEN 3
                 COMPUTE WS-X = WS-FX + 8
                 COMPUTE WS-Y = WS-FY + 8
             WHEN OTHER
                 COMPUTE WS-X = WS-FX + 8
                 MOVE WS-FY TO WS-Y
         END-EVALUATE
         COMPUTE WS-PX = WS-OX + WS-X * WS-AXX
         COMPUTE WS-PY = WS-OY - WS-Y * WS-SCALE
         COMPUTE WS-PZ = WS-OZ + WS-X * WS-AXZ
         COMPUTE WS-Q ROUNDED = WS-PX * 10000000
         MOVE WS-Q TO WS-NUM8
         STRING WS-NUM8 " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
         COMPUTE WS-Q ROUNDED = WS-PY * 10000000
         MOVE WS-Q TO WS-NUM8
         STRING WS-NUM8 " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
         COMPUTE WS-Q ROUNDED = WS-PZ * 10000000
         MOVE WS-Q TO WS-NUM8
         STRING WS-NUM8 " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE WS-LABEL TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-HEX-VALUE = the number of the six hex digits in WS-HEXES.
 HEX-VALUE.
     MOVE 0 TO WS-HEX-VALUE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         COMPUTE WS-HEX-DIGIT = FUNCTION ORD(WS-HEXES(WS-K:1)) - 1
         IF WS-HEX-DIGIT >= 65
             COMPUTE WS-HEX-DIGIT = WS-HEX-DIGIT - 55
         ELSE
             COMPUTE WS-HEX-DIGIT = WS-HEX-DIGIT - 48
         END-IF
         COMPUTE WS-HEX-VALUE = WS-HEX-VALUE * 16 + WS-HEX-DIGIT
     END-PERFORM.

*> WS-OBS = the four corners of SGR-GLYPH-CORNERS (WS-X, WS-Y, WS-W, WS-H, WS-BOLD, WS-ITALIC, WS-COPY) in tenths of a pixel, then z in thousandths.
 CORNERS-TEXT.
     CALL "SGR-GLYPH-CORNERS" USING WS-X WS-Y WS-W WS-H WS-BOLD WS-ITALIC WS-COPY WS-CORNERS WS-Z
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-Q ROUNDED = WS-C(WS-I * 2 - 1) * 10
         MOVE WS-Q TO WS-N1
         COMPUTE WS-Q ROUNDED = WS-C(WS-I * 2) * 10
         MOVE WS-Q TO WS-N2
         STRING FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     COMPUTE WS-Q ROUNDED = WS-Z * 1000
     MOVE WS-Q TO WS-N1
     STRING "z " FUNCTION TRIM(WS-N1) DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR.
 END PROGRAM TEST-SIGN-RENDER.
