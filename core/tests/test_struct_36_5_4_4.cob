*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md section 4.4 (choosing from the table, T1534): the full table totals 145; a draw v = 93 of nextInt(145) is
*> RoomCrossing (40, 5, 20, 20, 10 subtracted leave -2); when its box fails the factory the walk continues with the next entry, StraightStairsDown, with the same negative value; a draw
*> v = 140 lies in PortalRoom (cumulative bounds 40, 45, 65, 85, 95, 100, 105, 110, 115, 125, 145), which doPlace rejects while the depth is 5 or less and accepts at depth 6.
*> The draws are made real: the test searches a seed whose first nextInt(145) is the wanted v and gives it to the generation random (SP-RNG) before SH-PICK.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-4-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTSH.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-BOUND               BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 100.
 01 WS-Y                   BINARY-LONG VALUE 40.
 01 WS-Z                   BINARY-LONG VALUE 100.
 01 WS-DIR                 BINARY-LONG VALUE 0.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-BLOCK-TYPE          BINARY-LONG VALUE 30.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "SH-RESET"
     CALL "SPB-RESET"
     CALL "SH-UPDATE-WEIGHT" USING WS-ANY
     MOVE "acceptance US12 36-5§4.4 Choosing from the table: the full table totals 145" TO TL-CASE
     MOVE SH-TOTAL TO TL-OBSERVED-N
     MOVE 145 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   v = 93: the running subtraction 93 - 40 - 5 - 20 - 20 - 10 = -2 ends at RoomCrossing (index 5, type 27)
     MOVE 93 TO WS-WANT
     PERFORM FIND-SEED
     MOVE WS-SEED TO WS-STATE
     CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
     MOVE 3 TO WS-DEPTH
     CALL "SH-PICK" USING WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-ROW
     MOVE "acceptance US12 36-5§4.4 Choosing from the table: v = 93 is RoomCrossing (shrc, 27)" TO TL-CASE
     MOVE SP-TYPE(WS-ROW) TO TL-OBSERVED-N
     MOVE 27 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   its box fails the factory (a piece in its way): the walk goes on with StraightStairsDown (type 31), the value still negative
     CALL "SH-RESET"
     CALL "SPB-RESET"
     MOVE 105 TO B-X0
     MOVE 40 TO B-Y0
     MOVE 105 TO B-Z0
     MOVE 106 TO B-X1
     MOVE 44 TO B-Y1
     MOVE 105 TO B-Z1
     CALL "SPB-ADD" USING WS-BLOCK-TYPE WS-DIR WS-NONE BY CONTENT WS-NONE BY REFERENCE WS-BOX WS-ROW
     MOVE WS-SEED TO WS-STATE
     CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
     MOVE 3 TO WS-DEPTH
     CALL "SH-PICK" USING WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-ROW
     MOVE "acceptance US12 36-5§4.4 Choosing from the table: when RoomCrossing's box fails, the next entry StraightStairsDown (shssd, 31) is tried with the same negative value" TO TL-CASE
     MOVE SP-TYPE(WS-ROW) TO TL-OBSERVED-N
     MOVE 31 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   v = 140: PortalRoom (index 11, type 24), covering 125 to 144; accepted at depth 6
     CALL "SH-RESET"
     CALL "SPB-RESET"
     MOVE 140 TO WS-WANT
     PERFORM FIND-SEED
     MOVE WS-SEED TO WS-STATE
     CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
     MOVE 6 TO WS-DEPTH
     CALL "SH-PICK" USING WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-ROW
     MOVE "acceptance US12 36-5§4.4 Choosing from the table: v = 140 is PortalRoom (shpr, 24) at depth 6" TO TL-CASE
     MOVE SP-TYPE(WS-ROW) TO TL-OBSERVED-N
     MOVE 24 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   and rejected by doPlace at depth 5: the first try is abandoned (the piece, if any, comes from a later try and is not a portal room)
     CALL "SH-RESET"
     CALL "SPB-RESET"
     MOVE WS-SEED TO WS-STATE
     CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
     MOVE 5 TO WS-DEPTH
     CALL "SH-PICK" USING WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-ROW
     MOVE "acceptance US12 36-5§4.4 Choosing from the table: v = 140 at depth 5 is rejected by doPlace: no portal room is made and its place count stays 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-ROW > 0
         IF SP-TYPE(WS-ROW) = 24
             MOVE 1 TO TL-OBSERVED-N
         ELSE
             MOVE SH-CNT(11) TO TL-OBSERVED-N
         END-IF
     ELSE
         MOVE SH-CNT(11) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIND-SEED.
     MOVE 0 TO WS-SEED
     MOVE 145 TO WS-BOUND
     MOVE -1 TO WS-V
     PERFORM UNTIL WS-V = WS-WANT
         ADD 1 TO WS-SEED
         MOVE WS-SEED TO WS-STATE
         CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-V
     END-PERFORM.
 END PROGRAM TEST-STRUCT-36-5-4-4.
