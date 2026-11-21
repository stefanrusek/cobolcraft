*> Test of the crafting bench menu (core/src/menu-bench.cob; docs/protocol/12 §5.6b, 13 §3.5, §3.7; US10; T0402): Use Item On a
*> placed bench block opens the 3 x 3 menu (Open Screen with menu type 12, then Container Set Content of the 46 bench
*> slots, state id 1) whatever the hand holds; a recipe of five ingredients (sod_cake: four turf and a loam) matches only in
*> the bench menu's grid and not in the inventory menu's 2 x 2 grid; closing the bench returns its grid items; the
*> bench block places as an item; the bench menu's quick move sends an inventory stack into the grid first.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BENCH-MENU.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY PROTO.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 8.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 8.
 01 WS-Y1                  BINARY-LONG VALUE 71.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-BENCH-STATE         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 19.
 01 WS-TEXT                PIC X(1024).
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
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 0 TO WS-BENCH-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF CB-KEY(WS-I) = "cobolcraft:crafting_bench"
             MOVE CB-DEFAULT-STATE(WS-I) TO WS-BENCH-STATE
         END-IF
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-BENCH-STATE
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT

     MOVE "test bench menu Use Item On a placed bench with a placing item in the hand opens the menu: "
         & "Block Changed Ack, Open Screen (60), Container Set Content (18); container id 1, type 12, "
         & "state id 1; nothing is placed" TO TL-CASE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y1 WS-Z WS-STATE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE MN-WINDOW(WS-ROW) TO WS-EDIT
     MOVE MN-TYPE(WS-ROW) TO WS-EDIT2
     MOVE MN-STATE-ID(WS-ROW) TO WS-EDIT3
     MOVE WS-STATE TO WS-EDIT4
     STRING FUNCTION TRIM(TL-OBSERVED) " | window " FUNCTION TRIM(WS-EDIT) " type " FUNCTION TRIM(WS-EDIT2)
         " state " FUNCTION TRIM(WS-EDIT3) " above " FUNCTION TRIM(WS-EDIT4) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "60 18 4(1) | window 1 type 12 state 1 above 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test bench menu a recipe of five ingredients (sod_cake: four turf and a loam) in the bench grid "
         & "gives the result in slot 0" TO TL-CASE
     MOVE 4 TO WS-ITEM
     MOVE 1 TO WS-COUNT
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 4
         CALL "MENU-SET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     END-PERFORM
     MOVE 3 TO WS-ITEM
     MOVE 5 TO WS-SLOT
     CALL "MENU-SET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     CALL "MENU-CRAFT-UPDATE" USING WS-ROW
     MOVE 0 TO WS-SLOT
     CALL "MENU-GET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     MOVE SPACES TO WS-TEXT
     MOVE WS-ITEM TO WS-EDIT
     MOVE WS-COUNT TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "14x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test bench menu closing the bench (Container Close, container 1) returns the five grid items to the "
         & "inventory and makes the inventory menu the current one" TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER MN-WINDOW(WS-ROW)
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         ADD MN-BGRID-COUNT(WS-ROW, WS-I) TO WS-COUNT
     END-PERFORM
     MOVE SPACES TO WS-TEXT
     MOVE MN-WINDOW(WS-ROW) TO WS-EDIT
     MOVE WS-COUNT TO WS-EDIT2
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROW, WS-I) = 4
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-ITEM
         END-IF
     END-PERFORM
     MOVE WS-ITEM TO WS-EDIT3
     STRING "window " FUNCTION TRIM(WS-EDIT) " grid " FUNCTION TRIM(WS-EDIT2) " turf " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "window 0 grid 0 turf 68" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test bench menu the same four turf and the loam do not match in the 2x2 grid of the inventory "
         & "menu (a four-cell grid holds no five-ingredient recipe)" TO TL-CASE
     MOVE 4 TO WS-ITEM
     MOVE 1 TO WS-COUNT
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 4
         CALL "MENU-SET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     END-PERFORM
     CALL "MENU-CRAFT-UPDATE" USING WS-ROW
     MOVE 0 TO WS-SLOT
     CALL "MENU-GET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     MOVE SPACES TO WS-TEXT
     MOVE WS-ITEM TO WS-EDIT
     MOVE WS-COUNT TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test bench menu the bench block places as an item: a held bench item used on the top of "
         & "a block puts a bench block above it and uses the item up" TO TL-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-COUNT(WS-ROW, WS-I)
     END-PERFORM
     MOVE 0 TO PL-HELD(WS-ROW)
     MOVE 18 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE CB-DEFAULT-STATE(CR-GREYSTONE + 1) TO WS-STATE
     MOVE 80 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 2 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE 81 TO WS-Y
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO WS-TEXT
     IF WS-STATE = WS-BENCH-STATE
         MOVE "bench placed" TO WS-TEXT
     ELSE
         MOVE "not placed" TO WS-TEXT
     END-IF
     MOVE "bench placed" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BENCH-MENU.

 COPY CORETEST.
