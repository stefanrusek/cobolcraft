*> Acceptance test of the nether fortress child anchors and piece catalogue (docs/protocol/36-structures-8-nether-and-end.md section 4 and the vectors of 7.1; core/src/struct-fortress.cob; T13505): the anchors of
*> the forward, left and right helpers for all four orientations, the boxes of a BridgeStraight at those anchors, the box constants of all 14 piece classes, the constructor draws of the end filler (one nextInt())
*> and the two turn pieces (nextInt(3)), and that a failed createPiece (isOkBox or a collision) draws nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ORIENT              BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-HELPER              BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-REF                 BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-BITS                BINARY-LONG VALUE 32.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BEFORE              BINARY-DOUBLE UNSIGNED.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DUMMY               BINARY-LONG.
 01 WS-DUMMY2              BINARY-LONG.
 01 WS-DUMMY3              BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
*> registry id, width, height, depth of the 14 classes (4.3)
 01 WS-SIZES.
    05 FILLER PIC X(9) VALUE "004019010".
    05 FILLER PIC X(9) VALUE "005005010".
    05 FILLER PIC X(9) VALUE "006005010".
    05 FILLER PIC X(9) VALUE "007005014".
    05 FILLER PIC X(9) VALUE "008009007".
    05 FILLER PIC X(9) VALUE "009013014".
    05 FILLER PIC X(9) VALUE "010005007".
    05 FILLER PIC X(9) VALUE "011005007".
    05 FILLER PIC X(9) VALUE "012005007".
    05 FILLER PIC X(9) VALUE "013005007".
    05 FILLER PIC X(9) VALUE "014013014".
    05 FILLER PIC X(9) VALUE "015007008".
    05 FILLER PIC X(9) VALUE "016007009".
    05 FILLER PIC X(9) VALUE "017007011".
 01 WS-SZ REDEFINES WS-SIZES.
    05 WS-S OCCURS 14 TIMES.
       10 WS-S-TYPE        PIC 999.
       10 WS-S-W           PIC 999.
       10 WS-S-H           PIC 999.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   7.1: the start (2, 64, 2) to (20, 73, 20) facing north
     CALL "SPB-RESET"
     MOVE 18 TO WS-TYPE
     MOVE 2 TO WS-ORIENT
     MOVE 2 TO B-X0 B-Z0
     MOVE 64 TO B-Y0
     MOVE 20 TO B-X1 B-Z1
     MOVE 73 TO B-Y1
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEPTH WS-ZERO WS-BOX WS-ROW
     MOVE 1 TO WS-HELPER
     MOVE 8 TO WS-P
     MOVE 3 TO WS-Q
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: north start, forward child at (10, 67, 1) facing north" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AX NOT = 10 OR WS-AY NOT = 67 OR WS-AZ NOT = 1 OR WS-DIR NOT = 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-HELPER
     MOVE 3 TO WS-P
     MOVE 8 TO WS-Q
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: north start, left child at (1, 67, 10) facing west" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AX NOT = 1 OR WS-AY NOT = 67 OR WS-AZ NOT = 10 OR WS-DIR NOT = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-HELPER
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: north start, right child at (21, 67, 10) facing east" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AX NOT = 21 OR WS-AY NOT = 67 OR WS-AZ NOT = 10 OR WS-DIR NOT = 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the three bridge straights of 7.1 (18.1 item 5)
     MOVE 6 TO WS-TYPE
     MOVE "N" TO TL-MODE
     MOVE 10 TO WS-AX
     MOVE 67 TO WS-AY
     MOVE 1 TO WS-AZ
     MOVE 2 TO WS-DIR
     CALL "FORT-MAKE" USING WS-TYPE WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CHILD
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: a straight at (10, 67, 1) north is (9, 64, -17) to (13, 73, 1)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-X0(WS-CHILD) NOT = 9 OR SP-Y0(WS-CHILD) NOT = 64 OR SP-Z0(WS-CHILD) NOT = -17 OR SP-X1(WS-CHILD) NOT = 13
         OR SP-Y1(WS-CHILD) NOT = 73 OR SP-Z1(WS-CHILD) NOT = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   its own forward child: (10, 67, -18) facing north
     MOVE 1 TO WS-HELPER
     MOVE 1 TO WS-P
     MOVE 3 TO WS-Q
     CALL "FORT-ANCHOR" USING WS-HELPER WS-CHILD WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: the straight's forward child is at (10, 67, -18) north" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-AX NOT = 10 OR WS-AY NOT = 67 OR WS-AZ NOT = -18 OR WS-DIR NOT = 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-AX
     MOVE 67 TO WS-AY
     MOVE 10 TO WS-AZ
     MOVE 1 TO WS-DIR
     CALL "FORT-MAKE" USING WS-TYPE WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CHILD
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: a straight at (1, 67, 10) west is (-17, 64, 9) to (1, 73, 13)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-X0(WS-CHILD) NOT = -17 OR SP-Y0(WS-CHILD) NOT = 64 OR SP-Z0(WS-CHILD) NOT = 9 OR SP-X1(WS-CHILD) NOT = 1
         OR SP-Y1(WS-CHILD) NOT = 73 OR SP-Z1(WS-CHILD) NOT = 13
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 21 TO WS-AX
     MOVE 67 TO WS-AY
     MOVE 10 TO WS-AZ
     MOVE 3 TO WS-DIR
     CALL "FORT-MAKE" USING WS-TYPE WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CHILD
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: a straight at (21, 67, 10) east is (21, 64, 9) to (39, 73, 13)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-X0(WS-CHILD) NOT = 21 OR SP-Y0(WS-CHILD) NOT = 64 OR SP-Z0(WS-CHILD) NOT = 9 OR SP-X1(WS-CHILD) NOT = 39
         OR SP-Y1(WS-CHILD) NOT = 73 OR SP-Z1(WS-CHILD) NOT = 13
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the same start facing east: forward (21, 67, 10) east, left (10, 67, 1) north, right (10, 67, 21) south
     CALL "SPB-RESET"
     MOVE 3 TO WS-ORIENT
     MOVE 18 TO WS-TYPE
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEPTH WS-ZERO WS-BOX WS-ROW
     MOVE 0 TO WS-BAD
     MOVE 1 TO WS-HELPER
     MOVE 8 TO WS-P
     MOVE 3 TO WS-Q
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     IF WS-AX NOT = 21 OR WS-AY NOT = 67 OR WS-AZ NOT = 10 OR WS-DIR NOT = 3
         ADD 1 TO WS-BAD
     END-IF
     MOVE 2 TO WS-HELPER
     MOVE 3 TO WS-P
     MOVE 8 TO WS-Q
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     IF WS-AX NOT = 10 OR WS-AY NOT = 67 OR WS-AZ NOT = 1 OR WS-DIR NOT = 2
         ADD 1 TO WS-BAD
     END-IF
     MOVE 3 TO WS-HELPER
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     IF WS-AX NOT = 10 OR WS-AY NOT = 67 OR WS-AZ NOT = 21 OR WS-DIR NOT = 0
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: the east start's forward, left and right anchors" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   south and west starts: forward at maxZ + 1 and minX - 1, left of a south start west of it, right of a west start south of it
     CALL "SPB-RESET"
     MOVE 0 TO WS-ORIENT
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEPTH WS-ZERO WS-BOX WS-ROW
     MOVE 0 TO WS-BAD
     MOVE 1 TO WS-HELPER
     MOVE 8 TO WS-P
     MOVE 3 TO WS-Q
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     IF WS-AX NOT = 10 OR WS-AY NOT = 67 OR WS-AZ NOT = 21 OR WS-DIR NOT = 0
         ADD 1 TO WS-BAD
     END-IF
     MOVE 2 TO WS-HELPER
     MOVE 3 TO WS-P
     MOVE 8 TO WS-Q
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     IF WS-AX NOT = 1 OR WS-AZ NOT = 10 OR WS-DIR NOT = 1
         ADD 1 TO WS-BAD
     END-IF
     MOVE 3 TO WS-HELPER
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     IF WS-AX NOT = 21 OR WS-AZ NOT = 10 OR WS-DIR NOT = 3
         ADD 1 TO WS-BAD
     END-IF
     CALL "SPB-RESET"
     MOVE 1 TO WS-ORIENT
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEPTH WS-ZERO WS-BOX WS-ROW
     MOVE 1 TO WS-HELPER
     MOVE 8 TO WS-P
     MOVE 3 TO WS-Q
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     IF WS-AX NOT = 1 OR WS-AY NOT = 67 OR WS-AZ NOT = 10 OR WS-DIR NOT = 1
         ADD 1 TO WS-BAD
     END-IF
     MOVE 2 TO WS-HELPER
     MOVE 3 TO WS-P
     MOVE 8 TO WS-Q
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     IF WS-AX NOT = 10 OR WS-AZ NOT = 1 OR WS-DIR NOT = 2
         ADD 1 TO WS-BAD
     END-IF
     MOVE 3 TO WS-HELPER
     CALL "FORT-ANCHOR" USING WS-HELPER WS-ROW WS-P WS-Q WS-AX WS-AY WS-AZ WS-DIR
     IF WS-AX NOT = 10 OR WS-AZ NOT = 21 OR WS-DIR NOT = 0
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: the south and west starts' anchors" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the box constants of the 14 classes (facing south at (100, 70, 100): width x height x depth)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         CALL "SPB-RESET"
         MOVE WS-S-TYPE(WS-I) TO WS-TYPE
         MOVE 100 TO WS-AX
         MOVE 70 TO WS-AY
         MOVE 100 TO WS-AZ
         MOVE 0 TO WS-DIR
         CALL "FORT-MAKE" USING WS-TYPE WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CHILD
         IF WS-CHILD NOT = 1
             ADD 1 TO WS-BAD
         ELSE
             COMPUTE WS-W = SP-X1(1) - SP-X0(1) + 1
             COMPUTE WS-H = SP-Y1(1) - SP-Y0(1) + 1
             COMPUTE WS-D = SP-Z1(1) - SP-Z0(1) + 1
             IF WS-W NOT = WS-S-W(WS-I) OR WS-H NOT = WS-S-H(WS-I) OR SP-TYPE(1) NOT = WS-S-TYPE(WS-I)
                 ADD 1 TO WS-BAD
             END-IF
             CALL "FORT-SIZE" USING WS-TYPE WS-OX WS-OY WS-OZ WS-DUMMY WS-DUMMY2 WS-DUMMY3
             IF SP-X0(1) NOT = 100 + WS-OX OR SP-Y0(1) NOT = 70 + WS-OY OR SP-Z0(1) NOT = 100
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: the 14 classes have the offsets and sizes of the catalogue" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the constructor draws: a filler draws one nextInt() and keeps it, a turn piece draws nextInt(3)
     CALL "SPB-RESET"
     MOVE 5 TO WS-TYPE
     MOVE 0 TO WS-DIR
     MOVE 100 TO WS-AX
     MOVE 70 TO WS-AY
     MOVE 100 TO WS-AZ
     MOVE 12345 TO SP-RNG
     MOVE SP-RNG TO WS-REF
     CALL "JRAND-NEXT" USING WS-REF WS-BITS WS-SEED
     CALL "FORT-MAKE" USING WS-TYPE WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CHILD
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: a bridge end filler draws one nextInt() and keeps it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-RNG NOT = WS-REF OR SP-F1(WS-CHILD) NOT = WS-SEED
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 11 BY 2 UNTIL WS-I > 13
         CALL "SPB-RESET"
         MOVE WS-I TO WS-TYPE
         MOVE 777 TO SP-RNG
         MOVE SP-RNG TO WS-REF
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-THREE WS-DRAW
         CALL "FORT-MAKE" USING WS-TYPE WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CHILD
         IF SP-RNG NOT = WS-REF OR SP-F1(WS-CHILD) NOT = WS-DRAW
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: the two turn pieces draw nextInt(3) for their chest" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a failed createPiece draws nothing: below y 11, and over an existing piece
     CALL "SPB-RESET"
     MOVE 5 TO WS-TYPE
     MOVE 5 TO WS-AY
     MOVE SP-RNG TO WS-BEFORE
     CALL "FORT-MAKE" USING WS-TYPE WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CHILD
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: a box not above y 10 fails and draws nothing" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE SP-RNG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-AY
     CALL "FORT-MAKE" USING WS-TYPE WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CHILD
     MOVE SP-RNG TO WS-BEFORE
     CALL "FORT-MAKE" USING WS-TYPE WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-CHILD
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: a box over an existing piece fails and draws nothing" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE SP-RNG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§4 A. Child anchors and the piece catalogue: the failed piece is not in the builder" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-4.
