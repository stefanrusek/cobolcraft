*> The huge mushrooms (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 11.1 to 11.4; registry ids 21 huge_brown_mushroom and 23 huge_red_mushroom):
*> FD-MUSH-NODE USING doc, node, kind (1 brown, 2 red), row out takes a row of FD-WA: WA-PV(1) cap_provider, WA-PV(2) stem_provider, WA-I(1) foliage_radius (2), WA-I(2) the kind, WA-PR(1)
*> can_place_on, the pool 1 the tag leaves and the pool 2 the tag replaceable_by_mushrooms (FD-BAD when a tag or a member is missing). FR-MUSH places one: H = 4 + nextInt(3), doubled when
*> nextInt(12) is 0; the checks of 11.1 step 2 (height limits, can_place_on below, every layer's cells air or leaves, brown radius 0 up to layer 3 then foliage_radius, red radius 0); the
*> brown cap (one layer at H, corners left out, the four side properties by the rules of 11.2) or the red cap (four layers, 11.3); then the stem of H blocks (the stem provider asked about the
*> origin for every cell). A mushroom block is placed (flags 3) only over air or a block of replaceable_by_mushrooms. The cap state gets west, east, north, south (and up for the red cap)
*> only when the provider's state has all of them (FD-STATE-SET by name). Doc gap, recorded: the document names no property of the stem state to set and none of the cap's down; the data's
*> providers carry them whole (down false), so they are placed as given. huge_fungus (11.5) is not done here.
*>
*> Entry points: FD-MUSH-NODE; FR-MUSH USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-MUSH-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-K-CAP               PIC X(40) VALUE "cap_provider".
 01 WS-K-STEM              PIC X(40) VALUE "stem_provider".
 01 WS-K-RADIUS            PIC X(40) VALUE "foliage_radius".
 01 WS-K-PLACE             PIC X(40) VALUE "can_place_on".
 01 WS-TAG-LEAVES          PIC X(112) VALUE "minecraft:leaves".
 01 WS-TAG-REPL            PIC X(112) VALUE "minecraft:replaceable_by_mushrooms".
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KIND L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     MOVE L-KIND TO WA-I(WS-ROW, 2)
     MOVE 2 TO WA-I(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CAP WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-STEM WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RADIUS WS-E
     IF WS-E > 0
         CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 1) WS-OK
         IF WS-OK = 0 OR WA-I(WS-ROW, 1) < 1
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-PLACE WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 1)
     COMPUTE WA-START(WS-ROW, 1) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-LEAVES WA-N(WS-ROW, 1)
     COMPUTE WA-START(WS-ROW, 2) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-REPL WA-N(WS-ROW, 2)
     GOBACK.
 END PROGRAM FD-MUSH-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-MUSH.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-R0                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-B12                 BINARY-LONG VALUE 12.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 01 WS-NRAD                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-PV                  BINARY-LONG.
 01 WS-CAP                 BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-SRC-OUT             BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-XMIN                BINARY-LONG.
 01 WS-XMAX                BINARY-LONG.
 01 WS-ZMIN                BINARY-LONG.
 01 WS-ZMAX                BINARY-LONG.
 01 WS-ONX                 BINARY-LONG.
 01 WS-ONZ                 BINARY-LONG.
 01 WS-WEST                BINARY-LONG.
 01 WS-EAST                BINARY-LONG.
 01 WS-NORTH               BINARY-LONG.
 01 WS-SOUTH               BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-ABS-X               BINARY-LONG.
 01 WS-ABS-Z               BINARY-LONG.
 01 WS-CELL-X              BINARY-LONG.
 01 WS-CELL-Y              BINARY-LONG.
 01 WS-CELL-Z              BINARY-LONG.
 01 WS-TRUE                PIC X(40) VALUE "true".
 01 WS-FALSE               PIC X(40) VALUE "false".
 01 WS-K-WEST              PIC X(40) VALUE "west".
 01 WS-K-EAST              PIC X(40) VALUE "east".
 01 WS-K-NORTH             PIC X(40) VALUE "north".
 01 WS-K-SOUTH             PIC X(40) VALUE "south".
 01 WS-K-UP                PIC X(40) VALUE "up".
 01 WS-I                   BINARY-LONG.
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
     MOVE WA-I(WS-ROW, 2) TO WS-KIND
     MOVE WA-I(WS-ROW, 1) TO WS-R0
