*> Block support: what a block needs next to it to stay (lane bugsw T10305; docs/protocol/29 sections 3.2 (updateShape) and 9.5, the survive rules of docs/protocol/24 part 2 and 4). A
*> block with a support rule (SUPSTATE.cpy) whose neighbour changed is checked by BU-HOOK kind 4 (SUP-SHAPE): when the rule fails the new state is air, and the update engine destroys the block
*> with its drops (LEVEL-DESTROY-BLOCK, which puts water back where a water plant stood). BLOCK-PLACE asks the same rule (SUP-PLACE-OK) before it places a block.
*>
*> Entry points:
*>   SUP-OPEN: builds the rule table for the block table epoch (called by SUP-RULE-OF)
*>   SUP-SURVIVES USING dimension row, x, y, z, state, ok out: the rule of the block of the state at the cell, read from the level (1 when the block has no rule)
*>   SUP-SHAPE USING dimension row, x, y, z, state, new state in and out: the state is replaced by air (0) when it cannot survive
*>   SUP-DESTROY-STATE USING old state, new state out: the state a destroyed block leaves: water for a water plant or a waterlogged block, else air
*>   SUP-PLACE-OK USING dimension row, x, y, z, state, ok out: BlockItem.canPlace for the cell: the survive rule, and a water plant only in a water source

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUP-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CONTENT.
 COPY SUPSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FULL                PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:block".
 01 WS-CAP                 BINARY-LONG VALUE 2048.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 2048 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
