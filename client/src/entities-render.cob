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
 01 WS-VPATH               PIC X(64).
 01 WS-VFULL               PIC X(256).
 01 WS-VLEN                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-IMAGES.
    05 WS-IMAGE            PIC X(1048576) OCCURS 3 TIMES.
 01 WS-MODEL-IMAGES.
    05 WS-MIMAGE           PIC X(262144) OCCURS 64 TIMES.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-MD                  BINARY-LONG.
 01 WS-DW                  BINARY-LONG.
 01 WS-DH                  BINARY-LONG.
 01 WS-PAL                 BINARY-LONG.
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
    05 WS-RC OCCURS 67 TIMES.
       10 WS-RC-Y          BINARY-LONG.
       10 WS-RC-W          BINARY-LONG.
       10 WS-RC-H          BINARY-LONG.
 01 B-IMG                  PIC X(1048576) BASED.
 01 B-ATLAS                PIC X(16777216) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "VILLAGER-HAT-RESET"
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
*>       A model slot with a variant texture (ENTITY-TEX-PATH) asks the pack stack for it first and falls back to the row's own image.
         IF WS-K > 3 AND EA-MT-TEX(WS-M) > 0
             MOVE SPACES TO WS-VPATH
             CALL "ENTITY-TEX-PATH" USING CL-MD-KEY(WS-MD) EA-MT-TEX(WS-M) WS-VPATH
             IF WS-VPATH NOT = SPACES
                 MOVE SPACES TO WS-VFULL
                 MOVE 1 TO WS-PTR
                 STRING "assets/minecraft/" DELIMITED BY SIZE FUNCTION TRIM(WS-VPATH) DELIMITED BY SIZE
                     INTO WS-VFULL WITH POINTER WS-PTR
                 COMPUTE WS-VLEN = WS-PTR - 1
                 CALL "PACK-IMAGE" USING CLIENT-STATE WS-VFULL WS-VLEN B-IMG WS-CAPACITY
                     WS-W WS-H WS-FOUND
*>               An armor trim texture is recoloured with its palette (code 100000 + palette * 100 + pattern, 54 section 18.4 rule 4).
                 IF WS-FOUND = 1 AND EA-MT-TEX(WS-M) >= 100000
                     COMPUTE WS-PAL = FUNCTION MOD(FUNCTION INTEGER(EA-MT-TEX(WS-M) / 100), 1000)
                     CALL "TRIM-RECOLOUR" USING B-IMG WS-W WS-H WS-PAL
                 END-IF
             END-IF
         END-IF
         IF WS-FOUND = 0 AND WS-PATH-LENGTH > 0
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
 COPY CLMODELS.
 COPY CONTENT.
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
 01 WS-SAVED-MODEL         BINARY-LONG.
 01 WS-ADULT-MODEL         BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
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
 01 WS-OV                  BINARY-LONG.
 01 WS-OV-CODE             BINARY-LONG.
 01 WS-OV-R                FLOAT-LONG.
 01 WS-OV-G                FLOAT-LONG.
 01 WS-OV-B                FLOAT-LONG.
 01 WS-OV-M                BINARY-LONG.
 01 WS-G0                  BINARY-LONG.
 01 WS-GI                  BINARY-LONG.
 01 WS-GSLOT               BINARY-LONG.
 01 WS-GU                  FLOAT-LONG.
 01 WS-GV                  FLOAT-LONG.
 01 WS-GSCALE              FLOAT-LONG VALUE 0.5.
 01 WS-GSTR                FLOAT-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-HSLOT               BINARY-LONG.
 01 WS-HDYE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     MOVE 0 TO RL-EN-COUNT RL-GL-COUNT
     MOVE 0 TO WS-STRIP-X
*>   Every model the replica shows has its image in the atlas before any vertex takes a texture coordinate from it.
     CALL "ENTITY-MODEL-SLOTS" USING CLIENT-STATE
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
*>       An entity wholly outside the view frustum (a sphere of 6 blocks round its feet and a block above them, the figures being
*>       smaller) is not meshed: underground most of the mobs are behind the rock or the player.
         MOVE 1 TO WS-SEEN
         IF RL-CULL-ON = 1 AND EN-USED(WS-R) = 1
             COMPUTE WS-DX = EN-X(WS-R) - L-EYE(1)
             COMPUTE WS-DY = EN-Y(WS-R) + 1 - L-EYE(2)
             COMPUTE WS-DZ = EN-Z(WS-R) - L-EYE(3)
             PERFORM VARYING WS-P FROM 0 BY 3 UNTIL WS-P > 9 OR WS-SEEN = 0
                 COMPUTE WS-DOT = RL-CULL-PLANE(WS-P + 1) * WS-DX + RL-CULL-PLANE(WS-P + 2) * WS-DY
                     + RL-CULL-PLANE(WS-P + 3) * WS-DZ + 6
                 IF WS-DOT < 0
                     MOVE 0 TO WS-SEEN
                 END-IF
             END-PERFORM
         END-IF
         IF EN-USED(WS-R) = 1 AND EN-KEY(WS-R) = "end_crystal" AND EN-BP(WS-R) = 1
             MOVE 1 TO WS-SEEN
         END-IF
         MOVE EN-MODEL(WS-R) TO WS-ADULT-MODEL
         MOVE 0 TO EN-HAND-OK(WS-R, 1) EN-HAND-OK(WS-R, 2) EN-HAND-FOK(WS-R, 1) EN-HAND-FOK(WS-R, 2)
         IF EN-USED(WS-R) = 1 AND EN-MODEL(WS-R) > 0
             CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE WS-R EN-MODEL(WS-R)
         END-IF
         IF EN-USED(WS-R) = 1 AND EN-MODEL(WS-R) > 0 AND WS-SEEN = 1
             EVALUATE TRUE
