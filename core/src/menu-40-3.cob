*> Menus, part 3: the item combiner base, the anvil, the grindstone and the smithing table (docs/protocol/40-menus-3-anvil-grindstone-smithing.md sections 1
*> to 6 and 9; US12 phase 44). Programs of plain numbers (MN3- prefix): each takes the facts the caller read from the stacks (counts, damage values, flags, the
*> random draw) and returns the decision, the new numbers or the pixel arithmetic of the section. Stacks, enchantment maps and registries are the caller's:
*> nothing here touches the live window of a player (menus.cob), the block entities or the level. Flags are 0 or 1. Kinds of table M1: 1 anvil, 2 grindstone,
*> 3 smithing table. The data slot wire format is MN2-DATA-WIRE (menu-40-2.cob). The orb split of 4.4 (17 4.10) is not here.
*>
*>   MN3-IDENT, MN3-TITLE, MN3-BOUND, MN3-LEVEL-EVENT, MN3-VALID (1); MN3-DEF-CHECK, MN3-LAYOUT, MN3-RESULT-SLOT, MN3-SLOTS-CHANGED, MN3-COMBINER-QUICK (2)
*>   MN3-ANVIL-PATH, -REPAIR, -DURABILITY, -ENCH, -EXIT-D, -RENAME, -TOTAL, -NEWREPAIR, -PICKUP, -TAKE, -DAMAGE; MN3-NAME-CHAR, MN3-BLANK-CHAR, MN3-NAME-SET
*>   MN3-ANVIL-NAMECHG, -SLOT-CHANGED, -SCREEN, -LABEL, -KEY (3)
*>   MN3-GRIND-MAYPLACE, -COMPUTE, -MERGE, -MERGE-ENCH, -REMOVE, -MINCOST, -XP, -QUICK, -ERROR (4)
*>   MN3-SMITH-MAYPLACE, -FLAG, -CREATE, -TAKE, -CANMOVE, -PICKALL, MN3-CYCLE-TICK, -DRAW, MN3-ICON-COUNT, -NAME, MN3-TEMPLATE-ICON, MN3-SMITH-TOOLTIP,
*>   MN3-TOOLTIP-TEXT, MN3-PREVIEW, MN3-SMITH-SLOT-CHANGED, MN3-SMITH-SCREEN (5); MN3-SMITH-FIRST, MN3-INGREDIENT-OK (6)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-IDENT.
*> USING kind, menu type id out, own slots out, total slots out, data slots out (table M1, 8.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TYPE L-OWN L-TOTAL L-DATA.
    EVALUATE L-KIND
        WHEN 1
            MOVE 8 TO L-TYPE
            MOVE 3 TO L-OWN
            MOVE 39 TO L-TOTAL
            MOVE 1 TO L-DATA
        WHEN 2
            MOVE 15 TO L-TYPE
            MOVE 3 TO L-OWN
            MOVE 39 TO L-TOTAL
            MOVE 0 TO L-DATA
        WHEN OTHER
            MOVE 21 TO L-TYPE
            MOVE 4 TO L-OWN
            MOVE 40 TO L-TOTAL
            MOVE 1 TO L-DATA
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-IDENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-TITLE.
*> USING kind, default title key out, English text out (table M1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    EVALUATE L-KIND
        WHEN 1
            MOVE "container.repair" TO L-T1
            MOVE "Repair & Name" TO L-T2
        WHEN 2
            MOVE "container.grindstone_title" TO L-T1
            MOVE "Repair & Disenchant" TO L-T2
        WHEN 3
            MOVE "container.upgrade" TO L-T1
            MOVE "Upgrade Gear" TO L-T2
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-TITLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-BOUND.
*> USING kind, bound block out (the anvil by block tag), interaction statistic out (table M1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    EVALUATE L-KIND
        WHEN 1
            MOVE "tag anvil" TO L-T1
            MOVE "interact_with_anvil" TO L-T2
        WHEN 2
            MOVE "grindstone" TO L-T1
            MOVE "interact_with_grindstone" TO L-T2
        WHEN 3
            MOVE "smithing_table" TO L-T1
            MOVE "interact_with_smithing_table" TO L-T2
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-BOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-LEVEL-EVENT.
*> USING level event id, sound code out (1 anvil.destroy, 2 anvil.use, 3 anvil.land, 4 grindstone.use, 5 smithing_table.use; 0 not used here), volume x 100 out (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-VOL                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-CODE L-VOL.
    MOVE 0 TO L-CODE L-VOL
    EVALUATE L-EVENT
        WHEN 1029
            MOVE 1 TO L-CODE
            MOVE 100 TO L-VOL
        WHEN 1030
            MOVE 2 TO L-CODE
            MOVE 100 TO L-VOL
        WHEN 1031
            MOVE 3 TO L-CODE
            MOVE 30 TO L-VOL
        WHEN 1042
            MOVE 4 TO L-CODE
            MOVE 100 TO L-VOL
        WHEN 1044
            MOVE 5 TO L-CODE
            MOVE 100 TO L-VOL
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-LEVEL-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-VALID.
*> USING access is NULL, the block is the right one, the player is in range (+ 4.0), valid out (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NUL                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-NUL L-BLOCK L-RANGE L-VALID.
    MOVE 0 TO L-VALID
    IF L-NUL = 1 OR (L-BLOCK = 1 AND L-RANGE = 1)
        MOVE 1 TO L-VALID
    END-IF
    GOBACK.
 END PROGRAM MN3-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-DEF-CHECK.
*> USING input count, indexes continuous, result index, has a result, code out (0 valid, 1 not continuous, 2 result index wrong, 3 inputs or result missing) (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-CONT                 BINARY-LONG.
 01 L-RES                  BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-CONT L-RES L-HAS L-CODE.
    MOVE 0 TO L-CODE
    EVALUATE TRUE
        WHEN L-N = 0 OR L-HAS = 0
            MOVE 3 TO L-CODE
        WHEN L-CONT = 0
            MOVE 1 TO L-CODE
        WHEN L-RES NOT = L-N
            MOVE 2 TO L-CODE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-DEF-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-LAYOUT.
*> USING kind, menu slot, part out (0 none, 1 own, 2 player), x out, y out (2.2, 3.1, 4.1, 5.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OWN BINARY-LONG.
 01 WS-KEY BINARY-LONG.
 01 WS-REL BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SLOT L-PART L-X L-Y.
    MOVE 0 TO L-PART L-X L-Y
    MOVE 3 TO WS-OWN
    IF L-KIND = 3
        MOVE 4 TO WS-OWN
    END-IF
    COMPUTE WS-KEY = L-KIND * 10 + L-SLOT
    EVALUATE TRUE
        WHEN L-SLOT >= 0 AND L-SLOT < WS-OWN
            MOVE 1 TO L-PART
            EVALUATE WS-KEY
                WHEN 10
                    MOVE 27 TO L-X
                    MOVE 47 TO L-Y
                WHEN 11
                    MOVE 76 TO L-X
                    MOVE 47 TO L-Y
                WHEN 12
                    MOVE 134 TO L-X
                    MOVE 47 TO L-Y
                WHEN 20
                    MOVE 49 TO L-X
                    MOVE 19 TO L-Y
                WHEN 21
                    MOVE 49 TO L-X
                    MOVE 40 TO L-Y
                WHEN 22
                    MOVE 129 TO L-X
                    MOVE 34 TO L-Y
                WHEN 30
                    MOVE 8 TO L-X
                    MOVE 48 TO L-Y
                WHEN 31
                    MOVE 26 TO L-X
                    MOVE 48 TO L-Y
                WHEN 32
                    MOVE 44 TO L-X
                    MOVE 48 TO L-Y
                WHEN 33
                    MOVE 98 TO L-X
                    MOVE 48 TO L-Y
            END-EVALUATE
        WHEN L-SLOT >= WS-OWN AND L-SLOT < WS-OWN + 36
            MOVE 2 TO L-PART
            COMPUTE WS-REL = L-SLOT - WS-OWN
            CALL "MN2-STD-INV" USING WS-REL L-X L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-RESULT-SLOT.
*> USING menu hook mayPickup, mayPlace out, mayPickup out (2.3): the combiner result slot.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOOK                 BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-PICKUP               BINARY-LONG.
 PROCEDURE DIVISION USING L-HOOK L-PLACE L-PICKUP.
    MOVE 0 TO L-PLACE
    MOVE L-HOOK TO L-PICKUP
    GOBACK.
 END PROGRAM MN3-RESULT-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SLOTS-CHANGED.
*> USING container (0 input container, 1 result container), createResult out (2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CONT                 BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-CONT L-CREATE.
    MOVE 0 TO L-CREATE
    IF L-CONT = 0
        MOVE 1 TO L-CREATE
    END-IF
    GOBACK.
 END PROGRAM MN3-SLOTS-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-COMBINER-QUICK.
*> USING result slot index R, source index, canMoveIntoInputSlots, branch out (0 none, 1 to 5), first out, end out, reverse out, onQuickCraft out (2.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I0 BINARY-LONG.
 01 WS-I1 BINARY-LONG.
 01 WS-H1 BINARY-LONG.
 LINKAGE SECTION.
 01 L-R                    BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-BRANCH               BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REV                  BINARY-LONG.
 01 L-ONQ                  BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-I L-CAN L-BRANCH L-FIRST L-END L-REV L-ONQ.
    MOVE 0 TO L-BRANCH L-FIRST L-END L-REV L-ONQ
    COMPUTE WS-I0 = L-R + 1
    COMPUTE WS-I1 = WS-I0 + 27
    COMPUTE WS-H1 = WS-I1 + 9
    EVALUATE TRUE
        WHEN L-I = L-R
            MOVE 1 TO L-BRANCH L-REV L-ONQ
            MOVE WS-I0 TO L-FIRST
            MOVE WS-H1 TO L-END
        WHEN L-I >= 0 AND L-I < L-R
            MOVE 2 TO L-BRANCH
            MOVE WS-I0 TO L-FIRST
            MOVE WS-H1 TO L-END
        WHEN L-I >= WS-I0 AND L-I < WS-H1 AND L-CAN = 1
            MOVE 3 TO L-BRANCH
            MOVE 0 TO L-FIRST
            MOVE L-R TO L-END
        WHEN L-I >= WS-I0 AND L-I < WS-I1
            MOVE 4 TO L-BRANCH
            MOVE WS-I1 TO L-FIRST
            MOVE WS-H1 TO L-END
        WHEN L-I >= WS-I1 AND L-I < WS-H1
            MOVE 5 TO L-BRANCH
            MOVE WS-I0 TO L-FIRST
            MOVE WS-I1 TO L-END
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-COMBINER-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-PATH.
*> USING left empty, right empty, left damageable, valid repair item, book added, same item, path out (0 exit A, 1 rename only, 2 repair with material, 3 exit C, 4 merge), durability merge out (3.3 steps 2 to 8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LE                   BINARY-LONG.
 01 L-RE                   BINARY-LONG.
 01 L-DAM                  BINARY-LONG.
 01 L-VAL                  BINARY-LONG.
 01 L-BOOK                 BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-PATH                 BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LE L-RE L-DAM L-VAL L-BOOK L-SAME L-PATH L-DUR.
    MOVE 0 TO L-DUR
    EVALUATE TRUE
        WHEN L-LE = 1
            MOVE 0 TO L-PATH
        WHEN L-RE = 1
            MOVE 1 TO L-PATH
        WHEN L-DAM = 1 AND L-VAL = 1
            MOVE 2 TO L-PATH
        WHEN L-BOOK = 0 AND (L-SAME = 0 OR L-DAM = 0)
            MOVE 3 TO L-PATH
        WHEN OTHER
            MOVE 4 TO L-PATH
            IF L-DAM = 1 AND L-BOOK = 0
                MOVE 1 TO L-DUR
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-ANVIL-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-REPAIR.
*> USING damage, max damage, right count, early exit B out, units used out, cost out, new damage out (3.3 step 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q4 BINARY-LONG.
 01 WS-STEP BINARY-LONG.
 01 WS-DAM BINARY-LONG.
 LINKAGE SECTION.
 01 L-DMG                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-CNT                  BINARY-LONG.
 01 L-EARLY                BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-NEWD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DMG L-MAX L-CNT L-EARLY L-USED L-COST L-NEWD.
    MOVE 0 TO L-EARLY L-USED L-COST
    MOVE L-DMG TO L-NEWD
    COMPUTE WS-Q4 = L-MAX / 4
    COMPUTE WS-STEP = FUNCTION MIN(L-DMG, WS-Q4)
    IF WS-STEP <= 0
        MOVE 1 TO L-EARLY
    ELSE
        MOVE L-DMG TO WS-DAM
        PERFORM UNTIL WS-STEP <= 0 OR L-USED >= L-CNT
            COMPUTE WS-DAM = FUNCTION MAX(WS-DAM - WS-STEP, 0)
            ADD 1 TO L-COST
            COMPUTE WS-STEP = FUNCTION MIN(WS-DAM, WS-Q4)
            ADD 1 TO L-USED
        END-PERFORM
        MOVE WS-DAM TO L-NEWD
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-REPAIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-DURABILITY.
*> USING max left, damage left, max right, damage right, new damage out, cost added out (3.3 step 8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T BINARY-DOUBLE.
 01 WS-REM BINARY-DOUBLE.
 01 WS-ND BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ML                   BINARY-LONG.
 01 L-DL                   BINARY-LONG.
 01 L-MR                   BINARY-LONG.
 01 L-DR                   BINARY-LONG.
 01 L-NEWD                 BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ML L-DL L-MR L-DR L-NEWD L-COST.
    COMPUTE WS-T = L-ML * 12 / 100
    COMPUTE WS-REM = L-ML - L-DL + L-MR - L-DR + WS-T
    COMPUTE WS-ND = FUNCTION MAX(L-ML - WS-REM, 0)
    MOVE L-DL TO L-NEWD
    MOVE 0 TO L-COST
    IF WS-ND < L-DL
        MOVE WS-ND TO L-NEWD
        MOVE 2 TO L-COST
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-DURABILITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-ENCH.
*> USING level in left, level in right, supported, creative, left is a book, incompatible count, max level, anvil cost, book added, left count, applied out, rejected out, stored level out, cost added out, assign 40 out (3.3 step 9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N BINARY-LONG.
 01 WS-CAN BINARY-LONG.
 01 WS-AC BINARY-LONG.
 LINKAGE SECTION.
 01 L-LL                   BINARY-LONG.
 01 L-LR                   BINARY-LONG.
 01 L-CAN0                 BINARY-LONG.
 01 L-INF                  BINARY-LONG.
 01 L-BOOK                 BINARY-LONG.
 01 L-INC                  BINARY-LONG.
 01 L-MX                   BINARY-LONG.
 01 L-AC                   BINARY-LONG.
 01 L-BADD                 BINARY-LONG.
 01 L-CNT                  BINARY-LONG.
 01 L-APPLIED              BINARY-LONG.
 01 L-REJECTED             BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-A40                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LL L-LR L-CAN0 L-INF L-BOOK L-INC L-MX L-AC L-BADD L-CNT L-APPLIED L-REJECTED L-LEVEL L-COST L-A40.
    MOVE 0 TO L-APPLIED L-REJECTED L-A40
    MOVE L-LL TO L-LEVEL
    MOVE L-INC TO L-COST
    IF L-LR = L-LL
        COMPUTE WS-N = L-LR + 1
    ELSE
        COMPUTE WS-N = FUNCTION MAX(L-LR, L-LL)
    END-IF
    MOVE 0 TO WS-CAN
    IF L-CAN0 = 1 OR L-INF = 1 OR L-BOOK = 1
        MOVE 1 TO WS-CAN
    END-IF
    IF L-INC > 0
        MOVE 0 TO WS-CAN
    END-IF
    IF WS-CAN = 0
        MOVE 1 TO L-REJECTED
    ELSE
        MOVE 1 TO L-APPLIED
        COMPUTE WS-N = FUNCTION MIN(WS-N, L-MX)
        IF WS-N <= 0
            MOVE 0 TO L-LEVEL
        ELSE
            COMPUTE L-LEVEL = FUNCTION MIN(WS-N, 255)
        END-IF
        MOVE L-AC TO WS-AC
        IF L-BADD = 1
            COMPUTE WS-AC = L-AC / 2
            IF WS-AC < 1
                MOVE 1 TO WS-AC
            END-IF
        END-IF
        COMPUTE L-COST = L-INC + WS-AC * WS-N
        IF L-CNT > 1
            MOVE 1 TO L-A40
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-ENCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-EXIT-D.
*> USING any enchantment rejected, any applied, exit out (3.3 step 10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REJ                  BINARY-LONG.
 01 L-APP                  BINARY-LONG.
 01 L-EXIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-REJ L-APP L-EXIT.
    MOVE 0 TO L-EXIT
    IF L-REJ = 1 AND L-APP = 0
        MOVE 1 TO L-EXIT
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-EXIT-D.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-RENAME.
*> USING name is null or blank, left has custom_name, name differs from the hover name, rename cost out, cost added out, action out (0 none, 1 remove custom_name, 2 set custom_name) (3.3 step 11).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLANK                BINARY-LONG.
 01 L-CUST                 BINARY-LONG.
 01 L-DIFF                 BINARY-LONG.
 01 L-RC                   BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-ACT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BLANK L-CUST L-DIFF L-RC L-COST L-ACT.
    MOVE 0 TO L-RC L-COST L-ACT
    IF L-BLANK = 1
        IF L-CUST = 1
            MOVE 1 TO L-RC L-COST L-ACT
        END-IF
    ELSE
        IF L-DIFF = 1
            MOVE 1 TO L-RC L-COST
            MOVE 2 TO L-ACT
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-RENAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-TOTAL.
*> USING base (prior work), cost, rename cost, creative, data slot out, result empty out, only renaming out (3.3 steps 12 to 15).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-RC                   BINARY-LONG.
 01 L-INF                  BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-ONLY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-COST L-RC L-INF L-DATA L-EMPTY L-ONLY.
    MOVE 0 TO L-DATA L-ONLY L-EMPTY
    IF L-COST <= 0
        MOVE 1 TO L-EMPTY
    ELSE
        COMPUTE WS-T = L-BASE + L-COST
        COMPUTE WS-T = FUNCTION MAX(0, FUNCTION MIN(WS-T, 2147483647))
        MOVE WS-T TO L-DATA
    END-IF
    IF L-RC = L-COST AND L-RC > 0
        IF L-DATA >= 40
            MOVE 39 TO L-DATA
        END-IF
        MOVE 1 TO L-ONLY
    END-IF
    IF L-DATA >= 40 AND L-INF = 0
        MOVE 1 TO L-EMPTY
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-TOTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-NEWREPAIR.
*> USING repair cost of the result, repair cost of the right, rename cost, cost, new repair cost out (3.3 step 16).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RC BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-RC                   BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-RC L-COST L-OUT.
    MOVE L-A TO WS-RC
    IF WS-RC < L-B
        MOVE L-B TO WS-RC
    END-IF
    IF NOT (L-RC = L-COST AND L-RC NOT = 0)
        COMPUTE WS-RC = FUNCTION MIN(2 * WS-RC + 1, 2147483647)
    END-IF
    MOVE WS-RC TO L-OUT
    GOBACK.
 END PROGRAM MN3-ANVIL-NEWREPAIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-PICKUP.
*> USING creative, player level, cost data slot, ok out (3.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INF                  BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-INF L-LEVEL L-COST L-OK.
    MOVE 0 TO L-OK
    IF (L-INF = 1 OR L-LEVEL >= L-COST) AND L-COST > 0
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-TAKE.
*> USING creative, cost, player level, repair units, right count, only renaming, new level out, right action out (0 keep, 1 shrink, 2 empty), new right count out (3.5 steps 1, 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LV BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-INF                  BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 01 L-LV                   BINARY-LONG.
 01 L-RU                   BINARY-LONG.
 01 L-RC                   BINARY-LONG.
 01 L-ONLY                 BINARY-LONG.
 01 L-NLV                  BINARY-LONG.
 01 L-ACT                  BINARY-LONG.
 01 L-NRC                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INF L-COST L-LV L-RU L-RC L-ONLY L-NLV L-ACT L-NRC.
    MOVE L-LV TO WS-LV
    IF L-INF = 0
        COMPUTE WS-LV = L-LV - L-COST
        IF WS-LV > 2147483647
            MOVE 2147483647 TO WS-LV
        END-IF
        IF WS-LV < 0
            MOVE 0 TO WS-LV
        END-IF
    END-IF
    MOVE WS-LV TO L-NLV
    MOVE 0 TO L-ACT
    MOVE L-RC TO L-NRC
    IF L-RU > 0
        IF L-RC > L-RU
            MOVE 1 TO L-ACT
            COMPUTE L-NRC = L-RC - L-RU
        ELSE
            MOVE 2 TO L-ACT
            MOVE 0 TO L-NRC
        END-IF
    ELSE
        IF L-ONLY = 0
            MOVE 2 TO L-ACT
            MOVE 0 TO L-NRC
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-DAMAGE.
*> USING creative, block is in the tag anvil, the random float, block state (0 anvil, 1 chipped, 2 damaged), drawn out, new state out (0 same, 1 chipped, 2 damaged, 3 removed), level event out (3.5 step 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT FLOAT-LONG VALUE 0.12.
 LINKAGE SECTION.
 01 L-INF                  BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-ROLL                 FLOAT-LONG.
 01 L-ST                   BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 01 L-NEWST                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-INF L-TAG L-ROLL L-ST L-DRAWN L-NEWST L-EVENT.
    MOVE 0 TO L-DRAWN L-NEWST
    MOVE 1030 TO L-EVENT
    IF L-INF = 0 AND L-TAG = 1
        MOVE 1 TO L-DRAWN
        IF L-ROLL < WS-LIMIT
            COMPUTE L-NEWST = L-ST + 1
            IF L-ST = 2
                MOVE 3 TO L-NEWST
                MOVE 1029 TO L-EVENT
            END-IF
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-NAME-CHAR.
*> USING character code, keep out (3.7): a character is kept unless it is 167, below 32 or 127.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CP                   BINARY-LONG.
 01 L-KEEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CP L-KEEP.
    MOVE 1 TO L-KEEP
    IF L-CP = 167 OR L-CP < 32 OR L-CP = 127
        MOVE 0 TO L-KEEP
    END-IF
    GOBACK.
 END PROGRAM MN3-NAME-CHAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-BLANK-CHAR.
*> USING character code, blank out (3.7): whitespace (9 to 13, 28 to 32) or a space separator (160, 5760, 8192 to 8202, 8232, 8233, 8239, 8287, 12288).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CP                   BINARY-LONG.
 01 L-BLANK                BINARY-LONG.
 PROCEDURE DIVISION USING L-CP L-BLANK.
    MOVE 0 TO L-BLANK
    IF (L-CP >= 9 AND L-CP <= 13) OR (L-CP >= 28 AND L-CP <= 32) OR L-CP = 160 OR L-CP = 5760
       OR (L-CP >= 8192 AND L-CP <= 8202) OR L-CP = 8232 OR L-CP = 8233 OR L-CP = 8239
       OR L-CP = 8287 OR L-CP = 12288
        MOVE 1 TO L-BLANK
    END-IF
    GOBACK.
 END PROGRAM MN3-BLANK-CHAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-NAME-SET.
*> USING length after the filter, equals the current name, result slot has an item, new name blank, accepted out, edit out (0 none, 1 remove custom_name, 2 set it) (3.7 setItemName).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEN                  BINARY-LONG.
 01 L-EQ                   BINARY-LONG.
 01 L-RH                   BINARY-LONG.
 01 L-BLANK                BINARY-LONG.
 01 L-ACC                  BINARY-LONG.
 01 L-EDIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LEN L-EQ L-RH L-BLANK L-ACC L-EDIT.
    MOVE 0 TO L-ACC L-EDIT
    IF L-LEN <= 50 AND L-EQ = 0
        MOVE 1 TO L-ACC
        IF L-RH = 1
            MOVE 2 TO L-EDIT
            IF L-BLANK = 1
                MOVE 1 TO L-EDIT
            END-IF
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-NAME-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-NAMECHG.
*> USING slot 0 has an item, it has a custom_name, the text equals the hover name, setItemName returned true, proceed out, use the empty name out, send Rename Item out (3.8 onNameChanged).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-CUST                 BINARY-LONG.
 01 L-EQ                   BINARY-LONG.
 01 L-ACC                  BINARY-LONG.
 01 L-GO                   BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-CUST L-EQ L-ACC L-GO L-EMPTY L-SEND.
    MOVE 0 TO L-GO L-EMPTY L-SEND
    IF L-HAS = 1
        MOVE 1 TO L-GO
        IF L-CUST = 0 AND L-EQ = 1
            MOVE 1 TO L-EMPTY
        END-IF
        MOVE L-ACC TO L-SEND
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-NAMECHG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-SLOT-CHANGED.
*> USING slot, stack is empty, applies out, value is the hover name out, editable out, focus out (3.8 slotChanged).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-APPLIES              BINARY-LONG.
 01 L-HOVER                BINARY-LONG.
 01 L-EDIT                 BINARY-LONG.
 01 L-FOCUS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-EMPTY L-APPLIES L-HOVER L-EDIT L-FOCUS.
    MOVE 0 TO L-APPLIES L-HOVER L-EDIT L-FOCUS
    IF L-SLOT = 0
        MOVE 1 TO L-APPLIES L-FOCUS
        IF L-EMPTY = 0
            MOVE 1 TO L-HOVER L-EDIT
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-SLOT-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-SCREEN.
*> USING leftPos, topPos, slot 0 has an item, slot 1 has an item, result has an item, field x out, field y out, field sprite x out, field sprite y out, disabled sprite out, error x out, error y out, show error out, title label x out (3.8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-H0                   BINARY-LONG.
 01 L-H1                   BINARY-LONG.
 01 L-RH                   BINARY-LONG.
 01 L-FX                   BINARY-LONG.
 01 L-FY                   BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-DIS                  BINARY-LONG.
 01 L-EX                   BINARY-LONG.
 01 L-EY                   BINARY-LONG.
 01 L-SHOW                 BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-TOP L-H0 L-H1 L-RH L-FX L-FY L-BX L-BY L-DIS L-EX L-EY L-SHOW L-TX.
    COMPUTE L-FX = L-LEFT + 62
    COMPUTE L-FY = L-TOP + 24
    COMPUTE L-BX = L-LEFT + 59
    COMPUTE L-BY = L-TOP + 20
    MOVE 1 TO L-DIS
    IF L-H0 = 1
        MOVE 0 TO L-DIS
    END-IF
    COMPUTE L-EX = L-LEFT + 99
    COMPUTE L-EY = L-TOP + 45
    MOVE 0 TO L-SHOW
    IF (L-H0 = 1 OR L-H1 = 1) AND L-RH = 0
        MOVE 1 TO L-SHOW
    END-IF
    MOVE 60 TO L-TX
    GOBACK.
 END PROGRAM MN3-ANVIL-SCREEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-LABEL.
*> USING cost data slot, creative, result has an item, mayPickup, text width, kind out (0 nothing, 1 Too Expensive, 2 cost), colour out, box x0 out, box y0 out, box x1 out, box y1 out, text x out, text y out (3.8 cost label).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-INF                  BINARY-LONG.
 01 L-RH                   BINARY-LONG.
 01 L-MP                   BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-INF L-RH L-MP L-W L-KIND L-COL L-X0 L-Y0 L-X1 L-Y1 L-TX L-TY.
    MOVE 0 TO L-KIND L-COL L-X0 L-Y0 L-X1 L-Y1 L-TX L-TY
    IF L-C > 0
        EVALUATE TRUE
            WHEN L-C >= 40 AND L-INF = 0
                MOVE 1 TO L-KIND
                MOVE -40864 TO L-COL
            WHEN L-RH = 1
                MOVE 2 TO L-KIND
                MOVE -8323296 TO L-COL
                IF L-MP = 0
                    MOVE -40864 TO L-COL
                END-IF
        END-EVALUATE
        IF L-KIND > 0
            COMPUTE L-TX = 166 - L-W
            COMPUTE L-X0 = L-TX - 2
            MOVE 67 TO L-Y0
            MOVE 168 TO L-X1
            MOVE 79 TO L-Y1
            MOVE 69 TO L-TY
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-ANVIL-LABEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ANVIL-KEY.
*> USING key is Escape, the name field handled it, the field can consume input, action out (1 close the container, 2 consumed, 3 generic handling) (3.8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ESC                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-ACT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ESC L-HANDLED L-CAN L-ACT.
    MOVE 3 TO L-ACT
    EVALUATE TRUE
        WHEN L-ESC = 1
            MOVE 1 TO L-ACT
        WHEN L-HANDLED = 1 OR L-CAN = 1
            MOVE 2 TO L-ACT
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-ANVIL-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-GRIND-MAYPLACE.
*> USING damageable, has any enchantments, ok out (4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DAM                  BINARY-LONG.
 01 L-ENCH                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DAM L-ENCH L-OK.
    MOVE 0 TO L-OK
    IF L-DAM = 1 OR L-ENCH = 1
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN3-GRIND-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-GRIND-COMPUTE.
*> USING left empty, right empty, left count, right count, the single item has enchantments, same item, outcome out (0 empty, 1 stripped copy of the single item, 2 mergeItems) (4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AE                   BINARY-LONG.
 01 L-BE                   BINARY-LONG.
 01 L-AC                   BINARY-LONG.
 01 L-BC                   BINARY-LONG.
 01 L-SEN                  BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AE L-BE L-AC L-BC L-SEN L-SAME L-OUT.
    MOVE 0 TO L-OUT
    IF NOT (L-AE = 1 AND L-BE = 1) AND L-AC <= 1 AND L-BC <= 1
        IF L-AE = 0 AND L-BE = 0
            IF L-SAME = 1
                MOVE 2 TO L-OUT
            END-IF
        ELSE
            IF L-SEN = 1
                MOVE 1 TO L-OUT
            END-IF
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-GRIND-COMPUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-GRIND-MERGE.
*> USING max damage a, damage a, max damage b, damage b, a is damageable, max stack size, stacks match, ok out, count out, max damage out, damage out (4.3 mergeItems).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M BINARY-LONG.
 01 WS-T BINARY-LONG.
 01 WS-REM BINARY-LONG.
 LINKAGE SECTION.
 01 L-MA                   BINARY-LONG.
 01 L-DA                   BINARY-LONG.
 01 L-MB                   BINARY-LONG.
 01 L-DB                   BINARY-LONG.
 01 L-DAM                  BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 01 L-MT                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-CNT                  BINARY-LONG.
 01 L-MAXD                 BINARY-LONG.
 01 L-DMG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MA L-DA L-MB L-DB L-DAM L-MS L-MT L-OK L-CNT L-MAXD L-DMG.
    MOVE 1 TO L-OK
    MOVE 1 TO L-CNT
    MOVE 0 TO L-MAXD L-DMG
    COMPUTE WS-M = FUNCTION MAX(L-MA, L-MB)
    COMPUTE WS-T = WS-M * 5 / 100
    COMPUTE WS-REM = L-MA - L-DA + L-MB - L-DB + WS-T
    IF L-DAM = 1
        MOVE WS-M TO L-MAXD
        COMPUTE L-DMG = FUNCTION MAX(WS-M - WS-REM, 0)
    ELSE
        IF L-MS < 2 OR L-MT = 0
            MOVE 0 TO L-OK L-CNT
        ELSE
            MOVE 2 TO L-CNT
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-GRIND-MERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-GRIND-MERGE-ENCH.
*> USING enchantment is a curse, level in the result, level in the second item, applied out, new level out (4.3 mergeEnchants).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CURSE                BINARY-LONG.
 01 L-RL                   BINARY-LONG.
 01 L-LV                   BINARY-LONG.
 01 L-APP                  BINARY-LONG.
 01 L-NL                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CURSE L-RL L-LV L-APP L-NL.
    MOVE L-RL TO L-NL
    MOVE 0 TO L-APP
    IF L-CURSE = 0 OR L-RL = 0
        MOVE 1 TO L-APP
        IF L-LV > 0
            COMPUTE L-NL = FUNCTION MAX(L-RL, FUNCTION MIN(L-LV, 255))
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-GRIND-MERGE-ENCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-GRIND-REMOVE.
*> USING is an enchanted book, remaining curses, becomes a book out, repair cost out (4.3 removeNonCurses).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOOK                 BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-BECOMES              BINARY-LONG.
 01 L-RC                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BOOK L-K L-BECOMES L-RC.
    MOVE 0 TO L-BECOMES L-RC
    IF L-BOOK = 1 AND L-K = 0
        MOVE 1 TO L-BECOMES
    END-IF
    PERFORM L-K TIMES
        COMPUTE L-RC = 2 * L-RC + 1
    END-PERFORM
    GOBACK.
 END PROGRAM MN3-GRIND-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-GRIND-MINCOST.
*> USING minCost.base, per_level_above_first, level, minimum cost out (4.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-PER                  BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-PER L-LEVEL L-OUT.
    COMPUTE L-OUT = L-BASE + L-PER * (L-LEVEL - 1)
    GOBACK.
 END PROGRAM MN3-GRIND-MINCOST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-GRIND-XP.
*> USING sum of minimum costs T, the nextInt(h) draw, h out, experience out, draws out (4.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-XP                   BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-DRAW L-H L-XP L-DRAWS.
    MOVE 0 TO L-H L-XP L-DRAWS
    IF L-T > 0
        COMPUTE L-H = (L-T + 1) / 2
        COMPUTE L-XP = L-H + L-DRAW
        MOVE 1 TO L-DRAWS
    END-IF
    GOBACK.
 END PROGRAM MN3-GRIND-XP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-GRIND-QUICK.
*> USING source slot, slot 0 empty, slot 1 empty, branch out (0 none, 1 to 5), first out, end out, reverse out, onQuickCraft out (4.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-E0                   BINARY-LONG.
 01 L-E1                   BINARY-LONG.
 01 L-BRANCH               BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REV                  BINARY-LONG.
 01 L-ONQ                  BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-E0 L-E1 L-BRANCH L-FIRST L-END L-REV L-ONQ.
    MOVE 0 TO L-BRANCH L-FIRST L-END L-REV L-ONQ
    EVALUATE TRUE
        WHEN L-I = 2
            MOVE 1 TO L-BRANCH L-REV L-ONQ
            MOVE 3 TO L-FIRST
            MOVE 39 TO L-END
        WHEN L-I = 0 OR L-I = 1
            MOVE 2 TO L-BRANCH
            MOVE 3 TO L-FIRST
            MOVE 39 TO L-END
        WHEN L-I >= 3 AND (L-E0 = 1 OR L-E1 = 1)
            MOVE 3 TO L-BRANCH
            MOVE 0 TO L-FIRST
            MOVE 2 TO L-END
        WHEN L-I >= 3 AND L-I < 30
            MOVE 4 TO L-BRANCH
            MOVE 30 TO L-FIRST
            MOVE 39 TO L-END
        WHEN L-I >= 30 AND L-I < 39
            MOVE 5 TO L-BRANCH
            MOVE 3 TO L-FIRST
            MOVE 30 TO L-END
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-GRIND-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-GRIND-ERROR.
*> USING leftPos, topPos, slot 0 has an item, slot 1 has an item, result has an item, x out, y out, show out (4.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-H0                   BINARY-LONG.
 01 L-H1                   BINARY-LONG.
 01 L-RH                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-SHOW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-TOP L-H0 L-H1 L-RH L-X L-Y L-SHOW.
    COMPUTE L-X = L-LEFT + 92
    COMPUTE L-Y = L-TOP + 31
    MOVE 0 TO L-SHOW
    IF (L-H0 = 1 OR L-H1 = 1) AND L-RH = 0
        MOVE 1 TO L-SHOW
    END-IF
    GOBACK.
 END PROGRAM MN3-GRIND-ERROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-MAYPLACE.
*> USING slot, item in the smithing_template set, in smithing_base, in smithing_addition, ok out (5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-T L-B L-A L-OK.
    MOVE 1 TO L-OK
    EVALUATE L-SLOT
        WHEN 0
            MOVE L-T TO L-OK
        WHEN 1
            MOVE L-B TO L-OK
        WHEN 2
            MOVE L-A TO L-OK
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-SMITH-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-FLAG.
*> USING server level, slot 0, 1 and 2 have items, result has an item, old flag, flag out (5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-H0                   BINARY-LONG.
 01 L-H1                   BINARY-LONG.
 01 L-H2                   BINARY-LONG.
 01 L-RH                   BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-H0 L-H1 L-H2 L-RH L-OLD L-FLAG.
    MOVE L-OLD TO L-FLAG
    IF L-SERVER = 1
        MOVE 0 TO L-FLAG
        IF L-H0 = 1 AND L-H1 = 1 AND L-H2 = 1 AND L-RH = 0
            MOVE 1 TO L-FLAG
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-SMITH-FLAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-CREATE.
*> USING server level, a recipe matched, the assemble result is empty, recipe used out, result stored out (5.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-AEMPTY               BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-FOUND L-AEMPTY L-USED L-STORED.
    MOVE 0 TO L-USED L-STORED
    IF L-SERVER = 1 AND L-FOUND = 1
        MOVE 1 TO L-USED L-STORED
        IF L-AEMPTY = 1
            MOVE 0 TO L-STORED
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-SMITH-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-TAKE.
*> USING count of slot 0, 1, 2, new counts out (3), level event out (5.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C0                   BINARY-LONG.
 01 L-C1                   BINARY-LONG.
 01 L-C2                   BINARY-LONG.
 01 L-N0                   BINARY-LONG.
 01 L-N1                   BINARY-LONG.
 01 L-N2                   BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-C0 L-C1 L-C2 L-N0 L-N1 L-N2 L-EVENT.
    COMPUTE L-N0 = FUNCTION MAX(L-C0 - 1, 0)
    COMPUTE L-N1 = FUNCTION MAX(L-C1 - 1, 0)
    COMPUTE L-N2 = FUNCTION MAX(L-C2 - 1, 0)
    MOVE 1044 TO L-EVENT
    GOBACK.
 END PROGRAM MN3-SMITH-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-CANMOVE.
*> USING template set accepts, base set accepts, addition set accepts, slot 0 empty, slot 1 empty, slot 2 empty, ok out (5.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-E0                   BINARY-LONG.
 01 L-E1                   BINARY-LONG.
 01 L-E2                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-B L-A L-E0 L-E1 L-E2 L-OK.
    MOVE 0 TO L-OK
    IF (L-T = 1 AND L-E0 = 1) OR (L-B = 1 AND L-E1 = 1) OR (L-A = 1 AND L-E2 = 1)
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN3-SMITH-CANMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-PICKALL.
*> USING slot, canTakeItemForPickAll out (5.4): false only for the result slot 3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-OK.
    MOVE 1 TO L-OK
    IF L-SLOT = 3
        MOVE 0 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN3-SMITH-PICKALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-CYCLE-TICK.
*> USING list equals the current list, list size, tick counter, icon index, new tick out, new icon index out (5.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EQ                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 01 L-NTICK                BINARY-LONG.
 01 L-NIDX                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EQ L-SZ L-TICK L-IDX L-NTICK L-NIDX.
    MOVE L-TICK TO L-NTICK
    MOVE L-IDX TO L-NIDX
    IF L-EQ = 0
        MOVE 0 TO L-NIDX
    END-IF
    IF L-SZ > 0
        ADD 1 TO L-NTICK
        IF FUNCTION MOD(L-NTICK, 30) = 0
            COMPUTE L-NIDX = FUNCTION MOD(L-NIDX + 1, L-SZ)
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-CYCLE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-CYCLE-DRAW.
*> USING list size, tick, icon index, partial tick, slot has an item, draw out, transitioning out, alpha x 1e6 out, previous drawn out, previous index out, previous alpha x 1e6 out (5.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AL FLOAT-LONG.
 01 WS-T FLOAT-LONG.
 01 WS-M BINARY-LONG.
 LINKAGE SECTION.
 01 L-SZ                   BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 01 L-PT                   FLOAT-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-TR                   BINARY-LONG.
 01 L-ALPHA                BINARY-LONG.
 01 L-PDRAW                BINARY-LONG.
 01 L-PIDX                 BINARY-LONG.
 01 L-PALPHA               BINARY-LONG.
 PROCEDURE DIVISION USING L-SZ L-TICK L-IDX L-PT L-HAS L-DRAW L-TR L-ALPHA L-PDRAW L-PIDX L-PALPHA.
    MOVE 0 TO L-DRAW L-TR L-ALPHA L-PDRAW L-PIDX L-PALPHA
    IF L-SZ > 0 AND L-HAS = 0
        MOVE 1 TO L-DRAW
        MOVE 1 TO WS-AL
        IF L-SZ > 1 AND L-TICK >= 30
            MOVE 1 TO L-TR
            COMPUTE WS-T = FUNCTION MOD(L-TICK, 30) + L-PT
            IF WS-T > 4
                MOVE 4 TO WS-T
            END-IF
            COMPUTE WS-AL = WS-T / 4
        END-IF
        COMPUTE L-ALPHA ROUNDED = WS-AL * 1000000
        IF WS-AL < 1
            MOVE 1 TO L-PDRAW
            COMPUTE WS-M = L-IDX - 1
            COMPUTE L-PIDX = FUNCTION MOD(WS-M, L-SZ)
            COMPUTE L-PALPHA ROUNDED = (1 - WS-AL) * 1000000
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-CYCLE-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ICON-COUNT.
*> USING template kind (0 none, 1 armor trim, 2 netherite upgrade), slot (1 base, 2 addition), icon count out (5.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SLOT L-COUNT.
    MOVE 0 TO L-COUNT
    COMPUTE WS-KEY = L-KIND * 10 + L-SLOT
    EVALUATE WS-KEY
        WHEN 11
            MOVE 4 TO L-COUNT
        WHEN 12
            MOVE 7 TO L-COUNT
        WHEN 21
            MOVE 11 TO L-COUNT
        WHEN 22
            MOVE 1 TO L-COUNT
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-ICON-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-ICON-NAME.
*> USING template kind (1 armor trim, 2 netherite upgrade), slot (1 base, 2 addition), position from 1, sprite out, plain name out (5.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
 05 FILLER PIC X(16) VALUE "helmet          ".
 05 FILLER PIC X(16) VALUE "chestplate      ".
 05 FILLER PIC X(16) VALUE "leggings        ".
 05 FILLER PIC X(16) VALUE "boots           ".
 05 FILLER PIC X(16) VALUE "ingot           ".
 05 FILLER PIC X(16) VALUE "redstone_dust   ".
 05 FILLER PIC X(16) VALUE "lapis_lazuli    ".
 05 FILLER PIC X(16) VALUE "quartz          ".
 05 FILLER PIC X(16) VALUE "diamond         ".
 05 FILLER PIC X(16) VALUE "emerald         ".
 05 FILLER PIC X(16) VALUE "amethyst_shard  ".
 05 FILLER PIC X(16) VALUE "helmet          ".
 05 FILLER PIC X(16) VALUE "sword           ".
 05 FILLER PIC X(16) VALUE "chestplate      ".
 05 FILLER PIC X(16) VALUE "pickaxe         ".
 05 FILLER PIC X(16) VALUE "leggings        ".
 05 FILLER PIC X(16) VALUE "axe             ".
 05 FILLER PIC X(16) VALUE "boots           ".
 05 FILLER PIC X(16) VALUE "hoe             ".
 05 FILLER PIC X(16) VALUE "shovel          ".
 05 FILLER PIC X(16) VALUE "nautilus_armor  ".
 05 FILLER PIC X(16) VALUE "spear           ".
 05 FILLER PIC X(16) VALUE "ingot           ".
 01 FILLER REDEFINES WS-NAMES.
    05 WS-NAME PIC X(16) OCCURS 23 TIMES.
 01 WS-KEY BINARY-LONG.
 01 WS-IX BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-SLOT L-POS L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    MOVE 1 TO WS-IX
    COMPUTE WS-KEY = L-KIND * 10 + L-SLOT
    EVALUATE WS-KEY
        WHEN 12
            MOVE 5 TO WS-IX
        WHEN 21
            MOVE 12 TO WS-IX
        WHEN 22
            MOVE 23 TO WS-IX
    END-EVALUATE
    COMPUTE WS-IX = WS-IX + L-POS - 1
    MOVE FUNCTION TRIM(WS-NAME(WS-IX)) TO L-T2
    STRING "container/slot/" DELIMITED BY SIZE FUNCTION TRIM(WS-NAME(WS-IX)) DELIMITED BY SIZE INTO L-T1
    GOBACK.
 END PROGRAM MN3-ICON-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-TEMPLATE-ICON.
*> USING position 1 or 2, sprite out, plain name out (5.6): the two template icons of slot 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POS                  BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-POS L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    IF L-POS = 1
        MOVE "container/slot/smithing_template_armor_trim" TO L-T1
        MOVE "armor_trim" TO L-T2
    ELSE
        MOVE "container/slot/smithing_template_netherite_upgrade" TO L-T1
        MOVE "netherite_upgrade" TO L-T2
    END-IF
    GOBACK.
 END PROGRAM MN3-TEMPLATE-ICON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-TOOLTIP.
*> USING error flag, pointer in the 28 x 21 box, hovered slot or -1, slot 0 empty, slot 0 is a template, hovered stack empty, code out (0 none, 1 error, 2 missing template, 3 base description, 4 addition description) (5.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ERR                  BINARY-LONG.
 01 L-PTR                  BINARY-LONG.
 01 L-HV                   BINARY-LONG.
 01 L-T0E                  BINARY-LONG.
 01 L-T0T                  BINARY-LONG.
 01 L-HE                   BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ERR L-PTR L-HV L-T0E L-T0T L-HE L-CODE.
    MOVE 0 TO L-CODE
    IF L-ERR = 1 AND L-PTR = 1
        MOVE 1 TO L-CODE
    END-IF
    IF L-HV >= 0
        IF L-T0E = 1
            IF L-HV = 0
                MOVE 2 TO L-CODE
            END-IF
        ELSE
            IF L-T0T = 1 AND L-HE = 1
                EVALUATE L-HV
                    WHEN 1
                        MOVE 3 TO L-CODE
                    WHEN 2
                        MOVE 4 TO L-CODE
                END-EVALUATE
            END-IF
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-SMITH-TOOLTIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-TOOLTIP-TEXT.
*> USING tooltip code, template kind, language key out, English text out (5.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY BINARY-LONG.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-CODE L-KIND L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    COMPUTE WS-KEY = L-CODE * 10 + L-KIND
    EVALUATE WS-KEY
        WHEN 11
            MOVE "container.upgrade.error_tooltip" TO L-T1
            MOVE "Item can't be upgraded this way" TO L-T2
        WHEN 21
            MOVE "container.upgrade.missing_template_tooltip" TO L-T1
            MOVE "Add Smithing Template" TO L-T2
        WHEN 31
            MOVE "item.minecraft.smithing_template.armor_trim.base_slot_description" TO L-T1
            MOVE "Add a piece of armor" TO L-T2
        WHEN 41
            MOVE "item.minecraft.smithing_template.armor_trim.additions_slot_description" TO L-T1
            MOVE "Add ingot or crystal" TO L-T2
        WHEN 32
            MOVE "item.minecraft.smithing_template.netherite_upgrade.base_slot_description" TO L-T1
            MOVE "Add diamond armor, weapon, or tool" TO L-T2
        WHEN 42
            MOVE "item.minecraft.smithing_template.netherite_upgrade.additions_slot_description" TO L-T1
            MOVE "Add Netherite Ingot" TO L-T2
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-TOOLTIP-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-PREVIEW.
*> USING has an equippable component, its slot (1 head, 2 chest, 3 legs, 4 feet, 5 other), the head item passes shouldRender, result is empty, target out (0 cleared, 1 head equipment, 2 head item model, 3 chest, 4 legs, 5 feet, 6 left hand) (5.8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HE                   BINARY-LONG.
 01 L-SL                   BINARY-LONG.
 01 L-SR                   BINARY-LONG.
 01 L-RE                   BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-HE L-SL L-SR L-RE L-TARGET.
    EVALUATE TRUE
        WHEN L-RE = 1
            MOVE 0 TO L-TARGET
        WHEN L-HE = 0
            MOVE 6 TO L-TARGET
        WHEN L-SL = 1 AND L-SR = 1
            MOVE 1 TO L-TARGET
        WHEN L-SL = 1
            MOVE 2 TO L-TARGET
        WHEN L-SL = 2
            MOVE 3 TO L-TARGET
        WHEN L-SL = 3
            MOVE 4 TO L-TARGET
        WHEN L-SL = 4
            MOVE 5 TO L-TARGET
        WHEN OTHER
            MOVE 6 TO L-TARGET
    END-EVALUATE
    GOBACK.
 END PROGRAM MN3-PREVIEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-SLOT-CHANGED.
*> USING slot, update the preview out (5.8): from slotChanged when slot 3 changes.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-UPD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-UPD.
    MOVE 0 TO L-UPD
    IF L-SLOT = 3
        MOVE 1 TO L-UPD
    END-IF
    GOBACK.
 END PROGRAM MN3-SMITH-SLOT-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-SCREEN.
*> USING leftPos, topPos, error x out, error y out, preview box x0 out, y0 out, x1 out, y1 out, title x out, title y out (5.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-EX                   BINARY-LONG.
 01 L-EY                   BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-TOP L-EX L-EY L-X0 L-Y0 L-X1 L-Y1 L-TX L-TY.
    COMPUTE L-EX = L-LEFT + 65
    COMPUTE L-EY = L-TOP + 46
    COMPUTE L-X0 = L-LEFT + 121
    COMPUTE L-Y0 = L-TOP + 20
    COMPUTE L-X1 = L-LEFT + 161
    COMPUTE L-Y1 = L-TOP + 80
    MOVE 44 TO L-TX
    MOVE 15 TO L-TY
    GOBACK.
 END PROGRAM MN3-SMITH-SCREEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-SMITH-FIRST.
*> USING match flags of the loaded smithing recipes 1 to 8, index of the first match or 0 out (6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MS.
    05 WS-M BINARY-LONG OCCURS 8 TIMES.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-M1                   BINARY-LONG.
 01 L-M2                   BINARY-LONG.
 01 L-M3                   BINARY-LONG.
 01 L-M4                   BINARY-LONG.
 01 L-M5                   BINARY-LONG.
 01 L-M6                   BINARY-LONG.
 01 L-M7                   BINARY-LONG.
 01 L-M8                   BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-M1 L-M2 L-M3 L-M4 L-M5 L-M6 L-M7 L-M8 L-IDX.
    MOVE L-M1 TO WS-M(1)
    MOVE L-M2 TO WS-M(2)
    MOVE L-M3 TO WS-M(3)
    MOVE L-M4 TO WS-M(4)
    MOVE L-M5 TO WS-M(5)
    MOVE L-M6 TO WS-M(6)
    MOVE L-M7 TO WS-M(7)
    MOVE L-M8 TO WS-M(8)
    MOVE 0 TO L-IDX
    PERFORM VARYING WS-I FROM 8 BY -1 UNTIL WS-I < 1
        IF WS-M(WS-I) = 1
            MOVE WS-I TO L-IDX
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN3-SMITH-FIRST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN3-INGREDIENT-OK.
*> USING ingredient is absent, the slot is empty, the item matches, ok out (5.3, 6): an absent ingredient needs an empty slot.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ABSENT               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-MATCH                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ABSENT L-EMPTY L-MATCH L-OK.
    MOVE 0 TO L-OK
    IF L-ABSENT = 1
        MOVE L-EMPTY TO L-OK
    ELSE
        IF L-EMPTY = 0 AND L-MATCH = 1
            MOVE 1 TO L-OK
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN3-INGREDIENT-OK.
