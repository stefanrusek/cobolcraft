*> Implementation test (002-lane-buglevelnum, T58700; docs/protocol/12 section 5 experience bar and level number, 05b 0x69 Set Experience): what the HUD
*> draws for the level number, as vertices. The number is five labels of the digits of the Set Experience level (a VarInt, so 100 and 1000 are
*> plain digits): four black copies at (+1, 0), (-1, 0), (0, +1), (0, -1) and the green one (#80ff20 = 8453920, no shadow) at the centre
*> x = (W - textWidth) / 2, y = H - 35; the UI pipeline ignores vertex brightness (shim-abi section 9: texel x tint), so the colour of a text is its
*> tint, never a grey brightness (the reported symptom: the number a white blob, the outline white too). Every glyph quad of a copy sits at the
*> widget's position times the GUI scale (scales 1 to 4) and the glyph count of a copy is the digit count (levels 7, 12, 100, 1000).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HUD-XP-TEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PROGRESS            FLOAT-SHORT.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-LEVELS.
    05 WS-LEVEL-OF         BINARY-LONG OCCURS 4 TIMES.
 01 WS-LV                  BINARY-LONG.
 01 WS-SCALE               BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-TEXT-WIDTH          BINARY-LONG.
 01 WS-TEXT256             PIC X(256).
 01 WS-COPY                BINARY-LONG.
 01 WS-QUADS               BINARY-LONG.
 01 WS-QUADS-ALL           BINARY-LONG.
 01 WS-TINTED              BINARY-LONG.
 01 WS-WIDE-LEFT           BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LW                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-BL                  BINARY-LONG.
 01 WS-GREEN-X             BINARY-LONG.
 01 WS-PREV-WIDTH          BINARY-LONG.
 01 WS-COPY-ED             PIC 9.
 01 WS-LV-PLAIN            PIC Z(3)9.
 01 WS-ROW-TOP             BINARY-LONG.
 01 WS-ROW-BOTTOM          BINARY-LONG.
 01 WS-SC-ED               PIC 9.
 PROCEDURE DIVISION.
     MOVE 7 TO WS-LEVEL-OF(1)
     MOVE 12 TO WS-LEVEL-OF(2)
     MOVE 100 TO WS-LEVEL-OF(3)
     MOVE 1000 TO WS-LEVEL-OF(4)
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 1280 TO IN-WIN-W
     MOVE 720 TO IN-WIN-H
     MOVE 0 TO WS-PREV-WIDTH
     PERFORM VARYING WS-LV FROM 1 BY 1 UNTIL WS-LV > 4
         MOVE WS-LEVEL-OF(WS-LV) TO WS-LEVEL
         MOVE 0.5 TO WS-PROGRESS
         MOVE 120 TO WS-TOTAL
         CALL "TEST-SET-EXPERIENCE" USING CLIENT-STATE WS-CONN WS-PROGRESS WS-LEVEL WS-TOTAL
         PERFORM VARYING WS-SCALE FROM 1 BY 1 UNTIL WS-SCALE > 4
             PERFORM CHECK-NUMBER
         END-PERFORM
     END-PERFORM
     STOP RUN.
 CHECK-NUMBER.
     MOVE WS-SCALE TO WS-SC-ED
     MOVE WS-SCALE TO CL-GUI-SCALE
     COMPUTE WS-GW = IN-WIN-W / WS-SCALE
     COMPUTE WS-GH = IN-WIN-H / WS-SCALE
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "HUD-BUILD" USING CLIENT-STATE WS-GW WS-GH
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE WS-LEVEL TO WS-LV-PLAIN
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LV-PLAIN)) TO WS-DIGITS
*>   The independent expectation of the width: the glyph advances of the digits (UI-TEXT-WIDTH reads the font).
     MOVE SPACES TO WS-TEXT256
     MOVE FUNCTION TRIM(WS-LV-PLAIN) TO WS-TEXT256
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 WS-DIGITS WS-TEXT-WIDTH
     MOVE 0 TO WS-COPY WS-TINTED WS-GREEN-X
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-ARG(WS-I) = 78
             ADD 1 TO WS-COPY
             MOVE SM-W-X(WS-I) TO WS-LX
             MOVE 0 TO WS-QUADS
             PERFORM VARYING WS-Q FROM 1 BY 6 UNTIL WS-Q > RL-UI-COUNT
                 COMPUTE WS-QY = RL-UI-Y(WS-Q)
                 COMPUTE WS-QX = RL-UI-X(WS-Q)
                 IF WS-QY = SM-W-Y(WS-I) * WS-SCALE AND WS-QX = WS-LX * WS-SCALE
                     ADD 1 TO WS-QUADS
                     COMPUTE WS-R ROUNDED = RL-UI-R(WS-Q) * 255
                     COMPUTE WS-G ROUNDED = RL-UI-G(WS-Q) * 255
                     COMPUTE WS-BL ROUNDED = RL-UI-BLUE(WS-Q) * 255
                     IF WS-COPY < 5
                         IF WS-R NOT = 0 OR WS-G NOT = 0 OR WS-BL > 1
                             ADD 1 TO WS-TINTED
                         END-IF
                     ELSE
                         IF WS-R NOT = 128 OR WS-G NOT = 255 OR WS-BL NOT = 32
                             ADD 1 TO WS-TINTED
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
             MOVE WS-COPY TO WS-COPY-ED
             MOVE SPACES TO TL-CASE
             MOVE "N" TO TL-MODE
             STRING "hud xp text: copy " WS-COPY-ED " of level " WS-LV-PLAIN " at scale " WS-SC-ED " starts at its widget position times the scale (one first glyph)" DELIMITED BY SIZE INTO TL-CASE
             MOVE 1 TO TL-EXPECTED-N
             MOVE WS-QUADS TO TL-OBSERVED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             IF WS-COPY = 5
                 MOVE WS-LX TO WS-GREEN-X
             END-IF
         END-IF
     END-PERFORM
