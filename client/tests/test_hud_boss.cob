*> Implementation test of docs/protocol/57-client-closures-5 section 4 (task T47420): the boss bars. The Boss Event packet of the worked example (the body
*> 12345678-9abc-def0-1122-334455667788, ADD "Boss", progress 0.5, red, notched_10, flags 5), the operations (replace keeps the position, remove, re-add moves to the end,
*> progress, name, style, properties, an update before an add ends the connection), the progress glide over 100 ms, the layout (bar left W / 2 - 91, tops 12 + 19 n, the sprite
*> rows, the progress width floor(p x 181) + 1, the title at W / 2 - width / 2 and top - 9, the number of bars that fit: 4 at H 240, 5 at 270, 1 at 90), the darkening ramp (20 ticks
*> up, 80 down) and the boss music condition, and the sprite file names of the 22 sprites.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HUD-BOSS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-HEX                 PIC X(400).
 01 WS-HEX-LEN             BINARY-LONG.
 01 WS-HP                  BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-ONE-BYTE            PIC X.
 01 WS-ONE-COUNT           BINARY-LONG.
 01 WS-SERVER              BINARY-LONG.
 01 WS-NAME                PIC X(200).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 512.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-ID                  BINARY-LONG VALUE 9.
 01 WS-GW                  BINARY-LONG VALUE 427.
 01 WS-GH                  BINARY-LONG VALUE 240.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PROGRESS            FLOAT-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-X256                PIC X(256).
 01 WS-W                   BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-N                   PIC 99.
 01 WS-COUNT               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     MOVE 1000000 TO CL-NOW-MS
