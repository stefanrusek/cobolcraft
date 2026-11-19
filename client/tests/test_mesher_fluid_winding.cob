 *> Real-input test of the winding and the sides of the fluid mesh (lane bugfluidwalls, operator report try19 "the stronghold fountain flows but the wrong surfaces are rendered";
 *> docs/protocol/29a-fluids.md section 10.1 and 10.3): the translucent sections are drawn with the back faces culled (CC_PIPE_TRANSLUCENT_CULL), and a face is a front face when
 *> its first triangle (the vertices 1 2 3) points into the cell, as the baked block faces do. The fluid quads came in the order of the renderer, which points out of the cell, so
 *> a water face was seen only from the inside: the far faces of a waterfall's column, never the near ones. Doc: the top has a second, reverse-winding copy only when
 *> shouldRenderBackwardUpFace holds (a cell of the 3 x 3 above it that is neither the same fluid nor a solid block), the bottom is single-sided, a side face is drawn on both sides
 *> except where the overlay sprite replaces the flowing one (single-sided). Lava is opaque (the opaque pipeline does not cull), so its faces are drawn once.
 *> The scenes (generated vanilla pack, CC_GENERATED_DIR): the stronghold fountain of 36-5 (a pillar of stone bricks with a source on top, the four falling columns, the pool), a
 *> source in the air, a source under a ceiling, a source beside glass, a lava cell. Counts by kind of face and orientation (front: pointing into the cell).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-FLUID-WINDING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
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
 01 WS-BRICK               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-GLASS               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-QN                  BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-N                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-C                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E1                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E2                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-SF                  BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-TF                  BINARY-LONG.
 01 WS-TB                  BINARY-LONG.
 01 WS-BF                  BINARY-LONG.
 01 WS-BB                  BINARY-LONG.
 01 WS-FR                  FLOAT-LONG.
 01 WS-FRY                 FLOAT-LONG.
 01 WS-SIGN                BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-TEXT                PIC X(80).
 01 WS-PTR                 BINARY-LONG.
 01 B-VERTICES BASED.
    05 B-VERTEX OCCURS 150000 TIMES.
       10 B-XYZ            FLOAT-SHORT OCCURS 3 TIMES.
       10 B-REST           FLOAT-SHORT OCCURS 8 TIMES.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
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
     MOVE "stone_bricks" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-BRICK WS-STATUS
     MOVE SPACES TO WS-KEYSTR
     MOVE "water" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-WATER WS-STATUS
     MOVE SPACES TO WS-KEYSTR
     MOVE "lava" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-LAVA WS-STATUS
     MOVE SPACES TO WS-KEYSTR
     MOVE "glass" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-GLASS WS-STATUS

*>   The stronghold fountain (36-5 type 1 room crossing): a ring of stone bricks round a pillar with the source on top.
     PERFORM CLEAR-WORLD
     PERFORM BUILD-FOUNTAIN
     PERFORM MESH-ALL
     PERFORM COUNT-FACES
     MOVE "fluid winding fountain: 36 side faces are front faces (pointing into the cell, seen from outside)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 36 TO TL-EXPECTED-N
     MOVE WS-SF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fluid winding fountain: the 36 side faces have a second copy for the inside (water sides are double-sided)" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE WS-SB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fluid winding fountain: nine water surfaces, each seen from above" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-TF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fluid winding fountain: nine surfaces, each also seen from below (open air above)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-TB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A source in the air.
     PERFORM CLEAR-WORLD
     MOVE 8 TO WS-X WS-Y WS-Z
     MOVE WS-WATER TO WS-ID
     PERFORM PUT
     PERFORM MESH-ALL
     PERFORM COUNT-FACES
     MOVE "fluid winding a source in the air: 4 side faces, 4 more for the inside, the top twice (above and below), the bottom once" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "sides 4 4 top 1 1 bottom 1 0" TO TL-EXPECTED
     PERFORM COUNTS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A source under a ceiling of stone (the 3 x 3 above is solid): the surface is not seen from below.
     PERFORM CLEAR-WORLD
     MOVE WS-WATER TO WS-ID
     MOVE 8 TO WS-X WS-Y WS-Z
     PERFORM PUT
     MOVE WS-BRICK TO WS-ID
     MOVE 9 TO WS-Y
     PERFORM VARYING WS-X FROM 7 BY 1 UNTIL WS-X > 9
         PERFORM VARYING WS-Z FROM 7 BY 1 UNTIL WS-Z > 9
             PERFORM PUT
         END-PERFORM
     END-PERFORM
     PERFORM MESH-ALL
     PERFORM COUNT-FACES
     MOVE "fluid winding a source under a solid ceiling: the surface once (seen from above), no copy for below" TO TL-CASE
     MOVE "sides 4 4 top 1 0 bottom 1 0" TO TL-EXPECTED
     PERFORM COUNTS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A source beside glass: the side towards the glass takes the overlay sprite and is single-sided.
     PERFORM CLEAR-WORLD
     MOVE WS-WATER TO WS-ID
     MOVE 8 TO WS-X WS-Y WS-Z
     PERFORM PUT
     MOVE WS-GLASS TO WS-ID
     MOVE 9 TO WS-X
     PERFORM PUT
     PERFORM MESH-ALL
     PERFORM COUNT-FACES
     MOVE "fluid winding a source beside glass: the overlay face is single-sided, the other three sides double" TO TL-CASE
     MOVE "sides 4 3 top 1 1 bottom 1 0" TO TL-EXPECTED
     PERFORM COUNTS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Lava is opaque: drawn once, as a front face.
     PERFORM CLEAR-WORLD
     MOVE WS-LAVA TO WS-ID
     MOVE 8 TO WS-X WS-Y WS-Z
     PERFORM PUT
     PERFORM MESH-ALL
     PERFORM COUNT-FACES
     MOVE "fluid winding a lava source: every face once and a front face (the opaque pipeline does not cull)" TO TL-CASE
     MOVE "sides 4 0 top 1 0 bottom 1 0" TO TL-EXPECTED
     PERFORM COUNTS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-TEXT from the counts: sides front back, top front back, bottom front back (each a digit).
 COUNTS-TEXT.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE WS-SF TO WS-DIGIT
     STRING "sides " WS-DIGIT DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     MOVE WS-SB TO WS-DIGIT
     STRING " " WS-DIGIT DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     MOVE WS-TF TO WS-DIGIT
     STRING " top " WS-DIGIT DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     MOVE WS-TB TO WS-DIGIT
     STRING " " WS-DIGIT DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     MOVE WS-BF TO WS-DIGIT
     STRING " bottom " WS-DIGIT DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     MOVE WS-BB TO WS-DIGIT
     STRING " " WS-DIGIT DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR.

