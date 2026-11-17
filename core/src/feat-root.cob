*> The root system feature (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 10; registry id 38, root_system; the rooted azalea tree): FD-ROOTSYS-NODE compiles the configuration into a
*> row of FD-WA (WA-I(1) the tree's placed feature, WA-I(2) required_vertical_space_for_tree, WA-I(3) level_test_distance, WA-I(4) max_level_deviation, WA-I(5) root_radius, WA-I(6) root_placement_attempts,
*> WA-I(7) root_column_max_height, WA-I(8) hanging_root_radius, WA-I(9) hanging_roots_vertical_span, WA-I(10) hanging_root_placement_attempts, WA-I(11) allowed_vertical_water_for_tree; WA-PR(1) the allowed
*> position predicate; WA-PV(1) the root state provider, WA-PV(2) the hanging root provider; the pool 1 the root_replaceable blocks); FD-BAD when a number is out of the range of the document or a block,
*> provider or predicate is unsupported (the tree's placed feature may itself be unsupported: then it places nothing and the loop goes on).
*> FR-ROOTSYS: the origin must be air; the cursor climbs from the origin for at most root_column_max_height steps: it stops (false) when the WORLD_SURFACE height at the cursor is below the cursor; when the
*> allowed position holds and spaceForTree holds, a lava cell or a not solid block below the cursor ends the search (false) and else the tree is placed at the cursor, after which the rooted dirt column
*> (origin.y to cursor.y - 1, root_placement_attempts draws of four nextInt(root_radius) per cell, a root_replaceable block becomes the root provider's state, flags 2) is laid and the loop ends; then, once the
*> tree went in, the hanging roots (attempts of three offset pairs, an air cell whose cell above is solid takes the hanging root provider's state). Deviations: "sturdy DOWN face" and "solid" are CB-SOLID
*> (the approximation of every feature of the stage), canSurvive of the hanging roots is that same check of the cell above, and the lava test is the block class lava of the level.
*>
*> Entry points: FD-ROOTSYS-NODE USING doc, node, row out; FR-ROOTSYS USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-ROOTSYS-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDCONST.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-SAVED               BINARY-LONG.
 01 WS-KEYS.
    05 FILLER              PIC X(40) VALUE "required_vertical_space_for_tree".
    05 FILLER              PIC X(40) VALUE "level_test_distance".
    05 FILLER              PIC X(40) VALUE "max_level_deviation".
    05 FILLER              PIC X(40) VALUE "root_radius".
    05 FILLER              PIC X(40) VALUE "root_placement_attempts".
    05 FILLER              PIC X(40) VALUE "root_column_max_height".
    05 FILLER              PIC X(40) VALUE "hanging_root_radius".
    05 FILLER              PIC X(40) VALUE "hanging_roots_vertical_span".
    05 FILLER              PIC X(40) VALUE "hanging_root_placement_attempts".
    05 FILLER              PIC X(40) VALUE "allowed_vertical_water_for_tree".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(40) OCCURS 10 TIMES.
*> the row slot (WA-I index), the minimum and the maximum of each field, in the order of WS-KEYS
 01 WS-SPEC.
    05 FILLER              PIC 9(4) VALUE 2.
    05 FILLER              PIC 9(4) VALUE 1.
    05 FILLER              PIC 9(4) VALUE 64.
    05 FILLER              PIC 9(4) VALUE 3.
    05 FILLER              PIC 9(4) VALUE 0.
    05 FILLER              PIC 9(4) VALUE 16.
    05 FILLER              PIC 9(4) VALUE 4.
    05 FILLER              PIC 9(4) VALUE 0.
    05 FILLER              PIC 9(4) VALUE 64.
    05 FILLER              PIC 9(4) VALUE 5.
    05 FILLER              PIC 9(4) VALUE 1.
    05 FILLER              PIC 9(4) VALUE 64.
    05 FILLER              PIC 9(4) VALUE 6.
    05 FILLER              PIC 9(4) VALUE 1.
    05 FILLER              PIC 9(4) VALUE 256.
    05 FILLER              PIC 9(4) VALUE 7.
    05 FILLER              PIC 9(4) VALUE 1.
    05 FILLER              PIC 9(4) VALUE 4096.
    05 FILLER              PIC 9(4) VALUE 8.
    05 FILLER              PIC 9(4) VALUE 1.
    05 FILLER              PIC 9(4) VALUE 64.
    05 FILLER              PIC 9(4) VALUE 9.
    05 FILLER              PIC 9(4) VALUE 1.
    05 FILLER              PIC 9(4) VALUE 16.
    05 FILLER              PIC 9(4) VALUE 10.
    05 FILLER              PIC 9(4) VALUE 1.
    05 FILLER              PIC 9(4) VALUE 256.
    05 FILLER              PIC 9(4) VALUE 11.
    05 FILLER              PIC 9(4) VALUE 1.
    05 FILLER              PIC 9(4) VALUE 64.
 01 WS-SPEC-TABLE REDEFINES WS-SPEC.
    05 WS-SP OCCURS 10 TIMES.
       10 WS-SP-SLOT       PIC 9(4).
       10 WS-SP-MIN        PIC 9(4).
       10 WS-SP-MAX        PIC 9(4).
 01 WS-K-FEATURE           PIC X(40) VALUE "feature".
 01 WS-K-REPLACEABLE       PIC X(40) VALUE "root_replaceable".
 01 WS-K-ROOT              PIC X(40) VALUE "root_state_provider".
 01 WS-K-HANGING           PIC X(40) VALUE "hanging_root_state_provider".
 01 WS-K-ALLOWED           PIC X(40) VALUE "allowed_tree_position".
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-KEY(WS-I) WS-E
         CALL "FD-J-INT" USING JSON-DOC WS-E WS-V WS-OK
         IF WS-OK = 0 OR WS-V < WS-SP-MIN(WS-I) OR WS-V > WS-SP-MAX(WS-I)
             MOVE 1 TO FD-BAD
             MOVE 0 TO WS-V
         END-IF
         MOVE WS-V TO WA-I(WS-ROW, WS-SP-SLOT(WS-I))
     END-PERFORM
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-REPLACEABLE WS-E
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-E FC-N1 WA-START(WS-ROW, 1) WA-N(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ROOT WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-HANGING WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ALLOWED WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 1)
*>   the tree: a placed feature that is itself unsupported places nothing; a missing one is an error
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-FEATURE WS-E
     MOVE FD-BAD TO WS-SAVED
     CALL "FD-PFREF-NODE" USING JSON-DOC WS-E WS-PF
     MOVE WS-SAVED TO FD-BAD
     IF WS-PF = 0
         MOVE 1 TO FD-BAD
     END-IF
     MOVE WS-PF TO WA-I(WS-ROW, 1)
     GOBACK.
 END PROGRAM FD-ROOTSYS-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ROOTSYS.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-SPACE               BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-D3                  BINARY-LONG.
 01 WS-D4                  BINARY-LONG.
 01 WS-D5                  BINARY-LONG.
 01 WS-D6                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-HM-SURFACE          BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-ABOVE               BINARY-LONG.
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
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS NOT = 1
         GOBACK
     END-IF
     MOVE 1 TO L-RESULT
     MOVE 0 TO WS-DONE WS-PLACED
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WA-I(WS-ROW, 7) OR WS-DONE = 1
         COMPUTE WS-CY = L-Y + WS-I + 1
         CALL "FL-HEIGHT-OF" USING WS-HM-SURFACE L-X L-Z WS-H
         IF WS-H < WS-CY
             MOVE 1 TO WS-DONE
         ELSE
             CALL "FR-PRED-TEST" USING WA-PR(WS-ROW, 1) L-X WS-CY L-Z WS-FLAG
             IF WS-FLAG = 1
                 PERFORM SPACE-FOR-TREE
             ELSE
                 MOVE 0 TO WS-SPACE
             END-IF
             IF WS-SPACE = 1
                 COMPUTE WS-QY = WS-CY - 1
                 CALL "FL-GET-STATE" USING L-X WS-QY L-Z WS-STATE
                 CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 CALL "VP-STURDY" USING L-X WS-QY L-Z WS-FLAG
                 IF WS-CLASS = 3 OR WS-FLAG = 0
                     MOVE 1 TO WS-DONE
                 ELSE
                     CALL "FR-PLACE-PF" USING L-STATE WA-I(WS-ROW, 1) WS-ZERO L-X WS-CY L-Z WS-RES
                     IF WS-RES = 1
                         MOVE 1 TO WS-PLACED
                         MOVE 1 TO WS-DONE
                         COMPUTE WS-MAXY = L-Y + WS-I
                         PERFORM PLACE-DIRT
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-PLACED = 1
         PERFORM PLACE-ROOTS
     END-IF
     GO TO MAIN-EXIT.
*> spaceForTree at (L-X, WS-CY, L-Z): WS-SPACE 1 or 0
 SPACE-FOR-TREE.
     MOVE 1 TO WS-SPACE
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WA-I(WS-ROW, 2) OR WS-SPACE = 0
         COMPUTE WS-QY = WS-CY + WS-J
         CALL "FL-GET-STATE" USING L-X WS-QY L-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS = 1
             CONTINUE
         ELSE
             IF WS-CLASS = 2 AND WS-J + 1 <= WA-I(WS-ROW, 11)
                 CONTINUE
             ELSE
                 MOVE 0 TO WS-SPACE
             END-IF
         END-IF
     END-PERFORM
     IF WS-SPACE = 1 AND WA-I(WS-ROW, 3) > 0
         PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 3 OR WS-SPACE = 0
             EVALUATE WS-DIR
                 WHEN 0
                     MOVE 1 TO WS-DX
                     MOVE 0 TO WS-DZ
                 WHEN 1
                     MOVE -1 TO WS-DX
                     MOVE 0 TO WS-DZ
                 WHEN 2
                     MOVE 0 TO WS-DX
                     MOVE 1 TO WS-DZ
                 WHEN OTHER
                     MOVE 0 TO WS-DX
                     MOVE -1 TO WS-DZ
             END-EVALUATE
             COMPUTE WS-QX = L-X + WS-DX * WA-I(WS-ROW, 3)
             COMPUTE WS-QZ = L-Z + WS-DZ * WA-I(WS-ROW, 3)
             COMPUTE WS-QY = WS-CY - WA-I(WS-ROW, 4)
             CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS = 1
                 MOVE 0 TO WS-SPACE
             END-IF
             COMPUTE WS-QY = WS-CY + WA-I(WS-ROW, 4)
             CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS NOT = 1
                 MOVE 0 TO WS-SPACE
             END-IF
         END-PERFORM
     END-IF
     .
*> placeDirt: the rooted dirt column from the origin up to (not including) WS-MAXY
 PLACE-DIRT.
     PERFORM VARYING WS-QY FROM L-Y BY 1 UNTIL WS-QY >= WS-MAXY
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WA-I(WS-ROW, 6)
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 5) WS-D1
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 5) WS-D2
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 5) WS-D3
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 5) WS-D4
             COMPUTE WS-QX = L-X + WS-D1 - WS-D2
             COMPUTE WS-QZ = L-Z + WS-D3 - WS-D4
             CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 1) WA-N(WS-ROW, 1) WS-BLOCK WS-FLAG
             IF WS-FLAG = 1
                 CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 1) WS-QX WS-QY WS-QZ WS-SET WS-OK
                 IF WS-OK = 1
                     CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-SET WS-FLAGS WS-OK
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     .
*> placeRoots: the hanging roots around the origin
 PLACE-ROOTS.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WA-I(WS-ROW, 10)
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 8) WS-D1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 8) WS-D2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 9) WS-D3
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 9) WS-D4
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 8) WS-D5
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WA-I(WS-ROW, 8) WS-D6
         COMPUTE WS-QX = L-X + WS-D1 - WS-D2
         COMPUTE WS-QY = L-Y + WS-D3 - WS-D4
         COMPUTE WS-QZ = L-Z + WS-D5 - WS-D6
         CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS = 1
             CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 2) WS-QX WS-QY WS-QZ WS-SET WS-OK
             COMPUTE WS-ABOVE = WS-QY + 1
             CALL "VP-STURDY" USING WS-QX WS-ABOVE WS-QZ WS-FLAG
             IF WS-OK = 1 AND WS-FLAG = 1
                 CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-SET WS-FLAGS WS-OK
             END-IF
         END-IF
     END-PERFORM
     .
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM FR-ROOTSYS.
