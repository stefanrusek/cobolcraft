*> Implementation test (002-lane-bugvillage; docs/protocol/18-mob-framework.md sections 6.8 and 6.9): the block below a natural spawn must have a sturdy top face
*> (Block.isValidSpawn: the top face is sturdy and the light emission is below 14), not merely a collision shape. At night under open sky the zombie rule passes on stone
*> and on a stair or slab that holds its full face up (half top, type top or double); it never passes on a bottom stair or slab, a bed, a carpet, farmland, a path, a
*> fence, a cauldron (a water cauldron is no water cell) or a pane.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-FLOOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY STDMOBS.
 COPY BRWORLD.
 01 WS-CASE               PIC X(120).
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
 01 WS-PASS               BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-REASON             BINARY-LONG VALUE 0.
 01 WS-FLOOR-SIZE         BINARY-LONG.
 01 WS-KIND               BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-PAIRS              PIC X(160).
 01 WS-NAME               PIC X(24).
 01 WS-TYPE               BINARY-LONG.
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
     MOVE "zombie" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-ZROW
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
     MOVE 18000 TO CW-TIME
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM TRY-FLOOR
     MOVE "bugvillage 18§6.9 a zombie spawns at night on a stone floor" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N
     MOVE "minecraft:oak_stairs" TO WS-KEY
     MOVE "facing=north,half=top,shape=straight,waterlogged=false" TO WS-PAIRS
     PERFORM TRY-FLOOR
     MOVE "bugvillage 18§6.9 a zombie spawns on a stair that holds its full face up (half top)" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N
     MOVE "minecraft:oak_slab" TO WS-KEY
     MOVE "type=top,waterlogged=false" TO WS-PAIRS
     PERFORM TRY-FLOOR
     MOVE "bugvillage 18§6.9 a zombie spawns on a top slab" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N
     MOVE "minecraft:oak_slab" TO WS-KEY
     MOVE "type=double,waterlogged=false" TO WS-PAIRS
     PERFORM TRY-FLOOR
     MOVE "bugvillage 18§6.9 a zombie spawns on a double slab" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N
     MOVE "minecraft:oak_stairs" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:oak_slab" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:white_bed" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:white_carpet" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:farmland" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:dirt_path" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:oak_fence" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:glass_pane" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:cauldron" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:water_cauldron" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
*>   What a cell holds (MS6-BLOCK-KIND): the fluids and the fire are those blocks, not every key that holds the word.
     MOVE "minecraft:water" TO WS-KEY
     MOVE 2 TO WS-E
     PERFORM KIND-OF
     MOVE "minecraft:lava" TO WS-KEY
     MOVE 3 TO WS-E
     PERFORM KIND-OF
     MOVE "minecraft:fire" TO WS-KEY
     MOVE 4 TO WS-E
     PERFORM KIND-OF
     MOVE "minecraft:soul_fire" TO WS-KEY
     MOVE 4 TO WS-E
     PERFORM KIND-OF
     MOVE "minecraft:rail" TO WS-KEY
     MOVE 5 TO WS-E
     PERFORM KIND-OF
     MOVE "minecraft:water_cauldron" TO WS-KEY
     MOVE 1 TO WS-E
     PERFORM KIND-OF
     MOVE "minecraft:lava_cauldron" TO WS-KEY
     MOVE 1 TO WS-E
     PERFORM KIND-OF
     MOVE "minecraft:campfire" TO WS-KEY
     MOVE 1 TO WS-E
     PERFORM KIND-OF
     MOVE "minecraft:fire_coral_block" TO WS-KEY
     MOVE 1 TO WS-E
     PERFORM KIND-OF
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
*> The pass count of 200 seeds with the block (WS-KEY, WS-PAIRS) as the floor under the spot.
 TRY-FLOOR.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-FY TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-QX WS-BY WS-QZ WS-STATE
     PERFORM RELIGHT
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-VALID-SPOT" USING XR-STATE WS-DIM WS-ZROW WS-QX WS-Y WS-QZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM.
 TRY-FLOOR-NONE.
     PERFORM TRY-FLOOR
     MOVE SPACES TO WS-CASE
     STRING "bugvillage 18§6.9 no zombie spawns on " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PASS TO WS-O
     PERFORM CHECK-N.
 KIND-OF.
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     COMPUTE WS-BX = WS-QX + 5
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y WS-QZ WS-STATE
     CALL "MS6-BLOCK-KIND" USING WS-DIM WS-BX WS-Y WS-QZ WS-KIND
     MOVE SPACES TO WS-CASE
     STRING "bugvillage 18§6.9 the kind of a cell that holds " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-KIND TO WS-O
     PERFORM CHECK-N.
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
 END PROGRAM TEST-MOB-18-6-FLOOR.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