*> A ring of stone bricks (y 1) round a pillar (5, 1 to 3, 5) on a floor (y 0), the source (5, 4, 5) with its four neighbours of level 1, the falling columns of level 8 beside
*> the pillar and the pool of level 1 at the corners.
 BUILD-FOUNTAIN.
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 7
         PERFORM VARYING WS-Z FROM 3 BY 1 UNTIL WS-Z > 7
             MOVE WS-BRICK TO WS-ID
             MOVE 0 TO WS-Y
             PERFORM PUT
             IF WS-X = 3 OR WS-X = 7 OR WS-Z = 3 OR WS-Z = 7
                 MOVE 1 TO WS-Y
                 PERFORM PUT
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 5 TO WS-X WS-Z
     MOVE WS-BRICK TO WS-ID
     PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 3
         PERFORM PUT
     END-PERFORM
     MOVE 4 TO WS-Y
     MOVE WS-WATER TO WS-ID
     PERFORM PUT
     COMPUTE WS-ID = WS-WATER + 1
     MOVE 4 TO WS-X
     PERFORM PUT
     MOVE 6 TO WS-X
     PERFORM PUT
     MOVE 5 TO WS-X
     MOVE 4 TO WS-Z
     PERFORM PUT
     MOVE 6 TO WS-Z
     PERFORM PUT
     COMPUTE WS-ID = WS-WATER + 8
     PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 3
         MOVE 4 TO WS-X
         MOVE 5 TO WS-Z
         PERFORM PUT
         MOVE 6 TO WS-X
         PERFORM PUT
         MOVE 5 TO WS-X
         MOVE 4 TO WS-Z
         PERFORM PUT
         MOVE 6 TO WS-Z
         PERFORM PUT
     END-PERFORM
     MOVE 1 TO WS-Y
     COMPUTE WS-ID = WS-WATER + 1
     MOVE 4 TO WS-X
     MOVE 4 TO WS-Z
     PERFORM PUT
     MOVE 6 TO WS-X
     PERFORM PUT
     MOVE 6 TO WS-Z
     PERFORM PUT
     MOVE 4 TO WS-X
     PERFORM PUT.

 PUT.
     COMPUTE WS-WY = WS-Y + PL-MIN-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-ID.

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
     END-PERFORM.

