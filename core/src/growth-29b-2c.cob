*> Dirt path, mud, rooted dirt, the propagule, azalea and saplings, the can-survive table and the bone meal table (docs/protocol/29b part 2 sections 10 to 13) as programs of plain numbers (GB2- prefix, same
*> conventions as growth-29b-2.cob: USING in out with sixteen BINARY-LONG each, draws as inputs, float draws in millionths). Not wired into the play path.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-SOIL-SHAPE.
*> USING in (block 1 farmland, 2 dirt_path, 3 mud), out (collision height in pixels, shape used for light occlusion, pathfindable, random ticks, shade brightness in thousandths (0 when not stated)): 9, 10.1, 10.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-BLOCK             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 01 L-OUT.
    05 L-HEIGHT            BINARY-LONG.
    05 L-OCCLUSION         BINARY-LONG.
    05 L-PATH              BINARY-LONG.
    05 L-TICKS             BINARY-LONG.
    05 L-SHADE             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 15 TO L-HEIGHT
     MOVE 1 TO L-OCCLUSION
     MOVE 0 TO L-PATH L-TICKS L-SHADE
     EVALUATE L-BLOCK
         WHEN 1
             MOVE 1 TO L-TICKS
         WHEN 3
             MOVE 14 TO L-HEIGHT
             MOVE 0 TO L-OCCLUSION
             MOVE 200 TO L-SHADE
     END-EVALUATE
     GOBACK.
 END PROGRAM GB2-SOIL-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PATH.
