*> Test of the sliding window of the light engine (core/src/light-32.cob L32-SET-DIMENSION, L32-CLAIM-CHUNK; T0697): chunks anywhere (a chunk takes the slot
*> (z + 1 mod 4) * 4 + (x + 1 mod 4) + 1 of the 4 x 4 window and a slot taken by another chunk is cleared), the dimension's section count and lowest section,
*> block states beyond the first 64, and sky light under an overhang (32 section 5.2: sky light spreads sideways one level less per cell).
*> Expected levels come from the rules of docs/protocol/32-light-engine.md: block light loses one level per cell and by the opacity of the cell entered; an
*> open column holds sky light 15, a neighbouring cell 14, and so on.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-32-WINDOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-SKY                 BINARY-LONG.
 01 WS-NS                  BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-RESULT              PIC X(120).
 01 WS-SHOW                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-DEF.
    05 WS-D1               BINARY-LONG.
    05 WS-D2               BINARY-LONG.
    05 WS-D3               BINARY-LONG.
    05 WS-D4               BINARY-LONG.
    05 WS-D5               BINARY-LONG.
    05 WS-D6               BINARY-LONG.
    05 WS-D7               BINARY-LONG.
    05 WS-D8               BINARY-LONG.
    05 WS-D9               BINARY-LONG.
    05 WS-D10              BINARY-LONG.
    05 WS-D11              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE

*>   Case 1: a column far outside the old window (chunk 100, -50): one emitter of 14 lights its neighbours 13, 12, ... and stops at 0.
     MOVE 0 TO WS-SKY
     PERFORM START-ENGINE
     MOVE 100 TO WS-CX
     MOVE -50 TO WS-CZ
     PERFORM CLAIM-NINE
     MOVE 1584 TO WS-X1
     MOVE 1631 TO WS-X2
     MOVE -816 TO WS-Z1
     MOVE -769 TO WS-Z2
     MOVE 2 TO WS-STATE
     PERFORM FLOOR-LAYER
     PERFORM LIGHT-NINE
     MOVE 1601 TO WS-X
     MOVE 2 TO WS-Y
     MOVE -799 TO WS-Z
     MOVE 4 TO WS-STATE
     PERFORM PLACE-BLOCK
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 1 TO WS-LAYER
     PERFORM SHOW-FAR-LEVELS
     MOVE "acceptance US12 32§5 chunk (100, -50) outside the old window: emitter 14 gives 14/13/12/8/0 along x" TO TL-CASE
     MOVE "14/13/12/8/0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Case 2: the window slides: chunk (3, 0) takes the slot of chunk (-1, 0), whose cells then read as outside (bedrock, level 0) and chunk (3, 0) reads its own.
     MOVE 0 TO WS-SKY
     PERFORM START-ENGINE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 3 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "L32-CLAIM-CHUNK" USING WS-CX WS-CZ WS-CHANGED
     MOVE WS-CHANGED TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "L32-CLAIM-CHUNK" USING WS-CX WS-CZ WS-CHANGED
     MOVE WS-CHANGED TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 1 TO WS-C
     CALL "L32-AVAIL-CHUNK" USING WS-CX WS-CZ WS-C
     MOVE 48 TO WS-X
     MOVE 0 TO WS-Y WS-Z
     MOVE 2 TO WS-C
     CALL "L32-SET-CELL" USING WS-X WS-Y WS-Z WS-C
     CALL "L32-STATE-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE -16 TO WS-X
     CALL "L32-STATE-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "acceptance US12 32§2.2 a claimed slot: the chunk takes it once (1 then 0), reads its stone (2) and the chunk it replaced reads bedrock (1)" TO TL-CASE
     MOVE "1/0/2/1 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Case 3: a tall dimension (16 block sections, 0 to 255): an emitter at Y 200 lights 14, 13, 4 and nothing 30 cells up.
     MOVE 0 TO WS-SKY
     PERFORM START-ENGINE
     MOVE 16 TO WS-NS
     MOVE 0 TO WS-MIN
     CALL "L32-SET-DIMENSION" USING WS-NS WS-MIN
     MOVE 0 TO WS-CX WS-CZ
     PERFORM CLAIM-NINE
     MOVE -16 TO WS-X1
     MOVE 47 TO WS-X2 WS-Z2
     MOVE -16 TO WS-Z1
     MOVE 2 TO WS-STATE
     MOVE 0 TO WS-Y
     PERFORM FLOOR-LAYER-AT-Y
     PERFORM LIGHT-NINE
     MOVE 5 TO WS-X
     MOVE 200 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 4 TO WS-STATE
     PERFORM PLACE-BLOCK
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 1 TO WS-LAYER
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     MOVE 200 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE 201 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE 210 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE 230 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE "acceptance US12 32§6 16 block sections: emitter 14 at Y 200 gives 14/13/4/0 at Y 200, 201, 210, 230" TO TL-CASE
     MOVE "14 13 4 0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Case 4: a dimension that starts below zero (24 sections from section -4: Y -64 to 319): an emitter at Y -60 lights 14, 13 and 4 ten cells up; sky light above
