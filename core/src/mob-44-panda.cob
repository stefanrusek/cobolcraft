*> Panda goals (docs/protocol/44-residual-mob-questions-4-land-animals.md sections 7.1 to 7.3; lane 002-lane-p49s, T38620 to T38635): PandaRollGoal with handleRoll, PandaLieOnBackGoal and PandaSitGoal
*> (with the pick-up of bamboo and cake). The panda's flags are EN-PANDA-FLAGS (4 rolling, 8 sitting, 16 lying on the back; bit 2 the sneeze is not kept there), the roll counter EN-PANDA-T, the roll
*> velocity EN-PANDA-RDX and EN-PANDA-RDZ, the cooldown stamps EN-PANDA-LIE-CD and EN-PANDA-SIT-CD (game ticks), EN-PANDA-HAND the item held in the mouth. Every draw is the doc's roll
*> nextInt(n) == 1 with the numbers already halved (reducedTickDelay), taken once per game tick (the goal selector's half rate is not modelled), from RNG-HASH like the panda's other rolls.
*> Gaps (open): the scared state (a worried panda in thunder: the weather kind is not in this core's state), the unhappy counter, an item a panda cannot reach, the avoid, attack and look goals.
*>   PANDA-CAN-ACT USING row, can out                         canPerformAction: not on the back, not eating, not rolling, not sitting (the scared test left out)
*>   PANDA-DRAW USING row, salt, bound, draw out              a deterministic nextInt(bound) of the panda
*>   PANDA-GOALS USING row, hx out, hz out, walk out          one tick of the three goals and of handleRoll; walk 1: (hx, hz) is the walk, 2: the panda stands still

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-CAN-ACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAN.
     MOVE 1 TO L-CAN
     IF FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 4, 2) = 1 OR FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 8, 2) = 1
             OR FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 16, 2) = 1 OR EN-PANDA-EAT(L-ROW) > 0
         MOVE 0 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM PANDA-CAN-ACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-DRAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SALT                 BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SALT L-BOUND L-DRAW.
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE L-SALT TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE L-DRAW = FUNCTION MOD(WS-R, L-BOUND)
     GOBACK.
 END PROGRAM PANDA-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-FIND-FOOD.
*> USING row, range (FLOAT-LONG), best out: the first item entity in the box inflated by range on every axis that is in the item tag panda_eats_from_ground (bamboo, cake), alive and without a
*> pick-up delay (0 when none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-E                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-KEY32               PIC X(32).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RANGE                FLOAT-LONG.
 01 L-BEST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RANGE L-BEST.
     MOVE 0 TO L-BEST
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-BEST > 0
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-DIM(WS-E) = EN-DIM(L-ROW)
                 AND EN-DELAY(WS-E) <= 0 AND EN-ITEM-COUNT(WS-E) > 0
             CALL "PGW-ITEM-KEY" USING EN-ITEM(WS-E) WS-KEY32
             COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW))
             COMPUTE WS-DY = FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-ROW))
             COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW))
             IF (WS-KEY32 = "bamboo" OR WS-KEY32 = "cake") AND WS-DX <= L-RANGE AND WS-DY <= L-RANGE AND WS-DZ <= L-RANGE
                 MOVE WS-E TO L-BEST
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PANDA-FIND-FOOD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PANDA-GOALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 01 WS-TRAIT               BINARY-LONG.
 01 WS-LAZY                BINARY-LONG.
 01 WS-PLAYFUL             BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-SALT                BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-DIR-DONE            BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-FLAGS-BEFORE        BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-KEY32               PIC X(32).
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DROP                BINARY-LONG.
 01 WS-DX0                 FLOAT-LONG.
 01 WS-DY0                 FLOAT-LONG.
 01 WS-DZ0                 FLOAT-LONG.
 01 WS-RANGE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     COMPUTE WS-SPEED = SM-WALK-MILLI(WS-M) / 1000
     CALL "PANDA-TRAIT" USING EN-GENE-MAIN(L-ROW) EN-GENE-HIDDEN(L-ROW) WS-TRAIT
     MOVE 0 TO WS-LAZY WS-PLAYFUL WS-BABY
     IF WS-TRAIT = 1
         MOVE 1 TO WS-LAZY
     END-IF
     IF WS-TRAIT = 3
         MOVE 1 TO WS-PLAYFUL
     END-IF
     IF EN-MOBAGE(L-ROW) < 0
         MOVE 1 TO WS-BABY
     END-IF
     MOVE EN-PANDA-FLAGS(L-ROW) TO WS-FLAGS-BEFORE
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "TURTLE-IS-WATER" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-WATER

