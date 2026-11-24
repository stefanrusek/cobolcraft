*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md section 2.2 (constants and the piece-type ids, T1482): the artifact's code strings MSCorridor, MSCrossing, MSRoom,
*> MSStairs resolve (lower-cased by the registration helper) to the piece ids 0 to 3 and the stronghold's SHCC, SHFC, SH5C, SHLT, SHLi, SHPR, SHPH, SHRT, SHRC, SHSD, SHStart, SHS, SHSSD to the ids
*> the stronghold code uses (19 to 31); the saved id is the lower-case namespaced key (STRUCT-ENUM-NAME). The constants: MAX_DEPTH = 8 (a child at depth 8 is made, at depth 9 refused), MAGIC_START_Y = 50
*> (the root room starts at y 50), the default corridor section is 3 wide, 3 high, 5 long (MS-CORRIDOR-BOX of one section), and a corridor of n sections is 5 n long.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-2-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-NAME                PIC X(40).
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-X                   BINARY-LONG VALUE 100.
 01 WS-Y                   BINARY-LONG VALUE 40.
 01 WS-Z                   BINARY-LONG VALUE 200.
 01 WS-DIR                 BINARY-LONG VALUE 3.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PARENT              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-LEN                 BINARY-LONG.
 01 WS-MADE                BINARY-LONG.
 01 WS-SEED-X              BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-CODES.
    05 FILLER              PIC X(40) VALUE "MSCorridor".
    05 FILLER              PIC X(40) VALUE "MSCrossing".
    05 FILLER              PIC X(40) VALUE "MSRoom".
    05 FILLER              PIC X(40) VALUE "MSStairs".
    05 FILLER              PIC X(40) VALUE "SHCC".
    05 FILLER              PIC X(40) VALUE "SHFC".
    05 FILLER              PIC X(40) VALUE "SH5C".
    05 FILLER              PIC X(40) VALUE "SHLT".
    05 FILLER              PIC X(40) VALUE "SHLi".
    05 FILLER              PIC X(40) VALUE "SHPR".
    05 FILLER              PIC X(40) VALUE "SHPH".
    05 FILLER              PIC X(40) VALUE "SHRT".
    05 FILLER              PIC X(40) VALUE "SHRC".
    05 FILLER              PIC X(40) VALUE "SHSD".
    05 FILLER              PIC X(40) VALUE "SHStart".
    05 FILLER              PIC X(40) VALUE "SHS".
    05 FILLER              PIC X(40) VALUE "SHSSD".
 01 WS-CODE-TAB REDEFINES WS-CODES.
    05 WS-CODE             PIC X(40) OCCURS 17 TIMES.
 01 WS-IDS.
    05 FILLER              PIC 99 VALUE 00.
    05 FILLER              PIC 99 VALUE 01.
    05 FILLER              PIC 99 VALUE 02.
    05 FILLER              PIC 99 VALUE 03.
    05 FILLER              PIC 99 VALUE 19.
    05 FILLER              PIC 99 VALUE 20.
    05 FILLER              PIC 99 VALUE 21.
    05 FILLER              PIC 99 VALUE 22.
    05 FILLER              PIC 99 VALUE 23.
    05 FILLER              PIC 99 VALUE 24.
    05 FILLER              PIC 99 VALUE 25.
    05 FILLER              PIC 99 VALUE 26.
    05 FILLER              PIC 99 VALUE 27.
    05 FILLER              PIC 99 VALUE 28.
    05 FILLER              PIC 99 VALUE 29.
    05 FILLER              PIC 99 VALUE 30.
    05 FILLER              PIC 99 VALUE 31.
 01 WS-ID-TAB REDEFINES WS-IDS.
    05 WS-WANT-ID          PIC 99 OCCURS 17 TIMES.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BAD-NAMES           BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-BAD WS-BAD-NAMES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 17
         MOVE WS-CODE(WS-I) TO WS-NAME
         CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-ID
         IF WS-ID NOT = WS-WANT-ID(WS-I)
             ADD 1 TO WS-BAD
         END-IF
