*> Falling blocks, the shared behaviour model and the falling block entity (docs/protocol/29b part 1 sections 1 to 4) as programs of plain numbers (GB- prefix), with
*> the gravity rules wired into the block-update hooks: GB-RULES-OPEN registers the rows of 3.1 for the falling blocks of the open block tables (called when a world
*> opens) and GB-FALL-TICK runs the scheduled tick (BU-HOOK effect 6). The falling block ENTITY has no entity type in this core: a scheduled fall puts the block at its
*> landing cell at once (the first cell whose cell below is not free), without the per-tick motion, the damage to entities, the landing events or the item drop of
*> the entity; those rules of 4.1 to 4.8 stay helpers (GB-FALL-STEP, GB-LAND, GB-EXPIRY, GB-FALL-DAMAGE, GB-FALL-NBT, GB-FORCE-TICK). Sections 5 to 7 (the bone meal
*> framework, crop helpers, saplings) are not in this file.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-PART.
*> USING block key (PIC X(48)), owning part (1 to 8), section times ten (BINARY-LONG out): the block-name table of 1.3 for the blocks it lists (0 and 0 otherwise).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-PART                 BINARY-LONG.
 01 L-SECTION              BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PART L-SECTION.
     MOVE 0 TO L-PART L-SECTION
     COMPUTE WS-N = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
     EVALUATE TRUE
         WHEN L-KEY = "minecraft:sand" OR L-KEY = "minecraft:red_sand" OR L-KEY = "minecraft:gravel"
             MOVE 1 TO L-PART
             MOVE 32 TO L-SECTION
         WHEN L-KEY = "minecraft:suspicious_sand" OR L-KEY = "minecraft:suspicious_gravel"
             MOVE 1 TO L-PART
             MOVE 35 TO L-SECTION
         WHEN WS-N > 26 AND L-KEY(WS-N - 15:16) = "_concrete_powder"
             MOVE 1 TO L-PART
             MOVE 33 TO L-SECTION
         WHEN L-KEY = "minecraft:anvil" OR L-KEY = "minecraft:chipped_anvil" OR L-KEY = "minecraft:damaged_anvil"
             MOVE 1 TO L-PART
             MOVE 34 TO L-SECTION
         WHEN L-KEY = "minecraft:dragon_egg"
             MOVE 1 TO L-PART
             MOVE 36 TO L-SECTION
         WHEN L-KEY = "minecraft:scaffolding"
             MOVE 1 TO L-PART
             MOVE 37 TO L-SECTION
         WHEN L-KEY = "minecraft:pointed_dripstone" OR L-KEY = "minecraft:sulfur_spike"
             MOVE 6 TO L-PART
             MOVE 38 TO L-SECTION
         WHEN L-KEY = "minecraft:mangrove_propagule"
             MOVE 2 TO L-PART
             MOVE 74 TO L-SECTION
     END-EVALUATE
     GOBACK.
 END PROGRAM GB-PART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-TRIGGER.
*> USING trigger code (1 RT, 2 ST, 3 PL, 4 NU, 5 SU, 6 EV, 7 ET), kind out (the two-letter code as PIC XX), runs on a scheduled tick out: the trigger kinds of 2.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CODES               PIC X(14) VALUE "RTSTPLNUSUEVET".
 LINKAGE SECTION.
 01 L-TRIGGER              BINARY-LONG.
 01 L-KIND                 PIC XX.
 01 L-SCHEDULED            BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGER L-KIND L-SCHEDULED.
     MOVE WS-CODES(L-TRIGGER * 2 - 1:2) TO L-KIND
     MOVE 0 TO L-SCHEDULED
     IF L-TRIGGER = 2
         MOVE 1 TO L-SCHEDULED
     END-IF
     GOBACK.
 END PROGRAM GB-TRIGGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-PROBABILITY.
