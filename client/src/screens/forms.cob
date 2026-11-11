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
         WHEN "structure_block"
             MOVE L-X TO EB-X
             MOVE L-Y TO EB-Y
             MOVE L-Z TO EB-Z
             MOVE 3 TO EB-FORM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
                 MOVE SPACES TO EF-TEXT(WS-I)
                 MOVE 0 TO EF-LEN(WS-I)
             END-PERFORM
             MOVE "0" TO EF-TEXT(2) EF-TEXT(3) EF-TEXT(4) EF-TEXT(5) EF-TEXT(6) EF-TEXT(7) EF-TEXT(9)
             MOVE 1 TO EF-LEN(2) EF-LEN(3) EF-LEN(4) EF-LEN(5) EF-LEN(6) EF-LEN(7) EF-LEN(9)
             MOVE "1.0" TO EF-TEXT(8)
             MOVE 3 TO EF-LEN(8)
             MOVE 0 TO EB-ST-MODE EB-ST-MIRROR EB-ST-ROTATION
             MOVE 4 TO EB-ST-FLAGS
             MOVE EB-ST-MODE TO EB-ST-INIT-MODE
             MOVE EB-ST-MIRROR TO EB-ST-INIT-MIRROR
             MOVE EB-ST-ROTATION TO EB-ST-INIT-ROT
             MOVE EB-ST-FLAGS TO EB-ST-INIT-FLAGS
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
     IF EB-FORM = 3
         CALL "STRUCT-BUILD" USING CLIENT-STATE L-GW L-GH
         GOBACK
     END-IF
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
         WHEN ACT-ST-MODE THRU ACT-ST-CANCEL
             CALL "STRUCT-ACTION" USING CLIENT-STATE L-ACTION L-ARG
         WHEN ACT-EF-DONE
             IF EB-FORM = 3
                 CALL "STRUCT-SEND" USING CLIENT-STATE WS-NO
             ELSE
                 CALL "FORM-SEND" USING CLIENT-STATE WS-NO
             END-IF
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
 01 WS-OKC                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF EF-FOCUS >= 1 AND EF-FOCUS <= 10 AND (EB-FORM = 3 OR EF-FOCUS <= 6)
         MOVE 128 TO WS-MAX
         IF EB-FORM = 3 AND EF-FOCUS >= 2 AND EF-FOCUS <= 8
             MOVE 15 TO WS-MAX
         END-IF
         IF EB-FORM = 3 AND EF-FOCUS = 9
             MOVE 31 TO WS-MAX
         END-IF
         IF EB-FORM = 2 AND EF-FOCUS = 4
             MOVE 256 TO WS-MAX
         END-IF
         IF EB-FORM = 2 AND EF-FOCUS >= 5
             MOVE 3 TO WS-MAX
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
             MOVE 1 TO WS-OKC
             IF EB-FORM = 3 AND EF-FOCUS = 1 AND IN-TEXT(WS-I) >= 32 AND IN-TEXT(WS-I) < 127
                 CALL "STRUCT-NAME-CHAR" USING CLIENT-STATE IN-TEXT(WS-I) WS-OKC
             END-IF
             IF IN-TEXT(WS-I) >= 32 AND IN-TEXT(WS-I) < 127 AND EF-LEN(EF-FOCUS) < WS-MAX AND WS-OKC = 1
                 ADD 1 TO EF-LEN(EF-FOCUS)
                 MOVE FUNCTION CHAR(IN-TEXT(WS-I) + 1) TO EF-TEXT(EF-FOCUS)(EF-LEN(EF-FOCUS):1)
             END-IF
         END-PERFORM
         IF IN-KEY-PRESSED(CC-KEY-BACKSPACE + 1) = 1 AND EF-LEN(EF-FOCUS) > 0
             MOVE SPACE TO EF-TEXT(EF-FOCUS)(EF-LEN(EF-FOCUS):1)
             SUBTRACT 1 FROM EF-LEN(EF-FOCUS)
         END-IF
     END-IF
     IF EB-FORM = 3 AND (IN-KEY-PRESSED(257 + 1) = 1 OR IN-KEY-PRESSED(335 + 1) = 1)
         CALL "STRUCT-SEND" USING CLIENT-STATE WS-NO
     END-IF
     IF EB-FORM = 2 AND (IN-KEY-PRESSED(257 + 1) = 1 OR IN-KEY-PRESSED(335 + 1) = 1)
         CALL "FORM-VALID" USING CLIENT-STATE WS-VALID
         IF WS-VALID = 1
             CALL "FORM-SEND" USING CLIENT-STATE WS-NO
         END-IF
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-ESCAPE + 1) = 1 AND SM-SCREEN = SCR-FORM
         IF EB-FORM = 3
             CALL "STRUCT-RESTORE" USING CLIENT-STATE
         END-IF
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-IF
     GOBACK.
 END PROGRAM FORM-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-NAME-CHAR.