*>   ---- the worked ADD example of 4.1 ----
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 00 08 00 04 42 6F 73 73 3F 00 00 00 02 02 05" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "ADD: one bar" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE HX-BB-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "ADD: colour red (2), overlay notched_10 (2), flags 5" TO WS-NAME
     MOVE 2205 TO WS-EXP
     COMPUTE WS-OBS = HX-BB-COLOUR(1) * 1000 + HX-BB-OVERLAY(1) * 100 + HX-BB-FLAGS(1)
     PERFORM CHK
     MOVE "T" TO TL-MODE
     MOVE "ADD: the title is Boss" TO TL-CASE
     MOVE "Boss" TO TL-EXPECTED
     MOVE HX-BB-TITLE(1)(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-ROW
     CALL "BOSS-DISPLAYED" USING CLIENT-STATE WS-ROW WS-PROGRESS
     MOVE "ADD: the progress is 0.5" TO WS-NAME
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-PROGRESS * 1000
     PERFORM CHK
*>   the widgets: background, notched background, progress (w = floor(0.5 x 181) + 1 = 91), notched progress, title
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "BOSS-HUD-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "one bar of a notched overlay: five widgets" TO WS-NAME
     MOVE 5 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "the background sprite is red at x 213 - 91 = 122, y 12, 182 x 5" TO WS-NAME
     COMPUTE WS-EXP = (GSP-BOSS-BG-0 + 2) * 1000000000 + 122012182
     COMPUTE WS-OBS = SM-W-ARG(1) * 1000000000 + SM-W-X(1) * 1000000 + SM-W-Y(1) * 1000 + SM-W-W(1)
     PERFORM CHK
     MOVE "the notched_10 background over it is the row of overlay 2" TO WS-NAME
     COMPUTE WS-EXP = GSP-BOSS-NOTCH-BG-0 + 1
     MOVE SM-W-ARG(2) TO WS-OBS
     PERFORM CHK
     MOVE "the progress is the left 91 columns of the red progress sprite (a clip)" TO WS-NAME
     COMPUTE WS-EXP = WK-CLIP * 1000000 + (GSP-BOSS-PROGRESS-0 + 2) * 1000 + 91
     COMPUTE WS-OBS = SM-W-KIND(3) * 1000000 + SM-W-ARG(3) * 1000 + SM-W-W(3)
     PERFORM CHK
     MOVE "the notched progress is clipped alike" TO WS-NAME
     COMPUTE WS-EXP = (GSP-BOSS-NOTCH-PROGRESS-0 + 1) * 1000 + 91
     COMPUTE WS-OBS = SM-W-ARG(4) * 1000 + SM-W-W(4)
     PERFORM CHK
     MOVE "Boss" TO WS-X256
     MOVE 4 TO WS-COUNT
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-X256 WS-COUNT WS-W
     COMPUTE WS-HALF = WS-W / 2
     MOVE "the title is at x 213 - width / 2, y 12 - 9 = 3, white with the shadow" TO WS-NAME
     COMPUTE WS-EXP = (213 - WS-HALF) * 100000 + 3 * 1000 + 255
     COMPUTE WS-OBS = SM-W-X(5) * 100000 + SM-W-Y(5) * 1000 + SM-W-ALPHA(5)
     PERFORM CHK
*>   UPDATE_PROGRESS to 1.0 (the worked bytes): a glide of 100 ms from 0.5
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 02 3F 80 00 00" TO WS-HEX
     PERFORM SEND-HEX
     MOVE 1 TO WS-ROW
     CALL "BOSS-DISPLAYED" USING CLIENT-STATE WS-ROW WS-PROGRESS
     MOVE "UPDATE_PROGRESS: at once the displayed value is still 0.5" TO WS-NAME
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-PROGRESS * 1000
     PERFORM CHK
     ADD 50 TO CL-NOW-MS
     CALL "BOSS-DISPLAYED" USING CLIENT-STATE WS-ROW WS-PROGRESS
     MOVE "50 ms later: 0.75" TO WS-NAME
     MOVE 750 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-PROGRESS * 1000
     PERFORM CHK
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "BOSS-HUD-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "the progress width is floor(0.75 x 181) + 1 = 136" TO WS-NAME
     MOVE 136 TO WS-EXP
     MOVE SM-W-W(3) TO WS-OBS
     PERFORM CHK
     ADD 100 TO CL-NOW-MS
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "BOSS-HUD-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "after 100 ms the bar is full: 182" TO WS-NAME
     MOVE 182 TO WS-EXP
     MOVE SM-W-W(3) TO WS-OBS
     PERFORM CHK
*>   UPDATE_NAME, UPDATE_STYLE, UPDATE_PROPERTIES
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 03 08 00 02 48 69" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "T" TO TL-MODE
     MOVE "UPDATE_NAME: the title is Hi" TO TL-CASE
     MOVE "Hi" TO TL-EXPECTED
     MOVE HX-BB-TITLE(1)(1:2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 04 05 00" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "UPDATE_STYLE: purple (5), progress overlay (0)" TO WS-NAME
     MOVE 5000 TO WS-EXP
     COMPUTE WS-OBS = HX-BB-COLOUR(1) * 1000 + HX-BB-OVERLAY(1)
     PERFORM CHK
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "BOSS-HUD-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "no overlay: three widgets" TO WS-NAME
     MOVE 3 TO WS-EXP
     MOVE SM-WIDGET-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 05 02" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "UPDATE_PROPERTIES: flags 2 (a cleared bit clears the flag)" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE HX-BB-FLAGS(1) TO WS-OBS
     PERFORM CHK
*>   the darkening ramp (4.4): flags 5 raise it 0.05 a tick
     MOVE 5 TO HX-BB-FLAGS(1)
     MOVE 0 TO HX-BB-DARK
     PERFORM 10 TIMES
         CALL "BOSS-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "10 ticks with the darken flag: 0.5" TO WS-NAME
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = HX-BB-DARK * 1000
     PERFORM CHK
     PERFORM 15 TIMES
         CALL "BOSS-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "capped at 1 (20 ticks from 0)" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = HX-BB-DARK * 1000
     PERFORM CHK
     MOVE "the previous value is kept for the interpolation" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = HX-BB-DARK-O * 1000
     PERFORM CHK
     MOVE 2 TO HX-BB-FLAGS(1)
     PERFORM 40 TIMES
         CALL "BOSS-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "40 ticks without the flag: 1 - 0.5 = 0.5" TO WS-NAME
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = HX-BB-DARK * 1000
     PERFORM CHK
*>   the music (4.4): only in the End with the music flag
     MOVE "minecraft:overworld" TO PL-DIM-NAME
     CALL "BOSS-MUSIC" USING CLIENT-STATE WS-FLAG
     MOVE "the music flag has no effect in the overworld" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-FLAG TO WS-OBS
     PERFORM CHK
     MOVE "minecraft:the_end" TO PL-DIM-NAME
     CALL "BOSS-MUSIC" USING CLIENT-STATE WS-FLAG
     MOVE "in the End the boss track is wanted" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-FLAG TO WS-OBS
     PERFORM CHK
     MOVE 5 TO HX-BB-FLAGS(1)
     CALL "BOSS-MUSIC" USING CLIENT-STATE WS-FLAG
     MOVE "flags 5 have no music bit: not wanted" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-FLAG TO WS-OBS
     PERFORM CHK
*>   ---- order and the number of bars (4.2, 4.3) ----
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-HEX
         MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 00 08 00 01 58 3F 00 00 00 00 00 00" TO WS-HEX
         MOVE WS-I TO WS-N
         PERFORM SEND-HEX-VARIANT
     END-PERFORM
     MOVE "six bars are kept" TO WS-NAME
     MOVE 6 TO WS-EXP
     MOVE HX-BB-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "BOSS-HUD-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "H 240: four bars (tops 12, 31, 50, 69)" TO WS-NAME
     MOVE 4 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "the fourth bar's title is at y 69 - 9 = 60" TO WS-NAME
     MOVE 60 TO WS-EXP
     MOVE SM-W-Y(SM-WIDGET-COUNT) TO WS-OBS
     PERFORM CHK
     MOVE 270 TO WS-GH
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "BOSS-HUD-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "H 270: five bars" TO WS-NAME
     MOVE 5 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     PERFORM CHK
     MOVE 90 TO WS-GH
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "BOSS-HUD-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "H 90: the first bar only" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     PERFORM CHK
*>   an ADD of an existing id keeps its place; removing and adding moves it to the end
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 00 08 00 01 59 3F 00 00 00 00 00 00" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "T" TO TL-MODE
     MOVE "ADD of a known id replaces it in place (title Y at row 1)" TO TL-CASE
     MOVE "Y" TO TL-EXPECTED
     MOVE HX-BB-TITLE(1)(1:1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "ADD of a known id does not make a seventh bar" TO WS-NAME
     MOVE 6 TO WS-EXP
     MOVE HX-BB-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 01" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "REMOVE: five bars" TO WS-NAME
     MOVE 5 TO WS-EXP
     MOVE HX-BB-COUNT TO WS-OBS
     PERFORM CHK
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 00 08 00 01 5A 3F 00 00 00 00 00 00" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "T" TO TL-MODE
     MOVE "re-added: at the end (row 6)" TO TL-CASE
     MOVE "Z" TO TL-EXPECTED
     MOVE HX-BB-TITLE(6)(1:1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   the clock before the time of the last progress update (a backwards step) shows the start value
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 00 08 00 01 51 3F 00 00 00 03 00 00" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "a clock that went back before the update shows the start value 0.5" TO WS-NAME
     MOVE 6 TO WS-ROW
     COMPUTE CL-NOW-MS = CL-NOW-MS - 500
     CALL "BOSS-DISPLAYED" USING CLIENT-STATE WS-ROW WS-PROGRESS
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-PROGRESS * 1000
     PERFORM CHK
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 02 04 09 00" TO WS-HEX
     PERFORM SEND-HEX
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE 427 TO WS-GW
     MOVE 240 TO WS-GH
     CALL "BOSS-HUD-ADD" USING CLIENT-STATE WS-GW WS-GH
     MOVE "colour 9 of the first bar is drawn with the pink sprites (row of colour 0)" TO WS-NAME
     MOVE GSP-BOSS-BG-0 TO WS-EXP
     MOVE SM-W-ARG(1) TO WS-OBS
     PERFORM CHK
*>   an unknown operation id is ignored, a packet cut short is dropped, an ADD cut short adds nothing
     MOVE HX-BB-COUNT TO WS-COUNT
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 88 09" TO WS-HEX
     PERFORM SEND-HEX
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77 AA 00 08 00 01" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "operation 9 and the two short packets change nothing" TO WS-NAME
     MOVE WS-COUNT TO WS-EXP
     MOVE HX-BB-COUNT TO WS-OBS
     PERFORM CHK
*>   an update of an id that was never added ends the connection
     MOVE "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 99 02 3F 80 00 00" TO WS-HEX
     PERFORM SEND-HEX
     MOVE "UPDATE_PROGRESS before ADD: the connection ends (server list)" TO WS-NAME
     MOVE SCR-SERVER-LIST TO WS-EXP
     MOVE SM-SCREEN TO WS-OBS
     PERFORM CHK
     MOVE "the boss bars go with the connection" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE HX-BB-COUNT TO WS-OBS
     PERFORM CHK
*>   ---- the sprite files (4.3) ----
     MOVE GSP-BOSS-BG-0 TO WS-ROW
     CALL "GUI-SPRITE-PATH-X" USING WS-ROW WS-PATH
     MOVE "T" TO TL-MODE
     MOVE "row boss background 0: pink" TO TL-CASE
     MOVE "assets/minecraft/textures/gui/sprites/boss_bar/pink_background.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-ROW = GSP-BOSS-PROGRESS-0 + 6
     CALL "GUI-SPRITE-PATH-X" USING WS-ROW WS-PATH
     MOVE "row boss progress 6: white" TO TL-CASE
     MOVE "assets/minecraft/textures/gui/sprites/boss_bar/white_progress.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE GSP-BOSS-NOTCH-BG-0 TO WS-ROW
     CALL "GUI-SPRITE-PATH-X" USING WS-ROW WS-PATH
     MOVE "row notched background 0: notched_6" TO TL-CASE
     MOVE "assets/minecraft/textures/gui/sprites/boss_bar/notched_6_background.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE GSP-COUNT TO WS-ROW
     CALL "GUI-SPRITE-PATH-X" USING WS-ROW WS-PATH
     MOVE "the last row: notched_20 progress" TO TL-CASE
     MOVE "assets/minecraft/textures/gui/sprites/boss_bar/notched_20_progress.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     STOP RUN.

 CHK.
     MOVE WS-NAME TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Boss Event (id 9) with the body of WS-HEX.
 SEND-HEX.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     PERFORM APPEND-HEX
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.

*> The same with the last byte of the UUID replaced by WS-N (a new bar).
 SEND-HEX-VARIANT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAP
     MOVE "12 34 56 78 9A BC DE F0 11 22 33 44 55 66 77" TO WS-HEX
     PERFORM APPEND-HEX
     MOVE FUNCTION CHAR(WS-N + 1) TO WS-ONE-BYTE
     MOVE 1 TO WS-ONE-COUNT
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-ONE-BYTE WS-ONE-COUNT
     MOVE "00 08 00 01 58 3F 00 00 00 00 00 00" TO WS-HEX
     PERFORM APPEND-HEX
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID.

*> Appends the bytes of WS-HEX (pairs separated by spaces) to PB-BUFFER.
 APPEND-HEX.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-HEX TRAILING)) TO WS-HEX-LEN
     MOVE 1 TO WS-HP
     PERFORM UNTIL WS-HP > WS-HEX-LEN
         MOVE WS-HEX(WS-HP:1) TO WS-CH
         PERFORM HEX-DIGIT
         MOVE WS-DIGIT TO WS-HI
         MOVE WS-HEX(WS-HP + 1:1) TO WS-CH
         PERFORM HEX-DIGIT
         COMPUTE WS-BYTE = WS-HI * 16 + WS-DIGIT
         MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-ONE-BYTE
         MOVE 1 TO WS-ONE-COUNT
         CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-ONE-BYTE WS-ONE-COUNT
         ADD 3 TO WS-HP
     END-PERFORM.

 HEX-DIGIT.
     EVALUATE TRUE
         WHEN WS-CH >= "0" AND WS-CH <= "9"
             COMPUTE WS-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("0")
         WHEN WS-CH >= "A" AND WS-CH <= "F"
             COMPUTE WS-DIGIT = FUNCTION ORD(WS-CH) - FUNCTION ORD("A") + 10
         WHEN OTHER
             MOVE 0 TO WS-DIGIT
     END-EVALUATE.
 END PROGRAM TEST-HUD-BOSS.

 COPY CLTEST.
