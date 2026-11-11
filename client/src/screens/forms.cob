*> The test block and jigsaw block editor screens (docs/protocol/40-menus-9-block-editor-screens.md sections 6 and 7; 40-menus-x1-continuation.md sections 6 and 7): BLOCKEDIT-USE-CHECK opens the editor of
*> the block used (command block, test block, jigsaw) when the player can use game master blocks; the form screen (SCR-FORM) draws the boxes, cycles, slider and buttons; typed characters go to the
*> focused box; Done and Generate send the packets of editblocks.cob. The client keeps no block entity copy, so the boxes start with the entity defaults (pool, name and target minecraft:empty, final state
*> minecraft:air, priorities 0, rollable, START); the mode descriptions are drawn but resize, Alt and Shift-click cycling are not handled.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKEDIT-USE-CHECK.
*> USING CLIENT-STATE, x, y, z, block state id of the block used: with the permission, a command block family block opens the command block screen, a test_block the test block screen and a jigsaw the
*> jigsaw screen; the jigsaw's front is vertical when its orientation value starts with up_ or down_.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-OK                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(4).
    05 WS-KEY              PIC X(35).
    05 FILLER              PIC X(780).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-FORM.
 01 WS-PROPS.
    05 WS-P-COUNT          BINARY-LONG.
    05 WS-P-ENTRY OCCURS 16 TIMES.
       10 WS-P-NAME        PIC X(24).
       10 WS-P-VALUE       PIC X(32).
 01 WS-I                   BINARY-LONG.
 01 WS-SHORT               PIC X(35).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-STATE.
     CALL "CAN-USE-GM" USING CLIENT-STATE WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "CONTENT-BLOCK-OF-STATE" USING L-STATE WS-BLOCK WS-INDEX WS-ROW WS-STATUS
     IF WS-STATUS NOT = 0
         GOBACK
     END-IF
     MOVE WS-KEY TO WS-SHORT
     EVALUATE WS-SHORT
         WHEN "command_block" WHEN "chain_command_block" WHEN "repeating_command_block"
             CALL "CMDBLOCK-USE-CHECK" USING CLIENT-STATE L-X L-Y L-Z L-STATE
         WHEN "test_block"
             MOVE L-X TO EB-X
             MOVE L-Y TO EB-Y
             MOVE L-Z TO EB-Z
             MOVE 1 TO EB-FORM
             MOVE 0 TO EB-TB-MODE
             MOVE SPACES TO EF-TEXT(1)
             MOVE 0 TO EF-LEN(1)
             MOVE 1 TO EF-FOCUS
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         WHEN "jigsaw"
             MOVE L-X TO EB-X
             MOVE L-Y TO EB-Y
             MOVE L-Z TO EB-Z
             MOVE 2 TO EB-FORM
             MOVE "minecraft:empty" TO EF-TEXT(1) EF-TEXT(2) EF-TEXT(3)
             MOVE 15 TO EF-LEN(1) EF-LEN(2) EF-LEN(3)
             MOVE "minecraft:air" TO EF-TEXT(4)
             MOVE 13 TO EF-LEN(4)
             MOVE "0" TO EF-TEXT(5) EF-TEXT(6)
             MOVE 1 TO EF-LEN(5) EF-LEN(6)
             MOVE 0 TO EB-JG-JOINT EB-LEVELS EB-VERTICAL
             MOVE 1 TO EB-JG-KEEP EF-FOCUS
             CALL "CONTENT-STATE-PROPS" USING L-STATE WS-PROPS WS-STATUS
             IF WS-STATUS = 0
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-P-COUNT
                     IF WS-P-NAME(WS-I) = "orientation" AND (WS-P-VALUE(WS-I)(1:3) = "up_" OR WS-P-VALUE(WS-I)(1:5) = "down_")
                         MOVE 1 TO EB-VERTICAL
                     END-IF
                 END-PERFORM
             END-IF
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-EVALUATE
     GOBACK.
 END PROGRAM BLOCKEDIT-USE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORM-VALID.
