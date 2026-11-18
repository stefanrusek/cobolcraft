*> The loom as a live station menu (docs/protocol/40-menus-4 section 3, 31-3 section 3.4, 25-7 section 11; lane p70c, T23500): station kind 5, MN-CFAMILY 25; own slots 0 the banner, 1 the dye,
*> 2 the pattern item (MN-WSLOT 1 to 3), own slot 3 the result (MN-RESULT-*, MN-WRES 3). The one data slot is MN-WDATA(1), the selected index of the list (-1 none), also MN-WSEL. The list is not
*> kept: it follows the pattern slot (the 32 no_item_required patterns in tag order for an empty slot, the pattern of a pattern item, else none) and is empty while the banner or the dye slot is
*> empty. MN-WKEEP holds the registry position + 1 of the selected pattern (0 none), so that a selection survives a change of the list when the same pattern is still offered (3.5 step 3).
*> A stack of a banner is a banner of one of the 16 colours; the dye slot takes the dyes of the tag loom_dyes (the 16 "<colour>_dye" items); the pattern slot the items of the tag loom_patterns
*> that carry a provides_banner_patterns set (the ten "<name>_banner_pattern" items of 25-7 section 11.1, one pattern each). The result is one banner with the layer (pattern, dye colour) added.
*>   LOOM-BANNER-OF USING item, colour out          the colour of a banner item (-1 for any other item)
*>   LOOM-DYE-OF USING item, colour out             the colour of a loom dye (the tag loom_dyes and the dye component; -1 for any other item)
*>   LOOM-PATTERN-OF USING item, pattern out        the registry position of the pattern a pattern item provides (in loom_patterns; -1 for any other item)
*>   LOOM-LIST USING pattern item (0 empty slot), list out (43 positions), size out     getSelectablePatterns (3.4)
*>   MENU-LOOM-MAYPLACE USING own slot, item, ok out   mayPlace of 3.2
*>   MENU-LOOM-UPDATE USING row                     slotsChanged (3.5)
*>   MENU-LOOM-BUTTON USING row, button id, returned out   clickMenuButton (3.6)
*>   MENU-LOOM-TAKEN USING row                      onTake (3.7 steps 1 and 2)
*>   MENU-LOOM-QUICK USING row, menu slot, item out, count out   quickMoveStack (3.8)
*> Gaps: UI_LOOM_TAKE_RESULT is not played (40-4 open question 9: the sound keys were not looked up).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOM-BANNER-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SUFFIX              PIC X(8) VALUE "_banner".
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-COLOUR.
     CALL "CRAFT-COLOR-OF" USING L-ITEM WS-SUFFIX L-COLOUR
     GOBACK.
 END PROGRAM LOOM-BANNER-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOM-DYE-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SUFFIX              PIC X(8) VALUE "_dye".
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:loom_dyes".
 01 WS-TAGGED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-COLOUR.
     CALL "CRAFT-COLOR-OF" USING L-ITEM WS-SUFFIX L-COLOUR
     IF L-COLOUR >= 0
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-ITEM WS-TAGGED
         IF WS-TAGGED = 0
             MOVE -1 TO L-COLOUR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LOOM-DYE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOM-PATTERN-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-ROWS.
    05 FILLER PIC X(48) VALUE "flower_banner_pattern".
    05 FILLER PIC X(24) VALUE "flower".
    05 FILLER PIC X(48) VALUE "creeper_banner_pattern".
    05 FILLER PIC X(24) VALUE "creeper".
    05 FILLER PIC X(48) VALUE "skull_banner_pattern".
    05 FILLER PIC X(24) VALUE "skull".
    05 FILLER PIC X(48) VALUE "mojang_banner_pattern".
    05 FILLER PIC X(24) VALUE "mojang".
    05 FILLER PIC X(48) VALUE "globe_banner_pattern".
    05 FILLER PIC X(24) VALUE "globe".
    05 FILLER PIC X(48) VALUE "piglin_banner_pattern".
    05 FILLER PIC X(24) VALUE "piglin".
    05 FILLER PIC X(48) VALUE "flow_banner_pattern".
    05 FILLER PIC X(24) VALUE "flow".
    05 FILLER PIC X(48) VALUE "guster_banner_pattern".
    05 FILLER PIC X(24) VALUE "guster".
    05 FILLER PIC X(48) VALUE "field_masoned_banner_pattern".
    05 FILLER PIC X(24) VALUE "bricks".
    05 FILLER PIC X(48) VALUE "bordure_indented_banner_pattern".
    05 FILLER PIC X(24) VALUE "curly_border".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 10 TIMES.
       10 WS-ITEM-NAME     PIC X(48).
       10 WS-PATTERN-NAME  PIC X(24).
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:loom_patterns".
 01 WS-TAGGED              BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-PATTERN             PIC X(32).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-PATTERN              BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-PATTERN.
     MOVE -1 TO L-PATTERN
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-ITEM WS-TAGGED
     IF WS-TAGGED = 0
         GOBACK
     END-IF
     MOVE IT-KEY(L-ITEM + 1) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         IF WS-ITEM-NAME(WS-I) = WS-BARE
             MOVE SPACES TO WS-PATTERN
             MOVE WS-PATTERN-NAME(WS-I) TO WS-PATTERN
             COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-PATTERN TRAILING))
             CALL "BE3-BANNER-PATTERN" USING WS-PATTERN WS-LENGTH L-PATTERN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LOOM-PATTERN-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOM-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
