*> Test of WORLDSIM-COLUMN-TOP (core/src/worldsim-33d.cob): the top of a column of a loaded chunk, read from the chunk a section at a time, is what the walk down
*> from the build limit with WORLD-GET-BLOCK finds (one above the highest non-void block; the lowest y for an empty column), for columns of the world,
*> an empty column, a block at the very top and at the very bottom of the dimension, and column (4000, 4005) of a chunk that is not loaded yet (the walk itself, which loads it).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLDSIM-COLUMN-TOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BRUTE               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-GS                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CR-GREYSTONE TO WS-GS
     MOVE CB-DEFAULT-STATE(WS-GS + 1) TO WS-GS
     MOVE DM-MIN-Y(WS-DIM) TO WS-MIN
     COMPUTE WS-LAST = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM) - 1
*>   An empty column: clear a column of the first chunk by hand from the top, a block at the top and one at the bottom of others.
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     PERFORM VARYING WS-Y FROM WS-LAST BY -1 UNTIL WS-Y < WS-MIN
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     END-PERFORM
     MOVE 6 TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-LAST WS-Z WS-GS
     MOVE 7 TO WS-X
     PERFORM VARYING WS-Y FROM WS-LAST BY -1 UNTIL WS-Y < WS-MIN
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-MIN WS-Z WS-GS
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         COMPUTE WS-X = WS-I - 5
         COMPUTE WS-Z = WS-I * 3 - 20
         IF WS-I = 5 OR WS-I = 6 OR WS-I = 7
             MOVE WS-I TO WS-X
             MOVE 5 TO WS-Z
         END-IF
         IF WS-I = 15
             MOVE 4000 TO WS-X
             MOVE 4005 TO WS-Z
         END-IF
         CALL "WORLDSIM-COLUMN-TOP" USING WS-DIM WS-X WS-Z WS-TOP
         MOVE WS-MIN TO WS-BRUTE
         PERFORM VARYING WS-Y FROM WS-LAST BY -1 UNTIL WS-Y < WS-MIN OR WS-BRUTE > WS-MIN
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE NOT = 0
                 COMPUTE WS-BRUTE = WS-Y + 1
             END-IF
         END-PERFORM
         IF WS-TOP NOT = WS-BRUTE
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "worldsim-column-top given 16 columns of the world, an empty one, one with a block at the top and one with a block at the "
         & "bottom when asked then every top equals the walk's" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE WS-BAD TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The three made columns, by value.
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     CALL "WORLDSIM-COLUMN-TOP" USING WS-DIM WS-X WS-Z WS-TOP
     MOVE WS-TOP TO WS-E1
     MOVE 6 TO WS-X
     CALL "WORLDSIM-COLUMN-TOP" USING WS-DIM WS-X WS-Z WS-TOP
     MOVE WS-TOP TO WS-E2
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 7 TO WS-X
     CALL "WORLDSIM-COLUMN-TOP" USING WS-DIM WS-X WS-Z WS-TOP
     MOVE WS-TOP TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-TOP = WS-LAST + 1
     MOVE WS-MIN TO WS-E1
     MOVE WS-TOP TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-EXPECTED
     COMPUTE WS-TOP = WS-MIN + 1
     MOVE WS-TOP TO WS-E1
     STRING FUNCTION TRIM(TL-EXPECTED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "worldsim-column-top given an empty column, a block at the build limit and one at the lowest y when asked then "
         & "the tops are the lowest y, one above the limit and the lowest y plus 1" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WORLDSIM-COLUMN-TOP.

 COPY CORETEST.
