*> Armadillo (002-lane-mobsfull-h20; docs/protocol/19-mobs-land-friendly-and-neutral.md section 13): scutes, danger and the rolled-up states.
*> - scuteTime (EN-SCUTE) is nextInt(6000) + 6000 at birth (MOB-BORN) and counts down for an adult; at 0 one armadillo scute drops (the table gameplay/armadillo_shed, which is not in the content
*>   set, like gameplay/chicken_lay) while the game rule mob_drops is true, and the next time is drawn again.
*> - Every 80 ticks (EN-ARMA-SCAN) the armadillo looks for danger: a sprinting player (not a spectator) or an undead mob in the box of 7 blocks horizontally and 2 vertically around it (the centre
*>   distances stand in for the box intersection), and a hit by a player is danger too. Danger is remembered for 80 ticks (EN-DANGER, danger_detected_recently).
*> - Danger rolls an idle armadillo up: state 1 (EN-ARMA, metadata 18, ARMADILLO_STATE) for 10 ticks, then 2 scared; when the memory is gone it unrolls: state 3 for 30 ticks, then 0. A rolled
*>   armadillo does not walk. While scared the damage of a hit is (amount - 1) / 2 (ARMADILLO-REDUCE; whole points).
*> Open items: brushing (loot brush/armadillo), the 50-tick duration of the scared state as such (here it lasts as long as the danger memory), ArmadilloPanic against other attackers than players,
*> the spectator rule (no spectator mode exists), can-stay-rolled-up and the panic_environmental_causes, a danger check that is randomly offset at spawn, the box intersection by real boxes.
*>
*> Entry points:
*>   ARMADILLO-TICK USING row, walk out      one tick; walk 2 when the armadillo is rolled up (stands still), else 0
*>   ARMADILLO-HURT USING row, attacker      a hit by a player: danger for 80 ticks and rolled up
*>   ARMADILLO-REDUCE USING row, amount      the damage that gets through: (amount - 1) / 2 while scared, for an armadillo only

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMADILLO-REDUCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-M                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "armadillo" AND EN-ARMA(L-ROW) = 2
         COMPUTE L-AMOUNT = (L-AMOUNT - 1) / 2
     END-IF
     GOBACK.
 END PROGRAM ARMADILLO-REDUCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMADILLO-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "armadillo" AND L-ATTACKER > 0
         MOVE 80 TO EN-DANGER(L-ROW)
         IF EN-ARMA(L-ROW) = 0
             MOVE 1 TO EN-ARMA(L-ROW)
             MOVE 10 TO EN-ARMA-T(L-ROW)
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ARMADILLO-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARMADILLO-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 53.
 01 WS-BOUND               BINARY-LONG VALUE 6000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_drops".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:armadillo_scute".
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-OTHER               PIC X(24).
 01 WS-UNDEAD              BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-AROUND              BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PEEK-SALT           BINARY-LONG VALUE 54.
 01 WS-PEEK-BOUND          BINARY-LONG VALUE 301.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WALK.
     MOVE 0 TO L-WALK
     MOVE EN-ARMA(L-ROW) TO WS-OLD
*>   Scutes: an adult counts scuteTime down; at 0 a scute drops and the next time is drawn.
     IF EN-VARIANT(L-ROW) = 0
         SUBTRACT 1 FROM EN-SCUTE(L-ROW)
         IF EN-SCUTE(L-ROW) <= 0
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
             COMPUTE EN-SCUTE(L-ROW) = 6000 + WS-DRAW
             CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
             IF WS-RULE = 1
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
                 CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET WS-ITEM WS-ONE
                     WS-PATCH WS-ITEM-ENTITY
             END-IF
         END-IF
     END-IF
*>   The danger memory counts down; every 80 ticks the surroundings are scanned.
     IF EN-DANGER(L-ROW) > 0
         SUBTRACT 1 FROM EN-DANGER(L-ROW)
     END-IF
     ADD 1 TO EN-ARMA-SCAN(L-ROW)
     IF EN-ARMA-SCAN(L-ROW) >= 80
         MOVE 0 TO EN-ARMA-SCAN(L-ROW)
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-SPRINTING(WS-P) = 1
                 COMPUTE WS-DX = FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW))
                 COMPUTE WS-DY = FUNCTION ABS(PL-Y(WS-P) - EN-Y(L-ROW))
                 COMPUTE WS-DZ = FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW))
                 IF WS-DX <= 7 AND WS-DZ <= 7 AND WS-DY <= 2
                     MOVE 80 TO EN-DANGER(L-ROW)
                 END-IF
             END-IF
         END-PERFORM
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0 AND EN-PLAYER(WS-E) = 0
                 CALL "MOB-SPECIES-KEY" USING WS-E WS-OTHER
                 MOVE 0 TO WS-UNDEAD
                 EVALUATE WS-OTHER
                     WHEN "skeleton" WHEN "stray" WHEN "wither_skeleton" WHEN "skeleton_horse" WHEN "bogged" WHEN "parched"
                     WHEN "zombie_horse" WHEN "camel_husk" WHEN "zombie" WHEN "zombie_villager" WHEN "zombified_piglin"
                     WHEN "zoglin" WHEN "drowned" WHEN "husk" WHEN "wither" WHEN "phantom"
                         MOVE 1 TO WS-UNDEAD
                 END-EVALUATE
                 COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW))
                 COMPUTE WS-DY = FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-ROW))
                 COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW))
                 IF WS-UNDEAD = 1 AND WS-DX <= 7 AND WS-DZ <= 7 AND WS-DY <= 2
                     MOVE 80 TO EN-DANGER(L-ROW)
                 END-IF
             END-IF
         END-PERFORM
     END-IF