*> USING in (the block above is solid, it is a fence gate, the update direction is UP), out (can survive, a scheduled tick after 1 game tick, the tick converts to dirt (always), the placement state is dirt):
*> PathBlock (10.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-SOLID             BINARY-LONG.
    05 L-GATE              BINARY-LONG.
    05 L-UP                BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 L-OUT.
    05 L-SURVIVES          BINARY-LONG.
    05 L-SCHEDULE          BINARY-LONG.
    05 L-TURNS             BINARY-LONG.
    05 L-DIRT              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-SURVIVES L-SCHEDULE L-DIRT
     MOVE 1 TO L-TURNS
     IF L-SOLID = 0 OR L-GATE = 1
         MOVE 1 TO L-SURVIVES
     ELSE
         MOVE 1 TO L-DIRT
         IF L-UP = 1
             MOVE 1 TO L-SCHEDULE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-ROOTED.
*> USING in (the block below is air, pos.below() is inside the build height), out (valid, success (always 1), update flags of the hanging_roots write (0 when none), particle offset in y): RootedDirtBlock (10.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AIR               BINARY-LONG.
    05 L-INSIDE            BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-VALID             BINARY-LONG.
    05 L-SUCCESS           BINARY-LONG.
    05 L-FLAGS             BINARY-LONG.
    05 L-PARTICLE          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-VALID L-FLAGS
     MOVE 1 TO L-SUCCESS
     MOVE -1 TO L-PARTICLE
     IF L-AIR = 1 AND L-INSIDE = 1
         MOVE 1 TO L-VALID
         MOVE 3 TO L-FLAGS
     END-IF
     GOBACK.
 END PROGRAM GB2-ROOTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PROP-SHAPE.
*> USING in (age 0 to 4, hanging), out (minimum y, width, top y of column(2, SHAPE_MIN_Y[i], 16): i is the age when hanging, 4 when standing; SHAPE_MIN_Y = 13, 10, 7, 3, 0): 11.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-HANGING           BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 L-OUT.
    05 L-MIN-Y             BINARY-LONG.
    05 L-WIDTH             BINARY-LONG.
    05 L-TOP               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 2 TO L-WIDTH
     MOVE 16 TO L-TOP
     MOVE 0 TO L-MIN-Y
     IF L-HANGING = 1
         EVALUATE L-AGE
             WHEN 0
                 MOVE 13 TO L-MIN-Y
             WHEN 1
                 MOVE 10 TO L-MIN-Y
             WHEN 2
                 MOVE 7 TO L-MIN-Y
             WHEN 3
                 MOVE 3 TO L-MIN-Y
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM GB2-PROP-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PROP-SURVIVE.
*> USING in (hanging, the block below is in supports_mangrove_propagule, the block above is in supports_hanging_mangrove_propagule, waterlogged, the update direction is UP, the fluid at the clicked position is
*> water), out (can survive, the state becomes air, a water tick is scheduled, placement waterlogged, placement age, placement hanging): 11.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-HANGING           BINARY-LONG.
    05 L-BELOW             BINARY-LONG.
    05 L-ABOVE             BINARY-LONG.
    05 L-WATERLOGGED       BINARY-LONG.
    05 L-UP                BINARY-LONG.
    05 L-PLACE-WATER       BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 01 L-OUT.
    05 L-SURVIVES          BINARY-LONG.
    05 L-AIR               BINARY-LONG.
    05 L-SCHEDULE          BINARY-LONG.
    05 L-PLACE-WL          BINARY-LONG.
    05 L-PLACE-AGE         BINARY-LONG.
    05 L-PLACE-HANGING     BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-BELOW TO L-SURVIVES
     IF L-HANGING = 1
         MOVE L-ABOVE TO L-SURVIVES
     END-IF
     MOVE 0 TO L-AIR L-PLACE-HANGING
     IF L-UP = 1 AND L-SURVIVES = 0
         MOVE 1 TO L-AIR
     END-IF
     MOVE L-WATERLOGGED TO L-SCHEDULE
     MOVE L-PLACE-WATER TO L-PLACE-WL
     MOVE 4 TO L-PLACE-AGE
     GOBACK.
 END PROGRAM GB2-PROP-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PROP-TICK.
*> USING in (age, hanging, the nextInt(7) draw, the level random float in millionths), out (random tick: 0 nothing, 1 advanceTree, 2 age + 1; the age after it; bone meal valid; success; effect 1 age + 1,
*> 2 advanceTree; the age after the effect): 11.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 L-HANGING           BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 L-FLOAT             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 01 L-OUT.
    05 L-TICK              BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-VALID             BINARY-LONG.
    05 L-SUCCESS           BINARY-LONG.
    05 L-EFFECT            BINARY-LONG.
    05 L-BONE-NEW          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-TICK L-SUCCESS
     MOVE L-AGE TO L-NEW L-BONE-NEW
     MOVE 1 TO L-VALID
     MOVE 2 TO L-EFFECT
     IF L-HANGING = 1
         IF L-AGE NOT = 4
             MOVE 2 TO L-TICK
             COMPUTE L-NEW = L-AGE + 1
             MOVE 1 TO L-SUCCESS L-EFFECT
             COMPUTE L-BONE-NEW = L-AGE + 1
         ELSE
             MOVE 0 TO L-VALID
         END-IF
     ELSE
         IF L-DRAW = 0
             MOVE 1 TO L-TICK
         END-IF
         IF L-FLOAT < 450000
             MOVE 1 TO L-SUCCESS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB2-PROP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-PROP-NEW.
*> USING in (age, 0 by default), out (age, hanging, stage, waterlogged): createNewHangingPropagule (11.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-AGE               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 15 TIMES.
 01 L-OUT.
    05 L-NEW-AGE           BINARY-LONG.
    05 L-HANGING           BINARY-LONG.
    05 L-STAGE             BINARY-LONG.
    05 L-WATERLOGGED       BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-AGE TO L-NEW-AGE
     MOVE 1 TO L-HANGING
     MOVE 0 TO L-STAGE L-WATERLOGGED
     GOBACK.
 END PROGRAM GB2-PROP-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-AZALEA.
*> USING in (server level, the minimum height of azalea_tree, pos.above(minH + 2) is inside the build height, the fluid at pos.above() is empty, the level random float in millionths, the block below is in
*> supports_azalea), out (bone meal valid, success, the tree is grown (valid and successful: growTree with the azalea grower), can survive, the height above that must be inside the build height): 11.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-SERVER            BINARY-LONG.
    05 L-MIN-H             BINARY-LONG.
    05 L-INSIDE            BINARY-LONG.
    05 L-EMPTY             BINARY-LONG.
    05 L-FLOAT             BINARY-LONG.
    05 L-BELOW             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 01 L-OUT.
    05 L-VALID             BINARY-LONG.
    05 L-SUCCESS           BINARY-LONG.
    05 L-GROWN             BINARY-LONG.
    05 L-SURVIVES          BINARY-LONG.
    05 L-REACH             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-VALID L-SUCCESS L-GROWN
     MOVE L-BELOW TO L-SURVIVES
     COMPUTE L-REACH = L-MIN-H + 2
     IF L-SERVER = 1 AND L-INSIDE = 1 AND L-EMPTY = 1
         MOVE 1 TO L-VALID
     END-IF
     IF L-FLOAT < 450000
         MOVE 1 TO L-SUCCESS
     END-IF
     IF L-VALID = 1 AND L-SUCCESS = 1
         MOVE 1 TO L-GROWN
     END-IF
     GOBACK.
 END PROGRAM GB2-AZALEA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-SAPLING-KIND.
*> USING block key (PIC X(48)), out (grower of part 1 (1 oak, 2 spruce, 3 mangrove, 4 azalea, 5 birch, 6 jungle, 7 acacia, 8 cherry, 9 dark oak, 10 pale oak, 11 poplar; 0 for none), class 1 SaplingBlock,
*> 2 MangrovePropaguleBlock, 3 AzaleaBlock (0 for none), map colour METAL (poplar), offset type XZ (propagule)): the registrations of 11.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-OUT.
    05 L-GROWER            BINARY-LONG.
    05 L-CLASS             BINARY-LONG.
    05 L-METAL             BINARY-LONG.
    05 L-OFFSET            BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-KEY L-OUT.
     MOVE 0 TO L-GROWER L-CLASS L-METAL L-OFFSET
     EVALUATE L-KEY
         WHEN "minecraft:oak_sapling"
             MOVE 1 TO L-GROWER L-CLASS
         WHEN "minecraft:spruce_sapling"
             MOVE 2 TO L-GROWER
             MOVE 1 TO L-CLASS
         WHEN "minecraft:birch_sapling"
             MOVE 5 TO L-GROWER
             MOVE 1 TO L-CLASS
         WHEN "minecraft:jungle_sapling"
             MOVE 6 TO L-GROWER
             MOVE 1 TO L-CLASS
         WHEN "minecraft:acacia_sapling"
             MOVE 7 TO L-GROWER
             MOVE 1 TO L-CLASS
         WHEN "minecraft:cherry_sapling"
             MOVE 8 TO L-GROWER
             MOVE 1 TO L-CLASS
         WHEN "minecraft:dark_oak_sapling"
             MOVE 9 TO L-GROWER
             MOVE 1 TO L-CLASS
         WHEN "minecraft:pale_oak_sapling"
             MOVE 10 TO L-GROWER
             MOVE 1 TO L-CLASS
         WHEN "minecraft:poplar_sapling"
             MOVE 11 TO L-GROWER
             MOVE 1 TO L-CLASS L-METAL
         WHEN "minecraft:mangrove_propagule"
             MOVE 3 TO L-GROWER
             MOVE 2 TO L-CLASS
             MOVE 1 TO L-OFFSET
         WHEN "minecraft:azalea" WHEN "minecraft:flowering_azalea"
             MOVE 4 TO L-GROWER
             MOVE 3 TO L-CLASS
     END-EVALUATE
     GOBACK.
 END PROGRAM GB2-SAPLING-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-SURVIVE.
*> USING in (kind 1 crop, 2 pitcher lower, 3 pitcher upper, 4 stem or attached stem, 5 nether wart, 6 cocoa, 7 sweet berry bush, 8 sapling, 9 propagule standing, 10 propagule hanging, 11 azalea, 12 farmland,
*> 13 dirt path, 14 mud or rooted dirt; raw brightness; the tag condition of the row (below in the support tag, at the facing, above in the tag, the pitcher's lower half below, above in maintains_farmland or a fence
*> gate); the block above is solid), out (can survive, a VegetationBlock update turns it to air): the table of 12.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-KIND              BINARY-LONG.
    05 L-LIGHT             BINARY-LONG.
    05 L-TAG               BINARY-LONG.
    05 L-SOLID             BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 01 L-OUT.
    05 L-SURVIVES          BINARY-LONG.
    05 L-AIR               BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-TAG TO L-SURVIVES
     MOVE 0 TO L-AIR
     EVALUATE L-KIND
         WHEN 1 WHEN 2
             IF L-LIGHT < 8
                 MOVE 0 TO L-SURVIVES
             END-IF
         WHEN 12 WHEN 13
             IF L-SOLID = 0
                 MOVE 1 TO L-SURVIVES
             END-IF
         WHEN 14
             MOVE 1 TO L-SURVIVES
     END-EVALUATE
     IF L-SURVIVES = 0 AND L-KIND < 12
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM GB2-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB2-BONEMEAL.
*> USING in (kind 1 wheat, carrots, potatoes, 2 beetroots, 3 torchflower crop, 4 pitcher crop, 5 stems, 6 not a target (attached stems, nether wart, farmland, path, mud, pumpkin, melon), 7 cocoa, 8 sweet berry
*> bush, 9 rooted dirt, 10 sapling, 11 mangrove propagule, 12 azalea; age; the nextInt(4) draw; the block's own validity condition (canGrow of the pitcher, air below and room for rooted dirt, the sapling or azalea
*> tests of 7.1 and 11.2, the propagule's validity); the level random float in millionths; the propagule's success flag), out (valid, success mode 0 none 1 always 2 P(0.45) 3 as 11.1, success, age after, random
*> source 0 none 1 level random 2 the passed random, a random tick of the new state follows): the table of 13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CI.
    05 WS-CI-BLOCK         BINARY-LONG.
    05 WS-CI-AGE           BINARY-LONG.
    05 WS-CI-DRAW          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 13 TIMES.
 01 WS-SI.
    05 WS-SI-AGE           BINARY-LONG.
    05 WS-SI-DRAW          BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 14 TIMES.
 01 WS-CO.
    05 WS-CO-VALID         BINARY-LONG.
    05 WS-CO-SUCCESS       BINARY-LONG.
    05 WS-CO-NEW           BINARY-LONG.
    05 WS-CO-DRAWS         BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 12 TIMES.
 LINKAGE SECTION.
 01 L-IN.
    05 L-KIND              BINARY-LONG.
    05 L-AGE               BINARY-LONG.
    05 L-DRAW              BINARY-LONG.
    05 L-COND              BINARY-LONG.
    05 L-FLOAT             BINARY-LONG.
    05 L-FLAG              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 01 L-OUT.
    05 L-VALID             BINARY-LONG.
    05 L-MODE              BINARY-LONG.
    05 L-SUCCESS           BINARY-LONG.
    05 L-NEW               BINARY-LONG.
    05 L-SOURCE            BINARY-LONG.
    05 L-TICK              BINARY-LONG.
    05 FILLER              BINARY-LONG OCCURS 10 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-VALID L-MODE L-SUCCESS L-SOURCE L-TICK
     MOVE L-AGE TO L-NEW
     MOVE L-AGE TO WS-CI-AGE
     MOVE L-DRAW TO WS-CI-DRAW
     EVALUATE L-KIND
         WHEN 1 WHEN 2 WHEN 3
             MOVE 1 TO WS-CI-BLOCK
             IF L-KIND = 3
                 MOVE 5 TO WS-CI-BLOCK
             END-IF
             IF L-KIND = 2
                 MOVE 4 TO WS-CI-BLOCK
             END-IF
             CALL "GB2-CROP-BONE" USING WS-CI WS-CO
             MOVE WS-CO-VALID TO L-VALID
             MOVE 1 TO L-MODE
             MOVE WS-CO-NEW TO L-NEW
             IF L-KIND < 3
                 MOVE 1 TO L-SOURCE
             END-IF
         WHEN 4
             MOVE L-COND TO L-VALID
             MOVE 1 TO L-MODE
             IF L-VALID = 1
                 COMPUTE L-NEW = L-AGE + 1
             END-IF
         WHEN 5
             MOVE L-AGE TO WS-SI-AGE
             MOVE L-DRAW TO WS-SI-DRAW
             CALL "GB2-STEM-BONE" USING WS-SI WS-CO
             MOVE WS-CO-VALID TO L-VALID
             MOVE 1 TO L-MODE
             MOVE WS-CO-NEW TO L-NEW
             MOVE WS-CO-DRAWS TO L-TICK
             MOVE 2 TO L-SOURCE
         WHEN 7
             IF L-AGE < 2
                 MOVE 1 TO L-VALID
                 COMPUTE L-NEW = L-AGE + 1
             END-IF
             MOVE 1 TO L-MODE
         WHEN 8
             IF L-AGE < 3
                 MOVE 1 TO L-VALID
                 COMPUTE L-NEW = L-AGE + 1
             END-IF
             MOVE 1 TO L-MODE
         WHEN 9
             MOVE L-COND TO L-VALID
             MOVE 1 TO L-MODE
         WHEN 10 WHEN 12
             MOVE L-COND TO L-VALID
             MOVE 2 TO L-MODE
             MOVE 1 TO L-SOURCE
         WHEN 11
             MOVE L-COND TO L-VALID
             MOVE 3 TO L-MODE
             MOVE 1 TO L-SOURCE
     END-EVALUATE
     IF L-VALID = 1 AND (L-MODE = 1 OR (L-MODE = 2 AND L-FLOAT < 450000) OR (L-MODE = 3 AND L-FLAG = 1))
         MOVE 1 TO L-SUCCESS
     END-IF
     GOBACK.
 END PROGRAM GB2-BONEMEAL.
