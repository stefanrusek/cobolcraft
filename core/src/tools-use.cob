*> Special uses of tools and items (docs/protocol/17 section 3; US14; T2104 onward). Decision rules as programs of their own: each takes
*> the state of the use as plain values and answers what happens, so that the player-facing layer (the Use Item On, Use Item, Interact
*> and Player Action handlers) and the world layer call the same rules. Keys are block or item keys without "minecraft:". Faces are
*> 0 down, 1 up, 2 north, 3 south, 4 west, 5 east.
*>
*> Section 3.1 (block transformers):
*>   TOOL-COPPER-PARSE USING key (PIC X(48)), waxed out (1 or 0), level out (0 plain to 3 oxidized), family out (1 to 15, 0 none)
*>   TOOL-COPPER-BUILD USING waxed, level, family, key out
*>   TOOL-WAX-KEY USING direction (1 honeycomb wax on, 0 wax off), key, new key out, found out
*>   TOOL-TRANSFORM USING kind (PIC X(8): axe, shovel, hoe), key, face, air above (1 or 0), found out, new key out, sound out (PIC X(32)),
*>     particle out (PIC X(16), "-" none), loot out (PIC X(32), "-" none), update from neighbours out (1 or 0), copy properties out (1
*>     when the new block takes the properties of the clicked one)
*>   TOOL-USE-SKIPPED USING off hand blocks (1 or 0), hand used (0 main, 1 off), sneaking (1 or 0), skip out (1: the shield has priority)
*>   TOOL-CAMPFIRE-DOUSE USING key, lit (1 or 0), found out, level event out (1009), damage out (1)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-COPPER-PARSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TOOLFAM.
 01 WS-REST                PIC X(48).
 01 WS-TMP                 PIC X(48).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-WAXED                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-WAXED L-LEVEL L-FAMILY.
     MOVE 0 TO L-WAXED L-LEVEL L-FAMILY
     MOVE L-KEY TO WS-REST
     IF WS-REST(1:6) = "waxed_"
         MOVE 1 TO L-WAXED
         MOVE WS-REST(7:42) TO WS-TMP
         MOVE WS-TMP TO WS-REST
     END-IF
     EVALUATE TRUE
         WHEN WS-REST(1:8) = "exposed_"
             MOVE 1 TO L-LEVEL
             MOVE WS-REST(9:40) TO WS-TMP
             MOVE WS-TMP TO WS-REST
         WHEN WS-REST(1:10) = "weathered_"
             MOVE 2 TO L-LEVEL
             MOVE WS-REST(11:38) TO WS-TMP
             MOVE WS-TMP TO WS-REST
         WHEN WS-REST(1:9) = "oxidized_"
             MOVE 3 TO L-LEVEL
             MOVE WS-REST(10:39) TO WS-TMP
             MOVE WS-TMP TO WS-REST
     END-EVALUATE
     IF WS-REST = "copper_block" AND L-LEVEL = 0
         MOVE 1 TO L-FAMILY
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TF-FAMILIES
             IF WS-REST = TF-FAMILY(WS-I) AND (WS-I > 1 OR L-LEVEL > 0)
                 MOVE WS-I TO L-FAMILY
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM TOOL-COPPER-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-COPPER-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TOOLFAM.
 01 WS-PREFIX              PIC X(12).
 01 WS-NAME                PIC X(48).
 LINKAGE SECTION.
 01 L-WAXED                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 01 L-KEY                  PIC X(48).
 PROCEDURE DIVISION USING L-WAXED L-LEVEL L-FAMILY L-KEY.
     MOVE SPACES TO WS-PREFIX WS-NAME L-KEY
     EVALUATE L-LEVEL
         WHEN 1
             MOVE "exposed_" TO WS-PREFIX
         WHEN 2
             MOVE "weathered_" TO WS-PREFIX
         WHEN 3
             MOVE "oxidized_" TO WS-PREFIX
     END-EVALUATE
     IF L-FAMILY = 1 AND L-LEVEL = 0
         MOVE "copper_block" TO WS-NAME
     ELSE
         STRING FUNCTION TRIM(WS-PREFIX) FUNCTION TRIM(TF-FAMILY(L-FAMILY)) DELIMITED BY SIZE INTO WS-NAME
     END-IF
     IF L-WAXED = 1
         STRING "waxed_" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO L-KEY
     ELSE
         MOVE WS-NAME TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM TOOL-COPPER-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-WAX-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WAXED               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-NEW                  PIC X(48).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRECTION L-KEY L-NEW L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE "-" TO L-NEW
     CALL "TOOL-COPPER-PARSE" USING L-KEY WS-WAXED WS-LEVEL WS-FAMILY
     IF WS-FAMILY > 0 AND WS-WAXED NOT = L-DIRECTION
         MOVE L-DIRECTION TO WS-TARGET
         CALL "TOOL-COPPER-BUILD" USING WS-TARGET WS-LEVEL WS-FAMILY L-NEW
         MOVE 1 TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM TOOL-WAX-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-STRIP-KEY.
