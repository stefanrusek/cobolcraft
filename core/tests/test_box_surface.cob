*> Implementation test of the continuous top surface (T28970; docs/protocol/51-block-shapes.md rules R-B7, R-D1, R-D3, R-E3 and the slab rows of 3.2): ENTITY-BOX-SURFACE (core/src/ground-items.cob) is
*> ENTITY-BOX-HITS by the collision shape of each cell instead of the full cell: the box of an entity type at a position overlaps a shape box with positive volume (hit), and top is the highest y of the
*> shape boxes it overlaps, not the top of the cell (a bottom slab 0.5, a top slab 1, three snow layers 0.25 (one layer has no collision), a carpet 1/16, a closed bottom trapdoor 3/16, a closed top
*> trapdoor 1, a bed's mattress 9/16, a full cube 1). The standard set's tables are opened over the test world; the blocks are placed in the air above the spawn; the box is the loose item's (0.25 x 0.25).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BOX-SURFACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE 6 TO WS-BX
     MOVE 54 TO WS-BY
     MOVE 8 TO WS-BZ
     MOVE 6.5 TO WS-X
     MOVE 8.5 TO WS-Z
*>   A bottom slab: the top is 54.5; the box resting on it touches only.
     MOVE "oak_slab" TO WS-KEY
     MOVE "type=bottom,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.45 TO WS-Y
     MOVE "test box surface: a box in the lower half of a bottom slab hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of a bottom slab is 54.5" TO TL-CASE
     MOVE 54.5 TO WS-DIFF
     PERFORM TOP-OF
     MOVE 54.5 TO WS-Y
     MOVE "test box surface: a box resting on a bottom slab does not hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
*>   A top slab: the lower half is empty; the top is the top of the cell.
     MOVE "type=top,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.0 TO WS-Y
     MOVE "test box surface: a box in the empty lower half under a top slab does not hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE 54.6 TO WS-Y
     MOVE "test box surface: a box in the upper half of a top slab hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of a top slab is 55" TO TL-CASE
     MOVE 55 TO WS-DIFF
     PERFORM TOP-OF
*>   Three snow layers (collision 4 pixels), one layer (no collision, R-D3).
     MOVE "snow" TO WS-KEY
     MOVE "layers=3" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.2 TO WS-Y
     MOVE "test box surface: a box in three snow layers hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of three snow layers is 54.25" TO TL-CASE
     MOVE 54.25 TO WS-DIFF
     PERFORM TOP-OF
     MOVE 54.25 TO WS-Y
     MOVE "test box surface: a box resting on three snow layers does not hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "layers=1" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.0 TO WS-Y
     MOVE "test box surface: one snow layer has no collision" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
*>   A carpet (1 pixel, R-D1).
     MOVE "white_carpet" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.03 TO WS-Y
     MOVE "test box surface: a box in a carpet hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of a carpet is 54 and 1/16" TO TL-CASE
     MOVE 54.0625 TO WS-DIFF
     PERFORM TOP-OF
     MOVE 54.0625 TO WS-Y
     MOVE "test box surface: a box resting on a carpet does not hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
*>   Trapdoors closed (R-B7): bottom 3 pixels, top the upper 3 pixels.
     MOVE "oak_trapdoor" TO WS-KEY
     MOVE "facing=north,half=bottom,open=false,powered=false,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.1 TO WS-Y
     MOVE "test box surface: a box in a closed bottom trapdoor hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of a closed bottom trapdoor is 54 and 3/16" TO TL-CASE
     MOVE 54.1875 TO WS-DIFF
     PERFORM TOP-OF
     MOVE "facing=north,half=top,open=false,powered=false,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.5 TO WS-Y
     MOVE "test box surface: a box under a closed top trapdoor does not hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE 54.9 TO WS-Y
     MOVE "test box surface: a box in a closed top trapdoor hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of a closed top trapdoor is 55" TO TL-CASE
     MOVE 55 TO WS-DIFF
     PERFORM TOP-OF
*>   A bed (the mattress 3 to 9 pixels, R-E3).
     MOVE "red_bed" TO WS-KEY
     MOVE "facing=north,occupied=false,part=foot" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.5 TO WS-Y
     MOVE "test box surface: a box in a bed's mattress hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of a bed is 54 and 9/16" TO TL-CASE
     MOVE 54.5625 TO WS-DIFF
     PERFORM TOP-OF
*>   A full cube: the top of the cell.
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.5 TO WS-Y
     MOVE "test box surface: a box in stone hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of stone is 55" TO TL-CASE
     MOVE 55 TO WS-DIFF
     PERFORM TOP-OF
*>   Two cells: a bottom slab at (6, 54, 8) and stone at (7, 54, 8) under a box over the line between them: the top is the higher.
     MOVE "oak_slab" TO WS-KEY
     MOVE "type=bottom,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 7 TO WS-BX
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PLACE
     MOVE 6.95 TO WS-X
     MOVE 54.4 TO WS-Y
     MOVE "test box surface: a box over a slab and a cube hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: its top is the cube's 55, the higher of the two" TO TL-CASE
     MOVE 55 TO WS-DIFF
     PERFORM TOP-OF
*>   Air: no hit. A cell of an unloaded chunk counts as solid, its top the top of the cell.
     MOVE 6 TO WS-BX
     MOVE "air" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PLACE
     MOVE 7 TO WS-BX
     PERFORM PLACE
     MOVE 6.5 TO WS-X
     MOVE 54.4 TO WS-Y
     MOVE "test box surface: a box in air does not hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE 100000.5 TO WS-X
     MOVE "test box surface: a box in an unloaded chunk hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of an unloaded cell is the top of the cell, 55" TO TL-CASE
     MOVE 55 TO WS-DIFF
     PERFORM TOP-OF
*>   Scaffolding (51 section 3.8.5, R-C20): the shape an entity meets depends on where it is. Above the top (feet within 1e-5 of it or higher) it meets the stable shape
*>   (top slab, top 55); inside the cell it meets nothing, except the plate (top 54.125) of an unstable one whose feet are not below the cell's own y.
     MOVE 6 TO WS-BX
     MOVE 6.5 TO WS-X
     MOVE 8.5 TO WS-Z
     MOVE "scaffolding" TO WS-KEY
     MOVE "distance=0,bottom=false,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.5 TO WS-Y
     MOVE "test box surface: a box inside a scaffolding cell does not hit (the stable shape is for entities above it)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE 54.999995 TO WS-Y
     MOVE "test box surface: a box with its feet 5e-6 under the top of scaffolding is above it and hits the stable shape" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the top of scaffolding's stable shape is 55" TO TL-CASE
     MOVE 55 TO WS-DIFF
     PERFORM TOP-OF
     MOVE "distance=3,bottom=true,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.05 TO WS-Y
     MOVE "test box surface: a box low in an unstable scaffolding cell hits its plate" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test box surface: the plate's top is 54.125" TO TL-CASE
     MOVE 54.125 TO WS-DIFF
     PERFORM TOP-OF
     MOVE 53.5 TO WS-Y
     MOVE "test box surface: a box below an unstable scaffolding cell meets nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     STOP RUN.

 PLACE.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE.

 HIT-OF.
     CALL "ENTITY-BOX-SURFACE" USING WS-DIM CR-LOOSE-ITEM WS-X WS-Y WS-Z WS-HIT WS-TOP
     MOVE WS-HIT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 TOP-OF.
     CALL "ENTITY-BOX-SURFACE" USING WS-DIM CR-LOOSE-ITEM WS-X WS-Y WS-Z WS-HIT WS-TOP
     COMPUTE WS-DIFF = WS-TOP - WS-DIFF
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.000001 AND WS-DIFF > -0.000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-BOX-SURFACE.

 COPY CORETEST.
