*> Implementation test of the face-level occlusion of the mesher (T6000; operator play of try3: "the sides of blocks that are
*> surrounded by lower half slabs don't render"). Brute-force oracle over one chunk of three sections of the standard set filled
*> with air, stone and every state of oak_slab, oak_stairs, oak_trapdoor, white_carpet and snow: every plane between two adjacent
*> cells holds as many quads of the opaque mesh as the cells draw toward each other, and a cell draws its face toward a neighbour
*> unless the neighbour's face toward it covers the whole face of the cell (51 block shapes, 12 rendering: Block.shouldRenderFace
*> compares the face occlusion shapes, so a full block beside a bottom slab draws its side, the slab's side against the full
*> block is hidden, a bottom slab against a top slab draws both). The cells have no model in the fixture pack, so each is the
*> missing model: a full cube whose six faces carry a cullface. The expected face of a cell is computed here from the shape
*> boxes (BSH-SHAPE), not from the tables the mesher reads.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-FACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY CONTENT.
 COPY CTBSHAPE.
 COPY CLFACES.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-Z              BINARY-LONG VALUE 0.
 01 WS-BIG                 BINARY-LONG VALUE 64.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-KEYSTR              PIC X(112).
 01 WS-POOL-N              BINARY-LONG VALUE 0.
 01 WS-POOL                BINARY-LONG OCCURS 700 TIMES.
 01 WS-FIRST               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NAMES.
    05 FILLER PIC X(16) VALUE "oak_slab".
    05 FILLER PIC X(16) VALUE "oak_stairs".
    05 FILLER PIC X(16) VALUE "oak_trapdoor".
    05 FILLER PIC X(16) VALUE "white_carpet".
    05 FILLER PIC X(16) VALUE "snow".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(16) OCCURS 5 TIMES.
 01 WS-STONE               BINARY-LONG.
 01 WS-SLAB                BINARY-LONG.
 01 WS-TRAP-FIRST          BINARY-LONG.
 01 WS-TRAP-LAST           BINARY-LONG.
 01 WS-SNOW-FIRST          BINARY-LONG.
 01 WS-SNOW-LAST           BINARY-LONG.
 01 WS-STATE-NOW           BINARY-LONG.
 01 WS-IS-TRAP             BINARY-LONG.
 01 WS-KIND-FROM           BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-STATES.
    05 WS-STATE-OF         BINARY-LONG OCCURS 12288 TIMES.
 01 WS-PLANES.
    05 WS-PLANE-COUNT       BINARY-CHAR UNSIGNED OCCURS 208065 TIMES.
 01 WS-SA                  BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-DRAW-A              BINARY-LONG.
 01 WS-DRAW-B              BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-MISSING             BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-CHECKED             BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-HALF-DRAWN          BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-BOX                 BINARY-LONG.
 01 WS-U1                  BINARY-LONG.
 01 WS-U2                  BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-TOUCH               BINARY-LONG.
 01 WS-CI                  BINARY-LONG.
 01 WS-CJ                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-GRID                PIC X(256).
 01 WS-OWN                 PIC X(256).
 01 WS-NB                  PIC X(256).
 01 WS-ANY                 BINARY-LONG.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-XS                  PIC Z9.
 01 WS-YS                  PIC Z9.
 01 WS-ZS                  PIC Z9.
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
     MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)
     MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 384 TO PL-HEIGHT
     MOVE -64 TO PL-MIN-Y
     MOVE 1 TO PL-HAS-SKY
     MOVE 1000 TO SK-U
     MOVE 1 TO MB-FAKE
     MOVE 0 TO MB-FAKE-STEP MB-FAKE-NOW
     MOVE 1000000000 TO MB-BUDGET-US
     PERFORM BUILD-POOL
     PERFORM FILL-WORLD
     PERFORM MESH-IDLE
     PERFORM CHECK-PLANES
     MOVE "mesher faces every plane holds the quads the face shapes of its two cells draw" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MISSING + WS-EXTRA
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mesher faces the oracle looked at planes with a stair, slab, trapdoor, carpet or snow cell (not trivially empty)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HALF-DRAWN > 2000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mesher faces the distinct face masks of the whole standard set fit the face classes (ST-CMAX) with room to spare" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SF-COUNT < ST-CMAX - 50
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     DISPLAY "  face classes " SF-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM SLAB-CASE
     STOP RUN.

