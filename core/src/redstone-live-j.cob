*> Live redstone, the registered behaviours of the dispenser (docs/protocol/30-redstone-4 section 4) other than TNT (redstone-live-e.cob): flint and steel (4.10), bone meal (4.13), the water and lava buckets and
*> the empty bucket (4.5, 4.6), spawn eggs (4.11), minecarts (4.22), the armor stand (4.2), boats and rafts (4.4), honeycomb (4.20) and the projectiles egg, snowball and experience bottle (4.1; shoot noise of the
*> thrown items' own source THROWN-JITTER, not the projectile's java.util.Random; the random yaw draw of 4.2 is not made; a boat or minecart that falls back to the default drop plays the click and the smoke once,
*> not twice). An item without one of these behaviours is dropped (the default behaviour, 2).
*> Not done: the other projectiles (arrows, potions, fire charge, wind charge, firework: 4.1), chest (4.3), wither skull and carved pumpkin (4.7, 4.8), equipment (4.9), the sulfur cube swallowing (4.12), shulker boxes (4.15), glass bottle
*> (4.16), glowstone (4.17), shears (4.18), brush (4.19), the water potion (4.21); the fire placement of flint and steel uses "air above a block with a collision" for
*> BaseFireBlock.canBePlacedAt, and the flint and steel is not damaged (hurtAndBreak needs a durability component write that dispenser slots do not carry); a bucket's fish and other contents are not placed;
*> the game events (block_place, block_change, entity_place, fluid_pickup) have no listener in this core.
*> Entry points:
*>   RL-DISP-BEHAVE USING dim, front x, y, z, facing, item, variant, handled out, consumed out, remainder out (item id + 1, 0 none)
*>      handled 1 when a registered behaviour ran (its success is `consumed`: 1 the dispenser spends one item, 0 the dry click 1001 and the item stays, 2 handled and the item stays, 3 the item is spent and
*>      the sound is the launch 1002), handled 0 for the default behaviour

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-ITEM-ID-OF.
*> USING item key (PIC X(48), bare), item id out (-1 when the open table has no such item).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-I                   BINARY-LONG.
 01 WS-BARE                PIC X(48).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         CALL "KEY-BARE" USING IT-KEY(WS-I) WS-BARE
         IF WS-BARE = L-KEY
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-ITEM-ID-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DISP-BEHAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY CORESTATE.
 01 WS-LIT                 PIC X(16) VALUE "lit".
 01 WS-FALSE               PIC X(16) VALUE "false".
 01 WS-TRUE                PIC X(16) VALUE "true".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-LEVEL               PIC X(16) VALUE "level".
 01 WS-AGE                 PIC X(16) VALUE "age".
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-AGE-NAME            PIC X(24) VALUE "age".
 01 WS-WAX-SOUND           PIC X(48) VALUE "item.honeycomb.wax_on".
 LOCAL-STORAGE SECTION.
 01 LS-KEY                 PIC X(48).
 01 LS-BARE                PIC X(48).
 01 LS-LEN                 BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-BKEY                PIC X(48).
 01 LS-BBARE               PIC X(48).
 01 LS-BLEN                BINARY-LONG.
 01 LS-BELOW               BINARY-LONG.
 01 LS-BY                  BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-OLD                 PIC X(16).
 01 LS-FLAGS               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-WATER               BINARY-LONG.
 01 LS-LAVA                BINARY-LONG.
 01 LS-WATER-FIRST         BINARY-LONG.
 01 LS-LAVA-FIRST          BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-FIRST               BINARY-LONG.
 01 LS-AGE                 BINARY-LONG.
 01 LS-MAX                 BINARY-LONG.
 01 LS-FOUR                BINARY-LONG VALUE 4.
 01 LS-DRAW                BINARY-LONG.
 01 LS-VALID               BINARY-LONG.
 01 LS-NEW-AGE             BINARY-LONG.
 01 LS-EVENT               BINARY-LONG VALUE 1505.
 01 LS-DATA                BINARY-LONG VALUE 15.
 01 LS-NONE                BINARY-LONG VALUE 0.
 01 LS-REMAINDER-KEY       PIC X(48).
 01 LS-ID                  BINARY-LONG.
 01 LS-TYPE-KEY            PIC X(112).
 01 LS-TYPE                BINARY-LONG.
 01 LS-FX                  FLOAT-LONG.
 01 LS-FY                  FLOAT-LONG.
 01 LS-FZ                  FLOAT-LONG.
 01 LS-YAW                 FLOAT-SHORT VALUE 0.
 01 LS-ROW                 BINARY-LONG.
 01 LS-CART                BINARY-LONG.
 01 LS-NAME-HITS           BINARY-LONG.
 01 LS-OFFSET              FLOAT-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-YAWL                FLOAT-LONG.
 01 LS-WIDTH               FLOAT-LONG.
 01 LS-CX                  FLOAT-LONG.
 01 LS-CY                  FLOAT-LONG.
 01 LS-CZ                  FLOAT-LONG.
 01 LS-VX                  FLOAT-LONG.
 01 LS-VY                  FLOAT-LONG.
 01 LS-VZ                  FLOAT-LONG.
 01 LS-POWER               FLOAT-LONG.
 01 LS-UNCERTAIN           FLOAT-LONG.
 01 LS-PJ                  BINARY-LONG.
 01 LS-FAMILY              BINARY-LONG.
 01 LS-BASE                BINARY-LONG VALUE 2000.
 01 LS-NEW-KEY             PIC X(48).
 01 LS-ROW-TEXT            PIC X(819).
 01 LS-STATUS              BINARY-LONG.
 01 LS-WAX-ON              BINARY-LONG VALUE 1.
 01 LS-WAX-EVENT           BINARY-LONG VALUE 3003.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-SOURCE-BLOCKS       BINARY-LONG VALUE 4.
 01 LS-VOLUME              BINARY-LONG VALUE 1000000.
 01 LS-PITCH               BINARY-LONG VALUE 1000000.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 01 L-REMAINDER            BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-ITEM L-VAR L-HANDLED L-CONSUMED L-REMAINDER.
     MOVE 0 TO L-HANDLED L-CONSUMED L-REMAINDER
     MOVE IT-KEY(L-ITEM + 1) TO LS-KEY
     CALL "KEY-BARE" USING LS-KEY LS-BARE
     COMPUTE LS-LEN = FUNCTION LENGTH(FUNCTION TRIM(LS-BARE))
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-STATE
     MOVE CB-S-BLOCK(LS-STATE + 1) TO LS-BLOCK
     MOVE CB-KEY(LS-BLOCK + 1) TO LS-BKEY
     CALL "KEY-BARE" USING LS-BKEY LS-BBARE
     COMPUTE LS-BLEN = FUNCTION LENGTH(FUNCTION TRIM(LS-BBARE))
     COMPUTE LS-BY = L-Y - 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X LS-BY L-Z LS-BELOW
     CALL "FLUID-ROLES" USING LS-WATER LS-LAVA LS-WATER-FIRST LS-LAVA-FIRST
