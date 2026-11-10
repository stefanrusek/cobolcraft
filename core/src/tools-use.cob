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

*> Section 3.4 (bone meal):
*>   TOOL-BONEMEAL-USE USING valid target, growth succeeded, clicked face sturdy, creative, action out (0 nothing, 1 grow the target, 2 water
*>     plants beside the face), stack shrink out, grown out, level event out (1505), event data out (15)
*>   TOOL-BONEMEAL-STEPS USING attempt (0 to 127), steps out (attempt / 16)
*>   TOOL-BONEMEAL-STEP USING roll x, roll y1, roll y2, roll z (nextInt(3) each, 0 to 2), dx out, dy out, dz out
*>   TOOL-BONEMEAL-PLANT USING attempt, horizontal clicked face, coral biome (tag produces_corals_from_bonemeal), roll (nextInt(4)), kind out
*>     (seagrass, wall_coral, underwater_bonemeal)
*>   TOOL-BONEMEAL-SEAGRASS USING roll (nextInt(10)), grows out (1 when 0)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BONEMEAL-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-SHRINK               BINARY-LONG.
 01 L-GROWN                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-VALID L-SUCCESS L-STURDY L-CREATIVE L-ACTION L-SHRINK L-GROWN L-EVENT L-DATA.
     MOVE 0 TO L-ACTION L-SHRINK L-GROWN L-EVENT L-DATA
     EVALUATE TRUE
         WHEN L-VALID = 1
             MOVE 1 TO L-ACTION
             MOVE L-SUCCESS TO L-GROWN
         WHEN L-STURDY = 1
             MOVE 2 TO L-ACTION
     END-EVALUATE
     IF L-ACTION > 0
         MOVE 1505 TO L-EVENT
         MOVE 15 TO L-DATA
         IF L-CREATIVE = 0
             MOVE 1 TO L-SHRINK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-BONEMEAL-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BONEMEAL-STEPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTEMPT              BINARY-LONG.
 01 L-STEPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTEMPT L-STEPS.
     COMPUTE L-STEPS = L-ATTEMPT / 16
     GOBACK.
 END PROGRAM TOOL-BONEMEAL-STEPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BONEMEAL-STEP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RX                   BINARY-LONG.
 01 L-RY1                  BINARY-LONG.
 01 L-RY2                  BINARY-LONG.
 01 L-RZ                   BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RX L-RY1 L-RY2 L-RZ L-DX L-DY L-DZ.
     COMPUTE L-DX = L-RX - 1
     COMPUTE L-DY = (L-RY1 - 1) * L-RY2 / 2
     COMPUTE L-DZ = L-RZ - 1
     GOBACK.
 END PROGRAM TOOL-BONEMEAL-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BONEMEAL-PLANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTEMPT              BINARY-LONG.
 01 L-HORIZONTAL           BINARY-LONG.
 01 L-CORAL                BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-KIND                 PIC X(48).
 PROCEDURE DIVISION USING L-ATTEMPT L-HORIZONTAL L-CORAL L-ROLL L-KIND.
     MOVE "seagrass" TO L-KIND
     IF L-CORAL = 1
         IF L-ATTEMPT = 0 AND L-HORIZONTAL = 1
             MOVE "wall_coral" TO L-KIND
         ELSE
             IF L-ROLL = 0
                 MOVE "underwater_bonemeal" TO L-KIND
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-BONEMEAL-PLANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BONEMEAL-SEAGRASS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROLL                 BINARY-LONG.
 01 L-GROWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL L-GROWS.
     MOVE 0 TO L-GROWS
     IF L-ROLL = 0
         MOVE 1 TO L-GROWS
     END-IF
     GOBACK.
 END PROGRAM TOOL-BONEMEAL-SEAGRASS.

