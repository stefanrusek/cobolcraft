*> Acceptance test of docs/protocol/36-structures-5 sections 2.3 to 2.6, 2.11 and 2.12 (the mineshaft start and the recursive assembly of its pieces): the root room of the worked example
*> 4.2 (seed 0, chunk (1,0): (18,50,2)-(29,57,14) before the vertical shift), and eight starts compared with an independent script that follows the document (piece count, vertical
*> shift, the greatest depth and a hash of every piece's type, orientation, depth, box and fields, then the room's entrance boxes); limits of 5 (depth at most 9, no piece more than 80
*> blocks from its parent's minimum corner), the stub position and the refusal of the mesa type.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MST                 BINARY-LONG.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-MAX-DEPTH           BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-REACH               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-LEN                 BINARY-LONG VALUE 0.
 01 WS-ZB                  BINARY-LONG VALUE 0.
 01 WS-ZC                  BINARY-LONG VALUE 0.
 01 WS-REACH-DIR           BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CREATE-SEED         BINARY-DOUBLE UNSIGNED.
 01 WS-DIRN                BINARY-LONG.
 01 WS-E-COUNT             BINARY-LONG.
 01 WS-E-DY                BINARY-LONG.
 01 WS-E-HASH              BINARY-DOUBLE.
 01 WS-ALL-LOST            BINARY-LONG.
 01 WS-LOST-KEEP           BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 PROCEDURE DIVISION.
*>   the worked example 4.2
     MOVE 0 TO WS-SEED
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE 0 TO WS-MST
     CALL "MS-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-MST WS-SEA WS-MIN-Y WS-X WS-Y WS-Z WS-VALID
     MOVE "T" TO TL-MODE
     MOVE SP-X0(1) TO WS-EDIT
     MOVE SP-X1(1) TO WS-EDIT2
     MOVE SP-Z0(1) TO WS-EDIT3
     MOVE SP-Z1(1) TO WS-EDIT4
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) " " FUNCTION TRIM(WS-EDIT4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "acceptance US12 36-5§2 Mineshaft: seed 0 chunk (1,0): the root room spans x 18 to 29 and z 2 to 14 (the draws 4, 3, 5 of 4.2 after one nextDouble)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "18 29 2 14" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-5§2 Mineshaft: the room is 8 high before the shift (y 50 to 57) and the structure moves down 13: y 37 to 44" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SP-Y0(1) * 100 + SP-Y1(1)
     MOVE 3744 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2 Mineshaft: the stub is (16 cx + 8, 50 + dy, 16 cz) = (24, 37, 0) and valid" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 10000 + WS-Y * 100 + WS-Z + WS-VALID * 1000000
     COMPUTE TL-EXPECTED-N = 1000000 + 24 * 10000 + 37 * 100 + 0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   eight starts against the script
     MOVE 0 TO WS-ALL-LOST
     MOVE 0 TO WS-SEED
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE 65 TO WS-E-COUNT
     MOVE -13 TO WS-E-DY
     MOVE 92389713 TO WS-E-HASH
     PERFORM CHECK-ONE
     MOVE 0 TO WS-SEED
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE 190 TO WS-E-COUNT
     MOVE -50 TO WS-E-DY
     MOVE 1819107020 TO WS-E-HASH
     PERFORM CHECK-ONE
     MOVE 1 TO WS-SEED
     MOVE 5 TO WS-CX
     MOVE -7 TO WS-CZ
     MOVE 98 TO WS-E-COUNT
     MOVE -62 TO WS-E-DY
     MOVE 856079570 TO WS-E-HASH
     PERFORM CHECK-ONE
     MOVE 12345 TO WS-SEED
     MOVE -3 TO WS-CX
     MOVE 20 TO WS-CZ
     MOVE 147 TO WS-E-COUNT
     MOVE -67 TO WS-E-DY
     MOVE 1688276967 TO WS-E-HASH
     PERFORM CHECK-ONE
     MOVE -77 TO WS-SEED
     MOVE 100 TO WS-CX
     MOVE 100 TO WS-CZ
     MOVE 147 TO WS-E-COUNT
     MOVE -41 TO WS-E-DY
     MOVE 1765526864 TO WS-E-HASH
     PERFORM CHECK-ONE
     MOVE 987654321 TO WS-SEED
     MOVE -40 TO WS-CX
     MOVE -9 TO WS-CZ
     MOVE 150 TO WS-E-COUNT
     MOVE -27 TO WS-E-DY
     MOVE 144665768 TO WS-E-HASH
     PERFORM CHECK-ONE
     MOVE 4242 TO WS-SEED
     MOVE 7 TO WS-CX
     MOVE 7 TO WS-CZ
     MOVE 95 TO WS-E-COUNT
     MOVE -39 TO WS-E-DY
     MOVE 1663390338 TO WS-E-HASH
     PERFORM CHECK-ONE
     MOVE 31337 TO WS-SEED
     MOVE -1 TO WS-CX
     MOVE -1 TO WS-CZ
     MOVE 132 TO WS-E-COUNT
     MOVE -97 TO WS-E-DY
     MOVE 1721257514 TO WS-E-HASH
     PERFORM CHECK-ONE
     MOVE WS-ALL-LOST TO WS-LOST-KEEP
*>   the limits of 5
     MOVE "acceptance US12 36-5§5 Mineshaft: no piece has genDepth above 9 (the greatest depth of the checked starts is 9: the room is 0, a child's depth is its parent's plus 1 up to 9)" TO TL-CASE
     MOVE WS-MAX-DEPTH TO TL-OBSERVED-N
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§5 Mineshaft: no piece was dropped for lack of room in the table (the eight starts)" TO TL-CASE
     MOVE WS-LOST-KEEP TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the mesa type is refused (the base height of the terrain is not available)
     MOVE 1 TO WS-MST
     CALL "MS-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-MST WS-SEA WS-MIN-Y WS-X WS-Y WS-Z WS-VALID
     MOVE "acceptance US12 36-5§2.3 Mineshaft: the mesa type makes no start (its vertical placement needs the terrain's base height)" TO TL-CASE
     MOVE WS-VALID TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the corridor candidate box in the four directions (2.6, 4.6): anchor (100,40,200), two sections (10 long)
     MOVE 100 TO WS-CX
     MOVE 40 TO WS-Y
     MOVE 200 TO WS-Z
     MOVE 2 TO WS-LEN
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         MOVE WS-I TO WS-DIRN
         CALL "MS-CORRIDOR-BOX" USING WS-CX WS-Y WS-Z WS-DIRN WS-LEN WS-BOX
         MOVE SPACES TO WS-TEXT
         MOVE A-X0 TO WS-EDIT
         MOVE A-Z0 TO WS-EDIT2
         MOVE A-X1 TO WS-EDIT3
         MOVE A-Z1 TO WS-EDIT4
         STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) " " FUNCTION TRIM(WS-EDIT4) DELIMITED BY SIZE INTO WS-TEXT
         MOVE "T" TO TL-MODE
         MOVE WS-TEXT TO TL-OBSERVED
         EVALUATE WS-I
             WHEN 0
                 MOVE "100 200 102 209" TO TL-EXPECTED
                 MOVE "acceptance US12 36-5§2.6 Mineshaft corridor box south: 3 wide, 10 long toward +z: x 100 to 102, z 200 to 209" TO TL-CASE
             WHEN 1
                 MOVE "91 200 100 202" TO TL-EXPECTED
                 MOVE "acceptance US12 36-5§2.6 Mineshaft corridor box west: x 91 to 100, z 200 to 202" TO TL-CASE
             WHEN 2
                 MOVE "100 191 102 200" TO TL-EXPECTED
                 MOVE "acceptance US12 36-5§2.6 Mineshaft corridor box north: z 191 to 200" TO TL-CASE
             WHEN 3
                 MOVE "100 200 109 202" TO TL-EXPECTED
                 MOVE "acceptance US12 36-5§2.6 Mineshaft corridor box east: x 100 to 109" TO TL-CASE
         END-EVALUATE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   a candidate that collides with a piece makes none (crossing, stairs and corridor, every length): 60 seeds against a builder holding one huge piece
     CALL "SPB-RESET"
     MOVE -1000 TO A-X0
     MOVE -1000 TO A-Y0
     MOVE -1000 TO A-Z0
     MOVE 1000 TO A-X1
     MOVE 1000 TO A-Y1
     MOVE 1000 TO A-Z1
     MOVE 2 TO WS-DIRN
     MOVE 0 TO WS-LEN
     CALL "SPB-ADD" USING WS-LEN WS-DIRN WS-ZB WS-ZC WS-BOX WS-I
     MOVE 0 TO WS-ALL-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         MOVE WS-I TO WS-CREATE-SEED
         CALL "JRAND-SET-SEED" USING SP-RNG WS-CREATE-SEED
         MOVE 0 TO WS-X
         MOVE 0 TO WS-Z
         MOVE 2 TO WS-DIRN
         CALL "MS-CREATE" USING WS-X WS-Y WS-Z WS-DIRN WS-LEN WS-ZB WS-ROW
         ADD WS-ROW TO WS-ALL-LOST
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-5§2.4 Mineshaft: every candidate box collides with the huge piece: no piece is made (60 seeds covering the three classes)" TO TL-CASE
     MOVE WS-ALL-LOST TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   generateAndAddPiece: nothing more than 80 blocks in x or z from the parent's minimum corner (2.4)
     CALL "SPB-RESET"
     MOVE 0 TO A-X0
     MOVE 50 TO A-Y0
     MOVE 0 TO A-Z0
     MOVE 9 TO A-X1
     MOVE 55 TO A-Y1
     MOVE 9 TO A-Z1
     MOVE 2 TO WS-DIRN
     MOVE 0 TO WS-LEN
     MOVE -1 TO WS-REACH-DIR
     CALL "SPB-ADD" USING WS-LEN WS-REACH-DIR WS-ZB WS-ZC WS-BOX WS-ROW
     MOVE 81 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "MS-GEN-ADD" USING WS-ROW WS-X WS-Y WS-Z WS-DIRN WS-LEN WS-I
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-5§2.4 Mineshaft: a child 81 blocks in x from the parent's minimum corner is refused" TO TL-CASE
     MOVE WS-I TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X
     MOVE 81 TO WS-Z
     CALL "MS-GEN-ADD" USING WS-ROW WS-X WS-Y WS-Z WS-DIRN WS-LEN WS-I
     MOVE "acceptance US12 36-5§2.4 Mineshaft: and 81 blocks in z" TO TL-CASE
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CASE-RUN.
     MOVE 0 TO WS-MST
     CALL "MS-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-MST WS-SEA WS-MIN-Y WS-X WS-Y WS-Z WS-VALID
     COMPUTE WS-DY = WS-Y - 50
     MOVE 0 TO WS-H
     MOVE 0 TO WS-MAX-DEPTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         MOVE SP-TYPE(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-ORIENT(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-DEPTH(WS-I) TO WS-V
         PERFORM HASH-ADD
         IF SP-DEPTH(WS-I) > WS-MAX-DEPTH
             MOVE SP-DEPTH(WS-I) TO WS-MAX-DEPTH
         END-IF
         MOVE SP-X0(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-Y0(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-Z0(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-X1(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-Y1(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-Z1(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-F1(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-F2(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-F3(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SP-F4(WS-I) TO WS-V
         PERFORM HASH-ADD
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-ENT-COUNT
         MOVE SE-X0(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SE-Y0(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SE-Z0(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SE-X1(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SE-Y1(WS-I) TO WS-V
         PERFORM HASH-ADD
         MOVE SE-Z1(WS-I) TO WS-V
         PERFORM HASH-ADD
     END-PERFORM
     MOVE "N" TO TL-MODE.
 HASH-ADD.
     COMPUTE WS-H = FUNCTION MOD(WS-H * 31 + WS-V, 2147483647).
 CHECK-ONE.
     PERFORM CASE-RUN
     ADD SP-LOST TO WS-ALL-LOST
     MOVE WS-SEED TO WS-EDIT
     MOVE WS-CX TO WS-EDIT2
     MOVE WS-CZ TO WS-EDIT3
     MOVE SPACES TO WS-TEXT
     STRING "seed " FUNCTION TRIM(WS-EDIT) " chunk (" FUNCTION TRIM(WS-EDIT2) "," FUNCTION TRIM(WS-EDIT3) ")" DELIMITED BY SIZE INTO WS-TEXT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-5§2 Mineshaft: " FUNCTION TRIM(WS-TEXT) ": the piece count and the vertical shift match the script" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-OBSERVED-N = SP-COUNT * 1000 - WS-DY
     COMPUTE TL-EXPECTED-N = WS-E-COUNT * 1000 - WS-E-DY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-5§2 Mineshaft: " FUNCTION TRIM(WS-TEXT) ": the hash of every piece and entrance box matches the script" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE WS-E-HASH TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