*>   facing.toYRot (south 0, west 90, north 180, east 270; up and down 0)
     EVALUATE L-FACING
         WHEN 2
             MOVE 180 TO LS-YAWL
         WHEN 4
             MOVE 90 TO LS-YAWL
         WHEN 5
             MOVE 270 TO LS-YAWL
         WHEN OTHER
             MOVE 0 TO LS-YAWL
     END-EVALUATE
     CALL "RS1-STEP" USING L-FACING LS-DX LS-DY LS-DZ
     EVALUATE TRUE
         WHEN LS-BARE = "flint_and_steel"
*>           4.10: fire in air above a solid block; a campfire or candle lights; TNT primes and goes; otherwise the dry click
             MOVE 1 TO L-HANDLED
             MOVE 0 TO L-CONSUMED
             MOVE 0 TO LS-OK
             IF LS-STATE = 0 AND CB-SOLID(CB-S-BLOCK(LS-BELOW + 1) + 1) = 1
                 MOVE 0 TO LS-FIRST
                 PERFORM VARYING LS-ID FROM 1 BY 1 UNTIL LS-ID > CB-BLOCK-COUNT
                     CALL "KEY-BARE" USING CB-KEY(LS-ID) LS-BBARE
                     IF LS-BBARE = "fire"
                         MOVE LS-ID TO LS-FIRST
                     END-IF
                 END-PERFORM
                 IF LS-FIRST > 0
                     MOVE CB-DEFAULT-STATE(LS-FIRST) TO LS-NEW
                     MOVE 3 TO LS-FLAGS
                     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                     MOVE 1 TO LS-OK
                 END-IF
             END-IF
             IF LS-OK = 0 AND (LS-BBARE = "campfire" OR LS-BBARE = "soul_campfire" OR LS-BBARE = "candle"
                     OR (LS-BLEN >= 7 AND LS-BBARE(LS-BLEN - 6:7) = "_candle")
                     OR (LS-BLEN >= 11 AND LS-BBARE(LS-BLEN - 10:11) = "candle_cake"))
                 CALL "SW-SET-PROP" USING LS-STATE WS-LIT WS-KEEP LS-NEW LS-OLD
                 IF LS-OLD = "false"
                     CALL "SW-SET-PROP" USING LS-STATE WS-LIT WS-TRUE LS-NEW LS-OLD
                     MOVE 3 TO LS-FLAGS
                     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                     MOVE 1 TO LS-OK
                 END-IF
             END-IF
             IF LS-OK = 0 AND LS-BBARE = "tnt"
                 CALL "TNT-DISPENSE" USING L-DIM L-X L-Y L-Z LS-OK
                 IF LS-OK = 1
                     CALL "LEVEL-REMOVE-BLOCK" USING L-DIM L-X L-Y L-Z LS-NONE LS-RESULT
                 END-IF
             END-IF
             MOVE LS-OK TO L-CONSUMED
