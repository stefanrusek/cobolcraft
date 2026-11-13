*> Growing plants (docs/protocol/29b part 4) as programs of plain numbers (GC4- prefix), in the style of growth-29b-3.cob: the decisions of each section take the
*> facts the caller read from the level (flags, counts, the random draws) and return the decision. Like parts 1 and 3 they are helpers: nothing here is wired into the block-update
*> hooks. Direction numbers are the order of Direction.values() (1 down, 2 up, 3 north, 4 south, 5 west, 6 east).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PART.
*> USING block key (PIC X(48)), section x 10 (BINARY-LONG out): the class table of 1.2 (3.3 is 33, 5.1 is 51, 10.1 is 101); 0 for other blocks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-SECTION              BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-SECTION.
     MOVE 0 TO L-SECTION
     EVALUATE TRUE
         WHEN L-KEY = "minecraft:kelp" OR L-KEY = "minecraft:kelp_plant"
             MOVE 33 TO L-SECTION
         WHEN L-KEY = "minecraft:weeping_vines" OR L-KEY = "minecraft:weeping_vines_plant" OR L-KEY = "minecraft:twisting_vines" OR L-KEY = "minecraft:twisting_vines_plant"
             MOVE 34 TO L-SECTION
         WHEN L-KEY = "minecraft:cave_vines" OR L-KEY = "minecraft:cave_vines_plant"
             MOVE 35 TO L-SECTION
         WHEN L-KEY = "minecraft:sugar_cane"
             MOVE 40 TO L-SECTION
         WHEN L-KEY = "minecraft:cactus"
             MOVE 51 TO L-SECTION
         WHEN L-KEY = "minecraft:cactus_flower"
             MOVE 52 TO L-SECTION
         WHEN L-KEY = "minecraft:bamboo" OR L-KEY = "minecraft:bamboo_sapling"
             MOVE 60 TO L-SECTION
         WHEN L-KEY = "minecraft:vine"
             MOVE 70 TO L-SECTION
         WHEN L-KEY = "minecraft:chorus_plant"
             MOVE 81 TO L-SECTION
         WHEN L-KEY = "minecraft:chorus_flower"
             MOVE 82 TO L-SECTION
         WHEN L-KEY = "minecraft:seagrass"
             MOVE 92 TO L-SECTION
         WHEN L-KEY = "minecraft:tall_seagrass"
             MOVE 93 TO L-SECTION
         WHEN L-KEY = "minecraft:short_grass" OR L-KEY = "minecraft:fern"
             MOVE 95 TO L-SECTION
         WHEN L-KEY = "minecraft:tall_grass" OR L-KEY = "minecraft:large_fern" OR L-KEY = "minecraft:pitcher_plant"
             MOVE 91 TO L-SECTION
         WHEN L-KEY = "minecraft:sunflower" OR L-KEY = "minecraft:lilac" OR L-KEY = "minecraft:rose_bush" OR L-KEY = "minecraft:peony"
             MOVE 96 TO L-SECTION
         WHEN L-KEY = "minecraft:dandelion" OR L-KEY = "minecraft:golden_dandelion" OR L-KEY = "minecraft:torchflower" OR L-KEY = "minecraft:poppy"
              OR L-KEY = "minecraft:blue_orchid" OR L-KEY = "minecraft:allium" OR L-KEY = "minecraft:azure_bluet" OR L-KEY = "minecraft:red_tulip"
              OR L-KEY = "minecraft:orange_tulip" OR L-KEY = "minecraft:white_tulip" OR L-KEY = "minecraft:pink_tulip" OR L-KEY = "minecraft:oxeye_daisy"
              OR L-KEY = "minecraft:cornflower" OR L-KEY = "minecraft:lily_of_the_valley"
             MOVE 101 TO L-SECTION
         WHEN L-KEY = "minecraft:wither_rose"
             MOVE 102 TO L-SECTION
         WHEN L-KEY = "minecraft:open_eyeblossom" OR L-KEY = "minecraft:closed_eyeblossom"
             MOVE 103 TO L-SECTION
         WHEN L-KEY = "minecraft:pink_petals" OR L-KEY = "minecraft:wildflowers"
             MOVE 104 TO L-SECTION
         WHEN L-KEY = "minecraft:bush" OR L-KEY = "minecraft:red_shrub"
             MOVE 105 TO L-SECTION
         WHEN L-KEY = "minecraft:dead_bush" OR L-KEY = "minecraft:short_dry_grass" OR L-KEY = "minecraft:tall_dry_grass"
             MOVE 106 TO L-SECTION
         WHEN L-KEY = "minecraft:firefly_bush"
             MOVE 107 TO L-SECTION
         WHEN L-KEY = "minecraft:sea_pickle"
             MOVE 111 TO L-SECTION
         WHEN L-KEY = "minecraft:lily_pad"
             MOVE 112 TO L-SECTION
         WHEN L-KEY = "minecraft:big_dripleaf"
             MOVE 121 TO L-SECTION
         WHEN L-KEY = "minecraft:big_dripleaf_stem"
             MOVE 122 TO L-SECTION
         WHEN L-KEY = "minecraft:small_dripleaf"
             MOVE 124 TO L-SECTION
         WHEN L-KEY = "minecraft:hanging_roots"
             MOVE 131 TO L-SECTION
         WHEN L-KEY = "minecraft:spore_blossom"
             MOVE 132 TO L-SECTION
         WHEN L-KEY = "minecraft:pale_hanging_moss"
             MOVE 133 TO L-SECTION
         WHEN L-KEY = "minecraft:mangrove_roots" OR L-KEY = "minecraft:muddy_mangrove_roots"
             MOVE 134 TO L-SECTION
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-PART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-RT-FLAG.
*> USING block key (PIC X(48)), random-tick flag, condition (BINARY-LONG out: 0 none, 1 stage == 0, 2 age < 5, 3 age < 25): the "RT" column of 1.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SECTION             BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-RT                   BINARY-LONG.
 01 L-CONDITION            BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-RT L-CONDITION.
     MOVE 0 TO L-RT L-CONDITION
     CALL "GC4-PART" USING L-KEY WS-SECTION
     EVALUATE TRUE
         WHEN L-KEY = "minecraft:kelp" OR L-KEY = "minecraft:weeping_vines" OR L-KEY = "minecraft:twisting_vines" OR L-KEY = "minecraft:cave_vines"
             MOVE 1 TO L-RT
             MOVE 3 TO L-CONDITION
         WHEN L-KEY = "minecraft:bamboo"
             MOVE 1 TO L-RT
             MOVE 1 TO L-CONDITION
         WHEN L-KEY = "minecraft:chorus_flower"
             MOVE 1 TO L-RT
             MOVE 2 TO L-CONDITION
         WHEN WS-SECTION = 40 OR WS-SECTION = 51 OR WS-SECTION = 70 OR WS-SECTION = 103 OR L-KEY = "minecraft:bamboo_sapling"
             MOVE 1 TO L-RT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-RT-FLAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-IN-TAG.
