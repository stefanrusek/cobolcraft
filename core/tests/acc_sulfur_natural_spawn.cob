*> Acceptance test (CC-0046, operator report of try8: "a sulfur cave under spawn on seed 4 but no sulfur cubes spawned"; docs/protocol/20 section 18.2 and 18 sections 6.5, 6.6, 6.8 and
*> Appendix A): natural spawning of the sulfur cube through the real pack spawner (MS6-PACK, the spawn list of the sulfur_caves biome in MOBSPAWN.cpy, the species row of STDMOBS.cpy, rule
*> code 17, the placement and cost checks, MOB-SPAWN). The sulfur cube is a monster of the sulfur_caves biome only (weight 100, group of 2 to 4); its spawn rule checkSulfurCubeSpawnRules
*> is always true, so neither light nor the time of day keeps it from spawning (a cave is dark anyway). On a stone floor in full daylight far from the player the pack of the sulfur_caves biome
*> spawns sulfur cubes in groups of 2 to 4, none within 24 blocks of the player, and the same floor in the plains biome spawns none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SULFUR-NATURAL-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY STDMOBS.
 COPY BRWORLD.
 01 WS-CASE               PIC X(100).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
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
 01 WS-I                  BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-ZROW               BINARY-LONG.
 01 WS-CAT                BINARY-LONG VALUE 1.
 01 WS-BIOME              BINARY-LONG.
 01 WS-BIOME-KEY          PIC X(48).
 01 WS-SPAWNED            BINARY-LONG.
 01 WS-MAX                BINARY-LONG.
 01 WS-CUBES              BINARY-LONG.
 01 WS-NEAR               BINARY-LONG.
 01 WS-FLOOR-SIZE         BINARY-LONG.
 01 WS-KIND               BINARY-LONG.
 01 WS-NAME               PIC X(24).
 01 WS-TYPE               BINARY-LONG.
 01 WS-DX                 FLOAT-LONG.
 01 WS-DY                 FLOAT-LONG.
 01 WS-DZ                 FLOAT-LONG.
 01 WS-D2                 FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = WS-PY + 40
     MOVE "sulfur_cube" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-ZROW
*>   A stone floor 28 blocks east of the player and 40 above it, three layers of air over it, in full daylight.
     COMPUTE WS-QX = WS-PX + 20
     COMPUTE WS-QZ = WS-PZ - 10
     MOVE 20 TO WS-FLOOR-SIZE
     MOVE 1 TO WS-KIND
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-QX WS-QZ WS-FLOOR-SIZE WS-FY WS-KIND
     COMPUTE WS-QX = WS-PX + 30
     COMPUTE WS-QZ = WS-PZ
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
     COMPUTE WS-PY = WS-FY + 1
*>   The plains biome has no sulfur cube in its list: at night the zombies and the rest of its list spawn on the floor, but no cube does.
     MOVE 18000 TO CW-TIME
     MOVE "minecraft:plains" TO WS-BIOME-KEY
     CALL "MS6-BIOME-FIND" USING WS-BIOME-KEY WS-BIOME
     PERFORM RUN-PACKS
     MOVE "acceptance 20§18.2 the plains biome spawns no sulfur cube (the species is the sulfur_caves biome's)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-N
*>   The sulfur_caves biome: cubes spawn by day (the rule is always true) in groups of 2 to 4, never within 24 blocks of the player.
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:sulfur_caves" TO WS-BIOME-KEY
     CALL "MS6-BIOME-FIND" USING WS-BIOME-KEY WS-BIOME
     MOVE "acceptance 20§19.1 the sulfur_caves biome is in the spawn data" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-BIOME, 1)
     PERFORM CHECK-N
     PERFORM RUN-PACKS
     MOVE "acceptance 20§18.2 a pack of the sulfur_caves biome spawns sulfur cubes on a stone floor by day" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-CUBES, 1)
     PERFORM CHECK-N
     MOVE "acceptance 20§19.1 a pack of the sulfur_caves biome is at least 2 mobs somewhere (group of 2 to 4)" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-MAX, 2) - 1
     PERFORM CHECK-N
     MOVE "acceptance 20§19.1 one pack is never more than 4 mobs" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(1, 5 - WS-MAX)
     PERFORM CHECK-N
     MOVE "acceptance 44-1§4 no sulfur cube spawns within 24 blocks of the player" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-NEAR TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
*> 80 pack attempts at the start cell (a different seed each): WS-MAX the largest pack, WS-CUBES the sulfur cubes alive afterwards, WS-NEAR those within 24 blocks of the player.
 RUN-PACKS.
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-PACK" USING XR-STATE WS-DIM WS-CAT WS-BIOME WS-CX WS-CZ WS-QX WS-PY WS-QZ WS-SPAWNED
         IF WS-SPAWNED > WS-MAX
             MOVE WS-SPAWNED TO WS-MAX
         END-IF
     END-PERFORM
     MOVE 0 TO WS-CUBES WS-NEAR
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-TYPE(WS-ROW) = WS-TYPE
             ADD 1 TO WS-CUBES
             COMPUTE WS-DX = EN-X(WS-ROW) - PL-X(WS-PLAYER)
             COMPUTE WS-DY = EN-Y(WS-ROW) - PL-Y(WS-PLAYER)
             COMPUTE WS-DZ = EN-Z(WS-ROW) - PL-Z(WS-PLAYER)
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 <= 576
                 ADD 1 TO WS-NEAR
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM ACC-SULFUR-NATURAL-SPAWN.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