*> USING key, new key out, found out: the 25 strip rules of axe.json (ten woods as log and wood, warped and crimson stem and hyphae,
*> bamboo_block).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TOOLFAM.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(48).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-NEW                  PIC X(48).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-NEW L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE "-" TO L-NEW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TF-WOODS
         MOVE SPACES TO WS-NAME
         STRING FUNCTION TRIM(TF-WOOD(WS-I)) "_log" DELIMITED BY SIZE INTO WS-NAME
         IF L-KEY = WS-NAME
             MOVE 1 TO L-FOUND
         END-IF
         MOVE SPACES TO WS-NAME
         STRING FUNCTION TRIM(TF-WOOD(WS-I)) "_wood" DELIMITED BY SIZE INTO WS-NAME
         IF L-KEY = WS-NAME
             MOVE 1 TO L-FOUND
         END-IF
     END-PERFORM
     IF L-KEY = "warped_stem" OR "warped_hyphae" OR "crimson_stem" OR "crimson_hyphae" OR "bamboo_block"
         MOVE 1 TO L-FOUND
     END-IF
     IF L-FOUND = 1
         STRING "stripped_" FUNCTION TRIM(L-KEY) DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM TOOL-STRIP-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-TRANSFORM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WAXED               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-OFF                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KIND                 PIC X(8).
 01 L-KEY                  PIC X(48).
 01 L-FACE                 BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-NEW                  PIC X(48).
 01 L-SOUND                PIC X(32).
 01 L-PARTICLE             PIC X(16).
 01 L-LOOT                 PIC X(32).
 01 L-UPDATE               BINARY-LONG.
 01 L-COPY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-KEY L-FACE L-AIR L-FOUND L-NEW L-SOUND L-PARTICLE L-LOOT L-UPDATE L-COPY.
     MOVE 0 TO L-FOUND L-COPY
     MOVE 1 TO L-UPDATE
     MOVE "-" TO L-NEW L-SOUND L-PARTICLE L-LOOT
     EVALUATE L-KIND
         WHEN "axe"
             PERFORM AXE
         WHEN "shovel"
             IF L-AIR = 1 AND L-FACE NOT = 0 AND (L-KEY = "grass_block" OR "dirt" OR "podzol" OR "coarse_dirt"
                     OR "mycelium" OR "rooted_dirt")
                 MOVE 1 TO L-FOUND
                 MOVE "dirt_path" TO L-NEW
                 MOVE "item.shovel.flatten" TO L-SOUND
             END-IF
         WHEN OTHER
             PERFORM HOE
     END-EVALUATE
     GOBACK.

 AXE.
     CALL "TOOL-STRIP-KEY" USING L-KEY L-NEW L-FOUND
     IF L-FOUND = 1
         MOVE "item.axe.strip" TO L-SOUND
         MOVE 1 TO L-COPY
     ELSE
         CALL "TOOL-COPPER-PARSE" USING L-KEY WS-WAXED WS-LEVEL WS-FAMILY
         EVALUATE TRUE
             WHEN WS-FAMILY = 0
                 CONTINUE
             WHEN WS-WAXED = 1
                 CALL "TOOL-WAX-KEY" USING WS-OFF L-KEY L-NEW L-FOUND
                 MOVE "item.axe.wax_off" TO L-SOUND
                 MOVE "wax_off" TO L-PARTICLE
             WHEN WS-LEVEL > 0
                 COMPUTE WS-STEP = WS-LEVEL - 1
                 CALL "TOOL-COPPER-BUILD" USING WS-WAXED WS-STEP WS-FAMILY L-NEW
                 MOVE 1 TO L-FOUND
                 MOVE "item.axe.scrape" TO L-SOUND
                 MOVE "scrape" TO L-PARTICLE
         END-EVALUATE
         IF L-FOUND = 1
             MOVE 1 TO L-COPY
             IF WS-FAMILY > 13
                 MOVE 0 TO L-UPDATE
             END-IF
         END-IF
     END-IF.

 HOE.
     EVALUATE TRUE
         WHEN L-KEY = "rooted_dirt"
             MOVE 1 TO L-FOUND
             MOVE "dirt" TO L-NEW
             MOVE "till/rooted_dirt" TO L-LOOT
         WHEN L-AIR = 1 AND L-FACE NOT = 0 AND (L-KEY = "grass_block" OR "dirt_path" OR "dirt")
             MOVE 1 TO L-FOUND
             MOVE "farmland" TO L-NEW
         WHEN L-AIR = 1 AND L-FACE NOT = 0 AND L-KEY = "coarse_dirt"
             MOVE 1 TO L-FOUND
             MOVE "dirt" TO L-NEW
     END-EVALUATE
     IF L-FOUND = 1
         MOVE "item.hoe.till" TO L-SOUND
     END-IF.
 END PROGRAM TOOL-TRANSFORM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-USE-SKIPPED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCKS               BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-SNEAKING             BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCKS L-HAND L-SNEAKING L-SKIP.
     MOVE 0 TO L-SKIP
     IF L-BLOCKS = 1 AND L-HAND = 0 AND L-SNEAKING = 0
         MOVE 1 TO L-SKIP
     END-IF
     GOBACK.
 END PROGRAM TOOL-USE-SKIPPED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-CAMPFIRE-DOUSE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-LIT                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-LIT L-FOUND L-EVENT L-DAMAGE.
     MOVE 0 TO L-FOUND L-EVENT L-DAMAGE
     IF L-LIT = 1 AND (L-KEY = "campfire" OR "soul_campfire")
         MOVE 1 TO L-FOUND L-DAMAGE
         MOVE 1009 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM TOOL-CAMPFIRE-DOUSE.