*>   the floor is 15 up to the top.
     MOVE 1 TO WS-SKY
     PERFORM START-ENGINE
     MOVE 24 TO WS-NS
     MOVE -4 TO WS-MIN
     CALL "L32-SET-DIMENSION" USING WS-NS WS-MIN
     MOVE 0 TO WS-CX WS-CZ
     PERFORM CLAIM-NINE
     MOVE -16 TO WS-X1 WS-Z1
     MOVE 47 TO WS-X2 WS-Z2
     MOVE 2 TO WS-STATE
     MOVE -64 TO WS-Y
     PERFORM FLOOR-LAYER-AT-Y
     PERFORM LIGHT-NINE
     MOVE 5 TO WS-X
     MOVE -60 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 4 TO WS-STATE
     PERFORM PLACE-BLOCK
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 1 TO WS-LAYER
     MOVE -60 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE -59 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE -50 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE 2 TO WS-LAYER
     MOVE -63 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE 319 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE "acceptance US12 32§6 24 sections from Y -64: emitter 14 at Y -60 gives 14/13/4, sky light 15 above the floor and at the top" TO TL-CASE
     MOVE "14 13 4 15 15 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Case 5: a block state beyond the old table of 64: state 30000 emits 12, state 39999 is stone; the stone stops the light, the emitter lights its side.
     MOVE 0 TO WS-SKY
     PERFORM START-ENGINE
     MOVE 30000 TO WS-D1
     MOVE 12 TO WS-D2
     MOVE 0 TO WS-D3
     MOVE 0 TO WS-D4
     MOVE 0 TO WS-D5
     PERFORM DEFINE-ST
     MOVE 39999 TO WS-D1
     MOVE 0 TO WS-D2
     MOVE 15 TO WS-D3
     MOVE 1 TO WS-D4
     MOVE 0 TO WS-D5
     PERFORM DEFINE-FACES
     PERFORM DEFINE-ST
     MOVE 0 TO WS-CX WS-CZ
     PERFORM CLAIM-NINE
     MOVE -16 TO WS-X1 WS-Z1
     MOVE 47 TO WS-X2 WS-Z2
     MOVE 39999 TO WS-STATE
     MOVE 0 TO WS-Y
     PERFORM FLOOR-LAYER-AT-Y
     PERFORM LIGHT-NINE
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 30000 TO WS-STATE
     PERFORM PLACE-BLOCK
     MOVE 7 TO WS-X
     MOVE 39999 TO WS-STATE
     PERFORM PLACE-BLOCK
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 1 TO WS-LAYER
     MOVE 5 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 6 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 7 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 8 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 5 TO WS-X
     MOVE 0 TO WS-Y
     PERFORM SHOW-LEVEL
     MOVE "acceptance US12 32§2 states 30000 (emission 12) and 39999 (opaque): 12/11/0/7/0, the light goes round the stone and not into it" TO TL-CASE
     MOVE "12 11 0 7 0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Case 6: sky light under an overhang (a roof of stone at Y 40 over x 0 to 19, open to both sides): the cells under it hold 15 minus the distance to the nearest
*>   open column (14 at the edge, 9 five cells in, 5 in the middle) and the open column beside it 15.
     MOVE 1 TO WS-SKY
     PERFORM START-ENGINE
     MOVE 0 TO WS-CX WS-CZ
     MOVE -16 TO WS-X1 WS-Z1
     MOVE 47 TO WS-X2 WS-Z2
     MOVE 2 TO WS-STATE
     MOVE 0 TO WS-Y
     PERFORM FLOOR-LAYER-AT-Y
     MOVE 0 TO WS-X1
     MOVE 19 TO WS-X2
     MOVE 40 TO WS-Y
     PERFORM FLOOR-LAYER-AT-Y
     PERFORM LIGHT-SIXTEEN
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 2 TO WS-LAYER
     MOVE 5 TO WS-Z
     MOVE 39 TO WS-Y
     MOVE -1 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 0 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 5 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 9 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 10 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 19 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 20 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE 10 TO WS-Y
     MOVE 5 TO WS-X
     PERFORM SHOW-LEVEL
     MOVE "acceptance US12 32§5.2 sky light under an overhang: 15/14/9/5/5/14/15 under the roof at Y 39 and 9 at Y 10 below x 5" TO TL-CASE
     MOVE "15 14 9 5 5 14 15 9 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 START-ENGINE.
     CALL "L32-INIT" USING WS-SKY
     MOVE 2 TO WS-D1
     MOVE 0 TO WS-D2
     MOVE 15 TO WS-D3
     MOVE 1 TO WS-D4
     MOVE 0 TO WS-D5
     PERFORM DEFINE-FACES
     PERFORM DEFINE-ST
     MOVE 4 TO WS-D1
     MOVE 14 TO WS-D2
     MOVE 0 TO WS-D3
     MOVE 0 TO WS-D4
     MOVE 0 TO WS-D5
     MOVE 0 TO WS-D6 WS-D7 WS-D8 WS-D9 WS-D10 WS-D11
     PERFORM DEFINE-ST
     .

