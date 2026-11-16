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
         MOVE 1 TO L-USED
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-ZOMBIFY.
*> Piglins and hoglins (zoglin, 21 section 5.6) share the rule. The Nausea of 200 ticks of the converted mob and the cancelling of the admiring (the held items) are not done: open items of T7103.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
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
 LINKAGE SECTION.
 01 L-ENTITY                BINARY-LONG.
 01 L-DONE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-DONE.
     MOVE 0 TO L-DONE
     IF DM-KEY(EN-DIM(L-ENTITY)) = "minecraft:the_nether"
         MOVE 0 TO EN-ZOMBIFY(L-ENTITY)
         GOBACK
     END-IF
     ADD 1 TO EN-ZOMBIFY(L-ENTITY)
     IF EN-ZOMBIFY(L-ENTITY) > 300 AND BW-DIFFICULTY > 0
*>       cancelAdmiring (44 section 3.4): the held ingot is dropped as an item.
         IF EN-ADMIRE(L-ENTITY) > 0
             MOVE 0 TO EN-ADMIRE(L-ENTITY)
             MOVE "gold_ingot" TO WS-INGOT
             CALL "MERCHANT-ITEM-ID" USING WS-INGOT WS-ITEM
             MOVE EN-X(L-ENTITY) TO WS-X
             COMPUTE WS-Y = EN-Y(L-ENTITY) + 1
             MOVE EN-Z(L-ENTITY) TO WS-Z
             CALL "GI-SPAWN-RANDOM" USING EN-DIM(L-ENTITY) WS-X WS-Y WS-Z WS-ITEM WS-ONE WS-ZERO WS-DELAY WS-DROP
         END-IF
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
     IF EN-ADMIRE-OFF(L-ENTITY) > 0
         SUBTRACT 1 FROM EN-ADMIRE-OFF(L-ENTITY)
     END-IF
     IF EN-ADMIRE(L-ENTITY) > 0
         SUBTRACT 1 FROM EN-ADMIRE(L-ENTITY)
         IF EN-ADMIRE(L-ENTITY) = 0
             CALL "XP-RANDOM" USING WS-SALT-ROLL WS-TOTAL WS-DRAW
             CALL "PIGLIN-BARTER" USING WS-DRAW WS-KEY WS-LO WS-HI WS-MOD
             COMPUTE WS-SPAN = WS-HI - WS-LO + 1
             CALL "XP-RANDOM" USING WS-SALT-COUNT WS-SPAN WS-DRAW
             COMPUTE WS-COUNT = WS-LO + WS-DRAW
             MOVE WS-KEY TO WS-KEY32
             CALL "MERCHANT-ITEM-ID" USING WS-KEY32 WS-ITEM
             IF WS-ITEM >= 0
                 CALL "PIGLIN-THROW-VEC" USING L-ENTITY WS-VX WS-VY WS-VZ
                 MOVE EN-X(L-ENTITY) TO WS-X
                 COMPUTE WS-Y = EN-Y(L-ENTITY) + 1.49
                 MOVE EN-Z(L-ENTITY) TO WS-Z
                 CALL "GI-SPAWN-X" USING EN-DIM(L-ENTITY) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-DROP WS-ZERO
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-HURT.
*> Damage while admiring (44 section 3.4 cancelAdmiring on hurt): the memory is erased, the ingot in the off hand is lost (isCurrency and not barter), ADMIRING_DISABLED for 400 ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ENTITY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY.
     IF EN-ADMIRE(L-ENTITY) > 0
         MOVE 0 TO EN-ADMIRE(L-ENTITY)
         MOVE 400 TO EN-ADMIRE-OFF(L-ENTITY)
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