*> USING tag (1 supports_vegetation, 2 substrate_overworld, 3 dirt, 4 sand, 5 supports_sugar_cane, 6 supports_sugar_cane_adjacently (block), 7 supports_cactus,
*> 8 support_override_cactus_flower, 9 supports_bamboo, 10 cannot_support_kelp / cannot_support_seagrass, 11 supports_chorus_plant / supports_chorus_flower,
*> 12 supports_dry_vegetation, 13 terracotta, 14 supports_wither_rose, 15 supports_lily_pad (block), 16 supports_small_dripleaf, 17 supports_big_dripleaf,
*> 18 coral_blocks, 19 pale_oak_logs, 20 fluid supports_sugar_cane_adjacently (water tag), 21 fluid supports_lily_pad), block or fluid key (PIC X(48)), member (BINARY-LONG
*> out, 1 or 0): the tag members as shipped (2.4), listed to make the examples concrete; a reimplementation takes the tags from the data pack (23).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRT                BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-SUBSTRATE           BINARY-LONG.
 01 WS-VEG                 BINARY-LONG.
 01 WS-TERRA               BINARY-LONG.
 01 WS-SMALL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-KEY L-MEMBER.
     MOVE 0 TO L-MEMBER WS-DIRT WS-SAND WS-SUBSTRATE WS-VEG WS-TERRA WS-SMALL
     IF L-KEY = "minecraft:dirt" OR L-KEY = "minecraft:coarse_dirt" OR L-KEY = "minecraft:rooted_dirt"
         MOVE 1 TO WS-DIRT
     END-IF
     IF L-KEY = "minecraft:sand" OR L-KEY = "minecraft:red_sand" OR L-KEY = "minecraft:suspicious_sand"
         MOVE 1 TO WS-SAND
     END-IF
     IF WS-DIRT = 1 OR L-KEY = "minecraft:mud" OR L-KEY = "minecraft:moss_block" OR L-KEY = "minecraft:grass_block"
         MOVE 1 TO WS-SUBSTRATE
     END-IF
     IF WS-SUBSTRATE = 1 OR L-KEY = "minecraft:farmland"
         MOVE 1 TO WS-VEG
     END-IF
     IF L-KEY = "minecraft:terracotta" OR L-KEY = "minecraft:white_terracotta" OR L-KEY = "minecraft:orange_terracotta" OR L-KEY = "minecraft:magenta_terracotta"
         OR L-KEY = "minecraft:light_blue_terracotta" OR L-KEY = "minecraft:yellow_terracotta" OR L-KEY = "minecraft:lime_terracotta" OR L-KEY = "minecraft:pink_terracotta"
         OR L-KEY = "minecraft:gray_terracotta" OR L-KEY = "minecraft:light_gray_terracotta" OR L-KEY = "minecraft:cyan_terracotta" OR L-KEY = "minecraft:purple_terracotta"
         OR L-KEY = "minecraft:blue_terracotta" OR L-KEY = "minecraft:brown_terracotta" OR L-KEY = "minecraft:green_terracotta" OR L-KEY = "minecraft:red_terracotta"
         OR L-KEY = "minecraft:black_terracotta"
         MOVE 1 TO WS-TERRA
     END-IF
     IF L-KEY = "minecraft:clay" OR L-KEY = "minecraft:moss_block"
         MOVE 1 TO WS-SMALL
     END-IF
     EVALUATE L-TAG
         WHEN 1
             MOVE WS-VEG TO L-MEMBER
         WHEN 2
             MOVE WS-SUBSTRATE TO L-MEMBER
         WHEN 3
             MOVE WS-DIRT TO L-MEMBER
         WHEN 4
             MOVE WS-SAND TO L-MEMBER
         WHEN 5
             IF WS-SUBSTRATE = 1 OR WS-SAND = 1
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 6
             IF L-KEY = "minecraft:frosted_ice"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 7
             MOVE WS-SAND TO L-MEMBER
         WHEN 8
             IF L-KEY = "minecraft:cactus" OR L-KEY = "minecraft:farmland"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 9
             IF WS-SAND = 1 OR WS-SUBSTRATE = 1 OR L-KEY = "minecraft:bamboo" OR L-KEY = "minecraft:bamboo_sapling" OR L-KEY = "minecraft:gravel"
                 OR L-KEY = "minecraft:suspicious_gravel"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 10
             IF L-KEY = "minecraft:magma_block"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 11
             IF L-KEY = "minecraft:end_stone"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 12
             IF WS-SAND = 1 OR WS-TERRA = 1 OR WS-VEG = 1
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 13
             MOVE WS-TERRA TO L-MEMBER
         WHEN 14
             IF WS-VEG = 1 OR L-KEY = "minecraft:netherrack" OR L-KEY = "minecraft:soul_sand" OR L-KEY = "minecraft:soul_soil"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 15
             IF L-KEY = "minecraft:ice" OR L-KEY = "minecraft:frosted_ice"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 16
             MOVE WS-SMALL TO L-MEMBER
         WHEN 17
             IF WS-SMALL = 1 OR L-KEY = "minecraft:dirt" OR L-KEY = "minecraft:grass_block" OR L-KEY = "minecraft:podzol" OR L-KEY = "minecraft:coarse_dirt"
                 OR L-KEY = "minecraft:mycelium" OR L-KEY = "minecraft:rooted_dirt" OR L-KEY = "minecraft:mud" OR L-KEY = "minecraft:muddy_mangrove_roots"
                 OR L-KEY = "minecraft:farmland"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 18
             IF L-KEY = "minecraft:tube_coral_block" OR L-KEY = "minecraft:brain_coral_block" OR L-KEY = "minecraft:bubble_coral_block"
                 OR L-KEY = "minecraft:fire_coral_block" OR L-KEY = "minecraft:horn_coral_block"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 19
             IF L-KEY = "minecraft:pale_oak_log" OR L-KEY = "minecraft:pale_oak_wood" OR L-KEY = "minecraft:stripped_pale_oak_log"
                 OR L-KEY = "minecraft:stripped_pale_oak_wood"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 20
             IF L-KEY = "minecraft:water" OR L-KEY = "minecraft:flowing_water"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN OTHER
             IF L-KEY = "minecraft:water"
                 MOVE 1 TO L-MEMBER
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-IN-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VEG-RULES.
*> USING mayPlaceOn of the state below (BINARY-LONG), canSurvive, shape update (1 the state unchanged, 0 air), block tick scheduled (BINARY-LONG out): VegetationBlock (2.1);
*> the ground check is the neighbour update itself, there is no scheduled tick.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BELOW                BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-UPDATE               BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BELOW L-SURVIVE L-UPDATE L-TICK.
     MOVE L-BELOW TO L-SURVIVE L-UPDATE
     MOVE 0 TO L-TICK
     GOBACK.
 END PROGRAM GC4-VEG-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VEG-FACTS.
