*> The anvil engine over live stacks (docs/protocol/40-menus-3-anvil-grindstone-smithing.md section 3.3 steps 1 to 17; lane itemcomp2, T10102): the result of the left and right stacks and the
*> item name, with the repair cost, the enchantments of the stacks (stack-comp.cob, ench-def.cob) and the level cost. The stacks are item, count and patch handle (CSTACK.cpy).
*>   ANVIL-REPAIRS USING item, material item, ok out: the material is in the repairable set of the item (the tool and armour materials of 17 section 2.1, turtle scute, phantom membrane
*>     for the elytra, planks for the shield, breeze rod for the mace)
*>   ANVIL-CREATE-RESULT USING left item, count, handle, right item, count, handle, name (PIC X(64)), name length (0 = none), infinite materials (1 or 0),
*>     result item out, result count out, result handle out, cost out (the data slot: 0 for no result), repair units out (material used by the repair path), only renaming out (1 or 0)
*>   SP-CLEAR-COMPONENT USING handle (in, out), component type: the patch without an added component of that type
*> Gaps: the hover name compared with a new name is the custom_name only (an item's own item_name is not compared), a max_damage of a patched stack is read as the stack's own.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-CLEAR-COMPONENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==SX-==.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ONE-ITEM            BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-TYPE.
     CALL "SP-EXPORT" USING WS-ONE-ITEM WS-ONE L-HANDLE SX-ITEMSTACK-X
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SX-ISX-ADDED-COUNT
         IF SX-ISX-TYPE(WS-I) NOT = L-TYPE
             ADD 1 TO WS-J
             MOVE SX-ISX-TYPE(WS-I) TO SX-ISX-TYPE(WS-J)
             MOVE SX-ISX-VALUE-LENGTH(WS-I) TO SX-ISX-VALUE-LENGTH(WS-J)
             MOVE SX-ISX-VALUE(WS-I) TO SX-ISX-VALUE(WS-J)
         END-IF
     END-PERFORM
     MOVE WS-J TO SX-ISX-ADDED-COUNT
     CALL "SP-INTERN" USING SX-ITEMSTACK-X L-HANDLE
     GOBACK.
 END PROGRAM SP-CLEAR-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ANVIL-REPAIRS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-PREFIX              PIC X(48).
 01 WS-REST                PIC X(48).
 01 WS-SUFFIXES-DATA.
    05 FILLER PIC X(12) VALUE "_sword".
    05 FILLER PIC X(12) VALUE "_pickaxe".
    05 FILLER PIC X(12) VALUE "_axe".
    05 FILLER PIC X(12) VALUE "_shovel".
    05 FILLER PIC X(12) VALUE "_hoe".
    05 FILLER PIC X(12) VALUE "_helmet".
    05 FILLER PIC X(12) VALUE "_chestplate".
    05 FILLER PIC X(12) VALUE "_leggings".
    05 FILLER PIC X(12) VALUE "_boots".
 01 WS-SUFFIXES REDEFINES WS-SUFFIXES-DATA.
    05 WS-SUFFIX           PIC X(12) OCCURS 9 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-TOOL                BINARY-LONG.
 01 WS-WANT                PIC X(800).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-MATERIAL             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-MATERIAL L-OK.
     MOVE 0 TO L-OK
     CALL "TOOLUSE-KEY" USING L-ITEM WS-KEY
     MOVE SPACES TO WS-WANT
     MOVE 0 TO WS-TOOL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-HITS
         INSPECT WS-KEY TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-SUFFIX(WS-I))
         IF WS-HITS > 0
             MOVE 1 TO WS-TOOL
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-PREFIX WS-REST
     UNSTRING WS-KEY DELIMITED BY "_" INTO WS-PREFIX WS-REST
     EVALUATE TRUE
         WHEN WS-TOOL = 1 AND WS-PREFIX = "wooden"
             MOVE "#minecraft:planks" TO WS-WANT
         WHEN WS-TOOL = 1 AND WS-PREFIX = "stone"
             MOVE "minecraft:cobblestone minecraft:blackstone minecraft:cobbled_deepslate" TO WS-WANT
         WHEN WS-TOOL = 1 AND WS-PREFIX = "copper"
             MOVE "minecraft:copper_ingot" TO WS-WANT
         WHEN WS-TOOL = 1 AND (WS-PREFIX = "iron" OR WS-PREFIX = "chainmail")
             MOVE "minecraft:iron_ingot" TO WS-WANT
         WHEN WS-TOOL = 1 AND (WS-PREFIX = "golden" OR WS-PREFIX = "gold")
             MOVE "minecraft:gold_ingot" TO WS-WANT
         WHEN WS-TOOL = 1 AND WS-PREFIX = "diamond"
             MOVE "minecraft:diamond" TO WS-WANT
         WHEN WS-TOOL = 1 AND WS-PREFIX = "netherite"
             MOVE "minecraft:netherite_ingot" TO WS-WANT
         WHEN WS-TOOL = 1 AND WS-PREFIX = "leather"
             MOVE "minecraft:leather" TO WS-WANT
         WHEN WS-TOOL = 1 AND WS-PREFIX = "turtle"
             MOVE "minecraft:turtle_scute" TO WS-WANT
         WHEN WS-KEY = "elytra"
             MOVE "minecraft:phantom_membrane" TO WS-WANT
         WHEN WS-KEY = "shield"
             MOVE "#minecraft:planks" TO WS-WANT
         WHEN WS-KEY = "mace"
             MOVE "minecraft:breeze_rod" TO WS-WANT
     END-EVALUATE
     IF WS-WANT NOT = SPACES
         CALL "CRAFT-ING-TEST" USING L-MATERIAL WS-WANT L-OK
     END-IF
     GOBACK.
 END PROGRAM ANVIL-REPAIRS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ANVIL-CREATE-RESULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX-INT             BINARY-DOUBLE VALUE 2147483647.
 01 WS-KEY                 PIC X(48).
 01 WS-RES-ITEM            BINARY-LONG.
 01 WS-RES-VAR             BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-RTYPE               BINARY-LONG VALUE 19.
 01 WS-UTYPE               BINARY-LONG VALUE 4.
 01 WS-STYPE               BINARY-LONG VALUE 45.
 01 WS-CTYPE               BINARY-LONG VALUE 6.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-BASE                BINARY-DOUBLE.
 01 WS-COST                BINARY-LONG.
 01 WS-TOTAL               BINARY-DOUBLE.
 01 WS-BOOK-ADD            BINARY-LONG.
 01 WS-DAMAGEABLE          BINARY-LONG.
 01 WS-MAX-DMG             BINARY-LONG.
 01 WS-DMG                 BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-REPAIR-OK           BINARY-LONG.
 01 WS-MAX-R               BINARY-LONG.
 01 WS-DMG-R               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-REMAINING           BINARY-LONG.
 01 WS-NEW-DMG             BINARY-LONG.
 01 WS-RTYPE-E             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-LR                  BINARY-LONG.
 01 WS-LL                  BINARY-LONG.
 01 WS-NL                  BINARY-LONG.
 01 WS-X-N                 BINARY-LONG.
 01 WS-X-ID                BINARY-LONG.
 01 WS-X-LEVEL             BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-ANVIL               BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-EXCL                PIC X(112).
 01 WS-ANY-APPLIED         BINARY-LONG.
 01 WS-ANY-REJECTED        BINARY-LONG.
 01 WS-RENAME-COST         BINARY-LONG.
 01 WS-CUR-NAME            PIC X(64).
 01 WS-CUR-LENGTH          BINARY-LONG.
 01 WS-BLANK               BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-RC-R                BINARY-LONG.
 01 WS-RES-EMPTY           BINARY-LONG.
 01 WS-LCOST               BINARY-LONG.
 01 WS-RCOST               BINARY-LONG.
 01 WS-KEEP-ITEM           BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-LITEM                BINARY-LONG.
 01 L-LCOUNT               BINARY-LONG.
 01 L-LVAR                 BINARY-LONG.
 01 L-RITEM                BINARY-LONG.
 01 L-RCOUNT               BINARY-LONG.
 01 L-RVAR                 BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-INFINITE             BINARY-LONG.
 01 L-OITEM                BINARY-LONG.
 01 L-OCOUNT               BINARY-LONG.
 01 L-OVAR                 BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-UNITS                BINARY-LONG.
 01 L-ONLYREN              BINARY-LONG.
 PROCEDURE DIVISION USING L-LITEM L-LCOUNT L-LVAR L-RITEM L-RCOUNT L-RVAR L-NAME L-NAME-LENGTH L-INFINITE
         L-OITEM L-OCOUNT L-OVAR L-COST L-UNITS L-ONLYREN.
     MOVE 0 TO L-OITEM L-OCOUNT L-OVAR L-COST L-UNITS L-ONLYREN WS-COST WS-RENAME-COST WS-EXIT