*> USING notation (1 for 1/N, 2 for P(p), 3 for U(a, b)), N or the lower bound a, b (BINARY-LONG), p (FLOAT-LONG), the draw (an integer for 1/N and U, a float in p's
*> case), result out (1 the effect happens for 1/N and P(p); the value for U) (2.4): 1/N happens on draw 0; P(p) when the float draw is below p; U(a, b) is a when a >=
*> b, else draw + a for a draw of 0 to b - a (the caller draws nextInt(b - a + 1)); draws made out: 1 for each notation but U with a >= b (no draw).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOTATION             BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-P                    FLOAT-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-FLOAT-DRAW           FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-NOTATION L-A L-B L-P L-DRAW L-FLOAT-DRAW L-RESULT L-DRAWS.
     MOVE 0 TO L-RESULT
     MOVE 1 TO L-DRAWS
     EVALUATE L-NOTATION
         WHEN 1
             IF L-DRAW = 0
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 2
             IF L-FLOAT-DRAW < L-P
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN OTHER
             IF L-A >= L-B
                 MOVE L-A TO L-RESULT
                 MOVE 0 TO L-DRAWS
             ELSE
                 COMPUTE L-RESULT = L-DRAW + L-A
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GB-PROBABILITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-RATE.
*> USING random_tick_speed, N (BINARY-LONG), per random tick x 1000000, per game tick of a 1/N effect x 1000000000 (BINARY-DOUBLE out): 2.4: a random-ticking block gets
*> speed / 4096 random ticks a game tick and a 1/N effect happens speed / (4096 N) times a game tick (0 at speed 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPEED                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-TICKS                BINARY-DOUBLE.
 01 L-EFFECT               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SPEED L-N L-TICKS L-EFFECT.
     COMPUTE L-TICKS ROUNDED = L-SPEED * 1000000 / 4096
     COMPUTE L-EFFECT ROUNDED = L-SPEED * 1000000000 / (4096 * L-N)
     GOBACK.
 END PROGRAM GB-RATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-IS-FREE.
*> USING the state is air, it is in tag fire, it is a liquid, it is replaceable (BINARY-LONG), free out: FallingBlock.isFree (3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-REPLACEABLE          BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-FIRE L-LIQUID L-REPLACEABLE L-FREE.
     MOVE 0 TO L-FREE
     IF L-AIR = 1 OR L-FIRE = 1 OR L-LIQUID = 1 OR L-REPLACEABLE = 1
         MOVE 1 TO L-FREE
     END-IF
     GOBACK.
 END PROGRAM GB-IS-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-FALL-DECIDE.
*> USING the cell below is free, y of the block, the level's minimum y (BINARY-LONG), falls out: the scheduled tick of 3.1: nothing unless the cell below is free and y >= minY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FREE                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-FALLS                BINARY-LONG.
 PROCEDURE DIVISION USING L-FREE L-Y L-MIN-Y L-FALLS.
     MOVE 0 TO L-FALLS
     IF L-FREE = 1 AND L-Y >= L-MIN-Y
         MOVE 1 TO L-FALLS
     END-IF
     GOBACK.
 END PROGRAM GB-FALL-DECIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-DELAY.
*> USING block kind (1 sand, gravel, concrete powder, anvil; 2 dragon egg; 3 scaffolding; 4 brushable), delay out: getDelayAfterPlace (3.1, 3.5, 3.6, 3.7): 2, dragon egg 5, scaffolding 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DELAY.
     MOVE 2 TO L-DELAY
     IF L-KIND = 2
         MOVE 5 TO L-DELAY
     END-IF
     IF L-KIND = 3
         MOVE 1 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM GB-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-TOUCHES.
*> USING the powder's own cell is water, water neighbour flags in the order down, up, north, south, west, east, sturdy face flags (towards the powder) in the same order (twelve
*> BINARY-LONG in one group), touches out: touchesLiquid (3.3): the cell below counts only when the own cell is water; a water neighbour whose face is not sturdy.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-OWN                  BINARY-LONG.
 01 L-FLAGS.
    05 L-WATER             BINARY-LONG OCCURS 6 TIMES.
    05 L-STURDY            BINARY-LONG OCCURS 6 TIMES.
 01 L-TOUCHES              BINARY-LONG.
 PROCEDURE DIVISION USING L-OWN L-FLAGS L-TOUCHES.
     MOVE 0 TO L-TOUCHES
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
         IF L-WATER(WS-D) = 1 AND L-STURDY(WS-D) = 0 AND (WS-D > 1 OR L-OWN = 1)
             MOVE 1 TO L-TOUCHES
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GB-TOUCHES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-SOLIDIFY.
*> USING the state's fluid is water (canSolidify), touches liquid (BINARY-LONG), solidify out; and the cause (1 placement state, 2 shape update, 3 landing): the concrete
*> powder rules of 3.3: shouldSolidify = canSolidify or touchesLiquid for the placement and the landing; a shape update solidifies when it touches liquid.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-TOUCHES              BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-SOLIDIFY             BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-TOUCHES L-CAUSE L-SOLIDIFY.
     MOVE 0 TO L-SOLIDIFY
     IF L-CAUSE = 2
         MOVE L-TOUCHES TO L-SOLIDIFY
     ELSE
         IF L-WATER = 1 OR L-TOUCHES = 1
             MOVE 1 TO L-SOLIDIFY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB-SOLIDIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-ANVIL.
*> USING anvil state (0 anvil, 1 chipped, 2 damaged), silent (BINARY-LONG), damaged state out (-1 null), hurt per block x 10 out, hurt maximum out, land event out (1031 or 0),
*> broken event out (1029 or 0): the anvil rules of 3.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-SILENT               BINARY-LONG.
 01 L-DAMAGED              BINARY-LONG.
 01 L-HURT                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-LAND                 BINARY-LONG.
 01 L-BROKEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SILENT L-DAMAGED L-HURT L-MAX L-LAND L-BROKEN.
     MOVE -1 TO L-DAMAGED
     IF L-STATE < 2
         COMPUTE L-DAMAGED = L-STATE + 1
     END-IF
     MOVE 20 TO L-HURT
     MOVE 40 TO L-MAX
     MOVE 0 TO L-LAND L-BROKEN
     IF L-SILENT = 0
         MOVE 1031 TO L-LAND
         MOVE 1029 TO L-BROKEN
     END-IF
     GOBACK.
 END PROGRAM GB-ANVIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-BRUSHABLE.
*> USING a brushable block entity is there, the cell below is free, y >= minY (BINARY-LONG), check reset out, falls out, cancel drop out: the tick of 3.5 (the reset first, then the
*> fall of 3.1 with the drop disabled).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-Y-OK                 BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 01 L-FALLS                BINARY-LONG.
 01 L-CANCEL               BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-FREE L-Y-OK L-RESET L-FALLS L-CANCEL.
     MOVE L-ENTITY TO L-RESET
     MOVE 0 TO L-FALLS L-CANCEL
     IF L-FREE = 1 AND L-Y-OK = 1
         MOVE 1 TO L-FALLS L-CANCEL
     END-IF
     GOBACK.
 END PROGRAM GB-BRUSHABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-EGG-OFFSET.
*> USING the six draws (nextInt(16), nextInt(16), nextInt(8), nextInt(8), nextInt(16), nextInt(16)) (BINARY-LONG), x, y, z offsets out: one attempt of the dragon egg teleport (3.6): (a1 - a2,
*> b1 - b2, c1 - c2); the attempts are at most 1000.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAWS.
    05 L-DRAW              BINARY-LONG OCCURS 6 TIMES.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAWS L-DX L-DY L-DZ.
     COMPUTE L-DX = L-DRAW(1) - L-DRAW(2)
     COMPUTE L-DY = L-DRAW(3) - L-DRAW(4)
     COMPUTE L-DZ = L-DRAW(5) - L-DRAW(6)
     GOBACK.
 END PROGRAM GB-EGG-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-SCAFFOLD-DISTANCE.
*> USING the cell below is scaffolding, it has a sturdy top face, its distance, the four horizontal neighbours' distances (a neighbour that is not scaffolding passes 7) (BINARY-LONG in one group
*> of seven), distance out: getDistance (3.7): 0 over a sturdy non-scaffolding block, else the minimum of 7, the distance below (when scaffolding) and each neighbour's distance + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-NEIGHBOUR           BINARY-LONG.
 LINKAGE SECTION.
 01 L-SCAFFOLD             BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-IN.
    05 L-BELOW             BINARY-LONG.
    05 L-N                 BINARY-LONG OCCURS 4 TIMES.
 01 L-DISTANCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-SCAFFOLD L-STURDY L-IN L-DISTANCE.
     MOVE 7 TO L-DISTANCE
     IF L-SCAFFOLD = 0 AND L-STURDY = 1
         MOVE 0 TO L-DISTANCE
         GOBACK
     END-IF
     IF L-SCAFFOLD = 1 AND L-BELOW < L-DISTANCE
         MOVE L-BELOW TO L-DISTANCE
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-NEIGHBOUR = L-N(WS-I) + 1
         IF WS-NEIGHBOUR < L-DISTANCE
             MOVE WS-NEIGHBOUR TO L-DISTANCE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GB-SCAFFOLD-DISTANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-SCAFFOLD-TICK.
