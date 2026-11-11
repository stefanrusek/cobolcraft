*> Falling blocks, the shared behaviour model and the falling block entity (docs/protocol/29b part 1 sections 1 to 4) as programs of plain numbers (GB- prefix), with
*> the gravity rules wired into the block-update hooks: GB-RULES-OPEN registers the rows of 3.1 for the falling blocks of the open block tables (called when a world
*> opens) and GB-FALL-TICK runs the scheduled tick (BU-HOOK effect 6). The falling block ENTITY has no entity type in this core: a scheduled fall puts the block at its
*> landing cell at once (the first cell whose cell below is not free), without the per-tick motion, the damage to entities, the landing events or the item drop of
*> the entity; those rules of 4.1 to 4.8 stay helpers (GB-FALL-STEP, GB-LAND, GB-EXPIRY, GB-FALL-DAMAGE, GB-FALL-NBT, GB-FORCE-TICK). Sections 5 to 7 (the bone meal
*> framework, crop helpers, saplings) are helpers only, at the end of the file.

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
 01 WS-ZERO2               BINARY-LONG VALUE 0.
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
                 CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GB-RULES-OPEN.

*> Sections 5 to 7 of 29b part 1 as helpers only: the bone meal framework, the crop helpers and saplings. Nothing here is called from the play path: the item flow needs a bone
*> meal item and a growth block that this core's content does not have, and the random ticks of crops and saplings read the raw brightness at a position (the light engine of 32
*> answers it) and the level random.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-BONEMEAL-ITEM.
*> USING the clicked block is a valid bone meal target, isBonemealSuccess, server side, the clicked face is sturdy, growWaterPlant grew something (BINARY-LONG), performs out, shrinks
*> out, level event 1505 data 15 out, result out (0 PASS, 1 success of growCrop, 2 success of growWaterPlant): BoneMealItem.useOn (5.3): a valid target always shrinks the stack on the
*> server; performBonemeal runs only when the success test passes; the water plant branch is tried only when growCrop was not.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-PERFORMS             BINARY-LONG.
 01 L-SHRINKS              BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALID L-SUCCESS L-SERVER L-STURDY L-WATER L-PERFORMS L-SHRINKS L-EVENT L-RESULT.
     MOVE 0 TO L-PERFORMS L-SHRINKS L-EVENT L-RESULT
     IF L-VALID = 1
         MOVE 1 TO L-RESULT
         IF L-SERVER = 1
             MOVE 1 TO L-SHRINKS L-EVENT
             IF L-SUCCESS = 1
                 MOVE 1 TO L-PERFORMS
             END-IF
         END-IF
     ELSE
         IF L-STURDY = 1 AND L-WATER = 1
             MOVE 2 TO L-RESULT
             IF L-SERVER = 1
                 MOVE 1 TO L-EVENT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB-BONEMEAL-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-BUSH-SPREAD.
*> USING per horizontal direction in the order north, east, south, west: the neighbour is air, the plant can survive there (eight BINARY-LONG in one group), the shuffled order of the four
*> directions (four BINARY-LONG of 1 to 4 in one group), valid out, chosen out (0 none, else the direction 1 to 4): BushBlock bone meal (5.4): valid when some neighbour is air and
*> survivable; the first direction of the shuffled order that is, is chosen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAGS.
    05 L-AIR               BINARY-LONG OCCURS 4 TIMES.
    05 L-SURVIVES          BINARY-LONG OCCURS 4 TIMES.
 01 L-ORDER.
    05 L-DIRECTION         BINARY-LONG OCCURS 4 TIMES.
 01 L-VALID                BINARY-LONG.
 01 L-CHOSEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS L-ORDER L-VALID L-CHOSEN.
     MOVE 0 TO L-VALID L-CHOSEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF L-AIR(WS-I) = 1 AND L-SURVIVES(WS-I) = 1
             MOVE 1 TO L-VALID
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4 OR L-CHOSEN > 0
         MOVE L-DIRECTION(WS-I) TO WS-D
         IF L-AIR(WS-D) = 1 AND L-SURVIVES(WS-D) = 1
             MOVE WS-D TO L-CHOSEN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GB-BUSH-SPREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-BEE-GATE.