*> USING the fluid state is empty, the path type is AIR, the state has no collision (BINARY-LONG), propagatesSkylightDown, isPathfindable (1, or -1 for the default) out (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-NOCOL                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-PATH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-AIR L-NOCOL L-SKY L-PATH.
     MOVE L-EMPTY TO L-SKY
     MOVE -1 TO L-PATH
     IF L-AIR = 1 AND L-NOCOL = 1
         MOVE 1 TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM GC4-VEG-FACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BUSH-BONE.
*> USING hasSpreadableNeighbourPos (BINARY-LONG), valid, success, type (1 GROWER), setBlockAndUpdate flags out: BushBlock bone meal (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPREAD               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SPREAD L-VALID L-SUCCESS L-TYPE L-FLAGS.
     MOVE L-SPREAD TO L-VALID
     MOVE 1 TO L-SUCCESS L-TYPE
     MOVE 3 TO L-FLAGS
     GOBACK.
 END PROGRAM GC4-BUSH-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BUSH-SHAPE.
*> USING the constructor height (0 for none), the shape is Block.column(width, 0, height) out (BINARY-LONG: width, height): BushBlock (2.2), 13 by default.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HEIGHT-ARG           BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-HEIGHT-ARG L-WIDTH L-HEIGHT.
     MOVE 16 TO L-WIDTH
     MOVE 13 TO L-HEIGHT
     IF L-HEIGHT-ARG > 0
         MOVE L-HEIGHT-ARG TO L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM GC4-BUSH-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BUSH-CLASS.
*> USING block key (PIC X(48)), the block is a BushBlock with the generic spreader bone meal (BINARY-LONG out): only bush and red_shrub (2.2); the flowers extend VegetationBlock.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-BUSH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-BUSH.
     MOVE 0 TO L-BUSH
     IF L-KEY = "minecraft:bush" OR L-KEY = "minecraft:red_shrub"
         MOVE 1 TO L-BUSH
     END-IF
     GOBACK.
 END PROGRAM GC4-BUSH-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLUID.
*> USING kind (0 empty, 1 water source, 2 flowing water, 3 lava), amount (BINARY-LONG), in fluid tag water, FluidState.is(Fluids.WATER), isSourceOfType(WATER), isFull out (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-IS                   BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-AMOUNT L-TAG L-IS L-SOURCE L-FULL.
     MOVE 0 TO L-TAG L-IS L-SOURCE L-FULL
     IF L-KIND = 1 OR L-KIND = 2
         MOVE 1 TO L-TAG
     END-IF
     IF L-KIND = 1
         MOVE 1 TO L-IS L-SOURCE
     END-IF
     IF L-AMOUNT = 8
         MOVE 1 TO L-FULL
     END-IF
     GOBACK.
 END PROGRAM GC4-FLUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-LIQCONT.
*> USING canPlaceLiquid, placeLiquid, the fluid state is the water source (BINARY-LONG out): LiquidBlockContainer of kelp, kelp plant, seagrass, tall seagrass (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-PLACE L-FLUID.
     MOVE 0 TO L-CAN L-PLACE
     MOVE 1 TO L-FLUID
     GOBACK.
 END PROGRAM GC4-LIQCONT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-WATERLOG-COPY.
*> USING the state has the property waterlogged, isWaterAt(pos) (BINARY-LONG), the new value (-1 for the state unchanged) out: copyWaterloggedFrom (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-WATER L-NEW.
     MOVE -1 TO L-NEW
     IF L-HAS = 1
         MOVE L-WATER TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM GC4-WATERLOG-COPY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-HDIR.
*> USING kind, value (BINARY-LONG), direction out: 1 Plane.HORIZONTAL[i] (north, east, south, west: i 0 to 3), 2 Plane.VERTICAL[i] (up, down), 3 Direction.getRandom
*> (nextInt(6) over down, up, north, south, west, east), 4 getClockWise(direction), 5 getCounterClockWise(direction) (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-VALUE L-DIR.
     EVALUATE L-KIND ALSO L-VALUE
         WHEN 1 ALSO 0
             MOVE 3 TO L-DIR
         WHEN 1 ALSO 1
             MOVE 6 TO L-DIR
         WHEN 1 ALSO 2
             MOVE 4 TO L-DIR
         WHEN 1 ALSO 3
             MOVE 5 TO L-DIR
         WHEN 2 ALSO 0
             MOVE 2 TO L-DIR
         WHEN 2 ALSO 1
             MOVE 1 TO L-DIR
         WHEN 3 ALSO ANY
             COMPUTE L-DIR = L-VALUE + 1
         WHEN 4 ALSO 3
             MOVE 6 TO L-DIR
         WHEN 4 ALSO 6
             MOVE 4 TO L-DIR
         WHEN 4 ALSO 4
             MOVE 5 TO L-DIR
         WHEN 4 ALSO 5
             MOVE 3 TO L-DIR
         WHEN 5 ALSO 6
             MOVE 3 TO L-DIR
         WHEN 5 ALSO 4
             MOVE 6 TO L-DIR
         WHEN 5 ALSO 5
             MOVE 4 TO L-DIR
         WHEN OTHER
             MOVE 5 TO L-DIR
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-HDIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-NEXT-INT.
*> USING a, b, the nextInt(b - a + 1) draw (BINARY-LONG), the value out: Mth.nextInt(r, a, b) is a when a >= b, else a + the draw (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-DRAW L-VALUE.
     MOVE L-A TO L-VALUE
     IF L-A < L-B
         COMPUTE L-VALUE = L-A + L-DRAW
     END-IF
     GOBACK.
 END PROGRAM GC4-NEXT-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-RAND-BETWEEN.
*> USING a, b, the nextFloat draw (FLOAT-LONG), the value x 1000000 (BINARY-LONG out): Mth.randomBetween is draw * (b - a) + a (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-DRAW L-VALUE.
     COMPUTE L-VALUE ROUNDED = (L-DRAW * (L-B - L-A) + L-A) * 1000000
     GOBACK.
 END PROGRAM GC4-RAND-BETWEEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLAG.
*> USING name (1 flags 2, 2 flags 3, 3 flags 18, 4 flags 35, 5 flags 260, 6 level event 1033, 7 event 1034, 8 event 2001), value out (2.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-VALUE.
     EVALUATE L-NAME
         WHEN 1
             MOVE 2 TO L-VALUE
         WHEN 2
             MOVE 3 TO L-VALUE
         WHEN 3
             COMPUTE L-VALUE = 2 + 16
         WHEN 4
             COMPUTE L-VALUE = 1 + 2 + 32
         WHEN 5
             COMPUTE L-VALUE = 4 + 256
         WHEN 6
             MOVE 1033 TO L-VALUE
         WHEN 7
             MOVE 1034 TO L-VALUE
         WHEN OTHER
             MOVE 2001 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-FLAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SU-TICK.
*> USING canSurvive (BINARY-LONG), a block tick scheduled, its delay out: the shape update of the blocks that are removed by a tick (14.1): delay 1 when they cannot survive.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVE              BINARY-LONG.
 01 L-SCHEDULED            BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVE L-SCHEDULED L-DELAY.
     MOVE 0 TO L-SCHEDULED L-DELAY
     IF L-SURVIVE = 0
         MOVE 1 TO L-SCHEDULED L-DELAY
     END-IF
     GOBACK.
 END PROGRAM GC4-SU-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-TICK-REMOVE.
*> USING canSurvive (BINARY-LONG), destroyBlock, with drops out: the scheduled tick of those blocks (14.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVE              BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVE L-DESTROY L-DROPS.
     MOVE 0 TO L-DESTROY L-DROPS
     IF L-SURVIVE = 0
         MOVE 1 TO L-DESTROY L-DROPS
     END-IF
     GOBACK.
 END PROGRAM GC4-TICK-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-GROW-DATA.
*> USING block (1 kelp, 2 kelp_plant, 3 weeping_vines, 4 weeping_vines_plant, 5 twisting_vines, 6 twisting_vines_plant, 7 cave_vines, 8 cave_vines_plant), growth direction (1 down,
*> 2 up), scheduleFluidTicks, head probability x 1000, blocks per bone meal (0 = the NetherVines count), canGrowInto (1 water block, 2 air, 0 body), canAttachTo (1 not magma_block,
*> 2 always), shape width, y from, y to (BINARY-LONG out): the constructor data of 3.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-PROB                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-GROW                 BINARY-LONG.
 01 L-ATTACH               BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-DIR L-FLUID L-PROB L-COUNT L-GROW L-ATTACH L-WIDTH L-Y0 L-Y1.
     MOVE 0 TO L-FLUID L-PROB L-COUNT L-GROW L-Y0
     MOVE 2 TO L-DIR L-ATTACH
     MOVE 16 TO L-WIDTH L-Y1
     EVALUATE L-BLOCK
         WHEN 1
             MOVE 1 TO L-FLUID L-COUNT L-GROW L-ATTACH
             MOVE 140 TO L-PROB
             MOVE 9 TO L-Y1
         WHEN 2
             MOVE 1 TO L-FLUID L-ATTACH
         WHEN 3
             MOVE 1 TO L-DIR
             MOVE 100 TO L-PROB
             MOVE 2 TO L-GROW
             MOVE 8 TO L-WIDTH
             MOVE 9 TO L-Y0
         WHEN 4
             MOVE 1 TO L-DIR
             MOVE 14 TO L-WIDTH
         WHEN 5
             MOVE 100 TO L-PROB
             MOVE 2 TO L-GROW
             MOVE 8 TO L-WIDTH
             MOVE 15 TO L-Y1
         WHEN 6
             MOVE 8 TO L-WIDTH
         WHEN 7
             MOVE 1 TO L-DIR L-COUNT
             MOVE 100 TO L-PROB
             MOVE 2 TO L-GROW
             MOVE 14 TO L-WIDTH
         WHEN OTHER
             MOVE 1 TO L-DIR
             MOVE 14 TO L-WIDTH
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-GROW-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-GROW-CONST.
*> USING AGE_25 maximum, default age, GROW_PER_TICK_PROBABILITY x 1000, BONEMEAL_GROW_PROBABILITY_DECREASE_RATE x 1000 (BINARY-LONG out): 3.1, 3.2 step 5 and 3.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAX                  BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 01 L-PROB                 BINARY-LONG.
 01 L-RATE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX L-DEFAULT L-PROB L-RATE.
     MOVE 25 TO L-MAX
     MOVE 0 TO L-DEFAULT
     MOVE 100 TO L-PROB
     MOVE 826 TO L-RATE
     GOBACK.
 END PROGRAM GC4-GROW-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-GROW-SURVIVE.
*> USING canAttachTo of the state behind (BINARY-LONG), it is the head or the body of the family, its face toward the plant is sturdy, canSurvive out: 3.2 step 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACH               BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACH L-FAMILY L-STURDY L-SURVIVE.
     MOVE 0 TO L-SURVIVE
     IF L-ATTACH = 1 AND (L-FAMILY = 1 OR L-STURDY = 1)
         MOVE 1 TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM GC4-GROW-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-GROW-PLACE.
*> USING the block is kelp, the state in the growth direction is the head or body, the clicked fluid is in tag water, it is full, the nextInt(25) draw (BINARY-LONG), the result
*> (0 null, 1 body, 2 head) and the head's age (-1 for none) out: getStateForPlacement (3.2 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KELP                 BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KELP L-FAMILY L-WATER L-FULL L-DRAW L-RESULT L-AGE.
     MOVE -1 TO L-AGE
     EVALUATE TRUE
         WHEN L-KELP = 1 AND (L-WATER = 0 OR L-FULL = 0)
             MOVE 0 TO L-RESULT
         WHEN L-FAMILY = 1
             MOVE 1 TO L-RESULT
         WHEN OTHER
             MOVE 2 TO L-RESULT
             MOVE L-DRAW TO L-AGE
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-GROW-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-HEAD-RANDOM.
*> USING age, the probability (FLOAT-LONG), the nextDouble draw (FLOAT-LONG), canGrowInto of the cell beyond (BINARY-LONG), isRandomlyTicking, a draw was made, it grew, the age
*> after, the setBlockAndUpdate flags (BINARY-LONG out): the head random tick (3.2 steps 5 and 6); the draw is only made at age < 25.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-PROB                 FLOAT-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 01 L-GREW                 BINARY-LONG.
 01 L-AGE-AFTER            BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-PROB L-DRAW L-CAN L-TICKING L-DREW L-GREW L-AGE-AFTER L-FLAGS.
     MOVE 0 TO L-TICKING L-DREW L-GREW L-FLAGS
     MOVE L-AGE TO L-AGE-AFTER
     IF L-AGE < 25
         MOVE 1 TO L-TICKING L-DREW
         IF L-DRAW < L-PROB AND L-CAN = 1
             MOVE 1 TO L-GREW
             MOVE 3 TO L-FLAGS
             COMPUTE L-AGE-AFTER = L-AGE + 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC4-HEAD-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-HEAD-SU.
*> USING the changed direction (0 other, 1 opposite the growth direction, 2 the growth direction), canSurvive, the state in the growth direction (case 1) or the changed neighbour
*> (case 2) is the head or body, scheduleFluidTicks (BINARY-LONG), block tick scheduled, becomes the body, water tick scheduled out: GrowingPlantHeadBlock.updateShape (3.2 step 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-BODY                 BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-SURVIVE L-FAMILY L-FLUID L-TICK L-BODY L-WATER.
     MOVE 0 TO L-TICK L-BODY
     MOVE L-FLUID TO L-WATER
     EVALUATE TRUE
         WHEN L-DIR = 1 AND L-SURVIVE = 0
             MOVE 1 TO L-TICK
         WHEN L-DIR = 1 AND L-FAMILY = 1
             MOVE 1 TO L-BODY
         WHEN L-DIR = 2 AND L-FAMILY = 1
             MOVE 1 TO L-BODY
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-HEAD-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BODY-SU.
*> USING the changed direction (0 other, 1 opposite the growth direction, 2 the growth direction), canSurvive, the neighbour is this body or the head, scheduleFluidTicks, the
*> nextInt(25) draw (BINARY-LONG), block tick scheduled, becomes a head, the head's age (-1 for none), water tick out: GrowingPlantBodyBlock.updateShape (3.2 step 10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-HEAD                 BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-SURVIVE L-FAMILY L-FLUID L-DRAW L-TICK L-HEAD L-AGE L-WATER.
     MOVE 0 TO L-TICK L-HEAD
     MOVE -1 TO L-AGE
     MOVE L-FLUID TO L-WATER
     EVALUATE TRUE
         WHEN L-DIR = 1 AND L-SURVIVE = 0
             MOVE 1 TO L-TICK
         WHEN L-DIR = 2 AND L-FAMILY = 0
             MOVE 1 TO L-HEAD
             MOVE L-DRAW TO L-AGE
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-BODY-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-GROW-BONE-VALID.
*> USING a head was found, canGrowInto of the cell beyond it, that cell is inside the build height (BINARY-LONG), valid, success out: bone meal of heads and bodies (3.2 steps 8, 11).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FOUND                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-FOUND L-CAN L-HEIGHT L-VALID L-SUCCESS.
     MOVE 0 TO L-VALID
     MOVE 1 TO L-SUCCESS
     IF L-FOUND = 1 AND L-CAN = 1 AND L-HEIGHT = 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC4-GROW-BONE-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-GROW-BONE.
*> USING the clicked head's age, n (blocks to grow), the consecutive cells beyond it that accept growth and are inside the build height (BINARY-LONG), heads written, the first
*> and the last written age (0 for none) out: the bone meal effect (3.2 step 8); each head has age min(a + 1, 25), counting from the clicked head.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-WRITTEN              BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-N L-FREE L-WRITTEN L-FIRST L-LAST.
     MOVE 0 TO L-WRITTEN L-FIRST L-LAST
     COMPUTE WS-A = FUNCTION MIN(L-AGE + 1, 25)
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > L-N OR WS-STEP > L-FREE
         ADD 1 TO L-WRITTEN
         IF WS-STEP = 1
             MOVE WS-A TO L-FIRST
         END-IF
         MOVE WS-A TO L-LAST
         COMPUTE WS-A = FUNCTION MIN(WS-A + 1, 25)
     END-PERFORM
     GOBACK.
 END PROGRAM GC4-GROW-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BODY-FIND.
*> USING the cells after pos in the growth direction that hold the body block, the first other cell is the head (BINARY-LONG), a head was found, its offset from pos out: 3.2 step 11.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RUN                  BINARY-LONG.
 01 L-HEAD                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-RUN L-HEAD L-FOUND L-OFFSET.
     MOVE L-HEAD TO L-FOUND
     COMPUTE L-OFFSET = L-RUN + 1
     GOBACK.
 END PROGRAM GC4-BODY-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BODY-REPLACE.
*> USING the default canBeReplaced result, the item in hand is the head's item (BINARY-LONG), canBeReplaced out: 3.2 step 12.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DEFAULT              BINARY-LONG.
 01 L-HEAD-ITEM            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DEFAULT L-HEAD-ITEM L-RESULT.
     MOVE L-DEFAULT TO L-RESULT
     IF L-HEAD-ITEM = 1
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC4-BODY-REPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-NETHER-COUNT.
*> USING the nextDouble draws in order (16 FLOAT-LONG, the last one used ends the count), the count out: NetherVines.getBlocksToGrowWhenBonemealed (3.4): threshold 1.0; a draw
*> below the threshold multiplies it by 0.826 and counts, the first draw at or above it stops.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-THRESHOLD           FLOAT-LONG.
 01 WS-RATE                FLOAT-LONG VALUE 0.826.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAWS L-COUNT.
     MOVE 0 TO L-COUNT
     MOVE 1.0 TO WS-THRESHOLD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16 OR L-DRAW(WS-I) >= WS-THRESHOLD
         COMPUTE WS-THRESHOLD = WS-THRESHOLD * WS-RATE
         ADD 1 TO L-COUNT
     END-PERFORM
     GOBACK.
 END PROGRAM GC4-NETHER-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-NETHER-P.
*> USING k (BINARY-LONG), P(count >= k) x 10000 out: 0.826 to the power k (k - 1) / 2 (3.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RATE                FLOAT-LONG VALUE 0.826.
 01 WS-EXPONENT            BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-P                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-P.
     COMPUTE WS-EXPONENT = L-K * (L-K - 1) / 2
     COMPUTE L-P ROUNDED = WS-RATE ** WS-EXPONENT * 10000
     GOBACK.
 END PROGRAM GC4-NETHER-P.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-GROW-TIME.
*> USING random_tick_speed, the success probability per random tick (FLOAT-LONG), random ticks needed per step (BINARY-LONG), game ticks per step, minutes x 10 out: a block is
*> random-ticked speed / 4096 per game tick (3.3, 4); a minute is 1200 ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TICKS               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SPEED                BINARY-LONG.
 01 L-PROB                 FLOAT-LONG.
 01 L-NEEDED               BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-MINUTES              BINARY-LONG.
 PROCEDURE DIVISION USING L-SPEED L-PROB L-NEEDED L-TICKS L-MINUTES.
     COMPUTE WS-TICKS = L-NEEDED * 4096 / (L-SPEED * L-PROB)
     COMPUTE L-TICKS ROUNDED = WS-TICKS
     COMPUTE L-MINUTES ROUNDED = WS-TICKS / 120
     GOBACK.
 END PROGRAM GC4-GROW-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CAVE-GROW.
*> USING age, the nextDouble draw and the nextFloat draw (FLOAT-LONG), canGrowInto of the cell below (BINARY-LONG), it grew, the new head's age, berries, draws made out: the cave
*> vines head random tick (3.5 step 1): nextDouble below 0.1 at age < 25, then (only when growing) berries = nextFloat < 0.11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   FLOAT-LONG VALUE 0.1.
 01 WS-BERRIES             FLOAT-LONG VALUE 0.11.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-GREW                 BINARY-LONG.
 01 L-AGE-AFTER            BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-D1 L-D2 L-CAN L-GREW L-AGE-AFTER L-HAS L-DRAWS.
     MOVE 0 TO L-GREW L-HAS L-DRAWS
     MOVE L-AGE TO L-AGE-AFTER
     IF L-AGE < 25
         MOVE 1 TO L-DRAWS
         IF L-D1 < WS-P AND L-CAN = 1
             MOVE 1 TO L-GREW
             MOVE 2 TO L-DRAWS
             COMPUTE L-AGE-AFTER = L-AGE + 1
             IF L-D2 < WS-BERRIES
                 MOVE 1 TO L-HAS
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC4-CAVE-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CAVE-PLACE.
*> USING the nextInt(25) draw (BINARY-LONG), the head's age and berries (false) out: placement of a cave vines head (3.5 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-BERRIES              BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-AGE L-BERRIES.
     MOVE L-DRAW TO L-AGE
     MOVE 0 TO L-BERRIES
     GOBACK.
 END PROGRAM GC4-CAVE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CAVE-CONVERT.
*> USING kind (1 head to body, 2 body to head), berries, the nextInt(25) draw (BINARY-LONG), berries after, the new head's age (-1 for none) out: 3.5 step 3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-BERRIES              BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-BERRIES L-DRAW L-AFTER L-AGE.
     MOVE L-BERRIES TO L-AFTER
     MOVE -1 TO L-AGE
     IF L-KIND = 2
         MOVE L-DRAW TO L-AGE
     END-IF
     GOBACK.
 END PROGRAM GC4-CAVE-CONVERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CAVE-BONE.
*> USING berries (BINARY-LONG), valid, success, berries after, the setBlock flags out: bone meal of cave vines (3.5 step 4): berries only, no growth.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BERRIES              BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-BERRIES L-VALID L-SUCCESS L-AFTER L-FLAGS.
     MOVE 0 TO L-VALID
     IF L-BERRIES = 0
         MOVE 1 TO L-VALID
     END-IF
     MOVE 1 TO L-SUCCESS L-AFTER
     MOVE 2 TO L-FLAGS
     GOBACK.
 END PROGRAM GC4-CAVE-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CAVE-HARVEST.
*> USING berries, the level is a server (BINARY-LONG), the nextFloat draw (FLOAT-LONG), result (0 PASS, 1 SUCCESS), loot dropped, pitch x 1000000, berries after (-1 for
*> unchanged), flags, game event BLOCK_CHANGE out: CaveVines.use (3.5 step 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOW                 FLOAT-LONG VALUE 0.8.
 01 WS-HIGH                FLOAT-LONG VALUE 1.2.
 LINKAGE SECTION.
 01 L-BERRIES              BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-BERRIES L-SERVER L-DRAW L-RESULT L-DROPS L-PITCH L-AFTER L-FLAGS L-EVENT.
     MOVE 0 TO L-RESULT L-DROPS L-PITCH L-FLAGS L-EVENT
     MOVE -1 TO L-AFTER
     IF L-BERRIES = 0
         GOBACK
     END-IF
     MOVE 1 TO L-RESULT
     IF L-SERVER = 1
         MOVE 1 TO L-DROPS L-EVENT
         COMPUTE L-PITCH ROUNDED = (L-DRAW * (WS-HIGH - WS-LOW) + WS-LOW) * 1000000
         MOVE 0 TO L-AFTER
         MOVE 2 TO L-FLAGS
     END-IF
     GOBACK.
 END PROGRAM GC4-CAVE-HARVEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CAVE-LIGHT.
*> USING berries (BINARY-LONG), the light level out: the registry gives cave vines light 14 when berries (3.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BERRIES              BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-BERRIES L-LIGHT.
     MOVE 0 TO L-LIGHT
     IF L-BERRIES = 1
         MOVE 14 TO L-LIGHT
     END-IF
     GOBACK.
 END PROGRAM GC4-CAVE-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CANE-CONST.
*> USING age maximum, shape width, y from, y to, bone meal (0 none), the flags of the age writes (BINARY-LONG out): SugarCaneBlock state and shape (4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAX                  BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-BONE                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX L-WIDTH L-Y0 L-Y1 L-BONE L-FLAGS.
     MOVE 15 TO L-MAX
     MOVE 12 TO L-WIDTH
     MOVE 0 TO L-Y0 L-BONE
     MOVE 16 TO L-Y1
     COMPUTE L-FLAGS = 4 + 256
     GOBACK.
 END PROGRAM GC4-CANE-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CANE-SURVIVE.
*> USING the block below is sugar cane, it is in tag supports_sugar_cane, then for north, east, south, west the neighbour of the block below has water in its fluid or frosted_ice
*> as its block (BINARY-LONG), canSurvive out: 4 step 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CANE                 BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-CANE L-TAG L-N L-E L-S L-W L-SURVIVE.
     MOVE L-CANE TO L-SURVIVE
     IF L-CANE = 0 AND L-TAG = 1 AND (L-N = 1 OR L-E = 1 OR L-S = 1 OR L-W = 1)
         MOVE 1 TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM GC4-CANE-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CANE-RT.
*> USING the cell above is air, the sugar canes directly below, age (BINARY-LONG), acted, a new cane placed above, the age after (-1 for unchanged), the flags of the age write,
*> h out: the random tick of 4 step 3; h is 1 plus the canes below, nothing happens at h >= 3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-ACTED                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-BELOW L-AGE L-ACTED L-NEW L-AFTER L-FLAGS L-H.
     MOVE 0 TO L-ACTED L-NEW L-FLAGS L-H
     MOVE -1 TO L-AFTER
     IF L-AIR = 0
         GOBACK
     END-IF
     COMPUTE L-H = 1 + L-BELOW
     IF L-H >= 3
         GOBACK
     END-IF
     MOVE 1 TO L-ACTED
     COMPUTE L-FLAGS = 4 + 256
     IF L-AGE = 15
         MOVE 1 TO L-NEW
         MOVE 0 TO L-AFTER
     ELSE
         COMPUTE L-AFTER = L-AGE + 1
     END-IF
     GOBACK.
 END PROGRAM GC4-CANE-RT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CACTUS-CONST.
*> USING MAX_CACTUS_GROWING_HEIGHT, ATTEMPT_GROW_CACTUS_FLOWER_AGE, the flower chances x 1000 (column shorter than 3, 3 or more), selection shape width, y from, y to, collision
*> shape top, isPathfindable (BINARY-LONG out): CactusBlock (5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HEIGHT               BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-COLLISION            BINARY-LONG.
 01 L-PATH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HEIGHT L-AGE L-LOW L-HIGH L-WIDTH L-Y0 L-Y1 L-COLLISION L-PATH.
     MOVE 3 TO L-HEIGHT
     MOVE 8 TO L-AGE
     MOVE 100 TO L-LOW
     MOVE 250 TO L-HIGH
     MOVE 14 TO L-WIDTH
     MOVE 0 TO L-Y0 L-PATH
     MOVE 16 TO L-Y1
     MOVE 15 TO L-COLLISION
     GOBACK.
 END PROGRAM GC4-CACTUS-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CACTUS-SURVIVE.
*> USING for north, east, south, west the neighbour is solid or its fluid is in tag lava, the block below is a cactus or in supports_cactus, the state above is a liquid
*> (BINARY-LONG), canSurvive out: 5.1 step 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-BELOW L-LIQUID L-SURVIVE.
     MOVE 0 TO L-SURVIVE
     IF L-N = 0 AND L-E = 0 AND L-S = 0 AND L-W = 0 AND L-BELOW = 1 AND L-LIQUID = 0
         MOVE 1 TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM GC4-CACTUS-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CACTUS-HURT.
*> USING the damage of the cactus source x 10, a side test (0 none), the call frequency (BINARY-LONG out): entityInside (5.1 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DAMAGE               BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-FREQUENCY            BINARY-LONG.
 PROCEDURE DIVISION USING L-DAMAGE L-SIDE L-FREQUENCY.
     MOVE 10 TO L-DAMAGE
     MOVE 0 TO L-SIDE
     MOVE 18 TO L-FREQUENCY
     GOBACK.
 END PROGRAM GC4-CACTUS-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CACTUS-RT.
*> USING the cell above is air, the cacti directly below, age, a cactus can survive in the cell above (BINARY-LONG), the nextDouble draw (FLOAT-LONG), acted, a flower placed,
*> a new cactus placed, the age after (-1 for unchanged), h, a draw was made out: the random tick of 5.1 step 4; the chance is 0.25 at h >= 3, else 0.1, compared with <=.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOW                 FLOAT-LONG VALUE 0.1.
 01 WS-HIGH                FLOAT-LONG VALUE 0.25.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-ACTED                BINARY-LONG.
 01 L-FLOWER               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-BELOW L-AGE L-SURVIVE L-DRAW L-ACTED L-FLOWER L-NEW L-AFTER L-H L-DREW.
     MOVE 0 TO L-ACTED L-FLOWER L-NEW L-H L-DREW
     MOVE -1 TO L-AFTER
     IF L-AIR = 0
         GOBACK
     END-IF
     COMPUTE L-H = 1 + L-BELOW
     IF L-H >= 3 AND L-AGE = 15
         GOBACK
     END-IF
     MOVE 1 TO L-ACTED
     IF L-AGE = 8 AND L-SURVIVE = 1
         MOVE 1 TO L-DREW
         IF L-H >= 3
             IF L-DRAW <= WS-HIGH
                 MOVE 1 TO L-FLOWER
             END-IF
         ELSE
             IF L-DRAW <= WS-LOW
                 MOVE 1 TO L-FLOWER
             END-IF
         END-IF
     ELSE
         IF L-AGE = 15
             MOVE 1 TO L-NEW
             MOVE 0 TO L-AFTER
             GOBACK
         END-IF
     END-IF
     COMPUTE L-AFTER = L-AGE + 1
     GOBACK.
 END PROGRAM GC4-CACTUS-RT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CFLOWER-CONST.
*> USING properties, ticks (0 none), shape width, y from, y to (BINARY-LONG out): CactusFlowerBlock (5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PROPS                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PROPS L-TICKS L-WIDTH L-Y0 L-Y1.
     MOVE 0 TO L-PROPS L-TICKS L-Y0
     MOVE 14 TO L-WIDTH
     MOVE 12 TO L-Y1
     GOBACK.
 END PROGRAM GC4-CFLOWER-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CFLOWER-PLACE.
*> USING the block below is in support_override_cactus_flower, its top face is CENTER sturdy (BINARY-LONG), mayPlaceOn out (5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-STURDY L-PLACE.
     MOVE 0 TO L-PLACE
     IF L-TAG = 1 OR L-STURDY = 1
         MOVE 1 TO L-PLACE
     END-IF
     GOBACK.
 END PROGRAM GC4-CFLOWER-PLACE.