*> USING CLIENT-STATE, code point typed at the end of the name box, ok out (1/0): 5.4 isValidCharacterForName: a colon only when there is none yet (and before any slash), a slash always at the end, otherwise
*> _ - . a to z and 0 to 9 (upper case and a space are refused).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-SLASH               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CODE                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CODE L-OK.
     MOVE -1 TO WS-COLON WS-SLASH
     PERFORM VARYING WS-I FROM EF-LEN(1) BY -1 UNTIL WS-I < 1
         IF EF-TEXT(1)(WS-I:1) = ":"
             COMPUTE WS-COLON = WS-I - 1
         END-IF
         IF EF-TEXT(1)(WS-I:1) = "/"
             COMPUTE WS-SLASH = WS-I - 1
         END-IF
     END-PERFORM
     MOVE 0 TO L-OK
     EVALUATE TRUE
         WHEN L-CODE = 58
             IF WS-COLON = -1 AND (WS-SLASH = -1 OR EF-LEN(1) <= WS-SLASH)
                 MOVE 1 TO L-OK
             END-IF
         WHEN L-CODE = 47
             IF EF-LEN(1) > WS-COLON
                 MOVE 1 TO L-OK
             END-IF
         WHEN L-CODE = 95 OR L-CODE = 45 OR L-CODE = 46
             MOVE 1 TO L-OK
         WHEN L-CODE >= 97 AND L-CODE <= 122
             MOVE 1 TO L-OK
         WHEN L-CODE >= 48 AND L-CODE <= 57
             MOVE 1 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-NAME-CHAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RESTORE.
*> USING CLIENT-STATE: Cancel and Escape (5.7): the seven initial values go back to the entity (here the mode, mirror, rotation and flags kept at open).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE EB-ST-INIT-MODE TO EB-ST-MODE
     MOVE EB-ST-INIT-MIRROR TO EB-ST-MIRROR
     MOVE EB-ST-INIT-ROT TO EB-ST-ROTATION
     MOVE EB-ST-INIT-FLAGS TO EB-ST-FLAGS
     GOBACK.
 END PROGRAM STRUCT-RESTORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-NUM.
*> USING CLIENT-STATE, box, value out (BINARY-DOUBLE), ok out: the box text as an integer (Integer.parseInt and Long.valueOf: an optional sign and digits); not a number gives ok 0 and value 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   PIC X.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-BOX                  BINARY-LONG.
 01 L-VALUE                BINARY-DOUBLE.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-BOX L-VALUE L-OK.
     MOVE 0 TO L-VALUE
     MOVE 0 TO L-OK
     IF EF-LEN(L-BOX) > 0
         MOVE 1 TO L-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-LEN(L-BOX)
             MOVE EF-TEXT(L-BOX)(WS-I:1) TO WS-C
             IF NOT ((WS-C >= "0" AND WS-C <= "9") OR (WS-I = 1 AND (WS-C = "-" OR WS-C = "+") AND EF-LEN(L-BOX) > 1))
                 MOVE 0 TO L-OK
             END-IF
         END-PERFORM
         IF L-OK = 1
             MOVE FUNCTION NUMVAL(EF-TEXT(L-BOX)(1:EF-LEN(L-BOX))) TO L-VALUE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-NUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SEND.
