*> The cycling template-hint icons of the smithing table (docs/protocol/40-menus-3-anvil-grindstone-smithing.md 5.6): three helpers for the slots 0, 1 and 2, each with a current icon list, a tick counter and an
*> icon index. SMITH-CYCLE-TICK is one client tick (containerTick): the lists are the two template icons for slot 0 and, from the template in slot 0 (an armor trim or netherite upgrade smithing template),
*> the base and addition icon lists for slots 1 and 2 (empty without a template). Changing a list resets the index (not the counter); with a list the counter grows and every 30th tick moves the index on.
*> SMITH-CYCLE-ICON names the icon a helper shows (the sprite under container/slot/) and its alpha in sixteenths; the sprites are not in the client's UI atlas, so nothing is drawn from it.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMITH-CYCLE-LIST.
*> USING list id (0 none; 1 slot 0 templates; 2 armor trim base; 3 armor trim addition; 4 netherite upgrade base; 5 netherite upgrade addition), size out, index (0 based), icon out (PIC X(40)): 5.6 tables.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ICONS.
    05 FILLER PIC X(40) VALUE "smithing_template_armor_trim".
    05 FILLER PIC X(40) VALUE "smithing_template_netherite_upgrade".
    05 FILLER PIC X(40) VALUE "helmet".
    05 FILLER PIC X(40) VALUE "chestplate".
    05 FILLER PIC X(40) VALUE "leggings".
    05 FILLER PIC X(40) VALUE "boots".
    05 FILLER PIC X(40) VALUE "ingot".
    05 FILLER PIC X(40) VALUE "redstone_dust".
    05 FILLER PIC X(40) VALUE "lapis_lazuli".
    05 FILLER PIC X(40) VALUE "quartz".
    05 FILLER PIC X(40) VALUE "diamond".
    05 FILLER PIC X(40) VALUE "emerald".
    05 FILLER PIC X(40) VALUE "amethyst_shard".
    05 FILLER PIC X(40) VALUE "helmet".
    05 FILLER PIC X(40) VALUE "sword".
    05 FILLER PIC X(40) VALUE "chestplate".
    05 FILLER PIC X(40) VALUE "pickaxe".
    05 FILLER PIC X(40) VALUE "leggings".
    05 FILLER PIC X(40) VALUE "axe".
    05 FILLER PIC X(40) VALUE "boots".
    05 FILLER PIC X(40) VALUE "hoe".
    05 FILLER PIC X(40) VALUE "shovel".
    05 FILLER PIC X(40) VALUE "nautilus_armor".
    05 FILLER PIC X(40) VALUE "spear".
    05 FILLER PIC X(40) VALUE "ingot".
 01 WS-TABLE REDEFINES WS-ICONS.
    05 WS-ICON             PIC X(40) OCCURS 25 TIMES.
 LINKAGE SECTION.
 01 L-LIST                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-ICON                 PIC X(40).
 PROCEDURE DIVISION USING L-LIST L-SIZE L-INDEX L-ICON.
     MOVE SPACES TO L-ICON
     EVALUATE L-LIST
         WHEN 1
             MOVE 2 TO L-SIZE
             MOVE WS-ICON(1 + L-INDEX) TO L-ICON
         WHEN 2
             MOVE 4 TO L-SIZE
             MOVE WS-ICON(3 + L-INDEX) TO L-ICON
         WHEN 3
             MOVE 7 TO L-SIZE
             MOVE WS-ICON(7 + L-INDEX) TO L-ICON
         WHEN 4
             MOVE 11 TO L-SIZE
             MOVE WS-ICON(14 + L-INDEX) TO L-ICON
         WHEN 5
             MOVE 1 TO L-SIZE
             MOVE WS-ICON(25 + L-INDEX) TO L-ICON
         WHEN OTHER
             MOVE 0 TO L-SIZE
     END-EVALUATE
     GOBACK.
 END PROGRAM SMITH-CYCLE-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMITH-CYCLE-TICK.
