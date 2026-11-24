*> Test of the woodland mansion floor plan and piece layout (docs/protocol/36-structures-7-woodland-mansion.md sections 3 to 6, 11, 12; core/src/struct-mansion.cob, struct-man-place.cob; T10500).
*> World seed 0, chunk (2, 0): the rotation draw, the base grid and the floor-0 room codes of 11.1, the first seven pieces; the validation items 1 to 7 and 9 over a grid of chunks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-MANSION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 4.
 01 WS-ROT                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIG                 PIC 9.
 01 WS-ROW                 PIC X(100).
 01 WS-WANT                PIC X(100).
 01 WS-PTR                 BINARY-LONG.
 01 WS-CELL                PIC X(8).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-NAME                PIC X(24).
 01 WS-BEFORE              BINARY-DOUBLE UNSIGNED.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG.
 01 WS-SEEDS               BINARY-LONG.
 01 WS-ORIGINS             BINARY-LONG.
 01 WS-DOORS               BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-BASE-ROWS.
    05 FILLER              PIC X(11) VALUE "55555555555".
    05 FILLER              PIC X(11) VALUE "55555555555".
    05 FILLER              PIC X(11) VALUE "02222211155".
    05 FILLER              PIC X(11) VALUE "02111112155".
    05 FILLER              PIC X(11) VALUE "22122223355".
    05 FILLER              PIC X(11) VALUE "22111223355".
    05 FILLER              PIC X(11) VALUE "00221112155".
    05 FILLER              PIC X(11) VALUE "00221111155".
    05 FILLER              PIC X(11) VALUE "00002222200".
    05 FILLER              PIC X(11) VALUE "55555555555".
    05 FILLER              PIC X(11) VALUE "55555555555".
 01 WS-BASE-TAB REDEFINES WS-BASE-ROWS.
    05 WS-BASE-ROW         PIC X(11) OCCURS 11 TIMES.
 01 WS-ROOM-ROWS.
    05 FILLER              PIC X(60) VALUE ". . . . . . . . . . .".
    05 FILLER              PIC X(60) VALUE ". . . . . . . . . . .".
    05 FILLER              PIC X(60) VALUE ". 20015 320015 2000d 32000d 310016 . . . . .".
    05 FILLER              PIC X(60) VALUE ". 32000a . . . . . 310013 . . .".
    05 FILLER              PIC X(60) VALUE "110018 2000a . 20014 320014 4000c 34000c . 800000 . .".
    05 FILLER              PIC X(60) VALUE "2000f 32000f . . . 4000c 4000c . 800000 . .".
    05 FILLER              PIC X(60) VALUE ". . 320010 20010 . . . 31000b . . .".
    05 FILLER              PIC X(60) VALUE ". . 2000e 32000e . . . . . . .".
    05 FILLER              PIC X(60) VALUE ". . . . 20012 320012 310017 20011 320011 . .".
    05 FILLER              PIC X(60) VALUE ". . . . . . . . . . .".
    05 FILLER              PIC X(60) VALUE ". . . . . . . . . . .".
 01 WS-ROOM-TAB REDEFINES WS-ROOM-ROWS.
    05 WS-ROOM-ROW         PIC X(60) OCCURS 11 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "SPB-RESET"
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED 2 0
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
     MOVE "acceptance US12 36-7§11.1 seed 0 chunk (2, 0) draws the rotation NONE" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MNG-BUILD"