*> USING CLIENT-STATE, update type (0 UPDATE_DATA, 1 SAVE_AREA, 2 LOAD_AREA, 3 SCAN_AREA): 5.6: Set Structure Block from the boxes (offset and size by Integer.parseInt, 0 on failure; integrity
*> Float.valueOf, 1.0 on failure; seed 0 on failure; the name and the custom data as typed) and the entity values; then the world screen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-OK                  BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 01 WS-FRACTION            PIC X(32).
 01 WS-DOTS                BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-C                   PIC X.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-UPDATE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-UPDATE.
     MOVE L-UPDATE TO EB-ST-UPDATE
     MOVE SPACES TO EB-ST-NAME EB-ST-META
     MOVE EF-LEN(1) TO EB-ST-NAME-LEN
     IF EF-LEN(1) > 0
         MOVE EF-TEXT(1)(1:EF-LEN(1)) TO EB-ST-NAME
     END-IF
     MOVE EF-LEN(10) TO EB-ST-META-LEN
     IF EF-LEN(10) > 0
         MOVE EF-TEXT(10)(1:EF-LEN(10)) TO EB-ST-META
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-J = WS-I + 1
         CALL "STRUCT-NUM" USING CLIENT-STATE WS-J WS-V WS-OK
         MOVE WS-V TO EB-ST-OFFSET(WS-I)
         COMPUTE WS-J = WS-I + 4
         CALL "STRUCT-NUM" USING CLIENT-STATE WS-J WS-V WS-OK
         MOVE WS-V TO EB-ST-SIZE(WS-I)
     END-PERFORM
*>   Integrity: Float.valueOf: digits with one optional dot and an optional sign, else 1.0.
     MOVE 1 TO WS-OK
     MOVE 0 TO WS-DOTS
     IF EF-LEN(8) = 0
         MOVE 0 TO WS-OK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-LEN(8)
         MOVE EF-TEXT(8)(WS-I:1) TO WS-C
         IF WS-C = "."
             ADD 1 TO WS-DOTS
         ELSE
             IF NOT ((WS-C >= "0" AND WS-C <= "9") OR (WS-I = 1 AND (WS-C = "-" OR WS-C = "+")))
                 MOVE 0 TO WS-OK
             END-IF
         END-IF
     END-PERFORM
     IF WS-DOTS > 1
         MOVE 0 TO WS-OK
     END-IF
     IF WS-OK = 1
         COMPUTE EB-ST-INTEGRITY = FUNCTION NUMVAL(EF-TEXT(8)(1:EF-LEN(8)))
     ELSE
         MOVE 1.0 TO EB-ST-INTEGRITY
     END-IF
     CALL "STRUCT-NUM" USING CLIENT-STATE 9 EB-ST-SEED WS-OK
     CALL "SEND-SET-STRUCTURE-BLOCK" USING CLIENT-STATE EB-X EB-Y EB-Z
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     GOBACK.
 END PROGRAM STRUCT-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ACTION.
*> USING CLIENT-STATE, action, argument: the mode cycle (SAVE, LOAD, CORNER; from DATA the first click gives SAVE), the include entities, strict, show air and show bounding box toggles (changing the entity's
*> flags at once), the mirror cycle, the rotation buttons (the argument 0 to 3), SAVE, LOAD and DETECT (each only in its mode: the update type SAVE_AREA, LOAD_AREA, SCAN_AREA, then close) and Cancel (restore).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-BIT                 BINARY-LONG.
 01 WS-UPDATE              BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG.
     MOVE 0 TO WS-BIT
     EVALUATE L-ACTION
         WHEN ACT-ST-MODE
             IF EB-ST-MODE = 3
                 MOVE 0 TO EB-ST-MODE
             ELSE
                 COMPUTE EB-ST-MODE = FUNCTION MOD(EB-ST-MODE + 1, 3)
             END-IF
         WHEN ACT-ST-INCLUDE
             MOVE 1 TO WS-BIT
         WHEN ACT-ST-SHOWAIR
             MOVE 2 TO WS-BIT
         WHEN ACT-ST-SHOWBB
             MOVE 4 TO WS-BIT
         WHEN ACT-ST-STRICT
             MOVE 8 TO WS-BIT
         WHEN ACT-ST-MIRROR
             COMPUTE EB-ST-MIRROR = FUNCTION MOD(EB-ST-MIRROR + 1, 3)
         WHEN ACT-ST-ROT
             MOVE L-ARG TO EB-ST-ROTATION
         WHEN ACT-ST-SAVE
             IF EB-ST-MODE = 0
                 MOVE 1 TO WS-UPDATE
                 CALL "STRUCT-SEND" USING CLIENT-STATE WS-UPDATE
             END-IF
         WHEN ACT-ST-LOAD
             IF EB-ST-MODE = 1
                 MOVE 2 TO WS-UPDATE
                 CALL "STRUCT-SEND" USING CLIENT-STATE WS-UPDATE
             END-IF
         WHEN ACT-ST-DETECT
             IF EB-ST-MODE = 0
                 MOVE 3 TO WS-UPDATE
                 CALL "STRUCT-SEND" USING CLIENT-STATE WS-UPDATE
             END-IF
         WHEN ACT-ST-CANCEL
             CALL "STRUCT-RESTORE" USING CLIENT-STATE
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-EVALUATE
     IF WS-BIT > 0
         IF FUNCTION MOD(FUNCTION INTEGER-PART(EB-ST-FLAGS / WS-BIT), 2) = 1
             SUBTRACT WS-BIT FROM EB-ST-FLAGS
         ELSE
             ADD WS-BIT TO EB-ST-FLAGS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRUCT-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height: 5.2, 5.3 and 5.5 for cx = W / 2: the title at (cx, 10); the boxes and labels of the entity's mode (SAVE, LOAD, CORNER, DATA), then the buttons in the order mode,
