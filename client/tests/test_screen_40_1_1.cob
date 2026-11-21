*> Test US12-client (spec 002 T3180, T3181; docs/protocol/40-menus-1-model-and-containers.md section 1): the reading guide's conventions as the client keeps them. A container screen
*> is not a pause screen (5.5: the game keeps running: the client tick advances while it is open); pixel coordinates are relative to the screen image (leftPos, topPos); a menu slot
*> index is the number on the wire (own slot k of the chest is index k); a stack with count 0 or less is empty (Set Container Slot with count 0 empties the slot).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-1-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PACKET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE "T" TO TL-MODE
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
     MOVE PL-TIME TO WS-TIME
     MOVE 3 TO WS-I
     CALL "TEST-TICKS" USING CLIENT-STATE WS-I
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§1 a container screen is no pause screen: three client ticks advance the day time by 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-TIME - WS-TIME
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = 404
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§1 coordinates are relative to the screen image: own slot 3 (x 62, y 18) of the 3-row chest at leftPos 72, topPos 36 has its widget at (72 + 62 - 1, 36 + 18 - 1)" TO TL-CASE
     MOVE "133:53" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-SLOT
     MOVE 5 TO PB-ISX-COUNT
     MOVE 2 TO PB-ISX-ITEM
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO PB-ISX-ADDED-COUNT PB-ISX-REMOVED-COUNT
     CALL "PB-PUT-CONTAINER-SET-SLOT" USING PB-BUFFER WS-ID WS-STATE WS-SLOT PB-ITEMSTACK-X
     MOVE 20 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE 0 TO PB-ISX-COUNT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-CONTAINER-SET-SLOT" USING PB-BUFFER WS-ID WS-STATE WS-SLOT PB-ITEMSTACK-X
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§1 a stack with count 0 is empty: a Set Container Slot of count 0 empties the menu slot index 3" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BX-COUNT(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 END PROGRAM TEST-SCREEN-40-1-1.

 COPY CLTEST.
