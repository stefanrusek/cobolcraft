*> Entity models part 4 (docs/protocol/34-entity-models-4-farm-animals-equines.md): farm and ridable land animals. Section 0 and 1 here; each animal in client/src/entmodel-34-4-<n>.cob.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF4-SCALE-STEP IN(root offset y, root scale, s) OUT(offset y, scale) after one MeshTransformer.scaling(s) (0.1); chain it for several scalings.
*>   EF4-SCALE-PIVOT IN(pivot y, s) OUT(y of a part after the scaling, 0.1). EF4-AGEABLE entity(X(24)) flag(out BINARY-LONG): 1 when the renderer extends AgeableMobRenderer (0 for cow, pig, chicken).
*> Models are built by EF4-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out), client/src/entmodel-34-4-layers.cob.
*>   Section 1: EF4-REGISTRY (1.5), EF4-AGE-SCALE and EF4-SHADOW (1.6), EF4-HEAD-EAT, EF4-TAIL-OFFSET, EF4-EQUIP-DRAWN and EF4-LAYER-TYPE and EF4-LAYER-ORDER (1.3), EF4-VARIANT-MODEL and EF4-VARIANT-DRAW (1.2).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-SCALE-STEP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * L-I(3) + 24.016 * (1 - L-I(3))
     COMPUTE L-O(2) = L-I(2) * L-I(3)
     GOBACK.
 END PROGRAM EF4-SCALE-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-SCALE-PIVOT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * L-I(2) + 24.016 * (1 - L-I(2))
     GOBACK.
 END PROGRAM EF4-SCALE-PIVOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-AGEABLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENT                  PIC X(24).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENT L-FLAG.
     MOVE 1 TO L-FLAG
     IF L-ENT = "cow" OR L-ENT = "pig" OR L-ENT = "chicken"
         MOVE 0 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM EF4-AGEABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-REGISTRY.
*> USING entity(X(24)) shadow(FLOAT-LONG) adult-layer(X(32)) baby-layer(X(32), spaces when none) layers(BINARY-LONG, the layers after the body): the registry table of 1.5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENT                  PIC X(24).
 01 L-SHADOW               FLOAT-LONG.
 01 L-ADULT                PIC X(32).
 01 L-BABY                 PIC X(32).
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ENT L-SHADOW L-ADULT L-BABY L-N.
     MOVE 0 TO L-SHADOW L-N
     MOVE SPACES TO L-ADULT L-BABY
     EVALUATE L-ENT
         WHEN "cow"
             MOVE 0.7 TO L-SHADOW
             MOVE "COW" TO L-ADULT
             MOVE "COW_BABY" TO L-BABY
             MOVE 0 TO L-N
         WHEN "mooshroom"
             MOVE 0.7 TO L-SHADOW
             MOVE "MOOSHROOM" TO L-ADULT
             MOVE "MOOSHROOM_BABY" TO L-BABY
             MOVE 1 TO L-N
         WHEN "pig"
             MOVE 0.7 TO L-SHADOW
             MOVE "PIG" TO L-ADULT
             MOVE "PIG_BABY" TO L-BABY
             MOVE 1 TO L-N
         WHEN "sheep"
             MOVE 0.7 TO L-SHADOW
             MOVE "SHEEP" TO L-ADULT
             MOVE "SHEEP_BABY" TO L-BABY
             MOVE 2 TO L-N
         WHEN "chicken"
             MOVE 0.3 TO L-SHADOW
             MOVE "CHICKEN" TO L-ADULT
             MOVE "CHICKEN_BABY" TO L-BABY
             MOVE 0 TO L-N
         WHEN "goat"
             MOVE 0.7 TO L-SHADOW
             MOVE "GOAT" TO L-ADULT
             MOVE "GOAT_BABY" TO L-BABY
             MOVE 0 TO L-N
         WHEN "horse"
             MOVE 0.75 TO L-SHADOW
             MOVE "HORSE" TO L-ADULT
             MOVE "HORSE_BABY" TO L-BABY
             MOVE 3 TO L-N
         WHEN "donkey"
             MOVE 0.75 TO L-SHADOW
             MOVE "DONKEY" TO L-ADULT
             MOVE "DONKEY_BABY" TO L-BABY
             MOVE 1 TO L-N
         WHEN "mule"
             MOVE 0.75 TO L-SHADOW
             MOVE "MULE" TO L-ADULT
             MOVE "MULE_BABY" TO L-BABY
             MOVE 1 TO L-N
         WHEN "skeleton_horse"
             MOVE 0.75 TO L-SHADOW
             MOVE "SKELETON_HORSE" TO L-ADULT
             MOVE "SKELETON_HORSE_BABY" TO L-BABY
             MOVE 2 TO L-N
         WHEN "zombie_horse"
             MOVE 0.75 TO L-SHADOW
             MOVE "ZOMBIE_HORSE" TO L-ADULT
             MOVE "ZOMBIE_HORSE_BABY" TO L-BABY
             MOVE 2 TO L-N
         WHEN "llama"
             MOVE 0.7 TO L-SHADOW
             MOVE "LLAMA" TO L-ADULT
             MOVE "LLAMA_BABY" TO L-BABY
             MOVE 1 TO L-N
         WHEN "trader_llama"
             MOVE 0.7 TO L-SHADOW
             MOVE "TRADER_LLAMA" TO L-ADULT
             MOVE "TRADER_LLAMA_BABY" TO L-BABY
             MOVE 1 TO L-N
         WHEN "llama_spit"
             MOVE 0 TO L-SHADOW
             MOVE "LLAMA_SPIT" TO L-ADULT
             MOVE 0 TO L-N
         WHEN "camel"
             MOVE 0.7 TO L-SHADOW
             MOVE "CAMEL" TO L-ADULT
             MOVE "CAMEL_BABY" TO L-BABY
             MOVE 1 TO L-N
         WHEN "camel_husk"
             MOVE 0.7 TO L-SHADOW
             MOVE "CAMEL" TO L-ADULT
             MOVE 1 TO L-N
         WHEN "happy_ghast"
             MOVE 2 TO L-SHADOW
             MOVE "HAPPY_GHAST" TO L-ADULT
             MOVE "HAPPY_GHAST_BABY" TO L-BABY
             MOVE 2 TO L-N
         WHEN "rabbit"
             MOVE 0.3 TO L-SHADOW
             MOVE "RABBIT" TO L-ADULT
             MOVE "RABBIT_BABY" TO L-BABY
             MOVE 0 TO L-N
     END-EVALUATE
     GOBACK.
 END PROGRAM EF4-REGISTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-AGE-SCALE.
