*> Implementation test (lane covB; docs/protocol/36-structures-5-mineshaft-stronghold.md section 3): the stronghold assembly's limits: a piece made when the piece table is full, a pick whose
*> only drawn class is at its quota (nothing placed), a piece generated past depth 50 and the children of a piece that has no orientation.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-STRONGHOLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTSH.
 01 WS-X                   BINARY-LONG VALUE 1000.
 01 WS-Y                   BINARY-LONG VALUE 40.
 01 WS-Z                   BINARY-LONG VALUE 1000.
 01 WS-DIR                 BINARY-LONG VALUE 2.
 01 WS-DEPTH               BINARY-LONG VALUE 3.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CLASS               BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT0              BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-A                   BINARY-LONG VALUE 0.
 01 WS-B                   BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG VALUE 29.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 62.
 01 WS-CZ                  BINARY-LONG VALUE 62.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "SPB-RESET"
     CALL "SH-RESET"
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-SEED WS-CX WS-CZ
*>   A full piece table: the piece cannot be added, no row comes back.
     MOVE SP-COUNT TO WS-COUNT0
     MOVE SP-MAX TO SP-COUNT
     CALL "SH-MAKE" USING WS-CLASS WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-ROW
     MOVE WS-COUNT0 TO SP-COUNT
     MOVE "covB 36-5 3 a stronghold piece made with the piece table full gives no row" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A pick whose drawn class is at its quota places nothing of it (the class 1 here has weight 10 and one allowed piece, already placed; class 2 keeps the pick going).
     CALL "SH-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE 0 TO SH-IN(WS-I)
     END-PERFORM
     MOVE 1 TO SH-IN(1)
     MOVE 10 TO SH-W(1)
     MOVE 1 TO SH-MAX(1)
     MOVE 1 TO SH-CNT(1)
     MOVE 1 TO SH-IN(2)
     MOVE 0 TO SH-W(2)
     MOVE 5 TO SH-MAX(2)
     MOVE 0 TO SH-CNT(2)
     MOVE 0 TO SH-PREV SH-IMPOSED
     CALL "SH-PICK" USING WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-ROW
     MOVE "covB 36-5 3 a class at its quota is not placed again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SH-CNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Past depth 50 nothing is generated.
     MOVE 51 TO WS-DEPTH
     CALL "SH-GEN-ADD" USING WS-X WS-Y WS-Z WS-DIR WS-DEPTH WS-ROW
     MOVE "covB 36-5 3 a piece asked for at depth 51 is not generated" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A piece with no orientation has no children.
     CALL "SPB-RESET"
     MOVE 10 TO B-X0
     MOVE 40 TO B-Y0
     MOVE 10 TO B-Z0
     MOVE 14 TO B-X1
     MOVE 44 TO B-Y1
     MOVE 14 TO B-Z1
     MOVE -1 TO WS-DIR
     MOVE 0 TO WS-DEPTH
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-DEPTH WS-NONE WS-BOX WS-ROW
     MOVE SP-COUNT TO WS-COUNT0
     CALL "SH-CHILD" USING WS-ROW WS-KIND WS-A WS-B
     MOVE "covB 36-5 3.5 a piece with no orientation gets no child" TO TL-CASE
     MOVE WS-COUNT0 TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-STRONGHOLD.