*> USING crops grown since pollination, the nextFloat draw (FLOAT-LONG), the bee has nectar, has a valid hive, the nextInt(30) draw (BINARY-LONG), continues out, ticks out: Bee$BeeGrowCropGoal
*> (5.5): false at 10 or more crops or when the draw is below 0.3 (the float draw is made whatever the count), else true with nectar and a hive; the goal ticks on a draw of 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROWN                BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-NECTAR               BINARY-LONG.
 01 L-HIVE                 BINARY-LONG.
 01 L-TICK-DRAW            BINARY-LONG.
 01 L-CONTINUES            BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-GROWN L-DRAW L-NECTAR L-HIVE L-TICK-DRAW L-CONTINUES L-TICKS.
     MOVE 0 TO L-CONTINUES L-TICKS
     IF L-GROWN < 10 AND L-DRAW >= 0.3 AND L-NECTAR = 1 AND L-HIVE = 1
         MOVE 1 TO L-CONTINUES
     END-IF
     IF L-TICK-DRAW = 0
         MOVE 1 TO L-TICKS
     END-IF
     GOBACK.
 END PROGRAM GB-BEE-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-BEE-GROW.
*> USING the cell's kind (1 CropBlock, 2 StemBlock, 3 sweet_berry_bush, 4 cave vines and plant, 5 anything else, 6 pitcher crop), age, the largest age of the kind, the cave vines' MOB bone
*> meal is valid (BINARY-LONG), new age out (-1 no new state), counted out (1 the level event 2011 and the counter): the growth branches of 5.5 in their order; a pitcher crop is never grown.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-COUNTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-AGE L-MAX L-VALID L-NEW L-COUNTED.
     MOVE -1 TO L-NEW
     MOVE 0 TO L-COUNTED
     EVALUATE TRUE
         WHEN L-KIND = 1 AND L-AGE < L-MAX
             COMPUTE L-NEW = L-AGE + 1
         WHEN L-KIND = 2 AND L-AGE < 7
             COMPUTE L-NEW = L-AGE + 1
         WHEN L-KIND = 3 AND L-AGE < 3
             COMPUTE L-NEW = L-AGE + 1
         WHEN L-KIND = 4 AND L-VALID = 1
             MOVE L-AGE TO L-NEW
     END-EVALUATE
     IF L-NEW >= 0
         MOVE 1 TO L-COUNTED
     END-IF
     GOBACK.
 END PROGRAM GB-BEE-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-CROP-STATE.
*> USING age, the largest age, raw brightness at the position, the support below is in tag supports_crops (BINARY-LONG), max age out, randomly ticking out, enough light out, can survive out:
*> the CropBlock predicates (6.1): light 8 for survival.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 01 L-SUPPORT              BINARY-LONG.
 01 L-IS-MAX               BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 01 L-ENOUGH               BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-MAX L-LIGHT L-SUPPORT L-IS-MAX L-TICKING L-ENOUGH L-SURVIVES.
     MOVE 0 TO L-IS-MAX L-TICKING L-ENOUGH L-SURVIVES
     IF L-AGE >= L-MAX
         MOVE 1 TO L-IS-MAX
     ELSE
         MOVE 1 TO L-TICKING
     END-IF
     IF L-LIGHT >= 8
         MOVE 1 TO L-ENOUGH
         IF L-SUPPORT = 1
             MOVE 1 TO L-SURVIVES
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB-CROP-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-CROP-SPEED.
*> USING nine cell classes (0 none, 1 grows_crops, 3 grows_crops with moisture above 0) in the order dx -1 to 1 outer and dz -1 to 1 inner, the same block along x (west or east), along z (north
*> or south), at a diagonal (BINARY-LONG in one group of twelve), speed out (FLOAT-LONG): getGrowthSpeed (6.3): 1 plus each class (a quarter off the centre), halved once when along x and z both
*> or a diagonal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-CLASS             BINARY-LONG OCCURS 9 TIMES.
    05 L-ALONG-X           BINARY-LONG.
    05 L-ALONG-Z           BINARY-LONG.
    05 L-DIAGONAL          BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-IN L-SPEED.
     MOVE 1.0 TO L-SPEED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE L-CLASS(WS-I) TO WS-S
         IF WS-I NOT = 5
             COMPUTE WS-S = WS-S / 4
         END-IF
         ADD WS-S TO L-SPEED
     END-PERFORM
     IF (L-ALONG-X = 1 AND L-ALONG-Z = 1) OR L-DIAGONAL = 1
         COMPUTE L-SPEED = L-SPEED / 2
     END-IF
     GOBACK.
 END PROGRAM GB-CROP-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-CROP-TICK.
