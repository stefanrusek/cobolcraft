*> Acceptance test of US4-6 on the client (client-surface §3 hotbar keys 1 to 9, scroll wheel,
*> inventory screen E; 08 §10.8.6 inventory title, hotbar icons and counts; 09 §3.2 Set Carried
*> Item 0x36, Container Click 0x12, Set Creative Mode Slot 0x39): the world screen's hotbar shows the
*> nine hotbar slots with their icons and counts and the held one marked; number keys and the scroll
*> wheel choose the held slot and tell the server; E opens the inventory screen with all 36 slots;
*> clicking slots moves items (Container Click in survival, Set Creative Mode Slot in creative);
*> E closes it again.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-INVENTORY-SCREEN.
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
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   PIC Z(4)9.
 01 WS-ACTION              BINARY-LONG VALUE 15.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 FILLER              PIC X(12).
    05 WS-DX               FLOAT-SHORT.
    05 WS-DY               FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-starting-items.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-6b-set-held-slot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US4-6 given the starting inventory when the world is shown then the hotbar "
         & "shows slots 0 to 8 with their counts, slot 0 held, and an icon for each stack" TO TL-CASE
     PERFORM SLOTS-TEXT
     MOVE "9 0:64:1 1:64:0 2:64:0 3:64:0 4:64:0 5:64:0 6:64:0 7:64:0 8:1:0 icons 54"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-KEY-4 TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO TL-OBSERVED
     INITIALIZE WS-EVENT
     MOVE CC-EV-SCROLL TO WS-KIND
     MOVE -1 TO WS-DY
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE CC-KEY-1 TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 1 TO WS-DY
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE PL-HELD TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " held " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "acceptance US4-6 given the world shown when 4 is pressed, the wheel scrolls down, 1 is "
         & "pressed and the wheel scrolls up then the held slot becomes 3, 4, 0 and 8 (wrapping), "
         & "each sent as Set Carried Item" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "360003 360004 360000 360008 held 8" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US4-6 given the starting inventory when E is pressed then the inventory "
         & "screen shows its title and all 36 slots with their counts, an icon for each of the 10 "
         & "stacks" TO TL-CASE
     PERFORM SLOTS-TEXT
     MOVE TL-OBSERVED(1:40) TO WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E
     STRING "screen " FUNCTION TRIM(WS-E) " " WS-TEXT(1:2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL
             STRING FUNCTION TRIM(TL-OBSERVED) " " SM-W-TEXT(WS-I)(1:9) DELIMITED BY SIZE
                 INTO TL-OBSERVED
         END-IF
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) >= 8 AND SM-W-ARG(WS-I) <= 10
             MOVE SM-W-ARG(WS-I) TO WS-E
             STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) ":" DELIMITED BY SIZE
                 INTO TL-OBSERVED
             MOVE SM-W-LENGTH(WS-I) TO WS-N
             IF WS-N > 0
                 STRING FUNCTION TRIM(TL-OBSERVED) SM-W-TEXT(WS-I)(1:WS-N) DELIMITED BY SIZE
                     INTO TL-OBSERVED
             END-IF
         END-IF
     END-PERFORM
     MOVE RL-IC-COUNT TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " icons " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "screen 6 36 Inventory 8:1 9:1 10: icons 60" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM SLOT-CURSOR-TEXT
     MOVE 10 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     PERFORM SLOT-CURSOR-TEXT
     MOVE "acceptance US4-6 given survival when slot 0 and then the empty slot 10 are clicked then "
         & "the 64 greystone go to the cursor and then into slot 10, each click sent as Container "
         & "Click with the changed slot and the cursor" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "12000100000000010000000102400000 0x0/64x2 120001000a000001000a010240000000 64x2/0x0"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO PL-MODE
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = 36
             MOVE SM-W-LENGTH(WS-I) TO WS-N
             STRING FUNCTION TRIM(TL-OBSERVED) " cursor " SM-W-TEXT(WS-I)(1:WS-N)
                 DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     MOVE "acceptance US4-6 given creative when slot 10 is clicked then the stack goes to the "
         & "cursor (shown at the pointer with its count) and the server is sent Set Creative Mode "
         & "Slot of the emptied slot" TO TL-CASE
     MOVE "39000a00 cursor 64" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US4-6 given the inventory screen when E is pressed then the world is shown "
         & "again" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE SM-SCREEN TO WS-N
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US4-6 given the inventory screen opened with E when Escape is pressed then "
         & "the world is shown again" TO TL-CASE
     COMPUTE TL-EXPECTED-N = SCR-INVENTORY * 100 + SCR-WORLD
     COMPUTE TL-OBSERVED-N = WS-N * 100 + SM-SCREEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SLOTS-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND WS-N = 9
             MOVE SM-W-ARG(WS-I) TO WS-E
             STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) ":" DELIMITED BY SIZE
                 INTO TL-OBSERVED
             MOVE SM-W-LENGTH(WS-I) TO WS-ARG
             IF WS-ARG > 0
                 STRING FUNCTION TRIM(TL-OBSERVED) SM-W-TEXT(WS-I)(1:WS-ARG) DELIMITED BY SIZE
                     INTO TL-OBSERVED
             END-IF
             MOVE SM-W-STATE(WS-I) TO WS-E
             STRING FUNCTION TRIM(TL-OBSERVED) ":" FUNCTION TRIM(WS-E) DELIMITED BY SIZE
                 INTO TL-OBSERVED
         END-IF
     END-PERFORM
     IF WS-N = 9
         MOVE RL-IC-COUNT TO WS-E
         STRING FUNCTION TRIM(TL-OBSERVED) " icons " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-IF.

 SLOT-CURSOR-TEXT.
     MOVE PL-SLOT-COUNT(WS-ARG + 1) TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) "x" DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE PL-SLOT-ITEM(WS-ARG + 1) TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-E) "/" DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE PL-CARRIED-COUNT TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-E) "x" DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE PL-CARRIED-ITEM TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM ACC-US4-INVENTORY-SCREEN.
 COPY CLTEST.
