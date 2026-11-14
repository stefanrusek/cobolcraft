*> Entity models part 2 section 5 (docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md): the renderer table, texture choice, layer order,
*> hitbox dimensions and the armor stand flags.
*> Entry points for the integrator (inputs):
*>   EMD-RENDERER type(X(24)) found renderer adult-layer baby-layer shadow(radius before scale, ageScale) extra-layer adult-texture baby-texture (5.2; the giant's
*>     shadow is 0.5 x 6.0; found 0 for an unknown type, baby-layer and baby-texture spaces when there is no baby model); EMD-RENDERER-COUNT n (13).
*>   EMD-TEXTURE type baby brute path: the texture of 5.2 (the piglin family: brute first, else baby, else adult; the zombie family: the baby flag; the skeletons one texture).
*>   EMD-OUTER-TEXTURE type baby path: the outer layer or clothes texture of 5.3 (spaces for a mob without one).
*>   EMD-LAYER-ORDER family(humanoid, giant, stand) position(1..) layer(X(24), spaces past the end): the order the renderer adds its layers (5.2).
*>   EMD-DIMS type baby marker width height eye-height (5.7): a marker stand is 0 x 0, a small stand (baby) 0.25 x 0.9875; zero for a type outside the document.
*>   EMD-STAND-FLAGS client-flags(byte as number) small show-arms show-base-plate marker (5.6: bit 1 small, 4 arms, 8 no base plate, 16 marker).
*>   EMD-STAND-RENDER-TYPE marker visible ghost render-type(X(24)) (5.6).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-RENDERER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC X(220) VALUE "zombie            ZombieRenderer            ZOMBIE                  ZOMBIE_BABY             0.5 none                    textures/entity/zombie/zombie.png                 textures/entity/zombie/zombie_baby.png            ".
    05 FILLER PIC X(220) VALUE "husk              HuskRenderer              HUSK                    HUSK_BABY               0.5 none                    textures/entity/zombie/husk.png                   textures/entity/zombie/husk_baby.png              ".
    05 FILLER PIC X(220) VALUE "drowned           DrownedRenderer           DROWNED                 DROWNED_BABY            0.5 DrownedOuterLayer       textures/entity/zombie/drowned.png                textures/entity/zombie/drowned_baby.png           ".
    05 FILLER PIC X(220) VALUE "giant             GiantMobRenderer          GIANT                                           3.0 none                    textures/entity/zombie/zombie.png                                                                   ".
    05 FILLER PIC X(220) VALUE "skeleton          SkeletonRenderer          SKELETON                SKELETON                0.5 none                    textures/entity/skeleton/skeleton.png             textures/entity/skeleton/skeleton.png             ".
    05 FILLER PIC X(220) VALUE "stray             StrayRenderer             STRAY                   STRAY                   0.5 SkeletonClothingLayer   textures/entity/skeleton/stray.png                textures/entity/skeleton/stray.png                ".
    05 FILLER PIC X(220) VALUE "bogged            BoggedRenderer            BOGGED                  BOGGED                  0.5 SkeletonClothingLayer   textures/entity/skeleton/bogged.png               textures/entity/skeleton/bogged.png               ".
    05 FILLER PIC X(220) VALUE "wither_skeleton   WitherSkeletonRenderer    WITHER_SKELETON         WITHER_SKELETON         0.5 none                    textures/entity/skeleton/wither_skeleton.png      textures/entity/skeleton/wither_skeleton.png      ".
    05 FILLER PIC X(220) VALUE "parched           ParchedRenderer           PARCHED                 PARCHED                 0.5 none                    textures/entity/skeleton/parched.png              textures/entity/skeleton/parched.png              ".
    05 FILLER PIC X(220) VALUE "piglin            PiglinRenderer            PIGLIN                  PIGLIN_BABY             0.5 none                    textures/entity/piglin/piglin.png                 textures/entity/piglin/piglin_baby.png            ".
    05 FILLER PIC X(220) VALUE "piglin_brute      PiglinRenderer            PIGLIN_BRUTE            PIGLIN_BRUTE            0.5 none                    textures/entity/piglin/piglin_brute.png           textures/entity/piglin/piglin_brute.png           ".
    05 FILLER PIC X(220) VALUE "zombified_piglin  ZombifiedPiglinRenderer   ZOMBIFIED_PIGLIN        ZOMBIFIED_PIGLIN_BABY   0.5 none                    textures/entity/piglin/zombified_piglin.png       textures/entity/piglin/zombified_piglin_baby.png  ".
    05 FILLER PIC X(220) VALUE "armor_stand       ArmorStandRenderer        ARMOR_STAND             ARMOR_STAND_SMALL       0   none                    textures/entity/armorstand/armorstand.png         textures/entity/armorstand/armorstand.png         ".
 01 WS-TABLE-R REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 13 TIMES.
       10 WS-TYPE          PIC X(18).
       10 WS-RENDERER      PIC X(26).
       10 WS-ADULT         PIC X(24).
       10 WS-BABY          PIC X(24).
       10 WS-SHADOW        PIC X(4).
       10 WS-EXTRA         PIC X(24).
       10 WS-TEX-A         PIC X(50).
       10 WS-TEX-B         PIC X(50).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-FOUND                BINARY-LONG.
 01 L-RENDERER             PIC X(32).
 01 L-ADULT                PIC X(32).
 01 L-BABY                 PIC X(32).
 01 L-SHADOW               FLOAT-LONG.
 01 L-EXTRA                PIC X(32).
 01 L-TEX-A                PIC X(64).
 01 L-TEX-B                PIC X(64).
 PROCEDURE DIVISION USING L-TYPE L-FOUND L-RENDERER L-ADULT L-BABY L-SHADOW L-EXTRA L-TEX-A L-TEX-B.
     MOVE 0 TO L-FOUND L-SHADOW
     MOVE SPACES TO L-RENDERER L-ADULT L-BABY L-EXTRA L-TEX-A L-TEX-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         IF WS-TYPE(WS-I) = L-TYPE
             MOVE 1 TO L-FOUND
             MOVE WS-RENDERER(WS-I) TO L-RENDERER
             MOVE WS-ADULT(WS-I) TO L-ADULT
             MOVE WS-BABY(WS-I) TO L-BABY
             COMPUTE L-SHADOW = FUNCTION NUMVAL(WS-SHADOW(WS-I))
             MOVE WS-EXTRA(WS-I) TO L-EXTRA
             MOVE WS-TEX-A(WS-I) TO L-TEX-A
             MOVE WS-TEX-B(WS-I) TO L-TEX-B
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EMD-RENDERER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-RENDERER-COUNT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N.
     MOVE 13 TO L-N
     GOBACK.
 END PROGRAM EMD-RENDERER-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOUND               BINARY-LONG.
 01 WS-REND                PIC X(32).
 01 WS-ADULT               PIC X(32).
 01 WS-BABY                PIC X(32).
 01 WS-SHADOW              FLOAT-LONG.
 01 WS-EXTRA               PIC X(32).
 01 WS-TEX-A               PIC X(64).
 01 WS-TEX-B               PIC X(64).
 01 WS-BRUTE-NAME          PIC X(24) VALUE "piglin_brute".
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-BABY                 BINARY-LONG.
 01 L-BRUTE                BINARY-LONG.
 01 L-PATH                 PIC X(64).
 PROCEDURE DIVISION USING L-TYPE L-BABY L-BRUTE L-PATH.
     MOVE SPACES TO L-PATH
     CALL "EMD-RENDERER" USING L-TYPE WS-FOUND WS-REND WS-ADULT WS-BABY WS-SHADOW WS-EXTRA WS-TEX-A WS-TEX-B
     IF WS-FOUND = 1
         MOVE WS-TEX-A TO L-PATH
         IF L-BABY NOT = 0
             MOVE WS-TEX-B TO L-PATH
         END-IF
         IF L-TYPE = "piglin" AND L-BRUTE NOT = 0
             CALL "EMD-RENDERER" USING WS-BRUTE-NAME WS-FOUND WS-REND WS-ADULT WS-BABY WS-SHADOW WS-EXTRA WS-TEX-A WS-TEX-B
             MOVE WS-TEX-A TO L-PATH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EMD-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-OUTER-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-BABY                 BINARY-LONG.
 01 L-PATH                 PIC X(64).
 PROCEDURE DIVISION USING L-TYPE L-BABY L-PATH.
     MOVE SPACES TO L-PATH
     EVALUATE L-TYPE
         WHEN "drowned"
             MOVE "textures/entity/zombie/drowned_outer_layer.png" TO L-PATH
             IF L-BABY NOT = 0
                 MOVE "textures/entity/zombie/drowned_outer_layer_baby.png" TO L-PATH
             END-IF
         WHEN "stray"
             MOVE "textures/entity/skeleton/stray_overlay.png" TO L-PATH
         WHEN "bogged"
             MOVE "textures/entity/skeleton/bogged_overlay.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-OUTER-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-LAYER-ORDER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAMILY               PIC X(8).
 01 L-POSITION             BINARY-LONG.
 01 L-LAYER                PIC X(24).
 PROCEDURE DIVISION USING L-FAMILY L-POSITION L-LAYER.
     MOVE SPACES TO L-LAYER
     EVALUATE L-FAMILY ALSO L-POSITION
         WHEN "humanoid" ALSO 1 MOVE "custom_head" TO L-LAYER
         WHEN "humanoid" ALSO 2 MOVE "wings" TO L-LAYER
         WHEN "humanoid" ALSO 3 MOVE "item_in_hand" TO L-LAYER
         WHEN "humanoid" ALSO 4 MOVE "armor" TO L-LAYER
         WHEN "giant" ALSO 1 MOVE "item_in_hand" TO L-LAYER
         WHEN "giant" ALSO 2 MOVE "armor" TO L-LAYER
         WHEN "stand" ALSO 1 MOVE "armor" TO L-LAYER
         WHEN "stand" ALSO 2 MOVE "item_in_hand" TO L-LAYER
         WHEN "stand" ALSO 3 MOVE "wings" TO L-LAYER
         WHEN "stand" ALSO 4 MOVE "custom_head" TO L-LAYER
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-LAYER-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-DIMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC X(66) VALUE "zombie            0.6     1.95    1.74    0.49    0.98    0.775   ".
    05 FILLER PIC X(66) VALUE "husk              0.6     1.95    1.74    0.49    0.98    0.825   ".
    05 FILLER PIC X(66) VALUE "drowned           0.6     1.95    1.74    0.49    0.98    0.775   ".
    05 FILLER PIC X(66) VALUE "giant             3.6     12.0    10.44                           ".
    05 FILLER PIC X(66) VALUE "skeleton          0.6     1.99    1.74                            ".
    05 FILLER PIC X(66) VALUE "stray             0.6     1.99    1.74                            ".
    05 FILLER PIC X(66) VALUE "bogged            0.6     1.99    1.74                            ".
    05 FILLER PIC X(66) VALUE "parched           0.6     1.99    1.74                            ".
    05 FILLER PIC X(66) VALUE "wither_skeleton   0.7     2.4     2.1                             ".
    05 FILLER PIC X(66) VALUE "piglin            0.6     1.95    1.79    0.49    0.98    0.78    ".
    05 FILLER PIC X(66) VALUE "piglin_brute      0.6     1.95    1.79    0.49    0.98    0.78    ".
    05 FILLER PIC X(66) VALUE "zombified_piglin  0.6     1.95    1.79    0.49    0.98    0.78    ".
    05 FILLER PIC X(66) VALUE "armor_stand       0.5     1.975   1.7775  0.25    0.9875  0.9875  ".
 01 WS-TABLE-R REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 13 TIMES.
       10 WS-TYPE          PIC X(18).
       10 WS-W             PIC X(8).
       10 WS-H             PIC X(8).
       10 WS-EYE           PIC X(8).
       10 WS-BW            PIC X(8).
       10 WS-BH            PIC X(8).
       10 WS-BEYE          PIC X(8).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-BABY                 BINARY-LONG.
 01 L-MARKER               BINARY-LONG.
 01 L-W                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-EYE                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-TYPE L-BABY L-MARKER L-W L-H L-EYE.
     MOVE 0 TO L-W L-H L-EYE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         IF WS-TYPE(WS-I) = L-TYPE
             COMPUTE L-W = FUNCTION NUMVAL(WS-W(WS-I))
             COMPUTE L-H = FUNCTION NUMVAL(WS-H(WS-I))
             COMPUTE L-EYE = FUNCTION NUMVAL(WS-EYE(WS-I))
             IF L-BABY NOT = 0 AND WS-BW(WS-I) NOT = SPACES
                 COMPUTE L-W = FUNCTION NUMVAL(WS-BW(WS-I))
                 COMPUTE L-H = FUNCTION NUMVAL(WS-BH(WS-I))
                 COMPUTE L-EYE = FUNCTION NUMVAL(WS-BEYE(WS-I))
             END-IF
             IF L-TYPE = "armor_stand" AND L-MARKER NOT = 0
                 MOVE 0 TO L-W L-H L-EYE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EMD-DIMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-STAND-FLAGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAGS                BINARY-LONG.
 01 L-SMALL                BINARY-LONG.
 01 L-ARMS                 BINARY-LONG.
 01 L-PLATE                BINARY-LONG.
 01 L-MARKER               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS L-SMALL L-ARMS L-PLATE L-MARKER.
     COMPUTE L-SMALL = FUNCTION MOD(L-FLAGS, 2)
     COMPUTE WS-BIT = FUNCTION MOD(FUNCTION INTEGER-PART(L-FLAGS / 4), 2)
     MOVE WS-BIT TO L-ARMS
     COMPUTE WS-BIT = FUNCTION MOD(FUNCTION INTEGER-PART(L-FLAGS / 8), 2)
     COMPUTE L-PLATE = 1 - WS-BIT
     COMPUTE L-MARKER = FUNCTION MOD(FUNCTION INTEGER-PART(L-FLAGS / 16), 2)
     GOBACK.
 END PROGRAM EMD-STAND-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-STAND-RENDER-TYPE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MARKER               BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 01 L-GHOST                BINARY-LONG.
 01 L-TYPE                 PIC X(24).
 PROCEDURE DIVISION USING L-MARKER L-VISIBLE L-GHOST L-TYPE.
     MOVE SPACES TO L-TYPE
     IF L-MARKER NOT = 0
         EVALUATE TRUE
             WHEN L-VISIBLE NOT = 0
                 MOVE "entityCutout" TO L-TYPE
             WHEN L-GHOST NOT = 0
                 MOVE "entityTranslucent" TO L-TYPE
         END-EVALUATE
     ELSE
         EVALUATE TRUE
             WHEN L-GHOST NOT = 0
                 MOVE "entityTranslucentCull" TO L-TYPE
             WHEN L-VISIBLE NOT = 0
                 MOVE "entityCutout" TO L-TYPE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM EMD-STAND-RENDER-TYPE.