*> SAVE or LOAD, DETECT, include entities, strict, mirror, the four rotations (the current one inactive), show air or show bounding box, Done, Cancel; the mode description at (cx - 153, 174).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-CX                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG VALUE 20.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-OUT-256             PIC X(256).
 01 WS-WIDTH               BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-BITV                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LIT                 PIC X(4).
 01 WS-LIT-LEN             BINARY-LONG.
 01 WS-NAMES               PIC X(32) VALUE "save    load    corner  data    ".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-MODE-NAME        PIC X(8) OCCURS 4 TIMES.
 01 WS-MIRRORS             PIC X(36) VALUE "none        left_right  front_back  ".
 01 WS-MIRROR-TABLE REDEFINES WS-MIRRORS.
    05 WS-MIRROR-NAME      PIC X(12) OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     GO TO MAIN-FLOW.

*> A label of the lang key WS-KEY at (WS-X, WS-Y); right aligned to cx + 154 when WS-RIGHT is 1.
 KEY-LABEL.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     IF WS-RIGHT = 1
         MOVE WS-OUT(1:256) TO WS-OUT-256
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-OUT-256 WS-OUT-LENGTH WS-WIDTH
         COMPUTE WS-X = WS-CX + 154 - WS-WIDTH
     END-IF
     CALL "BOOK-LABEL" USING CLIENT-STATE WS-OUT WS-OUT-LENGTH WS-X WS-Y
     .

*> A button of the lang key WS-KEY (action WS-ACTION, argument WS-ARG) at (WS-X, WS-Y), WS-W x 20, state WS-STATE.
 KEY-BUTTON.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     CALL "BOOK-BUTTON" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-STATE
     .

*> An on/off button for the flag bit WS-BITV (inverted for include entities when WS-RIGHT is 2) at (WS-X, WS-Y), 50 x 20.
 TOGGLE.
     MOVE 50 TO WS-W
     IF (FUNCTION MOD(FUNCTION INTEGER-PART(EB-ST-FLAGS / WS-BITV), 2) = 1 AND WS-RIGHT NOT = 2) OR (FUNCTION MOD(FUNCTION INTEGER-PART(EB-ST-FLAGS / WS-BITV), 2) = 0 AND WS-RIGHT = 2)
         MOVE "options.on" TO WS-KEY
     ELSE
         MOVE "options.off" TO WS-KEY
     END-IF
     MOVE 0 TO WS-STATE
     PERFORM KEY-BUTTON
     .

 MAIN-FLOW.
     COMPUTE WS-CX = L-GW / 2
     MOVE 0 TO WS-RIGHT
     MOVE "block.minecraft.structure_block" TO WS-KEY
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     MOVE WS-OUT(1:256) TO WS-OUT-256
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-OUT-256 WS-OUT-LENGTH WS-WIDTH
     COMPUTE WS-X = WS-CX - WS-WIDTH / 2
     MOVE 10 TO WS-Y
     CALL "BOOK-LABEL" USING CLIENT-STATE WS-OUT WS-OUT-LENGTH WS-X WS-Y
