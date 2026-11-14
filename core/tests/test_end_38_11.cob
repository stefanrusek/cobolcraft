*> Implementation test (core/src/end-38d.cob; docs/protocol/38-end.md section 11, The End sky and the end flash): the flash parameters of windows 1, 2 and 5 (Java LCG seeded with the window; values computed independently), the intensity by the clock (none in window 0, the table sine over the visible span), and the first face of the end sky box.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-TOL                 BINARY-LONG VALUE 20.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-OFF                BINARY-LONG.
 01 WS-DUR                BINARY-LONG.
 01 WS-XA                 FLOAT-LONG.
 01 WS-YA                 FLOAT-LONG.
 01 WS-T                  BINARY-LONG.
 01 WS-U                  FLOAT-LONG.
 01 WS-IX                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-T
     CALL "END-FLASH-PARAMS" USING WS-T WS-OFF WS-DUR WS-XA WS-YA
     MOVE "acceptance US12 38§11 The End sky and the end flash window 1 offset" TO TL-CASE
     MOVE 133 TO TL-EXPECTED-N
     MOVE WS-OFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§11 The End sky and the end flash window 1 duration" TO TL-CASE
     MOVE 311 TO TL-EXPECTED-N
     MOVE WS-DUR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-XA TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash window 1 x angle" TO TL-CASE
     MOVE -314792156 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-YA TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash window 1 y angle" TO TL-CASE
     MOVE -1052226715 TO WS-WANT
     PERFORM CHECK-V
     MOVE 2 TO WS-T
     CALL "END-FLASH-PARAMS" USING WS-T WS-OFF WS-DUR WS-XA WS-YA
     MOVE "acceptance US12 38§11 The End sky and the end flash window 2 offset" TO TL-CASE
     MOVE 138 TO TL-EXPECTED-N
     MOVE WS-OFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§11 The End sky and the end flash window 2 duration" TO TL-CASE
     MOVE 296 TO TL-EXPECTED-N
     MOVE WS-DUR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-XA TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash window 2 x angle" TO TL-CASE
     MOVE -597090759 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-YA TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash window 2 y angle" TO TL-CASE
     MOVE -11438904 TO WS-WANT
     PERFORM CHECK-V
     MOVE 5 TO WS-T
     CALL "END-FLASH-PARAMS" USING WS-T WS-OFF WS-DUR WS-XA WS-YA
     MOVE "acceptance US12 38§11 The End sky and the end flash window 5 offset" TO TL-CASE
     MOVE 76 TO TL-EXPECTED-N
     MOVE WS-OFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§11 The End sky and the end flash window 5 duration" TO TL-CASE
     MOVE 198 TO TL-EXPECTED-N
     MOVE WS-DUR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-XA TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash window 5 x angle" TO TL-CASE
     MOVE -171727333 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-YA TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash window 5 y angle" TO TL-CASE
     MOVE -39943695 TO WS-WANT
     PERFORM CHECK-V
     MOVE 0 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 0 (window 0)" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     MOVE 599 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 599 (window 0)" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     MOVE 1234 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 1234 before the offset" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     MOVE 1338 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 1338 at the offset" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     MOVE 1486 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 1486 the peak of window 2" TO TL-CASE
     MOVE 10000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE 1635 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 1635 after the span" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     MOVE 811 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 811 a quarter into window 1" TO TL-CASE
     MOVE 7088672 TO WS-WANT
     PERFORM CHECK-V
     MOVE 888 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 888 the middle of window 1" TO TL-CASE
     MOVE 9999871 TO WS-WANT
     PERFORM CHECK-V
     MOVE 966 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 966" TO TL-CASE
     MOVE 7089348 TO WS-WANT
     PERFORM CHECK-V
     MOVE 3175 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 3175 the peak of window 5" TO TL-CASE
     MOVE 10000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE 3126 TO WS-T
     CALL "END-FLASH-INTENSITY" USING WS-T WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash intensity t 3126" TO TL-CASE
     MOVE 7126439 TO WS-WANT
     PERFORM CHECK-V
     MOVE 1 TO WS-IX
     CALL "END-SKY-VERTEX" USING WS-IX WS-X WS-Y WS-Z WS-F1 WS-F2
     MOVE WS-X TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 1 x" TO TL-CASE
     MOVE -1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Y TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 1 y" TO TL-CASE
     MOVE -1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Z TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 1 z" TO TL-CASE
     MOVE -1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-F1 TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 1 u" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-F2 TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 1 v" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     MOVE 2 TO WS-IX
     CALL "END-SKY-VERTEX" USING WS-IX WS-X WS-Y WS-Z WS-F1 WS-F2
     MOVE WS-X TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 2 x" TO TL-CASE
     MOVE -1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Y TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 2 y" TO TL-CASE
     MOVE -1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Z TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 2 z" TO TL-CASE
     MOVE 1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-F1 TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 2 u" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-F2 TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 2 v" TO TL-CASE
     MOVE 160000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE 3 TO WS-IX
     CALL "END-SKY-VERTEX" USING WS-IX WS-X WS-Y WS-Z WS-F1 WS-F2
     MOVE WS-X TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 3 x" TO TL-CASE
     MOVE 1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Y TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 3 y" TO TL-CASE
     MOVE -1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Z TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 3 z" TO TL-CASE
     MOVE 1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-F1 TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 3 u" TO TL-CASE
     MOVE 160000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-F2 TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 3 v" TO TL-CASE
     MOVE 160000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE 4 TO WS-IX
     CALL "END-SKY-VERTEX" USING WS-IX WS-X WS-Y WS-Z WS-F1 WS-F2
     MOVE WS-X TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 4 x" TO TL-CASE
     MOVE 1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Y TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 4 y" TO TL-CASE
     MOVE -1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Z TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 4 z" TO TL-CASE
     MOVE -1000000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-F1 TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 4 u" TO TL-CASE
     MOVE 160000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-F2 TO WS-V
     MOVE "acceptance US12 38§11 The End sky and the end flash sky box vertex 4 v" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-V
     STOP RUN.
 CHECK-V.
     COMPUTE WS-GOT ROUNDED = WS-V * 10000000
     COMPUTE WS-DIFF = WS-GOT - WS-WANT
     IF WS-DIFF < 0
         COMPUTE WS-DIFF = 0 - WS-DIFF
     END-IF
     MOVE WS-WANT TO TL-EXPECTED-N
     IF WS-DIFF <= WS-TOL
         MOVE WS-WANT TO TL-OBSERVED-N
     ELSE
         MOVE WS-GOT TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-END-38-11.