*> The operator's case: a stone cell with a bottom slab on each of its four sides (the slab is state-default of oak_slab, type bottom):
*> the side of the stone toward a slab is drawn, the side of the slab toward the stone is hidden, and two slabs side by side hide each other.
 SLAB-CASE.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO-Z WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE ALL X"FF" TO CE-SKYS
     MOVE "oak_slab" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-SLAB WS-STATUS
     MOVE 5 TO WS-Z
     COMPUTE WS-WY = 5 + PL-MIN-Y
     MOVE 5 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-STONE
     MOVE 6 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-SLAB
     MOVE 7 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-SLAB
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 12288
         MOVE 0 TO WS-STATE-OF(WS-CELL)
     END-PERFORM
     COMPUTE WS-CELL = 5 * 256 + 5 * 16 + 5 + 1
     MOVE WS-STONE TO WS-STATE-OF(WS-CELL)
     ADD 1 TO WS-CELL
     MOVE WS-SLAB TO WS-STATE-OF(WS-CELL)
     ADD 1 TO WS-CELL
     MOVE WS-SLAB TO WS-STATE-OF(WS-CELL)
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         MOVE 1 TO WR-DIRTY(WS-ROW, WS-S)
     END-PERFORM
     PERFORM MESH-IDLE
     PERFORM CHECK-PLANES
*>   Doubled coordinates: cell (5, 5, 5) spans 10 to 12 on x; the plane between x 5 and 6 is 12, y 5 is 11, z 5 is 11.
     COMPUTE WS-KEY = (11 * 33 + 11) * 65 + 12 + 1
     MOVE WS-PLANE-COUNT(WS-KEY) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     MOVE "mesher faces the side of a full block toward a bottom slab is drawn, the slab's side toward it is hidden" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-KEY = (11 * 33 + 11) * 65 + 14 + 1
     MOVE WS-PLANE-COUNT(WS-KEY) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     MOVE "mesher faces two bottom slabs side by side hide their sides toward each other" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The states of the five blocks and stone.
 BUILD-POOL.
     MOVE "stone" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STONE WS-STATUS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE SPACES TO WS-KEYSTR
         MOVE WS-NAME(WS-K) TO WS-KEYSTR
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
         MOVE WS-BLOCK-ROW TO CT-BLOCK-ROW
         COMPUTE WS-FIRST = FUNCTION NUMVAL(CT-BR-FIRST-STATE)
         COMPUTE WS-COUNT = FUNCTION NUMVAL(CT-BR-STATE-COUNT)
         IF WS-K = 5
             MOVE WS-FIRST TO WS-SNOW-FIRST
             COMPUTE WS-SNOW-LAST = WS-FIRST + WS-COUNT - 1
         END-IF
         IF WS-K = 3
             MOVE WS-FIRST TO WS-TRAP-FIRST
             COMPUTE WS-TRAP-LAST = WS-FIRST + WS-COUNT - 1
         END-IF
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT
*>           The dry states: a waterlogged one adds the water mesh of the cell.
             IF ST-FLUID(WS-FIRST + WS-I + 1) = 0
                 ADD 1 TO WS-POOL-N
                 COMPUTE WS-POOL(WS-POOL-N) = WS-FIRST + WS-I
             END-IF
         END-PERFORM
     END-PERFORM.

 FILL-WORLD.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO-Z WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE ALL X"FF" TO CE-SKYS
     MOVE 12345 TO WS-SEED
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 12288
         COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103 + 12345, 1000003)
         COMPUTE WS-R = FUNCTION MOD(WS-SEED / 7, 100)
         EVALUATE TRUE
             WHEN WS-R < 20
                 MOVE 0 TO CE-STATE(WS-CELL)
             WHEN WS-R < 40
                 MOVE WS-STONE TO CE-STATE(WS-CELL)
             WHEN OTHER
                 COMPUTE WS-K = FUNCTION MOD(WS-SEED / 101, WS-POOL-N) + 1
                 MOVE WS-POOL(WS-K) TO CE-STATE(WS-CELL)
         END-EVALUATE
         MOVE CE-STATE(WS-CELL) TO WS-STATE-OF(WS-CELL)
     END-PERFORM
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         MOVE 1 TO WR-DIRTY(WS-ROW, WS-S)
     END-PERFORM.

*> Frames until no section is dirty (at most 400).
 MESH-IDLE.
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

