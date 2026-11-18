*> Piglin bartering in the live world (docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md section 5.5.1; lane 002-lane-mobsb, T7103). The rules are PIGLIN-* of
*> mob-21-barter.cob; this file keeps the state (EN-ADMIRE, EN-ADMIRE-OFF, EN-ADMIRE-PL) and acts on it. The thrown item flies toward the giving player (44 section 3.4 BehaviorUtils.throwItem: 0.3 times the unit vector to the target + 1 block up; without a player in the dimension it goes
*> toward the piglin's own position). Gaps: the book, boots and potions of the table are dropped as plain items (no soul speed enchantment, no potion contents); the Nausea of 200 ticks of the
*> converted mob is not stored (mobs have no status effect store).
*>   PIGLIN-HURT USING entity row                                                 damage while admiring: the admiring ends, the ingot is lost, ADMIRING_DISABLED 400 ticks
*>
*>   PIGLIN-USE USING player row, entity row, held item key (X(24)), used out    mobInteract: a gold ingot from an adult that is not admiring starts the admiring
*>   PIGLIN-ZOMBIFY USING entity row, converted out                              21 section 5.5: timeInOverworld counts where piglins_zombify holds (everywhere but the Nether), above 300 and not peaceful the piglin becomes a zombified piglin
*>   PIGLIN-TICK USING entity row                                                 one tick: the timers count down, the barter happens when the admiring ends

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-CUR                  BINARY-LONG.
 01 WS-ADULT                BINARY-LONG.
 01 WS-ADMIRING             BINARY-LONG.
 01 WS-DISABLED             BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-ENTITY                BINARY-LONG.
 01 L-HELD                  PIC X(24).
 01 L-USED                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-HELD L-USED.
     MOVE 0 TO L-USED
     CALL "PIGLIN-CURRENCY" USING L-HELD WS-CUR
     MOVE 0 TO WS-ADULT WS-ADMIRING WS-DISABLED
     IF EN-MOBAGE(L-ENTITY) >= 0
         MOVE 1 TO WS-ADULT
     END-IF
     IF EN-ADMIRE(L-ENTITY) > 0
         MOVE 1 TO WS-ADMIRING
     END-IF
     IF EN-ADMIRE-OFF(L-ENTITY) > 0
         MOVE 1 TO WS-DISABLED
     END-IF
     CALL "PIGLIN-ADMIRE" USING WS-ADULT WS-ADMIRING WS-DISABLED WS-YES
     IF WS-CUR = 1 AND WS-YES = 1
         CALL "MOB-TAKE" USING L-ROW
         MOVE 119 TO EN-ADMIRE(L-ENTITY)
         MOVE L-ROW TO EN-ADMIRE-PL(L-ENTITY)
         MOVE 1 TO EN-ADMIRE-CUR(L-ENTITY)
         MOVE 1 TO L-USED
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-ZOMBIFY.
*> Piglins and hoglins (zoglin, 21 section 5.6) share the rule. The converted mob gets Nausea for 200 ticks (T8101); a piglin drops its off-hand item and its whole inventory (44-6 section 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-SPECIES              PIC X(24).
 01 WS-KEY                  PIC X(112).
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-NEW                  BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT.
 01 WS-INGOT                PIC X(32).
 01 WS-ITEM                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-DELAY                BINARY-LONG VALUE 10.
 01 WS-DROP                 BINARY-LONG.
 01 WS-NAUSEA               BINARY-LONG VALUE 8.
 01 WS-NAUSEA-TICKS         BINARY-LONG VALUE 200.
 01 WS-FLAGS                BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-ENTITY                BINARY-LONG.
 01 L-DONE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-DONE.
     MOVE 0 TO L-DONE
     IF DM-KEY(EN-DIM(L-ENTITY)) = "minecraft:the_nether" OR EN-PIG-IMMUNE(L-ENTITY) = 1
         MOVE 0 TO EN-ZOMBIFY(L-ENTITY)
         GOBACK
     END-IF
     ADD 1 TO EN-ZOMBIFY(L-ENTITY)
*>   44-6 section 7: finishConversion runs whatever the difficulty (only the converted sound is gated by Peaceful; no sound is made here).
     IF EN-ZOMBIFY(L-ENTITY) > 300
*>       cancelAdmiring (44 section 3.4): the held off-hand item is dropped as an item (the ingot, or the loved item PG-OFFHAND), then the whole inventory (44-6 section 7).
         IF EN-ADMIRE(L-ENTITY) > 0
             MOVE 0 TO EN-ADMIRE(L-ENTITY)
             MOVE "gold_ingot" TO WS-INGOT
             CALL "MERCHANT-ITEM-ID" USING WS-INGOT WS-ITEM
             CALL "PGB-OFFHAND-ITEM" USING L-ENTITY WS-ITEM
             MOVE EN-X(L-ENTITY) TO WS-X
             COMPUTE WS-Y = EN-Y(L-ENTITY) + 1
             MOVE EN-Z(L-ENTITY) TO WS-Z
             CALL "GI-SPAWN-RANDOM" USING EN-DIM(L-ENTITY) WS-X WS-Y WS-Z WS-ITEM WS-ONE WS-ZERO WS-DELAY WS-DROP
         END-IF
         CALL "PGB-INV-DROP" USING L-ENTITY
         CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-SPECIES
         MOVE "zombified_piglin" TO WS-KEY
         IF WS-SPECIES = "hoglin"
             MOVE "zoglin" TO WS-KEY
         END-IF
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         MOVE EN-X(L-ENTITY) TO WS-X
         MOVE EN-Y(L-ENTITY) TO WS-Y
         MOVE EN-Z(L-ENTITY) TO WS-Z
         MOVE EN-YAW(L-ENTITY) TO WS-YAW
         CALL "MOB-SPAWN" USING EN-DIM(L-ENTITY) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
         CALL "ENTITY-REMOVE" USING L-ENTITY
         IF WS-NEW > 0
             CALL "MEF-ADD" USING EN-ID(WS-NEW) WS-NAUSEA WS-ZERO WS-NAUSEA-TICKS WS-FLAGS
         END-IF
         MOVE 1 TO L-DONE
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-ZOMBIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT-ROLL            BINARY-LONG VALUE 61.
 01 WS-SALT-COUNT           BINARY-LONG VALUE 62.
 01 WS-TOTAL                BINARY-LONG VALUE 469.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-KEY                  PIC X(24).
 01 WS-KEY32                PIC X(32).
 01 WS-LO                   BINARY-LONG.
 01 WS-HI                   BINARY-LONG.
 01 WS-MOD                  BINARY-LONG.
 01 WS-SPAN                 BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-ITEM                 BINARY-LONG.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-DELAY                BINARY-LONG VALUE 10.
 01 WS-DROP                 BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 01 WS-KEPT                 BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-VX                   FLOAT-LONG.
 01 WS-VY                   FLOAT-LONG.
 01 WS-VZ                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ENTITY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY.
     CALL "PIGLIN-ZOMBIFY" USING L-ENTITY WS-DONE
     IF WS-DONE = 1
         GOBACK
     END-IF
     CALL "PIGLIN-PICKUP" USING L-ENTITY
     IF EN-ADMIRE-OFF(L-ENTITY) > 0
         SUBTRACT 1 FROM EN-ADMIRE-OFF(L-ENTITY)
     END-IF
     IF EN-ADMIRE(L-ENTITY) > 0
         SUBTRACT 1 FROM EN-ADMIRE(L-ENTITY)
         IF EN-ADMIRE(L-ENTITY) = 0 AND EN-ADMIRE-CUR(L-ENTITY) = 0
*>           stopHoldingOffHandItem without a barter: a loved item that is not currency goes in the inventory (44-6 section 3.4 step 2).
             CALL "PGB-OFFHAND-STOP" USING L-ENTITY WS-KEPT
         END-IF
         IF EN-ADMIRE(L-ENTITY) = 0 AND EN-ADMIRE-CUR(L-ENTITY) = 1
             CALL "XP-RANDOM" USING WS-SALT-ROLL WS-TOTAL WS-DRAW
             CALL "PIGLIN-BARTER" USING WS-DRAW WS-KEY WS-LO WS-HI WS-MOD
             COMPUTE WS-SPAN = WS-HI - WS-LO + 1
             CALL "XP-RANDOM" USING WS-SALT-COUNT WS-SPAN WS-DRAW
             COMPUTE WS-COUNT = WS-LO + WS-DRAW
             CALL "PIGLIN-THROW-VEC" USING L-ENTITY WS-VX WS-VY WS-VZ
             MOVE EN-X(L-ENTITY) TO WS-X
             COMPUTE WS-Y = EN-Y(L-ENTITY) + 1.49
             MOVE EN-Z(L-ENTITY) TO WS-Z
             CALL "PIGLIN-DROP" USING EN-DIM(L-ENTITY) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-KEY WS-MOD WS-COUNT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-HURT.
*> USING entity row, hit by a player (0/1): damage while admiring (44 section 3.4 cancelAdmiring on hurt): the memory is erased, the ingot in the off hand is lost (isCurrency and
*> not barter), any other loved item goes in the inventory (44-6 section 3.4 step 2), and only a player's hit sets ADMIRING_DISABLED for 400 ticks (44-6 section 2.3 step 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEPT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTITY                BINARY-LONG.
 01 L-BY-PLAYER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-BY-PLAYER.
     IF EN-ADMIRE(L-ENTITY) > 0
         MOVE 0 TO EN-ADMIRE(L-ENTITY)
         IF L-BY-PLAYER = 1
             MOVE 400 TO EN-ADMIRE-OFF(L-ENTITY)
         END-IF
         CALL "PGB-OFFHAND-STOP" USING L-ENTITY WS-KEPT
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-THROW-VEC.
*> USING entity row, vx, vy, vz out (FLOAT-LONG): BehaviorUtils.throwItem (44 section 3.4): 0.3 times the unit vector from the piglin to the target position + 1 block up; the target is the
*> player that gave the ingot while it is in the same dimension, else the piglin's own position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-LEN                  FLOAT-LONG.
 01 WS-P                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTITY                BINARY-LONG.
 01 L-VX                    FLOAT-LONG.
 01 L-VY                    FLOAT-LONG.
 01 L-VZ                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-VX L-VY L-VZ.
     MOVE EN-ADMIRE-PL(L-ENTITY) TO WS-P
     MOVE 0 TO WS-DX WS-DZ
     MOVE 1 TO WS-DY
     IF WS-P > 0 AND PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ENTITY)
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ENTITY)
         COMPUTE WS-DY = PL-Y(WS-P) + 1 - EN-Y(L-ENTITY)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ENTITY)
     END-IF
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     IF WS-LEN < 0.0001
         MOVE 0 TO L-VX L-VY L-VZ
     ELSE
         COMPUTE L-VX = 0.3 * WS-DX / WS-LEN
         COMPUTE L-VY = 0.3 * WS-DY / WS-LEN
         COMPUTE L-VZ = 0.3 * WS-DZ / WS-LEN
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-THROW-VEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-PICKUP.
*> USING entity row: an adult piglin takes an item lying within reach (the box of 1 block around it, 1.5 up and down; 44 section 3.2 wantsToPickUp and pickUpItem), one per
*> call, in the order of the entities: with the game rule mob_griefing off nothing; ADMIRING_DISABLED together with an attack target: nothing; a gold nugget: the whole stack
*> (kept: the piglin has no inventory store); food (porkchop, cooked porkchop) when it has not eaten recently: one is eaten (ATE_RECENTLY 200 ticks, PG-ATE); a loved item
*> when it is not admiring (no loved item in the off hand): one is held and admired for 119 ticks (a gold ingot barters at the end through EN-ADMIRE-CUR, any other loved item is
*> kept). Gaps: no walking to the item for nuggets and food, no line of sight test, babies take nothing (their stopHolding differs, 3.4), armour and other equipment is not
*> taken (canReplaceCurrentItem is Open question 2 of doc 44 part 6), the item tag piglin_repellents has no documented contents.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PGBRAIN.
 01 WS-RULE-NAME            PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                 BINARY-DOUBLE.
 01 WS-E                    BINARY-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-KEY                  PIC X(48).
 01 WS-KEY32                PIC X(32).
 01 WS-LOVED                BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-YES                  BINARY-LONG VALUE 1.
 01 WS-FITS                 BINARY-LONG.
 01 WS-LEFT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTITY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY.
     IF EN-MOBAGE(L-ENTITY) < 0
         GOBACK
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE = 0
         GOBACK
     END-IF
     CALL "PGB-SLOT" USING EN-ID(L-ENTITY) WS-YES WS-SLOT
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-DONE = 1
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-DIM(WS-E) = EN-DIM(L-ENTITY)
                 AND EN-DELAY(WS-E) <= 0 AND EN-ITEM-COUNT(WS-E) > 0
             COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ENTITY)
             COMPUTE WS-DY = EN-Y(WS-E) - EN-Y(L-ENTITY)
             COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ENTITY)
             IF FUNCTION ABS(WS-DX) <= 1 AND FUNCTION ABS(WS-DZ) <= 1 AND WS-DY >= -1.5 AND WS-DY <= 1.5
                 MOVE IT-KEY(EN-ITEM(WS-E) + 1) TO WS-KEY
                 IF WS-KEY(1:10) = "minecraft:"
                     MOVE WS-KEY(11:32) TO WS-KEY32
                 ELSE
                     MOVE WS-KEY(1:32) TO WS-KEY32
                 END-IF
                 CALL "PIGLIN-LOVED" USING WS-KEY32 WS-LOVED
                 EVALUATE TRUE
                     WHEN EN-ADMIRE-OFF(L-ENTITY) > 0 AND EN-TARGET(L-ENTITY) > 0
                         CONTINUE
                     WHEN WS-KEY32 = "gold_nugget"
