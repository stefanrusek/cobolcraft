*> Test (US15; docs/protocol/19 sections 1.4 and 6.1): the wolf's spawn floor (wolves_spawnable_on: grass_block, snow, snow_block, coarse_dirt, podzol) in core/src/mob-19-1.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-KEY                PIC X(24).
 01 WS-KEY48              PIC X(48).
 01 WS-CLASS              BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-FLOORS.
    05 FILLER PIC X(25) VALUE "1grass_block".
    05 FILLER PIC X(25) VALUE "1snow".
    05 FILLER PIC X(25) VALUE "1podzol".
    05 FILLER PIC X(25) VALUE "0stone".
    05 FILLER PIC X(25) VALUE "0sand".
 01 WS-TABLE REDEFINES WS-FLOORS.
    05 WS-ROW OCCURS 5 TIMES.
       10 WS-WANT           PIC 9.
       10 WS-NAME           PIC X(24).
 PROCEDURE DIVISION.
     MOVE "wolf" TO WS-KEY
     CALL "M19-SPECIES-FLOOR" USING WS-KEY WS-CLASS
     MOVE "acceptance US15 19§6.1 Wolf: the wolf has floor class 7" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-CLASS TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE SPACES TO WS-KEY48
         MOVE WS-NAME(WS-I) TO WS-KEY48
         CALL "M19-FLOOR-OK" USING WS-CLASS WS-KEY48 WS-OK
         MOVE "acceptance US15 19§6.1 Wolf: wolves spawn on grass, snow, snow block, coarse dirt and podzol only" TO WS-CASE
         MOVE WS-WANT(WS-I) TO WS-E
         MOVE WS-OK TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     MOVE "coarse_dirt" TO WS-KEY48
     CALL "M19-FLOOR-OK" USING WS-CLASS WS-KEY48 WS-OK
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE "snow_block" TO WS-KEY48
     CALL "M19-FLOOR-OK" USING WS-CLASS WS-KEY48 WS-OK
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-6.
