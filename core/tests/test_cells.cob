*> Implementation test of the cell layout the core adopts (T0321/T0322; contract/copy/CELLS.cpy, data-model
*> section 4): CORE-MAX-DIMS 3 and CORE-CHUNK-BYTES = CE-CHUNK-BYTES; a state is 2 bytes (unsigned,
*> little-endian); light is 4 bits per cell in light-section arrays that start one section below the
*> dimension (byte index 2048 + (cell - 1) div 2 + 1, even cell in the low nibble); sections derive from the
*> dimension's min_y and height (24 in the overworld); the core's own chunks use this layout.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CELLS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CELLS.
 01 WS-OWN                 PIC X(304640).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "test cells the core keeps three dimensions" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE CORE-MAX-DIMS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test cells weather state exists for the third dimension" TO TL-CASE
     MOVE 77 TO CW-WEATHER-LEFT(3)
     MOVE 77 TO TL-EXPECTED-N
     MOVE CW-WEATHER-LEFT(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test cells a core chunk is the CE-CHUNK-BYTES block" TO TL-CASE
     MOVE CE-CHUNK-BYTES TO TL-EXPECTED-N
     MOVE CORE-CHUNK-BYTES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Layout on a buffer of the test's own.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-OWN
     MOVE LOW-VALUES TO WS-OWN
     MOVE 300 TO CE-STATE(5)
     MOVE "test cells a state is two bytes, low byte first" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (FUNCTION ORD(CE-STATES(9:1)) - 1) * 1000 + FUNCTION ORD(CE-STATES(10:1)) - 1
     MOVE 44001 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 255 TO CE-SKY(2048 + 1)
     MOVE "test cells light section 1 (the dimension's first) starts at byte 2049" TO TL-CASE
     MOVE 255 TO TL-EXPECTED-N
     MOVE FUNCTION ORD(CE-SKYS(2049:1)) TO WS-NUM
     COMPUTE TL-OBSERVED-N = WS-NUM - 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test cells the overworld has 24 sections: the last cell is in section 23" TO TL-CASE
     MOVE -64 TO CE-DIM-MIN-Y
     MOVE 384 TO CE-DIM-HEIGHT
     COMPUTE CE-DIM-SECTIONS = CE-DIM-HEIGHT / 16
     COMPUTE WS-Y = CE-DIM-MIN-Y + CE-DIM-HEIGHT - 1
     COMPUTE WS-CELL = (WS-Y - CE-DIM-MIN-Y) * 256 + 255 + 1
     COMPUTE TL-OBSERVED-N = CE-DIM-SECTIONS * 1000 + (WS-CELL - 1) / 4096
     MOVE 24023 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The core's own world: a stand-in chunk is a CE-CHUNK.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE "test cells the baseplate layer reads as state 1 in cells 1 and 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CE-STATE(1) * 1000 + CE-STATE(2)
     MOVE 1001 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test cells a placed state reads back from its 2-byte cell" TO TL-CASE
     MOVE 3 TO WS-X MOVE 100 TO WS-Y MOVE 5 TO WS-Z MOVE 12 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     COMPUTE WS-CELL = WS-Y * 256 + WS-Z * 16 + WS-X + 1
     COMPUTE TL-OBSERVED-N = CE-STATE(WS-CELL) * 1000 + FUNCTION ORD(CE-STATES(WS-CELL * 2 - 1:1)) - 1
     MOVE 12012 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test cells sky light 15 above a column's top packs into one nibble" TO TL-CASE
*>   (4, 54, 8): even cell, low nibble; (5, 54, 8) the high nibble of the same byte.
     COMPUTE WS-CELL = 54 * 256 + 8 * 16 + 4
     COMPUTE WS-BYTE = 2048 + WS-CELL / 2 + 1
     COMPUTE TL-OBSERVED-N = FUNCTION MOD(CE-SKY(WS-BYTE), 16)
     MOVE 15 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test cells block light packs two cells per byte (glowtube 15, beside it 14)" TO TL-CASE
     COMPUTE WS-CELL = 59 * 256 + 8 * 16 + 8
     COMPUTE WS-BYTE = 2048 + WS-CELL / 2 + 1
     MOVE CE-BLOCK-LIGHT(WS-BYTE) TO TL-OBSERVED-N
     MOVE 239 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CELLS.

 COPY CORETEST.
