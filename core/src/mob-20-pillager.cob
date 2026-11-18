*> The pillager's five-slot inventory, its loot pickup, the charging metadata 17 and the captain's loot facts (docs/protocol/20 sections 13 and 13.2, 26 entity predicates; 002-lane-p49n).
*> State: P49NSTATE.cpy (PN-INV-ITEM, PN-INV-COUNT, PN-CHARGE, PN-LOOT-*), RAIDSTATE.cpy (RR-*), PATROL.cpy (PT-*).
*>
*>   RAIDER-IS-CAPTAIN USING tracker row, captain out, has raid out: has raid is 1 for a member of a raid wave (RR-ID); a captain wears the wave's banner (RR-LEADER 1) or is a patrol leader
*>     (PT-LEADER) with no raid wave (13, "Captain").
*>   PILLAGER-INV-ADD USING tracker row, item id (0 based), count, left out: SimpleContainer(5).addItem: the item merges into the stacks of the same item (up to the item's stack size)
*>     and then fills the first empty slot; the count that did not fit comes back.
*>   PILLAGER-PICKUP-TICK USING tracker row: Mob.aiStep loot pickup with canPickUpLoot (18 section 2.7: mob_griefing on, the item within 1 block horizontally of its box, no pickup
*>     delay) and Pillager.wantsItem: without an active raid any item that is not a banner goes into the inventory (a banner goes to the head by the Raider rule); with a raid only the
*>     ominous banner is wanted, so nothing is added here. The stack shrinks by what fitted and goes when empty.
*>   PILLAGER-FLAGS-TICK USING tracker row: metadata 17 follows the crossbow goal's CHARGING state (EN-DRAW 1) and is sent on a change.
*>   RAIDER-LOOT-SET USING tracker row / RAIDER-LOOT-CLEAR: the type_specific/raider facts for the loot of the row that dies (STDMOB-DIE).
*> Not here: the inventory in the saved entity (the Inventory list is kept by SPXTAB.cpy as it was read), the inventory's drop on death (not documented), Quick Charge, and banner
*> pickup into the head slot and the wave leader (the Raider rule of 13 is in the raid code).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAIDER-IS-CAPTAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RAIDSTATE.
 COPY PATROL.
 01 WS-I                   BINARY-LONG.
 01 WS-LEADER              BINARY-LONG.
 01 WS-BANNER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAPTAIN              BINARY-LONG.
 01 L-HAS-RAID             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAPTAIN L-HAS-RAID.
     MOVE 0 TO L-CAPTAIN L-HAS-RAID WS-LEADER WS-BANNER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) = EN-ID(L-ROW)
             MOVE 1 TO L-HAS-RAID
             IF RR-LEADER(WS-I) = 1
                 MOVE 1 TO WS-BANNER
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PT-MAX
         IF PT-ID(WS-I) = EN-ID(L-ROW) AND PT-LEADER(WS-I) = 1
             MOVE 1 TO WS-LEADER
         END-IF
     END-PERFORM
     IF WS-BANNER = 1 OR (WS-LEADER = 1 AND L-HAS-RAID = 0)
         MOVE 1 TO L-CAPTAIN
     END-IF
     GOBACK.
 END PROGRAM RAIDER-IS-CAPTAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PILLAGER-INV-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY P49NSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-MOVE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-LEFT.
     CALL "PN-ROW-OPEN" USING L-ROW
     MOVE L-COUNT TO L-LEFT
     MOVE IT-MAX-STACK(L-ITEM + 1) TO WS-MAX
     IF WS-MAX < 1
         MOVE 64 TO WS-MAX
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR L-LEFT = 0
         IF PN-INV-ITEM(L-ROW, WS-I) = L-ITEM + 1 AND PN-INV-COUNT(L-ROW, WS-I) < WS-MAX
             COMPUTE WS-ROOM = WS-MAX - PN-INV-COUNT(L-ROW, WS-I)
             COMPUTE WS-MOVE = FUNCTION MIN(WS-ROOM, L-LEFT)
             ADD WS-MOVE TO PN-INV-COUNT(L-ROW, WS-I)
             SUBTRACT WS-MOVE FROM L-LEFT
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR L-LEFT = 0
         IF PN-INV-ITEM(L-ROW, WS-I) = 0 OR PN-INV-COUNT(L-ROW, WS-I) = 0
             COMPUTE WS-MOVE = FUNCTION MIN(WS-MAX, L-LEFT)
             COMPUTE PN-INV-ITEM(L-ROW, WS-I) = L-ITEM + 1
             MOVE WS-MOVE TO PN-INV-COUNT(L-ROW, WS-I)
             SUBTRACT WS-MOVE FROM L-LEFT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PILLAGER-INV-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PILLAGER-PICKUP-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-E                   BINARY-LONG.
 01 WS-CAPTAIN             BINARY-LONG.
 01 WS-HAS-RAID            BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     CALL "RAIDER-IS-CAPTAIN" USING L-ROW WS-CAPTAIN WS-HAS-RAID
     IF WS-RULE = 0 OR WS-HAS-RAID = 1
         GOBACK
     END-IF
     COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) / 2000 + 1.125
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-DIM(WS-E) = EN-DIM(L-ROW)
                 AND EN-ITEM-COUNT(WS-E) > 0 AND EN-DELAY(WS-E) <= 0
             IF FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) < WS-HALF AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) < WS-HALF
                     AND EN-Y(WS-E) >= EN-Y(L-ROW) - 0.25 AND EN-Y(WS-E) < EN-Y(L-ROW) + WS-HEIGHT
                 MOVE IT-KEY(EN-ITEM(WS-E) + 1) TO WS-KEY
                 IF WS-KEY NOT = "minecraft:white_banner" AND WS-KEY NOT = "white_banner"
                     CALL "PILLAGER-INV-ADD" USING L-ROW EN-ITEM(WS-E) EN-ITEM-COUNT(WS-E) WS-LEFT
                     MOVE WS-LEFT TO EN-ITEM-COUNT(WS-E)
                     IF WS-LEFT = 0
                         CALL "ENTITY-REMOVE" USING WS-E
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PILLAGER-PICKUP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PILLAGER-FLAGS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 01 WS-CHARGING            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-ROW-OPEN" USING L-ROW
     MOVE 0 TO WS-CHARGING
     IF EN-DRAW(L-ROW) = 1
         MOVE 1 TO WS-CHARGING
     END-IF
     IF PN-CHARGE(L-ROW) NOT = WS-CHARGING
         MOVE WS-CHARGING TO PN-CHARGE(L-ROW)
         CALL "STDMOB-FLAGS-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM PILLAGER-FLAGS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAIDER-LOOT-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY P49NSTATE.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO PN-LOOT-RAIDER PN-LOOT-HAS-RAID PN-LOOT-CAPTAIN
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0
         IF SM-KEY(WS-M) = "pillager" OR "vindicator" OR "evoker" OR "illusioner" OR "witch" OR "ravager"
             MOVE 1 TO PN-LOOT-RAIDER
             CALL "RAIDER-IS-CAPTAIN" USING L-ROW PN-LOOT-CAPTAIN PN-LOOT-HAS-RAID
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RAIDER-LOOT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAIDER-LOOT-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY P49NSTATE.
 PROCEDURE DIVISION.
     MOVE 0 TO PN-LOOT-RAIDER PN-LOOT-HAS-RAID PN-LOOT-CAPTAIN
     GOBACK.
 END PROGRAM RAIDER-LOOT-CLEAR.
