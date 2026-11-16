*> Acceptance test, the villager's merchant window through the real play path (docs/protocol/40-menus-5 section 2, 19 sections 22.4 and 22.7; lane 002-lane-mobsb, T7102): a
*> right click on a villager with a profession opens menu type 19 (3 own slots) and sends Merchant Offers; Select Trade fills the payment slots from the inventory and
*> sets the result; taking the result uses the payment up, counts the use and the villager's xp; an out of stock offer gives no result; a villager that is too far or gone
*> closes the window; a villager without profession opens nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-MERCHANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY COREAPI.
 COPY VILSTATE.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PAPER               BINARY-LONG.
 01 WS-EMERALD             BINARY-LONG.
 01 WS-VROW                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-LIB                 PIC X(16) VALUE "librarian".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-F1                 BINARY-LONG.
 01 WS-F2                 BINARY-LONG.
 01 WS-F3                 BINARY-LONG.
 01 WS-E1                 PIC -(9)9.
 01 WS-E2                 PIC -(9)9.
 01 WS-E3                 PIC -(9)9.
 01 WS-OUT                PIC X(40).
 01 WS-IDS                 PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "paper" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-PAPER
     MOVE "emerald" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-EMERALD
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-VROW
     CALL "VL-FIND" USING EN-ID(WS-VROW) WS-ONE WS-SLOT
     MOVE "T" TO TL-MODE
*>   Without a profession nothing opens.
     CALL "MERCHANT-INTERACT" USING WS-ROW WS-VROW WS-USED
     MOVE "acceptance US15 19§22.4 a villager without a profession opens no window" TO TL-CASE
     MOVE "0 0 0" TO TL-EXPECTED
     MOVE MN-WINDOW(WS-ROW) TO WS-F1
     MOVE WS-USED TO WS-F2
     MOVE 0 TO WS-F3
     PERFORM FORMAT-3
     MOVE WS-OUT TO TL-OBSERVED
     PERFORM CHECK
*>   A librarian: its first level 1 trade is 24 paper for 1 emerald (max uses 16, xp 2).
     MOVE "librarian" TO VL-PROF(WS-SLOT)
     CALL "VIL-TRADE-SET" USING WS-LIB WS-ONE WS-FIRST WS-N WS-PICK
     MOVE 1 TO VL-O-N(WS-SLOT) VL-BUILT(WS-SLOT)
     MOVE WS-FIRST TO VL-O-ROW(WS-SLOT, 1)
     MOVE 0 TO VL-O-USES(WS-SLOT, 1) VL-O-DEMAND(WS-SLOT, 1) VL-O-SPECIAL(WS-SLOT, 1) VL-O-EXTRA(WS-SLOT, 1)
     MOVE WS-PAPER TO PL-SLOT-ITEM(WS-ROW, 10)
     MOVE 30 TO PL-SLOT-COUNT(WS-ROW, 10)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "MERCHANT-INTERACT" USING WS-ROW WS-VROW WS-USED
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 40§2.1 the window opens: type 19, 3 own slots, used" TO TL-CASE
     MOVE "19 3 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE MN-TYPE(WS-ROW) TO WS-F1
     MOVE MN-CSIZE(WS-ROW) TO WS-F2
     MOVE WS-USED TO WS-F3
     PERFORM FORMAT-3
     MOVE WS-OUT TO TL-OBSERVED
     PERFORM CHECK
     MOVE "acceptance US15 40§2.1 Open Screen (60) is sent first and Merchant Offers (53) follows" TO TL-CASE
     MOVE 0 TO WS-N
     INSPECT WS-IDS TALLYING WS-N FOR ALL " 53"
     MOVE "60 1" TO TL-EXPECTED
     MOVE WS-IDS(1:2) TO WS-OUT
     IF WS-N > 0
         MOVE "1" TO WS-OUT(4:1)
     END-IF
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-OUT(1:2) TO TL-OBSERVED(1:2)
     MOVE " " TO TL-OBSERVED(3:1)
     MOVE WS-OUT(4:1) TO TL-OBSERVED(4:1)
     PERFORM CHECK
     MOVE 0 TO WS-INDEX
     CALL "MERCHANT-SELECT" USING WS-CONN WS-INDEX
     MOVE "acceptance US15 40§2.7 Select Trade moves 24 paper into the first payment slot" TO TL-CASE
     MOVE "24 6 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-F1
     MOVE PL-SLOT-COUNT(WS-ROW, 10) TO WS-F2
     MOVE 0 TO WS-F3
     PERFORM FORMAT-3
     MOVE WS-OUT TO TL-OBSERVED
     PERFORM CHECK
     MOVE "acceptance US15 40§2.4 the result is 1 emerald" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-EMERALD TO WS-F1
     MOVE 1 TO WS-F2
     MOVE 0 TO WS-F3
     PERFORM FORMAT-3
     MOVE WS-OUT TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE MN-RESULT-ITEM(WS-ROW) TO WS-F1
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-F2
     MOVE 0 TO WS-F3
     PERFORM FORMAT-3
     MOVE WS-OUT TO TL-OBSERVED
     PERFORM CHECK
     CALL "MENU-STATION-TAKEN" USING WS-ROW
     MOVE "acceptance US15 40§2.5 taking the result uses the payment: 0 paper left, 1 use, 2 xp" TO TL-CASE
     MOVE "0 1 2" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO WS-F1
     MOVE VL-O-USES(WS-SLOT, 1) TO WS-F2
     MOVE VL-XP(WS-SLOT) TO WS-F3
     PERFORM FORMAT-3
     MOVE WS-OUT TO TL-OBSERVED
     PERFORM CHECK
*>   Out of stock: no result.
     MOVE 16 TO VL-O-USES(WS-SLOT, 1)
     CALL "MERCHANT-SELECT" USING WS-CONN WS-INDEX
     MOVE "acceptance US15 40§2.4 an offer out of stock gives no result" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
*>   Validity: within 4 blocks it holds, far away it does not.
     CALL "MERCHANT-VALID" USING WS-ROW WS-VALID
     MOVE "acceptance US15 40§2.9 the villager is within 4 blocks: valid" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE WS-VALID TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
     ADD 10 TO EN-X(WS-VROW)
     CALL "MERCHANT-VALID" USING WS-ROW WS-VALID
     MOVE "acceptance US15 40§2.9 10 blocks away: not valid" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE WS-VALID TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
     STOP RUN.

 FORMAT-3.
     MOVE WS-F1 TO WS-E1
     MOVE WS-F2 TO WS-E2
     MOVE WS-F3 TO WS-E3
     MOVE SPACES TO WS-OUT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-OUT.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-MERCHANT.
 COPY CORETEST.
 COPY BETEST.
