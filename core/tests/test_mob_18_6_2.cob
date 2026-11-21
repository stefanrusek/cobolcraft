*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.2, with doc 44 part 1 section 4): which chunks count for spawning.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PCX                BINARY-LONG VALUE 0.
 01 WS-PCZ                BINARY-LONG VALUE 0.
 01 WS-CX                 BINARY-LONG.
 01 WS-CZ                 BINARY-LONG.
 01 WS-PX                 FLOAT-LONG VALUE 8.0.
 01 WS-PZ                 FLOAT-LONG VALUE 8.0.
 01 WS-NEAR               BINARY-LONG.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-OTHER              BINARY-LONG.
 01 WS-OTHER-CONN         BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-COUNT              BINARY-LONG.
 01 WS-NAME               PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH        BINARY-LONG VALUE 5.
 PROCEDURE DIVISION.
     MOVE 5 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "MS6-CHUNK-NEAR" USING WS-PCX WS-PCZ WS-CX WS-CZ WS-PX WS-PZ WS-NEAR
     MOVE "acceptance US15 18§6.2 Which chunks count: a chunk 5 chunks away (the inscribed square) has players nearby" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-NEAR TO WS-O
     PERFORM CHECK-N
     MOVE 9 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "MS6-CHUNK-NEAR" USING WS-PCX WS-PCZ WS-CX WS-CZ WS-PX WS-PZ WS-NEAR
     MOVE "acceptance US15 18§6.2 Which chunks count: beyond 8 chunks the tracker says no" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-NEAR TO WS-O
     PERFORM CHECK-N
     MOVE 6 TO WS-CX
     CALL "MS6-CHUNK-NEAR" USING WS-PCX WS-PCZ WS-CX WS-CZ WS-PX WS-PZ WS-NEAR
     MOVE "acceptance US15 18§6.2 Which chunks count: chunk 6 centre is 96 blocks away, squared 9216 below 16384" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-NEAR TO WS-O
     PERFORM CHECK-N
     MOVE 8 TO WS-CX
     CALL "MS6-CHUNK-NEAR" USING WS-PCX WS-PCZ WS-CX WS-CZ WS-PX WS-PZ WS-NEAR
     MOVE "acceptance US15 18§6.2 Which chunks count: exactly 128 blocks (16384) is not strictly below" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-NEAR TO WS-O
     PERFORM CHECK-N
     MOVE 7 TO WS-CX
     MOVE 7 TO WS-CZ
     CALL "MS6-CHUNK-NEAR" USING WS-PCX WS-PCZ WS-CX WS-CZ WS-PX WS-PZ WS-NEAR
     MOVE "acceptance US15 18§6.2 Which chunks count: the diagonal chunk 7,7 is 147 blocks away" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-NEAR TO WS-O
     PERFORM CHECK-N

     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "MS6-CANDIDATE-COUNT" USING WS-DIM WS-COUNT
     MOVE "acceptance US15 18§6.2 Which chunks count: one player marks a 17 x 17 square of 289 chunks" TO WS-CASE
     MOVE 289 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-OTHER-CONN
     MOVE CN-PLAYER(WS-OTHER-CONN) TO WS-OTHER
     CALL "MS6-CANDIDATE-COUNT" USING WS-DIM WS-COUNT
     MOVE "acceptance US15 18§6.2 Which chunks count: two players on one spot count the distinct chunks, 289" TO WS-CASE
     MOVE 289 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     COMPUTE PL-X(WS-OTHER) = PL-X(WS-OTHER) + 320
     CALL "MS6-CANDIDATE-COUNT" USING WS-DIM WS-COUNT
     MOVE "acceptance US15 18§6.2 Which chunks count: two players 20 chunks apart mark 578 chunks" TO WS-CASE
     MOVE 578 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO PL-MODE(WS-OTHER)
     CALL "MS6-CANDIDATE-COUNT" USING WS-DIM WS-COUNT
     MOVE "acceptance US15 18§6.2 Which chunks count: a spectator marks nothing" TO WS-CASE
     MOVE 289 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-DIM = WS-DIM + 7
     CALL "MS6-CANDIDATE-COUNT" USING WS-DIM WS-COUNT
     MOVE "acceptance US15 18§6.2 Which chunks count: a dimension without players has none" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-6-2.
 COPY CORETEST.
 COPY MOBSPTEST.
