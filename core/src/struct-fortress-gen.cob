*> Generated geometry tables of the nether fortress pieces (docs/protocol/36-structures-8-nether-and-end.md section 5): one line per operation of the document's lists, in order, run by SCP-RUN
*> (core/src/struct-scatter.cob). Ops: B x0 y0 z0 x1 y1 z1 spec (generateBox, one block for edge and fill); P spec x y z (placeBlock); F spec x0 z0 x1 z1 y (fillColumnDown per column).
*> The markers of the lists that need the piece's own state (the throne's spawner, the turn pieces' chest, the entrance's lava tick) are the program boundaries: a table ends where the marker was.
*> One program per piece class (registry id of 36-1 2.4) and segment: FORT-GEO-<id>[-<segment>] USING row.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-04.
*> BridgeCrossing (whole)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 7 3 0 11 4 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 3 7 18 4 11 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 8 5 0 10 7 18 air".
    05 FILLER              PIC X(100) VALUE "B 0 5 8 18 7 10 air".
    05 FILLER              PIC X(100) VALUE "B 7 5 0 7 5 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 7 5 11 7 5 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 11 5 0 11 5 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 11 5 11 11 5 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 5 7 7 5 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 11 5 7 18 5 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 5 11 7 5 11 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 11 5 11 18 5 11 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 7 2 0 11 2 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 7 2 13 11 2 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 7 0 0 11 1 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 7 0 15 11 1 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 7 0 11 2 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 7 16 11 18 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 7 2 11 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 16 7 18 11 -1".
    05 FILLER              PIC X(100) VALUE "B 0 2 7 5 2 11 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 13 2 7 18 2 11 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 0 7 3 1 11 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 15 0 7 18 1 11 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 7 0 11 2 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 7 16 11 18 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 7 2 11 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 16 7 18 11 -1".
 01 WS-COUNT               BINARY-LONG VALUE 28.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-04.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-06.
*> BridgeStraight (whole)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 3 0 4 4 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 5 0 3 7 18 air".
    05 FILLER              PIC X(100) VALUE "B 0 5 0 0 5 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 5 0 4 5 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 4 2 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 13 4 2 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 0 0 4 1 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 0 15 4 1 18 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 4 2 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 16 4 18 -1".
    05 FILLER              PIC X(100) VALUE "B 0 1 1 0 4 1 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 0 3 4 0 4 4 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 0 3 14 0 4 14 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 0 1 17 0 4 17 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 1 1 4 4 1 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 4 3 4 4 4 4 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 4 3 14 4 4 14 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 4 1 17 4 4 17 nether_brick_fence[north=true,south=true,west=true]".
 01 WS-COUNT               BINARY-LONG VALUE 18.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-06.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-07.