*>   Step 2: early exit A.
     IF L-LCOUNT = 0 OR L-LITEM = 0
         GOBACK
     END-IF
     MOVE L-LITEM TO WS-RES-ITEM
     MOVE L-LVAR TO WS-RES-VAR
     CALL "TOOLUSE-KEY" USING L-LITEM WS-KEY
     MOVE 13 TO WS-ETYPE
     IF WS-KEY = "enchanted_book"
         MOVE 45 TO WS-ETYPE
     END-IF
*>   Step 3: the prior work.
     MOVE L-LVAR TO WS-A
     PERFORM REPAIR-COST-LEFT
     IF L-RCOUNT > 0
         MOVE L-RVAR TO WS-A
         PERFORM REPAIR-COST-OF
         MOVE WS-RC TO WS-RCOST
     ELSE
         MOVE 0 TO WS-RCOST
     END-IF
     COMPUTE WS-BASE = WS-LCOST + WS-RCOST
     IF L-RCOUNT > 0
         PERFORM WITH-RIGHT
     END-IF
     IF WS-EXIT = 1
         GOBACK
     END-IF
*>   Step 11: rename.
     PERFORM RENAME-STEP
*>   Steps 12 to 15.
     MOVE 0 TO WS-RES-EMPTY
     IF WS-COST <= 0
         MOVE 0 TO WS-TOTAL
         MOVE 1 TO WS-RES-EMPTY
     ELSE
         COMPUTE WS-TOTAL = FUNCTION MIN(WS-BASE + WS-COST, WS-MAX-INT)
     END-IF
     IF WS-RENAME-COST = WS-COST AND WS-RENAME-COST > 0
         IF WS-TOTAL >= 40
             MOVE 39 TO WS-TOTAL
         END-IF
         MOVE 1 TO L-ONLYREN
     END-IF
     IF WS-TOTAL >= 40 AND L-INFINITE = 0
         MOVE 1 TO WS-RES-EMPTY
     END-IF
     MOVE WS-TOTAL TO L-COST
     IF WS-RES-EMPTY = 1
         GOBACK
     END-IF
