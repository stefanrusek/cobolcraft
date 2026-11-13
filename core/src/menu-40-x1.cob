*> Menus, continuation x1: the block editor screens (docs/protocol/40-menus-x1-continuation.md; US12 phase 44).
*> Programs of plain numbers and texts (MNX- prefix): the generic widget rules (EditBox, CycleButton, slider, fitting text), the command block
*> server steps, label tables, the 0.0### format, the test instance block screen (layout in binary32 steps, parseSize, save state, status text, the
*> server store rules and the 0x41 body). They call the MN9- rule programs (menu-40-9.cob) and the MN8- text field programs (menu-40-8.cob).
*> Texts are PIC X(2000) with a length. Flags are 0 or 1. Java number grammars are recalled, not verified (doc open question 5): see menu-40-9.cob.
*>
*>   MNX-SENDS (1); MNX-TRIGGER (2); MNX-EB*, -CHARTYPED, -CYCLE*, -ONOFF, -SLIDER*, -FIT, -SUGGLIMIT (3); MNX-CMDINIT, -MINECART (4);
*>   MNX-STRKEY, -MIRRORTEXT, -DECFMT (5); MNX-JIGSLIDER, -JIGSEND (6); MNX-TBDONE (7); MNX-TIB*, -PARSESIZE, -ROTATION, -SAVESTATE, -INFO, -ITOA, -BODY41 (8)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-SENDS.
*> USING screen (1 command block, 2 minecart, 3 structure, 4 jigsaw, 5 test block, 6 test instance), packet id out, mask of what sends it out (1 Done,
*> 2 Enter, 4 SAVE LOAD DETECT, 8 Generate, 16 several actions) (1 overview table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-PACKET               BINARY-LONG.
 01 L-MASK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-PACKET L-MASK.
    MOVE 0 TO L-PACKET L-MASK
    EVALUATE L-SCREEN
        WHEN 1
            MOVE 55 TO L-PACKET
            MOVE 3 TO L-MASK
        WHEN 2
            MOVE 56 TO L-PACKET
            MOVE 3 TO L-MASK
        WHEN 3
            MOVE 60 TO L-PACKET
            MOVE 5 TO L-MASK
        WHEN 4
            MOVE 59 TO L-PACKET
            MOVE 9 TO L-MASK
        WHEN 5
            MOVE 61 TO L-PACKET
            MOVE 1 TO L-MASK
        WHEN 6
            MOVE 65 TO L-PACKET
            MOVE 16 TO L-MASK
    END-EVALUATE
    GOBACK.
 END PROGRAM MNX-SENDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TRIGGER.
*> USING kind (1 command block, 2 minecart, 3 structure block, 4 jigsaw, 5 test block, 6 test instance), method out (1 useWithoutItem, 2 interact,
*> 3 usedBy), server sends Block Entity Data out (only the command block) (2 table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-METHOD               BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-METHOD L-DATA.
    MOVE 1 TO L-METHOD
    MOVE 0 TO L-DATA
    IF L-KIND = 1
        MOVE 1 TO L-DATA
    END-IF
    IF L-KIND = 2
        MOVE 2 TO L-METHOD
    END-IF
    IF L-KIND = 3
        MOVE 3 TO L-METHOD
    END-IF
    GOBACK.
 END PROGRAM MNX-TRIGGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-EBCONST.
*> USING id, value out (3.1): 1 default maximum length, 2 text colour, 3 uneditable text colour, 4 cursor blink period in ms, 5 inner padding, 6 caret width.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-VALUE.
    MOVE 0 TO L-VALUE
    EVALUATE L-ID
        WHEN 1
            MOVE 32 TO L-VALUE
        WHEN 2
            MOVE -2039584 TO L-VALUE
        WHEN 3
            MOVE -9408400 TO L-VALUE
        WHEN 4
            MOVE 300 TO L-VALUE
        WHEN 5
            MOVE 4 TO L-VALUE
        WHEN 6
            MOVE 1 TO L-VALUE
    END-EVALUATE
    GOBACK.
 END PROGRAM MNX-EBCONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-CHARTYPED.
*> USING active, focused, editable, code point, counts out (3.1 rule 2): the box must be active, focused and editable and the character an allowed chat
*> character (MN8-ALLOWED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-OK                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ACTIVE               BINARY-LONG.
 01 L-FOCUSED              BINARY-LONG.
 01 L-EDITABLE             BINARY-LONG.
 01 L-CP                   BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-FOCUSED L-EDITABLE L-CP L-OUT.
    MOVE 0 TO L-OUT
    CALL "MN8-ALLOWED" USING L-CP W-OK
    IF L-ACTIVE = 1 AND L-FOCUSED = 1 AND L-EDITABLE = 1 AND W-OK = 1
        MOVE 1 TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MNX-CHARTYPED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-EBKEY.
*> USING key, control (with quirk) held, Shift held, editable, handled out, action out (1 delete back, 2 delete forward, 3 left, 4 right, 5 home, 6 end,
*> 7 select all, 8 copy, 9 cut, 10 paste), by word out, extends the selection out (3.1 rule 4). Enter and other keys are not handled.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  BINARY-LONG.
 01 L-CTRL                 BINARY-LONG.
 01 L-SHIFT                BINARY-LONG.
 01 L-EDITABLE             BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-WORD                 BINARY-LONG.
 01 L-EXTEND               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CTRL L-SHIFT L-EDITABLE L-HANDLED L-ACTION L-WORD L-EXTEND.
    MOVE 0 TO L-HANDLED L-ACTION L-WORD L-EXTEND
    EVALUATE TRUE
        WHEN L-KEY = 8 AND L-EDITABLE = 1
            MOVE 1 TO L-ACTION
        WHEN L-KEY = 127 AND L-EDITABLE = 1
            MOVE 2 TO L-ACTION
        WHEN L-KEY = 1073741904
            MOVE 3 TO L-ACTION
        WHEN L-KEY = 1073741903
            MOVE 4 TO L-ACTION
        WHEN L-KEY = 1073741898
            MOVE 5 TO L-ACTION
        WHEN L-KEY = 1073741901
            MOVE 6 TO L-ACTION
        WHEN L-KEY = 97 AND L-CTRL = 1
            MOVE 7 TO L-ACTION
        WHEN L-KEY = 99 AND L-CTRL = 1
            MOVE 8 TO L-ACTION
        WHEN L-KEY = 120 AND L-CTRL = 1 AND L-EDITABLE = 1
            MOVE 9 TO L-ACTION
        WHEN L-KEY = 118 AND L-CTRL = 1 AND L-EDITABLE = 1
            MOVE 10 TO L-ACTION
    END-EVALUATE
    IF L-ACTION > 0
        MOVE 1 TO L-HANDLED
    END-IF
    IF L-CTRL = 1 AND L-ACTION >= 1 AND L-ACTION <= 4
        MOVE 1 TO L-WORD
    END-IF
    IF L-SHIFT = 1 AND L-ACTION >= 3 AND L-ACTION <= 6
        MOVE 1 TO L-EXTEND
    END-IF
    GOBACK.
 END PROGRAM MNX-EBKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-EBDRAW.
*> USING x, y, width, height, bordered, visible, focused, drawn out, sprite out (0 none, 1 widget/text_field, 2 widget/text_field_highlighted), inner width
*> out, text x out, text y out (3.1 rule 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-HALF                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-BORDERED             BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 01 L-FOCUSED              BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 01 L-INNER                BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-W L-H L-BORDERED L-VISIBLE L-FOCUSED L-DRAWN L-SPRITE L-INNER L-TX L-TY.
    MOVE 0 TO L-DRAWN L-SPRITE L-INNER L-TX L-TY
    IF L-VISIBLE = 1
        MOVE 1 TO L-DRAWN
        MOVE L-W TO L-INNER
        MOVE L-X TO L-TX
        MOVE L-Y TO L-TY
        IF L-BORDERED = 1
            MOVE 1 TO L-SPRITE
            IF L-FOCUSED = 1
                MOVE 2 TO L-SPRITE
            END-IF
            COMPUTE L-INNER = L-W - 8
            COMPUTE L-TX = L-X + 4
            COMPUTE W-HALF = (L-H - 8) / 2
            COMPUTE L-TY = L-Y + W-HALF
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MNX-EBDRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-CYCLE.
*> USING list size, index, delta, new index out: positiveModulo(index + delta, size) (3.2 behaviour 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-SUM                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DELTA                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-INDEX L-DELTA L-NEW.
    COMPUTE W-SUM = L-INDEX + L-DELTA
    COMPUTE L-NEW = FUNCTION MOD(W-SUM, L-SIZE)
    GOBACK.
 END PROGRAM MNX-CYCLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-CYCLEEVENT.
*> USING event (1 click, 2 Shift-click, 3 wheel up, 4 wheel down, 5 wheel zero), delta out, wheel consumed out (3.2 behaviour 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-DELTA                BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-DELTA L-CONSUMED.
    MOVE 0 TO L-DELTA L-CONSUMED
    EVALUATE L-EVENT
        WHEN 1
            MOVE 1 TO L-DELTA
        WHEN 2
            MOVE -1 TO L-DELTA
        WHEN 3
            MOVE -1 TO L-DELTA
            MOVE 1 TO L-CONSUMED
        WHEN 4
            MOVE 1 TO L-DELTA
            MOVE 1 TO L-CONSUMED
        WHEN 5
            MOVE 1 TO L-CONSUMED
    END-EVALUATE
    GOBACK.
 END PROGRAM MNX-CYCLEEVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-CYCLELIST.
*> USING Alt held, the button has an alt list, default list size, alt list size, size of the list in use out (3.2 construction).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALT                  BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-ND                   BINARY-LONG.
 01 L-NA                   BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ALT L-HAS L-ND L-NA L-SIZE.
    MOVE L-ND TO L-SIZE
    IF L-ALT = 1 AND L-HAS = 1
        MOVE L-NA TO L-SIZE
    END-IF
    GOBACK.
 END PROGRAM MNX-CYCLELIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-CYCLESET.
*> USING index, position of the value in the list in use (-1 when absent), new index out, callback fired out (always 0) (3.2 behaviour 3 setValue).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-CALLBACK             BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-POS L-NEW L-CALLBACK.
    MOVE L-INDEX TO L-NEW
    MOVE 0 TO L-CALLBACK
    IF L-POS >= 0
        MOVE L-POS TO L-NEW
    END-IF
    GOBACK.
 END PROGRAM MNX-CYCLESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-CYCLELABEL.
*> USING display only the value, label kind out (0 the value text, 1 options.generic_value with name and value) (3.2 construction).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ONLY                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ONLY L-KIND.
    COMPUTE L-KIND = 1 - L-ONLY
    GOBACK.
 END PROGRAM MNX-CYCLELABEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-ONOFF.
*> USING value (1 true), text out, length out: options.on for true, options.off for false (3.2 onOffBuilder).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-TEXT L-LEN.
    MOVE SPACES TO L-TEXT
    IF L-VALUE = 1
        MOVE "options.on" TO L-TEXT
        MOVE 10 TO L-LEN
    ELSE
        MOVE "options.off" TO L-TEXT
        MOVE 11 TO L-LEN
    END-IF
    GOBACK.
 END PROGRAM MNX-ONOFF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-SLIDERCLICK.
*> USING mouse x, widget x, width, value out (FLOAT-LONG): clamp((mouse x - (x + 4)) / (width - 8), 0, 1) (3.3 rule 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-NUM                  BINARY-LONG.
 01 W-DEN                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-MX                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-MX L-X L-W L-VALUE.
    COMPUTE W-NUM = L-MX - L-X - 4
    COMPUTE W-DEN = L-W - 8
    COMPUTE L-VALUE = W-NUM / W-DEN
    IF L-VALUE < 0
        MOVE 0 TO L-VALUE
    END-IF
    IF L-VALUE > 1
        MOVE 1 TO L-VALUE
    END-IF
    GOBACK.
 END PROGRAM MNX-SLIDERCLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-SLIDERKEY.
*> USING key, width, canChangeValue, value, new value out, handled out: Left and Right change the value by -1 or +1 times 1 / (width - 8) while
*> canChangeValue is true; setValue clamps; other keys are not consumed (3.3 rule 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-DEN                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-NEW                  FLOAT-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-W L-CAN L-VALUE L-NEW L-HANDLED.
    MOVE L-VALUE TO L-NEW
    MOVE 0 TO L-HANDLED
    COMPUTE W-DEN = L-W - 8
    IF L-CAN = 1 AND L-KEY = 1073741904
        MOVE 1 TO L-HANDLED
        COMPUTE L-NEW = L-VALUE - 1 / W-DEN
    END-IF
    IF L-CAN = 1 AND L-KEY = 1073741903
        MOVE 1 TO L-HANDLED
        COMPUTE L-NEW = L-VALUE + 1 / W-DEN
    END-IF
    IF L-NEW < 0
        MOVE 0 TO L-NEW
    END-IF
    IF L-NEW > 1
        MOVE 1 TO L-NEW
    END-IF
    GOBACK.
 END PROGRAM MNX-SLIDERKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-SLIDERSET.
*> USING new value, old value, clamped value out, applyValue called out (when the clamped value differs from the old one) (3.3 rule 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NEW                  FLOAT-LONG.
 01 L-OLD                  FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-APPLIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-NEW L-OLD L-VALUE L-APPLIED.
    MOVE L-NEW TO L-VALUE
    IF L-VALUE < 0
        MOVE 0 TO L-VALUE
    END-IF
    IF L-VALUE > 1
        MOVE 1 TO L-VALUE
    END-IF
    MOVE 0 TO L-APPLIED
    IF L-VALUE NOT = L-OLD
        MOVE 1 TO L-APPLIED
    END-IF
    GOBACK.
 END PROGRAM MNX-SLIDERSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-SLIDERHANDLE.
*> USING widget x, width, value, handle x out: x + trunc(value * (width - 8)) (3.3 drawing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-TRAVEL               BINARY-LONG.
 01 W-OFF                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-HX                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-W L-VALUE L-HX.
    COMPUTE W-TRAVEL = L-W - 8
    COMPUTE W-OFF = FUNCTION INTEGER(L-VALUE * W-TRAVEL)
    COMPUTE L-HX = L-X + W-OFF
    GOBACK.
 END PROGRAM MNX-SLIDERHANDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-SLIDERFOCUS.
*> USING last input (1 mouse, 2 Tab navigation, 3 keyboard), canChangeValue out (3.3 rule 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INPUT                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INPUT L-CAN.
    MOVE 0 TO L-CAN
    IF L-INPUT = 1 OR L-INPUT = 2
        MOVE 1 TO L-CAN
    END-IF
    GOBACK.
 END PROGRAM MNX-SLIDERFOCUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-SLIDERSELECT.
*> USING canChangeValue, new value out: a selection key toggles it (3.3 rule 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-NEW.
    COMPUTE L-NEW = 1 - L-CAN
    GOBACK.
 END PROGRAM MNX-SLIDERSELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-FIT.
*> USING widget width, height, wrapped lines, text width out (width - 8), inner height out (lines x 9), scrollable out (inner height above height - 8),
*> full lines shown out ((height - 8) / 9) (3.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-AVAIL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-LINES                BINARY-LONG.
 01 L-MAXW                 BINARY-LONG.
 01 L-INNER                BINARY-LONG.
 01 L-SCROLL               BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-H L-LINES L-MAXW L-INNER L-SCROLL L-VISIBLE.
    COMPUTE L-MAXW = L-W - 8
    COMPUTE L-INNER = L-LINES * 9
    COMPUTE W-AVAIL = L-H - 8
    MOVE 0 TO L-SCROLL
    IF L-INNER > W-AVAIL
        MOVE 1 TO L-SCROLL
    END-IF
    COMPUTE L-VISIBLE = W-AVAIL / 9
    GOBACK.
 END PROGRAM MNX-FIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-SUGGLIMIT.
*> USING screen (1 chat, 2 command block), suggestion line limit out (3.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-LIMIT.
    MOVE 7 TO L-LIMIT
    IF L-SCREEN = 1
        MOVE 10 TO L-LIMIT
    END-IF
    GOBACK.
 END PROGRAM MNX-SUGGLIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-CMDINIT.
*> USING kind (1 block screen, 2 minecart screen), mode out (2 REDSTONE), conditional out, automatic out, controls enabled out, command empty out (4.2, 4.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-INIT                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-COND                 BINARY-LONG.
 01 L-AUTO                 BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-MODE L-COND L-AUTO L-ENABLED L-EMPTY.
    MOVE 2 TO L-MODE
    MOVE 0 TO L-COND L-AUTO
    MOVE 1 TO L-EMPTY
    CALL "MN9-CMDENABLE" USING L-KIND W-INIT L-ENABLED
    GOBACK.
 END PROGRAM MNX-CMDINIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-MINECART.
*> USING may use game master blocks, entity resolves, command text length, track output, command blocks enabled; out: message (0 none, 1 advMode.notAllowed,
*> 2 advMode.setCommand.success, 3 advMode.setCommand.disabled), setCommand, setTrackOutput, last output cleared, onUpdated (4.3 steps 1 to 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAY                  BINARY-LONG.
 01 L-RESOLVES             BINARY-LONG.
 01 L-TLEN                 BINARY-LONG.
 01 L-TRACK                BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-MSG                  BINARY-LONG.
 01 L-SETCMD               BINARY-LONG.
 01 L-SETTRACK             BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 01 L-UPDATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-MAY L-RESOLVES L-TLEN L-TRACK L-ENABLED L-MSG L-SETCMD L-SETTRACK L-CLEAR L-UPDATED.
    MOVE 0 TO L-MSG L-SETCMD L-SETTRACK L-CLEAR L-UPDATED
    EVALUATE TRUE
        WHEN L-MAY = 0
            MOVE 1 TO L-MSG
        WHEN L-RESOLVES = 1
            MOVE 1 TO L-SETCMD L-SETTRACK
            COMPUTE L-CLEAR = 1 - L-TRACK
            MOVE L-ENABLED TO L-UPDATED
            IF L-TLEN > 0
                MOVE 3 TO L-MSG
                IF L-ENABLED = 1
                    MOVE 2 TO L-MSG
                END-IF
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MNX-MINECART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-STRKEY.
*> USING label (1 name, 2 position, 3 include entities, 4 size, 5 detect, 6 show air, 7 integrity and seed, 8 strict, 9 show bounding box, 10 custom data),
*> language key out, length out (5.5 drawing).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LABEL                BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LABEL L-TEXT L-LEN.
    MOVE SPACES TO L-TEXT
    EVALUATE L-LABEL
        WHEN 1
            MOVE "structure_block.structure_name" TO L-TEXT
        WHEN 2
            MOVE "structure_block.position" TO L-TEXT
        WHEN 3
            MOVE "structure_block.include_entities" TO L-TEXT
        WHEN 4
            MOVE "structure_block.size" TO L-TEXT
        WHEN 5
            MOVE "structure_block.detect_size" TO L-TEXT
        WHEN 6
            MOVE "structure_block.show_air" TO L-TEXT
        WHEN 7
            MOVE "structure_block.integrity" TO L-TEXT
        WHEN 8
            MOVE "structure_block.strict" TO L-TEXT
        WHEN 9
            MOVE "structure_block.show_boundingbox" TO L-TEXT
        WHEN 10
            MOVE "structure_block.custom_data" TO L-TEXT
    END-EVALUATE
    MOVE 0 TO L-LEN
    INSPECT L-TEXT TALLYING L-LEN FOR CHARACTERS BEFORE INITIAL SPACE
    GOBACK.
 END PROGRAM MNX-STRKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-MIRRORTEXT.
*> USING mirror (0 none, 1 left_right, 2 front_back), the three code points out (0 when unused), code point count out (5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MIRROR               BINARY-LONG.
 01 L-C1                   BINARY-LONG.
 01 L-C2                   BINARY-LONG.
 01 L-C3                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-MIRROR L-C1 L-C2 L-C3 L-COUNT.
    MOVE 124 TO L-C1
    MOVE 0 TO L-C2 L-C3
    MOVE 1 TO L-COUNT
    EVALUATE L-MIRROR
        WHEN 1
            MOVE 8592 TO L-C1
            MOVE 32 TO L-C2
            MOVE 8594 TO L-C3
            MOVE 3 TO L-COUNT
        WHEN 2
            MOVE 8593 TO L-C1
            MOVE 32 TO L-C2
            MOVE 8595 TO L-C3
            MOVE 3 TO L-COUNT
    END-EVALUATE
    GOBACK.
 END PROGRAM MNX-MIRRORTEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-ITOA.
*> USING value, text out, length out: Integer.toString (3 and 8: the size and position boxes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ED                   PIC -(9)9.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-TEXT L-LEN.
    MOVE SPACES TO L-TEXT
    MOVE L-VALUE TO W-ED
    MOVE FUNCTION TRIM(W-ED) TO L-TEXT
    MOVE 0 TO L-LEN
    INSPECT L-TEXT TALLYING L-LEN FOR CHARACTERS BEFORE INITIAL SPACE
    GOBACK.
 END PROGRAM MNX-ITOA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-DECFMT.
*> USING value (FLOAT-LONG), text out, length out: DecimalFormat 0.0###, at least one and at most four decimals, half even on the product with 10000
*> (the half-even rounding is recalled, not verified) (5.2, 5.9 example 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-A                    FLOAT-LONG.
 01 W-X                    FLOAT-LONG.
 01 W-F                    FLOAT-LONG.
 01 W-N                    BINARY-DOUBLE.
 01 W-IP                   BINARY-DOUBLE.
 01 W-FP                   BINARY-LONG.
 01 W-NEG                  BINARY-LONG.
 01 W-EDI                  PIC Z(9)9.
 01 W-FD                   PIC 9(4).
 01 W-FL                   BINARY-LONG.
 01 W-IPT                  PIC X(10).
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-TEXT L-LEN.
    MOVE SPACES TO L-TEXT
    MOVE 0 TO W-NEG
    MOVE L-VALUE TO W-A
    IF W-A < 0
        MOVE 1 TO W-NEG
        COMPUTE W-A = 0 - W-A
    END-IF
    COMPUTE W-X = W-A * 10000
    COMPUTE W-N = FUNCTION INTEGER(W-X)
    COMPUTE W-F = W-X - W-N
    IF W-F > 0.5 OR (W-F = 0.5 AND FUNCTION MOD(W-N, 2) = 1)
        ADD 1 TO W-N
    END-IF
    DIVIDE W-N BY 10000 GIVING W-IP REMAINDER W-FP
    MOVE W-IP TO W-EDI
    MOVE FUNCTION TRIM(W-EDI) TO W-IPT
    MOVE W-FP TO W-FD
    MOVE 4 TO W-FL
    PERFORM UNTIL W-FL = 1 OR W-FD(W-FL:1) NOT = "0"
        SUBTRACT 1 FROM W-FL
    END-PERFORM
    IF W-NEG = 1
        STRING "-" W-IPT DELIMITED BY SPACE "." DELIMITED BY SIZE W-FD(1:W-FL) DELIMITED BY SIZE INTO L-TEXT
    ELSE
        STRING W-IPT DELIMITED BY SPACE "." DELIMITED BY SIZE W-FD(1:W-FL) DELIMITED BY SIZE INTO L-TEXT
    END-IF
    MOVE 0 TO L-LEN
    INSPECT L-TEXT TALLYING L-LEN FOR CHARACTERS BEFORE INITIAL SPACE
    GOBACK.
 END PROGRAM MNX-DECFMT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-JIGSLIDER.
*> USING mouse x, slider x, width, value out (FLOAT-LONG), levels out: a click sets the value (3.3), then levels = floor(20 * value) (6.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MX                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-LEVELS               BINARY-LONG.
 PROCEDURE DIVISION USING L-MX L-X L-W L-VALUE L-LEVELS.
    CALL "MNX-SLIDERCLICK" USING L-MX L-X L-W L-VALUE
    CALL "MN9-JIGLEVELS" USING L-VALUE L-LEVELS
    GOBACK.
 END PROGRAM MNX-JIGSLIDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-JIGSEND.
*> USING how (1 Done, 2 Enter, 3 Generate), valid (Done and Generate active), first packet id out, second packet id out, screen closes out: Done, Enter and
*> Generate act only while valid; Generate sends 0x3B then 0x1B; Enter never triggers Generate (6.2, 6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOW                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-P1                   BINARY-LONG.
 01 L-P2                   BINARY-LONG.
 01 L-CLOSES               BINARY-LONG.
 PROCEDURE DIVISION USING L-HOW L-VALID L-P1 L-P2 L-CLOSES.
    MOVE 0 TO L-P1 L-P2 L-CLOSES
    IF L-VALID = 1
        MOVE 59 TO L-P1
        MOVE 1 TO L-CLOSES
        IF L-HOW = 3
            MOVE 27 TO L-P2
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MNX-JIGSEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TBDONE.
*> USING mode, message box text length, mode sent out, message length sent out, screen closes out: the box text is sent whatever the mode (7 onDone).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-LEN                  BINARY-LONG.
 01 L-SENTMODE             BINARY-LONG.
 01 L-SENTLEN              BINARY-LONG.
 01 L-CLOSES               BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-LEN L-SENTMODE L-SENTLEN L-CLOSES.
    MOVE L-MODE TO L-SENTMODE
    MOVE L-LEN TO L-SENTLEN
    MOVE 1 TO L-CLOSES
    GOBACK.
 END PROGRAM MNX-TBDONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBX.
*> USING W, columns n, column i, exactWidgetSize x 10 out (rounded), widgetSize out, widgetX out (8.1): binary32 steps, each result stored in a FLOAT-SHORT:
*> exact = (316 - (n - 1) * 8) / n; widgetX = trunc(left + i * (8 + exact)) with left = W / 2 - 158.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-NUM                  BINARY-LONG.
 01 W-LEFT                 BINARY-LONG.
 01 W-EX                   FLOAT-SHORT.
 01 W-STEP                 FLOAT-SHORT.
 01 W-PROD                 FLOAT-SHORT.
 01 W-SUM                  FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-E10                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-N L-I L-E10 L-SIZE L-X.
    COMPUTE W-LEFT = L-W / 2 - 158
    COMPUTE W-NUM = 316 - (L-N - 1) * 8
    COMPUTE W-EX = W-NUM / L-N
    COMPUTE L-E10 ROUNDED = W-EX * 10
    COMPUTE L-SIZE = FUNCTION INTEGER(W-EX)
    COMPUTE W-STEP = 8 + W-EX
    COMPUTE W-PROD = L-I * W-STEP
    COMPUTE W-SUM = W-LEFT + W-PROD
    COMPUTE L-X = FUNCTION INTEGER(W-SUM)
    GOBACK.
 END PROGRAM MNX-TIBX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBRECT.
*> USING W, IDE flag, item (1 ID box, 2 info text, 3 to 5 size boxes, 6 rotation, 7 include entities, 8 Reset, 9 Save, 10 Export, 11 Run, 12 Done, 13 Cancel),
*> x y w h out (8.2, 7A.2). Export exists only with the IDE flag (else 0 0 0 0); the bottom button row has 3 columns with the flag, else 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-E10                  BINARY-LONG.
 01 W-C                    BINARY-LONG.
 01 W-COL                  BINARY-LONG.
 01 W-N                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-IDE                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-WD                   BINARY-LONG.
 01 L-HT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-IDE L-ITEM L-X L-Y L-WD L-HT.
    MOVE 0 TO L-X L-Y L-WD L-HT
    MOVE 2 TO W-C
    IF L-IDE = 1
        MOVE 3 TO W-C
    END-IF
    EVALUATE TRUE
        WHEN L-ITEM = 1
            COMPUTE L-X = L-W / 2 - 158
            MOVE 40 TO L-Y
            MOVE 316 TO L-WD
            MOVE 20 TO L-HT
        WHEN L-ITEM = 2
            COMPUTE L-X = L-W / 2 - 158
            MOVE 70 TO L-Y
            MOVE 316 TO L-WD
            MOVE 72 TO L-HT
        WHEN L-ITEM >= 3 AND L-ITEM <= 7
            COMPUTE W-COL = L-ITEM - 3
            MOVE 5 TO W-N
            CALL "MNX-TIBX" USING L-W W-N W-COL W-E10 L-WD L-X
            MOVE 160 TO L-Y
            MOVE 20 TO L-HT
        WHEN L-ITEM >= 8 AND L-ITEM <= 9
            COMPUTE W-COL = L-ITEM - 8
            CALL "MNX-TIBX" USING L-W W-C W-COL W-E10 L-WD L-X
            MOVE 185 TO L-Y
            MOVE 20 TO L-HT
        WHEN L-ITEM = 10 AND L-IDE = 1
            MOVE 2 TO W-COL
            CALL "MNX-TIBX" USING L-W W-C W-COL W-E10 L-WD L-X
            MOVE 185 TO L-Y
            MOVE 20 TO L-HT
        WHEN L-ITEM >= 11 AND L-ITEM <= 13
            COMPUTE W-COL = L-ITEM - 11
            MOVE 3 TO W-N
            CALL "MNX-TIBX" USING L-W W-N W-COL W-E10 L-WD L-X
            MOVE 210 TO L-Y
            MOVE 20 TO L-HT
    END-EVALUATE
    GOBACK.
 END PROGRAM MNX-TIBRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBLABEL.
*> USING W, label (1 title centred at cx, 2 test id, 3 test structure size, 4 rotation, 5 entities), x out, y out (8.3 point 6, 7A.2 labels).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-E10                  BINARY-LONG.
 01 W-SIZE                 BINARY-LONG.
 01 W-N                    BINARY-LONG.
 01 W-COL                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-LABEL                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-LABEL L-X L-Y.
    MOVE 150 TO L-Y
    MOVE 5 TO W-N
    EVALUATE L-LABEL
        WHEN 1
            COMPUTE L-X = L-W / 2
            MOVE 10 TO L-Y
        WHEN 2
            COMPUTE L-X = L-W / 2 - 158
            MOVE 30 TO L-Y
        WHEN 3
            COMPUTE L-X = L-W / 2 - 158
        WHEN 4
            MOVE 3 TO W-COL
            CALL "MNX-TIBX" USING L-W W-N W-COL W-E10 W-SIZE L-X
        WHEN 5
            MOVE 4 TO W-COL
            CALL "MNX-TIBX" USING L-W W-N W-COL W-E10 W-SIZE L-X
    END-EVALUATE
    GOBACK.
 END PROGRAM MNX-TIBLABEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-PARSESIZE.
*> USING text, length, size out: Integer.parseInt then clamp to 1..48, 1 on any number format error (8.3 point 1, 7A.3 parseSize).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-KIND                 BINARY-LONG VALUE 1.
 01 W-DEF                  BINARY-DOUBLE VALUE 1.
 01 W-V                    BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LEN L-SIZE.
    CALL "MN9-PARSENUM" USING L-TEXT L-LEN W-KIND W-DEF W-V
    COMPUTE L-SIZE = FUNCTION MIN(FUNCTION MAX(W-V, 1), 48)
    GOBACK.
 END PROGRAM MNX-PARSESIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-ROTATION.
*> USING the test own rotation t (0 to 3), the stored rotation d, shown out ((t + d) mod 4), stored by Done out (the same), effective afterwards out
*> ((2t + d) mod 4) (7A.3 Rotation.getRotated).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-SUM                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-SHOWN                BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 01 L-EFFECTIVE            BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-D L-SHOWN L-STORED L-EFFECTIVE.
    COMPUTE W-SUM = L-T + L-D
    COMPUTE L-SHOWN = FUNCTION MOD(W-SUM, 4)
    MOVE L-SHOWN TO L-STORED
    COMPUTE W-SUM = 2 * L-T + L-D
    COMPUTE L-EFFECTIVE = FUNCTION MOD(W-SUM, 4)
    GOBACK.
 END PROGRAM MNX-ROTATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-SAVESTATE.
*> USING rotation value (0 NONE), the id text parses (the empty text does), save active out: Save and Export need both (8.3 point 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROT                  BINARY-LONG.
 01 L-PARSES               BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROT L-PARSES L-ACTIVE.
    MOVE 0 TO L-ACTIVE
    IF L-ROT = 0 AND L-PARSES = 1
        MOVE 1 TO L-ACTIVE
    END-IF
    GOBACK.
 END PROGRAM MNX-SAVESTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-INFO.
*> USING init (1 at the end of init, 0 after an id box change), the id text parses, action out (0 INIT, 1 QUERY), invalid id text shown out (8.3 point 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INIT                 BINARY-LONG.
 01 L-PARSES               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-INVALID              BINARY-LONG.
 PROCEDURE DIVISION USING L-INIT L-PARSES L-ACTION L-INVALID.
    COMPUTE L-ACTION = 1 - L-INIT
    COMPUTE L-INVALID = 1 - L-PARSES
    GOBACK.
 END PROGRAM MNX-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBACTION.
*> USING how (1 Reset, 2 Save, 3 Export, 4 Run, 5 Done, 6 Cancel, 7 Escape), action id sent out (-1 none), screen closes out, how out (1 Gui.setScreen(null)
*> directly, 2 onClose) (8.2, 7A.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOW                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-CLOSES               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HOW L-ACTION L-CLOSES L-KIND.
    MOVE -1 TO L-ACTION
    MOVE 1 TO L-CLOSES
    MOVE 2 TO L-KIND
    EVALUATE L-HOW
        WHEN 1
            MOVE 3 TO L-ACTION
            MOVE 1 TO L-KIND
        WHEN 2
            MOVE 4 TO L-ACTION
            MOVE 1 TO L-KIND
        WHEN 3
            MOVE 5 TO L-ACTION
            MOVE 1 TO L-KIND
        WHEN 4
            MOVE 6 TO L-ACTION
            MOVE 1 TO L-KIND
        WHEN 5
            MOVE 2 TO L-ACTION
    END-EVALUATE
    GOBACK.
 END PROGRAM MNX-TIBACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBACTID.
*> USING id, action out: INIT 0, QUERY 1, SET 2, RESET 3, SAVE 4, EXPORT 5, RUN 6; an id outside 0..6 decodes as INIT (7A.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ACTION.
    MOVE 0 TO L-ACTION
    IF L-ID >= 0 AND L-ID <= 6
        MOVE L-ID TO L-ACTION
    END-IF
    GOBACK.
 END PROGRAM MNX-TIBACTID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBSERVER.
*> USING action id, may use game master blocks, entity exists; out: processed, stores the packet data, answers with a status packet, ends with a block update
*> (7A.4 server validation).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ACTION               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 01 L-EXISTS               BINARY-LONG.
 01 L-PROCESSED            BINARY-LONG.
 01 L-STORES               BINARY-LONG.
 01 L-ANSWERS              BINARY-LONG.
 01 L-UPDATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-MAY L-EXISTS L-PROCESSED L-STORES L-ANSWERS L-UPDATE.
    MOVE 0 TO L-PROCESSED L-STORES L-ANSWERS L-UPDATE
    CALL "MNX-TIBACTID" USING L-ID W-ACTION
    IF L-MAY = 1 AND L-EXISTS = 1
        MOVE 1 TO L-PROCESSED
        IF W-ACTION >= 2
            MOVE 1 TO L-STORES L-UPDATE
        ELSE
            MOVE 1 TO L-ANSWERS
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MNX-TIBSERVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBMSG.
*> USING the client entity has an error message, its text and length, the reply text and length, info text out, length out: the info text is Failed: <error>,
*> two line feeds, then the reply text; without an error only the reply text (7A.3 setStatus).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-P                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-ERR                  PIC X(2000).
 01 L-ELEN                 BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-TLEN                 BINARY-LONG.
 01 L-OUT                  PIC X(2000).
 01 L-OUTLEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-ERR L-ELEN L-TEXT L-TLEN L-OUT L-OUTLEN.
    MOVE SPACES TO L-OUT
    MOVE 0 TO L-OUTLEN
    IF L-HAS = 1
        MOVE "Failed: " TO L-OUT(1:8)
        MOVE 8 TO L-OUTLEN
        IF L-ELEN > 0
            MOVE L-ERR(1:L-ELEN) TO L-OUT(9:L-ELEN)
            ADD L-ELEN TO L-OUTLEN
        END-IF
        COMPUTE W-P = L-OUTLEN + 1
        MOVE X"0A" TO L-OUT(W-P:1)
        ADD 1 TO W-P
        MOVE X"0A" TO L-OUT(W-P:1)
        ADD 2 TO L-OUTLEN
    END-IF
    IF L-TLEN > 0
        COMPUTE W-P = L-OUTLEN + 1
        MOVE L-TEXT(1:L-TLEN) TO L-OUT(W-P:L-TLEN)
        ADD L-TLEN TO L-OUTLEN
    END-IF
    GOBACK.
 END PROGRAM MNX-TIBMSG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBSTATUS.
*> USING the current screen is this screen, handled out: a status packet with no such screen is dropped (7A.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CURRENT              BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CURRENT L-HANDLED.
    MOVE L-CURRENT TO L-HANDLED
    GOBACK.
 END PROGRAM MNX-TIBSTATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBRESIZE.
*> USING action sent out (0 INIT), info text empty out, typed text kept out (0): the widgets are rebuilt from the entity (7A.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTION               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-KEPT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTION L-EMPTY L-KEPT.
    MOVE 0 TO L-ACTION L-KEPT
    MOVE 1 TO L-EMPTY
    GOBACK.
 END PROGRAM MNX-TIBRESIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-TIBBG.
*> USING row (1 top, 2 bottom), colour out: the in-game gradient 0xC0101010 to 0xD0101010 as ints (7A.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-COLOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-COLOR.
    MOVE -804253680 TO L-COLOR
    IF L-ROW = 1
        MOVE -1072689136 TO L-COLOR
    END-IF
    GOBACK.
 END PROGRAM MNX-TIBBG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNX-BODY41.
*> USING x y z, action, test id text and length, size X Y Z (already clamped), rotation, ignore entities, hex out, byte count out: body of 0x41 Test Instance
*> Block Action: Position, action, the optional test (a boolean, then the key with its namespace), size, rotation, ignore entities, status 0, error absent (7A.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG.
 01 W-OK                   BINARY-LONG.
 01 W-ID                   PIC X(2000).
 01 W-IDLEN                BINARY-LONG.
 01 W-ONE                  BINARY-LONG VALUE 1.
 01 W-ZERO                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-TEXT                 PIC X(2000).
 01 L-LEN                  BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-IGNORE               BINARY-LONG.
 01 L-HEX                  PIC X(2000).
 01 L-BYTES                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-ACTION L-TEXT L-LEN L-SX L-SY L-SZ L-ROT L-IGNORE L-HEX L-BYTES.
    MOVE SPACES TO L-HEX
    MOVE 1 TO W-POS
    CALL "MN9-PUTPOS" USING L-X L-Y L-Z L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-ACTION L-HEX W-POS
    CALL "MN9-IDENT" USING L-TEXT L-LEN W-OK W-ID W-IDLEN
    IF W-OK = 1
        CALL "MN9-HEXBYTE" USING W-ONE L-HEX W-POS
        CALL "MN9-PUTSTR" USING W-ID W-IDLEN L-HEX W-POS
    ELSE
        CALL "MN9-HEXBYTE" USING W-ZERO L-HEX W-POS
    END-IF
    CALL "MN9-PUTVAR" USING L-SX L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-SY L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-SZ L-HEX W-POS
    CALL "MN9-PUTVAR" USING L-ROT L-HEX W-POS
    CALL "MN9-HEXBYTE" USING L-IGNORE L-HEX W-POS
    CALL "MN9-HEXBYTE" USING W-ZERO L-HEX W-POS
    CALL "MN9-HEXBYTE" USING W-ZERO L-HEX W-POS
    COMPUTE L-BYTES = (W-POS - 1) / 2
    GOBACK.
 END PROGRAM MNX-BODY41.