*>               An item frame draws no entity model: its item is in the ground item mesh (ENTITY-FRAME-EMIT).
                 WHEN CL-MD-ANIM(EN-MODEL(WS-R)) = "F"
                     CONTINUE
                 WHEN CL-MD-FAMILY(EN-MODEL(WS-R)) = 0 AND CL-MD-ANIM(EN-MODEL(WS-R)) = "A"
                     CALL "ENTITY-ARROW-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
                 WHEN CL-MD-FAMILY(EN-MODEL(WS-R)) = 0
                     CALL "ENTITY-ORB-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
                 WHEN OTHER
                     CALL "ENTITY-MODEL-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
             END-EVALUATE
*>           A guardian's beam to its attack target (34-6 11.6).
             IF (EN-KEY(WS-R) = "guardian" OR "elder_guardian") AND EN-TGT(WS-R) NOT = 0
                 CALL "ENTITY-BEAM-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
             END-IF
*>           The extra layer of the model (CL-MD-EXTRA: the sheep's wool) is the same row drawn as that model.
             MOVE EN-MODEL(WS-R) TO WS-SAVED-MODEL
*>           A sheared sheep (entry 18 bit 16) draws no wool.
             IF CL-MD-EXTRA(WS-SAVED-MODEL) > 0
                     AND NOT (EN-KEY(WS-R) = "sheep" AND EN-VAR(WS-R) >= 16 AND FUNCTION MOD(FUNCTION INTEGER(EN-VAR(WS-R) / 16), 2) = 1)
                 MOVE CL-MD-EXTRA(WS-SAVED-MODEL) TO EN-MODEL(WS-R)
                 CALL "ENTITY-MODEL-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
                 MOVE WS-SAVED-MODEL TO EN-MODEL(WS-R)
             END-IF
*>           The overlay layers (ENTITY-OVERLAY: villager type, profession and level, horse markings, collars): the model again with the layer's texture.
             PERFORM VARYING WS-OV FROM 1 BY 1 UNTIL WS-OV > 12
                 CALL "ENTITY-OVERLAY" USING CLIENT-STATE WS-R WS-OV WS-OV-CODE WS-OV-R WS-OV-G WS-OV-B WS-OV-M
                 IF WS-OV-CODE > 0 AND CL-MD-FAMILY(EN-MODEL(WS-R)) > 0
                     MOVE WS-OV-CODE TO EN-OVL(WS-R)
                     MOVE WS-OV TO EN-OVN(WS-R)
                     IF WS-OV-M > 0
                         MOVE WS-OV-M TO EN-MODEL(WS-R)
                     END-IF
                     CALL "ENTITY-MODEL-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
                     MOVE WS-SAVED-MODEL TO EN-MODEL(WS-R)
                     MOVE 0 TO EN-OVL(WS-R) EN-OVN(WS-R)
                 END-IF
             END-PERFORM
*>           The glint layers 13 to 16 of the armor pieces whose stack has the foil (54 section 19.3): the piece's model again, into the glint mesh.
             IF EN-EQ-FOIL(WS-R, 3) + EN-EQ-FOIL(WS-R, 4) + EN-EQ-FOIL(WS-R, 5) + EN-EQ-FOIL(WS-R, 6) > 0
                 PERFORM VARYING WS-OV FROM 13 BY 1 UNTIL WS-OV > 16
                     CALL "ENTITY-OVERLAY" USING CLIENT-STATE WS-R WS-OV WS-OV-CODE WS-OV-R WS-OV-G WS-OV-B WS-OV-M
                     IF WS-OV-CODE > 0 AND WS-OV-M > 0 AND CL-MD-FAMILY(EN-MODEL(WS-R)) > 0
                         MOVE WS-OV-CODE TO EN-OVL(WS-R)
                         MOVE WS-OV TO EN-OVN(WS-R)
                         MOVE WS-OV-M TO EN-MODEL(WS-R)
                         MOVE RL-EN-COUNT TO WS-G0
                         CALL "ENTITY-MODEL-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
                         PERFORM GLINT-MOVE
                         MOVE WS-SAVED-MODEL TO EN-MODEL(WS-R)
                         MOVE 0 TO EN-OVL(WS-R) EN-OVN(WS-R)
                     END-IF
                 END-PERFORM
             END-IF
*>           The banner a mob holds (the entity atlas holds its sprites, so the entity pass draws it): the arm frames the model just found (ENTITY-HELD-POSED).
             PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 2
                 COMPUTE WS-HSLOT = WS-H
                 IF FUNCTION MOD(FUNCTION INTEGER(EN-MOB-FLAGS(WS-R) / 2), 2) = 1
                     COMPUTE WS-HSLOT = 3 - WS-H
                 END-IF
                 IF EN-HAND-FOK(WS-R, WS-H) = 1 AND EN-EQ(WS-R, WS-HSLOT) > 0
                     CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE EN-EQ(WS-R, WS-HSLOT) WS-HDYE
                     IF WS-HDYE >= 0
                         CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-R WS-H EN-EQ(WS-R, WS-HSLOT) L-EYE-TABLE
                     END-IF
                 END-IF
             END-PERFORM
*>           The crystal beam of a crystal with a beam target and of a dragon with a nearest crystal (34-7 7.3, 8.5 pass 4, 8.7).
             IF (EN-KEY(WS-R) = "end_crystal" AND EN-BP(WS-R) = 1) OR (EN-KEY(WS-R) = "ender_dragon" AND EN-NCI(WS-R) NOT = 0)
                 CALL "ENTITY-CRYSTAL-BEAM-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
             END-IF
         END-IF
         MOVE WS-ADULT-MODEL TO EN-MODEL(WS-R)
         PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 8
             IF EN-USED(WS-R) = 1 AND WS-SEEN = 1 AND EN-VANILLA(WS-R) = 0 AND EN-TYPE(WS-R) = WS-MB-TYPE(WS-B)
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
*>   The shulker boxes of the loaded chunks (the block entity renderer of 52 section 4).
     CALL "SHULKER-MESH" USING CLIENT-STATE L-EYE-TABLE
*>   The local player's own model in the third-person modes (12 §7.3): the operator's boxes at the player's position and yaw, on the first free row.
     IF CL-CAMERA > 0 AND EN-COUNT < CL-MAX-ENTITIES AND RL-EN-COUNT + 36 <= CL-MAX-ENTITY-VERTICES
         COMPUTE WS-R = EN-COUNT + 1
         MOVE EN-ENTITY(WS-R) TO WS-SAVED
         MOVE PL-X TO EN-X(WS-R)
         MOVE PL-Y TO EN-Y(WS-R)
         MOVE PL-Z TO EN-Z(WS-R)
         MOVE PL-YAW TO EN-YAW(WS-R)
*>       A world of the standard set: the row is a "player" of the model table (the humanoid with the default skin), emitted like any
*>       other replica row; only the cobolcraft stand-in world keeps the operator's box.
         IF CT-OPEN = 1 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
             MOVE 1 TO EN-USED(WS-R) EN-VANILLA(WS-R)
             MOVE PL-YAW TO EN-HEAD-YAW(WS-R)
             MOVE PL-PITCH TO EN-PITCH(WS-R)
             MOVE 1 TO EN-ON-GROUND(WS-R)
             MOVE PL-POSE TO EN-POSE(WS-R)
             MOVE PL-SWIM-AMOUNT TO EN-SWIM(WS-R)
             COMPUTE EN-FLAGS(WS-R) = PL-SWIMMING * 16
             MOVE PL-ANIM-SPEED TO EN-WALK-SPEED(WS-R)
             MOVE PL-ANIM-POS TO EN-WALK-POS(WS-R)
             MOVE 1 TO EN-WALK-SCALE(WS-R)
             MOVE PL-ANIM-AGE TO EN-AGE(WS-R)
             MOVE 0 TO EN-MOB-FLAGS(WS-R) EN-SW-ACTIVE(WS-R)
             MOVE SPACES TO EN-KEY(WS-R)
             MOVE "player" TO EN-KEY(WS-R)
             CALL "ENTITY-MODEL-FIND" USING EN-KEY(WS-R) EN-MODEL(WS-R)
             ADD 1 TO EN-COUNT
             CALL "ENTITY-MODEL-SLOTS" USING CLIENT-STATE
             CALL "ENTITY-MODEL-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
             SUBTRACT 1 FROM EN-COUNT
             MOVE WS-SAVED TO EN-ENTITY(WS-R)
             GOBACK
         END-IF
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
     GO TO MAIN-EXIT.

*> The vertices the glint layer just appended to RL-EN-VERTEX (from WS-G0 + 1) move to the glint mesh: the model-space texture coordinate of the layer's atlas slot
*> through GLINT-UV at the armour scale 0.5, brightness the glint strength, alpha 1, no sky term, no tint (54 section 19.3).
 GLINT-MOVE.
     CALL "GLINT-STRENGTH" USING CLIENT-STATE WS-GSTR
     MOVE 0 TO WS-GSLOT
     PERFORM VARYING WS-GI FROM 1 BY 1 UNTIL WS-GI > EA-MT-COUNT
         IF EA-MT-MODEL(WS-GI) = EN-MODEL(WS-R) AND EA-MT-TEX(WS-GI) = WS-OV-CODE
             MOVE WS-GI TO WS-GSLOT
         END-IF
     END-PERFORM
     PERFORM VARYING WS-GI FROM WS-G0 BY 1 UNTIL WS-GI >= RL-EN-COUNT OR WS-GSLOT = 0
         IF RL-GL-COUNT < CL-MAX-GLINT-VERTICES
             ADD 1 TO RL-GL-COUNT
             MOVE RL-EN-X(WS-GI + 1) TO RL-GL-X(RL-GL-COUNT)
             MOVE RL-EN-Y(WS-GI + 1) TO RL-GL-Y(RL-GL-COUNT)
             MOVE RL-EN-Z(WS-GI + 1) TO RL-GL-Z(RL-GL-COUNT)
             COMPUTE WS-GU = (RL-EN-U(WS-GI + 1) * EA-W - EA-MT-X(WS-GSLOT)) / EA-MT-W(WS-GSLOT)
             COMPUTE WS-GV = (RL-EN-V(WS-GI + 1) * EA-H - EA-MT-Y(WS-GSLOT)) / EA-MT-H(WS-GSLOT)
             CALL "GLINT-UV" USING WS-GU WS-GV WS-GSCALE
             MOVE WS-GU TO RL-GL-U(RL-GL-COUNT)
             MOVE WS-GV TO RL-GL-V(RL-GL-COUNT)
             MOVE WS-GSTR TO RL-GL-B(RL-GL-COUNT)
             MOVE 1 TO RL-GL-A(RL-GL-COUNT) RL-GL-R(RL-GL-COUNT) RL-GL-G(RL-GL-COUNT) RL-GL-BLUE(RL-GL-COUNT)
             MOVE 0 TO RL-GL-SKY(RL-GL-COUNT)
         END-IF
     END-PERFORM
     MOVE WS-G0 TO RL-EN-COUNT.
 MAIN-EXIT.
     CONTINUE.
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
 01 WS-H                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-LOOSE               BINARY-LONG.
 01 WS-BDYE                BINARY-LONG.
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
*>       The item entity of a cobolcraft world is the stand-in type ET-LOOSE-ITEM (EN-VANILLA 0; type id 1 of a standard set is a boat, so
*>       a standard row is never one). The dropped item of a standard set (EN-VANILLA 1, key `item`) is drawn by VANILLA-ITEMS-MESH below.
         MOVE 0 TO WS-LOOSE
         IF EN-VANILLA(WS-R) = 0 AND EN-TYPE(WS-R) = ET-LOOSE-ITEM
             MOVE 1 TO WS-LOOSE
         END-IF
         IF EN-USED(WS-R) = 1 AND WS-LOOSE = 1 AND EN-STACK-COUNT(WS-R) > 0
                 AND RL-GI-COUNT + 6 <= CL-MAX-GI-VERTICES
             CALL "ITEM-SPRITE-OF" USING CLIENT-STATE EN-STACK-ITEM(WS-R) WS-SPRITE
             MOVE FUNCTION MAX(WS-SPRITE, 1) TO WS-SPRITE
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
*>   The items in the hands of the mobs drawn this frame (ENTITY-MODEL-EMIT found their hands): the main hand is the right arm's, a left-handed mob (mob flags bit 2)
*>   holds it in the left.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1
             PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 2
                 COMPUTE WS-SLOT = WS-H
                 IF FUNCTION MOD(FUNCTION INTEGER(EN-MOB-FLAGS(WS-R) / 2), 2) = 1
                     COMPUTE WS-SLOT = 3 - WS-H
                 END-IF
                 IF EN-HAND-OK(WS-R, WS-H) = 1 AND EN-EQ(WS-R, WS-SLOT) > 0
                     CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE EN-EQ(WS-R, WS-SLOT) WS-BDYE
*>                   A banner is drawn by the entity pass (ENTITIES-MESH).
                     IF WS-BDYE < 0
                         CALL "ENTITY-HELD-EMIT" USING CLIENT-STATE WS-R WS-H EN-EQ(WS-R, WS-SLOT) L-EYE-TABLE
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
*>   The items in item frames (34-9 section 10).
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND (EN-KEY(WS-R) = "item_frame" OR "glow_item_frame") AND EN-STACK-COUNT(WS-R) > 0
             CALL "ENTITY-FRAME-EMIT" USING CLIENT-STATE WS-R L-EYE-TABLE
         END-IF
     END-PERFORM
     CALL "VANILLA-ITEMS-MESH" USING CLIENT-STATE L-EYE-TABLE
     CALL "ENTITY-FIRE-MESH" USING CLIENT-STATE L-EYE-TABLE
     GOBACK.
 END PROGRAM GROUND-ITEMS-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FIRE-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): appends the flames of the burning entities to RL-GI-VERTEX (the block atlas, texture 0, after the ground items;
*> 34 part 1 section 7.4). An entity whose shared flags byte (EN-FLAGS, entry 0) has bit 0 set, and the local player's own figure in a third-person view (PL-ON-FIRE
*> from Set Entity Data of its own id), shows two layers of the block atlas sprites fire_0 and fire_1 (a pack without one shows the other in both layers; without
*> either nothing is drawn): the box of the entity (EN-BOX-HALF, EN-BOX-HEIGHT; 0.6 x 1.8 where the row has none) gives the quads of EM7-FIRE. The animation is the
*> atlas's own (ANIM-TICK writes the frame of the sprite into its cell). Where a first-person overlay of the flames would be drawn the documents say nothing (recorded
*> in tasks T11107).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 01 WS-S0                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-LEN                 BINARY-LONG VALUE 22.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     MOVE SPACES TO WS-ID
     MOVE "minecraft:block/fire_0" TO WS-ID
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-LEN WS-S0
     MOVE "minecraft:block/fire_1" TO WS-ID
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-LEN WS-S1
     IF WS-S0 = 0 AND WS-S1 = 0
         GOBACK
     END-IF
     IF WS-S0 = 0
         MOVE WS-S1 TO WS-S0
     END-IF
     IF WS-S1 = 0
         MOVE WS-S0 TO WS-S1
     END-IF
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND FUNCTION MOD(EN-FLAGS(WS-R), 2) = 1
             MOVE 0.6 TO WS-W
             MOVE 1.8 TO WS-H
             IF EN-BOX-HEIGHT(WS-R) > 0
                 COMPUTE WS-W = EN-BOX-HALF(WS-R) * 2
                 MOVE EN-BOX-HEIGHT(WS-R) TO WS-H
             END-IF
             CALL "ENTITY-FIRE-EMIT" USING CLIENT-STATE L-EYE-TABLE EN-X(WS-R) EN-Y(WS-R) EN-Z(WS-R) WS-W WS-H WS-S0 WS-S1
         END-IF
     END-PERFORM
     IF CL-CAMERA > 0 AND PL-ON-FIRE = 1
         MOVE 0.6 TO WS-W
         MOVE 1.8 TO WS-H
         CALL "ENTITY-FIRE-EMIT" USING CLIENT-STATE L-EYE-TABLE PL-X PL-Y PL-Z WS-W WS-H WS-S0 WS-S1
     END-IF
     GOBACK.
 END PROGRAM ENTITY-FIRE-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FIRE-EMIT.
