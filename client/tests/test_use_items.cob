*> Implementation test of the client half of the items that the server uses with Use Item (operator report "boats, bows ... do nothing from the real window"; lane bugusein T63300;
*> docs/protocol/17 sections 3.5, 3.14, 3.16, 25 part 7 and section 6.3, 09 section 3.3 Use Item 0x43 and Player Action 6 RELEASE_USE_ITEM): with no target block, the right
*> button sends Use Item (main hand, sequence, yaw, pitch) for a boat, a raft, a firework rocket, elytra and each armor piece, and releasing it sends nothing more; for a spyglass, goat
*> horn, potion and ominous bottle it sends Use Item and the release of the button sends release use item (Player Action 6); a brush in the air sends nothing (its use is the Use Item On
*> at a block: acc_bugbrush_control); a trident, driven by USE-ITEM-INPUT, sends exactly one
*> Use Item and one release (CONTROLS-INPUT must not send a second); changing the held item while the button is down releases at once; a stone sends nothing. The bow, crossbow and
*> shield (ammo, off hand, poses) are test_use_item. The standard content set is marked open.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-USE-ITEMS.
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
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-SEQ-START           BINARY-LONG.
 01 WS-SEQ-TABLE           PIC X(40) VALUE "000102030405060708090a0b0c0d0e0f10111213".
 01 WS-USE                 PIC X(40).
 01 WS-RELEASE             PIC X(24) VALUE "290600000000000000000000".
 01 WS-STONE               BINARY-LONG.
 01 WS-SPYGLASS            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 1 TO PL-ENTITY-ID
     MOVE 0 TO PL-HELD
     MOVE 1 TO PL-SLOT-COUNT(1)
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "T" TO TL-MODE
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STONE WS-ROW WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         EVALUATE WS-I
             WHEN 1 MOVE "oak_boat" TO WS-KEY
             WHEN 2 MOVE "bamboo_raft" TO WS-KEY
             WHEN 3 MOVE "firework_rocket" TO WS-KEY
             WHEN 4 MOVE "elytra" TO WS-KEY
             WHEN 5 MOVE "iron_chestplate" TO WS-KEY
             WHEN 6 MOVE "iron_helmet" TO WS-KEY
             WHEN 7 MOVE "iron_leggings" TO WS-KEY
             WHEN 8 MOVE "iron_boots" TO WS-KEY
             WHEN 9 MOVE "trident" TO WS-KEY
             WHEN 10 MOVE "spyglass" TO WS-KEY
             WHEN 11 MOVE "goat_horn" TO WS-KEY
             WHEN 12 MOVE "potion" TO WS-KEY
             WHEN 13 MOVE "ominous_bottle" TO WS-KEY
             WHEN 14 MOVE "brush" TO WS-KEY
             WHEN 15 MOVE "stone" TO WS-KEY
             WHEN OTHER MOVE "diamond_sword" TO WS-KEY
         END-EVALUATE
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
         MOVE WS-ID TO PL-SLOT-ITEM(1)
         MOVE CC-EV-BUTTON-DOWN TO WS-KIND
         CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
         CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
         MOVE WS-TEXT TO TL-OBSERVED
         MOVE SPACES TO TL-EXPECTED TL-CASE
         IF WS-I <= 13
             ADD 1 TO WS-SEQ
             COMPUTE WS-SEQ-START = WS-SEQ * 2 + 1
             STRING "4300" WS-SEQ-TABLE(WS-SEQ-START:2) "0000000000000000" DELIMITED BY SIZE INTO TL-EXPECTED
             STRING "client use items: " FUNCTION TRIM(WS-KEY) " in hand and no target: the right button sends Use Item (main hand, yaw 0, pitch 0)"
                 DELIMITED BY SIZE INTO TL-CASE
         ELSE
             STRING "client use items: " FUNCTION TRIM(WS-KEY) " in hand and no target: the right button sends nothing"
                 DELIMITED BY SIZE INTO TL-CASE
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE CC-EV-BUTTON-UP TO WS-KIND
         CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
         CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
         MOVE WS-TEXT TO TL-OBSERVED
         MOVE SPACES TO TL-EXPECTED TL-CASE
         IF WS-I >= 9 AND WS-I <= 13
             MOVE WS-RELEASE TO TL-EXPECTED
             STRING "client use items: " FUNCTION TRIM(WS-KEY) " and the button released: release use item (Player Action 6) is sent"
                 DELIMITED BY SIZE INTO TL-CASE
         ELSE
             STRING "client use items: " FUNCTION TRIM(WS-KEY) " and the button released: nothing more is sent"
                 DELIMITED BY SIZE INTO TL-CASE
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   A spyglass raised and then put away while the button is down is released at once; the button's release afterwards sends nothing.
     MOVE "spyglass" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SPYGLASS WS-ROW WS-STATUS
     MOVE WS-SPYGLASS TO PL-SLOT-ITEM(1)
     MOVE 1 TO PL-SLOT-COUNT(1)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE WS-STONE TO PL-SLOT-ITEM(1)
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE WS-RELEASE TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "client use items: the spyglass put away while the button is down: release use item is sent at once" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "client use items: and the button's release then sends nothing" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-OPEN
     STOP RUN.
 END PROGRAM TEST-USE-ITEMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RIGHT-BUTTON.
*> USING CLIENT-STATE, event kind (CC-EV-BUTTON-DOWN or CC-EV-BUTTON-UP), milliseconds: one CL-STEP that many milliseconds after the last with that
*> right-button event.
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
