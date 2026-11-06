*> Drawing entities (standin-content §3.1, §3.2; docs/protocol/08-resource-packs.md §10.3, §10.11):
*> ENTITY-ATLAS-BUILD loads the entity atlas (texture 1): the operator image
*> textures/entity/operator.png from the top-most pack that has it, or the missing-texture stripes
*> at the stand-in size 66 x 28 when no pack has it. ENTITIES-MESH builds the frame's entity mesh,
*> eye-relative like the sections: every operator entity of the replica as its box (-5.5, 0,
*> -5.5) to (5.5, 28, 5.5) in model pixels (1/16 block; +y up, +z the look direction, +x the
*> entity's left), turned about +y by -yaw and moved to the entity position. ENTITY-BOX draws one
*> box: six faces, each seen from outside with the corners and texel orientation of standin §3.1
*> (front +z, back -z, left +x, right -x, top +y, bottom -y; row 0 the top or -z edge), its
*> rectangle in the part's strip at x = 0, w, 2w, 2w + d, 2w + 2d, 3w + 2d, mapped by fractions of
*> the stand-in texture size onto the image's rectangle in the atlas (08 §10.11). Brightness: the
*> face's direction factor (top 1.0, front and back 0.8, left and right 0.6, bottom 0.5, as block
*> faces) times max(sky light x daylight, block light) / 15 of the entity's cell, at least 0.1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ATLAS-BUILD.
*> USING CLIENT-STATE: fills EA-* and marks texture 1 for upload.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(256) VALUE "assets/cobolcraft/textures/entity/operator.png".
 01 WS-PATH-LENGTH         BINARY-LONG VALUE 46.
 01 WS-IMAGE               PIC X(1048576).
 01 WS-CAPACITY            BINARY-LONG VALUE 1048576.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 B-ATLAS                PIC X(1048576) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMAGE WS-CAPACITY WS-W WS-H
         WS-FOUND
     IF WS-FOUND = 0
         MOVE 66 TO WS-W
         MOVE 28 TO WS-H
         CALL "MISSING-TEXTURE" USING WS-W WS-H WS-IMAGE
     END-IF
     MOVE WS-W TO EA-W EA-OP-W
     MOVE WS-H TO EA-H EA-OP-H
     MOVE 0 TO EA-OP-X EA-OP-Y
     IF EA-ADDR NOT = NULL
         FREE EA-ADDR
     END-IF
     COMPUTE WS-BYTES = WS-W * WS-H * 4
     ALLOCATE WS-BYTES CHARACTERS RETURNING EA-ADDR
     SET ADDRESS OF B-ATLAS TO EA-ADDR
     MOVE WS-IMAGE(1:WS-BYTES) TO B-ATLAS(1:WS-BYTES)
     MOVE 1 TO AT-UPLOAD(2)
     GOBACK.
 END PROGRAM ENTITY-ATLAS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITIES-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): RL-EN-VERTEX and RL-EN-COUNT for this frame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-R                   BINARY-LONG.
 01 WS-BOX.
    05 WS-FROM             FLOAT-LONG OCCURS 3 TIMES.
    05 WS-TO               FLOAT-LONG OCCURS 3 TIMES.
*> The part's strip (top-left texel), the stand-in texture size and the image's atlas rectangle.
 01 WS-SKIN.
    05 WS-STRIP-X          BINARY-LONG.
    05 WS-STRIP-Y          BINARY-LONG.
    05 WS-TEX-W            BINARY-LONG.
    05 WS-TEX-H            BINARY-LONG.
    05 WS-RECT-X           BINARY-LONG.
    05 WS-RECT-Y           BINARY-LONG.
    05 WS-RECT-W           BINARY-LONG.
    05 WS-RECT-H           BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     MOVE 0 TO RL-EN-COUNT
     MOVE -5.5 TO WS-FROM(1) WS-FROM(3)
     MOVE 0 TO WS-FROM(2)
     MOVE 5.5 TO WS-TO(1) WS-TO(3)
     MOVE 28 TO WS-TO(2)
     MOVE 0 TO WS-STRIP-X WS-STRIP-Y
     MOVE 66 TO WS-TEX-W
     MOVE 28 TO WS-TEX-H
     MOVE EA-OP-X TO WS-RECT-X
     MOVE EA-OP-Y TO WS-RECT-Y
     MOVE EA-OP-W TO WS-RECT-W
     MOVE EA-OP-H TO WS-RECT-H
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-TYPE(WS-R) = ET-OPERATOR
                 AND RL-EN-COUNT + 36 <= CL-MAX-ENTITY-VERTICES
             CALL "ENTITY-BOX" USING CLIENT-STATE WS-R L-EYE-TABLE WS-BOX WS-SKIN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITIES-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BOX.
*> USING CLIENT-STATE, entity row, eye (3 FLOAT-LONG), box (from, to: 6 FLOAT-LONG model pixels),
*> skin (strip x, y, stand-in texture width, height, atlas rectangle x, y, w, h: 8 BINARY-LONG):
*> appends the box's 36 vertices to RL-EN-VERTEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
*> Per face (front, back, left, right, top, bottom): the corners top-left, top-right,
*> bottom-right, bottom-left as x, y, z picks (0 = from, 1 = to).
 01 WS-CORNER-DATA.
    05 FILLER PIC X(12) VALUE "011111101001".
    05 FILLER PIC X(12) VALUE "110010000100".
    05 FILLER PIC X(12) VALUE "111110100101".
    05 FILLER PIC X(12) VALUE "010011001000".
    05 FILLER PIC X(12) VALUE "010110111011".
    05 FILLER PIC X(12) VALUE "100000001101".
 01 WS-CORNER-TABLE REDEFINES WS-CORNER-DATA.
    05 WS-FACE OCCURS 6 TIMES.
       10 WS-PICK            PIC 9 OCCURS 12 TIMES.
 01 WS-FACTOR-DATA.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 1.0.
    05 FILLER PIC 9V9 VALUE 0.5.
 01 WS-FACTOR-TABLE REDEFINES WS-FACTOR-DATA.
    05 WS-FACTOR           PIC 9V9 OCCURS 6 TIMES.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-FW                  FLOAT-LONG.
 01 WS-FH                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-BRIGHT              FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-M                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-CX-V            FLOAT-SHORT.
       10 WS-CY-V            FLOAT-SHORT.
       10 WS-CZ-V            FLOAT-SHORT.
       10 WS-CU              FLOAT-SHORT.
       10 WS-CV              FLOAT-SHORT.
