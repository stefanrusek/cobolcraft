*> Implementation test of client/src/sky-stopgap.cob (the client-side sky light stopgap, until CC-0007 builds the
*> real light engine): in a dimension with sky light, a cell whose stored sky light is 0 meshes (and reads through
*> WORLD-CELL) with sky 15 at and above each column's surface and 0 below, less one per cell below the top of water;
*> real nonzero sky light is used as it is; stored light is not changed; the surfaces are kept per row until a
*> block changes; a dimension without sky light is not touched.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SKY-STOPGAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-LX                  BINARY-LONG VALUE 1.
 01 WS-LY                  BINARY-LONG VALUE 10.
 01 WS-LZ                  BINARY-LONG VALUE 1.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEVEL-E             PIC 99.
 01 WS-ROW2                BINARY-LONG.
 01 WS-ONE-CX              BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-STONE               BINARY-LONG VALUE 2.
 01 WS-WATER               BINARY-LONG VALUE 310.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-NUM                 PIC +999.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 1000 TO SK-U
     MOVE 1 TO PL-HAS-SKY
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
*>   Stone (greystone, state 02) columns y 0 to 9 at (1, 1) and (5, 5); a one-cell cave at (5, 4, 5) under the
*>   stone above it. No light data at all, as the core sends for a fresh standard chunk.
     PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 9
         COMPUTE CE-STATE(WS-LY * 256 + 1 * 16 + 1 + 1) = 2
         COMPUTE CE-STATE(WS-LY * 256 + 5 * 16 + 5 + 1) = 2
     END-PERFORM
     MOVE 0 TO CE-STATE(4 * 256 + 5 * 16 + 5 + 1)
     MOVE 10 TO WS-LY
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE

     MOVE "T" TO TL-MODE
     MOVE "sky-stopgap given a stone column under open sky and no sky light data when meshed then the top face "
         & "has sky 1.00 and the face looking into a covered cave cell stays at the 0.10 floor" TO TL-CASE
     MOVE "1.00 0.10" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 10.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "05.5 04.0 05.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "LIGHT-GET" USING WR-ADDR(WS-ROW) WS-KIND WS-LY WS-LX WS-LZ WS-LEVEL
     MOVE WS-LEVEL TO WS-LEVEL-E
     MOVE "sky-stopgap given the stopgap lit a mesh then the stored sky light of that cell is still 0" TO TL-CASE
     MOVE "00" TO TL-EXPECTED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A dimension without sky light is not touched.
     MOVE 0 TO PL-HAS-SKY
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE "sky-stopgap given a dimension without sky light when meshed then the top face stays at the 0.10 floor"
         TO TL-CASE
     MOVE "0.10" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 10.0 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Real nonzero sky light in the section (7 above the column): as it is, not the stopgap's 15.
     MOVE 1 TO PL-HAS-SKY
     CALL "TEST-LIGHT" USING CLIENT-STATE WS-ROW "0 01 10 01 07"
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE "sky-stopgap given real nonzero sky light in one cell of the section when meshed then that cell is used as it "
         & "is: 7 / 15, and a cell of 0 above the surface in the same section is the assumed 1.00" TO TL-CASE
     MOVE "0.47 1.00" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 10.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "05.5 10.0 05.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Real sky light in every section: the cave face takes the real 15, the stopgap has nothing to do.
     MOVE ALL X"FF" TO CE-SKYS
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE "sky-stopgap given real sky light everywhere when meshed then the cave face has the real 1.00"
         TO TL-CASE
     MOVE "1.00" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "05.5 04.0 05.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   ---- CC-0007 stopgap, the dark-terrain fix: every loaded chunk lit at once, and cheaply ----
