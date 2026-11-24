*> Implementation test of moveInsideHeights of docs/protocol/36-structures-1-model-placement-starts.md section 6.6 (T1307; core/src/struct-pieces.cob SPB-MOVE-INSIDE): room = maxY - minY + 1 - ySpan (ySpan the
*> height of the union box), newMin = minY + nextInt(room) when room > 1 (one draw of the Java LCG, here from state 5: nextInt(374) = 318, nextInt(50) = 22, values from an independent evaluation of the LCG) else minY,
*> and every piece moves by newMin - box.minY (the returned dy). Two pieces of y -5 to 4 (ySpan 10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-PIECES-INSIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-TYPE                BINARY-LONG VALUE 5.
 01 WS-ORIENT              BINARY-LONG VALUE 0.
 01 WS-DEPTH               BINARY-LONG VALUE 0.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   room 374 for the world's -64 to 319: one draw, 318, newMin 254, dy 259
     PERFORM FILL-PIECES
     MOVE 5 TO SP-RNG
     MOVE -64 TO WS-MIN
     MOVE 319 TO WS-MAX
     CALL "SPB-MOVE-INSIDE" USING WS-MIN WS-MAX WS-DY
     MOVE "acceptance US12 36-1§6.6 moveInsideHeights(-64, 319): room 374, the draw nextInt(374) = 318 puts the structure's bottom at 254 (dy 259)" TO TL-CASE
     MOVE 259 TO TL-EXPECTED-N
     MOVE WS-DY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§6.6 moveInsideHeights: every piece moved by dy (the second piece's y range -3 to 2 becomes 256 to 261)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SP-Y0(2) * 1000 + SP-Y1(2)
     MOVE 256261 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   room 50 from y 0 to 59: draw nextInt(50) = 22, newMin 22, dy 27
     PERFORM FILL-PIECES
     MOVE 5 TO SP-RNG
     MOVE 0 TO WS-MIN
     MOVE 59 TO WS-MAX
     CALL "SPB-MOVE-INSIDE" USING WS-MIN WS-MAX WS-DY
     MOVE "acceptance US12 36-1§6.6 moveInsideHeights(0, 59): room 50, nextInt(50) = 22: dy 27" TO TL-CASE
     MOVE 27 TO TL-EXPECTED-N
     MOVE WS-DY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   room 1: no draw, the structure's bottom goes to minY; the generator state is unchanged
     PERFORM FILL-PIECES
     MOVE 5 TO SP-RNG
     MOVE -5 TO WS-MIN
     MOVE 5 TO WS-MAX
     CALL "SPB-MOVE-INSIDE" USING WS-MIN WS-MAX WS-DY
     MOVE "acceptance US12 36-1§6.6 moveInsideHeights(-5, 5): room 1 is not above 1, no draw, newMin = minY: dy 0 and the random state still 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-DY * 100 + SP-RNG
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   room 0 and a shifted minimum: no draw, dy = minY - box.minY
     PERFORM FILL-PIECES
     MOVE 5 TO SP-RNG
     MOVE 10 TO WS-MIN
     MOVE 19 TO WS-MAX
     CALL "SPB-MOVE-INSIDE" USING WS-MIN WS-MAX WS-DY
     MOVE "acceptance US12 36-1§6.6 moveInsideHeights(10, 19): room 0, no draw, the bottom goes to 10: dy 15" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-DY * 100 + SP-RNG - 5
     MOVE 1500 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FILL-PIECES.
     CALL "SPB-RESET"
     MOVE 0 TO A-X0 A-Z0
     MOVE -5 TO A-Y0
     MOVE 4 TO A-X1 A-Z1
     MOVE 0 TO A-Y1
     MOVE 4 TO A-Y1
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEPTH WS-MST WS-BOX WS-ROW
     MOVE -3 TO A-Y0
     MOVE 2 TO A-Y1
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEPTH WS-MST WS-BOX WS-ROW.
 END PROGRAM TEST-STRUCT-PIECES-INSIDE.
