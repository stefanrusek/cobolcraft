*> Test US12-client (spec 002; docs/protocol/40-menus-7-creative-inventory.md 11.9, 11.10 and 10 for the key handling): the operator tab (tab 13, op_blocks) is displayed only for a creative player with game
*> master permission (the bottom row then has 7 tabs), is hidden without it, and its members need the permission as well (the stand-in item table has no operator item, so the plain list is empty there).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CREATIVE-OP-TAB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-TAB                 BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BODY                PIC X(8).
 01 WS-BLEN                BINARY-LONG VALUE 1.
 01 WS-PACKET-ID           BINARY-LONG VALUE 14.
 01 WS-STATUS              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 13 TO WS-TAB
     MOVE 1 TO PL-MODE
     MOVE 0 TO PL-PERM
     CALL "CREATIVE-TAB-SHOWN" USING CLIENT-STATE WS-TAB WS-SHOWN
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§11 11.9 without game master permission the operator tab is not displayed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHOWN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PL-PERM
     CALL "CREATIVE-TAB-SHOWN" USING CLIENT-STATE WS-TAB WS-SHOWN
     MOVE "acceptance US12 40-7§11 11.9 with creative and level 2 the operator tab is displayed (7 bottom tabs)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SHOWN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE
     CALL "CREATIVE-TAB-SHOWN" USING CLIENT-STATE WS-TAB WS-SHOWN
     MOVE "acceptance US12 40-7§11 11.9 outside creative (no infinite materials) the operator tab is not displayed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHOWN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-MODE
     CALL "CL-ITEM-COUNT-NOW" USING WS-COUNT
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-COUNT
         CALL "CREATIVE-MEMBER" USING CLIENT-STATE WS-TAB WS-I WS-MEMBER
         ADD WS-MEMBER TO TL-OBSERVED-N
     END-PERFORM
     MOVE "acceptance US12 40-7§11 11.9 the stand-in item table has no operator item: the plain list of the tab is empty" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With the standard content set the plain list holds the operator items (command_block among them) for a permitted player and nothing without.
     MOVE X"00" TO WS-BODY(1:1)
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BLEN WS-STATUS
     CALL "CL-ITEM-COUNT-NOW" USING WS-COUNT
     MOVE 2 TO PL-PERM
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-COUNT
         CALL "CREATIVE-MEMBER" USING CLIENT-STATE WS-TAB WS-I WS-MEMBER
         ADD WS-MEMBER TO TL-OBSERVED-N
     END-PERFORM
     MOVE "acceptance US12 40-7§11 11.9 with the standard set and permission the operator tab's plain list holds items (command block, jigsaw, barrier, ...): at least 5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF TL-OBSERVED-N >= 5
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.
 END PROGRAM TEST-CREATIVE-OP-TAB.

 COPY CLTEST.
