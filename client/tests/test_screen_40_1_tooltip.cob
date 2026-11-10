*> Test US12-client (spec 002, deferred part of T3200 to T3215 "item tooltip layer for slot hover", docs/protocol/40-menus-1-model-and-containers.md section 5.6): on a container screen
*> (the anvil, GUI 320 x 240, left 72 top 37) the pointer over a slot with an item and an empty carried stack sets a tooltip at the pointer (title spacing on: an item tooltip) whose first
*> line is the item's name; an empty slot, or a carried stack, gives none; the player's slots work the same.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-1-TOOLTIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PACKET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 8.
 01 WS-ITEM                BINARY-LONG.
 01 WS-NAME                PIC X(512).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 2 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.

 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
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
     MOVE 1 TO BM-STATE-ID
     MOVE 1 TO BX-COUNT(1)
     MOVE 2 TO BX-ITEM(1)
     MOVE 0 TO PL-CARRIED-COUNT
*>   The pointer over the anvil's left slot (GUI (100, 85)).
     MOVE 100 TO WS-D1
     MOVE 85 TO WS-D2
     PERFORM POINT
     MOVE 2 TO WS-ITEM
     CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-ITEM WS-NAME WS-NAME-LENGTH
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-1§5.6 a slot with an item under the pointer gives a tooltip: its name, at the pointer, with title spacing" TO TL-CASE
     PERFORM TIP
     MOVE SPACES TO TL-EXPECTED
     STRING "1 100:85 gap 1 " WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An empty slot (the right one, GUI (149, 85)).
     MOVE 149 TO WS-D1
     PERFORM POINT
     MOVE "acceptance US12 40-1§5.6 an empty slot gives no tooltip" TO TL-CASE
     PERFORM TIP
     MOVE "0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A carried stack: no tooltip over the item.
     MOVE 100 TO WS-D1
     MOVE 1 TO PL-CARRIED-COUNT
     MOVE 3 TO PL-CARRIED-ITEM
     PERFORM POINT
     MOVE "acceptance US12 40-1§5.6 with a carried stack the item under the pointer gives no tooltip" TO TL-CASE
     PERFORM TIP
     MOVE "0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The player's first main inventory slot (inventory slot 9) at GUI (81, 122).
     MOVE 0 TO PL-CARRIED-COUNT
     MOVE 1 TO PL-SLOT-COUNT(10)
     MOVE 3 TO PL-SLOT-ITEM(10)
     MOVE 81 TO WS-D1
     MOVE 122 TO WS-D2
     PERFORM POINT
     MOVE 3 TO WS-ITEM
     CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-ITEM WS-NAME WS-NAME-LENGTH
     MOVE "acceptance US12 40-1§5.6 a player inventory slot with an item gives its name too" TO TL-CASE
     PERFORM TIP
     MOVE SPACES TO TL-EXPECTED
     STRING "1 81:122 gap 1 " WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The pointer to the GUI point (WS-D1, WS-D2) (GUI scale 2) and one frame.
 POINT.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-X(1) = WS-D1 * 2
     COMPUTE WS-Y(1) = WS-D2 * 2
     MOVE 1 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

*> TL-OBSERVED: "count x:y gap g" and the first line of the tooltip, each followed by a space.
 TIP.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE TT-COUNT TO WS-E1
     MOVE TT-X TO WS-E2
     MOVE TT-Y TO WS-E3
     MOVE TT-TITLE-GAP TO WS-E4
     STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     IF TT-COUNT > 0
         STRING FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) " gap " FUNCTION TRIM(WS-E4) " "
             DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         STRING TT-L-TEXT(1)(1:TT-L-LEN(1)) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     .

 END PROGRAM TEST-SCREEN-40-1-TOOLTIP.

 COPY CLTEST.
