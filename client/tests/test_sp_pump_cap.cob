*> Implementation test of the tick cap of SP-PUMP (client/src/sp-host.cob; operator playtest: one long
*> tick left many owed and they all ran back to back in the next frame): at most CL-MAX-PUMP-TICKS
*> (3) core ticks run in a frame; a debt of more than CL-PUMP-DEBT-MS (250) after them is dropped,
*> a smaller one is spread over the next frames.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SP-PUMP-CAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-sp-pump-cap".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-FOLDER              PIC X(80) VALUE "First".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-NAME                PIC X(64) VALUE "First".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED

*>   A debt of 100 owed ticks (5 s): 3 run, the rest is dropped (the next frame owes none).
     MOVE 5000000 TO CL-NOW-MS
     COMPUTE SP-NEXT-TICK = CL-NOW-MS - 5000
     MOVE SP-TICKS TO WS-BEFORE
     CALL "SP-PUMP" USING CLIENT-STATE
     COMPUTE WS-A = SP-TICKS - WS-BEFORE
     MOVE SP-TICKS TO WS-BEFORE
     CALL "SP-PUMP" USING CLIENT-STATE
     COMPUTE WS-B = SP-TICKS - WS-BEFORE
     MOVE "sp pump a debt of 5 seconds runs 3 ticks in the frame and drops the rest" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "first 3 second 0" TO TL-EXPECTED
     MOVE WS-A TO WS-E1
     MOVE WS-B TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "first " FUNCTION TRIM(WS-E1) " second " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A debt of 200 ms (5 owed ticks: 3, then 2 in the next frame, then none).
     ADD 100 TO CL-NOW-MS
     COMPUTE SP-NEXT-TICK = CL-NOW-MS - 200
     MOVE SP-TICKS TO WS-BEFORE
     CALL "SP-PUMP" USING CLIENT-STATE
     COMPUTE WS-A = SP-TICKS - WS-BEFORE
     MOVE SP-TICKS TO WS-BEFORE
     CALL "SP-PUMP" USING CLIENT-STATE
     COMPUTE WS-B = SP-TICKS - WS-BEFORE
     MOVE SP-TICKS TO WS-BEFORE
     CALL "SP-PUMP" USING CLIENT-STATE
     COMPUTE WS-C = SP-TICKS - WS-BEFORE
     MOVE "sp pump a debt of 200 ms (5 ticks) is spread: 3 ticks, then 2, then none" TO TL-CASE
     MOVE "3 2 0" TO TL-EXPECTED
     MOVE WS-A TO WS-E1
     MOVE WS-B TO WS-E2
     MOVE WS-C TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   One owed tick (the normal case) runs one.
     ADD 100 TO CL-NOW-MS
     COMPUTE SP-NEXT-TICK = CL-NOW-MS
     MOVE SP-TICKS TO WS-BEFORE
     CALL "SP-PUMP" USING CLIENT-STATE
     COMPUTE WS-A = SP-TICKS - WS-BEFORE
     MOVE "sp pump one owed tick runs one tick" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SP-PUMP-CAP.
 COPY CLTEST.