*> USING CLIENT-STATE, eye, entity position x y z (feet), width, height (FLOAT-LONG), sprite of fire_0, sprite of fire_1: the flame quads of one entity (EM7-FIRE) appended to
*> RL-GI-VERTEX unless they no longer fit. Quad k: half width w x s, bottom edge s x rise above the feet and top edge 1.4 s above that, centred on the entity and moved
*> s x (z translate + zs) along the camera's horizontal look direction (yaw Y looks along (-sin Y, 0, cos Y); the model x axis is the camera's left, (cos Y, 0, sin Y)). Corners
*> top-left (+x), top-right (-x), bottom-right, bottom-left, the six vertices 1, 2, 3, 1, 3, 4; the layer is fire_0 or fire_1 as EM7-FIRE says, u mirrored when it says so;
*> full brightness, alpha 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-IN.
    05 WS-I                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OUT.
    05 WS-O                FLOAT-LONG OCCURS 64 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I6                  BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-BOTTOM              FLOAT-LONG.
 01 WS-ZOFF                FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-MIRROR              BINARY-LONG.
 01 WS-CORNERS.
    05 WS-CO OCCURS 4 TIMES.
       10 WS-C-X           FLOAT-SHORT.
       10 WS-C-Y           FLOAT-SHORT.
       10 WS-C-Z           FLOAT-SHORT.
       10 WS-C-U           FLOAT-SHORT.
       10 WS-C-V           FLOAT-SHORT.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-WIDTH                FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-SPRITE0              BINARY-LONG.
 01 L-SPRITE1              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE L-X L-Y L-Z L-WIDTH L-HEIGHT L-SPRITE0 L-SPRITE1.
     MOVE L-WIDTH TO WS-I(1)
     MOVE L-HEIGHT TO WS-I(2)
     CALL "EM7-FIRE" USING WS-IN WS-OUT
     COMPUTE WS-N = FUNCTION INTEGER(WS-O(1))
     IF RL-GI-COUNT + WS-N * 6 > CL-MAX-GI-VERTICES
         GOBACK
     END-IF
     MOVE WS-O(2) TO WS-S
     COMPUTE WS-CY = FUNCTION COS(PL-YAW * FUNCTION PI / 180)
     COMPUTE WS-SY = FUNCTION SIN(PL-YAW * FUNCTION PI / 180)
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= WS-N
         COMPUTE WS-BASE = 5 + WS-K * 5
         COMPUTE WS-HALF = WS-O(WS-BASE) * WS-S
         COMPUTE WS-BOTTOM = L-Y - L-EYE(2) + WS-O(WS-BASE + 1) * WS-S
         COMPUTE WS-ZOFF = (WS-O(4) + WS-O(WS-BASE + 2)) * WS-S
         COMPUTE WS-CX = L-X - L-EYE(1) - WS-SY * WS-ZOFF
         COMPUTE WS-CZ = L-Z - L-EYE(3) + WS-CY * WS-ZOFF
         MOVE L-SPRITE0 TO WS-SPRITE
         IF WS-O(WS-BASE + 4) = 1
             MOVE L-SPRITE1 TO WS-SPRITE
         END-IF
         COMPUTE WS-MIRROR = FUNCTION INTEGER(WS-O(WS-BASE + 3))
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
*>           Corners 1 and 4 are on the +x side (the camera's left), 2 and 3 on the -x side; 1 and 2 are the top.
             MOVE WS-HALF TO WS-SIDE
             MOVE 0 TO WS-U16
             IF WS-C = 2 OR WS-C = 3
                 COMPUTE WS-SIDE = 0 - WS-HALF
                 MOVE 16 TO WS-U16
             END-IF
             IF WS-MIRROR = 1
                 COMPUTE WS-U16 = 16 - WS-U16
             END-IF
             COMPUTE WS-C-X(WS-C) = WS-CX + WS-SIDE * WS-CY
             COMPUTE WS-C-Z(WS-C) = WS-CZ + WS-SIDE * WS-SY
             MOVE 0 TO WS-V16
             COMPUTE WS-C-Y(WS-C) = WS-BOTTOM + 1.4 * WS-S
             IF WS-C >= 3
                 MOVE WS-BOTTOM TO WS-C-Y(WS-C)
                 MOVE 16 TO WS-V16
             END-IF
             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-C-U(WS-C) WS-C-V(WS-C)
         END-PERFORM
         PERFORM VARYING WS-I6 FROM 1 BY 1 UNTIL WS-I6 > 6
             MOVE WS-ORD(WS-I6) TO WS-C
             ADD 1 TO RL-GI-COUNT
             MOVE WS-C-X(WS-C) TO RL-GI-X(RL-GI-COUNT)
             MOVE WS-C-Y(WS-C) TO RL-GI-Y(RL-GI-COUNT)
             MOVE WS-C-Z(WS-C) TO RL-GI-Z(RL-GI-COUNT)
             MOVE WS-C-U(WS-C) TO RL-GI-U(RL-GI-COUNT)
             MOVE WS-C-V(WS-C) TO RL-GI-V(RL-GI-COUNT)
             MOVE 1 TO RL-GI-B(RL-GI-COUNT)
             MOVE 1 TO RL-GI-A(RL-GI-COUNT)
             MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
             MOVE 1 TO RL-GI-R(RL-GI-COUNT) RL-GI-G(RL-GI-COUNT) RL-GI-BLUE(RL-GI-COUNT)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-FIRE-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VANILLA-ITEMS-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): appends the dropped items of a standard-set world (the "item" entity, EN-VANILLA 1) to RL-GI-VERTEX as
