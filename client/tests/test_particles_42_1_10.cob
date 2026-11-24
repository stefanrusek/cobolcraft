*> Acceptance test of docs/protocol/42-particles-1-shared-model-engine.md section 1.1: the channel
*> conversion is float32 arithmetic (floor(c * 255.0f) with the product rounded to binary32), so
*> 0.2 gives 51 (the double product 50.99999 would give 50) and the glow squid ink colour is built
*> by the function (255, 51, 204, 153).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-1-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-C                   COMP-2.
 01 WS-A                   COMP-2.
 01 WS-R                   COMP-2.
 01 WS-G                   COMP-2.
 01 WS-B                   COMP-2.
 01 WS-BYTE                BINARY-LONG.
 01 WS-PACKED              BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0.2 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1.1 float32 channel: 0.2 gives 51" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     PERFORM CHECK-BYTE
     MOVE 0.8 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1.1 float32 channel: 0.8 gives 204" TO TL-CASE
     MOVE 204 TO TL-EXPECTED-N
     PERFORM CHECK-BYTE
     MOVE 0.6 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1.1 float32 channel: 0.6 gives 153" TO TL-CASE
     MOVE 153 TO TL-EXPECTED-N
     PERFORM CHECK-BYTE
     MOVE 0.3 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1.1 float32 channel: 0.3 gives 76" TO TL-CASE
     MOVE 76 TO TL-EXPECTED-N
     PERFORM CHECK-BYTE
     MOVE 0.55 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1.1 float32 channel: 0.55 still gives 140" TO TL-CASE
     MOVE 140 TO TL-EXPECTED-N
     PERFORM CHECK-BYTE
     MOVE -0.5 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1.1 float32 channel: negative clamps to 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-BYTE
     MOVE 1.0 TO WS-A
     MOVE 0.2 TO WS-R
     MOVE 0.8 TO WS-G
     MOVE 0.6 TO WS-B
     CALL "PART-COLOR-PACK" USING WS-A WS-R WS-G WS-B WS-PACKED
     MOVE "acceptance US12 42-1§1.1 float32 channel: colorFromFloat(1, 0.2, 0.8, 0.6)" TO TL-CASE
     MOVE 4281584793 TO TL-EXPECTED-N
     MOVE WS-PACKED TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2
     MOVE 1 TO WS-KIND
     CALL "P3-INK-ARGB" USING WS-KIND WS-PACKED
     MOVE "acceptance US12 42-1§1.1 float32 channel: glow ink argb equals the function" TO TL-CASE
     MOVE 4281584793 TO TL-EXPECTED-N
     MOVE WS-PACKED TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2
     STOP RUN.

 CHECK-BYTE.
     MOVE WS-BYTE TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2.

 CHECK-NUMBER-2.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-1-10.
