*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md section 4.2 (seeding, T1530): level seed 0, chunk (1, 0): setLargeFeatureSeed leaves the 48-bit state
*> 198298811348821 (the state after setSeed(a) with a the first nextLong of the LCG seeded with 0); the first nextDouble is 0.26044200501959935 (above 0.004: no mineshaft at that chunk);
*> with that double discarded the next three nextInt(6) are 4, 3, 5 (the root room is the box (18,50,2)..(29,57,14)); and for the stronghold the first nextInt(4) is 1.
*> The state is also checked against the document's definition: the seed after setLargeFeatureSeed(seed, cx, cz) is (cx * a) xor (cz * b) xor seed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-4-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-A                   BINARY-DOUBLE UNSIGNED.
 01 WS-B                   BINARY-DOUBLE UNSIGNED.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-D                   FLOAT-LONG.
 01 WS-D-MILLIONTHS        BINARY-DOUBLE.
 01 WS-SCALE               FLOAT-LONG VALUE 1000000000.
 01 WS-SCALED              FLOAT-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DRAWS               PIC X(20).
 01 WS-ED                  PIC 9.
 01 WS-X1                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   a and b: the first two nextLong of the LCG seeded with 0
     CALL "JRAND-SET-SEED" USING WS-STATE WS-USEED
     CALL "JRAND-NEXT-LONG" USING WS-STATE WS-A
     CALL "JRAND-NEXT-LONG" USING WS-STATE WS-B
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-STATE WS-USEED WS-CX WS-CZ
     MOVE "acceptance US12 36-5§4.2 Seeding: seed 0, chunk (1,0): the state after setLargeFeatureSeed is 198298811348821" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 198298811348821 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the same by the definition: setSeed((1 * a) xor (0 * b) xor 0) = (a xor 0x5DEECE66D) mod 2^48
     CALL "JRAND-SET-SEED" USING WS-STATE WS-A
     MOVE "acceptance US12 36-5§4.2 Seeding: that state is the state after setSeed(a), a the first nextLong (1 * a xor 0 * b xor 0 = a)" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 198298811348821 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the first nextDouble: 0.26044200501959935 (above 0.004)
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-STATE WS-USEED WS-CX WS-CZ
     CALL "STRUCT-NEXT-DOUBLE" USING WS-STATE WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-SCALE WS-SCALED
     MOVE WS-SCALED TO WS-D-MILLIONTHS
     MOVE "acceptance US12 36-5§4.2 Seeding: the first nextDouble at chunk (1,0) is 0.260442005 (to nine places)" TO TL-CASE
     MOVE WS-D-MILLIONTHS TO TL-OBSERVED-N
     MOVE 260442005 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§4.2 Seeding: 0.2604 is not below 0.004: the legacy_type_3 test drops chunk (1,0)" TO TL-CASE
     IF WS-D-MILLIONTHS < 4000000
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   after the first double, the next three nextInt(6): 4, 3, 5
     MOVE 6 TO WS-BOUND
     MOVE SPACES TO WS-DRAWS
     MOVE 1 TO WS-X1
     PERFORM 3 TIMES
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-DRAW
         MOVE WS-DRAW TO WS-ED
         MOVE WS-ED TO WS-DRAWS(WS-X1:1)
         ADD 1 TO WS-X1
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-5§4.2 Seeding: with the first double discarded the next three nextInt(6) are 4, 3, 5" TO TL-CASE
     MOVE WS-DRAWS TO TL-OBSERVED
     MOVE "435" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the stronghold at the same chunk and seed: the first draw nextInt(4) is 1
     MOVE "N" TO TL-MODE
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-STATE WS-USEED WS-CX WS-CZ
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-DRAW
     MOVE "acceptance US12 36-5§4.2 Seeding: the stronghold's first draw nextInt(4) at chunk (1,0) is 1" TO TL-CASE
     MOVE WS-DRAW TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-5-4-2.