*>           the flint and steel is never spent from the slot (only worn, which is not done): consumed 2 says handled, no decrement
             IF LS-OK = 1
                 MOVE 2 TO L-CONSUMED
             END-IF
         WHEN LS-BARE = "bone_meal"
*>           4.13: a crop below its last age grows (a level event 1505 with 15); else the dry click
             MOVE 1 TO L-HANDLED
             MOVE CB-KEY(LS-BLOCK + 1) TO LS-BKEY
             CALL "GB-GROWTH-KIND" USING LS-BKEY LS-KIND
             MOVE CB-FIRST-STATE(LS-BLOCK + 1) TO LS-FIRST
             COMPUTE LS-AGE = LS-STATE - LS-FIRST
             COMPUTE LS-MAX = CB-STATES(LS-BLOCK + 1) - 1
             IF LS-KIND = 1 AND LS-AGE < LS-MAX
                 MOVE 1 TO LS-VALID
                 CALL "LEVEL-RANDOM-INT" USING LS-FOUR LS-DRAW
                 CALL "GB-CROP-BONEMEAL" USING LS-AGE LS-MAX LS-DRAW LS-VALID LS-NEW-AGE
                 COMPUTE LS-NEW = LS-FIRST + LS-NEW-AGE
                 MOVE 2 TO LS-FLAGS
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "LEVEL-EVENT" USING L-DIM LS-EVENT L-X L-Y L-Z LS-DATA LS-NONE
                 MOVE 1 TO L-CONSUMED
             END-IF
         WHEN (LS-BARE = "water_bucket" OR LS-BARE = "lava_bucket")
*>           4.5: the fluid goes into an air or replaceable cell; the empty bucket comes back
             IF LS-STATE = 0 OR CB-REPLACEABLE(LS-BLOCK + 1) = 1
                 MOVE 1 TO L-HANDLED L-CONSUMED
                 MOVE LS-WATER-FIRST TO LS-NEW
                 IF LS-BARE = "lava_bucket"
                     MOVE LS-LAVA-FIRST TO LS-NEW
                 END-IF
                 MOVE 3 TO LS-FLAGS
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                 MOVE "bucket" TO LS-REMAINDER-KEY
                 CALL "RL-ITEM-ID-OF" USING LS-REMAINDER-KEY LS-ID
                 COMPUTE L-REMAINDER = LS-ID + 1
             END-IF
         WHEN LS-BARE = "bucket"