*> USING the old distance, the new distance, the cell below is scaffolding (BINARY-LONG), bottom out, action out (0 nothing, 1 write the new state, 2 destroy with drops, 3 fall as an entity):
*> ScaffoldingBlock.tick (3.7): a new distance of 7 falls when the old one was 7 too, else destroys; otherwise a changed state is written; bottom = distance above 0 and no scaffolding below.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-BOTTOM               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-OLD L-NEW L-BELOW L-BOTTOM L-ACTION.
     MOVE 0 TO L-BOTTOM L-ACTION
     IF L-NEW > 0 AND L-BELOW = 0
         MOVE 1 TO L-BOTTOM
     END-IF
     EVALUATE TRUE
         WHEN L-NEW = 7 AND L-OLD = 7
             MOVE 3 TO L-ACTION
         WHEN L-NEW = 7
             MOVE 2 TO L-ACTION
         WHEN L-NEW NOT = L-OLD
             MOVE 1 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM GB-SCAFFOLD-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-FALL-STEP.
*> USING vy in and out, fall distance in and out (FLOAT-LONG): one tick of the falling block entity's motion (4.2 steps 2 and 8): vy -= 0.04, the entity moves by vy (the distance
*> grows by -vy), then vy is multiplied by the air drag 0.98f (0.9800000190734863 widened).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VY                   FLOAT-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 PROCEDURE DIVISION USING L-VY L-DISTANCE.
     COMPUTE L-VY = L-VY - 0.04
     COMPUTE L-DISTANCE = L-DISTANCE - L-VY
     COMPUTE L-VY = L-VY * 0.9800000190734863
     GOBACK.
 END PROGRAM GB-FALL-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-LAND.