*> CastleCorridorStairsPiece (whole)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 0 0 4 7 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 8 0 3 12 0 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 1 8 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 2 8 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 3 8 0".
    05 FILLER              PIC X(100) VALUE "B 0 13 0 4 13 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 8 0 0 12 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 8 0 4 12 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 9 0 0 10 0 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 9 0 4 10 0 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 4 0 -1".
    05 FILLER              PIC X(100) VALUE "B 0 0 1 4 6 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 7 1 3 12 1 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 1 7 1".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 2 7 1".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 3 7 1".
    05 FILLER              PIC X(100) VALUE "B 0 13 1 4 13 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 7 1 0 12 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 7 1 4 12 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 1 4 1 -1".
    05 FILLER              PIC X(100) VALUE "B 0 0 2 4 5 2 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 6 2 3 11 2 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 1 6 2".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 2 6 2".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 3 6 2".
    05 FILLER              PIC X(100) VALUE "B 0 12 2 4 12 2 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 6 2 0 11 2 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 6 2 4 11 2 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 7 2 0 8 2 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 7 2 4 8 2 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 2 4 2 -1".
    05 FILLER              PIC X(100) VALUE "B 0 0 3 4 4 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 5 3 3 10 3 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 1 5 3".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 2 5 3".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 3 5 3".
    05 FILLER              PIC X(100) VALUE "B 0 11 3 4 11 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 5 3 0 10 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 5 3 4 10 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 3 4 3 -1".
    05 FILLER              PIC X(100) VALUE "B 0 0 4 4 3 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 4 4 3 9 4 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 1 4 4".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 2 4 4".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 3 4 4".
    05 FILLER              PIC X(100) VALUE "B 0 10 4 4 10 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 4 4 0 9 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 4 4 4 9 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 5 4 0 6 4 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 5 4 4 6 4 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 4 4 4 -1".
    05 FILLER              PIC X(100) VALUE "B 0 0 5 4 2 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 3 5 3 8 5 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 1 3 5".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 2 3 5".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 3 3 5".
    05 FILLER              PIC X(100) VALUE "B 0 9 5 4 9 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 3 5 0 8 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 3 5 4 8 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 5 4 5 -1".
    05 FILLER              PIC X(100) VALUE "B 0 0 6 4 1 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 2 6 3 7 6 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 1 2 6".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 2 2 6".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=south] 3 2 6".
    05 FILLER              PIC X(100) VALUE "B 0 8 6 4 8 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 6 0 7 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 2 6 4 7 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 3 6 0 4 6 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 3 6 4 4 6 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 6 4 6 -1".
    05 FILLER              PIC X(100) VALUE "B 0 0 7 4 1 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 2 7 3 6 7 air".
    05 FILLER              PIC X(100) VALUE "B 0 7 7 4 7 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 7 0 6 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 2 7 4 6 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 7 4 7 -1".
    05 FILLER              PIC X(100) VALUE "B 0 0 8 4 1 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 2 8 3 5 8 air".
    05 FILLER              PIC X(100) VALUE "B 0 6 8 4 6 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 8 0 5 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 2 8 4 5 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 3 8 0 4 8 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 3 8 4 4 8 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 8 4 8 -1".
    05 FILLER              PIC X(100) VALUE "B 0 0 9 4 1 9 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 2 9 3 5 9 air".
    05 FILLER              PIC X(100) VALUE "B 0 6 9 4 6 9 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 9 0 5 9 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 2 9 4 5 9 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 9 4 9 -1".
 01 WS-COUNT               BINARY-LONG VALUE 91.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-07.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-08.
*> CastleCorridorTBalconyPiece (whole)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 0 0 8 1 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 8 5 8 air".
    05 FILLER              PIC X(100) VALUE "B 0 6 0 8 6 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 2 5 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 6 2 0 8 5 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 3 0 1 4 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 7 3 0 7 4 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 2 4 8 2 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 1 4 2 2 4 air".
    05 FILLER              PIC X(100) VALUE "B 6 1 4 7 2 4 air".
    05 FILLER              PIC X(100) VALUE "B 1 3 8 7 3 8 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,south=true] 0 3 8".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[south=true,west=true] 8 3 8".
    05 FILLER              PIC X(100) VALUE "B 0 3 6 0 3 7 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 8 3 6 8 3 7 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 0 3 4 0 5 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 8 3 4 8 5 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 3 5 2 5 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 6 3 5 7 5 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 4 5 1 5 5 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 7 4 5 7 5 5 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 8 5 -1".
 01 WS-COUNT               BINARY-LONG VALUE 22.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-08.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-09-A.