*>           4.6: a fluid source is picked up and the filled bucket comes back; any other block: the default drop
             IF LS-STATE = LS-WATER-FIRST OR LS-STATE = LS-LAVA-FIRST
                 MOVE 1 TO L-HANDLED L-CONSUMED
                 MOVE "water_bucket" TO LS-REMAINDER-KEY
                 IF LS-STATE = LS-LAVA-FIRST
                     MOVE "lava_bucket" TO LS-REMAINDER-KEY
                 END-IF
                 MOVE 0 TO LS-NEW
                 MOVE 3 TO LS-FLAGS
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "RL-ITEM-ID-OF" USING LS-REMAINDER-KEY LS-ID
                 COMPUTE L-REMAINDER = LS-ID + 1
             END-IF
         WHEN LS-LEN >= 10 AND LS-BARE(LS-LEN - 9:10) = "_spawn_egg"
*>           4.11: the mob of the egg appears at the front cell
             MOVE SPACES TO LS-TYPE-KEY
             COMPUTE LS-LEN = LS-LEN - 10
             STRING "minecraft:" LS-BARE(1:LS-LEN) DELIMITED BY SIZE INTO LS-TYPE-KEY
             CALL "THROWN-TYPE" USING LS-TYPE-KEY LS-TYPE
             IF LS-TYPE > 0
                 COMPUTE LS-FX = L-X + 0.5
                 MOVE L-Y TO LS-FY
                 COMPUTE LS-FZ = L-Z + 0.5
                 MOVE 0 TO LS-ROW
                 CALL "MOB-SPAWN" USING L-DIM LS-TYPE LS-FX LS-FY LS-FZ LS-YAW LS-ROW
                 IF LS-ROW > 0
                     MOVE 1 TO L-HANDLED L-CONSUMED
                 END-IF
             END-IF
         WHEN LS-BARE = "minecart" OR LS-BARE = "chest_minecart" OR LS-BARE = "hopper_minecart" OR LS-BARE = "furnace_minecart"
                 OR LS-BARE = "tnt_minecart" OR LS-BARE = "command_block_minecart"
*>           4.22: only onto a rail (offset 0.1) or above a rail (offset -0.9); any other cell: the default drop
             MOVE 0 TO LS-OK
             IF LS-BLEN >= 4 AND LS-BBARE(LS-BLEN - 3:4) = "rail"
                 MOVE 1 TO LS-OK
                 MOVE 0.1 TO LS-OFFSET
             END-IF
             IF LS-STATE = 0
                 MOVE CB-KEY(CB-S-BLOCK(LS-BELOW + 1) + 1) TO LS-BKEY
                 CALL "KEY-BARE" USING LS-BKEY LS-BBARE
                 COMPUTE LS-BLEN = FUNCTION LENGTH(FUNCTION TRIM(LS-BBARE))
                 IF LS-BLEN >= 4 AND LS-BBARE(LS-BLEN - 3:4) = "rail"
                     MOVE 1 TO LS-OK
                     MOVE -0.9 TO LS-OFFSET
                 END-IF
             END-IF
             IF LS-OK = 1
                 EVALUATE LS-BARE
                     WHEN "minecart"
                         MOVE 1 TO LS-CART
                     WHEN "chest_minecart"
                         MOVE 2 TO LS-CART
                     WHEN "hopper_minecart"
                         MOVE 3 TO LS-CART
                     WHEN "furnace_minecart"
                         MOVE 4 TO LS-CART
                     WHEN "tnt_minecart"
                         MOVE 5 TO LS-CART
                     WHEN OTHER
                         MOVE 7 TO LS-CART
                 END-EVALUATE
                 COMPUTE LS-FX = L-X + 0.5
                 COMPUTE LS-FY = L-Y + LS-OFFSET
                 COMPUTE LS-FZ = L-Z + 0.5
                 MOVE 0 TO LS-ROW
                 CALL "MINECART-SPAWN" USING LS-CART L-DIM LS-FX LS-FY LS-FZ LS-ROW
                 IF LS-ROW > 0
                     MOVE 1 TO L-HANDLED L-CONSUMED
                 END-IF
             END-IF
         WHEN LS-BARE = "armor_stand"