*> USING the replaced state is a moving piston, cancelDrop, canReplace, the entity state can survive, the cell below is free (after the concrete-in-water exception), dropItem, the rule
*> entity_drops, setBlockAndUpdate succeeded (BINARY-LONG), action out: the landing of 4.3: 0 stop (a moving piston), 1 discard and onBrokenAfterFall (cancelDrop), 2 placed (and onLand), 3 write
*> failed with drops: discard, onBrokenAfterFall, spawn the item, 4 write failed and no drop: the entity stays for the next tick, 5 cannot be placed with drops: discard,
*> onBrokenAfterFall and the item, 6 cannot be placed, nothing dropped (discard only).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PISTON               BINARY-LONG.
 01 L-CANCEL               BINARY-LONG.
 01 L-REPLACE              BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-BELOW-FREE           BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-PISTON L-CANCEL L-REPLACE L-SURVIVE L-BELOW-FREE L-DROP L-RULE L-WRITE L-ACTION.
     EVALUATE TRUE
         WHEN L-PISTON = 1
             MOVE 0 TO L-ACTION
         WHEN L-CANCEL = 1
             MOVE 1 TO L-ACTION
         WHEN L-REPLACE = 1 AND L-SURVIVE = 1 AND L-BELOW-FREE = 0
             IF L-WRITE = 1
                 MOVE 2 TO L-ACTION
             ELSE
                 IF L-DROP = 1 AND L-RULE = 1
                     MOVE 3 TO L-ACTION
                 ELSE
                     MOVE 4 TO L-ACTION
                 END-IF
             END-IF
         WHEN OTHER
             IF L-DROP = 1 AND L-RULE = 1
                 MOVE 5 TO L-ACTION
             ELSE
                 MOVE 6 TO L-ACTION
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GB-LAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-EXPIRY.
*> USING time, the block y of the entity, the level's minimum y and maximum y, dropItem, entity_drops (BINARY-LONG), expired out, drop out: 4.4: expired when time > 100 with y at or below
*> the minimum or above the maximum, or time > 600; the item drops only with dropItem and the rule.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-MAX-Y                BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-EXPIRED              BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-Y L-MIN-Y L-MAX-Y L-DROP L-RULE L-EXPIRED L-ITEM.
     MOVE 0 TO L-EXPIRED L-ITEM
     IF (L-TIME > 100 AND (L-Y <= L-MIN-Y OR L-Y > L-MAX-Y)) OR L-TIME > 600
         MOVE 1 TO L-EXPIRED
         IF L-DROP = 1 AND L-RULE = 1
             MOVE 1 TO L-ITEM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB-EXPIRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-FALL-DAMAGE.