*> CastleEntrance (segment A)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 3 0 12 4 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 5 0 12 13 12 air".
    05 FILLER              PIC X(100) VALUE "B 0 5 0 1 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 11 5 0 12 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 5 11 4 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 8 5 11 10 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 9 11 7 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 5 0 4 12 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 8 5 0 10 12 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 9 0 7 12 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 11 2 10 12 10 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 8 0 7 8 0 nether_brick_fence".
    05 FILLER              PIC X(100) VALUE "B 1 10 0 1 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 1 10 12 1 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 1 0 11 1 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 1 12 11 1 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 1 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 1 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 1".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 1".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 2 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 2 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 2".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 2".
    05 FILLER              PIC X(100) VALUE "B 3 10 0 3 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 3 10 12 3 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 3 0 11 3 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 3 12 11 3 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 3 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 3 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 3".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 3".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 4 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 4 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 4".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 4".
    05 FILLER              PIC X(100) VALUE "B 5 10 0 5 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 5 10 12 5 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 5 0 11 5 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 5 12 11 5 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 5 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 5 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 5".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 5".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 6 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 6 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 6".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 6".
    05 FILLER              PIC X(100) VALUE "B 7 10 0 7 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 7 10 12 7 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 7 0 11 7 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 7 12 11 7 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 7 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 7 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 7".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 7".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 8 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 8 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 8".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 8".
    05 FILLER              PIC X(100) VALUE "B 9 10 0 9 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 9 10 12 9 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 9 0 11 9 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 9 12 11 9 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 9 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 9 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 9".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 9".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 10 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 10 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 10".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 10".
    05 FILLER              PIC X(100) VALUE "B 11 10 0 11 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 10 12 11 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 11 0 11 11 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 11 12 11 11 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 11 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 11 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 11".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 11".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,east=true] 0 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,south=true] 0 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[south=true,west=true] 12 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,west=true] 12 13 0".
    05 FILLER              PIC X(100) VALUE "B 1 7 3 1 8 3 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 7 3 11 8 3 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 1 7 5 1 8 5 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 7 5 11 8 5 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 1 7 7 1 8 7 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 7 7 11 8 7 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 1 7 9 1 8 9 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 7 9 11 8 9 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 2 0 8 2 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 4 12 2 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 0 0 8 1 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 0 9 8 1 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 0 4 3 1 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 9 0 4 12 1 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 4 0 8 2 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 4 10 8 12 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 4 2 8 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 10 4 12 8 -1".
    05 FILLER              PIC X(100) VALUE "B 5 5 5 7 5 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 6 1 6 6 4 6 air".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 6 0 6".
    05 FILLER              PIC X(100) VALUE "P lava 6 5 6".
 01 WS-COUNT               BINARY-LONG VALUE 106.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-09-A.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-10.
*> CastleSmallCorridorCrossingPiece (whole)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 0 0 4 1 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 4 5 4 air".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 0 5 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 2 0 4 5 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 4 0 5 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 2 4 4 5 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 6 0 4 6 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 4 4 -1".
 01 WS-COUNT               BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-10.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-11-A.
*> CastleSmallCorridorLeftTurnPiece (segment A)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 0 0 4 1 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 4 5 4 air".
    05 FILLER              PIC X(100) VALUE "B 4 2 0 4 5 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 3 1 4 4 1 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 3 3 4 4 3 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 0 5 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 4 3 5 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 3 4 1 4 4 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 3 3 4 3 4 4 nether_brick_fence[east=true,west=true]".
 01 WS-COUNT               BINARY-LONG VALUE 9.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-11-A.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-11-B.
*> CastleSmallCorridorLeftTurnPiece (segment B)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 6 0 4 6 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 4 4 -1".
 01 WS-COUNT               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-11-B.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-12.
*> CastleSmallCorridorPiece (whole)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 0 0 4 1 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 4 5 4 air".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 0 5 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 2 0 4 5 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 3 1 0 4 1 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 0 3 3 0 4 3 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 3 1 4 4 1 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 3 3 4 4 3 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 0 6 0 4 6 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 4 4 -1".
 01 WS-COUNT               BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-12.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-13-A.
*> CastleSmallCorridorRightTurnPiece (segment A)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 0 0 4 1 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 4 5 4 air".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 0 5 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 3 1 0 4 1 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 0 3 3 0 4 3 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 4 2 0 4 5 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 2 4 4 5 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 3 4 1 4 4 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 3 3 4 3 4 4 nether_brick_fence[east=true,west=true]".
 01 WS-COUNT               BINARY-LONG VALUE 9.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-13-A.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-13-B.
*> CastleSmallCorridorRightTurnPiece (segment B)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 6 0 4 6 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 4 4 -1".
 01 WS-COUNT               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-13-B.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-14.
