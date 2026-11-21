*> Buckets (docs/protocol/29a-fluids.md sections 7.1 to 7.3): BUCKET-USE runs for Use Item (0x43) when the held item is bucket, water_bucket or
*> lava_bucket. The server casts the ray itself, from the eye (feet + 1.6) along the packet's yaw and pitch for the block interaction range (4.5, 5.0
*> in creative), sampled every 0.02: blocks with an outline (every non-air state that holds no fluid) are hit; a liquid block is ignored unless the
*> bucket is empty and it is a source (SOURCE_ONLY), which it then picks up (the cell becomes air, the bucket the filled one; a stack of empty buckets
*> gives one and the filled bucket goes into the inventory). A filled bucket places a source (water or lava) in the cell before the hit (the ray passed it: air or a
*> liquid, replaceable both) and becomes an empty bucket; a water bucket aimed at a dry block with the waterlogged property waterlogs it instead (29a section 5, the
*> block is the container), and an empty bucket aimed at a waterlogged block takes the water and leaves the block dry (kelp and seagrass hold water but give none to a bucket;
*> the bubble column is taken). A creative player keeps the stack. Not done: evaporation in the Nether of a waterlogged block, powder snow, the sounds and game events,
*> spawn protection (mob buckets: lane p46e, RANGED-BUCKET).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUCKET-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EV-PICKUP           PIC X(32) VALUE "fluid_pickup".
 01 WS-EV-PLACE            PIC X(32) VALUE "fluid_place".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CMENU.
 COPY DIMENSIONS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-MODE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-HAVE-LAST           BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-NEW-STATE           BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FILLED-ID           BINARY-LONG.
 01 WS-EMPTY-ID            BINARY-LONG.
 01 WS-FILLED-KEY          PIC X(112).
 01 WS-EMPTY-KEY           PIC X(112) VALUE "bucket".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-EVAPORATES          BINARY-LONG.
 01 WS-FLAG-CODE           BINARY-LONG VALUE 6.
 01 WS-MOB-KEY             PIC X(48).
 01 WS-MOB-FOUND           BINARY-LONG VALUE 0.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-BUBBLE-KEY          PIC X(48) VALUE "minecraft:bubble_column".
 01 WS-IS-BUBBLE           BINARY-LONG.
 01 WS-WL-NAME             PIC X(24) VALUE "waterlogged".
 01 WS-WL-TEXT             PIC X(32).
 01 WS-WL-MODE             BINARY-LONG VALUE 2.
 01 WS-WL-STATE            BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-STATE(WS-ROW) NOT = PS-ALIVE OR MN-WINDOW(WS-ROW) NOT = 0
         GOBACK
     END-IF
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     COMPUTE WS-SLOT = WS-HELD + 1
     IF PL-SLOT-COUNT(WS-ROW, WS-SLOT) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, WS-SLOT) WS-KEY
     MOVE 0 TO WS-MOB-FOUND
     EVALUATE WS-KEY
         WHEN "bucket"
             MOVE 0 TO WS-MODE
         WHEN "water_bucket"
             MOVE 1 TO WS-MODE
         WHEN "lava_bucket"
             MOVE 2 TO WS-MODE
         WHEN OTHER
*>           A mob bucket empties its water like a water bucket and releases its mob (ranged-bucket.cob).
             CALL "BUCKET-MOB-SPECIES" USING WS-KEY WS-MOB-KEY WS-MOB-FOUND
             IF WS-MOB-FOUND = 0
                 GOBACK
             END-IF
             MOVE 1 TO WS-MODE
     END-EVALUATE
     MOVE 1 TO L-DONE
     MOVE PL-DIM(WS-ROW) TO WS-DIM
*>   The ray: the eye and the direction of the look (yaw 0 faces +z, pitch positive looks down).
     MOVE 4.5 TO WS-REACH
     IF PL-MODE(WS-ROW) = 1
         MOVE 5.0 TO WS-REACH
     END-IF
     COMPUTE WS-EX = PL-X(WS-ROW)
     COMPUTE WS-EY = PL-Y(WS-ROW) + 1.6
     COMPUTE WS-EZ = PL-Z(WS-ROW)
     COMPUTE WS-YAW = PSB-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = PSB-PITCH * FUNCTION PI / 180
     COMPUTE WS-DX = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-DY = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-DZ = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     MOVE 0 TO WS-HAVE-LAST WS-HIT WS-T
     PERFORM UNTIL WS-T > WS-REACH OR WS-HIT = 1
         COMPUTE WS-CX = FUNCTION INTEGER(WS-EX + WS-DX * WS-T)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-EY + WS-DY * WS-T)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-EZ + WS-DZ * WS-T)
         IF WS-HAVE-LAST = 0 OR WS-CX NOT = WS-LX OR WS-CY NOT = WS-LY OR WS-CZ NOT = WS-LZ
             CALL "FLUID-CELL" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
                 WS-SOLID WS-HOLDS
             IF WS-STATE NOT = 0
                 IF WS-FLUID = 0
                     MOVE 1 TO WS-HIT
                 END-IF
                 IF WS-FLUID > 0 AND WS-MODE = 0 AND (WS-KIND = 2 OR WS-KIND = 4)
                     MOVE 1 TO WS-HIT
                 END-IF
             END-IF
             IF WS-HIT = 0
                 MOVE WS-CX TO WS-LX
                 MOVE WS-CY TO WS-LY
                 MOVE WS-CZ TO WS-LZ
                 MOVE 1 TO WS-HAVE-LAST
             END-IF
         END-IF
         ADD 0.02 TO WS-T
     END-PERFORM
     IF WS-HIT = 0
         GOBACK
     END-IF
     IF WS-MODE = 0
