*> Armour and toughness of a mob (docs/protocol/18 section 7.3, 17 section 4.5; lane 002-lane-mobsa).
*>
*> Entry points:
*>   MOB-ARMOR-POINTS USING row, armor out, toughness out (tenths) the armor attribute: the base of the species (the zombie family 2.0) plus the pieces
*>                                                          worn (EN-EQUIP: tier and count, head first; a broken helmet counts nothing)
*>   MOB-HEALTH-LOSE USING row, amount, cause                the health lost by a hit of amount (whole points before armour): the causes that are not in the
*>                                                          tag bypasses_armor (a player, a mob, an explosion, an arrow, lava) go through CombatRules.getDamageAfterAbsorb;
*>                                                          the fraction is carried in EN-HEALTH-MILLI. Health 0 is for the caller to handle.
*>   A witch takes 0.15 of magic and indirect magic damage (tag witch_resistant_to, 20 section 11; 002-lane-p49n), after armour and before the health is lowered.
*> Open: Resistance and the protection enchantments on mobs, the Breach adjustment, the armour wear of the pieces, the killer bunny and cube armour.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-ARMOR-POINTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-TIER                BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY40               PIC X(40).
 01 WS-KEY48               PIC X(48).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-DEFENSE             BINARY-LONG.
 01 WS-TOUGHNESS           BINARY-LONG.
 01 WS-KNOCKBACK           BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-REPAIR              PIC X(40).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ARMOR                BINARY-LONG.
 01 L-TOUGHNESS            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ARMOR L-TOUGHNESS.
     MOVE 0 TO L-ARMOR L-TOUGHNESS WS-SLOTS WS-TIER
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "zombie" OR "zombie_villager" OR "husk"
         MOVE 2 TO L-ARMOR
     END-IF
*>   A closed shulker (raw peek 0) has a +20 armour modifier (21 section 6.2).
     IF WS-KEY = "shulker" AND EN-VARIANT(L-ROW) = 0
         MOVE 20 TO L-ARMOR
     END-IF
     IF EN-EQUIP(L-ROW) > 0
         COMPUTE WS-TIER = EN-EQUIP(L-ROW) / 10 - 1
         COMPUTE WS-SLOTS = FUNCTION MOD(EN-EQUIP(L-ROW), 10)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SLOTS
         IF NOT (WS-I = 1 AND EN-HEAD-WEAR(L-ROW) = -1)
             CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-I WS-KEY40
             MOVE WS-KEY40 TO WS-KEY48
             CALL "TOOL-ARMOR-ITEM" USING WS-KEY48 WS-FOUND WS-DURABILITY WS-DEFENSE WS-TOUGHNESS WS-KNOCKBACK
                 WS-ENCHANT WS-REPAIR
             IF WS-FOUND = 1
                 ADD WS-DEFENSE TO L-ARMOR
                 ADD WS-TOUGHNESS TO L-TOUGHNESS
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-ARMOR-POINTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-HEALTH-LOSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-ARMOR               BINARY-LONG.
 01 WS-TOUGHNESS           BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-LOSS                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-DAMAGE              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT L-CAUSE.
     COMPUTE WS-MILLI = L-AMOUNT * 1000
     MOVE 0 TO WS-ARMOR
     IF L-CAUSE = CAUSE-PLAYER OR CAUSE-MOB OR CAUSE-EXPLOSION OR CAUSE-ARROW OR CAUSE-LAVA OR CAUSE-CACTUS OR CAUSE-HOT-FLOOR OR CAUSE-BERRY
         CALL "MOB-ARMOR-POINTS" USING L-ROW WS-ARMOR WS-TOUGHNESS
     END-IF
     IF WS-ARMOR > 0
         MOVE L-AMOUNT TO WS-DAMAGE
         COMPUTE WS-F = 2 + WS-TOUGHNESS / 40
         COMPUTE WS-E = WS-ARMOR - WS-DAMAGE / WS-F
         COMPUTE WS-LOW = 0.2 * WS-ARMOR
         IF WS-E < WS-LOW
             MOVE WS-LOW TO WS-E
         END-IF
         IF WS-E > 20
             MOVE 20 TO WS-E
         END-IF
         COMPUTE WS-MILLI ROUNDED = WS-DAMAGE * (1 - WS-E / 25) * 1000
     END-IF
*>   A witch takes 15 percent of magic, indirect magic and sonic boom damage (the damage-type tag witch_resistant_to, 20 section 11); the hurt window's difference of a second hit is scaled the same.
     IF L-CAUSE = CAUSE-MAGIC OR CAUSE-INDIRECT-MAGIC OR CAUSE-SONIC-BOOM
         CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
         IF WS-M > 0
             IF SM-KEY(WS-M) = "witch"
                 COMPUTE WS-MILLI ROUNDED = WS-MILLI * 15 / 100
             END-IF
         END-IF
     END-IF
     COMPUTE WS-TOTAL = EN-HEALTH-MILLI(L-ROW) + WS-MILLI
     COMPUTE WS-LOSS = WS-TOTAL / 1000
     COMPUTE EN-HEALTH-MILLI(L-ROW) = WS-TOTAL - WS-LOSS * 1000
     COMPUTE EN-HEALTH(L-ROW) = FUNCTION MAX(0, EN-HEALTH(L-ROW) - WS-LOSS)
     CALL "STDMOB-HP-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM MOB-HEALTH-LOSE.
