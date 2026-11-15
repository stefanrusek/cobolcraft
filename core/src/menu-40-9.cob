*> Menus, part 9: the block editor screens (docs/protocol/40-menus-9-block-editor-screens.md; US12 phase 44).
*> Programs of plain numbers and texts (MN9- prefix): who may open which screen, widget rectangles, visibility, enabling, filters, parsers, the
*> Identifier grammar and the hex bodies of the packets 0x37, 0x38, 0x3B, 0x3C, 0x3D and 0x1B. Texts are PIC X(2000) with a length, one byte per
*> UTF-16 code unit. Flags are 0 or 1. Screens: 1 command block, 2 minecart command block, 3 structure block, 4 jigsaw block, 5 test block, 6 test
*> instance block (40-x1). The live screens, the widgets and the packets themselves belong to the client and the server; these programs hold the rules.
*> Number grammars of Java parseInt, Float.valueOf and Long.valueOf are recalled, not verified (doc open question 2): plain sign and digits forms.
*>
*>   MN9-SCREENPKT, -INGAMEUI (1); MN9-CANUSE, -PERMEVENT, -PERMCHANGE, -PERMOPEN, -OPEN, -SERVERCHECK (2); MN9-ENTER, -ESCAPE, -PAUSE, -RESIZEKIND (3);
*>   MN9-CMD* (4); MN9-STR*, -NAMECHAR, -PARSENUM, -PARSEFLOAT (5); MN9-JIG*, -IDENT (6); MN9-TB* (7); MN9-HEXBYTE, -PUT*, -*HEX, -BODY*, -LIMIT (8)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-SCREENPKT.
*> USING screen, how it ends (1 Done, 2 Enter, 3 Escape, 4 Cancel, 5 SAVE, 6 LOAD, 7 DETECT, 8 Generate), first packet id out (0 none), second
*> packet id out (0 none) (section 1 table, section 3 Enter rule).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-HOW                  BINARY-LONG.
 01 L-P1                   BINARY-LONG.
 01 L-P2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-HOW L-P1 L-P2.
    MOVE 0 TO L-P1 L-P2
    EVALUATE TRUE
        WHEN L-SCREEN = 1 AND (L-HOW = 1 OR L-HOW = 2)
            MOVE 55 TO L-P1
        WHEN L-SCREEN = 2 AND (L-HOW = 1 OR L-HOW = 2)
            MOVE 56 TO L-P1
        WHEN L-SCREEN = 3 AND (L-HOW = 1 OR L-HOW = 2 OR L-HOW = 5 OR L-HOW = 6 OR L-HOW = 7)
            MOVE 60 TO L-P1
        WHEN L-SCREEN = 4 AND (L-HOW = 1 OR L-HOW = 2 OR L-HOW = 8)
            MOVE 59 TO L-P1
            IF L-HOW = 8
                MOVE 27 TO L-P2
            END-IF
        WHEN L-SCREEN = 5 AND L-HOW = 1
            MOVE 61 TO L-P1
        WHEN L-SCREEN = 6 AND L-HOW = 1
            MOVE 65 TO L-P1
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-SCREENPKT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-INGAMEUI.
*> USING screen, isInGameUi out: all six editor screens return true (1; 40-x1 1; 40-9 7A.1 says false for the command block screen, a conflict).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-OUT.
    MOVE 0 TO L-OUT
    IF L-SCREEN >= 1 AND L-SCREEN <= 6
        MOVE 1 TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN9-INGAMEUI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CANUSE.
