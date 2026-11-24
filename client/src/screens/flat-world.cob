*> The superflat customization screens of the create-world screen (docs/protocol/56-superflat-world.md §6.2, §6.3,
*> §6.6 minimal version): the flat editor (SCR-FLAT-EDIT) lists the layers of the working preset top layer first,
*> each as the block's name and its height ("Top - n" for the top row, "Bottom - n" for the bottom row, "n" between;
*> a single layer is "Top - n"), with Presets, Done and Cancel; the preset screen (SCR-FLAT-PRESETS) lists the nine
*> presets of §3.1 (CLFLAT.cpy) and Use Preset (enabled by a selected row) and Cancel. Done keeps the working preset
*> in SP-FLAT-PRESET, Cancel drops it. Not in this version, as §6.6 allows: Remove Layer, the preset text box and
*> its share string (§6.4) and the item icons, so the layers can only come from a preset. The core is handed only
*> the preset id (SP-FLAT-PRESET), which SP-OPEN passes to FLAT-PRESET-SET before CORE-WORLD-OPEN of a new superflat world.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-PRESET-FIND.
*> USING preset id (PIC X(24)), index out (BINARY-LONG): the row of the nine presets of CLFLAT.cpy or of the world preset `flat` (row 10), 0 for an unknown id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLFLAT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   PIC X(24).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FP-WORLD
         IF FP-ID(WS-I) = L-ID
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FLAT-PRESET-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-LAYER-NAME.
*> USING CLIENT-STATE, block name (PIC X(16), no namespace), text out (PIC X(512)), length out: the layer's name on the
*> editor row (56 6.2): the item name of the block (the block.minecraft.<name> text of the language), a water layer shows
*> the water bucket and a lava layer the lava bucket (item.minecraft.<name>); a name the language does not hold shows
*> as the registry name (the item's path, without namespace).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-BLOCK                PIC X(16).
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-BLOCK L-TEXT L-LENGTH.
     MOVE L-BLOCK TO WS-NAME
     EVALUATE L-BLOCK
         WHEN "water"
             MOVE "water_bucket" TO WS-NAME
         WHEN "lava"
             MOVE "lava_bucket" TO WS-NAME
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     MOVE SPACES TO WS-KEY
     IF WS-NAME = L-BLOCK
         STRING "block.minecraft." WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO WS-KEY
         COMPUTE WS-KEY-LENGTH = 16 + WS-NAME-LENGTH
     ELSE
         STRING "item.minecraft." WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO WS-KEY
         COMPUTE WS-KEY-LENGTH = 15 + WS-NAME-LENGTH
     END-IF
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
*>   LANG-GET answers an unknown key with the key itself.
     IF WS-LENGTH = WS-KEY-LENGTH AND WS-TEXT(1:WS-LENGTH) = WS-KEY(1:WS-KEY-LENGTH)
         MOVE WS-NAME TO WS-TEXT
         MOVE WS-NAME-LENGTH TO WS-LENGTH
     END-IF
     MOVE WS-TEXT TO L-TEXT
     MOVE WS-LENGTH TO L-LENGTH
     GOBACK.
 END PROGRAM FLAT-LAYER-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-EDIT-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height: the flat editor of the working preset SP-FLAT-WORK (56 6.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 COPY CLFLAT.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 200.
 01 WS-H                   BINARY-LONG VALUE 16.
 01 WS-B                   BINARY-LONG VALUE 20.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SHORT               PIC X(256).
 01 WS-WIDTH               BINARY-LONG.
 01 WS-NUMBER              PIC Z(3)9.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-Z5                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 100
     MOVE 8 TO WS-Y
     MOVE "createWorld.customize.flat.title" TO WS-KEY
     MOVE 32 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
*>   The header: Layer Material at the left edge of the list, Height right-aligned at its right edge.
     COMPUTE WS-X = L-GW / 2 - 150
     MOVE 28 TO WS-Y
     MOVE "createWorld.customize.flat.tile" TO WS-KEY
     MOVE 31 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     MOVE "createWorld.customize.flat.height" TO WS-KEY
     MOVE 33 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     MOVE WS-TEXT(1:256) TO WS-SHORT
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-SHORT WS-LENGTH WS-WIDTH
     COMPUTE WS-X = L-GW / 2 + 150 - WS-WIDTH
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z4 WS-X WS-Y WS-Z2 WS-Z3 WS-TEXT
         WS-LENGTH WS-Z5
*>   The layers, the top layer first: the block's name at the left, the height text at the right.
     CALL "FLAT-PRESET-FIND" USING SP-FLAT-WORK WS-P
     IF WS-P = 0
         MOVE 1 TO WS-P
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FP-LAYER-COUNT(WS-P)
         COMPUTE WS-LAYER = FP-LAYER-COUNT(WS-P) - WS-I + 1
         COMPUTE WS-Y = 42 + (WS-I - 1) * 18
         COMPUTE WS-X = L-GW / 2 - 150
         CALL "FLAT-LAYER-NAME" USING CLIENT-STATE FP-BLOCK(WS-P, WS-LAYER) WS-TEXT WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z4 WS-X WS-Y WS-Z2 WS-Z3 WS-TEXT
             WS-LENGTH WS-Z5
         MOVE FP-HEIGHT(WS-P, WS-LAYER) TO WS-NUMBER
         MOVE 1 TO LA-COUNT
         MOVE FUNCTION TRIM(WS-NUMBER) TO LA-TEXT(1)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NUMBER)) TO LA-LENGTH(1)
         MOVE "createWorld.customize.flat.layer" TO WS-KEY
         MOVE 32 TO WS-KEY-LENGTH
         EVALUATE TRUE
             WHEN WS-I = 1
                 MOVE "createWorld.customize.flat.layer.top" TO WS-KEY
                 MOVE 36 TO WS-KEY-LENGTH
             WHEN WS-LAYER = 1
                 MOVE "createWorld.customize.flat.layer.bottom" TO WS-KEY
                 MOVE 39 TO WS-KEY-LENGTH
         END-EVALUATE
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
         MOVE WS-TEXT(1:256) TO WS-SHORT
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-SHORT WS-LENGTH WS-WIDTH
         COMPUTE WS-X = L-GW / 2 + 150 - WS-WIDTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z4 WS-X WS-Y WS-Z2 WS-Z3 WS-TEXT
             WS-LENGTH WS-Z5
     END-PERFORM
