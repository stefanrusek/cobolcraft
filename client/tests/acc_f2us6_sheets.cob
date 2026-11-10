*> Acceptance test US6-6 (spec 002 FR-013; builtin-ui-art 4.11): the built-in pack serves the three 256 x 256 sheets
*> (inventory, crafting table, recipe book) and the client loads them into the UI atlas as GSP rows 13 to 15; a sheet widget
*> (WK-SHEET) is one quad over its rectangle on the region of the sheet from its origin: the 176 x 166 inventory panel from (0, 0), the
*> recipe-book panel from (1, 1) when the widget says so.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US6-SHEETS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 01 WS-OK                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     MOVE "acceptance US6-6 the inventory sheet is loaded 256 x 256" TO TL-CASE
     MOVE 256256 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GS-W(GSP-SHEET-INVENTORY) * 1000 + GS-H(GSP-SHEET-INVENTORY)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-6 the crafting table sheet is loaded 256 x 256" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GS-W(GSP-SHEET-BENCH) * 1000 + GS-H(GSP-SHEET-BENCH)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-6 the recipe book sheet is loaded 256 x 256" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GS-W(GSP-SHEET-BOOK) * 1000 + GS-H(GSP-SHEET-BOOK)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 2 TO CL-GUI-SCALE
     MOVE 1 TO SM-WIDGET-COUNT
     INITIALIZE SM-WIDGET(1)
     MOVE WK-SHEET TO SM-W-KIND(1)
     MOVE GSP-SHEET-INVENTORY TO SM-W-ARG(1)
     MOVE 72 TO SM-W-X(1)
     MOVE 37 TO SM-W-Y(1)
     MOVE 176 TO SM-W-W(1)
     MOVE 166 TO SM-W-H(1)
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "acceptance US6-6 an inventory sheet widget is one quad (6 vertices)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-UI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-U0 = GS-X(GSP-SHEET-INVENTORY) / UA-W
     COMPUTE WS-V0 = GS-Y(GSP-SHEET-INVENTORY) / UA-H
     COMPUTE WS-U1 = (GS-X(GSP-SHEET-INVENTORY) + 176) / UA-W
     COMPUTE WS-V1 = (GS-Y(GSP-SHEET-INVENTORY) + 166) / UA-H
     MOVE 0 TO WS-OK
     IF RL-UI-X(1) = 144 AND RL-UI-Y(1) = 74 AND RL-UI-X(3) = 496 AND RL-UI-Y(3) = 406
             AND RL-UI-U(1) > WS-U0 - 0.00001 AND RL-UI-U(1) < WS-U0 + 0.00001
             AND RL-UI-V(1) > WS-V0 - 0.00001 AND RL-UI-V(1) < WS-V0 + 0.00001
             AND RL-UI-U(3) > WS-U1 - 0.00001 AND RL-UI-U(3) < WS-U1 + 0.00001
             AND RL-UI-V(3) > WS-V1 - 0.00001 AND RL-UI-V(3) < WS-V1 + 0.00001
         MOVE 1 TO WS-OK
     END-IF
     MOVE "acceptance US6-6 the quad is window (144, 74) to (496, 406) on the sheet region (0, 0) to (176, 166)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The recipe book panel, 147 x 166, from the origin (1, 1).
     MOVE GSP-SHEET-BOOK TO SM-W-ARG(1)
     MOVE 147 TO SM-W-W(1)
     MOVE 1 TO SM-W-STATE(1)
     CALL "UI-RENDER" USING CLIENT-STATE
     COMPUTE WS-U0 = (GS-X(GSP-SHEET-BOOK) + 1) / UA-W
     COMPUTE WS-V0 = (GS-Y(GSP-SHEET-BOOK) + 1) / UA-H
     COMPUTE WS-U1 = (GS-X(GSP-SHEET-BOOK) + 148) / UA-W
     COMPUTE WS-V1 = (GS-Y(GSP-SHEET-BOOK) + 167) / UA-H
     MOVE 0 TO WS-OK
     IF RL-UI-U(1) > WS-U0 - 0.00001 AND RL-UI-U(1) < WS-U0 + 0.00001
             AND RL-UI-V(1) > WS-V0 - 0.00001 AND RL-UI-V(1) < WS-V0 + 0.00001
             AND RL-UI-U(3) > WS-U1 - 0.00001 AND RL-UI-U(3) < WS-U1 + 0.00001
             AND RL-UI-V(3) > WS-V1 - 0.00001 AND RL-UI-V(3) < WS-V1 + 0.00001
         MOVE 1 TO WS-OK
     END-IF
     MOVE "acceptance US6-6 the recipe book panel is read from (1, 1) to (148, 167) of its sheet" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An argument that is no sheet draws nothing.
     MOVE GSP-HOTBAR TO SM-W-ARG(1)
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "acceptance US6-6 a sheet widget on a row that is no sheet draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-UI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US6-SHEETS.

 COPY CLTEST.
