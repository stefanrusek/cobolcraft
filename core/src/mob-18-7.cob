*> Damage, knockback, death, drops and experience of the mob framework (docs/protocol/18-mob-framework.md section 7; lane 002-lane-mobsfull-h13).
*>
*>   M187-RESIST USING species, resistance out (thousandths)           the knockback_resistance of a species (7.4; the species with an override in documents 19 and 21)
*>   M187-KNOCK USING row, source x, source z (FLOAT-LONG), strength, resistance (thousandths)   LivingEntity.knockback (7.4) on the velocity EN-VX, EN-VY, EN-VZ of a mob row
*>   M187-HIT USING row, attacker player row                           dealDefaultKnockback (7.4): strength 0.4 away from the attacker, the species' resistance

*>   Which items a mob wants (7.2, 44-1 RQ-1.3; the stack model of a mob row is core/src/mob-18-7-equip.cob). Pure rules on stack facts (M187FACTS.cpy) and modifier lists (M187MODS.cpy):
*>   M187-GROUP-HAS USING slot group, slot, yes out                  1 any, 2 mainhand, 3 offhand, 4 hand, 5 feet, 6 legs, 7 chest, 8 head, 9 armor, 10 body, 11 saddle (the list of 04)
*>   M187-APPROX-ATTR USING base, attribute, slot, count, modifiers, value out    getApproximateAttributeWith: one pass in list order, ADD_VALUE v += a, ADD_MULTIPLIED_BASE v += a x base, ADD_MULTIPLIED_TOTAL v += a x v
*>   M187-EQUAL-ITEM USING candidate facts, current facts, yes out   canReplaceEqualItem: more enchantments, else less damage, else a custom name against none
*>   M187-COMPARE-ARMOR USING candidate, current, yes out            prevent_armor_change refuses, then armor, then toughness, then the equal rule
*>   M187-COMPARE-WEAPONS USING candidate, current, yes out          the preferred tag, then attack damage, then the equal rule
*>   M187-CAN-REPLACE USING slot (1 head, 2 chest, 3 legs, 4 feet, 5 main hand, 6 off hand), candidate, current, yes out   canReplaceCurrentItem
*>   M187-DROP-TEST USING draw (nextFloat), chance, yes out          max(draw - 0.1, 0) < chance: whether equipItemIfPossible drops the old stack

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-RESIST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPECIES              PIC X(24).
 01 L-MILLI                BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECIES L-MILLI.
     EVALUATE L-SPECIES
         WHEN "iron_golem"
             MOVE 1000 TO L-MILLI
         WHEN "hoglin" WHEN "zoglin"
             MOVE 600 TO L-MILLI
         WHEN "nautilus" WHEN "zombie_nautilus"
             MOVE 300 TO L-MILLI
         WHEN OTHER
             MOVE 0 TO L-MILLI
     END-EVALUATE
     GOBACK.
 END PROGRAM M187-RESIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-KNOCK.
