*> Test of the R4 block shapes of docs/protocol/51-block-shapes.md section 3.8 and rules R-E5, R-E25, R-E26 against the real content set: the rows of
*> content/tests/fixtures/shapes_r4.txt ("block|constraint|constraint|C, O or I|boxes", boxes in thousandths of a pixel) come from the independent model
*> content/tests/fixtures/gen_shapes_r4.py, written from the document's authored boxes and the turn formulas of its section 2. The observed
*> shape of the first state that holds the constraints is compared as a sorted list of boxes (a decomposition that differs is a different row).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-SHAPES-R4.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT ROWS-FILE ASSIGN TO "content/tests/fixtures/shapes_r4.txt"
         ORGANIZATION IS LINE SEQUENTIAL
         FILE STATUS IS WS-FS.
 DATA DIVISION.
 FILE SECTION.
 FD ROWS-FILE.
 01 ROWS-RECORD             PIC X(1000).
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTBSHAPE.
 01 WS-FS                   PIC XX.
 01 WS-STATE                BINARY-LONG.
 01 WS-ID                   BINARY-LONG.
 01 WS-KEY                  PIC X(40).
 01 WS-P1                   PIC X(80).
 01 WS-P2                   PIC X(80).
 01 WS-P3                   PIC X(80).
 01 WS-WHICH                PIC X.
 01 WS-EXPECT               PIC X(1024).
 01 WS-SEEN                 BINARY-LONG VALUE 0.
 01 WS-STABLE               PIC X(200).
 01 WS-NAME                 PIC X(240).
 01 WS-FEET                 FLOAT-LONG.
 01 WS-DESC                 BINARY-LONG.
 01 WS-CELL-Y               BINARY-LONG VALUE 11.
 PROCEDURE DIVISION.
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     CALL "BSH-BUILD"
     MOVE "R4 shapes: the standard set is ready" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BSH-READY TO TL-OBSERVED-N
     PERFORM ASSERT-N
     OPEN INPUT ROWS-FILE
     MOVE "R4 shapes: the fixture opens" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FS TO TL-OBSERVED-N
     PERFORM ASSERT-N
     PERFORM UNTIL WS-FS NOT = "00"
         READ ROWS-FILE
             AT END
                 MOVE "10" TO WS-FS
             NOT AT END
                 PERFORM CHECK-ROW
         END-READ
     END-PERFORM
     CLOSE ROWS-FILE
     MOVE "R4 shapes: the fixture has its 232 rows" TO TL-CASE
     MOVE 232 TO TL-EXPECTED-N
     MOVE WS-SEEN TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   Scaffolding (51 section 3.8.5, rule R-C20): the collision depends on the entity. Stable = the top slab and four posts, Plate = (0,0,0,16,2,16).
*>   With the empty context (no entity) the answer is Stable. The cell is at y 11 here.
     MOVE "|0,14000,0,16000,16000,16000;0,0,0,2000,16000,2000;14000,0,0,16000,16000,2000;14000,0,14000,16000,16000,16000;0,0,14000,2000,16000,16000" TO WS-STABLE
     MOVE "scaffolding" TO WS-KEY
     MOVE "distance=0" TO WS-P1
     MOVE "bottom=false" TO WS-P2
     MOVE SPACES TO WS-P3
     CALL "BSH-TEST-FIND" USING WS-KEY WS-P1 WS-P2 WS-P3 WS-STATE
     MOVE 12.0 TO WS-FEET
     MOVE 0 TO WS-DESC
     MOVE "R4 scaffolding distance 0: a walking entity on top stands on the stable shape" TO WS-NAME
     PERFORM CHECK-STABLE
     MOVE 1 TO WS-DESC
     MOVE "R4 scaffolding distance 0: a sneaking entity on top falls through (no plate at distance 0)" TO WS-NAME
     PERFORM CHECK-EMPTY
     MOVE 0 TO WS-DESC
     MOVE 11.5 TO WS-FEET
     MOVE "R4 scaffolding distance 0: an entity inside the cell (not above the top) meets nothing" TO WS-NAME
     PERFORM CHECK-EMPTY
     MOVE 12.000001 TO WS-FEET
     MOVE "R4 scaffolding: feet 1e-6 above the top still count as above (the 1e-5 tolerance)" TO WS-NAME
     PERFORM CHECK-STABLE
     MOVE 11.99999 TO WS-FEET
     MOVE "R4 scaffolding: feet 1e-5 under the top are not above it" TO WS-NAME
     PERFORM CHECK-EMPTY
     MOVE 11.999995 TO WS-FEET
     MOVE "R4 scaffolding: feet 5e-6 under the top are above it" TO WS-NAME
     PERFORM CHECK-STABLE
     MOVE "distance=3" TO WS-P1
     MOVE "bottom=false" TO WS-P2
     CALL "BSH-TEST-FIND" USING WS-KEY WS-P1 WS-P2 WS-P3 WS-STATE
     MOVE 1 TO WS-DESC
     MOVE 12.0 TO WS-FEET
     MOVE "R4 scaffolding distance 3 without bottom: a sneaking entity falls through" TO WS-NAME
     PERFORM CHECK-EMPTY
     MOVE 0 TO WS-DESC
     MOVE "R4 scaffolding distance 3 without bottom: a walking entity on top stands on it" TO WS-NAME
     PERFORM CHECK-STABLE
     MOVE "bottom=true" TO WS-P2
     CALL "BSH-TEST-FIND" USING WS-KEY WS-P1 WS-P2 WS-P3 WS-STATE
     MOVE 1 TO WS-DESC
     MOVE "R4 scaffolding distance 3 bottom: a sneaking entity above the cell's own y meets the plate" TO WS-NAME
     PERFORM CHECK-PLATE
     MOVE 11.5 TO WS-FEET
     MOVE "R4 scaffolding distance 3 bottom: a sneaking entity inside the cell meets the plate" TO WS-NAME
     PERFORM CHECK-PLATE
     MOVE 10.5 TO WS-FEET
     MOVE "R4 scaffolding distance 3 bottom: an entity below the cell's own y meets nothing" TO WS-NAME
     PERFORM CHECK-EMPTY
     MOVE 0 TO WS-DESC
     MOVE 12.0 TO WS-FEET
     MOVE "R4 scaffolding distance 3 bottom: a walking entity on top stands on the stable shape" TO WS-NAME
     PERFORM CHECK-STABLE
     MOVE 11.5 TO WS-FEET
     MOVE "R4 scaffolding distance 3 bottom: a walking entity inside the cell meets the plate" TO WS-NAME
     PERFORM CHECK-PLATE
