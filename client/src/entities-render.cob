*> Drawing entities (standin-content §3.1, §3.2, §12.6; docs/protocol/08-resource-packs.md §10.3,
*> §10.11): ENTITY-ATLAS-BUILD loads the entity atlas (texture 1): the images
*> textures/entity/operator.png, sodgrazer.png and abend.png, each from the top-most pack that has
*> it, or the missing-texture stripes at its stand-in size (66 x 28, 80 x 23, 72 x 12) when no
*> pack has it, stacked in that order from the top and left-aligned (the atlas is as wide as the
*> widest image; texels right of a narrower image are transparent and never sampled).
*> ENTITIES-MESH builds the frame's entity mesh, eye-relative like the sections: every operator,
*> sodgrazer and abend of the replica as the boxes of its model (model pixels, 1/16 block; +y up,
*> +z the look direction, +x the entity's left), turned about +y by -yaw and moved to the entity
*> position; a box that no longer fits the entity vertex capacity is left out. A row of a standard-set world (EN-VANILLA 1) is
*> never a stand-in: its model of CL-MODELS is drawn by ENTITY-MODEL-EMIT (entities-models.cob). ENTITY-BOX draws
*> one box: six faces, each seen from outside with the corners and texel orientation of standin
*> §3.1 (front +z, back -z, left +x, right -x, top +y, bottom -y; row 0 the top or -z edge), its
*> rectangle in the part's strip at x = 0, w, 2w, 2w + d, 2w + 2d, 3w + 2d, mapped by fractions of
*> the stand-in texture size onto the image's rectangle in the atlas (08 §10.11). Brightness: the
*> face's direction factor (top 1.0, front and back 0.8, left and right 0.6, bottom 0.5, as block
*> faces) times max(sky light x daylight, block light) / 15 of the entity's cell, at least 0.1.
*> GROUND-ITEMS-MESH builds the frame's ground-item mesh (standin-content §3.3), eye-relative: every
*> loose_item of the replica holding a stack is its item's icon (IT-SPRITE, the block and item
*> atlas, texture 0; an item id outside the registry shows the missing texture) on a 0.3 x 0.3 quad,
*> bottom edge at the entity's y, centred on it horizontally, in the vertical plane across the
*> camera's horizontal look direction (yaw Y looks along (-sin Y, 0, cos Y); the camera's right is
*> (-cos Y, 0, -sin Y)), so it faces the camera. Corners top-left (left of the camera), top-right,
*> bottom-right, bottom-left, with the icon's top-left texel at the top-left corner; brightness
*> max(sky light x daylight, block light) / 15 of the entity's cell, at least 0.1; alpha 1 (the
*> icon's own alpha shows through the translucent pipeline).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ATLAS-BUILD.
*> USING CLIENT-STATE: fills EA-* and marks texture 1 for upload. The images are the three stand-ins, then the
*> image of each entity model slot (EA-MT, entities-models.cob; its pack path from CL-MODELS, assets/minecraft/
*> + CL-MD-PATH; a model without a path, or whose image no pack has, shows the missing-texture stripes at the
*> row's CL-MD-TEXW x CL-MD-TEXH), each stacked below the one before it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
*> Per image: entity type, path length, stand-in width and height, path.
 01 WS-SOURCE-DATA.
    05 FILLER PIC X(64) VALUE "04606628assets/cobolcraft/textures/entity/operator.png".
    05 FILLER PIC X(64) VALUE "24708023assets/cobolcraft/textures/entity/sodgrazer.png".
    05 FILLER PIC X(64) VALUE "34307212assets/cobolcraft/textures/entity/abend.png".
 01 WS-SOURCE-TABLE REDEFINES WS-SOURCE-DATA.
    05 WS-SOURCE OCCURS 3 TIMES.
       10 WS-S-TYPE          PIC 9.
       10 WS-S-LENGTH        PIC 99.
       10 WS-S-W             PIC 999.
       10 WS-S-H             PIC 99.
       10 WS-S-PATH          PIC X(56).
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-IMAGES.
    05 WS-IMAGE            PIC X(1048576) OCCURS 3 TIMES.
 01 WS-MODEL-IMAGES.
    05 WS-MIMAGE           PIC X(262144) OCCURS 16 TIMES.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-MD                  BINARY-LONG.
 01 WS-DW                  BINARY-LONG.
 01 WS-DH                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-ROW-BYTES           BINARY-LONG.
 01 WS-RECT.
    05 WS-RC OCCURS 19 TIMES.
       10 WS-RC-Y          BINARY-LONG.
       10 WS-RC-W          BINARY-LONG.
       10 WS-RC-H          BINARY-LONG.
 01 B-IMG                  PIC X(1048576) BASED.
 01 B-ATLAS                PIC X(4194304) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO EA-W EA-H
     COMPUTE WS-N = 3 + EA-MT-COUNT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
         MOVE SPACES TO WS-PATH
         MOVE 0 TO WS-PATH-LENGTH
         IF WS-K <= 3
             MOVE WS-S-PATH(WS-K) TO WS-PATH
             MOVE WS-S-LENGTH(WS-K) TO WS-PATH-LENGTH
             MOVE WS-S-W(WS-K) TO WS-DW
             MOVE WS-S-H(WS-K) TO WS-DH
             MOVE 1048576 TO WS-CAPACITY
             SET ADDRESS OF B-IMG TO ADDRESS OF WS-IMAGE(WS-K)
         ELSE
             COMPUTE WS-M = WS-K - 3
             MOVE EA-MT-MODEL(WS-M) TO WS-MD
             MOVE CL-MD-TEXW(WS-MD) TO WS-DW
             MOVE CL-MD-TEXH(WS-MD) TO WS-DH
             MOVE 262144 TO WS-CAPACITY
             SET ADDRESS OF B-IMG TO ADDRESS OF WS-MIMAGE(WS-M)
             IF CL-MD-PATH(WS-MD) NOT = SPACES
                 MOVE 1 TO WS-PTR
                 STRING "assets/minecraft/" DELIMITED BY SIZE CL-MD-PATH(WS-MD) DELIMITED BY SPACE
                     INTO WS-PATH WITH POINTER WS-PTR
                 COMPUTE WS-PATH-LENGTH = WS-PTR - 1
             END-IF
         END-IF
         MOVE 0 TO WS-FOUND
         IF WS-PATH-LENGTH > 0
             CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH B-IMG WS-CAPACITY
                 WS-W WS-H WS-FOUND
         END-IF
         IF WS-FOUND = 0
             MOVE WS-DW TO WS-W
             MOVE WS-DH TO WS-H
             CALL "MISSING-TEXTURE" USING WS-W WS-H B-IMG
         END-IF
         MOVE EA-H TO WS-RC-Y(WS-K)
         MOVE WS-W TO WS-RC-W(WS-K)
         MOVE WS-H TO WS-RC-H(WS-K)
         IF WS-K <= 3
             COMPUTE WS-T = WS-S-TYPE(WS-K) + 1
             MOVE 0 TO EA-IM-X(WS-T)
             MOVE EA-H TO EA-IM-Y(WS-T)
             MOVE WS-W TO EA-IM-W(WS-T)
             MOVE WS-H TO EA-IM-H(WS-T)
         ELSE
             MOVE 0 TO EA-MT-X(WS-M)
             MOVE EA-H TO EA-MT-Y(WS-M)
             MOVE WS-W TO EA-MT-W(WS-M)
             MOVE WS-H TO EA-MT-H(WS-M)
         END-IF
         ADD WS-H TO EA-H
         MOVE FUNCTION MAX(EA-W, WS-W) TO EA-W
     END-PERFORM
     IF EA-ADDR NOT = NULL
         FREE EA-ADDR
     END-IF
     COMPUTE WS-BYTES = EA-W * EA-H * 4
     ALLOCATE WS-BYTES CHARACTERS RETURNING EA-ADDR
     SET ADDRESS OF B-ATLAS TO EA-ADDR
     MOVE LOW-VALUES TO B-ATLAS(1:WS-BYTES)
*>   Each image row r goes to atlas row (its top + r), from column 0.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
         IF WS-K <= 3
             SET ADDRESS OF B-IMG TO ADDRESS OF WS-IMAGE(WS-K)
         ELSE
             COMPUTE WS-M = WS-K - 3
             SET ADDRESS OF B-IMG TO ADDRESS OF WS-MIMAGE(WS-M)
         END-IF
         COMPUTE WS-ROW-BYTES = WS-RC-W(WS-K) * 4
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R >= WS-RC-H(WS-K)
             COMPUTE WS-TO = (WS-RC-Y(WS-K) + WS-R) * EA-W * 4 + 1
             COMPUTE WS-FROM = WS-R * WS-ROW-BYTES + 1
             MOVE B-IMG(WS-FROM:WS-ROW-BYTES) TO B-ATLAS(WS-TO:WS-ROW-BYTES)
         END-PERFORM
     END-PERFORM
     MOVE 1 TO AT-UPLOAD(2)
     GOBACK.
 END PROGRAM ENTITY-ATLAS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITIES-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): RL-EN-VERTEX and RL-EN-COUNT for this frame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
