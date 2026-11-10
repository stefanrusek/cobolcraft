*> Test of special use 3.2 (17 section 3.2; core/src/tools-use.cob): the shears' durability on mining, the correct-tool blocks, growing
*> plants, the pumpkin carve, the beehive and bee nest, the sheep and the other shearable entities.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-USE-3-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(48).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-TEXT                PIC X(48).
 01 WS-TEXT2               PIC X(48).
 01 WS-SOUND               PIC X(32).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "acceptance US14 shears mining costs 1 durability per broken block unless the hardness is 0 or the block is in tag fire" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 800 TO WS-A
     MOVE 0 TO WS-B
     PERFORM MINE-COST
     MOVE 0 TO WS-A
     PERFORM MINE-COST
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     PERFORM MINE-COST
     MOVE 200 TO WS-A
     MOVE 1 TO WS-B
     PERFORM MINE-COST
     MOVE "1 0 0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 shears are the correct tool for cobweb, every leaves block, vine and glow_lichen, not for stone or wool" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "cobweb" TO WS-KEY
     PERFORM CORRECT
     MOVE "oak_leaves" TO WS-KEY
     PERFORM CORRECT
     MOVE "azalea_leaves" TO WS-KEY
     PERFORM CORRECT
     MOVE "vine" TO WS-KEY
     PERFORM CORRECT
     MOVE "glow_lichen" TO WS-KEY
     PERFORM CORRECT
     MOVE "stone" TO WS-KEY
     PERFORM CORRECT
     MOVE "white_wool" TO WS-KEY
     PERFORM CORRECT
     MOVE "1 1 1 1 1 0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 shears on a growing plant head (kelp, weeping_vines, twisting_vines, cave_vines) below the max age stop its growth: sound block.growing_plant.crop, 1 durability" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "kelp" TO WS-KEY
     PERFORM PLANT
     MOVE "weeping_vines" TO WS-KEY
     PERFORM PLANT
     MOVE "twisting_vines" TO WS-KEY
     PERFORM PLANT
     MOVE "cave_vines" TO WS-KEY
     PERFORM PLANT
     MOVE "vine" TO WS-KEY
     PERFORM PLANT
     MOVE "1/25 1/25 1/25 1/25 0/0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 shears on a pumpkin: carved_pumpkin, sound block.pumpkin.carve, 4 pumpkin_seeds at 0.65 x the face normal, 1 durability" TO TL-CASE
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "TOOL-PUMPKIN-CARVE" USING WS-A WS-B WS-TEXT WS-SOUND WS-C WS-D WS-E
     MOVE WS-C TO WS-E1
     MOVE WS-D TO WS-E2
     MOVE WS-E TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-SOUND) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "north block.pumpkin.carve 4 650 1" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 pumpkin facing: a vertical face faces opposite the player's horizontal direction, a side face faces the clicked direction" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-A
     MOVE 5 TO WS-B
     PERFORM CARVE-FACING
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     PERFORM CARVE-FACING
     MOVE 1 TO WS-A
     MOVE 4 TO WS-B
     PERFORM CARVE-FACING
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     PERFORM CARVE-FACING
     MOVE 2 TO WS-A
     MOVE 5 TO WS-B
     PERFORM CARVE-FACING
     MOVE 5 TO WS-A
     MOVE 5 TO WS-B
     PERFORM CARVE-FACING
     MOVE 3 TO WS-A
     MOVE 2 TO WS-B
     PERFORM CARVE-FACING
     MOVE 4 TO WS-A
     MOVE 2 TO WS-B
     PERFORM CARVE-FACING
     MOVE "west south east north north east south west" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 shears on a beehive at honey level 5 rolls 3 honeycomb (sound block.beehive.shear, 1 durability), the honey level resets, the bees stay when smoky" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     PERFORM BEEHIVE
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     PERFORM BEEHIVE
     MOVE 0 TO WS-C
     PERFORM BEEHIVE
     MOVE 4 TO WS-A
     MOVE 1 TO WS-C
     PERFORM BEEHIVE
     MOVE "3/0/0/1 3/1/1/1 3/0/0/1 0/0/0/0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 a glass bottle on a beehive at honey level 5 fills a honey_bottle by the same smoke rule" TO TL-CASE
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "TOOL-BEEHIVE-BOTTLE" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE WS-D TO WS-E1
     MOVE WS-E TO WS-E2
     MOVE WS-F TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     CALL "TOOL-BEEHIVE-BOTTLE" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE WS-D TO WS-E1
     MOVE WS-E TO WS-E2
     MOVE WS-F TO WS-E3
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1/0/0 1/1/1" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 smoke: a lit campfire 1 to 5 blocks below the hive with no solid cover between makes it smoky" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     PERFORM SMOKY
     MOVE 5 TO WS-A
     PERFORM SMOKY
     MOVE 6 TO WS-A
     PERFORM SMOKY
     MOVE 0 TO WS-A
     PERFORM SMOKY
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     PERFORM SMOKY
     MOVE "1 1 0 0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 shears on a sheep: an unsheared adult drops 1 to 3 wool of its colour (sound entity.sheep.shear, 1 durability), not a sheared sheep or a lamb" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "red" TO WS-KEY
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     PERFORM SHEEP
     MOVE 2 TO WS-C
     MOVE "light_blue" TO WS-KEY
     PERFORM SHEEP
     MOVE 1 TO WS-A
     PERFORM SHEEP
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     PERFORM SHEEP
     MOVE "red_wool/1/1 light_blue_wool/3/1 -/0/0 -/0/0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 shears on a mooshroom (5 red or brown mushrooms, becomes a cow), a snow golem (carved_pumpkin), a bogged (2 rolls of 1 mushroom)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "mooshroom" TO WS-KEY
     MOVE "red" TO WS-TEXT
     PERFORM OTHER-ENTITY
     MOVE "brown" TO WS-TEXT
     PERFORM OTHER-ENTITY
     MOVE "snow_golem" TO WS-KEY
     PERFORM OTHER-ENTITY
     MOVE "bogged" TO WS-KEY
     PERFORM OTHER-ENTITY
     MOVE "pig" TO WS-KEY
     PERFORM OTHER-ENTITY
     MOVE "red_mushroom/5 brown_mushroom/5 carved_pumpkin/1 mushroom/2 -/0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     STOP RUN.

 MINE-COST.
     CALL "TOOL-SHEARS-MINE-COST" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-E1
     PERFORM APPEND-E1.

 CORRECT.
     CALL "TOOL-SHEARS-CORRECT" USING WS-KEY WS-A
     MOVE WS-A TO WS-E1
     PERFORM APPEND-E1.

 PLANT.
     CALL "TOOL-SHEARS-PLANT" USING WS-KEY WS-A WS-B
     MOVE WS-A TO WS-E1
     MOVE WS-B TO WS-E2
     MOVE SPACES TO WS-TEXT2
     STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT2
     PERFORM APPEND-TEXT2.

 CARVE-FACING.
     CALL "TOOL-PUMPKIN-CARVE" USING WS-A WS-B WS-TEXT WS-SOUND WS-C WS-D WS-E
     MOVE WS-TEXT TO WS-TEXT2
     PERFORM APPEND-TEXT2.

 BEEHIVE.
     CALL "TOOL-BEEHIVE-SHEAR" USING WS-A WS-B WS-C WS-D WS-E WS-F
     MOVE WS-D TO WS-E1
     MOVE WS-E TO WS-E2
     MOVE WS-F TO WS-E3
     MOVE SPACES TO WS-TEXT2
     STRING "3/" DELIMITED BY SIZE INTO WS-TEXT2
     IF WS-D = 0
         MOVE "0/" TO WS-TEXT2
     END-IF
     STRING FUNCTION TRIM(WS-TEXT2) FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) "/" FUNCTION TRIM(WS-E1)
         DELIMITED BY SIZE INTO WS-TEXT2
     PERFORM APPEND-TEXT2.

 SMOKY.
     CALL "TOOL-BEEHIVE-SMOKY" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-E1
     PERFORM APPEND-E1.

 SHEEP.
     CALL "TOOL-SHEEP-SHEAR" USING WS-KEY WS-A WS-B WS-C WS-TEXT WS-D WS-E
     MOVE WS-D TO WS-E1
     MOVE WS-E TO WS-E2
     MOVE SPACES TO WS-TEXT2
     IF WS-D = 0
         MOVE "-" TO WS-TEXT
     END-IF
     STRING FUNCTION TRIM(WS-TEXT) "/" FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT2
     PERFORM APPEND-TEXT2.

 OTHER-ENTITY.
     CALL "TOOL-SHEAR-ENTITY" USING WS-KEY WS-TEXT WS-TEXT2 WS-A
     IF WS-A = 0
         MOVE "-" TO WS-TEXT2
     END-IF
     MOVE WS-A TO WS-E1
     MOVE SPACES TO WS-SOUND
     STRING FUNCTION TRIM(WS-TEXT2) "/" FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-SOUND
     MOVE WS-SOUND TO WS-TEXT2
     PERFORM APPEND-TEXT2.

 APPEND-E1.
     MOVE WS-E1 TO WS-TEXT2
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT2
     PERFORM APPEND-TEXT2.

 APPEND-TEXT2.
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-TEXT2) TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT2) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-USE-3-2.