*>   Step 16: the new repair cost.
     MOVE WS-RES-VAR TO WS-A
     PERFORM REPAIR-COST-OF
     MOVE WS-RC TO WS-LCOST
     IF WS-LCOST < WS-RCOST
         MOVE WS-RCOST TO WS-LCOST
     END-IF
     IF NOT (WS-RENAME-COST = WS-COST AND WS-RENAME-COST NOT = 0)
         COMPUTE WS-LCOST = FUNCTION MIN(2 * WS-LCOST + 1, 2147483647)
     END-IF
     IF WS-LCOST NOT = 0
         MOVE SPACES TO WS-VALUE
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-LCOST
         SUBTRACT 1 FROM WS-POS
         CALL "SP-SET-COMPONENT" USING WS-RES-VAR WS-RTYPE WS-VALUE WS-POS
     END-IF
     MOVE WS-RES-ITEM TO L-OITEM
     MOVE L-LCOUNT TO L-OCOUNT
     MOVE WS-RES-VAR TO L-OVAR
     GOBACK.

*> The repair cost component (19) of the stack handle WS-A, VarInt, in WS-RC (0 when absent).
 REPAIR-COST-OF.
     MOVE 0 TO WS-RC
     CALL "SP-GET-COMPONENT" USING WS-A WS-RTYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-RC
     END-IF.

 REPAIR-COST-LEFT.
     PERFORM REPAIR-COST-OF
     MOVE WS-RC TO WS-LCOST.

