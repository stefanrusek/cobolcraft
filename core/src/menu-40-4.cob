*> Menus, part 4: the rules common to the four workstation menus, the loom, the stonecutter, the cartography table and the packet table
*> (docs/protocol/40-menus-4-enchanting-loom-stonecutter-cartography.md sections 1, 3 to 6; US12 phase 44). The enchanting table (section 2) is in
*> menu-enchanting.cob (ENCH-). Programs of plain numbers (MN4- prefix): each takes the facts the caller read (counts, flags, list sizes, positions) and
*> returns the decision or the pixel arithmetic of the section. The live window of a player (menus.cob) is not changed by this file. Flags are 0 or 1; floats
*> are FLOAT-LONG and scaled results are x 1e6. Menu kinds of section 1: 1 enchanting table, 2 loom, 3 cartography table, 4 stonecutter. The scroll
*> programs take the row count the caller checked (rows - 4 > 0 for the loom, a non-zero offscreen row count for the stonecutter): the generic handler
*> of 40-1 section 5.5 is the caller's. The data slot wire format is MN2-DATA-WIRE (menu-40-2.cob), stillValid is MN3-VALID (menu-40-3.cob).
*>
*>   MN4-IDENT, MN4-BLOCK, MN4-TITLE, MN4-CLOSE, MN4-SOUND (1)
*>   MN4-LOOM-SLOT, -MAYPLACE, -SELECTABLE, -CHANGED, -BUTTON, -RESULT, -TAKE, -QUICK, -STATE, -CELL, -CELL-STATE, -ACTIVE, -THUMB, -DRAG, -WHEEL, -SCROLL-HIT,
*>   -BUTTON-UV, -GEOM (3)
*>   MN4-STONE-SLOT, -PICKALL, -CHANGED, -RESULT, -BUTTON, -TAKE, -QUICK, -ENDING, -ROWS, -THUMB, -DRAG, -WHEEL, -CELL, -SCROLL-HIT, -LISTEN (4)
*>   MN4-CARTO-SLOT, -MAYPLACE, -CHANGED, -SETUP, -TAKE, -POST, -QUICK, -MODE, -PREVIEW, -ERROR (5); MN4-PACKET, MN4-PROPERTIES (6)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-IDENT.
*> USING menu kind, type id out, own slots out, total slots out, data slots out, title label y shift out (1 rules 1 and 3, 8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-YSHIFT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TYPE L-OWN L-TOTAL L-DATA L-YSHIFT.
    EVALUATE L-KIND
        WHEN 1
            MOVE 13 TO L-TYPE
            MOVE 2 TO L-OWN
            MOVE 38 TO L-TOTAL
            MOVE 10 TO L-DATA
            MOVE 0 TO L-YSHIFT
        WHEN 2
            MOVE 18 TO L-TYPE
            MOVE 4 TO L-OWN
            MOVE 40 TO L-TOTAL
            MOVE 1 TO L-DATA
            MOVE 2 TO L-YSHIFT
        WHEN 3
            MOVE 23 TO L-TYPE
            MOVE 3 TO L-OWN
            MOVE 39 TO L-TOTAL
            MOVE 0 TO L-DATA
            MOVE 2 TO L-YSHIFT
        WHEN OTHER
            MOVE 24 TO L-TYPE
            MOVE 2 TO L-OWN
            MOVE 38 TO L-TOTAL
            MOVE 1 TO L-DATA
            MOVE 1 TO L-YSHIFT
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-IDENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-BLOCK.
*> USING menu kind, bound block out, default title key out (1 rules 2 and 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    EVALUATE L-KIND
        WHEN 1
            MOVE "enchanting_table" TO L-T1
            MOVE "container.enchant" TO L-T2
        WHEN 2
            MOVE "loom" TO L-T1
            MOVE "container.loom" TO L-T2
        WHEN 3
            MOVE "cartography_table" TO L-T1
            MOVE "container.cartography_table" TO L-T2
        WHEN 4
            MOVE "stonecutter" TO L-T1
            MOVE "container.stonecutter" TO L-T2
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-TITLE.
*> USING menu kind, title key out, English text out (1 rule 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-T1                   PIC X(96).
 01 L-T2                   PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-T1 L-T2.
    MOVE SPACES TO L-T1 L-T2
    EVALUATE L-KIND
        WHEN 1
            MOVE "container.enchant" TO L-T1
            MOVE "Enchant" TO L-T2
        WHEN 2
            MOVE "container.loom" TO L-T1
            MOVE "Loom" TO L-T2
        WHEN 3
            MOVE "container.cartography_table" TO L-T1
            MOVE "Cartography Table" TO L-T2
        WHEN 4
            MOVE "container.stonecutter" TO L-T1
            MOVE "Stonecutter" TO L-T2
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-TITLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CLOSE.
*> USING menu kind, input slots returned out, result item removed silently out (1 rule 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-CLEARED              BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-CLEARED L-REMOVED.
    MOVE 0 TO L-REMOVED
    EVALUATE L-KIND
        WHEN 1
            MOVE 2 TO L-CLEARED
        WHEN 2
            MOVE 3 TO L-CLEARED
        WHEN 3
            MOVE 2 TO L-CLEARED
            MOVE 1 TO L-REMOVED
        WHEN OTHER
            MOVE 1 TO L-CLEARED L-REMOVED
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-SOUND.
*> USING game time, last sound time, play out, new last sound time out (1 rule 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-PLAY                 BINARY-LONG.
 01 L-NEWLAST              BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-LAST L-PLAY L-NEWLAST.
    MOVE 0 TO L-PLAY
    MOVE L-LAST TO L-NEWLAST
    IF L-TIME NOT = L-LAST
        MOVE 1 TO L-PLAY
        MOVE L-TIME TO L-NEWLAST
    END-IF
    GOBACK.
 END PROGRAM MN4-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-SLOT.
*> USING menu slot, part out (0 none, 1 own, 2 player), x out, y out (3.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REL BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-PART L-X L-Y.
    MOVE 0 TO L-PART L-X L-Y
    EVALUATE TRUE
        WHEN L-SLOT = 0
            MOVE 1 TO L-PART
            MOVE 13 TO L-X
            MOVE 26 TO L-Y
        WHEN L-SLOT = 1
            MOVE 1 TO L-PART
            MOVE 33 TO L-X
            MOVE 26 TO L-Y
        WHEN L-SLOT = 2
            MOVE 1 TO L-PART
            MOVE 23 TO L-X
            MOVE 45 TO L-Y
        WHEN L-SLOT = 3
            MOVE 1 TO L-PART
            MOVE 143 TO L-X
            MOVE 57 TO L-Y
        WHEN L-SLOT >= 4 AND L-SLOT <= 39
            MOVE 2 TO L-PART
            COMPUTE WS-REL = L-SLOT - 4
            CALL "MN2-STD-INV" USING WS-REL L-X L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-LOOM-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-MAYPLACE.
*> USING slot, is a banner, in the tag loom_dyes, has the dye component, in the tag loom_patterns, has provides_banner_patterns, ok out (3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-BANNER               BINARY-LONG.
 01 L-DT                   BINARY-LONG.
 01 L-DC                   BINARY-LONG.
 01 L-PT                   BINARY-LONG.
 01 L-PC                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-BANNER L-DT L-DC L-PT L-PC L-OK.
    MOVE 1 TO L-OK
    EVALUATE L-SLOT
        WHEN 0
            MOVE L-BANNER TO L-OK
        WHEN 1
            MOVE 0 TO L-OK
            IF L-DT = 1 AND L-DC = 1
                MOVE 1 TO L-OK
            END-IF
        WHEN 2
            MOVE 0 TO L-OK
            IF L-PT = 1 AND L-PC = 1
                MOVE 1 TO L-OK
            END-IF
        WHEN 3
            MOVE 0 TO L-OK
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-LOOM-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-SELECTABLE.
*> USING pattern slot is empty, the stack has provides_banner_patterns, size of the tag no_item_required, size of the set, list size out (3.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PE                   BINARY-LONG.
 01 L-HC                   BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PE L-HC L-TAG L-SET L-SIZE.
    MOVE 0 TO L-SIZE
    IF L-PE = 1
        MOVE L-TAG TO L-SIZE
    ELSE
        IF L-HC = 1
            MOVE L-SET TO L-SIZE
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-SELECTABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-CHANGED.
*> USING banner empty, dye empty, old selected index, old list size, new list size, index of the old pattern in the new list (-1), banner layers, list size out, selected index out, result empty out, set up the result out (3.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WV BINARY-LONG.
 01 WS-CH BINARY-LONG.
 LINKAGE SECTION.
 01 L-BE                   BINARY-LONG.
 01 L-DE                   BINARY-LONG.
 01 L-OI                   BINARY-LONG.
 01 L-OSZ                  BINARY-LONG.
 01 L-NSZ                  BINARY-LONG.
 01 L-FI                   BINARY-LONG.
 01 L-LAY                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-REMPTY               BINARY-LONG.
 01 L-SETUP                BINARY-LONG.
 PROCEDURE DIVISION USING L-BE L-DE L-OI L-OSZ L-NSZ L-FI L-LAY L-SIZE L-SEL L-REMPTY L-SETUP.
    MOVE 0 TO L-SETUP
    IF L-BE = 1 OR L-DE = 1
        MOVE 0 TO L-SIZE
        MOVE -1 TO L-SEL
    ELSE
        MOVE 0 TO WS-WV WS-CH
        IF L-OI >= 0 AND L-OI < L-OSZ
            MOVE 1 TO WS-WV
        END-IF
        MOVE L-NSZ TO L-SIZE
        MOVE -1 TO L-SEL
        EVALUATE TRUE
            WHEN L-NSZ = 1
                MOVE 0 TO L-SEL
                MOVE 1 TO WS-CH
            WHEN WS-WV = 0
                MOVE -1 TO L-SEL
            WHEN L-FI >= 0
                MOVE L-FI TO L-SEL
                MOVE 1 TO WS-CH
        END-EVALUATE
        IF WS-CH = 1
            IF L-LAY >= 6
                MOVE -1 TO L-SEL
            ELSE
                MOVE 1 TO L-SETUP
            END-IF
        END-IF
    END-IF
    MOVE 1 TO L-REMPTY
    IF L-SETUP = 1
        MOVE 0 TO L-REMPTY
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-BUTTON.
*> USING button id, list size, returned out, selected out, set up the result out (3.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-SETUP                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SIZE L-OK L-SEL L-SETUP.
    MOVE 0 TO L-OK L-SEL L-SETUP
    IF L-ID >= 0 AND L-ID < L-SIZE
        MOVE 1 TO L-OK L-SETUP
        MOVE L-ID TO L-SEL
    ELSE
        MOVE -1 TO L-SEL
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-RESULT.
*> USING banner layers, the dye colour is null, banner empty, dye empty, layers of the result or -1 for an empty result out (3.5 setupResultSlot).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LAY                  BINARY-LONG.
 01 L-NULL                 BINARY-LONG.
 01 L-BE                   BINARY-LONG.
 01 L-DE                   BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LAY L-NULL L-BE L-DE L-OUT.
    MOVE -1 TO L-OUT
    IF L-BE = 0 AND L-DE = 0 AND L-NULL = 0
        COMPUTE L-OUT = L-LAY + 1
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-TAKE.
*> USING banner count, dye count, new banner count out, new dye count out, selection reset out (3.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BANNER               BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-NB                   BINARY-LONG.
 01 L-ND                   BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 PROCEDURE DIVISION USING L-BANNER L-DYE L-NB L-ND L-RESET.
    COMPUTE L-NB = L-BANNER - 1
    COMPUTE L-ND = L-DYE - 1
    MOVE 0 TO L-RESET
    IF L-NB = 0 OR L-ND = 0
        MOVE 1 TO L-RESET
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-QUICK.
*> USING source slot, is a banner, is a dye, is a pattern item, rule out (1 to 7), first out, end out, reverse out, onQuickCraft out (3.8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-BANNER               BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-PATTERN              BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REV                  BINARY-LONG.
 01 L-ONQ                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-BANNER L-DYE L-PATTERN L-RULE L-FIRST L-END L-REV L-ONQ.
    MOVE 0 TO L-REV L-ONQ
    EVALUATE TRUE
        WHEN L-SLOT = 3
            MOVE 1 TO L-RULE L-REV L-ONQ
            MOVE 4 TO L-FIRST
            MOVE 40 TO L-END
        WHEN L-SLOT >= 0 AND L-SLOT <= 2
            MOVE 2 TO L-RULE
            MOVE 4 TO L-FIRST
            MOVE 40 TO L-END
        WHEN L-BANNER = 1
            MOVE 3 TO L-RULE
            MOVE 0 TO L-FIRST
            MOVE 1 TO L-END
        WHEN L-DYE = 1
            MOVE 4 TO L-RULE
            MOVE 1 TO L-FIRST
            MOVE 2 TO L-END
        WHEN L-PATTERN = 1
            MOVE 5 TO L-RULE
            MOVE 2 TO L-FIRST
            MOVE 3 TO L-END
        WHEN L-SLOT >= 4 AND L-SLOT <= 30
            MOVE 6 TO L-RULE
            MOVE 31 TO L-FIRST
            MOVE 40 TO L-END
        WHEN OTHER
            MOVE 7 TO L-RULE
            MOVE 4 TO L-FIRST
            MOVE 31 TO L-END
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-LOOM-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-STATE.
*> USING an input stack changed, previous grid shown, banner empty, dye empty, banner has the maximum layers, list size, start row, grid shown out, reset the scroll out (3.10 containerChanged).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS BINARY-LONG.
 LINKAGE SECTION.
 01 L-CH                   BINARY-LONG.
 01 L-PD                   BINARY-LONG.
 01 L-BE                   BINARY-LONG.
 01 L-DE                   BINARY-LONG.
 01 L-MX                   BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-SROW                 BINARY-LONG.
 01 L-DISPLAY              BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 PROCEDURE DIVISION USING L-CH L-PD L-BE L-DE L-MX L-SIZE L-SROW L-DISPLAY L-RESET.
    MOVE L-PD TO L-DISPLAY
    IF L-CH = 1
        MOVE 0 TO L-DISPLAY
        IF L-BE = 0 AND L-DE = 0 AND L-MX = 0 AND L-SIZE > 0
            MOVE 1 TO L-DISPLAY
        END-IF
    END-IF
    COMPUTE WS-ROWS = (L-SIZE + 3) / 4
    MOVE 0 TO L-RESET
    IF L-SROW >= WS-ROWS
        MOVE 1 TO L-RESET
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-CELL.
*> USING start row, list size, row r, column c, index out, in the list out, x out, y out (3.10 grid cells).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SROW                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-INLIST               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SROW L-SIZE L-R L-C L-IX L-INLIST L-X L-Y.
    COMPUTE L-IX = (L-SROW + L-R) * 4 + L-C
    MOVE 0 TO L-INLIST
    IF L-IX < L-SIZE
        MOVE 1 TO L-INLIST
    END-IF
    COMPUTE L-X = 60 + 14 * L-C
    COMPUTE L-Y = 13 + 14 * L-R
    GOBACK.
 END PROGRAM MN4-LOOM-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-CELL-STATE.
*> USING cell index, selected index, pointer inside, sprite out (0 normal, 1 highlighted, 2 selected), tooltip out, pointing hand out (3.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IX                   BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-HOV                  BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-IX L-SEL L-HOV L-SPRITE L-TIP L-HAND.
    MOVE 0 TO L-SPRITE L-TIP L-HAND
    IF L-IX = L-SEL
        MOVE 2 TO L-SPRITE
    ELSE
        IF L-HOV = 1
            MOVE 1 TO L-SPRITE L-TIP L-HAND
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-CELL-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-ACTIVE.
*> USING grid shown, list size, scroll bar active out (3.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISPLAY              BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DISPLAY L-SIZE L-OUT.
    MOVE 0 TO L-OUT
    IF L-DISPLAY = 1 AND L-SIZE > 16
        MOVE 1 TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-ACTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-THUMB.
*> USING scrollOffs, thumb y out (3.10): 13 + int(41 x scrollOffs).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T BINARY-LONG.
 LINKAGE SECTION.
 01 L-SO                   FLOAT-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SO L-Y.
    COMPUTE WS-T = 41 * L-SO
    COMPUTE L-Y = 13 + WS-T
    GOBACK.
 END PROGRAM MN4-LOOM-THUMB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-DRAG.
*> USING mouse y, topPos, total rows, scrollOffs before, consumed out, scrollOffs out (x 1e6), start row out (3.10 drag): the caller reads the rows, nothing changes for 4 or fewer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R BINARY-LONG.
 01 WS-S FLOAT-LONG.
 01 WS-X FLOAT-LONG.
 LINKAGE SECTION.
 01 L-MY                   BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 01 L-SO0                  FLOAT-LONG.
 01 L-CONSUMED             BINARY-LONG.
 01 L-SO                   BINARY-LONG.
 01 L-START                BINARY-LONG.
 PROCEDURE DIVISION USING L-MY L-TOP L-ROWS L-SO0 L-CONSUMED L-SO L-START.
    MOVE 0 TO L-CONSUMED L-START
    COMPUTE L-SO ROUNDED = L-SO0 * 1000000
    COMPUTE WS-R = L-ROWS - 4
    IF WS-R > 0
        MOVE 1 TO L-CONSUMED
        COMPUTE WS-S = (L-MY - (L-TOP + 13) - 7.5) / 41
        COMPUTE WS-S = FUNCTION MAX(0, FUNCTION MIN(1, WS-S))
        COMPUTE L-SO ROUNDED = WS-S * 1000000
        COMPUTE WS-X = WS-S * WS-R + 0.5
        MOVE WS-X TO L-START
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-DRAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-WHEEL.
*> USING scrollOffs, scroll y, total rows (above 4), scrollOffs out (x 1e6), start row out (3.10 wheel).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R BINARY-LONG.
 01 WS-S FLOAT-LONG.
 01 WS-X FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SO                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-ROWS                 BINARY-LONG.
 01 L-SO2                  BINARY-LONG.
 01 L-START                BINARY-LONG.
 PROCEDURE DIVISION USING L-SO L-SY L-ROWS L-SO2 L-START.
    COMPUTE WS-R = L-ROWS - 4
    COMPUTE WS-S = L-SO - L-SY / WS-R
    COMPUTE WS-S = FUNCTION MAX(0, FUNCTION MIN(1, WS-S))
    COMPUTE L-SO2 ROUNDED = WS-S * 1000000
    COMPUTE WS-X = WS-S * WS-R + 0.5
    MOVE WS-X TO L-START
    GOBACK.
 END PROGRAM MN4-LOOM-WHEEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-SCROLL-HIT.
*> USING x, y relative to the window, scrolling starts out (x 119 to 130, y 9 to 64), over the drawn track out (y 13 to 68) (3.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-OVER                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-START L-OVER.
    MOVE 0 TO L-START L-OVER
    IF L-X >= 119 AND L-X < 131
        IF L-Y >= 9 AND L-Y < 65
            MOVE 1 TO L-START
        END-IF
        IF L-Y >= 13 AND L-Y < 69
            MOVE 1 TO L-OVER
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN4-LOOM-SCROLL-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-BUTTON-UV.
*> USING U0, V0, U1, V1 of the pattern sprite, u0 out, u1 out, v0 out, v1 out (x 1e6) (3.10 banner on a button).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DU FLOAT-LONG.
 01 WS-DV FLOAT-LONG.
 LINKAGE SECTION.
 01 L-U0                   FLOAT-LONG.
 01 L-V0                   FLOAT-LONG.
 01 L-U1                   FLOAT-LONG.
 01 L-V1                   FLOAT-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-U0 L-V0 L-U1 L-V1 L-A L-B L-C L-D.
    COMPUTE WS-DU = L-U1 - L-U0
    COMPUTE WS-DV = L-V1 - L-V0
    COMPUTE L-A ROUNDED = L-U0 * 1000000
    COMPUTE L-B ROUNDED = (L-U0 + WS-DU * 21 / 64) * 1000000
    COMPUTE L-C ROUNDED = (L-V0 + WS-DV / 64) * 1000000
    COMPUTE L-D ROUNDED = (L-V0 + WS-DV / 64 + WS-DV * 40 / 64) * 1000000
    GOBACK.
 END PROGRAM MN4-LOOM-BUTTON-UV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-LOOM-GEOM.
*> USING title label y, preview x, y, w, h, preview scale, error icon x, y out (3.10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TY                   BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PW                   BINARY-LONG.
 01 L-PH                   BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 01 L-EX                   BINARY-LONG.
 01 L-EY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TY L-PX L-PY L-PW L-PH L-SCALE L-EX L-EY.
    MOVE 4 TO L-TY
    MOVE 141 TO L-PX
    MOVE 8 TO L-PY
    MOVE 20 TO L-PW
    MOVE 40 TO L-PH
    MOVE 16 TO L-SCALE
    MOVE 138 TO L-EX
    MOVE 52 TO L-EY
    GOBACK.
 END PROGRAM MN4-LOOM-GEOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-SLOT.
*> USING menu slot, part out (0 none, 1 own, 2 player), x out, y out (4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REL BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-PART L-X L-Y.
    MOVE 0 TO L-PART L-X L-Y
    EVALUATE TRUE
        WHEN L-SLOT = 0
            MOVE 1 TO L-PART
            MOVE 20 TO L-X
            MOVE 33 TO L-Y
        WHEN L-SLOT = 1
            MOVE 1 TO L-PART
            MOVE 143 TO L-X
            MOVE 33 TO L-Y
        WHEN L-SLOT >= 2 AND L-SLOT <= 37
            MOVE 2 TO L-PART
            COMPUTE WS-REL = L-SLOT - 2
            CALL "MN2-STD-INV" USING WS-REL L-X L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-STONE-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-PICKALL.
*> USING slot, canTakeItemForPickAll out (4.2): false for the result slot.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-OK.
    MOVE 1 TO L-OK
    IF L-SLOT = 1
        MOVE 0 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN4-STONE-PICKALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-CHANGED.
*> USING item kind differs from the remembered one, the stack is not empty, selected index, reset out, selected out, result cleared out, list from the set out (4.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KD                   BINARY-LONG.
 01 L-HE                   BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 01 L-NSEL                 BINARY-LONG.
 01 L-CLEARED              BINARY-LONG.
 01 L-FROMSET              BINARY-LONG.
 PROCEDURE DIVISION USING L-KD L-HE L-SEL L-RESET L-NSEL L-CLEARED L-FROMSET.
    MOVE 0 TO L-RESET L-CLEARED L-FROMSET
    MOVE L-SEL TO L-NSEL
    IF L-KD = 1
        MOVE 1 TO L-RESET L-CLEARED
        MOVE -1 TO L-NSEL
        MOVE L-HE TO L-FROMSET
    END-IF
    GOBACK.
 END PROGRAM MN4-STONE-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-RESULT.
*> USING list size, index, has a result out (4.4 setupResultSlot).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-IX L-OK.
    MOVE 0 TO L-OK
    IF L-SIZE > 0 AND L-IX >= 0 AND L-IX < L-SIZE
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN4-STONE-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-BUTTON.
*> USING button id, selected index, list size, returned out, selected set out, set up the result out (4.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-SETUP                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SEL L-SIZE L-OK L-SET L-SETUP.
    MOVE 0 TO L-OK L-SET L-SETUP
    IF L-ID NOT = L-SEL
        MOVE 1 TO L-OK
        IF L-ID >= 0 AND L-ID < L-SIZE
            MOVE 1 TO L-SET L-SETUP
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN4-STONE-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-TAKE.
*> USING input count, selected index, list size, new count out, selected out, result present out (4.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-NC                   BINARY-LONG.
 01 L-NSEL                 BINARY-LONG.
 01 L-RES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-SEL L-SIZE L-NC L-NSEL L-RES.
    MOVE 0 TO L-NC L-RES
    MOVE -1 TO L-NSEL
    IF L-COUNT > 1
        COMPUTE L-NC = L-COUNT - 1
        MOVE L-SEL TO L-NSEL
        IF L-SIZE > 0 AND L-SEL >= 0 AND L-SEL < L-SIZE
            MOVE 1 TO L-RES
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN4-STONE-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-QUICK.
*> USING source slot, accepted by the stonecutter set, rule out (1 to 5), first out, end out, reverse out, onQuickCraft out (4.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ACC                  BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REV                  BINARY-LONG.
 01 L-ONQ                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ACC L-RULE L-FIRST L-END L-REV L-ONQ.
    MOVE 0 TO L-REV L-ONQ
    EVALUATE TRUE
        WHEN L-SLOT = 1
            MOVE 1 TO L-RULE L-REV L-ONQ
            MOVE 2 TO L-FIRST
            MOVE 38 TO L-END
        WHEN L-SLOT = 0
            MOVE 2 TO L-RULE
            MOVE 2 TO L-FIRST
            MOVE 38 TO L-END
        WHEN L-SLOT >= 2 AND L-ACC = 1
            MOVE 3 TO L-RULE
            MOVE 0 TO L-FIRST
            MOVE 1 TO L-END
        WHEN L-SLOT >= 2 AND L-SLOT <= 28
            MOVE 4 TO L-RULE
            MOVE 29 TO L-FIRST
            MOVE 38 TO L-END
        WHEN OTHER
            MOVE 5 TO L-RULE
            MOVE 2 TO L-FIRST
            MOVE 29 TO L-END
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-STONE-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-ENDING.
*> USING count after, count before, source is the result slot, cleared out, returned out, dropped count out (4.7 ending).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AFTER                BINARY-LONG.
 01 L-BEFORE               BINARY-LONG.
 01 L-RES                  BINARY-LONG.
 01 L-CLEARED              BINARY-LONG.
 01 L-RET                  BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AFTER L-BEFORE L-RES L-CLEARED L-RET L-DROP.
    MOVE 0 TO L-CLEARED L-RET L-DROP
    IF L-AFTER = 0
        MOVE 1 TO L-CLEARED
    END-IF
    IF L-AFTER NOT = L-BEFORE
        MOVE 1 TO L-RET
        IF L-RES = 1
            MOVE L-AFTER TO L-DROP
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN4-STONE-ENDING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-ROWS.
*> USING recipe count, offscreen rows out, scroll bar active out (4.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-OFF                  BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-OFF L-ACTIVE.
    COMPUTE WS-Q = (L-N + 3) / 4
    COMPUTE L-OFF = WS-Q - 3
    MOVE 0 TO L-ACTIVE
    IF L-N > 12
        MOVE 1 TO L-ACTIVE
    END-IF
    GOBACK.
 END PROGRAM MN4-STONE-ROWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-THUMB.
*> USING scrollOffs, thumb y out (4.9): 15 + int(41 x scrollOffs).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T BINARY-LONG.
 LINKAGE SECTION.
 01 L-SO                   FLOAT-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SO L-Y.
    COMPUTE WS-T = 41 * L-SO
    COMPUTE L-Y = 15 + WS-T
    GOBACK.
 END PROGRAM MN4-STONE-THUMB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-DRAG.
*> USING mouse y, topPos, offscreen rows, unused, scrollOffs out (x 1e6), start index out (4.9 drag).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S FLOAT-LONG.
 01 WS-X FLOAT-LONG.
 01 WS-Q BINARY-LONG.
 LINKAGE SECTION.
 01 L-MY                   BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-OFF                  BINARY-LONG.
 01 L-SO0                  FLOAT-LONG.
 01 L-SO                   BINARY-LONG.
 01 L-START                BINARY-LONG.
 PROCEDURE DIVISION USING L-MY L-TOP L-OFF L-SO0 L-SO L-START.
    COMPUTE WS-S = (L-MY - (L-TOP + 14) - 7.5) / 39
    COMPUTE WS-S = FUNCTION MAX(0, FUNCTION MIN(1, WS-S))
    COMPUTE L-SO ROUNDED = WS-S * 1000000
    COMPUTE WS-X = WS-S * L-OFF + 0.5
    MOVE WS-X TO WS-Q
    COMPUTE L-START = WS-Q * 4
    GOBACK.
 END PROGRAM MN4-STONE-DRAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-WHEEL.
*> USING scrollOffs, scroll y, offscreen rows (above 0), scrollOffs out (x 1e6), start index out (4.9 wheel).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S FLOAT-LONG.
 01 WS-X FLOAT-LONG.
 01 WS-Q BINARY-LONG.
 LINKAGE SECTION.
 01 L-SO                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-OFF                  BINARY-LONG.
 01 L-SO2                  BINARY-LONG.
 01 L-START                BINARY-LONG.
 PROCEDURE DIVISION USING L-SO L-SY L-OFF L-SO2 L-START.
    COMPUTE WS-S = L-SO - L-SY / L-OFF
    COMPUTE WS-S = FUNCTION MAX(0, FUNCTION MIN(1, WS-S))
    COMPUTE L-SO2 ROUNDED = WS-S * 1000000
    COMPUTE WS-X = WS-S * L-OFF + 0.5
    MOVE WS-X TO WS-Q
    COMPUTE L-START = WS-Q * 4
    GOBACK.
 END PROGRAM MN4-STONE-WHEEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-CELL.
*> USING visible position k, sprite x out, sprite y out, item x out, item y out, click x out, click y out (4.9 cell geometry).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COL BINARY-LONG.
 01 WS-ROW BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-IY                   BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-SX L-SY L-IX L-IY L-CX L-CY.
    COMPUTE WS-COL = FUNCTION MOD(L-K, 4)
    COMPUTE WS-ROW = (L-K - WS-COL) / 4
    COMPUTE L-SX = 52 + 16 * WS-COL
    COMPUTE L-SY = 14 + 18 * WS-ROW + 1
    MOVE L-SX TO L-IX L-CX
    COMPUTE L-IY = L-SY + 1
    COMPUTE L-CY = L-SY - 1
    GOBACK.
 END PROGRAM MN4-STONE-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-SCROLL-HIT.
*> USING x, y relative to the window, scrolling starts out (x 119 to 130, y 9 to 62) (4.9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-START                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-START.
    MOVE 0 TO L-START
    IF L-X >= 119 AND L-X < 131 AND L-Y >= 9 AND L-Y < 63
        MOVE 1 TO L-START
    END-IF
    GOBACK.
 END PROGRAM MN4-STONE-SCROLL-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-STONE-LISTEN.
*> USING the input slot has an item, list size, grid shown out, scrollOffs out, start index out (4.9 containerChanged).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-DISPLAY              BINARY-LONG.
 01 L-SO                   BINARY-LONG.
 01 L-START                BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-SIZE L-DISPLAY L-SO L-START.
    MOVE 0 TO L-DISPLAY L-SO L-START
    IF L-HAS = 1 AND L-SIZE > 0
        MOVE 1 TO L-DISPLAY
    END-IF
    GOBACK.
 END PROGRAM MN4-STONE-LISTEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-SLOT.
*> USING menu slot, part out (0 none, 1 own, 2 player), x out, y out (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REL BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-PART L-X L-Y.
    MOVE 0 TO L-PART L-X L-Y
    EVALUATE TRUE
        WHEN L-SLOT = 0
            MOVE 1 TO L-PART
            MOVE 15 TO L-X L-Y
        WHEN L-SLOT = 1
            MOVE 1 TO L-PART
            MOVE 15 TO L-X
            MOVE 52 TO L-Y
        WHEN L-SLOT = 2
            MOVE 1 TO L-PART
            MOVE 145 TO L-X
            MOVE 39 TO L-Y
        WHEN L-SLOT >= 3 AND L-SLOT <= 38
            MOVE 2 TO L-PART
            COMPUTE WS-REL = L-SLOT - 3
            CALL "MN2-STD-INV" USING WS-REL L-X L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-CARTO-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-MAYPLACE.
*> USING slot, has map_id, is paper, is the empty map, is a glass pane, ok out (5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-MAPID                BINARY-LONG.
 01 L-PAPER                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-GLASS                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-MAPID L-PAPER L-EMPTY L-GLASS L-OK.
    MOVE 0 TO L-OK
    EVALUATE L-SLOT
        WHEN 0
            MOVE L-MAPID TO L-OK
        WHEN 1
            IF L-PAPER = 1 OR L-EMPTY = 1 OR L-GLASS = 1
                MOVE 1 TO L-OK
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-CARTO-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-CHANGED.
*> USING result has an item, map slot empty, additional slot empty, action out (0 nothing, 1 remove the result silently, 2 set up the result) (5.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RH                   BINARY-LONG.
 01 L-ME                   BINARY-LONG.
 01 L-EE                   BINARY-LONG.
 01 L-ACT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-RH L-ME L-EE L-ACT.
    MOVE 0 TO L-ACT
    EVALUATE TRUE
        WHEN L-RH = 1 AND (L-ME = 1 OR L-EE = 1)
            MOVE 1 TO L-ACT
        WHEN L-RH = 0 AND L-ME = 0 AND L-EE = 0
            MOVE 2 TO L-ACT
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-CARTO-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-SETUP.
*> USING additional kind (1 paper, 2 empty map, 3 glass pane, 0 other), the map item is in extendable_maps, the map is locked, its scale, the saved map exists, action out (0 unchanged, 1 remove the result, 2 set it), result count out, post-processing out (0 none, 1 SCALE, 2 LOCK) (5.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-LOCKED               BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-ACT                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-POST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-EXT L-LOCKED L-SCALE L-FOUND L-ACT L-COUNT L-POST.
    MOVE 0 TO L-ACT L-COUNT L-POST
    IF L-FOUND = 1
        MOVE 1 TO L-ACT
        EVALUATE TRUE
            WHEN L-KIND = 1 AND L-EXT = 1 AND L-LOCKED = 0 AND L-SCALE < 4
                MOVE 2 TO L-ACT
                MOVE 1 TO L-COUNT L-POST
            WHEN L-KIND = 3 AND L-LOCKED = 0
                MOVE 2 TO L-ACT
                MOVE 1 TO L-COUNT
                MOVE 2 TO L-POST
            WHEN L-KIND = 2
                MOVE 2 TO L-ACT L-COUNT
        END-EVALUATE
    END-IF
    GOBACK.
 END PROGRAM MN4-CARTO-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-TAKE.
*> USING map slot count, additional slot count, new map count out, new additional count out (5.4 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAPC                 BINARY-LONG.
 01 L-ADDC                 BINARY-LONG.
 01 L-NM                   BINARY-LONG.
 01 L-NA                   BINARY-LONG.
 PROCEDURE DIVISION USING L-MAPC L-ADDC L-NM L-NA.
    COMPUTE L-NM = L-MAPC - 1
    COMPUTE L-NA = L-ADDC - 1
    GOBACK.
 END PROGRAM MN4-CARTO-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-POST.
*> USING post-processing (0 none, 1 SCALE, 2 LOCK), server level, scale of the original, new saved map made out, scale of the taken map out, locked out (5.4 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POST                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 01 L-MADE                 BINARY-LONG.
 01 L-NSCALE               BINARY-LONG.
 01 L-LOCKED               BINARY-LONG.
 PROCEDURE DIVISION USING L-POST L-SERVER L-SCALE L-MADE L-NSCALE L-LOCKED.
    MOVE 0 TO L-MADE L-LOCKED
    MOVE L-SCALE TO L-NSCALE
    IF L-POST > 0 AND L-SERVER = 1
        MOVE 1 TO L-MADE
        IF L-POST = 1
            COMPUTE L-NSCALE = L-SCALE + 1
        ELSE
            MOVE 1 TO L-LOCKED
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN4-CARTO-POST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-QUICK.
*> USING source slot, has map_id, is paper or the empty map or a glass pane, rule out (1 to 6), first out, end out, reverse out, onQuickCraft out (5.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-MAPID                BINARY-LONG.
 01 L-PMG                  BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REV                  BINARY-LONG.
 01 L-ONQ                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-MAPID L-PMG L-RULE L-FIRST L-END L-REV L-ONQ.
    MOVE 0 TO L-REV L-ONQ
    EVALUATE TRUE
        WHEN L-SLOT = 2
            MOVE 1 TO L-RULE L-REV L-ONQ
            MOVE 3 TO L-FIRST
            MOVE 39 TO L-END
        WHEN L-SLOT = 0 OR L-SLOT = 1
            MOVE 2 TO L-RULE
            MOVE 3 TO L-FIRST
            MOVE 39 TO L-END
        WHEN L-SLOT >= 3 AND L-MAPID = 1
            MOVE 3 TO L-RULE
            MOVE 0 TO L-FIRST
            MOVE 1 TO L-END
        WHEN L-SLOT >= 3 AND L-PMG = 1
            MOVE 4 TO L-RULE
            MOVE 1 TO L-FIRST
            MOVE 2 TO L-END
        WHEN L-SLOT >= 3 AND L-SLOT <= 29
            MOVE 5 TO L-RULE
            MOVE 30 TO L-FIRST
            MOVE 39 TO L-END
        WHEN OTHER
            MOVE 6 TO L-RULE
            MOVE 3 TO L-FIRST
            MOVE 30 TO L-END
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-CARTO-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-MODE.
*> USING has map_id, saved map found, locked, additional is paper, glass pane, empty map, map item in extendable_maps, scale, error out, error sprite out, preview case out (1 scaled, 2 duplicate, 3 glass, 4 other) (5.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAPID                BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-LOCKED               BINARY-LONG.
 01 L-PAPER                BINARY-LONG.
 01 L-GLASS                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 01 L-ERR                  BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 01 L-CASE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MAPID L-FOUND L-LOCKED L-PAPER L-GLASS L-EMPTY L-EXT L-SCALE L-ERR L-SPRITE L-CASE.
    MOVE 0 TO L-ERR L-SPRITE
    IF L-MAPID = 1 AND L-FOUND = 1
        IF L-LOCKED = 1
            MOVE 1 TO L-ERR
            IF L-PAPER = 1 OR L-GLASS = 1
                MOVE 1 TO L-SPRITE
            END-IF
        END-IF
        IF L-PAPER = 1 AND (L-EXT = 0 OR L-SCALE >= 4)
            MOVE 1 TO L-ERR L-SPRITE
        END-IF
    END-IF
    EVALUATE TRUE
        WHEN L-PAPER = 1 AND L-ERR = 0
            MOVE 1 TO L-CASE
        WHEN L-EMPTY = 1
            MOVE 2 TO L-CASE
        WHEN L-GLASS = 1
            MOVE 3 TO L-CASE
        WHEN OTHER
            MOVE 4 TO L-CASE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-CARTO-MODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-PREVIEW.
*> USING preview case 1 to 4, frame sprite (1 scaled_map, 2 duplicated_map, 3 map) out, frame x, y, map x, y, map scale x 1000, second sprite (0 none, 2 duplicated_map, 4 locked) out, its x, y, second map x, y (5.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PV.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 67.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 85.
    05 FILLER BINARY-LONG VALUE 31.
    05 FILLER BINARY-LONG VALUE 226.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 83.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 86.
    05 FILLER BINARY-LONG VALUE 16.
    05 FILLER BINARY-LONG VALUE 340.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 67.
    05 FILLER BINARY-LONG VALUE 29.
    05 FILLER BINARY-LONG VALUE 70.
    05 FILLER BINARY-LONG VALUE 32.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 67.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 71.
    05 FILLER BINARY-LONG VALUE 17.
    05 FILLER BINARY-LONG VALUE 450.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 118.
    05 FILLER BINARY-LONG VALUE 60.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 67.
    05 FILLER BINARY-LONG VALUE 13.
    05 FILLER BINARY-LONG VALUE 71.
    05 FILLER BINARY-LONG VALUE 17.
    05 FILLER BINARY-LONG VALUE 450.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
 01 FILLER REDEFINES WS-PV.
    05 WS-P BINARY-LONG OCCURS 44 TIMES.
 01 WS-BASE BINARY-LONG.
 01 WS-K BINARY-LONG.
 LINKAGE SECTION.
 01 L-CASE                 BINARY-LONG.
 01 L-S1                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-MX                   BINARY-LONG.
 01 L-MY                   BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 01 L-S2                   BINARY-LONG.
 01 L-X2                   BINARY-LONG.
 01 L-Y2                   BINARY-LONG.
 01 L-MX2                  BINARY-LONG.
 01 L-MY2                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-S1 L-X1 L-Y1 L-MX L-MY L-SCALE L-S2 L-X2 L-Y2 L-MX2 L-MY2.
    COMPUTE WS-BASE = (L-CASE - 1) * 11
    MOVE WS-P(WS-BASE + 1) TO L-S1
    MOVE WS-P(WS-BASE + 2) TO L-X1
    MOVE WS-P(WS-BASE + 3) TO L-Y1
    MOVE WS-P(WS-BASE + 4) TO L-MX
    MOVE WS-P(WS-BASE + 5) TO L-MY
    MOVE WS-P(WS-BASE + 6) TO L-SCALE
    MOVE WS-P(WS-BASE + 7) TO L-S2
    MOVE WS-P(WS-BASE + 8) TO L-X2
    MOVE WS-P(WS-BASE + 9) TO L-Y2
    MOVE WS-P(WS-BASE + 10) TO L-MX2
    MOVE WS-P(WS-BASE + 11) TO L-MY2
    GOBACK.
 END PROGRAM MN4-CARTO-PREVIEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-CARTO-ERROR.
*> USING error sprite x, y, title label y out (5.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-TY.
    MOVE 35 TO L-X
    MOVE 31 TO L-Y
    MOVE 4 TO L-TY
    GOBACK.
 END PROGRAM MN4-CARTO-ERROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-PACKET.
*> USING index 1 to 5 (Open Screen, Container Button Click, Container Set Data, Container Set Slot, Update Recipes), packet id out, sent per open or action out (6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-PER                  BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-ID L-PER.
    MOVE 1 TO L-PER
    EVALUATE L-I
        WHEN 1
            MOVE 60 TO L-ID
        WHEN 2
            MOVE 17 TO L-ID
        WHEN 3
            MOVE 19 TO L-ID
        WHEN 4
            MOVE 20 TO L-ID
        WHEN OTHER
            MOVE 136 TO L-ID
            MOVE 0 TO L-PER
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN4-PROPERTIES.
*> USING menu kind, data slot count out, first property id out (-1 for none) (6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-COUNT L-FIRST.
    MOVE 0 TO L-COUNT
    MOVE 0 TO L-FIRST
    EVALUATE L-KIND
        WHEN 1
            MOVE 10 TO L-COUNT
        WHEN 3
            MOVE -1 TO L-FIRST
        WHEN OTHER
            MOVE 1 TO L-COUNT
    END-EVALUATE
    GOBACK.
 END PROGRAM MN4-PROPERTIES.
