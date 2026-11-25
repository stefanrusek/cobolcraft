*> Acceptance test, lane bugbrush, client half (operator report try18: right click on suspicious sand did nothing visible): the right button pressed on a block with a brush held
*> sends Use Item On (the server starts the use of the brush, 17 section 3.5, 25 part 8 section 7) and, when the button is released, Player Action 6 release use item, which ends
*> the server's use (it otherwise lasts 200 ticks); another item at the same block sends only Use Item On and no release. The brush is item 1578 of the standard set.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGBRUSH-CONTROL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-KIND                BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BRUSH               BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "brush" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BRUSH WS-ROW WS-STATUS
*>   Survival, looking straight down at the greystone (0, 9, 0) under the feet, a brush held.
     MOVE 0 TO PL-MODE PL-HELD
     MOVE 1 TO PL-SLOT-COUNT(1)
     MOVE WS-BRUSH TO PL-SLOT-ITEM(1)
     MOVE 90 TO PL-PITCH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     MOVE 20 TO WS-MS
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance bugbrush client: given a brush held and a block aimed at when the right button is pressed then Use Item On is sent and nothing else" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "4200000000000000000901" & "3f0000003f8000003f000000" & "000001" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-EV-BUTTON-UP TO WS-KIND
     MOVE 20 TO WS-MS
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance bugbrush client: when the button is released then Player Action 6 release use item is sent, ending the brushing" TO TL-CASE
     MOVE "290600000000000000000000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance bugbrush client: a second release sends nothing" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Greystone (item 2) at the same block: only Use Item On.
     MOVE 2 TO PL-SLOT-ITEM(1)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance bugbrush client: given another item held when the button is pressed and released then no release use item is sent" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "4200000000000000000901" & "3f0000003f8000003f000000" & "000002" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGBRUSH-CONTROL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RIGHT-BUTTON.
*> USING CLIENT-STATE, event kind (CC-EV-BUTTON-DOWN or CC-EV-BUTTON-UP), milliseconds: one CL-STEP that many milliseconds after the last with that right-button event.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 FILLER              PIC X(16).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KIND                 BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-MS.
     INITIALIZE WS-EVENT
     MOVE L-KIND TO WS-KIND
     MOVE CC-BUTTON-RIGHT TO WS-A
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE L-MS
     GOBACK.
 END PROGRAM TEST-RIGHT-BUTTON.
 COPY CLTEST.