*>   handleRoll (7.1): runs every tick while the rolling flag is set, else the counter is reset.
     IF FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 4, 2) = 1
         ADD 1 TO EN-PANDA-T(L-ROW)
         IF EN-PANDA-T(L-ROW) > 32
             SUBTRACT 4 FROM EN-PANDA-FLAGS(L-ROW)
         ELSE
             COMPUTE WS-A = EN-YAW(L-ROW) * 0.017453292
             EVALUATE TRUE
                 WHEN EN-PANDA-T(L-ROW) = 1
                     MOVE 0.2 TO WS-FX
                     IF WS-BABY = 1
                         MOVE 0.1 TO WS-FX
                     END-IF
                     COMPUTE EN-PANDA-RDX(L-ROW) = EN-VX(L-ROW) + (0 - FUNCTION SIN(WS-A)) * WS-FX
                     COMPUTE EN-PANDA-RDZ(L-ROW) = EN-VZ(L-ROW) + FUNCTION COS(WS-A) * WS-FX
                     MOVE EN-PANDA-RDX(L-ROW) TO EN-VX(L-ROW)
                     MOVE 0.27 TO EN-VY(L-ROW)
                     MOVE EN-PANDA-RDZ(L-ROW) TO EN-VZ(L-ROW)
                 WHEN EN-PANDA-T(L-ROW) = 7 OR EN-PANDA-T(L-ROW) = 15 OR EN-PANDA-T(L-ROW) = 23
                     MOVE 0 TO EN-VX(L-ROW) EN-VZ(L-ROW)
                     IF EN-ON-GROUND(L-ROW) = 1
                         MOVE 0.27 TO EN-VY(L-ROW)
                     END-IF
                 WHEN OTHER
                     MOVE EN-PANDA-RDX(L-ROW) TO EN-VX(L-ROW)
                     MOVE EN-PANDA-RDZ(L-ROW) TO EN-VZ(L-ROW)
             END-EVALUATE
         END-IF
     ELSE
         IF FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 16, 2) = 0
             MOVE 0 TO EN-PANDA-T(L-ROW)
         END-IF
     END-IF

*>   PandaLieOnBackGoal (7.2).
     IF FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 16, 2) = 0
         CALL "PANDA-CAN-ACT" USING L-ROW WS-CAN
         MOVE 0 TO WS-ROLL
         IF WS-LAZY = 1 AND WS-CAN = 1 AND EN-PANDA-LIE-CD(L-ROW) < CW-TICKS
             MOVE 71 TO WS-SALT
             MOVE 200 TO WS-BOUND
             CALL "PANDA-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
             IF WS-DRAW = 1
                 ADD 16 TO EN-PANDA-FLAGS(L-ROW)
                 MOVE 0 TO EN-PANDA-LIE-CD(L-ROW)
             END-IF
         END-IF
     ELSE
         MOVE 0 TO WS-END
         IF WS-WATER = 1
             MOVE 1 TO WS-END
         END-IF
         IF WS-END = 0 AND WS-LAZY = 0
             MOVE 72 TO WS-SALT
             MOVE 300 TO WS-BOUND
             CALL "PANDA-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
             IF WS-DRAW = 1
                 MOVE 1 TO WS-END
             END-IF
         END-IF
         IF WS-END = 0
             MOVE 73 TO WS-SALT
             MOVE 1000 TO WS-BOUND
             CALL "PANDA-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
             IF WS-DRAW = 1
                 MOVE 1 TO WS-END
             END-IF
         END-IF
         IF WS-END = 1
             SUBTRACT 16 FROM EN-PANDA-FLAGS(L-ROW)
             COMPUTE EN-PANDA-LIE-CD(L-ROW) = CW-TICKS + 200
         END-IF
     END-IF