*> ItemEntityRenderer draws them (34-9 section 9.1 and 9.2) with the flat model of the item's icon: a quad 0.5 wide (x -0.25 to 0.25, y -0.125 to
*> 0.375, the ground display transform of 12 section 8.2: translate (0, 2, 0) / 16, scale 0.5), thickness 1/16 x 0.5 so a flat model. The pose: translate
*> (0, bob + base, 0) with base = 0.0625 + 0.125 and bob = sin(age / 10 + bobOffs) x 0.1 + 0.1, then rotate about Y by age / 20 + bobOffs radians (age in
*> ticks from the clock; bobOffs is a random phase of the client's own, taken as entity id mod 64 / 64 x 2 pi). Copies by stack size (1, 2, 3, 4, 5 at 1,
*> 2 to 16, 17 to 32, 33 to 48, 49 up); flat stacking: step = zs x 1.5 = 0.046875, the first copy at z = -(step (n - 1)) / 2, copy k at z + k step, copies
*> after the first moved by ((r1 x 2 - 1) x 0.075, (r2 x 2 - 1) x 0.075) with r from the Java LCG seeded with the item id (damage value 0), restarted
*> for each item. Both sides of the quad are drawn (12 vertices a copy). A block item (the item's model has faces, ITEM-FACE-SPRITE) is a thick model: the cube of its
*> model with the ground display of block/block (scale 0.25, translate (0, 3, 0) / 16: the cube spans y 0.0625 to 0.3125, so base = -minY + 0.0625 = 0), each face its own
*> sprite, drawn once (copies by stack size, the others moved by ((r1 x 2 - 1) x 0.15, (r2 x 2 - 1) x 0.15, (r3 x 2 - 1) x 0.15), spun with the pose), shaded by the face
*> direction (up 1, down 0.5, north and south 0.8, west and east 0.6; tint: none, a gap of the item tint sources).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-COPIES              BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-AGE                 FLOAT-LONG.
 01 WS-PHASE               FLOAT-LONG.
 01 WS-BOB                 FLOAT-LONG.
 01 WS-SPIN-SIN            FLOAT-LONG.
 01 WS-SPIN-COS            FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
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
*> The twelve vertices of a copy: the front triangles 1 2 3, 1 3 4 and the back triangles 1 3 2, 1 4 3.
 01 WS-CUBE                BINARY-LONG.
 01 WS-FS                  BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG.
 01 WS-PCK                 BINARY-LONG.
 01 WS-CPX                 FLOAT-LONG.
 01 WS-CPY                 FLOAT-LONG.
 01 WS-CPZ                 FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
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
*> The direction of each face of the corner table (south, north, east, west, up, down) and its shade.
 01 WS-DIR-DATA            PIC X(6) VALUE "436521".
 01 WS-DIR-TABLE REDEFINES WS-DIR-DATA.
    05 WS-FACE-DIR         PIC 9 OCCURS 6 TIMES.
 01 WS-SHADE-DATA.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 1.0.
    05 FILLER PIC 9V9 VALUE 0.5.
 01 WS-SHADE-TABLE REDEFINES WS-SHADE-DATA.
    05 WS-SHADE            PIC 9V9 OCCURS 6 TIMES.
 01 WS-ORDER-DATA          PIC X(12) VALUE "123134132143".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 12 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     COMPUTE WS-AGE = CL-NOW-MS / 50
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-VANILLA(WS-R) = 1 AND EN-KEY(WS-R) = "item" AND EN-STACK-COUNT(WS-R) > 0
             EVALUATE TRUE
                 WHEN EN-STACK-COUNT(WS-R) <= 1
                     MOVE 1 TO WS-COPIES
                 WHEN EN-STACK-COUNT(WS-R) <= 16
                     MOVE 2 TO WS-COPIES
                 WHEN EN-STACK-COUNT(WS-R) <= 32
                     MOVE 3 TO WS-COPIES
                 WHEN EN-STACK-COUNT(WS-R) <= 48
                     MOVE 4 TO WS-COPIES
                 WHEN OTHER
                     MOVE 5 TO WS-COPIES
             END-EVALUATE
             IF RL-GI-COUNT + 12 * WS-COPIES <= CL-MAX-GI-VERTICES
                 CALL "ITEM-SPRITE-OF" USING CLIENT-STATE EN-STACK-ITEM(WS-R) WS-SPRITE
                 MOVE FUNCTION MAX(WS-SPRITE, 1) TO WS-SPRITE
                 MOVE 0 TO WS-FS WS-CUBE
                 MOVE DIR-UP TO WS-DIRECTION
                 CALL "ITEM-FACE-SPRITE" USING CLIENT-STATE EN-STACK-ITEM(WS-R) WS-DIRECTION WS-FS
                 IF WS-FS > 0 AND RL-GI-COUNT + 36 * WS-COPIES <= CL-MAX-GI-VERTICES
                     MOVE 1 TO WS-CUBE
                 END-IF
                 COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-R))
                 COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-R))
                 COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-R))
                 CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE-ID WS-SKY WS-BLOCK
                 COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
                 COMPUTE WS-PHASE = FUNCTION MOD(EN-ID(WS-R), 64) / 64 * 2 * FUNCTION PI
                 COMPUTE WS-BOB = FUNCTION SIN(WS-AGE / 10 + WS-PHASE) * 0.1 + 0.1 + 0.1875
                 COMPUTE WS-SPIN-SIN = FUNCTION SIN(WS-AGE / 20 + WS-PHASE)
                 COMPUTE WS-SPIN-COS = FUNCTION COS(WS-AGE / 20 + WS-PHASE)
                 COMPUTE WS-Z0 = 0 - 0.046875 * (WS-COPIES - 1) / 2
                 MOVE EN-STACK-ITEM(WS-R) TO WS-SEED
                 CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
                 IF WS-CUBE = 1
                     PERFORM CUBE-COPIES
                 ELSE
                     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N >= WS-COPIES
                         MOVE 0 TO WS-OX WS-OY
                         IF WS-N > 0
                             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R1
                             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R2
                             COMPUTE WS-OX = (WS-R1 * 2 - 1) * 0.075
                             COMPUTE WS-OY = (WS-R2 * 2 - 1) * 0.075
                         END-IF
                         COMPUTE WS-LZ = WS-Z0 + 0.046875 * WS-N
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                             MOVE -0.25 TO WS-SIDE
                             MOVE 0 TO WS-U16
                             IF WS-K = 2 OR WS-K = 3
                                 MOVE 0.25 TO WS-SIDE
                                 MOVE 16 TO WS-U16
                             END-IF
                             MOVE 0.375 TO WS-TOP
                             MOVE 0 TO WS-V16
                             IF WS-K >= 3
                                 MOVE -0.125 TO WS-TOP
                                 MOVE 16 TO WS-V16
                             END-IF
                             COMPUTE WS-LX = WS-SIDE + WS-OX
                             COMPUTE WS-LY = WS-TOP + WS-OY
                             COMPUTE WS-SX = WS-LX * WS-SPIN-COS + WS-LZ * WS-SPIN-SIN
                             COMPUTE WS-SZ = WS-LZ * WS-SPIN-COS - WS-LX * WS-SPIN-SIN
                             COMPUTE WS-C-X(WS-K) = EN-X(WS-R) - L-EYE(1) + WS-SX
                             COMPUTE WS-C-Y(WS-K) = EN-Y(WS-R) - L-EYE(2) + WS-BOB + WS-LY
                             COMPUTE WS-C-Z(WS-K) = EN-Z(WS-R) - L-EYE(3) + WS-SZ
                             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-C-U(WS-K) WS-C-V(WS-K)
                         END-PERFORM
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
                             MOVE WS-ORD(WS-I) TO WS-K
                             ADD 1 TO RL-GI-COUNT
                             MOVE WS-C-X(WS-K) TO RL-GI-X(RL-GI-COUNT)
                             MOVE WS-C-Y(WS-K) TO RL-GI-Y(RL-GI-COUNT)
                             MOVE WS-C-Z(WS-K) TO RL-GI-Z(RL-GI-COUNT)
                             MOVE WS-C-U(WS-K) TO RL-GI-U(RL-GI-COUNT)
                             MOVE WS-C-V(WS-K) TO RL-GI-V(RL-GI-COUNT)
                             MOVE WS-LIGHT TO RL-GI-B(RL-GI-COUNT)
                             MOVE 1 TO RL-GI-A(RL-GI-COUNT)
                             MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
                             MOVE 1 TO RL-GI-R(RL-GI-COUNT) RL-GI-G(RL-GI-COUNT) RL-GI-BLUE(RL-GI-COUNT)
                         END-PERFORM
                     END-PERFORM
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GO TO MAIN-EXIT.

