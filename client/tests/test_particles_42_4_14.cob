*> Acceptance test of docs/protocol/42-particles-4-block-item-dust-ambient.md section 14 (The ambient-particle environment attribute): the rules, table rows,
*> formulas and worked cases of the section with the document's numbers; every float case compares
*> the value times 100000 rounded. Draws are injected through the draw tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-4-14.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-DRAWS.
    05 WS-D                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-EDRAWS.
    05 WS-E                FLOAT-LONG OCCURS 16 TIMES.
 01 W1                     FLOAT-LONG.
 01 W2                     FLOAT-LONG.
 01 W3                     FLOAT-LONG.
 01 W4                     FLOAT-LONG.
 01 W5                     FLOAT-LONG.
 01 W6                     FLOAT-LONG.
 01 W7                     FLOAT-LONG.
 01 W8                     FLOAT-LONG.
 01 I1                     BINARY-LONG.
 01 I2                     BINARY-LONG.
 01 I3                     BINARY-LONG.
 01 I4                     BINARY-LONG.
 01 I5                     BINARY-LONG.
 01 B1                     BINARY-DOUBLE.
 01 T1                     PIC X(80).
 01 Z1                     FLOAT-LONG VALUE 0.
 01 Z2                     FLOAT-LONG VALUE 0.
 01 Z3                     FLOAT-LONG VALUE 0.
 01 Z4                     FLOAT-LONG VALUE 0.
 01 Z5                     FLOAT-LONG VALUE 0.
 01 Z6                     FLOAT-LONG VALUE 0.
 01 WS-BIOME              PIC X(32).
 01 WS-PNAME              PIC X(32).
 01 WS-FOUND              BINARY-LONG.
 01 WS-AID                PIC X(40).
 01 WS-POS.
    05 WS-PP               BINARY-LONG OCCURS 3 TIMES.
 01 WS-OUT.
    05 WS-O                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-U.
    05 WS-UU               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "P4-AMBIENT-COUNT" USING I1
     MOVE "exactly four biomes set the attribute" TO WS-NAME
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE "soul_sand_valley" TO WS-BIOME
     CALL "P4-AMBIENT-LOOKUP" USING WS-BIOME WS-PNAME W1 WS-FOUND
     MOVE "soul sand valley spawns ash" TO WS-NAME
     MOVE "ash" TO TL-EXPECTED
     MOVE WS-PNAME TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "soul sand valley probability 0.00625" TO WS-NAME
     MOVE 625000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W1 * 1000) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "basalt_deltas" TO WS-BIOME
     CALL "P4-AMBIENT-LOOKUP" USING WS-BIOME WS-PNAME W1 WS-FOUND
     MOVE "basalt deltas spawn white_ash" TO WS-NAME
     MOVE "white_ash" TO TL-EXPECTED
     MOVE WS-PNAME TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "basalt deltas probability 0.118093334 (times 1000)" TO WS-NAME
     MOVE 11809333 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W1 * 1000) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "crimson_forest" TO WS-BIOME
     CALL "P4-AMBIENT-LOOKUP" USING WS-BIOME WS-PNAME W1 WS-FOUND
     MOVE "crimson forest spawns crimson_spore" TO WS-NAME
     MOVE "crimson_spore" TO TL-EXPECTED
     MOVE WS-PNAME TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "crimson forest probability 0.025" TO WS-NAME
     MOVE 2500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W1) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "warped_forest" TO WS-BIOME
     CALL "P4-AMBIENT-LOOKUP" USING WS-BIOME WS-PNAME W1 WS-FOUND
     MOVE "warped forest spawns warped_spore" TO WS-NAME
     MOVE "warped_spore" TO TL-EXPECTED
     MOVE WS-PNAME TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "warped forest probability 0.01428" TO WS-NAME
     MOVE 1428 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W1) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "nether_wastes" TO WS-BIOME
     CALL "P4-AMBIENT-LOOKUP" USING WS-BIOME WS-PNAME W1 WS-FOUND
     MOVE "nether wastes carries no ambient entry" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FOUND
     PERFORM ASSERT-NUMBER
     MOVE "plains" TO WS-BIOME
     CALL "P4-AMBIENT-LOOKUP" USING WS-BIOME WS-PNAME W1 WS-FOUND
     MOVE "every other biome resolves to the empty list" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FOUND
     PERFORM ASSERT-NUMBER
     MOVE 0.00625 TO W1
     MOVE 0.00625 TO W2
     CALL "P4-AMBIENT-CAN-SPAWN" USING W1 W2 I1
     MOVE "canSpawn uses r <= probability: equal spawns" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 0.00626 TO W1
     CALL "P4-AMBIENT-CAN-SPAWN" USING W1 W2 I1
     MOVE "a draw above the probability does not spawn" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 0 TO I2
     CALL "P4-AMBIENT-APPLIES" USING I2 I1
     MOVE "a non-full collision shape gets the ambient step" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 1 TO I2
     CALL "P4-AMBIENT-APPLIES" USING I2 I1
     MOVE "a full-block collision shape does not" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 10 TO WS-PP(1)
     MOVE 64 TO WS-PP(2)
     MOVE -3 TO WS-PP(3)
     MOVE 0.25 TO WS-UU(1)
     MOVE 0.5 TO WS-UU(2)
     MOVE 0.75 TO WS-UU(3)
     CALL "P4-AMBIENT-POS" USING WS-POS WS-U WS-OUT
     MOVE "position = pos.x + nextDouble" TO WS-NAME
     MOVE 1025000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-O(1)) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "position = pos.y + nextDouble" TO WS-NAME
     MOVE 6450000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-O(2)) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "position = pos.z + nextDouble" TO WS-NAME
     MOVE -225000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-O(3)) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 0.00625 TO W1
     CALL "P4-AMBIENT-RATE" USING W1 W2
     MOVE "expected spawns per tick for ash: 1334 * 0.00625" TO WS-NAME
     MOVE 833750 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W2) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 0.118093334 TO W1
     CALL "P4-AMBIENT-RATE" USING W1 W2
     MOVE "expected spawns per tick for white_ash: about 157" TO WS-NAME
     MOVE 15753651 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W2) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     CALL "P4-AMBIENT-ID" USING WS-AID
     MOVE "the attribute id" TO WS-NAME
     MOVE "minecraft:visual/ambient_particles" TO TL-EXPECTED
     MOVE WS-AID TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§14 The ambient-particle environment attribute: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§14 The ambient-particle environment attribute: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-4-14.
