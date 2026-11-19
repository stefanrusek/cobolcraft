*> Lane screenwidgets (T60400 and on; the open item T60103 of bugscreenart): the things drawn on top of a container screen's sheet are the pack's sprites, not swatch placeholders
*> (docs/protocol/40-menus-2 to 40-menus-6). The real generated vanilla pack (CC_GENERATED_DIR), the real SCREEN-BUILD and UI-RENDER; each case looks for the quad of a sprite at its
*> documented place with the documented source region (window coordinates are 2 x the GUI's; "bottom" and clipped parts take the part of the sprite the doc names), and the model
*> of each screen holds no swatch overlay (the placeholders). Furnace family (40-2 3.2, 3.3: flame and arrow of each kind), brewing stand (5, 4.2), anvil (40-3 3.8), grindstone and
*> smithing error icons, enchanting rows (40-4 2.9), beacon (40-5 3.7), merchant (2.10), stonecutter (40-4 4.9), loom and cartography (3.10, 5.7), crafter (40-2 7.3) and the mounts
*> (40-6 6.2). Skipped (no cases) when the pack has no container sheets.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-WIDGETS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-FILE                PIC X(512).
 01 WS-INFO                PIC X(16).
 01 WS-ROOT                PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V3                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-IMG-W               BINARY-LONG.
 01 WS-IMG-H               BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DW                  BINARY-LONG.
 01 WS-DH                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SW                  BINARY-LONG.
 01 WS-SH                  BINARY-LONG.
 01 WS-ABS                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-EX0                 FLOAT-LONG.
 01 WS-EY0                 FLOAT-LONG.
 01 WS-EX1                 FLOAT-LONG.
 01 WS-EY1                 FLOAT-LONG.
 01 WS-EU0                 FLOAT-LONG.
 01 WS-EV0                 FLOAT-LONG.
 01 WS-EU1                 FLOAT-LONG.
 01 WS-EV1                 FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-OVERLAYS            BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-BURN            BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE-N              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "FONT-LOAD" USING CLIENT-STATE
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-ROOT) "/assets/minecraft/textures/gui/container/generic_54.png" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     IF RETURN-CODE NOT = 0
         DISPLAY "test_screen_widgets: no container sheets in " FUNCTION TRIM(WS-ROOT) ", skipped"
         STOP RUN
     END-IF
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
     MOVE "N" TO TL-MODE
     DISPLAY "  UI atlas " UA-W " x " UA-H

*>   The 67 widget sprites are all loaded (rows GSP-BLAST-LIT on), at the sizes the docs give.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM GSP-BLAST-LIT BY 1 UNTIL WS-I > GSP-COUNT
         IF GS-W(WS-I) = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "widget sprites all 67 are loaded from the pack" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "widget sprites sizes: flame 14 x 14, arrow 24 x 16, bubbles 12 x 29, beacon button 22 x 22, villager scroller 6 x 27, error icon 28 x 21" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 14 * 1000000 + 24 * 10000 + 12 * 100 + 22
     COMPUTE TL-OBSERVED-N = GS-W(GSP-FURNACE-LIT) * 1000000 + GS-W(GSP-FURNACE-BURN) * 10000 + GS-W(GSP-BREW-BUBBLES) * 100 + GS-W(GSP-BEACON-BUTTON)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE TL-EXPECTED-N = 29 * 1000000 + 27 * 10000 + 28 * 100 + 21
     COMPUTE TL-OBSERVED-N = GS-H(GSP-BREW-BUBBLES) * 1000000 + GS-H(GSP-VIL-SCROLLER) * 10000 + GS-W(GSP-ANVIL-ERROR) * 100 + GS-H(GSP-ANVIL-ERROR)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM CHECK-FURNACES
     PERFORM CHECK-BREWING
     PERFORM CHECK-ANVIL-FAMILY
     PERFORM CHECK-ENCHANTING
     PERFORM CHECK-BEACON
     PERFORM CHECK-MERCHANT
     PERFORM CHECK-STONECUTTER
     PERFORM CHECK-LOOM-CARTOGRAPHY
     PERFORM CHECK-CRAFTER
     PERFORM CHECK-MOUNTS
     STOP RUN.

*> A clean state for a screen: no stacks, no data, no offers, the pointer far outside every screen, survival.
 RESET-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 0 TO BX-COUNT(WS-I) BX-ITEM(WS-I) BX-DAMAGE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO BM-DATA(WS-I)
     END-PERFORM
     MOVE 0 TO MC-COUNT MC-LEVEL MC-XP MC-PROGRESS MC-RESTOCK MC-SCROLL MC-SELECTED BC-PRIMARY BC-SECONDARY SC-COUNT SC-START
     MOVE 0 TO MT-SADDLE MT-BODY MT-ICON MT-KIND PL-MODE PL-XP-LEVEL
     MOVE -1000 TO IN-CURSOR-X IN-CURSOR-Y
     .