*>   Labels and boxes of the mode.
     IF EB-ST-MODE NOT = 3
         MOVE "structure_block.structure_name" TO WS-KEY
         COMPUTE WS-X = WS-CX - 153
         MOVE 30 TO WS-Y
         PERFORM KEY-LABEL
         MOVE 1 TO WS-IDX
         COMPUTE WS-X = WS-CX - 152
         MOVE 40 TO WS-Y
         MOVE 300 TO WS-W
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
     END-IF
     IF EB-ST-MODE = 0 OR EB-ST-MODE = 1
         MOVE "structure_block.position" TO WS-KEY
         COMPUTE WS-X = WS-CX - 153
         MOVE 70 TO WS-Y
         PERFORM KEY-LABEL
         MOVE "structure_block.include_entities" TO WS-KEY
         MOVE 150 TO WS-Y
         MOVE 1 TO WS-RIGHT
         PERFORM KEY-LABEL
         MOVE 0 TO WS-RIGHT
         MOVE 80 TO WS-W
         MOVE 80 TO WS-Y
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
             COMPUTE WS-IDX = 2 + WS-I
             COMPUTE WS-X = WS-CX - 152 + 80 * WS-I
             CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         END-PERFORM
     END-IF
     IF EB-ST-MODE = 0
         MOVE "structure_block.size" TO WS-KEY
         COMPUTE WS-X = WS-CX - 153
         MOVE 110 TO WS-Y
         PERFORM KEY-LABEL
         MOVE "structure_block.detect_size" TO WS-KEY
         MOVE 1 TO WS-RIGHT
         PERFORM KEY-LABEL
         MOVE "structure_block.show_air" TO WS-KEY
         MOVE 70 TO WS-Y
         PERFORM KEY-LABEL
         MOVE 0 TO WS-RIGHT
         MOVE 80 TO WS-W
         MOVE 120 TO WS-Y
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
             COMPUTE WS-IDX = 5 + WS-I
             COMPUTE WS-X = WS-CX - 152 + 80 * WS-I
             CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         END-PERFORM
     END-IF
     IF EB-ST-MODE = 1
         MOVE "structure_block.integrity" TO WS-KEY
         COMPUTE WS-X = WS-CX - 153
         MOVE 110 TO WS-Y
         PERFORM KEY-LABEL
         MOVE "structure_block.strict" TO WS-KEY
         MOVE 1 TO WS-RIGHT
         PERFORM KEY-LABEL
         MOVE "structure_block.show_boundingbox" TO WS-KEY
         MOVE 70 TO WS-Y
         PERFORM KEY-LABEL
         MOVE 0 TO WS-RIGHT
         MOVE 80 TO WS-W
         MOVE 120 TO WS-Y
         MOVE 8 TO WS-IDX
         COMPUTE WS-X = WS-CX - 152
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
         MOVE 9 TO WS-IDX
         COMPUTE WS-X = WS-CX - 72
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
     END-IF
     IF EB-ST-MODE = 3
         MOVE "structure_block.custom_data" TO WS-KEY
         COMPUTE WS-X = WS-CX - 153
         MOVE 110 TO WS-Y
         PERFORM KEY-LABEL
         MOVE 10 TO WS-IDX
         COMPUTE WS-X = WS-CX - 152
         MOVE 120 TO WS-Y
         MOVE 240 TO WS-W
         CALL "FORM-FIELD" USING CLIENT-STATE WS-IDX WS-X WS-Y WS-W
     END-IF