*>   1. the height
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B3 WS-DRAW
     COMPUTE WS-H = 4 + WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B12 WS-DRAW
     IF WS-DRAW = 0
         COMPUTE WS-H = WS-H * 2
     END-IF
*>   2. isValidPosition
     COMPUTE WS-MAXY = FL-MIN-Y + FL-HEIGHT - 1
     IF L-Y < FL-MIN-Y + 1 OR L-Y + WS-H + 1 > WS-MAXY
         GOBACK
     END-IF
     COMPUTE WS-YB = L-Y - 1
     CALL "FR-PRED-TEST" USING WA-PR(WS-ROW, 1) L-X WS-YB L-Z WS-TEST
     IF WS-TEST = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-LAYER FROM 0 BY 1 UNTIL WS-LAYER > WS-H
         MOVE 0 TO WS-RAD
         IF WS-KIND = 1 AND WS-LAYER > 3
             MOVE WS-R0 TO WS-RAD
         END-IF
         COMPUTE WS-NRAD = 0 - WS-RAD
         PERFORM VARYING WS-DX FROM WS-NRAD BY 1 UNTIL WS-DX > WS-RAD
             PERFORM VARYING WS-DZ FROM WS-NRAD BY 1 UNTIL WS-DZ > WS-RAD
                 COMPUTE WS-CELL-X = L-X + WS-DX
                 COMPUTE WS-CELL-Y = L-Y + WS-LAYER
                 COMPUTE WS-CELL-Z = L-Z + WS-DZ
                 CALL "FL-GET-STATE" USING WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STATE
                 CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 IF WS-CLASS NOT = 1
                     CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 1) WA-N(WS-ROW, 1) WS-BLOCK WS-FLAG
                     IF WS-FLAG = 0
                         GOBACK
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   3. the cap, then the trunk
     IF WS-KIND = 1
         PERFORM BROWN-CAP
     ELSE
         PERFORM RED-CAP
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-H
         MOVE WA-PV(WS-ROW, 2) TO WS-PV
         CALL "FR-PROV-STATE" USING L-STATE WS-PV L-X L-Y L-Z WS-CAP WS-OK
         IF WS-OK = 1
             COMPUTE WS-CELL-X = L-X
             COMPUTE WS-CELL-Y = L-Y + WS-I
             COMPUTE WS-CELL-Z = L-Z
             PERFORM PLACE-MUSHROOM-BLOCK
         END-IF
     END-PERFORM
     MOVE 1 TO L-RESULT
     GO TO MAIN-EXIT.
*> PLACE-MUSHROOM-BLOCK: WS-CAP at (WS-CELL-X, WS-CELL-Y, WS-CELL-Z) when the block there is air or in replaceable_by_mushrooms (flags 3)
 PLACE-MUSHROOM-BLOCK.
     CALL "FL-GET-STATE" USING WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE 1 TO WS-FLAG
     IF WS-CLASS NOT = 1
         CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 2) WA-N(WS-ROW, 2) WS-BLOCK WS-FLAG
     END-IF
     IF WS-FLAG = 1
         CALL "FL-SET-STATE" USING WS-CELL-X WS-CELL-Y WS-CELL-Z WS-CAP WS-FLAGS WS-WRITTEN
     END-IF
     .
