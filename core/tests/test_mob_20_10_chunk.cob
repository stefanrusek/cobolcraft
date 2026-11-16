*> Implementation test (002-lane-mobsa3; docs/protocol/54 section 8.1 and 20 section 10 (b)): the 64 bit wrap of the slime chunk seed sum and the slime-chunk
*> alternative of the spawn rule (the chunk test on the world seed, a fresh nextInt(10) = 0, y below 40 and a floor).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-10-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CASE                PIC X(100).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-OUT                 BINARY-DOUBLE.
 01 WS-STATE-SEED          BINARY-DOUBLE UNSIGNED.
 01 WS-SLIME               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-REASON              BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 5.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-FLOOR-Y             BINARY-LONG VALUE 30.
 01 WS-YES                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG.
 PROCEDURE DIVISION.
*>   The wrap: world seed Long.MAX_VALUE with chunk (1, 0) overflows upward, Long.MIN_VALUE with chunk (-1, 0) downward.
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE 9223372036854775807 TO WS-SEED
     CALL "M44-SLIME-SEED" USING WS-CX WS-CZ WS-SEED WS-OUT
     MOVE "acceptance US15 54§8.1 Slime seed: the sum wraps past Long.MAX_VALUE" TO WS-CASE
     MOVE WS-OUT TO WS-O
     MOVE -9223372035873383489 TO WS-E
     PERFORM CHECK-N
     MOVE -1 TO WS-CX
     COMPUTE WS-SEED = -9223372036854775807 - 1
     CALL "M44-SLIME-SEED" USING WS-CX WS-CZ WS-SEED WS-OUT
     MOVE "acceptance US15 54§8.1 Slime seed: the sum wraps below Long.MIN_VALUE" TO WS-CASE
     MOVE WS-OUT TO WS-O
     MOVE 9223372035867630196 TO WS-E
     PERFORM CHECK-N
     MOVE 3 TO WS-CX
     MOVE 5 TO WS-CZ
     MOVE 12345 TO WS-SEED
     CALL "M44-SLIME-SEED" USING WS-CX WS-CZ WS-SEED WS-OUT
     MOVE "acceptance US15 54§8.1 Slime seed: chunk (3, 5), seed 12345 is unchanged by the wrap" TO WS-CASE
     MOVE WS-OUT TO WS-O
     MOVE 817810565 TO WS-E
     PERFORM CHECK-N
*>   The rule: a stone floor at y 30 near the player (plains biome, no surface branch).
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 10
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FLOOR-Y WS-KIND
     COMPUTE WS-X = WS-FX + 1
     COMPUTE WS-Z = WS-FZ + 1
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z / 16)
     COMPUTE WS-FY = WS-FLOOR-Y + 1
     MOVE 0 TO WS-REASON
     MOVE 2 TO BW-DIFFICULTY
*>   A world seed whose chunk here is a slime chunk: some tries pass (one in ten), not all.
     MOVE 0 TO WS-SLIME
     PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SLIME = 1 OR WS-SEED > 500
         CALL "M44-SLIME-CHUNK" USING WS-CX WS-CZ WS-SEED WS-SLIME
     END-PERFORM
     SUBTRACT 1 FROM WS-SEED
     MOVE WS-SEED TO CW-SEED
     PERFORM TRIES
     MOVE "acceptance US15 20§10 Slime: a slime chunk below y 40 lets some tries spawn" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-HITS >= 1 AND WS-HITS < 150
         MOVE 1 TO WS-OBS
     END-IF
     MOVE WS-EXP TO WS-E
     MOVE WS-OBS TO WS-O
     PERFORM CHECK-N
*>   Above y 40 the same chunk never spawns (plains).
     COMPUTE WS-FY = 45
     PERFORM TRIES
     MOVE "acceptance US15 20§10 Slime: a slime chunk at y 45 never spawns" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-EXP TO WS-E
     MOVE WS-HITS TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-FY = WS-FLOOR-Y + 1
*>   A world seed whose chunk here is not a slime chunk never spawns.
     MOVE 1 TO WS-SLIME
     MOVE 1 TO WS-SEED
     PERFORM UNTIL WS-SLIME = 0
         CALL "M44-SLIME-CHUNK" USING WS-CX WS-CZ WS-SEED WS-SLIME
         ADD 1 TO WS-SEED
     END-PERFORM
     SUBTRACT 1 FROM WS-SEED
     MOVE WS-SEED TO CW-SEED
     PERFORM TRIES
     MOVE "acceptance US15 20§10 Slime: outside a slime chunk a plains cave never spawns" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-EXP TO WS-E
     MOVE WS-HITS TO WS-O
     PERFORM CHECK-N
     GOBACK.

 TRIES.
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
         MOVE WS-I TO WS-STATE-SEED
         CALL "XORO-SEED" USING WS-STATE-SEED XR-STATE
         MOVE 0 TO WS-OK
         CALL "STDMOB-SLIME-RULE" USING XR-STATE WS-DIM WS-X WS-FY WS-Z WS-REASON WS-OK
         ADD WS-OK TO WS-HITS
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-20-10-CHUNK.
 COPY CORETEST.
 COPY MOBSPTEST.
