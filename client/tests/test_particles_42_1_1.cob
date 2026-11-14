*> Acceptance test of docs/protocol/42-particles-1-shared-model-engine.md section 1 (common rules for
*> all particle parts): 1.1 the number conventions (channel bytes are floor(c x 255), the worked
*> examples alpha 0.55 gives 140 and 0.4955 gives 126, ARGB packing alpha first, light packing and
*> the two named values, the legacy generator: state from a seed, 48-bit steps), 1.2 and 1.3 the
*> record schemas are the registry columns (checked in section 2's test).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-1-1.
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
 01 WS-LIGHT               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-STATE               BINARY-DOUBLE.
 01 WS-BITS                BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              PIC X(8).
 PROCEDURE DIVISION.
     MOVE 0.55 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     PERFORM CHECK-BYTE-140
     MOVE 0.4955 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: 0.4955 gives byte 126"
         TO TL-CASE
     MOVE 126 TO TL-EXPECTED-N
     PERFORM CHECK-NUMBER
     MOVE 0.999 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: floor, not rounding" TO TL-CASE
     MOVE 254 TO TL-EXPECTED-N
     PERFORM CHECK-NUMBER
     MOVE 1.0 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: 1.0 is 255" TO TL-CASE
     MOVE 255 TO TL-EXPECTED-N
     PERFORM CHECK-NUMBER
     MOVE 0 TO WS-C
     CALL "PART-CHANNEL" USING WS-C WS-BYTE
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: 0.0 is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-NUMBER
*>   Packing: alpha first, red, green, blue.
     MOVE 1.0 TO WS-A
     MOVE 1.0 TO WS-R
     MOVE 0.5 TO WS-G
     MOVE 0.0 TO WS-B
     CALL "PART-COLOR-PACK" USING WS-A WS-R WS-G WS-B WS-PACKED
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: ARGB packing" TO WS-CASE
     MOVE "FFFF7F00" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-PACKED
     MOVE 0.55 TO WS-A
     MOVE 0.0 TO WS-R
     MOVE 0.0 TO WS-G
     MOVE 1.0 TO WS-B
     CALL "PART-COLOR-PACK" USING WS-A WS-R WS-G WS-B WS-PACKED
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: alpha 0.55 packs as 8C" TO WS-CASE
     MOVE "8C0000FF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-PACKED
*>   Light: (block << 4) | (sky << 20); full bright 15728880, full sky 15728640.
     MOVE 15 TO WS-BLOCK
     MOVE 15 TO WS-SKY
     CALL "PART-LIGHT-PACK" USING WS-BLOCK WS-SKY WS-LIGHT
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: full bright light" TO TL-CASE
     MOVE 15728880 TO TL-EXPECTED-N
     MOVE WS-LIGHT TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2
     MOVE 0 TO WS-BLOCK
     CALL "PART-LIGHT-PACK" USING WS-BLOCK WS-SKY WS-LIGHT
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: full sky light" TO TL-CASE
     MOVE 15728640 TO TL-EXPECTED-N
     MOVE WS-LIGHT TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2
*>   The generator: state = (seed xor 0x5DEECE66D) and mask; steps are the legacy 48-bit LCG.
     MOVE 0 TO WS-SEED
     CALL "PART-RANDOM-SEED" USING WS-SEED WS-STATE
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: seed 0 state" TO TL-CASE
     MOVE 25214903917 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2
     MOVE 31 TO WS-BITS
     CALL "TINT-LEGACY-NEXT" USING WS-STATE WS-BITS WS-VALUE
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: first draw of seed 0"
         TO TL-CASE
     MOVE 1569741360 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2
     CALL "TINT-LEGACY-NEXT" USING WS-STATE WS-BITS WS-VALUE
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: second draw of seed 0"
         TO TL-CASE
     MOVE 1785505948 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2
     MOVE 12345 TO WS-SEED
     CALL "PART-RANDOM-SEED" USING WS-SEED WS-STATE
     MOVE 31 TO WS-BITS
     CALL "TINT-LEGACY-NEXT" USING WS-STATE WS-BITS WS-VALUE
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: first draw of seed 12345"
         TO TL-CASE
     MOVE 776966251 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2
     STOP RUN.

 CHECK-BYTE-140.
     MOVE "acceptance US12 42-1§1 Common rules for all particle parts: 0.55 gives byte 140"
         TO TL-CASE
     MOVE 140 TO TL-EXPECTED-N
     PERFORM CHECK-NUMBER.

 CHECK-NUMBER.
     MOVE WS-BYTE TO TL-OBSERVED-N
     PERFORM CHECK-NUMBER-2.

 CHECK-NUMBER-2.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-1-1.
 COPY TINTTEST.
