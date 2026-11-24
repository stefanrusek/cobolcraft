*> Acceptance test of the nether fortress piece tables, selection and limits (docs/protocol/36-structures-8-nether-and-end.md section 3 and 7.2, 7.3; core/src/struct-fortress.cob; T13506): the weighted
*> choice of the bridge and castle tables against independently computed cumulative weights, the exhausted table (only fillers, one nextInt() each), the generation depth limit, and the rules that hold in
*> every grown fortress (the maxima of the limited pieces, allowInRow through previousPiece, depth at most 30 for table pieces, no two boxes intersecting).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTFORT.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG VALUE 100.
 01 WS-AY                  BINARY-LONG VALUE 70.
 01 WS-AZ                  BINARY-LONG VALUE 100.
 01 WS-DIR                 BINARY-LONG VALUE 0.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-REF                 BINARY-DOUBLE UNSIGNED.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BITS                BINARY-LONG VALUE 32.
 01 WS-DUMMY               BINARY-DOUBLE.
 01 WS-SEEN-TAB.
    05 WS-SEEN             BINARY-LONG OCCURS 20 TIMES.
 01 WS-COUNTS.
    05 WS-CNT              BINARY-LONG OCCURS 20 TIMES.
 01 WS-BAD-MAX             BINARY-LONG.
 01 WS-BAD-ROW             BINARY-LONG.
 01 WS-BAD-DEPTH           BINARY-LONG.
 01 WS-BAD-BOX             BINARY-LONG.
 01 WS-PREV-TYPE           BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-MAXES.
    05 WS-MAXV             BINARY-LONG OCCURS 20 TIMES.
*> cumulative weights and registry ids in table order
 01 WS-BRIDGE-IDS          PIC X(12) VALUE "060416171509".
 01 WS-BRIDGE-CUM          PIC X(18) VALUE "030040050060065070".
 01 WS-CASTLE-IDS          PIC X(14) VALUE "12101311070814".
 01 WS-CASTLE-CUM          PIC X(21) VALUE "025040045050060067072".
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-CX WS-CZ
     CALL "FORT-START" USING WS-SEED WS-CX WS-CZ
*>   the choice of the bridge table: 60 states, an empty builder, fresh entries
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         PERFORM RESET-TABLES
         CALL "SPB-RESET"
         MOVE WS-I TO SP-RNG
         MOVE SP-RNG TO WS-REF
         MOVE 70 TO WS-TOTAL
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-TOTAL WS-R
         MOVE 0 TO WS-WANT
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6 OR WS-WANT > 0
             IF WS-R < FUNCTION NUMVAL(WS-BRIDGE-CUM(WS-J * 3 - 2:3))
                 MOVE FUNCTION NUMVAL(WS-BRIDGE-IDS(WS-J * 2 - 1:2)) TO WS-WANT
             END-IF
         END-PERFORM
         MOVE 1 TO WS-LO
         MOVE 6 TO WS-HI
         MOVE 3 TO WS-DEPTH
         CALL "FORT-PICK" USING WS-LO WS-HI WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-ROW
         IF WS-ROW NOT = 1 OR SP-TYPE(1) NOT = WS-WANT OR SP-RNG NOT = WS-REF
             ADD 1 TO WS-BAD
         END-IF
         ADD 1 TO WS-SEEN(WS-WANT)
     END-PERFORM
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: the bridge table picks by cumulative weight 30, 40, 50, 60, 65, 70" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
         IF WS-SEEN(FUNCTION NUMVAL(WS-BRIDGE-IDS(WS-J * 2 - 1:2))) = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: every bridge entry was chosen at least once in 60 draws" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the castle table
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         PERFORM RESET-TABLES
         CALL "SPB-RESET"
         MOVE WS-I TO SP-RNG
         MOVE SP-RNG TO WS-REF
         MOVE 72 TO WS-TOTAL
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-TOTAL WS-R
         MOVE 0 TO WS-WANT
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7 OR WS-WANT > 0
             IF WS-R < FUNCTION NUMVAL(WS-CASTLE-CUM(WS-J * 3 - 2:3))
                 MOVE FUNCTION NUMVAL(WS-CASTLE-IDS(WS-J * 2 - 1:2)) TO WS-WANT
             END-IF
         END-PERFORM
         IF WS-WANT = 11 OR WS-WANT = 13
             MOVE 3 TO WS-TOTAL
             CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-TOTAL WS-R
         END-IF
         MOVE 7 TO WS-LO
         MOVE 13 TO WS-HI
         CALL "FORT-PICK" USING WS-LO WS-HI WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-ROW
         IF WS-ROW NOT = 1 OR SP-TYPE(1) NOT = WS-WANT OR SP-RNG NOT = WS-REF
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: the castle table picks by cumulative weight 25, 40, 45, 50, 60, 67, 72" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the generation depth limit: a parent at depth 30 gives a filler, drawing one nextInt() and no choice
     PERFORM RESET-TABLES
     CALL "SPB-RESET"
     MOVE 99 TO SP-RNG
     MOVE SP-RNG TO WS-REF
     CALL "JRAND-NEXT" USING WS-REF WS-BITS WS-DUMMY
     MOVE 1 TO WS-LO
     MOVE 6 TO WS-HI
     MOVE 31 TO WS-DEPTH
     CALL "FORT-PICK" USING WS-LO WS-HI WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-ROW
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: a generation depth over 30 makes only a filler (one nextInt())" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW NOT = 1 OR SP-TYPE(1) NOT = 5 OR SP-RNG NOT = WS-REF
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the exhausted bridge table (7.3): only BridgeStraight is left, total is -1, so a filler
     PERFORM RESET-TABLES
     PERFORM VARYING WS-J FROM 2 BY 1 UNTIL WS-J > 6
         MOVE 0 TO FE-LIVE(WS-J)
     END-PERFORM
     CALL "SPB-RESET"
     MOVE 99 TO SP-RNG
     MOVE SP-RNG TO WS-REF
     CALL "JRAND-NEXT" USING WS-REF WS-BITS WS-DUMMY
     MOVE 3 TO WS-DEPTH
     CALL "FORT-PICK" USING WS-LO WS-HI WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-ROW
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: an exhausted table gives a filler and draws only its seed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW NOT = 1 OR SP-TYPE(1) NOT = 5 OR SP-RNG NOT = WS-REF
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   previousPiece: a RoomCrossing just made cannot be made again, the attempt ends (a new draw) and the filler comes after five attempts
     PERFORM RESET-TABLES
     MOVE 3 TO FO-PREV
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "SPB-RESET"
         MOVE 4 TO FO-PREV
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 13
             MOVE 0 TO FE-PLACED(WS-J)
             MOVE 1 TO FE-LIVE(WS-J)
         END-PERFORM
         MOVE WS-I TO SP-RNG
         MOVE 1 TO WS-LO
         MOVE 6 TO WS-HI
         CALL "FORT-PICK" USING WS-LO WS-HI WS-AX WS-AY WS-AZ WS-DIR WS-DEPTH WS-ROW
