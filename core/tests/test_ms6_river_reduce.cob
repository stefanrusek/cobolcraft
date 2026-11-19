*> Acceptance test (lane 002-lane-p49s, T38600; docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 8.1 step 3): for the category water_ambient in a biome of the tag
*> reduce_water_ambient_spawns (is_river: river and frozen_river) the spawner first rolls nextFloat < 0.98 and then draws the list, so it consumes one more draw than in any other biome
*> (plains: none consumed before the draw of the list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MS6-RIVER-REDUCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY MOBSPAWN.
 COPY BRWORLD.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-PX                 BINARY-LONG.
 01 WS-PZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-PY                 BINARY-LONG.
 01 WS-QX                 BINARY-LONG.
 01 WS-QZ                 BINARY-LONG.
 01 WS-CX                 BINARY-LONG.
 01 WS-CZ                 BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-CAT                BINARY-LONG.
 01 WS-RIVER              BINARY-LONG.
 01 WS-FROZEN             BINARY-LONG.
 01 WS-PLAINS             BINARY-LONG.
 01 WS-KEY48              PIC X(48).
 01 WS-SPAWNED            BINARY-LONG.
 01 WS-FLOOR-SIZE         BINARY-LONG VALUE 20.
 01 WS-KIND               BINARY-LONG VALUE 1.
 01 WS-LO-A               BINARY-DOUBLE UNSIGNED.
 01 WS-LO-B               BINARY-DOUBLE UNSIGNED.
 01 WS-DIFF               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 18000 TO CW-TIME
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     MOVE "minecraft:river" TO WS-KEY48
     CALL "MS6-BIOME-FIND" USING WS-KEY48 WS-RIVER
     MOVE "minecraft:frozen_river" TO WS-KEY48
     CALL "MS6-BIOME-FIND" USING WS-KEY48 WS-FROZEN
     MOVE "minecraft:plains" TO WS-KEY48
     CALL "MS6-BIOME-FIND" USING WS-KEY48 WS-PLAINS
     COMPUTE WS-QX = WS-PX + 18
     COMPUTE WS-QZ = WS-PZ - 10
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-QX WS-QZ WS-FLOOR-SIZE WS-FY WS-KIND
     COMPUTE WS-QX = WS-PX + 28
     COMPUTE WS-QZ = WS-PZ
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
     IF WS-QX < 0
         COMPUTE WS-CX = (WS-QX - 15) / 16
     END-IF
     IF WS-QZ < 0
         COMPUTE WS-CZ = (WS-QZ - 15) / 16
     END-IF
     COMPUTE WS-PY = WS-FY + 1
     MOVE 7 TO WS-CAT
     MOVE "acceptance US15 44-2§8.1 step 3 water_ambient in a river: the 0.98 roll consumes a draw plains does not" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-RIVER TO WS-I
     PERFORM COUNT-DIFFERENT
     MOVE WS-DIFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-2§8.1 step 3 the same in a frozen river" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-FROZEN TO WS-I
     PERFORM COUNT-DIFFERENT
     MOVE WS-DIFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COUNT-DIFFERENT.
*>   Over 20 seeds: the generator state after MS6-PACK in the biome WS-I against the state in plains, both from the same seed; WS-DIFF counts the seeds where they differ.
     MOVE 0 TO WS-DIFF
     PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 20
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-PACK" USING XR-STATE WS-DIM WS-CAT WS-I WS-CX WS-CZ WS-QX WS-PY WS-QZ WS-SPAWNED
         MOVE XR-LO TO WS-LO-A
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-PACK" USING XR-STATE WS-DIM WS-CAT WS-PLAINS WS-CX WS-CZ WS-QX WS-PY WS-QZ WS-SPAWNED
         MOVE XR-LO TO WS-LO-B
         IF WS-LO-A NOT = WS-LO-B
             ADD 1 TO WS-DIFF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MS6-RIVER-REDUCE.
 COPY CORETEST.
 COPY MOBSPTEST.