*> The tag no_item_required in its order (31-3 section 3.4).
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "square_bottom_left".
    05 FILLER PIC X(24) VALUE "square_bottom_right".
    05 FILLER PIC X(24) VALUE "square_top_left".
    05 FILLER PIC X(24) VALUE "square_top_right".
    05 FILLER PIC X(24) VALUE "stripe_bottom".
    05 FILLER PIC X(24) VALUE "stripe_top".
    05 FILLER PIC X(24) VALUE "stripe_left".
    05 FILLER PIC X(24) VALUE "stripe_right".
    05 FILLER PIC X(24) VALUE "stripe_center".
    05 FILLER PIC X(24) VALUE "stripe_middle".
    05 FILLER PIC X(24) VALUE "stripe_downright".
    05 FILLER PIC X(24) VALUE "stripe_downleft".
    05 FILLER PIC X(24) VALUE "small_stripes".
    05 FILLER PIC X(24) VALUE "cross".
    05 FILLER PIC X(24) VALUE "straight_cross".
    05 FILLER PIC X(24) VALUE "triangle_bottom".
    05 FILLER PIC X(24) VALUE "triangle_top".
    05 FILLER PIC X(24) VALUE "triangles_bottom".
    05 FILLER PIC X(24) VALUE "triangles_top".
    05 FILLER PIC X(24) VALUE "diagonal_left".
    05 FILLER PIC X(24) VALUE "diagonal_up_right".
    05 FILLER PIC X(24) VALUE "diagonal_up_left".
    05 FILLER PIC X(24) VALUE "diagonal_right".
    05 FILLER PIC X(24) VALUE "circle".
    05 FILLER PIC X(24) VALUE "rhombus".
    05 FILLER PIC X(24) VALUE "half_vertical".
    05 FILLER PIC X(24) VALUE "half_horizontal".
    05 FILLER PIC X(24) VALUE "half_vertical_right".
    05 FILLER PIC X(24) VALUE "half_horizontal_bottom".
    05 FILLER PIC X(24) VALUE "border".
    05 FILLER PIC X(24) VALUE "gradient".
    05 FILLER PIC X(24) VALUE "gradient_up".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-NAME             PIC X(24) OCCURS 32 TIMES.
 01 WS-PATTERN             PIC X(32).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-LIST.
    05 L-POS               BINARY-LONG OCCURS 43 TIMES.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-LIST L-SIZE.
     MOVE 0 TO L-SIZE
     IF L-ITEM = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
             MOVE SPACES TO WS-PATTERN
             MOVE WS-NAME(WS-I) TO WS-PATTERN
             COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-PATTERN TRAILING))
             CALL "BE3-BANNER-PATTERN" USING WS-PATTERN WS-LENGTH WS-P
             ADD 1 TO L-SIZE
             MOVE WS-P TO L-POS(L-SIZE)
         END-PERFORM
         GOBACK
     END-IF
     CALL "LOOM-PATTERN-OF" USING L-ITEM WS-P
     IF WS-P >= 0
         MOVE 1 TO L-SIZE
         MOVE WS-P TO L-POS(1)
     END-IF
     GOBACK.
 END PROGRAM LOOM-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-LOOM-MAYPLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-PATTERN             BINARY-LONG.
 01 WS-BANNER              BINARY-LONG.
 01 WS-DT                  BINARY-LONG.
 01 WS-DC                  BINARY-LONG.
 01 WS-PT                  BINARY-LONG.
 01 WS-PC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ITEM L-OK.
     MOVE 0 TO WS-BANNER WS-DT WS-DC WS-PT WS-PC
     CALL "LOOM-BANNER-OF" USING L-ITEM WS-COLOUR
     IF WS-COLOUR >= 0
         MOVE 1 TO WS-BANNER
     END-IF
     CALL "LOOM-DYE-OF" USING L-ITEM WS-COLOUR
     IF WS-COLOUR >= 0
         MOVE 1 TO WS-DT WS-DC
     END-IF
     CALL "LOOM-PATTERN-OF" USING L-ITEM WS-PATTERN
     IF WS-PATTERN >= 0
         MOVE 1 TO WS-PT WS-PC
     END-IF
     CALL "MN4-LOOM-MAYPLACE" USING L-SLOT WS-BANNER WS-DT WS-DC WS-PT WS-PC L-OK
     GOBACK.
 END PROGRAM MENU-LOOM-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOM-SETUP.
