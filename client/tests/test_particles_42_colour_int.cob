*> Colour ints with the high byte set (42-1 section 3 and 42-5 section 1.3): the wire Int is signed
*> (-12210434 is 0xFF45AEFE), so the shared colour helpers take the same colour as a signed or as an
*> unsigned 32-bit value and agree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-COLOUR-INT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(100).
 01 C1                     BINARY-DOUBLE.
 01 C2                     BINARY-DOUBLE.
 01 C3                     BINARY-DOUBLE.
 01 C4                     BINARY-DOUBLE.
 01 W1                     FLOAT-LONG.
 01 W2                     FLOAT-LONG.
 01 W3                     FLOAT-LONG.
 01 WR                     FLOAT-LONG.
 01 WG                     FLOAT-LONG.
 01 WB                     FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE -12210434 TO C1
     MOVE 1.0 TO W1 W2 W3
     CALL "P5-SCALE-RGB" USING C1 W1 W2 W3 C2
     MOVE "scaleRGB of the signed colour -12210434 keeps alpha: 0xFF45AEFE" TO WS-NAME
     MOVE 4282756862 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = C2
     PERFORM ASSERT-NUMBER
     MOVE -1 TO C1
     MOVE 0.5 TO W1
     MOVE 0.5 TO W2 W3
     CALL "P5-SCALE-RGB" USING C1 W1 W2 W3 C2
     MOVE "scaleRGB of the signed colour -1 halves each channel (FF7F7F7F)" TO WS-NAME
     MOVE 4286545791 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = C2
     PERFORM ASSERT-NUMBER
     MOVE -12210434 TO C1
     MOVE -1 TO C2
     MOVE 0.5 TO W1
     CALL "P5-SRGB-LERP" USING W1 C1 C2 C3
     MOVE "srgbLerp with signed ends = the unsigned result 0xFFA2D6FE" TO WS-NAME
     MOVE 4288861950 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = C3
     PERFORM ASSERT-NUMBER
     MOVE 4282756862 TO C1
     MOVE 4294967295 TO C2
     CALL "P5-SRGB-LERP" USING W1 C1 C2 C4
     MOVE "srgbLerp with unsigned ends gives the same result" TO WS-NAME
     MOVE 4288861950 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = C4
     PERFORM ASSERT-NUMBER
     MOVE -12210434 TO C1
     CALL "PART-RGB24" USING C1 WR WG WB
     MOVE "RGB24 of the signed colour: red byte 69 (x1000 rounded 271)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 271
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WR * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 4282756862 TO C1
     CALL "PART-RGB24" USING C1 W1 W2 W3
     MOVE "RGB24 of the unsigned colour gives the same red" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 271
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(W1 * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-1§3 colour ints: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-COLOUR-INT.