*> Section 3.5 (brush):
*>   TOOL-BRUSH-INFO USING use duration, brushes to break, cooldown ticks, reset ticks, durability (BINARY-LONG each, out)
*>   TOOL-BRUSH-DUSTED USING brushes, dusted out (0 to 3)
*>   TOOL-BRUSH-COUNT USING brushes, ticks since the last counted brush, new brushes out, result out (0 cooldown, 1 counted, 2 completed),
*>     durability damage out (1 only on completion)
*>   TOOL-BRUSH-RESET USING ticks since the last brush, reset out (1 at 40 or more)
*>   TOOL-BRUSH-TICK USING remaining use ticks, brush out (1 when the used ticks modulo 10 equal 5)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BRUSH-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DURATION             BINARY-LONG.
 01 L-NEEDED               BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 01 L-DURABILITY           BINARY-LONG.
 PROCEDURE DIVISION USING L-DURATION L-NEEDED L-COOLDOWN L-RESET L-DURABILITY.
     MOVE 200 TO L-DURATION
     MOVE 10 TO L-NEEDED L-COOLDOWN
     MOVE 40 TO L-RESET
     MOVE 64 TO L-DURABILITY
     GOBACK.
 END PROGRAM TOOL-BRUSH-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BRUSH-DUSTED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BRUSHES              BINARY-LONG.
 01 L-DUSTED               BINARY-LONG.
 PROCEDURE DIVISION USING L-BRUSHES L-DUSTED.
     EVALUATE TRUE
         WHEN L-BRUSHES = 0
             MOVE 0 TO L-DUSTED
         WHEN L-BRUSHES <= 2
             MOVE 1 TO L-DUSTED
         WHEN L-BRUSHES <= 5
             MOVE 2 TO L-DUSTED
         WHEN OTHER
             MOVE 3 TO L-DUSTED
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-BRUSH-DUSTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BRUSH-COUNT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BRUSHES              BINARY-LONG.
 01 L-SINCE                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-BRUSHES L-SINCE L-NEW L-RESULT L-DAMAGE.
     MOVE L-BRUSHES TO L-NEW
     MOVE 0 TO L-RESULT L-DAMAGE
     IF L-SINCE >= 10
         ADD 1 TO L-NEW
         MOVE 1 TO L-RESULT
         IF L-NEW >= 10
             MOVE 2 TO L-RESULT
             MOVE 1 TO L-DAMAGE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-BRUSH-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BRUSH-RESET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SINCE                BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 PROCEDURE DIVISION USING L-SINCE L-RESET.
     MOVE 0 TO L-RESET
     IF L-SINCE >= 40
         MOVE 1 TO L-RESET
     END-IF
     GOBACK.
 END PROGRAM TOOL-BRUSH-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BRUSH-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-USED                BINARY-LONG.
 LINKAGE SECTION.
 01 L-REMAINING            BINARY-LONG.
 01 L-BRUSH                BINARY-LONG.
 PROCEDURE DIVISION USING L-REMAINING L-BRUSH.
     COMPUTE WS-USED = 200 - L-REMAINING + 1
     MOVE 0 TO L-BRUSH
     IF FUNCTION MOD(WS-USED, 10) = 5
         MOVE 1 TO L-BRUSH
     END-IF
     GOBACK.
 END PROGRAM TOOL-BRUSH-TICK.