*>   the base grid
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         MOVE SPACES TO WS-ROW
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             MOVE 1 TO WS-Q
             CALL "MNG-GET" USING WS-Q WS-X WS-Y WS-V
             MOVE WS-V TO WS-DIG
             MOVE WS-DIG TO WS-ROW(WS-X + 1:1)
         END-PERFORM
         COMPUTE WS-I = WS-Y + 1
         IF WS-ROW(1:11) NOT = WS-BASE-ROW(WS-I)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§11.1 the base grid of seed 0 chunk (2, 0) equals the table" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the floor-0 room codes as hex
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         MOVE SPACES TO WS-ROW
         MOVE 1 TO WS-PTR
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             MOVE 3 TO WS-Q
             CALL "MNG-GET" USING WS-Q WS-X WS-Y WS-V
             CALL "MNG-HEX" USING WS-V WS-CELL
             IF WS-X > 0
                 STRING " " DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
             END-IF
             STRING FUNCTION TRIM(WS-CELL) DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         END-PERFORM
         COMPUTE WS-I = WS-Y + 1
         MOVE WS-ROOM-ROW(WS-I) TO WS-WANT
         IF WS-ROW NOT = WS-WANT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§11.1 the floor-0 room codes of seed 0 chunk (2, 0) equal the table" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the layout: the first seven pieces
     MOVE 0 TO WS-ZERO
     CALL "MNP-LAYOUT" USING WS-ROT WS-ZERO WS-ZERO2 WS-ZERO3
     MOVE "acceptance US12 36-7§11.1 piece 1 is the entrance at (-9, 0, 0)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "entrance -9 0 0 0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     MOVE 1 TO WS-I
     PERFORM SHOW-ENTRY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§11.1 piece 2 is wall_flat at (7, 0, 16)" TO TL-CASE
     MOVE "wall_flat 7 0 16 0" TO TL-EXPECTED
     MOVE 2 TO WS-I
     PERFORM SHOW-ENTRY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§11.1 piece 4 is wall_flat at (7, 0, 32)" TO TL-CASE
     MOVE "wall_flat 7 0 32 0" TO TL-EXPECTED
     MOVE 4 TO WS-I
     PERFORM SHOW-ENTRY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§11.1 piece 5 is wall_corner at (0, 0, 39)" TO TL-CASE
     MOVE "wall_corner 0 0 39 0" TO TL-EXPECTED
     MOVE 5 TO WS-I
     PERFORM SHOW-ENTRY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§11.1 piece 6 is wall_flat at (6, 0, 39) turned 90" TO TL-CASE
     MOVE "wall_flat 6 0 39 1" TO TL-EXPECTED
     MOVE 6 TO WS-I
     PERFORM SHOW-ENTRY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§11.1 piece 7 is wall_flat at (-2, 0, 39) turned 90" TO TL-CASE
     MOVE "wall_flat -2 0 39 1" TO TL-EXPECTED
     MOVE 7 TO WS-I
     PERFORM SHOW-ENTRY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-7§6.3 the first-floor cursor is back at O with rotation R after the lap" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION ABS(MN-CX(1)) + FUNCTION ABS(MN-CZ(1)) + MN-CROT(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the 1x1 room doors (6.7): door east, north, west, south at R = 0, q = (0, 0, 0)
     MOVE 0 TO MN-COUNT
     MOVE 0 TO WS-ROT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 0
                 MOVE 1 TO WS-V
             WHEN 1
                 MOVE 0 TO WS-V
             WHEN 2
                 MOVE 3 TO WS-V
             WHEN OTHER
                 MOVE 2 TO WS-V
         END-EVALUATE
         MOVE 0 TO WS-FLOOR
         CALL "MNP-ROOM-1X1" USING WS-ZERO WS-ZERO2 WS-ZERO3 WS-ROT WS-V WS-FLOOR
     END-PERFORM
     MOVE "acceptance US12 36-7§11.2 four 1x1 rooms, doors east north west south: positions and rotations" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "1 0 0 0|1 0 6 3|7 0 6 2|7 0 0 1" TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MN-COUNT
         MOVE ME-X(WS-I) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE ME-Y(WS-I) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE ME-Z(WS-I) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE ME-ROT(WS-I) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         IF WS-I < MN-COUNT
             STRING "|" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the name selection draws (6.8): a stairs name draws nothing, 1x2_se draws once
     MOVE "N" TO TL-MODE
     CALL "JRAND-SET-SEED" USING SP-RNG WS-USEED
     MOVE SP-RNG TO WS-BEFORE
     MOVE 1 TO WS-FLOOR
     MOVE 1 TO WS-STAIRS
     MOVE 3 TO WS-Q
     CALL "MNP-NAME" USING WS-Q WS-FLOOR WS-STAIRS WS-NAME
     MOVE "acceptance US12 36-7§6.8 a floor-1 stairs side entrance is 1x2_c_stairs and draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-NAME = "1x2_c_stairs" AND SP-RNG = WS-BEFORE
         MOVE 0 TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-Q
     CALL "MNP-NAME" USING WS-Q WS-FLOOR WS-ZERO WS-NAME
     MOVE "acceptance US12 36-7§6.8 floor-1 secret 1x2 is 1x2_se1 and still draws once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-NAME = "1x2_se1" AND SP-RNG NOT = WS-BEFORE
         MOVE 0 TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   validation over a grid of chunks: items 2, 3, 4, 5 and the closed lap of item 7
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-SEEDS
     PERFORM VARYING WS-CX FROM -3 BY 1 UNTIL WS-CX > 3
         PERFORM VARYING WS-CZ FROM -3 BY 1 UNTIL WS-CZ > 3
             CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED WS-CX WS-CZ
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
             CALL "MNG-BUILD"
             CALL "MNG-CHECK" USING WS-V
             ADD WS-V TO WS-BAD
             CALL "MNP-LAYOUT" USING WS-ROT WS-CX WS-ZERO2 WS-CZ
             IF MN-CROT(1) NOT = WS-ROT OR MN-CX(1) NOT = WS-CX OR MN-CZ(1) NOT = WS-CZ
                 ADD 1 TO WS-BAD
             END-IF
             ADD 1 TO WS-SEEDS
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-7§12 items 2 to 7: rows of 5, room partition, doors, third floor and closed lap hold for 49 chunks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 SHOW-ENTRY.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING FUNCTION TRIM(ME-NAME(WS-I)) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE ME-X(WS-I) TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE ME-Y(WS-I) TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE ME-Z(WS-I) TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE ME-ROT(WS-I) TO WS-ED
     STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR.
 END PROGRAM TEST-STRUCT-MANSION.