*>           4.2: an armor stand at the bottom centre of the front cell, looking the way the dispenser points
             COMPUTE LS-FX = L-X + 0.5
             MOVE L-Y TO LS-FY
             COMPUTE LS-FZ = L-Z + 0.5
             MOVE 0 TO LS-ROW
             CALL "ARMOR-STAND-SPAWN" USING L-DIM LS-FX LS-FY LS-FZ LS-YAWL LS-ROW
             IF LS-ROW > 0
                 MOVE 1 TO L-HANDLED L-CONSUMED
             END-IF
         WHEN LS-LEN >= 5 AND (LS-BARE(LS-LEN - 4:5) = "_boat" OR LS-BARE(LS-LEN - 4:5) = "_raft")
*>           4.4: a boat or raft only onto water (offset 1.0) or air above water (offset 0), d = 0.5625 + width / 2 in front of the dispenser's centre; any other cell: the default drop
             MOVE SPACES TO LS-TYPE-KEY
             STRING "minecraft:" LS-BARE(1:LS-LEN) DELIMITED BY SIZE INTO LS-TYPE-KEY
             CALL "THROWN-TYPE" USING LS-TYPE-KEY LS-TYPE
             MOVE 0 TO LS-OK
             IF CB-S-BLOCK(LS-STATE + 1) = LS-WATER
                 MOVE 1 TO LS-OK
                 MOVE 1.0 TO LS-OFFSET
             END-IF
             IF LS-OK = 0 AND LS-STATE = 0 AND CB-S-BLOCK(LS-BELOW + 1) = LS-WATER
                 MOVE 1 TO LS-OK
                 MOVE 0 TO LS-OFFSET
             END-IF
             IF LS-OK = 1 AND LS-TYPE > 0
                 COMPUTE LS-WIDTH = 0.5625 + ET-WIDTH-MILLI(LS-TYPE + 1) / 2000
                 COMPUTE LS-CX = L-X - LS-DX + 0.5
                 COMPUTE LS-CY = L-Y - LS-DY + 0.5
                 COMPUTE LS-CZ = L-Z - LS-DZ + 0.5
                 COMPUTE LS-FX = LS-CX + LS-DX * LS-WIDTH
                 COMPUTE LS-FY = LS-CY + LS-DY * 1.125 + LS-OFFSET
                 COMPUTE LS-FZ = LS-CZ + LS-DZ * LS-WIDTH
                 MOVE 0 TO LS-ROW
                 CALL "BOAT-SPAWN" USING L-DIM LS-FX LS-FY LS-FZ LS-YAWL LS-TYPE-KEY LS-ROW
                 IF LS-ROW > 0
                     MOVE 1 TO L-HANDLED L-CONSUMED
                 END-IF
             END-IF
         WHEN LS-BARE = "honeycomb"
*>           4.20: a block with a waxed form becomes it (level event 3003, the wax-on sound); any other block: the default drop (the click stays 1000)
             CALL "TOOL-WAX-KEY" USING LS-WAX-ON LS-BBARE LS-NEW-KEY LS-OK
             IF LS-OK = 1
                 MOVE SPACES TO LS-TYPE-KEY
                 STRING "minecraft:" FUNCTION TRIM(LS-NEW-KEY) DELIMITED BY SIZE INTO LS-TYPE-KEY
                 CALL "CONTENT-BLOCK-BY-KEY" USING LS-TYPE-KEY LS-ID LS-ROW-TEXT LS-STATUS
*>               the waxed block has the same properties as the unwaxed one: its state of the same index
                 COMPUTE LS-NEW = CB-FIRST-STATE(LS-ID + 1) + LS-STATE - CB-FIRST-STATE(LS-BLOCK + 1)
                 MOVE 3 TO LS-FLAGS
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "LEVEL-EVENT" USING L-DIM LS-WAX-EVENT L-X L-Y L-Z LS-ZERO LS-NONE
                 CALL "RL-SOUND-AT" USING L-DIM L-X L-Y L-Z WS-WAX-SOUND LS-SOURCE-BLOCKS LS-VOLUME LS-PITCH
                 MOVE 1 TO L-HANDLED L-CONSUMED
             END-IF
         WHEN LS-BARE = "egg" OR LS-BARE = "snowball" OR LS-BARE = "experience_bottle"
