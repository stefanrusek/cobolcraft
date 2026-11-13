*> Cauldrons of docs/protocol/29b part 7 (section 8) as programs of plain numbers (GC7- prefix). Class codes: 1 empty cauldron, 2 water cauldron, 3 powder snow cauldron,
*> 4 lava cauldron; fluid codes 1 water, 3 lava; the float compares use FCMP-GT (a GnuCOBOL float compare has a tolerance).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-FAMILY.
*> USING the class, the level (0 outside the layered ones), then the comparator output, the content height in pixels, isFull, the fluid (0 none 1 water 2 powder snow 3 lava),
*> the inside effects requested, a precipitation handler exists out (8.1, 8.3, 8.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-COMPARATOR           BINARY-LONG.
 01 L-PIXELS               BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-EFFECTS              BINARY-LONG.
 01 L-HANDLER              BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-LEVEL L-COMPARATOR L-PIXELS L-FULL L-FLUID L-EFFECTS L-HANDLER.
     MOVE 0 TO L-COMPARATOR L-PIXELS L-FULL L-FLUID L-EFFECTS
     MOVE 1 TO L-HANDLER
     EVALUATE L-CLASS
         WHEN 2 THRU 3
             MOVE L-LEVEL TO L-COMPARATOR
             COMPUTE L-PIXELS = 6 + 3 * L-LEVEL
             MOVE 1 TO L-EFFECTS
             IF L-LEVEL = 3
                 MOVE 1 TO L-FULL
             END-IF
             IF L-CLASS = 2
                 MOVE 1 TO L-FLUID
             ELSE
                 MOVE 2 TO L-FLUID
             END-IF
         WHEN 4
             MOVE 3 TO L-COMPARATOR L-FLUID L-EFFECTS
             MOVE 15 TO L-PIXELS
             MOVE 1 TO L-FULL
             MOVE 0 TO L-HANDLER
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-CAULDRON-FAMILY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-BOX.
*> USING the part (1 to 3 legs and walls, 4 SHAPE_INSIDE, 5 layered fill, 6 lava fill), the level, the box x0 y0 z0 x1 y1 z1 in pixels out (8.1, 8.3, 8.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PART                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PART L-LEVEL L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 2 TO L-X0 L-Z0
     MOVE 14 TO L-X1 L-Z1
     MOVE 0 TO L-Y0
     MOVE 3 TO L-Y1
     EVALUATE L-PART
         WHEN 1
             MOVE 0 TO L-X0
             MOVE 4 TO L-Z0
             MOVE 16 TO L-X1
             MOVE 12 TO L-Z1
         WHEN 2
             MOVE 4 TO L-X0
             MOVE 0 TO L-Z0
             MOVE 12 TO L-X1
             MOVE 16 TO L-Z1
         WHEN 4
             MOVE 4 TO L-Y0
             MOVE 16 TO L-Y1
         WHEN 5
             MOVE 4 TO L-Y0
             COMPUTE L-Y1 = 6 + 3 * L-LEVEL
         WHEN 6
             MOVE 4 TO L-Y0
             MOVE 15 TO L-Y1
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-CAULDRON-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-CONST.
*> USING the selector (1 RAIN_FILL_CHANCE x 1000, 2 POWDER_SNOW_FILL_CHANCE x 1000, 3 MIN_FILL_LEVEL, 4 MAX_FILL_LEVEL, 5 BASE_CONTENT_HEIGHT, 6 HEIGHT_PER_LEVEL, 7 FLOOR_LEVEL), the value out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 50.
    05 FILLER              BINARY-LONG VALUE 100.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 4.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 7 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC7-CAULDRON-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-DISPATCH.
*> USING the dispatcher (the class of the cauldron), the held item (1 lava_bucket, 2 water_bucket, 3 powder_snow_bucket, 4 potion, 5 bucket, 6 glass_bottle, 7 item of cauldron_can_remove_dye,
*> 8 banner, 9 dyed shulker box, 10 plain shulker box, 11 other), the interaction out (0 DEFAULT: try with the empty hand, 1 to 3 the default bucket entries, 4 potion into an empty cauldron,
*> 5 water bucket pick-up, 6 glass bottle, 7 potion into water, 8 dye removal, 9 banner, 10 shulker box, 11 lava bucket pick-up, 12 powder snow bucket pick-up) (8.1, 8.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISPATCHER           BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DISPATCHER L-ITEM L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-DISPATCHER = 2 AND L-ITEM = 7
         MOVE 8 TO L-RESULT
     ELSE
         EVALUATE L-ITEM
             WHEN 1 THRU 3
                 MOVE L-ITEM TO L-RESULT
             WHEN 4
                 IF L-DISPATCHER = 1
                     MOVE 4 TO L-RESULT
                 END-IF
                 IF L-DISPATCHER = 2
                     MOVE 7 TO L-RESULT
                 END-IF
             WHEN 5
                 EVALUATE L-DISPATCHER
                     WHEN 2
                         MOVE 5 TO L-RESULT
                     WHEN 3
                         MOVE 12 TO L-RESULT
                     WHEN 4
                         MOVE 11 TO L-RESULT
                 END-EVALUATE
             WHEN 6
                 IF L-DISPATCHER = 2
                     MOVE 6 TO L-RESULT
                 END-IF
             WHEN 8
                 IF L-DISPATCHER = 2
                     MOVE 9 TO L-RESULT
                 END-IF
             WHEN 9
                 IF L-DISPATCHER = 2
                     MOVE 10 TO L-RESULT
                 END-IF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM GC7-CAULDRON-DISPATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-BUCKET-IN.
*> USING the bucket (1 lava, 2 water, 3 powder snow), the fluid above is water, server level, then the result (1 success, 2 consume with no change), the new class, the new level,
*> the sound (1 bucket_empty_lava, 2 bucket_empty, 3 bucket_empty_powder_snow), the block changed out (8.5 default entries and emptyBucket).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BUCKET               BINARY-LONG.
 01 L-WATER-ABOVE          BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-BUCKET L-WATER-ABOVE L-SERVER L-RESULT L-CLASS L-LEVEL L-SOUND L-CHANGED.
     MOVE 1 TO L-RESULT
     MOVE 0 TO L-CLASS L-LEVEL L-SOUND
     MOVE L-SERVER TO L-CHANGED
     IF L-BUCKET NOT = 2 AND L-WATER-ABOVE = 1
         MOVE 2 TO L-RESULT
         MOVE 0 TO L-CHANGED
     ELSE
         MOVE L-BUCKET TO L-SOUND
         MOVE 3 TO L-LEVEL
         EVALUATE L-BUCKET
             WHEN 1
                 MOVE 4 TO L-CLASS
                 MOVE 0 TO L-LEVEL
                 MOVE 1 TO L-SOUND
             WHEN 2
                 MOVE 2 TO L-CLASS
                 MOVE 2 TO L-SOUND
             WHEN OTHER
                 MOVE 3 TO L-CLASS
                 MOVE 3 TO L-SOUND
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM GC7-CAULDRON-BUCKET-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-FILL.
*> USING the class (2 water, 3 powder snow, 4 lava), the level, server level, then the result (1 success, 0 try with the empty hand), the filled bucket (1 water, 2 lava, 3 powder snow),
*> the sound (1 bucket_fill, 2 bucket_fill_lava, 3 bucket_fill_powder_snow), the new class (empty after a fill), the block changed out (8.5 fillBucket).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS-IN             BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-BUCKET               BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS-IN L-LEVEL L-SERVER L-RESULT L-BUCKET L-SOUND L-CLASS L-CHANGED.
     MOVE 0 TO L-RESULT L-BUCKET L-SOUND L-CHANGED
     MOVE L-CLASS-IN TO L-CLASS
     IF L-CLASS-IN = 4 OR L-LEVEL = 3
         MOVE 1 TO L-RESULT
         MOVE 1 TO L-CLASS
         MOVE L-SERVER TO L-CHANGED
         EVALUATE L-CLASS-IN
             WHEN 2
                 MOVE 1 TO L-BUCKET L-SOUND
             WHEN 3
                 MOVE 3 TO L-BUCKET L-SOUND
             WHEN OTHER
                 MOVE 2 TO L-BUCKET L-SOUND
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM GC7-CAULDRON-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-BOTTLE.
*> USING the class (1 empty, 2 water), the item (1 plain water potion, 2 other potion, 3 potion without potion_contents, 4 glass bottle), the level, server level, then the result
*> (1 success, 0 try with the empty hand), the new class, the new level, the sound (1 bottle_empty, 2 bottle_fill), the game event (1 fluid_place, 2 fluid_pickup), the stack put in hand
*> (1 glass bottle, 2 water potion), the block changed out (8.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS-IN             BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-LEVEL-IN             BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS-IN L-ITEM L-LEVEL-IN L-SERVER L-RESULT L-CLASS L-LEVEL L-SOUND L-EVENT L-HAND L-CHANGED.
     MOVE 0 TO L-RESULT L-SOUND L-EVENT L-HAND L-CHANGED
     MOVE L-CLASS-IN TO L-CLASS
     MOVE L-LEVEL-IN TO L-LEVEL
     EVALUATE TRUE
         WHEN L-CLASS-IN = 1 AND L-ITEM = 1
             MOVE 1 TO L-RESULT L-SOUND L-EVENT L-HAND L-LEVEL
             MOVE 2 TO L-CLASS
         WHEN L-CLASS-IN = 2 AND L-ITEM = 4
             MOVE 1 TO L-RESULT
             MOVE 2 TO L-SOUND L-EVENT L-HAND
             COMPUTE L-LEVEL = L-LEVEL-IN - 1
             IF L-LEVEL = 0
                 MOVE 1 TO L-CLASS
             END-IF
         WHEN L-CLASS-IN = 2 AND L-ITEM = 1 AND L-LEVEL-IN < 3
             MOVE 1 TO L-RESULT L-SOUND L-EVENT L-HAND
             COMPUTE L-LEVEL = L-LEVEL-IN + 1
     END-EVALUATE
     IF L-RESULT = 1
         MOVE L-SERVER TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM GC7-CAULDRON-BOTTLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-LOWER.
*> USING the class (2 water, 3 powder snow), the level, then the new class and level out (8.3 lowerFillLevel): level - 1, the empty cauldron at 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS-IN             BINARY-LONG.
 01 L-LEVEL-IN             BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS-IN L-LEVEL-IN L-CLASS L-LEVEL.
     COMPUTE L-LEVEL = L-LEVEL-IN - 1
     MOVE L-CLASS-IN TO L-CLASS
     IF L-LEVEL = 0
         MOVE 1 TO L-CLASS
     END-IF
     GOBACK.
 END PROGRAM GC7-CAULDRON-LOWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-CLEAN.
*> USING the kind (1 dyed item, 2 banner, 3 dyed shulker box), the condition (1 has dyed_color, the banner layer count, 1 is a shulker box), server level, then the result (1 success,
*> 0 try with the empty hand), the statistic awarded (1 clean_armor, 2 clean_banner, 3 clean_shulker_box), the level lowered, the banner layers left out (8.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-CONDITION            BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-STAT                 BINARY-LONG.
 01 L-LOWERED              BINARY-LONG.
 01 L-LAYERS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-CONDITION L-SERVER L-RESULT L-STAT L-LOWERED L-LAYERS.
     MOVE 0 TO L-RESULT L-STAT L-LOWERED
     MOVE L-CONDITION TO L-LAYERS
     IF (L-KIND = 2 AND L-CONDITION > 0) OR (L-KIND NOT = 2 AND L-CONDITION = 1)
         MOVE 1 TO L-RESULT
         IF L-SERVER = 1
             MOVE L-KIND TO L-STAT
             MOVE 1 TO L-LOWERED
             IF L-KIND = 2
                 COMPUTE L-LAYERS = L-CONDITION - 1
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-CAULDRON-CLEAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-FILLED-RESULT.
*> USING infinite materials, limitToOne, the stack count, the inventory already holds the result, the inventory has room, then the count left, the result replaces the stack in hand,
*> the result is added to the inventory, the result is dropped out (8.5 createFilledResult).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INFINITE             BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HOLDS                BINARY-LONG.
 01 L-ROOM                 BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-ADDED                BINARY-LONG.
 01 L-DROPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INFINITE L-LIMIT L-COUNT L-HOLDS L-ROOM L-LEFT L-HAND L-ADDED L-DROPPED.
     MOVE 0 TO L-HAND L-ADDED L-DROPPED
     MOVE L-COUNT TO L-LEFT
     IF L-INFINITE = 1 AND L-LIMIT = 1
         IF L-HOLDS = 0
             MOVE 1 TO L-ADDED
         END-IF
     ELSE
         COMPUTE L-LEFT = L-COUNT - 1
         IF L-LEFT = 0
             MOVE 1 TO L-HAND
         ELSE
             IF L-ROOM = 1
                 MOVE 1 TO L-ADDED
             ELSE
                 MOVE 1 TO L-DROPPED
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-FILLED-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-PRECIP.
*> USING the class, the precipitation (1 rain, 2 snow, 0 other), nextFloat (FLOAT-LONG), the level, then a float was drawn, the new class, the new level, the game event block_change out (8.2, 8.3, 8.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-BELOW               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CLASS-IN             BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-LEVEL-IN             BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS-IN L-TYPE L-DRAW L-LEVEL-IN L-DREW L-CLASS L-LEVEL L-EVENT.
     MOVE 0 TO L-DREW L-EVENT WS-BELOW
     MOVE L-CLASS-IN TO L-CLASS
     MOVE L-LEVEL-IN TO L-LEVEL
     IF L-CLASS-IN NOT = 4
         EVALUATE L-TYPE
             WHEN 1
                 COMPUTE WS-CHANCE = 0.05
                 MOVE 1 TO L-DREW
             WHEN 2
                 COMPUTE WS-CHANCE = 0.1
                 MOVE 1 TO L-DREW
         END-EVALUATE
         IF L-DREW = 1
             CALL "FCMP-GT" USING WS-CHANCE L-DRAW WS-BELOW
         END-IF
         IF WS-BELOW = 1
             EVALUATE TRUE
                 WHEN L-CLASS-IN = 1
                     MOVE 1 TO L-LEVEL L-EVENT
                     MOVE 2 TO L-CLASS
                     IF L-TYPE = 2
                         MOVE 3 TO L-CLASS
                     END-IF
                 WHEN L-LEVEL-IN NOT = 3 AND ((L-CLASS-IN = 2 AND L-TYPE = 1) OR (L-CLASS-IN = 3 AND L-TYPE = 2))
                     COMPUTE L-LEVEL = L-LEVEL-IN + 1
                     MOVE 1 TO L-EVENT
             END-EVALUATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-CAULDRON-PRECIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-DRIP.
*> USING the class, the fluid (1 water, 3 lava, 0 other), the level, then the cauldron can receive the drip, the new class, the new level, the level event out (8.2, 8.3, 8.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS-IN             BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-LEVEL-IN             BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS-IN L-FLUID L-LEVEL-IN L-CAN L-CLASS L-LEVEL L-EVENT.
     MOVE 0 TO L-CAN L-EVENT
     MOVE L-CLASS-IN TO L-CLASS
     MOVE L-LEVEL-IN TO L-LEVEL
     EVALUATE TRUE
         WHEN L-CLASS-IN = 1
             MOVE 1 TO L-CAN
             EVALUATE L-FLUID
                 WHEN 1
                     MOVE 2 TO L-CLASS
                     MOVE 1 TO L-LEVEL
                     MOVE 1047 TO L-EVENT
                 WHEN 3
                     MOVE 4 TO L-CLASS
                     MOVE 0 TO L-LEVEL
                     MOVE 1046 TO L-EVENT
             END-EVALUATE
         WHEN L-CLASS-IN = 2 AND L-FLUID = 1
             MOVE 1 TO L-CAN
             IF L-LEVEL-IN < 3
                 COMPUTE L-LEVEL = L-LEVEL-IN + 1
                 MOVE 1047 TO L-EVENT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-CAULDRON-DRIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-DRIP-TICK.
*> USING a stalactite tip is found above, the fill fluid is not EMPTY (1 or 0), canReceiveStalactiteDrip, receiveStalactiteDrip is called out (8.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIP                  BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-RECEIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-TIP L-FLUID L-CAN L-RECEIVE.
     MOVE 0 TO L-RECEIVE
     IF L-TIP = 1 AND L-FLUID NOT = 0 AND L-CAN = 1
         MOVE 1 TO L-RECEIVE
     END-IF
     GOBACK.
 END PROGRAM GC7-DRIP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAN-FILL.
*> USING the fluid (0 empty, 1 water, 2 flowing water, 3 lava), canFillCauldron out (8.6): water and lava only.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-CAN.
     MOVE 0 TO L-CAN
     IF L-FLUID = 1 OR L-FLUID = 3
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM GC7-CAN-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-DRIP-DELAY.
*> USING the tip y, the cauldron y, the delay of the scheduled tick out (8.6): (tip y - cauldron y) + 50.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIP-Y                BINARY-LONG.
 01 L-CAULDRON-Y           BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-TIP-Y L-CAULDRON-Y L-DELAY.
     COMPUTE L-DELAY = L-TIP-Y - L-CAULDRON-Y + 50
     GOBACK.
 END PROGRAM GC7-DRIP-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-DRIP-GATE.
*> USING the roll r (FLOAT-LONG), the fluid (1 water, 3 lava, other), then stop (r above 0.17578125 and above 0.05859375), the threshold x 1e8 (0 for another fluid), the roll passes out (8.6 steps 1 and 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WATER               FLOAT-LONG.
 01 WS-LAVA                FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROLL                 FLOAT-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-STOP                 BINARY-LONG.
 01 L-THRESHOLD            BINARY-LONG.
 01 L-PASS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL L-FLUID L-STOP L-THRESHOLD L-PASS.
     COMPUTE WS-WATER = 0.17578125
     COMPUTE WS-LAVA = 0.05859375
     CALL "FCMP-GT" USING L-ROLL WS-WATER WS-A
     CALL "FCMP-GT" USING L-ROLL WS-LAVA WS-B
     MOVE 0 TO L-STOP L-THRESHOLD L-PASS
     IF WS-A = 1 AND WS-B = 1
         MOVE 1 TO L-STOP
     END-IF
     EVALUATE L-FLUID
         WHEN 1
             MOVE 17578125 TO L-THRESHOLD
             MOVE WS-WATER TO WS-LIMIT
         WHEN 3
             MOVE 5859375 TO L-THRESHOLD
             MOVE WS-LAVA TO WS-LIMIT
     END-EVALUATE
     IF L-STOP = 0 AND L-THRESHOLD > 0
         CALL "FCMP-GT" USING WS-LIMIT L-ROLL WS-A
         MOVE WS-A TO L-PASS
     END-IF
     GOBACK.
 END PROGRAM GC7-DRIP-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-DRIP-FLUID.
*> USING the block above the root is mud, the environment attribute water_evaporates, the fluid at that position (1 water, 3 lava, 0 empty), the fluid reported out (8.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MUD                  BINARY-LONG.
 01 L-EVAPORATES           BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-MUD L-EVAPORATES L-FLUID L-RESULT.
     MOVE L-FLUID TO L-RESULT
     IF L-MUD = 1 AND L-EVAPORATES = 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC7-DRIP-FLUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAULDRON-FIRE.
*> USING the class (2 water, 3 powder snow), the level, server level, the entity is on fire, it may interact, then a callback is registered, the cauldron changed, the new class, the new level,
*> the extinguish effect requested out (8.3 entityInside, handleEntityOnFireInside): a powder snow cauldron first becomes a water cauldron of the same level, then lowerFillLevel.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS-IN             BINARY-LONG.
 01 L-LEVEL-IN             BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 01 L-CALLBACK             BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-EXTINGUISH           BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS-IN L-LEVEL-IN L-SERVER L-FIRE L-MAY L-CALLBACK L-CHANGED L-CLASS L-LEVEL L-EXTINGUISH.
     MOVE L-SERVER TO L-CALLBACK
     MOVE 1 TO L-EXTINGUISH
     MOVE 0 TO L-CHANGED
     MOVE L-CLASS-IN TO L-CLASS
     MOVE L-LEVEL-IN TO L-LEVEL
     IF L-SERVER = 1 AND L-FIRE = 1 AND L-MAY = 1
         MOVE 1 TO L-CHANGED
         COMPUTE L-LEVEL = L-LEVEL-IN - 1
         MOVE 2 TO L-CLASS
         IF L-LEVEL = 0
             MOVE 1 TO L-CLASS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-CAULDRON-FIRE.