*> tag, then rule (negative: the tag's members get that rule as a positive number when they have none) or support bit (positive)
 01 WS-TAGS.
    05 FILLER PIC X(48) VALUE "minecraft:small_flowers".
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER PIC X(48) VALUE "minecraft:saplings".
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER PIC X(48) VALUE "minecraft:wool_carpets".
    05 FILLER BINARY-LONG VALUE -14.
    05 FILLER PIC X(48) VALUE "minecraft:pressure_plates".
    05 FILLER BINARY-LONG VALUE -14.
    05 FILLER PIC X(48) VALUE "minecraft:rails".
    05 FILLER BINARY-LONG VALUE -14.
    05 FILLER PIC X(48) VALUE "minecraft:standing_signs".
    05 FILLER BINARY-LONG VALUE -14.
    05 FILLER PIC X(48) VALUE "minecraft:wall_signs".
    05 FILLER BINARY-LONG VALUE -15.
    05 FILLER PIC X(48) VALUE "minecraft:buttons".
    05 FILLER BINARY-LONG VALUE -16.
    05 FILLER PIC X(48) VALUE "minecraft:doors".
    05 FILLER BINARY-LONG VALUE -17.
    05 FILLER PIC X(48) VALUE "minecraft:supports_vegetation".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER PIC X(48) VALUE "minecraft:supports_dry_vegetation".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(48) VALUE "minecraft:overrides_mushroom_light_requirement".
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER PIC X(48) VALUE "minecraft:supports_lily_pad".
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER PIC X(48) VALUE "minecraft:cannot_support_seagrass".
    05 FILLER BINARY-LONG VALUE 16.
    05 FILLER PIC X(48) VALUE "minecraft:cannot_support_snow_layer".
    05 FILLER BINARY-LONG VALUE 32.
    05 FILLER PIC X(48) VALUE "minecraft:support_override_snow_layer".
    05 FILLER BINARY-LONG VALUE 64.
    05 FILLER PIC X(48) VALUE "minecraft:supports_sugar_cane".
    05 FILLER BINARY-LONG VALUE 128.
    05 FILLER PIC X(48) VALUE "minecraft:supports_sugar_cane_adjacently".
    05 FILLER BINARY-LONG VALUE 256.
    05 FILLER PIC X(48) VALUE "minecraft:supports_cactus".
    05 FILLER BINARY-LONG VALUE 512.
    05 FILLER PIC X(48) VALUE "minecraft:cannot_support_kelp".
    05 FILLER BINARY-LONG VALUE 1024.
    05 FILLER PIC X(48) VALUE "minecraft:supports_bamboo".
    05 FILLER BINARY-LONG VALUE 2048.
    05 FILLER PIC X(48) VALUE "minecraft:fences".
    05 FILLER BINARY-LONG VALUE 4096.
    05 FILLER PIC X(48) VALUE "minecraft:walls".
    05 FILLER BINARY-LONG VALUE 4096.
*>   The ground tags of 29b part 2 section 2.2 and 12 (lane bugcrop): crops on farmland, stems, nether wart on soul sand, cocoa on a jungle log, azalea, mangrove propagule, wither rose, nether roots and sprouts.
    05 FILLER PIC X(48) VALUE "minecraft:supports_crops".
    05 FILLER BINARY-LONG VALUE 8192.
    05 FILLER PIC X(48) VALUE "minecraft:supports_pumpkin_stem".
    05 FILLER BINARY-LONG VALUE 16384.
    05 FILLER PIC X(48) VALUE "minecraft:supports_melon_stem".
    05 FILLER BINARY-LONG VALUE 32768.
    05 FILLER PIC X(48) VALUE "minecraft:supports_nether_wart".
    05 FILLER BINARY-LONG VALUE 65536.
    05 FILLER PIC X(48) VALUE "minecraft:supports_cocoa".
    05 FILLER BINARY-LONG VALUE 131072.
    05 FILLER PIC X(48) VALUE "minecraft:supports_azalea".
    05 FILLER BINARY-LONG VALUE 262144.
    05 FILLER PIC X(48) VALUE "minecraft:supports_mangrove_propagule".
    05 FILLER BINARY-LONG VALUE 524288.
    05 FILLER PIC X(48) VALUE "minecraft:supports_hanging_mangrove_propagule".
    05 FILLER BINARY-LONG VALUE 1048576.
    05 FILLER PIC X(48) VALUE "minecraft:supports_wither_rose".
    05 FILLER BINARY-LONG VALUE 2097152.
    05 FILLER PIC X(48) VALUE "minecraft:supports_crimson_roots".
    05 FILLER BINARY-LONG VALUE 4194304.
    05 FILLER PIC X(48) VALUE "minecraft:supports_warped_roots".
    05 FILLER BINARY-LONG VALUE 8388608.
    05 FILLER PIC X(48) VALUE "minecraft:supports_nether_sprouts".
    05 FILLER BINARY-LONG VALUE 16777216.
 01 WS-TAG-TABLE REDEFINES WS-TAGS.
    05 WS-TAG-ROW OCCURS 35 TIMES.
       10 WS-TAG-KEY         PIC X(48).
       10 WS-TAG-KIND        BINARY-LONG.
 PROCEDURE DIVISION.
     IF SP-EPOCH = CB-EPOCH + 1
         GOBACK
     END-IF
     MOVE 0 TO SP-WATER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         MOVE 0 TO SP-RULE(WS-I) SP-ARG(WS-I) SP-SUP(WS-I)
         CALL "KEY-NAMESPACED" USING CB-KEY(WS-I) WS-FULL
         COMPUTE WS-N = FUNCTION LENGTH(FUNCTION TRIM(WS-FULL))
         EVALUATE FUNCTION TRIM(WS-FULL)
             WHEN "minecraft:water"
                 MOVE WS-I TO SP-WATER
             WHEN "minecraft:short_grass"
             WHEN "minecraft:fern"
             WHEN "minecraft:bush"
             WHEN "minecraft:sweet_berry_bush"
             WHEN "minecraft:pink_petals"
             WHEN "minecraft:wildflowers"
                 MOVE 1 TO SP-RULE(WS-I)
             WHEN "minecraft:dead_bush"
             WHEN "minecraft:short_dry_grass"
             WHEN "minecraft:tall_dry_grass"
                 MOVE 2 TO SP-RULE(WS-I)
             WHEN "minecraft:tall_grass"
             WHEN "minecraft:large_fern"
             WHEN "minecraft:sunflower"
             WHEN "minecraft:lilac"
             WHEN "minecraft:rose_bush"
             WHEN "minecraft:peony"
                 MOVE 13 TO SP-RULE(WS-I)
                 MOVE 1 TO SP-ARG(WS-I)
*>           A crop stands on a block of supports_crops in light 8 or more; the pitcher crop is a double plant with the crop rule on its lower half.
             WHEN "minecraft:wheat"
             WHEN "minecraft:carrots"
             WHEN "minecraft:potatoes"
             WHEN "minecraft:beetroots"
             WHEN "minecraft:torchflower_crop"
                 MOVE 22 TO SP-RULE(WS-I)
             WHEN "minecraft:pitcher_crop"
                 MOVE 13 TO SP-RULE(WS-I)
                 MOVE 22 TO SP-ARG(WS-I)
*>           A block that stands on the blocks of one tag (the tag's bit is its SP-ARG): stems, nether wart, azalea, wither rose, nether roots and sprouts.
             WHEN "minecraft:pumpkin_stem"
             WHEN "minecraft:attached_pumpkin_stem"
                 MOVE 21 TO SP-RULE(WS-I)
                 MOVE 16384 TO SP-ARG(WS-I)
             WHEN "minecraft:melon_stem"
             WHEN "minecraft:attached_melon_stem"
                 MOVE 21 TO SP-RULE(WS-I)
                 MOVE 32768 TO SP-ARG(WS-I)
             WHEN "minecraft:nether_wart"
                 MOVE 21 TO SP-RULE(WS-I)
                 MOVE 65536 TO SP-ARG(WS-I)
             WHEN "minecraft:azalea"
             WHEN "minecraft:flowering_azalea"
                 MOVE 21 TO SP-RULE(WS-I)
                 MOVE 262144 TO SP-ARG(WS-I)
             WHEN "minecraft:wither_rose"
                 MOVE 21 TO SP-RULE(WS-I)
                 MOVE 2097152 TO SP-ARG(WS-I)
             WHEN "minecraft:crimson_roots"
                 MOVE 21 TO SP-RULE(WS-I)
                 MOVE 4194304 TO SP-ARG(WS-I)
             WHEN "minecraft:warped_roots"
                 MOVE 21 TO SP-RULE(WS-I)
                 MOVE 8388608 TO SP-ARG(WS-I)
             WHEN "minecraft:nether_sprouts"
                 MOVE 21 TO SP-RULE(WS-I)
                 MOVE 16777216 TO SP-ARG(WS-I)
*>           Cocoa hangs on the block its facing points to (supports_cocoa); the mangrove propagule stands on supports_mangrove_propagule, hanging from supports_hanging_mangrove_propagule.
             WHEN "minecraft:cocoa"
                 MOVE 23 TO SP-RULE(WS-I)
             WHEN "minecraft:mangrove_propagule"
                 MOVE 24 TO SP-RULE(WS-I)
             WHEN "minecraft:brown_mushroom"
             WHEN "minecraft:red_mushroom"
                 MOVE 3 TO SP-RULE(WS-I)
             WHEN "minecraft:lily_pad"
                 MOVE 4 TO SP-RULE(WS-I)
             WHEN "minecraft:seagrass"
                 MOVE 5 TO SP-RULE(WS-I)
             WHEN "minecraft:sea_pickle"
                 MOVE 6 TO SP-RULE(WS-I)
             WHEN "minecraft:tall_seagrass"
                 MOVE 7 TO SP-RULE(WS-I)
                 MOVE 5 TO SP-ARG(WS-I)
             WHEN "minecraft:snow"
                 MOVE 8 TO SP-RULE(WS-I)
             WHEN "minecraft:sugar_cane"
                 MOVE 9 TO SP-RULE(WS-I)
             WHEN "minecraft:cactus"
                 MOVE 10 TO SP-RULE(WS-I)
             WHEN "minecraft:kelp"
             WHEN "minecraft:kelp_plant"
                 MOVE 11 TO SP-RULE(WS-I)
             WHEN "minecraft:bamboo"
             WHEN "minecraft:bamboo_sapling"
                 MOVE 12 TO SP-RULE(WS-I)
             WHEN "minecraft:torch"
             WHEN "minecraft:soul_torch"
             WHEN "minecraft:redstone_torch"
             WHEN "minecraft:copper_torch"
             WHEN "minecraft:redstone_wire"
             WHEN "minecraft:repeater"
             WHEN "minecraft:comparator"
             WHEN "minecraft:leaf_litter"
                 MOVE 14 TO SP-RULE(WS-I)
             WHEN "minecraft:wall_torch"
             WHEN "minecraft:soul_wall_torch"
             WHEN "minecraft:redstone_wall_torch"
             WHEN "minecraft:copper_wall_torch"
             WHEN "minecraft:ladder"
             WHEN "minecraft:tripwire_hook"
                 MOVE 15 TO SP-RULE(WS-I)
             WHEN "minecraft:lever"
             WHEN "minecraft:grindstone"
                 MOVE 16 TO SP-RULE(WS-I)
             WHEN "minecraft:lantern"
             WHEN "minecraft:soul_lantern"
                 MOVE 19 TO SP-RULE(WS-I)
             WHEN "minecraft:vine"
             WHEN "minecraft:glow_lichen"
             WHEN "minecraft:sculk_vein"
             WHEN "minecraft:resin_clump"
                 MOVE 20 TO SP-RULE(WS-I)
             WHEN OTHER
                 IF WS-N > 7 AND WS-FULL(WS-N - 6:7) = "_banner"
                     MOVE 14 TO SP-RULE(WS-I)
                     IF WS-N > 12 AND WS-FULL(WS-N - 11:12) = "_wall_banner"
                         MOVE 15 TO SP-RULE(WS-I)
                     END-IF
                 END-IF
*>               Coral fans stand on a block with a solid top, wall fans hang on the block behind (24 part 6 section 3.4); a copper lantern is a lantern.
                 IF WS-N > 10 AND WS-FULL(WS-N - 9:10) = "_coral_fan"
                     MOVE 14 TO SP-RULE(WS-I)
                 END-IF
                 IF WS-N > 15 AND WS-FULL(WS-N - 14:15) = "_coral_wall_fan"
                     MOVE 15 TO SP-RULE(WS-I)
                 END-IF
                 IF WS-N > 14 AND WS-FULL(WS-N - 13:14) = "copper_lantern"
                     MOVE 19 TO SP-RULE(WS-I)
                 END-IF
*>               A bed half needs its other half (BedBlock.updateShape: the neighbour in the connected direction must be the same bed with the other part).
                 IF WS-N > 4 AND WS-FULL(WS-N - 3:4) = "_bed"
                     MOVE 25 TO SP-RULE(WS-I)
                 END-IF
*>               A ceiling hanging sign hangs from the block above it; a wall hanging sign has no survive rule (it is placed by WallHangingSignBlock.canPlace).
                 IF WS-N > 13 AND WS-FULL(WS-N - 12:13) = "_hanging_sign"
                     MOVE 18 TO SP-RULE(WS-I)
                 END-IF
                 IF WS-N > 18 AND WS-FULL(WS-N - 17:18) = "_wall_hanging_sign"
                     MOVE 0 TO SP-RULE(WS-I)
                 END-IF
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 35
         MOVE WS-TAG-KEY(WS-J) TO WS-KEY112
         CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-KEY112 WS-COUNT WS-IDS WS-CAP WS-STATUS
         IF WS-STATUS = CT-OK
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 COMPUTE WS-INDEX = WS-ID(WS-I) + 1
                 IF WS-INDEX >= 1 AND WS-INDEX <= CB-BLOCK-COUNT
                     IF WS-TAG-KIND(WS-J) < 0
                         IF SP-RULE(WS-INDEX) = 0
                             COMPUTE SP-RULE(WS-INDEX) = 0 - WS-TAG-KIND(WS-J)
                         END-IF
                     ELSE
                         COMPUTE WS-Q = SP-SUP(WS-INDEX) / WS-TAG-KIND(WS-J)
                         COMPUTE WS-HAS = FUNCTION MOD(WS-Q, 2)
                         IF WS-HAS = 0
                             ADD WS-TAG-KIND(WS-J) TO SP-SUP(WS-INDEX)
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     COMPUTE SP-EPOCH = CB-EPOCH + 1
     GOBACK.
 END PROGRAM SUP-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUP-SOLID-AT.
*> USING dimension row, x, y, z, solid out (BINARY-LONG), block number out (1-based, 0 for none), bits out (SP-SUP of the block): the block at the cell is a block with a collision shape.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY SUPSTATE.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-BITS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SOLID L-BLOCK L-BITS.
     MOVE 0 TO L-SOLID L-BLOCK L-BITS
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0 AND WS-STATE < CB-STATE-COUNT
         COMPUTE L-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE CB-SOLID(L-BLOCK) TO L-SOLID
         MOVE SP-SUP(L-BLOCK) TO L-BITS
     END-IF
     GOBACK.
 END PROGRAM SUP-SOLID-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUP-HAS-BIT.
*> USING bits, bit (BINARY-LONG), flag out: 1 when the bit is set in bits.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BITS                 BINARY-LONG.
 01 L-BIT                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BITS L-BIT L-FLAG.
     COMPUTE WS-Q = L-BITS / L-BIT
     COMPUTE L-FLAG = FUNCTION MOD(WS-Q, 2)
     GOBACK.
 END PROGRAM SUP-HAS-BIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUP-FACING.
*> USING state, property name (PIC X(24)), dx out, dz out, dy out, found out: the horizontal direction of the property facing (north 0,-1; south 0,1; west -1,0; east 1,0) or the vertical one of
*> a face property (floor: dy -1 below, ceiling: +1); found 0 when the block has no such property.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(32).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(24).
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-NAME L-DX L-DZ L-DY L-FOUND.
     MOVE 0 TO L-DX L-DZ L-DY
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE L-NAME WS-TEXT L-FOUND
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "north"
             MOVE -1 TO L-DZ
         WHEN "south"
             MOVE 1 TO L-DZ
         WHEN "west"
             MOVE -1 TO L-DX
         WHEN "east"
             MOVE 1 TO L-DX
         WHEN "floor"
             MOVE -1 TO L-DY
         WHEN "ceiling"
             MOVE 1 TO L-DY
         WHEN "up"
             MOVE 1 TO L-DY
         WHEN "down"
             MOVE -1 TO L-DY
     END-EVALUATE
     GOBACK.
 END PROGRAM SUP-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUP-SURVIVES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY SUPSTATE.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RULE                BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OTHER-SOLID         BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-OTHER-BITS          BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(32).
 01 WS-HALF                PIC X(24) VALUE "half".
 01 WS-FACING              PIC X(24) VALUE "facing".
 01 WS-FACE                PIC X(24) VALUE "face".
 01 WS-FACE-FOUND          BINARY-LONG.
 01 WS-ABOVE-STATE         BINARY-LONG.
 01 WS-SEA-OK              BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-LIGHT         BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-NEAR                BINARY-LONG VALUE 7.
 01 WS-HANGING             PIC X(24) VALUE "hanging".
 01 WS-NAME24              PIC X(24).
 01 WS-NAME48              PIC X(48).
 01 WS-BED-PART            BINARY-LONG.
 01 WS-OTHER-PART          BINARY-LONG.
 01 WS-SIGN-SUFFIX         PIC X(24) VALUE "hanging_sign".
 01 WS-SIDE-TABLE.
    05 WS-SIDE-DX          BINARY-LONG OCCURS 4 TIMES.
    05 WS-SIDE-DZ          BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-OK.
     MOVE 1 TO L-OK
     CALL "SUP-OPEN"
     IF L-STATE <= 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(L-STATE + 1) + 1
     MOVE SP-RULE(WS-BLOCK) TO WS-RULE
     IF WS-RULE = 0
         GOBACK
     END-IF
*>   The four horizontal neighbours, west, east, north, south.
     MOVE -1 TO WS-SIDE-DX(1)
     MOVE 1 TO WS-SIDE-DX(2)
     MOVE 0 TO WS-SIDE-DX(3) WS-SIDE-DX(4)
     MOVE 0 TO WS-SIDE-DZ(1) WS-SIDE-DZ(2)
     MOVE -1 TO WS-SIDE-DZ(3)
     MOVE 1 TO WS-SIDE-DZ(4)
     COMPUTE WS-Y = L-Y - 1
     CALL "SUP-SOLID-AT" USING L-DIM L-X WS-Y L-Z WS-SOLID WS-BELOW WS-BITS
     MOVE 0 TO L-OK
*>   A double plant's rule is that of its lower half; its upper half needs the lower half of the same block below.
     IF WS-RULE = 13
         MOVE SPACES TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-HALF WS-TEXT WS-FOUND
         IF FUNCTION TRIM(WS-TEXT) = "upper"
             IF WS-BELOW = WS-BLOCK
                 MOVE 1 TO L-OK
             END-IF
             GOBACK
         END-IF
         MOVE SP-ARG(WS-BLOCK) TO WS-RULE
     END-IF
     IF WS-RULE = 7
         MOVE SPACES TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-HALF WS-TEXT WS-FOUND
         IF FUNCTION TRIM(WS-TEXT) = "upper"
             IF WS-BELOW = WS-BLOCK
                 MOVE 1 TO L-OK
             END-IF
             GOBACK
         END-IF
         MOVE 5 TO WS-RULE
     END-IF
     EVALUATE WS-RULE
         WHEN 1
             MOVE 1 TO WS-BIT
             CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT L-OK
         WHEN 2
             MOVE 2 TO WS-BIT
             CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT L-OK
         WHEN 3
             MOVE 4 TO WS-BIT
             CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT L-OK
             IF WS-BELOW > 0 AND CB-OPAQUE(WS-BELOW) = 1
                 MOVE 1 TO L-OK
             END-IF
*>       a lily pad stands on water with nothing above it
         WHEN 4
             IF WS-BELOW > 0 AND WS-BELOW = SP-WATER
                 COMPUTE WS-Y = L-Y + 1
                 CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-ABOVE-STATE
                 IF WS-ABOVE-STATE = 0
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
*>       seagrass: a full block below that does not list cannot_support_seagrass (tall seagrass is checked as its lower half)
         WHEN 5
             MOVE 16 TO WS-BIT
             CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT WS-FLAG
             IF WS-BELOW > 0 AND CB-OPAQUE(WS-BELOW) = 1 AND WS-FLAG = 0
                 MOVE 1 TO L-OK
             END-IF
         WHEN 6
             IF WS-SOLID = 1
                 MOVE 1 TO L-OK
             END-IF
*>       snow: a block below that is not in cannot_support_snow_layer and has a solid top (or is in support_override_snow_layer)
         WHEN 8
             MOVE 32 TO WS-BIT
             CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT WS-FLAG
             IF WS-BELOW > 0 AND WS-FLAG = 0
                 MOVE 64 TO WS-BIT
                 CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT WS-FLAG
                 IF WS-SOLID = 1 OR WS-FLAG = 1
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
*>       sugar cane: sugar cane below, or a supporting block with water beside it
         WHEN 9
             IF WS-BELOW = WS-BLOCK
                 MOVE 1 TO L-OK
             ELSE
                 MOVE 128 TO WS-BIT
                 CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT WS-FLAG
                 IF WS-FLAG = 1
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                         COMPUTE WS-X = L-X + WS-SIDE-DX(WS-I)
                         COMPUTE WS-Z = L-Z + WS-SIDE-DZ(WS-I)
                         COMPUTE WS-Y = L-Y - 1
                         CALL "SUP-SOLID-AT" USING L-DIM WS-X WS-Y WS-Z WS-OTHER-SOLID WS-OTHER WS-OTHER-BITS
                         MOVE 256 TO WS-BIT
                         CALL "SUP-HAS-BIT" USING WS-OTHER-BITS WS-BIT WS-FLAG
                         IF WS-OTHER > 0 AND (WS-OTHER = SP-WATER OR WS-FLAG = 1)
                             MOVE 1 TO L-OK
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
*>       cactus: cactus below or a supporting block, and no solid block beside it
         WHEN 10
             IF WS-BELOW = WS-BLOCK
                 MOVE 1 TO L-OK
             ELSE
                 MOVE 512 TO WS-BIT
                 CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT L-OK
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 COMPUTE WS-X = L-X + WS-SIDE-DX(WS-I)
                 COMPUTE WS-Z = L-Z + WS-SIDE-DZ(WS-I)
                 CALL "SUP-SOLID-AT" USING L-DIM WS-X L-Y WS-Z WS-OTHER-SOLID WS-OTHER WS-OTHER-BITS
                 IF WS-OTHER-SOLID = 1
                     MOVE 0 TO L-OK
                 END-IF
             END-PERFORM
*>       kelp: kelp below, or a block with a solid top that is not in cannot_support_kelp
         WHEN 11
             IF WS-BELOW = SP-WATER OR WS-BELOW = 0
                 CONTINUE
             ELSE
                 MOVE 1024 TO WS-BIT
                 CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT WS-FLAG
                 IF SP-RULE(WS-BELOW) = 11 OR (WS-SOLID = 1 AND WS-FLAG = 0)
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
         WHEN 12
             IF WS-BELOW > 0 AND SP-RULE(WS-BELOW) = 12
                 MOVE 1 TO L-OK
             ELSE
                 MOVE 2048 TO WS-BIT
                 CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT L-OK
             END-IF
*>       stands on a block with a solid top (a fence or wall counts)
         WHEN 14
             MOVE 4096 TO WS-BIT
             CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT WS-FLAG
             IF WS-SOLID = 1 OR WS-FLAG = 1
                 MOVE 1 TO L-OK
             END-IF
*>       hangs on the solid block behind it
         WHEN 15
             CALL "SUP-FACING" USING L-STATE WS-FACING WS-DX WS-DZ WS-DY WS-FOUND
             COMPUTE WS-X = L-X - WS-DX
             COMPUTE WS-Z = L-Z - WS-DZ
             CALL "SUP-SOLID-AT" USING L-DIM WS-X L-Y WS-Z WS-OTHER-SOLID WS-OTHER WS-OTHER-BITS
*>           every block of rule 15 has a facing property; one without it would stay (nothing to hang on)
             IF WS-OTHER-SOLID = 1 OR WS-FOUND = 0
                 MOVE 1 TO L-OK
             END-IF
*>       a button or lever: floor below, ceiling above, wall behind
         WHEN 16
             CALL "SUP-FACING" USING L-STATE WS-FACE WS-DX WS-DZ WS-DY WS-FOUND
             MOVE WS-FOUND TO WS-FACE-FOUND
             MOVE L-X TO WS-X
             MOVE L-Z TO WS-Z
             COMPUTE WS-Y = L-Y + WS-DY
             IF WS-DY = 0
                 CALL "SUP-FACING" USING L-STATE WS-FACING WS-DX WS-DZ WS-DY WS-FOUND
                 COMPUTE WS-X = L-X - WS-DX
                 COMPUTE WS-Z = L-Z - WS-DZ
                 MOVE L-Y TO WS-Y
             END-IF
             CALL "SUP-SOLID-AT" USING L-DIM WS-X WS-Y WS-Z WS-OTHER-SOLID WS-OTHER WS-OTHER-BITS
*>           every button and lever has a face property; one without it would stay
             IF WS-OTHER-SOLID = 1 OR WS-FACE-FOUND = 0
                 MOVE 1 TO L-OK
             END-IF
*>       a ceiling hanging sign hangs from a solid block above it
         WHEN 18
             COMPUTE WS-Y = L-Y + 1
             CALL "SUP-SOLID-AT" USING L-DIM L-X WS-Y L-Z WS-OTHER-SOLID WS-OTHER WS-OTHER-BITS
             IF WS-OTHER-SOLID = 1
                 MOVE 1 TO L-OK
             END-IF
*>           a hanging sign hangs from another one (the chain of hanging signs)
             CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-ABOVE-STATE
             CALL "PS-NAME-OF" USING WS-ABOVE-STATE WS-NAME48
             CALL "PS-ENDS" USING WS-NAME48 WS-SIGN-SUFFIX WS-FLAG
             IF WS-FLAG = 1
                 MOVE 1 TO L-OK
             END-IF
*>       a lantern stands on a solid block below it, or (hanging) hangs from one above
         WHEN 19
             MOVE SPACES TO WS-TEXT
             MOVE "hanging" TO WS-NAME24
             CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME24 WS-TEXT WS-FOUND
             COMPUTE WS-Y = L-Y - 1
             IF FUNCTION TRIM(WS-TEXT) = "true"
                 COMPUTE WS-Y = L-Y + 1
             END-IF
             CALL "SUP-SOLID-AT" USING L-DIM L-X WS-Y L-Z WS-OTHER-SOLID WS-OTHER WS-OTHER-BITS
             IF WS-OTHER-SOLID = 1
                 MOVE 1 TO L-OK
             END-IF
*>       a vine, glow lichen, sculk vein or resin clump holds on while one of its faces has a solid block behind it (a vine's side face also holds on a vine above that has the face)
         WHEN 20
             CALL "SUP-MULTIFACE" USING L-DIM L-X L-Y L-Z L-STATE L-OK
*>       a block that stands on the blocks of one tag: the tag's bit is the block's SP-ARG (stems, nether wart, azalea, wither rose, nether roots and sprouts; 29b part 2 section 12)
         WHEN 21
             MOVE SP-ARG(WS-BLOCK) TO WS-BIT
             CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT L-OK
*>       a crop (also the lower half of the pitcher crop): a block of supports_crops below and raw brightness 8 or more (no sky darkening: the stored light, the sky reach as the random tick reads it)
         WHEN 22
             MOVE 8192 TO WS-BIT
             CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT WS-FLAG
             IF WS-FLAG = 1
                 CALL "LIGHT-RAW" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCK-LIGHT WS-LIGHT
                 CALL "LIGHT-SKY-SPREAD" USING L-DIM L-X L-Y L-Z WS-NEAR WS-SKY
                 COMPUTE WS-LIGHT = FUNCTION MAX(WS-BLOCK-LIGHT, WS-SKY)
                 IF WS-LIGHT >= 8
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
*>       cocoa: the block on the side of its facing is in supports_cocoa (no light test)
         WHEN 23
             CALL "SUP-FACING" USING L-STATE WS-FACING WS-DX WS-DZ WS-DY WS-FOUND
             COMPUTE WS-X = L-X + WS-DX
             COMPUTE WS-Z = L-Z + WS-DZ
             CALL "SUP-SOLID-AT" USING L-DIM WS-X L-Y WS-Z WS-OTHER-SOLID WS-OTHER WS-OTHER-BITS
             MOVE 131072 TO WS-BIT
             CALL "SUP-HAS-BIT" USING WS-OTHER-BITS WS-BIT L-OK
*>       mangrove propagule: standing, a block of supports_mangrove_propagule below; hanging, a block of supports_hanging_mangrove_propagule above
         WHEN 24
             MOVE SPACES TO WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-HANGING WS-TEXT WS-FOUND
             IF FUNCTION TRIM(WS-TEXT) = "true"
                 COMPUTE WS-Y = L-Y + 1
                 CALL "SUP-SOLID-AT" USING L-DIM L-X WS-Y L-Z WS-OTHER-SOLID WS-OTHER WS-OTHER-BITS
                 MOVE 1048576 TO WS-BIT
                 CALL "SUP-HAS-BIT" USING WS-OTHER-BITS WS-BIT L-OK
             ELSE
                 MOVE 524288 TO WS-BIT
                 CALL "SUP-HAS-BIT" USING WS-BITS WS-BIT L-OK
             END-IF
*>       a bed half: the cell of the other half holds the same bed with the opposite part
         WHEN 25
             CALL "BED-PART" USING L-STATE WS-BED-PART WS-DX WS-DZ
             COMPUTE WS-X = L-X + WS-DX
             COMPUTE WS-Z = L-Z + WS-DZ
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-X L-Y WS-Z WS-STATE
             CALL "BED-PART" USING WS-STATE WS-OTHER-PART WS-DX WS-DZ
             IF WS-OTHER-PART + WS-BED-PART = 3 AND CB-S-BLOCK(WS-STATE + 1) + 1 = WS-BLOCK
                 MOVE 1 TO L-OK
             END-IF
*>       a door: its lower half stands on a solid block, its upper half on the lower half of the same door
         WHEN 17
             MOVE SPACES TO WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-HALF WS-TEXT WS-FOUND
             IF FUNCTION TRIM(WS-TEXT) = "upper"
                 IF WS-BELOW = WS-BLOCK
                     MOVE 1 TO L-OK
                 END-IF
             ELSE
                 IF WS-SOLID = 1
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SUP-SURVIVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUP-MULTIFACE.
*> USING dimension row, x, y, z, state, ok out: the survive rule of a multiface block (24 part 4 sections 6.7 and 6.8): at least one face of the state is set and held, a face by the solid block behind it and,
*> for a vine's side face, also by a vine above with that face set (VineBlock.getUpdatedState).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-D                   BINARY-LONG.
 01 WS-DIR-TEXT            PIC X(32).
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-ABOVE-Y             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-OK.
     MOVE 0 TO L-OK
     COMPUTE WS-ABOVE-Y = L-Y + 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-ABOVE-Y L-Z WS-ABOVE
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
         CALL "PS-DIR-NAME" USING WS-D WS-DIR-TEXT
         MOVE WS-DIR-TEXT TO WS-NAME
         CALL "PS-GET" USING L-STATE WS-NAME WS-TEXT WS-FOUND
         IF WS-FOUND = 1 AND FUNCTION TRIM(WS-TEXT) = "true"
             CALL "PS-DIR-STEP" USING WS-D WS-DX WS-DY WS-DZ
             COMPUTE WS-X = L-X + WS-DX
             COMPUTE WS-Y = L-Y + WS-DY
             COMPUTE WS-Z = L-Z + WS-DZ
             CALL "SUP-SOLID-AT" USING L-DIM WS-X WS-Y WS-Z WS-SOLID WS-BLOCK WS-BITS
             IF WS-SOLID = 1
                 MOVE 1 TO L-OK
             END-IF
*>           The block above is the same block with the same face set (the vine that hangs from a vine).
             IF WS-D >= 2 AND WS-ABOVE > 0 AND WS-ABOVE < CB-STATE-COUNT
                 IF CB-S-BLOCK(WS-ABOVE + 1) = CB-S-BLOCK(L-STATE + 1)
                     CALL "PS-GET" USING WS-ABOVE WS-NAME WS-TEXT WS-FOUND
                     IF FUNCTION TRIM(WS-TEXT) = "true"
                         MOVE 1 TO L-OK
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SUP-MULTIFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUP-SHAPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-NEW.
     CALL "SUP-SURVIVES" USING L-DIM L-X L-Y L-Z L-STATE WS-OK
     IF WS-OK = 0
         MOVE 0 TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM SUP-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUP-DESTROY-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY SUPSTATE.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(24) VALUE "waterlogged".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OLD L-NEW.
     MOVE 0 TO L-NEW
     CALL "SUP-OPEN"
     IF L-OLD > 0 AND L-OLD < CB-STATE-COUNT AND SP-WATER > 0
         COMPUTE WS-BLOCK = CB-S-BLOCK(L-OLD + 1) + 1
         IF SP-RULE(WS-BLOCK) = 5 OR SP-RULE(WS-BLOCK) = 7 OR SP-RULE(WS-BLOCK) = 11
             MOVE CB-DEFAULT-STATE(SP-WATER) TO L-NEW
         ELSE
             MOVE SPACES TO WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE L-OLD WS-NAME WS-TEXT WS-FOUND
             IF WS-FOUND = 1 AND FUNCTION TRIM(WS-TEXT) = "true"
                 MOVE CB-DEFAULT-STATE(SP-WATER) TO L-NEW
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SUP-DESTROY-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUP-PLACE-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY SUPSTATE.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-OK.
     CALL "SUP-SURVIVES" USING L-DIM L-X L-Y L-Z L-STATE L-OK
     IF L-OK = 0 AND L-STATE > 0 AND L-STATE < CB-STATE-COUNT
*>       A bed's foot is placed before its head: its own placement rule (PS-BED) checks the head cell instead.
         IF SP-RULE(CB-S-BLOCK(L-STATE + 1) + 1) = 25
             MOVE 1 TO L-OK
         END-IF
     END-IF
     IF L-OK = 1 AND L-STATE > 0 AND L-STATE < CB-STATE-COUNT
         COMPUTE WS-BLOCK = CB-S-BLOCK(L-STATE + 1) + 1
*>       A water plant (seagrass, tall seagrass, kelp) is placed only where the fluid of the cell is in tag water and full (29a 5.2, 29b part 4 sections 3.2, 9.2 and 9.3:
*>       FluidState.isFull is amount 8): a source or a falling cell (levels 8 to 15), not the flowing levels 1 to 7. The plant then holds the water source (lane bugkelpplace).
         IF SP-RULE(WS-BLOCK) = 5 OR SP-RULE(WS-BLOCK) = 7 OR SP-RULE(WS-BLOCK) = 11
             MOVE 0 TO L-OK
             CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-OLD
             IF WS-OLD > 0 AND WS-OLD < CB-STATE-COUNT
                 CALL "FLUID-OF-STATE" USING WS-OLD WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
                 CALL "LC-PLANT-PLACEMENT" USING WS-KIND WS-AMOUNT L-OK
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SUP-PLACE-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ICE-AFTER-BREAK.
*> USING dimension row, x, y, z, state (the ice that was broken), player row (BINARY-LONG): IceBlock.playerDestroy (29b section 7.1, lane bugsw T10306: a broken ice left air, so the
*> neighbouring water flowed into the hole as flowing water): unless the tool in the main hand has silk touch (the tag prevents_ice_melting), the broken ice becomes a water source when the
*> block below blocks motion (a solid block, the tag ice_melts_when_destroyed_above) or is a liquid. The Nether's water_evaporates is not modelled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY SUPSTATE.
 01 WS-FULL                PIC X(48).
 01 WS-STATE-BELOW         BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:ice_melts_when_destroyed_above".
 01 WS-IN-TAG              BINARY-LONG.
 01 WS-LIQUID              BINARY-LONG.
 01 WS-SILK-KEY            PIC X(112) VALUE "minecraft:silk_touch".
 01 WS-SILK                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 20 TIMES.
 01 WS-LEVELS.
    05 WS-LEVEL            BINARY-LONG OCCURS 20 TIMES.
 01 WS-PREVENTS            BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-ROW.
     IF L-STATE <= 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(L-STATE + 1) + 1
     CALL "KEY-NAMESPACED" USING CB-KEY(WS-BLOCK) WS-FULL
     IF FUNCTION TRIM(WS-FULL) NOT = "minecraft:ice"
         GOBACK
     END-IF
*>   Silk touch on the tool in the main hand prevents the melting.
     MOVE 0 TO WS-PREVENTS
     IF L-ROW > 0
         IF PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) > 0
             MOVE PL-SLOT-VAR(L-ROW, PL-HELD(L-ROW) + 1) TO WS-HANDLE
             IF WS-HANDLE > 0
                 CALL "LOOT-ENCH-ID" USING WS-SILK-KEY WS-SILK
                 CALL "LOOT-STACK-ENCHANTS" USING WS-HANDLE WS-COUNT WS-IDS WS-LEVELS
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                     IF WS-ID(WS-I) = WS-SILK
                         MOVE 1 TO WS-PREVENTS
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-IF
     IF WS-PREVENTS = 1
         GOBACK
     END-IF
     CALL "SUP-OPEN"
     COMPUTE WS-Y = L-Y - 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE-BELOW
     MOVE 0 TO WS-IN-TAG WS-LIQUID
     IF WS-STATE-BELOW > 0 AND WS-STATE-BELOW < CB-STATE-COUNT
         MOVE CB-S-BLOCK(WS-STATE-BELOW + 1) TO WS-BELOW
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BELOW WS-IN-TAG
         IF CB-SOLID(WS-BELOW + 1) = 1
             MOVE 1 TO WS-IN-TAG
         END-IF
         IF WS-BELOW + 1 = SP-WATER
             MOVE 1 TO WS-LIQUID
         END-IF
         CALL "KEY-NAMESPACED" USING CB-KEY(WS-BELOW + 1) WS-FULL
         IF FUNCTION TRIM(WS-FULL) = "minecraft:lava"
             MOVE 1 TO WS-LIQUID
         END-IF
     END-IF
     IF (WS-IN-TAG = 1 OR WS-LIQUID = 1) AND SP-WATER > 0
         MOVE CB-DEFAULT-STATE(SP-WATER) TO WS-NEW
         CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-NEW
     END-IF
     GOBACK.
 END PROGRAM ICE-AFTER-BREAK.
