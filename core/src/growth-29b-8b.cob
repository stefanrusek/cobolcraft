*> Fire burn-out, spread, environment inputs, soul fire, entity contact and breaking (sections 2.5 to 2.12) of docs/protocol/29b part 8 as programs of plain numbers (GC8- prefix).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-BURNOUT.
*> USING the environment attribute gameplay/increased_fire_burnout (1 true), the burnout out (2.5 step 8): -50 when true, else 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTRIBUTE            BINARY-LONG.
 01 L-BURNOUT              BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTRIBUTE L-BURNOUT.
     MOVE 0 TO L-BURNOUT
     IF L-ATTRIBUTE = 1
         MOVE -50 TO L-BURNOUT
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-BURNOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-BURN-CHANCE.
*> USING the burnout, the neighbour (1 east, 2 west, 3 below, 4 above, 5 north, 6 south), the chance of checkBurnOut out (2.5 step 9): 300, 300, 250, 250, 300, 300 plus the burnout.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BURNOUT              BINARY-LONG.
 01 L-NEIGHBOUR            BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-BURNOUT L-NEIGHBOUR L-CHANCE.
     COMPUTE L-CHANCE = 300 + L-BURNOUT
     IF L-NEIGHBOUR = 3 OR L-NEIGHBOUR = 4
         COMPUTE L-CHANCE = 250 + L-BURNOUT
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-BURN-CHANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-CELL.
*> USING the cell number (1 to 53, the order of the spread loop), then dx, dy, dz and the bound of its draw out (2.6): dx -1 to 1 outermost, dz -1 to 1, dy -1 to 4 innermost, (0, 0, 0) skipped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAW                 BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELL                 BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-CELL L-DX L-DY L-DZ L-BOUND.
     COMPUTE WS-RAW = L-CELL - 1
     IF L-CELL > 25
         MOVE L-CELL TO WS-RAW
     END-IF
     DIVIDE WS-RAW BY 18 GIVING WS-Q REMAINDER WS-REST
     COMPUTE L-DX = WS-Q - 1
     DIVIDE WS-REST BY 6 GIVING WS-Q REMAINDER WS-RAW
     COMPUTE L-DZ = WS-Q - 1
     COMPUTE L-DY = WS-RAW - 1
     MOVE 100 TO L-BOUND
     IF L-DY > 1
         COMPUTE L-BOUND = 100 + (L-DY - 1) * 100
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-CELL-ODDS.
*> USING the cell is air, the maximum ignite odds of its six neighbours, the ignite odds of the cell out (2.6 step 2): 0 unless it is air.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-MAXIMUM              BINARY-LONG.
 01 L-ODDS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-MAXIMUM L-ODDS.
     MOVE 0 TO L-ODDS
     IF L-AIR = 1
         MOVE L-MAXIMUM TO L-ODDS
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-CELL-ODDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-CHANCE.
*> USING the odds o, the difficulty id, the entry age, the attribute increased_fire_burnout, the chance out (2.6 step 3): (o + 40 + 7 x difficulty) / (age + 30), integer division, halved with the attribute.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ODDS                 BINARY-LONG.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-ATTRIBUTE            BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ODDS L-DIFFICULTY L-AGE L-ATTRIBUTE L-CHANCE.
     COMPUTE WS-TOP = L-ODDS + 40 + 7 * L-DIFFICULTY
     COMPUTE WS-BOTTOM = L-AGE + 30
     DIVIDE WS-TOP BY WS-BOTTOM GIVING L-CHANCE
     IF L-ATTRIBUTE = 1
         DIVIDE L-CHANCE BY 2 GIVING L-CHANCE
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-CHANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-PROB.
*> USING the chance, the bound, the probability the cell catches fire x 10000 out (2.6 table): the draw is at most the chance, so chance + 1 of bound outcomes.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHANCE               BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 01 L-PROBABILITY          BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANCE L-BOUND L-PROBABILITY.
     COMPUTE L-PROBABILITY = (L-CHANCE + 1) * 10000 / L-BOUND
     GOBACK.
 END PROGRAM GC8-FIRE-PROB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-SPREAD-CELL.