*> USING mob tracker row, source x, source z (FLOAT-LONG), strength and resistance (BINARY-LONG thousandths): strength = strength x (1 - resistance), nothing at 0 or
*> below; (dx, dz) is the direction from the victim to the source, and while its squared length is below 1.0E-5 it is replaced by a random pair
*> ((a - b) x 0.01 each, drawn from the hash of the entity id and the time and a counter); the new velocity is x = vx / 2 - dx / |d| x strength, z likewise,
*> y = min(0.4, vy / 2 + strength) on the ground and unchanged in the air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-S                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-UP                  FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-TRY                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-RESIST               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Z L-STRENGTH L-RESIST.
     COMPUTE WS-S = L-STRENGTH * (1000 - L-RESIST) / 1000000
     IF WS-S <= 0
         GOBACK
     END-IF
     COMPUTE WS-DX = L-X - EN-X(L-ROW)
     COMPUTE WS-DZ = L-Z - EN-Z(L-ROW)
     MOVE 0 TO WS-TRY
     PERFORM UNTIL WS-DX * WS-DX + WS-DZ * WS-DZ >= 0.00001
         ADD 1 TO WS-TRY
         MOVE EN-ID(L-ROW) TO WS-ARG(1)
         MOVE CW-TICKS TO WS-ARG(2)
         MOVE 31 TO WS-ARG(3)
         MOVE WS-TRY TO WS-ARG(4)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         COMPUTE WS-Q = FUNCTION MOD(WS-R, 2001)
         COMPUTE WS-DX = (WS-Q - 1000) / 100000
         COMPUTE WS-Q = FUNCTION MOD(WS-R / 2001, 2001)
         COMPUTE WS-DZ = (WS-Q - 1000) / 100000
     END-PERFORM
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) / 2 - WS-DX / WS-LEN * WS-S
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) / 2 - WS-DZ / WS-LEN * WS-S
     IF EN-ON-GROUND(L-ROW) = 1
         COMPUTE WS-UP = FUNCTION MIN(0.4, EN-VY(L-ROW) / 2 + WS-S)
         MOVE WS-UP TO EN-VY(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M187-KNOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-HIT.
*> USING mob tracker row, attacker player row: the default knockback of a fresh hit (7.4), strength 0.4, away from the attacker.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-RESIST              BINARY-LONG.
 01 WS-STRENGTH            BINARY-LONG VALUE 400.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     CALL "M187-RESIST" USING WS-KEY WS-RESIST
     CALL "M187-KNOCK" USING L-ROW PL-X(L-ATTACKER) PL-Z(L-ATTACKER) WS-STRENGTH WS-RESIST
     GOBACK.
 END PROGRAM M187-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-GROUP-HAS.
*> USING group, slot, yes out: whether the slot group holds the equipment slot (04 list: any holds every slot, hand the two hands, armor the four armor slots, every other group only its own slot).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROUP                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUP L-SLOT L-YES.
     MOVE 0 TO L-YES
     EVALUATE TRUE
         WHEN L-GROUP = 1
             MOVE 1 TO L-YES
         WHEN L-GROUP = 4 AND (L-SLOT = 2 OR L-SLOT = 3)
             MOVE 1 TO L-YES
         WHEN L-GROUP = 9 AND L-SLOT >= 5 AND L-SLOT <= 8
             MOVE 1 TO L-YES
         WHEN L-GROUP NOT = 4 AND L-GROUP NOT = 9 AND L-GROUP = L-SLOT
             MOVE 1 TO L-YES
     END-EVALUATE
     GOBACK.
 END PROGRAM M187-GROUP-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-APPROX-ATTR.
*> USING base, attribute code, slot, count, modifiers (M187MODS.cpy), value out (FLOAT-LONG): getApproximateAttributeWith (7.2): v = base, then each of the first count modifiers in list
*> order whose attribute is the one asked and whose slot group holds the slot: ADD_VALUE v += a, ADD_MULTIPLIED_BASE v += a x base, ADD_MULTIPLIED_TOTAL v += a x v (the running value).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BASE                 FLOAT-LONG.
 01 L-ATTR                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 COPY M187MODS REPLACING LEADING ==MM-== BY ==L-M-==.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-BASE L-ATTR L-SLOT L-COUNT L-M-MODS L-VALUE.
     MOVE L-BASE TO L-VALUE
     MOVE L-COUNT TO WS-LAST
     IF WS-LAST > 8
         MOVE 8 TO WS-LAST
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LAST
         IF L-M-ATTR(WS-I) = L-ATTR
             CALL "M187-GROUP-HAS" USING L-M-GROUP(WS-I) L-SLOT WS-YES
             IF WS-YES = 1
                 EVALUATE L-M-OP(WS-I)
                     WHEN 0
                         COMPUTE L-VALUE = L-VALUE + L-M-AMOUNT(WS-I)
                     WHEN 1
                         COMPUTE L-VALUE = L-VALUE + L-M-AMOUNT(WS-I) * L-BASE
                     WHEN 2
                         COMPUTE L-VALUE = L-VALUE + L-M-AMOUNT(WS-I) * L-VALUE
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M187-APPROX-ATTR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-EQUAL-ITEM.
*> USING candidate facts, current facts, yes out: canReplaceEqualItem (7.2): different numbers of distinct enchantments: yes exactly when the candidate has more; else different damage
*> values: yes exactly when the candidate's is lower; else yes exactly when the candidate has a custom name and the current has none.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==L-C-==.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==L-U-==.
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-C-FACTS L-U-FACTS L-YES.
     MOVE 0 TO L-YES
     EVALUATE TRUE
         WHEN L-C-ENCH NOT = L-U-ENCH
             IF L-C-ENCH > L-U-ENCH
                 MOVE 1 TO L-YES
             END-IF
         WHEN L-C-WEAR NOT = L-U-WEAR
             IF L-C-WEAR < L-U-WEAR
                 MOVE 1 TO L-YES
             END-IF
         WHEN L-C-NAMED = 1 AND L-U-NAMED = 0
             MOVE 1 TO L-YES
     END-EVALUATE
     GOBACK.
 END PROGRAM M187-EQUAL-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-COMPARE-ARMOR.
*> USING candidate facts, current facts, yes out: compareArmor (7.2): a current stack with prevent_armor_change refuses; different armor: yes exactly when the candidate's is more; else different
*> toughness: yes exactly when the candidate's is more; else canReplaceEqualItem.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==L-C-==.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==L-U-==.
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-C-FACTS L-U-FACTS L-YES.
     MOVE 0 TO L-YES
     EVALUATE TRUE
         WHEN L-U-BINDING = 1
             CONTINUE
         WHEN L-C-ARMOR NOT = L-U-ARMOR
             IF L-C-ARMOR > L-U-ARMOR
                 MOVE 1 TO L-YES
             END-IF
         WHEN L-C-TOUGH NOT = L-U-TOUGH
             IF L-C-TOUGH > L-U-TOUGH
                 MOVE 1 TO L-YES
             END-IF
         WHEN OTHER
             CALL "M187-EQUAL-ITEM" USING L-C-FACTS L-U-FACTS L-YES
     END-EVALUATE
     GOBACK.
 END PROGRAM M187-COMPARE-ARMOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-COMPARE-WEAPONS.
*> USING candidate facts, current facts, yes out: compareWeapons (7.2): with a preferred weapon tag, a current stack in it against a candidate outside it refuses and a current outside it against a candidate
*> in it replaces (MF-PREF; a mob with no tag has it 0 on both); else different attack damage: yes exactly when the candidate's is more; else canReplaceEqualItem.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==L-C-==.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==L-U-==.
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-C-FACTS L-U-FACTS L-YES.
     MOVE 0 TO L-YES
     EVALUATE TRUE
         WHEN L-U-PREF = 1 AND L-C-PREF = 0
             CONTINUE
         WHEN L-U-PREF = 0 AND L-C-PREF = 1
             MOVE 1 TO L-YES
         WHEN L-C-DAMAGE NOT = L-U-DAMAGE
             IF L-C-DAMAGE > L-U-DAMAGE
                 MOVE 1 TO L-YES
             END-IF
         WHEN OTHER
             CALL "M187-EQUAL-ITEM" USING L-C-FACTS L-U-FACTS L-YES
     END-EVALUATE
     GOBACK.
 END PROGRAM M187-COMPARE-WEAPONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-CAN-REPLACE.
*> USING slot (1 head, 2 chest, 3 legs, 4 feet, 5 main hand, 6 off hand), candidate facts, current facts, yes out: canReplaceCurrentItem (7.2): an empty current stack is replaced; an armor
*> slot compares armor, the main hand compares weapons, any other slot refuses (the per-mob overrides are the callers' own).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==L-C-==.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==L-U-==.
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-C-FACTS L-U-FACTS L-YES.
     MOVE 0 TO L-YES
     EVALUATE TRUE
         WHEN L-U-EMPTY = 1
             MOVE 1 TO L-YES
         WHEN L-SLOT >= 1 AND L-SLOT <= 4
             CALL "M187-COMPARE-ARMOR" USING L-C-FACTS L-U-FACTS L-YES
         WHEN L-SLOT = 5
             CALL "M187-COMPARE-WEAPONS" USING L-C-FACTS L-U-FACTS L-YES
     END-EVALUATE
     GOBACK.
 END PROGRAM M187-CAN-REPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-DROP-TEST.
*> USING draw (FLOAT-LONG, a nextFloat), chance (FLOAT-LONG), yes out: equipItemIfPossible drops the old stack when max(draw - 0.1, 0) < the slot's drop chance (7.2; the caller draws only for a
*> non-empty old stack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-CHANCE L-YES.
     COMPUTE WS-X = L-DRAW - 0.1
     IF WS-X < 0
         MOVE 0 TO WS-X
     END-IF
     MOVE 0 TO L-YES
     IF WS-X < L-CHANCE
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM M187-DROP-TEST.