*> USING entity(X(24)) baby(BINARY-LONG) ageScale(out FLOAT-LONG): 1.6, 1 for an adult, 0.5 for a baby except goat 0.55, camel and camel_husk 0.6, happy_ghast 0.2375.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENT                  PIC X(24).
 01 L-BABY                 BINARY-LONG.
 01 L-AGE                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-ENT L-BABY L-AGE.
     MOVE 1 TO L-AGE
     IF L-BABY NOT = 0
         MOVE 0.5 TO L-AGE
         EVALUATE L-ENT
             WHEN "goat" MOVE 0.55 TO L-AGE
             WHEN "camel" WHEN "camel_husk" MOVE 0.6 TO L-AGE
             WHEN "happy_ghast" MOVE 0.2375 TO L-AGE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM EF4-AGE-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-SHADOW.
*> USING entity baby radius(out): the shadow radius, the base radius of 1.5 times ageScale (scale 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-A32                 PIC X(32).
 01 WS-B32                 PIC X(32).
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENT                  PIC X(24).
 01 L-BABY                 BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ENT L-BABY L-R.
     CALL "EF4-REGISTRY" USING L-ENT WS-S WS-A32 WS-B32 WS-N
     CALL "EF4-AGE-SCALE" USING L-ENT L-BABY WS-A
     COMPUTE L-R = WS-S * WS-A
     GOBACK.
 END PROGRAM EF4-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HEAD-EAT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(headEatPositionScale, ageScale) OUT(head y offset): the sheep head offset of 1.6 and 5.2 (position scale x 9 x ageScale).
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * 9 * L-I(2)
     GOBACK.
 END PROGRAM EF4-HEAD-EAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-TAIL-OFFSET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(walkAnimationSpeed s, ageScale) OUT(tail y offset, tail z offset): the equine tail of 1.6 and 8.3 step 12.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * L-I(2)
     COMPUTE L-O(2) = L-I(1) * 2 * L-I(2)
     GOBACK.
 END PROGRAM EF4-TAIL-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-EQUIP-DRAWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(has EQUIPPABLE, asset id present, baby, baby model present) OUT(drawn): SimpleEquipmentLayer of 1.3.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0 AND L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
         IF L-I(3) NOT = 0 AND L-I(4) = 0
             MOVE 0 TO L-O(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF4-EQUIP-DRAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-LAYER-TYPE.
*> USING layer-type-name(X(40)) ordinal(out BINARY-LONG, 0 unknown): EquipmentClientInfo$LayerType values of 1.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ORD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ORD.
     MOVE 0 TO L-ORD
     EVALUATE L-NAME
         WHEN "horse_body" MOVE 5 TO L-ORD
         WHEN "llama_body" MOVE 6 TO L-ORD
         WHEN "pig_saddle" MOVE 7 TO L-ORD
         WHEN "camel_saddle" MOVE 9 TO L-ORD
         WHEN "camel_husk_saddle" MOVE 10 TO L-ORD
         WHEN "horse_saddle" MOVE 11 TO L-ORD
         WHEN "donkey_saddle" MOVE 12 TO L-ORD
         WHEN "mule_saddle" MOVE 13 TO L-ORD
         WHEN "zombie_horse_saddle" MOVE 14 TO L-ORD
         WHEN "skeleton_horse_saddle" MOVE 15 TO L-ORD
         WHEN "happy_ghast_body" MOVE 16 TO L-ORD
     END-EVALUATE
     GOBACK.
 END PROGRAM EF4-LAYER-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-LAYER-ORDER.
*> USING entity(X(24)) kind(1 armor, 2 saddle) order(out): HorseRenderer passes 2 for its armor and saddle layers, every other layer uses 0 (1.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENT                  PIC X(24).
 01 L-KIND                 BINARY-LONG.
 01 L-ORDER                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ENT L-KIND L-ORDER.
     MOVE 0 TO L-ORDER
     IF L-ENT = "horse"
         MOVE 2 TO L-ORDER
     END-IF
     GOBACK.
 END PROGRAM EF4-LAYER-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-VARIANT-MODEL.
*> USING kind(X(24) cow, pig or chicken) model-type(X(40) normal, warm, cold) baby layer(out X(32)): the model pair of the variant's model type (1.2, 1.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 PIC X(24).
 01 L-TYPE                 PIC X(40).
 01 L-BABY                 BINARY-LONG.
 01 L-LAYER                PIC X(32).
 PROCEDURE DIVISION USING L-KIND L-TYPE L-BABY L-LAYER.
     MOVE SPACES TO L-LAYER
     EVALUATE L-KIND
         WHEN "cow"
             EVALUATE L-TYPE
                 WHEN "warm" MOVE "WARM_COW" TO L-LAYER
                 WHEN "cold" MOVE "COLD_COW" TO L-LAYER
                 WHEN OTHER MOVE "COW" TO L-LAYER
             END-EVALUATE
             IF L-BABY NOT = 0
                 STRING FUNCTION TRIM(L-LAYER) "_BABY" DELIMITED BY SIZE INTO L-LAYER
             END-IF
         WHEN "pig"
             MOVE "PIG" TO L-LAYER
             IF L-TYPE = "cold" AND L-BABY = 0
                 MOVE "COLD_PIG" TO L-LAYER
             END-IF
             IF L-BABY NOT = 0
                 MOVE "PIG_BABY" TO L-LAYER
             END-IF
         WHEN "chicken"
             MOVE "CHICKEN" TO L-LAYER
             IF L-TYPE = "cold" AND L-BABY = 0
                 MOVE "COLD_CHICKEN" TO L-LAYER
             END-IF
             IF L-BABY NOT = 0
                 MOVE "CHICKEN_BABY" TO L-LAYER
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM EF4-VARIANT-MODEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-VARIANT-DRAW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
*> IN(variant is null) OUT(draws, texture is the missing texture): cow, pig and chicken submit nothing for a null variant (1.2).
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     MOVE 0 TO L-O(2)
     IF L-I(1) NOT = 0
         MOVE 0 TO L-O(1)
         MOVE 1 TO L-O(2)
     END-IF
     GOBACK.
 END PROGRAM EF4-VARIANT-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-QUAD-POSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-QI.
    05 WS-QV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-QO.
    05 WS-QOV              FLOAT-LONG OCCURS 10 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
*> USING model state(1 xRot degrees, 2 yRot degrees, 3 walk position, 4 walk speed): the QuadrupedModel.setupAnim of 34-1 3.4 on the parts head, right_hind_leg,
*> left_hind_leg, right_front_leg, left_front_leg (reset first; a part that the model lacks is skipped).
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE L-I(1) TO WS-QV(1)
     MOVE L-I(2) TO WS-QV(2)
     MOVE L-I(3) TO WS-QV(3)
     MOVE L-I(4) TO WS-QV(4)
     CALL "EM3-QUAD-ANIM" USING WS-QI WS-QO
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     IF WS-P NOT = 0
         MOVE WS-QOV(1) TO MM-CXROT(WS-P)
         MOVE WS-QOV(2) TO MM-CYROT(WS-P)
     END-IF
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     IF WS-P NOT = 0
         MOVE WS-QOV(3) TO MM-CXROT(WS-P)
     END-IF
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     IF WS-P NOT = 0
         MOVE WS-QOV(4) TO MM-CXROT(WS-P)
     END-IF
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     IF WS-P NOT = 0
         MOVE WS-QOV(5) TO MM-CXROT(WS-P)
     END-IF
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     IF WS-P NOT = 0
         MOVE WS-QOV(6) TO MM-CXROT(WS-P)
     END-IF
     GOBACK.
 END PROGRAM EF4-QUAD-POSE.