*> CastleStalkRoom (whole)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 3 0 12 4 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 5 0 12 13 12 air".
    05 FILLER              PIC X(100) VALUE "B 0 5 0 1 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 11 5 0 12 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 5 11 4 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 8 5 11 10 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 9 11 7 12 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 5 0 4 12 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 8 5 0 10 12 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 9 0 7 12 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 11 2 10 12 10 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 10 0 1 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 1 10 12 1 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 1 0 11 1 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 1 12 11 1 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 1 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 1 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 1".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 1".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 2 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 2 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 2".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 2".
    05 FILLER              PIC X(100) VALUE "B 3 10 0 3 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 3 10 12 3 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 3 0 11 3 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 3 12 11 3 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 3 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 3 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 3".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 3".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 4 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 4 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 4".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 4".
    05 FILLER              PIC X(100) VALUE "B 5 10 0 5 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 5 10 12 5 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 5 0 11 5 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 5 12 11 5 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 5 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 5 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 5".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 5".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 6 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 6 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 6".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 6".
    05 FILLER              PIC X(100) VALUE "B 7 10 0 7 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 7 10 12 7 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 7 0 11 7 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 7 12 11 7 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 7 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 7 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 7".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 7".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 8 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 8 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 8".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 8".
    05 FILLER              PIC X(100) VALUE "B 9 10 0 9 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 9 10 12 9 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 9 0 11 9 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 9 12 11 9 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 9 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 9 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 9".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 9".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 10 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 10 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 0 13 10".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,south=true] 12 13 10".
    05 FILLER              PIC X(100) VALUE "B 11 10 0 11 11 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 10 12 11 11 12 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 10 11 0 11 11 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 12 10 11 12 11 11 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 11 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 11 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 0 13 11".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 12 13 11".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,east=true] 0 13 0".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,south=true] 0 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[south=true,west=true] 12 13 12".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,west=true] 12 13 0".
    05 FILLER              PIC X(100) VALUE "B 1 7 3 1 8 3 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 7 3 11 8 3 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 1 7 5 1 8 5 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 7 5 11 8 5 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 1 7 7 1 8 7 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 7 7 11 8 7 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 1 7 9 1 8 9 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 11 7 9 11 8 9 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 5 5 4".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 6 5 4".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 7 5 4".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 5 6 5".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 6 6 5".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 7 6 5".
    05 FILLER              PIC X(100) VALUE "B 5 5 5 7 5 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 7 5 7 10 5 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 5 7 6".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 6 7 6".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 7 7 6".
    05 FILLER              PIC X(100) VALUE "B 5 5 6 7 6 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 8 6 7 11 6 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 5 8 7".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 6 8 7".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 7 8 7".
    05 FILLER              PIC X(100) VALUE "B 5 5 7 7 7 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 9 7 7 12 7 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 5 9 8".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 6 9 8".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 7 9 8".
    05 FILLER              PIC X(100) VALUE "B 5 5 8 7 8 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 10 8 7 13 8 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 5 10 9".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 6 10 9".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 7 10 9".
    05 FILLER              PIC X(100) VALUE "B 5 8 9 7 9 9 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 11 9 7 14 9 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 5 11 10".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 6 11 10".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 7 11 10".
    05 FILLER              PIC X(100) VALUE "B 5 8 10 7 10 10 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 12 10 7 15 10 air".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 5 12 11".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 6 12 11".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=north] 7 12 11".
    05 FILLER              PIC X(100) VALUE "B 5 6 7 5 7 7 nether_brick_fence[north=true,east=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 7 6 7 7 7 7 nether_brick_fence[north=true,south=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 5 13 12 7 13 12 air".
    05 FILLER              PIC X(100) VALUE "B 2 5 2 3 5 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 5 9 3 5 10 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 5 4 2 5 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 9 5 2 10 5 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 9 5 9 10 5 10 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 10 5 4 10 5 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=west] 4 5 2".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=west] 4 5 3".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=west] 4 5 9".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=west] 4 5 10".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=east] 8 5 2".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=east] 8 5 3".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=east] 8 5 9".
    05 FILLER              PIC X(100) VALUE "P nether_brick_stairs[facing=east] 8 5 10".
    05 FILLER              PIC X(100) VALUE "B 3 4 4 4 4 8 soul_sand".
    05 FILLER              PIC X(100) VALUE "B 8 4 4 9 4 8 soul_sand".
    05 FILLER              PIC X(100) VALUE "B 3 5 4 4 5 8 nether_wart".
    05 FILLER              PIC X(100) VALUE "B 8 5 4 9 5 8 nether_wart".
    05 FILLER              PIC X(100) VALUE "B 4 2 0 8 2 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 4 12 2 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 0 0 8 1 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 4 0 9 8 1 12 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 0 4 3 1 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 9 0 4 12 1 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 4 0 8 2 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 4 10 8 12 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 4 2 8 -1".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 10 4 12 8 -1".
 01 WS-COUNT               BINARY-LONG VALUE 158.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-14.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-15-A.