*>   The surface of the row is found once and kept: a changed cache is read by the next section meshed.
     MOVE LOW-VALUES TO CE-SKYS
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE WR-SURF-OK(WS-ROW) TO WS-NUM
     MOVE "sky-stopgap given a row meshed once when the surface cache is asked then it is current" TO TL-CASE
     MOVE "+001" TO TL-EXPECTED
     MOVE WS-NUM TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WR-SURF(WS-ROW, 18) TO WS-NUM
     MOVE "sky-stopgap given the stone column at (1, 1) when its surface is cached then it is 10" TO TL-CASE
     MOVE "+010" TO TL-EXPECTED
     MOVE WS-NUM TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WR-SURF(WS-ROW, 86)
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE "sky-stopgap given a current cache with the cave column's surface changed by hand when meshed again then the "
         & "cave face follows the cache (the surface is not scanned again)" TO TL-CASE
     MOVE "1.00" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "05.5 04.0 05.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A block set drops the cache; the new top block raises the surface and its top face is lit.
     MOVE 1 TO WS-BX
     MOVE 10 TO WS-BY
     MOVE 1 TO WS-BZ
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STONE
     MOVE WR-SURF-OK(WS-ROW) TO WS-NUM
     MOVE "sky-stopgap given a block set in the row when the cache is asked then it is no longer current" TO TL-CASE
     MOVE "+000" TO TL-EXPECTED
     MOVE WS-NUM TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-FOUR
     MOVE WR-SURF(WS-ROW, 18) TO WS-NUM
     MOVE "sky-stopgap given a stone placed on the column when meshed then the surface is 11 and the cave face is dark again"
         TO TL-CASE
     MOVE "+011 0.10 1.00" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-NUM " " DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "05.5 04.0 05.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 11.0 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A chunk border: the face at the edge looks into the neighbouring chunk's cell, lit by that chunk's own surface.
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ONE-CX WS-ZERO WS-ROW2
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW2)
     PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 9
         COMPUTE CE-STATE(WS-LY * 256 + 5 * 16 + 0 + 1) = 2
     END-PERFORM
     MOVE 0 TO CE-STATE(5 * 256 + 5 * 16 + 0 + 1)
     PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 2
         COMPUTE CE-STATE(WS-LY * 256 + 7 * 16 + 0 + 1) = 2
     END-PERFORM
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 9
         COMPUTE CE-STATE(WS-LY * 256 + 5 * 16 + 15 + 1) = 2
     END-PERFORM
     PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 4
         COMPUTE CE-STATE(WS-LY * 256 + 7 * 16 + 15 + 1) = 2
     END-PERFORM
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-FOUR
     MOVE "sky-stopgap given the east edge of a chunk when its neighbour's cell is under stone (a cave) or above that "
         & "chunk's surface then the face looks into 0.10 and into 0.60" TO TL-CASE
     MOVE "0.10 0.60" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "16.0 05.5 05.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "16.0 04.5 07.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Water: the light falls by one for every cell below the top of the water, from the surface (the sea floor) up.
