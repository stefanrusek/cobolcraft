*> Implementation test, lane bugtorchblack (operator report of try15: "torches with a block above them render black; break the block above and they look right"; docs/protocol/12 sections 1.3 and
*> 1.6: a quad that is not on the border of its block (and a block that is not a full cube) takes the light of its own cell, B = P, not of the neighbour in the direction of the face, and 1.4: a
*> state's emission raises the block light read). A wall torch and a standing torch (hand-made thin models, client/tests/fixtures/mini-torch) in a cell under a stone ceiling and against a stone wall,
*> with the light the core stores (block 14 at the torch cell, 13 around it, sky 0 in the sealed space): every vertex of the torch's six quads draws at 0.4 or more at full daylight (the stone faces
*> the quads used to look into hold no light, so they were drawn at the 0.1 floor), and the torch has its 36 vertices.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-TORCH-LIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-BIG                 BINARY-LONG VALUE 64.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-KEYSTR              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STONE               BINARY-LONG.
 01 WS-WALL-TORCH          BINARY-LONG.
 01 WS-TORCH               BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-VERTS               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-BR                  FLOAT-LONG.
 01 WS-ODD                 BINARY-LONG.
 01 WS-MINBR               FLOAT-LONG.
 01 WS-SHOWN               PIC 9.99.
 01 B-VERTICES BASED.
    05 B-VERTEX OCCURS 150000 TIMES.
       10 B-X              FLOAT-SHORT.
       10 B-Y              FLOAT-SHORT.
       10 B-Z              FLOAT-SHORT.
       10 B-U              FLOAT-SHORT.
       10 B-V              FLOAT-SHORT.
       10 B-B              FLOAT-SHORT.
       10 B-ALPHA          FLOAT-SHORT.
       10 B-SKY            FLOAT-SHORT.
       10 B-R              FLOAT-SHORT.
       10 B-G              FLOAT-SHORT.
       10 B-BLUE           FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-torch" TO PK-ROOT(PK-COUNT)
     MOVE 32 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 0 TO ST-READY MB-CREDIT-ON
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 384 TO PL-HEIGHT
     MOVE -64 TO PL-MIN-Y
     MOVE 1 TO PL-HAS-SKY
     MOVE 1000 TO SK-U
     MOVE 1 TO MB-FAKE
     MOVE 0 TO MB-FAKE-STEP MB-FAKE-NOW
     MOVE 1000000000 TO MB-BUDGET-US
     MOVE "stone" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STONE WS-STATUS
     MOVE "torch" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-TORCH WS-STATUS
     MOVE "wall_torch" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-WALL-TORCH WS-STATUS

*>   A wall torch at (5, 5, 5) on the stone at (4, 5, 5), under a stone ceiling slab (x, z 3 to 8, y 6), with the light the core stores.
     PERFORM CLEAR-WORLD
     MOVE 5 TO WS-X WS-Y WS-Z
     COMPUTE WS-WY = WS-Y + PL-MIN-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-WALL-TORCH
     MOVE 4 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-STONE
     PERFORM PUT-CEILING
     PERFORM PUT-LIGHT
     PERFORM MESH-ALL
     PERFORM MEASURE-TORCH
     MOVE "N" TO TL-MODE
     MOVE "mesher torch light a wall torch under a ceiling and on a wall has its 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE WS-VERTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mesher torch light no vertex of a wall torch under a ceiling is drawn dim (the stone it looked into holds no light)"
         TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A standing torch at (5, 5, 5) on stone at (5, 4, 5) under the ceiling.
     PERFORM CLEAR-WORLD
     MOVE 5 TO WS-X WS-Y WS-Z
     COMPUTE WS-WY = WS-Y + PL-MIN-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-TORCH
     MOVE 4 TO WS-Y
     COMPUTE WS-WY = WS-Y + PL-MIN-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-STONE
     PERFORM PUT-CEILING
     PERFORM PUT-LIGHT
*>   The stone floor holds no light (the core stores 0 in an opaque cell).
     MOVE 0 TO WS-L
     CALL "LIGHT-SET" USING WR-ADDR(WS-ROW) WS-K WS-Y WS-X WS-Z WS-L
     PERFORM MESH-ALL
     PERFORM MEASURE-TORCH
     MOVE "mesher torch light a standing torch under a ceiling has its 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE WS-VERTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The bottom quad of the standing torch lies flat on the border of its cell, so it keeps the light of the stone floor it is flush with (0): the six vertices nobody sees.
     MOVE "mesher torch light only the bottom quad of a standing torch (flush with the floor) is dim" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-DIM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The stone slab x, z 3 to 8 at y 6.
 PUT-CEILING.
     MOVE 6 TO WS-Y
     COMPUTE WS-WY = WS-Y + PL-MIN-Y
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Z FROM 3 BY 1 UNTIL WS-Z > 8
             CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-STONE
         END-PERFORM
     END-PERFORM.

