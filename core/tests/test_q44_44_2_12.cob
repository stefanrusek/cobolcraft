*> Implementation test (wrap I3, T2716/T2717; docs/protocol/44-residual-mob-questions-2-spawning-structures.md sections 9 and 12, 19 section 5.2): Ocelot.checkOcelotSpawnRules passes with probability
*> 2/3 (one draw nextInt(3), a draw of 0 fails; the draw is made for every reason and is the only one), has no light test and no floor test of the Animal predicate, and the ocelot's ground rules follow:
*> the feet at or above the sea level and grass_block or a leaves block below. The expected draws are computed here with the section 1.4.1 generator (XORO-SEED, XORO-NEXT-INT).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-2-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY DIMENSIONS.
 COPY STDMOBS.
 COPY XORO.
 COPY XORO REPLACING LEADING ==XR-== BY ==CP-==.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-OCELOT              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-SEA                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-LEAVES              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-REASON              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-3                   BINARY-LONG VALUE 3.
 01 WS-DRAW                BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-PASS-SEED           BINARY-DOUBLE UNSIGNED.
 01 WS-FAIL-SEED           BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:ocelot" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-OCELOT WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-OCELOT WS-M
     MOVE DM-SEA-LEVEL(WS-DIM) TO WS-SEA
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 3
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-GRASS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:jungle_leaves" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LEAVES
*>   Seeds: the first whose first nextInt(3) is 0 and the first whose is not (computed with the generator, not with the rule).
     MOVE 0 TO WS-PASS-SEED WS-FAIL-SEED
     PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-PASS-SEED > 0 AND WS-FAIL-SEED > 0
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "XORO-NEXT-INT" USING XR-STATE WS-3 WS-DRAW
         IF WS-DRAW = 0 AND WS-FAIL-SEED = 0
             MOVE WS-SEED TO WS-FAIL-SEED
         END-IF
         IF WS-DRAW NOT = 0 AND WS-PASS-SEED = 0
             MOVE WS-SEED TO WS-PASS-SEED
         END-IF
     END-PERFORM
*>   The cell: feet at the floor y + 1 (floor y 6 above the sea level), two air cells.
     COMPUTE WS-FY = WS-SEA + 6
     MOVE WS-X0 TO WS-BX
     MOVE WS-Z0 TO WS-BZ
     PERFORM SET-COLUMN-GRASS
     COMPUTE WS-BY = WS-FY + 1
     MOVE 0 TO WS-REASON
     MOVE WS-FAIL-SEED TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "XORO-SEED" USING WS-SEED CP-STATE
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 44-2§12 ocelot predicate: a draw of 0 fails on a grass floor above the sea level" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "XORO-NEXT-INT" USING CP-STATE WS-3 WS-DRAW
     CALL "XORO-NEXT-INT" USING CP-STATE WS-3 WS-DRAW
     CALL "XORO-NEXT-INT" USING XR-STATE WS-3 WS-NEXT
     MOVE "acceptance US15 44-2§12 ocelot predicate: exactly one draw is consumed (the next draw is the second of the generator)" TO TL-CASE
     MOVE WS-DRAW TO TL-EXPECTED-N
     MOVE WS-NEXT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PASS-SEED TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 44-2§12 ocelot predicate: a draw of 1 or 2 passes on a grass floor above the sea level" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The draw applies to every reason: a spawner (2) with a failing draw fails too.
     MOVE 2 TO WS-REASON
     MOVE WS-FAIL-SEED TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 44-2§12 ocelot predicate: the draw is made for a spawner too" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-REASON
*>   No light test: a cell under a stone roof (dark) passes.
     COMPUTE WS-BY = WS-FY + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-BY = WS-FY + 1
     MOVE WS-PASS-SEED TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 44-2§12 ocelot predicate: no light test (a dark cell under a roof passes)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Ground rules: a leaves block below passes, stone fails, a grass floor below the sea level fails.
     COMPUTE WS-BY = WS-FY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-LEAVES
     COMPUTE WS-BY = WS-FY + 1
     MOVE WS-PASS-SEED TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 44-2§12 ocelot ground rule: a leaves block below passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-FY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-BY = WS-FY + 1
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 44-2§12 ocelot ground rule: a stone floor fails although the draw passes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-SEA - 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-GRASS
     COMPUTE WS-BY = WS-SEA - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-SEA
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-SEA - 1
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 44-2§12 ocelot ground rule: feet below the sea level fail" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 SET-COLUMN-GRASS.
     MOVE WS-FY TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-GRASS
     COMPUTE WS-BY = WS-FY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-FY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR.
 END PROGRAM TEST-Q44-44-2-12.
 COPY CORETEST.
 COPY MOBSPTEST.
