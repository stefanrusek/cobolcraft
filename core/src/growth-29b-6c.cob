*> Falling and breaking speleothems, the pointed dripstone fluid transfer and the cauldron side (docs/protocol/29b part 6, sections 6 to 8) as programs of plain numbers (GC6-
*> prefix), helpers like those of growth-29b-6.cob. Fluids: 0 empty, 1 water (still), 2 flowing water, 3 lava (still), 4 flowing lava.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FALL-TICK.
*> USING the state is a stalagmite, canSurvive (BINARY-LONG), the action out (6.1): 1 destroy with drops for an unsupported stalagmite, else 2 spawnFallingStalactite.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STALAGMITE           BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-STALAGMITE L-SURVIVES L-ACTION.
     MOVE 2 TO L-ACTION
     IF L-STALAGMITE = 1 AND L-SURVIVES = 0
         MOVE 1 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM GC6-FALL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FALL-SPAWN.
*> USING the cells from the ticking position down (BINARY-LONG x 12: 0 not a stalactite, 1 a stalactite piece, 2 a stalactite tip or merged tip), the falling entities made, the
*> factor h of the tip entity (0 without a tip), damage per fall distance x 100, maximum damage out (6.2): h = max(1 + pos.y - c.y, 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELLS.
    05 L-CELL              BINARY-LONG OCCURS 12 TIMES.
 01 L-PIECES               BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CELLS L-PIECES L-H L-DAMAGE L-MAX.
     MOVE 0 TO L-PIECES L-H L-DAMAGE L-MAX WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12 OR L-CELL(WS-I) = 0 OR WS-DONE = 1
         ADD 1 TO L-PIECES
         IF L-CELL(WS-I) = 2
             MOVE 1 TO WS-DONE
             MOVE WS-I TO L-H
             IF L-H < 6
                 MOVE 6 TO L-H
             END-IF
             COMPUTE L-DAMAGE = 100 * L-H
             MOVE 40 TO L-MAX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC6-FALL-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FALL-LAND.
*> USING the block kind (1 pointed_dripstone, 2 sulfur_spike), the entity is silent (BINARY-LONG), the level event sent (0 for none), the damage source (1 falling_stalactite) out (6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SILENT               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SILENT L-EVENT L-SOURCE.
     MOVE 0 TO L-EVENT
     MOVE 1 TO L-SOURCE
     IF L-SILENT = 0
         MOVE 1045 TO L-EVENT
         IF L-KIND = 2
             MOVE 1052 TO L-EVENT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-FALL-LAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FALL-DAMAGE.
*> USING h (BINARY-LONG), the fall distance (FLOAT-LONG), n, the damage out (6.3): n = ceil(fallDistance - 1), damage = min(floor(n x h), 40).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-N                    BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-H L-DISTANCE L-N L-DAMAGE.
     COMPUTE WS-V = L-DISTANCE - 1
     COMPUTE L-N = FUNCTION INTEGER(WS-V)
     IF WS-V > L-N
         ADD 1 TO L-N
     END-IF
     COMPUTE L-DAMAGE = L-N * L-H
     IF L-DAMAGE > 40
         MOVE 40 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM GC6-FALL-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FALL-REST.
*> USING the entity's canSurvive holds (a sturdy block or speleothem above), dropItem, the entity_drops rule (BINARY-LONG), places, discarded, the block item drops out (6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVES             BINARY-LONG.
 01 L-DROP-ITEM            BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-PLACES               BINARY-LONG.
 01 L-DISCARDED            BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVES L-DROP-ITEM L-RULE L-PLACES L-DISCARDED L-DROPS.
     MOVE L-SURVIVES TO L-PLACES
     MOVE 0 TO L-DISCARDED L-DROPS
     IF L-SURVIVES = 0
         MOVE 1 TO L-DISCARDED
         IF L-DROP-ITEM = 1 AND L-RULE = 1
             MOVE 1 TO L-DROPS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-FALL-REST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-PROJ-INTERACT.
*> USING the owner (0 none, 1 a player, 2 another entity), the player's own mayInteract, the game rule mob_griefing (BINARY-LONG), mayInteract out (6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OWNER                BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-GRIEFING             BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER L-PLAYER L-GRIEFING L-MAY.
     MOVE 1 TO L-MAY
     IF L-OWNER = 1
         MOVE L-PLAYER TO L-MAY
     END-IF
     IF L-OWNER = 2
         MOVE L-GRIEFING TO L-MAY
     END-IF
     GOBACK.
 END PROGRAM GC6-PROJ-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-PROJ-ADVENTURE.
*> USING the owner (0 none, 1 a player, 2 another entity), the adventure mode flag (the server default game type for no owner, the player's game mode), the projectile's own canBreak
*> predicate (BINARY-LONG; false for ordinary projectiles), canBreakBlockInAdventureMode out (6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OWNER                BINARY-LONG.
 01 L-ADVENTURE            BINARY-LONG.
 01 L-PREDICATE            BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER L-ADVENTURE L-PREDICATE L-OK.
     MOVE L-PREDICATE TO L-OK
     IF L-OWNER NOT = 2
         MOVE 1 TO L-OK
         IF L-ADVENTURE = 1
             MOVE 0 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-PROJ-ADVENTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-PROJ-MAYBREAK.
*> USING the entity type is in impact_projectiles, the game rule projectiles_can_break_blocks, canBreakBlockInAdventureMode (BINARY-LONG), mayBreak out (6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IMPACT               BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-ADVENTURE            BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-IMPACT L-RULE L-ADVENTURE L-MAY.
     MOVE 0 TO L-MAY
     IF L-IMPACT = 1 AND L-RULE = 1 AND L-ADVENTURE = 1
         MOVE 1 TO L-MAY
     END-IF
     GOBACK.
 END PROGRAM GC6-PROJ-MAYBREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-PROJ-BREAK.
*> USING server level, mayInteract, mayBreak, the projectile is a trident (BINARY-LONG), the length of its velocity vector (FLOAT-LONG), destroyBlock(pos, true) runs out (6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-INTERACT             BINARY-LONG.
 01 L-BREAK                BINARY-LONG.
 01 L-TRIDENT              BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-DESTROY              BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-INTERACT L-BREAK L-TRIDENT L-SPEED L-DESTROY.
     MOVE 0 TO L-DESTROY
     IF L-SERVER = 1 AND L-INTERACT = 1 AND L-BREAK = 1 AND L-TRIDENT = 1 AND L-SPEED > 0.6
         MOVE 1 TO L-DESTROY
     END-IF
     GOBACK.
 END PROGRAM GC6-PROJ-BREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FLUID-ABOVE.
*> USING the state is a stalactite, a root block was found (GC6-FIND-VERT), the block above the root is mud, water_evaporates holds there, the fluid type of the cell above the root
*> (BINARY-LONG), a result exists, its fluid, its source state is mud out (7.1 getFluidAboveStalactite).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STALACTITE           BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 01 L-MUD                  BINARY-LONG.
 01 L-EVAPORATES           BINARY-LONG.
 01 L-FLUID-AT             BINARY-LONG.
 01 L-EXISTS               BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-SOURCE-MUD           BINARY-LONG.
 PROCEDURE DIVISION USING L-STALACTITE L-ROOT L-MUD L-EVAPORATES L-FLUID-AT L-EXISTS L-FLUID L-SOURCE-MUD.
     MOVE 0 TO L-EXISTS L-FLUID L-SOURCE-MUD
     IF L-STALACTITE = 1 AND L-ROOT = 1
         MOVE 1 TO L-EXISTS
         MOVE L-FLUID-AT TO L-FLUID
         MOVE L-MUD TO L-SOURCE-MUD
         IF L-MUD = 1 AND L-EVAPORATES = 0
             MOVE 1 TO L-FLUID
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-FLUID-ABOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FILL-TYPE.
*> USING a fluid (BINARY-LONG), the cauldron fill type out (7.1 getCauldronFillFluidType): water and lava stay, anything else is EMPTY (0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-FILL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-FILL.
     MOVE 0 TO L-FILL
     IF L-FLUID = 1 OR L-FLUID = 3
         MOVE L-FLUID TO L-FILL
     END-IF
     GOBACK.
 END PROGRAM GC6-FILL-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-TRANSFER.
*> USING the roll nextFloat() of randomTick (FLOAT-LONG), the piece is a start position, the fluid info exists, its fluid, an unmerged tip was found, the source state is mud, a
*> fillable cauldron was found, tip y - cauldron y (BINARY-LONG), the action (0 none, 1 mud to clay, 2 schedule the cauldron tick), level event, tick delay, push entities up, game
*> event block_change out (7.2 maybeTransferFluid).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-THRESHOLD           FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROLL                 FLOAT-LONG.
 01 L-START                BINARY-LONG.
 01 L-INFO                 BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 01 L-MUD                  BINARY-LONG.
 01 L-CAULDRON             BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-PUSH                 BINARY-LONG.
 01 L-GAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL L-START L-INFO L-FLUID L-TIP L-MUD L-CAULDRON L-DY L-ACTION L-EVENT L-DELAY L-PUSH L-GAME.
     MOVE 0 TO L-ACTION L-EVENT L-DELAY L-PUSH L-GAME
     MOVE 0 TO WS-THRESHOLD
     IF L-FLUID = 1
         MOVE 0.17578125 TO WS-THRESHOLD
     END-IF
     IF L-FLUID = 3
         MOVE 0.05859375 TO WS-THRESHOLD
     END-IF
     IF L-ROLL <= 0.17578125 AND L-START = 1 AND L-INFO = 1 AND L-ROLL < WS-THRESHOLD AND L-TIP = 1
         EVALUATE TRUE
             WHEN L-MUD = 1 AND L-FLUID = 1
                 MOVE 1 TO L-ACTION L-PUSH L-GAME
                 MOVE 1504 TO L-EVENT
             WHEN L-CAULDRON = 1
                 MOVE 2 TO L-ACTION
                 MOVE 1504 TO L-EVENT
                 COMPUTE L-DELAY = 50 + L-DY
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM GC6-TRANSFER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-DRIP-CONST.
*> USING the selector (1 to 10) (BINARY-LONG), the value out (7.2, 7.3): 1 water probability x 1e8, 2 lava probability x 1e8, 3 search length, 4 STALAGMITE_FALL_DISTANCE_OFFSET x 10,
*> 5 STALAGMITE_FALL_DAMAGE_MODIFIER, 6 the landing sound event, 7 and 8 the drip probabilities x 100 (plain, under a liquid source), 9 water 45 of 256, 10 lava 15 of 256.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 17578125.
    05 FILLER              BINARY-LONG VALUE 5859375.
    05 FILLER              BINARY-LONG VALUE 11.
    05 FILLER              BINARY-LONG VALUE 25.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 1045.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 12.
    05 FILLER              BINARY-LONG VALUE 45.
    05 FILLER              BINARY-LONG VALUE 15.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 10 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC6-DRIP-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FALL-ON.
*> USING the state is a pointed dripstone, its tip direction is up, its thickness is exactly tip (BINARY-LONG), the fall distance (FLOAT-LONG), the stalagmite damage applies, the
*> distance passed x 1000, the damage modifier x 1000 out (7.3 fallOn): causeFallDamage(distance + 2.5, 2.0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POINTED              BINARY-LONG.
 01 L-UP                   BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-SPECIAL              BINARY-LONG.
 01 L-PASSED               BINARY-LONG.
 01 L-MODIFIER             BINARY-LONG.
 PROCEDURE DIVISION USING L-POINTED L-UP L-TIP L-DISTANCE L-SPECIAL L-PASSED L-MODIFIER.
     MOVE 0 TO L-SPECIAL L-PASSED L-MODIFIER
     IF L-POINTED = 1 AND L-UP = 1 AND L-TIP = 1
         MOVE 1 TO L-SPECIAL
         COMPUTE L-PASSED ROUNDED = (L-DISTANCE + 2.5) * 1000
         MOVE 2000 TO L-MODIFIER
     END-IF
     GOBACK.
 END PROGRAM GC6-FALL-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FALL-CAUSE.
*> USING the fall distance, the modifier, the safe fall distance, the player's multiplier (FLOAT-LONG), the damage out (BINARY-LONG) (7.3, E5): floor((distance + 0.000001 - safe)
*> x modifier x multiplier), not below 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-MODIFIER             FLOAT-LONG.
 01 L-SAFE                 FLOAT-LONG.
 01 L-MULTIPLIER           FLOAT-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-MODIFIER L-SAFE L-MULTIPLIER L-DAMAGE.
     COMPUTE WS-V = (L-DISTANCE + 0.000001 - L-SAFE) * L-MODIFIER * L-MULTIPLIER
     COMPUTE L-DAMAGE = FUNCTION INTEGER(WS-V)
     IF L-DAMAGE < 0
         MOVE 0 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM GC6-FALL-CAUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CAULDRON-TICK.
*> USING a stalactite tip was found above, the fill fluid type (0 EMPTY, 1 water, 3 lava), canReceiveStalactiteDrip (BINARY-LONG), receiveStalactiteDrip runs out (8.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIP                  BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-RECEIVES             BINARY-LONG.
 PROCEDURE DIVISION USING L-TIP L-FLUID L-CAN L-RECEIVES.
     MOVE 0 TO L-RECEIVES
     IF L-TIP = 1 AND L-FLUID NOT = 0 AND L-CAN = 1
         MOVE 1 TO L-RECEIVES
     END-IF
     GOBACK.
 END PROGRAM GC6-CAULDRON-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CAULDRON-RECV.
*> USING the class (1 lava_cauldron, the default; 2 empty cauldron; 3 water_cauldron; 4 powder_snow_cauldron), the fluid (1 water, 3 lava, other), the level (BINARY-LONG), canReceive,
*> the action (0 nothing, 1 set water_cauldron level 1, 2 set lava_cauldron, 3 level + 1), the new level, level event, game event block_change out (8.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-GAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-FLUID L-LEVEL L-CAN L-ACTION L-NEW L-EVENT L-GAME.
     MOVE 0 TO L-CAN L-ACTION L-NEW L-EVENT L-GAME
     EVALUATE TRUE
         WHEN L-CLASS = 2
             MOVE 1 TO L-CAN
             EVALUATE L-FLUID
                 WHEN 1
                     MOVE 1 TO L-ACTION L-NEW L-GAME
                     MOVE 1047 TO L-EVENT
                 WHEN 3
                     MOVE 2 TO L-ACTION
                     MOVE 1 TO L-NEW L-GAME
                     MOVE 1046 TO L-EVENT
             END-EVALUATE
         WHEN L-CLASS = 3 AND L-FLUID = 1
             MOVE 1 TO L-CAN
             MOVE L-LEVEL TO L-NEW
             IF L-LEVEL < 3
                 MOVE 3 TO L-ACTION
                 COMPUTE L-NEW = L-LEVEL + 1
                 MOVE 1047 TO L-EVENT
                 MOVE 1 TO L-GAME
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-CAULDRON-RECV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-LEVEL-EVENT.
*> USING the level event id (BINARY-LONG), kind (1 local sound at the block, 2 particles only, 3 the drip particle without sound, 4 specified in another part, 0 not of this part),
*> volume x 10, pitch base x 100, pitch range x 100 out (8.2): the sounds have volume 2.0 and pitch 0.9 + nextFloat x 0.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-KIND L-VOLUME L-PITCH L-RANGE.
     MOVE 0 TO L-KIND L-VOLUME L-PITCH L-RANGE
     EVALUATE TRUE
         WHEN L-EVENT = 1045 OR L-EVENT = 1046 OR L-EVENT = 1047 OR L-EVENT = 1052
             MOVE 1 TO L-KIND
             MOVE 20 TO L-VOLUME
             MOVE 90 TO L-PITCH
             MOVE 10 TO L-RANGE
         WHEN L-EVENT = 1504
             MOVE 3 TO L-KIND
         WHEN L-EVENT = 3006
             MOVE 2 TO L-KIND
         WHEN L-EVENT = 3007
             MOVE 4 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-LEVEL-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-LEVEL-SOUND.
*> USING the level event id (BINARY-LONG), the sound key PIC X(64) out (blank for an event without a sound) (8.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-SOUND                PIC X(64).
 PROCEDURE DIVISION USING L-EVENT L-SOUND.
     MOVE SPACES TO L-SOUND
     EVALUATE L-EVENT
         WHEN 1045
             MOVE "block.pointed_dripstone.land" TO L-SOUND
         WHEN 1052
             MOVE "block.sulfur_spike.land" TO L-SOUND
         WHEN 1046
             MOVE "block.pointed_dripstone.drip_lava_into_cauldron" TO L-SOUND
         WHEN 1047
             MOVE "block.pointed_dripstone.drip_water_into_cauldron" TO L-SOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-LEVEL-SOUND.