*> The copies of a block item (see the header): the cube of the model, 36 vertices a copy.
 CUBE-COPIES.
     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N >= WS-COPIES
         MOVE 0 TO WS-OX WS-OY WS-OZ
         IF WS-N > 0
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R1
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R2
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R3
             COMPUTE WS-OX = (WS-R1 * 2 - 1) * 0.15
             COMPUTE WS-OY = (WS-R2 * 2 - 1) * 0.15
             COMPUTE WS-OZ = (WS-R3 * 2 - 1) * 0.15
         END-IF
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
             MOVE WS-SPRITE TO WS-FS
             MOVE WS-FACE-DIR(WS-F) TO WS-DIRECTION
             CALL "ITEM-FACE-SPRITE" USING CLIENT-STATE EN-STACK-ITEM(WS-R) WS-DIRECTION WS-FS
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 MOVE 0 TO WS-U16
                 IF WS-K = 2 OR WS-K = 3
                     MOVE 16 TO WS-U16
                 END-IF
                 MOVE 0 TO WS-V16
                 IF WS-K >= 3
                     MOVE 16 TO WS-V16
                 END-IF
                 COMPUTE WS-A = (WS-K - 1) * 3
                 COMPUTE WS-CPX = (WS-PICK(WS-F, WS-A + 1) - 0.5) * 0.25 + WS-OX
                 COMPUTE WS-CPY = (WS-PICK(WS-F, WS-A + 2) - 0.5) * 0.25
                 COMPUTE WS-CPZ = (WS-PICK(WS-F, WS-A + 3) - 0.5) * 0.25 + WS-OZ
                 COMPUTE WS-SX = WS-CPX * WS-SPIN-COS + WS-CPZ * WS-SPIN-SIN
                 COMPUTE WS-SZ = WS-CPZ * WS-SPIN-COS - WS-CPX * WS-SPIN-SIN
                 COMPUTE WS-C-X(WS-K) = EN-X(WS-R) - L-EYE(1) + WS-SX
                 COMPUTE WS-C-Y(WS-K) = EN-Y(WS-R) - L-EYE(2) + WS-BOB + WS-CPY + WS-OY
                 COMPUTE WS-C-Z(WS-K) = EN-Z(WS-R) - L-EYE(3) + WS-SZ
                 CALL "ATLAS-UV" USING CLIENT-STATE WS-FS WS-U16 WS-V16 WS-C-U(WS-K) WS-C-V(WS-K)
             END-PERFORM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 MOVE WS-ORD(WS-I) TO WS-K
                 ADD 1 TO RL-GI-COUNT
                 MOVE WS-C-X(WS-K) TO RL-GI-X(RL-GI-COUNT)
                 MOVE WS-C-Y(WS-K) TO RL-GI-Y(RL-GI-COUNT)
                 MOVE WS-C-Z(WS-K) TO RL-GI-Z(RL-GI-COUNT)
                 MOVE WS-C-U(WS-K) TO RL-GI-U(RL-GI-COUNT)
                 MOVE WS-C-V(WS-K) TO RL-GI-V(RL-GI-COUNT)
                 COMPUTE RL-GI-B(RL-GI-COUNT) = FUNCTION MAX(WS-SHADE(WS-F) * WS-LIGHT, 0.1)
                 MOVE 1 TO RL-GI-A(RL-GI-COUNT)
                 MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
                 MOVE 1 TO RL-GI-R(RL-GI-COUNT) RL-GI-G(RL-GI-COUNT) RL-GI-BLUE(RL-GI-COUNT)
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM VANILLA-ITEMS-MESH.
