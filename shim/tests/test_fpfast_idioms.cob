*> Implementation test of the constructs lane perfshim takes over in shim/src/cc_fpfast.c, as a COBOL program sees them: a float compared with an integer or
*> a literal, a float stored into a binary field (cut toward zero), MOVE of literals into floats, FUNCTION INTEGER, INTEGER-PART and ABS of floats, the floor
*> division INTEGER(a / b) of integers (negative and positive, with and without a remainder), FUNCTION PI inside a function argument, TAN and ATAN. Every
*> case holds with and without FPFAST (tools/package.mk): the values are those libcob alone gives, or within 1e-9 of them where a function is libm's.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FPFAST-IDIOMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-F                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-WANT                FLOAT-LONG.
 01 WS-S                   FLOAT-SHORT.
 01 WS-N                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-U                   PIC 9(4).
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE

     MOVE 2.5 TO WS-F
     MOVE 0 TO WS-FLAG
     IF WS-F > 0 AND WS-F > 2 AND WS-F < 3 AND WS-F NOT = 0 AND WS-F NOT = 2 AND WS-F >= 2.5
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "fpfast idioms given a float 2.5 then it compares with the integers 0, 2, 3 and the literal 2.5 as 2.5 does" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE -0.5 TO WS-F
     MOVE 0 TO WS-FLAG
     IF WS-F < 0 AND WS-F > -1 AND WS-F < -0.25 AND WS-F > -0.75
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "fpfast idioms given a float -0.5 then it is below 0 and above -1, -0.75, and below -0.25" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 7 TO WS-N
     MOVE 0 TO WS-FLAG
     IF WS-F < WS-N AND WS-N > WS-F AND WS-N = 7.0
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "fpfast idioms given a float and a BINARY-LONG 7 then they compare in both orders and 7 equals the literal 7.0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3.99 TO WS-F
     COMPUTE WS-N = WS-F
     MOVE "fpfast idioms given 3.99 stored into a BINARY-LONG then it holds 3 (cut, not rounded)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE -3.99 TO WS-F
     COMPUTE WS-N = WS-F
     MOVE "fpfast idioms given -3.99 stored into a BINARY-LONG then it holds -3" TO TL-CASE
     MOVE -3 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3.99 TO WS-F
     COMPUTE WS-N ROUNDED = WS-F
     MOVE "fpfast idioms given 3.99 stored into a BINARY-LONG ROUNDED then it holds 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2.75 TO WS-F
     MOVE WS-F TO WS-D
     MOVE "fpfast idioms given MOVE of 2.75 to a BINARY-DOUBLE then it holds 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1234.9 TO WS-F
     MOVE WS-F TO WS-U
     MOVE "fpfast idioms given MOVE of 1234.9 to a PIC 9(4) then it holds 1234" TO TL-CASE
     MOVE 1234 TO TL-EXPECTED-N
     MOVE WS-U TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0.125 TO WS-F
     MOVE 3 TO WS-R
     MOVE -1.5 TO WS-S
     MOVE 0 TO WS-FLAG
     IF WS-F = 0.125 AND WS-R = 3 AND WS-S = -1.5
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "fpfast idioms given MOVE of the literals 0.125, 3 and -1.5 into floats then they hold those numbers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE -2.5 TO WS-F
     COMPUTE WS-N = FUNCTION INTEGER(WS-F)
     MOVE "fpfast idioms given FUNCTION INTEGER(-2.5) then it is -3" TO TL-CASE
     MOVE -3 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     COMPUTE WS-N = FUNCTION INTEGER-PART(WS-F)
     MOVE "fpfast idioms given FUNCTION INTEGER-PART(-2.5) then it is -2" TO TL-CASE
     MOVE -2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     COMPUTE WS-N = FUNCTION INTEGER(WS-F * 16)
     MOVE "fpfast idioms given FUNCTION INTEGER(-2.5 * 16) then it is -40" TO TL-CASE
     MOVE -40 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     COMPUTE WS-R = FUNCTION ABS(WS-F)
     MOVE 2.5 TO WS-WANT
     MOVE "fpfast idioms given FUNCTION ABS(-2.5) then it is 2.5" TO TL-CASE
     PERFORM CHECK-NEAR

     MOVE -7 TO WS-X
     MOVE 0 TO WS-Q
     COMPUTE WS-N = FUNCTION INTEGER(WS-X / 16)
     MOVE "fpfast idioms given FUNCTION INTEGER(-7 / 16) then it is -1 (floor)" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 31 TO WS-X
     COMPUTE WS-N = FUNCTION INTEGER(WS-X / 16)
     MOVE "fpfast idioms given FUNCTION INTEGER(31 / 16) then it is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE -32 TO WS-X
     COMPUTE WS-N = FUNCTION INTEGER(WS-X / 16)
     MOVE "fpfast idioms given FUNCTION INTEGER(-32 / 16) then it is -2 (no remainder)" TO TL-CASE
     MOVE -2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE -17 TO WS-X
     COMPUTE WS-N = FUNCTION INTEGER-PART(WS-X / 16)
     MOVE "fpfast idioms given FUNCTION INTEGER-PART(-17 / 16) then it is -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1000000007 TO WS-X
     COMPUTE WS-N = FUNCTION INTEGER(WS-X / 3)
     MOVE "fpfast idioms given FUNCTION INTEGER(1000000007 / 3) then it is 333333335" TO TL-CASE
     MOVE 333333335 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO WS-X
     COMPUTE WS-R = FUNCTION MAX(WS-X / 4, 0)
     MOVE 0.25 TO WS-WANT
     MOVE "fpfast idioms given FUNCTION MAX(1 / 4, 0) then it is 0.25" TO TL-CASE
     PERFORM CHECK-NEAR

     COMPUTE WS-R = FUNCTION ABS(WS-X / 3)
     COMPUTE WS-WANT = 1.0 / 3.0
     MOVE "fpfast idioms given FUNCTION ABS(1 / 3) then it is a third within 1e-9" TO TL-CASE
     PERFORM CHECK-NEAR

     MOVE 60 TO WS-F
     COMPUTE WS-R = FUNCTION COS(WS-F * FUNCTION PI / 180)
     MOVE 0.5 TO WS-WANT
     MOVE "fpfast idioms given FUNCTION COS(60 * FUNCTION PI / 180) then it is 0.5 within 1e-9" TO TL-CASE
     PERFORM CHECK-NEAR

     MOVE 30 TO WS-F
     COMPUTE WS-R = FUNCTION SIN(WS-F * FUNCTION PI / 180)
     MOVE 0.5 TO WS-WANT
     MOVE "fpfast idioms given FUNCTION SIN(30 * FUNCTION PI / 180) then it is 0.5 within 1e-9" TO TL-CASE
     PERFORM CHECK-NEAR

     MOVE 45 TO WS-F
     COMPUTE WS-R = FUNCTION TAN(WS-F * FUNCTION PI / 180)
     MOVE 1 TO WS-WANT
     MOVE "fpfast idioms given FUNCTION TAN(45 * FUNCTION PI / 180) then it is 1 within 1e-9" TO TL-CASE
     PERFORM CHECK-NEAR

     MOVE 1 TO WS-F
     COMPUTE WS-R = FUNCTION ATAN(WS-F) * 4
     COMPUTE WS-WANT = FUNCTION PI
     MOVE "fpfast idioms given FUNCTION ATAN(1) * 4 then it is pi within 1e-9" TO TL-CASE
     PERFORM CHECK-NEAR

     MOVE 0 TO WS-F
     COMPUTE WS-R = FUNCTION ATAN(WS-F)
     MOVE 0 TO WS-WANT
     MOVE "fpfast idioms given FUNCTION ATAN(0) then it is 0" TO TL-CASE
     PERFORM CHECK-NEAR

     COMPUTE WS-R = FUNCTION PI
     MOVE 3.141592653589793 TO WS-WANT
     MOVE "fpfast idioms given FUNCTION PI stored into a float then it is pi within 1e-9" TO TL-CASE
     PERFORM CHECK-NEAR

     COMPUTE WS-R = 0.5
     MOVE 0.5 TO WS-WANT
     MOVE "fpfast idioms given COMPUTE of the literal 0.5 into a float then it is 0.5" TO TL-CASE
     PERFORM CHECK-NEAR

     MOVE 3 TO WS-N
     COMPUTE WS-R = WS-N * 0.5
     MOVE 1.5 TO WS-WANT
     MOVE "fpfast idioms given 3 * 0.5 stored into a float then it is 1.5" TO TL-CASE
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
 END PROGRAM TEST-FPFAST-IDIOMS.
