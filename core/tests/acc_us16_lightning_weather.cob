*> Acceptance test, lightning from thunderstorms (docs/protocol/33 section 4.4 tickThunder, 44 part 9 section 2; lane 002-lane-mobsb8, T9710): a chunk tick strikes only in rain and thunder and on a
*> draw of 0 (one in 100000); the bolt stands at the bottom centre of the column's surface; the skeleton trap (a skeleton horse and a visual-only bolt) when the roll is below the effective difficulty
*> (never in Peaceful) and spawn_mobs is on.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-LIGHTNING-WEATHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-BOLTS               BINARY-LONG.
 01 WS-BOLTS0              BINARY-LONG.
 01 WS-HORSES0             BINARY-LONG.
 01 WS-HORSES              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HKEY                PIC X(112) VALUE "minecraft:skeleton_horse".
 01 WS-HTYPE               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "THROWN-TYPE" USING WS-HKEY WS-HTYPE
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE 900 TO PL-X(WS-PLAYER)
     MOVE 900 TO PL-Z(WS-PLAYER)
     MOVE 5 TO WS-BX
     MOVE 150 TO WS-BY
     MOVE 5 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE 0 TO WS-CX WS-CZ
     MOVE 0 TO WS-DRAW
     MOVE 0 TO WS-BOLTS0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 9
             ADD 1 TO WS-BOLTS0
         END-IF
     END-PERFORM
*>   A clear sky: nothing.
     MOVE 0 TO CW-RAIN-LEVEL(WS-DIM) CW-THUNDER-LEVEL(WS-DIM)
     MOVE 2 TO BW-DIFFICULTY
     CALL "LIGHTNING-CHUNK-TICK" USING WS-DIM WS-CX WS-CZ WS-DRAW
     MOVE 0 TO WS-BOLTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 9
             ADD 1 TO WS-BOLTS
         END-IF
     END-PERFORM
     MOVE "acceptance US16 33 4.4 without a thunderstorm a chunk tick makes no lightning" TO TL-CASE
     MOVE WS-BOLTS0 TO TL-EXPECTED-N
     MOVE WS-BOLTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Thunderstorm, draw not 0: nothing; draw 0: one bolt.
     MOVE 1 TO CW-RAIN-LEVEL(WS-DIM) CW-THUNDER-LEVEL(WS-DIM)
     MOVE 7 TO WS-DRAW
     CALL "LIGHTNING-CHUNK-TICK" USING WS-DIM WS-CX WS-CZ WS-DRAW
     MOVE 0 TO WS-BOLTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 9
             ADD 1 TO WS-BOLTS
         END-IF
     END-PERFORM
     MOVE "acceptance US16 33 4.4 a draw other than 0 makes no lightning" TO TL-CASE
     MOVE WS-BOLTS0 TO TL-EXPECTED-N
     MOVE WS-BOLTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-DRAW
     CALL "LIGHTNING-CHUNK-TICK" USING WS-DIM WS-CX WS-CZ WS-DRAW
     MOVE 0 TO WS-BOLTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 9
             ADD 1 TO WS-BOLTS
         END-IF
     END-PERFORM
     MOVE "acceptance US16 33 4.4 in rain and thunder a draw of 0 strikes (one more bolt)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-BOLTS0 + 1
     MOVE WS-BOLTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CW-THUNDER-LEVEL(WS-DIM)
     CALL "LIGHTNING-CHUNK-TICK" USING WS-DIM WS-CX WS-CZ WS-DRAW
     MOVE 0 TO WS-BOLTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 9
             ADD 1 TO WS-BOLTS
         END-IF
     END-PERFORM
     MOVE "acceptance US16 33 4.4 rain without thunder makes none" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-BOLTS0 + 1
     MOVE WS-BOLTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The strike at a column: the stone block at (5, 150, 5) makes the surface 151; the bolt is at (5.5, 151, 5.5).
     MOVE 1 TO WS-ROLL
     MOVE 99999 TO WS-ROLL
     CALL "LIGHTNING-STRIKE-AT" USING WS-DIM WS-BX WS-BZ WS-ROLL WS-ROW
     MOVE "acceptance US16 33 4.4 the bolt is at the bottom centre of the column's surface (y 151)" TO TL-CASE
     MOVE 151 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Y(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 33 4.4 and centred on the column (x 5.5)" TO TL-CASE
     MOVE 55 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-ROW) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 33 4.4 with a high roll there is no trap: the bolt is not visual only" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I3(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Trap: a roll of 0 on Normal (effective difficulty above 0): a skeleton horse and a visual-only bolt.
     MOVE 0 TO WS-HORSES0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-HTYPE
             ADD 1 TO WS-HORSES0
         END-IF
     END-PERFORM
     MOVE 0 TO WS-ROLL
     CALL "LIGHTNING-STRIKE-AT" USING WS-DIM WS-BX WS-BZ WS-ROLL WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 0 TO WS-HORSES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-HTYPE
             ADD 1 TO WS-HORSES
         END-IF
     END-PERFORM
     MOVE "acceptance US16 33 4.4 a trap roll makes a skeleton horse" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-HORSES0 + 1
     MOVE WS-HORSES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 33 4.4 and the trap's bolt is visual only" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I3(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Peaceful: the effective difficulty is 0, no trap.
     MOVE 0 TO BW-DIFFICULTY
     MOVE 0 TO WS-ROLL
     CALL "LIGHTNING-STRIKE-AT" USING WS-DIM WS-BX WS-BZ WS-ROLL WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 33 4.4 in Peaceful there is no trap" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I3(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-LIGHTNING-WEATHER.
 COPY CORETEST.
 COPY MOBSPTEST.
