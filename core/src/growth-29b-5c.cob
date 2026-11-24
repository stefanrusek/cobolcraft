*> Waxing, scraping, wax-off and lightning (docs/protocol/29b part 5, sections 7 and 8) as programs of plain numbers (GC5- prefix), helpers like those of growth-29b-5.cob:
*> the caller reads the level and applies the decision. Directions are numbered as Direction.values(): 1 down, 2 up, 3 north, 4 south, 5 west, 6 east.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-WAX-ON.
*> USING the clicked block has a waxed entry, the player is a server player, the block is a chest whose type is not single (BINARY-LONG), result (1 success, 0 pass), advancement
*> trigger, stack shrink, setBlock flags, level event, the partner half gets game event, event and sound out (7.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WAXED                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-CHEST                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-ADVANCEMENT          BINARY-LONG.
 01 L-SHRINK               BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-PARTNER              BINARY-LONG.
 PROCEDURE DIVISION USING L-WAXED L-SERVER L-CHEST L-RESULT L-ADVANCEMENT L-SHRINK L-FLAGS L-EVENT L-PARTNER.
     MOVE 0 TO L-RESULT L-ADVANCEMENT L-SHRINK L-FLAGS L-EVENT L-PARTNER
     IF L-WAXED = 1
         MOVE 1 TO L-RESULT L-SHRINK
         MOVE 11 TO L-FLAGS
         MOVE 3003 TO L-EVENT
         MOVE L-SERVER TO L-ADVANCEMENT
         MOVE L-CHEST TO L-PARTNER
     END-IF
     GOBACK.
 END PROGRAM GC5-WAX-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-DISPENSE.
*> USING a waxed block exists for the cell in front (BINARY-LONG), the block is set, setBlockAndUpdate flags, level event, stack shrink, success out (7.2): otherwise the default
*> optional behaviour (all 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WAXED                BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-SHRINK               BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-WAXED L-SET L-FLAGS L-EVENT L-SHRINK L-SUCCESS.
     MOVE 0 TO L-SET L-FLAGS L-EVENT L-SHRINK L-SUCCESS
     IF L-WAXED = 1
         MOVE 1 TO L-SET L-SHRINK L-SUCCESS
         MOVE 3 TO L-FLAGS
         MOVE 3003 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM GC5-DISPENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-AXE-ENTRY.
*> USING the index of the transformation in axe.json (0 to 6) (BINARY-LONG), the number of rules, sound (1 item.axe.strip, 2 item.axe.scrape, 3 item.axe.wax_off), particle (0 none,
*> 1 scrape, 2 wax_off), update_from_neighbors, transform_type copper_chest out (7.3): scrape and wax-off lists leave out the chest and the door families (15 - 2 = 13).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-RULES                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-PARTICLE             BINARY-LONG.
 01 L-UPDATE               BINARY-LONG.
 01 L-CHEST                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-RULES L-SOUND L-PARTICLE L-UPDATE L-CHEST.
     MOVE 25 TO L-RULES
     MOVE 1 TO L-SOUND L-UPDATE
     MOVE 0 TO L-PARTICLE L-CHEST
     EVALUATE L-INDEX
         WHEN 1
             COMPUTE L-RULES = (15 - 2) * 3
             MOVE 2 TO L-SOUND
             MOVE 1 TO L-PARTICLE
         WHEN 2 THRU 3
             MOVE 3 TO L-RULES
             MOVE 2 TO L-SOUND
             MOVE 1 TO L-PARTICLE
             MOVE 0 TO L-UPDATE
             IF L-INDEX = 2
                 MOVE 1 TO L-CHEST
             END-IF
         WHEN 4
             COMPUTE L-RULES = (15 - 2) * 4
             MOVE 3 TO L-SOUND
             MOVE 2 TO L-PARTICLE
         WHEN 5 THRU 6
             MOVE 4 TO L-RULES
             MOVE 3 TO L-SOUND
             MOVE 2 TO L-PARTICLE
             MOVE 0 TO L-UPDATE
             IF L-INDEX = 5
                 MOVE 1 TO L-CHEST
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC5-AXE-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-AXE-PARTICLE.
*> USING the particle (1 scrape, 2 wax_on, 3 wax_off) (BINARY-LONG), the level event id out (7.3 step 9): 3005, 3003, 3004.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PARTICLE             BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-PARTICLE L-EVENT.
     EVALUATE L-PARTICLE
         WHEN 1
             MOVE 3005 TO L-EVENT
         WHEN 2
             MOVE 3003 TO L-EVENT
         WHEN OTHER
             MOVE 3004 TO L-EVENT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC5-AXE-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-AXE-TRANSFORM.
*> USING the used hand is the main hand, the off-hand holds a blocks_attacks item, the player is sneaking, a transformation applies, the stack is stackable, the transformation
*> type is copper_chest, the old state's chest type is not single (BINARY-LONG), result (1 success, 0 pass), item cost (1 consume one, 2 damage by item_damage_per_use),
*> setBlock flags, partner game event and particle event out (7.3 transformBlock).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAIN                 BINARY-LONG.
 01 L-SHIELD               BINARY-LONG.
 01 L-SNEAK                BINARY-LONG.
 01 L-APPLIES              BINARY-LONG.
 01 L-STACKABLE            BINARY-LONG.
 01 L-CHEST                BINARY-LONG.
 01 L-NOT-SINGLE           BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-PARTNER              BINARY-LONG.
 PROCEDURE DIVISION USING L-MAIN L-SHIELD L-SNEAK L-APPLIES L-STACKABLE L-CHEST L-NOT-SINGLE L-RESULT L-COST L-FLAGS L-PARTNER.
     MOVE 0 TO L-RESULT L-COST L-FLAGS L-PARTNER
     IF L-APPLIES = 1 AND NOT (L-MAIN = 1 AND L-SHIELD = 1 AND L-SNEAK = 0)
         MOVE 1 TO L-RESULT
         MOVE 2 TO L-COST
         IF L-STACKABLE = 1
             MOVE 1 TO L-COST
         END-IF
         MOVE 11 TO L-FLAGS
         IF L-CHEST = 1 AND L-NOT-SINGLE = 1
             MOVE 1 TO L-PARTNER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC5-AXE-TRANSFORM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-HOE.
*> USING the block (0 other, 1 in tag turns_into_farmland, 2 coarse_dirt, 3 rooted_dirt), air above, the clicked face (1 down, other values not down) (BINARY-LONG), the new block
*> (0 none, 1 farmland with moisture 0, 2 dirt), the till/rooted_dirt loot dropped, damage out (7.3 hoe.json): index 0 skips the down face and needs air above; index 1 has none.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-LOOT                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-AIR L-FACE L-RESULT L-LOOT L-DAMAGE.
     MOVE 0 TO L-RESULT L-LOOT L-DAMAGE
     EVALUATE TRUE
         WHEN L-FACE NOT = 1 AND L-AIR = 1 AND L-BLOCK = 1
             MOVE 1 TO L-RESULT L-DAMAGE
         WHEN L-FACE NOT = 1 AND L-AIR = 1 AND L-BLOCK = 2
             MOVE 2 TO L-RESULT
             MOVE 1 TO L-DAMAGE
         WHEN L-BLOCK = 3
             MOVE 2 TO L-RESULT
             MOVE 1 TO L-LOOT L-DAMAGE
     END-EVALUATE
     GOBACK.
 END PROGRAM GC5-HOE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-SHOVEL.
*> USING the block is in tag turns_into_dirt_path, air above, the clicked face (1 down) (BINARY-LONG), dirt_path out (7.3 shovel.json): the down face is skipped.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-PATH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-AIR L-FACE L-PATH.
     MOVE 0 TO L-PATH
     IF L-TAG = 1 AND L-AIR = 1 AND L-FACE NOT = 1
         MOVE 1 TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM GC5-SHOVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-LIGHT-POS.
*> USING the bolt position x, y, z (FLOAT-LONG), the strike block x, y, z (BINARY-LONG out) (8): the block containing (x, y - 1.0E-6, z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-BX L-BY L-BZ.
     COMPUTE WS-Y = L-Y - 0.000001
     COMPUTE L-BX = FUNCTION INTEGER(L-X)
     COMPUTE L-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE L-BZ = FUNCTION INTEGER(L-Z)
     GOBACK.
 END PROGRAM GC5-LIGHT-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-ROD-CONST.
*> USING ACTIVATION_TICKS, RANGE (BINARY-LONG out) (8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKS L-RANGE.
     MOVE 8 TO L-TICKS
     MOVE 128 TO L-RANGE
     GOBACK.
 END PROGRAM GC5-ROD-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-LIGHT-COUNT.
*> USING kind (1 the number of walks 3 + nextInt(3), 2 the steps of a walk 1 + nextInt(8)), the draw (BINARY-LONG), the count out (8 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DRAW L-COUNT.
     COMPUTE L-COUNT = L-DRAW + 1
     IF L-KIND = 1
         COMPUTE L-COUNT = L-DRAW + 3
     END-IF
     GOBACK.
 END PROGRAM GC5-LIGHT-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-LIGHT-CLEAR.
*> USING the block at the strike is a key of the wax-off map (waxed), it is a WeatheringCopper (BINARY-LONG), reset to getFirst, the walks run out (8 steps 1 to 3): a block that
*> is neither stops without a draw.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WAXED                BINARY-LONG.
 01 L-WEATHERING           BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 01 L-WALKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WAXED L-WEATHERING L-RESET L-WALKS.
     MOVE L-WEATHERING TO L-RESET
     MOVE 0 TO L-WALKS
     IF L-WAXED = 1 OR L-WEATHERING = 1
         MOVE 1 TO L-WALKS
     END-IF
     GOBACK.
 END PROGRAM GC5-LIGHT-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-LIGHT-STEP.
*> USING the 10 candidate cells of BlockPos.randomInCube in order (BINARY-LONG x 10: 0 not a WeatheringCopper, 1 one with a previous state, 2 one without), the index taken
*> (0 for none), the previous state is set, level event, its data, nextInt(3) draws made out (8): the first weathering cell wins and the rest are not drawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-TRIED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELLS.
    05 L-CELL              BINARY-LONG OCCURS 10 TIMES.
 01 L-INDEX                BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-CELLS L-INDEX L-SET L-EVENT L-DATA L-DRAWS.
     MOVE 0 TO L-INDEX L-SET L-EVENT L-DATA WS-TRIED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR L-INDEX > 0
         ADD 1 TO WS-TRIED
         IF L-CELL(WS-I) > 0
             MOVE WS-I TO L-INDEX
             MOVE 3002 TO L-EVENT
             MOVE -1 TO L-DATA
         END-IF
         IF L-CELL(WS-I) = 1
             MOVE 1 TO L-SET
         END-IF
     END-PERFORM
     COMPUTE L-DRAWS = 3 * WS-TRIED
     GOBACK.
 END PROGRAM GC5-LIGHT-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-LIGHT-WALK.
*> USING the steps m of the walk, how many consecutive steps from the strike find a weathering block (BINARY-LONG), the moves made, the steps tried out (8 step 3): the walk ends
*> at the first step without a hit.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STEPS                BINARY-LONG.
 01 L-HITS                 BINARY-LONG.
 01 L-MOVES                BINARY-LONG.
 01 L-TRIED                BINARY-LONG.
 PROCEDURE DIVISION USING L-STEPS L-HITS L-MOVES L-TRIED.
     MOVE L-STEPS TO L-MOVES
     IF L-HITS < L-STEPS
         MOVE L-HITS TO L-MOVES
     END-IF
     COMPUTE L-TRIED = L-MOVES + 1
     IF L-MOVES = L-STEPS
         MOVE L-MOVES TO L-TRIED
     END-IF
     GOBACK.
 END PROGRAM GC5-LIGHT-WALK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-ROD-STRIKE.
*> USING facing (1 down, 2 up, 3 north, 4 south, 5 west, 6 east) (BINARY-LONG), powered, the direction of the neighbour update (the opposite of facing), tick delay, level event,
*> its data (the axis ordinal of facing: x 0, y 1, z 2) out (8 onLightningStrike).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-UPDATE               BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-POWERED L-UPDATE L-DELAY L-EVENT L-DATA.
     MOVE 1 TO L-POWERED
     MOVE 8 TO L-DELAY
     MOVE 3002 TO L-EVENT
     COMPUTE L-UPDATE = L-FACING + 1
     IF FUNCTION MOD(L-FACING, 2) = 0
         COMPUTE L-UPDATE = L-FACING - 1
     END-IF
     EVALUATE L-FACING
         WHEN 1 THRU 2
             MOVE 1 TO L-DATA
         WHEN 3 THRU 4
             MOVE 2 TO L-DATA
         WHEN OTHER
             MOVE 0 TO L-DATA
     END-EVALUATE
     GOBACK.
 END PROGRAM GC5-ROD-STRIKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-ROD-SIGNAL.
*> USING powered, facing, the direction asked (BINARY-LONG), own signal, direct signal out (8): a powered rod gives 15, direct only towards its facing.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-DIRECT               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-FACING L-DIR L-OWN L-DIRECT.
     MOVE 0 TO L-OWN L-DIRECT
     IF L-POWERED = 1
         MOVE 15 TO L-OWN
         IF L-DIR = L-FACING
             MOVE 15 TO L-DIRECT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC5-ROD-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-BOLT-ORDER.
*> USING difficulty (0 peaceful, 1 easy, 2 normal, 3 hard) (BINARY-LONG), spawnFire runs, powerLightningRod order, clearCopper order, lightning_strike game event order out (8):
*> at life 2 the fire first (normal or hard only), then the three calls in this order.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-ROD                  BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFICULTY L-FIRE L-ROD L-CLEAR L-EVENT.
     MOVE 0 TO L-FIRE
     MOVE 1 TO L-ROD
     MOVE 2 TO L-CLEAR
     MOVE 3 TO L-EVENT
     IF L-DIFFICULTY >= 2
         MOVE 1 TO L-FIRE
     END-IF
     GOBACK.
 END PROGRAM GC5-BOLT-ORDER.