*>   The footer: Presets, then Done and Cancel.
     MOVE WK-BUTTON TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 100
     COMPUTE WS-Y = L-GH - 52
     MOVE ACT-FLAT-PRESETS TO WS-ACTION
     MOVE "createWorld.customize.presets" TO WS-KEY
     MOVE 29 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-B WS-KEY
         WS-KEY-LENGTH
     COMPUTE WS-Y = L-GH - 28
     MOVE 98 TO WS-W
     MOVE ACT-FLAT-DONE TO WS-ACTION
     MOVE "cobolcraft.screen.common.done" TO WS-KEY
     MOVE 29 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-B WS-KEY
         WS-KEY-LENGTH
     ADD 102 TO WS-X
     MOVE ACT-FLAT-CANCEL TO WS-ACTION
     MOVE "cobolcraft.screen.common.cancel" TO WS-KEY
     MOVE 31 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-B WS-KEY
         WS-KEY-LENGTH
     MOVE 200 TO WS-W
     GOBACK.
 END PROGRAM FLAT-EDIT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-PRESETS-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height: the preset screen (56 6.3): the nine presets in the order of 56 3.1 as
*> selectable rows (SM-SELECTED the row, ACT-SELECT), Use Preset (disabled until a row is selected) and Cancel.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLFLAT.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 300.
 01 WS-H                   BINARY-LONG VALUE 16.
 01 WS-B                   BINARY-LONG VALUE 20.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 100
     MOVE 8 TO WS-Y
     MOVE "createWorld.customize.presets.title" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     COMPUTE WS-X = L-GW / 2 - 150
     MOVE 24 TO WS-Y
     MOVE "createWorld.customize.presets.list" TO WS-KEY
     MOVE 34 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     MOVE WK-ENTRY TO WS-KIND
     MOVE ACT-SELECT TO WS-ACTION
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FP-COUNT
         COMPUTE WS-Y = 38 + (WS-I - 1) * 17
         MOVE 0 TO WS-STATE
         IF WS-I = SM-SELECTED
             MOVE 1 TO WS-STATE
         END-IF
         MOVE SPACES TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(FP-ID(WS-I))) TO WS-ID-LENGTH
         STRING "flat_world_preset.minecraft." FP-ID(WS-I)(1:WS-ID-LENGTH) DELIMITED BY SIZE INTO WS-KEY
         COMPUTE WS-KEY-LENGTH = 28 + WS-ID-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-I WS-X WS-Y WS-W WS-H WS-TEXT
             WS-LENGTH WS-STATE
     END-PERFORM
     MOVE WK-BUTTON TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 100
     COMPUTE WS-Y = L-GH - 28
     MOVE 98 TO WS-W
     MOVE "createWorld.customize.presets.select" TO WS-KEY
     MOVE 36 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     MOVE 2 TO WS-STATE
     IF SM-SELECTED > 0
         MOVE 0 TO WS-STATE
     END-IF
     MOVE ACT-FLAT-USE TO WS-ACTION
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z1 WS-X WS-Y WS-W WS-B WS-TEXT
         WS-LENGTH WS-STATE
     ADD 102 TO WS-X
     MOVE ACT-FLAT-BACK TO WS-ACTION
     MOVE "cobolcraft.screen.common.cancel" TO WS-KEY
     MOVE 31 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-B WS-KEY
         WS-KEY-LENGTH
     MOVE 300 TO WS-W
     GOBACK.
 END PROGRAM FLAT-PRESETS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLAT-ACTION.