*> USING CLIENT-STATE: one tick of the three helpers (5.6) while the smithing table (menu type 21) is open.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEW                 BINARY-LONG OCCURS 3 TIMES.
 01 WS-ITEM                BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ICON                PIC X(40).
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF BM-ID = 0 OR BM-TYPE NOT = 21
         GOBACK
     END-IF
     MOVE 1 TO WS-NEW(1)
     MOVE 0 TO WS-NEW(2) WS-NEW(3)
     IF BX-COUNT(1) > 0
         MOVE BX-ITEM(1) TO WS-ITEM
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-LEN
         IF WS-KNOWN = 1 AND WS-LEN > 18 AND WS-PATH(WS-LEN - 17:18) = "_smithing_template"
             IF WS-PATH(1:17) = "netherite_upgrade"
                 MOVE 4 TO WS-NEW(2)
                 MOVE 5 TO WS-NEW(3)
             ELSE
                 MOVE 2 TO WS-NEW(2)
                 MOVE 3 TO WS-NEW(3)
             END-IF
         END-IF
     END-IF
     PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 3
         IF WS-NEW(WS-H) NOT = CY-LIST(WS-H)
             MOVE WS-NEW(WS-H) TO CY-LIST(WS-H)
             MOVE 0 TO CY-INDEX(WS-H)
         END-IF
         CALL "SMITH-CYCLE-LIST" USING CY-LIST(WS-H) WS-SIZE WS-ZERO WS-ICON
         IF WS-SIZE > 0
             ADD 1 TO CY-TICK(WS-H)
             IF FUNCTION MOD(CY-TICK(WS-H), 30) = 0
                 COMPUTE CY-INDEX(WS-H) = FUNCTION MOD(CY-INDEX(WS-H) + 1, WS-SIZE)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SMITH-CYCLE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMITH-CYCLE-ICON.
*> USING CLIENT-STATE, helper (1 to 3: the slots 0, 1, 2), icon out (PIC X(40), spaces when nothing is drawn), alpha out (0 to 16 sixteenths, partial tick 0): 5.6 draw: nothing for an empty list or
*> when the slot holds an item; while transitioning (a list over 1 and the counter at 30 or more) the alpha is min(counter mod 30, 4) / 4 (the previous icon, drawn at 1 - alpha first, is not returned).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIZE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HELPER               BINARY-LONG.
 01 L-ICON                 PIC X(40).
 01 L-ALPHA                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-HELPER L-ICON L-ALPHA.
     MOVE SPACES TO L-ICON
     MOVE 16 TO L-ALPHA
     CALL "SMITH-CYCLE-LIST" USING CY-LIST(L-HELPER) WS-SIZE CY-INDEX(L-HELPER) L-ICON
     IF WS-SIZE = 0 OR BX-COUNT(L-HELPER) > 0
         MOVE SPACES TO L-ICON
         MOVE 0 TO L-ALPHA
         GOBACK
     END-IF
     IF WS-SIZE > 1 AND CY-TICK(L-HELPER) >= 30
         COMPUTE L-ALPHA = 4 * FUNCTION MIN(FUNCTION MOD(CY-TICK(L-HELPER), 30), 4)
     END-IF
     GOBACK.
 END PROGRAM SMITH-CYCLE-ICON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMITH-ICON-ROW.