*> The six vertices of a quad: corners 1, 2, 3, 1, 3, 4.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-BOX.
    05 L-FROM              FLOAT-LONG OCCURS 3 TIMES.
    05 L-TO                FLOAT-LONG OCCURS 3 TIMES.
 01 L-SKIN.
    05 L-STRIP-X           BINARY-LONG.
    05 L-STRIP-Y           BINARY-LONG.
    05 L-TEX-W             BINARY-LONG.
    05 L-TEX-H             BINARY-LONG.
    05 L-RECT-X            BINARY-LONG.
    05 L-RECT-Y            BINARY-LONG.
    05 L-RECT-W            BINARY-LONG.
    05 L-RECT-H            BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE L-BOX L-SKIN.
     COMPUTE WS-W = L-TO(1) - L-FROM(1)
     COMPUTE WS-H = L-TO(2) - L-FROM(2)
     COMPUTE WS-D = L-TO(3) - L-FROM(3)
     COMPUTE WS-COS = FUNCTION COS(EN-YAW(L-ROW) * FUNCTION PI / 180)
     COMPUTE WS-SIN = FUNCTION SIN(EN-YAW(L-ROW) * FUNCTION PI / 180)
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
*>       The face's rectangle in the strip: its left edge and size in texels.
         EVALUATE WS-F
             WHEN 1
                 MOVE 0 TO WS-TX
             WHEN 2
                 MOVE WS-W TO WS-TX
             WHEN 3
                 COMPUTE WS-TX = 2 * WS-W
             WHEN 4
                 COMPUTE WS-TX = 2 * WS-W + WS-D
             WHEN 5
                 COMPUTE WS-TX = 2 * WS-W + 2 * WS-D
             WHEN OTHER
                 COMPUTE WS-TX = 3 * WS-W + 2 * WS-D
         END-EVALUATE
         MOVE WS-W TO WS-FW
         MOVE WS-H TO WS-FH
         IF WS-F = 3 OR WS-F = 4
             MOVE WS-D TO WS-FW
         END-IF
         IF WS-F >= 5
             MOVE WS-D TO WS-FH
         END-IF
         COMPUTE WS-TX = WS-TX + L-STRIP-X
         MOVE L-STRIP-Y TO WS-TY
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 COMPUTE WS-I = (WS-K - 1) * 3 + WS-A
                 MOVE L-FROM(WS-A) TO WS-M(WS-A)
                 IF WS-PICK(WS-F, WS-I) = 1
                     MOVE L-TO(WS-A) TO WS-M(WS-A)
                 END-IF
             END-PERFORM
             COMPUTE WS-CX-V(WS-K) = EN-X(L-ROW) - L-EYE(1)
                 + (WS-M(1) * WS-COS - WS-M(3) * WS-SIN) / 16
             COMPUTE WS-CY-V(WS-K) = EN-Y(L-ROW) - L-EYE(2) + WS-M(2) / 16
             COMPUTE WS-CZ-V(WS-K) = EN-Z(L-ROW) - L-EYE(3)
                 + (WS-M(1) * WS-SIN + WS-M(3) * WS-COS) / 16
*>           Texel corner: top-left (tx, ty), top-right (tx + fw, ty), and so on.
             COMPUTE WS-CU(WS-K) = (L-RECT-X + WS-TX / L-TEX-W * L-RECT-W) / EA-W
             COMPUTE WS-CV(WS-K) = (L-RECT-Y + WS-TY / L-TEX-H * L-RECT-H) / EA-H
             IF WS-K = 2 OR WS-K = 3
                 COMPUTE WS-CU(WS-K) = (L-RECT-X + (WS-TX + WS-FW) / L-TEX-W * L-RECT-W) / EA-W
             END-IF
             IF WS-K >= 3
                 COMPUTE WS-CV(WS-K) = (L-RECT-Y + (WS-TY + WS-FH) / L-TEX-H * L-RECT-H) / EA-H
             END-IF
         END-PERFORM
         COMPUTE WS-BRIGHT = FUNCTION MAX(WS-FACTOR(WS-F) * WS-LIGHT, 0.1)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
             MOVE WS-ORD(WS-I) TO WS-N
             ADD 1 TO RL-EN-COUNT
             MOVE WS-CX-V(WS-N) TO RL-EN-X(RL-EN-COUNT)
             MOVE WS-CY-V(WS-N) TO RL-EN-Y(RL-EN-COUNT)
             MOVE WS-CZ-V(WS-N) TO RL-EN-Z(RL-EN-COUNT)
             MOVE WS-CU(WS-N) TO RL-EN-U(RL-EN-COUNT)
             MOVE WS-CV(WS-N) TO RL-EN-V(RL-EN-COUNT)
             MOVE WS-BRIGHT TO RL-EN-B(RL-EN-COUNT)
             MOVE 1 TO RL-EN-A(RL-EN-COUNT)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-BOX.
