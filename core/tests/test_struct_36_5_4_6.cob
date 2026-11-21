*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md section 4.6 (a corridor box, T1538): a NORTH corridor of len = 3 at the anchor (100, 40, 200) has the length 15, the
*> world box (100, 40, 186)..(102, 42, 200) and numSections = 15 / 5 = 3 (MS-CREATE with a seed whose draws give len 3); its side-branch scan runs i = 189 (189 + 3 = 192 <= 200) and
*> i = 194 (197 <= 200) and stops at i = 199 (202 > 200): two nextInt(5) draws, after the draws r = nextInt(4) and y = nextInt(3) of the forward child. The draws are compared with a model of the
*> document's order on a second generator, with a box around everything so that no child is ever made (the draws of each candidate are the class draw and the crossing or corridor length draw).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-4-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-MODEL               BINARY-DOUBLE UNSIGNED.
 01 WS-B                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 100.
 01 WS-Y                   BINARY-LONG VALUE 40.
 01 WS-Z                   BINARY-LONG VALUE 200.
 01 WS-DIR                 BINARY-LONG VALUE 2.
 01 WS-DEPTH               BINARY-LONG VALUE 3.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-GIANT               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SIDES               BINARY-LONG.
 01 WS-LEN                 BINARY-LONG VALUE 3.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-TEXT                PIC X(60).
 01 WS-P                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   the corridor box of len 3
     CALL "MS-CORRIDOR-BOX" USING WS-X WS-Y WS-Z WS-DIR WS-LEN WS-BOX
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-P
     MOVE B-X0 TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     MOVE B-Y0 TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     MOVE B-Z0 TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     MOVE B-X1 TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     MOVE B-Y1 TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     MOVE B-Z1 TO WS-ED
     STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     MOVE "acceptance US12 36-5§4.6 A corridor box: NORTH, len 3, anchor (100,40,200): L = 15, world box (100,40,186)..(102,42,200)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "100 40 186 102 42 200" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   MS-CREATE of a free site with a seed whose class draw is below 70 and whose length draw is 1 (len = 3): the piece has the box and 3 sections
     CALL "SPB-RESET"
     MOVE 0 TO WS-SEED
     MOVE 99 TO WS-V
     MOVE 9 TO WS-V2
     PERFORM UNTIL WS-V < 70 AND WS-V2 = 1
         ADD 1 TO WS-SEED
         MOVE WS-SEED TO WS-STATE
         CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
         MOVE 100 TO WS-B
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-B WS-V
         MOVE 3 TO WS-B
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-B WS-V2
     END-PERFORM
     MOVE WS-SEED TO WS-STATE
     CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
     CALL "MS-CREATE" USING WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-MST WS-ROW
     MOVE "acceptance US12 36-5§4.6 A corridor box: the created corridor holds numSections = 15 / 5 = 3" TO TL-CASE
     MOVE SP-F4(WS-ROW) TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§4.6 A corridor box: and its box ends at z 186 (minimum) and 200 (the anchor)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SP-Z0(WS-ROW) * 1000 + SP-Z1(WS-ROW)
     MOVE 186200 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the children's draws: a box around everything, then the corridor of 4.6 at depth 3
     CALL "SPB-RESET"
     MOVE -5000 TO B-X0
     MOVE -500 TO B-Y0
     MOVE -5000 TO B-Z0
     MOVE 5000 TO B-X1
     MOVE 500 TO B-Y1
     MOVE 5000 TO B-Z1
     MOVE 0 TO WS-TYPE
     CALL "SPB-ADD" USING WS-TYPE WS-NONE WS-ZERO WS-ZERO2 WS-BOX WS-GIANT
     MOVE 100 TO B-X0
     MOVE 40 TO B-Y0
     MOVE 186 TO B-Z0
     MOVE 102 TO B-X1
     MOVE 42 TO B-Y1
     MOVE 200 TO B-Z1
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-DEPTH WS-ZERO WS-BOX WS-ROW
     MOVE 0 TO WS-SIDES
     PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 6
         MOVE WS-SEED TO WS-STATE
         CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
         CALL "MS-CHILDREN" USING WS-ROW
         MOVE SP-RNG TO WS-STATE
*>       the model: r, y, the forward child's candidate draws, then i = 189 and 194, each with s and a candidate for s 0 and 1
         MOVE WS-SEED TO WS-MODEL
         CALL "JRAND-SET-SEED" USING WS-MODEL WS-SEED
         MOVE 4 TO WS-B
         CALL "JRAND-NEXT-INT-BOUND" USING WS-MODEL WS-B WS-V
         MOVE 3 TO WS-B
         CALL "JRAND-NEXT-INT-BOUND" USING WS-MODEL WS-B WS-V
         PERFORM MODEL-CANDIDATE
         PERFORM VARYING WS-I FROM 189 BY 5 UNTIL WS-I + 3 > 200
             MOVE 5 TO WS-B
             CALL "JRAND-NEXT-INT-BOUND" USING WS-MODEL WS-B WS-S
             IF WS-S < 2
                 PERFORM MODEL-CANDIDATE
             END-IF
         END-PERFORM
         IF WS-MODEL = WS-STATE
             ADD 1 TO WS-SIDES
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§4.6 A corridor box: six seeds: the draws of the children are r, y, then one nextInt(5) at i = 189 and 194 (none at 199), as modelled" TO TL-CASE
     MOVE WS-SIDES TO TL-OBSERVED-N
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 MODEL-CANDIDATE.
*>   createRandomShaftPiece when every box collides: the class draw, then the crossing's nextInt(4) or the corridor's nextInt(3); the stairs draw nothing
     MOVE 100 TO WS-B
     CALL "JRAND-NEXT-INT-BOUND" USING WS-MODEL WS-B WS-V
     IF WS-V >= 80
         MOVE 4 TO WS-B
         CALL "JRAND-NEXT-INT-BOUND" USING WS-MODEL WS-B WS-V2
     END-IF
     IF WS-V < 70
         MOVE 3 TO WS-B
         CALL "JRAND-NEXT-INT-BOUND" USING WS-MODEL WS-B WS-V2
     END-IF.
 END PROGRAM TEST-STRUCT-36-5-4-6.