*> Damageable (40-3 3.3): a max_damage, no unbreakable component; WS-DAMAGEABLE, WS-MAX-DMG and WS-DMG of the result stack.
 DAMAGE-OF-RESULT.
     CALL "SP-GET-MAX-DAMAGE" USING WS-RES-ITEM WS-RES-VAR WS-MAX-DMG
     CALL "SP-GET-COMPONENT" USING WS-RES-VAR WS-UTYPE WS-VALUE WS-LENGTH WS-FOUND
     MOVE 0 TO WS-DAMAGEABLE
     IF WS-MAX-DMG > 0 AND WS-FOUND = 0
         MOVE 1 TO WS-DAMAGEABLE
     END-IF
     CALL "SP-GET-DAMAGE" USING WS-RES-ITEM WS-RES-VAR WS-DMG.

*> Steps 4 to 10 with a right stack.
 WITH-RIGHT.
     MOVE 0 TO WS-BOOK-ADD
     CALL "TOOLUSE-KEY" USING L-RITEM WS-KEY
     CALL "SP-GET-COMPONENT" USING L-RVAR WS-STYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-KEY = "enchanted_book" OR WS-FOUND = 1
         MOVE 1 TO WS-BOOK-ADD
     END-IF
     PERFORM DAMAGE-OF-RESULT
     MOVE 0 TO WS-REPAIR-OK
     IF WS-DAMAGEABLE = 1
         CALL "ANVIL-REPAIRS" USING WS-RES-ITEM L-RITEM WS-REPAIR-OK
     END-IF
     IF WS-DAMAGEABLE = 1 AND WS-REPAIR-OK = 1
         PERFORM MATERIAL-REPAIR
     ELSE
         PERFORM COMBINE
     END-IF.

*> Step 6.
 MATERIAL-REPAIR.
     COMPUTE WS-STEP = FUNCTION MIN(WS-DMG, FUNCTION INTEGER(WS-MAX-DMG / 4))
     IF WS-STEP <= 0
         MOVE 1 TO WS-EXIT
     ELSE
         MOVE 0 TO WS-USED
         PERFORM UNTIL WS-STEP <= 0 OR WS-USED >= L-RCOUNT
             COMPUTE WS-DMG = FUNCTION MAX(WS-DMG - WS-STEP, 0)
             ADD 1 TO WS-COST
             COMPUTE WS-STEP = FUNCTION MIN(WS-DMG, FUNCTION INTEGER(WS-MAX-DMG / 4))
             ADD 1 TO WS-USED
         END-PERFORM
         MOVE WS-USED TO L-UNITS
         CALL "SP-SET-DAMAGE" USING WS-RES-VAR WS-DMG
     END-IF.

*> Steps 7 to 10.
 COMBINE.
     IF WS-BOOK-ADD = 0 AND (WS-RES-ITEM NOT = L-RITEM OR WS-DAMAGEABLE = 0)
         MOVE 1 TO WS-EXIT
         EXIT PARAGRAPH
     END-IF
     IF WS-DAMAGEABLE = 1 AND WS-BOOK-ADD = 0
         CALL "SP-GET-MAX-DAMAGE" USING L-RITEM L-RVAR WS-MAX-R
         CALL "SP-GET-DAMAGE" USING L-RITEM L-RVAR WS-DMG-R
         COMPUTE WS-A = WS-MAX-DMG - WS-DMG
         COMPUTE WS-B = WS-MAX-R - WS-DMG-R + FUNCTION INTEGER(WS-MAX-DMG * 12 / 100)
         COMPUTE WS-REMAINING = WS-A + WS-B
         COMPUTE WS-NEW-DMG = FUNCTION MAX(WS-MAX-DMG - WS-REMAINING, 0)
         IF WS-NEW-DMG < WS-DMG
             MOVE WS-NEW-DMG TO WS-DMG
             CALL "SP-SET-DAMAGE" USING WS-RES-VAR WS-DMG
             ADD 2 TO WS-COST
         END-IF
     END-IF