*> The model boxes (08 §10.11; standin-content §3.2, §12.6): entity type, from x y z and to x y z
*> in model pixels, the top row of its part's strip, the stand-in texture width and height.
 01 WS-BOX-DATA.
    05 FILLER PIC X(31) VALUE "0-055+000-055+055+280+055006628".
    05 FILLER PIC X(31) VALUE "2-070+030-060+070+120+060008023".
    05 FILLER PIC X(31) VALUE "2-040+060+060+040+140+110128023".
    05 FILLER PIC X(31) VALUE "2+020+000+020+050+030+050208023".
    05 FILLER PIC X(31) VALUE "2-050+000+020-020+030+050208023".
    05 FILLER PIC X(31) VALUE "2+020+000-050+050+030-020208023".
    05 FILLER PIC X(31) VALUE "2-050+000-050-020+030-020208023".
    05 FILLER PIC X(31) VALUE "3-060+000-060+060+120+060007212".
 01 WS-BOX-TABLE REDEFINES WS-BOX-DATA.
    05 WS-MODEL-BOX OCCURS 8 TIMES.
       10 WS-MB-TYPE         PIC 9.
       10 WS-MB-CORNER       PIC S99V9 SIGN LEADING SEPARATE OCCURS 6 TIMES.
       10 WS-MB-STRIP        PIC 99.
       10 WS-MB-TEX-W        PIC 99.
       10 WS-MB-TEX-H        PIC 99.
 01 WS-R                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-SAVED               PIC X(1024).
 01 WS-BOX.
    05 WS-CORNER           FLOAT-LONG OCCURS 6 TIMES.
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
     MOVE 0 TO WS-STRIP-X