*> Builds and renders the container screen of type BM-TYPE with the image size WS-IMG-W x WS-IMG-H (the screen's position follows).
 BUILD-SCREEN.
     MOVE WS-TYPE-N TO BM-TYPE
     MOVE SCR-CONTAINER TO SM-SCREEN
     MOVE "Title" TO SM-CX-TITLE
     MOVE 5 TO SM-CX-TITLE-LENGTH
     MOVE 1 TO BM-ID BM-STATE-ID
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "UI-RENDER" USING CLIENT-STATE
     COMPUTE WS-GW = IN-WIN-W / CL-GUI-SCALE
     COMPUTE WS-GH = IN-WIN-H / CL-GUI-SCALE
     COMPUTE WS-LEFT = (WS-GW - WS-IMG-W) / 2
     COMPUTE WS-TOP = (WS-GH - WS-IMG-H) / 2
     .

*> Counts into WS-FOUND the quads of sprite WS-SPRITE whose destination is (WS-DX, WS-DY) of size WS-DW x WS-DH (relative to the image unless WS-ABS is 1) and whose source is the part
*> of the sprite from texel (WS-SX, WS-SY) of size WS-SW x WS-SH.
 FIND-SPRITE.
     IF WS-ABS = 1
         COMPUTE WS-EX0 = WS-DX * CL-GUI-SCALE
         COMPUTE WS-EY0 = WS-DY * CL-GUI-SCALE
         COMPUTE WS-EX1 = (WS-DX + WS-DW) * CL-GUI-SCALE
         COMPUTE WS-EY1 = (WS-DY + WS-DH) * CL-GUI-SCALE
     ELSE
         COMPUTE WS-EX0 = (WS-LEFT + WS-DX) * CL-GUI-SCALE
         COMPUTE WS-EY0 = (WS-TOP + WS-DY) * CL-GUI-SCALE
         COMPUTE WS-EX1 = (WS-LEFT + WS-DX + WS-DW) * CL-GUI-SCALE
         COMPUTE WS-EY1 = (WS-TOP + WS-DY + WS-DH) * CL-GUI-SCALE
     END-IF
     COMPUTE WS-EU0 = (GS-X(WS-SPRITE) + WS-SX) / UA-W
     COMPUTE WS-EV0 = (GS-Y(WS-SPRITE) + WS-SY) / UA-H
     COMPUTE WS-EU1 = (GS-X(WS-SPRITE) + WS-SX + WS-SW) / UA-W
     COMPUTE WS-EV1 = (GS-Y(WS-SPRITE) + WS-SY + WS-SH) / UA-H
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-Q FROM 0 BY 1 UNTIL WS-Q * 6 + 6 > RL-UI-COUNT
         COMPUTE WS-V1 = WS-Q * 6 + 1
         COMPUTE WS-V3 = WS-Q * 6 + 3
         IF RL-UI-X(WS-V1) > WS-EX0 - 0.01 AND RL-UI-X(WS-V1) < WS-EX0 + 0.01
                 AND RL-UI-Y(WS-V1) > WS-EY0 - 0.01 AND RL-UI-Y(WS-V1) < WS-EY0 + 0.01
                 AND RL-UI-X(WS-V3) > WS-EX1 - 0.01 AND RL-UI-X(WS-V3) < WS-EX1 + 0.01
                 AND RL-UI-Y(WS-V3) > WS-EY1 - 0.01 AND RL-UI-Y(WS-V3) < WS-EY1 + 0.01
                 AND RL-UI-U(WS-V1) > WS-EU0 - 0.00001 AND RL-UI-U(WS-V1) < WS-EU0 + 0.00001
                 AND RL-UI-V(WS-V1) > WS-EV0 - 0.00001 AND RL-UI-V(WS-V1) < WS-EV0 + 0.00001
                 AND RL-UI-U(WS-V3) > WS-EU1 - 0.00001 AND RL-UI-U(WS-V3) < WS-EU1 + 0.00001
                 AND RL-UI-V(WS-V3) > WS-EV1 - 0.00001 AND RL-UI-V(WS-V3) < WS-EV1 + 0.00001
             ADD 1 TO WS-FOUND
         END-IF
     END-PERFORM
     .

*> A whole sprite (not clipped) of its own size at (WS-DX, WS-DY), the case text TL-CASE, expected WS-FOUND = L (1 drawn, 0 absent) in TL-EXPECTED-N.
 EXPECT-WHOLE.
     MOVE GS-W(WS-SPRITE) TO WS-DW WS-SW
     MOVE GS-H(WS-SPRITE) TO WS-DH WS-SH
     MOVE 0 TO WS-SX WS-SY
     PERFORM FIND-SPRITE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> A whole sprite drawn at least once (a frame the slot widget's own well draws again at the same place).
 EXPECT-SOME.
     MOVE GS-W(WS-SPRITE) TO WS-DW WS-SW
     MOVE GS-H(WS-SPRITE) TO WS-DH WS-SH
     MOVE 0 TO WS-SX WS-SY
     PERFORM FIND-SPRITE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> A part of a sprite: destination (WS-DX, WS-DY) of WS-DW x WS-DH, source (WS-SX, WS-SY) of WS-SW x WS-SH; expectation in TL-EXPECTED-N.
 EXPECT-PART.
     PERFORM FIND-SPRITE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> No swatch overlay is in the screen model (the placeholders) and no panel one covers the screen.
 EXPECT-NO-OVERLAY.
     MOVE 0 TO WS-OVERLAYS
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-Q) = WK-OVERLAY
             ADD 1 TO WS-OVERLAYS
         END-IF
     END-PERFORM
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OVERLAYS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> Furnace (14), blast furnace (10), smoker (22): data (1200, 1600, 57, 200): flame h = 11 (source (0, 3) 14 x 11 at (56, 39)) and the arrow w = 7 (7 x 16 at (79, 34)), each kind's own sprites.
 CHECK-FURNACES.
     MOVE 176 TO WS-IMG-W
     MOVE 166 TO WS-IMG-H
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         PERFORM RESET-STATE
         EVALUATE WS-K
             WHEN 1
                 MOVE 14 TO WS-TYPE-N
                 MOVE "furnace" TO WS-NAME
             WHEN 2
                 MOVE 10 TO WS-TYPE-N
                 MOVE "blast furnace" TO WS-NAME
             WHEN OTHER
                 MOVE 22 TO WS-TYPE-N
                 MOVE "smoker" TO WS-NAME
         END-EVALUATE
         MOVE 1200 TO BM-DATA(1)
         MOVE 1600 TO BM-DATA(2)
         MOVE 57 TO BM-DATA(3)
         MOVE 200 TO BM-DATA(4)
         PERFORM BUILD-SCREEN
         CALL "DECOR-FURNACE-ROWS" USING WS-TYPE-N WS-SPRITE WS-ROW-BURN
         MOVE SPACES TO TL-CASE
         STRING "furnace screens " FUNCTION TRIM(WS-NAME) ": its own flame and arrow rows" DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-K
             WHEN 1
                 COMPUTE TL-EXPECTED-N = GSP-FURNACE-LIT * 1000 + GSP-FURNACE-BURN
             WHEN 2
                 COMPUTE TL-EXPECTED-N = GSP-BLAST-LIT * 1000 + GSP-BLAST-BURN
             WHEN OTHER
                 COMPUTE TL-EXPECTED-N = GSP-SMOKER-LIT * 1000 + GSP-SMOKER-BURN
         END-EVALUATE
         COMPUTE TL-OBSERVED-N = WS-SPRITE * 1000 + WS-ROW-BURN
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 56 TO WS-DX
         MOVE 39 TO WS-DY
         MOVE 14 TO WS-DW
         MOVE 11 TO WS-DH
         MOVE 0 TO WS-SX
         MOVE 3 TO WS-SY
         MOVE 14 TO WS-SW
         MOVE 11 TO WS-SH
         MOVE 0 TO WS-ABS
         MOVE SPACES TO TL-CASE
         STRING "furnace screens " FUNCTION TRIM(WS-NAME) ": the flame is the bottom 11 rows of its own 14 x 14 sprite at (56, 39)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         PERFORM EXPECT-PART
         MOVE WS-ROW-BURN TO WS-SPRITE
         MOVE 79 TO WS-DX
         MOVE 34 TO WS-DY
         MOVE 7 TO WS-DW WS-SW
         MOVE 16 TO WS-DH WS-SH
         MOVE 0 TO WS-SX WS-SY
         MOVE SPACES TO TL-CASE
         STRING "furnace screens " FUNCTION TRIM(WS-NAME) ": the arrow is the left 7 columns of its own 24 x 16 sprite at (79, 34)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         PERFORM EXPECT-PART
         MOVE SPACES TO TL-CASE
         STRING "furnace screens " FUNCTION TRIM(WS-NAME) ": no swatch placeholder" DELIMITED BY SIZE INTO TL-CASE
         PERFORM EXPECT-NO-OVERLAY
     END-PERFORM
     .

*> Brewing stand: E6 of 40-2: b = 200, B = 400, f = 10, T = 20: the arrow 9 x 14 from the top, the bubbles (index 2, 20 rows) from source row 9 at (63, 23), the fuel bar 9 x 4 at (60, 44);
*> a bottle in the left slot only: the empty-slot icons of the other two bottle slots and the fuel slot (16 x 16 at their item cells).
 CHECK-BREWING.
     MOVE 176 TO WS-IMG-W
     MOVE 166 TO WS-IMG-H
     PERFORM RESET-STATE
     MOVE 11 TO WS-TYPE-N
     MOVE 200 TO BM-DATA(1)
     MOVE 10 TO BM-DATA(2)
     MOVE 400 TO BM-DATA(3)
     MOVE 20 TO BM-DATA(4)
     MOVE 1 TO BX-COUNT(1)
     PERFORM BUILD-SCREEN
     MOVE GSP-BREW-ARROW TO WS-SPRITE
     MOVE 97 TO WS-DX
     MOVE 16 TO WS-DY
     MOVE 9 TO WS-DW WS-SW
     MOVE 14 TO WS-DH WS-SH
     MOVE 0 TO WS-SX WS-SY
     MOVE "brewing stand the arrow is the top 14 rows of the 9 x 28 sprite at (97, 16)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-PART
     MOVE GSP-BREW-BUBBLES TO WS-SPRITE
     MOVE 63 TO WS-DX
     MOVE 23 TO WS-DY
     MOVE 12 TO WS-DW WS-SW
     MOVE 20 TO WS-DH WS-SH
     MOVE 0 TO WS-SX
     MOVE 9 TO WS-SY
     MOVE "brewing stand the bubbles are the bottom 20 rows of the 12 x 29 sprite at (63, 23)" TO TL-CASE
     PERFORM EXPECT-PART
     MOVE GSP-BREW-FUEL TO WS-SPRITE
     MOVE 60 TO WS-DX
     MOVE 44 TO WS-DY
     MOVE 9 TO WS-DW WS-SW
     MOVE 4 TO WS-DH WS-SH
     MOVE 0 TO WS-SX WS-SY
     MOVE "brewing stand the fuel bar is the left 9 columns of the 18 x 4 sprite at (60, 44)" TO TL-CASE
     PERFORM EXPECT-PART
     MOVE GSP-SLOT-POTION TO WS-SPRITE
     MOVE 79 TO WS-DX
     MOVE 58 TO WS-DY
     MOVE "brewing stand the middle bottle slot is empty: the potion icon at (79, 58)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 102 TO WS-DX
     MOVE 51 TO WS-DY
     MOVE "brewing stand the right bottle slot is empty: the potion icon at (102, 51)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 56 TO WS-DX
     MOVE 51 TO WS-DY
     MOVE "brewing stand the left bottle slot holds a bottle: no potion icon at (56, 51)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-SLOT-BREW-FUEL TO WS-SPRITE
     MOVE 17 TO WS-DX
     MOVE 17 TO WS-DY
     MOVE "brewing stand the fuel slot is empty: the brewing fuel icon at (17, 17)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE "brewing stand no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     .

*> Anvil (40-3 3.8): the field sprite 110 x 16 at (59, 20), the enabled one with an item in slot 0, the disabled one without; the error icon 28 x 21 at (99, 45) with an input and no result.
*> Grindstone (4.7): the error icon at (92, 31). Smithing (5.5): the error icon at (65, 46) while the error flag is 1.
 CHECK-ANVIL-FAMILY.
     MOVE 176 TO WS-IMG-W
     MOVE 166 TO WS-IMG-H
     PERFORM RESET-STATE
     MOVE 8 TO WS-TYPE-N
     MOVE 1 TO BX-COUNT(1)
     PERFORM BUILD-SCREEN
     MOVE GSP-ANVIL-FIELD TO WS-SPRITE
     MOVE 59 TO WS-DX
     MOVE 20 TO WS-DY
     MOVE "anvil with an item: the enabled field sprite at (59, 20)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-ANVIL-FIELD-OFF TO WS-SPRITE
     MOVE "anvil with an item: not the disabled field sprite" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-ANVIL-ERROR TO WS-SPRITE
     MOVE 99 TO WS-DX
     MOVE 45 TO WS-DY
     MOVE "anvil with an input and no result: the error icon at (99, 45)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE "anvil no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     MOVE 1 TO BX-COUNT(3)
     MOVE 0 TO BX-COUNT(1)
     PERFORM BUILD-SCREEN
     MOVE GSP-ANVIL-FIELD-OFF TO WS-SPRITE
     MOVE 59 TO WS-DX
     MOVE 20 TO WS-DY
     MOVE "anvil without an item in slot 0: the disabled field sprite at (59, 20)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-ANVIL-ERROR TO WS-SPRITE
     MOVE 99 TO WS-DX
     MOVE 45 TO WS-DY
     MOVE "anvil with a result: no error icon" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     PERFORM RESET-STATE
     MOVE 15 TO WS-TYPE-N
     MOVE 1 TO BX-COUNT(2)
     PERFORM BUILD-SCREEN
     MOVE GSP-GRIND-ERROR TO WS-SPRITE
     MOVE 92 TO WS-DX
     MOVE 31 TO WS-DY
     MOVE "grindstone with an input and no result: the error icon at (92, 31)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE "grindstone no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     PERFORM RESET-STATE
     MOVE 21 TO WS-TYPE-N
     MOVE 1 TO BM-DATA(1)
     PERFORM BUILD-SCREEN
     MOVE GSP-SMITH-ERROR TO WS-SPRITE
     MOVE 65 TO WS-DX
     MOVE 46 TO WS-DY
     MOVE "smithing table with the error flag: the error icon at (65, 46)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE "smithing table no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     MOVE 0 TO BM-DATA(1)
     PERFORM BUILD-SCREEN
     MOVE "smithing table without the error flag: no error icon" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     .

*> Enchanting table (40-4 2.9): costs 10, 20, 0 with 2 lapis and level 15: row 0 enabled (level_1 icon at (61, 15), the normal row sprite), row 1 not payable (the disabled row sprite and
*> level_2_disabled at (61, 34)), row 2 cost 0 (the disabled sprite only); with the pointer in row 0 its sprite is the highlighted one.
 CHECK-ENCHANTING.
     MOVE 176 TO WS-IMG-W
     MOVE 166 TO WS-IMG-H
     PERFORM RESET-STATE
     MOVE 13 TO WS-TYPE-N
     MOVE 10 TO BM-DATA(1)
     MOVE 20 TO BM-DATA(2)
     MOVE 0 TO BM-DATA(3)
     MOVE 2 TO BX-COUNT(2)
     MOVE 15 TO PL-XP-LEVEL
     PERFORM BUILD-SCREEN
     MOVE GSP-ENCH-SLOT TO WS-SPRITE
     MOVE 60 TO WS-DX
     MOVE 14 TO WS-DY
     MOVE "enchanting row 0 payable: the normal row sprite 108 x 19 at (60, 14)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-ENCH-LEVEL-1 TO WS-SPRITE
     MOVE 61 TO WS-DX
     MOVE 15 TO WS-DY
     MOVE "enchanting row 0 payable: the level 1 icon at (61, 15)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-ENCH-SLOT-OFF TO WS-SPRITE
     MOVE 60 TO WS-DX
     MOVE 33 TO WS-DY
     MOVE "enchanting row 1 level 15 under the cost 20: the disabled row sprite at (60, 33)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-ENCH-LEVEL-OFF-2 TO WS-SPRITE
     MOVE 61 TO WS-DX
     MOVE 34 TO WS-DY
     MOVE "enchanting row 1 level 15 under the cost 20: the level 2 disabled icon at (61, 34)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 60 TO WS-DX
     MOVE 52 TO WS-DY
     MOVE GSP-ENCH-SLOT-OFF TO WS-SPRITE
     MOVE "enchanting row 2 with cost 0: the disabled row sprite at (60, 52)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-ENCH-LEVEL-OFF-3 TO WS-SPRITE
     MOVE 61 TO WS-DX
     MOVE 53 TO WS-DY
     MOVE "enchanting row 2 with cost 0: no level icon" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE "enchanting no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     COMPUTE IN-CURSOR-X = (WS-LEFT + 100) * CL-GUI-SCALE
     COMPUTE IN-CURSOR-Y = (WS-TOP + 20) * CL-GUI-SCALE
     PERFORM BUILD-SCREEN
     MOVE GSP-ENCH-SLOT-HI TO WS-SPRITE
     MOVE 60 TO WS-DX
     MOVE 14 TO WS-DY
     MOVE "enchanting row 0 under the pointer: the highlighted row sprite" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-ENCH-SLOT TO WS-SPRITE
     MOVE "enchanting row 0 under the pointer: not the normal row sprite" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-ENCH-SLOT-HI TO WS-SPRITE
     MOVE 60 TO WS-DX
     MOVE 33 TO WS-DY
     MOVE "enchanting row 1 not payable under no pointer: never highlighted" TO TL-CASE
     PERFORM EXPECT-WHOLE
     .

*> Beacon (40-5 3.7; image 230 x 219): level 2, the speed power chosen, a payment in the slot. The 22 x 22 buttons: speed (53, 22) selected, haste (77, 22) normal, resistance (53, 47) normal,
*> strength (65, 72) and the secondary regeneration (144, 47) disabled (tier 2 and 3 under level 2); the upgrade button (168, 47) shows once a primary is chosen and is disabled; confirm (164, 107)
*> normal with its 18 x 18 icon at (166, 109), cancel (190, 107) with its icon at (192, 109). The pointer over haste gives its highlighted sprite.
 CHECK-BEACON.
     MOVE 230 TO WS-IMG-W
     MOVE 219 TO WS-IMG-H
     PERFORM RESET-STATE
     MOVE 9 TO WS-TYPE-N
     MOVE 2 TO BM-DATA(1)
     MOVE 1 TO BC-PRIMARY
     MOVE 1 TO BX-COUNT(1)
     PERFORM BUILD-SCREEN
     MOVE GSP-BEACON-SEL TO WS-SPRITE
     MOVE 53 TO WS-DX
     MOVE 22 TO WS-DY
     MOVE "beacon the chosen primary power: the selected button sprite at (53, 22)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-BEACON-BUTTON TO WS-SPRITE
     MOVE 77 TO WS-DX
     MOVE "beacon an active power: the plain button sprite at (77, 22)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 47 TO WS-DY
     MOVE 53 TO WS-DX
     MOVE "beacon tier 1 under level 2: the plain button sprite at (53, 47)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-BEACON-OFF TO WS-SPRITE
     MOVE 65 TO WS-DX
     MOVE 72 TO WS-DY
     MOVE "beacon tier 2 under level 2: the disabled button sprite at (65, 72)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 144 TO WS-DX
     MOVE 47 TO WS-DY
     MOVE "beacon the secondary power under level 2: the disabled button sprite at (144, 47)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 168 TO WS-DX
     MOVE "beacon the upgrade button under level 2: the disabled button sprite at (168, 47)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-BEACON-BUTTON TO WS-SPRITE
     MOVE 164 TO WS-DX
     MOVE 107 TO WS-DY
     MOVE "beacon confirm with a payment and a primary: the plain button sprite at (164, 107)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 190 TO WS-DX
     MOVE "beacon cancel: the plain button sprite at (190, 107)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-BEACON-CONFIRM TO WS-SPRITE
     MOVE 166 TO WS-DX
     MOVE 109 TO WS-DY
     MOVE "beacon the confirm icon 18 x 18 at (166, 109)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-BEACON-CANCEL TO WS-SPRITE
     MOVE 192 TO WS-DX
     MOVE "beacon the cancel icon 18 x 18 at (192, 109)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE "beacon no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     MOVE 0 TO BX-COUNT(1)
     PERFORM BUILD-SCREEN
     MOVE GSP-BEACON-OFF TO WS-SPRITE
     MOVE 164 TO WS-DX
     MOVE 107 TO WS-DY
     MOVE "beacon confirm without a payment: the disabled button sprite at (164, 107)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE 1 TO BX-COUNT(1)
     COMPUTE IN-CURSOR-X = (WS-LEFT + 85) * CL-GUI-SCALE
     COMPUTE IN-CURSOR-Y = (WS-TOP + 30) * CL-GUI-SCALE
     PERFORM BUILD-SCREEN
     MOVE GSP-BEACON-HI TO WS-SPRITE
     MOVE 77 TO WS-DX
     MOVE 22 TO WS-DY
     MOVE "beacon the pointer over haste: the highlighted button sprite at (77, 22)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     .

*> Merchant (40-5 2.10; image 276 x 166, left 22): three offers, the second out of stock and selected (level 2, xp 40, the trade shown in the result slot worth 5 xp). The row buttons are the
*> 88 x 20 button sprite (a nine-slice: its top-left border quad is looked for), the selected offer's the disabled one; the arrow 10 x 9 at (60, 22 + 20 r), the out-of-stock one on row 1;
*> the scroller thumb 6 x 27 at (94, 18), the disabled sprite (3 offers fit); the experience bar 102 x 5 at (136, 16) with the current part 51 wide (E4) and the preview of 8 from source
*> column 51; the out-of-stock cross 28 x 21 at (182, 35).
 CHECK-MERCHANT.
     MOVE 276 TO WS-IMG-W
     MOVE 166 TO WS-IMG-H
     PERFORM RESET-STATE
     MOVE 19 TO WS-TYPE-N
     MOVE 3 TO MC-COUNT
     MOVE 2 TO MC-LEVEL
     MOVE 40 TO MC-XP
     MOVE 1 TO MC-PROGRESS
     MOVE 1 TO MC-SELECTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE 1 TO MO-A-ITEM(WS-I)
         MOVE 5 TO MO-A-COUNT(WS-I)
         MOVE 0 TO MO-B-ITEM(WS-I) MO-B-COUNT(WS-I)
         MOVE 2 TO MO-R-ITEM(WS-I)
         MOVE 1 TO MO-R-COUNT(WS-I)
         MOVE 0 TO MO-OUT(WS-I) MO-USES(WS-I) MO-SPECIAL(WS-I) MO-DEMAND(WS-I)
         MOVE 10 TO MO-MAX(WS-I)
         MOVE 0 TO MO-XP(WS-I)
         MOVE 0 TO MO-MULT(WS-I)
     END-PERFORM
     MOVE 1 TO MO-OUT(2)
     MOVE 5 TO MO-XP(2)
     MOVE 1 TO BX-COUNT(3)
     PERFORM BUILD-SCREEN
     COMPUTE WS-F = GS-W(GSP-BUTTON) / GS-LW(GSP-BUTTON)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         MOVE GSP-BUTTON TO WS-SPRITE
         MOVE "merchant row button the plain sprite (top-left corner quad)" TO TL-CASE
         IF WS-I = 1
             MOVE GSP-BUTTON-OFF TO WS-SPRITE
             MOVE "merchant row button of the selected offer the disabled sprite (top-left corner quad)" TO TL-CASE
         END-IF
         MOVE 5 TO WS-DX
         COMPUTE WS-DY = 18 + 20 * WS-I
         MOVE GS-BL(WS-SPRITE) TO WS-DW
         MOVE GS-BT(WS-SPRITE) TO WS-DH
         MOVE 0 TO WS-SX WS-SY
         COMPUTE WS-SW = GS-BL(WS-SPRITE) * GS-W(WS-SPRITE) / GS-LW(WS-SPRITE)
         COMPUTE WS-SH = GS-BT(WS-SPRITE) * GS-H(WS-SPRITE) / GS-LH(WS-SPRITE)
         MOVE 1 TO TL-EXPECTED-N
         PERFORM EXPECT-PART
     END-PERFORM
     MOVE GSP-VIL-ARROW TO WS-SPRITE
     MOVE 60 TO WS-DX
     MOVE 22 TO WS-DY
     MOVE "merchant row 0 in stock: the trade arrow at (60, 22)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-VIL-ARROW-OFF TO WS-SPRITE
     MOVE 42 TO WS-DY
     MOVE "merchant row 1 out of stock: the out-of-stock arrow at (60, 42)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-VIL-SCROLLER-OFF TO WS-SPRITE
     MOVE 94 TO WS-DX
     MOVE 18 TO WS-DY
     MOVE "merchant 3 offers fit: the disabled scroller at (94, 18)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-VIL-XP-BACK TO WS-SPRITE
     MOVE 136 TO WS-DX
     MOVE 16 TO WS-DY
     MOVE "merchant the experience bar background 102 x 5 at (136, 16)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-VIL-XP-CURRENT TO WS-SPRITE
     MOVE 51 TO WS-DW WS-SW
     MOVE 5 TO WS-DH WS-SH
     MOVE 0 TO WS-SX WS-SY
     MOVE "merchant level 2, xp 40: the current part is the left 51 columns (E4)" TO TL-CASE
     PERFORM EXPECT-PART
     MOVE GSP-VIL-XP-RESULT TO WS-SPRITE
     MOVE 187 TO WS-DX
     MOVE 8 TO WS-DW WS-SW
     MOVE 51 TO WS-SX
     MOVE "merchant the preview of 5 xp: 8 columns from source column 51 at (187, 16)" TO TL-CASE
     PERFORM EXPECT-PART
     MOVE GSP-VIL-OUT TO WS-SPRITE
     MOVE 182 TO WS-DX
     MOVE 35 TO WS-DY
     MOVE "merchant the selected offer is out of stock: the cross at (182, 35)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE "merchant no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     MOVE 0 TO MC-SELECTED
     PERFORM BUILD-SCREEN
     MOVE GSP-VIL-OUT TO WS-SPRITE
     MOVE "merchant the selected offer is in stock: no cross" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     COMPUTE IN-CURSOR-X = (WS-LEFT + 40) * CL-GUI-SCALE
     COMPUTE IN-CURSOR-Y = (WS-TOP + 70) * CL-GUI-SCALE
     PERFORM BUILD-SCREEN
     MOVE GSP-BUTTON-HI TO WS-SPRITE
     MOVE 5 TO WS-DX
     MOVE 58 TO WS-DY
     MOVE GS-BL(WS-SPRITE) TO WS-DW
     MOVE GS-BT(WS-SPRITE) TO WS-DH
     MOVE 0 TO WS-SX WS-SY
     COMPUTE WS-SW = GS-BL(WS-SPRITE) * GS-W(WS-SPRITE) / GS-LW(WS-SPRITE)
     COMPUTE WS-SH = GS-BT(WS-SPRITE) * GS-H(WS-SPRITE) / GS-LH(WS-SPRITE)
     MOVE "merchant the pointer over row 2: its button is the highlighted sprite" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-PART
     .

*> Stonecutter (40-4 4.9): 14 recipes from index 4, the recipe 5 selected, the pointer over the cell k = 2: visible cells k 0 to 9 are 16 x 18 sprites at (52 + 16 (k mod 4), 15 + 18 (k div 4)),
*> the selected one recipe_selected, the hovered one recipe_highlighted; over 12 recipes the scroller is the enabled sprite at (119, 15 + 41), with 5 recipes the disabled one at (119, 15).
 CHECK-STONECUTTER.
     MOVE 176 TO WS-IMG-W
     MOVE 166 TO WS-IMG-H
     PERFORM RESET-STATE
     MOVE 24 TO WS-TYPE-N
     MOVE 14 TO SC-COUNT
     MOVE 4 TO SC-START
     MOVE 5 TO BM-DATA(1)
     MOVE 1 TO BX-COUNT(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         MOVE WS-I TO SC-ITEM(WS-I)
         MOVE 1 TO SC-AMOUNT(WS-I)
     END-PERFORM
     COMPUTE IN-CURSOR-X = (72 + 52 + 16 * 2 + 5) * 2
     COMPUTE IN-CURSOR-Y = (37 + 14 + 8) * 2
     PERFORM BUILD-SCREEN
     MOVE GSP-STONE-RECIPE-SEL TO WS-SPRITE
     MOVE 68 TO WS-DX
     MOVE 15 TO WS-DY
     MOVE "stonecutter the selected recipe (cell 1): recipe_selected 16 x 18 at (68, 15)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-STONE-RECIPE-HI TO WS-SPRITE
     MOVE 84 TO WS-DX
     MOVE "stonecutter the hovered recipe (cell 2): recipe_highlighted at (84, 15)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-STONE-RECIPE TO WS-SPRITE
     MOVE 52 TO WS-DX
     MOVE "stonecutter a plain recipe (cell 0): recipe at (52, 15)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 52 TO WS-DX
     MOVE 51 TO WS-DY
     MOVE "stonecutter a plain recipe (cell 8, row 2): recipe at (52, 51)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 68 TO WS-DX
     MOVE 51 TO WS-DY
     MOVE "stonecutter a plain recipe (cell 9, row 2): recipe at (68, 51)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE 84 TO WS-DX
     MOVE 51 TO WS-DY
     MOVE "stonecutter 10 visible cells only: nothing at cell 10" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-STONE-SCROLLER TO WS-SPRITE
     MOVE 119 TO WS-DX
     MOVE 56 TO WS-DY
     MOVE "stonecutter 14 recipes at the last row: the enabled scroller at (119, 56)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE "stonecutter no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     MOVE 5 TO SC-COUNT
     MOVE 0 TO SC-START
     MOVE -1000 TO IN-CURSOR-X IN-CURSOR-Y
     PERFORM BUILD-SCREEN
     MOVE GSP-STONE-SCROLLER-OFF TO WS-SPRITE
     MOVE 119 TO WS-DX
     MOVE 15 TO WS-DY
     MOVE "stonecutter 5 recipes: the disabled scroller at (119, 15)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     .

*> Loom (40-4 3.10): empty banner, dye and pattern slots show their 16 x 16 icons at (13, 26), (33, 26), (23, 45); the thumb 12 x 15 at (119, 13) is the disabled sprite; a dye in slot 1 hides its icon.
*> Cartography table (5.7): the map frame 66 x 66 at (67, 13) without an additional item, the scaled map frame with paper, the duplicated map frame (50 x 66 at (83, 13) and (67, 29)) with an empty map,
*> the map frame and the locked icon 10 x 14 at (118, 60) with a glass pane.
 CHECK-LOOM-CARTOGRAPHY.
     MOVE 176 TO WS-IMG-W
     MOVE 166 TO WS-IMG-H
     PERFORM RESET-STATE
     MOVE 18 TO WS-TYPE-N
     MOVE 1 TO BX-COUNT(2)
     PERFORM BUILD-SCREEN
     MOVE GSP-SLOT-BANNER TO WS-SPRITE
     MOVE 13 TO WS-DX
     MOVE 26 TO WS-DY
     MOVE "loom the empty banner slot: its icon at (13, 26)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-SLOT-DYE TO WS-SPRITE
     MOVE 33 TO WS-DX
     MOVE "loom a dye in slot 1: no dye icon at (33, 26)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-SLOT-BANNER-PATTERN TO WS-SPRITE
     MOVE 23 TO WS-DX
     MOVE 45 TO WS-DY
     MOVE "loom the empty pattern slot: its icon at (23, 45)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-LOOM-SCROLLER-OFF TO WS-SPRITE
     MOVE 119 TO WS-DX
     MOVE 13 TO WS-DY
     MOVE "loom without a pattern list: the disabled scroller thumb at (119, 13)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE "loom no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     PERFORM RESET-STATE
     MOVE 23 TO WS-TYPE-N
     PERFORM BUILD-SCREEN
     MOVE GSP-CART-MAP TO WS-SPRITE
     MOVE 67 TO WS-DX
     MOVE 13 TO WS-DY
     MOVE "cartography without an additional item: the map frame 66 x 66 at (67, 13)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE "cartography no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     MOVE "paper" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE 1 TO BX-COUNT(2)
     MOVE WS-ITEM TO BX-ITEM(2)
     PERFORM BUILD-SCREEN
     MOVE GSP-CART-SCALED TO WS-SPRITE
     MOVE "cartography with paper: the scaled map frame at (67, 13)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-CART-MAP TO WS-SPRITE
     MOVE "cartography with paper: not the plain map frame" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE "map" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO BX-ITEM(2)
     PERFORM BUILD-SCREEN
     MOVE GSP-CART-DUPLICATED TO WS-SPRITE
     MOVE 83 TO WS-DX
     MOVE "cartography with an empty map: the duplicated map frame 50 x 66 at (83, 13)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE 67 TO WS-DX
     MOVE 29 TO WS-DY
     MOVE "cartography with an empty map: the second frame at (67, 29)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE "glass_pane" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO BX-ITEM(2)
     PERFORM BUILD-SCREEN
     MOVE GSP-CART-LOCKED TO WS-SPRITE
     MOVE 118 TO WS-DX
     MOVE 60 TO WS-DY
     MOVE "cartography with a glass pane: the locked icon 10 x 14 at (118, 60)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-CART-MAP TO WS-SPRITE
     MOVE 67 TO WS-DX
     MOVE 13 TO WS-DY
     MOVE "cartography with a glass pane: the map frame at (67, 13)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     .

*> Crafter (40-2 7.3): a disabled slot is the 18 x 18 disabled-slot sprite at the slot widget ((26 - 1, 17 - 1) for slot 0); the indicator 16 x 16 at (GW / 2 + 9, GH / 2 - 48) is the unpowered
*> sprite, the powered one while data 9 is 1.
 CHECK-CRAFTER.
     MOVE 176 TO WS-IMG-W
     MOVE 166 TO WS-IMG-H
     PERFORM RESET-STATE
     MOVE 7 TO WS-TYPE-N
     MOVE 1 TO BM-DATA(1)
     PERFORM BUILD-SCREEN
     MOVE GSP-CRAFTER-DISABLED TO WS-SPRITE
     MOVE 25 TO WS-DX
     MOVE 16 TO WS-DY
     MOVE "crafter a disabled slot 0: the disabled slot sprite at (25, 16)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE 43 TO WS-DX
     MOVE "crafter an enabled slot 1: no disabled sprite at (43, 16)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-CRAFTER-UNPOWERED TO WS-SPRITE
     COMPUTE WS-DX = WS-GW / 2 + 9
     COMPUTE WS-DY = WS-GH / 2 - 48
     MOVE 1 TO WS-ABS
     MOVE "crafter unpowered: the unpowered indicator at (GW / 2 + 9, GH / 2 - 48)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE "crafter no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     MOVE 1 TO BM-DATA(10)
     PERFORM BUILD-SCREEN
     MOVE GSP-CRAFTER-POWERED TO WS-SPRITE
     MOVE "crafter powered: the powered indicator" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-CRAFTER-UNPOWERED TO WS-SPRITE
     MOVE "crafter powered: not the unpowered indicator" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE 0 TO WS-ABS
     .

*> Mounts (40-6 6.2): a horse (type 103, three columns) with a saddle and a body slot and no stacks: the chest area sprite clipped to 54 x 54 at (79, 17), the two 18 x 18 frames at (7, 17)
*> and (7, 35) and the empty-slot icons (saddle at (8, 18), horse armor at (8, 36)); a llama's body icon is the llama armor, the nautilus' (type 110) the nautilus armor; a stack in a slot hides its icon.
 CHECK-MOUNTS.
     MOVE 176 TO WS-IMG-W
     MOVE 166 TO WS-IMG-H
     PERFORM RESET-STATE
     MOVE 103 TO WS-TYPE-N
     MOVE 1 TO MT-KIND MT-SADDLE MT-BODY MT-ICON
     PERFORM BUILD-SCREEN
     MOVE GSP-HORSE-CHEST TO WS-SPRITE
     MOVE 79 TO WS-DX
     MOVE 17 TO WS-DY
     MOVE 54 TO WS-DW WS-SW
     MOVE 54 TO WS-DH WS-SH
     MOVE 0 TO WS-SX WS-SY
     MOVE "mount horse with 3 columns: the chest area is the left 54 columns of the sprite at (79, 17)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-PART
     MOVE GSP-SLOT TO WS-SPRITE
     MOVE 7 TO WS-DX
     MOVE 17 TO WS-DY
     MOVE "mount horse: the saddle frame at (7, 17) (the slot widget's own well draws the same one)" TO TL-CASE
     PERFORM EXPECT-SOME
     MOVE 35 TO WS-DY
     MOVE "mount horse: the body frame at (7, 35)" TO TL-CASE
     PERFORM EXPECT-SOME
     MOVE GSP-SLOT-SADDLE TO WS-SPRITE
     MOVE 8 TO WS-DX
     MOVE 18 TO WS-DY
     MOVE "mount horse: the saddle icon at (8, 18)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-SLOT-HORSE-ARMOR TO WS-SPRITE
     MOVE 36 TO WS-DY
     MOVE "mount horse: the horse armor icon at (8, 36)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE "mount no swatch placeholder" TO TL-CASE
     PERFORM EXPECT-NO-OVERLAY
     MOVE 1 TO BX-COUNT(1)
     MOVE 2 TO MT-ICON
     PERFORM BUILD-SCREEN
     MOVE GSP-SLOT-SADDLE TO WS-SPRITE
     MOVE 18 TO WS-DY
     MOVE "mount a saddle in the slot: no saddle icon" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     MOVE GSP-SLOT-LLAMA-ARMOR TO WS-SPRITE
     MOVE 36 TO WS-DY
     MOVE "mount a llama: the llama armor icon at (8, 36)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     PERFORM RESET-STATE
     MOVE 110 TO WS-TYPE-N
     MOVE 2 TO MT-KIND
     MOVE 1 TO MT-SADDLE MT-BODY
     MOVE 3 TO MT-ICON
     PERFORM BUILD-SCREEN
     MOVE GSP-SLOT-NAUTILUS-ARMOR TO WS-SPRITE
     MOVE 8 TO WS-DX
     MOVE 36 TO WS-DY
     MOVE "mount a nautilus: the nautilus armor icon at (8, 36)" TO TL-CASE
     PERFORM EXPECT-WHOLE
     MOVE GSP-HORSE-CHEST TO WS-SPRITE
     MOVE 79 TO WS-DX
     MOVE 17 TO WS-DY
     MOVE "mount a nautilus has no chest area" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM EXPECT-WHOLE
     .
 END PROGRAM TEST-SCREEN-WIDGETS.

 COPY CLTEST.
