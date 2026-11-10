*> Test US12-client (spec 002 T3192 to T3199, in one file; docs/protocol/40-menus-1-model-and-containers.md sections 2.1, 5.1, 5.3, 7 to 10): the generic container screen of the
*> chest family (generic_9x1 to 9x6), shulker box, hopper and dispenser. Open Screen (0x3C) opens it with the container id, the menu type and the title; Set Container Slot
*> fills a menu slot (own slots first, then the player's main inventory 27, then the hotbar 9); the screen is leftPos = (W - 176) / 2, topPos = (H - imageHeight) / 2 with
*> imageHeight 114 + 18 rows (chest), 167 (shulker), 133 (hopper), 166 (dispenser); own slots at the tables of 7.2, 8.2, 9.2, 10.2 (the item cell; the widget is 1 pixel out);
*> the player inventory at (8 + 18 col, Y0 + 18 row) and the hotbar at Y0 + 58; the title at (8, 6) (dispenser: centred), the inventory label at (8, imageHeight - 94).
*> Container Close and Escape close it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PATH                PIC X(256).
 01 WS-PACKET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-TITLE               PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO CL-NOW-MS PL-HURT-UNTIL
     MOVE "T" TO TL-MODE

*>   2.1 and 5.3: Open Screen of the contract (container 127, generic_9x3, title "Loot").
     MOVE "contract/fixtures/wire/play-s2c-3c-open-screen-chest-with-name.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     MOVE BM-ID TO WS-E2
     MOVE BM-TYPE TO WS-E3
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
         SM-CX-TITLE(1:SM-CX-TITLE-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§2 Open Screen generic_9x3 opens the container screen (20) of container 127, type 2, title Loot" TO TL-CASE
     MOVE "20 127 2 Loot" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.2 for 3 rows at GUI 320 x 240: imageHeight 168, left 72, top 36, Y0 85. Own slot 0 at (79, 53), slot 26 at (223, 89); main slot 0 at (79, 120); hotbar 0 at (79, 178).
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 401 TO WS-ARG
     PERFORM SLOT-AT
     MOVE 427 TO WS-ARG
     PERFORM SLOT-AT
     MOVE 9 TO WS-ARG
     PERFORM SLOT-AT
     MOVE 0 TO WS-ARG
     PERFORM SLOT-AT
     MOVE 35 TO WS-ARG
     PERFORM SLOT-AT
     MOVE "acceptance US12 40-1§7 chest 3 rows: own 0 (79, 53), own 26 (223, 89), main 0 (79, 120), hotbar 0 (79, 178), main 26 (223, 156)" TO TL-CASE
     MOVE "79:53 223:89 79:120 79:178 223:156" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-I
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-ID) = WK-SLOT
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§7 the menu has 27 + 36 = 63 slot widgets" TO TL-CASE
     MOVE 63 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
*>   5.3: the title at (8, 6) and the inventory label at (8, imageHeight - 94 = 74) relative to the screen: (80, 42) and (80, 110).
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-ID) = WK-LABEL
             MOVE SM-W-X(WS-ID) TO WS-E1
             MOVE SM-W-Y(WS-ID) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "=" SM-W-TEXT(WS-ID)(1:SM-W-LENGTH(WS-ID)) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-1§5 labels: the title at (8, 6) and Inventory at (8, imageHeight - 94)" TO TL-CASE
     MOVE "80:42=Loot 80:110=Inventory" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Set Container Slot of container 127: menu slot 0 gets 63 of item 2, menu slot 27 (player main 0) gets 5 of item 3, menu slot 54 (hotbar 0) 7 of item 2.
     MOVE 127 TO WS-ID
     MOVE 0 TO WS-SLOT
     MOVE 63 TO PB-ISX-COUNT
     MOVE 2 TO PB-ISX-ITEM
     PERFORM SEND-SLOT
     MOVE 27 TO WS-SLOT
     MOVE 5 TO PB-ISX-COUNT
     MOVE 3 TO PB-ISX-ITEM
     PERFORM SEND-SLOT
     MOVE 54 TO WS-SLOT
     MOVE 7 TO PB-ISX-COUNT
     MOVE 2 TO PB-ISX-ITEM
     PERFORM SEND-SLOT
     MOVE SPACES TO TL-OBSERVED
     MOVE BX-COUNT(1) TO WS-E1
     MOVE PL-SLOT-COUNT(10) TO WS-E2
     MOVE PL-SLOT-COUNT(1) TO WS-E3
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§3 menu slot 0 is container slot 0, menu slot 27 the player's main slot 0 (inventory 9), menu slot 54 the hotbar 0" TO TL-CASE
     MOVE "63 5 7" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A slot of another container id is ignored.
     MOVE 5 TO WS-ID
     MOVE 0 TO WS-SLOT
     MOVE 1 TO PB-ISX-COUNT
     MOVE 3 TO PB-ISX-ITEM
     PERFORM SEND-SLOT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§4 a Set Container Slot of another container id changes nothing" TO TL-CASE
     MOVE 63 TO TL-EXPECTED-N
     MOVE BX-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   Container Close of 127 returns to the world.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 127 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE 17 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§4 Container Close of the open container returns to the world screen" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   The other layouts: type (id), rows, image height and Y0: 9x1 132/49, 9x6 222/139, hopper (16) 133/51, dispenser (6) 166/84, shulker (20) 167/84; the last own slot and the hotbar.
     MOVE 0 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM LAYOUT-TEXT
     MOVE "acceptance US12 40-1§7 chest 1 row (generic_9x1): 9 own slots; image 132: left 72 top 54; own 8 (223, 71); hotbar 0 (79, 54 + 107 - 1 = 160)" TO TL-CASE
     MOVE "223:71 79:160" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE "acceptance US12 40-1§7 chest 6 rows (generic_9x6): image 222, top 9: own 53 (223, 9 + 18 + 90 - 1 = 116); hotbar 0 (79, 9 + 139 + 58 - 1 = 205)" TO TL-CASE
     PERFORM LAYOUT-TEXT
     MOVE "223:116 79:205" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM LAYOUT-TEXT
     MOVE "acceptance US12 40-1§9 hopper: image 133, top 53; own 4 (72 + 44 + 72 - 1 = 187, 53 + 20 - 1 = 72); hotbar 0 (79, 53 + 109 - 1 = 161)" TO TL-CASE
     MOVE "187:72 79:161" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM LAYOUT-TEXT
     MOVE "acceptance US12 40-1§10 dispenser: 3 x 3 from (62, 17), image 166, top 37: own 8 (72 + 62 + 36 - 1 = 169, 37 + 17 + 36 - 1 = 89); hotbar 0 (79, 37 + 142 - 1 = 178)" TO TL-CASE
     MOVE "169:89 79:178" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-I
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-ID) = WK-LABEL AND SM-W-Y(WS-ID) = 43
             MOVE SM-W-X(WS-ID) TO WS-I
         END-IF
     END-PERFORM
     MOVE "Loot" TO WS-TITLE
     MOVE 4 TO WS-LENGTH
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TITLE WS-LENGTH WS-WIDTH
     COMPUTE WS-ARG = 72 + (176 - WS-WIDTH) / 2
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§10 the dispenser title is centred: x = left + (176 - title width) div 2" TO TL-CASE
     MOVE WS-ARG TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 20 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM LAYOUT-TEXT
     MOVE "acceptance US12 40-1§8 shulker box: 27 slots as the chest, image 167, top 36 (top = (240 - 167) div 2): own 26 (223, 36 + 18 + 36 - 1 = 89); hotbar 0 (79, 36 + 142 - 1 = 177)" TO TL-CASE
     MOVE "223:89 79:177" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> "x:y" of the slot widget WS-ARG, appended.
 SLOT-AT.
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-ID) = WK-SLOT AND SM-W-ARG(WS-ID) = WS-ARG
             MOVE SM-W-X(WS-ID) TO WS-E1
             MOVE SM-W-Y(WS-ID) TO WS-E2
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 SEND-SLOT.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO PB-ISX-ADDED-COUNT PB-ISX-REMOVED-COUNT
     CALL "PB-PUT-CONTAINER-SET-SLOT" USING PB-BUFFER WS-ID WS-STATE WS-SLOT PB-ITEMSTACK-X
     MOVE 20 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     .

*> Open Screen with container 9, menu type WS-TYPE and the title "Loot", then the screen built.
 OPEN-TYPE.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE 4 TO PB-TX-LENGTH
     MOVE "Loot" TO PB-TX-VALUE
     MOVE 0 TO PB-TX-ARG-COUNT
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     MOVE 60 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

*> "x:y" of the last own slot (arg 400 + WS-I + 1... the caller sets WS-I) and of the hotbar slot 0.
 LAYOUT-TEXT.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM FIND-LAST-OWN
     PERFORM SLOT-AT
     MOVE 0 TO WS-ARG
     PERFORM SLOT-AT
     .

 FIND-LAST-OWN.
     MOVE 0 TO WS-ARG
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-ID) = WK-SLOT AND SM-W-ARG(WS-ID) > 400 AND SM-W-ARG(WS-ID) > WS-ARG
             MOVE SM-W-ARG(WS-ID) TO WS-ARG
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-1.

 COPY CLTEST.