*>   Every model the replica shows has its image in the atlas before any vertex takes a texture coordinate from it.
     CALL "ENTITY-MODEL-SLOTS" USING CLIENT-STATE
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-MODEL(WS-R) > 0
             CALL "ENTITY-MODEL-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
         END-IF
         PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 8
             IF EN-USED(WS-R) = 1 AND EN-VANILLA(WS-R) = 0 AND EN-TYPE(WS-R) = WS-MB-TYPE(WS-B)
                     AND RL-EN-COUNT + 36 <= CL-MAX-ENTITY-VERTICES
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 6
                     MOVE WS-MB-CORNER(WS-B, WS-A) TO WS-CORNER(WS-A)
                 END-PERFORM
                 MOVE WS-MB-STRIP(WS-B) TO WS-STRIP-Y
                 MOVE WS-MB-TEX-W(WS-B) TO WS-TEX-W
                 MOVE WS-MB-TEX-H(WS-B) TO WS-TEX-H
                 COMPUTE WS-T = WS-MB-TYPE(WS-B) + 1
                 MOVE EA-IM-X(WS-T) TO WS-RECT-X
                 MOVE EA-IM-Y(WS-T) TO WS-RECT-Y
                 MOVE EA-IM-W(WS-T) TO WS-RECT-W
                 MOVE EA-IM-H(WS-T) TO WS-RECT-H
                 CALL "ENTITY-BOX" USING CLIENT-STATE WS-R L-EYE-TABLE WS-BOX WS-SKIN
             END-IF
         END-PERFORM
     END-PERFORM
