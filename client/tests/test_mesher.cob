*> Implementation test of client/src/mesher.cob (MESH-SECTION, MESH-DIRTY; data-model §13 per-face
*> brightness; standin-content §1.1 culling): faces against opaque neighbours are culled; between
*> two lucite blocks the shared faces are culled, and against an opaque block the lucite face is
*> culled while the opaque block's face is drawn; per-face brightness is top 1.0, north and south
*> 0.8, east and west 0.6, bottom 0.5 times max(sky x daylight, block light) / 15 of the cell the
*> face looks into, at least 0.1; translucent sprites go to the translucent mesh; texture
*> coordinates come from the atlas.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SECTION             BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-SHORT.
 01 WS-Y                   FLOAT-SHORT.
 01 WS-Z                   FLOAT-SHORT.
 01 WS-FOUND               BINARY-LONG.
 01 WS-B                   FLOAT-SHORT.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 WS-E                   PIC 9.99.
 01 WS-E1                  PIC Z9.
 01 WS-ROW-2-X             BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-SECTION-24          BINARY-LONG.
 01 WS-VERTICES            BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-NAME                PIC X(80).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-EXPECT-U            FLOAT-SHORT.
 01 WS-EXPECT-V            FLOAT-SHORT.
 01 WS-U16                 FLOAT-SHORT VALUE 0.
 01 WS-V16                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 1000 TO SK-U
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE ALL X"FF" TO CE-SKYS
*>   An isolated greystone at (1, 1, 1); a greystone pair (5, 1, 1)-(6, 1, 1); a lucite pair
*>   (10, 1, 1)-(11, 1, 1) with greystone on top of the first; greystone at (1, 5, 1) under a cell
*>   with block light 9 and no sky light; greystone at (1, 10, 1) under a dark cell.
     CALL "TEST-PUT" USING CE-CHUNK "01 01 01 02"
     CALL "TEST-PUT" USING CE-CHUNK "05 01 01 02"
     CALL "TEST-PUT" USING CE-CHUNK "06 01 01 02"
     CALL "TEST-PUT" USING CE-CHUNK "10 01 01 12"
     CALL "TEST-PUT" USING CE-CHUNK "11 01 01 12"
     CALL "TEST-PUT" USING CE-CHUNK "10 02 01 02"
     CALL "TEST-PUT" USING CE-CHUNK "01 05 01 02"
     CALL "TEST-LIGHT" USING CLIENT-STATE WS-ROW "0 01 06 01 00"
     CALL "TEST-LIGHT" USING CLIENT-STATE WS-ROW "1 01 06 01 09"
     CALL "TEST-PUT" USING CE-CHUNK "01 10 01 02"
     CALL "TEST-LIGHT" USING CLIENT-STATE WS-ROW "0 01 11 01 00"
     MOVE 1 TO WR-DIRTY(WS-ROW, 1) WR-DIRTY(WS-ROW, 2)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE "mesher one dirty section per budget unit is meshed and marked for upload" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "011" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WR-DIRTY(WS-ROW, 1) WR-DIRTY(WS-ROW, 2) WR-UPLOAD(WS-ROW, 1) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mesher an isolated block draws six faces: top 1.0, north and south 0.8, east and west "
         & "0.6, bottom 0.5 under full sky light by day" TO TL-CASE
     MOVE "1.00 0.80 0.80 0.60 0.60 0.50" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 02.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 01.5 01.0 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 01.5 02.0 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.0 01.5 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "02.0 01.5 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 01.0 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mesher the faces between two opaque blocks are culled, their outer faces drawn"
         TO TL-CASE
     MOVE "none none 0.60 0.60" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "06.0 01.5 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "06.0 01.5 01.5 1" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "05.0 01.5 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "07.0 01.5 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mesher lucite: faces between two lucite blocks culled; the lucite face under greystone "
         & "culled, the greystone face over lucite drawn; lucite faces in the translucent mesh only"
         TO TL-CASE
     MOVE "none none 0.10 0.60 none" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "11.0 01.5 01.5 1" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "10.5 02.0 01.5 1" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "10.5 02.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "10.0 01.5 01.5 1" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "10.0 01.5 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mesher a face lit only by block light 9 has 9 / 15; a face looking into a dark cell has "
         & "the floor 0.1" TO TL-CASE
     MOVE "0.60 0.10" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 06.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 11.0 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "greystone" TO WS-NAME
     MOVE "cobolcraft:block/greystone" TO WS-NAME
     MOVE 26 TO WS-NAME-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-EXPECT-U WS-EXPECT-V
     MOVE 1.5 TO WS-X WS-Z
     MOVE 2 TO WS-Y
     CALL "TEST-MESH-FACE" USING WR-OP-ADDR(WS-ROW, 1) WR-OP-COUNT(WS-ROW, 1) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V
     MOVE "mesher texture coordinates are the sprite's place in the atlas (top-left corner of the "
         & "greystone top face at the sprite's top-left)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-U - WS-EXPECT-U) < 0.0001 AND FUNCTION ABS(WS-V - WS-EXPECT-V) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 200 TO SK-U
     MOVE "mesher by night (daylight 0.2, the mesh not rebuilt) sky light 15 counts as 3: the top "
         & "face is 0.20" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0.20" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 02.0 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   T2942: states above 255 mesh and cull through the per-state tables. State 300 borrows the baked
