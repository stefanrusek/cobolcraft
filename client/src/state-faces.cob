*> The face classes of the state tables (12: Block.shouldRenderFace hides a face when the neighbour's face shape covers it; 51 block
*> shapes). A face of a state is a 16 x 16 mask of the sixteenths of the cell's side that its outline shape (the occlusion shape of
*> a state that occludes by shape) touches; equal masks share a class (CLFACES.cpy, at most ST-CMAX). STATE-TABLES-BUILD stores the
*> classes per state, and STATE-FACES-MATRIX the table of which class hides which, so the mesher decides a face with table reads.
*>   STATE-FACES-INIT      no parameters: class 1 = the whole face, class 2 = no part of it; no shape done.
*>   STATE-FACES-GRID      USING shape id, direction (DIR-*), mode (1 the sixteenths the boxes cover wholly, 2 the ones they touch),
*>                         mask out (PIC X(256)).
*>   STATE-FACES-CLASS     USING mask, class out: the class of the mask, a new one when it is not known.
*>   STATE-FACES-SHAPE     USING shape id: SF-OWN and SF-NB of its six faces (own: the touched sixteenths, the whole face when none;
*>                         nb: the wholly covered ones).
*>   STATE-FACES-MATRIX    USING CLIENT-STATE: ST-COVER from the classes: class nb hides class own when nb has a part and every
*>                         sixteenth of own is in nb; a face whose class does not fit the table (ST-CMAX, the catch-all) is hidden
*>                         by the whole face only.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-FACES-INIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLFACES.
 01 WS-S                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO SF-COUNT
     MOVE ALL "1" TO SF-MASK(1)
     MOVE ALL "0" TO SF-MASK(2)
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 2000
         MOVE 0 TO SF-DONE(WS-S)
     END-PERFORM
     GOBACK.
 END PROGRAM STATE-FACES-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-FACES-GRID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
