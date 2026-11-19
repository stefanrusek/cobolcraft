*> Acceptance test, operator report of try17 (lane bugscreenbg): the inventory, trading, crafting and the other screens of the game hid the world (a flat sky
*> colour behind them) and the F3 overlay. The world is now drawn behind every screen laid over it (12 section 5.6: the in-game screens' transparent
*> background is a vertical gradient from #c0101010 at the top to #d0101010 at the bottom, 40-9 section 7A.1), the screen is dimmed by that gradient
*> (UI-DIM-QUADS, bands of one alpha each), the world screen itself is not dimmed, the F3 overlay's lines come first among the widgets of a screen over
*> the world, and the screens with a background of their own (title, death, lists, connecting) keep no world.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2BUGSCREENBG-BEHIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-BEHIND              BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-TR                  BINARY-LONG.
 01 WS-TG                  BINARY-LONG.
 01 WS-TB                  BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 3.
 01 WS-EDIT                PIC Z(4)9.
 01 WS-SCREENS.
    05 WS-SCREEN           BINARY-LONG OCCURS 13 TIMES.
 01 WS-OTHERS.
    05 WS-OTHER            BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 1000000000 TO MB-BUDGET-US
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "N" TO TL-MODE
     MOVE SCR-PAUSE TO WS-SCREEN(1)
     MOVE SCR-INVENTORY TO WS-SCREEN(2)
     MOVE SCR-BENCH TO WS-SCREEN(3)
     MOVE SCR-CONTAINER TO WS-SCREEN(4)
     MOVE SCR-CHAT TO WS-SCREEN(5)
     MOVE SCR-SIGN TO WS-SCREEN(6)
     MOVE SCR-BOOK TO WS-SCREEN(7)
     MOVE SCR-CREATIVE TO WS-SCREEN(8)
     MOVE SCR-CMDBLOCK TO WS-SCREEN(9)
     MOVE SCR-FORM TO WS-SCREEN(10)
     MOVE SCR-OPTIONS TO WS-SCREEN(11)
     MOVE SCR-OPEN-TO-OTHERS TO WS-SCREEN(12)
     MOVE SCR-WORLD TO WS-SCREEN(13)
     MOVE SCR-TITLE TO WS-OTHER(1)
     MOVE SCR-DEATH TO WS-OTHER(2)
     MOVE SCR-CONNECTING TO WS-OTHER(3)
     MOVE SCR-WORLD-LIST TO WS-OTHER(4)
     MOVE SCR-PACKS TO WS-OTHER(5)
     MOVE SCR-SERVER-LIST TO WS-OTHER(6)

*>   The world is in the render list behind each screen of the game, as on the world screen (the last of the table).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         MOVE WS-SCREEN(WS-I) TO SM-SCREEN
         MOVE 0 TO SM-WIDGET-COUNT
         CALL "UI-RENDER" USING CLIENT-STATE
         CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
         CALL "TEST-TERRAIN-DRAWS" USING CLIENT-STATE WS-DRAWS
         MOVE WS-SCREEN(WS-I) TO WS-EDIT
         MOVE SPACES TO TL-CASE
         STRING "acceptance bugscreenbg: given play when screen " FUNCTION TRIM(WS-EDIT)
             " is shown then the chunk sections are drawn behind it" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-DRAWS > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   Screens with a background of their own keep none of the world, though the connection is in play.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-OTHER(WS-I) TO SM-SCREEN
         MOVE 0 TO SM-WIDGET-COUNT
         CALL "UI-RENDER" USING CLIENT-STATE
         CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
         CALL "TEST-TERRAIN-DRAWS" USING CLIENT-STATE WS-DRAWS
         MOVE WS-OTHER(WS-I) TO WS-EDIT
         MOVE SPACES TO TL-CASE
         STRING "acceptance bugscreenbg: given play when screen " FUNCTION TRIM(WS-EDIT)
             " is shown then it draws no chunk section and no dimming" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = WS-DRAWS + RL-UI-COUNT
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   Out of play (no game connection) the options screen is a menu screen: no world behind it.
     MOVE PH-NONE TO CN-PHASE(CONN-GAME)
     MOVE SCR-OPTIONS TO SM-SCREEN
     CALL "SCREEN-WORLD-BEHIND" USING CLIENT-STATE WS-BEHIND
     MOVE "acceptance bugscreenbg: given no game connection when the options screen is shown then no world is behind it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BEHIND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PH-PLAY TO CN-PHASE(CONN-GAME)

*>   The dimming: 16 bands over the window (640 x 480) of the white swatch tinted #101010, alpha from 192/255 (top) to 208/255 (bottom).
     MOVE SCR-INVENTORY TO SM-SCREEN
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "acceptance bugscreenbg: given the inventory screen over the world then the gradient is 16 bands of 6 vertices (96)" TO TL-CASE
     MOVE 96 TO TL-EXPECTED-N
     MOVE RL-UI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugscreenbg: the first band spans the window width from the top edge (x 0 to 640, y 0 to 30)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 640 * 1000000 + 30 * 1000 + 0
     COMPUTE TL-OBSERVED-N = RL-UI-X(3) * 1000000 + RL-UI-Y(3) * 1000 + RL-UI-X(1) + RL-UI-Y(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugscreenbg: the last band ends at the bottom edge (y 480)" TO TL-CASE
     MOVE 480 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-UI-Y(96)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugscreenbg: the first band's alpha is 0.7549 (the gradient at its middle, in thousandths 754)" TO TL-CASE
     MOVE 754 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-UI-A(1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugscreenbg: the last band's alpha is 0.8137 (813 thousandths)" TO TL-CASE
     MOVE 813 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-UI-A(91) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugscreenbg: the veil is #101010: tint 16/255 (62 thousandths) in each channel, full brightness" TO TL-CASE
     COMPUTE WS-TR = RL-UI-R(1) * 1000
     COMPUTE WS-TG = RL-UI-G(1) * 1000
     COMPUTE WS-TB = RL-UI-BLUE(1) * 1000
     COMPUTE TL-EXPECTED-N = 62062062 * 10 + 1
     COMPUTE TL-OBSERVED-N = (WS-TR * 1000000 + WS-TG * 1000 + WS-TB) * 10 + RL-UI-B(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugscreenbg: the alpha rises band by band (band 2 above band 1, below band 16)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-UI-A(7) > RL-UI-A(1) AND RL-UI-A(7) < RL-UI-A(91)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The world screen is not dimmed.
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "acceptance bugscreenbg: given the world screen then no gradient is drawn" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-UI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The F3 overlay over a screen: its version line is the first widget when F3 is on, absent when it is off, and never on a screen of its own background.
     MOVE 1 TO CL-DEBUG
     MOVE SCR-INVENTORY TO SM-SCREEN
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "TEST-DEBUG-AT" USING CLIENT-STATE WS-AT
     MOVE "acceptance bugscreenbg: given F3 on when the inventory screen is built then the overlay's version line is its first widget" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SCR-PAUSE TO SM-SCREEN
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "TEST-DEBUG-AT" USING CLIENT-STATE WS-AT
     MOVE "acceptance bugscreenbg: given F3 on when the pause menu is built then the overlay's version line is its first widget" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SCR-TITLE TO SM-SCREEN
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "TEST-DEBUG-AT" USING CLIENT-STATE WS-AT
     MOVE "acceptance bugscreenbg: given F3 on when the title screen is built then there is no overlay" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-DEBUG
     MOVE SCR-INVENTORY TO SM-SCREEN
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "TEST-DEBUG-AT" USING CLIENT-STATE WS-AT
     MOVE "acceptance bugscreenbg: given F3 off when the inventory screen is built then there is no overlay" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM ACC-F2BUGSCREENBG-BEHIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DEBUG-AT.
*> USING CLIENT-STATE, index out: the first widget that is a label whose text begins "CobolCraft" (the F3 overlay's version line), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-AT                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-AT.
     MOVE 0 TO L-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF L-AT = 0 AND SM-W-KIND(WS-I) = WK-LABEL AND SM-W-LENGTH(WS-I) >= 10
                 AND SM-W-TEXT(WS-I)(1:10) = "CobolCraft"
             MOVE WS-I TO L-AT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-DEBUG-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TERRAIN-DRAWS.
*> USING CLIENT-STATE, count out: the draws of the render list that are chunk sections (mesh slots MESH-SLOT-BASE up to the entity slot).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) >= MESH-SLOT-BASE AND RL-D-SLOT(WS-I) < MESH-SLOT-ENTITIES
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-TERRAIN-DRAWS.