*>   quads of greystone and is opaque (block 77); state 400 has no baked model (it draws nothing)
*>   and is opaque; greystone at (9, 1, 1) next to it loses its west face (its east face looks into the dark lucite cell: 0.10).
     MOVE 1000 TO SK-U
     MOVE BM-STATE(3) TO BM-STATE(301)
     MOVE 1 TO ST-OPAQUE(301) ST-OPAQUE(401)
     MOVE 77 TO ST-BLOCK(301)
     MOVE 300 TO CE-STATE(1 * 256 + 1 * 16 + 3 + 1)
     MOVE 300 TO CE-STATE(1 * 256 + 1 * 16 + 4 + 1)
     MOVE 400 TO CE-STATE(1 * 256 + 1 * 16 + 8 + 1)
     MOVE 2 TO CE-STATE(1 * 256 + 1 * 16 + 9 + 1)
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW WS-SECTION
     MOVE "mesher a state above 255 draws its baked faces and culls the face against its opaque "
         & "neighbour; a state with no baked model draws nothing but hides the face beside it"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1.00 none 1.00 none none 0.10" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "03.5 02.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "04.0 01.5 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "04.5 02.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "08.5 02.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "09.0 01.5 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "10.0 01.5 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   T2942: a 24-section column of the standard overworld (min_y -64, height 384): greystone in
*>   section 21 (1-based) at height 3 above the section's floor, at the very top of the world (section
*>   24, height 15) and at the very bottom (section 1, height 0).
     MOVE -64 TO PL-MIN-Y
     MOVE 384 TO PL-HEIGHT
     MOVE 2 TO WS-ROW-2-X
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ROW-2-X WS-ZERO2 WS-ROW2
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW2)
     MOVE ALL X"FF" TO CE-SKYS
     MOVE 2 TO CE-STATE(323 * 256 + 1 * 16 + 1 + 1)
     MOVE 2 TO CE-STATE(383 * 256 + 1 * 16 + 1 + 1)
     MOVE 2 TO CE-STATE(0 * 256 + 1 * 16 + 1 + 1)
     MOVE 21 TO WS-SECTION-24
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW2 WS-SECTION-24
     MOVE "mesher section 21 of a 24-section column: the greystone at height 3 has its six faces "
         & "at the section's local coordinates, the top face under full sky light" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "6 1.00" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WR-OP-COUNT(WS-ROW2, 21) TO WS-VERTICES
     DIVIDE WS-VERTICES BY 6 GIVING WS-VERTICES
     MOVE WS-VERTICES TO WS-E1
     MOVE 1.5 TO WS-X WS-Z
     MOVE 4 TO WS-Y
     CALL "TEST-MESH-FACE" USING WR-OP-ADDR(WS-ROW2, 21) WR-OP-COUNT(WS-ROW2, 21) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V
     MOVE WS-B TO WS-E
     STRING FUNCTION TRIM(WS-E1) " " WS-E DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 24 TO WS-SECTION-24
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW2 WS-SECTION-24
     MOVE "mesher the top section of the column (24): the face at the top of the world looks into "
         & "void under full sky light (1.00), the bottom face into the cell below (0.50)"
         TO TL-CASE
     MOVE "1.00 0.50" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 16 TO WS-Y
     CALL "TEST-MESH-FACE" USING WR-OP-ADDR(WS-ROW2, 24) WR-OP-COUNT(WS-ROW2, 24) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V
     MOVE WS-B TO WS-E
     STRING WS-E DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 15 TO WS-Y
     CALL "TEST-MESH-FACE" USING WR-OP-ADDR(WS-ROW2, 24) WR-OP-COUNT(WS-ROW2, 24) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V
     MOVE WS-B TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " WS-E DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO WS-SECTION-24
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW2 WS-SECTION-24
     MOVE "mesher the lowest section (1): the bottom face at the floor of the world looks into the "
         & "dark below it (the floor 0.10)" TO TL-CASE
     MOVE "0.10" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-Y
     CALL "TEST-MESH-FACE" USING WR-OP-ADDR(WS-ROW2, 1) WR-OP-COUNT(WS-ROW2, 1) WS-X WS-Y WS-Z
         WS-FOUND WS-B WS-U WS-V
     MOVE WS-B TO WS-E
     STRING WS-E DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MESHER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PUT.
