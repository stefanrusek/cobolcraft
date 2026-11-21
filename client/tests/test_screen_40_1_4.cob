*> Test US12-client (spec 002 T3186, T3187; docs/protocol/40-menus-1-model-and-containers.md section 4): synchronisation as the client applies it. Container Set Data (0x13:
*> container id VarInt, property Short, value Short) writes the data slot of the open menu only (a signed 16-bit value; another container id changes nothing); Container Set Content
*> of the open container sets its stacks, the carried stack and the state id (4.3); Set Cursor Item (05b 0x62) sets the carried stack; the state id is what the next Container Click
*> carries (4.2); Container Close of the open id returns to the world and the client's own close (Escape) sends Container Close with the id (4.6); a new Open Screen clears the data slots.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-1-4.
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
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-PACKET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE "T" TO TL-MODE
     MOVE 14 TO WS-TYPE
     PERFORM OPEN-TYPE
*>   4.3 Container Set Data: property 2 of the open container 9 gets 57, property 3 gets 200, a value of 65535 reads as -1, another container's data changes nothing.
     MOVE 9 TO WS-ID
     MOVE 2 TO WS-SLOT
     MOVE 57 TO WS-VALUE
     PERFORM SEND-DATA
     MOVE 3 TO WS-SLOT
     MOVE 200 TO WS-VALUE
     PERFORM SEND-DATA
     MOVE 0 TO WS-SLOT
     MOVE 65535 TO WS-VALUE
     PERFORM SEND-DATA
     MOVE 5 TO WS-ID
     MOVE 1 TO WS-SLOT
     MOVE 99 TO WS-VALUE
     PERFORM SEND-DATA
     MOVE SPACES TO TL-OBSERVED
     MOVE BM-DATA(1) TO WS-E1
     MOVE BM-DATA(2) TO WS-E2
     MOVE BM-DATA(3) TO WS-E3
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE BM-DATA(4) TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§4 Container Set Data writes properties 0 to 3 of the open container (65535 is -1) and ignores another container id" TO TL-CASE
     MOVE "-1 0 57 200" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   4.3 Set Container Content of the open container: 2 stacks, the cursor 4 x item 3, state id 7.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-ID
     MOVE 7 TO WS-STATE
     MOVE 2 TO WS-COUNT
     CALL "PB-PUT-CONTAINER-CONTENT-HEAD" USING PB-BUFFER WS-ID WS-STATE WS-COUNT
     MOVE 0 TO PB-ISX-ADDED-COUNT PB-ISX-REMOVED-COUNT
     MOVE 16 TO PB-ISX-COUNT
     MOVE 2 TO PB-ISX-ITEM
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE 0 TO PB-ISX-COUNT
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE 4 TO PB-ISX-COUNT
     MOVE 3 TO PB-ISX-ITEM
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     MOVE 18 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE SPACES TO TL-OBSERVED
     MOVE BX-COUNT(1) TO WS-E1
     MOVE BM-STATE-ID TO WS-E2
     MOVE PL-CARRIED-COUNT TO WS-E3
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§4 Set Container Content of the open container sets the stacks, the state id (7) and the carried stack (4)" TO TL-CASE
     MOVE "16 7 4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   4.3 Set Cursor Item: 16 x oak planks (item 63) on the cursor.
     MOVE "contract/fixtures/wire/play-s2c-62-set-cursor-item.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-CARRIED-COUNT TO WS-E1
     MOVE PL-CARRIED-ITEM TO WS-E2
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§4 Set Cursor Item (0x62) sets the carried stack: 16 x item 63" TO TL-CASE
     MOVE "16x63" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-62-set-cursor-item-empty.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§4 Set Cursor Item with an empty stack empties the cursor" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-CARRIED-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
*>   4.2 the next Container Click carries the state id 7 (and the container id 9): a click on own slot 0 (widget argument 401).
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 401 TO WS-SLOT
     MOVE 15 TO WS-ID
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ID WS-SLOT WS-COUNT
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE FUNCTION TRIM(WS-TEXT)(1:8) TO TL-OBSERVED
     MOVE "acceptance US12 40-1§4 a click carries the container id (09) and the state id (07) of the last Set Container Content: 12 09 07" TO TL-CASE
     MOVE "12090700" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   4.6 the client's own close: Escape sends Container Close of the id and returns to the world.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-1§4 Escape closes the container screen: Container Close (13 09) is sent and the screen is the world (5)" TO TL-CASE
     MOVE "1309 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   4.1 a new Open Screen starts with zeroed data slots.
     MOVE 11 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§4 a new Open Screen clears the data slots" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BM-DATA(3) + BM-DATA(4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     STOP RUN.

 SEND-DATA.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-SLOT
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-VALUE
     MOVE 19 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     .

 OPEN-TYPE.
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
     .

 END PROGRAM TEST-SCREEN-40-1-4.

 COPY CLTEST.