*> USING CLIENT-STATE, valid out (1/0): the pool, name and target boxes (1 to 3) each parse as an identifier (Identifier.tryParse: non-empty; the characters a to z, 0 to 9, _, -, . and at most one colon;
*> a slash is accepted anywhere).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-COLONS              BINARY-LONG.
 01 WS-C                   PIC X.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-VALID.
     MOVE 1 TO L-VALID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         IF EF-LEN(WS-I) = 0
             MOVE 0 TO L-VALID
         END-IF
         MOVE 0 TO WS-COLONS
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EF-LEN(WS-I)
             MOVE EF-TEXT(WS-I)(WS-J:1) TO WS-C
             EVALUATE TRUE
                 WHEN WS-C >= "a" AND WS-C <= "z"
                     CONTINUE
                 WHEN WS-C >= "0" AND WS-C <= "9"
                     CONTINUE
                 WHEN WS-C = "_" OR WS-C = "-" OR WS-C = "."
                     CONTINUE
                 WHEN WS-C = "/"
                     CONTINUE
                 WHEN WS-C = ":"
                     ADD 1 TO WS-COLONS
                     IF WS-COLONS > 1
                         MOVE 0 TO L-VALID
                     END-IF
                 WHEN OTHER
                     MOVE 0 TO L-VALID
             END-EVALUATE
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FORM-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORM-FIELD.
*> USING CLIENT-STATE, box index, x, y, width: a box: a field swatch overlay 20 high, a clickable area (focus) and the text at (x + 4, y + 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SWATCH              BINARY-LONG VALUE SW-FIELD.
 01 WS-H                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NOTEXT              PIC X(512).
 01 WS-TEXT                PIC X(512).
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-INDEX L-X L-Y L-W.
     MOVE SPACES TO WS-NOTEXT
     MOVE WK-OVERLAY TO WS-KIND
     MOVE ACT-NONE TO WS-ACTION
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH L-X L-Y L-W WS-H WS-NOTEXT WS-ZERO WS-STATE
     MOVE WK-IMAGE TO WS-KIND
     MOVE ACT-EF-FOCUS TO WS-ACTION
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION L-INDEX L-X L-Y L-W WS-H WS-NOTEXT WS-ZERO WS-STATE
     IF EF-LEN(L-INDEX) > 0
         MOVE SPACES TO WS-TEXT
         MOVE EF-TEXT(L-INDEX)(1:EF-LEN(L-INDEX)) TO WS-TEXT
         COMPUTE WS-TX = L-X + 4
         COMPUTE WS-TY = L-Y + 6
         CALL "BOOK-LABEL" USING CLIENT-STATE WS-TEXT EF-LEN(L-INDEX) WS-TX WS-TY
     END-IF
     GOBACK.
 END PROGRAM FORM-FIELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORM-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height: the test block form (title at y 10, message label and box when the mode is not START, mode cycle, the mode description at (cx - 153, 174), Done, Cancel) or
*> the jigsaw form (labels, the six boxes, the joint cycle when the front is vertical, the levels slider, keep jigsaws, Generate, Done, Cancel), all per 40-x1 sections 6 and 7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 01 WS-CX                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-OUT-256             PIC X(256).
 01 WS-WIDTH               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-VALID               BINARY-LONG.
 01 WS-ED                  PIC Z(8)9.
 01 WS-NAMES               PIC X(32) VALUE "start   log     fail    accept  ".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-MODE-NAME        PIC X(8) OCCURS 4 TIMES.
 01 WS-LABEL-LEN           BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     GO TO MAIN-FLOW.

*> A label of the lang key WS-KEY at (WS-X, WS-Y).
 KEY-LABEL.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     CALL "BOOK-LABEL" USING CLIENT-STATE WS-OUT WS-OUT-LENGTH WS-X WS-Y
     .

*> A button of the lang key WS-KEY with the action WS-ACTION at (WS-X, WS-Y), WS-W x 20, state WS-STATE.
 KEY-BUTTON.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     MOVE 20 TO WS-H
     CALL "BOOK-BUTTON" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-STATE
     .

 DONE-CANCEL.
     MOVE "gui.done" TO WS-KEY
     MOVE ACT-EF-DONE TO WS-ACTION
     COMPUTE WS-X = WS-CX - 154
     MOVE 210 TO WS-Y
     MOVE 150 TO WS-W
     PERFORM KEY-BUTTON
     MOVE "gui.cancel" TO WS-KEY
     MOVE ACT-CLOSE-MENU TO WS-ACTION
     MOVE 0 TO WS-STATE
     COMPUTE WS-X = WS-CX + 4
     PERFORM KEY-BUTTON
     .

 MAIN-FLOW.
     COMPUTE WS-CX = L-GW / 2
     MOVE 0 TO WS-STATE
     IF EB-FORM = 1
         MOVE "block.minecraft.test_block" TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
         MOVE WS-OUT(1:256) TO WS-OUT-256
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-OUT-256 WS-OUT-LENGTH WS-WIDTH
         COMPUTE WS-X = WS-CX - WS-WIDTH / 2
         MOVE 10 TO WS-Y
         CALL "BOOK-LABEL" USING CLIENT-STATE WS-OUT WS-OUT-LENGTH WS-X WS-Y
         IF EB-TB-MODE NOT = 0
             MOVE "test_block.message" TO WS-KEY
             COMPUTE WS-X = WS-CX - 153
             MOVE 70 TO WS-Y
             PERFORM KEY-LABEL
             MOVE 1 TO WS-IDX
             COMPUTE WS-X = WS-CX - 152
             MOVE 80 TO WS-Y
             MOVE 240 TO WS-W
             CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         END-IF
         MOVE SPACES TO WS-KEY
         STRING "test_block.mode." FUNCTION TRIM(WS-MODE-NAME(EB-TB-MODE + 1)) DELIMITED BY SIZE INTO WS-KEY
         MOVE ACT-EF-MODE TO WS-ACTION
         COMPUTE WS-X = WS-CX - 154
         MOVE 185 TO WS-Y
         MOVE 50 TO WS-W
         PERFORM KEY-BUTTON
         MOVE SPACES TO WS-KEY
         STRING "test_block.mode_info." FUNCTION TRIM(WS-MODE-NAME(EB-TB-MODE + 1)) DELIMITED BY SIZE INTO WS-KEY
         COMPUTE WS-X = WS-CX - 153
         MOVE 174 TO WS-Y
         PERFORM KEY-LABEL
         PERFORM DONE-CANCEL
     ELSE
         MOVE "jigsaw_block.pool" TO WS-KEY
         COMPUTE WS-X = WS-CX - 153
         MOVE 10 TO WS-Y
         PERFORM KEY-LABEL
         MOVE "jigsaw_block.name" TO WS-KEY
         MOVE 45 TO WS-Y
         PERFORM KEY-LABEL
         MOVE "jigsaw_block.target" TO WS-KEY
         MOVE 80 TO WS-Y
         PERFORM KEY-LABEL
         MOVE "jigsaw_block.final_state" TO WS-KEY
         MOVE 115 TO WS-Y
         PERFORM KEY-LABEL
         MOVE "jigsaw_block.selection_priority" TO WS-KEY
         MOVE 150 TO WS-Y
         PERFORM KEY-LABEL
         MOVE "jigsaw_block.placement_priority" TO WS-KEY
         COMPUTE WS-X = WS-CX - 50
         PERFORM KEY-LABEL
         COMPUTE WS-X = WS-CX - 153
         MOVE 300 TO WS-W
         MOVE 1 TO WS-IDX
         MOVE 20 TO WS-Y
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         MOVE 2 TO WS-IDX
         MOVE 55 TO WS-Y
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         MOVE 3 TO WS-IDX
         MOVE 90 TO WS-Y
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         MOVE 4 TO WS-IDX
         MOVE 125 TO WS-Y
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         MOVE 98 TO WS-W
         MOVE 5 TO WS-IDX
         MOVE 160 TO WS-Y
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         MOVE 6 TO WS-IDX
         COMPUTE WS-X = WS-CX - 50
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         IF EB-VERTICAL = 1
             MOVE "jigsaw_block.joint_label" TO WS-KEY
             COMPUTE WS-X = WS-CX + 53
             MOVE 150 TO WS-Y
             PERFORM KEY-LABEL
             IF EB-JG-JOINT = 1
                 MOVE "jigsaw_block.joint.aligned" TO WS-KEY
             ELSE
                 MOVE "jigsaw_block.joint.rollable" TO WS-KEY
             END-IF
             MOVE ACT-EF-MODE TO WS-ACTION
             COMPUTE WS-X = WS-CX + 54
             MOVE 160 TO WS-Y
             MOVE 100 TO WS-W
             PERFORM KEY-BUTTON
         END-IF
         CALL "FORM-VALID" USING CLIENT-STATE WS-VALID
*>       The slider (a button reading Levels: n), keep jigsaws and Generate.
         MOVE 1 TO LA-COUNT
         MOVE EB-LEVELS TO WS-ED
         MOVE FUNCTION TRIM(WS-ED) TO LA-TEXT(1)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ED)) TO LA-LENGTH(1)
         MOVE "jigsaw_block.levels" TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-OUT WS-OUT-LENGTH
         COMPUTE WS-X = WS-CX - 154
         MOVE 185 TO WS-Y
         MOVE 100 TO WS-W
         MOVE 20 TO WS-H
         MOVE ACT-EF-LEVELS TO WS-ACTION
         CALL "WIDGET-ADD" USING CLIENT-STATE WK-BUTTON WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-OUT WS-OUT-LENGTH WS-STATE
         MOVE "jigsaw_block.keep_jigsaws" TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
         IF EB-JG-KEEP = 1
             MOVE ": ON" TO WS-OUT(WS-OUT-LENGTH + 1:4)
         ELSE
             MOVE ": OFF" TO WS-OUT(WS-OUT-LENGTH + 1:5)
             ADD 1 TO WS-OUT-LENGTH
         END-IF
         ADD 4 TO WS-OUT-LENGTH
         COMPUTE WS-X = WS-CX - 50
         MOVE ACT-EF-KEEP TO WS-ACTION
         CALL "WIDGET-ADD" USING CLIENT-STATE WK-BUTTON WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-OUT WS-OUT-LENGTH WS-STATE
         MOVE 0 TO WS-STATE
         IF WS-VALID = 0
             MOVE 2 TO WS-STATE
         END-IF
         MOVE "jigsaw_block.generate" TO WS-KEY
         MOVE ACT-EF-GENERATE TO WS-ACTION
         COMPUTE WS-X = WS-CX + 54
         PERFORM KEY-BUTTON
         PERFORM DONE-CANCEL
     END-IF
     GOBACK.
 END PROGRAM FORM-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORM-SEND.
