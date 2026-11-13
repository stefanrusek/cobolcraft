*> Implementation test of client/src/sky-stopgap.cob (the client-side sky light stopgap, until CC-0007 builds the
*> real light engine): in a dimension with sky light, a section whose sky light data is all zero meshes with sky 15
*> at and above each column's surface and 0 below; real nonzero sky light is used as it is; stored light is not
*> changed; a dimension without sky light is not touched.
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
     MOVE "sky-stopgap given real nonzero sky light in the section when meshed then it is used as it is: 7 / 15"
         TO TL-CASE
     MOVE "0.47" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 10.0 01.5 0" TL-OBSERVED
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
