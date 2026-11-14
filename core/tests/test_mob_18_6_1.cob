*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.1, with doc 44 part 1 section 4.7): the spawn cycle: which categories a tick tries.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-TIME               BINARY-DOUBLE.
 01 WS-MOBS               BINARY-LONG.
 01 WS-MONSTERS           BINARY-LONG.
 01 WS-CHUNKS             BINARY-LONG VALUE 289.
 01 WS-N                  BINARY-LONG.
 01 WS-COUNTS.
    05 WS-COUNT           BINARY-LONG OCCURS 8 TIMES.
 01 WS-FLAGS.
    05 WS-FLAG            BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION.
     INITIALIZE WS-COUNTS
     MOVE 1 TO WS-MOBS WS-MONSTERS
     MOVE 400 TO WS-TIME
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: on a tick with gameTime mod 400 = 0 all seven categories are tried" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: creature is the second category and is on" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FLAG(2) TO WS-O
     PERFORM CHECK-N

     MOVE 401 TO WS-TIME
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: on other ticks the creature category is left out (six remain)" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: the creature flag is 0 off the friendly cycle" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FLAG(2) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: monster stays on every tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FLAG(1) TO WS-O
     PERFORM CHECK-N

     MOVE 0 TO WS-MONSTERS
     MOVE 400 TO WS-TIME
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: spawn_monsters off drops the monster category only" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-E
     MOVE WS-FLAG(1) TO WS-O
     MOVE "acceptance US15 18§6.1 The spawn cycle: the monster flag is 0 with spawn_monsters off" TO WS-CASE
     PERFORM CHECK-N

     MOVE 0 TO WS-MOBS
     MOVE 1 TO WS-MONSTERS
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: spawn_mobs false makes the list empty" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-1§4.7 spawn_mobs false: no flag is set" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-FLAG(1) + WS-FLAG(2) + WS-FLAG(3) + WS-FLAG(7)
     PERFORM CHECK-N

     MOVE 1 TO WS-MOBS
     MOVE 70 TO WS-COUNT(1)
     CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
     MOVE "acceptance US15 18§6.1 The spawn cycle: a category at its global cap is left out" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FLAG(1) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-6-1.