*> Section 3.6 (shield):
*>   TOOL-SHIELD-BLOCKING USING ticks used, blocking out (1 from 5 ticks)
*>   TOOL-SHIELD-ANGLE USING source has a position, head yaw (degrees), dx, dz (source minus blocker, any scale), inside out (angle <= 90)
*>   TOOL-SHIELD-RESOLVE USING damage (thousandths), bypassed, piercing arrow, blocking, inside, blocked out, remaining out, shield damage
*>     out (0 under 3.0, else floor(1 + damage)), push attacker out (0: a full block pushes nothing)
*>   TOOL-SHIELD-DISABLE USING disable seconds (thousandths), cooldown scale (thousandths), cooldown ticks out
*>   TOOL-SHIELD-STAT USING blocked (thousandths), stat out (round(blocked x 10))
*>   TOOL-SHIELD-PITCH USING roll (0 to 999), pitch out (thousandths)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHIELD-BLOCKING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-BLOCKING             BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKS L-BLOCKING.
     MOVE 0 TO L-BLOCKING
     IF L-TICKS >= 5
         MOVE 1 TO L-BLOCKING
     END-IF
     GOBACK.
 END PROGRAM TOOL-SHIELD-BLOCKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHIELD-ANGLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-YAW                  BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-YAW L-DX L-DZ L-INSIDE.
     MOVE 0 TO L-INSIDE
     IF L-HAS = 1
         COMPUTE WS-RAD = L-YAW * 0.017453292519943295
         COMPUTE WS-DOT = (0 - FUNCTION SIN(WS-RAD)) * L-DX + FUNCTION COS(WS-RAD) * L-DZ
         IF WS-DOT >= -0.000001
             MOVE 1 TO L-INSIDE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-SHIELD-ANGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHIELD-RESOLVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DAMAGE               BINARY-LONG.
 01 L-BYPASSED             BINARY-LONG.
 01 L-PIERCING             BINARY-LONG.
 01 L-BLOCKING             BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 01 L-BLOCKED              BINARY-LONG.
 01 L-REMAINING            BINARY-LONG.
 01 L-SHIELD               BINARY-LONG.
 01 L-PUSH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DAMAGE L-BYPASSED L-PIERCING L-BLOCKING L-INSIDE L-BLOCKED L-REMAINING L-SHIELD L-PUSH.
     MOVE 0 TO L-BLOCKED L-SHIELD L-PUSH
     MOVE L-DAMAGE TO L-REMAINING
     IF L-BLOCKING = 1 AND L-BYPASSED = 0 AND L-PIERCING = 0 AND L-INSIDE = 1
         MOVE L-DAMAGE TO L-BLOCKED
         MOVE 0 TO L-REMAINING
         IF L-DAMAGE >= 3000
             COMPUTE L-SHIELD = 1 + L-DAMAGE / 1000
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-SHIELD-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHIELD-DISABLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SECONDS              BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SECONDS L-SCALE L-TICKS.
     COMPUTE L-TICKS ROUNDED = L-SECONDS * 20 * L-SCALE / 1000000
     GOBACK.
 END PROGRAM TOOL-SHIELD-DISABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHIELD-STAT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCKED              BINARY-LONG.
 01 L-STAT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCKED L-STAT.
     COMPUTE L-STAT ROUNDED = L-BLOCKED / 100
     GOBACK.
 END PROGRAM TOOL-SHIELD-STAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SHIELD-PITCH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROLL                 BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL L-PITCH.
     COMPUTE L-PITCH = 800 + L-ROLL * 400 / 1000
     GOBACK.
 END PROGRAM TOOL-SHIELD-PITCH.

*> Section 3.7 (lead, name tag, saddle):
*>   TOOL-LEAD-INFO USING half side of the search cube, break distance, elastic distance (thousandths of a block)
*>   TOOL-LEAD-BIND USING block key, holder is the player, mob can have a leash (1 or 0 each), binds out (the fence is in tag fences)
*>   TOOL-NAMETAG-USE USING stack has a custom name, entity can serialize, creative, applied out, persistent out, consumed out
*>   TOOL-SADDLE-USE USING entity in tag can_equip_saddle, saddle slot empty, equipped out, split out
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-LEAD-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HALF                 BINARY-LONG.
 01 L-BREAK                BINARY-LONG.
 01 L-ELASTIC              BINARY-LONG.
 PROCEDURE DIVISION USING L-HALF L-BREAK L-ELASTIC.
     MOVE 16000 TO L-HALF
     MOVE 12000 TO L-BREAK
     MOVE 6000 TO L-ELASTIC
     GOBACK.
 END PROGRAM TOOL-LEAD-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-LEAD-BIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-HOLDER               BINARY-LONG.
 01 L-LEASHABLE            BINARY-LONG.
 01 L-BINDS                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-HOLDER L-LEASHABLE L-BINDS.
     MOVE 0 TO L-BINDS WS-HITS
     INSPECT L-KEY TALLYING WS-HITS FOR ALL "_fence "
     IF WS-HITS > 0 AND L-HOLDER = 1 AND L-LEASHABLE = 1
         MOVE 1 TO L-BINDS
     END-IF
     GOBACK.
 END PROGRAM TOOL-LEAD-BIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-NAMETAG-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAMED                BINARY-LONG.
 01 L-SERIALIZE            BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-APPLIED              BINARY-LONG.
 01 L-PERSISTENT           BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 PROCEDURE DIVISION USING L-NAMED L-SERIALIZE L-CREATIVE L-APPLIED L-PERSISTENT L-CONSUMED.
     MOVE 0 TO L-APPLIED L-PERSISTENT L-CONSUMED
     IF L-NAMED = 1 AND L-SERIALIZE = 1
         MOVE 1 TO L-APPLIED L-PERSISTENT
         IF L-CREATIVE = 0
             MOVE 1 TO L-CONSUMED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-NAMETAG-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SADDLE-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALLOWED              BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-EQUIPPED             BINARY-LONG.
 01 L-SPLIT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ALLOWED L-EMPTY L-EQUIPPED L-SPLIT.
     MOVE 0 TO L-EQUIPPED L-SPLIT
     IF L-ALLOWED = 1 AND L-EMPTY = 1
         MOVE 1 TO L-EQUIPPED L-SPLIT
     END-IF
     GOBACK.
 END PROGRAM TOOL-SADDLE-USE.