*> Section 3.2 (shears):
*>   TOOL-SHEARS-MINE-COST USING hardness (thousandths), in tag fire (1 or 0), cost out (1 durability per broken block, 0 for hardness 0 or fire)
*>   TOOL-SHEARS-CORRECT USING key, correct out (cobweb, every leaves block, vine, glow_lichen drop through the shears)
*>   TOOL-SHEARS-PLANT USING key, found out, max age out (the growing plant heads; the age 25 of GrowingPlantHeadBlock)
*>   TOOL-PUMPKIN-CARVE USING clicked face, player horizontal direction (2 to 5), facing out (PIC X(48)), sound out (PIC X(32)), seeds out
*>     (4), spawn offset out (650 thousandths of the face normal), damage out (1)
*>   TOOL-BEEHIVE-SMOKY USING lit campfire distance below (1 to 5, 0 none), solid cover between (1 or 0), smoky out
*>   TOOL-BEEHIVE-SHEAR USING honey level, smoky, hive holds bees (1 or 0), damage out (1 when sheared), bees released out, bees angered out
*>   TOOL-BEEHIVE-BOTTLE USING honey level, smoky, holds bees, bottle filled out, bees released out, bees angered out
*>   TOOL-SHEEP-SHEAR USING colour key, sheared, baby, roll (0 to 2: the uniform draw of 1 to 3), item key out, count out, damage out
*>   TOOL-SHEAR-ENTITY USING entity key, variant (mooshroom: red or brown), item out, count out (0: not shearable by this rule)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHEARS-MINE-COST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HARDNESS             BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HARDNESS L-FIRE L-COST.
     MOVE 1 TO L-COST
     IF L-HARDNESS = 0 OR L-FIRE = 1
         MOVE 0 TO L-COST
     END-IF
     GOBACK.
 END PROGRAM TOOL-SHEARS-MINE-COST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHEARS-CORRECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEAVES              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-CORRECT              BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CORRECT.
     MOVE 0 TO L-CORRECT WS-LEAVES
     INSPECT L-KEY TALLYING WS-LEAVES FOR ALL "_leaves "
     IF WS-LEAVES > 0 OR L-KEY = "cobweb" OR "vine" OR "glow_lichen" OR "leaves"
         MOVE 1 TO L-CORRECT
     END-IF
     GOBACK.
 END PROGRAM TOOL-SHEARS-CORRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHEARS-PLANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-FOUND                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FOUND L-AGE.
     MOVE 0 TO L-FOUND L-AGE
     IF L-KEY = "kelp" OR "weeping_vines" OR "twisting_vines" OR "cave_vines"
         MOVE 1 TO L-FOUND
         MOVE 25 TO L-AGE
     END-IF
     GOBACK.
 END PROGRAM TOOL-SHEARS-PLANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-PUMPKIN-CARVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACE                 BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-FACING               PIC X(48).
 01 L-SOUND                PIC X(32).
 01 L-SEEDS                BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACE L-DIRECTION L-FACING L-SOUND L-SEEDS L-OFFSET L-DAMAGE.
     MOVE "block.pumpkin.carve" TO L-SOUND
     MOVE 4 TO L-SEEDS
     MOVE 650 TO L-OFFSET
     MOVE 1 TO L-DAMAGE
     MOVE SPACES TO L-FACING
     IF L-FACE < 2
         EVALUATE L-DIRECTION
             WHEN 2
                 MOVE "south" TO L-FACING
             WHEN 3
                 MOVE "north" TO L-FACING
             WHEN 4
                 MOVE "east" TO L-FACING
             WHEN OTHER
                 MOVE "west" TO L-FACING
         END-EVALUATE
     ELSE
         EVALUATE L-FACE
             WHEN 2
                 MOVE "north" TO L-FACING
             WHEN 3
                 MOVE "south" TO L-FACING
             WHEN 4
                 MOVE "west" TO L-FACING
             WHEN OTHER
                 MOVE "east" TO L-FACING
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM TOOL-PUMPKIN-CARVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BEEHIVE-SMOKY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-COVER                BINARY-LONG.
 01 L-SMOKY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-COVER L-SMOKY.
     MOVE 0 TO L-SMOKY
     IF L-DISTANCE >= 1 AND L-DISTANCE <= 5 AND L-COVER = 0
         MOVE 1 TO L-SMOKY
     END-IF
     GOBACK.
 END PROGRAM TOOL-BEEHIVE-SMOKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BEEHIVE-SHEAR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HONEY                BINARY-LONG.
 01 L-SMOKY                BINARY-LONG.
 01 L-BEES                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-RELEASED             BINARY-LONG.
 01 L-ANGERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-HONEY L-SMOKY L-BEES L-DAMAGE L-RELEASED L-ANGERED.
     MOVE 0 TO L-DAMAGE L-RELEASED L-ANGERED
     IF L-HONEY = 5
         MOVE 1 TO L-DAMAGE
         IF L-SMOKY = 0 AND L-BEES = 1
             MOVE 1 TO L-RELEASED L-ANGERED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-BEEHIVE-SHEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BEEHIVE-BOTTLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HONEY                BINARY-LONG.
 01 L-SMOKY                BINARY-LONG.
 01 L-BEES                 BINARY-LONG.
 01 L-FILLED               BINARY-LONG.
 01 L-RELEASED             BINARY-LONG.
 01 L-ANGERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-HONEY L-SMOKY L-BEES L-FILLED L-RELEASED L-ANGERED.
     MOVE 0 TO L-FILLED L-RELEASED L-ANGERED
     IF L-HONEY = 5
         MOVE 1 TO L-FILLED
         IF L-SMOKY = 0 AND L-BEES = 1
             MOVE 1 TO L-RELEASED L-ANGERED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-BEEHIVE-BOTTLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHEEP-SHEAR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COLOUR               PIC X(48).
 01 L-SHEARED              BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-ITEM                 PIC X(48).
 01 L-COUNT                BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-COLOUR L-SHEARED L-BABY L-ROLL L-ITEM L-COUNT L-DAMAGE.
     MOVE 0 TO L-COUNT L-DAMAGE
     MOVE SPACES TO L-ITEM
     IF L-SHEARED = 0 AND L-BABY = 0
         STRING FUNCTION TRIM(L-COLOUR) "_wool" DELIMITED BY SIZE INTO L-ITEM
         COMPUTE L-COUNT = L-ROLL + 1
         MOVE 1 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM TOOL-SHEEP-SHEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHEAR-ENTITY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(48).
 01 L-VARIANT              PIC X(48).
 01 L-ITEM                 PIC X(48).
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-VARIANT L-ITEM L-COUNT.
     MOVE 0 TO L-COUNT
     MOVE SPACES TO L-ITEM
     EVALUATE L-ENTITY
         WHEN "mooshroom"
             STRING FUNCTION TRIM(L-VARIANT) "_mushroom" DELIMITED BY SIZE INTO L-ITEM
             MOVE 5 TO L-COUNT
         WHEN "snow_golem"
             MOVE "carved_pumpkin" TO L-ITEM
             MOVE 1 TO L-COUNT
         WHEN "bogged"
             MOVE "mushroom" TO L-ITEM
             MOVE 2 TO L-COUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-SHEAR-ENTITY.