*> Per direction: the index of the box value that must sit on the cell's side (1 x1, 2 y1, 3 z1, 4 x2, 5 y2, 6 z2), 1 when that value
*> is 16000 (else 0), the indices of the first and second coordinate's low and high value.
 01 WS-SIDES.
    05 FILLER PIC X(6) VALUE "201436".
    05 FILLER PIC X(6) VALUE "511436".
    05 FILLER PIC X(6) VALUE "301425".
    05 FILLER PIC X(6) VALUE "611425".
    05 FILLER PIC X(6) VALUE "103625".
    05 FILLER PIC X(6) VALUE "413625".
 01 WS-SIDE-TABLE REDEFINES WS-SIDES.
    05 WS-SIDE OCCURS 6 TIMES.
       10 WS-TOUCH-AT      PIC 9.
       10 WS-TOUCH-FAR     PIC 9.
       10 WS-U1-AT         PIC 9.
       10 WS-U2-AT         PIC 9.
       10 WS-V1-AT         PIC 9.
       10 WS-V2-AT         PIC 9.
 01 WS-BOX                 BINARY-LONG.
 01 WS-TOUCH               BINARY-LONG.
 01 WS-U1                  BINARY-LONG.
 01 WS-U2                  BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-GRID                 PIC X(256).
 PROCEDURE DIVISION USING L-SHAPE L-DIR L-MODE L-GRID.
     MOVE ALL "0" TO L-GRID
     PERFORM VARYING WS-BOX FROM 1 BY 1 UNTIL WS-BOX > BSH-N(L-SHAPE + 1)
         MOVE WS-TOUCH-AT(L-DIR) TO WS-AT
         MOVE BSH-V(L-SHAPE + 1, WS-BOX, WS-AT) TO WS-TOUCH
         MOVE 0 TO WS-LIMIT
         IF WS-TOUCH-FAR(L-DIR) = 1
             MOVE 16000 TO WS-LIMIT
         END-IF
         IF WS-TOUCH = WS-LIMIT
             MOVE WS-U1-AT(L-DIR) TO WS-AT
             MOVE BSH-V(L-SHAPE + 1, WS-BOX, WS-AT) TO WS-U1
             MOVE WS-U2-AT(L-DIR) TO WS-AT
             MOVE BSH-V(L-SHAPE + 1, WS-BOX, WS-AT) TO WS-U2
             MOVE WS-V1-AT(L-DIR) TO WS-AT
             MOVE BSH-V(L-SHAPE + 1, WS-BOX, WS-AT) TO WS-V1
             MOVE WS-V2-AT(L-DIR) TO WS-AT
             MOVE BSH-V(L-SHAPE + 1, WS-BOX, WS-AT) TO WS-V2
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 15
                 PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
                     COMPUTE WS-POS = WS-J * 16 + WS-I + 1
                     IF L-MODE = 1
                         IF WS-U1 <= WS-I * 1000 AND WS-U2 >= (WS-I + 1) * 1000
                                 AND WS-V1 <= WS-J * 1000 AND WS-V2 >= (WS-J + 1) * 1000
                             MOVE "1" TO L-GRID(WS-POS:1)
                         END-IF
                     ELSE
                         IF WS-U1 < (WS-I + 1) * 1000 AND WS-U2 > WS-I * 1000
                                 AND WS-V1 < (WS-J + 1) * 1000 AND WS-V2 > WS-J * 1000
                             MOVE "1" TO L-GRID(WS-POS:1)
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STATE-FACES-GRID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-FACES-CLASS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLFACES.
 01 WS-I                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-GRID                 PIC X(256).
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING L-GRID L-CLASS.
     MOVE 0 TO L-CLASS
     COMPUTE WS-LIMIT = FUNCTION MIN(SF-COUNT, ST-CMAX - 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIMIT OR L-CLASS > 0
         IF SF-MASK(WS-I) = L-GRID
             MOVE WS-I TO L-CLASS
         END-IF
     END-PERFORM
*>   A new class; past the table the catch-all slot is written (the matrix treats it apart).
     IF L-CLASS = 0
         ADD 1 TO SF-COUNT
         COMPUTE L-CLASS = FUNCTION MIN(SF-COUNT, ST-CMAX)
         MOVE L-GRID TO SF-MASK(L-CLASS)
     END-IF
     GOBACK.
 END PROGRAM STATE-FACES-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-FACES-SHAPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLFACES.
 01 WS-D                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-GRID                PIC X(256).
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE.
     IF SF-DONE(L-SHAPE + 1) = 0
         MOVE 1 TO SF-DONE(L-SHAPE + 1)
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
             MOVE 2 TO WS-MODE
             CALL "STATE-FACES-GRID" USING L-SHAPE WS-D WS-MODE WS-GRID
             MOVE 0 TO WS-HITS
             INSPECT WS-GRID TALLYING WS-HITS FOR ALL "1"
*>           A shape that touches no part of the side is hidden only by a whole face.
             IF WS-HITS = 0
                 MOVE ALL "1" TO WS-GRID
             END-IF
             CALL "STATE-FACES-CLASS" USING WS-GRID WS-CLASS
             MOVE WS-CLASS TO SF-OWN(L-SHAPE + 1, WS-D)
             MOVE 1 TO WS-MODE
             CALL "STATE-FACES-GRID" USING L-SHAPE WS-D WS-MODE WS-GRID
             CALL "STATE-FACES-CLASS" USING WS-GRID WS-CLASS
             MOVE WS-CLASS TO SF-NB(L-SHAPE + 1, WS-D)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM STATE-FACES-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-FACES-MATRIX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLFACES.
 01 WS-N                   BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-AT FROM 1 BY 1 UNTIL WS-AT > 90000
         MOVE 0 TO ST-COVER(WS-AT)
     END-PERFORM
     COMPUTE WS-N = FUNCTION MIN(SF-COUNT, ST-CMAX - 1)
     PERFORM VARYING WS-NB FROM 1 BY 1 UNTIL WS-NB > WS-N
         MOVE 0 TO WS-HITS
         INSPECT SF-MASK(WS-NB) TALLYING WS-HITS FOR ALL "1"
         IF WS-HITS > 0
             PERFORM VARYING WS-OWN FROM 1 BY 1 UNTIL WS-OWN > WS-N
                 MOVE 1 TO WS-OK
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 256 OR WS-OK = 0
                     IF SF-MASK(WS-OWN)(WS-K:1) = "1" AND SF-MASK(WS-NB)(WS-K:1) = "0"
                         MOVE 0 TO WS-OK
                     END-IF
                 END-PERFORM
                 COMPUTE WS-AT = (WS-NB - 1) * ST-CMAX + WS-OWN
                 MOVE WS-OK TO ST-COVER(WS-AT)
             END-PERFORM
         END-IF
     END-PERFORM
*>   The catch-all own class is covered by the whole face (class 1) only.
     MOVE 1 TO ST-COVER(ST-CMAX)
     GOBACK.
 END PROGRAM STATE-FACES-MATRIX.
