*> T10401 (bug-sweep: ice drew its hidden faces; operator play of try7): a 4 x 4 x 4 block of ice across a chunk border (x 14 to 17) and a section
*> border (rows 14 to 17) draws only the 96 faces of its outside (576 translucent vertices), none between two cells of ice; an ice cell beside a stone
*> cell draws its five other faces only (the face toward the stone is hidden: the stone covers it), and the stone draws its six.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-ICE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG OCCURS 2 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BIG                 BINARY-LONG VALUE 64.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-KEYSTR              PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-ICE                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-TR                  BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-AXES                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-QN                  BINARY-LONG.
 01 WS-N                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-C                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E1                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E2                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LO                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HI                  FLOAT-LONG OCCURS 3 TIMES.
 01 B-VERTICES BASED.
    05 B-VERTEX OCCURS 150000 TIMES.
       10 B-XYZ            FLOAT-SHORT OCCURS 3 TIMES.
       10 B-REST           FLOAT-SHORT OCCURS 8 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-ice" TO PK-ROOT(PK-COUNT)
     MOVE 30 TO PK-ROOT-LENGTH(PK-COUNT)
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
     MOVE "ice" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-ICE WS-STATUS
     MOVE SPACES TO WS-KEYSTR
     MOVE "stone" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STONE WS-STATUS
*>   A 4 x 4 x 4 block of ice across the chunk border (x 14..17) and the section border (rows 14..17).
     PERFORM CLEAR-WORLD
     PERFORM VARYING WS-Y FROM 14 BY 1 UNTIL WS-Y > 17
         PERFORM VARYING WS-Z FROM 4 BY 1 UNTIL WS-Z > 7
             PERFORM VARYING WS-X FROM 14 BY 1 UNTIL WS-X > 17
                 COMPUTE WS-WY = WS-Y + PL-MIN-Y
                 CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-ICE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM MESH-ALL
     MOVE "mesher ice a 4 x 4 x 4 block of ice across a chunk and a section border draws only its 96 outside faces (576 vertices)"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 576 TO TL-EXPECTED-N
     MOVE WS-TR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The winding: the first triangle of every quad (vertices 1 2 3) is clockwise seen from outside (the winding the translucent culling pipeline CC_PIPE_TRANSLUCENT_CULL takes as front: the normal of the
*>   triangle points into the block).
     MOVE 14 TO WS-LO(1) WS-LO(2)
     MOVE 18 TO WS-HI(1) WS-HI(2)
     MOVE 4 TO WS-LO(3)
     MOVE 8 TO WS-HI(3)
     MOVE 3 TO WS-AXES
     PERFORM CHECK-WINDING
     MOVE "mesher ice the quads of the ice block are clockwise seen from outside (front faces of the culling pipeline)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A cell of water in the air: this pack holds no water sprites, so the faces take the missing-texture sprite, which is opaque: six quads (the top, the bottom, the four sides), each
*>   once (the copies for the inside are made for translucent sprites only; test_mesher_fluid_winding has the translucent water of the real pack).
     PERFORM CLEAR-WORLD
     MOVE "water" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-WATER WS-STATUS
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     COMPUTE WS-WY = 5 + PL-MIN-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-WATER
     PERFORM MESH-ALL
     COMPUTE TL-OBSERVED-N = (WS-TR + WS-OP) / 6
     MOVE 6 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     MOVE "mesher ice a cell of water in the air with an opaque sprite has six quads: the top, the bottom and four sides" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-LO(1) WS-LO(2) WS-LO(3)
     MOVE 6 TO WS-HI(1) WS-HI(2) WS-HI(3)
     MOVE 1 TO WS-AXES
     MOVE 0 TO WS-AXES
     PERFORM CHECK-WINDING
     MOVE "mesher ice the water cell's sides are clockwise seen from outside" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An ice cell beside a stone cell.
     PERFORM CLEAR-WORLD
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     COMPUTE WS-WY = 5 + PL-MIN-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-ICE
     MOVE 6 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-STONE
     PERFORM MESH-ALL
     MOVE "mesher ice an ice cell beside a stone cell draws five faces (30 translucent vertices)" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE WS-TR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mesher ice the stone cell beside the ice cell draws its six faces (36 opaque vertices)" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE WS-OP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The quads of both meshes whose plane is a face of the box WS-LO .. WS-HI (the axes 1 to WS-AXES; 0 means x and z only, the water cell's top is
