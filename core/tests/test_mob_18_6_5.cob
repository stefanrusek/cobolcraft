*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.5, with doc 44 part 1 section 4): spawning a pack at a position.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY MOBSPAWN.
 COPY BRWORLD.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-MIRROR.
    05 WS-M-LO            BINARY-DOUBLE UNSIGNED.
    05 WS-M-HI            BINARY-DOUBLE UNSIGNED.
 01 WS-PLAYER            BINARY-LONG.
 01 WS-DIM               BINARY-LONG.
 01 WS-PX                BINARY-LONG.
 01 WS-PY                BINARY-LONG.
 01 WS-PZ                BINARY-LONG.
 01 WS-FY                BINARY-LONG.
 01 WS-QX                BINARY-LONG.
 01 WS-QZ                BINARY-LONG.
 01 WS-CX                BINARY-LONG.
 01 WS-CZ                BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-ROW               BINARY-LONG.
 01 WS-CAT               BINARY-LONG.
 01 WS-BIOME             BINARY-LONG.
 01 WS-BIOME-KEY         PIC X(48) VALUE "minecraft:plains".
 01 WS-SPAWNED           BINARY-LONG.
 01 WS-TOTAL             BINARY-LONG.
 01 WS-MAX               BINARY-LONG.
 01 WS-BAD               BINARY-LONG.
 01 WS-FLOOR-SIZE        BINARY-LONG.
 01 WS-KIND              BINARY-LONG.
 01 WS-DX                FLOAT-LONG.
 01 WS-DY                FLOAT-LONG.
 01 WS-DZ                FLOAT-LONG.
 01 WS-D2                FLOAT-LONG.
 01 WS-BEFORE            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 6000 TO CW-TIME
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = WS-PY + 40
     CALL "MS6-BIOME-FIND" USING WS-BIOME-KEY WS-BIOME
*>   A far grass floor (28 blocks east, 41 above the player): animals.
     COMPUTE WS-QX = WS-PX + 18
     COMPUTE WS-QZ = WS-PZ - 10
     MOVE 20 TO WS-FLOOR-SIZE
     MOVE 2 TO WS-KIND
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
     MOVE 2 TO WS-CAT
     COMPUTE WS-PY = WS-FY + 1
     PERFORM RUN-PACKS
     MOVE "acceptance US15 18§6.5 Spawning a pack: creature packs spawn on a lit grass floor far from the player" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = FUNCTION MIN(WS-TOTAL, 1)
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.5 Spawning a pack: a call spawns at most 4 mobs (the cluster size)" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = FUNCTION MIN(1, 5 - WS-MAX)
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.5 Spawning a pack: no spawned mob is within 24 blocks of the player (squared distance above 576)" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-BAD
     PERFORM CHECK-N
     PERFORM COUNT-ROWS
     MOVE WS-BEFORE TO WS-E
     MOVE WS-FY TO WS-PY
     PERFORM RUN-PACKS
     MOVE "acceptance US15 18§6.5 Spawning a pack: a start block that is a full solid block spawns nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-TOTAL TO WS-O
     PERFORM CHECK-N
*>   A grass floor under the player: every candidate is within 24 blocks.
     COMPUTE WS-QX = WS-PX - 6
     COMPUTE WS-QZ = WS-PZ - 6
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     MOVE 12 TO WS-FLOOR-SIZE
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-QX WS-QZ WS-FLOOR-SIZE WS-FY WS-KIND
     COMPUTE WS-QX = WS-PX + 2
     COMPUTE WS-QZ = WS-PZ + 2
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
     IF WS-QX < 0
         COMPUTE WS-CX = (WS-QX - 15) / 16
     END-IF
     IF WS-QZ < 0
         COMPUTE WS-CZ = (WS-QZ - 15) / 16
     END-IF
     COMPUTE WS-PY = WS-FY + 1
     PERFORM RUN-PACKS
     MOVE "acceptance US15 18§6.5 Spawning a pack: a start within 24 blocks of the only player spawns nothing" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-TOTAL
     PERFORM CHECK-N
*>   Monsters on a stone floor far away: none by day (light), some at night (dark), none on Peaceful.
     COMPUTE WS-QX = WS-PX + 18
     COMPUTE WS-QZ = WS-PZ - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     MOVE 20 TO WS-FLOOR-SIZE
     MOVE 1 TO WS-KIND
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
     MOVE 1 TO WS-CAT
     MOVE 6000 TO CW-TIME
     PERFORM RUN-PACKS
     MOVE "acceptance US15 18§6.5 Spawning a pack: no monster pack spawns in full daylight" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-TOTAL
     PERFORM CHECK-N
     MOVE 18000 TO CW-TIME
     MOVE 0 TO BW-DIFFICULTY
     PERFORM RUN-PACKS
     MOVE "acceptance US15 18§6.5 Spawning a pack: Peaceful allows no monster pack, even at night" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-TOTAL
     PERFORM CHECK-N
     MOVE 2 TO BW-DIFFICULTY
     PERFORM RUN-PACKS
     MOVE "acceptance US15 18§6.5 Spawning a pack: monster packs spawn at night" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = FUNCTION MIN(WS-TOTAL, 1)
     PERFORM CHECK-N
     MOVE "acceptance US15 44-1§4 no spawned monster is within 24 blocks of the player" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-BAD
     PERFORM CHECK-N

     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 RUN-PACKS.
     MOVE 0 TO WS-TOTAL WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-PACK" USING XR-STATE WS-DIM WS-CAT WS-BIOME WS-CX WS-CZ WS-QX WS-PY WS-QZ WS-SPAWNED
         ADD WS-SPAWNED TO WS-TOTAL
         IF WS-SPAWNED > WS-MAX
             MOVE WS-SPAWNED TO WS-MAX
         END-IF
     END-PERFORM
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             COMPUTE WS-DX = EN-X(WS-ROW) - PL-X(WS-PLAYER)
             COMPUTE WS-DY = EN-Y(WS-ROW) - PL-Y(WS-PLAYER)
             COMPUTE WS-DZ = EN-Z(WS-ROW) - PL-Z(WS-PLAYER)
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 <= 576
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM.
 COUNT-ROWS.
     MOVE 0 TO WS-BEFORE
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             ADD 1 TO WS-BEFORE
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-18-6-5.
 COPY CORETEST.
 COPY MOBSPTEST.
