*> Implementation test of the F3 overlay (13 §5): the day count is the overworld clock's total ticks divided by 24,000
*> (not the wrapped time of day, which could only ever give day 0 or 1), and the targeted block shows its registered
*> name and one "property: value" line per block-state property (not a bare state number).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DEBUG-BLOCK-DAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-TEXTS               PIC X(2048).
 01 WS-KEY                 BINARY-LONG VALUE 292.
 01 WS-TICKS               BINARY-LONG VALUE 5.
 01 WS-NAME                PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-HITS                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE "oak_fence" TO WS-NAME
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-NAME WS-ID WS-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE 3 4 5 WS-STATE
     MOVE "N" TO TL-MODE
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE 1 TO TG-HIT
     MOVE 3 TO TG-X
     MOVE 4 TO TG-Y
     MOVE 5 TO TG-Z
     MOVE 72001 TO PL-DAY-TICKS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXTS
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXTS TALLYING WS-HITS FOR ALL "Day #3"
     MOVE "debug overlay 72,001 ticks of the clock is Day #3" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE FUNCTION MIN(WS-HITS, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXTS TALLYING WS-HITS FOR ALL "minecraft:oak_fence"
     MOVE "debug overlay the targeted block is named minecraft:oak_fence" TO TL-CASE
     MOVE FUNCTION MIN(WS-HITS, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXTS TALLYING WS-HITS FOR ALL "waterlogged: false"
     MOVE "debug overlay a property line waterlogged: false follows" TO TL-CASE
     MOVE FUNCTION MIN(WS-HITS, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXTS TALLYING WS-HITS FOR ALL "Block state:"
     MOVE "debug overlay no bare state number line" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DEBUG-BLOCK-DAY.

 COPY CLTEST.
