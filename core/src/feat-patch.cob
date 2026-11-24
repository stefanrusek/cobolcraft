*> The vegetation patches (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 9; registry ids 53 vegetation_patch and 56 waterlogged_vegetation_patch):
*> FD-VPATCH-NODE compiles the configuration into a row of FD-WA (WA-I(1) the surface 0 floor or 1 ceiling, WA-I(2) vertical_range, WA-I(3) the placed feature of the vegetation,
*> WA-I(4) 1 for the waterlogged variant; the pool 1 the replaceable blocks; WA-PV(1) the ground state provider; WA-IP(1) depth and WA-IP(2) xz_radius; WA-F(1)
*> extra_bottom_block_chance, WA-F(2) vegetation_chance, WA-F(3) extra_edge_column_chance), FR-VPATCH places it.
*>
*> Deviations: the ground positions are kept in the order they were found (insertion order), not in the iteration order of Java's HashSet (section 9.1 and Open question 1: the order
*> decides which ground position receives which vegetation draw, so a patch is vanilla-like but not seed-identical; the operator decision of the 002 lane). "Has a sturdy face" is a
*> solid block of the content set (CB-SOLID), like the other features. A ground provider that gives no state stops the column like a block that is not replaceable. The waterlogged
*> variant returns true iff the unexposed set is not empty (its placeGroundPatch returns that set). The columns beyond 4096 of a patch (a radius of 32 and more) are not distributed
*> vegetation; no data has such a radius.
*>
*> Entry points: FD-VPATCH-NODE USING doc, node, row out, feature type (53 or 56) (FD-BAD set when the feature cannot be placed whole); FR-VPATCH USING state, feature, x, y, z,
*> result out; VP-STURDY USING x, y, z, flag out (1 when the block at the cell is solid).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-VPATCH-NODE IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDCONST.
 COPY FEATDATA.
 01 WS-K-REPLACEABLE       PIC X(40) VALUE "replaceable".
 01 WS-K-GROUND            PIC X(40) VALUE "ground_state".
 01 WS-K-VEGETATION        PIC X(40) VALUE "vegetation_feature".
 01 WS-K-SURFACE           PIC X(40) VALUE "surface".
 01 WS-K-DEPTH             PIC X(40) VALUE "depth".
 01 WS-K-EXTRA-BOTTOM      PIC X(40) VALUE "extra_bottom_block_chance".
 01 WS-K-RANGE             PIC X(40) VALUE "vertical_range".
 01 WS-K-VEG-CHANCE        PIC X(40) VALUE "vegetation_chance".
 01 WS-K-RADIUS            PIC X(40) VALUE "xz_radius".
 01 WS-K-EXTRA-EDGE        PIC X(40) VALUE "extra_edge_column_chance".
 LOCAL-STORAGE SECTION.
 01 LS-ROW                 BINARY-LONG.
 01 LS-E                   BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-PF                  BINARY-LONG.
 01 LS-SAVED               BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-TEXT                PIC X(120).
 01 LS-LEN                 BINARY-LONG.
 01 LS-CAP                 BINARY-LONG VALUE 120.
 01 LS-P4.
    05 LS-Q                BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW L-TYPE.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO LS-ROW
     INITIALIZE FD-WA(LS-ROW)
     MOVE LS-ROW TO L-ROW
     IF L-TYPE = 56
         MOVE 1 TO WA-I(LS-ROW, 4)
     END-IF