*> The planes of the mesh (doubled coordinates of each quad's centre) against the expected quads of every pair of cells.
 CHECK-PLANES.
     PERFORM VARYING WS-KEY FROM 1 BY 1 UNTIL WS-KEY > 208065
         MOVE 0 TO WS-PLANE-COUNT(WS-KEY)
     END-PERFORM
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
         IF WR-OP-COUNT(WS-ROW, WS-S) > 0
             SET ADDRESS OF B-VERTICES TO WR-OP-ADDR(WS-ROW, WS-S)
             PERFORM VARYING WS-Q FROM 0 BY 6 UNTIL WS-Q >= WR-OP-COUNT(WS-ROW, WS-S)
                 COMPUTE WS-A = WS-Q + 1
                 COMPUTE WS-B = WS-Q + 3
                 COMPUTE WS-X2 ROUNDED = B-X(WS-A) + B-X(WS-B)
                 COMPUTE WS-Y2 ROUNDED = B-Y(WS-A) + B-Y(WS-B) + (WS-S - 1) * 32
                 COMPUTE WS-Z2 ROUNDED = B-Z(WS-A) + B-Z(WS-B)
                 COMPUTE WS-KEY = (WS-Y2 * 33 + WS-Z2) * 65 + WS-X2 + 1
                 ADD 1 TO WS-PLANE-COUNT(WS-KEY)
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE 0 TO WS-MISSING WS-EXTRA WS-CHECKED WS-SHOWN WS-HALF-DRAWN
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 47
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 PERFORM VARYING WS-AXIS FROM 1 BY 1 UNTIL WS-AXIS > 3
                     MOVE WS-X TO WS-NX
                     MOVE WS-Y TO WS-NY
                     MOVE WS-Z TO WS-NZ
                     COMPUTE WS-X2 = WS-X * 2 + 1
                     COMPUTE WS-Y2 = WS-Y * 2 + 1
                     COMPUTE WS-Z2 = WS-Z * 2 + 1
                     EVALUATE WS-AXIS
                         WHEN 1
                             ADD 1 TO WS-NX
                             ADD 1 TO WS-X2
                             MOVE DIR-EAST TO WS-DIR
                             MOVE DIR-WEST TO WS-OPP
                         WHEN 2
                             ADD 1 TO WS-NY
                             ADD 1 TO WS-Y2
                             MOVE DIR-UP TO WS-DIR
                             MOVE DIR-DOWN TO WS-OPP
                         WHEN 3
                             ADD 1 TO WS-NZ
                             ADD 1 TO WS-Z2
                             MOVE DIR-SOUTH TO WS-DIR
                             MOVE DIR-NORTH TO WS-OPP
                     END-EVALUATE
                     IF WS-NX <= 15 AND WS-NY <= 47 AND WS-NZ <= 15
                         COMPUTE WS-CELL = WS-Y * 256 + WS-Z * 16 + WS-X + 1
                         MOVE WS-STATE-OF(WS-CELL) TO WS-SA
                         COMPUTE WS-CELL = WS-NY * 256 + WS-NZ * 16 + WS-NX + 1
                         MOVE WS-STATE-OF(WS-CELL) TO WS-SB
*>                       A draws toward B (direction WS-DIR), B toward A (WS-OPP).
                         MOVE WS-SA TO WS-FROM
                         MOVE WS-SB TO WS-TO
                         MOVE WS-DIR TO WS-DRAWS
                         PERFORM DRAWS-FACE
                         MOVE WS-DRAWN TO WS-DRAW-A
                         MOVE WS-SB TO WS-FROM
                         MOVE WS-SA TO WS-TO
                         MOVE WS-OPP TO WS-DRAWS
                         PERFORM DRAWS-FACE
                         MOVE WS-DRAWN TO WS-DRAW-B
                         COMPUTE WS-EXPECT = WS-DRAW-A + WS-DRAW-B
                         COMPUTE WS-KEY = (WS-Y2 * 33 + WS-Z2) * 65 + WS-X2 + 1
                         MOVE WS-PLANE-COUNT(WS-KEY) TO WS-SEEN
                         ADD 1 TO WS-CHECKED
                         IF WS-SA NOT = WS-STONE AND WS-SA NOT = 0 AND WS-SB NOT = 0
                             ADD 1 TO WS-HALF-DRAWN
                         END-IF
                         IF WS-SEEN NOT = WS-EXPECT
                             IF WS-SEEN < WS-EXPECT
                                 ADD 1 TO WS-MISSING
                             ELSE
                                 ADD 1 TO WS-EXTRA
                             END-IF
                             IF WS-SHOWN < 12
                                 ADD 1 TO WS-SHOWN
                                 MOVE WS-X TO WS-XS
                                 MOVE WS-Y TO WS-YS
                                 MOVE WS-Z TO WS-ZS
                                 CALL "CONTENT-BLOCK-OF-STATE" USING WS-SA WS-ID WS-K WS-BLOCK-ROW WS-STATUS
                                 MOVE WS-BLOCK-ROW TO CT-BLOCK-ROW
                                 DISPLAY "  A " CT-BR-KEY WS-K
                                 CALL "CONTENT-BLOCK-OF-STATE" USING WS-SB WS-ID WS-K WS-BLOCK-ROW WS-STATUS
                                 MOVE WS-BLOCK-ROW TO CT-BLOCK-ROW
                                 DISPLAY "  B " CT-BR-KEY WS-K
                                 DISPLAY "  plane after cell " WS-XS " " WS-YS " " WS-ZS " axis " WS-AXIS
                                     " states " WS-SA " " WS-SB " expected " WS-EXPECT " quads " WS-SEEN
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM.

*> WS-DRAWN = 1 when the cell WS-FROM draws its face toward direction WS-DRAWS beside the cell WS-TO: it is not air, and its
*> face (every position its boxes overlap, the whole face when none) is not inside the part of the face of the neighbour that
*> the neighbour's boxes cover wholly (nothing for air).
 DRAWS-FACE.
     MOVE 0 TO WS-DRAWN
     IF WS-FROM NOT = 0
         MOVE BSH-OUT(WS-FROM + 1) TO WS-SHAPE
         MOVE 2 TO WS-MODE
         PERFORM FACE-GRID
         MOVE WS-GRID TO WS-OWN
         MOVE 0 TO WS-ANY
         INSPECT WS-OWN TALLYING WS-ANY FOR ALL "1"
         MOVE WS-FROM TO WS-STATE-NOW
         PERFORM IS-TRAPDOOR
         MOVE WS-IS-TRAP TO WS-KIND-FROM
         IF WS-ANY = 0 OR WS-IS-TRAP > 0
             MOVE ALL "1" TO WS-OWN
         END-IF
         MOVE ALL "0" TO WS-NB
         MOVE WS-TO TO WS-STATE-NOW
         PERFORM IS-TRAPDOOR
         IF WS-TO NOT = 0 AND WS-IS-TRAP = 0
             MOVE BSH-OUT(WS-TO + 1) TO WS-SHAPE
             MOVE 1 TO WS-MODE
             MOVE WS-DRAWS TO WS-HI
             PERFORM OPPOSITE
             MOVE WS-LO TO WS-DRAWS
             PERFORM FACE-GRID
             MOVE WS-GRID TO WS-NB
             MOVE WS-HI TO WS-DRAWS
         END-IF
         MOVE 0 TO WS-ANY
         INSPECT WS-NB TALLYING WS-ANY FOR ALL "1"
         MOVE 1 TO WS-DRAWN
*>       The same block that fills the cube without occluding hides its own faces (glass beside glass; here a snow layer of eight).
         IF WS-KIND-FROM > 0 AND WS-KIND-FROM = WS-IS-TRAP AND BSH-OUT(WS-FROM + 1) = 1
             MOVE 0 TO WS-DRAWN
         END-IF
         IF WS-ANY > 0 AND WS-DRAWN = 1
             MOVE 0 TO WS-DRAWN
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 256
                 IF WS-OWN(WS-K:1) = "1" AND WS-NB(WS-K:1) = "0"
                     MOVE 1 TO WS-DRAWN
                 END-IF
             END-PERFORM
         END-IF
     END-IF.

*> A trapdoor and a snow layer are no occluders here (flagged noOcclusion, replaceable; 24 part 1 section 5.2: the flags clear canOcclude): its faces need a whole neighbour face and it hides none.
 IS-TRAPDOOR.
     MOVE 0 TO WS-IS-TRAP
     IF WS-STATE-NOW >= WS-TRAP-FIRST AND WS-STATE-NOW <= WS-TRAP-LAST
         MOVE 1 TO WS-IS-TRAP
     END-IF
     IF WS-STATE-NOW >= WS-SNOW-FIRST AND WS-STATE-NOW <= WS-SNOW-LAST
         MOVE 2 TO WS-IS-TRAP
     END-IF.

*> WS-LO = the direction opposite WS-DRAWS.
 OPPOSITE.
     EVALUATE WS-DRAWS
         WHEN DIR-DOWN
             MOVE DIR-UP TO WS-LO
         WHEN DIR-UP
             MOVE DIR-DOWN TO WS-LO
         WHEN DIR-NORTH
             MOVE DIR-SOUTH TO WS-LO
         WHEN DIR-SOUTH
             MOVE DIR-NORTH TO WS-LO
         WHEN DIR-WEST
             MOVE DIR-EAST TO WS-LO
         WHEN OTHER
             MOVE DIR-WEST TO WS-LO
     END-EVALUATE.

*> WS-GRID (16 x 16 characters "0" or "1", row j (second coordinate) times 16 plus column i, 1 based): the face of the shape
*> WS-SHAPE toward direction WS-DRAWS: the cells (a sixteenth wide) that the boxes touching that side of the cell cover wholly
*> (WS-MODE 1) or overlap (2). The columns run along x (down, up, north, south) or z (west, east); the rows along z (down, up)
*> or y.
 FACE-GRID.
     MOVE ALL "0" TO WS-GRID
     PERFORM VARYING WS-BOX FROM 1 BY 1 UNTIL WS-BOX > BSH-N(WS-SHAPE + 1)
         MOVE 0 TO WS-TOUCH
         EVALUATE WS-DRAWS
             WHEN DIR-DOWN
                 IF BSH-V(WS-SHAPE + 1, WS-BOX, 2) = 0
                     MOVE 1 TO WS-TOUCH
                 END-IF
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 1) TO WS-U1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 4) TO WS-U2
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 3) TO WS-V1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 6) TO WS-V2
             WHEN DIR-UP
                 IF BSH-V(WS-SHAPE + 1, WS-BOX, 5) = 16000
                     MOVE 1 TO WS-TOUCH
                 END-IF
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 1) TO WS-U1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 4) TO WS-U2
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 3) TO WS-V1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 6) TO WS-V2
             WHEN DIR-NORTH
                 IF BSH-V(WS-SHAPE + 1, WS-BOX, 3) = 0
                     MOVE 1 TO WS-TOUCH
                 END-IF
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 1) TO WS-U1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 4) TO WS-U2
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 2) TO WS-V1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 5) TO WS-V2
             WHEN DIR-SOUTH
                 IF BSH-V(WS-SHAPE + 1, WS-BOX, 6) = 16000
                     MOVE 1 TO WS-TOUCH
                 END-IF
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 1) TO WS-U1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 4) TO WS-U2
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 2) TO WS-V1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 5) TO WS-V2
             WHEN DIR-WEST
                 IF BSH-V(WS-SHAPE + 1, WS-BOX, 1) = 0
                     MOVE 1 TO WS-TOUCH
                 END-IF
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 3) TO WS-U1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 6) TO WS-U2
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 2) TO WS-V1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 5) TO WS-V2
             WHEN OTHER
                 IF BSH-V(WS-SHAPE + 1, WS-BOX, 4) = 16000
                     MOVE 1 TO WS-TOUCH
                 END-IF
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 3) TO WS-U1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 6) TO WS-U2
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 2) TO WS-V1
                 MOVE BSH-V(WS-SHAPE + 1, WS-BOX, 5) TO WS-V2
         END-EVALUATE
         IF WS-TOUCH = 1
             PERFORM VARYING WS-CJ FROM 0 BY 1 UNTIL WS-CJ > 15
                 PERFORM VARYING WS-CI FROM 0 BY 1 UNTIL WS-CI > 15
                     IF WS-MODE = 1
                         IF WS-U1 <= WS-CI * 1000 AND WS-U2 >= (WS-CI + 1) * 1000
                                 AND WS-V1 <= WS-CJ * 1000 AND WS-V2 >= (WS-CJ + 1) * 1000
                             MOVE "1" TO WS-GRID(WS-CJ * 16 + WS-CI + 1:1)
                         END-IF
                     ELSE
                         IF WS-U1 < (WS-CI + 1) * 1000 AND WS-U2 > WS-CI * 1000
                                 AND WS-V1 < (WS-CJ + 1) * 1000 AND WS-V2 > WS-CJ * 1000
                             MOVE "1" TO WS-GRID(WS-CJ * 16 + WS-CI + 1:1)
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM.

 END PROGRAM TEST-MESHER-FACES.