*> Section 3.3 (flint and steel, fire charge):
*>   TOOL-FIRE-USE USING item (PIC X(16): flint_and_steel or fire_charge), clicked block key, lit, waterlogged, target beside the face is air,
*>     target has a sturdy floor, target has a flammable neighbour, the block below the target is a soul fire base (1 or 0 each), creative,
*>     action out (0 nothing, 1 lights the clicked block, 2 places fire beside the face), new key out ("-": the same block lit, fire or
*>     soul_fire), sound out, durability damage out (flint, survival), stack consumed out (fire charge, survival)
*>   TOOL-FIRE-PITCH USING item, roll 1, roll 2 (0 to 999 thousandths of nextFloat), pitch out (thousandths: flint 0.8 + 0.4 r1; charge
*>     1.0 + 0.2 (r1 - r2); truncated)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-FIRE-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HITS                BINARY-LONG.
 01 WS-LIGHTABLE           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 PIC X(16).
 01 L-KEY                  PIC X(48).
 01 L-LIT                  BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-SUPPORT              BINARY-LONG.
 01 L-FLAMMABLE            BINARY-LONG.
 01 L-SOUL                 BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-NEW                  PIC X(48).
 01 L-SOUND                PIC X(32).
 01 L-DAMAGE               BINARY-LONG.
 01 L-CONSUME              BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-KEY L-LIT L-WATERLOGGED L-AIR L-SUPPORT L-FLAMMABLE L-SOUL L-CREATIVE
         L-ACTION L-NEW L-SOUND L-DAMAGE L-CONSUME.
     MOVE 0 TO L-ACTION L-DAMAGE L-CONSUME WS-LIGHTABLE
     MOVE "-" TO L-NEW L-SOUND
     MOVE 0 TO WS-HITS
     INSPECT L-KEY TALLYING WS-HITS FOR ALL "candle " ALL "candle_cake "
     IF WS-HITS > 0 OR L-KEY = "campfire" OR "soul_campfire"
         IF L-LIT = 0 AND L-WATERLOGGED = 0
             MOVE 1 TO WS-LIGHTABLE
         END-IF
     END-IF
     EVALUATE TRUE
         WHEN WS-LIGHTABLE = 1
             MOVE 1 TO L-ACTION
             MOVE L-KEY TO L-NEW
         WHEN L-AIR = 1 AND (L-SUPPORT = 1 OR L-FLAMMABLE = 1 OR L-SOUL = 1)
             MOVE 2 TO L-ACTION
             IF L-SOUL = 1
                 MOVE "soul_fire" TO L-NEW
             ELSE
                 MOVE "fire" TO L-NEW
             END-IF
     END-EVALUATE
     IF L-ACTION > 0
         IF L-ITEM = "fire_charge"
             MOVE "item.firecharge.use" TO L-SOUND
             IF L-CREATIVE = 0
                 MOVE 1 TO L-CONSUME
             END-IF
         ELSE
             MOVE "item.flintandsteel.use" TO L-SOUND
             IF L-CREATIVE = 0
                 MOVE 1 TO L-DAMAGE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-FIRE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-FIRE-PITCH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ITEM                 PIC X(16).
 01 L-R1                   BINARY-LONG.
 01 L-R2                   BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-R1 L-R2 L-PITCH.
     IF L-ITEM = "fire_charge"
         COMPUTE L-PITCH = 1000 + (L-R1 - L-R2) * 200 / 1000
     ELSE
         COMPUTE L-PITCH = 800 + L-R1 * 400 / 1000
     END-IF
     GOBACK.
 END PROGRAM TOOL-FIRE-PITCH.
