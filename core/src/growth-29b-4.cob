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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BAMBOO-CONST.
*> USING MAX_HEIGHT, age maximum, stage maximum, shape width with large leaves, shape width otherwise, collision width, sapling shape width and top (BINARY-LONG out): 6.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HEIGHT               BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 01 L-LARGE                BINARY-LONG.
 01 L-SMALL                BINARY-LONG.
 01 L-COLLISION            BINARY-LONG.
 01 L-SAPLING              BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HEIGHT L-AGE L-STAGE L-LARGE L-SMALL L-COLLISION L-SAPLING L-TOP.
     MOVE 16 TO L-HEIGHT
     MOVE 1 TO L-AGE L-STAGE
     MOVE 10 TO L-LARGE
     MOVE 6 TO L-SMALL
     MOVE 3 TO L-COLLISION
     MOVE 8 TO L-SAPLING
     MOVE 12 TO L-TOP
     GOBACK.
 END PROGRAM GC4-BAMBOO-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BAMBOO-TICKING.
*> USING stage (BINARY-LONG), isRandomlyTicking out: the stalk ticks only while it is growing (6.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STAGE                BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 PROCEDURE DIVISION USING L-STAGE L-TICKING.
     MOVE 0 TO L-TICKING
     IF L-STAGE = 0
         MOVE 1 TO L-TICKING
     END-IF
     GOBACK.
 END PROGRAM GC4-BAMBOO-TICKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BAMBOO-PLACE.
*> USING the fluid at the clicked position is empty, the block below is in supports_bamboo, the below kind (0 other, 1 bamboo_sapling, 2 bamboo), its age, the above kind (0 other,
*> 1 bamboo), its age (BINARY-LONG), result (0 null, 1 stalk, 2 bamboo_sapling) and the stalk's age (-1 for none) out: getStateForPlacement (6.2 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-BELOW-AGE            BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-ABOVE-AGE            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-OK L-BELOW L-BELOW-AGE L-ABOVE L-ABOVE-AGE L-RESULT L-AGE.
     MOVE -1 TO L-AGE
     EVALUATE TRUE
         WHEN L-EMPTY = 0 OR L-OK = 0
             MOVE 0 TO L-RESULT
         WHEN L-BELOW = 1
             MOVE 1 TO L-RESULT
             MOVE 0 TO L-AGE
         WHEN L-BELOW = 2
             MOVE 1 TO L-RESULT
             MOVE 0 TO L-AGE
             IF L-BELOW-AGE > 0
                 MOVE 1 TO L-AGE
             END-IF
         WHEN L-ABOVE = 1
             MOVE 1 TO L-RESULT
             MOVE L-ABOVE-AGE TO L-AGE
         WHEN OTHER
             MOVE 2 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-BAMBOO-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BAMBOO-SU.
*> USING canSurvive, the changed direction is UP, the neighbour is bamboo, its age, this age (BINARY-LONG), block tick scheduled, the age after (-1 for unchanged) out: 6.2 step 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVE              BINARY-LONG.
 01 L-UP                   BINARY-LONG.
 01 L-BAMBOO               BINARY-LONG.
 01 L-NEIGHBOUR-AGE        BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVE L-UP L-BAMBOO L-NEIGHBOUR-AGE L-AGE L-TICK L-AFTER.
     MOVE 0 TO L-TICK
     MOVE -1 TO L-AFTER
     IF L-SURVIVE = 0
         MOVE 1 TO L-TICK
     END-IF
     IF L-UP = 1 AND L-BAMBOO = 1 AND L-NEIGHBOUR-AGE > L-AGE
         COMPUTE L-AFTER = 1 - L-AGE
     END-IF
     GOBACK.
 END PROGRAM GC4-BAMBOO-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BAMBOO-RT.
*> USING stage, the nextInt(3) draw, the cell above is air, its raw brightness, the bamboo blocks below (BINARY-LONG), isRandomlyTicking, grows, h out: the stalk random tick
*> (6.2 step 4); the draw is first, h is the bamboo below (at most 16) plus 1 and growth needs h < 16.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STAGE                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-BRIGHTNESS           BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 01 L-GROWS                BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STAGE L-DRAW L-AIR L-BRIGHTNESS L-BELOW L-TICKING L-GROWS L-H.
     MOVE 0 TO L-TICKING L-GROWS L-H
     IF L-STAGE NOT = 0
         GOBACK
     END-IF
     MOVE 1 TO L-TICKING
     COMPUTE L-H = FUNCTION MIN(L-BELOW, 16) + 1
     IF L-DRAW = 0 AND L-AIR = 1 AND L-BRIGHTNESS >= 9 AND L-H < 16
         MOVE 1 TO L-GROWS
     END-IF
     GOBACK.
 END PROGRAM GC4-BAMBOO-RT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BAMBOO-GROW.
*> USING h, the state below (0 not bamboo, 1 bamboo without leaves, 2 bamboo with leaves), a stalk is two below (BINARY-LONG), this stalk's age, the nextFloat draw (FLOAT-LONG),
*> the new stalk's leaves (0 none, 1 small, 2 large), the stalk below is set small, the one two below is set none, the new age, the new stage, a draw was made out: growBamboo (6.2 step 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-TWO                  BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-LEAVES               BINARY-LONG.
 01 L-SET1                 BINARY-LONG.
 01 L-SET2                 BINARY-LONG.
 01 L-NEW-AGE              BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-H L-BELOW L-TWO L-AGE L-DRAW L-LEAVES L-SET1 L-SET2 L-NEW-AGE L-STAGE L-DREW.
     MOVE 0 TO L-LEAVES L-SET1 L-SET2 L-NEW-AGE L-STAGE L-DREW
     IF L-H >= 1
         IF L-BELOW < 2
             MOVE 1 TO L-LEAVES
         ELSE
             MOVE 2 TO L-LEAVES
             IF L-TWO = 1
                 MOVE 1 TO L-SET1 L-SET2
             END-IF
         END-IF
     END-IF
     IF L-AGE = 1 OR L-TWO = 1
         MOVE 1 TO L-NEW-AGE
     END-IF
     IF L-H >= 11
         MOVE 1 TO L-DREW
         IF L-DRAW < WS-QUARTER
             MOVE 1 TO L-STAGE
         END-IF
     END-IF
     IF L-H = 15
         MOVE 1 TO L-STAGE
     END-IF
     GOBACK.
 END PROGRAM GC4-BAMBOO-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BAMBOO-BONE-VALID.
*> USING the bamboo above pos, the bamboo below pos, the top stalk's stage, p is inside the build height, p is air (BINARY-LONG), valid, success out: 6.2 step 6.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ABOVE                BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-ABOVE L-BELOW L-STAGE L-HEIGHT L-AIR L-VALID L-SUCCESS.
     MOVE 0 TO L-VALID
     MOVE 1 TO L-SUCCESS
     IF L-ABOVE + L-BELOW + 1 < 16 AND L-STAGE NOT = 1 AND L-HEIGHT = 1 AND L-AIR = 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC4-BAMBOO-BONE-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BAMBOO-BONE.
*> USING the bamboo above pos, below pos, the top stalk's stage, the free cells above the top (air and inside the height), the nextInt(2) draw (BINARY-LONG), two nextFloat draws
*> (FLOAT-LONG), n, stalks grown, the total after, floats drawn out: the bone meal effect (6.2 step 6); each growth stops at total >= 16, stage 1 or no free cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 01 WS-STEP                BINARY-LONG.
 01 WS-STAGE               BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ABOVE                BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-F1                   FLOAT-LONG.
 01 L-F2                   FLOAT-LONG.
 01 L-N                    BINARY-LONG.
 01 L-GROWN                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-ABOVE L-BELOW L-STAGE L-FREE L-DRAW L-F1 L-F2 L-N L-GROWN L-TOTAL L-DRAWN.
     COMPUTE L-TOTAL = L-ABOVE + L-BELOW + 1
     COMPUTE L-N = 1 + L-DRAW
     MOVE 0 TO L-GROWN L-DRAWN
     MOVE L-STAGE TO WS-STAGE
     MOVE L-FREE TO WS-FREE
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > L-N OR L-TOTAL >= 16 OR WS-STAGE = 1 OR WS-FREE = 0
         MOVE 0 TO WS-STAGE
         IF L-TOTAL >= 11
             ADD 1 TO L-DRAWN
             MOVE L-F1 TO WS-DRAW
             IF L-DRAWN = 2
                 MOVE L-F2 TO WS-DRAW
             END-IF
             IF WS-DRAW < WS-QUARTER
                 MOVE 1 TO WS-STAGE
             END-IF
         END-IF
         IF L-TOTAL = 15
             MOVE 1 TO WS-STAGE
         END-IF
         ADD 1 TO L-TOTAL L-GROWN
         SUBTRACT 1 FROM WS-FREE
     END-PERFORM
     GOBACK.
 END PROGRAM GC4-BAMBOO-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SAPLING-RT.
*> USING the nextInt(3) draw, the cell above is air, its raw brightness (BINARY-LONG), grows, the new stalk's leaves (1 small) out: BambooSaplingBlock random tick (6.3 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-BRIGHTNESS           BINARY-LONG.
 01 L-GROWS                BINARY-LONG.
 01 L-LEAVES               BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-AIR L-BRIGHTNESS L-GROWS L-LEAVES.
     MOVE 0 TO L-GROWS
     MOVE 1 TO L-LEAVES
     IF L-DRAW = 0 AND L-AIR = 1 AND L-BRIGHTNESS >= 9
         MOVE 1 TO L-GROWS
     END-IF
     GOBACK.
 END PROGRAM GC4-SAPLING-RT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SAPLING-SU.
*> USING canSurvive, the changed direction is UP, the neighbour is bamboo (BINARY-LONG), result (0 unchanged, 1 air, 2 the default stalk) out: 6.3 step 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVE              BINARY-LONG.
 01 L-UP                   BINARY-LONG.
 01 L-BAMBOO               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVE L-UP L-BAMBOO L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE TRUE
         WHEN L-SURVIVE = 0
             MOVE 1 TO L-RESULT
         WHEN L-UP = 1 AND L-BAMBOO = 1
             MOVE 2 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-SAPLING-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SAPLING-BONE.
*> USING the cell above is air, it is inside the build height (BINARY-LONG), valid, success out: 6.3 step 3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-HEIGHT L-VALID L-SUCCESS.
     MOVE 0 TO L-VALID
     MOVE 1 TO L-SUCCESS
     IF L-AIR = 1 AND L-HEIGHT = 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC4-SAPLING-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-GATE.
*> USING the game rule spread_vines, the nextInt(4) draw (BINARY-LONG), the random tick goes on (BINARY-LONG out): the gate of 7.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-PASS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-DRAW L-PASS.
     MOVE 0 TO L-PASS
     IF L-RULE = 1 AND L-DRAW = 0
         MOVE 1 TO L-PASS
     END-IF
     GOBACK.
 END PROGRAM GC4-VINE-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-CROWD.
*> USING the vine blocks in the box (BINARY-LONG), canSpread (at most 4), the volume of the box (9 x 3 x 9) out: 7.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-SPREAD               BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-SPREAD L-VOLUME.
     MOVE 0 TO L-SPREAD
     IF L-COUNT <= 4
         MOVE 1 TO L-SPREAD
     END-IF
     COMPUTE L-VOLUME = 9 * 3 * 9
     GOBACK.
 END PROGRAM GC4-VINE-CROWD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-BOX.
*> USING the offset dx, dy, dz of a cell from the vine (BINARY-LONG), the cell is inside the crowding box (both corners inclusive) out: 7.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-INSIDE.
     MOVE 0 TO L-INSIDE
     IF L-DX >= -4 AND L-DX <= 4 AND L-DY >= -1 AND L-DY <= 1 AND L-DZ >= -4 AND L-DZ <= 4
         MOVE 1 TO L-INSIDE
     END-IF
     GOBACK.
 END PROGRAM GC4-VINE-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-WRAP.
*> USING the nextFloat draw converted to double (FLOAT-LONG), the wrap-over happens (BINARY-LONG out): the draw is below 0.05 (7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CHANCE              FLOAT-LONG VALUE 0.05.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-WRAP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-WRAP.
     MOVE 0 TO L-WRAP
     IF L-DRAW < WS-CHANCE
         MOVE 1 TO L-WRAP
     END-IF
     GOBACK.
 END PROGRAM GC4-VINE-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-UPFACES.
*> USING four nextBoolean draws (north, east, south, west) and four acceptances of the neighbour of the cell above (BINARY-LONG), the four faces of the new vine out: the face
*> survives only when the draw is false and the neighbour is acceptable (7, copy to the block above).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-D3                   BINARY-LONG.
 01 L-D4                   BINARY-LONG.
 01 L-A1                   BINARY-LONG.
 01 L-A2                   BINARY-LONG.
 01 L-A3                   BINARY-LONG.
 01 L-A4                   BINARY-LONG.
 01 L-F1                   BINARY-LONG.
 01 L-F2                   BINARY-LONG.
 01 L-F3                   BINARY-LONG.
 01 L-F4                   BINARY-LONG.
 PROCEDURE DIVISION USING L-D1 L-D2 L-D3 L-D4 L-A1 L-A2 L-A3 L-A4 L-F1 L-F2 L-F3 L-F4.
     MOVE 0 TO L-F1 L-F2 L-F3 L-F4
     IF L-D1 = 0 AND L-A1 = 1
         MOVE 1 TO L-F1
     END-IF
     IF L-D2 = 0 AND L-A2 = 1
         MOVE 1 TO L-F2
     END-IF
     IF L-D3 = 0 AND L-A3 = 1
         MOVE 1 TO L-F3
     END-IF
     IF L-D4 = 0 AND L-A4 = 1
         MOVE 1 TO L-F4
     END-IF
     GOBACK.
 END PROGRAM GC4-VINE-UPFACES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-COPYDOWN.
*> USING four nextBoolean draws (north, east, south, west) and whether the source vine has each face (BINARY-LONG), the faces the target gets out: copyRandomFaces (7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-D3                   BINARY-LONG.
 01 L-D4                   BINARY-LONG.
 01 L-S1                   BINARY-LONG.
 01 L-S2                   BINARY-LONG.
 01 L-S3                   BINARY-LONG.
 01 L-S4                   BINARY-LONG.
 01 L-T1                   BINARY-LONG.
 01 L-T2                   BINARY-LONG.
 01 L-T3                   BINARY-LONG.
 01 L-T4                   BINARY-LONG.
 PROCEDURE DIVISION USING L-D1 L-D2 L-D3 L-D4 L-S1 L-S2 L-S3 L-S4 L-T1 L-T2 L-T3 L-T4.
     MOVE 0 TO L-T1 L-T2 L-T3 L-T4
     IF L-D1 = 1 AND L-S1 = 1
         MOVE 1 TO L-T1
     END-IF
     IF L-D2 = 1 AND L-S2 = 1
         MOVE 1 TO L-T2
     END-IF
     IF L-D3 = 1 AND L-S3 = 1
         MOVE 1 TO L-T3
     END-IF
     IF L-D4 = 1 AND L-S4 = 1
         MOVE 1 TO L-T4
     END-IF
     GOBACK.
 END PROGRAM GC4-VINE-COPYDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-HCONN.
*> USING the four horizontal faces (BINARY-LONG), hasHorizontalConnection out (7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-ANY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-ANY.
     MOVE 0 TO L-ANY
     IF L-N = 1 OR L-E = 1 OR L-S = 1 OR L-W = 1
         MOVE 1 TO L-ANY
     END-IF
     GOBACK.
 END PROGRAM GC4-VINE-HCONN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-UPCHECK.
*> USING kind (1 the re-check of the up face, getUpdatedState, which passes DOWN and so tests the TOP face of the block above; 2 the random tick and placement, which pass UP and
*> test its BOTTOM face), the top face is full, the bottom face is full (BINARY-LONG), isAcceptableNeighbour out: the quirk of 7 (open question 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-BOTTOM               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TOP L-BOTTOM L-OK.
     MOVE L-BOTTOM TO L-OK
     IF L-KIND = 1
         MOVE L-TOP TO L-OK
     END-IF
     GOBACK.
 END PROGRAM GC4-VINE-UPCHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-REPLACE.
*> USING the faces of the vine (BINARY-LONG), canBeReplaced out: while it has fewer than 5 faces (7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACES                BINARY-LONG.
 01 L-REPLACE              BINARY-LONG.
 PROCEDURE DIVISION USING L-FACES L-REPLACE.
     MOVE 0 TO L-REPLACE
     IF L-FACES < 5
         MOVE 1 TO L-REPLACE
     END-IF
     GOBACK.
 END PROGRAM GC4-VINE-REPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-SU.
*> USING the changed direction (1 down), the faces of the recomputed state (BINARY-LONG), result (0 the default, 1 the recomputed state, 2 air) out: updateShape (7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-FACES                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-FACES L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-DIR = 1
         MOVE 0 TO L-RESULT
     ELSE
         IF L-FACES = 0
             MOVE 2 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC4-VINE-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-VINE-CONST.
*> USING the flags of every write of the random tick, the entries of the face-property map (BINARY-LONG out): 7.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLAGS                BINARY-LONG.
 01 L-FACES                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS L-FACES.
     MOVE 2 TO L-FLAGS
     MOVE 5 TO L-FACES
     GOBACK.
 END PROGRAM GC4-VINE-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CHORUS-CONST.
*> USING the PipeBlock size, the boolean properties, the strength x 10 (BINARY-LONG out): the chorus plant (8.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-PROPS                BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-PROPS L-STRENGTH.
     MOVE 10 TO L-SIZE
     MOVE 6 TO L-PROPS
     MOVE 4 TO L-STRENGTH
     GOBACK.
 END PROGRAM GC4-CHORUS-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CHORUS-CONN.
*> USING the direction, the neighbour is a plant or a flower, it is in supports_chorus_plant (BINARY-LONG), connected out: DOWN also connects to the tag, the rest only to
*> a plant or a flower (8.1 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-PLANT                BINARY-LONG.
 01 L-SUPPORT              BINARY-LONG.
 01 L-CONNECTED            BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-PLANT L-SUPPORT L-CONNECTED.
     MOVE L-PLANT TO L-CONNECTED
     IF L-DIR = 1 AND L-SUPPORT = 1
         MOVE 1 TO L-CONNECTED
     END-IF
     GOBACK.
 END PROGRAM GC4-CHORUS-CONN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CHORUS-SU.
*> USING canSurvive, the changed direction, the neighbour is a plant or flower, it is in supports_chorus_plant (BINARY-LONG), a block tick scheduled, the property of the changed
*> direction (-1 when it is left to the default update) out: ChorusPlantBlock.updateShape (8.1 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVE              BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-PLANT                BINARY-LONG.
 01 L-SUPPORT              BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-PROP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVE L-DIR L-PLANT L-SUPPORT L-TICK L-PROP.
     MOVE 0 TO L-TICK
     MOVE -1 TO L-PROP
     IF L-SURVIVE = 0
         MOVE 1 TO L-TICK
         GOBACK
     END-IF
     CALL "GC4-CHORUS-CONN" USING L-DIR L-PLANT L-SUPPORT L-PROP
     GOBACK.
 END PROGRAM GC4-CHORUS-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-CHORUS-SURVIVE.
*> USING the block below is a plant or in supports_chorus_plant, the block below is air, the block above is air, then for north, east, south, west: the neighbour is a plant and
*> the block below it is a plant or in the tag (BINARY-LONG pairs), canSurvive out: 8.1 step 4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BOTH                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BELOW-OK             BINARY-LONG.
 01 L-BELOW-AIR            BINARY-LONG.
 01 L-ABOVE-AIR            BINARY-LONG.
 01 L-P1                   BINARY-LONG.
 01 L-Q1                   BINARY-LONG.
 01 L-P2                   BINARY-LONG.
 01 L-Q2                   BINARY-LONG.
 01 L-P3                   BINARY-LONG.
 01 L-Q3                   BINARY-LONG.
 01 L-P4                   BINARY-LONG.
 01 L-Q4                   BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-BELOW-OK L-BELOW-AIR L-ABOVE-AIR L-P1 L-Q1 L-P2 L-Q2 L-P3 L-Q3 L-P4 L-Q4 L-SURVIVE.
     MOVE 0 TO WS-BOTH
     IF L-BELOW-AIR = 0 AND L-ABOVE-AIR = 0
         MOVE 1 TO WS-BOTH
     END-IF
     EVALUATE TRUE
         WHEN L-P1 = 1 AND WS-BOTH = 1
             MOVE 0 TO L-SURVIVE
         WHEN L-P1 = 1 AND L-Q1 = 1
             MOVE 1 TO L-SURVIVE
         WHEN L-P2 = 1 AND WS-BOTH = 1
             MOVE 0 TO L-SURVIVE
         WHEN L-P2 = 1 AND L-Q2 = 1
             MOVE 1 TO L-SURVIVE
         WHEN L-P3 = 1 AND WS-BOTH = 1
             MOVE 0 TO L-SURVIVE
         WHEN L-P3 = 1 AND L-Q3 = 1
             MOVE 1 TO L-SURVIVE
         WHEN L-P4 = 1 AND WS-BOTH = 1
             MOVE 0 TO L-SURVIVE
         WHEN L-P4 = 1 AND L-Q4 = 1
             MOVE 1 TO L-SURVIVE
         WHEN OTHER
             MOVE L-BELOW-OK TO L-SURVIVE
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-CHORUS-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLOWER-SURVIVE.
*> USING the block below is a plant or in supports_chorus_flower, the block below is air, then for north, east, south, west the neighbour (0 air, 1 plant, 2 other)
*> (BINARY-LONG), canSurvive out: ChorusFlowerBlock (8.2 step 1): with air below exactly one horizontal neighbour is a plant and the others are air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SIDES.
    05 WS-SIDE             BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-BELOW-OK             BINARY-LONG.
 01 L-BELOW-AIR            BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-BELOW-OK L-BELOW-AIR L-N L-E L-S L-W L-SURVIVE.
     MOVE 1 TO L-SURVIVE
     IF L-BELOW-OK = 1
         GOBACK
     END-IF
     MOVE 0 TO L-SURVIVE
     IF L-BELOW-AIR = 0
         GOBACK
     END-IF
     MOVE L-N TO WS-SIDE(1)
     MOVE L-E TO WS-SIDE(2)
     MOVE L-S TO WS-SIDE(3)
     MOVE L-W TO WS-SIDE(4)
     MOVE 0 TO WS-FOUND WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4 OR WS-BAD = 1
         EVALUATE WS-SIDE(WS-I)
             WHEN 1
                 IF WS-FOUND = 1
                     MOVE 1 TO WS-BAD
                 END-IF
                 MOVE 1 TO WS-FOUND
             WHEN 2
                 MOVE 1 TO WS-BAD
         END-EVALUATE
     END-PERFORM
     IF WS-BAD = 0
         MOVE WS-FOUND TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM GC4-FLOWER-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLOWER-SU.
*> USING the changed direction (2 up), canSurvive (BINARY-LONG), a block tick scheduled out: ChorusFlowerBlock.updateShape (8.2 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-SURVIVE L-TICK.
     MOVE 0 TO L-TICK
     IF L-DIR NOT = 2 AND L-SURVIVE = 0
         MOVE 1 TO L-TICK
     END-IF
     GOBACK.
 END PROGRAM GC4-FLOWER-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLOWER-PROJ.
*> USING the level is a server, the projectile may interact with the position, it may break blocks (BINARY-LONG), destroyBlock with drops out: onProjectileHit (8.2 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-INTERACT             BINARY-LONG.
 01 L-BREAK                BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-INTERACT L-BREAK L-DESTROY.
     MOVE 0 TO L-DESTROY
     IF L-SERVER = 1 AND L-INTERACT = 1 AND L-BREAK = 1
         MOVE 1 TO L-DESTROY
     END-IF
     GOBACK.
 END PROGRAM GC4-FLOWER-PROJ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLOWER-COLUMN.
*> USING the cells 2, 3 and 4 below the flower (1 plant, 2 end stone in supports_chorus_flower, 0 other) (BINARY-LONG), h, endBelow out: the look down a plant column (8.2 step 4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C2                   BINARY-LONG.
 01 L-C3                   BINARY-LONG.
 01 L-C4                   BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING L-C2 L-C3 L-C4 L-H L-END.
     MOVE 1 TO L-H
     MOVE 0 TO L-END
     EVALUATE TRUE
         WHEN L-C2 NOT = 1
             IF L-C2 = 2
                 MOVE 1 TO L-END
             END-IF
         WHEN L-C3 NOT = 1
             MOVE 2 TO L-H
             IF L-C3 = 2
                 MOVE 1 TO L-END
             END-IF
         WHEN L-C4 NOT = 1
             MOVE 3 TO L-H
             IF L-C4 = 2
                 MOVE 1 TO L-END
             END-IF
         WHEN OTHER
             MOVE 4 TO L-H
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-FLOWER-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLOWER-GROW.
*> USING the block below (1 in supports_chorus_flower, 2 the plant, 3 air, 0 other), h, endBelow, the nextInt(5 or 4) draw (BINARY-LONG), grow, a draw was made out: the growth
*> test of the random tick (8.2 step 4.2 to 4.4); a plant column grows when h < 2 or h <= the draw, the draw made only when h >= 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BELOW                BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-GROW                 BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BELOW L-H L-END L-DRAW L-GROW L-DREW.
     MOVE 0 TO L-GROW L-DREW
     EVALUATE TRUE
         WHEN L-BELOW = 1 OR L-BELOW = 3
             MOVE 1 TO L-GROW
         WHEN L-BELOW = 2 AND L-H < 2
             MOVE 1 TO L-GROW
         WHEN L-BELOW = 2
             MOVE 1 TO L-DREW
             IF L-H <= L-DRAW
                 MOVE 1 TO L-GROW
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-FLOWER-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLOWER-EMPTY.
*> USING the four horizontal neighbours north, east, south, west are air (BINARY-LONG), the excepted direction (0 none, else 1 to 4), all empty out: allNeighborsEmpty (8.2 step 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-EXCEPT               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-EXCEPT L-EMPTY.
     MOVE 1 TO L-EMPTY
     IF L-N = 0 AND L-EXCEPT NOT = 1
         MOVE 0 TO L-EMPTY
     END-IF
     IF L-E = 0 AND L-EXCEPT NOT = 2
         MOVE 0 TO L-EMPTY
     END-IF
     IF L-S = 0 AND L-EXCEPT NOT = 3
         MOVE 0 TO L-EMPTY
     END-IF
     IF L-W = 0 AND L-EXCEPT NOT = 4
         MOVE 0 TO L-EMPTY
     END-IF
     GOBACK.
 END PROGRAM GC4-FLOWER-EMPTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLOWER-RT.
*> USING the cell above is air, it is inside the build height, age, grow, growing up is possible (allNeighborsEmpty of the cell above and air two above), the nextInt(4) draw, endBelow,
*> and whether each of the first four side attempts finds a valid cell (BINARY-LONG), action (0 nothing, 1 grew up, 2 branched, 3 died after branching, 4 died), flowers placed, level
*> event, the placed flower's age, direction draws out: the random tick of the flower (8.2 step 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-GROW                 BINARY-LONG.
 01 L-UP-OK                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-V1                   BINARY-LONG.
 01 L-V2                   BINARY-LONG.
 01 L-V3                   BINARY-LONG.
 01 L-V4                   BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-FLOWER-AGE           BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-HEIGHT L-AGE L-GROW L-UP-OK L-DRAW L-END L-V1 L-V2 L-V3 L-V4 L-ACTION L-PLACED L-EVENT L-FLOWER-AGE L-DRAWS.
     MOVE 0 TO L-ACTION L-PLACED L-EVENT L-DRAWS
     MOVE L-AGE TO L-FLOWER-AGE
     IF L-AIR = 0 OR L-HEIGHT = 0 OR L-AGE >= 5
         GOBACK
     END-IF
     IF L-GROW = 1 AND L-UP-OK = 1
         MOVE 1 TO L-ACTION
         MOVE 1033 TO L-EVENT
         GOBACK
     END-IF
     IF L-AGE < 4
         COMPUTE WS-N = L-DRAW + L-END
         MOVE WS-N TO L-DRAWS
         IF WS-N >= 1
             ADD L-V1 TO L-PLACED
         END-IF
         IF WS-N >= 2
             ADD L-V2 TO L-PLACED
         END-IF
         IF WS-N >= 3
             ADD L-V3 TO L-PLACED
         END-IF
         IF WS-N >= 4
             ADD L-V4 TO L-PLACED
         END-IF
         IF L-PLACED > 0
             MOVE 2 TO L-ACTION
             MOVE 1033 TO L-EVENT
             COMPUTE L-FLOWER-AGE = L-AGE + 1
             GOBACK
         END-IF
         MOVE 3 TO L-ACTION
     ELSE
         MOVE 4 TO L-ACTION
     END-IF
     MOVE 1034 TO L-EVENT
     MOVE 5 TO L-FLOWER-AGE
     GOBACK.
 END PROGRAM GC4-FLOWER-RT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLOWER-CONST.
*> USING two ages, AGE_5 maximum, DEAD_AGE, isRandomlyTicking at the first age, at the second age, support shape width and top (BINARY-LONG out): 8.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE-A                BINARY-LONG.
 01 L-AGE-B                BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-DEAD                 BINARY-LONG.
 01 L-TICK-A               BINARY-LONG.
 01 L-TICK-B               BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE-A L-AGE-B L-MAX L-DEAD L-TICK-A L-TICK-B L-WIDTH L-TOP.
     MOVE 5 TO L-MAX L-DEAD
     MOVE 0 TO L-TICK-A L-TICK-B
     IF L-AGE-A < 5
         MOVE 1 TO L-TICK-A
     END-IF
     IF L-AGE-B < 5
         MOVE 1 TO L-TICK-B
     END-IF
     MOVE 14 TO L-WIDTH
     MOVE 15 TO L-TOP
     GOBACK.
 END PROGRAM GC4-FLOWER-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DOUBLE-PLACE.
*> USING the clicked y is below the maximum build height, the cell above can be replaced (BINARY-LONG), the lower state is placed out (0 null): DoublePlantBlock (9.1 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HEIGHT               BINARY-LONG.
 01 L-REPLACE              BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-HEIGHT L-REPLACE L-PLACED.
     MOVE 0 TO L-PLACED
     IF L-HEIGHT = 1 AND L-REPLACE = 1
         MOVE 1 TO L-PLACED
     END-IF
     GOBACK.
 END PROGRAM GC4-DOUBLE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DOUBLE-SETPLACED.
*> USING the block has the property waterlogged, isWaterAt(pos) (BINARY-LONG), the half written above (1 upper), its waterlogged (-1 without the property), the flags out: setPlacedBy (9.1 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-WATER L-HALF L-WATERLOGGED L-FLAGS.
     MOVE 1 TO L-HALF
     MOVE 3 TO L-FLAGS
     CALL "GC4-WATERLOG-COPY" USING L-HAS L-WATER L-WATERLOGGED
     GOBACK.
 END PROGRAM GC4-DOUBLE-SETPLACED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DOUBLE-SURVIVE.
*> USING half (0 lower, 1 upper), the state below is this block with half lower, mayPlaceOn of the state below (BINARY-LONG), canSurvive out: 9.1 step 3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HALF                 BINARY-LONG.
 01 L-BELOW-LOWER          BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-HALF L-BELOW-LOWER L-MAY L-SURVIVE.
     MOVE L-MAY TO L-SURVIVE
     IF L-HALF = 1
         MOVE L-BELOW-LOWER TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM GC4-DOUBLE-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DOUBLE-SU.
*> USING half (0 lower, 1 upper), the changed direction (1 down, 2 up, 3 other), the neighbour is this block, its half, canSurvive (BINARY-LONG), the result (1 air, 0 unchanged) out:
*> DoublePlantBlock.updateShape (9.1 step 4): the partner cell gives air unless the neighbour is this block with the other half; else the lower half over a missing ground gives air.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HALF                 BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-NEIGHBOUR-HALF       BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HALF L-DIR L-SAME L-NEIGHBOUR-HALF L-SURVIVE L-AIR.
     MOVE 0 TO L-AIR
     EVALUATE TRUE
         WHEN (L-HALF = 0 AND L-DIR = 2) OR (L-HALF = 1 AND L-DIR = 1)
             IF L-SAME = 0 OR L-NEIGHBOUR-HALF = L-HALF
                 MOVE 1 TO L-AIR
             END-IF
         WHEN L-SURVIVE = 0
             MOVE 1 TO L-AIR
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-DOUBLE-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DOUBLE-PLACEAT.
*> USING the block has the property waterlogged, isWaterAt(pos) (BINARY-LONG), the waterlogged of the lower and of the upper half (-1 without the property) out: placeAt (9.1 step 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-LOWER                BINARY-LONG.
 01 L-UPPER                BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-WATER L-LOWER L-UPPER.
     CALL "GC4-WATERLOG-COPY" USING L-HAS L-WATER L-LOWER
     MOVE L-LOWER TO L-UPPER
     GOBACK.
 END PROGRAM GC4-DOUBLE-PLACEAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DOUBLE-BREAK.
*> USING the player prevents block drops (creative), half (0 lower, 1 upper), the state below is this block with half lower, FluidState.is(Fluids.WATER) of the lower position (BINARY-LONG),
*> action (0 nothing, 1 dropResources, 2 lower set to water, 3 lower set to air), flags, level event, drops of the break itself out: playerWillDestroy (9.1 step 6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CREATIVE             BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-BELOW-LOWER          BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-CREATIVE L-HALF L-BELOW-LOWER L-WATER L-ACTION L-FLAGS L-EVENT L-DROPS.
     MOVE 0 TO L-ACTION L-FLAGS L-EVENT L-DROPS
     EVALUATE TRUE
         WHEN L-CREATIVE = 0
             MOVE 1 TO L-ACTION
         WHEN L-HALF = 1 AND L-BELOW-LOWER = 1
             MOVE 3 TO L-ACTION
             IF L-WATER = 1
                 MOVE 2 TO L-ACTION
             END-IF
             COMPUTE L-FLAGS = 1 + 2 + 32
             MOVE 2001 TO L-EVENT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-DOUBLE-BREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DOUBLE-SEED.
*> USING half (0 lower, 1 upper), y, the y of the position the offset seed uses out: both halves use the lower half's position (9.1 step 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HALF                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-SEED-Y               BINARY-LONG.
 PROCEDURE DIVISION USING L-HALF L-Y L-SEED-Y.
     MOVE L-Y TO L-SEED-Y
     IF L-HALF = 1
         SUBTRACT 1 FROM L-SEED-Y
     END-IF
     GOBACK.
 END PROGRAM GC4-DOUBLE-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SEAGRASS-PLACEON.
*> USING the block below has a sturdy face toward UP, it is in cannot_support_seagrass (BINARY-LONG), mayPlaceOn out: 9.2 step 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STURDY               BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STURDY L-TAG L-OK.
     MOVE 0 TO L-OK
     IF L-STURDY = 1 AND L-TAG = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM GC4-SEAGRASS-PLACEON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SEAGRASS-PLACE.
*> USING the clicked fluid is in tag water, it is full (BINARY-LONG), placed out (0 null): 9.2 step 2 and 9.3 (the cell above for tall seagrass).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-FULL L-PLACED.
     MOVE 0 TO L-PLACED
     IF L-WATER = 1 AND L-FULL = 1
         MOVE 1 TO L-PLACED
     END-IF
     GOBACK.
 END PROGRAM GC4-SEAGRASS-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SEAGRASS-SU.
*> USING canSurvive (BINARY-LONG), the result is air, a water tick is scheduled out: the shape update of seagrass (9.2 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVE              BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVE L-AIR L-WATER.
     MOVE 0 TO L-AIR L-WATER
     IF L-SURVIVE = 0
         MOVE 1 TO L-AIR
     ELSE
         MOVE 1 TO L-WATER
     END-IF
     GOBACK.
 END PROGRAM GC4-SEAGRASS-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SEAGRASS-BONE.
*> USING the block above is block water (BINARY-LONG), valid, success, the flags of both tall_seagrass writes out: 9.2 step 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ABOVE                BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ABOVE L-VALID L-SUCCESS L-FLAGS.
     MOVE L-ABOVE TO L-VALID
     MOVE 1 TO L-SUCCESS
     MOVE 2 TO L-FLAGS
     GOBACK.
 END PROGRAM GC4-SEAGRASS-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-TALLSEA-SURVIVE.
*> USING half (0 lower, 1 upper), the state below is this block with half lower, mayPlaceOn, the fluid at pos is in tag water and full (BINARY-LONG), canSurvive out: 9.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HALF                 BINARY-LONG.
 01 L-BELOW-LOWER          BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-HALF L-BELOW-LOWER L-MAY L-WATER L-SURVIVE.
     MOVE 0 TO L-SURVIVE
     EVALUATE TRUE
         WHEN L-HALF = 1
             MOVE L-BELOW-LOWER TO L-SURVIVE
         WHEN L-MAY = 1 AND L-WATER = 1
             MOVE 1 TO L-SURVIVE
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-TALLSEA-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-TALLSEA-PLACE.
*> USING the DoublePlantBlock placement succeeds, the fluid at clickedPos.above() is in tag water and full (BINARY-LONG), placed out: 9.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DOUBLE               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-DOUBLE L-WATER L-PLACED.
     MOVE 0 TO L-PLACED
     IF L-DOUBLE = 1 AND L-WATER = 1
         MOVE 1 TO L-PLACED
     END-IF
     GOBACK.
 END PROGRAM GC4-TALLSEA-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-NOT-BONE.
*> USING block key (PIC X(48)), the block is not a bone meal target (BINARY-LONG out 1): the list of 9.4 (plain DoublePlantBlocks, tall seagrass, the flowers, sugar cane, cactus ...).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SECTION             BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-NOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-NOT.
     MOVE 0 TO L-NOT
     CALL "GC4-PART" USING L-KEY WS-SECTION
     IF WS-SECTION = 91 OR WS-SECTION = 93 OR WS-SECTION = 101 OR WS-SECTION = 102 OR WS-SECTION = 103 OR WS-SECTION = 40 OR WS-SECTION = 51
        OR WS-SECTION = 52 OR WS-SECTION = 70 OR WS-SECTION = 112 OR WS-SECTION = 131 OR WS-SECTION = 132 OR WS-SECTION = 134
        OR L-KEY = "minecraft:dead_bush"
         MOVE 1 TO L-NOT
     END-IF
     GOBACK.
 END PROGRAM GC4-NOT-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-GRASS-BONE.
*> USING the block is a fern (BINARY-LONG; else short_grass), the grown block's lower state can survive at pos, the cell above is air, it is inside the build height, valid, success,
*> the grown block (1 tall_grass, 2 large_fern), the placeAt flags out: TallGrassBlock bone meal (9.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FERN                 BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-GROWN                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-FERN L-SURVIVE L-AIR L-HEIGHT L-VALID L-SUCCESS L-GROWN L-FLAGS.
     MOVE 0 TO L-VALID
     MOVE 1 TO L-SUCCESS L-GROWN
     MOVE 2 TO L-FLAGS
     IF L-FERN = 1
         MOVE 2 TO L-GROWN
     END-IF
     IF L-SURVIVE = 1 AND L-AIR = 1 AND L-HEIGHT = 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC4-GRASS-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-TALLFLOWER-BONE.
*> USING valid, success, the block's item is popped, the plant grows (BINARY-LONG out): TallFlowerBlock bone meal (9.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-POP                  BINARY-LONG.
 01 L-GROWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALID L-SUCCESS L-POP L-GROWS.
     MOVE 1 TO L-VALID L-SUCCESS L-POP
     MOVE 0 TO L-GROWS
     GOBACK.
 END PROGRAM GC4-TALLFLOWER-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-STEW-TICKS.
*> USING the duration in seconds (FLOAT-LONG), the ticks out: the suspicious stew effect entry is floor(seconds x 20) (10.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MILLI               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SECONDS              FLOAT-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SECONDS L-TICKS.
*> The seconds are decimals of at most three places: 0.35 x 20 must give 7, not 6.99999 of the binary double, so the product is rounded to thousandths of a tick first.
     COMPUTE WS-MILLI ROUNDED = L-SECONDS * 20000
     DIVIDE WS-MILLI BY 1000 GIVING L-TICKS
     GOBACK.
 END PROGRAM GC4-STEW-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-FLOWER10-CONST.
*> USING shape width, y from, y to, ticks (0 none), bone meal (0 none), getBeeInteractionEffect (0 null) (BINARY-LONG out): FlowerBlock (10.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WIDTH                BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-BONE                 BINARY-LONG.
 01 L-BEE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WIDTH L-Y0 L-Y1 L-TICKS L-BONE L-BEE.
     MOVE 6 TO L-WIDTH
     MOVE 0 TO L-Y0 L-TICKS L-BONE L-BEE
     MOVE 10 TO L-Y1
     GOBACK.
 END PROGRAM GC4-FLOWER10-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-WITHER-HIT.
*> USING the level is a server, the difficulty (0 peaceful), the entity is a LivingEntity, it is invulnerable to wither damage (BINARY-LONG), the wither effect is applied, its ticks,
*> its amplifier out: WitherRoseBlock.entityInside (10.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-INVULNERABLE         BINARY-LONG.
 01 L-APPLIES              BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-AMPLIFIER            BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-DIFFICULTY L-LIVING L-INVULNERABLE L-APPLIES L-TICKS L-AMPLIFIER.
     MOVE 0 TO L-APPLIES L-AMPLIFIER
     MOVE 40 TO L-TICKS
     IF L-SERVER = 1 AND L-DIFFICULTY NOT = 0 AND L-LIVING = 1 AND L-INVULNERABLE = 0
         MOVE 1 TO L-APPLIES
     END-IF
     GOBACK.
 END PROGRAM GC4-WITHER-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-EYE-TYPE.
*> USING the type (1 OPEN, 2 CLOSED), open, effect (1 blindness, 2 nausea), its seconds, the particle colour, the transformed type (BINARY-LONG out): EyeblossomBlock.Type (10.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-OPEN L-EFFECT L-SECONDS L-COLOUR L-OTHER.
     IF L-TYPE = 1
         MOVE 1 TO L-OPEN L-EFFECT
         MOVE 11 TO L-SECONDS
         MOVE 16545810 TO L-COLOUR
         MOVE 2 TO L-OTHER
     ELSE
         MOVE 0 TO L-OPEN
         MOVE 2 TO L-EFFECT
         MOVE 7 TO L-SECONDS
         MOVE 6250335 TO L-COLOUR
         MOVE 1 TO L-OTHER
     END-IF
     GOBACK.
 END PROGRAM GC4-EYE-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-EYE-CHANGE.
*> USING the attribute gameplay/eyeblossom_open (0 false, 1 true, 2 the tri-state default), the type's open (BINARY-LONG), want, the state changes out: tryChangingState (10.3 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTRIBUTE            BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-WANT                 BINARY-LONG.
 01 L-CHANGES              BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTRIBUTE L-OPEN L-WANT L-CHANGES.
     MOVE L-ATTRIBUTE TO L-WANT
     IF L-ATTRIBUTE = 2
         MOVE L-OPEN TO L-WANT
     END-IF
     MOVE 0 TO L-CHANGES
     IF L-WANT NOT = L-OPEN
         MOVE 1 TO L-CHANGES
     END-IF
     GOBACK.
 END PROGRAM GC4-EYE-CHANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-EYE-DELAY.
*> USING distSqr, the draw of nextInt(high - low + 1) (BINARY-LONG), low (int)(dist x 5), high (int)(dist x 10), the delay out: nextIntBetweenInclusive for a neighbour (10.3 step 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIST                FLOAT-LONG.
 01 WS-FIVE                FLOAT-LONG.
 01 WS-TEN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DSQ                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DSQ L-DRAW L-LOW L-HIGH L-DELAY.
     COMPUTE WS-DIST = FUNCTION SQRT(L-DSQ)
     COMPUTE WS-FIVE = WS-DIST * 5
     COMPUTE WS-TEN = WS-DIST * 10
     COMPUTE L-LOW = FUNCTION INTEGER(WS-FIVE)
     COMPUTE L-HIGH = FUNCTION INTEGER(WS-TEN)
     COMPUTE L-DELAY = L-LOW + L-DRAW
     GOBACK.
 END PROGRAM GC4-EYE-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-EYE-SCAN.
*> USING the offset dx, dy, dz of a cell from the changed block (BINARY-LONG), the cell is a candidate out: the box of 10.3 step 1, the changed block itself excluded.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-CANDIDATE            BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-CANDIDATE.
     MOVE 0 TO L-CANDIDATE
     IF L-DX >= -3 AND L-DX <= 3 AND L-DY >= -2 AND L-DY <= 2 AND L-DZ >= -3 AND L-DZ <= 3 AND (L-DX NOT = 0 OR L-DY NOT = 0 OR L-DZ NOT = 0)
         MOVE 1 TO L-CANDIDATE
     END-IF
     GOBACK.
 END PROGRAM GC4-EYE-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-EYE-SOUND.
*> USING the trigger (1 random tick, 2 scheduled tick), the state changed (BINARY-LONG), the sound (0 none, 1 long switch sound, 2 short switch sound) out: 10.3 steps 2 and 3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRIGGER              BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGER L-CHANGED L-SOUND.
     MOVE 0 TO L-SOUND
     IF L-CHANGED = 1
         MOVE L-TRIGGER TO L-SOUND
     END-IF
     GOBACK.
 END PROGRAM GC4-EYE-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BEE-ATTRACTS.
*> USING block key (PIC X(48)), waterlogged (0 when the block has no such property), half (1 upper) (BINARY-LONG), attractsBees out: the block is in tag bee_attractive (the 29 members as
*> shipped, 10.3 step 5) and not waterlogged; sunflower only for its upper half.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MEMBER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-ATTRACTS             BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-WATERLOGGED L-HALF L-ATTRACTS.
     MOVE 0 TO WS-MEMBER L-ATTRACTS
     IF L-KEY = "minecraft:dandelion" OR L-KEY = "minecraft:open_eyeblossom" OR L-KEY = "minecraft:poppy" OR L-KEY = "minecraft:blue_orchid"
        OR L-KEY = "minecraft:allium" OR L-KEY = "minecraft:azure_bluet" OR L-KEY = "minecraft:red_tulip" OR L-KEY = "minecraft:orange_tulip"
        OR L-KEY = "minecraft:white_tulip" OR L-KEY = "minecraft:pink_tulip" OR L-KEY = "minecraft:oxeye_daisy" OR L-KEY = "minecraft:cornflower"
        OR L-KEY = "minecraft:lily_of_the_valley" OR L-KEY = "minecraft:wither_rose" OR L-KEY = "minecraft:torchflower" OR L-KEY = "minecraft:sunflower"
        OR L-KEY = "minecraft:lilac" OR L-KEY = "minecraft:peony" OR L-KEY = "minecraft:rose_bush" OR L-KEY = "minecraft:pitcher_plant"
        OR L-KEY = "minecraft:flowering_azalea_leaves" OR L-KEY = "minecraft:flowering_azalea" OR L-KEY = "minecraft:mangrove_propagule"
        OR L-KEY = "minecraft:cherry_leaves" OR L-KEY = "minecraft:pink_petals" OR L-KEY = "minecraft:wildflowers" OR L-KEY = "minecraft:chorus_flower"
        OR L-KEY = "minecraft:spore_blossom" OR L-KEY = "minecraft:cactus_flower"
         MOVE 1 TO WS-MEMBER
     END-IF
     IF WS-MEMBER = 1 AND L-WATERLOGGED = 0 AND (L-KEY NOT = "minecraft:sunflower" OR L-HALF = 1)
         MOVE 1 TO L-ATTRACTS
     END-IF
     GOBACK.
 END PROGRAM GC4-BEE-ATTRACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-EYE-INSIDE.
*> USING the level is a server, the difficulty (0 peaceful), the entity is a Bee, Bee.attractsBees of the state, the bee is already poisoned (BINARY-LONG), poison applied, its ticks,
*> its amplifier out: EyeblossomBlock.entityInside (10.3 step 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-BEE                  BINARY-LONG.
 01 L-ATTRACTS             BINARY-LONG.
 01 L-POISONED             BINARY-LONG.
 01 L-APPLIES              BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-AMPLIFIER            BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-DIFFICULTY L-BEE L-ATTRACTS L-POISONED L-APPLIES L-TICKS L-AMPLIFIER.
     MOVE 0 TO L-APPLIES L-AMPLIFIER
     MOVE 25 TO L-TICKS
     IF L-SERVER = 1 AND L-DIFFICULTY NOT = 0 AND L-BEE = 1 AND L-ATTRACTS = 1 AND L-POISONED = 0
         MOVE 1 TO L-APPLIES
     END-IF
     GOBACK.
 END PROGRAM GC4-EYE-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BED-PLACE.
*> USING the state at the clicked position is this block, its flower_amount, the placer's horizontal direction (3 north, 4 south, 5 west, 6 east) (BINARY-LONG), the new amount, the new
*> facing (-1 kept) out: SegmentableBlock.getStateForPlacement (10.4 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-PLACER               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-AMOUNT L-PLACER L-NEW L-FACING.
     MOVE -1 TO L-FACING
     MOVE 1 TO L-NEW
     IF L-SAME = 1
         COMPUTE L-NEW = FUNCTION MIN(4, L-AMOUNT + 1)
         GOBACK
     END-IF
     EVALUATE L-PLACER
         WHEN 3
             MOVE 4 TO L-FACING
         WHEN 4
             MOVE 3 TO L-FACING
         WHEN 5
             MOVE 6 TO L-FACING
         WHEN OTHER
             MOVE 5 TO L-FACING
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-BED-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SEG-REPLACE.
*> USING secondary use is active, the item in hand is this block's item, the amount (flower_amount or pickles), the default canBeReplaced (BINARY-LONG), canBeReplaced out:
*> true when not secondary use, the item matches and the amount is below 4 (10.4 step 2, 11.1 step 3); otherwise the default.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SECONDARY            BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SECONDARY L-ITEM L-AMOUNT L-DEFAULT L-RESULT.
     MOVE L-DEFAULT TO L-RESULT
     IF L-SECONDARY = 0 AND L-ITEM = 1 AND L-AMOUNT < 4
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC4-SEG-REPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BED-BONE.
*> USING flower_amount (BINARY-LONG), valid, success, the amount after (-1 for none), the flags, an item is dropped out: FlowerBedBlock bone meal (10.4 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AMOUNT               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AMOUNT L-VALID L-SUCCESS L-AFTER L-FLAGS L-DROP.
     MOVE 1 TO L-VALID L-SUCCESS
     MOVE 2 TO L-FLAGS
     IF L-AMOUNT < 4
         COMPUTE L-AFTER = L-AMOUNT + 1
         MOVE 0 TO L-DROP
     ELSE
         MOVE -1 TO L-AFTER
         MOVE 1 TO L-DROP
     END-IF
     GOBACK.
 END PROGRAM GC4-BED-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-BED-CONST.
*> USING the default facing (3 north), default flower_amount, its maximum, the shape height (BINARY-LONG out): FlowerBedBlock (10.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-AMOUNT L-MAX L-HEIGHT.
     MOVE 3 TO L-FACING L-HEIGHT
     MOVE 1 TO L-AMOUNT
     MOVE 4 TO L-MAX
     GOBACK.
 END PROGRAM GC4-BED-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRY-SHAPE.
*> USING kind (1 dead_bush, 2 short_dry_grass, 3 tall_dry_grass), shape width, y from, y to, offset (0 none, 2 XYZ) (BINARY-LONG out): 10.6.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-WIDTH L-Y0 L-Y1 L-OFFSET.
     MOVE 0 TO L-Y0
     EVALUATE L-KIND
         WHEN 1
             MOVE 12 TO L-WIDTH
             MOVE 13 TO L-Y1
             MOVE 0 TO L-OFFSET
         WHEN 2
             MOVE 12 TO L-WIDTH
             MOVE 10 TO L-Y1
             MOVE 2 TO L-OFFSET
         WHEN OTHER
             MOVE 14 TO L-WIDTH
             MOVE 16 TO L-Y1
             MOVE 2 TO L-OFFSET
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-DRY-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRY-BONE.
*> USING kind (1 dead_bush, 2 short_dry_grass, 3 tall_dry_grass), a horizontal neighbour can take short_dry_grass (BINARY-LONG), valid, success, effect (0 none, 1 grows in place into
*> tall_dry_grass, 2 spreads short_dry_grass to a neighbour), the flags out: bone meal of the dry vegetation (10.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SPREAD               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SPREAD L-VALID L-SUCCESS L-EFFECT L-FLAGS.
     MOVE 0 TO L-VALID L-SUCCESS L-EFFECT L-FLAGS
     EVALUATE TRUE
         WHEN L-KIND = 2
             MOVE 1 TO L-VALID L-SUCCESS L-EFFECT
             MOVE 3 TO L-FLAGS
         WHEN L-KIND = 3 AND L-SPREAD = 1
             MOVE 1 TO L-VALID L-SUCCESS
             MOVE 2 TO L-EFFECT
             MOVE 3 TO L-FLAGS
         WHEN L-KIND = 3
             MOVE 1 TO L-SUCCESS
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-DRY-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PICKLE-LIGHT.
*> USING pickles, waterlogged (BINARY-LONG), the light level out: 0 when dead (not waterlogged), else 3 + 3 x pickles (11.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PICKLES              BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-PICKLES L-WATERLOGGED L-LIGHT.
     MOVE 0 TO L-LIGHT
     IF L-WATERLOGGED = 1
         COMPUTE L-LIGHT = 3 + 3 * L-PICKLES
     END-IF
     GOBACK.
 END PROGRAM GC4-PICKLE-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PICKLE-SHAPE.
*> USING pickles (BINARY-LONG), the shape width and height out: column(4, 0, 6), (10, 0, 6), (12, 0, 6), (12, 0, 7) (11.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PICKLES              BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-PICKLES L-WIDTH L-HEIGHT.
     MOVE 6 TO L-HEIGHT
     EVALUATE L-PICKLES
         WHEN 1
             MOVE 4 TO L-WIDTH
         WHEN 2
             MOVE 10 TO L-WIDTH
         WHEN 3
             MOVE 12 TO L-WIDTH
         WHEN OTHER
             MOVE 12 TO L-WIDTH
             MOVE 7 TO L-HEIGHT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-PICKLE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PICKLE-PLACEON.
*> USING the block below has a non-empty collision face toward UP, its top face is sturdy (BINARY-LONG), mayPlaceOn out (replaces the vegetation tag rule): 11.1 step 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COLLISION            BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-COLLISION L-STURDY L-OK.
     MOVE 0 TO L-OK
     IF L-COLLISION = 1 OR L-STURDY = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM GC4-PICKLE-PLACEON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PICKLE-PLACE.
*> USING the state at the clicked position is this block, its pickles, the fluid there is a water source (BINARY-LONG), the new pickles, waterlogged (-1 kept) out: 11.1 step 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-PICKLES              BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-PICKLES L-SOURCE L-NEW L-WATERLOGGED.
     IF L-SAME = 1
         COMPUTE L-NEW = FUNCTION MIN(4, L-PICKLES + 1)
         MOVE -1 TO L-WATERLOGGED
     ELSE
         MOVE 1 TO L-NEW
         MOVE L-SOURCE TO L-WATERLOGGED
     END-IF
     GOBACK.
 END PROGRAM GC4-PICKLE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PICKLE-SU.
*> USING canSurvive, waterlogged (BINARY-LONG), the result is air, a water tick is scheduled out: the shape update of 11.1 step 4 (air first, no tick for the removed block).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVE              BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVE L-WATERLOGGED L-AIR L-WATER.
     MOVE 0 TO L-AIR L-WATER
     IF L-SURVIVE = 0
         MOVE 1 TO L-AIR
     ELSE
         MOVE L-WATERLOGGED TO L-WATER
     END-IF
     GOBACK.
 END PROGRAM GC4-PICKLE-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PICKLE-BONE-VALID.
*> USING waterlogged (the pickle is not dead), the block below is in coral_blocks (BINARY-LONG), valid, success out: 11.1 step 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-CORAL                BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-CORAL L-VALID L-SUCCESS.
     MOVE 0 TO L-VALID
     MOVE 1 TO L-SUCCESS
     IF L-WATERLOGGED = 1 AND L-CORAL = 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC4-PICKLE-BONE-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PICKLE-CELL.
*> USING the cell number 1 to 26 (BINARY-LONG), dx, dz, dy (BINARY-LONG out): the cells of the sea pickle patch scan (11.1 step 5): 13 columns, x ascending then z ascending, the lower
*> height (y - 1) before the upper (y).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLUMN              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SIZES.
    05 WS-SIZE             BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-CELL                 BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CELL L-DX L-DZ L-DY.
     MOVE 1 TO WS-SIZE(1) WS-SIZE(5)
     MOVE 3 TO WS-SIZE(2) WS-SIZE(4)
     MOVE 5 TO WS-SIZE(3)
     COMPUTE WS-COLUMN = (L-CELL - 1) / 2
     COMPUTE L-DY = -1 + FUNCTION MOD(L-CELL - 1, 2)
     PERFORM VARYING L-DX FROM -2 BY 1 UNTIL WS-COLUMN < WS-SIZE(L-DX + 3)
         SUBTRACT WS-SIZE(L-DX + 3) FROM WS-COLUMN
     END-PERFORM
     COMPUTE WS-ROW = WS-COLUMN
     COMPUTE L-DZ = WS-ROW - (WS-SIZE(L-DX + 3) - 1) / 2
     GOBACK.
 END PROGRAM GC4-PICKLE-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PICKLE-STEP.
*> USING the cell is the clicked pickle, the nextInt(6) draw, the state at the cell is block water, the block below it is in coral_blocks, the nextInt(4) draw (BINARY-LONG), a nextInt(6)
*> draw was made, a pickle was placed, its pickles out: one cell of the patch scan (11.1 step 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POS                  BINARY-LONG.
 01 L-DRAW6                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-CORAL                BINARY-LONG.
 01 L-DRAW4                BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 01 L-PICKLES              BINARY-LONG.
 PROCEDURE DIVISION USING L-POS L-DRAW6 L-WATER L-CORAL L-DRAW4 L-DREW L-PLACED L-PICKLES.
     MOVE 0 TO L-DREW L-PLACED L-PICKLES
     IF L-POS = 1
         GOBACK
     END-IF
     MOVE 1 TO L-DREW
     IF L-DRAW6 = 0 AND L-WATER = 1 AND L-CORAL = 1
         MOVE 1 TO L-PLACED
         COMPUTE L-PICKLES = L-DRAW4 + 1
     END-IF
     GOBACK.
 END PROGRAM GC4-PICKLE-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-PICKLE-CONST.
*> USING the cells scanned, the cells that draw nextInt(6), the pickles of the clicked block after, its flags (BINARY-LONG out): the totals of 11.1 step 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CELLS                BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 01 L-PICKLES              BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-CELLS L-DRAWS L-PICKLES L-FLAGS.
     COMPUTE L-CELLS = 13 * 2
     COMPUTE L-DRAWS = L-CELLS - 1
     MOVE 4 TO L-PICKLES
     MOVE 2 TO L-FLAGS
     GOBACK.
 END PROGRAM GC4-PICKLE-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-LILY-PLACE.
*> USING the fluid below is in fluid tag supports_lily_pad, the block below is in block tag supports_lily_pad, the fluid at its own position is empty (BINARY-LONG), mayPlaceOn out: 11.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-BLOCK L-EMPTY L-OK.
     MOVE 0 TO L-OK
     IF (L-FLUID = 1 OR L-BLOCK = 1) AND L-EMPTY = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM GC4-LILY-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-LILY-BOAT.
*> USING the level is a server, the entity is an AbstractBoat (BINARY-LONG), destroyBlock, with drops out: LilyPadBlock.entityInside (11.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-BOAT                 BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-BOAT L-DESTROY L-DROPS.
     MOVE 0 TO L-DESTROY L-DROPS
     IF L-SERVER = 1 AND L-BOAT = 1
         MOVE 1 TO L-DESTROY L-DROPS
     END-IF
     GOBACK.
 END PROGRAM GC4-LILY-BOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-LILY-SHAPE.
*> USING the shape width, y from and y to x 10 (BINARY-LONG out): column(14, 0, 1.5) (11.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WIDTH                BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WIDTH L-Y0 L-Y1.
     MOVE 14 TO L-WIDTH
     MOVE 0 TO L-Y0
     MOVE 15 TO L-Y1
     GOBACK.
 END PROGRAM GC4-LILY-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-TILT.
*> USING tilt (0 none, 1 unstable, 2 partial, 3 full), causesVibration, the delay until the next tilt step (-1 none), the collision shape's y from and y to (0 0 for the empty shape)
*> (BINARY-LONG out): the Tilt enum and the leaf collision shapes (12.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TILT                 BINARY-LONG.
 01 L-VIBRATION            BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TILT L-VIBRATION L-DELAY L-Y0 L-Y1.
     MOVE 1 TO L-VIBRATION
     MOVE 11 TO L-Y0
     MOVE 15 TO L-Y1
     EVALUATE L-TILT
         WHEN 0
             MOVE -1 TO L-DELAY
         WHEN 1
             MOVE 0 TO L-VIBRATION
             MOVE 10 TO L-DELAY
         WHEN 2
             MOVE 10 TO L-DELAY
             MOVE 13 TO L-Y1
         WHEN OTHER
             MOVE 100 TO L-DELAY
             MOVE 0 TO L-Y0 L-Y1
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-DRIP-TILT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-CONST.
*> USING NO_TICK, MAX_GEN_HEIGHT, the stem box width, the leaf box width (BINARY-LONG out): BigDripleafBlock (12.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NO-TICK              BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-STEM                 BINARY-LONG.
 01 L-LEAF                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NO-TICK L-MAX L-STEM L-LEAF.
     MOVE -1 TO L-NO-TICK
     MOVE 5 TO L-MAX
     MOVE 6 TO L-STEM
     MOVE 16 TO L-LEAF
     GOBACK.
 END PROGRAM GC4-DRIP-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-SURVIVE.
*> USING the state below is big_dripleaf or big_dripleaf_stem, it is in supports_big_dripleaf (BINARY-LONG), canSurvive out: 12.1 step 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-FAMILY L-TAG L-SURVIVE.
     MOVE 0 TO L-SURVIVE
     IF L-FAMILY = 1 OR L-TAG = 1
         MOVE 1 TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM GC4-DRIP-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-PLACE.
*> USING the state below is big_dripleaf or big_dripleaf_stem, its facing, the placer's horizontal direction (3 north, 4 south, 5 west, 6 east), the clicked fluid is a water source
*> (BINARY-LONG), facing, waterlogged out: getStateForPlacement (12.1 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-FACING-BELOW         BINARY-LONG.
 01 L-PLACER               BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 PROCEDURE DIVISION USING L-FAMILY L-FACING-BELOW L-PLACER L-SOURCE L-FACING L-WATERLOGGED.
     MOVE L-SOURCE TO L-WATERLOGGED
     IF L-FAMILY = 1
         MOVE L-FACING-BELOW TO L-FACING
         GOBACK
     END-IF
     EVALUATE L-PLACER
         WHEN 3
             MOVE 4 TO L-FACING
         WHEN 4
             MOVE 3 TO L-FACING
         WHEN 5
             MOVE 6 TO L-FACING
         WHEN OTHER
             MOVE 5 TO L-FACING
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-DRIP-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-SU.
*> USING the changed direction (1 down, 2 up, 3 other), canSurvive, waterlogged, the neighbour is big_dripleaf (BINARY-LONG), result (0 unchanged, 1 air, 2 a big_dripleaf_stem with the same
*> properties), a water tick out: BigDripleafBlock.updateShape (12.1 step 3); air is returned before anything else.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-HEAD                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-SURVIVE L-WATERLOGGED L-HEAD L-RESULT L-WATER.
     MOVE 0 TO L-RESULT L-WATER
     IF L-DIR = 1 AND L-SURVIVE = 0
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     MOVE L-WATERLOGGED TO L-WATER
     IF L-DIR = 2 AND L-HEAD = 1
         MOVE 2 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC4-DRIP-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-CANGROW.
*> USING the position is inside the build height, the state there (1 air, 2 block water, 3 small_dripleaf, 0 other) (BINARY-LONG), canGrowInto and canPlaceAt out: 12.1 step 4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HEIGHT               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HEIGHT L-KIND L-CAN.
     MOVE 0 TO L-CAN
     IF L-HEIGHT = 1 AND L-KIND >= 1 AND L-KIND <= 3
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM GC4-DRIP-CANGROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-WRITE.
*> USING the fluid is a water source (BINARY-LONG), waterlogged, the setBlockAndUpdate flags out: place of the head and of the stem (12.1 step 5, 12.2 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-WATERLOGGED L-FLAGS.
     MOVE L-SOURCE TO L-WATERLOGGED
     MOVE 3 TO L-FLAGS
     GOBACK.
 END PROGRAM GC4-DRIP-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-BONE.
*> USING canGrowInto(above), canPlaceAt(above) (BINARY-LONG), valid, success, the effect (this block a stem and a new head above) happens out: 12.1 step 6.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-PLACE L-VALID L-SUCCESS L-EFFECT.
     MOVE L-CAN TO L-VALID
     MOVE 1 TO L-SUCCESS
     MOVE 0 TO L-EFFECT
     IF L-CAN = 1 AND L-PLACE = 1
         MOVE 1 TO L-EFFECT
     END-IF
     GOBACK.
 END PROGRAM GC4-DRIP-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-INSIDE.
*> USING the level is a client, the tilt, the entity is on the ground (BINARY-LONG), the entity's y (FLOAT-LONG), the leaf's y (BINARY-LONG), the cell has a neighbour signal (BINARY-LONG),
*> the tilt after (-1 unchanged), the delay of the scheduled tick (-1 none), the sound (0 none) out: entityInside (12.1 step 7.1): tilt none, on the ground, y above pos.y + 0.6875,
*> no signal sets unstable and schedules a tick in 10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CLIENT               BINARY-LONG.
 01 L-TILT                 BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-POS-Y                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-CLIENT L-TILT L-GROUND L-Y L-POS-Y L-SIGNAL L-AFTER L-DELAY L-SOUND.
     MOVE -1 TO L-AFTER L-DELAY
     MOVE 0 TO L-SOUND
     COMPUTE WS-LIMIT = L-POS-Y + 0.6875
     IF L-CLIENT = 0 AND L-TILT = 0 AND L-GROUND = 1 AND L-Y > WS-LIMIT AND L-SIGNAL = 0
         MOVE 1 TO L-AFTER
         MOVE 10 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM GC4-DRIP-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-SETTILT.
*> USING the old tilt, the new tilt (0 none, 1 unstable, 2 partial, 3 full) (BINARY-LONG), the game event BLOCK_CHANGE is sent out: setTilt (12.1 step 7.3), when the new tilt causes
*> vibration (every tilt but unstable) and differs from the old one.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-OLD L-NEW L-EVENT.
     MOVE 0 TO L-EVENT
     IF L-NEW NOT = 1 AND L-NEW NOT = L-OLD
         MOVE 1 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM GC4-DRIP-SETTILT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-RESET.
*> USING the given state's tilt (BINARY-LONG), the tilt after (0), the tilt-up sound is played out: resetTilt (12.1 step 7.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TILT                 BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-TILT L-AFTER L-SOUND.
     MOVE 0 TO L-AFTER L-SOUND
     IF L-TILT NOT = 0
         MOVE 1 TO L-SOUND
     END-IF
     GOBACK.
 END PROGRAM GC4-DRIP-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-TICK.
*> USING the cell has a neighbour signal, the tilt (BINARY-LONG), the tilt after, the sound (0 none, 1 tilt down, 2 tilt up), the delay of the next tick (-1 none) out: tick (12.1 step 7.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-UP                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-TILT                 BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-TILT L-AFTER L-SOUND L-DELAY.
     MOVE -1 TO L-DELAY
     MOVE 0 TO L-AFTER L-SOUND
     CALL "GC4-DRIP-RESET" USING L-TILT L-AFTER WS-UP
     IF L-SIGNAL = 1 OR L-TILT = 3
         IF WS-UP = 1
             MOVE 2 TO L-SOUND
         END-IF
         GOBACK
     END-IF
     EVALUATE L-TILT
         WHEN 1
             MOVE 2 TO L-AFTER
             MOVE 1 TO L-SOUND
             MOVE 10 TO L-DELAY
         WHEN 2
             MOVE 3 TO L-AFTER
             MOVE 1 TO L-SOUND
             MOVE 100 TO L-DELAY
     END-EVALUATE
     GOBACK.
 END PROGRAM GC4-DRIP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-NEIGHBOUR.
*> USING the cell receives a redstone signal, the tilt (BINARY-LONG), the tilt after (-1 for no change), the sound out: the neighbour change of 12.1 step 7.7 resets the tilt.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-UP                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-TILT                 BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-TILT L-AFTER L-SOUND.
     MOVE -1 TO L-AFTER
     MOVE 0 TO L-SOUND
     IF L-SIGNAL = 1
         CALL "GC4-DRIP-RESET" USING L-TILT L-AFTER L-SOUND
     END-IF
     GOBACK.
 END PROGRAM GC4-DRIP-NEIGHBOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-PROJECTILE.
*> USING the tilt, the tilt-down sound (1), the delay of the reset tick out: onProjectileHit (12.1 step 7.8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TILT                 BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-TILT L-SOUND L-DELAY.
     MOVE 3 TO L-TILT
     MOVE 1 TO L-SOUND
     MOVE 100 TO L-DELAY
     GOBACK.
 END PROGRAM GC4-DRIP-PROJECTILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-STEM-SURVIVE.
*> USING the state below is a stem or in supports_big_dripleaf, the state above is a stem or a head (BINARY-LONG), canSurvive out: 12.2 step 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BELOW                BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-BELOW L-ABOVE L-SURVIVE.
     MOVE 0 TO L-SURVIVE
     IF L-BELOW = 1 AND L-ABOVE = 1
         MOVE 1 TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM GC4-STEM-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-STEM-SU.
*> USING the changed direction (1 down, 2 up, 3 other), canSurvive, waterlogged (BINARY-LONG), a block tick scheduled, a water tick scheduled out: 12.2 step 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-SURVIVE L-WATERLOGGED L-TICK L-WATER.
     MOVE 0 TO L-TICK
     MOVE L-WATERLOGGED TO L-WATER
     IF (L-DIR = 1 OR L-DIR = 2) AND L-SURVIVE = 0
         MOVE 1 TO L-TICK
     END-IF
     GOBACK.
 END PROGRAM GC4-STEM-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-STEM-FIND.
*> USING the stems from pos upward including pos, the cell above them is a big_dripleaf (BINARY-LONG), the head was found, its offset from pos out: 12.2 step 4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RUN                  BINARY-LONG.
 01 L-HEAD                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-RUN L-HEAD L-FOUND L-OFFSET.
     MOVE L-HEAD TO L-FOUND
     MOVE L-RUN TO L-OFFSET
     GOBACK.
 END PROGRAM GC4-STEM-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-STEM-BONE.
*> USING the head was found, canPlaceAt(top.above()) (BINARY-LONG), valid, success out: 12.2 step 4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FOUND                BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-FOUND L-PLACE L-VALID L-SUCCESS.
     MOVE 0 TO L-VALID
     MOVE 1 TO L-SUCCESS
     IF L-FOUND = 1 AND L-PLACE = 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC4-STEM-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-DRIP-HEIGHT.
*> USING the nextInt(4) draw (n = Mth.nextInt(2, 5)), the consecutive cells from pos upward that canPlaceAt (BINARY-LONG), n, the cells used, the stems, the head's offset from pos out:
*> placeWithRandomHeight (12.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 01 L-STEMS                BINARY-LONG.
 01 L-HEAD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-FREE L-N L-USED L-STEMS L-HEAD.
     COMPUTE L-N = 2 + L-DRAW
     MOVE L-N TO L-USED
     IF L-FREE < L-N
         MOVE L-FREE TO L-USED
     END-IF
     MOVE 0 TO L-STEMS
     IF L-USED > 0
         COMPUTE L-STEMS = L-USED - 1
     END-IF
     MOVE L-STEMS TO L-HEAD
     GOBACK.
 END PROGRAM GC4-DRIP-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SMALL-PLACEON.
*> USING the supporting state is in supports_small_dripleaf, the fluid in the lower half's own cell is a water source, the supporting state is in supports_vegetation (BINARY-LONG),
*> mayPlaceOn out: SmallDripleafBlock (12.4 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-VEGETATION           BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-WATER L-VEGETATION L-OK.
     MOVE 0 TO L-OK
     IF L-TAG = 1 OR (L-WATER = 1 AND L-VEGETATION = 1)
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM GC4-SMALL-PLACEON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SMALL-PLACED.
*> USING the level is a server (BINARY-LONG), the upper half is placed above out: setPlacedBy (12.4 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-PLACED.
     MOVE L-SERVER TO L-PLACED
     GOBACK.
 END PROGRAM GC4-SMALL-PLACED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SMALL-SU.
*> USING waterlogged (BINARY-LONG), a water tick is scheduled out: the shape update of 12.4 step 5 (then the DoublePlantBlock update, GC4-DOUBLE-SU).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-WATER.
     MOVE L-WATERLOGGED TO L-WATER
     GOBACK.
 END PROGRAM GC4-SMALL-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SMALL-BONE.
*> USING half (0 lower, 1 upper), the fluid above the lower half is water (BINARY-LONG), valid, success, the y offset of the acting position, the replacement of the upper cell (1 water,
*> 0 air), its flags out: small dripleaf bone meal (12.4 step 6); the upper half acts on the lower half's position.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HALF                 BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-REPLACEMENT          BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-HALF L-WATER L-VALID L-SUCCESS L-OFFSET L-REPLACEMENT L-FLAGS.
     MOVE 1 TO L-VALID L-SUCCESS
     COMPUTE L-OFFSET = 0 - L-HALF
     MOVE L-WATER TO L-REPLACEMENT
     COMPUTE L-FLAGS = 2 + 16
     GOBACK.
 END PROGRAM GC4-SMALL-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC4-SMALL-CONST.
*> USING the shape width, y from, y to, the maximum vertical offset x 1000 (BINARY-LONG out): SmallDripleafBlock (12.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WIDTH                BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-WIDTH L-Y0 L-Y1 L-OFFSET.
     MOVE 12 TO L-WIDTH
     MOVE 0 TO L-Y0
     MOVE 13 TO L-Y1
     MOVE 100 TO L-OFFSET
     GOBACK.
 END PROGRAM GC4-SMALL-CONST.
