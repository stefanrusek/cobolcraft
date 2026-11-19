*> The chunk lookup of WORLD-FIND remembers the row of the last chunk it found (lane perfframe: a mob's pathing reads one chunk thousands of times a tick) and
*> uses it only while the row is in use and holds that chunk: the same row for the same chunk, another chunk found in between and the first again, 0 for a chunk
*> the world no longer holds after it was reopened (the row of the memo is free), a chunk loaded again found at its new row. WORLD-GET-BLOCK and WORLD-PEEK-BLOCK
*> read the same state at positions on both sides of a chunk border, negative ones included. The cost of 20000 reads of one chunk is shown and bounded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-FIND-MEMO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CX2                 BINARY-LONG.
 01 WS-CZ2                 BINARY-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 60.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PEEK                BINARY-LONG.
 01 WS-SAME                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-D9                  PIC Z(8)9.
 01 WS-D9B                 PIC Z(8)9.
 01 WS-D9C                 PIC Z(8)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 2 TO WS-CX
     MOVE -3 TO WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW-A
     MOVE "T" TO TL-MODE
     MOVE "test world find memo: the same chunk twice is the same row, another chunk in between is another row, the first again is the first row" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "same other same" TO TL-EXPECTED
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 0 TO WS-I
     IF WS-ROW = WS-ROW-A
         MOVE 1 TO WS-I
     END-IF
     MOVE 3 TO WS-CX2
     MOVE -3 TO WS-CZ2
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX2 WS-CZ2 WS-ROW-B
     CALL "WORLD-FIND" USING WS-DIM WS-CX2 WS-CZ2 WS-ROW
     IF WS-ROW NOT = WS-ROW-A AND WS-ROW = WS-ROW-B AND WS-I = 1
         MOVE 2 TO WS-I
     END-IF
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     IF WS-ROW = WS-ROW-A AND WS-I = 2
         MOVE "same other same" TO TL-OBSERVED
     ELSE
         MOVE "differs" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Reads on both sides of the border between chunk (2, -3) and (3, -3): x 79 and 80, z -33 (z -48 to -33).
     MOVE 0 TO WS-SAME
     PERFORM VARYING WS-X FROM 78 BY 1 UNTIL WS-X > 81
         PERFORM VARYING WS-Z FROM -48 BY 7 UNTIL WS-Z > -33
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             CALL "WORLD-PEEK-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-PEEK
             IF WS-STATE = WS-PEEK
                 ADD 1 TO WS-SAME
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "test world find memo: get block and peek block agree on both sides of a chunk border" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Reopening the world frees the rows: the chunk is not found, and loaded again it is.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE "T" TO TL-MODE
     MOVE "test world find memo: after the world was reopened the remembered chunk is not found, and found again once it is loaded" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "0 found" TO TL-EXPECTED
     MOVE WS-ROW TO WS-D9
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW-A
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE WS-ROW TO WS-D9B
     IF WS-D9 = "        0" AND WS-ROW = WS-ROW-A AND WS-ROW > 0
         MOVE "0 found" TO TL-OBSERVED
     ELSE
         STRING "before " FUNCTION TRIM(WS-D9) " after " FUNCTION TRIM(WS-D9B) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The cost of reading one chunk: 20000 reads.
     MOVE 8 TO WS-X
     MOVE -40 TO WS-Z
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW-A
     CALL STATIC "clock" RETURNING WS-T0
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 80
         PERFORM VARYING WS-X FROM 32 BY 1 UNTIL WS-X > 47
             PERFORM VARYING WS-Z FROM -48 BY 1 UNTIL WS-Z > -33
                 CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL STATIC "clock" RETURNING WS-T1
     COMPUTE WS-US = WS-T1 - WS-T0
     MOVE WS-US TO WS-D9C
     DISPLAY "PERF 20000 WORLD-GET-BLOCK reads of one chunk: " WS-D9C " us"
     MOVE "test world find memo: 20000 reads of one chunk take less than 10 ms of CPU time (about 29 ms before the memo)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-US < 10000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WORLD-FIND-MEMO.
 COPY CORETEST.