*>   PandaRollGoal (7.1): canUse in order: a baby or playful panda on the ground, canPerformAction, the block ahead and below is air (no draw), a playful panda nextInt(30) = 1, then nextInt(250) = 1.
     CALL "PANDA-CAN-ACT" USING L-ROW WS-CAN
     IF (WS-BABY = 1 OR WS-PLAYFUL = 1) AND EN-ON-GROUND(L-ROW) = 1 AND WS-CAN = 1
         COMPUTE WS-A = EN-YAW(L-ROW) * 0.017453292
         COMPUTE WS-FX = 0 - FUNCTION SIN(WS-A)
         COMPUTE WS-FZ = FUNCTION COS(WS-A)
         MOVE 0 TO WS-SX WS-SZ
         IF FUNCTION ABS(WS-FX) > 0.5
             IF WS-FX > 0
                 MOVE 1 TO WS-SX
             ELSE
                 MOVE -1 TO WS-SX
             END-IF
         END-IF
         IF FUNCTION ABS(WS-FZ) > 0.5
             IF WS-FZ > 0
                 MOVE 1 TO WS-SZ
             ELSE
                 MOVE -1 TO WS-SZ
             END-IF
         END-IF
         COMPUTE WS-PX = WS-CX + WS-SX
         COMPUTE WS-PY = WS-CY - 1
         COMPUTE WS-PZ = WS-CZ + WS-SZ
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-STATE
         MOVE 0 TO WS-ROLL
         IF WS-STATE = 0
             MOVE 1 TO WS-ROLL
         END-IF
         IF WS-ROLL = 0 AND WS-PLAYFUL = 1
             MOVE 74 TO WS-SALT
             MOVE 30 TO WS-BOUND
             CALL "PANDA-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
             IF WS-DRAW = 1
                 MOVE 1 TO WS-ROLL
             END-IF
         END-IF
         IF WS-ROLL = 0
             MOVE 75 TO WS-SALT
             MOVE 250 TO WS-BOUND
             CALL "PANDA-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
             IF WS-DRAW = 1
                 MOVE 1 TO WS-ROLL
             END-IF
         END-IF
         IF WS-ROLL = 1
             ADD 4 TO EN-PANDA-FLAGS(L-ROW)
             MOVE 0 TO EN-PANDA-T(L-ROW)
         END-IF
     END-IF

*>   The pick-up of bamboo and cake into the mouth (Panda.pickUpItem): the item's box meets the panda's box inflated by 1 horizontally; mob_griefing must be on.
     IF EN-PANDA-HAND(L-ROW) = 0 AND EN-MOBAGE(L-ROW) >= 0
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
         IF WS-RULE = 1
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR EN-PANDA-HAND(L-ROW) > 0
                 IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-DIM(WS-E) = EN-DIM(L-ROW)
                         AND EN-DELAY(WS-E) <= 0 AND EN-ITEM-COUNT(WS-E) > 0
                     CALL "PGW-ITEM-KEY" USING EN-ITEM(WS-E) WS-KEY32
                     COMPUTE WS-DX = FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW))
                     COMPUTE WS-DZ = FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW))
                     COMPUTE WS-DY = EN-Y(WS-E) - EN-Y(L-ROW)
                     IF (WS-KEY32 = "bamboo" OR WS-KEY32 = "cake") AND WS-DX < 1.775 AND WS-DZ < 1.775 AND WS-DY > -0.25 AND WS-DY < 1.25
                         COMPUTE EN-PANDA-HAND(L-ROW) = EN-ITEM(WS-E) + 1
                         MOVE 0 TO EN-ITEM-COUNT(WS-E)
                         CALL "ENTITY-REMOVE" USING WS-E
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-IF

*>   PandaSitGoal (7.3).
     IF EN-PANDA-SIT-GOAL(L-ROW) = 0
         CALL "PANDA-CAN-ACT" USING L-ROW WS-CAN
         IF EN-PANDA-SIT-CD(L-ROW) <= CW-TICKS AND WS-BABY = 0 AND WS-WATER = 0 AND WS-CAN = 1
             MOVE 0 TO WS-ROLL
             IF EN-PANDA-HAND(L-ROW) > 0
                 MOVE 1 TO WS-ROLL
             ELSE
                 MOVE 6 TO WS-RANGE
                 CALL "PANDA-FIND-FOOD" USING L-ROW WS-RANGE WS-BEST
                 IF WS-BEST > 0
                     MOVE 1 TO WS-ROLL
                 END-IF
             END-IF
             IF WS-ROLL = 1
                 MOVE 1 TO EN-PANDA-SIT-GOAL(L-ROW)
                 MOVE 0 TO EN-PANDA-SIT-CD(L-ROW)
                 IF EN-PANDA-HAND(L-ROW) > 0
                     IF FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 8, 2) = 0
                         ADD 8 TO EN-PANDA-FLAGS(L-ROW)
                     END-IF
                 END-IF
             END-IF
         END-IF
     ELSE
