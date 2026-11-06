*> Acceptance test of US5-3, the client half (client-surface §3 "Throw one / throw stack: Q /
*> Ctrl+Q"; standin-content §9.1 throw; docs/protocol/09-cobolcraft-profile.md §3.3 Player Action
*> 0x29 actions 5 DROP_ITEM and 4 DROP_ALL_ITEMS, location (0, 0, 0), face 0, sequence 0): on the
*> world screen Q throws one item of the held hotbar slot and Ctrl+Q the whole stack; the server
*> decides what is thrown (the client sends the action only). With nothing held nothing is sent.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US5-THROW.
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
 01 WS-KEY                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 3 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-starting-items.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-6b-set-held-slot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE CC-KEY-Q TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US5-3 client half: given 64 items in the held hotbar slot 0 when Q is "
         & "pressed then Player Action 5 drop item is sent (location 0, face 0, sequence 0)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "290500000000000000000000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-LEFT-CONTROL TO WS-A(1)
     MOVE CC-MOD-CONTROL TO WS-B(1)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-ONE
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-EV-KEY-UP TO WS-KIND(2)
     MOVE CC-KEY-Q TO WS-A(1) WS-A(2)
     MOVE CC-MOD-CONTROL TO WS-B(1) WS-B(2)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-TWO
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-UP TO WS-KIND(1)
     MOVE CC-KEY-LEFT-CONTROL TO WS-A(1)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-ONE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US5-3 client half: when Ctrl+Q is pressed then Player Action 4 drop all "
         & "items is sent" TO TL-CASE
     MOVE "290400000000000000000000" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO PL-SLOT-COUNT(PL-HELD + 1)
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US5-3 client half: given an empty held slot when Q is pressed then nothing "
         & "is sent" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US5-THROW.
 COPY CLTEST.