*>   Buttons.
     MOVE SPACES TO WS-KEY
     STRING "structure_block.mode." FUNCTION TRIM(WS-MODE-NAME(EB-ST-MODE + 1)) DELIMITED BY SIZE INTO WS-KEY
     MOVE ACT-ST-MODE TO WS-ACTION
     COMPUTE WS-X = WS-CX - 154
     MOVE 185 TO WS-Y
     MOVE 50 TO WS-W
     MOVE 0 TO WS-STATE
     PERFORM KEY-BUTTON
     IF EB-ST-MODE = 0
         MOVE "structure_block.button.save" TO WS-KEY
         MOVE ACT-ST-SAVE TO WS-ACTION
         COMPUTE WS-X = WS-CX + 104
         PERFORM KEY-BUTTON
         MOVE "structure_block.button.detect_size" TO WS-KEY
         MOVE ACT-ST-DETECT TO WS-ACTION
         MOVE 120 TO WS-Y
         PERFORM KEY-BUTTON
     END-IF
     IF EB-ST-MODE = 1
         MOVE "structure_block.button.load" TO WS-KEY
         MOVE ACT-ST-LOAD TO WS-ACTION
         COMPUTE WS-X = WS-CX + 104
         PERFORM KEY-BUTTON
     END-IF
     IF EB-ST-MODE = 0 OR EB-ST-MODE = 1
         MOVE ACT-ST-INCLUDE TO WS-ACTION
         MOVE 1 TO WS-BITV
         MOVE 2 TO WS-RIGHT
         COMPUTE WS-X = WS-CX + 104
         MOVE 160 TO WS-Y
         PERFORM TOGGLE
         MOVE 0 TO WS-RIGHT
     END-IF
     IF EB-ST-MODE = 1
         MOVE ACT-ST-STRICT TO WS-ACTION
         MOVE 8 TO WS-BITV
         MOVE 120 TO WS-Y
         PERFORM TOGGLE
         MOVE SPACES TO WS-KEY
         STRING "mirror." FUNCTION TRIM(WS-MIRROR-NAME(EB-ST-MIRROR + 1)) DELIMITED BY SIZE INTO WS-KEY
         MOVE ACT-ST-MIRROR TO WS-ACTION
         COMPUTE WS-X = WS-CX - 20
         MOVE 185 TO WS-Y
         MOVE 40 TO WS-W
         MOVE 0 TO WS-STATE
         PERFORM KEY-BUTTON
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
             EVALUATE WS-I
                 WHEN 0
                     COMPUTE WS-X = WS-CX - 102
                     MOVE "0" TO WS-LIT
                     MOVE 1 TO WS-LIT-LEN
                 WHEN 1
                     COMPUTE WS-X = WS-CX - 61
                     MOVE "90" TO WS-LIT
                     MOVE 2 TO WS-LIT-LEN
                 WHEN 2
                     COMPUTE WS-X = WS-CX + 21
                     MOVE "180" TO WS-LIT
                     MOVE 3 TO WS-LIT-LEN
                 WHEN 3
                     COMPUTE WS-X = WS-CX + 62
                     MOVE "270" TO WS-LIT
                     MOVE 3 TO WS-LIT-LEN
             END-EVALUATE
             MOVE 0 TO WS-STATE
             IF EB-ST-ROTATION = WS-I
                 MOVE 2 TO WS-STATE
             END-IF
             MOVE WS-I TO WS-ARG
             MOVE WS-LIT TO WS-OUT
             MOVE ACT-ST-ROT TO WS-ACTION
             CALL "WIDGET-ADD" USING CLIENT-STATE WK-BUTTON WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-OUT WS-LIT-LEN WS-STATE
         END-PERFORM
         MOVE 0 TO WS-ARG
         MOVE 0 TO WS-STATE
         MOVE ACT-ST-SHOWBB TO WS-ACTION
         MOVE 4 TO WS-BITV
         COMPUTE WS-X = WS-CX + 104
         MOVE 80 TO WS-Y
         PERFORM TOGGLE
     END-IF
     IF EB-ST-MODE = 0
         MOVE ACT-ST-SHOWAIR TO WS-ACTION
         MOVE 2 TO WS-BITV
         COMPUTE WS-X = WS-CX + 104
         MOVE 80 TO WS-Y
         PERFORM TOGGLE
     END-IF
     MOVE "gui.done" TO WS-KEY
     MOVE ACT-EF-DONE TO WS-ACTION
     COMPUTE WS-X = WS-CX - 154
     MOVE 210 TO WS-Y
     MOVE 150 TO WS-W
     MOVE 0 TO WS-STATE
     PERFORM KEY-BUTTON
     MOVE "gui.cancel" TO WS-KEY
     MOVE ACT-ST-CANCEL TO WS-ACTION
     COMPUTE WS-X = WS-CX + 4
     PERFORM KEY-BUTTON
     MOVE SPACES TO WS-KEY
     STRING "structure_block.mode_info." FUNCTION TRIM(WS-MODE-NAME(EB-ST-MODE + 1)) DELIMITED BY SIZE INTO WS-KEY
     COMPUTE WS-X = WS-CX - 153
     MOVE 174 TO WS-Y
     PERFORM KEY-LABEL
     GOBACK.
 END PROGRAM STRUCT-BUILD.
