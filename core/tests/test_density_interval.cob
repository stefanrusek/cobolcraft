*> Implementation test of the density node interval_select (core/src/density.cob; docs/protocol/11 section 2.3, read from the artifact's
*> IntervalSelectFunction): the input is evaluated, then only the function at the first threshold that is strictly greater than the input
*> (the last function when the input is at or above every threshold) is evaluated. The overworld's caves/entrances (spaghetti 3D) and
*> caves/spaghetti_2d use it; a loader that dropped its fields made it read 0, which made every column of entrances negative and
*> opened a sheer hole under every hill. Fixture tree core/tests/fixtures/interval (gradients on x, y and z so that no noise code is needed).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DENSITY-INTERVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/interval".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-ROWS.
*>   function (4 or 2), x, y, z, expected value
    05 FILLER PIC X(48) VALUE "4 +0 +5 +0 +10".
    05 FILLER PIC X(48) VALUE "4 +1 +5 +0 +20".
    05 FILLER PIC X(48) VALUE "4 +2 +5 +0 +50".
    05 FILLER PIC X(48) VALUE "4 +2 +2 +0 +20".
    05 FILLER PIC X(48) VALUE "4 +3 +5 +0 +40".
    05 FILLER PIC X(48) VALUE "4 +4 +5 +0 +40".
    05 FILLER PIC X(48) VALUE "4 -3 +5 +0 +10".
    05 FILLER PIC X(48) VALUE "2 +0 +5 +0 +3".
    05 FILLER PIC X(48) VALUE "2 +2 +5 +2 +3".
    05 FILLER PIC X(48) VALUE "2 +2 +5 +3 +50".
    05 FILLER PIC X(48) VALUE "2 +0 +5 +3 +10".
 01 WS-ROW-TABLE REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(48) OCCURS 11 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-EDIT                PIC Z9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "WORLDGEN-FREE"
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     MOVE "test density interval the fixture functions load" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DENSITY-SETUP" USING WS-SEED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         UNSTRING WS-ROW(WS-I) DELIMITED BY SPACE INTO WS-F WS-X WS-Y WS-Z WS-WANT
         MOVE SPACES TO WS-KEY
         IF WS-F = 4
             MOVE "minecraft:t/pick4" TO WS-KEY
         ELSE
             MOVE "minecraft:t/pick2" TO WS-KEY
         END-IF
         CALL "DENSITY-EVAL" USING WS-KEY WS-X WS-Y WS-Z WS-R
         COMPUTE WS-GOT = WS-R
         MOVE WS-I TO WS-EDIT
         MOVE SPACES TO TL-CASE
         STRING "test density interval row " FUNCTION TRIM(WS-EDIT) " picks the function of the first threshold above the input"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-WANT TO TL-EXPECTED-N
         MOVE WS-GOT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-DENSITY-INTERVAL.
