*> Acceptance test of docs/protocol/36-structures-2 sections 3 and 4.3 (coordinate transform, bounding box, zero position, palette choice):
*> the worked examples 11.1, 11.2 and 11.5, every rotation and mirror, and the palette index.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-2-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-MIRROR              BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-BOX.
    05 WS-BOX-V            BINARY-LONG OCCURS 6 TIMES.
 01 WS-ED-A                PIC -(5)9.
 01 WS-ED-B                PIC -(5)9.
 01 WS-ED-C                PIC -(5)9.
 01 WS-ED-D                PIC -(5)9.
 01 WS-ED-E                PIC -(5)9.
 01 WS-ED-F                PIC -(5)9.
 01 WS-COUNT               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-PX WS-PZ
     MOVE 3 TO WS-X
     MOVE 5 TO WS-Y
     MOVE 1 TO WS-Z
     MOVE "acceptance US12 36-2§3 Coordinate transform: block (3,5,1), clockwise 90, pivot origin: (-1,5,3)" TO TL-CASE
     MOVE 0 TO WS-MIRROR
     MOVE 1 TO WS-ROT
     PERFORM DO-TX
     MOVE "-1 5 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: counterclockwise 90: (1,5,-3)" TO TL-CASE
     MOVE 3 TO WS-ROT
     PERFORM DO-TX
     MOVE "1 5 -3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: clockwise 180: (-3,5,-1)" TO TL-CASE
     MOVE 2 TO WS-ROT
     PERFORM DO-TX
     MOVE "-3 5 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: no rotation and no mirror leave the position" TO TL-CASE
     MOVE 0 TO WS-ROT
     PERFORM DO-TX
     MOVE "3 5 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: pivot (2,0,2), clockwise 90: (3,5,3)" TO TL-CASE
     MOVE 2 TO WS-PX WS-PZ
     MOVE 1 TO WS-ROT
     PERFORM DO-TX
     MOVE "3 5 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: pivot (2,0,2), counterclockwise 90 turns offset (1,-1) into (-1,-1): (1,5,1)" TO TL-CASE
     MOVE 3 TO WS-ROT
     PERFORM DO-TX
     MOVE "1 5 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: pivot (2,0,2), clockwise 180: (1,5,3)" TO TL-CASE
     MOVE 2 TO WS-ROT
     PERFORM DO-TX
     MOVE "1 5 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-PX WS-PZ
     MOVE "acceptance US12 36-2§3 Coordinate transform: mirror left-right then clockwise 90: (1,5,3)" TO TL-CASE
     MOVE 1 TO WS-MIRROR
     MOVE 1 TO WS-ROT
     PERFORM DO-TX
     MOVE "1 5 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: mirror front-back alone: (-3,5,1)" TO TL-CASE
     MOVE 2 TO WS-MIRROR
     MOVE 0 TO WS-ROT
     PERFORM DO-TX
     MOVE "-3 5 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 36-2§3 Coordinate transform: size (5,4,3) turned a quarter is (3,4,5), a half turn keeps it" TO TL-CASE
     CALL "STRUCT-TX-SIZE" USING 5 4 3 1 WS-OX WS-OY WS-OZ
     PERFORM SHOW-OUT
     MOVE "3 4 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-TX-SIZE" USING 5 4 3 3 WS-OX WS-OY WS-OZ
     PERFORM SHOW-OUT
     MOVE "3 4 5" TO TL-EXPECTED
     MOVE "acceptance US12 36-2§3 Coordinate transform: size under counterclockwise 90" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-TX-SIZE" USING 5 4 3 2 WS-OX WS-OY WS-OZ
     PERFORM SHOW-OUT
     MOVE "5 4 3" TO TL-EXPECTED
     MOVE "acceptance US12 36-2§3 Coordinate transform: size under clockwise 180" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 36-2§3 Coordinate transform: example 11.2 box (98,64,200) to (100,67,204)" TO TL-CASE
     CALL "STRUCT-TX-BOX" USING 5 4 3 0 1 0 0 100 64 200 WS-BOX
     PERFORM SHOW-BOX
     MOVE "98 64 200 100 67 204" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: mirrored box of a template (5,4,3), no rotation, front-back" TO TL-CASE
     CALL "STRUCT-TX-BOX" USING 5 4 3 2 0 0 0 10 0 10 WS-BOX
     PERFORM SHOW-BOX
     MOVE "6 0 10 10 3 12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 36-2§3 Coordinate transform: example 11.2 zero position of (100,64,200) is (102,64,200)" TO TL-CASE
     CALL "STRUCT-ZERO-POS" USING 100 64 200 0 1 5 3 WS-OX WS-OY WS-OZ
     PERFORM SHOW-OUT
     MOVE "102 64 200" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: zero position, no rotation, no mirror" TO TL-CASE
     CALL "STRUCT-ZERO-POS" USING 100 64 200 0 0 5 3 WS-OX WS-OY WS-OZ
     PERFORM SHOW-OUT
     MOVE "100 64 200" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: zero position, front-back mirror, clockwise 180 (sx - dx = 0, sz - dz = 2)" TO TL-CASE
     CALL "STRUCT-ZERO-POS" USING 100 64 200 2 2 5 3 WS-OX WS-OY WS-OZ
     PERFORM SHOW-OUT
     MOVE "100 64 202" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: zero position, left-right mirror, counterclockwise 90 (dz, sx - dx) = (2, 4)" TO TL-CASE
     CALL "STRUCT-ZERO-POS" USING 100 64 200 1 3 5 3 WS-OX WS-OY WS-OZ
     PERFORM SHOW-OUT
     MOVE "102 64 204" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§3 Coordinate transform: zero position, front-back mirror, clockwise 90 (sz - dz, dx) = (2, 4)" TO TL-CASE
     CALL "STRUCT-ZERO-POS" USING 100 64 200 2 1 5 3 WS-OX WS-OY WS-OZ
     PERFORM SHOW-OUT
     MOVE "102 64 204" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 36-2§4 Placement settings: example 11.5 four palettes at (10,64,10) choose palette 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "STRUCT-PALETTE-PICK" USING 4 10 64 10 WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§4 Placement settings: example 11.5 two palettes at (10,64,10) choose palette 0" TO TL-CASE
     CALL "STRUCT-PALETTE-PICK" USING 2 10 64 10 WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§4 Placement settings: the same origin always gives the same palette" TO TL-CASE
     CALL "STRUCT-PALETTE-PICK" USING 4 10 64 10 WS-COUNT
     COMPUTE TL-OBSERVED-N = WS-COUNT - WS-INDEX + 1
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-2§4 Placement settings: no palettes gives -1 (an error in the game; the caller exits first)" TO TL-CASE
     CALL "STRUCT-PALETTE-PICK" USING 0 10 64 10 WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 DO-TX.
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-MIRROR WS-ROT WS-PX WS-PZ WS-OX WS-OY WS-OZ
     PERFORM SHOW-OUT.

 SHOW-OUT.
     MOVE WS-OX TO WS-ED-A
     MOVE WS-OY TO WS-ED-B
     MOVE WS-OZ TO WS-ED-C
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED-A) " " FUNCTION TRIM(WS-ED-B) " " FUNCTION TRIM(WS-ED-C) DELIMITED BY SIZE INTO TL-OBSERVED.

 SHOW-BOX.
     MOVE WS-BOX-V(1) TO WS-ED-A
     MOVE WS-BOX-V(2) TO WS-ED-B
     MOVE WS-BOX-V(3) TO WS-ED-C
     MOVE WS-BOX-V(4) TO WS-ED-D
     MOVE WS-BOX-V(5) TO WS-ED-E
     MOVE WS-BOX-V(6) TO WS-ED-F
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED-A) " " FUNCTION TRIM(WS-ED-B) " " FUNCTION TRIM(WS-ED-C) " " FUNCTION TRIM(WS-ED-D) " "
         FUNCTION TRIM(WS-ED-E) " " FUNCTION TRIM(WS-ED-F) DELIMITED BY SIZE INTO TL-OBSERVED.