*>   The local player's own model in the third-person modes (12 §7.3): the operator's boxes at the player's position and yaw, on the first free row.
     IF CL-CAMERA > 0 AND EN-COUNT < CL-MAX-ENTITIES AND RL-EN-COUNT + 36 <= CL-MAX-ENTITY-VERTICES
         COMPUTE WS-R = EN-COUNT + 1
         MOVE EN-ENTITY(WS-R) TO WS-SAVED
         MOVE PL-X TO EN-X(WS-R)
         MOVE PL-Y TO EN-Y(WS-R)
         MOVE PL-Z TO EN-Z(WS-R)
         MOVE PL-YAW TO EN-YAW(WS-R)
         MOVE 1 TO WS-B
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 6
             MOVE WS-MB-CORNER(WS-B, WS-A) TO WS-CORNER(WS-A)
         END-PERFORM
         MOVE WS-MB-STRIP(WS-B) TO WS-STRIP-Y
         MOVE WS-MB-TEX-W(WS-B) TO WS-TEX-W
         MOVE WS-MB-TEX-H(WS-B) TO WS-TEX-H
         MOVE EA-IM-X(1) TO WS-RECT-X
         MOVE EA-IM-Y(1) TO WS-RECT-Y
         MOVE EA-IM-W(1) TO WS-RECT-W
         MOVE EA-IM-H(1) TO WS-RECT-H
         CALL "ENTITY-BOX" USING CLIENT-STATE WS-R L-EYE-TABLE WS-BOX WS-SKIN
         MOVE WS-SAVED TO EN-ENTITY(WS-R)
     END-IF
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
             MOVE 0 TO RL-EN-SKY(RL-EN-COUNT)
             MOVE 1 TO RL-EN-R(RL-EN-COUNT) RL-EN-G(RL-EN-COUNT) RL-EN-BLUE(RL-EN-COUNT)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GROUND-ITEMS-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): RL-GI-VERTEX and RL-GI-COUNT for this frame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X             FLOAT-SHORT.
       10 WS-C-Y             FLOAT-SHORT.
       10 WS-C-Z             FLOAT-SHORT.
       10 WS-C-U             FLOAT-SHORT.
       10 WS-C-V             FLOAT-SHORT.
*> The six vertices of the quad: corners 1, 2, 3, 1, 3, 4.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     MOVE 0 TO RL-GI-COUNT
     COMPUTE WS-RX = - FUNCTION COS(PL-YAW * FUNCTION PI / 180)
     COMPUTE WS-RZ = - FUNCTION SIN(PL-YAW * FUNCTION PI / 180)
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-TYPE(WS-R) = ET-LOOSE-ITEM AND EN-STACK-COUNT(WS-R) > 0
                 AND RL-GI-COUNT + 6 <= CL-MAX-GI-VERTICES
             MOVE 1 TO WS-SPRITE
             IF EN-STACK-ITEM(WS-R) >= 0 AND EN-STACK-ITEM(WS-R) < CL-ITEM-COUNT
                 MOVE IT-SPRITE(EN-STACK-ITEM(WS-R) + 1) TO WS-SPRITE
             END-IF
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-R))
             COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-R))
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-R))
             CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
             COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15,
                 0.1)
*>           Corner k: left (-0.15 along the right) for 1 and 4, right (+0.15) for 2 and 3; top
*>           (y + 0.3) for 1 and 2, bottom for 3 and 4.
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 MOVE -0.15 TO WS-SIDE
                 MOVE 0 TO WS-U16
                 IF WS-K = 2 OR WS-K = 3
                     MOVE 0.15 TO WS-SIDE
                     MOVE 16 TO WS-U16
                 END-IF
                 COMPUTE WS-C-X(WS-K) = EN-X(WS-R) - L-EYE(1) + WS-SIDE * WS-RX
                 COMPUTE WS-C-Y(WS-K) = EN-Y(WS-R) - L-EYE(2) + 0.3
                 MOVE 0 TO WS-V16
                 IF WS-K >= 3
                     COMPUTE WS-C-Y(WS-K) = EN-Y(WS-R) - L-EYE(2)
                     MOVE 16 TO WS-V16
                 END-IF
                 COMPUTE WS-C-Z(WS-K) = EN-Z(WS-R) - L-EYE(3) + WS-SIDE * WS-RZ
                 CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-C-U(WS-K)
                     WS-C-V(WS-K)
             END-PERFORM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 MOVE WS-ORD(WS-I) TO WS-N
                 ADD 1 TO RL-GI-COUNT
                 MOVE WS-C-X(WS-N) TO RL-GI-X(RL-GI-COUNT)
                 MOVE WS-C-Y(WS-N) TO RL-GI-Y(RL-GI-COUNT)
                 MOVE WS-C-Z(WS-N) TO RL-GI-Z(RL-GI-COUNT)
                 MOVE WS-C-U(WS-N) TO RL-GI-U(RL-GI-COUNT)
                 MOVE WS-C-V(WS-N) TO RL-GI-V(RL-GI-COUNT)
                 MOVE WS-LIGHT TO RL-GI-B(RL-GI-COUNT)
                 MOVE 1 TO RL-GI-A(RL-GI-COUNT)
                 MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
                 MOVE 1 TO RL-GI-R(RL-GI-COUNT) RL-GI-G(RL-GI-COUNT) RL-GI-BLUE(RL-GI-COUNT)
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GROUND-ITEMS-MESH.
