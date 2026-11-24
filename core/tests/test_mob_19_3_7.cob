*> Implementation test (002-lane-mobsfull-h21; docs/protocol/19-mobs-land-friendly-and-neutral.md section 3.7, 44-residual-mob-questions-4-land-animals.md section 2.2): the llama's strength and
*> variant. Strength at spawn: bound 5 when nextFloat < 0.04 else 3, strength = 1 + nextInt(bound); the variant is one of the four (0 creamy, 1 white, 2 brown, 3 gray); the foal has strength
*> nextInt(max(parents)) + 1, plus 1 with probability 0.03 (at most 5) and the variant of one parent by the coin; strength (metadata 20) and variant (21) are entity data.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-3-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROLL                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-STRENGTH            BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-SA                  BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:llama" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "N" TO TL-MODE

*>   Strength at spawn: the bound by the float roll (0 to 9999), the draw within the bound.
     MOVE 399 TO WS-ROLL
     MOVE 4 TO WS-DRAW
     CALL "LLAMA-STRENGTH" USING WS-ROLL WS-DRAW WS-STRENGTH
     MOVE "acceptance US15 44-4§2.2 a roll under 0.04 gives bound 5: draw 4 is strength 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-STRENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 400 TO WS-ROLL
     MOVE 2 TO WS-DRAW
     CALL "LLAMA-STRENGTH" USING WS-ROLL WS-DRAW WS-STRENGTH
     MOVE "acceptance US15 44-4§2.2 otherwise bound 3: draw 2 is strength 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-STRENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-DRAW
     CALL "LLAMA-STRENGTH" USING WS-ROLL WS-DRAW WS-STRENGTH
     MOVE "acceptance US15 44-4§2.2 draw 0 is strength 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STRENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The foal: nextInt(max) + 1, plus 1 with probability 0.03, at most 5.
     MOVE 2 TO WS-SA
     MOVE 4 TO WS-SB
     MOVE 3 TO WS-DRAW
     MOVE 300 TO WS-ROLL
     CALL "LLAMA-FOAL-STRENGTH" USING WS-SA WS-SB WS-DRAW WS-ROLL WS-STRENGTH
     MOVE "acceptance US15 44-4§2.2 foal of strengths 2 and 4, draw 3: 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-STRENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 299 TO WS-ROLL
     CALL "LLAMA-FOAL-STRENGTH" USING WS-SA WS-SB WS-DRAW WS-ROLL WS-STRENGTH
     MOVE "acceptance US15 44-4§2.2 a roll under 0.03 adds 1" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-STRENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-DRAW
     MOVE 5 TO WS-SB
     CALL "LLAMA-FOAL-STRENGTH" USING WS-SA WS-SB WS-DRAW WS-ROLL WS-STRENGTH
     MOVE "acceptance US15 44-4§2.2 the strength is clamped to 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-STRENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A new llama has strength 1 to 5 and a variant of 0 to 3; the strength is entity data.
     COMPUTE WS-X = WS-PX + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE "acceptance US15 minecraft:llama a new llama has strength 1 to 5 and a variant 0 to 3" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-STRENGTH(WS-A) >= 1 AND EN-STRENGTH(WS-A) <= 5 AND EN-WOOL(WS-A) >= 0 AND EN-WOOL(WS-A) <= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     CALL "MOB-DATA-SEND" USING WS-A
     MOVE "acceptance US15 19§3.7 Llama: strength (20) and variant (21) are entity data" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Over 100 llamas the strength 4 and 5 are rare (bound 5 only 4 percent of the time) and 1 to 3 are common.
     MOVE 0 TO WS-N
     PERFORM 100 TIMES
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-B
         IF EN-STRENGTH(WS-B) > 3
             ADD 1 TO WS-N
         END-IF
         CALL "ENTITY-REMOVE" USING WS-B
     END-PERFORM
     MOVE "acceptance US15 44-4§2.2 of 100 new llamas fewer than 15 have strength 4 or 5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N < 15
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Breeding: the foal has strength 1 to 5 and the variant of a parent (by the coin).
     COMPUTE WS-X = WS-PX + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-B
     MOVE 1 TO EN-WOOL(WS-A)
     MOVE 3 TO EN-WOOL(WS-B)
     MOVE 1 TO EN-TAMED(WS-A) EN-TAMED(WS-B)
     CALL "MOB-BREED" USING WS-A WS-B
     MOVE 0 TO WS-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND WS-I NOT = WS-A AND WS-I NOT = WS-B
             MOVE WS-I TO WS-C
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§2.2 the foal has strength 1 to 5, a parent's variant and is a baby" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-C > 0
         IF EN-VARIANT(WS-C) = 1 AND EN-STRENGTH(WS-C) >= 1 AND EN-STRENGTH(WS-C) <= 5 AND (EN-WOOL(WS-C) = 1 OR EN-WOOL(WS-C) = 3)
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-I
     CALL "LLAMA-BRED" USING WS-A WS-B WS-C WS-I
     MOVE EN-WOOL(WS-C) TO WS-N
     MOVE 0 TO WS-I
     CALL "LLAMA-BRED" USING WS-A WS-B WS-C WS-I
     MOVE "acceptance US15 44-4§2.2 the coin names the parent whose variant the foal gets (b 3, a 1)" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N * 10 + EN-WOOL(WS-C)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-19-3-7.
 COPY CORETEST.
 COPY MOBSPTEST.