*> USING CLIENT-STATE, generate (1/0): onDone: the test block sends Set Test Block with the position, mode and the box text; the jigsaw (only when valid) Set Jigsaw Block from the boxes (the identifiers
*> with minecraft: added when they have no namespace, the priorities by number, 0 on a bad text) and, for Generate, Jigsaw Generate; then the world screen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-VALID               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-TEXT                PIC X(1100).
 01 WS-NUM                 PIC X(8).
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 01 WS-LEN                 BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-NUMERIC             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GENERATE             BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GENERATE.
     IF EB-FORM = 1
         MOVE SPACES TO WS-TEXT
         IF EF-LEN(1) > 0
             MOVE EF-TEXT(1)(1:EF-LEN(1)) TO WS-TEXT
         END-IF
         CALL "SEND-SET-TEST-BLOCK" USING CLIENT-STATE EB-X EB-Y EB-Z EB-TB-MODE WS-TEXT EF-LEN(1)
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         GOBACK
     END-IF
     CALL "FORM-VALID" USING CLIENT-STATE WS-VALID
     IF WS-VALID = 0
         GOBACK
     END-IF
*>   Packet order: name, target, pool, final state (boxes 2, 3, 1, 4).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE 2 TO WS-J
             WHEN 2 MOVE 3 TO WS-J
             WHEN 3 MOVE 1 TO WS-J
             WHEN 4 MOVE 4 TO WS-J
         END-EVALUATE
         MOVE 0 TO WS-COLON
         PERFORM VARYING WS-LEN FROM 1 BY 1 UNTIL WS-LEN > EF-LEN(WS-J)
             IF EF-TEXT(WS-J)(WS-LEN:1) = ":"
                 MOVE 1 TO WS-COLON
             END-IF
         END-PERFORM
         MOVE SPACES TO EB-JG-TEXT(WS-I)
         IF WS-I < 4 AND WS-COLON = 0
             STRING "minecraft:" EF-TEXT(WS-J)(1:EF-LEN(WS-J)) DELIMITED BY SIZE INTO EB-JG-TEXT(WS-I)
             COMPUTE EB-JG-LEN(WS-I) = EF-LEN(WS-J) + 10
         ELSE
             IF EF-LEN(WS-J) > 0
                 MOVE EF-TEXT(WS-J)(1:EF-LEN(WS-J)) TO EB-JG-TEXT(WS-I)
             END-IF
             MOVE EF-LEN(WS-J) TO EB-JG-LEN(WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 5 BY 1 UNTIL WS-I > 6
         MOVE 0 TO WS-NUMERIC
         MOVE FUNCTION TRIM(EF-TEXT(WS-I)(1:EF-LEN(WS-I))) TO WS-NUM
         IF EF-LEN(WS-I) > 0 AND FUNCTION TEST-NUMVAL(WS-NUM(1:EF-LEN(WS-I))) = 0
             MOVE FUNCTION NUMVAL(WS-NUM(1:EF-LEN(WS-I))) TO WS-NUMERIC
         END-IF
         IF WS-I = 5
             MOVE WS-NUMERIC TO EB-JG-SELECTION
         ELSE
             MOVE WS-NUMERIC TO EB-JG-PLACEMENT
         END-IF
     END-PERFORM
     CALL "SEND-SET-JIGSAW-BLOCK" USING CLIENT-STATE EB-X EB-Y EB-Z
     IF L-GENERATE = 1
         CALL "SEND-JIGSAW-GENERATE" USING CLIENT-STATE EB-X EB-Y EB-Z EB-LEVELS EB-JG-KEEP
     END-IF
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     GOBACK.
 END PROGRAM FORM-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORM-ACTION.
*> USING CLIENT-STATE, action, argument: focus a box; the test block mode cycle (START, LOG, FAIL, ACCEPT) or the jigsaw joint cycle; the keep flag; the levels slider (a click at x gives
*> floor(20 x clamp((x - left - 4) / 92, 0, 1))); Done and Generate (only while the identifiers are valid, which the inactive buttons already enforce).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X                   BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG.
     EVALUATE L-ACTION
         WHEN ACT-EF-FOCUS
             MOVE L-ARG TO EF-FOCUS
         WHEN ACT-EF-MODE
             IF EB-FORM = 1
                 COMPUTE EB-TB-MODE = FUNCTION MOD(EB-TB-MODE + 1, 4)
             ELSE
                 COMPUTE EB-JG-JOINT = 1 - EB-JG-JOINT
             END-IF
         WHEN ACT-EF-KEEP
             COMPUTE EB-JG-KEEP = 1 - EB-JG-KEEP
         WHEN ACT-EF-LEVELS
             COMPUTE WS-X = IN-CLICK-X / CL-GUI-SCALE
             COMPUTE WS-LEFT = (FUNCTION MAX(IN-WIN-W / CL-GUI-SCALE, CL-MIN-GUI-W)) / 2 - 154
             COMPUTE WS-VALUE = FUNCTION MAX(0, FUNCTION MIN(1, (WS-X - WS-LEFT - 4) / 92.0))
             COMPUTE EB-LEVELS = FUNCTION INTEGER-PART(20 * WS-VALUE)
         WHEN ACT-EF-DONE
             CALL "FORM-SEND" USING CLIENT-STATE WS-NO
         WHEN ACT-EF-GENERATE
             CALL "FORM-SEND" USING CLIENT-STATE WS-YES
     END-EVALUATE
     GOBACK.
 END PROGRAM FORM-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORM-INPUT.
*> USING CLIENT-STATE: typed characters (32 to 126) go to the focused box up to its limit (the test block message 128; the jigsaw pool, name and target 128, final state 256, priorities 3); Backspace
*> removes one; Enter (257, 335) is Done on the jigsaw while it is valid (nothing on the test block); Escape closes with no packet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF EF-FOCUS >= 1 AND EF-FOCUS <= 6
         MOVE 128 TO WS-MAX
         IF EB-FORM = 2 AND EF-FOCUS = 4
             MOVE 256 TO WS-MAX
         END-IF
         IF EB-FORM = 2 AND EF-FOCUS >= 5
             MOVE 3 TO WS-MAX
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
             IF IN-TEXT(WS-I) >= 32 AND IN-TEXT(WS-I) < 127 AND EF-LEN(EF-FOCUS) < WS-MAX
                 ADD 1 TO EF-LEN(EF-FOCUS)
                 MOVE FUNCTION CHAR(IN-TEXT(WS-I) + 1) TO EF-TEXT(EF-FOCUS)(EF-LEN(EF-FOCUS):1)
             END-IF
         END-PERFORM
         IF IN-KEY-PRESSED(CC-KEY-BACKSPACE + 1) = 1 AND EF-LEN(EF-FOCUS) > 0
             MOVE SPACE TO EF-TEXT(EF-FOCUS)(EF-LEN(EF-FOCUS):1)
             SUBTRACT 1 FROM EF-LEN(EF-FOCUS)
         END-IF
     END-IF
     IF EB-FORM = 2 AND (IN-KEY-PRESSED(257 + 1) = 1 OR IN-KEY-PRESSED(335 + 1) = 1)
         CALL "FORM-VALID" USING CLIENT-STATE WS-VALID
         IF WS-VALID = 1
             CALL "FORM-SEND" USING CLIENT-STATE WS-NO
         END-IF
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-ESCAPE + 1) = 1 AND SM-SCREEN = SCR-FORM
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-IF
     GOBACK.
 END PROGRAM FORM-INPUT.