*> USING row, pattern position: setupResultSlot (3.5): the banner with the layer added, or an empty result.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PATTERN              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PATTERN.
     MOVE 0 TO MN-RESULT-ITEM(L-ROW) MN-RESULT-COUNT(L-ROW) MN-RESULT-VAR(L-ROW)
     IF MN-WSLOT-COUNT(L-ROW, 1) = 0 OR MN-WSLOT-COUNT(L-ROW, 2) = 0
         GOBACK
     END-IF
     CALL "LOOM-DYE-OF" USING MN-WSLOT-ITEM(L-ROW, 2) WS-COLOUR
     IF WS-COLOUR < 0
         GOBACK
     END-IF
     MOVE MN-WSLOT-VAR(L-ROW, 1) TO WS-HANDLE
     CALL "SC-BANNER-ADD" USING WS-HANDLE L-PATTERN WS-COLOUR
     MOVE MN-WSLOT-ITEM(L-ROW, 1) TO MN-RESULT-ITEM(L-ROW)
     MOVE 1 TO MN-RESULT-COUNT(L-ROW)
     MOVE WS-HANDLE TO MN-RESULT-VAR(L-ROW)
     GOBACK.
 END PROGRAM LOOM-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-LOOM-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-LIST.
    05 WS-POS              BINARY-LONG OCCURS 43 TIMES.
 01 WS-SIZE                BINARY-LONG.
 01 WS-PITEM               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEL                 BINARY-LONG.
 01 WS-CHOSEN              BINARY-LONG.
 01 WS-LAYERS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF MN-WSLOT-COUNT(L-ROW, 1) = 0 OR MN-WSLOT-COUNT(L-ROW, 2) = 0
         MOVE 0 TO MN-RESULT-ITEM(L-ROW) MN-RESULT-COUNT(L-ROW) MN-RESULT-VAR(L-ROW) MN-WKEEP(L-ROW)
         MOVE -1 TO MN-WSEL(L-ROW) MN-WDATA(L-ROW, 1)
         GOBACK
     END-IF
     MOVE 0 TO WS-PITEM
     IF MN-WSLOT-COUNT(L-ROW, 3) > 0
         MOVE MN-WSLOT-ITEM(L-ROW, 3) TO WS-PITEM
     END-IF
     CALL "LOOM-LIST" USING WS-PITEM WS-LIST WS-SIZE
     MOVE -1 TO WS-SEL WS-CHOSEN
     EVALUATE TRUE
         WHEN WS-SIZE = 1
             MOVE 0 TO WS-SEL
             MOVE WS-POS(1) TO WS-CHOSEN
         WHEN MN-WKEEP(L-ROW) > 0
             PERFORM VARYING WS-I FROM WS-SIZE BY -1 UNTIL WS-I < 1
                 IF WS-POS(WS-I) + 1 = MN-WKEEP(L-ROW)
                     COMPUTE WS-SEL = WS-I - 1
                     MOVE WS-POS(WS-I) TO WS-CHOSEN
                 END-IF
             END-PERFORM
     END-EVALUATE
     MOVE 0 TO MN-RESULT-ITEM(L-ROW) MN-RESULT-COUNT(L-ROW) MN-RESULT-VAR(L-ROW)
     IF WS-CHOSEN >= 0
         CALL "SC-BANNER-COUNT" USING MN-WSLOT-VAR(L-ROW, 1) WS-LAYERS
         IF WS-LAYERS >= 6
             MOVE -1 TO WS-SEL WS-CHOSEN
         ELSE
             CALL "LOOM-SETUP" USING L-ROW WS-CHOSEN
         END-IF
     END-IF
     MOVE WS-SEL TO MN-WSEL(L-ROW) MN-WDATA(L-ROW, 1)
     MOVE 0 TO MN-WKEEP(L-ROW)
     IF WS-CHOSEN >= 0
         COMPUTE MN-WKEEP(L-ROW) = WS-CHOSEN + 1
     END-IF
     GOBACK.
 END PROGRAM MENU-LOOM-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-LOOM-BUTTON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-LIST.
    05 WS-POS              BINARY-LONG OCCURS 43 TIMES.
 01 WS-SIZE                BINARY-LONG.
 01 WS-PITEM               BINARY-LONG.
 01 WS-SEL                 BINARY-LONG.
 01 WS-SETUP               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-RETURNED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BUTTON L-RETURNED.
     MOVE 0 TO WS-SIZE WS-PITEM
     IF MN-WSLOT-COUNT(L-ROW, 1) > 0 AND MN-WSLOT-COUNT(L-ROW, 2) > 0
         IF MN-WSLOT-COUNT(L-ROW, 3) > 0
             MOVE MN-WSLOT-ITEM(L-ROW, 3) TO WS-PITEM
         END-IF
         CALL "LOOM-LIST" USING WS-PITEM WS-LIST WS-SIZE
     END-IF
     CALL "MN4-LOOM-BUTTON" USING L-BUTTON WS-SIZE L-RETURNED WS-SEL WS-SETUP
     IF WS-SETUP = 1
         MOVE WS-SEL TO MN-WSEL(L-ROW) MN-WDATA(L-ROW, 1)
         COMPUTE MN-WKEEP(L-ROW) = WS-POS(WS-SEL + 1) + 1
         CALL "LOOM-SETUP" USING L-ROW WS-POS(WS-SEL + 1)
     END-IF
     GOBACK.
 END PROGRAM MENU-LOOM-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-LOOM-TAKEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-NB                  BINARY-LONG.
 01 WS-ND                  BINARY-LONG.
 01 WS-RESET               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MN4-LOOM-TAKE" USING MN-WSLOT-COUNT(L-ROW, 1) MN-WSLOT-COUNT(L-ROW, 2) WS-NB WS-ND WS-RESET
     MOVE WS-NB TO MN-WSLOT-COUNT(L-ROW, 1)
     MOVE WS-ND TO MN-WSLOT-COUNT(L-ROW, 2)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         IF MN-WSLOT-COUNT(L-ROW, WS-I) = 0
             MOVE 0 TO MN-WSLOT-ITEM(L-ROW, WS-I) MN-WSLOT-VAR(L-ROW, WS-I)
         END-IF
     END-PERFORM
     IF WS-RESET = 1
         MOVE -1 TO MN-WSEL(L-ROW) MN-WDATA(L-ROW, 1)
         MOVE 0 TO MN-WKEEP(L-ROW)
     END-IF
     CALL "MENU-STATION-UPDATE" USING L-ROW
     GOBACK.
 END PROGRAM MENU-LOOM-TAKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-LOOM-QUICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-PATTERN             BINARY-LONG.
 01 WS-BANNER              BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-PITEM               BINARY-LONG.
 01 WS-RULE                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REV                 BINARY-LONG.
 01 WS-ONQ                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-BANNER WS-DYE WS-PITEM
     CALL "LOOM-BANNER-OF" USING WS-ITEM WS-COLOUR
     IF WS-COLOUR >= 0
         MOVE 1 TO WS-BANNER
     END-IF
     CALL "LOOM-DYE-OF" USING WS-ITEM WS-COLOUR
     IF WS-COLOUR >= 0
         MOVE 1 TO WS-DYE
     END-IF
     CALL "LOOM-PATTERN-OF" USING WS-ITEM WS-PATTERN
     IF WS-PATTERN >= 0
         MOVE 1 TO WS-PITEM
     END-IF
     CALL "MN4-LOOM-QUICK" USING L-SLOT WS-BANNER WS-DYE WS-PITEM WS-RULE WS-FIRST WS-END WS-REV WS-ONQ
     MOVE WS-COUNT TO WS-LEFT
     MOVE 0 TO WS-MOVED
     CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REV WS-MOVED WS-VAR
     IF WS-MOVED = 0
         GOBACK
     END-IF
*>   The result is one banner, so a move that took anything took all of it.
     IF L-SLOT = 3
         CALL "MENU-SET-X" USING L-ROW L-SLOT WS-ITEM WS-ZERO WS-VAR
         CALL "MENU-STATION-TAKEN" USING L-ROW
         MOVE WS-ITEM TO L-RET-ITEM
         MOVE WS-COUNT TO L-RET-COUNT
     ELSE
         CALL "MENU-QUICK-FINISH" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-LEFT WS-MOVED L-RET-ITEM L-RET-COUNT
     END-IF
     GOBACK.
 END PROGRAM MENU-LOOM-QUICK.