*> The six faces of a full block (15) for the state being defined.
 DEFINE-FACES.
     MOVE 15 TO WS-D6 WS-D7 WS-D8 WS-D9 WS-D10 WS-D11
     .

 DEFINE-ST.
     CALL "L32-DEFINE-STATE" USING WS-D1 WS-D2 WS-D3 WS-D4 WS-D5 WS-D6 WS-D7 WS-D8 WS-D9 WS-D10 WS-D11
     .

*> Claims the nine chunks around (WS-CX, WS-CZ) and makes them available.
 CLAIM-NINE.
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-X = WS-CX + WS-DX
             COMPUTE WS-Z = WS-CZ + WS-DZ
             CALL "L32-CLAIM-CHUNK" USING WS-X WS-Z WS-CHANGED
             CALL "L32-AVAIL-CHUNK" USING WS-X WS-Z WS-ONE
         END-PERFORM
     END-PERFORM
     .

*> Stone (WS-STATE) at Y 0 and 1 over the cells WS-X1..WS-X2, WS-Z1..WS-Z2.
 FLOOR-LAYER.
     MOVE 0 TO WS-Y
     PERFORM FLOOR-LAYER-AT-Y
     .

 FLOOR-LAYER-AT-Y.
     PERFORM VARYING WS-X FROM WS-X1 BY 1 UNTIL WS-X > WS-X2
         PERFORM VARYING WS-Z FROM WS-Z1 BY 1 UNTIL WS-Z > WS-Z2
             CALL "L32-SET-CELL" USING WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     .

*> Lights the nine chunks around (WS-CX, WS-CZ): sources, stage, then the queued work runs.
 LIGHT-NINE.
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-X = WS-CX + WS-DX
             COMPUTE WS-Z = WS-CZ + WS-DZ
             CALL "L32-INIT-LIGHT" USING WS-X WS-Z WS-ZERO
         END-PERFORM
     END-PERFORM
     CALL "L32-SERVER-RUN" USING WS-A WS-B
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-X = WS-CX + WS-DX
             COMPUTE WS-Z = WS-CZ + WS-DZ
             CALL "L32-LIGHT-STAGE" USING WS-X WS-Z WS-ZERO
         END-PERFORM
     END-PERFORM
     CALL "L32-SERVER-RUN" USING WS-A WS-B
     .

*> The default window (chunks -1 to 2) lit chunk by chunk.
 LIGHT-SIXTEEN.
     PERFORM VARYING WS-Z FROM -1 BY 1 UNTIL WS-Z > 2
         PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 2
             CALL "L32-AVAIL-CHUNK" USING WS-X WS-Z WS-ONE
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-A
     PERFORM VARYING WS-Z FROM -1 BY 1 UNTIL WS-Z > 2
         PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 2
             CALL "L32-INIT-LIGHT" USING WS-X WS-Z WS-ZERO
         END-PERFORM
     END-PERFORM
     CALL "L32-SERVER-RUN" USING WS-A WS-B
     PERFORM VARYING WS-Z FROM -1 BY 1 UNTIL WS-Z > 2
         PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 2
             CALL "L32-LIGHT-STAGE" USING WS-X WS-Z WS-ZERO
         END-PERFORM
     END-PERFORM
     CALL "L32-SERVER-RUN" USING WS-A WS-B
     .

 PLACE-BLOCK.
     CALL "L32-SET-BLOCK" USING WS-ZERO WS-X WS-Y WS-Z WS-STATE
     CALL "L32-RUN-BOTH" USING WS-A
     .

 SHOW-LEVEL.
     CALL "L32-GET-WORKING" USING WS-LAYER WS-X WS-Y WS-Z WS-LEVEL
     MOVE WS-LEVEL TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> The block light along x from the emitter (1601, 2, -799): 0, 1, 2, 6 and 14 cells away, shown as "/"-separated levels.
 SHOW-FAR-LEVELS.
     MOVE 2 TO WS-Y
     MOVE -799 TO WS-Z
     MOVE 1601 TO WS-X
     CALL "L32-GET-WORKING" USING WS-LAYER WS-X WS-Y WS-Z WS-LEVEL
     MOVE WS-LEVEL TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 1602 TO WS-X
     CALL "L32-GET-WORKING" USING WS-LAYER WS-X WS-Y WS-Z WS-LEVEL
     MOVE WS-LEVEL TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 1603 TO WS-X
     CALL "L32-GET-WORKING" USING WS-LAYER WS-X WS-Y WS-Z WS-LEVEL
     MOVE WS-LEVEL TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 1607 TO WS-X
     CALL "L32-GET-WORKING" USING WS-LAYER WS-X WS-Y WS-Z WS-LEVEL
     MOVE WS-LEVEL TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE 1615 TO WS-X
     CALL "L32-GET-WORKING" USING WS-LAYER WS-X WS-Y WS-Z WS-LEVEL
     MOVE WS-LEVEL TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .
 END PROGRAM TEST-LIGHT-32-WINDOW.