*> Section 3.8 (buckets):
*>   TOOL-BUCKET-INFO USING item key, stack size out (0 not a bucket; 16 for the empty bucket, 1 filled), remainder out ("bucket" for a filled
*>     one, "-"), fuel out (lava_bucket)
*>   TOOL-BUCKET-PLACE USING clicked block replaceable, clicked block is a container that accepts the fluid, water evaporates here,
*>     position out (0 the clicked block, 1 beside the face), placed out (0 when the contents evaporate)
*>   TOOL-BUCKET-FILL USING fluid key (water, lava, powder_snow), bucket out ("-" none)
*>   TOOL-MILK-INFO USING drink ticks, clears all effects, remainder (PIC X(48)) out
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BUCKET-INFO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-STACK                BINARY-LONG.
 01 L-REMAINDER            PIC X(48).
 01 L-FUEL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-STACK L-REMAINDER L-FUEL.
     MOVE 0 TO L-STACK L-FUEL WS-HITS
     MOVE "-" TO L-REMAINDER
     INSPECT L-KEY TALLYING WS-HITS FOR ALL "_bucket "
     EVALUATE TRUE
         WHEN L-KEY = "bucket"
             MOVE 16 TO L-STACK
         WHEN WS-HITS > 0
             MOVE 1 TO L-STACK
             MOVE "bucket" TO L-REMAINDER
             IF L-KEY = "lava_bucket"
                 MOVE 1 TO L-FUEL
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-BUCKET-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BUCKET-PLACE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REPLACEABLE          BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-EVAPORATES           BINARY-LONG.
 01 L-POSITION             BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-REPLACEABLE L-CONTAINER L-EVAPORATES L-POSITION L-PLACED.
     MOVE 0 TO L-POSITION
     MOVE 1 TO L-PLACED
     IF L-REPLACEABLE = 0 AND L-CONTAINER = 0
         MOVE 1 TO L-POSITION
     END-IF
     IF L-EVAPORATES = 1
         MOVE 0 TO L-PLACED
     END-IF
     GOBACK.
 END PROGRAM TOOL-BUCKET-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BUCKET-FILL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                PIC X(48).
 01 L-BUCKET               PIC X(48).
 PROCEDURE DIVISION USING L-FLUID L-BUCKET.
     MOVE "-" TO L-BUCKET
     IF L-FLUID = "water" OR "lava" OR "powder_snow"
         STRING FUNCTION TRIM(L-FLUID) "_bucket" DELIMITED BY SIZE INTO L-BUCKET
     END-IF
     GOBACK.
 END PROGRAM TOOL-BUCKET-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-MILK-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-CLEARS               BINARY-LONG.
 01 L-REMAINDER            PIC X(48).
 PROCEDURE DIVISION USING L-TICKS L-CLEARS L-REMAINDER.
     MOVE 32 TO L-TICKS
     MOVE 1 TO L-CLEARS
     MOVE "bucket" TO L-REMAINDER
     GOBACK.
 END PROGRAM TOOL-MILK-INFO.

