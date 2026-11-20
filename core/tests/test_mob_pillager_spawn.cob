*> Implementation test (lane p45c; docs/protocol/36-structures-9-villages-outposts.md section 11.3 item 2, 44 part 2 section 8, 18 section 6.8): the pillager, the one natural spawn the pillager
*> outpost's override lists (11.3 item 1), is a species the natural cycle can pick (MS6-SPECIES finds its row) and follows PatrollingMonster.checkPatrollingMonsterSpawnRules: a block light above 8
*> at the position returns false, otherwise the any-light monster rule applies (a floor below, not Peaceful, no light test: it passes by day under open sky and in the dark).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-PILLAGER-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY STDMOBS.
 COPY BRWORLD.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-PX                 BINARY-LONG.
 01 WS-PY                 BINARY-LONG.
 01 WS-PZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-QX                 BINARY-LONG.
 01 WS-QZ                 BINARY-LONG.
 01 WS-CX                 BINARY-LONG.
 01 WS-CZ                 BINARY-LONG.
 01 WS-CHUNK              BINARY-LONG.
 01 WS-Y                  BINARY-LONG.
 01 WS-A                  BINARY-LONG.
 01 WS-B                  BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-I                  BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-PASS               BINARY-LONG.
 01 WS-REASON             BINARY-LONG VALUE 0.
 01 WS-FLOOR-SIZE         BINARY-LONG.
 01 WS-KIND               BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-KEY48              PIC X(48).
 01 WS-NAME               PIC X(24).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ZROW               BINARY-LONG.
 01 WS-INDEX              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "pillager" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-INDEX
     MOVE "acceptance US12 36-9§11.3 Pillager spawning: the natural cycle finds the pillager's species row (a spawn rule is set)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INDEX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-INDEX = 0
         STOP RUN
     END-IF
     MOVE WS-INDEX TO WS-ZROW
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = WS-PY + 40
     COMPUTE WS-QX = WS-PX + 20
     COMPUTE WS-QZ = WS-PZ - 10
     MOVE 20 TO WS-FLOOR-SIZE
     MOVE 1 TO WS-KIND
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-QX WS-QZ WS-FLOOR-SIZE WS-FY WS-KIND
     COMPUTE WS-QX = WS-PX + 30
     COMPUTE WS-QZ = WS-PZ
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
*>   by day under open sky: no light test, so it passes
     MOVE 6000 TO CW-TIME
     PERFORM COUNT-PASSES
     MOVE "acceptance US12 36-9§11.3 Pillager spawning: by day under open sky (block light 0) the any-light rule passes" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PASS = 200
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   at night too
     MOVE 18000 TO CW-TIME
     PERFORM COUNT-PASSES
     MOVE "acceptance US12 36-9§11.3 Pillager spawning: at night the same" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PASS = 200
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a torch (block light 14) in the cell: above 8, it is rejected
     MOVE "minecraft:torch" TO WS-KEY
     MOVE 1 TO WS-I
     PERFORM SET-AT
     PERFORM COUNT-PASSES
     MOVE "acceptance US12 36-9§11.3 Pillager spawning: with a torch in the cell (block light 14) the block light above 8 rejects the spawn" TO TL-CASE
     MOVE WS-PASS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Peaceful rejects it (the any-light monster rule is a monster rule)
     MOVE "minecraft:air" TO WS-KEY
     MOVE 1 TO WS-I
     PERFORM SET-AT
     MOVE 0 TO BW-DIFFICULTY
     PERFORM COUNT-PASSES
     MOVE "acceptance US12 36-9§11.3 Pillager spawning: on Peaceful the monster rule rejects it" TO TL-CASE
     MOVE WS-PASS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SET-AT.
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-BY = WS-FY + WS-I
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-QX WS-BY WS-QZ WS-STATE.
 RELIGHT.
     PERFORM VARYING WS-A FROM -1 BY 1 UNTIL WS-A > 1
         PERFORM VARYING WS-B FROM -1 BY 1 UNTIL WS-B > 1
             COMPUTE WS-BX = WS-CX + WS-A
             COMPUTE WS-BZ = WS-CZ + WS-B
             CALL "WORLD-FIND" USING WS-DIM WS-BX WS-BZ WS-CHUNK
             IF WS-CHUNK > 0
                 MOVE 0 TO CK-LIT(WS-CHUNK)
             END-IF
             CALL "STDMOB-READY" USING WS-DIM WS-BX WS-BZ WS-OK
         END-PERFORM
     END-PERFORM.
 COUNT-PASSES.
     PERFORM RELIGHT
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-ZROW WS-QX WS-Y WS-QZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM.
 END PROGRAM TEST-MOB-PILLAGER-SPAWN.
 COPY CORETEST.
 COPY MOBSPTEST.