*>       Running: tick (sit when something is held), the continue rolls, the stop.
         IF EN-PANDA-HAND(L-ROW) > 0 AND FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 8, 2) = 0 AND WS-WATER = 0
             ADD 8 TO EN-PANDA-FLAGS(L-ROW)
         END-IF
         MOVE 0 TO WS-END
         IF WS-WATER = 1
             MOVE 1 TO WS-END
         END-IF
         IF WS-END = 0 AND WS-LAZY = 0
             MOVE 76 TO WS-SALT
             MOVE 300 TO WS-BOUND
             CALL "PANDA-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
             IF WS-DRAW = 1
                 MOVE 1 TO WS-END
             END-IF
         END-IF
         IF WS-END = 0
             MOVE 77 TO WS-SALT
             MOVE 1000 TO WS-BOUND
             CALL "PANDA-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
             IF WS-DRAW = 1
                 MOVE 1 TO WS-END
             END-IF
         END-IF
         IF WS-END = 1
             MOVE 0 TO EN-PANDA-SIT-GOAL(L-ROW)
             IF EN-PANDA-HAND(L-ROW) > 0
                 COMPUTE WS-ITEM = EN-PANDA-HAND(L-ROW) - 1
                 MOVE 0 TO EN-PANDA-HAND(L-ROW) EN-PANDA-EAT(L-ROW)
                 COMPUTE WS-DX0 = EN-X(L-ROW)
                 COMPUTE WS-DY0 = EN-Y(L-ROW) + 0.5
                 COMPUTE WS-DZ0 = EN-Z(L-ROW)
                 CALL "GI-SPAWN-RANDOM" USING EN-DIM(L-ROW) WS-DX0 WS-DY0 WS-DZ0 WS-ITEM WS-ONE WS-ZERO WS-DELAY WS-DROP
                 MOVE 78 TO WS-SALT
                 IF WS-LAZY = 1
                     MOVE 50 TO WS-BOUND
                 ELSE
                     MOVE 150 TO WS-BOUND
                 END-IF
                 CALL "PANDA-DRAW" USING L-ROW WS-SALT WS-BOUND WS-DRAW
                 COMPUTE EN-PANDA-SIT-CD(L-ROW) = CW-TICKS + 20 * (WS-DRAW + 10)
             END-IF
             IF FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 8, 2) = 1
                 SUBTRACT 8 FROM EN-PANDA-FLAGS(L-ROW)
             END-IF
         ELSE
*>           A running goal with an empty hand walks to the first food within 8 blocks (speed 1.2).
             IF EN-PANDA-HAND(L-ROW) = 0
                 MOVE 8 TO WS-RANGE
                 CALL "PANDA-FIND-FOOD" USING L-ROW WS-RANGE WS-BEST
                 IF WS-BEST > 0
                     COMPUTE WS-DX = EN-X(WS-BEST) - EN-X(L-ROW)
                     COMPUTE WS-DZ = EN-Z(WS-BEST) - EN-Z(L-ROW)
                     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
                     IF WS-H > 0.1
                         COMPUTE L-HX = WS-DX / WS-H * WS-SPEED * 1.2
                         COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED * 1.2
                         MOVE 1 TO L-WALK
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
*>   The body keeps still while it rolls, lies or sits.
     IF FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 4, 2) = 1 OR FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 8, 2) = 1
             OR FUNCTION MOD(EN-PANDA-FLAGS(L-ROW) / 16, 2) = 1
         MOVE 2 TO L-WALK
         MOVE 0 TO L-HX L-HZ
     END-IF
     IF EN-PANDA-FLAGS(L-ROW) NOT = WS-FLAGS-BEFORE
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM PANDA-GOALS.