*>       An empty bucket takes a source: the cell becomes air and the bucket the filled one.
         IF WS-FLUID = 0
             GOBACK
         END-IF
         MOVE SPACES TO WS-FILLED-KEY
         IF WS-FLUID = 1
             MOVE "water_bucket" TO WS-FILLED-KEY
         ELSE
             MOVE "lava_bucket" TO WS-FILLED-KEY
         END-IF
         CALL "CONTENT-ITEM-BY-KEY" USING WS-FILLED-KEY WS-FILLED-ID WS-ITEM-ROW WS-STATUS
*>       The source is held by the block: a waterlogged block stays and dries (BucketPickup of SimpleWaterloggedBlock), a bubble column goes, kelp and seagrass keep their water.
         CALL "FLUID-CONTAINER" USING WS-STATE WS-CLASS WS-FULL
         CALL "FLUID-KEY-IS" USING WS-STATE WS-BUBBLE-KEY WS-IS-BUBBLE
         MOVE WS-AIR TO WS-NEW-STATE
         IF WS-CLASS = 2
             MOVE "false" TO WS-WL-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-WL-MODE WS-STATE WS-WL-NAME WS-WL-TEXT WS-NEW-STATE
         END-IF
         IF WS-CLASS = 1 AND WS-IS-BUBBLE = 0
             GOBACK
         END-IF
         CALL "BLOCK-CHANGE" USING WS-DIM WS-CX WS-CY WS-CZ WS-NEW-STATE
*>       BucketItem.use: fluid_pickup at the centre of the cell, the player as the source (30-8 14.3.9)
         CALL "GAME-EVENT-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-EV-PICKUP WS-ROW WS-NO-STATE
         IF PL-MODE(WS-ROW) = 0
             IF PL-SLOT-COUNT(WS-ROW, WS-SLOT) = 1
                 MOVE WS-FILLED-ID TO PL-SLOT-ITEM(WS-ROW, WS-SLOT)
             ELSE
                 SUBTRACT 1 FROM PL-SLOT-COUNT(WS-ROW, WS-SLOT)
                 CALL "INV-ADD" USING WS-ROW WS-FILLED-ID WS-ONE WS-LEFT
                 CALL "INV-SLOT-SEND" USING L-ID WS-HELD
             END-IF
             COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
             CALL "INV-SLOT-SEND" USING L-ID WS-HELD
         END-IF
         GOBACK
     END-IF
*>   A water bucket aimed at a dry block that can be waterlogged fills the block (it is the container: the hit cell, not the cell before it).
     IF WS-MODE = 1
         CALL "FLUID-CONTAINER" USING WS-STATE WS-CLASS WS-FULL
         IF WS-CLASS = 2 AND WS-FULL = 0
             MOVE "true" TO WS-WL-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-WL-MODE WS-STATE WS-WL-NAME WS-WL-TEXT WS-WL-STATE
             CALL "BLOCK-CHANGE" USING WS-DIM WS-CX WS-CY WS-CZ WS-WL-STATE
             IF PL-MODE(WS-ROW) = 0
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-EMPTY-KEY WS-EMPTY-ID WS-ITEM-ROW WS-STATUS
                 MOVE WS-EMPTY-ID TO PL-SLOT-ITEM(WS-ROW, WS-SLOT)
                 COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
                 CALL "INV-SLOT-SEND" USING L-ID WS-HELD
             END-IF
             GOBACK
         END-IF
     END-IF
*>   A filled bucket places a source in the cell before the hit: the ray passed it, so it holds air or a liquid (a flowing cell or a source of the
*>   other fluid), both replaceable.
     IF WS-HAVE-LAST = 0
         GOBACK
     END-IF
     MOVE WS-MODE TO WS-FLUID
     MOVE 2 TO WS-KIND
     IF WS-MODE = 2
         MOVE 4 TO WS-KIND
     END-IF
     MOVE 8 TO WS-AMOUNT
     MOVE 0 TO WS-FALLING
     CALL "FLUID-STATE-ID" USING WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-NEW-STATE
*>   water_evaporates (37-nether-1 section 3.1): no water in the Nether, the sound and the smoke instead.
     MOVE 0 TO WS-EVAPORATES
     IF WS-MODE = 1 AND DM-KEY(WS-DIM) = "minecraft:the_nether"
         CALL "NETHER-DIM-FLAG" USING WS-FLAG-CODE WS-EVAPORATES
     END-IF
     IF WS-EVAPORATES = 1
         CALL "NETHER-EVAPORATE" USING WS-DIM WS-LX WS-LY WS-LZ
     ELSE
         CALL "BLOCK-CHANGE" USING WS-DIM WS-LX WS-LY WS-LZ WS-NEW-STATE
*>       BucketItem.playEmptySound: fluid_place at the centre of the filled cell, the player as the source
         CALL "GAME-EVENT-BLOCK" USING WS-DIM WS-LX WS-LY WS-LZ WS-EV-PLACE WS-ROW WS-NO-STATE
     END-IF
     IF WS-MOB-FOUND = 1
         CALL "BUCKET-MOB-RELEASE" USING WS-ROW WS-MOB-KEY WS-LX WS-LY WS-LZ WS-SLOT
     END-IF
     IF PL-MODE(WS-ROW) = 0
         CALL "CONTENT-ITEM-BY-KEY" USING WS-EMPTY-KEY WS-EMPTY-ID WS-ITEM-ROW WS-STATUS
         MOVE WS-EMPTY-ID TO PL-SLOT-ITEM(WS-ROW, WS-SLOT)
         COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
         CALL "INV-SLOT-SEND" USING L-ID WS-HELD
     END-IF
     GOBACK.
 END PROGRAM BUCKET-USE.