*> MonsterThrone (segment A)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 2 0 6 7 7 air".
    05 FILLER              PIC X(100) VALUE "B 1 0 0 5 1 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 2 1 5 2 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 3 2 5 3 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 4 3 5 4 7 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 2 0 1 4 2 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 2 0 5 4 2 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 5 2 1 5 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 5 2 5 5 3 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 5 3 0 5 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 6 5 3 6 5 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 5 8 5 5 8 nether_bricks".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[west=true] 1 6 3".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true] 5 6 3".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,east=true] 0 6 3".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[north=true,west=true] 6 6 3".
    05 FILLER              PIC X(100) VALUE "B 0 6 4 0 6 7 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 6 6 4 6 6 7 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,south=true] 0 6 8".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[south=true,west=true] 6 6 8".
    05 FILLER              PIC X(100) VALUE "B 1 6 8 5 6 8 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true] 1 7 8".
    05 FILLER              PIC X(100) VALUE "B 2 7 8 4 7 8 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[west=true] 5 7 8".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true] 2 8 8".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[east=true,west=true] 3 8 8".
    05 FILLER              PIC X(100) VALUE "P nether_brick_fence[west=true] 4 8 8".
 01 WS-COUNT               BINARY-LONG VALUE 27.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-15-A.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-15-B.
*> MonsterThrone (segment B)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 6 6 -1".
 01 WS-COUNT               BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-15-B.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-16.
*> RoomCrossing (whole)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 0 0 6 1 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 6 7 6 air".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 1 6 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 6 1 6 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 2 0 6 6 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 2 6 6 6 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 0 6 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 5 0 6 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 6 2 0 6 6 1 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 6 2 5 6 6 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 6 0 4 6 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 5 0 4 5 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 2 6 6 4 6 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 5 6 4 5 6 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "B 0 6 2 0 6 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 5 2 0 5 4 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 6 6 2 6 6 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 6 5 2 6 5 4 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 6 6 -1".
 01 WS-COUNT               BINARY-LONG VALUE 19.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-16.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FORT-GEO-17.
*> StairsRoom (whole)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPS.
    05 FILLER              PIC X(100) VALUE "B 0 0 0 6 1 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 6 10 6 air".
    05 FILLER              PIC X(100) VALUE "B 0 2 0 1 8 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 5 2 0 6 8 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 2 1 0 8 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 6 2 1 6 8 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 2 6 5 8 6 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 0 3 2 0 5 4 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 6 3 2 6 5 2 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "B 6 3 4 6 5 4 nether_brick_fence[north=true,south=true]".
    05 FILLER              PIC X(100) VALUE "P nether_bricks 5 2 5".
    05 FILLER              PIC X(100) VALUE "B 4 2 5 4 3 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 3 2 5 3 4 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 2 5 2 5 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 2 5 1 6 5 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 1 7 1 5 7 4 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 6 8 2 6 8 4 air".
    05 FILLER              PIC X(100) VALUE "B 2 6 0 4 8 0 nether_bricks".
    05 FILLER              PIC X(100) VALUE "B 2 5 0 4 5 0 nether_brick_fence[east=true,west=true]".
    05 FILLER              PIC X(100) VALUE "F nether_bricks 0 0 6 6 -1".
 01 WS-COUNT               BINARY-LONG VALUE 20.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "SCP-RUN" USING L-ROW WS-OPS WS-COUNT
     GOBACK.
 END PROGRAM FORT-GEO-17.
