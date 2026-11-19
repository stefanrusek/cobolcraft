*> Implementation test (T29500, US12-4; lane p46g report note): SW-SET-PROP kept property names in 16 byte fields, so a state with a longer name (the sculk sensors' sculk_sensor_phase, 18
*> characters) lost it: writing power changed the state text to "sculk_sensor_pha=..." and BLOCKS-STATE-OF found no state. SW-SET-PROP now keeps every name of the state text, and
*> SW-SET-PROP-L takes a name of up to 32 bytes (the long property is settable). Needs the generated packs (skipped without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SW-SET-PROP-LONG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-ST2                 BINARY-LONG.
 01 WS-ST3                 BINARY-LONG.
 01 WS-PN                  PIC X(16) VALUE "power".
 01 WS-PV                  PIC X(16).
 01 WS-LN                  PIC X(32) VALUE "sculk_sensor_phase".
 01 WS-OLD                 PIC X(16).
 01 WS-PROPS               PIC X(160).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "implementation sw-set-prop long names: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "sculk_sensor" TO WS-K
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     MOVE "5" TO WS-PV
     CALL "SW-SET-PROP" USING WS-ST WS-PN WS-PV WS-ST2 WS-OLD
     CALL "BLOCKS-STATE-PROPS" USING WS-ST2 WS-PROPS
     MOVE "implementation sw-set-prop: power of a sculk sensor keeps the 18 character phase name" TO TL-CASE
     MOVE "power=5,sculk_sensor_phase=inactive,waterlogged=false" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation sw-set-prop: the old value of power is returned" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE WS-OLD TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "active" TO WS-PV
     CALL "SW-SET-PROP-L" USING WS-ST2 WS-LN WS-PV WS-ST3 WS-OLD
     CALL "BLOCKS-STATE-PROPS" USING WS-ST3 WS-PROPS
     MOVE "implementation sw-set-prop-l: the long property sculk_sensor_phase is set" TO TL-CASE
     MOVE "power=5,sculk_sensor_phase=active,waterlogged=false" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation sw-set-prop-l: the old value of the phase is returned" TO TL-CASE
     MOVE "inactive" TO TL-EXPECTED
     MOVE WS-OLD TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SW-SET-PROP-LONG.

 COPY CORETEST.
 COPY PORTALTEST.
