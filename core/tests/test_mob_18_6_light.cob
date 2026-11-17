*> Implementation test (002-lane-spawnfix; docs/protocol/18-mob-framework.md sections 6.5 and 6.8, 44 part 2 section 3): a hostile mob does not spawn in daylight
*> on the surface (open sky, grass or a flower in its cell, a canopy of leaves above it), still spawns in a cave and at night, and not within 24 blocks of
*> the world spawn point.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-LIGHT.
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
 01 WS-CHUNK              BINARY-LONG.
 01 WS-Y                  BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-CAT                BINARY-LONG.
 01 WS-BIOME              BINARY-LONG.
 01 WS-BIOME-KEY          PIC X(48) VALUE "minecraft:plains".
 01 WS-SPAWNED            BINARY-LONG.
 01 WS-TOTAL              BINARY-LONG.
 01 WS-PASS               BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-REASON             BINARY-LONG VALUE 0.
 01 WS-FLOOR-SIZE         BINARY-LONG.
 01 WS-KIND               BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-NAME               PIC X(24).
 01 WS-TYPE               BINARY-LONG.
 01 WS-BAD                BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-ZROW               BINARY-LONG.
 01 WS-A                  BINARY-LONG.
 01 WS-B                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = WS-PY + 40
     CALL "MS6-BIOME-FIND" USING WS-BIOME-KEY WS-BIOME
     MOVE "zombie" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-ZROW
*>   A stone floor 28 blocks east of the player and 40 above it, three layers of air over it.
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
*>   Daylight, open sky.
     MOVE 6000 TO CW-TIME
     PERFORM COUNT-PASSES
     MOVE "acceptance 18§6.8 a zombie rule never passes by day under open sky" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PASS TO WS-O
     PERFORM CHECK-N
*>   Daylight, a plant (short grass) in the mob's own cell.
     MOVE "minecraft:short_grass" TO WS-KEY
     MOVE 1 TO WS-I
     PERFORM SET-AT
     PERFORM COUNT-PASSES
     MOVE "acceptance 18§6.8 a zombie rule never passes by day with grass in its cell" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PASS TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:air" TO WS-KEY
     MOVE 1 TO WS-I
     PERFORM SET-AT
*>   Daylight, a roof of leaves 3 above the floor (a forest canopy).
     MOVE "minecraft:oak_leaves" TO WS-KEY
     MOVE 3 TO WS-I
     PERFORM SET-AT
     PERFORM COUNT-PASSES
     MOVE "acceptance 18§6.8 a zombie rule never passes by day under a canopy of leaves" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PASS TO WS-O
     PERFORM CHECK-N
*>   A cave: a stone roof, by day and by night.
     MOVE "minecraft:stone" TO WS-KEY
     MOVE 3 TO WS-I
     PERFORM SET-AT
     PERFORM COUNT-PASSES
     MOVE "acceptance 18§6.8 a zombie rule passes under a stone roof by day" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N
     MOVE "minecraft:air" TO WS-KEY
     MOVE 3 TO WS-I
     PERFORM SET-AT
*>   Night, open sky.
     MOVE 18000 TO CW-TIME
     PERFORM COUNT-PASSES
     MOVE "acceptance 18§6.8 a zombie rule passes at night under open sky" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N
*>   Spawn protection: the pack never lands within 24 blocks of the world spawn; far from it the same positions do spawn.
     MOVE 1 TO WS-CAT
     MOVE WS-QX TO CW-SPAWN-X
     MOVE WS-QZ TO CW-SPAWN-Z
     MOVE WS-FY TO CW-SPAWN-Y
     PERFORM RUN-PACKS
     MOVE "acceptance 44-2§3 no monster pack spawns within 24 blocks of the world spawn" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-TOTAL TO WS-O
     PERFORM CHECK-N
     COMPUTE CW-SPAWN-X = WS-PX - 200
     PERFORM RUN-PACKS
     MOVE "acceptance 44-2§3 the same pack spawns at night when the world spawn is far away" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-TOTAL, 1)
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
*> Set the block WS-KEY over the 5 x 5 cells around the test spot at WS-FY + WS-I, then light the chunk again.
 SET-AT.
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-BY = WS-FY + WS-I
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 24
         COMPUTE WS-BX = WS-QX - 2 + FUNCTION MOD(WS-J, 5)
         COMPUTE WS-BZ = WS-QZ - 2 + FUNCTION INTEGER(WS-J / 5)
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     END-PERFORM.
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
 RUN-PACKS.
     PERFORM RELIGHT
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-PACK" USING XR-STATE WS-DIM WS-CAT WS-BIOME WS-CX WS-CZ WS-QX WS-Y WS-QZ WS-SPAWNED
         ADD WS-SPAWNED TO WS-TOTAL
     END-PERFORM.
 END PROGRAM TEST-MOB-18-6-LIGHT.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