*> USING raw brightness, age, the largest age (BINARY-LONG), speed (FLOAT-LONG), the nextInt draw (BINARY-LONG), bound out, grows out: CropBlock.randomTick (6.2): needs light 9 and age below the
*> maximum; the bound is int(25.0f / speed) + 1 and the crop grows on a draw of 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 01 L-GROWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-AGE L-MAX L-SPEED L-DRAW L-BOUND L-GROWS.
     MOVE 0 TO L-BOUND L-GROWS
     IF L-LIGHT >= 9 AND L-AGE < L-MAX
         COMPUTE WS-Q = 25.0 / L-SPEED
         COMPUTE L-BOUND = FUNCTION INTEGER-PART(WS-Q) + 1
         IF L-DRAW = 0
             MOVE 1 TO L-GROWS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB-CROP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-CROP-BONEMEAL.
*> USING age, the largest age, the nextInt(4) draw (BINARY-LONG), valid out, new age out: CropBlock bone meal (6.4): valid below the maximum; newAge = min(max, age + U(2, 5)), U drawing nextInt(4) + 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-MAX L-DRAW L-VALID L-NEW.
     MOVE 0 TO L-VALID
     MOVE L-AGE TO L-NEW
     IF L-AGE < L-MAX
         MOVE 1 TO L-VALID
         COMPUTE L-NEW = FUNCTION MIN(L-MAX, L-AGE + L-DRAW + 2)
     END-IF
     GOBACK.
 END PROGRAM GB-CROP-BONEMEAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-SAPLING.
