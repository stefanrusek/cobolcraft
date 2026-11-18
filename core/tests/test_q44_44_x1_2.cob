*> Acceptance test of docs/protocol/44-residual-mob-questions-x1-continuation.md section 2, per-block entity effects as rule functions (lane 002-lane-p49j-b, T24300 range): honey block slide test and
*> movement with the worked examples, powder snow (walkers, collision shape, landing sound), bubble column (state, occupancy, the four velocity ramps), campfire damage and cobweb multipliers.
*> The functions of core/src/q44-44-x1.cob are not called by an entity-inside tick (see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X1-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(160).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                  FLOAT-LONG.
 01 WS-B                  FLOAT-LONG.
 01 WS-C                  FLOAT-LONG.
 01 WS-D                  FLOAT-LONG.
 01 WS-E                  FLOAT-LONG.
 01 WS-F                  FLOAT-LONG.
 01 WS-G                  FLOAT-LONG.
 01 WS-H                  FLOAT-LONG.
 01 WS-J                  FLOAT-LONG.
 01 WS-K                  FLOAT-LONG.
 01 WS-N1                 BINARY-LONG.
 01 WS-N2                 BINARY-LONG.
 01 WS-N3                 BINARY-LONG.
 01 WS-N4                 BINARY-LONG.
 01 WS-N5                 BINARY-LONG.
 01 WS-N6                 BINARY-LONG.
 01 WS-N7                 BINARY-LONG.
 01 WS-N8                 BINARY-LONG.
 01 WS-N9                 BINARY-LONG.
 01 WS-N10                 BINARY-LONG.
 01 WS-N11                 BINARY-LONG.
 01 WS-N12                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LEVEL OCCURS 5 TIMES.
       10 WS-AMP            BINARY-LONG.
       10 WS-DUR            BINARY-LONG.
       10 WS-ACTIVE         BINARY-LONG.
 01 WS-TAB.
    05 WS-TN                BINARY-LONG.
    05 WS-TC OCCURS 6 TIMES.
       10 WS-TA             BINARY-LONG.
       10 WS-TB             BINARY-LONG.
       10 WS-TD             BINARY-LONG.
 01 WS-COL.
    05 WS-CELL OCCURS 14 TIMES.
       10 WS-CE             BINARY-LONG.
       10 WS-CF             BINARY-LONG.
 01 WS-S1                  PIC X(32).
 01 WS-S2                  PIC X(32).
 01 WS-S3                  PIC X(32).
 01 WS-S4                  PIC X(32).
 01 WS-S5                  PIC X(32).
 01 WS-S6                  PIC X(32).
 PROCEDURE DIVISION.
     MOVE -0.5 TO WS-A
     CALL "X1-HONEY-OLD-DY" USING WS-A WS-B
     MOVE "acceptance US15 44-x1§2 2.1 oldDeltaY(-0.5) = -0.4302 (ten-thousandths)" TO WS-CASE
     MOVE -4302 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE -0.05 TO WS-A
     CALL "X1-HONEY-NEW-DY" USING WS-A WS-B
     MOVE "acceptance US15 44-x1§2 2.1 newDeltaY(-0.05) = -0.1274 (ten-thousandths)" TO WS-CASE
     MOVE -1274 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 64.5 TO WS-A
     MOVE 64 TO WS-B
     MOVE -0.5 TO WS-C
     MOVE 0.9 TO WS-D
     MOVE 0.1 TO WS-E
     MOVE 0.6 TO WS-F
     CALL "X1-HONEY-SLIDING" USING WS-N1 WS-A WS-B WS-C WS-D WS-E WS-F WS-N2
     MOVE "acceptance US15 44-x1§2 2.1 sliding: airborne against the side, falling, edge overlap" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 64.5 TO WS-A
     MOVE 64 TO WS-B
     MOVE -0.5 TO WS-C
     MOVE 0.9 TO WS-D
     MOVE 0.1 TO WS-E
     MOVE 0.6 TO WS-F
     CALL "X1-HONEY-SLIDING" USING WS-N1 WS-A WS-B WS-C WS-D WS-E WS-F WS-N2
     MOVE "acceptance US15 44-x1§2 2.1 on the ground is not sliding" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 64.95 TO WS-A
     MOVE 64 TO WS-B
     MOVE -0.5 TO WS-C
     MOVE 0.9 TO WS-D
     MOVE 0.1 TO WS-E
     MOVE 0.6 TO WS-F
     CALL "X1-HONEY-SLIDING" USING WS-N1 WS-A WS-B WS-C WS-D WS-E WS-F WS-N2
     MOVE "acceptance US15 44-x1§2 2.1 above the top 1/16 is not sliding" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 64.5 TO WS-A
     MOVE 64 TO WS-B
     MOVE -0.05 TO WS-C
     MOVE 0.9 TO WS-D
     MOVE 0.1 TO WS-E
     MOVE 0.6 TO WS-F
     CALL "X1-HONEY-SLIDING" USING WS-N1 WS-A WS-B WS-C WS-D WS-E WS-F WS-N2
     MOVE "acceptance US15 44-x1§2 2.1 delta.y -0.05 (example 3) is not sliding" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 64.5 TO WS-A
     MOVE 64 TO WS-B
     MOVE -0.5 TO WS-C
     MOVE 0.5 TO WS-D
     MOVE 0.5 TO WS-E
     MOVE 0.6 TO WS-F
     CALL "X1-HONEY-SLIDING" USING WS-N1 WS-A WS-B WS-C WS-D WS-E WS-F WS-N2
     MOVE "acceptance US15 44-x1§2 2.1 well inside the footprint (0.5, 0.5) is not sliding" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 64.5 TO WS-A
     MOVE 64 TO WS-B
     MOVE -0.5 TO WS-C
     MOVE 0.1 TO WS-D
     MOVE 0.9 TO WS-E
     MOVE 0.6 TO WS-F
     CALL "X1-HONEY-SLIDING" USING WS-N1 WS-A WS-B WS-C WS-D WS-E WS-F WS-N2
     MOVE "acceptance US15 44-x1§2 2.1 z overlap alone is enough" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE -0.5 TO WS-B
     MOVE 0 TO WS-C
     CALL "X1-HONEY-SLIDE" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-x1§2 2.1 example 1: vx x 0.1162 (ten-thousandths)" TO WS-CASE
     MOVE 1162 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x1§2 2.1 example 1: vy becomes -0.1274 (ten-thousandths)" TO WS-CASE
     MOVE -1274 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE -0.2 TO WS-B
     MOVE 0 TO WS-C
     CALL "X1-HONEY-SLIDE" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-x1§2 2.1 example 2: delta.y -0.2 keeps vx" TO WS-CASE
     MOVE 10000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2 WS-N3
     CALL "X1-POWDER-WALKABLE" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x1§2 2.2 a type in powder_snow_walkable_mobs walks on it" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2 WS-N3
     CALL "X1-POWDER-WALKABLE" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x1§2 2.2 a living entity in leather boots walks on it" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1 WS-N3
     MOVE 1 TO WS-N2
     CALL "X1-POWDER-WALKABLE" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x1§2 2.2 a living entity without boots sinks" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1 WS-N2
     MOVE 1 TO WS-N3
     CALL "X1-POWDER-WALKABLE" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x1§2 2.2 a non-living untagged entity sinks" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-A
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X1-POWDER-COLLISION" USING WS-A WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x1§2 2.2 fallDistance above 2.5: the falling box" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2.5 TO WS-A
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X1-POWDER-COLLISION" USING WS-A WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x1§2 2.2 exactly 2.5 is not the falling box" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X1-POWDER-COLLISION" USING WS-A WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x1§2 2.2 a falling block entity gets the normal shape" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X1-POWDER-COLLISION" USING WS-A WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x1§2 2.2 a walker above the block gets the normal shape" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "X1-POWDER-COLLISION" USING WS-A WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x1§2 2.2 a walker that is descending sinks" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X1-POWDER-COLLISION" USING WS-A WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x1§2 2.2 a walker not above the shape sinks" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X1-POWDER-COLLISION" USING WS-A WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x1§2 2.2 anyone else sinks" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3.9 TO WS-A
     MOVE 1 TO WS-N1
     CALL "X1-POWDER-LAND" USING WS-A WS-N1 WS-N2
     MOVE "acceptance US15 44-x1§2 2.2 landing below 4: no sound" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 4 TO WS-A
     MOVE 1 TO WS-N1
     CALL "X1-POWDER-LAND" USING WS-A WS-N1 WS-N2
     MOVE "acceptance US15 44-x1§2 2.2 landing at 4: the small sound" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 6.9 TO WS-A
     MOVE 1 TO WS-N1
     CALL "X1-POWDER-LAND" USING WS-A WS-N1 WS-N2
     MOVE "acceptance US15 44-x1§2 2.2 landing at 6.9: the small sound" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 7 TO WS-A
     MOVE 1 TO WS-N1
     CALL "X1-POWDER-LAND" USING WS-A WS-N1 WS-N2
     MOVE "acceptance US15 44-x1§2 2.2 landing at 7: the big sound" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 9 TO WS-A
     MOVE 0 TO WS-N1
     CALL "X1-POWDER-LAND" USING WS-A WS-N1 WS-N2
     MOVE "acceptance US15 44-x1§2 2.2 a non-living entity makes no sound" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-N1
     PERFORM 17 TIMES
         CALL "X1-BUBBLE-ABOVE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 above a push column: 17 ticks reach 1.7" TO WS-CASE
     MOVE 1700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-N1
     PERFORM 18 TIMES
         CALL "X1-BUBBLE-ABOVE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 above a push column: the 18th tick reaches the cap 1.8" TO WS-CASE
     MOVE 1800 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-N1
     PERFORM 25 TIMES
         CALL "X1-BUBBLE-ABOVE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 above a push column: it stays at 1.8" TO WS-CASE
     MOVE 1800 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 1 TO WS-N1
     PERFORM 29 TIMES
         CALL "X1-BUBBLE-ABOVE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 above a drag column: 29 ticks reach -0.87" TO WS-CASE
     MOVE -870 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 1 TO WS-N1
     PERFORM 30 TIMES
         CALL "X1-BUBBLE-ABOVE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 above a drag column: the 30th tick reaches the floor -0.9" TO WS-CASE
     MOVE -900 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 1 TO WS-N1
     PERFORM 40 TIMES
         CALL "X1-BUBBLE-ABOVE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 above a drag column: it stays at -0.9" TO WS-CASE
     MOVE -900 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-N1
     PERFORM 11 TIMES
         CALL "X1-BUBBLE-INSIDE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 inside a push column: 11 ticks reach 0.66" TO WS-CASE
     MOVE 660 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-N1
     PERFORM 12 TIMES
         CALL "X1-BUBBLE-INSIDE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 inside a push column: the 12th tick is capped at 0.7" TO WS-CASE
     MOVE 700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 1 TO WS-N1
     PERFORM 9 TIMES
         CALL "X1-BUBBLE-INSIDE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 inside a drag column: 9 ticks reach -0.27" TO WS-CASE
     MOVE -270 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 1 TO WS-N1
     PERFORM 10 TIMES
         CALL "X1-BUBBLE-INSIDE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 inside a drag column: the 10th tick reaches -0.3" TO WS-CASE
     MOVE -300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 1 TO WS-N1
     PERFORM 20 TIMES
         CALL "X1-BUBBLE-INSIDE" USING WS-N1 WS-A
     END-PERFORM
     MOVE "acceptance US15 44-x1§2 2.3 inside a drag column: it stays at -0.3" TO WS-CASE
     MOVE -300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X1-BUBBLE-STATE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x1§2 2.3 getColumnState: a column below is kept" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X1-BUBBLE-STATE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x1§2 2.3 getColumnState: a push-up source below makes drag_down false" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X1-BUBBLE-STATE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x1§2 2.3 getColumnState: a drag-down source below makes drag_down true" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X1-BUBBLE-STATE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x1§2 2.3 getColumnState: no source and a column here: plain water" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X1-BUBBLE-STATE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x1§2 2.3 getColumnState: otherwise the current state" TO WS-CASE
     MOVE 5 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     CALL "X1-BUBBLE-OCCUPY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x1§2 2.3 canOccupy: an existing column" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 8 TO WS-N5
     CALL "X1-BUBBLE-OCCUPY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x1§2 2.3 canOccupy: a full water source in a liquid block" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 7 TO WS-N5
     CALL "X1-BUBBLE-OCCUPY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x1§2 2.3 canOccupy: amount 7 does not qualify" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 8 TO WS-N5
     CALL "X1-BUBBLE-OCCUPY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x1§2 2.3 canOccupy: a waterlogged block (not a liquid block) does not qualify" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 8 TO WS-N5
     CALL "X1-BUBBLE-OCCUPY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x1§2 2.3 canOccupy: flowing water does not qualify" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 8 TO WS-N5
     CALL "X1-BUBBLE-OCCUPY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x1§2 2.3 canOccupy: a fluid outside bubble_column_can_occupy does not qualify" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A MOVE 0 TO WS-N1 MOVE 1 TO WS-N2
     CALL "X1-BUBBLE-AFFECT" USING WS-N1 WS-N2 WS-A
     MOVE "acceptance US15 44-x1§2 2.3 entityInside with free air above: the above handler (push +0.1)" TO WS-CASE
     MOVE 100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A MOVE 0 TO WS-N1 WS-N2
     CALL "X1-BUBBLE-AFFECT" USING WS-N1 WS-N2 WS-A
     MOVE "acceptance US15 44-x1§2 2.3 entityInside with water above: the inside handler (push +0.06)" TO WS-CASE
     MOVE 60 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X1-CAMPFIRE-DAMAGE" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x1§2 2.4 a lit campfire hurts a living entity for 1.0" TO WS-CASE
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X1-CAMPFIRE-DAMAGE" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x1§2 2.4 a lit soul campfire hurts for 2.0" TO WS-CASE
     MOVE 2000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X1-CAMPFIRE-DAMAGE" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x1§2 2.4 an unlit campfire does not hurt" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X1-CAMPFIRE-DAMAGE" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x1§2 2.4 a non-living entity is not hurt" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "X1-WEB-MULT" USING WS-N1 WS-A WS-B
     MOVE "acceptance US15 44-x1§2 2.4 cobweb multiplier x 0.25 and y 0.05" TO WS-CASE
     MOVE 250 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x1§2 2.4 cobweb y multiplier 0.05 (widened float, millionths)" TO WS-CASE
     MOVE 50000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     CALL "X1-WEB-MULT" USING WS-N1 WS-A WS-B
     MOVE "acceptance US15 44-x1§2 2.4 weaving: x 0.5" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x1§2 2.4 weaving: y 0.25" TO WS-CASE
     MOVE 250 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X1-2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(160).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