*>           4.1: the thrown item leaves from 0.7 in front of the dispenser's centre and 0.1 above it, shot along the facing with the item's power and uncertainty (6 and 1.1; the experience bottle 3 and 1.375)
             COMPUTE LS-FX = L-X - LS-DX + 0.5 + 0.7 * LS-DX
             COMPUTE LS-FY = L-Y - LS-DY + 0.5 + 0.7 * LS-DY + 0.1
             COMPUTE LS-FZ = L-Z - LS-DZ + 0.5 + 0.7 * LS-DZ
             MOVE LS-DX TO LS-VX
             MOVE LS-DY TO LS-VY
             MOVE LS-DZ TO LS-VZ
             MOVE 1.1 TO LS-POWER
             MOVE 6.0 TO LS-UNCERTAIN
             MOVE 0 TO LS-ROW
             EVALUATE LS-BARE
                 WHEN "egg"
                     CALL "THROWN-JITTER" USING LS-VX LS-VY LS-VZ LS-POWER LS-UNCERTAIN
                     MOVE 6 TO LS-PJ
                     MOVE "minecraft:egg" TO LS-TYPE-KEY
                     CALL "THROWN-SPAWN" USING LS-PJ LS-TYPE-KEY L-DIM LS-FX LS-FY LS-FZ LS-VX LS-VY LS-VZ LS-ZERO LS-ROW
                 WHEN "snowball"
                     CALL "THROWN-JITTER" USING LS-VX LS-VY LS-VZ LS-POWER LS-UNCERTAIN
                     MOVE 3 TO LS-PJ
                     CALL "PROJ-SPAWN" USING LS-PJ L-DIM LS-FX LS-FY LS-FZ LS-VX LS-VY LS-VZ LS-NONE LS-ZERO LS-ROW
                     IF LS-ROW > 0
                         COMPUTE EN-VX(LS-ROW) = LS-VX
                         COMPUTE EN-VY(LS-ROW) = LS-VY
                         COMPUTE EN-VZ(LS-ROW) = LS-VZ
                     END-IF
                 WHEN OTHER
                     MOVE 3.0 TO LS-UNCERTAIN
                     MOVE 1.375 TO LS-POWER
                     CALL "THROWN-JITTER" USING LS-VX LS-VY LS-VZ LS-POWER LS-UNCERTAIN
                     MOVE 40 TO LS-PJ
                     MOVE "minecraft:experience_bottle" TO LS-TYPE-KEY
                     CALL "THROWN-SPAWN" USING LS-PJ LS-TYPE-KEY L-DIM LS-FX LS-FY LS-FZ LS-VX LS-VY LS-VZ LS-ZERO LS-ROW
             END-EVALUATE
             IF LS-ROW > 0
                 MOVE 1 TO L-HANDLED
                 MOVE 3 TO L-CONSUMED
             END-IF
         WHEN LS-BARE = "arrow" OR LS-BARE = "spectral_arrow" OR LS-BARE = "tipped_arrow"
*>           4.1: an arrow is shot like the thrown items (power 1.1, uncertainty 6.0, launch sound 1002); a tipped arrow is an arrow here (its potion contents are not modelled), a spectral arrow glows its target
             COMPUTE LS-FX = L-X - LS-DX + 0.5 + 0.7 * LS-DX
             COMPUTE LS-FY = L-Y - LS-DY + 0.5 + 0.7 * LS-DY + 0.1
             COMPUTE LS-FZ = L-Z - LS-DZ + 0.5 + 0.7 * LS-DZ
             MOVE LS-DX TO LS-VX
             MOVE LS-DY TO LS-VY
             MOVE LS-DZ TO LS-VZ
             MOVE 1.1 TO LS-POWER
             MOVE 6.0 TO LS-UNCERTAIN
             CALL "THROWN-JITTER" USING LS-VX LS-VY LS-VZ LS-POWER LS-UNCERTAIN
             MOVE 1 TO LS-FAMILY
             IF LS-BARE = "spectral_arrow"
                 MOVE 2 TO LS-FAMILY
             END-IF
             MOVE 0 TO LS-ROW
             CALL "ARROW-SPAWN-AS" USING LS-FAMILY L-DIM LS-FX LS-FY LS-FZ LS-VX LS-VY LS-VZ LS-BASE LS-ZERO LS-ROW
             IF LS-ROW > 0
                 MOVE 1 TO L-HANDLED
                 MOVE 3 TO L-CONSUMED
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-DISP-BEHAVE.
