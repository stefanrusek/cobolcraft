*> The two halves of a door and of a tall plant (a block with the property half = lower or upper: doors, tall grass, large fern, sunflower, lilac,
*> rose bush, peony, tall seagrass, small dripleaf; operator report of try6: a door was placed with its bottom half only, and each half could be broken
*> alone). Vanilla: placing the lower half places the upper half above it (refused unless that cell is empty or replaceable), breaking either half
*> removes both and the door drops once, from the lower half.
*> Entry points:
*>   DOUBLE-HALF USING state, half out (BINARY-LONG: 0 the block has no half property of lower or upper, 1 lower, 2 upper)
*>   DOUBLE-BREAK USING dim, x, y, z (the broken half), state (its state), drop y out, drop state out: removes the other half when it is the same block
*>     with the opposite half (a void is written, the changed block goes to the viewers), and gives where the loot comes from: the lower half
*>     (the broken one when it is lower or has no partner).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOUBLE-HALF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(24) VALUE "half".
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-HALF.
     MOVE 0 TO L-HALF
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-RESULT
     IF WS-RESULT = 1
         EVALUATE WS-TEXT
             WHEN "lower"
                 MOVE 1 TO L-HALF
             WHEN "upper"
                 MOVE 2 TO L-HALF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM DOUBLE-HALF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOUBLE-BREAK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-HALF                BINARY-LONG.
 01 WS-OTHER-HALF          BINARY-LONG.
 01 WS-OTHER-Y             BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-VOID                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-DROP-Y               BINARY-LONG.
 01 L-DROP-STATE           BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-DROP-Y L-DROP-STATE.
     MOVE L-Y TO L-DROP-Y
     MOVE L-STATE TO L-DROP-STATE
     CALL "DOUBLE-HALF" USING L-STATE WS-HALF
     IF WS-HALF = 0
         GOBACK
     END-IF
     IF WS-HALF = 1
         COMPUTE WS-OTHER-Y = L-Y + 1
     ELSE
         COMPUTE WS-OTHER-Y = L-Y - 1
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-OTHER-Y L-Z WS-OTHER
     CALL "DOUBLE-HALF" USING WS-OTHER WS-OTHER-HALF
     IF WS-OTHER-HALF + WS-HALF = 3 AND CB-S-BLOCK(WS-OTHER + 1) = CB-S-BLOCK(L-STATE + 1)
         CALL "BLOCK-CHANGE" USING L-DIM L-X WS-OTHER-Y L-Z WS-VOID
         IF WS-HALF = 2
             MOVE WS-OTHER-Y TO L-DROP-Y
             MOVE WS-OTHER TO L-DROP-STATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM DOUBLE-BREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOUBLE-PLACE-FITS.
*> USING dim, x, y, z (the cell of the lower half), state (the state to place), fits out (BINARY-LONG): 1 unless the state is a lower half and the cell
*> above it is outside the dimension or neither empty nor replaceable (the tag minecraft:replaceable).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 01 WS-HALF                BINARY-LONG.
 01 WS-ABOVE-Y             BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-REPLACEABLE         BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:replaceable".
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FITS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-FITS.
     MOVE 1 TO L-FITS
     CALL "DOUBLE-HALF" USING L-STATE WS-HALF
     IF WS-HALF NOT = 1
         GOBACK
     END-IF
     COMPUTE WS-ABOVE-Y = L-Y + 1
     IF WS-ABOVE-Y >= DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM)
         MOVE 0 TO L-FITS
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-ABOVE-Y L-Z WS-OLD
     IF WS-OLD NOT = 0
         MOVE CB-S-BLOCK(WS-OLD + 1) TO WS-BLOCK
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-REPLACEABLE
         IF WS-REPLACEABLE = 0
             MOVE 0 TO L-FITS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM DOUBLE-PLACE-FITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOUBLE-PLACE-UPPER.
*> USING dim, x, y, z (the cell of the lower half), state (the lower half's state): places the upper half above a lower half (nothing for any other state).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(24) VALUE "half".
 01 WS-TEXT                PIC X(32) VALUE "upper".
 01 WS-UPPER               BINARY-LONG.
 01 WS-ABOVE-Y             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "DOUBLE-HALF" USING L-STATE WS-HALF
     IF WS-HALF = 1
         CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-NAME WS-TEXT WS-UPPER
         COMPUTE WS-ABOVE-Y = L-Y + 1
         CALL "BLOCK-CHANGE" USING L-DIM L-X WS-ABOVE-Y L-Z WS-UPPER
     END-IF
     GOBACK.
 END PROGRAM DOUBLE-PLACE-UPPER.
