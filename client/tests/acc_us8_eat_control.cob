*> Acceptance test of US8-3 and the US8 early-release edge case, the client half (client-surface §3
*> "Place / use / toggle glowtube / eat (hold): Right mouse button"; standin-content §11.5 food
*> items, §11.6 eating: 30 ticks; docs/protocol/09-cobolcraft-profile.md §3.3 Use Item 0x43 (hand
*> 0, sequence, yaw, pitch) and Player Action 6 RELEASE_USE_ITEM (location 0, face 0, sequence
*> 0)): pressing the right button with a food item held sends Use Item; releasing it before the
*> eating time has passed sends release use item; releasing it later, or after the server said the
*> meal was eaten (Entity Event 9), sends nothing. Without a food item held nothing is sent.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US8-EAT-CONTROL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-KIND                BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 PROCEDURE DIVISION.
*>   Survival, looking straight ahead at eye height over the flat floor (no target block); three
*>   grazer flank (item 12, standin §11.5) in the held hotbar slot 0; the player's entity id 1.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
     MOVE 0 TO PL-HELD
     MOVE 3 TO PL-SLOT-COUNT(1)
     MOVE 12 TO PL-SLOT-ITEM(1)
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     MOVE 20 TO WS-MS
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US8-3 client half: given grazer flank held when the right button is pressed "
         & "then Use Item is sent (main hand, sequence 1, yaw 0, pitch 0)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "4300010000000000000000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 31 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US8-3 client half: when the button is held for the whole eating time (30 "
         & "ticks) and released then nothing more is sent (the meal was not cut short)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     MOVE 200 TO WS-MS
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     MOVE 20 TO WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "US8 edge client half: when the right button is pressed again and released after 0.2 "
         & "seconds then Use Item (sequence 2) and Player Action 6 release use item are sent"
         TO TL-CASE
     MOVE "4300020000000000000000 290600000000000000000000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     MOVE "contract/fixtures/wire/play-s2c-22-entity-event-eating-finished.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US8-3 client half: when Entity Event 9 (eating finished) arrives for the "
         & "Player before the button is released then the release sends nothing" TO TL-CASE
     MOVE "4300030000000000000000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2 TO PL-SLOT-ITEM(1)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     MOVE 0 TO PL-SLOT-COUNT(1)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "US8-3 client half: given greystone (not food) held, then an empty hand, with no "
         & "target block when the right button is pressed and released then nothing is sent"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US8-EAT-CONTROL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RIGHT-BUTTON.
*> USING CLIENT-STATE, event kind (CC-EV-BUTTON-DOWN or CC-EV-BUTTON-UP), milliseconds: one
*> CL-STEP that many milliseconds after the last with that right-button event.
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