*>       the saved id is the lower-case code string
         CALL "STRUCT-ENUM-NAME" USING WS-KIND WS-ID WS-KEY
         IF WS-KEY NOT = FUNCTION LOWER-CASE(WS-CODE(WS-I))
             ADD 1 TO WS-BAD-NAMES
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§2.2 Constants and the piece-type ids: the 17 code strings resolve (lower-cased) to mscorridor 0, mscrossing 1, msroom 2, msstairs 3 and the stronghold ids 19 to 31" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.2 Constants and the piece-type ids: the saved id of each is the lower-case namespaced key" TO TL-CASE
     MOVE WS-BAD-NAMES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   MAX_DEPTH = 8: a child requested with genDepth 8 is made, with 9 it is refused (a free site, a room parent at the origin)
     CALL "SPB-RESET"
     MOVE 0 TO B-X0
     MOVE 50 TO B-Y0
     MOVE 0 TO B-Z0
     MOVE 9 TO B-X1
     MOVE 55 TO B-Y1
     MOVE 9 TO B-Z1
     CALL "SPB-ADD" USING WS-TYPE WS-NONE WS-ZERO WS-MST WS-BOX WS-PARENT
     MOVE 0 TO WS-MADE
     PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 20
         MOVE WS-SEED TO WS-STATE
         CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
         MOVE 8 TO WS-DEPTH
         MOVE 40 TO WS-X
         MOVE 40 TO WS-Z
         CALL "MS-GEN-ADD" USING WS-PARENT WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-ROW
         IF WS-ROW > 0
             ADD 1 TO WS-MADE
             MOVE WS-ROW TO WS-I
             IF SP-DEPTH(WS-I) NOT = 9
                 ADD 100 TO WS-MADE
             END-IF
         END-IF
         CALL "SPB-RESET"
         CALL "SPB-ADD" USING WS-TYPE WS-NONE WS-ZERO WS-MST WS-BOX WS-PARENT
     END-PERFORM
     MOVE "acceptance US12 36-5§2.2 Constants and the piece-type ids: MAX_DEPTH 8: with genDepth 8 a child is made (its depth is 9: at most 9 of the pieces), 20 seeds, at least 12 made" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MADE >= 12 AND WS-MADE < 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-MADE
     PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 20
         MOVE WS-SEED TO WS-STATE
         CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
         MOVE 9 TO WS-DEPTH
         CALL "MS-GEN-ADD" USING WS-PARENT WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-ROW
         IF WS-ROW > 0
             ADD 1 TO WS-MADE
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-5§2.2 Constants and the piece-type ids: MAX_DEPTH 8: with genDepth 9 no child is made" TO TL-CASE
     MOVE WS-MADE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   MAGIC_START_Y = 50: the root room of chunk (1,0) at seed 0 starts at y 50 and is 8 high before the shift (y 50 to 57); the shift for sea level 63 is -13: y 37 to 44
     MOVE 0 TO WS-SEED-X
     MOVE 0 TO WS-MST
     CALL "MS-FIND-POINT" USING WS-SEED-X WS-CX WS-CZ WS-MST WS-SEA WS-MIN-Y WS-SX WS-SY WS-SZ WS-VALID
     MOVE "acceptance US12 36-5§2.2 Constants and the piece-type ids: MAGIC_START_Y = 50: the root room is at y 50 to 57 before the shift of -13 (stored 37 to 44)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SP-Y0(1) + 13) * 1000 + SP-Y1(1) + 13
     MOVE 50057 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the default corridor section: 3 wide, 3 high, 5 long; a corridor of n sections is 5 n long
     MOVE 1 TO WS-LEN
     MOVE 3 TO WS-DIR
     CALL "MS-CORRIDOR-BOX" USING WS-X WS-Y WS-Z WS-DIR WS-LEN WS-BOX
     MOVE "acceptance US12 36-5§2.2 Constants and the piece-type ids: one corridor section east of (100,40,200) is 5 long, 3 wide and 3 high (x 100 to 104, y 40 to 42, z 200 to 202)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (B-X1 - B-X0 + 1) * 10000 + (B-Y1 - B-Y0 + 1) * 100 + B-Z1 - B-Z0 + 1
     MOVE 50303 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-LEN
     CALL "MS-CORRIDOR-BOX" USING WS-X WS-Y WS-Z WS-DIR WS-LEN WS-BOX
     MOVE "acceptance US12 36-5§2.2 Constants and the piece-type ids: four sections are 20 long" TO TL-CASE
     COMPUTE TL-OBSERVED-N = B-X1 - B-X0 + 1
     MOVE 20 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-5-2-2.
