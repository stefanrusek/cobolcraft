*> Entity models part 2 (docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md): model data and helpers of the humanoid-base mobs. Records:
*> client/copy/CLEMM.cpy. Every builder loads rows through EMM-ROW (client/src/entmodel-model.cob), the rows being the tables of the document.
*> Entry points for the integrator (inputs):
*>   EMD-HUMANOID EMM-MODEL grow y-offset: the base humanoid mesh of 1.2 (texture 64 x 64), grow on every cuboid and grow + 0.5 on the hat, y-offset added to the
*>     pivot y of every part except hat.
*>   EMD-SCALE-ROOT EMM-MODEL s: MeshTransformer.scaling of 1.3 (each direct child of the root: position and scale times s, then translated by (0, 24.016 (1 - s), 0)).
*>   EMD-BABY EMM-MODEL: the humanoid baby transform of 1.3 (head parts {head}, scaleHead, 16, 0, 2, 2, 24).
*>   EMD-RETAIN EMM-MODEL mode(1 retainPartsAndChildren, 2 retainExactParts) set("a|b" part names).
*>   EMD-ARMOR-SET EMM-MODEL slot(1 head, 2 chest, 3 legs, 4 feet) inner outer: the adult armor mesh of 1.4 for one slot (texture 64 x 32); EMD-BABY-ARMOR EMM-MODEL
*>     slot grow-triple arm-offset-triple: the baby armor mesh (64 x 64).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-HUMANOID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -4 -8 -4 8 8 8 g 0".
    05 FILLER PIC X(100) VALUE "P hat head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C hat 32 0 -4 -8 -4 8 8 8 g+0.5 0".
    05 FILLER PIC X(100) VALUE "P body root 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 16 16 -4 0 -2 8 12 4 g 0".
    05 FILLER PIC X(100) VALUE "P right_arm root -5 2 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_arm 40 16 -3 -2 -2 4 12 4 g 0".
    05 FILLER PIC X(100) VALUE "P left_arm root 5 2 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_arm 40 16 -1 -2 -2 4 12 4 g 1".
    05 FILLER PIC X(100) VALUE "P right_leg root -1.9 12 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_leg 0 16 -2 0 -2 4 12 4 g 0".
    05 FILLER PIC X(100) VALUE "P left_leg root 1.9 12 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_leg 0 16 -2 0 -2 4 12 4 g 1".
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 14 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-G.
    05 WS-GV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-GROW                 FLOAT-LONG.
 01 L-YOFF                 FLOAT-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-GROW L-YOFF.
     CALL "EMM-INIT" USING EMM-MODEL
     MOVE L-GROW TO WS-GV(1) WS-GV(2) WS-GV(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         CALL "EMM-ROW" USING EMM-MODEL WS-ROW(WS-I) WS-G
     END-PERFORM
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > MM-COUNT
         IF MM-NAME(WS-I) NOT = "hat"
             COMPUTE MM-Y(WS-I) = MM-Y(WS-I) + L-YOFF
             MOVE MM-INIT(WS-I) TO MM-CUR(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EMD-HUMANOID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-SCALE-ROOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-S                    FLOAT-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-S.
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > MM-COUNT
         IF MM-PARENT(WS-I) = 1
             COMPUTE MM-X(WS-I) = MM-X(WS-I) * L-S
             COMPUTE MM-Y(WS-I) = MM-Y(WS-I) * L-S + 24.016 * (1 - L-S)
             COMPUTE MM-Z(WS-I) = MM-Z(WS-I) * L-S
             COMPUTE MM-XSCALE(WS-I) = MM-XSCALE(WS-I) * L-S
             COMPUTE MM-YSCALE(WS-I) = MM-YSCALE(WS-I) * L-S
             COMPUTE MM-ZSCALE(WS-I) = MM-ZSCALE(WS-I) * L-S
             MOVE MM-INIT(WS-I) TO MM-CUR(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EMD-SCALE-ROOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > MM-COUNT
         IF MM-PARENT(WS-I) = 1
             MOVE 24 TO WS-DY
             MOVE 0.5 TO WS-F
             IF MM-NAME(WS-I) = "head"
                 MOVE 16 TO WS-DY
                 MOVE 0.75 TO WS-F
             END-IF
             COMPUTE MM-X(WS-I) = MM-X(WS-I) * WS-F
             COMPUTE MM-Y(WS-I) = (MM-Y(WS-I) + WS-DY) * WS-F
             COMPUTE MM-Z(WS-I) = MM-Z(WS-I) * WS-F
             COMPUTE MM-XSCALE(WS-I) = MM-XSCALE(WS-I) * WS-F
             COMPUTE MM-YSCALE(WS-I) = MM-YSCALE(WS-I) * WS-F
             COMPUTE MM-ZSCALE(WS-I) = MM-ZSCALE(WS-I) * WS-F
             MOVE MM-INIT(WS-I) TO MM-CUR(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EMD-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-RETAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STATE               BINARY-LONG OCCURS 40 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-MODE                 BINARY-LONG.
 01 L-SET                  PIC X(120).
 PROCEDURE DIVISION USING EMM-MODEL L-MODE L-SET.
     MOVE 0 TO WS-STATE(1)
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > MM-COUNT
         MOVE MM-PARENT(WS-I) TO WS-P
         MOVE 0 TO WS-STATE(WS-I)
         IF WS-STATE(WS-P) = 0
             CALL "EM2-IN-SET" USING MM-NAME(WS-I) L-SET WS-FOUND
             IF WS-FOUND = 1
                 MOVE 2 TO WS-STATE(WS-I)
             ELSE
                 MOVE 0 TO MM-NCUBES(WS-I)
             END-IF
         ELSE
             MOVE 3 TO WS-STATE(WS-I)
             IF L-MODE = 2
                 MOVE 0 TO MM-NCUBES(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EMD-RETAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-ARMOR-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-G                   FLOAT-LONG.
 01 WS-YOFF                FLOAT-LONG VALUE 0.
 01 WS-GR.
    05 WS-GV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-MODE                BINARY-LONG.
 01 WS-SET                 PIC X(120).
 01 WS-ROW1                PIC X(100) VALUE "P right_leg root -1.9 12 0 0 0 0".
 01 WS-ROW2                PIC X(100) VALUE "C right_leg 0 16 -2 0 -2 4 12 4 g-0.1 0".
 01 WS-ROW3                PIC X(100) VALUE "P left_leg root 1.9 12 0 0 0 0".
 01 WS-ROW4                PIC X(100) VALUE "C left_leg 0 16 -2 0 -2 4 12 4 g-0.1 1".
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-SLOT                 BINARY-LONG.
 01 L-INNER                FLOAT-LONG.
 01 L-OUTER                FLOAT-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-SLOT L-INNER L-OUTER.
     MOVE L-OUTER TO WS-G
     IF L-SLOT = 3
         MOVE L-INNER TO WS-G
     END-IF
     CALL "EMD-HUMANOID" USING EMM-MODEL WS-G WS-YOFF
     MOVE WS-G TO WS-GV(1) WS-GV(2) WS-GV(3)
     CALL "EMM-ROW" USING EMM-MODEL WS-ROW1 WS-GR
     CALL "EMM-ROW" USING EMM-MODEL WS-ROW2 WS-GR
     CALL "EMM-ROW" USING EMM-MODEL WS-ROW3 WS-GR
     CALL "EMM-ROW" USING EMM-MODEL WS-ROW4 WS-GR
     MOVE 32 TO MM-TEXH
     EVALUATE L-SLOT
         WHEN 1
             MOVE 1 TO WS-MODE
             MOVE "head" TO WS-SET
         WHEN 2
             MOVE 2 TO WS-MODE
             MOVE "body|left_arm|right_arm" TO WS-SET
         WHEN 3
             MOVE 2 TO WS-MODE
             MOVE "left_leg|right_leg|body" TO WS-SET
         WHEN OTHER
             MOVE 2 TO WS-MODE
             MOVE "left_leg|right_leg" TO WS-SET
     END-EVALUATE
     CALL "EMD-RETAIN" USING EMM-MODEL WS-MODE WS-SET
     GOBACK.
 END PROGRAM EMD-ARMOR-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-BABY-ARMOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 15 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -4.5 -7 -4.5 9 8 8 g 0".
    05 FILLER PIC X(100) VALUE "P hat head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 18 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 17 -3 -3 -1.5 6 5 3 g 0".
    05 FILLER PIC X(100) VALUE "P waist root 0 19 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C waist 0 36 -3 -1.2 -1.49 5.9 2 2.9 g-0.1 0".
    05 FILLER PIC X(100) VALUE "P right_arm root -3.5 15.5 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_arm 30 25 -1 0 -1.53 2 5 3 g 0".
    05 FILLER PIC X(100) VALUE "P left_arm root 3.5 15.5 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_arm 30 17 -1 0 -1.53 2 5 3 g 0".
    05 FILLER PIC X(100) VALUE "P inner_body root 0 18 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C inner_body 0 17 -3 -3 -1.5 6 5 3 g 0".
    05 FILLER PIC X(100) VALUE "P left_leg root 1.5 20 0.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_leg 18 24 -2 -0.2 -2 3 4 3 g-0.1 0".
    05 FILLER PIC X(100) VALUE "P left_foot left_leg 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_foot 0 29 -1 2.9 -2 3 1 3 g 1".
    05 FILLER PIC X(100) VALUE "P right_leg root -1.5 20 0.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_leg 18 17 -1 -0.2 -2 3 4 3 g-0.1 0".
    05 FILLER PIC X(100) VALUE "P right_foot right_leg 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_foot 0 25 -2 2.9 -2 3 1 3 g 0".
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 21 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-SET                 PIC X(120).
 01 WS-PART                BINARY-LONG.
 01 WS-NAME                PIC X(24).
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-SLOT                 BINARY-LONG.
 01 L-GROW.
    05 L-G                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-OFF.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-SLOT L-GROW L-OFF.
     CALL "EMM-INIT" USING EMM-MODEL
     MOVE 64 TO MM-TEXW MM-TEXH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 21
         CALL "EMM-ROW" USING EMM-MODEL WS-ROW(WS-I) L-GROW
     END-PERFORM
     MOVE "right_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-PART
     COMPUTE MM-X(WS-PART) = MM-X(WS-PART) - L-O(1)
     COMPUTE MM-Y(WS-PART) = MM-Y(WS-PART) + L-O(2)
     COMPUTE MM-Z(WS-PART) = MM-Z(WS-PART) + L-O(3)
     MOVE MM-INIT(WS-PART) TO MM-CUR(WS-PART)
     MOVE "left_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-PART
     COMPUTE MM-X(WS-PART) = MM-X(WS-PART) + L-O(1)
     COMPUTE MM-Y(WS-PART) = MM-Y(WS-PART) + L-O(2)
     COMPUTE MM-Z(WS-PART) = MM-Z(WS-PART) + L-O(3)
     MOVE MM-INIT(WS-PART) TO MM-CUR(WS-PART)
     EVALUATE L-SLOT
         WHEN 1
             MOVE 1 TO WS-MODE
             MOVE "head" TO WS-SET
         WHEN 2
             MOVE 2 TO WS-MODE
             MOVE "body|left_arm|right_arm" TO WS-SET
         WHEN 3
             MOVE 2 TO WS-MODE
             MOVE "left_leg|right_leg|waist" TO WS-SET
         WHEN OTHER
             MOVE 2 TO WS-MODE
             MOVE "left_foot|right_foot" TO WS-SET
     END-EVALUATE
     CALL "EMD-RETAIN" USING EMM-MODEL WS-MODE WS-SET
     GOBACK.
 END PROGRAM EMD-BABY-ARMOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-LAYER-TYPE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                 BINARY-LONG.
 01 L-STAND                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-TYPE                 PIC X(20).
*> USING baby armor-stand slot type: humanoid_baby, else humanoid_leggings for the legs slot (3), else humanoid (1.5 step 2).
 PROCEDURE DIVISION USING L-BABY L-STAND L-SLOT L-TYPE.
     MOVE "humanoid" TO L-TYPE
     IF L-BABY NOT = 0 AND L-STAND = 0
         MOVE "humanoid_baby" TO L-TYPE
     ELSE
         IF L-SLOT = 3
             MOVE "humanoid_leggings" TO L-TYPE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EMD-LAYER-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-EQUIP-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(20).
 01 L-PATH                 PIC X(40).
 01 L-OUT                  PIC X(100).
 *> USING layer-type layer-texture-path texture: textures/entity/equipment/<type>/<path>.png (1.5 step 3).
 PROCEDURE DIVISION USING L-TYPE L-PATH L-OUT.
     MOVE SPACES TO L-OUT
     STRING "textures/entity/equipment/" FUNCTION TRIM(L-TYPE) "/" FUNCTION TRIM(L-PATH) ".png" DELIMITED BY SIZE INTO L-OUT
     GOBACK.
 END PROGRAM EMD-EQUIP-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-TRIM-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(20).
 01 L-PATTERN              PIC X(40).
 01 L-OUT                  PIC X(100).
 *> USING layer-type pattern-path texture-id: trims/entity/<type>/<pattern path>, spaces for the humanoid_baby type which has no trim (1.5 step 6).
 PROCEDURE DIVISION USING L-TYPE L-PATTERN L-OUT.
     MOVE SPACES TO L-OUT
     IF L-TYPE NOT = "humanoid_baby"
         STRING "trims/entity/" FUNCTION TRIM(L-TYPE) "/" FUNCTION TRIM(L-PATTERN) DELIMITED BY SIZE INTO L-OUT
     END-IF
     GOBACK.
 END PROGRAM EMD-TRIM-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-DRAW-SLOT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POSITION             BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 *> USING position(1..4) slot: the armor layer draws chest (2), legs (3), feet (4), head (1) in that order (1.5).
 PROCEDURE DIVISION USING L-POSITION L-SLOT.
     EVALUATE L-POSITION
         WHEN 1 MOVE 2 TO L-SLOT
         WHEN 2 MOVE 3 TO L-SLOT
         WHEN 3 MOVE 4 TO L-SLOT
         WHEN 4 MOVE 1 TO L-SLOT
         WHEN OTHER MOVE 0 TO L-SLOT
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-DRAW-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-SKULL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC X(120) VALUE "skeleton        SKELETON_SKULL        64 32mob       textures/entity/skeleton/skeleton.png                              ".
    05 FILLER PIC X(120) VALUE "wither_skeleton WITHER_SKELETON_SKULL 64 32mob       textures/entity/skeleton/wither_skeleton.png                       ".
    05 FILLER PIC X(120) VALUE "creeper         CREEPER_HEAD          64 32mob       textures/entity/creeper/creeper.png                                ".
    05 FILLER PIC X(120) VALUE "zombie          ZOMBIE_HEAD           64 64humanoid  textures/entity/zombie/zombie.png                                  ".
    05 FILLER PIC X(120) VALUE "player          PLAYER_HEAD           64 64humanoid  profile skin or the default skin                                   ".
    05 FILLER PIC X(120) VALUE "piglin          PIGLIN_HEAD           64 64piglin    textures/entity/piglin/piglin.png                                  ".
    05 FILLER PIC X(120) VALUE "dragon          DRAGON_SKULL          0  0 dragon    textures/entity/enderdragon/dragon.png                             ".
 01 WS-TABLE-R REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 7 TIMES.
       10 WS-TYPE          PIC X(16).
       10 WS-LAYER         PIC X(22).
       10 WS-W             PIC X(3).
       10 WS-H             PIC X(2).
       10 WS-KIND          PIC X(10).
       10 WS-TEX           PIC X(67).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(16).
 01 L-LAYER                PIC X(22).
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-KIND                 PIC X(10).
 01 L-TEX                  PIC X(67).
*> USING skull-type layer width height model-kind(mob, humanoid, piglin, dragon) texture (1.6.1); spaces and 0 for an unknown type.
 PROCEDURE DIVISION USING L-TYPE L-LAYER L-W L-H L-KIND L-TEX.
     MOVE SPACES TO L-LAYER L-KIND L-TEX
     MOVE 0 TO L-W L-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         IF WS-TYPE(WS-I) = L-TYPE
             MOVE WS-LAYER(WS-I) TO L-LAYER
             COMPUTE L-W = FUNCTION NUMVAL(WS-W(WS-I))
             COMPUTE L-H = FUNCTION NUMVAL(WS-H(WS-I))
             MOVE WS-KIND(WS-I) TO L-KIND
             MOVE WS-TEX(WS-I) TO L-TEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EMD-SKULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-SKULL-MESH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -4 -8 -4 8 8 8 g 0".
    05 FILLER PIC X(100) VALUE "P hat head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C hat 32 0 -4 -8 -4 8 8 8 0.25 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -5 -8 -4 10 8 8 g 0".
    05 FILLER PIC X(100) VALUE "C head 31 1 -2 -4 -5 4 4 1 g 0".
    05 FILLER PIC X(100) VALUE "C head 2 4 2 -2 -5 1 2 1 g 0".
    05 FILLER PIC X(100) VALUE "C head 2 0 -3 -2 -5 1 2 1 g 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 4.5 -6 0 0 0 -0.5235988".
    05 FILLER PIC X(100) VALUE "C left_ear 51 6 0 0 -2 1 5 4 g 0".
    05 FILLER PIC X(100) VALUE "P right_ear head -4.5 -6 0 0 0 0.5235988".
    05 FILLER PIC X(100) VALUE "C right_ear 39 6 -1 0 -2 1 5 4 g 0".
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 12 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-G.
    05 WS-GV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-KIND                 PIC X(10).
*> USING model kind(mob, humanoid, piglin): the skull head meshes of 1.6.1 (mob head 64 x 32; humanoid head with hat grown 0.25 and piglin head, 64 x 64).
 PROCEDURE DIVISION USING EMM-MODEL L-KIND.
     CALL "EMM-INIT" USING EMM-MODEL
     MOVE 0 TO WS-GV(1) WS-GV(2) WS-GV(3)
     MOVE 64 TO MM-TEXW MM-TEXH
     EVALUATE L-KIND
         WHEN "mob"
             MOVE 32 TO MM-TEXH
             MOVE 1 TO WS-FIRST
             MOVE 2 TO WS-LAST
         WHEN "humanoid"
             MOVE 1 TO WS-FIRST
             MOVE 4 TO WS-LAST
         WHEN OTHER
             MOVE 1 TO WS-FIRST
             MOVE 1 TO WS-LAST
     END-EVALUATE
     PERFORM VARYING WS-I FROM WS-FIRST BY 1 UNTIL WS-I > WS-LAST
         CALL "EMM-ROW" USING EMM-MODEL WS-ROW(WS-I) WS-G
     END-PERFORM
     IF L-KIND = "piglin"
         PERFORM VARYING WS-I FROM 5 BY 1 UNTIL WS-I > 12
             CALL "EMM-ROW" USING EMM-MODEL WS-ROW(WS-I) WS-G
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM EMD-SKULL-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-SKULL-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEAD                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-Q                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 4 TIMES.
*> USING model IN(yRot degrees, xRot degrees, animationPos, piglin 1) (1.6.1): SkullModel sets the head rotation; PiglinHeadModel also flaps the ears.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     COMPUTE MM-CYROT(WS-HEAD) = L-I(1) * 0.017453292
     COMPUTE MM-CXROT(WS-HEAD) = L-I(2) * 0.017453292
     IF L-I(4) NOT = 0
         MOVE "left_ear" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LEFT
         MOVE "right_ear" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RIGHT
         COMPUTE WS-Q = L-I(3) * 3.141592653589793 * 0.2
         COMPUTE MM-CZROT(WS-LEFT) = -(FUNCTION COS(WS-Q * 1.2) + 2.5) * 0.2
         COMPUTE MM-CZROT(WS-RIGHT) = (FUNCTION COS(WS-Q) + 2.5) * 0.2
     END-IF
     GOBACK.
 END PROGRAM EMD-SKULL-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-HEAD-TRANSFORM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAMILY               PIC X(8).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 4 TIMES.
*> USING family(default, piglin) OUT(yOffset, skullYOffset, horizontal scale, vertical scale) (1.6).
 PROCEDURE DIVISION USING L-FAMILY L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     MOVE 1 TO L-O(3) L-O(4)
     IF L-FAMILY = "piglin"
         MOVE 1.0019531 TO L-O(3)
     END-IF
     GOBACK.
 END PROGRAM EMD-HEAD-TRANSFORM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> USING entity-type IN(scale, ageScale) OUT(shadow radius): the renderer constant (0.5, the giant 0.5 x 6.0, the armor stand 0) times the scale and, for a
*> mob, the age scale (2.1, 5.2).
 PROCEDURE DIVISION USING L-TYPE L-IN L-OUT.
     EVALUATE L-TYPE
         WHEN "armor_stand"
             MOVE 0 TO L-O(1)
         WHEN "giant"
             COMPUTE L-O(1) = 0.5 * 6 * L-I(1) * L-I(2)
         WHEN OTHER
             COMPUTE L-O(1) = 0.5 * L-I(1) * L-I(2)
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-SHAKING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-FROZEN               BINARY-LONG.
 01 L-CONVERTING           BINARY-LONG.
 01 L-STATE-SHAKING        BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
*> USING type fully-frozen converting skeleton-shaking flag: isShaking (2.2): the zombie, husk, drowned, piglin and piglin brute renderers shake when frozen or
*> converting, the skeleton family by the state's own flag alone, every other renderer when frozen.
 PROCEDURE DIVISION USING L-TYPE L-FROZEN L-CONVERTING L-STATE-SHAKING L-FLAG.
     MOVE 0 TO L-FLAG
     EVALUATE L-TYPE
         WHEN "zombie" WHEN "husk" WHEN "drowned" WHEN "piglin" WHEN "piglin_brute"
             IF L-FROZEN NOT = 0 OR L-CONVERTING NOT = 0
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN "skeleton" WHEN "stray" WHEN "bogged" WHEN "parched" WHEN "wither_skeleton"
             IF L-STATE-SHAKING NOT = 0
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN OTHER
             IF L-FROZEN NOT = 0
                 MOVE 1 TO L-FLAG
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-SHAKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-ARMORSTAND-ROT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-KIND                FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(body rotation, wiggle) OUT(operation count, 4 numbers per operation as EM6-POSE-CHAIN): the armor stand's setupRotations: rotate Y by 180 - bodyRot, then
*> when wiggle < 5 by sin(wiggle / 1.5 pi) x 3 degrees (2.2).
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO WS-N
     MOVE 3 TO WS-KIND
     COMPUTE WS-A = 180 - L-I(1)
     MOVE 0 TO WS-B WS-C
     CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
     IF L-I(2) < 5
         COMPUTE WS-A = FUNCTION SIN(L-I(2) / 1.5 * 3.141592653589793) * 3
         CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
     END-IF
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EMD-ARMORSTAND-ROT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-DROWNED-ROT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-KIND                FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(swim amount, xRot, bounding box height, scale) OUT(count, operations): the extra operations of the drowned's setupRotations after the base steps: with
*> swimAmount > 0, rotate about X by lerp(swim, 0, -10 - xRot) degrees around the point (0, height / 2 / scale, 0) (2.2).
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO WS-N
     IF L-I(1) > 0
         COMPUTE WS-H = L-I(3) / 2 / L-I(4)
         MOVE 1 TO WS-KIND
         MOVE 0 TO WS-A WS-C
         MOVE WS-H TO WS-B
         CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
         MOVE 5 TO WS-KIND
         COMPUTE WS-A = L-I(1) * (-10 - L-I(2))
         MOVE 0 TO WS-B
         CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
         MOVE 1 TO WS-KIND
         MOVE 0 TO WS-A
         COMPUTE WS-B = -WS-H
         CALL "EM6-ADD-OP" USING L-OUT WS-N WS-KIND WS-A WS-B WS-C
     END-IF
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EMD-DROWNED-ROT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-WALK-STATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(riding, alive, walk position, walk speed) OUT(position, speed): zero while riding or dead (2.3).
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     IF L-I(1) = 0 AND L-I(2) NOT = 0
         MOVE L-I(3) TO L-O(1)
         MOVE L-I(4) TO L-O(2)
     END-IF
     GOBACK.
 END PROGRAM EMD-WALK-STATE.