*>                       The whole stack goes into the inventory when it fits (canAddToInventory).
                         CALL "PGB-INV-FITS" USING L-ENTITY EN-ITEM(WS-E) EN-ITEM-COUNT(WS-E) WS-FITS
                         IF WS-FITS = 1
                             MOVE 1 TO WS-DONE
                             CALL "PGB-INV-ADD" USING L-ENTITY EN-ITEM(WS-E) EN-ITEM-COUNT(WS-E) WS-LEFT
                             MOVE 0 TO EN-ITEM-COUNT(WS-E)
                             CALL "ENTITY-REMOVE" USING WS-E
                         END-IF
                     WHEN (WS-KEY32 = "porkchop" OR "cooked_porkchop") AND PG-ATE(WS-SLOT) = 0
*>                       eat: one is consumed and ATE_RECENTLY lasts 200 ticks.
                         MOVE 1 TO WS-DONE
                         MOVE 200 TO PG-ATE(WS-SLOT)
                         SUBTRACT 1 FROM EN-ITEM-COUNT(WS-E)
                         IF EN-ITEM-COUNT(WS-E) = 0
                             CALL "ENTITY-REMOVE" USING WS-E
                         END-IF
                     WHEN WS-LOVED = 1 AND EN-ADMIRE(L-ENTITY) = 0
                         MOVE 1 TO WS-DONE
                         MOVE 119 TO EN-ADMIRE(L-ENTITY)
                         MOVE 0 TO EN-ADMIRE-PL(L-ENTITY) EN-ADMIRE-CUR(L-ENTITY)
                         IF WS-KEY32 = "gold_ingot"
                             MOVE 1 TO EN-ADMIRE-CUR(L-ENTITY)
                         ELSE
*>                           Any other loved item stays in the off hand until the admiring ends (PGB-OFFHAND-STOP).
                             COMPUTE PG-OFFHAND(WS-SLOT) = EN-ITEM(WS-E) + 1
                         END-IF
                         SUBTRACT 1 FROM EN-ITEM-COUNT(WS-E)
                         IF EN-ITEM-COUNT(WS-E) = 0
                             CALL "ENTITY-REMOVE" USING WS-E
                         END-IF
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PIGLIN-PICKUP.