*> USING max local raw brightness above, the nextInt(7) draw, stage (BINARY-LONG), server side, canGrow, the cell above the minimum height is inside the build height (BINARY-LONG), the nextFloat draw
*> (FLOAT-LONG), random tick advances out, advance action out (0 stage 1 written with flags 260, 1 the tree grows), bone meal valid out, bone meal success out: SaplingBlock (7.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-CAN-GROW             BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 01 L-FLOAT                FLOAT-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-DRAW L-STAGE L-SERVER L-CAN-GROW L-INSIDE L-FLOAT L-TICK L-ACTION L-VALID L-SUCCESS.
     MOVE 0 TO L-TICK L-VALID L-SUCCESS
     IF L-LIGHT >= 9 AND L-DRAW = 0
         MOVE 1 TO L-TICK
     END-IF
     MOVE L-STAGE TO L-ACTION
     IF L-SERVER = 1 AND L-CAN-GROW = 1 AND L-INSIDE = 1
         MOVE 1 TO L-VALID
     END-IF
     IF L-FLOAT < 0.45
         MOVE 1 TO L-SUCCESS
     END-IF
     GOBACK.
 END PROGRAM GB-SAPLING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-WEIGHTED.
*> USING the weights of the list entries in order (four BINARY-LONG in one group, 0 for an absent entry), the nextInt(total) draw (BINARY-LONG), entry out (1 to 4, 0 for an empty list), draws out
*> (0 or 1): WeightedList.getRandom (7.2): an empty list draws nothing; the entry is the first whose cumulative range holds the draw.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-WEIGHTS.
    05 L-WEIGHT            BINARY-LONG OCCURS 4 TIMES.
 01 L-DRAW                 BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WEIGHTS L-DRAW L-ENTRY L-DRAWS.
     MOVE 0 TO L-ENTRY L-DRAWS WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         ADD L-WEIGHT(WS-I) TO WS-TOTAL
     END-PERFORM
     IF WS-TOTAL > 0
         MOVE 1 TO L-DRAWS
         MOVE L-DRAW TO WS-LEFT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4 OR L-ENTRY > 0
             IF L-WEIGHT(WS-I) > 0
                 SUBTRACT L-WEIGHT(WS-I) FROM WS-LEFT
                 IF WS-LEFT < 0
                     MOVE WS-I TO L-ENTRY
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM GB-WEIGHTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-GROWER.
*> USING grower (1 OAK, 2 SPRUCE, 3 MANGROVE, 4 AZALEA, 5 BIRCH, 6 JUNGLE, 7 ACACIA, 8 CHERRY, 9 DARK_OAK, 10 PALE_OAK, 11 POPLAR), the total weight of trees, of megaTrees, of flowerTrees, has a
*> shortestTreeType (BINARY-LONG out): the table of 7.4 (a single-entry list has weight 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
LINKAGE SECTION.
 01 L-GROWER               BINARY-LONG.
 01 L-TREES                BINARY-LONG.
 01 L-MEGA                 BINARY-LONG.
 01 L-FLOWERS              BINARY-LONG.
 01 L-SHORTEST             BINARY-LONG.
 PROCEDURE DIVISION USING L-GROWER L-TREES L-MEGA L-FLOWERS L-SHORTEST.
     EVALUATE L-GROWER
         WHEN 1
             MOVE 10 TO L-TREES
             MOVE 0 TO L-MEGA
             MOVE 10 TO L-FLOWERS
             MOVE 1 TO L-SHORTEST
         WHEN 2
             MOVE 1 TO L-TREES
             MOVE 2 TO L-MEGA
             MOVE 0 TO L-FLOWERS
             MOVE 1 TO L-SHORTEST
         WHEN 3
             MOVE 100 TO L-TREES
             MOVE 0 TO L-MEGA L-FLOWERS
             MOVE 1 TO L-SHORTEST
         WHEN 4
             MOVE 1 TO L-TREES
             MOVE 0 TO L-MEGA L-FLOWERS
             MOVE 1 TO L-SHORTEST
         WHEN 5
             MOVE 1 TO L-TREES
             MOVE 0 TO L-MEGA
             MOVE 1 TO L-FLOWERS L-SHORTEST
         WHEN 6
             MOVE 1 TO L-TREES L-MEGA L-SHORTEST
             MOVE 0 TO L-FLOWERS
         WHEN 7
             MOVE 1 TO L-TREES
             MOVE 0 TO L-MEGA L-FLOWERS
             MOVE 1 TO L-SHORTEST
         WHEN 8
             MOVE 1 TO L-TREES L-FLOWERS L-SHORTEST
             MOVE 0 TO L-MEGA
         WHEN 9
             MOVE 0 TO L-TREES L-FLOWERS L-SHORTEST
             MOVE 1 TO L-MEGA
         WHEN 10
             MOVE 0 TO L-TREES L-FLOWERS L-SHORTEST
             MOVE 1 TO L-MEGA
         WHEN OTHER
             MOVE 3 TO L-TREES
             MOVE 0 TO L-MEGA L-FLOWERS
             MOVE 1 TO L-SHORTEST
     END-EVALUATE
     GOBACK.
 END PROGRAM GB-GROWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-TREE-CAN-GROW.
*> USING the normal pick is null (the list is empty or the draw found nothing), the mega pick is not null, a 2 x 2 group of the sapling exists (BINARY-LONG), can grow out, and the dx, dz of the
*> box test (BINARY-LONG; flowers within -2 to 2, -1 to 1, -2 to 2), inside out: TreeGrower.canGrow and hasFlowers (7.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NORMAL-NULL          BINARY-LONG.
 01 L-MEGA                 BINARY-LONG.
 01 L-GROUP                BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING L-NORMAL-NULL L-MEGA L-GROUP L-DX L-DY L-DZ L-CAN L-INSIDE.
     MOVE 1 TO L-CAN
     IF L-NORMAL-NULL = 1 AND L-MEGA = 1
         MOVE L-GROUP TO L-CAN
     END-IF
     MOVE 0 TO L-INSIDE
     IF L-DX >= -2 AND L-DX <= 2 AND L-DY >= -1 AND L-DY <= 1 AND L-DZ >= -2 AND L-DZ <= 2
         MOVE 1 TO L-INSIDE
     END-IF
     GOBACK.
 END PROGRAM GB-TREE-CAN-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-TWO-BY-TWO.
*> USING sixteen flags (the four candidate squares in the order (0, 0), (0, -1), (-1, 0), (-1, -1) of (dx, dz), four cells each, 1 when the cell holds the same block as the sapling), dx out, dz out,
*> found out: findTwoByTwoSaplingPos (7.2): the first square whose four cells all match.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-DXS                 PIC X(4) VALUE "0011".
 01 WS-DZS                 PIC X(4) VALUE "0101".
 LINKAGE SECTION.
 01 L-FLAGS.
    05 L-FLAG              BINARY-LONG OCCURS 16 TIMES.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS L-DX L-DZ L-FOUND.
     MOVE 0 TO L-DX L-DZ L-FOUND
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 4 OR L-FOUND = 1
         MOVE 1 TO WS-ALL
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
             IF L-FLAG((WS-S - 1) * 4 + WS-C) = 0
                 MOVE 0 TO WS-ALL
             END-IF
         END-PERFORM
         IF WS-ALL = 1
             MOVE 1 TO L-FOUND
             MOVE WS-DXS(WS-S:1) TO L-DX
             MOVE WS-DZS(WS-S:1) TO L-DZ
             COMPUTE L-DX = 0 - L-DX
             COMPUTE L-DZ = 0 - L-DZ
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GB-TWO-BY-TWO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-GROW-TREE.
*> USING the mega pick is not null, it is registered, a 2 x 2 group was found, the normal pick is not null, it is registered, place succeeded (BINARY-LONG), action out (0 nothing, 1 mega tree placed,
*> 2 one-sapling tree placed), restore out (1 the removed saplings return with flags 260), result out, remove flags out (818): TreeGrower.growTree (7.3): the mega branch has no fallback to a
*> single tree.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MEGA                 BINARY-LONG.
 01 L-REGISTERED           BINARY-LONG.
 01 L-GROUP                BINARY-LONG.
 01 L-NORMAL               BINARY-LONG.
 01 L-NORMAL-REGISTERED    BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-RESTORE              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-REMOVE-FLAGS         BINARY-LONG.
 PROCEDURE DIVISION USING L-MEGA L-REGISTERED L-GROUP L-NORMAL L-NORMAL-REGISTERED L-PLACE L-ACTION L-RESTORE L-RESULT L-REMOVE-FLAGS.
     MOVE 0 TO L-ACTION L-RESTORE L-RESULT
     MOVE 818 TO L-REMOVE-FLAGS
     EVALUATE TRUE
         WHEN L-MEGA = 1 AND L-REGISTERED = 1 AND L-GROUP = 1
             MOVE 1 TO L-ACTION
             MOVE L-PLACE TO L-RESULT
             IF L-PLACE = 0
                 MOVE 1 TO L-RESTORE
             END-IF
         WHEN L-NORMAL = 1 AND L-NORMAL-REGISTERED = 1
             MOVE 2 TO L-ACTION
             MOVE L-PLACE TO L-RESULT
             IF L-PLACE = 0
                 MOVE 1 TO L-RESTORE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GB-GROW-TREE.
