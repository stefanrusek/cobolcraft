*> Equivalence test (lane perfsteady): WORLD-ROW keeps the rows it found in a small table by chunk and takes one from it while the row is in use and holds that chunk; it must answer as the
*> pass over the rows (the program it replaces, kept here as REF-WORLD-ROW). 700 rows (view 12) are given chunks of a square, then 20000 random steps: a row is freed, given another chunk
*> (the reuse of a row by the replica), or given back; after each, WORLD-ROW and the pass are asked for a chunk drawn from the square (loaded or not) and for the chunk of the row just
*> changed: the answers are the same.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-ROW-MEMO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-SEED                BINARY-DOUBLE VALUE 99.
 01 WS-PICK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-REF                 BINARY-LONG.
 01 WS-DIFFER              BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG VALUE 0.
 01 WS-MISSED              BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE 700 TO WR-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 700
         MOVE 1 TO WR-USED(WS-I)
         COMPUTE WR-CX(WS-I) = FUNCTION MOD(WS-I - 1, 26) - 13
         COMPUTE WR-CZ(WS-I) = (WS-I - 1) / 26 - 13
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20000
         PERFORM DRAW
         COMPUTE WS-R = 1 + FUNCTION MOD(WS-PICK, 700)
         PERFORM DRAW
         COMPUTE WS-OP = FUNCTION MOD(WS-PICK, 8)
*>       A chunk is in one row at most (the replica's rule), so a row is given a chunk, or given back, only when no used row holds it.
         EVALUATE WS-OP
             WHEN 0
                 MOVE 0 TO WR-USED(WS-R)
             WHEN 1
                 MOVE WR-CX(WS-R) TO WS-CX
                 MOVE WR-CZ(WS-R) TO WS-CZ
                 CALL "REF-WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-REF
                 IF WS-REF = 0
                     MOVE 1 TO WR-USED(WS-R)
                 END-IF
             WHEN 2
                 PERFORM DRAW
                 COMPUTE WS-CX = FUNCTION MOD(WS-PICK, 30) - 15
                 PERFORM DRAW
                 COMPUTE WS-CZ = FUNCTION MOD(WS-PICK, 30) - 15
                 CALL "REF-WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-REF
                 IF WS-REF = 0
                     MOVE WS-CX TO WR-CX(WS-R)
                     MOVE WS-CZ TO WR-CZ(WS-R)
                     MOVE 1 TO WR-USED(WS-R)
                 END-IF
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
         PERFORM DRAW
         COMPUTE WS-CX = FUNCTION MOD(WS-PICK, 30) - 15
         PERFORM DRAW
         COMPUTE WS-CZ = FUNCTION MOD(WS-PICK, 30) - 15
         CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-GOT
         CALL "REF-WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-REF
         PERFORM CHECK
         MOVE WR-CX(WS-R) TO WS-CX
         MOVE WR-CZ(WS-R) TO WS-CZ
         CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-GOT
         CALL "REF-WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-REF
         PERFORM CHECK
     END-PERFORM
     MOVE "perfsteady: given 700 rows and 20000 random frees, reuses and queries when WORLD-ROW answers then it answers as the pass over the rows" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFFER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "perfsteady: the queries found chunks and missed chunks in good numbers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 5000 AND WS-MISSED > 5000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CHECK.
     IF WS-GOT NOT = WS-REF
         ADD 1 TO WS-DIFFER
     END-IF
     IF WS-REF > 0
         ADD 1 TO WS-FOUND
     ELSE
         ADD 1 TO WS-MISSED
     END-IF
     .
 DRAW.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     COMPUTE WS-PICK = FUNCTION MOD(WS-SEED / 65536, 32768)
     .
 END PROGRAM TEST-WORLD-ROW-MEMO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REF-WORLD-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT OR L-ROW > 0
         IF WR-USED(WS-R) = 1 AND WR-CX(WS-R) = L-CX AND WR-CZ(WS-R) = L-CZ
             MOVE WS-R TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REF-WORLD-ROW.
