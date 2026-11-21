*> Acceptance test of docs/protocol/36-structures-1 section 6 (pieces): BoundingBox operations (6.3: constructor, intersects, inside, centre, inflate, move, union), orientBox and
*> makeBoundingBox (the vectors of 12.4), the piece-local frame (6.4: world conversions and the mirror and rotation of a direction per orientation) and the pieces builder (6.6: add,
*> first collision, vertical offset, union, moveBelowSeaLevel with and without slack, a full table, isCloseToChunk).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-B2.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-B3.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==C-==.
 01 WS-V.
    05 V1                  BINARY-LONG.
    05 V2                  BINARY-LONG.
    05 V3                  BINARY-LONG.
    05 V4                  BINARY-LONG.
    05 V5                  BINARY-LONG.
    05 V6                  BINARY-LONG.
    05 V7                  BINARY-LONG.
    05 V8                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-NEG                 BINARY-LONG VALUE -1.
 01 WS-M4                  BINARY-LONG VALUE -4.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LIT-1              BINARY-LONG.
 01 WS-LIT-2              BINARY-LONG.
 01 WS-LIT-3              BINARY-LONG.
 01 WS-LIT-4              BINARY-LONG.
 01 WS-LIT-5              BINARY-LONG.
 01 WS-LIT-6              BINARY-LONG.
 01 WS-LIT-7              BINARY-LONG.
 01 WS-LIT-8              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE

*>   orientBox (12.4)
     PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 4
         MOVE 10 TO WS-LIT-1
         MOVE 64 TO WS-LIT-2
         MOVE 20 TO WS-LIT-3
         MOVE 5 TO WS-LIT-4
         MOVE 6 TO WS-LIT-5
         MOVE 7 TO WS-LIT-6
         CALL "SPB-ORIENT-BOX" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-NEG WS-M4 WS-ZERO WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-DIR WS-BOX
         PERFORM BOX-TEXT
         EVALUATE WS-DIR
             WHEN 0
                 MOVE "acceptance US12 36-1§6 Pieces: orientBox(10,64,20, -1,-4,0, 5,6,7) south is (9,60,20)-(13,65,26)" TO TL-CASE
                 MOVE "9 60 20 13 65 26" TO TL-EXPECTED
             WHEN 1
                 MOVE "acceptance US12 36-1§6 Pieces: the same with west is (4,60,19)-(10,65,23)" TO TL-CASE
                 MOVE "4 60 19 10 65 23" TO TL-EXPECTED
             WHEN 2
                 MOVE "acceptance US12 36-1§6 Pieces: the same with north is (9,60,14)-(13,65,20)" TO TL-CASE
                 MOVE "9 60 14 13 65 20" TO TL-EXPECTED
             WHEN 3
                 MOVE "acceptance US12 36-1§6 Pieces: the same with east is (10,60,19)-(16,65,23)" TO TL-CASE
                 MOVE "10 60 19 16 65 23" TO TL-EXPECTED
             WHEN OTHER
                 MOVE "acceptance US12 36-1§6 Pieces: any other direction (up, down) takes the south row" TO TL-CASE
                 MOVE "9 60 20 13 65 26" TO TL-EXPECTED
         END-EVALUATE
         MOVE WS-TEXT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   makeBoundingBox (12.4)
     MOVE 2 TO WS-DIR
     MOVE 100 TO WS-LIT-1
     MOVE 64 TO WS-LIT-2
     MOVE 200 TO WS-LIT-3
     MOVE 10 TO WS-LIT-4
     MOVE 5 TO WS-LIT-5
     MOVE 15 TO WS-LIT-6
     CALL "SPB-MAKE-BOX" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-DIR WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-BOX
     PERFORM BOX-TEXT
     MOVE "acceptance US12 36-1§6 Pieces: makeBoundingBox(100,64,200, NORTH, 10,5,15) is (100,64,200)-(109,68,214)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "100 64 200 109 68 214" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-DIR
     MOVE 100 TO WS-LIT-1
     MOVE 64 TO WS-LIT-2
     MOVE 200 TO WS-LIT-3
     MOVE 10 TO WS-LIT-4
     MOVE 5 TO WS-LIT-5
     MOVE 15 TO WS-LIT-6
     CALL "SPB-MAKE-BOX" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-DIR WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-BOX
     PERFORM BOX-TEXT
     MOVE "acceptance US12 36-1§6 Pieces: the same with EAST is (100,64,200)-(114,68,209)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "100 64 200 114 68 209" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the constructor, the operations (6.3)
     MOVE 5 TO WS-LIT-1
     MOVE 9 TO WS-LIT-2
     MOVE 7 TO WS-LIT-3
     MOVE 1 TO WS-LIT-4
     MOVE 2 TO WS-LIT-5
     MOVE 3 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-BOX
     PERFORM BOX-TEXT
     MOVE "acceptance US12 36-1§6 Pieces: a malformed box (x1 < x0 ...) stores the per-axis min and max" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 2 3 5 9 7" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-LIT-1
     MOVE 64 TO WS-LIT-2
     MOVE 200 TO WS-LIT-3
     MOVE 109 TO WS-LIT-4
     MOVE 68 TO WS-LIT-5
     MOVE 214 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-BOX
     CALL "SPB-BOX-CENTER" USING WS-BOX WS-X WS-Y WS-Z
     PERFORM XYZ-TEXT
     MOVE "acceptance US12 36-1§6 Pieces: the centre of (100,64,200)-(109,68,214) is (105,66,207) (min + span / 2)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "105 66 207" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 110 TO WS-LIT-1
     MOVE 64 TO WS-LIT-2
     MOVE 200 TO WS-LIT-3
     MOVE 120 TO WS-LIT-4
     MOVE 68 TO WS-LIT-5
     MOVE 214 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-B2
     CALL "SPB-BOX-INTERSECTS" USING WS-BOX WS-B2 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: boxes one block apart do not intersect" TO TL-CASE
     PERFORM FLAG-0
     MOVE 109 TO WS-LIT-1
     MOVE 64 TO WS-LIT-2
     MOVE 200 TO WS-LIT-3
     MOVE 120 TO WS-LIT-4
     MOVE 68 TO WS-LIT-5
     MOVE 214 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-B2
     CALL "SPB-BOX-INTERSECTS" USING WS-BOX WS-B2 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: touching boxes (a shared layer) intersect" TO TL-CASE
     PERFORM FLAG-1
     MOVE 100 TO WS-LIT-1
     MOVE 69 TO WS-LIT-2
     MOVE 200 TO WS-LIT-3
     MOVE 120 TO WS-LIT-4
     MOVE 70 TO WS-LIT-5
     MOVE 214 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-B2
     CALL "SPB-BOX-INTERSECTS" USING WS-BOX WS-B2 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: a box above does not intersect in 3-D" TO TL-CASE
     PERFORM FLAG-0
     CALL "SPB-BOX-INTERSECTS-XZ" USING WS-BOX WS-B2 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: but it does on x and z only" TO TL-CASE
     PERFORM FLAG-1
     MOVE 300 TO WS-LIT-1
     MOVE 64 TO WS-LIT-2
     MOVE 200 TO WS-LIT-3
     MOVE 320 TO WS-LIT-4
     MOVE 68 TO WS-LIT-5
     MOVE 214 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-B2
     CALL "SPB-BOX-INTERSECTS-XZ" USING WS-BOX WS-B2 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: a far box does not intersect on x and z" TO TL-CASE
     PERFORM FLAG-0
     MOVE 109 TO WS-LIT-1
     MOVE 68 TO WS-LIT-2
     MOVE 214 TO WS-LIT-3
     CALL "SPB-BOX-INSIDE" USING WS-BOX WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: the maximum corner is inside (both ends inclusive)" TO TL-CASE
     PERFORM FLAG-1
     MOVE 110 TO WS-LIT-1
     MOVE 68 TO WS-LIT-2
     MOVE 214 TO WS-LIT-3
     CALL "SPB-BOX-INSIDE" USING WS-BOX WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: one past it is not" TO TL-CASE
     PERFORM FLAG-0
     MOVE WS-BOX TO WS-B2
     MOVE 12 TO WS-LIT-1
     CALL "SPB-BOX-INFLATE" USING WS-B2 WS-LIT-1
     PERFORM BOX-TEXT-2
     MOVE "acceptance US12 36-1§6 Pieces: inflatedBy(12) lowers every min and raises every max by 12" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "88 52 188 121 80 226" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-BOX TO WS-B2
     MOVE 1 TO WS-LIT-1
     MOVE -2 TO WS-LIT-2
     MOVE 3 TO WS-LIT-3
     CALL "SPB-BOX-MOVE" USING WS-B2 WS-LIT-1 WS-LIT-2 WS-LIT-3
     PERFORM BOX-TEXT-2
     MOVE "acceptance US12 36-1§6 Pieces: move(1, -2, 3) shifts all six values" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "101 62 203 110 66 217" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 90 TO WS-LIT-1
     MOVE 70 TO WS-LIT-2
     MOVE 210 TO WS-LIT-3
     MOVE 95 TO WS-LIT-4
     MOVE 71 TO WS-LIT-5
     MOVE 230 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-B2
     CALL "SPB-BOX-UNION" USING WS-BOX WS-B2 WS-B3
     MOVE WS-B3 TO WS-B2
     PERFORM BOX-TEXT-2
     MOVE "acceptance US12 36-1§6 Pieces: the union is the smallest box containing both" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "90 64 200 109 71 230" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the piece-local frame (6.4, 12.4)
     CALL "SPB-RESET"
     MOVE 100 TO WS-LIT-1
     MOVE 64 TO WS-LIT-2
     MOVE 200 TO WS-LIT-3
     MOVE 109 TO WS-LIT-4
     MOVE 68 TO WS-LIT-5
     MOVE 214 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-BOX
     MOVE 0 TO WS-LIT-1
     MOVE 2 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 0 TO WS-LIT-4
     CALL "SPB-ADD" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-BOX WS-ROW
     MOVE 3 TO WS-LIT-1
     MOVE 2 TO WS-LIT-2
     MOVE 4 TO WS-LIT-3
     CALL "SPB-WORLD" USING WS-ROW WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-X WS-Y WS-Z
     PERFORM XYZ-TEXT
     MOVE "acceptance US12 36-1§6 Pieces: a NORTH piece, local (3,2,4): world (103,66,210)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "103 66 210" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-LIT-1
     MOVE 64 TO WS-LIT-2
     MOVE 200 TO WS-LIT-3
     MOVE 114 TO WS-LIT-4
     MOVE 68 TO WS-LIT-5
     MOVE 209 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-BOX
     MOVE 0 TO WS-LIT-1
     MOVE 1 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 0 TO WS-LIT-4
     CALL "SPB-ADD" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-BOX WS-ROW
     MOVE 3 TO WS-LIT-1
     MOVE 2 TO WS-LIT-2
     MOVE 4 TO WS-LIT-3
     CALL "SPB-WORLD" USING WS-ROW WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-X WS-Y WS-Z
     PERFORM XYZ-TEXT
     MOVE "acceptance US12 36-1§6 Pieces: a WEST piece with box (100,64,200)-(114,68,209), local (3,2,4): world (110,66,203)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "110 66 203" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 0 TO WS-LIT-4
     CALL "SPB-ADD" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-BOX WS-ROW
     MOVE 3 TO WS-LIT-1
     MOVE 2 TO WS-LIT-2
     MOVE 4 TO WS-LIT-3
     CALL "SPB-WORLD" USING WS-ROW WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-X WS-Y WS-Z
     PERFORM XYZ-TEXT
     MOVE "acceptance US12 36-1§6 Pieces: a SOUTH piece takes minX + x, minY + y, minZ + z (103,66,204)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "103 66 204" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LIT-1
     MOVE 3 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 0 TO WS-LIT-4
     CALL "SPB-ADD" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-BOX WS-ROW
     MOVE 3 TO WS-LIT-1
     MOVE 2 TO WS-LIT-2
     MOVE 4 TO WS-LIT-3
     CALL "SPB-WORLD" USING WS-ROW WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-X WS-Y WS-Z
     PERFORM XYZ-TEXT
     MOVE "acceptance US12 36-1§6 Pieces: an EAST piece takes minX + z, minZ + x (104,66,203)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "104 66 203" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     CALL "SPB-ADD" USING WS-LIT-1 WS-NEG WS-LIT-2 WS-LIT-3 WS-BOX WS-ROW
     MOVE 3 TO WS-LIT-1
     MOVE 2 TO WS-LIT-2
     MOVE 4 TO WS-LIT-3
     CALL "SPB-WORLD" USING WS-ROW WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-X WS-Y WS-Z
     PERFORM XYZ-TEXT
     MOVE "acceptance US12 36-1§6 Pieces: a piece without orientation has no local frame: (3,2,4) stays" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "3 2 4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   mirror and rotation of a direction (6.4) for the pieces of rows 1 to 6 (north, west, south, east... see the adds above): directions n e s w as 2 3 0 1
     CALL "SPB-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1
                 MOVE 2 TO WS-DIR
             WHEN 2
                 MOVE 0 TO WS-DIR
             WHEN 3
                 MOVE 1 TO WS-DIR
             WHEN 4
                 MOVE 3 TO WS-DIR
             WHEN 5
                 MOVE -1 TO WS-DIR
         END-EVALUATE
         MOVE 0 TO WS-LIT-1
         MOVE 0 TO WS-LIT-2
         MOVE 0 TO WS-LIT-3
         CALL "SPB-ADD" USING WS-LIT-1 WS-DIR WS-LIT-2 WS-LIT-3 WS-BOX WS-ROW
     END-PERFORM
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 5
         MOVE SPACES TO WS-TEXT
         MOVE 1 TO WS-PTR
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
             COMPUTE WS-DIR = FUNCTION MOD(WS-I + 2, 4)
             CALL "SPB-DIR-XFORM" USING WS-ROW WS-DIR WS-X
             MOVE WS-X TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         END-PERFORM
         MOVE WS-TEXT TO TL-OBSERVED
         EVALUATE WS-ROW
             WHEN 1
                 MOVE "acceptance US12 36-1§6 Pieces: a north piece leaves n e s w alone" TO TL-CASE
                 MOVE "2301" TO TL-EXPECTED
             WHEN 2
                 MOVE "acceptance US12 36-1§6 Pieces: a south piece mirrors left-right (north and south swap)" TO TL-CASE
                 MOVE "0321" TO TL-EXPECTED
             WHEN 3
                 MOVE "acceptance US12 36-1§6 Pieces: a west piece mirrors then turns clockwise 90" TO TL-CASE
                 MOVE "1032" TO TL-EXPECTED
             WHEN 4
                 MOVE "acceptance US12 36-1§6 Pieces: an east piece turns clockwise 90" TO TL-CASE
                 MOVE "3012" TO TL-EXPECTED
             WHEN 5
                 MOVE "acceptance US12 36-1§6 Pieces: a piece without orientation changes nothing" TO TL-CASE
                 MOVE "2301" TO TL-EXPECTED
         END-EVALUATE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   the builder (6.6): collision order, offset, union
     CALL "SPB-RESET"
     MOVE 0 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 9 TO WS-LIT-4
     MOVE 9 TO WS-LIT-5
     MOVE 9 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-BOX
     MOVE 1 TO WS-LIT-1
     MOVE 2 TO WS-LIT-2
     MOVE 3 TO WS-LIT-3
     MOVE 0 TO WS-LIT-4
     CALL "SPB-ADD" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-BOX WS-ROW
     MOVE 20 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 29 TO WS-LIT-4
     MOVE 9 TO WS-LIT-5
     MOVE 9 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-BOX
     MOVE 2 TO WS-LIT-1
     MOVE 2 TO WS-LIT-2
     MOVE 4 TO WS-LIT-3
     MOVE 1 TO WS-LIT-4
     CALL "SPB-ADD" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-BOX WS-ROW
     MOVE 8 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 22 TO WS-LIT-4
     MOVE 9 TO WS-LIT-5
     MOVE 9 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-B2
     CALL "SPB-FIND-COLLISION" USING WS-B2 WS-ROW
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-1§6 Pieces: the first piece in list order that intersects is found" TO TL-CASE
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 15 TO WS-LIT-4
     MOVE 9 TO WS-LIT-5
     MOVE 9 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-B2
     CALL "SPB-FIND-COLLISION" USING WS-B2 WS-ROW
     MOVE "acceptance US12 36-1§6 Pieces: no collision gives 0" TO TL-CASE
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§6 Pieces: addPiece appends: two pieces, the second one's type, depth and mineshaft type are kept" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SP-COUNT * 1000 + SP-TYPE(2) * 100 + SP-DEPTH(2) * 10 + SP-MST(2)
     MOVE 2241 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     CALL "SPB-UNION-ALL" USING WS-B2
     PERFORM BOX-TEXT-2
     MOVE "acceptance US12 36-1§6 Pieces: the union of the piece boxes" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "0 0 0 29 9 9" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -5 TO WS-LIT-1
     CALL "SPB-OFFSET" USING WS-LIT-1
     MOVE SP-BOX(2) TO WS-B2
     PERFORM BOX-TEXT-2
     MOVE "acceptance US12 36-1§6 Pieces: offsetPiecesVertically moves every box by dy" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "20 -5 0 29 4 9" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   moveBelowSeaLevel (6.6): the union is y -5 to 4 (ySpan 10): top = 10 + minY + 1 = -53 for min y -64, cap = 63 - 10 = 53, slack 106; the draw is nextInt(106) of the LCG state 5 (28)
     MOVE 5 TO SP-RNG
     MOVE 63 TO WS-LIT-1
     MOVE -64 TO WS-LIT-2
     MOVE 10 TO WS-LIT-3
     CALL "SPB-MOVE-BELOW-SEA" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-ROW
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-1§6 Pieces: moveBelowSeaLevel(63, -64, 10) with slack draws nextInt(106) (28 from state 5): the structure's top is -25" TO TL-CASE
     MOVE SP-Y1(1) TO TL-OBSERVED-N
     MOVE -25 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§6 Pieces: the returned dy is the shift (-29 from the top 4)" TO TL-CASE
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE -29 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -43 TO WS-LIT-1
     MOVE -64 TO WS-LIT-2
     MOVE 10 TO WS-LIT-3
     CALL "SPB-MOVE-BELOW-SEA" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-ROW
     MOVE "acceptance US12 36-1§6 Pieces: with no slack (cap -53 = top) there is no draw: the top is ySpan + minY + 1 = -53" TO TL-CASE
     MOVE SP-Y1(1) TO TL-OBSERVED-N
     MOVE -53 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   isCloseToChunk
     CALL "SPB-RESET"
     MOVE 40 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 50 TO WS-LIT-4
     MOVE 9 TO WS-LIT-5
     MOVE 9 TO WS-LIT-6
     CALL "SPB-BOX-NEW" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-LIT-5 WS-LIT-6 WS-BOX
     MOVE 0 TO WS-LIT-1
     MOVE 2 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     MOVE 0 TO WS-LIT-4
     CALL "SPB-ADD" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-BOX WS-ROW
     MOVE 0 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 8 TO WS-LIT-3
     CALL "SPB-IS-CLOSE" USING WS-ROW WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: a box at x 40 to 50 is within margin 8 of chunk (0,0) (reaches 23)? no: 40 > 23" TO TL-CASE
     PERFORM FLAG-0
     MOVE 2 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     CALL "SPB-IS-CLOSE" USING WS-ROW WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: it is in chunk (2,0) itself (x 32 to 47, margin 0)" TO TL-CASE
     PERFORM FLAG-1
     MOVE 4 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 0 TO WS-LIT-3
     CALL "SPB-IS-CLOSE" USING WS-ROW WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: chunk (4,0) starts at x 64: out at margin 0" TO TL-CASE
     PERFORM FLAG-0
     MOVE 4 TO WS-LIT-1
     MOVE 0 TO WS-LIT-2
     MOVE 14 TO WS-LIT-3
     CALL "SPB-IS-CLOSE" USING WS-ROW WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-FLAG
     MOVE "acceptance US12 36-1§6 Pieces: and in at margin 14 (reaches 50)" TO TL-CASE
     PERFORM FLAG-1