*> sloped and drawn both ways) and whose first triangle points out of the box: WS-BAD.
 CHECK-WINDING.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             PERFORM VARYING WS-LIST FROM 1 BY 1 UNTIL WS-LIST > 2
                 MOVE 0 TO WS-QN
                 IF WS-LIST = 1
                     MOVE WR-TR-COUNT(WS-ROW(WS-R), WS-S) TO WS-QN
                     IF WS-QN > 0
                         SET ADDRESS OF B-VERTICES TO WR-TR-ADDR(WS-ROW(WS-R), WS-S)
                     END-IF
                 ELSE
                     MOVE WR-OP-COUNT(WS-ROW(WS-R), WS-S) TO WS-QN
                     IF WS-QN > 0
                         SET ADDRESS OF B-VERTICES TO WR-OP-ADDR(WS-ROW(WS-R), WS-S)
                     END-IF
                 END-IF
                 PERFORM VARYING WS-Q FROM 0 BY 6 UNTIL WS-Q >= WS-QN
                     PERFORM CHECK-QUAD
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 CHECK-QUAD.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         COMPUTE WS-E1(WS-K) = B-XYZ(WS-Q + 2, WS-K) - B-XYZ(WS-Q + 1, WS-K)
         COMPUTE WS-E2(WS-K) = B-XYZ(WS-Q + 3, WS-K) - B-XYZ(WS-Q + 1, WS-K)
         COMPUTE WS-C(WS-K) = (B-XYZ(WS-Q + 1, WS-K) + B-XYZ(WS-Q + 3, WS-K)) / 2
     END-PERFORM
     COMPUTE WS-C(1) = WS-C(1) + (WS-R - 1) * 16
     COMPUTE WS-C(2) = WS-C(2) + (WS-S - 1) * 16
     COMPUTE WS-N(1) = WS-E1(2) * WS-E2(3) - WS-E1(3) * WS-E2(2)
     COMPUTE WS-N(2) = WS-E1(3) * WS-E2(1) - WS-E1(1) * WS-E2(3)
     COMPUTE WS-N(3) = WS-E1(1) * WS-E2(2) - WS-E1(2) * WS-E2(1)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         IF WS-K = 2 AND WS-AXES = 0
             CONTINUE
         ELSE
             IF WS-N(WS-K) < -0.0001 AND WS-C(WS-K) = WS-LO(WS-K)
                 ADD 1 TO WS-BAD
             END-IF
             IF WS-N(WS-K) > 0.0001 AND WS-C(WS-K) = WS-HI(WS-K)
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM.

 CLEAR-WORLD.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-CX = WS-I - 1
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-ZERO WS-ROW(WS-I)
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW(WS-I))
         MOVE ALL X"FF" TO CE-SKYS
         PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 12288
             MOVE 0 TO CE-STATE(WS-CELL)
         END-PERFORM
     END-PERFORM.

 MESH-ALL.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             MOVE 1 TO WR-DIRTY(WS-ROW(WS-I), WS-S)
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-FRAMES
     MOVE 1 TO WS-DIRTY
     PERFORM UNTIL WS-DIRTY = 0 OR WS-FRAMES > 400
         ADD 1 TO WS-FRAMES
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
         MOVE 0 TO WS-DIRTY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
                 IF WR-DIRTY(WS-ROW(WS-I), WS-S) = 1
                     MOVE 1 TO WS-DIRTY
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-TR WS-OP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             ADD WR-TR-COUNT(WS-ROW(WS-I), WS-S) TO WS-TR
             ADD WR-OP-COUNT(WS-ROW(WS-I), WS-S) TO WS-OP
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-MESHER-ICE.
