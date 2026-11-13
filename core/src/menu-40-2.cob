*> Menus, part 2: the furnace family screens, the brewing stand and its screen, the crafter and its screen, and the packet summary
*> (docs/protocol/40-menus-2-furnaces-brewing-crafter.md sections 3 to 8; US12 phase 44). Programs of plain numbers (MN2- prefix): each takes the facts the
*> caller read (data slot values, flags, positions) and returns the decision or the pixel arithmetic of the section. Divisions of the doc's float formulas
*> (litProgress, burnProgress, the brewing arrow) are done on exact integers: ceil(p x 24 / t) instead of ceil((p / t) x 24). The live window of a player
*> (menus.cob, menu-container.cob) is not changed by this file. Flags are 0 or 1. Furnace kinds 1 furnace, 2 blast furnace, 3 smoker. Part kinds of
*> section 8: 1 crafter, 2 blast furnace, 3 brewing stand, 4 furnace, 5 smoker.
*>
*>   MN2-FRAME USING screen w, screen h, title width, leftPos out, topPos out, title x out, title y out, inventory label y out            1.1, 3.1
*>   MN2-STD-INV USING relative index 0 to 35, x out, y out                                                                              1.2
*>   MN2-QUICK-TAIL USING count after, count before, cleared out, returned out, onTake out; MN2-QUICK-LOOP USING returned, same item, again   1.3
*>   MN2-FURNACE-BUTTON, MN2-FLAME, MN2-ARROW, MN2-FURNACE-TEXTURE, -SPRITES, -TABS                                                      3
*>   MN2-BREW-SLOT, -MAYPLACE, -ROUTE, -FALLBACK, -DATA (4); MN2-BREW-FUEL-BAR, -ARROW, -BUBBLES (5)
*>   MN2-CRAFTER-SLOT, -DISABLED, -MAYPLACE, -MENU-SET, -BE-SET, -QUICK, -PREVIEW, -RESULT, -POWERED (6); MN2-DATA-SYNC (6.4)
*>   MN2-CRAFTER-CLICK, -UPDATE, -SERVER, -DRAW, -TOOLTIP, -POWER (7); MN2-PART-TYPE, -SIZE, -PACKET, MN2-DATA-WIRE (8)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-FRAME.
*> USING screen width, screen height, title width, leftPos out, topPos out, title x out, title y out, inventory label y out (1.1, 3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SW                   BINARY-LONG.
 01 L-SH                   BINARY-LONG.
 01 L-TW                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-LY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SW L-SH L-TW L-LEFT L-TOP L-TX L-TY L-LY.
    COMPUTE L-LEFT = (L-SW - 176) / 2
    COMPUTE L-TOP = (L-SH - 166) / 2
    COMPUTE L-TX = (176 - L-TW) / 2
    MOVE 6 TO L-TY
    MOVE 72 TO L-LY
    GOBACK.
 END PROGRAM MN2-FRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-STD-INV.
*> USING relative index 0 to 35 (main 0 to 26, hotbar 27 to 35), x out, y out (1.2): (8 + 18 c, 84 + 18 r) and (8 + 18 i, 142).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COL BINARY-LONG.
 01 WS-ROW BINARY-LONG.
 LINKAGE SECTION.
 01 L-REL                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-REL L-X L-Y.
    IF L-REL < 27
        COMPUTE WS-COL = FUNCTION MOD(L-REL, 9)
        COMPUTE WS-ROW = (L-REL - WS-COL) / 9
        COMPUTE L-X = 8 + 18 * WS-COL
        COMPUTE L-Y = 84 + 18 * WS-ROW
    ELSE
        COMPUTE L-X = 8 + 18 * (L-REL - 27)
        MOVE 142 TO L-Y
    END-IF
    GOBACK.
 END PROGRAM MN2-STD-INV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-QUICK-TAIL.
*> USING count after, count before, cleared out, returned out, onTake out (1.3): the common tail of the quick-move methods.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AFTER                BINARY-LONG.
 01 L-BEFORE               BINARY-LONG.
 01 L-CLEARED              BINARY-LONG.
 01 L-RETURNED             BINARY-LONG.
 01 L-ONTAKE               BINARY-LONG.
 PROCEDURE DIVISION USING L-AFTER L-BEFORE L-CLEARED L-RETURNED L-ONTAKE.
    MOVE 0 TO L-CLEARED L-RETURNED L-ONTAKE
    IF L-AFTER = 0
        MOVE 1 TO L-CLEARED
    END-IF
    IF L-AFTER NOT = L-BEFORE
        MOVE 1 TO L-RETURNED L-ONTAKE
    END-IF
    GOBACK.
 END PROGRAM MN2-QUICK-TAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-QUICK-LOOP.
*> USING returned a non-empty stack, the slot still holds the same item, again out (1.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RETURNED             BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-AGAIN                BINARY-LONG.
 PROCEDURE DIVISION USING L-RETURNED L-SAME L-AGAIN.
    MOVE 0 TO L-AGAIN
    IF L-RETURNED = 1 AND L-SAME = 1
        MOVE 1 TO L-AGAIN
    END-IF
    GOBACK.
 END PROGRAM MN2-QUICK-LOOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-FURNACE-BUTTON.
*> USING leftPos, screen height, x out, y out, width out, height out (3.1): the recipe book button.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-SH                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-SH L-X L-Y L-W L-H.
    COMPUTE L-X = L-LEFT + 20
    COMPUTE WS-HALF = L-SH / 2
    COMPUTE L-Y = WS-HALF - 49
    MOVE 20 TO L-W
    MOVE 18 TO L-H
    GOBACK.
 END PROGRAM MN2-FURNACE-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-FLAME.
*> USING data 0, data 1, leftPos, topPos, h out, source v out, x out, y out (3.2): the lit flame, h = ceil(litProgress x 13) + 1; all 0 while not lit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D BINARY-DOUBLE.
 01 WS-N BINARY-DOUBLE.
 01 WS-Q BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-D0                   BINARY-LONG.
 01 L-D1                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D0 L-D1 L-LEFT L-TOP L-H L-V L-X L-Y.
    MOVE 0 TO L-H L-V L-X L-Y
    IF L-D0 > 0
        MOVE L-D1 TO WS-D
        IF WS-D = 0
            MOVE 200 TO WS-D
        END-IF
        IF WS-D < 0
            MOVE 1 TO L-H
        ELSE
            COMPUTE WS-N = FUNCTION MIN(L-D0, WS-D)
            COMPUTE WS-Q = (13 * WS-N + WS-D - 1) / WS-D
            COMPUTE L-H = WS-Q + 1
        END-IF
        COMPUTE L-V = 14 - L-H
        COMPUTE L-X = L-LEFT + 56
        COMPUTE L-Y = L-TOP + 36 + 14 - L-H
    END-IF
    GOBACK.
 END PROGRAM MN2-FLAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-ARROW.
*> USING data 2, data 3, leftPos, topPos, w out, x out, y out (3.2): w = ceil(burnProgress x 24), 0 when either value is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P BINARY-DOUBLE.
 01 WS-T BINARY-DOUBLE.
 01 WS-N BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-T L-LEFT L-TOP L-W L-X L-Y.
    MOVE L-P TO WS-P
    MOVE L-T TO WS-T
    IF WS-T < 0
        COMPUTE WS-P = 0 - WS-P
        COMPUTE WS-T = 0 - WS-T
    END-IF
    MOVE 0 TO L-W
    IF WS-P > 0 AND WS-T > 0
        COMPUTE WS-N = FUNCTION MIN(WS-P, WS-T)
        COMPUTE L-W = (24 * WS-N + WS-T - 1) / WS-T
    END-IF
    COMPUTE L-X = L-LEFT + 79
    COMPUTE L-Y = L-TOP + 34
    GOBACK.
 END PROGRAM MN2-ARROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-FURNACE-TEXTURE.
*> USING kind (1 furnace, 2 blast furnace, 3 smoker), texture out, filter label key out (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    EVALUATE L-KIND
        WHEN 1
            MOVE "textures/gui/container/furnace.png" TO L-T1
            MOVE "gui.recipebook.toggleRecipes.smeltable" TO L-T2
        WHEN 2
            MOVE "textures/gui/container/blast_furnace.png" TO L-T1
            MOVE "gui.recipebook.toggleRecipes.blastable" TO L-T2
        WHEN 3
            MOVE "textures/gui/container/smoker.png" TO L-T1
            MOVE "gui.recipebook.toggleRecipes.smokable" TO L-T2
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-FURNACE-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-FURNACE-SPRITES.
*> USING kind, flame sprite out, arrow sprite out (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    EVALUATE L-KIND
        WHEN 1
            MOVE "container/furnace/lit_progress" TO L-T1
            MOVE "container/furnace/burn_progress" TO L-T2
        WHEN 2
            MOVE "container/blast_furnace/lit_progress" TO L-T1
            MOVE "container/blast_furnace/burn_progress" TO L-T2
        WHEN 3
            MOVE "container/smoker/lit_progress" TO L-T1
            MOVE "container/smoker/burn_progress" TO L-T2
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-FURNACE-SPRITES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-FURNACE-TABS.
*> USING kind, recipe book category out, tabs with their icons out (3.3): tab:icon, a tab with two icons joins them with +.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    EVALUATE L-KIND
        WHEN 1
            MOVE "FURNACE" TO L-T1
            MOVE "furnace_food:porkchop;furnace_blocks:stone;furnace_misc:lava_bucket+emerald" TO L-T2
        WHEN 2
            MOVE "BLAST_FURNACE" TO L-T1
            MOVE "blast_furnace_blocks:redstone_ore;blast_furnace_misc:iron_shovel+golden_leggings" TO L-T2
        WHEN 3
            MOVE "SMOKER" TO L-T1
            MOVE "smoker_food:porkchop" TO L-T2
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-FURNACE-TABS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-BREW-SLOT.
*> USING menu slot, part out (0 none, 1 own, 2 player), x out, y out, class out (0 plain, 1 potion, 2 ingredient, 3 fuel) (4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REL BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-CLS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-PART L-X L-Y L-CLS.
    MOVE 0 TO L-PART L-X L-Y L-CLS
    EVALUATE L-SLOT
        WHEN 0
            MOVE 1 TO L-PART L-CLS
            MOVE 56 TO L-X
            MOVE 51 TO L-Y
        WHEN 1
            MOVE 1 TO L-PART L-CLS
            MOVE 79 TO L-X
            MOVE 58 TO L-Y
        WHEN 2
            MOVE 1 TO L-PART L-CLS
            MOVE 102 TO L-X
            MOVE 51 TO L-Y
        WHEN 3
            MOVE 1 TO L-PART
            MOVE 2 TO L-CLS
            MOVE 79 TO L-X
            MOVE 17 TO L-Y
        WHEN 4
            MOVE 1 TO L-PART
            MOVE 3 TO L-CLS
            MOVE 17 TO L-X L-Y
        WHEN 5 THRU 40
            MOVE 2 TO L-PART
            COMPUTE WS-REL = L-SLOT - 5
            CALL "MN2-STD-INV" USING WS-REL L-X L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-BREW-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-BREW-MAYPLACE.
*> USING slot, in brewing_input, in brewing_potion_inputs, in reagent set, has brewing_fuel, ok out, stack cap out (1 for a bottle slot, 0 plain) (4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-INP                  BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-REA                  BINARY-LONG.
 01 L-FUEL                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-CAP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-INP L-TAG L-REA L-FUEL L-OK L-CAP.
    MOVE 1 TO L-OK
    MOVE 0 TO L-CAP
    EVALUATE TRUE
        WHEN L-SLOT >= 0 AND L-SLOT <= 2
            MOVE 1 TO L-CAP
            MOVE 0 TO L-OK
            IF L-INP = 1 OR L-TAG = 1
                MOVE 1 TO L-OK
            END-IF
        WHEN L-SLOT = 3
            MOVE L-REA TO L-OK
        WHEN L-SLOT = 4
            MOVE L-FUEL TO L-OK
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-BREW-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-BREW-ROUTE.
*> USING slot, is fuel, is reagent, is potion input, rule out (1 to 7), first out, end out, reverse out, mode out (0 common tail, 1 onQuickCraft then tail, 2 return empty at once on success) (4.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-FUEL                 BINARY-LONG.
 01 L-REA                  BINARY-LONG.
 01 L-POT                  BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REV                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-FUEL L-REA L-POT L-RULE L-FIRST L-END L-REV L-MODE.
    MOVE 0 TO L-REV L-MODE
    EVALUATE TRUE
        WHEN L-SLOT >= 0 AND L-SLOT <= 4
            MOVE 1 TO L-RULE L-REV L-MODE
            MOVE 5 TO L-FIRST
            MOVE 41 TO L-END
        WHEN L-FUEL = 1
            MOVE 2 TO L-RULE L-MODE
            MOVE 4 TO L-FIRST
            MOVE 5 TO L-END
        WHEN L-REA = 1
            MOVE 3 TO L-RULE
            MOVE 3 TO L-FIRST
            MOVE 4 TO L-END
        WHEN L-POT = 1
            MOVE 4 TO L-RULE
            MOVE 0 TO L-FIRST
            MOVE 3 TO L-END
        WHEN L-SLOT >= 5 AND L-SLOT < 32
            MOVE 5 TO L-RULE
            MOVE 32 TO L-FIRST
            MOVE 41 TO L-END
        WHEN L-SLOT >= 32 AND L-SLOT < 41
            MOVE 6 TO L-RULE
            MOVE 5 TO L-FIRST
            MOVE 32 TO L-END
        WHEN OTHER
            MOVE 7 TO L-RULE
            MOVE 5 TO L-FIRST
            MOVE 41 TO L-END
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-BREW-ROUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-BREW-FALLBACK.
*> USING is reagent, proceed out, first out, end out (4.4 rule 2): after a failed fuel move a reagent is moved into [3, 4), anything else ends with nothing moved.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REA                  BINARY-LONG.
 01 L-GO                   BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING L-REA L-GO L-FIRST L-END.
    MOVE 0 TO L-GO L-FIRST L-END
    IF L-REA = 1
        MOVE 1 TO L-GO
        MOVE 3 TO L-FIRST
        MOVE 4 TO L-END
    END-IF
    GOBACK.
 END PROGRAM MN2-BREW-FALLBACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-BREW-DATA.
*> USING data index, brewTime, fuel, totalBrewTime, totalFuel, value out (4.5): index 0 to 3, any other index reads 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-A L-B L-C L-D L-V.
    EVALUATE L-I
        WHEN 0
            MOVE L-A TO L-V
        WHEN 1
            MOVE L-B TO L-V
        WHEN 2
            MOVE L-C TO L-V
        WHEN 3
            MOVE L-D TO L-V
        WHEN OTHER
            MOVE 0 TO L-V
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-BREW-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-BREW-FUEL-BAR.
*> USING data 1 (fuel uses), data 3 (total fuel), leftPos, topPos, w out, x out, y out (5): w = clamp(ceilDiv(18 f, T), 0, 18), 0 when T <= 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A BINARY-DOUBLE.
 01 WS-Q BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-T L-LEFT L-TOP L-W L-X L-Y.
    MOVE 0 TO L-W
    IF L-T > 0
        COMPUTE WS-A = 18 * L-F
        IF WS-A > 0
            COMPUTE WS-Q = (WS-A + L-T - 1) / L-T
            COMPUTE L-W = FUNCTION MIN(18, WS-Q)
        END-IF
    END-IF
    COMPUTE L-X = L-LEFT + 60
    COMPUTE L-Y = L-TOP + 44
    GOBACK.
 END PROGRAM MN2-BREW-FUEL-BAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-BREW-ARROW.
*> USING data 0 (b), data 2 (B), leftPos, topPos, a out, x out, y out (5): a = trunc(28 x (1 - b / B)) while b > 0 and B > 0, else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-B                    BINARY-LONG.
 01 L-BB                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-B L-BB L-LEFT L-TOP L-A L-X L-Y.
    MOVE 0 TO L-A
    IF L-B > 0 AND L-BB > 0
        COMPUTE WS-Q = 28 * (L-BB - L-B) / L-BB
        IF WS-Q > 0
            MOVE WS-Q TO L-A
        END-IF
    END-IF
    COMPUTE L-X = L-LEFT + 97
    COMPUTE L-Y = L-TOP + 16
    GOBACK.
 END PROGRAM MN2-BREW-ARROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-BREW-BUBBLES.
*> USING b, B, leftPos, topPos, index out, L out, source v out, x out, y out (5): index (b / 2) mod 7 into 29, 24, 20, 16, 11, 6, 0; all 0 unless b > 0 and B > 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF BINARY-LONG.
 01 WS-TAB PIC X(14) VALUE "29242016110600".
 01 FILLER REDEFINES WS-TAB.
    05 WS-LEN PIC 99 OCCURS 7 TIMES.
 LINKAGE SECTION.
 01 L-B                    BINARY-LONG.
 01 L-BB                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 01 L-LEN                  BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-B L-BB L-LEFT L-TOP L-IDX L-LEN L-V L-X L-Y.
    MOVE 0 TO L-IDX L-LEN L-V L-X L-Y
    IF L-B > 0 AND L-BB > 0
        COMPUTE WS-HALF = L-B / 2
        COMPUTE L-IDX = FUNCTION MOD(WS-HALF, 7)
        MOVE WS-LEN(L-IDX + 1) TO L-LEN
        IF L-LEN > 0
            COMPUTE L-V = 29 - L-LEN
            COMPUTE L-X = L-LEFT + 63
            COMPUTE L-Y = L-TOP + 14 + 29 - L-LEN
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN2-BREW-BUBBLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-SLOT.
*> USING menu slot, part out (0 none, 1 crafting, 2 player, 3 result), x out, y out (6.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COL BINARY-LONG.
 01 WS-ROW BINARY-LONG.
 01 WS-REL BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-PART L-X L-Y.
    MOVE 0 TO L-PART L-X L-Y
    EVALUATE TRUE
        WHEN L-SLOT >= 0 AND L-SLOT <= 8
            MOVE 1 TO L-PART
            COMPUTE WS-COL = FUNCTION MOD(L-SLOT, 3)
            COMPUTE WS-ROW = (L-SLOT - WS-COL) / 3
            COMPUTE L-X = 26 + 18 * WS-COL
            COMPUTE L-Y = 17 + 18 * WS-ROW
        WHEN L-SLOT >= 9 AND L-SLOT <= 44
            MOVE 2 TO L-PART
            COMPUTE WS-REL = L-SLOT - 9
            CALL "MN2-STD-INV" USING WS-REL L-X L-Y
        WHEN L-SLOT = 45
            MOVE 3 TO L-PART
            MOVE 134 TO L-X
            MOVE 35 TO L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-CRAFTER-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-DISABLED.
*> USING index, data value, disabled out (6.4): true for -1 < index < 9 with the value 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-D L-OUT.
    MOVE 0 TO L-OUT
    IF L-I > -1 AND L-I < 9 AND L-D = 1
        MOVE 1 TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-DISABLED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-MAYPLACE.
*> USING index, data value, ok out (6.2): a CrafterSlot accepts exactly when it is not disabled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIS BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-D L-OK.
    CALL "MN2-CRAFTER-DISABLED" USING L-I L-D WS-DIS
    COMPUTE L-OK = 1 - WS-DIS
    GOBACK.
 END PROGRAM MN2-CRAFTER-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-MENU-SET.
*> USING slot, enabled, data value out (6.4): setSlotState of the menu writes 0 when enabled, 1 when disabled.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-EN                   BINARY-LONG.
 01 L-V                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-EN L-V.
    MOVE 1 TO L-V
    IF L-EN = 1
        MOVE 0 TO L-V
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-MENU-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-BE-SET.
*> USING slot, slot is empty, enabled, changed out, value out (-1 when nothing is written) (6.4, 7.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-EN                   BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-V                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-EMPTY L-EN L-CHANGED L-V.
    MOVE 0 TO L-CHANGED
    MOVE -1 TO L-V
    IF L-SLOT >= 0 AND L-SLOT <= 8 AND L-EMPTY = 1
        MOVE 1 TO L-CHANGED
        MOVE 1 TO L-V
        IF L-EN = 1
            MOVE 0 TO L-V
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-BE-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-QUICK.
*> USING clicked slot, first out, end out, reverse out (6.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REV                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-FIRST L-END L-REV.
    IF L-SLOT >= 0 AND L-SLOT <= 8
        MOVE 9 TO L-FIRST
        MOVE 45 TO L-END
        MOVE 1 TO L-REV
    ELSE
        MOVE 0 TO L-FIRST L-REV
        MOVE 9 TO L-END
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-PREVIEW.
*> USING player is a server player, a recipe matched, action out (0 nothing, 1 set the product, 2 set empty) (6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-ACT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-FOUND L-ACT.
    MOVE 0 TO L-ACT
    IF L-SERVER = 1
        MOVE 2 TO L-ACT
        IF L-FOUND = 1
            MOVE 1 TO L-ACT
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-PREVIEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-RESULT.
*> USING mayPlace out, mayPickup out, allowModification out, highlightable out, isFake out (6.2): the display-only result slot.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLACE                BINARY-LONG.
 01 L-PICKUP               BINARY-LONG.
 01 L-MODIFY               BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 01 L-FAKE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLACE L-PICKUP L-MODIFY L-HIGH L-FAKE.
    MOVE 0 TO L-PLACE L-PICKUP L-MODIFY L-HIGH
    MOVE 1 TO L-FAKE
    GOBACK.
 END PROGRAM MN2-CRAFTER-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-POWERED.
*> USING data 9, powered out (6.4): isPowered is data 9 equal to 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-OUT.
    MOVE 0 TO L-OUT
    IF L-D = 1
        MOVE 1 TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-POWERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-DATA-SYNC.
*> USING last sent value, current value, send out, wire value out (6.4, 1.4): Container Set Data for a changed property, the value as a signed 16-bit short.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LAST                 BINARY-LONG.
 01 L-CUR                  BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 01 L-WIRE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LAST L-CUR L-SEND L-WIRE.
    MOVE 0 TO L-SEND
    IF L-CUR NOT = L-LAST
        MOVE 1 TO L-SEND
    END-IF
    CALL "MN2-DATA-WIRE" USING L-CUR L-WIRE
    GOBACK.
 END PROGRAM MN2-DATA-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-CLICK.
*> USING clicked slot is a CrafterSlot, it has an item, spectator, click type (0 pickup, 1 swap, 2 other), slot disabled, cursor empty, swap inventory stack not empty, action out (0 none, 1 enable, 2 disable) (7.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ISC                  BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-SPEC                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-DIS                  BINARY-LONG.
 01 L-CUR                  BINARY-LONG.
 01 L-SWP                  BINARY-LONG.
 01 L-ACT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ISC L-HAS L-SPEC L-TYPE L-DIS L-CUR L-SWP L-ACT.
    MOVE 0 TO L-ACT
    IF L-ISC = 1 AND L-HAS = 0 AND L-SPEC = 0
        EVALUATE TRUE
            WHEN L-TYPE = 0 AND L-DIS = 1
                MOVE 1 TO L-ACT
            WHEN L-TYPE = 0 AND L-CUR = 1
                MOVE 2 TO L-ACT
            WHEN L-TYPE = 1 AND L-DIS = 1 AND L-SWP = 1
                MOVE 1 TO L-ACT
        END-EVALUATE
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-UPDATE.
*> USING action (1 enable, 2 disable), slot id, container id, local data out, packet slot id out, packet container id out, packet new state out, volume x 100 out, pitch x 100 out (7.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACT                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-CONT                 BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-PSLOT                BINARY-LONG.
 01 L-PCONT                BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-VOL                  BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-ACT L-SLOT L-CONT L-DATA L-PSLOT L-PCONT L-STATE L-VOL L-PITCH.
    MOVE L-SLOT TO L-PSLOT
    MOVE L-CONT TO L-PCONT
    MOVE 40 TO L-VOL
    IF L-ACT = 1
        MOVE 0 TO L-DATA
        MOVE 1 TO L-STATE
        MOVE 100 TO L-PITCH
    ELSE
        MOVE 1 TO L-DATA
        MOVE 0 TO L-STATE
        MOVE 75 TO L-PITCH
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-SERVER.
*> USING sender is a spectator, container id matches, open menu is a crafter menu, container is the crafter block entity, accept out (7.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPEC                 BINARY-LONG.
 01 L-IDM                  BINARY-LONG.
 01 L-ISM                  BINARY-LONG.
 01 L-BE                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SPEC L-IDM L-ISM L-BE L-OK.
    MOVE 0 TO L-OK
    IF L-SPEC = 0 AND L-IDM = 1 AND L-ISM = 1 AND L-BE = 1
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-SERVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-DRAW.
*> USING crafting slot 0 to 8, disabled, mouse x, mouse y, leftPos, topPos, disabled sprite out, sprite x out, sprite y out, pointer out (7.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COL BINARY-LONG.
 01 WS-ROW BINARY-LONG.
 01 WS-X BINARY-LONG.
 01 WS-Y BINARY-LONG.
 01 WS-X0 BINARY-LONG.
 01 WS-Y0 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-DIS                  BINARY-LONG.
 01 L-MX                   BINARY-LONG.
 01 L-MY                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-SPR                  BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-PTR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-DIS L-MX L-MY L-LEFT L-TOP L-SPR L-SX L-SY L-PTR.
    COMPUTE WS-COL = FUNCTION MOD(L-SLOT, 3)
    COMPUTE WS-ROW = (L-SLOT - WS-COL) / 3
    COMPUTE WS-X = 26 + 18 * WS-COL
    COMPUTE WS-Y = 17 + 18 * WS-ROW
    MOVE L-DIS TO L-SPR
    COMPUTE L-SX = WS-X - 1
    COMPUTE L-SY = WS-Y - 1
    COMPUTE WS-X0 = L-LEFT + WS-X - 2
    COMPUTE WS-Y0 = L-TOP + WS-Y - 2
    MOVE 0 TO L-PTR
    IF L-MX > WS-X0 AND L-MX < WS-X0 + 19 AND L-MY > WS-Y0 AND L-MY < WS-Y0 + 19
        MOVE 1 TO L-PTR
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-TOOLTIP.
*> USING hovered slot is a CrafterSlot, it is disabled, cursor empty, slot has an item, spectator, show out (7.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOV                  BINARY-LONG.
 01 L-DIS                  BINARY-LONG.
 01 L-CUR                  BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-SPEC                 BINARY-LONG.
 01 L-SHOW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HOV L-DIS L-CUR L-HAS L-SPEC L-SHOW.
    MOVE 0 TO L-SHOW
    IF L-HOV = 1 AND L-DIS = 0 AND L-CUR = 1 AND L-HAS = 0 AND L-SPEC = 0
        MOVE 1 TO L-SHOW
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-TOOLTIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-CRAFTER-POWER.
*> USING screen width, screen height, powered, x out, y out, sprite out (1 powered, 0 unpowered) (7.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF BINARY-LONG.
 LINKAGE SECTION.
 01 L-SW                   BINARY-LONG.
 01 L-SH                   BINARY-LONG.
 01 L-POW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-SPR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SW L-SH L-POW L-X L-Y L-SPR.
    COMPUTE WS-HALF = L-SW / 2
    COMPUTE L-X = WS-HALF + 9
    COMPUTE WS-HALF = L-SH / 2
    COMPUTE L-Y = WS-HALF - 48
    MOVE 0 TO L-SPR
    IF L-POW = 1
        MOVE 1 TO L-SPR
    END-IF
    GOBACK.
 END PROGRAM MN2-CRAFTER-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-PART-TYPE.
*> USING part kind (1 crafter, 2 blast furnace, 3 brewing stand, 4 furnace, 5 smoker), menu type id out (8, V16).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ID.
    EVALUATE L-KIND
        WHEN 1
            MOVE 7 TO L-ID
        WHEN 2
            MOVE 10 TO L-ID
        WHEN 3
            MOVE 11 TO L-ID
        WHEN 4
            MOVE 14 TO L-ID
        WHEN OTHER
            MOVE 22 TO L-ID
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-PART-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-PART-SIZE.
*> USING part kind, data slot count out, slot total out (V1 to V4): furnace family 4 and 39, brewing stand 4 and 41, crafter 10 and 46.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DATA L-TOTAL.
    MOVE 4 TO L-DATA
    MOVE 39 TO L-TOTAL
    EVALUATE L-KIND
        WHEN 1
            MOVE 10 TO L-DATA
            MOVE 46 TO L-TOTAL
        WHEN 3
            MOVE 41 TO L-TOTAL
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-PART-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-DATA-WIRE.
*> USING value, wire value out (8, 1.4): the low 16 bits as a signed short (32768 arrives as -32768).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M BINARY-LONG.
 LINKAGE SECTION.
 01 L-V                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-V L-W.
    COMPUTE WS-M = FUNCTION MOD(L-V, 65536)
    IF WS-M >= 32768
        SUBTRACT 65536 FROM WS-M
    END-IF
    MOVE WS-M TO L-W
    GOBACK.
 END PROGRAM MN2-DATA-WIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN2-PART-PACKET.
*> USING packet index 1 to 9, packet id out, used by this part out (8): Container Set Data, Container Button Click (unused), Container Click, Slot State Changed, Recipe Book Settings, Change Settings, Seen Recipe, Place Recipe, Place Ghost Recipe.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-ID L-USED.
    MOVE 1 TO L-USED
    EVALUATE L-I
        WHEN 1
            MOVE 19 TO L-ID
        WHEN 2
            MOVE 17 TO L-ID
            MOVE 0 TO L-USED
        WHEN 3
            MOVE 18 TO L-ID
        WHEN 4
            MOVE 20 TO L-ID
        WHEN 5
            MOVE 77 TO L-ID
        WHEN 6
            MOVE 47 TO L-ID
        WHEN 7
            MOVE 48 TO L-ID
        WHEN 8
            MOVE 39 TO L-ID
        WHEN OTHER
            MOVE 64 TO L-ID
    END-EVALUATE
    GOBACK.
 END PROGRAM MN2-PART-PACKET.
