*> Test US12-client (spec 002; docs/protocol/40-menus-1-model-and-containers.md section 5.6): the slot-hover item tooltip on the survival inventory screen (the inventory key, GUI 320 x 240, left 72,
*> top 37) and on the crafting table screen (Open Screen type 12): a slot with an item under the pointer and nothing carried gives the item's name at the pointer; an empty slot or a carried stack gives none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-1-TOOLTIP-INV.
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
     MOVE "T" TO TL-MODE
     MOVE 0 TO PL-CARRIED-COUNT
     MOVE 1 TO PL-SLOT-COUNT(10)
     MOVE 3 TO PL-SLOT-ITEM(10)
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-E TO WS-A(1)
     MOVE CC-EV-KEY-UP TO WS-KIND(2)
     MOVE CC-KEY-E TO WS-A(2)
     MOVE 2 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 3 TO WS-ITEM
     CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-ITEM WS-NAME WS-NAME-LENGTH
     PERFORM CHECKS
*>   The crafting table.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE 12 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE 4 TO PB-TX-LENGTH
     MOVE "Loot" TO PB-TX-VALUE
     MOVE 0 TO PB-TX-ARG-COUNT
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     MOVE 60 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE 1 TO PL-SLOT-COUNT(10)
     MOVE 3 TO PL-SLOT-ITEM(10)
     PERFORM CHECKS
     STOP RUN.

 CHECKS.
     MOVE 85 TO WS-D1
     MOVE 126 TO WS-D2
     PERFORM POINT
     MOVE "acceptance US12 40-1§5.6 on the inventory and crafting screens a main slot with an item under the pointer gives its name at the pointer, with title spacing" TO TL-CASE
     PERFORM TIP
     MOVE SPACES TO TL-EXPECTED
     STRING "1 85:126 gap 1 " WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 103 TO WS-D1
     PERFORM POINT
     MOVE "acceptance US12 40-1§5.6 an empty main slot under the pointer gives no tooltip" TO TL-CASE
     PERFORM TIP
     MOVE "0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-CARRIED-COUNT
     MOVE 4 TO PL-CARRIED-ITEM
     MOVE 85 TO WS-D1
     PERFORM POINT
     MOVE "acceptance US12 40-1§5.6 with a carried stack the slot under the pointer gives no tooltip" TO TL-CASE
     PERFORM TIP
     MOVE "0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-CARRIED-COUNT
     .

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

 END PROGRAM TEST-SCREEN-40-1-TOOLTIP-INV.

 COPY CLTEST.
