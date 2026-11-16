*> The tempt goal of the animals (docs/protocol/18-mob-framework.md section 4.7 TemptGoal; 19 sections 2 and 3.4 for the speed of each species), wired into STDMOB-STEP.
*>
*> Programs:
*>   MOB-TEMPT-SPEED USING species, milli out         the speed modifier of the species' tempt goal in thousandths (pig 1.2, cow, mooshroom, goat, the horse family and llamas 1.25,
*>                                                    sheep 1.1, chicken, rabbit, panda 1.0; the camel's is not in the documents and is taken as 1.0); 0 for a species with no tempt goal here
*>   MOB-TEMPT-FOOD USING species, item, ok out       1 when the item tempts the species: its food (M188-FOOD), except the horse family (golden carrot, golden apple, enchanted
*>                                                    golden apple: tag horse_tempt_items), llamas (hay block) and the camel (cactus)
*>   MOB-TEMPT-TICK USING row, table row, hx out, hz out, yaw (changed), walk out
*>                                                    one tick of the goal: walk 1 when hx and hz are the walk toward the player, 2 when the animal stands facing the player
*>                                                    (within 2.5 blocks), 0 when the goal does not act. EN-TEMPT is 0 idle, -1 running, above 0 the cooldown (100 ticks after it stops).
*> The goal needs the nearest alive, non-spectator player of the dimension within the tempt range (10 blocks) to hold food in the main hand (the off hand is not stored by the core).
*> The goal walks to the player through STDMOB-HEAD at the walk speed x the modifier squared (the speed of a goal's walk is movement speed x modifier, and the table speed is its square).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-TEMPT-SPEED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-MILLI                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-MILLI.
     EVALUATE L-KEY
         WHEN "pig"
             MOVE 1200 TO L-MILLI
         WHEN "cow" WHEN "mooshroom" WHEN "goat" WHEN "horse" WHEN "donkey" WHEN "mule" WHEN "zombie_horse" WHEN "llama" WHEN "trader_llama"
             MOVE 1250 TO L-MILLI
         WHEN "sheep"
             MOVE 1100 TO L-MILLI
         WHEN "chicken" WHEN "rabbit" WHEN "panda" WHEN "camel"
             MOVE 1000 TO L-MILLI
         WHEN OTHER
             MOVE 0 TO L-MILLI
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-TEMPT-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-TEMPT-FOOD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-LOVE                BINARY-LONG.
 01 WS-TAME                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-ITEM                 PIC X(24).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ITEM L-OK.
     MOVE 0 TO L-OK
     EVALUATE TRUE
         WHEN L-KEY = "horse" OR "donkey" OR "mule" OR "zombie_horse"
             IF L-ITEM = "golden_carrot" OR "golden_apple" OR "enchanted_golden_apple"
                 MOVE 1 TO L-OK
             END-IF
         WHEN L-KEY = "llama" OR "trader_llama"
             IF L-ITEM = "hay_block"
                 MOVE 1 TO L-OK
             END-IF
         WHEN L-KEY = "camel"
             IF L-ITEM = "cactus"
                 MOVE 1 TO L-OK
             END-IF
         WHEN OTHER
             CALL "M188-FOOD" USING L-KEY L-ITEM L-OK WS-SECONDS WS-LOVE WS-TAME
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-TEMPT-FOOD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-TEMPT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-MILLI               BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-ITEM                PIC X(24).
 01 WS-CLOSE               FLOAT-LONG VALUE 2.5.
 01 WS-WALK               BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-FACTOR              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-HX L-HZ L-YAW L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "MOB-TEMPT-SPEED" USING SM-KEY(L-M) WS-MILLI
     IF WS-MILLI = 0
         GOBACK
     END-IF
*>   The nearest player of the dimension who passes the non-combat conditions (alive, not a spectator) within the tempt range.
     MOVE 0 TO WS-BEST
     MOVE 100 TO WS-LIMIT
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) NOT = 3 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 <= WS-LIMIT
                 MOVE WS-D2 TO WS-LIMIT
                 MOVE WS-P TO WS-BEST
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO WS-HOLDS
     IF WS-BEST > 0
         IF PL-SLOT-COUNT(WS-BEST, PL-HELD(WS-BEST) + 1) > 0
             CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-BEST, PL-HELD(WS-BEST) + 1) WS-KEY48
             MOVE WS-KEY48 TO WS-ITEM
             CALL "MOB-TEMPT-FOOD" USING SM-KEY(L-M) WS-ITEM WS-OK
             MOVE WS-OK TO WS-HOLDS
         END-IF
     END-IF
*>   Idle: starts when food is held. Running: stops (cooldown 100) when it is not. Cooling: counts down.
     EVALUATE TRUE
         WHEN EN-TEMPT(L-ROW) > 0
             SUBTRACT 1 FROM EN-TEMPT(L-ROW)
             GOBACK
         WHEN EN-TEMPT(L-ROW) = 0 AND WS-HOLDS = 1
             MOVE -1 TO EN-TEMPT(L-ROW)
         WHEN EN-TEMPT(L-ROW) < 0 AND WS-HOLDS = 0
             MOVE 100 TO EN-TEMPT(L-ROW)
             GOBACK
     END-EVALUATE
     IF EN-TEMPT(L-ROW) = 0
         GOBACK
     END-IF
     COMPUTE WS-DX = PL-X(WS-BEST) - EN-X(L-ROW)
     COMPUTE WS-DZ = PL-Z(WS-BEST) - EN-Z(L-ROW)
     CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ L-YAW
     CALL "TEMPTATION-WALK" USING WS-LIMIT WS-CLOSE WS-WALK
     MOVE 2 TO L-WALK
     IF WS-WALK = 1
         COMPUTE WS-GX = FUNCTION INTEGER(PL-X(WS-BEST))
         COMPUTE WS-GY = FUNCTION INTEGER(PL-Y(WS-BEST))
         COMPUTE WS-GZ = FUNCTION INTEGER(PL-Z(WS-BEST))
         CALL "STDMOB-HEAD" USING L-ROW L-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
         COMPUTE WS-FACTOR = (WS-MILLI / 1000) * (WS-MILLI / 1000)
         COMPUTE L-HX = L-HX * WS-FACTOR
         COMPUTE L-HZ = L-HZ * WS-FACTOR
         MOVE 1 TO L-WALK
     END-IF
     GOBACK.
 END PROGRAM MOB-TEMPT-TICK.
