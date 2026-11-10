*> Edge-case test of the off-hand swap (spec edge case; core/src/menu-inventory.cob MENU-OFFHAND-SWAP; 13 §4; US19; T2918): an empty
*> hand with a full off-hand, a full hand with an empty off-hand, and both empty (nothing changes, no packet is sent).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OFFHAND-EMPTY.
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
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TEXT-2              PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-STATE-EDIT          PIC -(9)9.
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
     MOVE 0 TO PL-HELD(WS-ROW)
     MOVE 3 TO MN-EQUIP-ITEM(WS-ROW, 5)
     MOVE 2 TO MN-EQUIP-COUNT(WS-ROW, 5)
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT

     MOVE "test offhand empty an empty hand and a full off-hand: the stack moves into the hand and the "
         & "off-hand is emptied" TO TL-CASE
     PERFORM SWAP
     MOVE "packets [20(2,36=3x2) 20(2,45=0x0)] held 3x2 off 0x0 state 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test offhand empty a full hand and an empty off-hand: the stack moves into the off-hand and the "
         & "hand is emptied" TO TL-CASE
     MOVE 0 TO PL-SLOT-ITEM(WS-ROW, 1) PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 3 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO MN-EQUIP-ITEM(WS-ROW, 5) MN-EQUIP-COUNT(WS-ROW, 5)
     PERFORM SWAP
     MOVE "packets [20(3,36=0x0) 20(3,45=3x2)] held 0x0 off 3x2 state 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test offhand empty both empty: nothing changes and no packet is sent" TO TL-CASE
     MOVE 0 TO MN-EQUIP-ITEM(WS-ROW, 5) MN-EQUIP-COUNT(WS-ROW, 5)
     PERFORM SWAP
     MOVE "packets [] held 0x0 off 0x0 state 3" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 SWAP.
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-ZERO WS-ZERO WS-ZERO WS-ZERO WS-ZERO
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-TEXT-2
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO WS-EDIT
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-EDIT2
     MOVE MN-EQUIP-ITEM(WS-ROW, 5) TO WS-EDIT3
     MOVE MN-EQUIP-COUNT(WS-ROW, 5) TO WS-EDIT4
     MOVE PL-STATE-ID(WS-ROW) TO WS-STATE-EDIT
     STRING "packets [" DELIMITED BY SIZE WS-TEXT DELIMITED BY "  " "] held "
         FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2)
         " off " FUNCTION TRIM(WS-EDIT3) "x" FUNCTION TRIM(WS-EDIT4) " state "
         FUNCTION TRIM(WS-STATE-EDIT) DELIMITED BY SIZE INTO WS-TEXT-2
     MOVE WS-TEXT-2 TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-OFFHAND-EMPTY.

 COPY CORETEST.