*> The fluid quads of both meshes of the first row (the translucent mesh holds water, the opaque one the stone and the lava; a stone quad is told from a fluid one by the
*> inset of 0.001: a face of the fluid is never on a whole number).
 COUNT-FACES.
     MOVE 0 TO WS-SF WS-SB WS-TF WS-TB WS-BF WS-BB
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
         PERFORM VARYING WS-LIST FROM 1 BY 1 UNTIL WS-LIST > 2
             MOVE 0 TO WS-QN
             IF WS-LIST = 1
                 MOVE WR-TR-COUNT(WS-ROW(1), WS-S) TO WS-QN
                 IF WS-QN > 0
                     SET ADDRESS OF B-VERTICES TO WR-TR-ADDR(WS-ROW(1), WS-S)
                 END-IF
             ELSE
                 MOVE WR-OP-COUNT(WS-ROW(1), WS-S) TO WS-QN
                 IF WS-QN > 0
                     SET ADDRESS OF B-VERTICES TO WR-OP-ADDR(WS-ROW(1), WS-S)
                 END-IF
             END-IF
             PERFORM VARYING WS-Q FROM 0 BY 6 UNTIL WS-Q >= WS-QN
                 PERFORM CLASSIFY-QUAD
             END-PERFORM
         END-PERFORM
     END-PERFORM.

*> A quad's first triangle: its normal and centre; a vertical face (the normal along x or z) is a side whose cell edge is the near whole number (outward is towards it), a face with
*> the normal along y is a top (its centre is not on a whole number height, 0.001 above the floor is the bottom). Front: the normal points against the outward direction.
 CLASSIFY-QUAD.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         COMPUTE WS-E1(WS-K) = B-XYZ(WS-Q + 2, WS-K) - B-XYZ(WS-Q + 1, WS-K)
         COMPUTE WS-E2(WS-K) = B-XYZ(WS-Q + 3, WS-K) - B-XYZ(WS-Q + 1, WS-K)
         COMPUTE WS-C(WS-K) = (B-XYZ(WS-Q + 1, WS-K) + B-XYZ(WS-Q + 3, WS-K)) / 2
     END-PERFORM
     COMPUTE WS-N(1) = WS-E1(2) * WS-E2(3) - WS-E1(3) * WS-E2(2)
     COMPUTE WS-N(2) = WS-E1(3) * WS-E2(1) - WS-E1(1) * WS-E2(3)
     COMPUTE WS-N(3) = WS-E1(1) * WS-E2(2) - WS-E1(2) * WS-E2(1)
     COMPUTE WS-FRY = WS-C(2) - FUNCTION INTEGER(WS-C(2))
     EVALUATE TRUE
*>       A face of a block (stone, glass, lava is a fluid) lies on a whole number of its axis: not a fluid face.
         WHEN FUNCTION ABS(WS-N(1)) + FUNCTION ABS(WS-N(3)) < FUNCTION ABS(WS-N(2)) AND WS-FRY < 0.0005
             CONTINUE
         WHEN FUNCTION ABS(WS-N(1)) + FUNCTION ABS(WS-N(3)) >= FUNCTION ABS(WS-N(2)) AND FUNCTION ABS(WS-N(1)) > FUNCTION ABS(WS-N(3))
                 AND (FUNCTION MOD(WS-C(1) * 1000, 1000) < 0.5 OR FUNCTION MOD(WS-C(1) * 1000, 1000) > 999.5)
             CONTINUE
         WHEN FUNCTION ABS(WS-N(1)) + FUNCTION ABS(WS-N(3)) >= FUNCTION ABS(WS-N(2)) AND FUNCTION ABS(WS-N(1)) <= FUNCTION ABS(WS-N(3))
                 AND (FUNCTION MOD(WS-C(3) * 1000, 1000) < 0.5 OR FUNCTION MOD(WS-C(3) * 1000, 1000) > 999.5)
             CONTINUE
         WHEN FUNCTION ABS(WS-N(1)) + FUNCTION ABS(WS-N(3)) < FUNCTION ABS(WS-N(2))
             IF WS-FRY < 0.01
                 IF WS-N(2) > 0
                     ADD 1 TO WS-BF
                 ELSE
                     ADD 1 TO WS-BB
                 END-IF
             ELSE
                 IF WS-N(2) < 0
                     ADD 1 TO WS-TF
                 ELSE
                     ADD 1 TO WS-TB
                 END-IF
             END-IF
         WHEN FUNCTION ABS(WS-N(1)) > FUNCTION ABS(WS-N(3))
             COMPUTE WS-FR = WS-C(1) - FUNCTION INTEGER(WS-C(1))
             MOVE 1 TO WS-SIGN
             IF WS-FR < 0.5
                 MOVE -1 TO WS-SIGN
             END-IF
             IF WS-N(1) * WS-SIGN < 0
                 ADD 1 TO WS-SF
             ELSE
                 ADD 1 TO WS-SB
             END-IF
         WHEN OTHER
             COMPUTE WS-FR = WS-C(3) - FUNCTION INTEGER(WS-C(3))
             MOVE 1 TO WS-SIGN
             IF WS-FR < 0.5
                 MOVE -1 TO WS-SIGN
             END-IF
             IF WS-N(3) * WS-SIGN < 0
                 ADD 1 TO WS-SF
             ELSE
                 ADD 1 TO WS-SB
             END-IF
     END-EVALUATE.
 END PROGRAM TEST-MESHER-FLUID-WINDING.
