*> Entity models part 1 section 8 (docs/protocol/34-entity-models-1-shared-model-and-framework.md): generic layers. IN is 16 FLOAT-LONG, OUT 64.
*>   EM8-LAYER-COLOUR IN(dyeable dye undyed-present undyed-rgb) OUT(colour as a Java int; 0 skips the layer); EM8-EQUIP-SKIP IN(has-equippable
*>     has-asset-id is-baby has-baby-model) OUT(skip, model 0 adult 1 baby); EM8-GLINT IN(foil trim layer-index(1..) humanoid-baby-layer-type)
*>     OUT(glint on this layer, trim drawn, trim glint drawn); EM8-HAND-OFFSET IN(arm sign +1 right -1 left, baby, armor-stand) OUT(x y z in blocks);
*>     EM8-HEAD-OPS IN(y offset, skull y offset, horizontal scale, vertical scale, is-skull) OUT(op count then 4 per op as in EM6-POSE-CHAIN);
*>     EM8-EMISSIVE IN(invisible, always-visible, alpha) OUT(draw, tint alpha byte); EM8-SWIRL IN(powered, age-in-ticks, x offset) OUT(draw, u, v,
*>     tint int); EM8-STUCK IN(a b c, snap choice 0 1 2 or -1 for none, cuboid min xyz, max xyz) OUT(translate xyz in blocks, yaw about Y, pitch about Z)
*>     (the random draws a, b, c, choice come from the caller: 8.7 Open question 14).
*>   EM8-LAYER-DOC class(X(32)) part(X(8) out: the document part of 8.6, "8.7" for the stuck layers, "-" for player-only, "?" unknown);
*>   EM8-STUCK-LAYER class model(X(40)) texture(X(60)) placement(0 IN_CUBE 1 ON_SURFACE -1 unknown).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-LAYER-COLOUR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE -1 TO L-O(1)
     IF L-I(1) NOT = 0
         MOVE 0 TO L-O(1)
         EVALUATE TRUE
             WHEN L-I(2) NOT = 0
                 MOVE L-I(2) TO L-O(1)
             WHEN L-I(3) NOT = 0
                 COMPUTE L-O(1) = L-I(4) - 16777216
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM EM8-LAYER-COLOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-EQUIP-SKIP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     IF L-I(1) = 0 OR L-I(2) = 0 OR (L-I(3) NOT = 0 AND L-I(4) = 0)
         MOVE 1 TO L-O(1)
     END-IF
     IF L-I(3) NOT = 0
         MOVE 1 TO L-O(2)
     END-IF
     GOBACK.
 END PROGRAM EM8-EQUIP-SKIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-GLINT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     IF L-I(2) NOT = 0 AND L-I(4) = 0
         MOVE 1 TO L-O(2)
         IF L-I(1) NOT = 0
             MOVE 1 TO L-O(3)
         END-IF
     END-IF
     IF L-I(1) NOT = 0 AND L-O(2) = 0 AND L-I(3) = 1
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EM8-GLINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-HAND-OFFSET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(2) NOT = 0 AND L-I(3) = 0
         MOVE 0 TO L-O(1)
         COMPUTE L-O(2) = 1 / 16
         COMPUTE L-O(3) = -4.5 / 16
     ELSE
         COMPUTE L-O(1) = L-I(1) / 16
         COMPUTE L-O(2) = 2 / 16
         COMPUTE L-O(3) = -10 / 16
     END-IF
     GOBACK.
 END PROGRAM EM8-HAND-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-HEAD-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
