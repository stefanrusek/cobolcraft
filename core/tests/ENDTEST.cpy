*> Test helpers of the End tests (COPY it after the test program; the program COPYs CBLOCKS, END and defines WS-V FLOAT-LONG, WS-WANT, WS-GOT,
*> WS-DIFF BINARY-DOUBLE and WS-TOL BINARY-LONG): END-TABLES fills the block table with the blocks the End generator places (states: air 0,
*> end_stone 200) and the biome table with the five End biomes in the order the_end 0, end_highlands 1, end_midlands 2, small_end_islands 3,
*> end_barrens 4, then resolves them (END-STATES). CHECK-V asserts WS-V (a float) against WS-WANT (value times 1e7) within WS-TOL, case TL-CASE
*> (TL-MODE "N"). Test infrastructure.
 END-TABLES.
     MOVE 1 TO CB-BLOCK-COUNT
     MOVE "minecraft:end_stone" TO CB-KEY(1)
     MOVE 19 TO CB-KEY-LENGTH(1)
     MOVE 200 TO CB-DEFAULT-STATE(1)
     MOVE 5 TO CBI-COUNT
     MOVE "minecraft:the_end" TO CBI-KEY(1)
     MOVE 17 TO CBI-KEY-LENGTH(1)
     MOVE "minecraft:end_highlands" TO CBI-KEY(2)
     MOVE 23 TO CBI-KEY-LENGTH(2)
     MOVE "minecraft:end_midlands" TO CBI-KEY(3)
     MOVE 22 TO CBI-KEY-LENGTH(3)
     MOVE "minecraft:small_end_islands" TO CBI-KEY(4)
     MOVE 27 TO CBI-KEY-LENGTH(4)
     MOVE "minecraft:end_barrens" TO CBI-KEY(5)
     MOVE 21 TO CBI-KEY-LENGTH(5)
     CALL "END-STATES".
 CHECK-V.
     COMPUTE WS-GOT ROUNDED = WS-V * 10000000
     COMPUTE WS-DIFF = WS-GOT - WS-WANT
     IF WS-DIFF < 0
         COMPUTE WS-DIFF = 0 - WS-DIFF
     END-IF
     MOVE WS-WANT TO TL-EXPECTED-N
     IF WS-DIFF <= WS-TOL
         MOVE WS-WANT TO TL-OBSERVED-N
     ELSE
         MOVE WS-GOT TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
