*> Crops and stems (docs/protocol/29b part 2 sections 1 to 5) as programs of plain numbers (GB2- prefix): the block table of 1, the tag membership of 2, the CropBlock family of 3, the pitcher
*> crop of 4 and the stems, attached stems, pumpkin and melon of 5. Every program takes USING in out (or in key out): "in" and "out" are groups of sixteen BINARY-LONG; each header lists the
*> fields in order. Random draws are inputs (the caller draws nextInt(bound) and tests the result), float draws are given in millionths, a speed in hundredths. Nothing here is wired into
*> the play path (part 1 wires only the CropBlock random tick, bone meal on crops and saplings); sections 6 to 13 are in growth-29b-2b.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-BLOCK.
*> USING block key (PIC X(48)), out: section times ten of this document that describes the block (0 for a block not covered), registration flag random ticks (1/0), instabreak (1/0) (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-OUT.
    05 L-SECTION           BINARY-LONG.
    05 L-TICKS             BINARY-LONG.
    05 L-INSTA             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 PROCEDURE DIVISION USING L-KEY L-OUT.
     MOVE 0 TO L-SECTION L-TICKS L-INSTA
     EVALUATE TRUE
         WHEN L-KEY = "minecraft:wheat" OR L-KEY = "minecraft:carrots" OR L-KEY = "minecraft:potatoes"
             MOVE 30 TO L-SECTION
             MOVE 1 TO L-TICKS L-INSTA
         WHEN L-KEY = "minecraft:beetroots"
             MOVE 33 TO L-SECTION
             MOVE 1 TO L-TICKS L-INSTA
         WHEN L-KEY = "minecraft:torchflower_crop"
             MOVE 34 TO L-SECTION
             MOVE 1 TO L-TICKS L-INSTA
         WHEN L-KEY = "minecraft:pitcher_crop"
             MOVE 40 TO L-SECTION
             MOVE 1 TO L-TICKS L-INSTA
         WHEN L-KEY = "minecraft:pumpkin_stem"
             MOVE 51 TO L-SECTION
             MOVE 1 TO L-TICKS L-INSTA
         WHEN L-KEY = "minecraft:melon_stem"
             MOVE 52 TO L-SECTION
             MOVE 1 TO L-TICKS L-INSTA
         WHEN L-KEY = "minecraft:attached_pumpkin_stem" OR L-KEY = "minecraft:attached_melon_stem"
             MOVE 53 TO L-SECTION
             MOVE 0 TO L-TICKS
             MOVE 1 TO L-INSTA
         WHEN L-KEY = "minecraft:pumpkin" OR L-KEY = "minecraft:melon"
             MOVE 54 TO L-SECTION
         WHEN L-KEY = "minecraft:nether_wart"
             MOVE 60 TO L-SECTION
             MOVE 1 TO L-TICKS
         WHEN L-KEY = "minecraft:cocoa"
             MOVE 70 TO L-SECTION
             MOVE 1 TO L-TICKS
         WHEN L-KEY = "minecraft:sweet_berry_bush"
             MOVE 80 TO L-SECTION
             MOVE 1 TO L-TICKS
         WHEN L-KEY = "minecraft:farmland"
             MOVE 90 TO L-SECTION
             MOVE 1 TO L-TICKS
         WHEN L-KEY = "minecraft:dirt_path"
             MOVE 101 TO L-SECTION
         WHEN L-KEY = "minecraft:mud"
             MOVE 102 TO L-SECTION
         WHEN L-KEY = "minecraft:rooted_dirt"
             MOVE 103 TO L-SECTION
         WHEN L-KEY = "minecraft:mangrove_propagule"
             MOVE 111 TO L-SECTION
             MOVE 1 TO L-TICKS L-INSTA
         WHEN L-KEY = "minecraft:azalea" OR L-KEY = "minecraft:flowering_azalea"
             MOVE 112 TO L-SECTION
             MOVE 1 TO L-INSTA
         WHEN L-KEY = "minecraft:oak_sapling" OR L-KEY = "minecraft:spruce_sapling" OR L-KEY = "minecraft:birch_sapling"
              OR L-KEY = "minecraft:jungle_sapling" OR L-KEY = "minecraft:acacia_sapling" OR L-KEY = "minecraft:cherry_sapling"
              OR L-KEY = "minecraft:dark_oak_sapling" OR L-KEY = "minecraft:pale_oak_sapling" OR L-KEY = "minecraft:poplar_sapling"
             MOVE 113 TO L-SECTION
             MOVE 1 TO L-TICKS L-INSTA
     END-EVALUATE
     GOBACK.
 END PROGRAM GB2-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-VOCAB.
*> USING in (block light, sky light, sky darkening), out (rawBrightness(pos, 0), maxLocalRawBrightness(pos)) (2.1): the raw value is max(block, sky); the local one darkens the sky term (not below 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SKY                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-BLOCK             BINARY-LONG.
    05 L-SKY               BINARY-LONG.
    05 L-DARK              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-RAW               BINARY-LONG.
    05 L-LOCAL             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-RAW = FUNCTION MAX(L-BLOCK, L-SKY)
     COMPUTE WS-SKY = FUNCTION MAX(0, L-SKY - L-DARK)
     COMPUTE L-LOCAL = FUNCTION MAX(L-BLOCK, WS-SKY)
     GOBACK.
 END PROGRAM GB2-VOCAB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-TAG.
*> USING in (tag 1 supports_crops, 2 grows_crops, 3 supports_vegetation, 4 substrate_overworld, 5 supports_azalea, 6 supports_mangrove_propagule, 7 supports_cocoa, 8 supports_nether_wart,
*> 9 supports_pumpkin_stem, 10 supports_melon_stem, 11 supports_pumpkin_stem_fruit, 12 supports_melon_stem_fruit, 13 maintains_farmland, 14 supports_hanging_mangrove_propagule; then the
*> block is in each of the tags #dirt, #mud, #moss_blocks, #grass_blocks, #jungle_logs, #fence_gates, 1/0), block key (PIC X(48)), out (member 1/0): the members of 2.2 (data; the
*> tags that 2.2 names but does not list are the caller's flags).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SUBSTRATE           BINARY-LONG.
 01 WS-VEG                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-TAG               BINARY-LONG.
    05 L-DIRT              BINARY-LONG.
    05 L-MUD               BINARY-LONG.
    05 L-MOSS              BINARY-LONG.
    05 L-GRASS             BINARY-LONG.
    05 L-JUNGLE            BINARY-LONG.
    05 L-GATES             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 9 TIMES.
 01 L-KEY                  PIC X(48).
 01 L-OUT.
    05 L-MEMBER            BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 PROCEDURE DIVISION USING L-IN L-KEY L-OUT.
     MOVE 0 TO L-MEMBER WS-SUBSTRATE WS-VEG
     IF L-DIRT = 1 OR L-MUD = 1 OR L-MOSS = 1 OR L-GRASS = 1
         MOVE 1 TO WS-SUBSTRATE
     END-IF
     IF WS-SUBSTRATE = 1 OR L-KEY = "minecraft:farmland"
         MOVE 1 TO WS-VEG
     END-IF
     EVALUATE L-TAG
         WHEN 1 WHEN 2 WHEN 9 WHEN 10
             IF L-KEY = "minecraft:farmland"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 3 WHEN 11 WHEN 12
             MOVE WS-VEG TO L-MEMBER
         WHEN 4
             MOVE WS-SUBSTRATE TO L-MEMBER
         WHEN 5 WHEN 6
             IF WS-VEG = 1 OR L-KEY = "minecraft:clay"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 7
             MOVE L-JUNGLE TO L-MEMBER
         WHEN 8
             IF L-KEY = "minecraft:soul_sand"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 13
             IF L-GATES = 1 OR L-KEY = "minecraft:pumpkin_stem" OR L-KEY = "minecraft:attached_pumpkin_stem"
                OR L-KEY = "minecraft:melon_stem" OR L-KEY = "minecraft:attached_melon_stem" OR L-KEY = "minecraft:beetroots"
                OR L-KEY = "minecraft:carrots" OR L-KEY = "minecraft:potatoes" OR L-KEY = "minecraft:torchflower_crop"
                OR L-KEY = "minecraft:torchflower" OR L-KEY = "minecraft:pitcher_crop" OR L-KEY = "minecraft:wheat"
                OR L-KEY = "minecraft:moving_piston"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 14
             IF L-KEY = "minecraft:mangrove_leaves"
                 MOVE 1 TO L-MEMBER
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GB2-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-CROP-CLASS.
*> USING in (block 1 wheat, 2 carrots, 3 potatoes, 4 beetroots, 5 torchflower_crop; age), out (getMaxAge, largest value of the age property, outline width and height in pixels, has its own
*> randomTick (1/0), pick-block item 1 wheat_seeds, 2 carrot, 3 potato, 4 beetroot_seeds, 5 torchflower_seeds, isMaxAge, isRandomlyTicking): the class table of 3.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-BLOCK             BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-MAX               BINARY-LONG.
    05 L-PROP-MAX          BINARY-LONG.
    05 L-WIDTH             BINARY-LONG.
    05 L-HEIGHT            BINARY-LONG.
    05 L-OWN               BINARY-LONG.
    05 L-ITEM              BINARY-LONG.
    05 L-IS-MAX            BINARY-LONG.
    05 L-TICKING           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-BLOCK TO L-ITEM
     MOVE 16 TO L-WIDTH
     MOVE 0 TO L-OWN
     EVALUATE L-BLOCK
         WHEN 1
             MOVE 7 TO L-MAX L-PROP-MAX
             COMPUTE L-HEIGHT = 2 + 2 * L-AGE
         WHEN 2 WHEN 3
             MOVE 7 TO L-MAX L-PROP-MAX
             COMPUTE L-HEIGHT = 2 + L-AGE
         WHEN 4
             MOVE 3 TO L-MAX L-PROP-MAX
             MOVE 1 TO L-OWN
             COMPUTE L-HEIGHT = 2 + 2 * L-AGE
         WHEN OTHER
             MOVE 2 TO L-MAX
             MOVE 1 TO L-PROP-MAX L-OWN
             MOVE 6 TO L-WIDTH
             COMPUTE L-HEIGHT = 6 + 4 * L-AGE
     END-EVALUATE
     MOVE 0 TO L-IS-MAX L-TICKING
     IF L-AGE >= L-MAX
         MOVE 1 TO L-IS-MAX
     ELSE
         MOVE 1 TO L-TICKING
     END-IF
     GOBACK.
 END PROGRAM GB2-CROP-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-CROP-TICK.
*> USING in (block as in GB2-CROP-CLASS, the nextInt(3) draw of beetroots and the torchflower crop (ignored for the others), raw brightness, age, speed in hundredths, the growth draw), out (draws
*> made, bound of the growth draw (0 when none is made), grows (1/0), new age, becomes the torchflower (1/0)): the random tick of 3.2 to 3.4: beetroots and the torchflower crop draw nextInt(3)
*> first and stop on 0; then light 9 and age below getMaxAge, and the draw nextInt(int(25 / speed) + 1) of 0 grows; the torchflower crop at age 1 becomes the flower (state for age 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CI.
    05 WS-CI-BLOCK         BINARY-LONG.
    05 WS-CI-AGE           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 WS-CO.
    05 WS-CO-MAX           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 01 WS-GATED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-BLOCK             BINARY-LONG.
    05 L-GATE              BINARY-LONG.
    05 L-LIGHT             BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 L-SPEED             BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 01 L-OUT.
    05 L-DRAWS             BINARY-LONG.
    05 L-BOUND             BINARY-LONG.
    05 L-GROWS             BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-FLOWER            BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-BLOCK TO WS-CI-BLOCK
     MOVE L-AGE TO WS-CI-AGE
     CALL "GB2-CROP-CLASS" USING WS-CI WS-CO
     MOVE 0 TO L-DRAWS L-BOUND L-GROWS L-FLOWER WS-GATED
     MOVE L-AGE TO L-NEW
     IF L-BLOCK > 3
         MOVE 1 TO L-DRAWS WS-GATED
         IF L-GATE = 0
             MOVE 2 TO WS-GATED
         END-IF
     END-IF
     IF WS-GATED < 2 AND L-LIGHT >= 9 AND L-AGE < WS-CO-MAX
         ADD 1 TO L-DRAWS
         COMPUTE L-BOUND = 2500 / L-SPEED + 1
         IF L-DRAW = 0
             MOVE 1 TO L-GROWS
             COMPUTE L-NEW = L-AGE + 1
         END-IF
     END-IF
     IF L-BLOCK = 5 AND L-NEW = 2
         MOVE 1 TO L-FLOWER
     END-IF
     GOBACK.
 END PROGRAM GB2-CROP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-CROP-BONE.
*> USING in (block as in GB2-CROP-CLASS, age, the nextInt(4) draw), out (valid (1/0), success (always 1), new age, draws made, becomes the torchflower): bone meal (3.2 to 3.4, 13): below the
*> maximum, age + U(2, 5) (nextInt(4) + 2) capped; beetroots add U(2, 5) / 3; the torchflower crop is always valid and adds 1 without a draw (max 2, age 1 becomes the flower).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CI.
    05 WS-CI-BLOCK         BINARY-LONG.
    05 WS-CI-AGE           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 WS-CO.
    05 WS-CO-MAX           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 01 WS-INC                 BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-BLOCK             BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-VALID             BINARY-LONG.
    05 L-SUCCESS           BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-DRAWS             BINARY-LONG.
    05 L-FLOWER            BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-BLOCK TO WS-CI-BLOCK
     MOVE L-AGE TO WS-CI-AGE
     CALL "GB2-CROP-CLASS" USING WS-CI WS-CO
     MOVE 0 TO L-VALID L-DRAWS L-FLOWER
     MOVE 1 TO L-SUCCESS
     MOVE L-AGE TO L-NEW
     IF L-AGE < WS-CO-MAX OR L-BLOCK = 5
         MOVE 1 TO L-VALID
         MOVE 1 TO L-DRAWS
         COMPUTE WS-INC = L-DRAW + 2
         IF L-BLOCK = 4
             COMPUTE WS-INC = WS-INC / 3
         END-IF
         IF L-BLOCK = 5
             MOVE 1 TO WS-INC
             MOVE 0 TO L-DRAWS
         END-IF
         COMPUTE WS-SUM = L-AGE + WS-INC
         COMPUTE L-NEW = FUNCTION MIN(WS-CO-MAX, WS-SUM)
     END-IF
     IF L-BLOCK = 5 AND L-NEW = 2
         MOVE 1 TO L-FLOWER
     END-IF
     GOBACK.
 END PROGRAM GB2-CROP-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-RAVAGER.
*> USING in (server level, the entity is a Ravager, mob_griefing), out (the block is destroyed with drops (1/0)): entityInside of a crop or the pitcher crop (3.2, 4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-SERVER            BINARY-LONG.
    05 L-RAVAGER           BINARY-LONG.
    05 L-GRIEF             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-DESTROY           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-DESTROY
     IF L-SERVER = 1 AND L-RAVAGER = 1 AND L-GRIEF = 1
         MOVE 1 TO L-DESTROY
     END-IF
     GOBACK.
 END PROGRAM GB2-RAVAGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PITCHER-STATE.
*> USING in (age 0 to 4, half 0 upper 1 lower), out (isDouble, randomly ticking, outline width, y0, y1 in pixels, collision width (0 empty), y0, y1): the shapes and predicates of 4.2 and 4.3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-HALF              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-DOUBLE            BINARY-LONG.
    05 L-TICKING           BINARY-LONG.
    05 L-WIDTH             BINARY-LONG.
    05 L-Y0                BINARY-LONG.
    05 L-Y1                BINARY-LONG.
    05 L-CWIDTH            BINARY-LONG.
    05 L-CY0               BINARY-LONG.
    05 L-CY1               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-DOUBLE L-TICKING L-CWIDTH L-CY0 L-CY1
     IF L-AGE >= 3
         MOVE 1 TO L-DOUBLE
     END-IF
     IF L-HALF = 1 AND L-AGE < 4
         MOVE 1 TO L-TICKING
     END-IF
     EVALUATE L-AGE
         WHEN 0
             MOVE 0 TO WS-T
         WHEN 1
             MOVE 9 TO WS-T
         WHEN 2
             MOVE 11 TO WS-T
         WHEN 3
             MOVE 22 TO WS-T
         WHEN OTHER
             MOVE 26 TO WS-T
     END-EVALUATE
     MOVE 10 TO L-WIDTH
     COMPUTE WS-H = 6 + WS-T
     IF L-AGE = 0
         MOVE 6 TO L-WIDTH
         COMPUTE WS-H = 4 + WS-T
     END-IF
     IF L-HALF = 1
         MOVE -1 TO L-Y0
         COMPUTE L-Y1 = FUNCTION MIN(16, WS-H - 1)
         MOVE -1 TO L-CY0
         MOVE 5 TO L-CY1
         MOVE 10 TO L-CWIDTH
         IF L-AGE = 0
             MOVE 3 TO L-CY1
             MOVE 6 TO L-CWIDTH
         END-IF
     ELSE
         MOVE 0 TO L-Y0
         COMPUTE L-Y1 = FUNCTION MAX(WS-H - 17, 0)
     END-IF
     GOBACK.
 END PROGRAM GB2-PITCHER-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PITCHER-SURVIVE.
*> USING in (half 0 upper 1 lower, raw brightness, the block below is in supports_crops, the block below is a lower half of this block), out (canSurvive 1/0, mayPlaceOn 1/0, canBeReplaced 0): 4.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-HALF              BINARY-LONG.
    05 L-LIGHT             BINARY-LONG.
    05 L-SUPPORT           BINARY-LONG.
    05 L-LOWER-BELOW       BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 01 L-OUT.
    05 L-SURVIVES          BINARY-LONG.
    05 L-MAY-PLACE         BINARY-LONG.
    05 L-REPLACED          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-SURVIVES L-REPLACED
     MOVE L-SUPPORT TO L-MAY-PLACE
     IF L-HALF = 0
         MOVE L-LOWER-BELOW TO L-SURVIVES
     ELSE
         IF L-LIGHT >= 8 AND L-SUPPORT = 1
             MOVE 1 TO L-SURVIVES
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-PITCHER-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PITCHER-SHAPE.
*> USING in (age, half 0 upper 1 lower, direction 0 down 1 up 2 to 5 horizontal, the neighbour is this block, the neighbour has the same half, canSurvive), out (the state becomes air 1/0): updateShape
*> of 4.1: a single block (age below 3) survives or is air; a double one is air when the partner half is missing (rule a), when a lower half cannot survive from below (rule b), else when it cannot survive.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-HALF              BINARY-LONG.
    05 L-DIR               BINARY-LONG.
    05 L-NEIGHBOUR         BINARY-LONG.
    05 L-SAME-HALF         BINARY-LONG.
    05 L-SURVIVES          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 01 L-OUT.
    05 L-AIR               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-AIR
     IF L-SURVIVES = 0
         MOVE 1 TO L-AIR
     END-IF
     IF L-AGE >= 3 AND L-DIR < 2 AND L-HALF = L-DIR AND (L-NEIGHBOUR = 0 OR L-SAME-HALF = 1)
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM GB2-PITCHER-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PITCHER-GROW.
*> USING in (age of the lower half, raw brightness, pos.above() is inside the build height, the cell above is air, the cell above is a pitcher crop, the increase), out (canGrow for the new age,
*> new age, upper half written with setBlockAndUpdate, lower half written with flags 2): canGrow and grow of 4.3 (newAge = min(age + inc, 4)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SUM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-LIGHT             BINARY-LONG.
    05 L-INSIDE            BINARY-LONG.
    05 L-AIR               BINARY-LONG.
    05 L-PITCHER           BINARY-LONG.
    05 L-INC               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 01 L-OUT.
    05 L-CAN               BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-UPPER             BINARY-LONG.
    05 L-LOWER             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-SUM = L-AGE + L-INC
     COMPUTE L-NEW = FUNCTION MIN(WS-SUM, 4)
     MOVE 0 TO L-CAN L-UPPER L-LOWER
     IF L-AGE < 4 AND L-LIGHT >= 8 AND L-INSIDE = 1
         MOVE 1 TO L-CAN
     END-IF
     IF L-NEW >= 3 AND L-AIR = 0 AND L-PITCHER = 0
         MOVE 0 TO L-CAN
     END-IF
     IF L-CAN = 1
         MOVE 1 TO L-LOWER
         IF L-NEW >= 3
             MOVE 1 TO L-UPPER
         END-IF
     ELSE
         MOVE L-AGE TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM GB2-PITCHER-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PITCHER-TICK.
*> USING in (age, half 0 upper 1 lower, speed in hundredths, the nextInt draw), out (randomly ticking, bound of the draw (0 when none), grow(1) attempted): randomTick of 4.3: no light test here.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-HALF              BINARY-LONG.
    05 L-SPEED             BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 01 L-OUT.
    05 L-TICKING           BINARY-LONG.
    05 L-BOUND             BINARY-LONG.
    05 L-GROW              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-TICKING L-BOUND L-GROW
     IF L-HALF = 1 AND L-AGE < 4
         MOVE 1 TO L-TICKING
         COMPUTE L-BOUND = 2500 / L-SPEED + 1
         IF L-DRAW = 0
             MOVE 1 TO L-GROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-PITCHER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PITCHER-BONE.
*> USING in (the clicked half 0 upper 1 lower, the block below is a lower-half pitcher crop, the lower half's age, raw brightness, pos.above() inside the build height, the cell above is air, the
*> cell above is a pitcher crop), out (a lower half was found, valid, success (always 1), new age after grow(1), the upper half written): the bone meal rules of 4.4 (the step is exactly 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GI.
    05 WS-AGE              BINARY-LONG.
    05 WS-LIGHT            BINARY-LONG.
    05 WS-INSIDE           BINARY-LONG.
    05 WS-AIR              BINARY-LONG.
    05 WS-PITCHER          BINARY-LONG.
    05 WS-INC              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 01 WS-GO.
    05 WS-CAN              BINARY-LONG.
    05 WS-NEW              BINARY-LONG.
    05 WS-UPPER            BINARY-LONG.
    05 WS-LOWER            BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 LINKAGE SECTION.
 01 L-IN.
    05 L-CLICKED           BINARY-LONG.
    05 L-BELOW-LOWER       BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 L-LIGHT             BINARY-LONG.
    05 L-INSIDE            BINARY-LONG.
    05 L-AIR               BINARY-LONG.
    05 L-PITCHER           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 9 TIMES.
 01 L-OUT.
    05 L-FOUND             BINARY-LONG.
    05 L-VALID             BINARY-LONG.
    05 L-SUCCESS           BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-UPPER             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-FOUND L-VALID L-UPPER
     MOVE 1 TO L-SUCCESS
     MOVE L-AGE TO L-NEW
     IF L-CLICKED = 1 OR L-BELOW-LOWER = 1
         MOVE 1 TO L-FOUND
     END-IF
     IF L-FOUND = 1
         MOVE L-AGE TO WS-AGE
         MOVE L-LIGHT TO WS-LIGHT
         MOVE L-INSIDE TO WS-INSIDE
         MOVE L-AIR TO WS-AIR
         MOVE L-PITCHER TO WS-PITCHER
         CALL "GB2-PITCHER-GROW" USING WS-GI WS-GO
         MOVE WS-CAN TO L-VALID
         MOVE WS-NEW TO L-NEW
         MOVE WS-UPPER TO L-UPPER
     END-IF
     GOBACK.
 END PROGRAM GB2-PITCHER-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-STEM-NAMES.
*> USING stem (1 pumpkin_stem, 2 melon_stem), fruit key, attached stem key, seed item key (each PIC X(48)), stem support tag, fruit support tag (BINARY-LONG; tag numbers of GB2-TAG): 5.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STEM                 BINARY-LONG.
 01 L-FRUIT                PIC X(48).
 01 L-ATTACHED             PIC X(48).
 01 L-SEED                 PIC X(48).
 01 L-STEM-TAG             BINARY-LONG.
 01 L-FRUIT-TAG            BINARY-LONG.
 PROCEDURE DIVISION USING L-STEM L-FRUIT L-ATTACHED L-SEED L-STEM-TAG L-FRUIT-TAG.
     IF L-STEM = 1
         MOVE "minecraft:pumpkin" TO L-FRUIT
         MOVE "minecraft:attached_pumpkin_stem" TO L-ATTACHED
         MOVE "minecraft:pumpkin_seeds" TO L-SEED
         MOVE 9 TO L-STEM-TAG
         MOVE 11 TO L-FRUIT-TAG
     ELSE
         MOVE "minecraft:melon" TO L-FRUIT
         MOVE "minecraft:attached_melon_stem" TO L-ATTACHED
         MOVE "minecraft:melon_seeds" TO L-SEED
         MOVE 10 TO L-STEM-TAG
         MOVE 12 TO L-FRUIT-TAG
     END-IF
     GOBACK.
 END PROGRAM GB2-STEM-NAMES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-STEM-STATE.
*> USING in (age 0 to 7, the block below is in the stem support tag), out (outline width, height in pixels, can survive (no light test), randomly ticking (always 1)): 5.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-SUPPORT           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-WIDTH             BINARY-LONG.
    05 L-HEIGHT            BINARY-LONG.
    05 L-SURVIVES          BINARY-LONG.
    05 L-TICKING           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 2 TO L-WIDTH
     COMPUTE L-HEIGHT = 2 + 2 * L-AGE
     MOVE L-SUPPORT TO L-SURVIVES
     MOVE 1 TO L-TICKING
     GOBACK.
 END PROGRAM GB2-STEM-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-STEM-TICK.
*> USING in (raw brightness, age, speed in hundredths, the growth draw nextInt(int(25 / speed) + 1), the direction draw nextInt(4), the target cell is air, the soil below the target is in the fruit
*> support tag, the fruit block and the attached stem block exist), out (action 0 nothing, 1 age + 1 written, 2 fruit and attached stem written; bound of the growth draw (0 when none), new age, direction
*> code 2 north 5 east 3 south 4 west (0 when none drawn), draws made): the random tick of 5.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-LIGHT             BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 L-SPEED             BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 L-DIR-DRAW          BINARY-LONG.
    05 L-AIR               BINARY-LONG.
    05 L-SOIL              BINARY-LONG.
    05 L-REGISTERED        BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 8 TIMES.
 01 L-OUT.
    05 L-ACTION            BINARY-LONG.
    05 L-BOUND             BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-DIR               BINARY-LONG.
    05 L-DRAWS             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-ACTION L-BOUND L-DIR L-DRAWS
     MOVE L-AGE TO L-NEW
     IF L-LIGHT >= 9
         MOVE 1 TO L-DRAWS
         COMPUTE L-BOUND = 2500 / L-SPEED + 1
         IF L-DRAW = 0
             IF L-AGE < 7
                 MOVE 1 TO L-ACTION
                 COMPUTE L-NEW = L-AGE + 1
             ELSE
                 MOVE 2 TO L-DRAWS
                 EVALUATE L-DIR-DRAW
                     WHEN 0
                         MOVE 2 TO L-DIR
                     WHEN 1
                         MOVE 5 TO L-DIR
                     WHEN 2
                         MOVE 3 TO L-DIR
                     WHEN OTHER
                         MOVE 4 TO L-DIR
                 END-EVALUATE
                 IF L-AIR = 1 AND L-SOIL = 1 AND L-REGISTERED = 1
                     MOVE 2 TO L-ACTION
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-STEM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-STEM-BONE.
*> USING in (age, the draw nextInt(4) of U(2, 5)), out (valid (age not 7), success (always 1), new age min(7, age + draw + 2), an immediate random tick of the new state follows (new age 7), draws): 5 and 13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SUM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-VALID             BINARY-LONG.
    05 L-SUCCESS           BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-TICK              BINARY-LONG.
    05 L-DRAWS             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-VALID L-TICK L-DRAWS
     MOVE 1 TO L-SUCCESS
     MOVE L-AGE TO L-NEW
     IF L-AGE NOT = 7
         MOVE 1 TO L-VALID L-DRAWS
         COMPUTE WS-SUM = L-AGE + L-DRAW + 2
         COMPUTE L-NEW = FUNCTION MIN(7, WS-SUM)
         IF L-NEW = 7
             MOVE 1 TO L-TICK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-STEM-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-ATTACHED.
*> USING in (direction code of the changed neighbour 2 north 3 south 4 west 5 east (0 down, 1 up), facing code, the neighbour is the fruit block, the stem block exists, the block below is in the
*> support tag), out (becomes the stem at age 7 (1/0), age of that stem, survives (the VegetationBlock rule), no random ticks 1): updateShape and survival of attached stems (5.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-DIR               BINARY-LONG.
    05 L-FACING            BINARY-LONG.
    05 L-FRUIT             BINARY-LONG.
    05 L-STEM              BINARY-LONG.
    05 L-SUPPORT           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 01 L-OUT.
    05 L-REVERT            BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 L-SURVIVES          BINARY-LONG.
    05 L-NO-TICKS          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-REVERT L-AGE
     MOVE L-SUPPORT TO L-SURVIVES
     MOVE 1 TO L-NO-TICKS
     IF L-FRUIT = 0 AND L-DIR = L-FACING AND L-STEM = 1
         MOVE 1 TO L-REVERT
         MOVE 7 TO L-AGE
     END-IF
     GOBACK.
 END PROGRAM GB2-ATTACHED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-STEM-SEEDS.
*> USING in (attached stem 1/0, age 0 to 7), out (trials n, probability of each trial in millionths): the shipped seed counts of 5.3 (data): a stem (age + 1) / 15, an attached stem 0.53333336.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-ATTACHED          BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-N                 BINARY-LONG.
    05 L-P                 BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 3 TO L-N
     COMPUTE L-P ROUNDED = (L-AGE + 1) * 1000000 / 15
     IF L-ATTACHED = 1
         MOVE 533333 TO L-P
     END-IF
     GOBACK.
 END PROGRAM GB2-STEM-SEEDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-CARVE.
*> USING in (held stack is shears, clicked face (0 down 1 up 2 north 3 south 4 west 5 east), the player's horizontal direction opposite (same codes), r1, r2 in thousandths (the nextDouble draws, r1
*> first)), out (carves, facing of carved_pumpkin, update flags 11, durability 1, item entity offset x, y, z in thousandths from the block corner, delta x, y, z in millionths): PumpkinBlock.useItemOn (5.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP-X              BINARY-LONG.
 01 WS-STEP-Z              BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-SHEARS            BINARY-LONG.
    05 L-FACE              BINARY-LONG.
    05 L-OPPOSITE          BINARY-LONG.
    05 L-R1                BINARY-LONG.
    05 L-R2                BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 01 L-OUT.
    05 L-CARVES            BINARY-LONG.
    05 L-FACING            BINARY-LONG.
    05 L-FLAGS             BINARY-LONG.
    05 L-DURABILITY        BINARY-LONG.
    05 L-X                 BINARY-LONG.
    05 L-Y                 BINARY-LONG.
    05 L-Z                 BINARY-LONG.
    05 L-DX                BINARY-LONG.
    05 L-DY                BINARY-LONG.
    05 L-DZ                BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-CARVES L-FACING L-FLAGS L-DURABILITY L-X L-Y L-Z L-DX L-DY L-DZ
     IF L-SHEARS = 1
         MOVE 1 TO L-CARVES
         MOVE 11 TO L-FLAGS
         MOVE 1 TO L-DURABILITY
         MOVE L-FACE TO L-FACING
         IF L-FACE < 2
             MOVE L-OPPOSITE TO L-FACING
         END-IF
         MOVE 0 TO WS-STEP-X WS-STEP-Z
         EVALUATE L-FACING
             WHEN 2
                 MOVE -1 TO WS-STEP-Z
             WHEN 3
                 MOVE 1 TO WS-STEP-Z
             WHEN 4
                 MOVE -1 TO WS-STEP-X
             WHEN 5
                 MOVE 1 TO WS-STEP-X
         END-EVALUATE
         COMPUTE L-X = 500 + 650 * WS-STEP-X
         MOVE 100 TO L-Y
         COMPUTE L-Z = 500 + 650 * WS-STEP-Z
         COMPUTE L-DX = 50000 * WS-STEP-X + 20 * L-R1
         MOVE 50000 TO L-DY
         COMPUTE L-DZ = 50000 * WS-STEP-Z + 20 * L-R2
     END-IF
     GOBACK.
 END PROGRAM GB2-CARVE.