*> USING fall distance, damage per distance (FLOAT-LONG), damage maximum, hurt entities, the state is in tag anvil (BINARY-LONG), the nextFloat draw (FLOAT-LONG), n out, damage out (FLOAT-LONG), chip
*> out (0 none, 1 the anvil becomes the next damaged state, 2 the anvil breaks: cancelDrop), draw made out: causeFallDamage (4.6): n = ceil(distance - 1); damage = min(floor(n x per), max);
*> the chip test nextFloat() < 0.05 + n x 0.05 only when it is an anvil with damage above 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-PER                  FLOAT-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-HURTS                BINARY-LONG.
 01 L-ANVIL                BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-N                    BINARY-LONG.
 01 L-DAMAGE               FLOAT-LONG.
 01 L-CHIP                 BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-PER L-MAX L-HURTS L-ANVIL L-DRAW L-N L-DAMAGE L-CHIP L-DRAWN.
     MOVE 0 TO L-N L-DAMAGE L-CHIP L-DRAWN
     IF L-HURTS = 0
         GOBACK
     END-IF
     COMPUTE WS-X = L-DISTANCE - 1
     COMPUTE L-N = FUNCTION INTEGER(WS-X)
     IF L-N < WS-X
         ADD 1 TO L-N
     END-IF
     IF L-N < 0
         MOVE 0 TO L-N
         GOBACK
     END-IF
     COMPUTE WS-X = L-N * L-PER
     COMPUTE L-DAMAGE = FUNCTION INTEGER(WS-X + 0.000001)
     IF L-DAMAGE > L-MAX
         MOVE L-MAX TO L-DAMAGE
     END-IF
     IF L-ANVIL = 1 AND L-DAMAGE > 0
         MOVE 1 TO L-DRAWN
         COMPUTE WS-LIMIT = 0.05 + L-N * 0.05
         IF L-DRAW < WS-LIMIT
             MOVE 1 TO L-CHIP
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB-FALL-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-FALL-NBT.
*> USING the state is in tag anvil, a TileEntityData exists (BINARY-LONG), HurtEntities default out, FallHurtMax default out, DropItem default out, TileEntityData written out, source and target
*> are exactly one the End (BINARY-LONG in one group of two, then the teleport made a duplicate), force tick out: the defaults of 4.7 and the forced tick of 4.8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ANVIL                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-HURT                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-WRITTEN              BINARY-LONG.
 01 L-SOURCE-END           BINARY-LONG.
 01 L-TARGET-END           BINARY-LONG.
 01 L-DUPLICATE            BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ANVIL L-DATA L-HURT L-MAX L-DROP L-WRITTEN L-SOURCE-END L-TARGET-END L-DUPLICATE L-FORCE.
     MOVE L-ANVIL TO L-HURT
     MOVE 40 TO L-MAX
     MOVE 1 TO L-DROP
     MOVE L-DATA TO L-WRITTEN
     MOVE 0 TO L-FORCE
     IF L-DUPLICATE = 1 AND L-SOURCE-END NOT = L-TARGET-END
         MOVE 1 TO L-FORCE
     END-IF
     GOBACK.
 END PROGRAM GB-FALL-NBT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-FALL-TICK.