*> Block light 14 at (5, 5, 5), 13 in the four air cells and the one below around it (what the core stores for a torch there); sky light 0 (the core's value in a sealed space).
 PUT-LIGHT.
     MOVE 1 TO WS-K
     MOVE 5 TO WS-Y
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     MOVE 14 TO WS-L
     CALL "LIGHT-SET" USING WR-ADDR(WS-ROW) WS-K WS-Y WS-X WS-Z WS-L
     MOVE 13 TO WS-L
     MOVE 6 TO WS-X
     CALL "LIGHT-SET" USING WR-ADDR(WS-ROW) WS-K WS-Y WS-X WS-Z WS-L
     MOVE 5 TO WS-X
     MOVE 4 TO WS-Z
     CALL "LIGHT-SET" USING WR-ADDR(WS-ROW) WS-K WS-Y WS-X WS-Z WS-L
     MOVE 6 TO WS-Z
     CALL "LIGHT-SET" USING WR-ADDR(WS-ROW) WS-K WS-Y WS-X WS-Z WS-L
     MOVE 5 TO WS-Z
     MOVE 4 TO WS-Y
     CALL "LIGHT-SET" USING WR-ADDR(WS-ROW) WS-K WS-Y WS-X WS-Z WS-L.

*> The vertices of the torch (a vertex off the whole-number planes of the cells: stone quads lie on them): WS-VERTS counted, WS-DIM those drawn below 0.4 (the larger of the block term and the sky term at full daylight).
 MEASURE-TORCH.
     MOVE 0 TO WS-VERTS WS-DIM
     MOVE 1 TO WS-MINBR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 2
             MOVE 0 TO WS-K
             IF WS-T = 1
                 MOVE WR-OP-COUNT(WS-ROW, WS-S) TO WS-K
                 IF WS-K > 0
                     SET ADDRESS OF B-VERTICES TO WR-OP-ADDR(WS-ROW, WS-S)
                 END-IF
             ELSE
                 MOVE WR-TR-COUNT(WS-ROW, WS-S) TO WS-K
                 IF WS-K > 0
                     SET ADDRESS OF B-VERTICES TO WR-TR-ADDR(WS-ROW, WS-S)
                 END-IF
             END-IF
             PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > WS-K
                 MOVE 0 TO WS-ODD
                 MOVE B-X(WS-Q) TO WS-V
                 PERFORM CHECK-FRACTION
                 MOVE B-Y(WS-Q) TO WS-V
                 PERFORM CHECK-FRACTION
                 MOVE B-Z(WS-Q) TO WS-V
                 PERFORM CHECK-FRACTION
                 IF WS-ODD = 1
                     ADD 1 TO WS-VERTS
                     MOVE B-B(WS-Q) TO WS-BR
                     IF B-SKY(WS-Q) > WS-BR
                         MOVE B-SKY(WS-Q) TO WS-BR
                     END-IF
                     IF WS-BR < 0.4
                         ADD 1 TO WS-DIM
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 CHECK-FRACTION.
     COMPUTE WS-R = WS-V - FUNCTION INTEGER(WS-V)
     IF WS-R > 0.01 AND WS-R < 0.99
         MOVE 1 TO WS-ODD
     END-IF.

 CLEAR-WORLD.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 12288
         MOVE 0 TO CE-STATE(WS-CELL)
     END-PERFORM.

 MESH-ALL.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         MOVE 1 TO WR-DIRTY(WS-ROW, WS-S)
     END-PERFORM
     MOVE 0 TO WS-FRAMES
     MOVE 1 TO WS-DIRTY
     PERFORM UNTIL WS-DIRTY = 0 OR WS-FRAMES > 400
         ADD 1 TO WS-FRAMES
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
         MOVE 0 TO WS-DIRTY
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             IF WR-DIRTY(WS-ROW, WS-S) = 1
                 MOVE 1 TO WS-DIRTY
             END-IF
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-MESHER-TORCH-LIGHT.
