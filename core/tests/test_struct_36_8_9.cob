*> Acceptance test of the end city template piece's connection arithmetic (docs/protocol/36-structures-8-nether-and-end.md section 9.2 and the vectors of 12.1 to 12.3; core/src/struct-endcity.cob
*> ENDCITY-ADD, ENDCITY-HOUSE): newPos = parent position + the offset turned by the parent's rotation, the box from the template size turned by the piece's own rotation, the house of 12.1 for none and
*> clockwise 90, the tower of 12.2 and the bridge of 12.3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTEC.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-OW                  BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROOF                BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   12.1 rotation none
     MOVE 100 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 200 TO WS-Z
     MOVE 0 TO WS-ROT
     CALL "ENDCITY-HOUSE" USING WS-X WS-Y WS-Z WS-ROT
     MOVE 0 TO WS-BAD
     IF EP-NAME(1) NOT = "base_floor" OR EP-X(1) NOT = 100 OR EP-Y(1) NOT = 60 OR EP-Z(1) NOT = 200
         OR EP-X0(1) NOT = 100 OR EP-Y0(1) NOT = 60 OR EP-Z0(1) NOT = 200 OR EP-X1(1) NOT = 109 OR EP-Y1(1) NOT = 63 OR EP-Z1(1) NOT = 209
         ADD 1 TO WS-BAD
     END-IF
     IF EP-NAME(2) NOT = "second_floor_1" OR EP-X(2) NOT = 99 OR EP-Y(2) NOT = 60 OR EP-Z(2) NOT = 199
         OR EP-X0(2) NOT = 99 OR EP-Z0(2) NOT = 199 OR EP-X1(2) NOT = 110 OR EP-Y1(2) NOT = 67 OR EP-Z1(2) NOT = 210
         ADD 1 TO WS-BAD
     END-IF
     IF EP-NAME(3) NOT = "third_floor_1" OR EP-X(3) NOT = 98 OR EP-Y(3) NOT = 64 OR EP-Z(3) NOT = 198
         OR EP-X0(3) NOT = 98 OR EP-Z0(3) NOT = 198 OR EP-X1(3) NOT = 111 OR EP-Y1(3) NOT = 71 OR EP-Z1(3) NOT = 211
         ADD 1 TO WS-BAD
     END-IF
     IF EP-NAME(4) NOT = "third_roof" OR EP-X(4) NOT = 97 OR EP-Y(4) NOT = 72 OR EP-Z(4) NOT = 197
         OR EP-X0(4) NOT = 97 OR EP-Z0(4) NOT = 197 OR EP-X1(4) NOT = 112 OR EP-Y1(4) NOT = 73 OR EP-Z1(4) NOT = 212
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: the none house of 12.1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     IF EP-OW(1) NOT = 1 OR EP-OW(2) NOT = 0 OR EP-OW(3) NOT = 0 OR EP-OW(4) NOT = 1 OR EP-GD(1) NOT = 0 OR EP-GD(4) NOT = 0
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: overwrite true for floor and roof, false for the upper floors" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   12.1 clockwise 90
     MOVE 1 TO WS-ROT
     CALL "ENDCITY-HOUSE" USING WS-X WS-Y WS-Z WS-ROT
     MOVE 0 TO WS-BAD
     IF EP-X(1) NOT = 100 OR EP-X0(1) NOT = 91 OR EP-X1(1) NOT = 100 OR EP-Z0(1) NOT = 200 OR EP-Z1(1) NOT = 209
         ADD 1 TO WS-BAD
     END-IF
     IF EP-X(2) NOT = 101 OR EP-Z(2) NOT = 199 OR EP-X0(2) NOT = 90 OR EP-X1(2) NOT = 101 OR EP-Z0(2) NOT = 199 OR EP-Z1(2) NOT = 210
         ADD 1 TO WS-BAD
     END-IF
     IF EP-X(3) NOT = 102 OR EP-Y(3) NOT = 64 OR EP-Z(3) NOT = 198 OR EP-X0(3) NOT = 89 OR EP-X1(3) NOT = 102 OR EP-Z1(3) NOT = 211
         ADD 1 TO WS-BAD
     END-IF
     IF EP-X(4) NOT = 103 OR EP-Y(4) NOT = 72 OR EP-Z(4) NOT = 197 OR EP-X0(4) NOT = 88 OR EP-X1(4) NOT = 103 OR EP-Z1(4) NOT = 212
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: the clockwise 90 house of 12.1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   12.2 a tower on the none house, built by ENDCITY-ADD with draws of 0
     MOVE 0 TO WS-ROT
     CALL "ENDCITY-HOUSE" USING WS-X WS-Y WS-Z WS-ROT
     MOVE 4 TO WS-ROOF
     MOVE 0 TO EC-COUNT
     MOVE 4 TO EC-COUNT
     MOVE "tower_base" TO WS-NAME
     MOVE 3 TO WS-PX
     MOVE -3 TO WS-PY
     MOVE 3 TO WS-PZ
     CALL "ENDCITY-ADD" USING WS-NAME WS-ROOF WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-BASE
     MOVE "tower_piece" TO WS-NAME
     MOVE 0 TO WS-PX WS-PZ
     MOVE 7 TO WS-PY
     CALL "ENDCITY-ADD" USING WS-NAME WS-BASE WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-P1
     MOVE 4 TO WS-PY
     CALL "ENDCITY-ADD" USING WS-NAME WS-P1 WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-P2
     MOVE "tower_top" TO WS-NAME
     MOVE -1 TO WS-PX WS-PZ
     CALL "ENDCITY-ADD" USING WS-NAME WS-P2 WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-TOP
     MOVE 0 TO WS-BAD
     IF EP-X(WS-BASE) NOT = 100 OR EP-Y(WS-BASE) NOT = 69 OR EP-Z(WS-BASE) NOT = 200 OR EP-X1(WS-BASE) NOT = 106 OR EP-Y1(WS-BASE) NOT = 75 OR EP-Z1(WS-BASE) NOT = 206
         ADD 1 TO WS-BAD
     END-IF
     IF EP-Y(WS-P1) NOT = 76 OR EP-Y1(WS-P1) NOT = 79 OR EP-Y(WS-P2) NOT = 80 OR EP-Y1(WS-P2) NOT = 83
         ADD 1 TO WS-BAD
     END-IF
     IF EP-X(WS-TOP) NOT = 99 OR EP-Y(WS-TOP) NOT = 84 OR EP-Z(WS-TOP) NOT = 199 OR EP-X1(WS-TOP) NOT = 107 OR EP-Y1(WS-TOP) NOT = 88 OR EP-Z1(WS-TOP) NOT = 207
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: the tower of 12.2 for none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   12.2 clockwise 90: only the top differs in position (101, 84, 199), and the boxes turn
     MOVE 1 TO WS-ROT
     CALL "ENDCITY-HOUSE" USING WS-X WS-Y WS-Z WS-ROT
     MOVE 4 TO EC-COUNT
     MOVE "tower_base" TO WS-NAME
     MOVE 3 TO WS-PX
     MOVE -3 TO WS-PY
     MOVE 3 TO WS-PZ
     CALL "ENDCITY-ADD" USING WS-NAME WS-ROOF WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-BASE
     MOVE "tower_piece" TO WS-NAME
     MOVE 0 TO WS-PX WS-PZ
     MOVE 7 TO WS-PY
     CALL "ENDCITY-ADD" USING WS-NAME WS-BASE WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-P1
     MOVE 4 TO WS-PY
     CALL "ENDCITY-ADD" USING WS-NAME WS-P1 WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-P2
     MOVE "tower_top" TO WS-NAME
     MOVE -1 TO WS-PX WS-PZ
     CALL "ENDCITY-ADD" USING WS-NAME WS-P2 WS-PX WS-PY WS-PZ WS-ROT WS-OW WS-TOP
     MOVE 0 TO WS-BAD
     IF EP-X(WS-BASE) NOT = 100 OR EP-Z(WS-BASE) NOT = 200 OR EP-X0(WS-BASE) NOT = 94 OR EP-X1(WS-BASE) NOT = 100
         ADD 1 TO WS-BAD
     END-IF
     IF EP-X(WS-TOP) NOT = 101 OR EP-Y(WS-TOP) NOT = 84 OR EP-Z(WS-TOP) NOT = 199 OR EP-X0(WS-TOP) NOT = 93 OR EP-X1(WS-TOP) NOT = 101 OR EP-Z1(WS-TOP) NOT = 207
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: the top of the clockwise 90 tower is turned by the last piece's rotation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-9.
