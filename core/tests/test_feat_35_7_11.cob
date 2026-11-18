*> Implementation test of docs/protocol/35-worldgen-features-7-nether-end-misc.md section 11 (T1290; core/src/feat-35-7.cob F357-TEMPLATE-ANCHOR): 11.1 bonus_chest and 11.2 fill_layer are references to 35-5 sections 18 and 11
*> (their tests are test_feat_35_5_18 and test_feat_35_5_11), so this file holds 11.3 template placement offsets: offX = unit(rotation.rotate(WEST)) * (sizeX div 2) and offZ = unit(rotation.rotate(NORTH)) * (sizeZ div 2),
*> the anchor is the origin plus both. The document's example (size 7 x h x 7: none gives (-3, 0, -3), clockwise_90 gives (3, 0, -3)) and the other two rotations and an even / odd size mix (integer division).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-7-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CASE                PIC X(160).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 7 TO WS-SX WS-SZ
     MOVE 0 TO WS-ROT
     PERFORM CHECK-ONE
     MOVE -3 TO TL-EXPECTED-N
     MOVE WS-DX TO TL-OBSERVED-N
     MOVE "acceptance US12 35-7§11 `bonus_chest`, `fill_layer` (by reference) and `template`: size 7 x 7, none: x offset -3" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -3 TO TL-EXPECTED-N
     MOVE WS-DZ TO TL-OBSERVED-N
     MOVE "acceptance US12 35-7§11 `bonus_chest`, `fill_layer` (by reference) and `template`: size 7 x 7, none: z offset -3" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-ROT
     PERFORM CHECK-ONE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-DX TO TL-OBSERVED-N
     MOVE "acceptance US12 35-7§11 `bonus_chest`, `fill_layer` (by reference) and `template`: size 7 x 7, clockwise_90: x offset 3 (offZ = east * 3)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -3 TO TL-EXPECTED-N
     MOVE WS-DZ TO TL-OBSERVED-N
     MOVE "acceptance US12 35-7§11 `bonus_chest`, `fill_layer` (by reference) and `template`: size 7 x 7, clockwise_90: z offset -3 (offX = north * 3)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   180: WEST turns to EAST (+3), NORTH to SOUTH (+3); counterclockwise_90: WEST to SOUTH (z +3), NORTH to WEST (x -3)
     MOVE 2 TO WS-ROT
     PERFORM CHECK-ONE
     COMPUTE TL-OBSERVED-N = WS-DX * 10 + WS-DZ
     MOVE 33 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-7§11 `bonus_chest`, `fill_layer` (by reference) and `template`: size 7 x 7, clockwise_180: (3, 0, 3)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-ROT
     PERFORM CHECK-ONE
     COMPUTE TL-OBSERVED-N = WS-DX * 10 + WS-DZ
     MOVE -27 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-7§11 `bonus_chest`, `fill_layer` (by reference) and `template`: size 7 x 7, counterclockwise_90: (-3, 0, 3)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   size 5 x 8 with none: sizeX div 2 = 2, sizeZ div 2 = 4
     MOVE 5 TO WS-SX
     MOVE 8 TO WS-SZ
     MOVE 0 TO WS-ROT
     PERFORM CHECK-ONE
     COMPUTE TL-OBSERVED-N = WS-DX * 10 + WS-DZ
     MOVE -24 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-7§11 `bonus_chest`, `fill_layer` (by reference) and `template`: size 5 x 8, none: (-2, 0, -4), sizes halved by integer division" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-ONE.
     CALL "F357-TEMPLATE-ANCHOR" USING WS-ROT WS-SX WS-SZ WS-DX WS-DZ
     .
 END PROGRAM TEST-FEAT-35-7-11.
