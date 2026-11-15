*> Frogspawn, honey block and beehive of docs/protocol/29b part 7 (sections 5 to 7) as programs of plain numbers (GC7- prefix).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-FROG-SHAPE.
*> USING the box x0 y0 z0 x1, y1 x 10 (the 1.5 pixel film), z1 out (5): column(16, 0, 1.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 0 TO L-X0 L-Y0 L-Z0
     MOVE 16 TO L-X1 L-Z1
     MOVE 15 TO L-Y1
     GOBACK.
 END PROGRAM GC7-FROG-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-FROG-SURVIVE.
*> USING the fluid below is in supports_frogspawn, the block below is in supports_frogspawn, the fluid above is empty, canSurvive out (5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID-BELOW          BINARY-LONG.
 01 L-BLOCK-BELOW          BINARY-LONG.
 01 L-EMPTY-ABOVE          BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID-BELOW L-BLOCK-BELOW L-EMPTY-ABOVE L-SURVIVE.
     MOVE 0 TO L-SURVIVE
     IF (L-FLUID-BELOW = 1 OR L-BLOCK-BELOW = 1) AND L-EMPTY-ABOVE = 1
         MOVE 1 TO L-SURVIVE
     END-IF
     GOBACK.
 END PROGRAM GC7-FROG-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-FROG-DELAY.
*> USING the draw nextInt(8400), the hatch delay out (5): 3600 + draw.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-DELAY.
     COMPUTE L-DELAY = 3600 + L-DRAW
     GOBACK.
 END PROGRAM GC7-FROG-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-FROG-TRIGGER.
*> USING the trigger (1 onPlace, 2 updateShape, 3 block tick, 4 entity inside), canSurvive, the entity is a falling block, the action out (0 none, 1 schedule the hatch, 2 air, 3 destroy, 4 hatch) (5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRIGGER              BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGER L-SURVIVE L-FALLING L-ACTION.
     MOVE 0 TO L-ACTION
     EVALUATE L-TRIGGER
         WHEN 1
             MOVE 1 TO L-ACTION
         WHEN 2
             IF L-SURVIVE = 0
                 MOVE 2 TO L-ACTION
             END-IF
         WHEN 3
             IF L-SURVIVE = 0
                 MOVE 3 TO L-ACTION
             ELSE
                 MOVE 4 TO L-ACTION
             END-IF
         WHEN 4
             IF L-FALLING = 1
                 MOVE 3 TO L-ACTION
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-FROG-TRIGGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-FROG-TADPOLES.
*> USING the draw nextInt(2, 6) as its offset 0 to 3, the yaw draw nextInt(1, 361) as its offset 0 to 359, the tadpoles, the yaw, the y offset x 1000 out (5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT-DRAW           BINARY-LONG.
 01 L-YAW-DRAW             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-YAW                  BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT-DRAW L-YAW-DRAW L-COUNT L-YAW L-Y.
     COMPUTE L-COUNT = 2 + L-COUNT-DRAW
     COMPUTE L-YAW = 1 + L-YAW-DRAW
     MOVE -500 TO L-Y
     GOBACK.
 END PROGRAM GC7-FROG-TADPOLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-FROG-OFFSET.
*> USING nextDouble (FLOAT-LONG), the spawn offset x 1e9 out (5): clamp(draw, 0.20000000298023224, 0.7999999970197678); the compares use FCMP-GT (a float
*> compare of GnuCOBOL has a tolerance that would treat 0.2 as equal to the float 0.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLAMPED             FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-OFFSET.
     COMPUTE WS-LOW = 0.20000000298023224
     COMPUTE WS-HIGH = 0.7999999970197678
     MOVE L-DRAW TO WS-CLAMPED
     CALL "FCMP-GT" USING WS-LOW WS-CLAMPED WS-GT
     IF WS-GT = 1
         MOVE WS-LOW TO WS-CLAMPED
     END-IF
     CALL "FCMP-GT" USING WS-CLAMPED WS-HIGH WS-GT
     IF WS-GT = 1
         MOVE WS-HIGH TO WS-CLAMPED
     END-IF
     COMPUTE L-OFFSET ROUNDED = WS-CLAMPED * 1000000000
     GOBACK.
 END PROGRAM GC7-FROG-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-HONEY-CONST.
*> USING the selector (BINARY-LONG), the value out (6): 1 slide speed x 100, 2 minimum fall speed x 100, 3 throttled speed x 100, 4 achievement ticks, 5 speed factor x 10,
*> 6 jump factor x 10, 7 collision x0, 8 collision x1, 9 collision height (pixels).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 13.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 20.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 15.
    05 FILLER              BINARY-LONG VALUE 15.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 9 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC7-HONEY-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-HONEY-SLIDES.
*> USING the entity kind (1 living, 2 minecart, 3 primed TNT, 4 boat, 5 other), slides out (6.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SLIDES               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SLIDES.
     MOVE 0 TO L-SLIDES
     IF L-KIND >= 1 AND L-KIND <= 4
         MOVE 1 TO L-SLIDES
     END-IF
     GOBACK.
 END PROGRAM GC7-HONEY-SLIDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-HONEY-SLIDING.
*> USING on the ground, pos y, pos x, pos z (BINARY-LONG), the entity y, vertical velocity, x, z, bounding box width (FLOAT-LONG), sliding out (6.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-DXE                 FLOAT-LONG.
 01 WS-DZE                 FLOAT-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-FAST                BINARY-LONG.
 01 WS-OUT-X               BINARY-LONG.
 01 WS-OUT-Z               BINARY-LONG.
 LINKAGE SECTION.
 01 L-GROUND               BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-WIDTH                FLOAT-LONG.
 01 L-SLIDING              BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUND L-PY L-PX L-PZ L-Y L-VY L-X L-Z L-WIDTH L-SLIDING.
     MOVE 0 TO L-SLIDING
     COMPUTE WS-TOP = L-PY + 0.9375 - 0.0000001
     COMPUTE WS-OLD = L-VY / 0.9800000190734863 + 0.08
     COMPUTE WS-LIMIT = -0.08
     COMPUTE WS-DX = FUNCTION ABS(L-PX + 0.5 - L-X)
     COMPUTE WS-DZ = FUNCTION ABS(L-PZ + 0.5 - L-Z)
     COMPUTE WS-W = 0.4375 + L-WIDTH / 2
     COMPUTE WS-DXE = WS-DX + 0.0000001
     COMPUTE WS-DZE = WS-DZ + 0.0000001
     CALL "FCMP-GT" USING L-Y WS-TOP WS-ABOVE
     CALL "FCMP-GT" USING WS-LIMIT WS-OLD WS-FAST
     CALL "FCMP-GT" USING WS-DXE WS-W WS-OUT-X
     CALL "FCMP-GT" USING WS-DZE WS-W WS-OUT-Z
     IF L-GROUND = 0 AND WS-ABOVE = 0 AND WS-FAST = 1
         IF WS-OUT-X = 1 OR WS-OUT-Z = 1
             MOVE 1 TO L-SLIDING
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-HONEY-SLIDING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-HONEY-MOVE.
*> USING the velocity vx, vy, vz (FLOAT-LONG), then x 1e6: the old vertical speed, the factor, the new vx, vy, vz out (6.3 doSlideMovement).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 FLOAT-LONG.
 01 WS-FACTOR              FLOAT-LONG.
 01 WS-NEW-Y               FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-FAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-FACTOR               BINARY-LONG.
 01 L-NX                   BINARY-LONG.
 01 L-NY                   BINARY-LONG.
 01 L-NZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-VX L-VY L-VZ L-OLD L-FACTOR L-NX L-NY L-NZ.
     COMPUTE WS-OLD = L-VY / 0.9800000190734863 + 0.08
     COMPUTE WS-NEW-Y = (-0.05 - 0.08) * 0.9800000190734863
     MOVE 1 TO WS-FACTOR
     COMPUTE WS-LIMIT = -0.13
     CALL "FCMP-GT" USING WS-LIMIT WS-OLD WS-FAST
     IF WS-FAST = 1
         COMPUTE WS-FACTOR = -0.05 / WS-OLD
     END-IF
     COMPUTE L-OLD ROUNDED = WS-OLD * 1000000
     COMPUTE L-FACTOR ROUNDED = WS-FACTOR * 1000000
     COMPUTE L-NX ROUNDED = L-VX * WS-FACTOR * 1000000
     COMPUTE L-NY ROUNDED = WS-NEW-Y * 1000000
     COMPUTE L-NZ ROUNDED = L-VZ * WS-FACTOR * 1000000
     GOBACK.
 END PROGRAM GC7-HONEY-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-HONEY-INSIDE.
*> USING sliding, the entity is a server player, the game time, the advancement criterion honey_block_slide, the slide movement, the slide effects out (6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLIDING              BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-TIME                 BINARY-LONG.
 01 L-ADVANCE              BINARY-LONG.
 01 L-MOVE                 BINARY-LONG.
 01 L-EFFECTS              BINARY-LONG.
 PROCEDURE DIVISION USING L-SLIDING L-PLAYER L-TIME L-ADVANCE L-MOVE L-EFFECTS.
     MOVE 0 TO L-ADVANCE L-MOVE L-EFFECTS
     IF L-SLIDING = 1
         MOVE 1 TO L-MOVE L-EFFECTS
         IF L-PLAYER = 1 AND FUNCTION MOD(L-TIME, 20) = 0
             MOVE 1 TO L-ADVANCE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-HONEY-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-HONEY-EFFECTS.
*> USING the entity is one of 6.1, the draw nextInt(5), server level, the second draw nextInt(5), the sound played, entity event 53 broadcast, the second draw was made out (6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ELIGIBLE             BINARY-LONG.
 01 L-DRAW1                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-DRAW2                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ELIGIBLE L-DRAW1 L-SERVER L-DRAW2 L-SOUND L-EVENT L-DREW.
     MOVE 0 TO L-SOUND L-EVENT L-DREW
     IF L-ELIGIBLE = 1
         IF L-DRAW1 = 0
             MOVE 1 TO L-SOUND
         END-IF
         IF L-SERVER = 1
             MOVE 1 TO L-DREW
             IF L-DRAW2 = 0
                 MOVE 1 TO L-EVENT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-HONEY-EFFECTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-HONEY-LAND.
*> USING server level, damage was dealt, the sound type volume and pitch (FLOAT-LONG), then entity event 54, the damage multiplier x 100, the fall sound played,
*> its volume x 1000 (volume x 0.5) and pitch x 1000 (pitch x 0.75) out (6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-DAMAGED              BINARY-LONG.
 01 L-VOLUME               FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-MULTIPLIER           BINARY-LONG.
 01 L-FALL-SOUND           BINARY-LONG.
 01 L-FALL-VOLUME          BINARY-LONG.
 01 L-FALL-PITCH           BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-DAMAGED L-VOLUME L-PITCH L-EVENT L-MULTIPLIER L-FALL-SOUND L-FALL-VOLUME L-FALL-PITCH.
     MOVE 0 TO L-EVENT L-FALL-SOUND L-FALL-VOLUME L-FALL-PITCH
     MOVE 20 TO L-MULTIPLIER
     IF L-SERVER = 1
         MOVE 54 TO L-EVENT
     END-IF
     IF L-DAMAGED = 1
         MOVE 1 TO L-FALL-SOUND
         COMPUTE L-FALL-VOLUME ROUNDED = L-VOLUME * 0.5 * 1000
         COMPUTE L-FALL-PITCH ROUNDED = L-PITCH * 0.75 * 1000
     END-IF
     GOBACK.
 END PROGRAM GC7-HONEY-LAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-DATA.
*> USING the selector (1 MAX_HONEY_LEVELS, 2 bee_nest hardness x 10, 3 beehive hardness x 10), the value out (7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 6.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC7-BEE-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-USE.
*> USING honey level, the held item (1 shears, 2 glass bottle, 3 other), server level, a smoky campfire below, the block entity exists, it holds bees, then done, honeycomb rolled,
*> the item_used stat, bees angered, bees released, honey level reset, the result (1 success, 0 the base useItemOn) out (7.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-SMOKY                BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-BEES                 BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 01 L-COMBS                BINARY-LONG.
 01 L-STAT                 BINARY-LONG.
 01 L-ANGER                BINARY-LONG.
 01 L-RELEASE              BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-ITEM L-SERVER L-SMOKY L-ENTITY L-BEES L-DONE L-COMBS L-STAT L-ANGER L-RELEASE L-RESET L-RESULT.
     MOVE 0 TO L-DONE L-COMBS L-STAT L-ANGER L-RELEASE L-RESET L-RESULT
     IF L-LEVEL >= 5
         EVALUATE TRUE
             WHEN L-ITEM = 1 AND L-SERVER = 1
                 MOVE 1 TO L-DONE
                 MOVE 3 TO L-COMBS
             WHEN L-ITEM = 2
                 MOVE 1 TO L-DONE
         END-EVALUATE
     END-IF
     IF L-DONE = 1
         MOVE 1 TO L-RESULT L-RESET
         IF L-SERVER = 1
             MOVE 1 TO L-STAT
         END-IF
         IF L-SMOKY = 0
             MOVE L-BEES TO L-ANGER
             MOVE L-ENTITY TO L-RELEASE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-BEE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-BOTTLE.
*> USING the stack count, the inventory has room, the count left, the honey_bottle goes in that hand, to the inventory, is dropped out (7.1 glass bottle).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-ROOM                 BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-INVENTORY            BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-ROOM L-LEFT L-HAND L-INVENTORY L-DROP.
     MOVE 0 TO L-HAND L-INVENTORY L-DROP
     COMPUTE L-LEFT = L-COUNT - 1
     IF L-LEFT = 0
         MOVE 1 TO L-HAND
     ELSE
         IF L-ROOM = 1
             MOVE 1 TO L-INVENTORY
         ELSE
             MOVE 1 TO L-DROP
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-BEE-BOTTLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-DESTROY.
*> USING the block entity is a beehive, the tool carries prevents_bee_spawns_when_mining, then the hive is emptied, neighbours updated, bees angered, the criterion triggered out (7.2 playerDestroy).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HIVE                 BINARY-LONG.
 01 L-SILK                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-NEIGHBOURS           BINARY-LONG.
 01 L-ANGER                BINARY-LONG.
 01 L-CRITERION            BINARY-LONG.
 PROCEDURE DIVISION USING L-HIVE L-SILK L-EMPTY L-NEIGHBOURS L-ANGER L-CRITERION.
     MOVE 0 TO L-EMPTY L-NEIGHBOURS L-ANGER L-CRITERION
     IF L-HIVE = 1
         MOVE 1 TO L-CRITERION
         IF L-SILK = 0
             MOVE 1 TO L-EMPTY L-NEIGHBOURS L-ANGER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-BEE-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-NEIGHBOUR.
*> USING the changed neighbour is a FireBlock, the block entity is a beehive, the hive is emptied with no player out (7.2 updateShape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIRE                 BINARY-LONG.
 01 L-HIVE                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 PROCEDURE DIVISION USING L-FIRE L-HIVE L-EMPTY.
     MOVE 0 TO L-EMPTY
     IF L-FIRE = 1 AND L-HIVE = 1
         MOVE 1 TO L-EMPTY
     END-IF
     GOBACK.
 END PROGRAM GC7-BEE-NEIGHBOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-WILL-DESTROY.
*> USING server level, preventsBlockDrops, block_drops, the block entity is a hive, it holds bees, honey level, then an item is spawned, the honey_level it carries out (7.2 playerWillDestroy).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 01 L-HIVE                 BINARY-LONG.
 01 L-BEES                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-CARRIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-CREATIVE L-DROPS L-HIVE L-BEES L-LEVEL L-SPAWN L-CARRIED.
     MOVE 0 TO L-SPAWN L-CARRIED
     IF L-SERVER = 1 AND L-CREATIVE = 1 AND L-DROPS = 1 AND L-HIVE = 1
         IF L-BEES = 1 OR L-LEVEL > 0
             MOVE 1 TO L-SPAWN
             MOVE L-LEVEL TO L-CARRIED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-BEE-WILL-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-DROPS.
*> USING the breaking entity (1 primed TNT, 2 creeper, 3 wither skull, 4 wither boss, 5 TNT minecart, 6 other), the loot block entity is a hive, the hive is emptied out (7.2 getDrops).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-HIVE                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-HIVE L-EMPTY.
     MOVE 0 TO L-EMPTY
     IF L-KIND >= 1 AND L-KIND <= 5 AND L-HIVE = 1
         MOVE 1 TO L-EMPTY
     END-IF
     GOBACK.
 END PROGRAM GC7-BEE-DROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-CLONE.
*> USING includeData, the honey level, the block_state component is set, its honey_level out (7.2 pick block).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INCLUDE              BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-INCLUDE L-LEVEL L-SET L-VALUE.
     MOVE 0 TO L-SET L-VALUE
     IF L-INCLUDE = 1
         MOVE 1 TO L-SET
         MOVE L-LEVEL TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM GC7-BEE-CLONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-ANGER.
*> USING the bees in the box, the players in it, the bees without a target, then the box inflate x, y, z and the bees given a target out (7.2 angerNearbyBees).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BEES                 BINARY-LONG.
 01 L-PLAYERS              BINARY-LONG.
 01 L-UNTARGETED           BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-GIVEN                BINARY-LONG.
 PROCEDURE DIVISION USING L-BEES L-PLAYERS L-UNTARGETED L-DX L-DY L-DZ L-GIVEN.
     MOVE 8 TO L-DX L-DZ
     MOVE 6 TO L-DY
     MOVE 0 TO L-GIVEN
     IF L-BEES > 0 AND L-PLAYERS > 0
         MOVE L-UNTARGETED TO L-GIVEN
     END-IF
     GOBACK.
 END PROGRAM GC7-BEE-ANGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-EXPLODE.
*> USING bees are angered out (7.2 onExplosionHit: always, after the base).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ANGER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ANGER.
     MOVE 1 TO L-ANGER
     GOBACK.
 END PROGRAM GC7-BEE-EXPLODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-BEE-DRIP.
*> USING honey level, the block holds a fluid, nextFloat (FLOAT-LONG), an attempt this tick, a dripping_honey particle out (7.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-BELOW               BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-ATTEMPT              BINARY-LONG.
 01 L-PARTICLE             BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-FLUID L-DRAW L-ATTEMPT L-PARTICLE.
     MOVE 0 TO L-ATTEMPT L-PARTICLE
     COMPUTE WS-CHANCE = 0.3
     CALL "FCMP-GT" USING WS-CHANCE L-DRAW WS-BELOW
     IF L-LEVEL >= 5
         MOVE 1 TO L-ATTEMPT
         IF L-FLUID = 0 AND WS-BELOW = 1
             MOVE 1 TO L-PARTICLE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-BEE-DRIP.