*>   Every non-white glyph quad in the rows of the five copies (the bar's swatches are 5 rows lower): five copies of one quad per digit.
     MOVE 0 TO WS-QUADS-ALL
     COMPUTE WS-ROW-TOP = (WS-GH - 36) * WS-SCALE
     COMPUTE WS-ROW-BOTTOM = (WS-GH - 34) * WS-SCALE
     PERFORM VARYING WS-Q FROM 1 BY 6 UNTIL WS-Q > RL-UI-COUNT
         COMPUTE WS-QY = RL-UI-Y(WS-Q)
         COMPUTE WS-QX = RL-UI-X(WS-Q)
         IF WS-QY >= WS-ROW-TOP AND WS-QY <= WS-ROW-BOTTOM AND WS-QX >= (WS-GREEN-X - 1) * WS-SCALE
                 AND WS-QX < (WS-GREEN-X + WS-TEXT-WIDTH + 1) * WS-SCALE
             ADD 1 TO WS-QUADS-ALL
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "hud xp text: level " WS-LV-PLAIN " scale " WS-SC-ED " draws five copies of one quad per digit" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * WS-DIGITS
     MOVE WS-QUADS-ALL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "hud xp text: level " WS-LV-PLAIN " scale " WS-SC-ED " has five label copies" DELIMITED BY SIZE INTO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-COPY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "hud xp text: level " WS-LV-PLAIN " scale " WS-SC-ED " tints: four black copies (0, 0, 1) and the green one (128, 255, 32)" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TINTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "hud xp text: level " WS-LV-PLAIN " scale " WS-SC-ED " the green copy is centred (W - width) / 2" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-EXPECTED-N = (WS-GW - WS-TEXT-WIDTH) / 2
     MOVE WS-GREEN-X TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-HUD-XP-TEXT.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SET-EXPERIENCE.
*> USING CLIENT-STATE, connection, progress (FLOAT-SHORT), level, total (BINARY-LONG): hands PROTO-PACKET a Set Experience (0x69).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG VALUE 105.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-PROGRESS             FLOAT-SHORT.
 01 L-LEVEL                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-PROGRESS L-LEVEL L-TOTAL.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-PROGRESS
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-LEVEL
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TOTAL
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-SET-EXPERIENCE.
 COPY CLTEST.