*>   a full table drops the piece and counts it
     CALL "SPB-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1025
         MOVE 0 TO WS-LIT-1
         MOVE 2 TO WS-LIT-2
         MOVE 0 TO WS-LIT-3
         MOVE 0 TO WS-LIT-4
         CALL "SPB-ADD" USING WS-LIT-1 WS-LIT-2 WS-LIT-3 WS-LIT-4 WS-BOX WS-ROW
     END-PERFORM
     MOVE "acceptance US12 36-1§6 Pieces: a full table (1024) refuses the 1025th piece, counts it and answers row 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SP-COUNT * 10000 + SP-LOST * 10 + WS-ROW
     MOVE 10240010 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FLAG-0.
     MOVE "N" TO TL-MODE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE.
 FLAG-1.
     MOVE "N" TO TL-MODE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE.
 BOX-TEXT.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE A-X0 TO WS-X
     MOVE A-Y0 TO WS-Y
     MOVE A-Z0 TO WS-Z
     PERFORM XYZ-PART
     STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE A-X1 TO WS-X
     MOVE A-Y1 TO WS-Y
     MOVE A-Z1 TO WS-Z
     PERFORM XYZ-PART.
 BOX-TEXT-2.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE B-X0 TO WS-X
     MOVE B-Y0 TO WS-Y
     MOVE B-Z0 TO WS-Z
     PERFORM XYZ-PART
     STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE B-X1 TO WS-X
     MOVE B-Y1 TO WS-Y
     MOVE B-Z1 TO WS-Z
     PERFORM XYZ-PART.
 XYZ-TEXT.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM XYZ-PART.
 XYZ-PART.
     MOVE WS-X TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE WS-Y TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE WS-Z TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.