*>   The empty context has no entity: the stable shape, whatever the state's own rule (the shape table's collision).
     CALL "BSH-COLL-ID" USING WS-STATE WS-ID
     CALL "BSH-TEST-TEXT" USING WS-ID TL-OBSERVED
     CALL "BSH-TEST-SORT" USING TL-OBSERVED
     MOVE WS-STABLE(2:) TO WS-EXPECT
     CALL "BSH-TEST-SORT" USING WS-EXPECT
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE "R4 scaffolding: the collision of the table (empty context) is the stable shape" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Another block answers its own collision shape.
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-P1 WS-P2
     CALL "BSH-TEST-FIND" USING WS-KEY WS-P1 WS-P2 WS-P3 WS-STATE
     MOVE 1 TO WS-DESC
     CALL "BSH-SCAFFOLD-COLL" USING WS-STATE WS-CELL-Y WS-FEET WS-DESC WS-ID
     MOVE "R4 scaffolding rule: any other block answers its own collision shape" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-N
     GOBACK.

 CHECK-STABLE.
     CALL "BSH-SCAFFOLD-COLL" USING WS-STATE WS-CELL-Y WS-FEET WS-DESC WS-ID
     CALL "BSH-TEST-TEXT" USING WS-ID TL-OBSERVED
     CALL "BSH-TEST-SORT" USING TL-OBSERVED
     MOVE WS-STABLE(2:) TO WS-EXPECT
     CALL "BSH-TEST-SORT" USING WS-EXPECT
     PERFORM ASSERT-TEXT.

 CHECK-PLATE.
     CALL "BSH-SCAFFOLD-COLL" USING WS-STATE WS-CELL-Y WS-FEET WS-DESC WS-ID
     CALL "BSH-TEST-TEXT" USING WS-ID TL-OBSERVED
     MOVE "0,0,0,16000,2000,16000" TO WS-EXPECT
     PERFORM ASSERT-TEXT.

 CHECK-EMPTY.
     CALL "BSH-SCAFFOLD-COLL" USING WS-STATE WS-CELL-Y WS-FEET WS-DESC WS-ID
     CALL "BSH-TEST-TEXT" USING WS-ID TL-OBSERVED
     MOVE "-" TO WS-EXPECT
     PERFORM ASSERT-TEXT.

 ASSERT-TEXT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-ROW.
     ADD 1 TO WS-SEEN
     MOVE SPACES TO WS-KEY WS-P1 WS-P2 WS-P3 WS-EXPECT
     UNSTRING ROWS-RECORD DELIMITED BY "|" INTO WS-KEY WS-P1 WS-P2 WS-WHICH WS-EXPECT
     CALL "BSH-TEST-FIND" USING WS-KEY WS-P1 WS-P2 WS-P3 WS-STATE
     EVALUATE WS-WHICH
         WHEN "C"
             CALL "BSH-COLL-ID" USING WS-STATE WS-ID
         WHEN "I"
             MOVE BSH-INT(WS-STATE + 1) TO WS-ID
         WHEN OTHER
             CALL "BSH-OUT-ID" USING WS-STATE WS-ID
     END-EVALUATE
     CALL "BSH-TEST-TEXT" USING WS-ID TL-OBSERVED
     CALL "BSH-TEST-SORT" USING TL-OBSERVED
     MOVE SPACES TO TL-CASE
     STRING "R4 " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-P1) " " FUNCTION TRIM(WS-P2) " " WS-WHICH DELIMITED BY SIZE INTO TL-CASE
     CALL "BSH-TEST-SORT" USING WS-EXPECT
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BLOCK-SHAPES-R4.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TEST-SORT.
*> USING text (PIC X(1024)): the boxes of a shape text ("a,b,..;c,d,...") sorted as strings and joined again; "-" stays.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BOX                  PIC X(64) OCCURS 24 TIMES.
 01 WS-N                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-J                    BINARY-LONG.
 01 WS-POINTER              BINARY-LONG.
 01 WS-HOLD                 PIC X(64).
 01 WS-POS                  BINARY-LONG.
 01 WS-OUT                  PIC X(1024).
 LINKAGE SECTION.
 01 L-TEXT                  PIC X(1024).
 PROCEDURE DIVISION USING L-TEXT.
     MOVE 0 TO WS-N
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 1024 OR WS-N >= 24
         ADD 1 TO WS-N
         MOVE SPACES TO WS-BOX(WS-N)
         UNSTRING L-TEXT DELIMITED BY ";" INTO WS-BOX(WS-N) WITH POINTER WS-POINTER
         IF WS-BOX(WS-N) = SPACES
             SUBTRACT 1 FROM WS-N
             MOVE 1025 TO WS-POINTER
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > WS-N
         MOVE WS-BOX(WS-I) TO WS-HOLD
         MOVE WS-I TO WS-J
         PERFORM UNTIL WS-J < 2 OR WS-BOX(WS-J - 1) <= WS-HOLD
             MOVE WS-BOX(WS-J - 1) TO WS-BOX(WS-J)
             SUBTRACT 1 FROM WS-J
         END-PERFORM
         MOVE WS-HOLD TO WS-BOX(WS-J)
     END-PERFORM
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         IF WS-I > 1
             MOVE ";" TO WS-OUT(WS-POS:1)
             ADD 1 TO WS-POS
         END-IF
         STRING FUNCTION TRIM(WS-BOX(WS-I)) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-POS
     END-PERFORM
     MOVE WS-OUT TO L-TEXT
     GOBACK.
 END PROGRAM BSH-TEST-SORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TEST-FIND.
