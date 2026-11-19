*> Lane bugscreenart (T60100 and on; operator try17: "only the inventory is rendering the full UI, the others just render stuff on top of a black box"): every container
*> screen of the real generated vanilla pack (CC_GENERATED_DIR) draws its own background sheet (docs/protocol/40-menus-*: textures/gui/container/<name>.png, a 256 x 256 sheet
*> (the merchant's 512 x 256), the region (0, 0, image width, image height) blitted at (leftPos, topPos); the chest sheet in two blits, 40-1 7.5) through the real SCREEN-BUILD and
*> UI-RENDER, not the dark translucent panel swatch. Each type: the sheet quad is at the screen position with the sheet region's texture coordinates, no swatch quad of the panel
*> covers the image, and every slot widget of the sheet's wells sits exactly on a well of the sheet (the sheet's interior grey under the cell's corners, the well's dark top-left and
*> light bottom-right edge on its sides). Skipped (no cases) when the pack has no container sheets. The sheet rows of the atlas are GSP-SHEET-0 + index - 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONTAINER-SHEETS.
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
*> type (3 digits), sheet index (2), image width (3), height (3).
 01 WS-TYPES.
    05 FILLER PIC X(11) VALUE "00001176132".
    05 FILLER PIC X(11) VALUE "00101176150".
    05 FILLER PIC X(11) VALUE "00201176168".
    05 FILLER PIC X(11) VALUE "00301176186".
    05 FILLER PIC X(11) VALUE "00401176204".
    05 FILLER PIC X(11) VALUE "00501176222".
    05 FILLER PIC X(11) VALUE "00604176166".
    05 FILLER PIC X(11) VALUE "00709176166".
    05 FILLER PIC X(11) VALUE "00810176166".
    05 FILLER PIC X(11) VALUE "00918230219".
    05 FILLER PIC X(11) VALUE "01006176166".
    05 FILLER PIC X(11) VALUE "01108176166".
    05 FILLER PIC X(11) VALUE "01313176166".
    05 FILLER PIC X(11) VALUE "01405176166".
    05 FILLER PIC X(11) VALUE "01511176166".
    05 FILLER PIC X(11) VALUE "01603176133".
    05 FILLER PIC X(11) VALUE "01814176166".
    05 FILLER PIC X(11) VALUE "01917276166".
    05 FILLER PIC X(11) VALUE "02002176167".
    05 FILLER PIC X(11) VALUE "02112176166".
    05 FILLER PIC X(11) VALUE "02207176166".
    05 FILLER PIC X(11) VALUE "02316176166".
    05 FILLER PIC X(11) VALUE "02415176166".
    05 FILLER PIC X(11) VALUE "10019176166".
    05 FILLER PIC X(11) VALUE "10119176166".
    05 FILLER PIC X(11) VALUE "10219176166".
    05 FILLER PIC X(11) VALUE "10319176166".
    05 FILLER PIC X(11) VALUE "10419176166".
    05 FILLER PIC X(11) VALUE "10519176166".
    05 FILLER PIC X(11) VALUE "11020176166".
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-ROW OCCURS 30 TIMES.
       10 WS-T-TYPE        PIC 999.
       10 WS-T-SHEET       PIC 99.
       10 WS-T-W           PIC 999.
       10 WS-T-H           PIC 999.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V3                  BINARY-LONG.
 01 WS-ROWNO               BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-EX0                 FLOAT-LONG.
 01 WS-EY0                 FLOAT-LONG.
 01 WS-EX1                 FLOAT-LONG.
 01 WS-EY1                 FLOAT-LONG.
 01 WS-EU0                 FLOAT-LONG.
 01 WS-EV0                 FLOAT-LONG.
 01 WS-EU1                 FLOAT-LONG.
 01 WS-EV1                 FLOAT-LONG.
 01 WS-SRC-Y               BINARY-LONG.
 01 WS-DST-Y               BINARY-LONG.
 01 WS-SRC-H               BINARY-LONG.
 01 WS-DST-H               BINARY-LONG.
 01 WS-SRC-V               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PANEL               BINARY-LONG.
 01 WS-PU                  FLOAT-LONG.
 01 WS-PV                  FLOAT-LONG.
 01 WS-AREA                FLOAT-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-GREY                BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-BARE                BINARY-LONG.
 01 WS-CASE-TYPE           PIC 999.
 01 WS-BASED-LEN           BINARY-LONG.
 01 B-ATLAS                PIC X(1073741824) BASED.
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
         DISPLAY "test_container_sheets: no container sheets in " FUNCTION TRIM(WS-ROOT) ", skipped"
         STOP RUN
     END-IF
     MOVE "N" TO TL-MODE
     MOVE "container sheets the pack's 20 sheets are loaded into the atlas (rows GSP-SHEET-0 on)" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM GSP-SHEET-0 BY 1 UNTIL WS-I > GSP-SHEET-LAST
         IF GS-W(WS-I) = 0 OR GS-H(WS-I) NOT = 256
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
     SET ADDRESS OF B-ATLAS TO UA-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         PERFORM CHECK-TYPE
     END-PERFORM
     STOP RUN.

 CHECK-TYPE.
     MOVE WS-T-TYPE(WS-I) TO BM-TYPE WS-CASE-TYPE
     MOVE SCR-CONTAINER TO SM-SCREEN
     MOVE "Chest" TO SM-CX-TITLE
     MOVE 5 TO SM-CX-TITLE-LENGTH
     MOVE 1 TO BM-ID BM-STATE-ID
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "UI-RENDER" USING CLIENT-STATE
     COMPUTE WS-GW = IN-WIN-W / CL-GUI-SCALE
     COMPUTE WS-GH = IN-WIN-H / CL-GUI-SCALE
     COMPUTE WS-LEFT = (WS-GW - WS-T-W(WS-I)) / 2
     COMPUTE WS-TOP = (WS-GH - WS-T-H(WS-I)) / 2
     COMPUTE WS-ROWNO = GSP-SHEET-0 + WS-T-SHEET(WS-I) - 1
     COMPUTE WS-F = GS-H(WS-ROWNO) / 256
*>   The blits: the chest sheet's top part (18 R + 17 rows from v 0) and bottom part (96 rows from v 126, below it); one blit of the whole image for the others.
     MOVE 0 TO WS-SRC-Y WS-DST-Y
     MOVE WS-T-H(WS-I) TO WS-SRC-H WS-DST-H
     IF WS-T-TYPE(WS-I) <= 5
         COMPUTE WS-SRC-H = 18 * (WS-T-TYPE(WS-I) + 1) + 17
         MOVE WS-SRC-H TO WS-DST-H
     END-IF
     PERFORM FIND-BLIT
     MOVE SPACES TO TL-CASE
     STRING "container sheets the sheet region is blitted at the screen position with its texture coordinates, type " WS-CASE-TYPE DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-T-TYPE(WS-I) <= 5
         COMPUTE WS-DST-Y = WS-SRC-H
         MOVE 126 TO WS-SRC-Y
         MOVE 96 TO WS-SRC-H WS-DST-H
         PERFORM FIND-BLIT
         MOVE SPACES TO TL-CASE
         STRING "container sheets the chest sheet's lower blit is (0, 126) 176 x 96 below the upper one, type " WS-CASE-TYPE
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-FOUND TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF
*>   No quad of the dark panel swatch is as large as the image.
     COMPUTE WS-PU = (SW-PANEL * 8 + 4) / UA-W
     COMPUTE WS-PV = (UA-H - 4) / UA-H
     MOVE 0 TO WS-PANEL
     PERFORM VARYING WS-Q FROM 0 BY 1 UNTIL WS-Q * 6 + 6 > RL-UI-COUNT
         COMPUTE WS-V1 = WS-Q * 6 + 1
         COMPUTE WS-V3 = WS-Q * 6 + 3
         COMPUTE WS-AREA = (RL-UI-X(WS-V3) - RL-UI-X(WS-V1)) * (RL-UI-Y(WS-V3) - RL-UI-Y(WS-V1))
         IF WS-AREA > 40000 AND RL-UI-U(WS-V1) > WS-PU - 0.00001 AND RL-UI-U(WS-V1) < WS-PU + 0.00001
                 AND RL-UI-V(WS-V1) > WS-PV - 0.00001 AND RL-UI-V(WS-V1) < WS-PV + 0.00001
             ADD 1 TO WS-PANEL
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "container sheets no panel swatch covers the image, type " WS-CASE-TYPE DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PANEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Every slot widget of the menu is a bare one on a well of the sheet (the sheets carry the wells; the mounts' own slots draw their well sprite instead).
     MOVE 0 TO WS-SLOTS WS-BAD WS-BARE
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-Q) = WK-SLOT AND SM-W-ARG(WS-Q) NOT = 36 AND NOT (SM-W-ARG(WS-Q) >= 401 AND BM-TYPE >= 100)
             ADD 1 TO WS-SLOTS
             IF SM-W-STATE(WS-Q) = 3
                 ADD 1 TO WS-BARE
             END-IF
             PERFORM CHECK-WELL
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "container sheets every slot of the sheet is a bare widget, type " WS-CASE-TYPE DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-SLOTS TO TL-EXPECTED-N
     MOVE WS-BARE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "container sheets every slot widget sits on a well of the sheet, type " WS-CASE-TYPE DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> The quad at the destination (left, top + WS-DST-Y) of WS-W x WS-DST-H over the sheet from (0, WS-SRC-Y) of the same size: window coordinates are 2 x the GUI's.
 FIND-BLIT.
     COMPUTE WS-EX0 = WS-LEFT * CL-GUI-SCALE
     COMPUTE WS-EY0 = (WS-TOP + WS-DST-Y) * CL-GUI-SCALE
     COMPUTE WS-EX1 = (WS-LEFT + WS-T-W(WS-I)) * CL-GUI-SCALE
     COMPUTE WS-EY1 = (WS-TOP + WS-DST-Y + WS-DST-H) * CL-GUI-SCALE
     COMPUTE WS-EU0 = GS-X(WS-ROWNO) / UA-W
     COMPUTE WS-EV0 = (GS-Y(WS-ROWNO) + WS-SRC-Y * WS-F) / UA-H
     COMPUTE WS-EU1 = (GS-X(WS-ROWNO) + WS-T-W(WS-I) * WS-F) / UA-W
     COMPUTE WS-EV1 = (GS-Y(WS-ROWNO) + (WS-SRC-Y + WS-SRC-H) * WS-F) / UA-H
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

*> A slot widget (18 x 18, 1 pixel out of its item cell) of widget WS-Q: its position in the image, then in the sheet (the chest sheet's lower part is 126 - (18 R + 17)
*> rows further up), must have the well's interior grey (#8B8B8B) at its corner pixels (1, 1) and (16, 16), the well's dark top-left edge (#373737) at (8, 0) and (0, 8) and its
*> light bottom-right edge (#FFFFFF) at (8, 17) and (17, 8): the 18 x 18 well of a standard slot. A result slot's larger well (furnace family, crafter) has only the interior test.
 CHECK-WELL.
     COMPUTE WS-SX = SM-W-X(WS-Q) - WS-LEFT
     COMPUTE WS-SY = SM-W-Y(WS-Q) - WS-TOP
     IF WS-T-TYPE(WS-I) <= 5 AND WS-SY >= 18 * (WS-T-TYPE(WS-I) + 1) + 17
         COMPUTE WS-SY = WS-SY - (18 * (WS-T-TYPE(WS-I) + 1) + 17) + 126
     END-IF
     MOVE 1 TO WS-PX
     MOVE 1 TO WS-PY
     PERFORM PIXEL-GREY
     IF WS-GREY NOT = 139
         ADD 1 TO WS-BAD
         DISPLAY "  type " WS-CASE-TYPE " slot arg " SM-W-ARG(WS-Q) " at " WS-SX "," WS-SY ": corner (1,1) grey " WS-GREY
     END-IF
     MOVE 16 TO WS-PX
     MOVE 16 TO WS-PY
     PERFORM PIXEL-GREY
     IF WS-GREY NOT = 139
         ADD 1 TO WS-BAD
         DISPLAY "  type " WS-CASE-TYPE " slot arg " SM-W-ARG(WS-Q) " at " WS-SX "," WS-SY ": corner (16,16) grey " WS-GREY
     END-IF
     MOVE 8 TO WS-PX
     MOVE 0 TO WS-PY
     PERFORM PIXEL-GREY
     IF WS-GREY NOT = 55 AND NOT (WS-T-SHEET(WS-I) >= 5 AND WS-T-SHEET(WS-I) <= 9 AND WS-GREY = 139)
         ADD 1 TO WS-BAD
         DISPLAY "  type " WS-CASE-TYPE " slot arg " SM-W-ARG(WS-Q) " at " WS-SX "," WS-SY ": top edge grey " WS-GREY
     END-IF
     MOVE 0 TO WS-PX
     MOVE 8 TO WS-PY
     PERFORM PIXEL-GREY
     IF WS-GREY NOT = 55 AND NOT (WS-T-SHEET(WS-I) >= 5 AND WS-T-SHEET(WS-I) <= 9 AND WS-GREY = 139)
         ADD 1 TO WS-BAD
         DISPLAY "  type " WS-CASE-TYPE " slot arg " SM-W-ARG(WS-Q) " at " WS-SX "," WS-SY ": left edge grey " WS-GREY
     END-IF
     .

*> The red byte of the sheet's pixel (WS-SX + WS-PX, WS-SY + WS-PY) in the atlas (a grey is the same in the three), in WS-GREY.
 PIXEL-GREY.
     COMPUTE WS-W = ((GS-Y(WS-ROWNO) + (WS-SY + WS-PY) * GS-H(WS-ROWNO) / 256) * UA-W
         + GS-X(WS-ROWNO) + (WS-SX + WS-PX) * GS-H(WS-ROWNO) / 256) * 4 + 1
     COMPUTE WS-GREY = FUNCTION ORD(B-ATLAS(WS-W:1)) - 1
     .
 END PROGRAM TEST-CONTAINER-SHEETS.

 COPY CLTEST.
