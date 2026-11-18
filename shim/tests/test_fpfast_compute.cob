*> Implementation test of arithmetic on float fields as a COBOL program sees it, with and without FPFAST (tools/package.mk; shim/src/cc_fpfast.c): every case
*> holds in both settings. Float results are compared within 1e-9 (libcob alone loses the last digits of a float operand; the overlay computes in IEEE
*> double: test_cc_fpfast.c has the exact comparison); the cases that the overlay passes on to libcob are compared exactly: a division by zero raises the
*> size error, a float expression compared with a decimal literal, an operand above 2^53, a decimal computed from decimals.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FPFAST-COMPUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-A                   FLOAT-LONG VALUE 1.5.
 01 WS-B                   FLOAT-LONG VALUE 0.25.
 01 WS-C                   FLOAT-LONG VALUE 3.
 01 WS-R                   FLOAT-LONG.
 01 WS-WANT                FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-S                   FLOAT-SHORT VALUE 2.5.
 01 WS-S2                  FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG VALUE 7.
 01 WS-BIG                 BINARY-DOUBLE VALUE 9007199254740993.
 01 WS-BIG2                BINARY-DOUBLE.
 01 WS-DEC                 PIC S9(5)V9(4) VALUE 123.4567.
 01 WS-DEC2                PIC S9(5)V9(4).
 01 WS-FLAG                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-R
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000
         COMPUTE WS-R = WS-R + WS-A * WS-B - WS-C / 7
     END-PERFORM
     MOVE -53.5714285714 TO WS-WANT
     MOVE "fpfast compute given a float expression summed 1000 times then the sum is 1000 * (1.5 * 0.25 - 3 / 7) within 1e-9" TO TL-CASE
     PERFORM CHECK-NEAR

     COMPUTE WS-R = (WS-A + WS-B) * (WS-A - WS-B) / WS-N
     MOVE 0.3125 TO WS-WANT
     MOVE "fpfast compute given floats and a BINARY-LONG then (1.5 + 0.25) * (1.5 - 0.25) / 7 is 0.3125" TO TL-CASE
     PERFORM CHECK-NEAR

     COMPUTE WS-S2 = WS-S * WS-B + 1
     MOVE WS-S2 TO WS-R
     MOVE 1.625 TO WS-WANT
     MOVE "fpfast compute given FLOAT-SHORT and FLOAT-LONG operands then a FLOAT-SHORT target holds 2.5 * 0.25 + 1" TO TL-CASE
     PERFORM CHECK-NEAR

     COMPUTE WS-I = WS-A * 100
     MOVE "fpfast compute given 1.5 * 100 then a BINARY-LONG target holds 150" TO TL-CASE
     MOVE 150 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     COMPUTE WS-I ROUNDED = WS-B * 10
     MOVE "fpfast compute given 0.25 * 10 ROUNDED then a BINARY-LONG target holds 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-FLAG
     MOVE 99 TO WS-R
     COMPUTE WS-R = WS-A / WS-ZERO
         ON SIZE ERROR MOVE 1 TO WS-FLAG
     END-COMPUTE
     MOVE "fpfast compute given a float divided by a float zero then the size error is raised" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fpfast compute given a float divided by a float zero with a size error then the target keeps its value" TO TL-CASE
     MOVE 99 TO WS-WANT
     PERFORM CHECK-NEAR

     MOVE 0 TO WS-FLAG
     IF WS-A * WS-B > 0.374 AND WS-A * WS-B < 0.376
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "fpfast compute given a float product then it compares with decimal literals on both sides (0.374 < 0.375 < 0.376)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-FLAG
     IF WS-A * WS-B < WS-A + WS-B
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "fpfast compute given two float expressions then 1.5 * 0.25 is below 1.5 + 0.25" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     COMPUTE WS-BIG2 = WS-BIG + WS-B - WS-B
     MOVE "fpfast compute given 2^53 + 1 plus and minus a float then the BINARY-DOUBLE target keeps every digit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BIG2 - WS-BIG
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     COMPUTE WS-DEC2 ROUNDED = WS-DEC * 2 / 3
     MOVE "fpfast compute given decimals only then 123.4567 * 2 / 3 ROUNDED is 82.3045" TO TL-CASE
     MOVE 823045 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DEC2 * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     COMPUTE WS-R = WS-A ** 2 + FUNCTION SQRT(WS-B)
     MOVE 2.75 TO WS-WANT
     MOVE "fpfast compute given a power and an intrinsic then 1.5 ** 2 + sqrt(0.25) is 2.75" TO TL-CASE
     PERFORM CHECK-NEAR
     GOBACK.

*> WS-R is within 1e-9 of WS-WANT.
 CHECK-NEAR.
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-R - WS-WANT) < 0.000000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-FPFAST-COMPUTE.