*> USING icon name (PIC X(40)), sprite row out (GSP-CSLOT-0 + n; 0 for no icon): the UI atlas row of a hint icon (the order of CLCONST GSP-CSLOT-0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-NAMES.
    05 FILLER PIC X(40) VALUE "smithing_template_armor_trim".
    05 FILLER PIC X(40) VALUE "smithing_template_netherite_upgrade".
    05 FILLER PIC X(40) VALUE "helmet".
    05 FILLER PIC X(40) VALUE "chestplate".
    05 FILLER PIC X(40) VALUE "leggings".
    05 FILLER PIC X(40) VALUE "boots".
    05 FILLER PIC X(40) VALUE "ingot".
    05 FILLER PIC X(40) VALUE "redstone_dust".
    05 FILLER PIC X(40) VALUE "lapis_lazuli".
    05 FILLER PIC X(40) VALUE "quartz".
    05 FILLER PIC X(40) VALUE "diamond".
    05 FILLER PIC X(40) VALUE "emerald".
    05 FILLER PIC X(40) VALUE "amethyst_shard".
    05 FILLER PIC X(40) VALUE "sword".
    05 FILLER PIC X(40) VALUE "pickaxe".
    05 FILLER PIC X(40) VALUE "axe".
    05 FILLER PIC X(40) VALUE "hoe".
    05 FILLER PIC X(40) VALUE "shovel".
    05 FILLER PIC X(40) VALUE "nautilus_armor".
    05 FILLER PIC X(40) VALUE "spear".
 01 WS-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(40) OCCURS 20 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ICON                 PIC X(40).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ICON L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         IF L-ICON = WS-NAME(WS-I) AND L-ICON NOT = SPACES
             COMPUTE L-ROW = GSP-CSLOT-0 + WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SMITH-ICON-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMITH-CYCLE-DRAW.
*> USING CLIENT-STATE, left, top: 5.6 draw for the three helpers at the slots (8, 48), (26, 48), (44, 48): nothing for an empty list or a slot with an item; while transitioning
*> (a list over 1 and the counter at 30 or more) the previous icon at alpha 1 - a first, then the current icon at alpha a, a = min(counter mod 30, 4) / 4 (partial tick 0); each icon a 16 x 16 sprite.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-H                   BINARY-LONG.
 01 WS-ICON                PIC X(40).
 01 WS-PREV                PIC X(40).
 01 WS-ALPHA               BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-PI                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 48.
 01 WS-16                  BINARY-LONG VALUE 16.
 01 WS-16H                 BINARY-LONG VALUE 16.
 01 WS-KIND                BINARY-LONG VALUE WK-SPRITE.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-TEXT                PIC X(512).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEFT L-TOP.
     PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 3
         CALL "SMITH-CYCLE-ICON" USING CLIENT-STATE WS-H WS-ICON WS-ALPHA
         IF WS-ICON NOT = SPACES
             COMPUTE WS-X = L-LEFT + 8 + 18 * (WS-H - 1)
             MOVE 48 TO WS-Y
             ADD L-TOP TO WS-Y
             IF WS-ALPHA < 16
                 CALL "SMITH-CYCLE-LIST" USING CY-LIST(WS-H) WS-SIZE WS-ZERO WS-PREV
                 COMPUTE WS-PI = FUNCTION MOD(CY-INDEX(WS-H) + WS-SIZE - 1, WS-SIZE)
                 CALL "SMITH-CYCLE-LIST" USING CY-LIST(WS-H) WS-SIZE WS-PI WS-PREV
                 CALL "SMITH-ICON-ROW" USING WS-PREV WS-ROW
                 COMPUTE WS-STATE = 1 + 1000 * WS-ALPHA / 16
                 IF WS-ROW > 0
                     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ROW WS-X WS-Y WS-16 WS-16H WS-TEXT WS-ZERO WS-STATE
                 END-IF
             END-IF
             CALL "SMITH-ICON-ROW" USING WS-ICON WS-ROW
             COMPUTE WS-STATE = 1 + 1000 * (16 - WS-ALPHA) / 16
             IF WS-ALPHA >= 16
                 MOVE 0 TO WS-STATE
             END-IF
             IF WS-ROW > 0
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ROW WS-X WS-Y WS-16 WS-16H WS-TEXT WS-ZERO WS-STATE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SMITH-CYCLE-DRAW.