*> USING the chance, the draw nextInt(bound), rain near the cell, the draw nextInt(5), the entry age, then the first draw made, the cell caught, the second draw made, the fire placed,
*> the age of the new fire out (2.6 steps 4 to 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHANCE               BINARY-LONG.
 01 L-DRAW1                BINARY-LONG.
 01 L-RAIN-NEAR            BINARY-LONG.
 01 L-DRAW2                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-DREW1                BINARY-LONG.
 01 L-CAUGHT               BINARY-LONG.
 01 L-DREW2                BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 01 L-NEW-AGE              BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANCE L-DRAW1 L-RAIN-NEAR L-DRAW2 L-AGE L-DREW1 L-CAUGHT L-DREW2 L-PLACED L-NEW-AGE.
     MOVE 0 TO L-DREW1 L-CAUGHT L-DREW2 L-PLACED
     MOVE L-AGE TO L-NEW-AGE
     IF L-CHANCE > 0
         MOVE 1 TO L-DREW1
         IF L-DRAW1 <= L-CHANCE
             MOVE 1 TO L-CAUGHT
             IF L-RAIN-NEAR = 0
                 MOVE 1 TO L-DREW2 L-PLACED
                 DIVIDE L-DRAW2 BY 4 GIVING WS-STEP
                 COMPUTE L-NEW-AGE = FUNCTION MIN(15, L-AGE + WS-STEP)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-SPREAD-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-BURN-CHECK.
*> USING the burn odds, the chance, the draw nextInt(chance), the entry age, the draw nextInt(age + 10), raining at the block, the draw nextInt(5), the block was TNT, then the outcome (0 none,
*> 1 fire, 2 removed), the second draw made, the third draw made, the age of the fire, TNT is primed out (2.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BURN                 BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 01 L-DRAW1                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-DRAW2                BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 01 L-DRAW3                BINARY-LONG.
 01 L-TNT                  BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 01 L-DREW2                BINARY-LONG.
 01 L-DREW3                BINARY-LONG.
 01 L-NEW-AGE              BINARY-LONG.
 01 L-PRIME                BINARY-LONG.
 PROCEDURE DIVISION USING L-BURN L-CHANCE L-DRAW1 L-AGE L-DRAW2 L-RAINING L-DRAW3 L-TNT L-OUTCOME L-DREW2 L-DREW3 L-NEW-AGE L-PRIME.
     MOVE 0 TO L-OUTCOME L-DREW2 L-DREW3 L-PRIME
     MOVE L-AGE TO L-NEW-AGE
     IF L-DRAW1 < L-BURN
         MOVE 1 TO L-DREW2
         MOVE L-TNT TO L-PRIME
         IF L-DRAW2 < 5 AND L-RAINING = 0
             MOVE 1 TO L-OUTCOME L-DREW3
             DIVIDE L-DRAW3 BY 4 GIVING WS-STEP
             COMPUTE L-NEW-AGE = FUNCTION MIN(15, L-AGE + WS-STEP)
         ELSE
             MOVE 2 TO L-OUTCOME
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-BURN-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-INFINIBURN.
*> USING the dimension type (1 overworld, 2 overworld_caves, 3 the_nether, 4 the_end), the block below (1 netherrack, 2 magma_block, 3 bedrock, 4 other), infiniburn out (2.8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIMENSION            BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-INFINIBURN           BINARY-LONG.
 PROCEDURE DIVISION USING L-DIMENSION L-BLOCK L-INFINIBURN.
     MOVE 0 TO L-INFINIBURN
     IF L-BLOCK = 1 OR L-BLOCK = 2
         MOVE 1 TO L-INFINIBURN
     END-IF
     IF L-DIMENSION = 4 AND L-BLOCK = 3
         MOVE 1 TO L-INFINIBURN
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-INFINIBURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-CAN-SPREAD.
*> USING the rule fire_spread_radius_around_player, a player is close enough, canSpreadFireAround out (2.8): true when the rule is -1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-CLOSE L-CAN.
     MOVE L-CLOSE TO L-CAN
     IF L-RULE = -1
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-CAN-SPREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-BIOME-BURNOUT.
*> USING the biome (1 bamboo_jungle, 2 frozen_peaks, 3 jagged_peaks, 4 jungle, 5 mangrove_swamp, 6 mushroom_fields, 7 snowy_slopes, 8 swamp, 9 any other), the attribute PIC X(64) out (2.8): true or false.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BIOME                BINARY-LONG.
 01 L-VALUE                PIC X(64).
 PROCEDURE DIVISION USING L-BIOME L-VALUE.
     MOVE "false" TO L-VALUE
     IF L-BIOME >= 1 AND L-BIOME <= 8
         MOVE "true" TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM GC8-BIOME-BURNOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-IGNITE.
*> USING fire immune, remainingFireTicks, a server player, the draw of nextInt(1, 3) as 0 or 1, then the new remainingFireTicks, the seconds the entity burns, the draw made out (2.10 fireIgnite).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IMMUNE               BINARY-LONG.
 01 L-TICKS-IN             BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-IMMUNE L-TICKS-IN L-PLAYER L-DRAW L-TICKS L-SECONDS L-DREW.
     MOVE L-TICKS-IN TO L-TICKS
     MOVE 0 TO L-SECONDS L-DREW
     IF L-IMMUNE = 0
         EVALUATE TRUE
             WHEN L-TICKS < 0
                 ADD 1 TO L-TICKS
             WHEN L-PLAYER = 1
                 MOVE 1 TO L-DREW
                 COMPUTE L-TICKS = L-TICKS + 1 + L-DRAW
         END-EVALUATE
         IF L-TICKS >= 0
             MOVE 8 TO L-SECONDS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-IGNITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-BREAK.
*> USING server level, the level event and its data out (2.11): 1009 with data 0 on the server.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-EVENT L-DATA.
     MOVE 0 TO L-EVENT L-DATA
     IF L-SERVER = 1
         MOVE 1009 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM GC8-FIRE-BREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC8-FIRE-PRODUCER.
*> USING the row (1 to 5) of the producer table of 2.12 (BINARY-LONG), the place that specifies it PIC X(64) out (blank for another row).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DOC                  PIC X(64).
 PROCEDURE DIVISION USING L-ROW L-DOC.
     MOVE SPACES TO L-DOC
     EVALUATE L-ROW
         WHEN 1
             MOVE "17 s3.3; 30 p4 s4.10" TO L-DOC
         WHEN 2
             MOVE "29a; 33; 29b-3" TO L-DOC
         WHEN 3
             MOVE "2.6, 2.7" TO L-DOC
         WHEN 4
             MOVE "21" TO L-DOC
         WHEN 5
             MOVE "2.4 step 2 (Open question 3)" TO L-DOC
     END-EVALUATE
     GOBACK.
 END PROGRAM GC8-FIRE-PRODUCER.
