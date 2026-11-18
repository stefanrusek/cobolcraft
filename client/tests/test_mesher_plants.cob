*> Implementation test of the light a mesh face reads from a cell that lets light through (lane bugblack; the black squares of the try14 screenshots were faces at the 0.10 floor,
*> 0.1 x the grass colour: faces whose looked-into cell read sky 0 and block 0). A greystone column under a cell of lucite (state 12, not opaque: a stand-in for a plant or a path
*> cell): the top face of the column and the side face of a neighbouring column that look into the lucite cell are lit by the open sky (1.00 on top, 0.60 on a side, whose fixed shade is 0.6), whether the core stored the sky light of
*> that cell as 0 (the client's stopgap assumes 15 above the column's surface) or as the 15 the core stores now (light.cob LIGHT-SKY by the dampening of the cells); a stored 14 (a leaf
*> above it) is used as it is, 14 / 15.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-PLANTS.
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
 01 WS-LY                  BINARY-LONG.
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
*>   Greystone (state 2) columns y 0 to 9 at (1, 1) and (2, 1), the second one with a block at y 10 as well; a lucite cell (state 12) at (1, 10, 1), beside it.
     PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 9
         COMPUTE CE-STATE(WS-LY * 256 + 1 * 16 + 1 + 1) = 2
         COMPUTE CE-STATE(WS-LY * 256 + 1 * 16 + 2 + 1) = 2
     END-PERFORM
     COMPUTE CE-STATE(10 * 256 + 1 * 16 + 2 + 1) = 2
     COMPUTE CE-STATE(10 * 256 + 1 * 16 + 1 + 1) = 12
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE

     MOVE "T" TO TL-MODE
     MOVE "mesher-plants given a lucite cell above a column and no sky light data when meshed then the top face of the "
         & "column and the side face of its neighbour that look into the cell are lit (1.00 on top, 0.60 on the side with its fixed side shade), not the 0.10 floor" TO TL-CASE
     MOVE "1.00 0.60" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 10.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "02.0 10.5 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The sky light as the core stores it now: 15 in the cell of the plant.
     CALL "TEST-LIGHT" USING CLIENT-STATE WS-ROW "0 01 10 01 15"
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE "mesher-plants given the sky light 15 stored in the lucite cell when meshed then the faces are 1.00 and 0.60" TO TL-CASE
     MOVE "1.00 0.60" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 10.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "02.0 10.5 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Under a leaf the core stores 14: used as it is.
     CALL "TEST-LIGHT" USING CLIENT-STATE WS-ROW "0 01 10 01 14"
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE "mesher-plants given the sky light 14 stored in the lucite cell when meshed then the faces are 14 / 15 = 0.93 and 0.56"
         TO TL-CASE
     MOVE "0.93 0.56" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "01.5 10.0 01.5 0" TL-OBSERVED
     CALL "TEST-FACE" USING CLIENT-STATE WS-ROW "02.0 10.5 01.5 0" TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MESHER-PLANTS.

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