*> SET-SIDES: the cap state of the provider at the origin with west, east, north, south (and up for the red cap) put over it, when it has them all; placed at the cell
 SET-SIDES.
     MOVE WA-PV(WS-ROW, 1) TO WS-PV
     CALL "FR-PROV-STATE" USING L-STATE WS-PV L-X L-Y L-Z WS-CAP WS-OK
     IF WS-OK = 0
         EXIT PARAGRAPH
     END-IF
     MOVE WS-CAP TO WS-SRC
     MOVE 1 TO WS-HAS
     PERFORM SET-ONE-WEST
     PERFORM SET-ONE-EAST
     PERFORM SET-ONE-NORTH
     PERFORM SET-ONE-SOUTH
     IF WS-KIND = 2
         PERFORM SET-ONE-UP
     END-IF
     IF WS-HAS = 1
         MOVE WS-SRC TO WS-CAP
     END-IF
     PERFORM PLACE-MUSHROOM-BLOCK
     .
 SET-ONE-WEST.
     IF WS-WEST = 1
         CALL "FD-STATE-SET" USING WS-SRC WS-K-WEST WS-TRUE WS-SRC-OUT WS-FOUND
     ELSE
         CALL "FD-STATE-SET" USING WS-SRC WS-K-WEST WS-FALSE WS-SRC-OUT WS-FOUND
     END-IF
     MOVE WS-SRC-OUT TO WS-SRC
     IF WS-FOUND = 0
         MOVE 0 TO WS-HAS
     END-IF
     .
 SET-ONE-EAST.
     IF WS-EAST = 1
         CALL "FD-STATE-SET" USING WS-SRC WS-K-EAST WS-TRUE WS-SRC-OUT WS-FOUND
     ELSE
         CALL "FD-STATE-SET" USING WS-SRC WS-K-EAST WS-FALSE WS-SRC-OUT WS-FOUND
     END-IF
     MOVE WS-SRC-OUT TO WS-SRC
     IF WS-FOUND = 0
         MOVE 0 TO WS-HAS
     END-IF
     .
 SET-ONE-NORTH.
     IF WS-NORTH = 1
         CALL "FD-STATE-SET" USING WS-SRC WS-K-NORTH WS-TRUE WS-SRC-OUT WS-FOUND
     ELSE
         CALL "FD-STATE-SET" USING WS-SRC WS-K-NORTH WS-FALSE WS-SRC-OUT WS-FOUND
     END-IF
     MOVE WS-SRC-OUT TO WS-SRC
     IF WS-FOUND = 0
         MOVE 0 TO WS-HAS
     END-IF
     .
 SET-ONE-SOUTH.
     IF WS-SOUTH = 1
         CALL "FD-STATE-SET" USING WS-SRC WS-K-SOUTH WS-TRUE WS-SRC-OUT WS-FOUND
     ELSE
         CALL "FD-STATE-SET" USING WS-SRC WS-K-SOUTH WS-FALSE WS-SRC-OUT WS-FOUND
     END-IF
     MOVE WS-SRC-OUT TO WS-SRC
     IF WS-FOUND = 0
         MOVE 0 TO WS-HAS
     END-IF
     .
 SET-ONE-UP.
     IF WS-UP = 1
         CALL "FD-STATE-SET" USING WS-SRC WS-K-UP WS-TRUE WS-SRC-OUT WS-FOUND
     ELSE
         CALL "FD-STATE-SET" USING WS-SRC WS-K-UP WS-FALSE WS-SRC-OUT WS-FOUND
     END-IF
     MOVE WS-SRC-OUT TO WS-SRC
     IF WS-FOUND = 0
         MOVE 0 TO WS-HAS
     END-IF
     .
