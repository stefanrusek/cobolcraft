*> Piglin bartering (docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md section 5.5.1; lane 002-lane-mobsb). Programs of plain numbers over BARTER.cpy.
*>
*>   PIGLIN-BARTER USING draw (0 to 468), item key out (X(24)), count low out, count high out, modifier out   the row of the barter table a draw falls in
*>   PIGLIN-CURRENCY USING item key (X(24)), yes out                                                       the barter currency is gold_ingot
*>   PIGLIN-LOVED USING item key (X(24)), yes out                                                          piglin_loved
*>   PIGLIN-SAFE-ARMOR USING item key (X(24)), yes out                                                     piglin_safe_armor: the four golden armor pieces
*>   PIGLIN-ADMIRE USING adult, admiring, admiring disabled, yes out                                         mobInteract accepts an ingot only from an adult not admiring and not disabled
*>   PIGLIN-STACK USING item key (X(24)), modifier, item id out (-1 unknown), patch handle out               the stack of a barter row with its modifier applied (T9604): 1 enchant randomly with soul_speed (a book
*>                                                                                                             becomes an enchanted_book with stored_enchantments, boots get enchantments; level 1 to 3), 2 and 3 the potion
*>                                                                                                             fire_resistance and water in potion_contents
*>   PIGLIN-DROP USING dim, x, y, z, vx, vy, vz (FLOAT-LONG), item key, modifier, count                       PIGLIN-STACK, then the item entity with the patch (pickup delay 10)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-BARTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BARTER.
 01 WS-BT REDEFINES BARTER-DATA.
    05 WS-ROW OCCURS 19 TIMES.
       10 WS-KEY               PIC X(24).
       10 WS-WEIGHT            BINARY-LONG.
       10 WS-LO                BINARY-LONG.
       10 WS-HI                BINARY-LONG.
       10 WS-MOD               BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-SUM                  BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DRAW                  BINARY-LONG.
 01 L-KEY                   PIC X(24).
 01 L-LO                    BINARY-LONG.
 01 L-HI                    BINARY-LONG.
 01 L-MOD                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-KEY L-LO L-HI L-MOD.
     MOVE 0 TO WS-SUM WS-DONE
     MOVE SPACES TO L-KEY
     MOVE 0 TO L-LO L-HI L-MOD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         ADD WS-WEIGHT(WS-I) TO WS-SUM
         IF WS-DONE = 0 AND L-DRAW < WS-SUM
             MOVE 1 TO WS-DONE
             MOVE WS-KEY(WS-I) TO L-KEY
             MOVE WS-LO(WS-I) TO L-LO
             MOVE WS-HI(WS-I) TO L-HI
             MOVE WS-MOD(WS-I) TO L-MOD
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PIGLIN-BARTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-CURRENCY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(24).
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-YES.
     MOVE 0 TO L-YES
     IF L-KEY = "gold_ingot"
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-CURRENCY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-LOVED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOVED.
 01 WS-LV REDEFINES LOVED-DATA.
    05 WS-L                 PIC X(32) OCCURS 28 TIMES.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(32).
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-YES.
     MOVE 0 TO L-YES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LV-COUNT
         IF WS-L(WS-I) = L-KEY
             MOVE 1 TO L-YES
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PIGLIN-LOVED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-SAFE-ARMOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(24).
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-YES.
     MOVE 0 TO L-YES
     IF L-KEY = "golden_helmet" OR "golden_chestplate" OR "golden_leggings" OR "golden_boots"
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-SAFE-ARMOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-ADMIRE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ADULT                 BINARY-LONG.
 01 L-ADMIRING              BINARY-LONG.
 01 L-DISABLED              BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ADULT L-ADMIRING L-DISABLED L-YES.
     MOVE 0 TO L-YES
     IF L-ADULT = 1 AND L-ADMIRING = 0 AND L-DISABLED = 0
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-ADMIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-STACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SALT-LEVEL          BINARY-LONG VALUE 63.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-KEY32               PIC X(32).
 01 WS-ENCH                PIC X(112) VALUE "soul_speed".
 01 WS-SOUL                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-POTION-KEY          PIC X(32).
 01 WS-POTION              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-MOD                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-MOD L-ITEM L-HANDLE.
     MOVE 0 TO L-HANDLE
     MOVE SPACES TO WS-KEY32
     MOVE L-KEY TO WS-KEY32
     IF L-MOD = 1 AND L-KEY = "book"
         MOVE "enchanted_book" TO WS-KEY32
     END-IF
     CALL "MERCHANT-ITEM-ID" USING WS-KEY32 L-ITEM
     IF L-ITEM < 0
         GOBACK
     END-IF
     EVALUATE L-MOD
         WHEN 1
             CALL "LOOT-ENCH-ID" USING WS-ENCH WS-SOUL
             CALL "XP-RANDOM" USING WS-SALT-LEVEL WS-THREE WS-DRAW
             COMPUTE WS-LEVEL = WS-DRAW + 1
             IF L-KEY = "book"
                 MOVE 45 TO WS-TYPE
             ELSE
                 MOVE 13 TO WS-TYPE
             END-IF
             CALL "SC-ENCH-ADD" USING L-HANDLE WS-TYPE WS-SOUL WS-LEVEL
         WHEN 2
             MOVE "fire_resistance" TO WS-POTION-KEY
             CALL "SC-POTION-ID" USING WS-POTION-KEY WS-POTION
             CALL "SC-POTION-SET" USING L-HANDLE WS-POTION
         WHEN 3
             MOVE "water" TO WS-POTION-KEY
             CALL "SC-POTION-ID" USING WS-POTION-KEY WS-POTION
             CALL "SC-POTION-SET" USING L-HANDLE WS-POTION
     END-EVALUATE
     GOBACK.
 END PROGRAM PIGLIN-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-ITEM                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-KEY                  PIC X(24).
 01 L-MOD                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-KEY L-MOD L-COUNT.
     CALL "PIGLIN-STACK" USING L-KEY L-MOD WS-ITEM WS-HANDLE
     IF WS-ITEM >= 0
         CALL "GI-SPAWN-X" USING L-DIM L-X L-Y L-Z L-VX L-VY L-VZ WS-ITEM L-COUNT WS-DELAY WS-ROW WS-HANDLE
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-DROP.
