*> Coverage of core/src/menu-enchant.cob: a table opened by a player whose seed was never drawn draws it (MENU-ENCH-OPEN), a creative player pressing an option with the item slot empty gets
*> no enchanting (MENU-ENCH-BUTTON), and a shift click on the empty item slot moves nothing (MENU-ENCH-QUICK).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-C-MENU-ENCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY COREAPI.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/anvil-registry".
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 3.
 01 WS-Y                   BINARY-LONG VALUE 10.
 01 WS-Z                   BINARY-LONG VALUE 3.
 01 WS-KIND                BINARY-LONG VALUE 7.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-RET                 BINARY-LONG.
 01 WS-CLICK               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-REG-STATUS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "T" TO TL-MODE

     MOVE "cove-c enchant open: a player whose seed was never drawn gets one when the table opens, and the menu holds it" TO TL-CASE
     MOVE 0 TO PL-ENCH-INIT(WS-ROW)
     MOVE 0 TO PL-ENCH-SEED(WS-ROW)
     CALL "MENU-STATION-OPEN" USING WS-CONN WS-X WS-Y WS-Z WS-KIND
     MOVE PL-ENCH-INIT(WS-ROW) TO WS-E1
     MOVE 0 TO WS-E2
     IF PL-ENCH-SEED(WS-ROW) NOT = 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE 0 TO WS-E3
     IF MN-WDATA(WS-ROW, 4) = PL-ENCH-SEED(WS-ROW)
         MOVE 1 TO WS-E3
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "init " FUNCTION TRIM(WS-E1) " drawn " FUNCTION TRIM(WS-E2) " in-menu " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "init 1 drawn 1 in-menu 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cove-c enchant button: a creative player with no item in the table presses option 1 and nothing is enchanted" TO TL-CASE
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 0 TO WS-BUTTON
     CALL "MENU-STATION-BUTTON" USING WS-ROW WS-BUTTON WS-RET
     MOVE WS-RET TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "returned " FUNCTION TRIM(WS-E1) " item " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "returned 0 item 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cove-c enchant quick move: a shift click on the empty item slot changes nothing" TO TL-CASE
     MOVE 0 TO WS-S WS-BUTTON
     MOVE 1 TO WS-CLICK
     CALL "TEST-CLICK-WIN" USING WS-CONN WS-S WS-BUTTON WS-CLICK
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-E2
     MOVE MN-CFAMILY(WS-ROW) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "slots " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " family " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "slots 0/0 family 27" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVE-C-MENU-ENCH.
 COPY CORETEST.
 COPY BETEST.