*> USING CLIENT-STATE, action (ACT-FLAT-*): Customize (superflat only) copies the stored preset to the working preset
*> and opens the editor; Presets opens the preset screen; Use Preset takes the selected row as the working preset and
*> returns to the editor; the preset screen's Cancel returns to the editor; Done stores the working preset in
*> SP-FLAT-PRESET and Cancel drops it, both returning to the create-world screen (which keeps its state, SCREEN-OPEN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLFLAT.
 01 WS-SCREEN              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION.
     MOVE 0 TO WS-SCREEN
     EVALUATE L-ACTION
         WHEN ACT-FLAT-CUSTOMIZE
             IF SP-CREATE-TYPE = CL-TYPE-SUPERFLAT
                 MOVE SP-FLAT-PRESET TO SP-FLAT-WORK
                 MOVE SCR-FLAT-EDIT TO WS-SCREEN
             END-IF
         WHEN ACT-FLAT-PRESETS
             MOVE SCR-FLAT-PRESETS TO WS-SCREEN
         WHEN ACT-FLAT-USE
             IF SM-SELECTED >= 1 AND SM-SELECTED <= FP-COUNT
                 MOVE FP-ID(SM-SELECTED) TO SP-FLAT-WORK
                 MOVE SCR-FLAT-EDIT TO WS-SCREEN
             END-IF
         WHEN ACT-FLAT-BACK
             MOVE SCR-FLAT-EDIT TO WS-SCREEN
         WHEN ACT-FLAT-DONE
             MOVE SP-FLAT-WORK TO SP-FLAT-PRESET
             MOVE SCR-CREATE-WORLD TO WS-SCREEN
         WHEN ACT-FLAT-CANCEL
             MOVE SCR-CREATE-WORLD TO WS-SCREEN
     END-EVALUATE
     IF WS-SCREEN > 0
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-IF
     GOBACK.
 END PROGRAM FLAT-ACTION.