*> Section 3.9 (bow and crossbow):
*>   TOOL-BOW-POWER USING ticks used, power out (thousandths of min((f f + 2 f) / 3, 1), f = ticks / 20), velocity out (3.0 x power)
*>   TOOL-BOW-SHOT USING ticks used, infinity, creative, shoots out (power >= 0.1), ammo consumed out, durability out, crit out (power 1.0)
*>   TOOL-ARROW-DAMAGE USING speed (thousandths), base damage (thousandths), crit, roll (nextInt(damage / 2 + 2)), damage out
*>   TOOL-CROSSBOW-CHARGE USING quick charge level, ticks out (floor(20 (1.25 - 0.25 level)))
*>   TOOL-CROSSBOW-ANGLE USING projectile count, index, degrees out (0, then alternating -step and +step, step = 2 x 10 / (n - 1))
*>   TOOL-CROSSBOW-SHOT USING firework, durability out (1; 3 for a firework), power out (3150; 1600 for a firework)
*>   TOOL-CROSSBOW-READY USING use ticks, charge ticks, loaded out
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BOW-POWER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-VELOCITY             BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKS L-POWER L-VELOCITY.
     COMPUTE WS-V = (L-TICKS * L-TICKS / 400 + L-TICKS / 10) * 1000
     IF WS-V > 3000
         MOVE 3000 TO WS-V
     END-IF
     MOVE WS-V TO L-VELOCITY
     COMPUTE L-POWER = WS-V / 3
     IF WS-V = 3000
         MOVE 1000 TO L-POWER
     END-IF
     GOBACK.
 END PROGRAM TOOL-BOW-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-BOW-SHOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POWER               BINARY-LONG.
 01 WS-VELOCITY            BINARY-LONG.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-INFINITY             BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-SHOOTS               BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 01 L-DURABILITY           BINARY-LONG.
 01 L-CRIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKS L-INFINITY L-CREATIVE L-SHOOTS L-CONSUMED L-DURABILITY L-CRIT.
     MOVE 0 TO L-SHOOTS L-CONSUMED L-DURABILITY L-CRIT
     CALL "TOOL-BOW-POWER" USING L-TICKS WS-POWER WS-VELOCITY
     IF WS-POWER >= 100
         MOVE 1 TO L-SHOOTS L-DURABILITY
         IF L-INFINITY = 0 AND L-CREATIVE = 0
             MOVE 1 TO L-CONSUMED
         END-IF
         IF WS-POWER = 1000
             MOVE 1 TO L-CRIT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-BOW-SHOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ARROW-DAMAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PRODUCT             BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-SPEED                BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-CRIT                 BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SPEED L-BASE L-CRIT L-ROLL L-DAMAGE.
     COMPUTE WS-PRODUCT = L-SPEED * L-BASE
     COMPUTE L-DAMAGE = (WS-PRODUCT + 999999) / 1000000
     IF L-CRIT = 1
         ADD L-ROLL TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM TOOL-ARROW-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-CROSSBOW-CHARGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-TICKS.
     COMPUTE L-TICKS = 25 - 5 * L-LEVEL
     GOBACK.
 END PROGRAM TOOL-CROSSBOW-CHARGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-CROSSBOW-ANGLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DEGREES              BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-INDEX L-DEGREES.
     MOVE 0 TO L-DEGREES
     IF L-COUNT > 1 AND L-INDEX > 0
         COMPUTE WS-STEP = 20 / (L-COUNT - 1)
         COMPUTE WS-K = (L-INDEX + 1) / 2
         COMPUTE L-DEGREES = WS-K * WS-STEP
         IF FUNCTION MOD(L-INDEX, 2) = 1
             COMPUTE L-DEGREES = 0 - L-DEGREES
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-CROSSBOW-ANGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-CROSSBOW-SHOT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIREWORK             BINARY-LONG.
 01 L-DURABILITY           BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-FIREWORK L-DURABILITY L-POWER.
     MOVE 1 TO L-DURABILITY
     MOVE 3150 TO L-POWER
     IF L-FIREWORK = 1
         MOVE 3 TO L-DURABILITY
         MOVE 1600 TO L-POWER
     END-IF
     GOBACK.
 END PROGRAM TOOL-CROSSBOW-SHOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-CROSSBOW-READY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-USE                  BINARY-LONG.
 01 L-CHARGE               BINARY-LONG.
 01 L-LOADED               BINARY-LONG.
 PROCEDURE DIVISION USING L-USE L-CHARGE L-LOADED.
     MOVE 0 TO L-LOADED
     IF L-USE >= L-CHARGE
         MOVE 1 TO L-LOADED
     END-IF
     GOBACK.
 END PROGRAM TOOL-CROSSBOW-READY.
