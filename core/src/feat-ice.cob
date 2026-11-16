*> The blue ice feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 10; registry id 4, blue_ice): FD-ICE-NODE takes the row of FD-WA (WA-I(1) the block index of packed_ice, WA-I(2) of ice,
*> WA-I(3) of blue_ice; FD-BAD when the table lacks one), FR-ICE places it: no origin above sea level - 1; the origin must be water or have water below, and one of up, north, south, west, east must be
*> packed_ice; blue ice (default state, flag 2) is written there, then 200 attempts: dy = nextInt(5) - nextInt(6), spread 3 (+ dy / 2 truncated toward zero when dy < 2, skipped when below 1), the offset
*> (nextInt(spread) - nextInt(spread), dy, nextInt(spread) - nextInt(spread)); an air, water, packed_ice or ice cell there with a blue_ice neighbour (down, up, north, south, west, east) becomes blue ice.
*>
*> Entry points: FD-ICE-NODE USING doc, node, row out; FR-ICE USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-ICE-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NAME                PIC X(48).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     MOVE "minecraft:packed_ice" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 1)
     MOVE "minecraft:ice" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 2)
     MOVE "minecraft:blue_ice" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 3)
     IF WA-I(WS-ROW, 1) = 0 OR WA-I(WS-ROW, 2) = 0 OR WA-I(WS-ROW, 3) = 0
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-ICE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ICE.
*> USING state, feature, x, y, z, result out (1 when the origin took blue ice).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CBLOCKS.
 COPY FEATLEVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLUE-STATE          BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG.
 01 WS-QUOT                BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-B6                  BINARY-LONG VALUE 6.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-SEA-LIMIT           BINARY-LONG.
 01 WS-BELOW-WATER         BINARY-LONG.
 01 WS-HERE-WATER          BINARY-LONG.
 01 WS-DIRS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR6 OCCURS 6 TIMES.
       10 WS-DDX           BINARY-LONG.
       10 WS-DDY           BINARY-LONG.
       10 WS-DDZ           BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     COMPUTE WS-SEA-LIMIT = FL-SEA - 1
     IF L-Y > WS-SEA-LIMIT
         GOBACK
     END-IF
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     MOVE 0 TO WS-HERE-WATER WS-BELOW-WATER
     IF WS-CLASS = 2
         MOVE 1 TO WS-HERE-WATER
     END-IF
     COMPUTE WS-Y = L-Y - 1
     CALL "FL-GET-STATE" USING L-X WS-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS = 2
         MOVE 1 TO WS-BELOW-WATER
     END-IF
     IF WS-HERE-WATER = 0 AND WS-BELOW-WATER = 0
         GOBACK
     END-IF
*>   a packed_ice neighbour among up, north, south, west, east
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 6
         COMPUTE WS-QX = L-X + WS-DDX(WS-K)
         COMPUTE WS-QY = L-Y + WS-DDY(WS-K)
         COMPUTE WS-QZ = L-Z + WS-DDZ(WS-K)
         CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         IF WS-BLOCK = WA-I(WS-ROW, 1)
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         GOBACK
     END-IF
     MOVE WA-I(WS-ROW, 3) TO WS-BLOCK
     MOVE CB-DEFAULT-STATE(WS-BLOCK) TO WS-BLUE-STATE
     CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-BLUE-STATE WS-FLAGS WS-WRITTEN
     PERFORM 200 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-A1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B6 WS-A2
         COMPUTE WS-DY = WS-A1 - WS-A2
         MOVE 3 TO WS-SPREAD
         IF WS-DY < 2
             DIVIDE WS-DY BY 2 GIVING WS-QUOT
             COMPUTE WS-SPREAD = 3 + WS-QUOT
         END-IF
         IF WS-SPREAD >= 1
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SPREAD WS-A1
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SPREAD WS-A2
             COMPUTE WS-X = L-X + WS-A1 - WS-A2
             COMPUTE WS-Y = L-Y + WS-DY
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SPREAD WS-A1
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SPREAD WS-A2
             COMPUTE WS-Z = L-Z + WS-A1 - WS-A2
             CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF WS-CLASS = 1 OR WS-CLASS = 2 OR WS-BLOCK = WA-I(WS-ROW, 1) OR WS-BLOCK = WA-I(WS-ROW, 2)
                 MOVE 0 TO WS-FOUND
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6 OR WS-FOUND = 1
                     COMPUTE WS-QX = WS-X + WS-DDX(WS-K)
                     COMPUTE WS-QY = WS-Y + WS-DDY(WS-K)
                     COMPUTE WS-QZ = WS-Z + WS-DDZ(WS-K)
                     CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     IF WS-BLOCK = WA-I(WS-ROW, 3)
                         MOVE 1 TO WS-FOUND
                         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-BLUE-STATE WS-FLAGS WS-WRITTEN
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-ICE.
