*> Test of the off-hand swap (core/src/menu-inventory.cob MENU-OFFHAND-SWAP; docs/protocol/13 §4; US19-1, US19-2; T2917): the
*> Player Action SWAP_ITEM_WITH_OFFHAND (action 7) exchanges the held hotbar stack with the off-hand slot (menu slot
*> 45) and sends Container Set Slot for the held slot (menu slot 36 + hotbar index) and for slot 45 with the state id
*> raised once; a Container Click SWAP with button 40 exchanges the clicked slot with the off-hand slot and echoes both.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OFFHAND-SWAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 7.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-Z5                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TEXT-2              PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-COUNT(WS-ROW, WS-I)
     END-PERFORM
     MOVE 3 TO PL-HELD(WS-ROW)
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 4)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 4)
     MOVE 3 TO MN-EQUIP-ITEM(WS-ROW, 5)
     MOVE 2 TO MN-EQUIP-COUNT(WS-ROW, 5)
     MOVE 3 TO PL-SLOT-ITEM(WS-ROW, 10)
     MOVE 4 TO PL-SLOT-COUNT(WS-ROW, 10)
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT

     MOVE "test offhand swap Player Action 7 exchanges the held slot (hotbar 3, menu slot 39) with the "
         & "off-hand and sends Set Slot for both with the state id raised once" TO TL-CASE
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-Z1 WS-Z2 WS-Z3 WS-Z4 WS-Z5
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-TEXT-2
     MOVE PL-SLOT-ITEM(WS-ROW, 4) TO WS-EDIT
     MOVE PL-SLOT-COUNT(WS-ROW, 4) TO WS-EDIT2
     MOVE MN-EQUIP-ITEM(WS-ROW, 5) TO WS-EDIT3
     MOVE MN-EQUIP-COUNT(WS-ROW, 5) TO WS-EDIT4
     STRING FUNCTION TRIM(WS-TEXT) " | held " FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2)
         " off " FUNCTION TRIM(WS-EDIT3) "x" FUNCTION TRIM(WS-EDIT4) DELIMITED BY SIZE INTO WS-TEXT-2
     MOVE WS-TEXT-2 TO WS-TEXT
     MOVE "20(2,39=3x2) 20(2,45=2x5) | held 3x2 off 2x5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test offhand swap Container Click SWAP with button 40 on menu slot 9 exchanges it with the "
         & "off-hand and echoes both slots" TO TL-CASE
     MOVE 9 TO WS-SLOT
     MOVE 40 TO WS-BUTTON
     MOVE 2 TO WS-TYPE
     CALL "TEST-CLICK" USING WS-CONN WS-SLOT WS-BUTTON WS-TYPE
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-TEXT-2
     MOVE PL-SLOT-ITEM(WS-ROW, 10) TO WS-EDIT
     MOVE PL-SLOT-COUNT(WS-ROW, 10) TO WS-EDIT2
     MOVE MN-EQUIP-ITEM(WS-ROW, 5) TO WS-EDIT3
     MOVE MN-EQUIP-COUNT(WS-ROW, 5) TO WS-EDIT4
     STRING FUNCTION TRIM(WS-TEXT) " | slot " FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2)
         " off " FUNCTION TRIM(WS-EDIT3) "x" FUNCTION TRIM(WS-EDIT4) DELIMITED BY SIZE INTO WS-TEXT-2
     MOVE WS-TEXT-2 TO WS-TEXT
     MOVE "20(3,9=2x5) 20(3,45=3x4) | slot 2x5 off 3x4" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-OFFHAND-SWAP.

 COPY CORETEST.