*> USING block key, three texts of comma separated "name=value" constraints (spaces = none), state out: the first state of the block
*> that holds them all.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTPROPS.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(359).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 FILLER              PIC X(451).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-STATES              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-LIST                PIC X(120).
 01 WS-POINTER             BINARY-LONG.
 01 WS-WANT                PIC X(40).
 01 WS-HAVE                PIC X(60).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(40).
 01 L-P1                   PIC X(80).
 01 L-P2                   PIC X(80).
 01 L-P3                   PIC X(80).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-P1 L-P2 L-P3 L-STATE.
     MOVE L-KEY TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     COMPUTE WS-FIRST = FUNCTION NUMVAL(WS-R-FIRST)
     COMPUTE WS-STATES = FUNCTION NUMVAL(WS-R-COUNT)
     MOVE SPACES TO WS-LIST
     STRING FUNCTION TRIM(L-P1) "," FUNCTION TRIM(L-P2) "," FUNCTION TRIM(L-P3) "," DELIMITED BY SIZE INTO WS-LIST
     MOVE WS-FIRST TO L-STATE
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-STATES OR WS-OK = 1
         COMPUTE WS-STATE = WS-FIRST + WS-I
         CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
         MOVE 1 TO WS-OK
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL WS-POINTER > 120
             MOVE SPACES TO WS-WANT
             UNSTRING WS-LIST DELIMITED BY "," INTO WS-WANT WITH POINTER WS-POINTER
             IF WS-WANT NOT = SPACES
                 MOVE 0 TO WS-HAS
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CTP-COUNT
                     MOVE SPACES TO WS-HAVE
                     STRING FUNCTION TRIM(CTP-NAME(WS-J)) "=" FUNCTION TRIM(CTP-VALUE(WS-J)) DELIMITED BY SIZE INTO WS-HAVE
                     IF WS-HAVE = WS-WANT
                         MOVE 1 TO WS-HAS
                     END-IF
                 END-PERFORM
                 IF WS-HAS = 0
                     MOVE 0 TO WS-OK
                 END-IF
             END-IF
         END-PERFORM
         IF WS-OK = 1
             MOVE WS-STATE TO L-STATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-TEST-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TEST-TEXT.
*> USING shape id, text out (PIC X(1024)): "x1,y1,z1,x2,y2,z2" per box, joined by ";"; "-" for the empty shape.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-NUMBER              PIC -(8)9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-POS
     IF BSH-N(L-ID + 1) = 0
         MOVE "-" TO L-TEXT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSH-N(L-ID + 1)
         IF WS-I > 1
             MOVE ";" TO L-TEXT(WS-POS:1)
             ADD 1 TO WS-POS
         END-IF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             IF WS-K > 1
                 MOVE "," TO L-TEXT(WS-POS:1)
                 ADD 1 TO WS-POS
             END-IF
             MOVE BSH-V(L-ID + 1, WS-I, WS-K) TO WS-NUMBER
             STRING FUNCTION TRIM(WS-NUMBER) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POS
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-TEST-TEXT.