*>       entry 4 is StairsRoom (registry 17): never chosen straight after itself
         IF SP-TYPE(1) = 17
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: the piece made last is not made again unless allowInRow" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   whole fortresses: limits, rows, depth, no collisions
     MOVE 0 TO WS-BAD-MAX WS-BAD-ROW WS-BAD-DEPTH WS-BAD-BOX
     MOVE 0 TO WS-MAXV(4) WS-MAXV(16) WS-MAXV(17) WS-MAXV(15) WS-MAXV(9) WS-MAXV(10)
     MOVE 4 TO WS-MAXV(4)
     MOVE 4 TO WS-MAXV(16)
     MOVE 3 TO WS-MAXV(17)
     MOVE 2 TO WS-MAXV(15)
     MOVE 1 TO WS-MAXV(9)
     MOVE 5 TO WS-MAXV(10)
     MOVE 10 TO WS-MAXV(13)
     MOVE 10 TO WS-MAXV(11)
     MOVE 3 TO WS-MAXV(7)
     MOVE 2 TO WS-MAXV(8)
     MOVE 2 TO WS-MAXV(14)
     MOVE 999 TO WS-MAXV(5) WS-MAXV(6) WS-MAXV(12) WS-MAXV(18)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 40
         COMPUTE WS-CX = WS-K - 20
         COMPUTE WS-CZ = FUNCTION MOD(WS-K * 7, 13) - 6
         CALL "FORT-START" USING WS-SEED WS-CX WS-CZ
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 20
             MOVE 0 TO WS-CNT(WS-J)
         END-PERFORM
         MOVE 0 TO WS-PREV-TYPE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
             MOVE SP-TYPE(WS-I) TO WS-T
             ADD 1 TO WS-CNT(WS-T)
             ADD 1 TO WS-SEEN(WS-T)
             IF WS-T NOT = 5 AND WS-T NOT = 18
                 IF WS-T = WS-PREV-TYPE AND WS-T NOT = 6 AND WS-T NOT = 12 AND WS-T NOT = 7
                     ADD 1 TO WS-BAD-ROW
                 END-IF
                 MOVE WS-T TO WS-PREV-TYPE
                 IF SP-DEPTH(WS-I) > 30
                     ADD 1 TO WS-BAD-DEPTH
                 END-IF
             END-IF
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-I
                 IF SP-X0(WS-I) <= SP-X1(WS-J) AND SP-X1(WS-I) >= SP-X0(WS-J) AND SP-Y0(WS-I) <= SP-Y1(WS-J)
                     AND SP-Y1(WS-I) >= SP-Y0(WS-J) AND SP-Z0(WS-I) <= SP-Z1(WS-J) AND SP-Z1(WS-I) >= SP-Z0(WS-J)
                     ADD 1 TO WS-BAD-BOX
                 END-IF
             END-PERFORM
         END-PERFORM
         PERFORM VARYING WS-J FROM 4 BY 1 UNTIL WS-J > 18
             IF WS-CNT(WS-J) > WS-MAXV(WS-J)
                 ADD 1 TO WS-BAD-MAX
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: the maxima of the limited pieces hold in 40 fortresses" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-MAX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: previousPiece blocks a repeat except straight, corridor and stairs pieces" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: no table piece is deeper than 30" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-DEPTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: no two pieces of a fortress intersect" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-BOX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-J FROM 4 BY 1 UNTIL WS-J > 18
         IF WS-SEEN(WS-J) = 0
             ADD 1 TO WS-BAD
             DISPLAY "PROBE type never seen " WS-J
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§3 A. The piece tables, selection and limits: all 15 classes occur in 40 fortresses" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 RESET-TABLES.
     PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > 13
         MOVE 0 TO FE-PLACED(WS-IX)
         MOVE 1 TO FE-LIVE(WS-IX)
     END-PERFORM
     MOVE 0 TO FO-PREV
     EXIT.
 END PROGRAM TEST-STRUCT-36-8-3.