*>   Step 9: the enchantments of the right stack (stored_enchantments of a book, enchantments otherwise).
     MOVE 13 TO WS-RTYPE-E
     IF WS-KEY = "enchanted_book"
         MOVE 45 TO WS-RTYPE-E
     END-IF
     MOVE 0 TO WS-ANY-APPLIED WS-ANY-REJECTED
     CALL "SC-ENCH-COUNT" USING L-RVAR WS-RTYPE-E WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "SC-ENCH-NTH" USING L-RVAR WS-RTYPE-E WS-I WS-ID WS-LR
         CALL "SC-ENCH-LEVEL" USING WS-RES-VAR WS-ETYPE WS-ID WS-LL
         IF WS-LL = WS-LR
             COMPUTE WS-NL = WS-LR + 1
         ELSE
             MOVE FUNCTION MAX(WS-LR, WS-LL) TO WS-NL
         END-IF
         MOVE 1 TO WS-CAN
         IF NOT (L-INFINITE = 1 OR WS-ETYPE = 45)
             CALL "ENCH-CAN" USING WS-ID L-LITEM WS-CAN
         END-IF
         CALL "SC-ENCH-COUNT" USING WS-RES-VAR WS-ETYPE WS-X-N
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-X-N
             CALL "SC-ENCH-NTH" USING WS-RES-VAR WS-ETYPE WS-J WS-X-ID WS-X-LEVEL
             IF WS-X-ID NOT = WS-ID
                 CALL "ENCH-COMPATIBLE" USING WS-ID WS-X-ID WS-OK
                 IF WS-OK = 0
                     MOVE 0 TO WS-CAN
                     ADD 1 TO WS-COST
                 END-IF
             END-IF
         END-PERFORM
         IF WS-CAN = 0
             MOVE 1 TO WS-ANY-REJECTED
         ELSE
             MOVE 1 TO WS-ANY-APPLIED
             CALL "ENCH-DEF" USING WS-ID WS-MAX WS-ANVIL WS-WEIGHT WS-TAG WS-EXCL WS-FOUND
             MOVE FUNCTION MIN(WS-NL, WS-MAX) TO WS-NL
             CALL "SC-ENCH-ADD" USING WS-RES-VAR WS-ETYPE WS-ID WS-NL
             IF WS-BOOK-ADD = 1
                 MOVE FUNCTION MAX(1, FUNCTION INTEGER(WS-ANVIL / 2)) TO WS-ANVIL
             END-IF
             COMPUTE WS-COST = WS-COST + WS-ANVIL * WS-NL
             IF L-LCOUNT > 1
                 MOVE 40 TO WS-COST
             END-IF
         END-IF
     END-PERFORM
     IF WS-ANY-REJECTED = 1 AND WS-ANY-APPLIED = 0
         MOVE 1 TO WS-EXIT
     END-IF.

*> Step 11: a blank name removes the custom_name (cost 1), a new name sets it (cost 1).
 RENAME-STEP.
     MOVE 0 TO WS-BLANK
     IF L-NAME-LENGTH = 0 OR L-NAME(1:L-NAME-LENGTH) = SPACES
         MOVE 1 TO WS-BLANK
     END-IF
     CALL "SP-GET-NAME" USING L-LVAR WS-CUR-NAME WS-CUR-LENGTH
     IF WS-BLANK = 1
         IF WS-CUR-LENGTH > 0
             MOVE 1 TO WS-RENAME-COST
             ADD 1 TO WS-COST
             CALL "SP-CLEAR-COMPONENT" USING WS-RES-VAR WS-CTYPE
         END-IF
     ELSE
         IF L-NAME-LENGTH NOT = WS-CUR-LENGTH OR L-NAME(1:L-NAME-LENGTH) NOT = WS-CUR-NAME(1:L-NAME-LENGTH)
             MOVE 1 TO WS-RENAME-COST
             ADD 1 TO WS-COST
             CALL "SP-SET-NAME" USING WS-RES-VAR L-NAME L-NAME-LENGTH
         END-IF
     END-IF.
 END PROGRAM ANVIL-CREATE-RESULT.