*> USING instabuild flag, permission level (0 to 4), result out: canUseGameMasterBlocks needs instabuild and the gamemaster permission (level 2 or more) (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INSTABUILD           BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INSTABUILD L-LEVEL L-OUT.
    MOVE 0 TO L-OUT
    IF L-INSTABUILD = 1 AND L-LEVEL >= 2
        MOVE 1 TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN9-CANUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PERMEVENT.
*> USING entity event id, level out (24 to 28 store the set of level id - 24, any other id stores nothing: -1), has gamemaster out (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-GM                   BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-LEVEL L-GM.
    MOVE -1 TO L-LEVEL
    MOVE 0 TO L-GM
    IF L-EVENT >= 24 AND L-EVENT <= 28
        COMPUTE L-LEVEL = L-EVENT - 24
        IF L-LEVEL >= 2
            MOVE 1 TO L-GM
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN9-PERMEVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PERMCHANGE.
*> USING screen, old level, new level, has-gamemaster changed out, screen reacts out: none of the screens implements HasGamemasterPermissionReaction (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-REACTS               BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-OLD L-NEW L-CHANGED L-REACTS.
    MOVE 0 TO L-CHANGED L-REACTS
    IF (L-OLD >= 2 AND L-NEW < 2) OR (L-OLD < 2 AND L-NEW >= 2)
        MOVE 1 TO L-CHANGED
    END-IF
    GOBACK.
 END PROGRAM MN9-PERMCHANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PERMOPEN.
*> USING entity event id, instabuild flag, level out, may open out (the entity event sets the level, then the permission rule) (10.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-GM                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-INSTABUILD           BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-INSTABUILD L-LEVEL L-MAY.
    CALL "MN9-PERMEVENT" USING L-EVENT L-LEVEL W-GM
    CALL "MN9-CANUSE" USING L-INSTABUILD L-LEVEL L-MAY
    GOBACK.
 END PROGRAM MN9-PERMOPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-OPEN.
*> USING kind (1 command block, 2 minecart, 3 structure, 4 jigsaw, 5 test block, 6 test instance), entity present, may use game master blocks, side
*> (1 client, 2 server), result out (1 SUCCESS, 0 PASS), action out (1 the client pushes the screen, 2 the server sends Block Entity Data, 0 nothing) (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-PRESENT L-MAY L-SIDE L-RESULT L-ACTION.
    MOVE 0 TO L-RESULT L-ACTION
    IF L-MAY = 1 AND (L-PRESENT = 1 OR L-KIND = 2)
        MOVE 1 TO L-RESULT
        IF L-SIDE = 1
            MOVE 1 TO L-ACTION
        END-IF
        IF L-SIDE = 2 AND L-KIND = 1
            MOVE 2 TO L-ACTION
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN9-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-SERVERCHECK.
*> USING packet id, may use game master blocks, target exists with the right type, action out (0 stop silently, 1 stop with the message
*> advMode.notAllowed, 2 proceed) (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PACKET               BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-PACKET L-MAY L-TARGET L-ACTION.
    MOVE 0 TO L-ACTION
    EVALUATE TRUE
        WHEN L-PACKET NOT = 55 AND L-PACKET NOT = 56 AND L-PACKET NOT = 59 AND L-PACKET NOT = 60 AND L-PACKET NOT = 61
             AND L-PACKET NOT = 27 AND L-PACKET NOT = 65
            MOVE 0 TO L-ACTION
        WHEN L-MAY = 0 AND (L-PACKET = 55 OR L-PACKET = 56)
            MOVE 1 TO L-ACTION
        WHEN L-MAY = 1 AND L-TARGET = 1
            MOVE 2 TO L-ACTION
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-SERVERCHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-ENTER.
*> USING screen, Done active, onDone runs out: Enter on the command, minecart and structure screens does not test Done, the jigsaw screen only while Done
*> is active, the test block and test instance screens have no keyPressed override (3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-DONE L-RUNS.
    MOVE 0 TO L-RUNS
    EVALUATE TRUE
        WHEN L-SCREEN >= 1 AND L-SCREEN <= 3
            MOVE 1 TO L-RUNS
        WHEN L-SCREEN = 4
            MOVE L-DONE TO L-RUNS
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-ENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-ESCAPE.
*> USING screen, restore the seven initial values out (structure screen only), packet id out (always 0) (3 Escape and Cancel).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-RESTORE              BINARY-LONG.
 01 L-PACKET               BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-RESTORE L-PACKET.
    MOVE 0 TO L-RESTORE L-PACKET
    IF L-SCREEN = 3
        MOVE 1 TO L-RESTORE
    END-IF
    GOBACK.
 END PROGRAM MN9-ESCAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PAUSE.
*> USING screen, pauses out: Screen.isPauseScreen is true and no editor screen overrides it (3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-OUT.
    MOVE 0 TO L-OUT
    IF L-SCREEN >= 1 AND L-SCREEN <= 6
        MOVE 1 TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN9-PAUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-RESIZEKIND.
*> USING screen, keeps the typed texts out (1 for screens 1 to 4, which override resize), sends INIT again out (1 for the test instance screen) (3 Resize, 7A.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-KEEPS                BINARY-LONG.
 01 L-INIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-KEEPS L-INIT.
    MOVE 0 TO L-KEEPS L-INIT
    IF L-SCREEN >= 1 AND L-SCREEN <= 4
        MOVE 1 TO L-KEEPS
    END-IF
    IF L-SCREEN = 6
        MOVE 1 TO L-INIT
    END-IF
    GOBACK.
 END PROGRAM MN9-RESIZEKIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDRECT.
*> USING W, H, minecart (0 block, 1 minecart), item (1 command box, 2 previous output box, 3 track output cycle, 4 mode cycle, 5 type cycle, 6 trigger cycle,
*> 7 Done, 8 Cancel, 9 title point, 10 command label point, 11 previous output label point), x, y, width, height out (4.1, 4.2). The cycles 4 to 6 do not
*> exist on the minecart screen (all 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CX                   BINARY-LONG.
 01 W-Q                    BINARY-LONG.
 01 W-PY                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-MC                   BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-WD                   BINARY-LONG.
 01 L-HT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-H L-MC L-ITEM L-X L-Y L-WD L-HT.
    MOVE 0 TO L-X L-Y L-WD L-HT
    COMPUTE W-CX = L-W / 2
    COMPUTE W-Q = L-H / 4
    MOVE 135 TO W-PY
    IF L-MC = 1
        MOVE 150 TO W-PY
    END-IF
    EVALUATE L-ITEM
        WHEN 1
            COMPUTE L-X = W-CX - 150
            MOVE 50 TO L-Y
            MOVE 300 TO L-WD
            MOVE 20 TO L-HT
        WHEN 2
            COMPUTE L-X = W-CX - 150
            MOVE W-PY TO L-Y
            MOVE 276 TO L-WD
            MOVE 20 TO L-HT
        WHEN 3
            COMPUTE L-X = W-CX + 130
            MOVE W-PY TO L-Y
            MOVE 20 TO L-WD
            MOVE 20 TO L-HT
        WHEN 4
            IF L-MC = 0
                COMPUTE L-X = W-CX - 154
                MOVE 165 TO L-Y
                MOVE 100 TO L-WD
                MOVE 20 TO L-HT
            END-IF
        WHEN 5
            IF L-MC = 0
                COMPUTE L-X = W-CX - 50
                MOVE 165 TO L-Y
                MOVE 100 TO L-WD
                MOVE 20 TO L-HT
            END-IF
        WHEN 6
            IF L-MC = 0
                COMPUTE L-X = W-CX + 54
                MOVE 165 TO L-Y
                MOVE 100 TO L-WD
                MOVE 20 TO L-HT
            END-IF
        WHEN 7
            COMPUTE L-X = W-CX - 154
            COMPUTE L-Y = W-Q + 132
            MOVE 150 TO L-WD
            MOVE 20 TO L-HT
        WHEN 8
            COMPUTE L-X = W-CX + 4
            COMPUTE L-Y = W-Q + 132
            MOVE 150 TO L-WD
            MOVE 20 TO L-HT
        WHEN 9
            MOVE W-CX TO L-X
            MOVE 20 TO L-Y
        WHEN 10
            COMPUTE L-X = W-CX - 149
            MOVE 40 TO L-Y
        WHEN 11
            COMPUTE L-X = W-CX - 149
            COMPUTE L-Y = W-PY - 10
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-CMDRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDVALUE.
*> USING cycle (1 mode, 2 type, 3 trigger, 4 track output), index in the value list, which (1 value label, 2 name key), text out, length out (4.1, 4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CYCLE                BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CYCLE L-INDEX L-WHICH L-TEXT L-LEN.
    MOVE SPACES TO L-TEXT
    MOVE 0 TO L-LEN
    EVALUATE TRUE
        WHEN L-WHICH = 2 AND L-CYCLE = 1
            MOVE "advMode.mode" TO L-TEXT
        WHEN L-WHICH = 2 AND L-CYCLE = 2
            MOVE "advMode.type" TO L-TEXT
        WHEN L-WHICH = 2 AND L-CYCLE = 3
            MOVE "advMode.triggering" TO L-TEXT
        WHEN L-WHICH = 2 AND L-CYCLE = 4
            MOVE "advMode.trackOutput" TO L-TEXT
        WHEN L-CYCLE = 1 AND L-INDEX = 0
            MOVE "advMode.mode.sequence" TO L-TEXT
        WHEN L-CYCLE = 1 AND L-INDEX = 1
            MOVE "advMode.mode.auto" TO L-TEXT
        WHEN L-CYCLE = 1 AND L-INDEX = 2
            MOVE "advMode.mode.redstone" TO L-TEXT
        WHEN L-CYCLE = 2 AND L-INDEX = 0
            MOVE "advMode.mode.conditional" TO L-TEXT
        WHEN L-CYCLE = 2 AND L-INDEX = 1
            MOVE "advMode.mode.unconditional" TO L-TEXT
        WHEN L-CYCLE = 3 AND L-INDEX = 0
            MOVE "advMode.mode.autoexec.bat" TO L-TEXT
        WHEN L-CYCLE = 3 AND L-INDEX = 1
            MOVE "advMode.mode.redstoneTriggered" TO L-TEXT
        WHEN L-CYCLE = 4 AND L-INDEX = 0
            MOVE "O" TO L-TEXT
        WHEN L-CYCLE = 4 AND L-INDEX = 1
            MOVE "X" TO L-TEXT
    END-EVALUATE
    INSPECT L-TEXT TALLYING L-LEN FOR CHARACTERS BEFORE INITIAL SPACE
    GOBACK.
 END PROGRAM MN9-CMDVALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDPREV.
*> USING track output, last output length, value kind out (0 the text -, 1 the last output), drawn out (box and label are drawn when the value is not empty) (4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRACK                BINARY-LONG.
 01 L-OUTLEN               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRACK L-OUTLEN L-KIND L-DRAWN.
    MOVE 0 TO L-KIND
    MOVE 1 TO L-DRAWN
    IF L-TRACK = 1
        MOVE 1 TO L-KIND
        IF L-OUTLEN = 0
            MOVE 0 TO L-DRAWN
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN9-CMDPREV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDGUI.
*> USING track output, mode (0 SEQUENCE, 1 AUTO, 2 REDSTONE), conditional, automatic, last output length; out: controls enabled, the list index of the track cycle,
*> mode cycle, type cycle and trigger cycle (boolean lists hold true first), previous box kind and drawn (4.3 updateGui: setValue fires no callback).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRACK                BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-COND                 BINARY-LONG.
 01 L-AUTO                 BINARY-LONG.
 01 L-OUTLEN               BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-ITRACK               BINARY-LONG.
 01 L-IMODE                BINARY-LONG.
 01 L-ITYPE                BINARY-LONG.
 01 L-ITRIG                BINARY-LONG.
 01 L-PKIND                BINARY-LONG.
 01 L-PDRAWN               BINARY-LONG.
 PROCEDURE DIVISION USING L-TRACK L-MODE L-COND L-AUTO L-OUTLEN L-ENABLED L-ITRACK L-IMODE L-ITYPE L-ITRIG L-PKIND L-PDRAWN.
    MOVE 1 TO L-ENABLED
    COMPUTE L-ITRACK = 1 - L-TRACK
    MOVE L-MODE TO L-IMODE
    COMPUTE L-ITYPE = 1 - L-COND
    COMPUTE L-ITRIG = 1 - L-AUTO
    CALL "MN9-CMDPREV" USING L-TRACK L-OUTLEN L-PKIND L-PDRAWN
    GOBACK.
 END PROGRAM MN9-CMDGUI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDENABLE.
*> USING kind (1 block screen, 2 minecart screen), event (1 init, 2 data arrived, 3 resize), controls enabled out (4.2, 4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-EVENT L-ENABLED.
    MOVE 1 TO L-ENABLED
    IF L-KIND = 1 AND L-EVENT = 1
        MOVE 0 TO L-ENABLED
    END-IF
    GOBACK.
 END PROGRAM MN9-CMDENABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDDONE.
*> USING track output, clear the last output of the client copy out (onDone, 4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRACK                BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRACK L-CLEAR.
    COMPUTE L-CLEAR = 1 - L-TRACK
    GOBACK.
 END PROGRAM MN9-CMDDONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDTICK.
*> USING the shared block object is valid, the screen closes itself out (tick, 4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALID                BINARY-LONG.
 01 L-CLOSES               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALID L-CLOSES.
    COMPUTE L-CLOSES = 1 - L-VALID
    GOBACK.
 END PROGRAM MN9-CMDTICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDREFRESH.
*> USING loaded entity is a command block entity, current screen is a command block screen, refresh out (positions are not compared) (4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-SCREEN               BINARY-LONG.
 01 L-REFRESH              BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-SCREEN L-REFRESH.
    MOVE 0 TO L-REFRESH
    IF L-ENTITY = 1 AND L-SCREEN = 1
        MOVE 1 TO L-REFRESH
    END-IF
    GOBACK.
 END PROGRAM MN9-CMDREFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDCONST.
*> USING id, value out (4.1): 1 commandsOnly, 2 onlyShowIfCursorPastError, 3 line start offset, 4 line limit, 5 anchored to the bottom, 6 fill colour,
*> 7 box maximum length, 8 previousY of the block screen, 9 of the minecart screen, 10 label colour, 11 title colour, 12 title y, 13 command box y,
*> 14 command box width, 15 previous box width, 16 the track cycle size is 20 (id 16 gives 150, the button width of Done and Cancel).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-VALUE.
    MOVE 0 TO L-VALUE
    EVALUATE L-ID
        WHEN 1
            MOVE 1 TO L-VALUE
        WHEN 2
            MOVE 1 TO L-VALUE
        WHEN 4
            MOVE 7 TO L-VALUE
        WHEN 6
            MOVE -2147483648 TO L-VALUE
        WHEN 7
            MOVE 32500 TO L-VALUE
        WHEN 8
            MOVE 135 TO L-VALUE
        WHEN 9
            MOVE 150 TO L-VALUE
        WHEN 10
            MOVE -6250336 TO L-VALUE
        WHEN 11
            MOVE -1 TO L-VALUE
        WHEN 12
            MOVE 20 TO L-VALUE
        WHEN 13
            MOVE 50 TO L-VALUE
        WHEN 14
            MOVE 300 TO L-VALUE
        WHEN 15
            MOVE 276 TO L-VALUE
        WHEN 16
            MOVE 150 TO L-VALUE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-CMDCONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRRECT.
*> USING W, H, item (1 Done, 2 Cancel, 3 SAVE, 4 LOAD, 5 mode cycle, 6 DETECT, 7 include entities, 8 strict, 9 mirror, 10 show air, 11 show bounding box,
*> 12 to 15 rotation buttons 0 90 180 270, 16 name box, 17 to 19 position boxes, 20 to 22 size boxes, 23 integrity, 24 seed, 25 custom data), x y w h out (5.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CX                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-WD                   BINARY-LONG.
 01 L-HT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-H L-ITEM L-X L-Y L-WD L-HT.
    MOVE 20 TO L-HT
    COMPUTE W-CX = L-W / 2
    EVALUATE L-ITEM
        WHEN 1
            COMPUTE L-X = W-CX - 154
            MOVE 210 TO L-Y
            MOVE 150 TO L-WD
        WHEN 2
            COMPUTE L-X = W-CX + 4
            MOVE 210 TO L-Y
            MOVE 150 TO L-WD
        WHEN 3
            COMPUTE L-X = W-CX + 104
            MOVE 185 TO L-Y
            MOVE 50 TO L-WD
        WHEN 4
            COMPUTE L-X = W-CX + 104
            MOVE 185 TO L-Y
            MOVE 50 TO L-WD
        WHEN 5
            COMPUTE L-X = W-CX - 154
            MOVE 185 TO L-Y
            MOVE 50 TO L-WD
        WHEN 6
            COMPUTE L-X = W-CX + 104
            MOVE 120 TO L-Y
            MOVE 50 TO L-WD
        WHEN 7
            COMPUTE L-X = W-CX + 104
            MOVE 160 TO L-Y
            MOVE 50 TO L-WD
        WHEN 8
            COMPUTE L-X = W-CX + 104
            MOVE 120 TO L-Y
            MOVE 50 TO L-WD
        WHEN 9
            COMPUTE L-X = W-CX - 20
            MOVE 185 TO L-Y
            MOVE 40 TO L-WD
        WHEN 10
            COMPUTE L-X = W-CX + 104
            MOVE 80 TO L-Y
            MOVE 50 TO L-WD
        WHEN 11
            COMPUTE L-X = W-CX + 104
            MOVE 80 TO L-Y
            MOVE 50 TO L-WD
        WHEN 12
            COMPUTE L-X = W-CX - 102
            MOVE 185 TO L-Y
            MOVE 40 TO L-WD
        WHEN 13
            COMPUTE L-X = W-CX - 61
            MOVE 185 TO L-Y
            MOVE 40 TO L-WD
        WHEN 14
            COMPUTE L-X = W-CX + 21
            MOVE 185 TO L-Y
            MOVE 40 TO L-WD
        WHEN 15
            COMPUTE L-X = W-CX + 62
            MOVE 185 TO L-Y
            MOVE 40 TO L-WD
        WHEN 16
            COMPUTE L-X = W-CX - 152
            MOVE 40 TO L-Y
            MOVE 300 TO L-WD
        WHEN 17
            COMPUTE L-X = W-CX - 152
            MOVE 80 TO L-Y
            MOVE 80 TO L-WD
        WHEN 18
            COMPUTE L-X = W-CX - 72
            MOVE 80 TO L-Y
            MOVE 80 TO L-WD
        WHEN 19
            COMPUTE L-X = W-CX + 8
            MOVE 80 TO L-Y
            MOVE 80 TO L-WD
        WHEN 20
            COMPUTE L-X = W-CX - 152
            MOVE 120 TO L-Y
            MOVE 80 TO L-WD
        WHEN 21
            COMPUTE L-X = W-CX - 72
            MOVE 120 TO L-Y
            MOVE 80 TO L-WD
        WHEN 22
            COMPUTE L-X = W-CX + 8
            MOVE 120 TO L-Y
            MOVE 80 TO L-WD
        WHEN 23
            COMPUTE L-X = W-CX - 152
            MOVE 120 TO L-Y
            MOVE 80 TO L-WD
        WHEN 24
            COMPUTE L-X = W-CX - 72
            MOVE 120 TO L-Y
            MOVE 80 TO L-WD
        WHEN 25
            COMPUTE L-X = W-CX - 152
            MOVE 120 TO L-Y
            MOVE 240 TO L-WD
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-STRRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRVIS.
*> USING mode (0 SAVE, 1 LOAD, 2 CORNER, 3 DATA), item of 5.1, visible out (5.2 updateMode; mode cycle, Done and Cancel are always shown).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-VIS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-ITEM L-VIS.
    MOVE 0 TO L-VIS
    EVALUATE TRUE
        WHEN L-ITEM = 1 OR L-ITEM = 2 OR L-ITEM = 5
            MOVE 1 TO L-VIS
        WHEN L-MODE = 0 AND (L-ITEM = 3 OR L-ITEM = 6 OR L-ITEM = 7 OR L-ITEM = 10 OR (L-ITEM >= 16 AND L-ITEM <= 22))
            MOVE 1 TO L-VIS
        WHEN L-MODE = 1 AND (L-ITEM = 4 OR L-ITEM = 7 OR L-ITEM = 8 OR L-ITEM = 9 OR L-ITEM = 11 OR L-ITEM = 12 OR L-ITEM = 13
                             OR L-ITEM = 14 OR L-ITEM = 15 OR L-ITEM = 16 OR L-ITEM = 17 OR L-ITEM = 18 OR L-ITEM = 19
                             OR L-ITEM = 23 OR L-ITEM = 24)
            MOVE 1 TO L-VIS
        WHEN L-MODE = 2 AND L-ITEM = 16
            MOVE 1 TO L-VIS
        WHEN L-MODE = 3 AND L-ITEM = 25
            MOVE 1 TO L-VIS
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-STRVIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRLABEL.
*> USING W, mode, label (1 name, 2 position, 3 include entities, 4 size, 5 detect, 6 show air, 7 integrity, 8 strict, 9 show bounding box, 10 custom data,
*> 11 mode description), drawn out, x out, y out, right aligned out (x is then the right edge cx + 154) (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CX                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-LABEL                BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-RIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-MODE L-LABEL L-DRAWN L-X L-Y L-RIGHT.
    MOVE 0 TO L-DRAWN L-RIGHT
    COMPUTE W-CX = L-W / 2
    COMPUTE L-X = W-CX - 153
    EVALUATE L-LABEL
        WHEN 1
            MOVE 30 TO L-Y
            IF L-MODE NOT = 3
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 2
            MOVE 70 TO L-Y
            IF L-MODE = 0 OR L-MODE = 1
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 3
            COMPUTE L-X = W-CX + 154
            MOVE 150 TO L-Y
            MOVE 1 TO L-RIGHT
            IF L-MODE = 0 OR L-MODE = 1
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 4
            MOVE 110 TO L-Y
            IF L-MODE = 0
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 5
            COMPUTE L-X = W-CX + 154
            MOVE 110 TO L-Y
            MOVE 1 TO L-RIGHT
            IF L-MODE = 0
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 6
            COMPUTE L-X = W-CX + 154
            MOVE 70 TO L-Y
            MOVE 1 TO L-RIGHT
            IF L-MODE = 0
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 7
            MOVE 110 TO L-Y
            IF L-MODE = 1
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 8
            COMPUTE L-X = W-CX + 154
            MOVE 110 TO L-Y
            MOVE 1 TO L-RIGHT
            IF L-MODE = 1
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 9
            COMPUTE L-X = W-CX + 154
            MOVE 70 TO L-Y
            MOVE 1 TO L-RIGHT
            IF L-MODE = 1
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 10
            MOVE 110 TO L-Y
            IF L-MODE = 3
                MOVE 1 TO L-DRAWN
            END-IF
        WHEN 11
            MOVE 174 TO L-Y
            MOVE 1 TO L-DRAWN
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-STRLABEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-NAMECHAR.
*> USING text, length, cursor (0 based), typed code point, accepted out: only typing is filtered (5.3). colon and slash are the first 0 based
*> indexes of : and / in the text (-1 when absent): a colon needs colon -1 and (slash -1 or cursor <= slash), a slash needs cursor > colon, anything
*> else must be _ - . a to z or 0 to 9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-COLON                BINARY-LONG.
 01 W-SLASH                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-CURSOR               BINARY-LONG.
 01 L-CP                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LEN L-CURSOR L-CP L-OK.
    MOVE 0 TO L-OK
    MOVE -1 TO W-COLON W-SLASH
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > L-LEN
        IF L-TEXT(W-I:1) = ":" AND W-COLON = -1
            COMPUTE W-COLON = W-I - 1
        END-IF
        IF L-TEXT(W-I:1) = "/" AND W-SLASH = -1
            COMPUTE W-SLASH = W-I - 1
        END-IF
    END-PERFORM
    EVALUATE TRUE
        WHEN L-CP = 58
            IF W-COLON = -1 AND (W-SLASH = -1 OR L-CURSOR <= W-SLASH)
                MOVE 1 TO L-OK
            END-IF
        WHEN L-CP = 47
            IF L-CURSOR > W-COLON
                MOVE 1 TO L-OK
            END-IF
        WHEN L-CP = 95 OR L-CP = 45 OR L-CP = 46 OR (L-CP >= 97 AND L-CP <= 122) OR (L-CP >= 48 AND L-CP <= 57)
            MOVE 1 TO L-OK
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-NAMECHAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRMODES.
*> USING Alt held, entries of the mode cycle out: SAVE LOAD CORNER, and with Alt held also DATA (5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALT                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ALT L-COUNT.
    MOVE 3 TO L-COUNT
    IF L-ALT = 1
        MOVE 4 TO L-COUNT
    END-IF
    GOBACK.
 END PROGRAM MN9-STRMODES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRROT.
*> USING the entity rotation id (0 to 3), active flag of the buttons 0, 90, 180, 270 out: the button of the current rotation is inactive (5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROT                  BINARY-LONG.
 01 L-A0                   BINARY-LONG.
 01 L-A1                   BINARY-LONG.
 01 L-A2                   BINARY-LONG.
 01 L-A3                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROT L-A0 L-A1 L-A2 L-A3.
    MOVE 1 TO L-A0 L-A1 L-A2 L-A3
    EVALUATE L-ROT
        WHEN 0
            MOVE 0 TO L-A0
        WHEN 1
            MOVE 0 TO L-A1
        WHEN 2
            MOVE 0 TO L-A2
        WHEN 3
            MOVE 0 TO L-A3
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-STRROT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRACT.
*> USING how (1 Done, 2 Enter, 3 SAVE, 4 LOAD, 5 DETECT, 6 Cancel, 7 Escape), entity mode (0 SAVE, 1 LOAD, 2 CORNER, 3 DATA), packet sent out, update type out
*> (0 UPDATE_DATA, 1 SAVE_AREA, 2 LOAD_AREA, 3 SCAN_AREA), screen closes out, seven initial values restored out (5.1, 5.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOW                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-SENT                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-CLOSES               BINARY-LONG.
 01 L-RESTORE              BINARY-LONG.
 PROCEDURE DIVISION USING L-HOW L-MODE L-SENT L-TYPE L-CLOSES L-RESTORE.
    MOVE 0 TO L-SENT L-TYPE L-CLOSES L-RESTORE
    EVALUATE TRUE
        WHEN L-HOW = 1 OR L-HOW = 2
            MOVE 1 TO L-SENT L-CLOSES
        WHEN L-HOW = 3 AND L-MODE = 0
            MOVE 1 TO L-SENT L-CLOSES L-TYPE
        WHEN L-HOW = 4 AND L-MODE = 1
            MOVE 1 TO L-SENT L-CLOSES
            MOVE 2 TO L-TYPE
        WHEN L-HOW = 5 AND L-MODE = 0
            MOVE 1 TO L-SENT L-CLOSES
            MOVE 3 TO L-TYPE
        WHEN L-HOW = 6 OR L-HOW = 7
            MOVE 1 TO L-CLOSES L-RESTORE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-STRACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRCLAMP.
*> USING kind (1 offset, 2 size), typed value, value the server reads out: the writer keeps the low 8 bits, the reader takes a signed byte and clamps an
*> offset to -48..48 and a size to 0..48 (5.4, 8; the low-byte rule is Netty behaviour, recalled, not verified).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-B                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-VALUE L-OUT.
    COMPUTE W-B = FUNCTION MOD(L-VALUE, 256)
    IF W-B >= 128
        SUBTRACT 256 FROM W-B
    END-IF
    IF L-KIND = 1
        COMPUTE L-OUT = FUNCTION MIN(FUNCTION MAX(W-B, -48), 48)
    ELSE
        COMPUTE L-OUT = FUNCTION MIN(FUNCTION MAX(W-B, 0), 48)
    END-IF
    GOBACK.
 END PROGRAM MN9-STRCLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PARSENUM.
*> USING text, length, kind (1 Integer.parseInt, 2 Long.valueOf), default, value out (BINARY-DOUBLE): an optional + or - and one or more digits, no
*> other character, in the range of the type; anything else gives the default (5.4; the full Java grammar is recalled, not verified).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-FIRST                BINARY-LONG.
 01 W-START                BINARY-LONG.
 01 W-NEG                  BINARY-LONG.
 01 W-OK                   BINARY-LONG.
 01 W-SIG                  BINARY-LONG.
 01 W-MAXD                 BINARY-LONG.
 01 W-D                    BINARY-LONG.
 01 W-LIM                  PIC X(19).
 01 W-ACC                  BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DEFAULT              BINARY-DOUBLE.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TEXT L-LEN L-KIND L-DEFAULT L-VALUE.
    MOVE L-DEFAULT TO L-VALUE
    MOVE 1 TO W-OK W-START
    MOVE 0 TO W-NEG
    IF L-LEN >= 1 AND (L-TEXT(1:1) = "+" OR L-TEXT(1:1) = "-")
        MOVE 2 TO W-START
        IF L-TEXT(1:1) = "-"
            MOVE 1 TO W-NEG
        END-IF
    END-IF
    IF W-START > L-LEN
        MOVE 0 TO W-OK
    END-IF
    PERFORM VARYING W-I FROM W-START BY 1 UNTIL W-I > L-LEN
        IF L-TEXT(W-I:1) < "0" OR L-TEXT(W-I:1) > "9"
            MOVE 0 TO W-OK
        END-IF
    END-PERFORM
    IF W-OK = 1
        MOVE W-START TO W-FIRST
        PERFORM UNTIL W-FIRST >= L-LEN OR L-TEXT(W-FIRST:1) NOT = "0"
            ADD 1 TO W-FIRST
        END-PERFORM
        COMPUTE W-SIG = L-LEN - W-FIRST + 1
        MOVE 10 TO W-MAXD
        MOVE "2147483647" TO W-LIM
        IF L-KIND = 2
            MOVE 19 TO W-MAXD
            MOVE "9223372036854775807" TO W-LIM
        END-IF
        IF W-SIG > W-MAXD
            MOVE 0 TO W-OK
        END-IF
        IF W-OK = 1 AND W-SIG = W-MAXD
            IF W-NEG = 1
                MOVE "2147483648" TO W-LIM
                IF L-KIND = 2
                    MOVE "9223372036854775808" TO W-LIM
                END-IF
            END-IF
            IF L-TEXT(W-FIRST:W-SIG) > W-LIM(1:W-SIG)
                MOVE 0 TO W-OK
            END-IF
        END-IF
    END-IF
    IF W-OK = 1
        MOVE 0 TO W-ACC
        PERFORM VARYING W-I FROM W-FIRST BY 1 UNTIL W-I > L-LEN
            COMPUTE W-D = FUNCTION ORD(L-TEXT(W-I:1)) - 49
            IF W-NEG = 1
                COMPUTE W-ACC = W-ACC * 10 - W-D
            ELSE
                COMPUTE W-ACC = W-ACC * 10 + W-D
            END-IF
        END-PERFORM
        MOVE W-ACC TO L-VALUE
    END-IF
    GOBACK.
 END PROGRAM MN9-PARSENUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PARSEFLOAT.
*> USING text, length, default, value out (FLOAT-LONG): an optional sign and plain decimal digits with at most one point and at least one digit; anything
*> else gives the default (Float.valueOf of 5.4; exponent, hexadecimal, NaN and Infinity forms are recalled, not verified, and not accepted here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-START                BINARY-LONG.
 01 W-NEG                  BINARY-LONG.
 01 W-OK                   BINARY-LONG.
 01 W-POINT                BINARY-LONG.
 01 W-DIGITS               BINARY-LONG.
 01 W-D                    BINARY-LONG.
 01 W-INT                  FLOAT-LONG.
 01 W-FRAC                 FLOAT-LONG.
 01 W-SCALE                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-DEFAULT              FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LEN L-DEFAULT L-VALUE.
    MOVE L-DEFAULT TO L-VALUE
    MOVE 1 TO W-OK W-START
    MOVE 0 TO W-NEG W-POINT W-DIGITS
    MOVE 0 TO W-INT W-FRAC
    MOVE 1 TO W-SCALE
    IF L-LEN >= 1 AND (L-TEXT(1:1) = "+" OR L-TEXT(1:1) = "-")
        MOVE 2 TO W-START
        IF L-TEXT(1:1) = "-"
            MOVE 1 TO W-NEG
        END-IF
    END-IF
    PERFORM VARYING W-I FROM W-START BY 1 UNTIL W-I > L-LEN
        EVALUATE TRUE
            WHEN L-TEXT(W-I:1) = "." AND W-POINT = 0
                MOVE 1 TO W-POINT
            WHEN L-TEXT(W-I:1) >= "0" AND L-TEXT(W-I:1) <= "9"
                ADD 1 TO W-DIGITS
                COMPUTE W-D = FUNCTION ORD(L-TEXT(W-I:1)) - 49
                IF W-POINT = 0
                    COMPUTE W-INT = W-INT * 10 + W-D
                ELSE
                    COMPUTE W-FRAC = W-FRAC * 10 + W-D
                    COMPUTE W-SCALE = W-SCALE * 10
                END-IF
            WHEN OTHER
                MOVE 0 TO W-OK
        END-EVALUATE
    END-PERFORM
    IF W-DIGITS = 0
        MOVE 0 TO W-OK
    END-IF
    IF W-OK = 1
        COMPUTE L-VALUE = W-INT + W-FRAC / W-SCALE
        IF W-NEG = 1
            COMPUTE L-VALUE = 0 - L-VALUE
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN9-PARSEFLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRCONST.
*> USING id, value out (5.1, 9): 1 name box maximum, 2 position boxes, 3 size boxes, 4 integrity box, 5 seed box, 6 custom data box, 7 boxes saved by
*> resize, 8 label colour, 9 button height, 10 title colour.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-VALUE.
    MOVE 0 TO L-VALUE
    EVALUATE L-ID
        WHEN 1
            MOVE 128 TO L-VALUE
        WHEN 2
            MOVE 15 TO L-VALUE
        WHEN 3
            MOVE 15 TO L-VALUE
        WHEN 4
            MOVE 15 TO L-VALUE
        WHEN 5
            MOVE 31 TO L-VALUE
        WHEN 6
            MOVE 128 TO L-VALUE
        WHEN 7
            MOVE 10 TO L-VALUE
        WHEN 8
            MOVE -6250336 TO L-VALUE
        WHEN 9
            MOVE 20 TO L-VALUE
        WHEN 10
            MOVE -1 TO L-VALUE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-STRCONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRMODEKEY.
*> USING mode (0 SAVE, 1 LOAD, 2 CORNER, 3 DATA), which (1 mode cycle label key, 2 description key), text out, length out (5.1, 5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-NAME                 PIC X(6).
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-WHICH L-TEXT L-LEN.
    MOVE SPACES TO L-TEXT
    EVALUATE L-MODE
        WHEN 0
            MOVE "save" TO W-NAME
        WHEN 1
            MOVE "load" TO W-NAME
        WHEN 2
            MOVE "corner" TO W-NAME
        WHEN 3
            MOVE "data" TO W-NAME
    END-EVALUATE
    IF L-WHICH = 1
        STRING "structure_block.mode." W-NAME DELIMITED BY SPACE INTO L-TEXT
    ELSE
        STRING "structure_block.mode_info." W-NAME DELIMITED BY SPACE INTO L-TEXT
    END-IF
    MOVE 0 TO L-LEN
    INSPECT L-TEXT TALLYING L-LEN FOR CHARACTERS BEFORE INITIAL SPACE
    GOBACK.
 END PROGRAM MN9-STRMODEKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-JIGRECT.
*> USING W, H, item (1 pool box, 2 name box, 3 target box, 4 final state box, 5 selection priority box, 6 placement priority box, 7 joint cycle, 8 levels
*> slider, 9 keep jigsaws, 10 Generate, 11 Done, 12 Cancel), x y w h out (6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CX                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-WD                   BINARY-LONG.
 01 L-HT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-H L-ITEM L-X L-Y L-WD L-HT.
    MOVE 20 TO L-HT
    COMPUTE W-CX = L-W / 2
    EVALUATE L-ITEM
        WHEN 1
            COMPUTE L-X = W-CX - 153
            MOVE 20 TO L-Y
            MOVE 300 TO L-WD
        WHEN 2
            COMPUTE L-X = W-CX - 153
            MOVE 55 TO L-Y
            MOVE 300 TO L-WD
        WHEN 3
            COMPUTE L-X = W-CX - 153
            MOVE 90 TO L-Y
            MOVE 300 TO L-WD
        WHEN 4
            COMPUTE L-X = W-CX - 153
            MOVE 125 TO L-Y
            MOVE 300 TO L-WD
        WHEN 5
            COMPUTE L-X = W-CX - 153
            MOVE 160 TO L-Y
            MOVE 98 TO L-WD
        WHEN 6
            COMPUTE L-X = W-CX - 50
            MOVE 160 TO L-Y
            MOVE 98 TO L-WD
        WHEN 7
            COMPUTE L-X = W-CX + 54
            MOVE 160 TO L-Y
            MOVE 100 TO L-WD
        WHEN 8
            COMPUTE L-X = W-CX - 154
            MOVE 185 TO L-Y
            MOVE 100 TO L-WD
        WHEN 9
            COMPUTE L-X = W-CX - 50
            MOVE 185 TO L-Y
            MOVE 100 TO L-WD
        WHEN 10
            COMPUTE L-X = W-CX + 54
            MOVE 185 TO L-Y
            MOVE 100 TO L-WD
        WHEN 11
            COMPUTE L-X = W-CX - 154
            MOVE 210 TO L-Y
            MOVE 150 TO L-WD
        WHEN 12
            COMPUTE L-X = W-CX + 4
            MOVE 210 TO L-Y
            MOVE 150 TO L-WD
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-JIGRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-JIGLABEL.
*> USING W, label (1 pool, 2 name, 3 target, 4 final state, 5 selection priority, 6 placement priority, 7 joint), x y out (6 drawing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CX                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-LABEL                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-LABEL L-X L-Y.
    COMPUTE W-CX = L-W / 2
    COMPUTE L-X = W-CX - 153
    EVALUATE L-LABEL
        WHEN 1
            MOVE 10 TO L-Y
        WHEN 2
            MOVE 45 TO L-Y
        WHEN 3
            MOVE 80 TO L-Y
        WHEN 4
            MOVE 115 TO L-Y
        WHEN 5
            MOVE 150 TO L-Y
        WHEN 6
            COMPUTE L-X = W-CX - 50
            MOVE 150 TO L-Y
        WHEN 7
            COMPUTE L-X = W-CX + 53
            MOVE 150 TO L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-JIGLABEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-JIGVIS.
*> USING item (7 joint cycle, 13 joint label, anything else), front direction (0 down, 1 up, 2 north, 3 south, 4 west, 5 east), visible and active out: the
*> joint cycle and its label need a vertical front direction (6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-VIS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-DIR L-VIS.
    MOVE 1 TO L-VIS
    IF (L-ITEM = 7 OR L-ITEM = 13) AND L-DIR > 1
        MOVE 0 TO L-VIS
    END-IF
    GOBACK.
 END PROGRAM MN9-JIGVIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-IDENT.
*> USING text, length, parsed out (Identifier.tryParse not null), text with the namespace out, its length out (spaces when not parsed) (6, 7A.3): split at the
*> first colon; the path takes a-z 0-9 _ - / . and may be empty; the namespace takes a-z 0-9 _ - . (never ..); no colon or a colon at the start means minecraft.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-COLON                BINARY-LONG.
 01 W-PATHFROM             BINARY-LONG.
 01 W-PATHLEN              BINARY-LONG.
 01 W-NSLEN                BINARY-LONG.
 01 W-OK                   BINARY-LONG.
 01 W-C                    PIC X.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-OUT                  PIC X(2000).
 01 L-OUTLEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LEN L-OK L-OUT L-OUTLEN.
    MOVE SPACES TO L-OUT
    MOVE 0 TO L-OK L-OUTLEN W-COLON
    MOVE 1 TO W-OK
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > L-LEN OR W-COLON > 0
        IF L-TEXT(W-I:1) = ":"
            MOVE W-I TO W-COLON
        END-IF
    END-PERFORM
    COMPUTE W-PATHFROM = W-COLON + 1
    COMPUTE W-PATHLEN = L-LEN - W-COLON
    COMPUTE W-NSLEN = W-COLON - 1
    PERFORM VARYING W-I FROM W-PATHFROM BY 1 UNTIL W-I > L-LEN
        MOVE L-TEXT(W-I:1) TO W-C
        IF NOT ((W-C >= "a" AND W-C <= "z") OR (W-C >= "0" AND W-C <= "9") OR W-C = "_" OR W-C = "-" OR W-C = "/" OR W-C = ".")
            MOVE 0 TO W-OK
        END-IF
    END-PERFORM
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > W-NSLEN
        MOVE L-TEXT(W-I:1) TO W-C
        IF NOT ((W-C >= "a" AND W-C <= "z") OR (W-C >= "0" AND W-C <= "9") OR W-C = "_" OR W-C = "-" OR W-C = ".")
            MOVE 0 TO W-OK
        END-IF
    END-PERFORM
    IF W-NSLEN = 2 AND L-TEXT(1:2) = ".."
        MOVE 0 TO W-OK
    END-IF
    IF W-OK = 1
        MOVE 1 TO L-OK
        IF W-NSLEN > 0
            MOVE L-TEXT(1:W-NSLEN) TO L-OUT(1:W-NSLEN)
            MOVE W-NSLEN TO L-OUTLEN
        ELSE
            MOVE "minecraft" TO L-OUT(1:9)
            MOVE 9 TO L-OUTLEN
        END-IF
        ADD 1 TO L-OUTLEN
        MOVE ":" TO L-OUT(L-OUTLEN:1)
        IF W-PATHLEN > 0
            MOVE L-TEXT(W-PATHFROM:W-PATHLEN) TO L-OUT(L-OUTLEN + 1:W-PATHLEN)
            ADD W-PATHLEN TO L-OUTLEN
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN9-IDENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-JIGVALID.
*> USING name text and length, target text and length, pool text and length, valid out: Done and Generate are active while each parses (6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-OK1                  BINARY-LONG.
 01 W-OK2                  BINARY-LONG.
 01 W-OK3                  BINARY-LONG.
 01 W-OUT                  PIC X(2000).
 01 W-OUTLEN               BINARY-LONG.
 LINKAGE SECTION.
 01 L-T1                   PIC X(2000).
 01 L-N1                   BINARY-LONG.
 01 L-T2                   PIC X(2000).
 01 L-N2                   BINARY-LONG.
 01 L-T3                   PIC X(2000).
 01 L-N3                   BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-T1 L-N1 L-T2 L-N2 L-T3 L-N3 L-VALID.
    CALL "MN9-IDENT" USING L-T1 L-N1 W-OK1 W-OUT W-OUTLEN
    CALL "MN9-IDENT" USING L-T2 L-N2 W-OK2 W-OUT W-OUTLEN
    CALL "MN9-IDENT" USING L-T3 L-N3 W-OK3 W-OUT W-OUTLEN
    MOVE 0 TO L-VALID
    IF W-OK1 = 1 AND W-OK2 = 1 AND W-OK3 = 1
        MOVE 1 TO L-VALID
    END-IF
    GOBACK.
 END PROGRAM MN9-JIGVALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-JIGLEVELS.
*> USING slider value (FLOAT-LONG), levels out: floor(clampedLerp(value, 0, 20)) = floor(20 * value) with the value clamped to 0..1 (6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-V                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-LEVELS               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-LEVELS.
    MOVE L-VALUE TO W-V
    IF W-V < 0
        MOVE 0 TO W-V
    END-IF
    IF W-V > 1
        MOVE 1 TO W-V
    END-IF
    COMPUTE W-V = W-V * 20
    COMPUTE L-LEVELS = FUNCTION INTEGER(W-V)
    GOBACK.
 END PROGRAM MN9-JIGLEVELS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-JIGRESIZE.
*> USING levels, joint, slider value in hundredths out (0: the slider is rebuilt at 0.0), the levels its label shows out, the joint after the setValue out (6.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVELS               BINARY-LONG.
 01 L-JOINT                BINARY-LONG.
 01 L-SLIDER               BINARY-LONG.
 01 L-LABEL                BINARY-LONG.
 01 L-JOUT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVELS L-JOINT L-SLIDER L-LABEL L-JOUT.
    MOVE 0 TO L-SLIDER
    MOVE L-LEVELS TO L-LABEL
    MOVE L-JOINT TO L-JOUT
    GOBACK.
 END PROGRAM MN9-JIGRESIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-JIGJOINTTEXT.
*> USING joint index (0 ROLLABLE, 1 ALIGNED), value label key out, length out (6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-JOINT                BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-JOINT L-TEXT L-LEN.
    MOVE SPACES TO L-TEXT
    IF L-JOINT = 0
        MOVE "jigsaw_block.joint.rollable" TO L-TEXT
    ELSE
        MOVE "jigsaw_block.joint.aligned" TO L-TEXT
    END-IF
    MOVE 0 TO L-LEN
    INSPECT L-TEXT TALLYING L-LEN FOR CHARACTERS BEFORE INITIAL SPACE
    GOBACK.
 END PROGRAM MN9-JIGJOINTTEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-JIGCONST.
*> USING id, value out (6): 1 pool box maximum, 2 name box, 3 target box, 4 final state box, 5 selection priority box, 6 placement priority box, 7 highest
*> level, 8 initial slider value, 9 keep jigsaws initial.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-VALUE.
    MOVE 0 TO L-VALUE
    EVALUATE L-ID
        WHEN 1
            MOVE 128 TO L-VALUE
        WHEN 2
            MOVE 128 TO L-VALUE
        WHEN 3
            MOVE 128 TO L-VALUE
        WHEN 4
            MOVE 256 TO L-VALUE
        WHEN 5
            MOVE 3 TO L-VALUE
        WHEN 6
            MOVE 3 TO L-VALUE
        WHEN 7
            MOVE 20 TO L-VALUE
        WHEN 9
            MOVE 1 TO L-VALUE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-JIGCONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-TBRECT.
*> USING W, H, item (1 message box, 2 mode cycle, 3 Done, 4 Cancel), x y w h out (7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CX                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-WD                   BINARY-LONG.
 01 L-HT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-H L-ITEM L-X L-Y L-WD L-HT.
    MOVE 20 TO L-HT
    COMPUTE W-CX = L-W / 2
    EVALUATE L-ITEM
        WHEN 1
            COMPUTE L-X = W-CX - 152
            MOVE 80 TO L-Y
            MOVE 240 TO L-WD
        WHEN 2
            COMPUTE L-X = W-CX - 154
            MOVE 185 TO L-Y
            MOVE 50 TO L-WD
        WHEN 3
            COMPUTE L-X = W-CX - 154
            MOVE 210 TO L-Y
            MOVE 150 TO L-WD
        WHEN 4
            COMPUTE L-X = W-CX + 4
            MOVE 210 TO L-Y
            MOVE 150 TO L-WD
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-TBRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-TBLABEL.
*> USING W, mode, item (1 title centred at cx, 2 the label Message:, 3 the mode description), drawn out, x out, y out (7 drawing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CX                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-MODE L-ITEM L-DRAWN L-X L-Y.
    MOVE 1 TO L-DRAWN
    COMPUTE W-CX = L-W / 2
    EVALUATE L-ITEM
        WHEN 1
            MOVE W-CX TO L-X
            MOVE 10 TO L-Y
        WHEN 2
            COMPUTE L-X = W-CX - 153
            MOVE 70 TO L-Y
            IF L-MODE = 0
                MOVE 0 TO L-DRAWN
            END-IF
        WHEN 3
            COMPUTE L-X = W-CX - 153
            MOVE 174 TO L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-TBLABEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-TBVIS.
*> USING mode (0 START, 1 LOG, 2 FAIL, 3 ACCEPT), message box visible out (7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-VIS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-VIS.
    MOVE 1 TO L-VIS
    IF L-MODE = 0
        MOVE 0 TO L-VIS
    END-IF
    GOBACK.
 END PROGRAM MN9-TBVIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-TBKEY.
*> USING mode, which (1 cycle label key, 2 description key), text out, length out (7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-NAME                 PIC X(6).
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-WHICH L-TEXT L-LEN.
    MOVE SPACES TO L-TEXT
    EVALUATE L-MODE
        WHEN 0
            MOVE "start" TO W-NAME
        WHEN 1
            MOVE "log" TO W-NAME
        WHEN 2
            MOVE "fail" TO W-NAME
        WHEN 3
            MOVE "accept" TO W-NAME
    END-EVALUATE
    IF L-WHICH = 1
        STRING "test_block.mode." W-NAME DELIMITED BY SPACE INTO L-TEXT
    ELSE
        STRING "test_block.mode_info." W-NAME DELIMITED BY SPACE INTO L-TEXT
    END-IF
    MOVE 0 TO L-LEN
    INSPECT L-TEXT TALLYING L-LEN FOR CHARACTERS BEFORE INITIAL SPACE
    GOBACK.
 END PROGRAM MN9-TBKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-TBRESIZE.
*> USING stored message and length (written by Done), typed text and length, shown message out, its length out: a resize rebuilds the box from the
*> stored message (7, 9.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STORED               PIC X(2000).
 01 L-SLEN                 BINARY-LONG.
 01 L-TYPED                PIC X(2000).
 01 L-TLEN                 BINARY-LONG.
 01 L-SHOWN                PIC X(2000).
 01 L-SHOWNLEN             BINARY-LONG.
 PROCEDURE DIVISION USING L-STORED L-SLEN L-TYPED L-TLEN L-SHOWN L-SHOWNLEN.
    MOVE L-STORED TO L-SHOWN
    MOVE L-SLEN TO L-SHOWNLEN
    GOBACK.
 END PROGRAM MN9-TBRESIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-TBCONST.
*> USING id, value out (7): 1 message box maximum, 2 highest mode id, 3 title y, 4 description y, 5 message label y, 6 label colour.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-VALUE.
    MOVE 0 TO L-VALUE
    EVALUATE L-ID
        WHEN 1
            MOVE 128 TO L-VALUE
        WHEN 2
            MOVE 3 TO L-VALUE
        WHEN 3
            MOVE 10 TO L-VALUE
        WHEN 4
            MOVE 174 TO L-VALUE
        WHEN 5
            MOVE 70 TO L-VALUE
        WHEN 6
            MOVE -6250336 TO L-VALUE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-TBCONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-HEXBYTE.
*> USING byte 0 to 255, hex text, position (1 based, advanced by two): appends the byte as two lower-case hex digits (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-DIGITS               PIC X(16) VALUE "0123456789abcdef".
 01 W-HI                   BINARY-LONG.
 01 W-LO                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BYTE                 BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BYTE L-HEX L-POS.
    DIVIDE L-BYTE BY 16 GIVING W-HI REMAINDER W-LO
    ADD 1 TO W-HI W-LO
    MOVE W-DIGITS(W-HI:1) TO L-HEX(L-POS:1)
    ADD 1 TO L-POS
    MOVE W-DIGITS(W-LO:1) TO L-HEX(L-POS:1)
    ADD 1 TO L-POS
    GOBACK.
 END PROGRAM MN9-HEXBYTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PUTVAR.
*> USING value (32 bit, negative takes five bytes), hex text, position: appends a VarInt (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-V                    BINARY-DOUBLE.
 01 W-BYTE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-HEX L-POS.
    MOVE L-VALUE TO W-V
    IF W-V < 0
        ADD 4294967296 TO W-V
    END-IF
    PERFORM WITH TEST AFTER UNTIL W-V = 0
        DIVIDE W-V BY 128 GIVING W-V REMAINDER W-BYTE
        IF W-V > 0
            ADD 128 TO W-BYTE
        END-IF
        CALL "MN9-HEXBYTE" USING W-BYTE L-HEX L-POS
    END-PERFORM
    GOBACK.
 END PROGRAM MN9-PUTVAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PUTLONG.
*> USING value (64 bit), hex text, position: appends a VarLong, ten bytes for a negative value (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-V                    BINARY-DOUBLE.
 01 W-BYTE                 BINARY-LONG.
 01 W-N                    BINARY-LONG.
 01 W-ONE                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-DOUBLE.
 01 L-HEX                  PIC X(2000).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-HEX L-POS.
    MOVE L-VALUE TO W-V
    IF W-V < 0
        PERFORM VARYING W-N FROM 1 BY 1 UNTIL W-N > 9
            COMPUTE W-BYTE = FUNCTION MOD(W-V, 128)
            COMPUTE W-V = (W-V - W-BYTE) / 128
            ADD 128 TO W-BYTE
            CALL "MN9-HEXBYTE" USING W-BYTE L-HEX L-POS
        END-PERFORM
        CALL "MN9-HEXBYTE" USING W-ONE L-HEX L-POS
    ELSE
        PERFORM WITH TEST AFTER UNTIL W-V = 0
            DIVIDE W-V BY 128 GIVING W-V REMAINDER W-BYTE
            IF W-V > 0
                ADD 128 TO W-BYTE
            END-IF
            CALL "MN9-HEXBYTE" USING W-BYTE L-HEX L-POS
        END-PERFORM
    END-IF
    GOBACK.
 END PROGRAM MN9-PUTLONG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PUTPOS.
*> USING x, y, z, hex text, position: appends a Position, X in bits 38 to 63, Z in 12 to 37 and Y in 0 to 11, each masked (00 section 4.1) (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-XU                   BINARY-LONG.
 01 W-ZU                   BINARY-LONG.
 01 W-YU                   BINARY-LONG.
 01 W-Q                    BINARY-LONG.
 01 W-B                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-HEX L-POS.
    COMPUTE W-XU = FUNCTION MOD(L-X, 67108864)
    COMPUTE W-ZU = FUNCTION MOD(L-Z, 67108864)
    COMPUTE W-YU = FUNCTION MOD(L-Y, 4096)
    DIVIDE W-XU BY 262144 GIVING W-B
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    DIVIDE W-XU BY 1024 GIVING W-Q
    COMPUTE W-B = FUNCTION MOD(W-Q, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    DIVIDE W-XU BY 4 GIVING W-Q
    COMPUTE W-B = FUNCTION MOD(W-Q, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    DIVIDE W-ZU BY 1048576 GIVING W-Q
    COMPUTE W-B = FUNCTION MOD(W-XU, 4) * 64 + W-Q
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    DIVIDE W-ZU BY 4096 GIVING W-Q
    COMPUTE W-B = FUNCTION MOD(W-Q, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    DIVIDE W-ZU BY 16 GIVING W-Q
    COMPUTE W-B = FUNCTION MOD(W-Q, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    DIVIDE W-YU BY 256 GIVING W-Q
    COMPUTE W-B = FUNCTION MOD(W-ZU, 16) * 16 + W-Q
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    COMPUTE W-B = FUNCTION MOD(W-YU, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    GOBACK.
 END PROGRAM MN9-PUTPOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PUTSTR.
*> USING text, length, hex text, position: appends a String, a VarInt length and the bytes (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-B                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LEN L-HEX L-POS.
    CALL "MN9-PUTVAR" USING L-LEN L-HEX L-POS
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > L-LEN
        COMPUTE W-B = FUNCTION ORD(L-TEXT(W-I:1)) - 1
        CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    END-PERFORM
    GOBACK.
 END PROGRAM MN9-PUTSTR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-PUTFLOAT.
*> USING value (FLOAT-LONG), hex text, position: appends the IEEE binary32 of the value, big-endian, rounded to nearest even (8; normal numbers and zero).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-A                    FLOAT-LONG.
 01 W-MANT                 FLOAT-LONG.
 01 W-FR                   FLOAT-LONG.
 01 W-E                    BINARY-LONG.
 01 W-M                    BINARY-LONG.
 01 W-SIGN                 BINARY-LONG.
 01 W-BITS                 BINARY-DOUBLE.
 01 W-TOP                  BINARY-LONG.
 01 W-B                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-HEX L-POS.
    MOVE 0 TO W-BITS W-SIGN W-E
    MOVE L-VALUE TO W-A
    IF W-A < 0
        MOVE 1 TO W-SIGN
        COMPUTE W-A = 0 - W-A
    END-IF
    IF W-A > 0
        PERFORM UNTIL W-A < 2
            COMPUTE W-A = W-A / 2
            ADD 1 TO W-E
        END-PERFORM
        PERFORM UNTIL W-A >= 1
            COMPUTE W-A = W-A * 2
            SUBTRACT 1 FROM W-E
        END-PERFORM
        COMPUTE W-MANT = (W-A - 1) * 8388608
        COMPUTE W-M = FUNCTION INTEGER(W-MANT)
        COMPUTE W-FR = W-MANT - W-M
        IF W-FR > 0.5 OR (W-FR = 0.5 AND FUNCTION MOD(W-M, 2) = 1)
            ADD 1 TO W-M
        END-IF
        IF W-M = 8388608
            MOVE 0 TO W-M
            ADD 1 TO W-E
        END-IF
        COMPUTE W-BITS = (W-E + 127) * 8388608 + W-M
    END-IF
    COMPUTE W-BITS = W-BITS + W-SIGN * 2147483648
    DIVIDE W-BITS BY 16777216 GIVING W-TOP REMAINDER W-M
    MOVE W-TOP TO W-B
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    DIVIDE W-M BY 65536 GIVING W-B REMAINDER W-M
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    DIVIDE W-M BY 256 GIVING W-B REMAINDER W-M
    CALL "MN9-HEXBYTE" USING W-B L-HEX L-POS
    CALL "MN9-HEXBYTE" USING W-M L-HEX L-POS
    GOBACK.
 END PROGRAM MN9-PUTFLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-VARINTHEX.
*> USING value, hex out, byte count out: the VarInt of the value alone (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTVAR" USING L-VALUE L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-VARINTHEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-VARLONGHEX.
*> USING value (BINARY-DOUBLE), hex out, byte count out: the VarLong of the value alone (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-DOUBLE.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTLONG" USING L-VALUE L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-VARLONGHEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-POSHEX.
*> USING x, y, z, hex out, byte count out: the Position alone (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTPOS" USING L-X L-Y L-Z L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-POSHEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-FLOATHEX.
*> USING value (FLOAT-LONG), hex out, byte count out: the binary32 alone (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTFLOAT" USING L-VALUE L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-FLOATHEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-CMDFLAGS.
*> USING track output, conditional, automatic, flags byte out: 0x01, 0x02 and 0x04 (0x37 Flags).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRACK                BINARY-LONG.
 01 L-COND                 BINARY-LONG.
 01 L-AUTO                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRACK L-COND L-AUTO L-FLAGS.
    COMPUTE L-FLAGS = L-TRACK + 2 * L-COND + 4 * L-AUTO
    GOBACK.
 END PROGRAM MN9-CMDFLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-STRFLAGS.
*> USING ignore entities, show air, show bounding box, strict, flags byte out: 0x01, 0x02, 0x04 and 0x08 (0x3C Flags).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IGNORE               BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-BBOX                 BINARY-LONG.
 01 L-STRICT               BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-IGNORE L-AIR L-BBOX L-STRICT L-FLAGS.
    COMPUTE L-FLAGS = L-IGNORE + 2 * L-AIR + 4 * L-BBOX + 8 * L-STRICT
    GOBACK.
 END PROGRAM MN9-STRFLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-BODY37.
*> USING x y z, command text and length, mode, track output, conditional, automatic, hex out, byte count out: body of 0x37 Set Command Block (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 01 W-FLAGS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-TRACK                BINARY-LONG.
 01 L-COND                 BINARY-LONG.
 01 L-AUTO                 BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-TEXT L-LEN L-MODE L-TRACK L-COND L-AUTO L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTPOS" USING L-X L-Y L-Z L-HEX W-POS
    CALL "MN9-PUTSTR" USING L-TEXT L-LEN L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-MODE L-HEX W-POS
    CALL "MN9-CMDFLAGS" USING L-TRACK L-COND L-AUTO W-FLAGS
    CALL "MN9-HEXBYTE" USING W-FLAGS L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-BODY37.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-BODY38.
*> USING entity id, command text and length, track output, hex out, byte count out: body of 0x38 Set Command Minecart (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-TRACK                BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-TEXT L-LEN L-TRACK L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTVAR" USING L-ID L-HEX W-POS
    CALL "MN9-PUTSTR" USING L-TEXT L-LEN L-HEX W-POS
    CALL "MN9-HEXBYTE" USING L-TRACK L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-BODY38.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-BODY3B.
*> USING x y z, name text and length, target text and length, pool text and length, final state text and length, joint (0 rollable, 1 aligned), selection
*> priority, placement priority, hex out, byte count out: body of 0x3B Set Jigsaw Block; the three identifiers are written with the namespace (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 01 W-OK                   BINARY-LONG.
 01 W-ID                   PIC X(2000).
 01 W-IDLEN                BINARY-LONG.
 01 W-JOINT                PIC X(8).
 01 W-JLEN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-NAME                 PIC X(2000).
 01 L-NLEN                 BINARY-LONG.
 01 L-TARGET               PIC X(2000).
 01 L-TLEN                 BINARY-LONG.
 01 L-POOL                 PIC X(2000).
 01 L-PLEN                 BINARY-LONG.
 01 L-FINAL                PIC X(2000).
 01 L-FLEN                 BINARY-LONG.
 01 L-JOINT                BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-NAME L-NLEN L-TARGET L-TLEN L-POOL L-PLEN L-FINAL L-FLEN L-JOINT L-SEL L-PLACE L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTPOS" USING L-X L-Y L-Z L-HEX W-POS
    CALL "MN9-IDENT" USING L-NAME L-NLEN W-OK W-ID W-IDLEN
    CALL "MN9-PUTSTR" USING W-ID W-IDLEN L-HEX W-POS
    CALL "MN9-IDENT" USING L-TARGET L-TLEN W-OK W-ID W-IDLEN
    CALL "MN9-PUTSTR" USING W-ID W-IDLEN L-HEX W-POS
    CALL "MN9-IDENT" USING L-POOL L-PLEN W-OK W-ID W-IDLEN
    CALL "MN9-PUTSTR" USING W-ID W-IDLEN L-HEX W-POS
    CALL "MN9-PUTSTR" USING L-FINAL L-FLEN L-HEX W-POS
    MOVE "rollable" TO W-JOINT
    MOVE 8 TO W-JLEN
    IF L-JOINT = 1
        MOVE "aligned" TO W-JOINT
        MOVE 7 TO W-JLEN
    END-IF
    MOVE SPACES TO W-ID
    MOVE W-JOINT TO W-ID(1:8)
    CALL "MN9-PUTSTR" USING W-ID W-JLEN L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-SEL L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-PLACE L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-BODY3B.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-BODY3C.
*> USING x y z, update type, mode, name text and length, offset X Y Z, size X Y Z (typed values, written as the low byte), mirror, rotation, metadata text
*> and length, integrity (clamped to 0..1, binary32), seed (VarLong), ignore entities, show air, show bounding box, strict, hex out, byte count out:
*> body of 0x3C Set Structure Block (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 01 W-FLAGS                BINARY-LONG.
 01 W-B                    BINARY-LONG.
 01 W-F                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-UTYPE                BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-NAME                 PIC X(2000).
 01 L-NLEN                 BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-META                 PIC X(2000).
 01 L-MLEN                 BINARY-LONG.
 01 L-INTEG                FLOAT-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-IGNORE               BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-BBOX                 BINARY-LONG.
 01 L-STRICT               BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-UTYPE L-MODE L-NAME L-NLEN L-OX L-OY L-OZ L-SX L-SY L-SZ L-MIRROR L-ROT L-META L-MLEN
                          L-INTEG L-SEED L-IGNORE L-AIR L-BBOX L-STRICT L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTPOS" USING L-X L-Y L-Z L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-UTYPE L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-MODE L-HEX W-POS
    CALL "MN9-PUTSTR" USING L-NAME L-NLEN L-HEX W-POS
    COMPUTE W-B = FUNCTION MOD(L-OX, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX W-POS
    COMPUTE W-B = FUNCTION MOD(L-OY, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX W-POS
    COMPUTE W-B = FUNCTION MOD(L-OZ, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX W-POS
    COMPUTE W-B = FUNCTION MOD(L-SX, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX W-POS
    COMPUTE W-B = FUNCTION MOD(L-SY, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX W-POS
    COMPUTE W-B = FUNCTION MOD(L-SZ, 256)
    CALL "MN9-HEXBYTE" USING W-B L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-MIRROR L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-ROT L-HEX W-POS
    CALL "MN9-PUTSTR" USING L-META L-MLEN L-HEX W-POS
    COMPUTE W-F = FUNCTION MIN(FUNCTION MAX(L-INTEG, 0), 1)
    CALL "MN9-PUTFLOAT" USING W-F L-HEX W-POS
    CALL "MN9-PUTLONG" USING L-SEED L-HEX W-POS
    CALL "MN9-STRFLAGS" USING L-IGNORE L-AIR L-BBOX L-STRICT W-FLAGS
    CALL "MN9-HEXBYTE" USING W-FLAGS L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-BODY3C.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-BODY3D.
*> USING x y z, mode, message text and length, hex out, byte count out: body of 0x3D Set Test Block (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-MODE L-TEXT L-LEN L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTPOS" USING L-X L-Y L-Z L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-MODE L-HEX W-POS
    CALL "MN9-PUTSTR" USING L-TEXT L-LEN L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-BODY3D.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-BODY1B.
*> USING x y z, levels, keep jigsaws, hex out, byte count out: body of 0x1B Jigsaw Generate (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVELS               BINARY-LONG.
 01 L-KEEP                 BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-LEVELS L-KEEP L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTPOS" USING L-X L-Y L-Z L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-LEVELS L-HEX W-POS
    CALL "MN9-HEXBYTE" USING L-KEEP L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MN9-BODY1B.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN9-LIMIT.
*> USING field (1 command box, 2 minecart command, 3 structure name, 4 structure metadata, 5 structure number boxes, 6 seed box, 7 jigsaw identifiers,
*> 8 final state, 9 priorities, 10 test block message, 11 previous output box), screen limit out, wire string limit out (0 none) (8 table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIELD                BINARY-LONG.
 01 L-SCREEN               BINARY-LONG.
 01 L-WIRE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FIELD L-SCREEN L-WIRE.
    MOVE 0 TO L-SCREEN L-WIRE
    EVALUATE L-FIELD
        WHEN 1
            MOVE 32500 TO L-SCREEN
            MOVE 32767 TO L-WIRE
        WHEN 2
            MOVE 32500 TO L-SCREEN
            MOVE 32767 TO L-WIRE
        WHEN 3
            MOVE 128 TO L-SCREEN
            MOVE 32767 TO L-WIRE
        WHEN 4
            MOVE 128 TO L-SCREEN
            MOVE 128 TO L-WIRE
        WHEN 5
            MOVE 15 TO L-SCREEN
        WHEN 6
            MOVE 31 TO L-SCREEN
        WHEN 7
            MOVE 128 TO L-SCREEN
            MOVE 32767 TO L-WIRE
        WHEN 8
            MOVE 256 TO L-SCREEN
            MOVE 32767 TO L-WIRE
        WHEN 9
            MOVE 3 TO L-SCREEN
        WHEN 10
            MOVE 128 TO L-SCREEN
            MOVE 32767 TO L-WIRE
        WHEN 11
            MOVE 32500 TO L-SCREEN
            MOVE 32767 TO L-WIRE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN9-LIMIT.