*> USING the chunk cells, spec "xx yy zz ss": sets the cell's state, its sky light to 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CELL                BINARY-LONG.
 01 WS-CHUNK               USAGE POINTER.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CELLS REPLACING ==BASED== BY == ==.
 01 L-SPEC.
    05 L-X                 PIC 99.
    05 FILLER              PIC X.
    05 L-Y                 PIC 99.
    05 FILLER              PIC X.
    05 L-Z                 PIC 99.
    05 FILLER              PIC X.
    05 L-STATE             PIC 99.
 PROCEDURE DIVISION USING CE-CHUNK L-SPEC.
     COMPUTE WS-CELL = L-Y * 256 + L-Z * 16 + L-X + 1
     MOVE L-STATE TO CE-STATE(WS-CELL)
     SET WS-CHUNK TO ADDRESS OF CE-CHUNK
     MOVE L-Y TO WS-Y
     MOVE L-X TO WS-X
     MOVE L-Z TO WS-Z
     CALL "LIGHT-SET" USING WS-CHUNK WS-KIND WS-Y WS-X WS-Z WS-LEVEL
     GOBACK.
 END PROGRAM TEST-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT.
*> USING CLIENT-STATE, row, spec "k xx yy zz ll": sets the light (k 0 sky, 1 block) of the cell
*> (x, y, z, offsets from the dimension's bottom, in the chunk's first 16 columns) to ll.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-SPEC                 PIC X(13).
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SPEC.
     MOVE FUNCTION NUMVAL(L-SPEC(1:1)) TO WS-K
     MOVE FUNCTION NUMVAL(L-SPEC(3:2)) TO WS-X
     MOVE FUNCTION NUMVAL(L-SPEC(6:2)) TO WS-Y
     MOVE FUNCTION NUMVAL(L-SPEC(9:2)) TO WS-Z
     MOVE FUNCTION NUMVAL(L-SPEC(12:2)) TO WS-L
     CALL "LIGHT-SET" USING WR-ADDR(L-ROW) WS-K WS-Y WS-X WS-Z WS-L
     GOBACK.
 END PROGRAM TEST-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FACE.
*> USING CLIENT-STATE, row, spec "xx.x yy.y zz.z t" (centre, translucent flag), text (appended): the
*> brightness of the face with that centre in section 1's opaque (0) or translucent (1) mesh, or
*> "none".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
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
 01 WS-E                   PIC 9.99.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-SPEC.
    05 L-X                 PIC X(4).
    05 FILLER              PIC X.
    05 L-Y                 PIC X(4).
    05 FILLER              PIC X.
    05 L-Z                 PIC X(4).
    05 FILLER              PIC X.
    05 L-TRANSLUCENT       PIC 9.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SPEC L-TEXT.
     COMPUTE WS-X = FUNCTION NUMVAL(L-X)
     COMPUTE WS-Y = FUNCTION NUMVAL(L-Y)
     COMPUTE WS-Z = FUNCTION NUMVAL(L-Z)
     IF L-TRANSLUCENT = 0
         CALL "TEST-MESH-VERTEX" USING WR-OP-ADDR(L-ROW, 1) WR-OP-COUNT(L-ROW, 1) WS-X WS-Y WS-Z
             WS-FOUND WS-B WS-U WS-V WS-SKY WS-R WS-G WS-BLUE
     ELSE
         CALL "TEST-MESH-VERTEX" USING WR-TR-ADDR(L-ROW, 1) WR-TR-COUNT(L-ROW, 1) WS-X WS-Y WS-Z
             WS-FOUND WS-B WS-U WS-V WS-SKY WS-R WS-G WS-BLUE
     END-IF
*>   The drawn brightness: the shader's max(brightness, sky x daylight) at this state's daylight.
     COMPUTE WS-SKY = WS-SKY * SK-U / 1000
     IF WS-SKY > WS-B
         MOVE WS-SKY TO WS-B
     END-IF
     COMPUTE WS-E ROUNDED = WS-B
     IF WS-FOUND = 1
         STRING FUNCTION TRIM(L-TEXT) " " WS-E DELIMITED BY SIZE INTO L-TEXT
     ELSE
         STRING FUNCTION TRIM(L-TEXT) " none" DELIMITED BY SIZE INTO L-TEXT
     END-IF
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-FACE.
 COPY CLTEST.