*>   the surface: floor (direction DOWN) or ceiling (UP)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SURFACE LS-E
     MOVE SPACES TO LS-TEXT
     IF LS-E > 0
         CALL "JSON-STRING" USING JSON-DOC LS-E LS-TEXT LS-CAP LS-LEN
     END-IF
     EVALUATE FUNCTION TRIM(LS-TEXT)
         WHEN "floor"
             MOVE 0 TO WA-I(LS-ROW, 1)
         WHEN "ceiling"
             MOVE 1 TO WA-I(LS-ROW, 1)
         WHEN OTHER
             MOVE 1 TO FD-BAD
     END-EVALUATE
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RANGE LS-E
     CALL "FD-J-INT" USING JSON-DOC LS-E WA-I(LS-ROW, 2) LS-OK
     IF LS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-REPLACEABLE LS-E
     CALL "FD-J-BLOCKS" USING JSON-DOC LS-E FC-N1 WA-START(LS-ROW, 1) WA-N(LS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-GROUND LS-E
     CALL "FD-PROV-NODE" USING JSON-DOC LS-E WA-PV(LS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-DEPTH LS-E
     CALL "FD-J-IP" USING JSON-DOC LS-E LS-P4 LS-OK
     IF LS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 4
         MOVE LS-Q(LS-I) TO WA-IPV(LS-ROW, 1, LS-I)
     END-PERFORM
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RADIUS LS-E
     CALL "FD-J-IP" USING JSON-DOC LS-E LS-P4 LS-OK
     IF LS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 4
         MOVE LS-Q(LS-I) TO WA-IPV(LS-ROW, 2, LS-I)
     END-PERFORM
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-EXTRA-BOTTOM LS-E
     CALL "FD-J-DOUBLE" USING JSON-DOC LS-E WA-F(LS-ROW, 1) LS-OK
     IF LS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-VEG-CHANCE LS-E
     CALL "FD-J-DOUBLE" USING JSON-DOC LS-E WA-F(LS-ROW, 2) LS-OK
     IF LS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-EXTRA-EDGE LS-E
     CALL "FD-J-DOUBLE" USING JSON-DOC LS-E WA-F(LS-ROW, 3) LS-OK
     IF LS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
*>   the vegetation: a placed feature that is itself unsupported places nothing (the ground still is laid), a missing one is an error
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-VEGETATION LS-E
     MOVE FD-BAD TO LS-SAVED
     CALL "FD-PFREF-NODE" USING JSON-DOC LS-E LS-PF
     MOVE LS-SAVED TO FD-BAD
     IF LS-PF = 0
         MOVE 1 TO FD-BAD
     END-IF
     MOVE LS-PF TO WA-I(LS-ROW, 3)
     GOBACK.
 END PROGRAM FD-VPATCH-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VP-STURDY.
*> USING x, y, z, flag out: 1 when the block at the cell is a solid one (the approximation of "has a sturdy face" of every feature of the stage).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK > 0
         MOVE CB-SOLID(WS-BLOCK) TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM VP-STURDY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VP-LAY.
*> USING state, row, x, y of the first ground block, z, direction (-1 floor, 1 ceiling), placed out: the ground layers of one column (section 9.1 steps 4 and 5): the depth, plus one
*> when the extra bottom chance draws under it, then each layer from the first ground block along the direction. A layer of the block already there is skipped without moving; a block
*> that is not replaceable (or a provider that gives no state) stops the column, which counts as placed when a layer was laid before.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-P4.
    05 WS-Q                BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-LAYERS              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-GSTATE              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-GBLOCK              BINARY-LONG.
 01 WS-REPLACEABLE         BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-D L-PLACED.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WA-IPV(L-ROW, 1, WS-I) TO WS-Q(WS-I)
     END-PERFORM
     CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-LAYERS
     IF WA-F(L-ROW, 1) > 0
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WA-F(L-ROW, 1) WS-U
         IF WS-F < WS-U
             ADD 1 TO WS-LAYERS
         END-IF
     END-IF
     MOVE L-Y TO WS-Y
     MOVE 0 TO WS-STOP
     MOVE 1 TO L-PLACED
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-LAYERS OR WS-STOP = 1
         CALL "FR-PROV-STATE" USING L-STATE WA-PV(L-ROW, 1) L-X WS-Y L-Z WS-GSTATE WS-OK
         CALL "FL-GET-STATE" USING L-X WS-Y L-Z WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-CUR
         CALL "FL-BLOCK-OF" USING WS-GSTATE WS-GBLOCK
         CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-CUR WS-REPLACEABLE
         EVALUATE TRUE
             WHEN WS-OK = 1 AND WS-GBLOCK = WS-CUR
                 CONTINUE
             WHEN WS-OK = 0 OR WS-REPLACEABLE = 0
                 MOVE 1 TO WS-STOP
                 IF WS-I = 0
                     MOVE 0 TO L-PLACED
                 END-IF
             WHEN OTHER
                 CALL "FL-SET-STATE" USING L-X WS-Y L-Z WS-GSTATE WS-FLAGS WS-WRITTEN
                 ADD L-D TO WS-Y
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM VP-LAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-VPATCH IS RECURSIVE.
*> USING state, feature, x, y, z, result out (1 when the ground set is not empty).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-NEIGHBOURS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-NEIGHBOUR-TABLE REDEFINES WS-NEIGHBOURS.
    05 WS-NB OCCURS 5 TIMES.
       10 WS-NDX           BINARY-LONG.
       10 WS-NDY           BINARY-LONG.
       10 WS-NDZ           BINARY-LONG.
 01 WS-WATERLOGGED         PIC X(40) VALUE "waterlogged".
 01 WS-TRUE                PIC X(40) VALUE "true".
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LOCAL-STORAGE SECTION.
 01 LS-LIST.
    05 LS-G OCCURS 4096 TIMES.
       10 LS-GX            BINARY-LONG.
       10 LS-GY            BINARY-LONG.
       10 LS-GZ            BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-RANGE               BINARY-LONG.
 01 LS-RX                  BINARY-LONG.
 01 LS-RZ                  BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-SKIP                BINARY-LONG.
 01 LS-F                   FLOAT-LONG.
 01 LS-U                   FLOAT-LONG.
 01 LS-CX                  BINARY-LONG.
 01 LS-CY                  BINARY-LONG.
 01 LS-CZ                  BINARY-LONG.
 01 LS-STEPS               BINARY-LONG.
 01 LS-GO                  BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-GBLOCK              BINARY-LONG.
 01 LS-BELOW               BINARY-LONG.
 01 LS-SOLID               BINARY-LONG.
 01 LS-LAYERS              BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-GSTATE              BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-STOP                BINARY-LONG.
 01 LS-PLACED              BINARY-LONG.
 01 LS-REPLACEABLE         BINARY-LONG.
 01 LS-EXPOSED             BINARY-LONG.
 01 LS-KEEP                BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-PY                  BINARY-LONG.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-R                   BINARY-LONG.
 01 LS-WATER               BINARY-LONG.
 01 LS-P4.
    05 LS-Q                BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT LS-N
     MOVE FT-A(L-FT) TO LS-ROW
     MOVE WA-I(LS-ROW, 2) TO LS-RANGE
     MOVE -1 TO LS-D
     IF WA-I(LS-ROW, 1) = 1
         MOVE 1 TO LS-D
     END-IF
*>   1. the radii, x first
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 4
         MOVE WA-IPV(LS-ROW, 2, LS-I) TO LS-Q(LS-I)
     END-PERFORM
     CALL "FR-INT-SAMPLE" USING L-STATE LS-P4 LS-RX
     ADD 1 TO LS-RX
     CALL "FR-INT-SAMPLE" USING L-STATE LS-P4 LS-RZ
     ADD 1 TO LS-RZ
*>   2. the ground patch, x outermost
     COMPUTE LS-DX = 0 - LS-RX
     PERFORM VARYING LS-DX FROM LS-DX BY 1 UNTIL LS-DX > LS-RX
         COMPUTE LS-DZ = 0 - LS-RZ
         PERFORM VARYING LS-DZ FROM LS-DZ BY 1 UNTIL LS-DZ > LS-RZ
             MOVE 0 TO LS-SKIP
             IF (LS-DX = LS-RX OR LS-DX = 0 - LS-RX) AND (LS-DZ = LS-RZ OR LS-DZ = 0 - LS-RZ)
                 MOVE 1 TO LS-SKIP
             END-IF
             IF LS-SKIP = 0 AND WA-F(LS-ROW, 3) NOT = 0 AND (LS-DX = LS-RX OR LS-DX = 0 - LS-RX OR LS-DZ = LS-RZ OR LS-DZ = 0 - LS-RZ)
                 CALL "WGR-NEXT-FLOAT" USING L-STATE LS-F
                 CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WA-F(LS-ROW, 3) LS-U
                 IF LS-F > LS-U
                     MOVE 1 TO LS-SKIP
                 END-IF
             END-IF
             IF LS-SKIP = 0
                 COMPUTE LS-CX = L-X + LS-DX
                 COMPUTE LS-CZ = L-Z + LS-DZ
                 MOVE L-Y TO LS-CY
*>               along the surface direction while the cell is air, then back while it is not
                 MOVE 0 TO LS-STEPS LS-GO
                 PERFORM UNTIL LS-GO = 1
                     CALL "FL-GET-STATE" USING LS-CX LS-CY LS-CZ LS-STATE
                     CALL "FL-CLASS" USING LS-STATE LS-CLASS
                     IF LS-CLASS = 1 AND LS-STEPS < LS-RANGE
                         ADD LS-D TO LS-CY
                         ADD 1 TO LS-STEPS
                     ELSE
                         MOVE 1 TO LS-GO
                     END-IF
                 END-PERFORM
                 MOVE 0 TO LS-STEPS LS-GO
                 PERFORM UNTIL LS-GO = 1
                     CALL "FL-GET-STATE" USING LS-CX LS-CY LS-CZ LS-STATE
                     CALL "FL-CLASS" USING LS-STATE LS-CLASS
                     IF LS-CLASS NOT = 1 AND LS-STEPS < LS-RANGE
                         SUBTRACT LS-D FROM LS-CY
                         ADD 1 TO LS-STEPS
                     ELSE
                         MOVE 1 TO LS-GO
                     END-IF
                 END-PERFORM
                 COMPUTE LS-BELOW = LS-CY + LS-D
                 CALL "VP-STURDY" USING LS-CX LS-BELOW LS-CZ LS-SOLID
                 IF LS-CLASS = 1 AND LS-SOLID = 1
                     CALL "VP-LAY" USING L-STATE LS-ROW LS-CX LS-BELOW LS-CZ LS-D LS-PLACED
                     IF LS-PLACED = 1 AND LS-N < 4096
                         ADD 1 TO LS-N
                         MOVE LS-CX TO LS-GX(LS-N)
                         MOVE LS-BELOW TO LS-GY(LS-N)
                         MOVE LS-CZ TO LS-GZ(LS-N)
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
*>   3. the waterlogged variant keeps the unexposed ground (every neighbour but above has a sturdy face; the world is read before any write) and turns it to water
     IF WA-I(LS-ROW, 4) = 1
         MOVE 0 TO LS-KEEP
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-N
             MOVE 0 TO LS-EXPOSED
             PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K > 5
                 COMPUTE LS-NX = LS-GX(LS-I) + WS-NDX(LS-K)
                 COMPUTE LS-NY = LS-GY(LS-I) + WS-NDY(LS-K)
                 COMPUTE LS-NZ = LS-GZ(LS-I) + WS-NDZ(LS-K)
                 CALL "VP-STURDY" USING LS-NX LS-NY LS-NZ LS-SOLID
                 IF LS-SOLID = 0
                     MOVE 1 TO LS-EXPOSED
                 END-IF
             END-PERFORM
             IF LS-EXPOSED = 0
                 ADD 1 TO LS-KEEP
                 MOVE LS-GX(LS-I) TO LS-GX(LS-KEEP)
                 MOVE LS-GY(LS-I) TO LS-GY(LS-KEEP)
                 MOVE LS-GZ(LS-I) TO LS-GZ(LS-KEEP)
             END-IF
         END-PERFORM
         MOVE LS-KEEP TO LS-N
         MOVE CB-DEFAULT-STATE(FL-B-WATER) TO LS-WATER
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-N
             CALL "FL-SET-STATE" USING LS-GX(LS-I) LS-GY(LS-I) LS-GZ(LS-I) LS-WATER WS-FLAGS LS-OK
         END-PERFORM
     END-IF
     IF LS-N > 0
         MOVE 1 TO L-RESULT
     END-IF
*>   4. the vegetation: one draw per ground position in the order found; the feature goes above a floor patch's ground (below a ceiling's), at the ground cell of the waterlogged one
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-N
         IF WA-F(LS-ROW, 2) NOT = 0
             CALL "WGR-NEXT-FLOAT" USING L-STATE LS-F
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WA-F(LS-ROW, 2) LS-U
             IF LS-F < LS-U
                 MOVE LS-GY(LS-I) TO LS-PY
                 IF WA-I(LS-ROW, 4) = 0
                     SUBTRACT LS-D FROM LS-PY
                 END-IF
                 CALL "FR-PLACE-PF" USING L-STATE WA-I(LS-ROW, 3) LS-ZERO LS-GX(LS-I) LS-PY LS-GZ(LS-I) LS-R
*>               a waterlogged ground cell that now holds a block with a false waterlogged property gets it true
                 IF LS-R = 1 AND WA-I(LS-ROW, 4) = 1
                     CALL "FL-GET-STATE" USING LS-GX(LS-I) LS-PY LS-GZ(LS-I) LS-STATE
                     CALL "FD-STATE-SET" USING LS-STATE WS-WATERLOGGED WS-TRUE LS-GSTATE LS-OK
                     IF LS-OK = 1
                         CALL "FL-SET-STATE" USING LS-GX(LS-I) LS-PY LS-GZ(LS-I) LS-GSTATE WS-FLAGS LS-OK
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-VPATCH.