*> USING dimension row, x, y, z (BINARY-LONG): the scheduled tick of a falling block (3.1 ST, BU-HOOK effect 6): nothing unless the cell below is free and y >= the dimension's minimum
*> y (GB-FALL-DECIDE; a cell is free when it has no collision, the air, liquids and the replaceable blocks of this approximation); then the block's cell is cleared (flags 3, as
*> FallingBlockEntity.fall) and the block is written at its landing cell, the lowest of the free cells below it whose cell below is not free (4.3 without the entity's flight, the
*> concrete powder solidification and the events).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-STATE               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-FALLS               BINARY-LONG.
 01 WS-LAND                BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     COMPUTE WS-BELOW = L-Y - 1
     MOVE 0 TO WS-FREE
     IF WS-BELOW >= DM-MIN-Y(L-DIM)
         CALL "FLUID-CELL" USING L-DIM L-X WS-BELOW L-Z WS-STATE2 WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         MOVE WS-HOLDS TO WS-FREE
     END-IF
     CALL "GB-FALL-DECIDE" USING WS-FREE L-Y DM-MIN-Y(L-DIM) WS-FALLS
     IF WS-FALLS = 0
         GOBACK
     END-IF
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-AIR WS-FLAGS WS-BUDGET WS-RESULT
     MOVE WS-BELOW TO WS-LAND
     PERFORM UNTIL WS-LAND <= DM-MIN-Y(L-DIM)
         COMPUTE WS-NEXT = WS-LAND - 1
         CALL "FLUID-CELL" USING L-DIM L-X WS-NEXT L-Z WS-STATE2 WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         IF WS-HOLDS = 0
             EXIT PERFORM
         END-IF
         MOVE WS-NEXT TO WS-LAND
     END-PERFORM
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X WS-LAND L-Z WS-STATE WS-FLAGS WS-BUDGET WS-RESULT
     GOBACK.
 END PROGRAM GB-FALL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-RULES-OPEN.
*> No parameters: called when a world opens (CORE-WORLD-OPEN): registers the hook rows of 3.1 (BU-RULE-ADD) for each falling block of the open block tables that is not already
*> registered: sand, red sand, gravel, the anvils, the dragon egg and the concrete powders: onPlace and updateShape schedule the block's tick after its delay (2, dragon egg 5), and the
*> scheduled tick runs GB-FALL-TICK (effect 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BUSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG.
 01 WS-BLOCK-KIND          BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BU-ENSURE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         CALL "GB-PART" USING CB-KEY(WS-I) WS-PART WS-SECTION
         IF WS-PART = 1 AND (WS-SECTION = 32 OR WS-SECTION = 33 OR WS-SECTION = 34 OR WS-SECTION = 36)
             COMPUTE WS-BLOCK = WS-I - 1
             MOVE 1 TO WS-BLOCK-KIND
             IF WS-SECTION = 36
                 MOVE 2 TO WS-BLOCK-KIND
             END-IF
             CALL "GB-DELAY" USING WS-BLOCK-KIND WS-DELAY
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > BU-RULE-COUNT
                 IF BU-R-KIND(WS-R) = 7 AND BU-R-BLOCK(WS-R) = WS-BLOCK AND BU-R-EFFECT(WS-R) = 6
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0
                 MOVE 1 TO WS-KIND
                 MOVE 3 TO WS-EFFECT
                 CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-DELAY
                 MOVE 4 TO WS-KIND
                 CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-DELAY
                 MOVE 7 TO WS-KIND
                 MOVE 6 TO WS-EFFECT
                 CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GB-RULES-OPEN.