*>   op 1: scale (horizontal, vertical, horizontal); a skull then translates by its y offset and scales 1.1875; another item translates down 0.25,
*>   turns 180 degrees about Y and scales (0.625, -0.625, -0.625). Kinds: 1 translate, 2 scale, 3 rotate about Y.
     MOVE 2 TO L-O(2)
     MOVE L-I(3) TO L-O(3) L-O(5)
     MOVE L-I(4) TO L-O(4)
     IF L-I(5) NOT = 0
         MOVE 3 TO L-O(1)
         MOVE 1 TO L-O(6)
         MOVE 0 TO L-O(7) L-O(9)
         MOVE L-I(2) TO L-O(8)
         MOVE 2 TO L-O(10)
         MOVE 1.1875 TO L-O(11) L-O(12) L-O(13)
     ELSE
         MOVE 4 TO L-O(1)
         MOVE 1 TO L-O(6)
         MOVE 0 TO L-O(7) L-O(9)
         COMPUTE L-O(8) = -0.25 + L-I(1)
         MOVE 3 TO L-O(10)
         MOVE 180 TO L-O(11)
         MOVE 0 TO L-O(12) L-O(13)
         MOVE 2 TO L-O(14)
         MOVE 0.625 TO L-O(15)
         MOVE -0.625 TO L-O(16) L-O(17)
     END-IF
     GOBACK.
 END PROGRAM EM8-HEAD-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-EMISSIVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     IF (L-I(1) NOT = 0 AND L-I(2) = 0) OR L-I(3) <= 0.00001
         MOVE 0 TO L-O(1)
     END-IF
     MOVE 0 TO L-O(2)
     IF L-O(1) = 1
         COMPUTE L-O(2) = FUNCTION INTEGER(L-I(3) * 255)
     END-IF
     GOBACK.
 END PROGRAM EM8-EMISSIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-SWIRL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4)
     IF L-I(1) NOT = 0
         MOVE 1 TO L-O(1)
         COMPUTE L-O(2) = L-I(3) - FUNCTION INTEGER(L-I(3))
         COMPUTE L-O(3) = L-I(2) * 0.01 - FUNCTION INTEGER(L-I(2) * 0.01)
         MOVE -8355712 TO L-O(4)
     END-IF
     GOBACK.
 END PROGRAM EM8-SWIRL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-STUCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-CHOICE              BINARY-LONG.
 01 WS-T1                  FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-A
     MOVE L-I(2) TO WS-B
     MOVE L-I(3) TO WS-C
     COMPUTE WS-CHOICE = L-I(4)
     EVALUATE WS-CHOICE
         WHEN 0
             MOVE 0.5 TO WS-A
             IF L-I(1) > 0.5
                 MOVE 1 TO WS-A
             END-IF
         WHEN 1
             MOVE 0.5 TO WS-B
             IF L-I(2) > 0.5
                 MOVE 1 TO WS-B
             END-IF
         WHEN 2
             MOVE 0.5 TO WS-C
             IF L-I(3) > 0.5
                 MOVE 1 TO WS-C
             END-IF
     END-EVALUATE
     COMPUTE L-O(1) = (L-I(5) + (L-I(8) - L-I(5)) * WS-A) / 16
     COMPUTE L-O(2) = (L-I(6) + (L-I(9) - L-I(6)) * WS-B) / 16
     COMPUTE L-O(3) = (L-I(7) + (L-I(10) - L-I(7)) * WS-C) / 16
     COMPUTE WS-AX = -(2 * WS-A - 1)
     COMPUTE WS-AY = -(2 * WS-B - 1)
     COMPUTE WS-AZ = -(2 * WS-C - 1)
     COMPUTE WS-R = FUNCTION SQRT(WS-AX * WS-AX + WS-AZ * WS-AZ)
     CALL "EM8-ATAN2" USING WS-AX WS-AZ WS-T1
     CALL "EM8-ATAN2" USING WS-AY WS-R WS-T2
     COMPUTE L-O(4) = WS-T1 * 57.2957763671875 - 90
     COMPUTE L-O(5) = WS-T2 * 57.2957763671875
     GOBACK.
 END PROGRAM EM8-STUCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-LAYER-DOC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC X(40) VALUE "HumanoidArmorLayer              2".
    05 FILLER PIC X(40) VALUE "WingsLayer                      2".
    05 FILLER PIC X(40) VALUE "CapeLayer                       12".
    05 FILLER PIC X(40) VALUE "Deadmau5EarsLayer               12".
    05 FILLER PIC X(40) VALUE "CrossedArmsItemLayer            3".
    05 FILLER PIC X(40) VALUE "VillagerProfessionLayer         3".
    05 FILLER PIC X(40) VALUE "WitchItemLayer                  3".
    05 FILLER PIC X(40) VALUE "SkeletonClothingLayer           2".
    05 FILLER PIC X(40) VALUE "DrownedOuterLayer               2".
    05 FILLER PIC X(40) VALUE "CarriedBlockLayer               6".
    05 FILLER PIC X(40) VALUE "EnderEyesLayer                  6".
    05 FILLER PIC X(40) VALUE "IronGolemCrackinessLayer        3".
    05 FILLER PIC X(40) VALUE "IronGolemFlowerLayer            3".
    05 FILLER PIC X(40) VALUE "SnowGolemHeadLayer              3".
    05 FILLER PIC X(40) VALUE "BlockDecorationLayer            3".
    05 FILLER PIC X(40) VALUE "WitherArmorLayer                7".
    05 FILLER PIC X(40) VALUE "CreeperPowerLayer               6".
    05 FILLER PIC X(40) VALUE "SlimeOuterLayer                 6".
    05 FILLER PIC X(40) VALUE "SulfurCubeInnerLayer            6".
    05 FILLER PIC X(40) VALUE "SpiderEyesLayer                 6".
    05 FILLER PIC X(40) VALUE "PhantomEyesLayer                6".
    05 FILLER PIC X(40) VALUE "BreezeEyesLayer                 6".
    05 FILLER PIC X(40) VALUE "BreezeWindLayer                 6".
    05 FILLER PIC X(40) VALUE "SheepWoolLayer                  4".
    05 FILLER PIC X(40) VALUE "SheepWoolUndercoatLayer         4".
    05 FILLER PIC X(40) VALUE "MushroomCowMushroomLayer        4".
    05 FILLER PIC X(40) VALUE "LlamaDecorLayer                 4".
    05 FILLER PIC X(40) VALUE "HorseMarkingLayer               4".
    05 FILLER PIC X(40) VALUE "CatCollarLayer                  5".
    05 FILLER PIC X(40) VALUE "WolfCollarLayer                 5".
    05 FILLER PIC X(40) VALUE "WolfArmorLayer                  5".
    05 FILLER PIC X(40) VALUE "FoxHeldItemLayer                5".
    05 FILLER PIC X(40) VALUE "PandaHoldsItemLayer             5".
    05 FILLER PIC X(40) VALUE "RopesLayer                      4".
    05 FILLER PIC X(40) VALUE "DolphinCarryingItemLayer        8".
    05 FILLER PIC X(40) VALUE "TropicalFishPatternLayer        8".
    05 FILLER PIC X(40) VALUE "StuckInBodyLayer                8.7".
    05 FILLER PIC X(40) VALUE "ArrowLayer                      8.7".
    05 FILLER PIC X(40) VALUE "BeeStingerLayer                 8.7".
    05 FILLER PIC X(40) VALUE "ParrotOnShoulderLayer           -".
 01 WS-TABLE-R REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 40 TIMES.
       10 WS-CLASS         PIC X(32).
       10 WS-PART          PIC X(8).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CLASS                PIC X(32).
 01 L-PART                 PIC X(8).
 PROCEDURE DIVISION USING L-CLASS L-PART.
     MOVE "?" TO L-PART
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         IF WS-CLASS(WS-I) = L-CLASS
             MOVE WS-PART(WS-I) TO L-PART
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM8-LAYER-DOC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-STUCK-LAYER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                PIC X(32).
 01 L-MODEL                PIC X(40).
 01 L-TEX                  PIC X(60).
 01 L-PLACE                BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-MODEL L-TEX L-PLACE.
     MOVE SPACES TO L-MODEL L-TEX
     MOVE -1 TO L-PLACE
     EVALUATE L-CLASS
         WHEN "ArrowLayer"
             MOVE "minecraft:arrow#main" TO L-MODEL
             MOVE "NORMAL_ARROW_LOCATION" TO L-TEX
             MOVE 0 TO L-PLACE
         WHEN "BeeStingerLayer"
             MOVE "minecraft:bee_stinger#main" TO L-MODEL
             MOVE "textures/entity/bee/bee_stinger.png" TO L-TEX
             MOVE 1 TO L-PLACE
     END-EVALUATE
     GOBACK.
 END PROGRAM EM8-STUCK-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM8-ATAN2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
*> USING y x angle: radians in (-pi, pi]; atan2(0, 0) is 0 (GnuCOBOL has no ATAN2).
 PROCEDURE DIVISION USING L-Y L-X L-A.
     EVALUATE TRUE
         WHEN L-X > 0
             COMPUTE L-A = FUNCTION ATAN(L-Y / L-X)
         WHEN L-X < 0 AND L-Y >= 0
             COMPUTE L-A = FUNCTION ATAN(L-Y / L-X) + 3.141592653589793
         WHEN L-X < 0
             COMPUTE L-A = FUNCTION ATAN(L-Y / L-X) - 3.141592653589793
         WHEN L-Y > 0
             COMPUTE L-A = 1.5707963267948966
         WHEN L-Y < 0
             COMPUTE L-A = -1.5707963267948966
         WHEN OTHER
             MOVE 0 TO L-A
     END-EVALUATE
     GOBACK.
 END PROGRAM EM8-ATAN2.