*>   Column (9, 9) of the row: stone 0 to 3, water 4 to 9 (state 310, a fluid, not opaque).
     MOVE 1 TO ST-FLUID(WS-WATER + 1)
     MOVE 0 TO ST-OPAQUE(WS-WATER + 1)
     PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 3
         COMPUTE CE-STATE(WS-LY * 256 + 9 * 16 + 9 + 1) = 2
     END-PERFORM
     PERFORM VARYING WS-LY FROM 4 BY 1 UNTIL WS-LY > 9
         COMPUTE CE-STATE(WS-LY * 256 + 9 * 16 + 9 + 1) = 310
     END-PERFORM
     MOVE 0 TO WR-SURF-OK(WS-ROW)
     MOVE SPACES TO TL-OBSERVED
     MOVE "sky-stopgap given water over a sea floor when the light of the cells is asked then it is 0 in the stone, "
         & "14 in the water's top cell, 15 above the water" TO TL-CASE
     MOVE "00 14 15" TO TL-EXPECTED
     PERFORM VARYING WS-LY FROM 3 BY 6 UNTIL WS-LY > 15
         MOVE 0 TO WS-LIGHT
         MOVE 9 TO WS-BX WS-BZ
         CALL "SKY-STOPGAP-LIGHT" USING CLIENT-STATE WS-ROW WS-BX WS-LY WS-BZ WS-LIGHT
         MOVE WS-LIGHT TO WS-LEVEL-E
         STRING FUNCTION TRIM(TL-OBSERVED) " " WS-LEVEL-E DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LIGHT
     MOVE 4 TO WS-BY
     MOVE 9 TO WS-BX WS-BZ
     CALL "SKY-STOPGAP-LIGHT" USING CLIENT-STATE WS-ROW WS-BX WS-BY WS-BZ WS-LIGHT
     MOVE WS-LIGHT TO WS-LEVEL-E
     MOVE "sky-stopgap given water 6 cells deep over the sea floor when the floor cell's light is asked then it is 9"
         TO TL-CASE
     MOVE "09" TO TL-EXPECTED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Water far deeper than 15: the light is not below 0.
     MOVE 0 TO WS-LIGHT
     MOVE 9 TO WS-BX WS-BZ
     CALL "SKY-STOPGAP-LIGHT" USING CLIENT-STATE WS-ROW WS-BX WS-ONE WS-BZ WS-LIGHT
     MOVE WS-LIGHT TO WS-LEVEL-E
     MOVE "sky-stopgap given a cell under stone when asked then it is 0" TO TL-CASE
     MOVE "00" TO TL-EXPECTED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WR-WTOP(WS-ROW, 154)
     MOVE 0 TO WR-SURF(WS-ROW, 154)
     MOVE 0 TO WS-LIGHT
     MOVE 20 TO WS-BY
     CALL "SKY-STOPGAP-LIGHT" USING CLIENT-STATE WS-ROW WS-BX WS-BY WS-BZ WS-LIGHT
     MOVE WS-LIGHT TO WS-LEVEL-E
     MOVE "sky-stopgap given 20 cells of water above a cell when asked then the light is 0, not negative" TO TL-CASE
     MOVE "00" TO TL-EXPECTED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The fluid mesher reads its cells through MF-AT: the same assumed light (water cell 14, the cell above the water 15).
     MOVE 0 TO WR-SURF-OK(WS-ROW)
     MOVE 9 TO WS-BX WS-BZ
     MOVE 9 TO WS-BY
     CALL "MF-AT" USING CLIENT-STATE WS-ROW WS-HEIGHT WS-BX WS-BY WS-BZ WS-STATE WS-SKY WS-BLOCK
     MOVE WS-SKY TO WS-LEVEL-E
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     MOVE 12 TO WS-BY
     CALL "MF-AT" USING CLIENT-STATE WS-ROW WS-HEIGHT WS-BX WS-BY WS-BZ WS-STATE WS-SKY WS-BLOCK
     MOVE WS-SKY TO WS-LEVEL-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " WS-LEVEL-E DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "sky-stopgap given water in a column when the fluid mesher reads the water cell and the cell above it "
         & "then their sky light is 14 and 15" TO TL-CASE
     MOVE "14 15" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Entities and the rest read WORLD-CELL: the assumed light there too, the stored light where there is any.
     MOVE 0 TO WR-SURF-OK(WS-ROW)
     MOVE 1 TO WS-BX
     MOVE 12 TO WS-BY
     MOVE 1 TO WS-BZ
     CALL "WORLD-CELL" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STATE WS-SKY WS-BLOCK
     MOVE WS-SKY TO WS-LEVEL-E
     MOVE "sky-stopgap given a cell above the surface when WORLD-CELL is asked then its sky light is the assumed 15"
         TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-BY
     CALL "WORLD-CELL" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STATE WS-SKY WS-BLOCK
     MOVE WS-SKY TO WS-LEVEL-E
     MOVE "sky-stopgap given a cell inside the stone when WORLD-CELL is asked then its sky light is the assumed 0" TO TL-CASE
     MOVE "00" TO TL-EXPECTED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-HAS-SKY
     MOVE 12 TO WS-BY
     CALL "WORLD-CELL" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STATE WS-SKY WS-BLOCK
     MOVE WS-SKY TO WS-LEVEL-E
     MOVE "sky-stopgap given a dimension without sky light when WORLD-CELL is asked then the stored 0 stays" TO TL-CASE
     MOVE "00" TO TL-EXPECTED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-HAS-SKY
     CALL "TEST-LIGHT" USING CLIENT-STATE WS-ROW "0 01 12 01 07"
     CALL "WORLD-CELL" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STATE WS-SKY WS-BLOCK
     MOVE WS-SKY TO WS-LEVEL-E
     MOVE "sky-stopgap given real sky light in the section when WORLD-CELL is asked then the stored 7 is returned"
         TO TL-CASE
     MOVE "07" TO TL-EXPECTED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-BX
     MOVE 3 TO WS-BZ
     MOVE 40 TO WS-BY
     CALL "WORLD-CELL" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STATE WS-SKY WS-BLOCK
     MOVE WS-SKY TO WS-LEVEL-E
     MOVE "sky-stopgap given a cell in an all-air section above the blocks when WORLD-CELL is asked then it is 15"
         TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     MOVE WS-LEVEL-E TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SKY-STOPGAP.

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
