*> Test US12-client (spec 002; docs/protocol/40-menus-7-creative-inventory.md section 10 key use): with infinite materials and no screen open, a hotbar key with the save activator (C) down stores the nine
*> hotbar stacks as saved hotbar i and writes hotbar.nbt; with the load activator (X) down the saved stacks come back (load wins when both are down); without an activator, or with a screen open, or in
*> survival, the key selects the hotbar slot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HOTBAR-KEYS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-N                   BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-TEXT                PIC X(1100).
 01 WS-SCREEN              BINARY-LONG.
 01 WS-INFO                PIC X(16).
 01 WS-PATH                PIC X(64) VALUE "build/client-test-hotbar-keys/hotbar.nbt".
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 4 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-EX            FLOAT-SHORT.
       10 WS-EY            FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-hotbar-keys; mkdir -p build/client-test-hotbar-keys"
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "build/client-test-hotbar-keys" TO CL-GAME-DIR
     MOVE 29 TO CL-GAME-DIR-LENGTH
     MOVE 1 TO PL-MODE
     MOVE 67 TO KB-CODE(KB-SAVE-TOOLBAR)
     MOVE 88 TO KB-CODE(KB-LOAD-TOOLBAR)
     MOVE 52 TO KB-CODE(KB-HOTBAR-1 + 3)
     MOVE 5 TO PL-SLOT-ITEM(1)
     MOVE 7 TO PL-SLOT-COUNT(1)
     MOVE 0 TO PL-HELD
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1) WS-KIND(2)
     MOVE 67 TO WS-A(1)
     MOVE 52 TO WS-A(2)
     MOVE 2 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§10 C + 4 stores the hotbar stacks as saved hotbar 3 (slot 0: item 5 x 7) and keeps the selected slot" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 1000 + 7 * 10 + 0
     COMPUTE TL-OBSERVED-N = CR-HB-ITEM(28) * 1000 + CR-HB-COUNT(28) * 10 + PL-HELD
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     MOVE "acceptance US12 40-7§10 saving writes hotbar.nbt" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RETURN-CODE TO TL-OBSERVED-N
     MOVE 0 TO RETURN-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SLOT-COUNT(1)
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1) WS-KIND(2) WS-KIND(3)
     MOVE 88 TO WS-A(1)
     MOVE 67 TO WS-A(2)
     MOVE 52 TO WS-A(3)
     MOVE 3 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US12 40-7§10 X + C + 4 loads: load wins over save, slot 0 is item 5 x 7 again" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 1000 + 7
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(1) * 1000 + PL-SLOT-COUNT(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
*>   Release the activators, then the plain key selects slot 3.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-UP TO WS-KIND(1) WS-KIND(2) WS-KIND(3)
     MOVE 88 TO WS-A(1)
     MOVE 67 TO WS-A(2)
     MOVE 52 TO WS-A(3)
     MOVE 3 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "TEST-STEP" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE 52 TO WS-A(1)
     MOVE 1 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US12 40-7§10 key 4 without an activator selects hotbar slot 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-HELD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Survival: the activator does nothing special.
     MOVE 0 TO PL-HELD
     MOVE 0 TO PL-MODE
     MOVE 9 TO CR-HB-COUNT(28)
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1) WS-KIND(2)
     MOVE 67 TO WS-A(1)
     MOVE 52 TO WS-A(2)
     MOVE 2 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US12 40-7§10 in survival C + 4 selects slot 3 and stores nothing" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 100 + 9
     COMPUTE TL-OBSERVED-N = PL-HELD * 100 + CR-HB-COUNT(28)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-HOTBAR-KEYS.

 COPY CLTEST.
