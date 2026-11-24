*> Implementation test of the client half of the thrown items (operator report of try15 to try19: "I still can't throw Eyes of Ender"; docs/protocol/25 section 6.3, 09
*> section 3.3 Use Item 0x43; lane bugeye T62900): with an ender eye, ender pearl, egg, snowball, splash potion, lingering potion or fishing rod in the held slot the right
*> button sends Use Item (main hand, sequence, yaw, pitch) even with no target block, as the server throws the item (THROWN-ITEM-USE) itself; a stone in hand sends nothing;
*> releasing the button sends nothing more. The standard content set is marked open so that the item ids are the standard ones.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-THROWN-USE.
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
 01 WS-SEQ                 PIC 9.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         EVALUATE WS-I
             WHEN 1 MOVE "ender_eye" TO WS-KEY
             WHEN 2 MOVE "ender_pearl" TO WS-KEY
             WHEN 3 MOVE "egg" TO WS-KEY
             WHEN 4 MOVE "snowball" TO WS-KEY
             WHEN 5 MOVE "splash_potion" TO WS-KEY
             WHEN 6 MOVE "lingering_potion" TO WS-KEY
             WHEN 7 MOVE "fishing_rod" TO WS-KEY
             WHEN OTHER MOVE "stone" TO WS-KEY
         END-EVALUATE
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
         MOVE WS-ID TO PL-SLOT-ITEM(1)
         MOVE CC-EV-BUTTON-DOWN TO WS-KIND
         CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
         MOVE CC-EV-BUTTON-UP TO WS-KIND
         CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-KIND WS-MS
         CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
         MOVE WS-TEXT TO TL-OBSERVED
         IF WS-I < 8
             MOVE SPACES TO TL-CASE
             STRING "client thrown items: " FUNCTION TRIM(WS-KEY) " in hand and no target: the right button sends Use Item (main hand, yaw 0, pitch 0) and the release nothing"
                 DELIMITED BY SIZE INTO TL-CASE
             MOVE WS-I TO WS-SEQ
             MOVE SPACES TO TL-EXPECTED
             STRING "43000" WS-SEQ "0000000000000000" DELIMITED BY SIZE INTO TL-EXPECTED
         ELSE
             MOVE "client thrown items: a stone in hand and no target: the right button sends nothing" TO TL-CASE
             MOVE SPACES TO TL-EXPECTED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 0 TO CT-OPEN
     STOP RUN.
 END PROGRAM TEST-THROWN-USE.

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