*> BROWN-CAP (11.2): one layer at y = H over the square of radius R without its corners
 BROWN-CAP.
     COMPUTE WS-CELL-Y = L-Y + WS-H
     COMPUTE WS-NRAD = 0 - WS-R0
     PERFORM VARYING WS-DX FROM WS-NRAD BY 1 UNTIL WS-DX > WS-R0
         PERFORM VARYING WS-DZ FROM WS-NRAD BY 1 UNTIL WS-DZ > WS-R0
             MOVE 0 TO WS-XMIN WS-XMAX WS-ZMIN WS-ZMAX WS-ONX WS-ONZ
             IF WS-DX = WS-NRAD
                 MOVE 1 TO WS-XMIN
             END-IF
             IF WS-DX = WS-R0
                 MOVE 1 TO WS-XMAX
             END-IF
             IF WS-DZ = WS-NRAD
                 MOVE 1 TO WS-ZMIN
             END-IF
             IF WS-DZ = WS-R0
                 MOVE 1 TO WS-ZMAX
             END-IF
             IF WS-XMIN = 1 OR WS-XMAX = 1
                 MOVE 1 TO WS-ONX
             END-IF
             IF WS-ZMIN = 1 OR WS-ZMAX = 1
                 MOVE 1 TO WS-ONZ
             END-IF
             IF NOT (WS-ONX = 1 AND WS-ONZ = 1)
                 MOVE 0 TO WS-WEST WS-EAST WS-NORTH WS-SOUTH
                 IF WS-XMIN = 1 OR (WS-ONZ = 1 AND WS-DX = 1 - WS-R0)
                     MOVE 1 TO WS-WEST
                 END-IF
                 IF WS-XMAX = 1 OR (WS-ONZ = 1 AND WS-DX = WS-R0 - 1)
                     MOVE 1 TO WS-EAST
                 END-IF
                 IF WS-ZMIN = 1 OR (WS-ONX = 1 AND WS-DZ = 1 - WS-R0)
                     MOVE 1 TO WS-NORTH
                 END-IF
                 IF WS-ZMAX = 1 OR (WS-ONX = 1 AND WS-DZ = WS-R0 - 1)
                     MOVE 1 TO WS-SOUTH
                 END-IF
                 COMPUTE WS-CELL-X = L-X + WS-DX
                 COMPUTE WS-CELL-Z = L-Z + WS-DZ
                 PERFORM SET-SIDES
             END-IF
         END-PERFORM
     END-PERFORM
     .
*> RED-CAP (11.3): four layers from H - 3 to H
 RED-CAP.
     COMPUTE WS-INNER = WS-R0 - 2
     COMPUTE WS-LAYER = WS-H - 3
     PERFORM UNTIL WS-LAYER > WS-H
         IF WS-LAYER < WS-H
             MOVE WS-R0 TO WS-RAD
         ELSE
             COMPUTE WS-RAD = WS-R0 - 1
         END-IF
         COMPUTE WS-NRAD = 0 - WS-RAD
         COMPUTE WS-CELL-Y = L-Y + WS-LAYER
         PERFORM VARYING WS-DX FROM WS-NRAD BY 1 UNTIL WS-DX > WS-RAD
             PERFORM VARYING WS-DZ FROM WS-NRAD BY 1 UNTIL WS-DZ > WS-RAD
                 COMPUTE WS-ABS-X = FUNCTION ABS(WS-DX)
                 COMPUTE WS-ABS-Z = FUNCTION ABS(WS-DZ)
                 MOVE 0 TO WS-ONX WS-ONZ
                 IF WS-ABS-X = WS-RAD
                     MOVE 1 TO WS-ONX
                 END-IF
                 IF WS-ABS-Z = WS-RAD
                     MOVE 1 TO WS-ONZ
                 END-IF
                 IF WS-LAYER >= WS-H OR WS-ONX NOT = WS-ONZ
                     MOVE 0 TO WS-UP WS-WEST WS-EAST WS-NORTH WS-SOUTH
                     IF WS-LAYER >= WS-H - 1
                         MOVE 1 TO WS-UP
                     END-IF
                     IF WS-DX < 0 - WS-INNER
                         MOVE 1 TO WS-WEST
                     END-IF
                     IF WS-DX > WS-INNER
                         MOVE 1 TO WS-EAST
                     END-IF
                     IF WS-DZ < 0 - WS-INNER
                         MOVE 1 TO WS-NORTH
                     END-IF
                     IF WS-DZ > WS-INNER
                         MOVE 1 TO WS-SOUTH
                     END-IF
                     COMPUTE WS-CELL-X = L-X + WS-DX
                     COMPUTE WS-CELL-Z = L-Z + WS-DZ
                     PERFORM SET-SIDES
                 END-IF
             END-PERFORM
         END-PERFORM
         ADD 1 TO WS-LAYER
     END-PERFORM
     .
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM FR-MUSH.