*>   The state machine (44 part 4 section 12, ArmadilloBallUp): idle rolls up on danger; rolling (10 ticks) becomes scared. While the memory lasts, a scared armadillo counts its peek
*>   timer down, re-rolls it to 50 + U(100, 400) whenever danger around (remaining above 75) flips, peeks (event 64) at timer 0 on the ground with danger around, starts unrolling when
*>   the remaining memory is below 30 and goes back to scared above 30. With the memory gone a scared one unrolls (the rolling-out one-shot); unrolling (30 ticks) becomes idle.
     EVALUATE EN-ARMA(L-ROW)
         WHEN 0
             IF EN-DANGER(L-ROW) > 0
                 MOVE 1 TO EN-ARMA(L-ROW)
                 MOVE 10 TO EN-ARMA-T(L-ROW)
             END-IF
         WHEN 1
             SUBTRACT 1 FROM EN-ARMA-T(L-ROW)
             IF EN-ARMA-T(L-ROW) = 0
                 MOVE 2 TO EN-ARMA(L-ROW)
             END-IF
         WHEN 2
             IF EN-DANGER(L-ROW) = 0
                 MOVE 3 TO EN-ARMA(L-ROW)
                 MOVE 30 TO EN-ARMA-T(L-ROW)
             ELSE
                 PERFORM BALL-UP-SCARED
             END-IF
         WHEN 3
             IF EN-DANGER(L-ROW) > 30
                 MOVE 2 TO EN-ARMA(L-ROW)
             ELSE
                 SUBTRACT 1 FROM EN-ARMA-T(L-ROW)
                 IF EN-ARMA-T(L-ROW) = 0
                     MOVE 0 TO EN-ARMA(L-ROW)
                 END-IF
             END-IF
     END-EVALUATE
     IF EN-ARMA(L-ROW) NOT = WS-OLD
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     IF EN-ARMA(L-ROW) > 0
         MOVE 2 TO L-WALK
     END-IF
     GOBACK.

 BALL-UP-SCARED.
     IF EN-ARMA-PEEK(L-ROW) > 0
         SUBTRACT 1 FROM EN-ARMA-PEEK(L-ROW)
     END-IF
     MOVE 0 TO WS-AROUND
     IF EN-DANGER(L-ROW) > 75
         MOVE 1 TO WS-AROUND
     END-IF
     IF WS-AROUND NOT = EN-ARMA-AROUND(L-ROW)
         PERFORM PEEK-ROLL
         MOVE WS-AROUND TO EN-ARMA-AROUND(L-ROW)
     END-IF
     IF EN-ARMA-PEEK(L-ROW) = 0 AND EN-ON-GROUND(L-ROW) = 1 AND WS-AROUND = 1
         MOVE 64 TO WS-EVENT
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
         PERFORM PEEK-ROLL
     END-IF
     IF EN-DANGER(L-ROW) < 30
         MOVE 3 TO EN-ARMA(L-ROW)
         MOVE 30 TO EN-ARMA-T(L-ROW)
     END-IF.

 PEEK-ROLL.
     CALL "XP-RANDOM" USING WS-PEEK-SALT WS-PEEK-BOUND WS-DRAW
     COMPUTE EN-ARMA-PEEK(L-ROW) = 150 + WS-DRAW.
 END PROGRAM ARMADILLO-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-ARMADILLO-BRUSH.
*> USING player row, entity row (an armadillo): a brush in the main hand on a non-baby armadillo that is not scared (44 part 4 section 12, 19 section 13): one armadillo scute
*> drops (the table ARMADILLO_BRUSH is not in the docs: the one scute of the shed table stands in), the brush loses 16 durability. A baby or a rolled-up armadillo fails (nothing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24) VALUE "armadillo_scute".
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-COST                BINARY-LONG VALUE 16.
 01 WS-BROKE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY.
     IF EN-VARIANT(L-ENTITY) = 0 AND EN-MOBAGE(L-ENTITY) >= 0 AND EN-ARMA(L-ENTITY) = 0
         CALL "MOB-DROP-ITEMS" USING L-ENTITY WS-KEY WS-COUNT
         CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) PL-HELD(L-ROW) WS-COST WS-BROKE
     END-IF
     GOBACK.
 END PROGRAM MOB-ARMADILLO-BRUSH.
