*> Coverage test for corners of the light engine (core/src/light-32b.cob to light-32e.cob; docs/protocol/32-light-engine.md sections 5, 6 and 8): a new sky layer below a
*> gap of sections that store no light copies the first row of the next storing section above (6.6); removing a light source finds a neighbour with its own emission (5.1);
*> a sky check below the lowest source clears a lit cell (5.2); a lit cell on a section's west edge spreads east through the empty sections below the neighbour (5.2);
*> the client deque keeps the tasks it did not run (8.2); the server asks for an update while either engine has work (8.3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-COVB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY L32.
 01 W-A                    BINARY-LONG.
 01 W-B                    BINARY-LONG.
 01 W-C                    BINARY-LONG.
 01 W-D                    BINARY-LONG.
 01 W-E                    BINARY-LONG.
 01 W-F                    BINARY-LONG.
 01 W-G                    BINARY-LONG.
 01 W-H                    BINARY-LONG.
 01 W-I                    BINARY-LONG.
 01 W-J                    BINARY-LONG.
 01 W-K                    BINARY-LONG.
 01 W-L                    BINARY-LONG.
 01 W-R                    BINARY-LONG.
 01 W-R2                   BINARY-LONG.
 01 W-SHOW                 PIC -(10)9.
 01 W-PTR                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 32§6 sky layer creation: a section below a gap of sections that store no light copies the first Y row of the next storing section above (levels at x 3 and 4)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO W-A
     CALL "L32-INIT" USING W-A
     MOVE 2 TO W-A MOVE 6 TO W-B MOVE 1 TO W-C
     CALL "L32-STORAGE-ENABLE" USING W-A W-B W-C
     MOVE 2 TO W-A MOVE 0 TO W-B MOVE 4 TO W-C MOVE 0 TO W-D MOVE 0 TO W-E
     CALL "L32-STORAGE-STATUS" USING W-A W-B W-C W-D W-E
     MOVE 2 TO W-A
     CALL "L32-STORAGE-FINISH" USING W-A
     MOVE 2 TO W-A MOVE 3 TO W-B MOVE 48 TO W-C MOVE 4 TO W-D MOVE 5 TO W-E
     CALL "L32-SET-STORED" USING W-A W-B W-C W-D W-E
     MOVE 2 TO W-A
     CALL "L32-STORAGE-FINISH" USING W-A
     MOVE 2 TO W-A MOVE 0 TO W-B MOVE 0 TO W-C MOVE 0 TO W-D MOVE 0 TO W-E
     CALL "L32-STORAGE-STATUS" USING W-A W-B W-C W-D W-E
     MOVE 2 TO W-A
     CALL "L32-STORAGE-FINISH" USING W-A
     MOVE 2 TO W-A MOVE 3 TO W-B MOVE -5 TO W-C MOVE 4 TO W-D
     CALL "L32-GET-PUBLISHED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 4 TO W-B
     CALL "L32-GET-PUBLISHED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE "5 15" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 32§5 propagateDecrease: removing a level 14 torch next to a cell with its own emission 5 keeps that cell at 5 and the cells beyond it at 4 and 3 (levels before and after)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO W-A
     CALL "L32-INIT" USING W-A
     MOVE 4 TO W-A MOVE 14 TO W-B
     PERFORM DEFINE-LIGHT-STATE
     MOVE 12 TO W-A MOVE 5 TO W-B
     PERFORM DEFINE-LIGHT-STATE
     PERFORM SETUP-WORLD
     PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > 16
         MOVE 1 TO W-A MOVE W-I TO W-B MOVE 1 TO W-C
         CALL "L32-STORAGE-ENABLE" USING W-A W-B W-C
     END-PERFORM
     PERFORM VARYING W-I FROM -1 BY 1 UNTIL W-I > 2
         PERFORM VARYING W-J FROM 0 BY 1 UNTIL W-J > 3
             PERFORM VARYING W-K FROM -1 BY 1 UNTIL W-K > 2
                 MOVE 1 TO W-A MOVE W-I TO W-B MOVE W-J TO W-C MOVE W-K TO W-D MOVE 0 TO W-E
                 CALL "L32-STORAGE-STATUS" USING W-A W-B W-C W-D W-E
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 1 TO W-A
     CALL "L32-STORAGE-FINISH" USING W-A
     MOVE 8 TO W-A MOVE 20 TO W-B MOVE 8 TO W-C MOVE 4 TO W-D
     CALL "L32-SET-CELL" USING W-A W-B W-C W-D
     MOVE 9 TO W-A MOVE 20 TO W-B MOVE 8 TO W-C MOVE 12 TO W-D
     CALL "L32-SET-CELL" USING W-A W-B W-C W-D
     MOVE 1 TO W-A MOVE 8 TO W-B MOVE 20 TO W-C MOVE 8 TO W-D
     CALL "L32-CHECK-BLOCK" USING W-A W-B W-C W-D
     MOVE 9 TO W-B
     CALL "L32-CHECK-BLOCK" USING W-A W-B W-C W-D
     MOVE 1 TO W-A
     CALL "L32-RUN-UPDATES" USING W-A W-R
     MOVE 1 TO W-A MOVE 9 TO W-B MOVE 20 TO W-C MOVE 8 TO W-D
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 8 TO W-B MOVE 0 TO W-E
     MOVE 8 TO W-E
     MOVE 8 TO W-A MOVE 20 TO W-B MOVE 8 TO W-C MOVE 0 TO W-D
     CALL "L32-SET-CELL" USING W-A W-B W-C W-D
     MOVE 1 TO W-A MOVE 8 TO W-B MOVE 20 TO W-C MOVE 8 TO W-D
     CALL "L32-CHECK-BLOCK" USING W-A W-B W-C W-D
     MOVE 1 TO W-A
     CALL "L32-RUN-UPDATES" USING W-A W-R
     MOVE 1 TO W-A MOVE 9 TO W-B MOVE 20 TO W-C MOVE 8 TO W-D
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 10 TO W-B
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 7 TO W-B
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE "13 5 4 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 32§5 sky check: a cell below the lowest source that holds a level other than 15 is set to 0 (levels at y 20, 21 and 19 of the column)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO W-A
     CALL "L32-INIT" USING W-A
     MOVE 0 TO W-A MOVE 0 TO W-B MOVE 1 TO W-C
     CALL "L32-AVAIL-CHUNK" USING W-A W-B W-C
     MOVE 2 TO W-A MOVE 6 TO W-B MOVE 1 TO W-C
     CALL "L32-STORAGE-ENABLE" USING W-A W-B W-C
     MOVE 2 TO W-A MOVE 0 TO W-B MOVE 1 TO W-C MOVE 0 TO W-D MOVE 0 TO W-E
     CALL "L32-STORAGE-STATUS" USING W-A W-B W-C W-D W-E
     MOVE 2 TO W-A
     CALL "L32-STORAGE-FINISH" USING W-A
     MOVE 2 TO W-A MOVE 8 TO W-B MOVE 20 TO W-C MOVE 8 TO W-D MOVE 7 TO W-E
     CALL "L32-SET-STORED" USING W-A W-B W-C W-D W-E
     MOVE 40 TO EN-LS(6, 137)
     MOVE 2 TO W-A MOVE 8 TO W-B MOVE 20 TO W-C MOVE 8 TO W-D
     CALL "L32-SKY-CHECK" USING W-B W-C W-D
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 21 TO W-C
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 19 TO W-C
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE "0 0 15" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 32§5 propagateFromEmptySections: a level 15 cell on the east edge of a section spreads east into the sections below that store no light (mirror of the west edge worked example)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO W-A
     CALL "L32-INIT" USING W-A
     PERFORM SETUP-WORLD
     MOVE 2 TO W-A MOVE 2 TO W-B MOVE 0 TO W-C MOVE 0 TO W-D MOVE 0 TO W-E
     CALL "L32-STORAGE-STATUS" USING W-A W-B W-C W-D W-E
     MOVE 2 TO W-A MOVE 0 TO W-B MOVE 3 TO W-C MOVE 0 TO W-D MOVE 0 TO W-E
     CALL "L32-STORAGE-STATUS" USING W-A W-B W-C W-D W-E
     MOVE 2 TO W-A
     CALL "L32-STORAGE-FINISH" USING W-A
     MOVE 2 TO W-A MOVE 15 TO W-B MOVE 32 TO W-C MOVE 5 TO W-D MOVE 15 TO W-E
     CALL "L32-SET-STORED" USING W-A W-B W-C W-D W-E
     MOVE 1007 TO W-E
     CALL "L32-PUSH-INC" USING W-A W-B W-C W-D W-E
     MOVE 2 TO W-A
     CALL "L32-RUN-UPDATES" USING W-A W-R
     MOVE 2 TO W-A MOVE 16 TO W-B MOVE 32 TO W-C MOVE 5 TO W-D
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 31 TO W-C
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE -16 TO W-C
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE -17 TO W-C
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 17 TO W-B MOVE 31 TO W-C
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 14 TO W-B MOVE 32 TO W-C
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE 15 TO W-B MOVE 4 TO W-D
     CALL "L32-GET-STORED" USING W-A W-B W-C W-D W-R
     PERFORM ADD-R
     MOVE "14 14 14 0 13 14 14" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 32§8.2 client update: 12 queued tasks run 10 (max(10, n / 10)) and the 2 left stay queued and run in the next frame (ran, left; ran, left)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO W-A
     CALL "L32-INIT" USING W-A
     PERFORM SETUP-WORLD
     PERFORM 12 TIMES
         MOVE 2 TO W-A MOVE 0 TO W-B MOVE 0 TO W-C
         CALL "L32-CLIENT-QUEUE" USING W-A W-B W-C
     END-PERFORM
     CALL "L32-CLIENT-UPDATE" USING W-R W-R2
     PERFORM ADD-R
     MOVE EN-CT-N TO W-R
     PERFORM ADD-R
     CALL "L32-CLIENT-UPDATE" USING W-R W-R2
     PERFORM ADD-R
     MOVE EN-CT-N TO W-R
     PERFORM ADD-R
     MOVE "10 2 2 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 32§8.3 server needs an update: with no task pending the block engine's work gives 1, drained gives 0, the sky engine's work gives 1 again (needs, needs, needs)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO W-A
     CALL "L32-INIT" USING W-A
     PERFORM SETUP-WORLD
     MOVE 1 TO W-A MOVE 8 TO W-B MOVE 20 TO W-C MOVE 8 TO W-D
     CALL "L32-CHECK-BLOCK" USING W-A W-B W-C W-D
     CALL "L32-SERVER-NEEDS" USING W-R
     PERFORM ADD-R
     CALL "L32-RUN-UPDATES" USING W-A W-R
     CALL "L32-SERVER-NEEDS" USING W-R
     PERFORM ADD-R
     MOVE 2 TO W-A
     CALL "L32-CHECK-BLOCK" USING W-A W-B W-C W-D
     CALL "L32-SERVER-NEEDS" USING W-R
     PERFORM ADD-R
     MOVE "1 0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO W-PTR
     .

 ADD-R.
     MOVE W-R TO W-SHOW
     IF W-PTR > 1
         STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER W-PTR
     END-IF
     STRING FUNCTION TRIM(W-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER W-PTR
     .

 DEFINE-LIGHT-STATE.
     MOVE 0 TO W-C W-D W-E W-F W-G W-H W-I W-J W-K
     CALL "L32-DEFINE-STATE" USING W-A W-B W-C W-D W-E W-F W-G W-H W-I W-J W-K
     .

 SETUP-WORLD.
     PERFORM VARYING W-I FROM -1 BY 1 UNTIL W-I > 2
         PERFORM VARYING W-J FROM -1 BY 1 UNTIL W-J > 2
             MOVE W-I TO W-A MOVE W-J TO W-B MOVE 1 TO W-C
             CALL "L32-AVAIL-CHUNK" USING W-A W-B W-C
         END-PERFORM
     END-PERFORM
     .
 END PROGRAM TEST-LIGHT-COVB.
