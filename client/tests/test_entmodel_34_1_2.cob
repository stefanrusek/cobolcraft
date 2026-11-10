*> Acceptance test of docs/protocol/34-entity-models-1-shared-model-and-framework.md section 2 (Building a model: definitions, deformation, baby transform
*> and scaling): 2.1 the replace rule, clearChild, clearRecursively, retainPartsAndChildren, retainExactParts; 2.2 mesh scaling with V5 and the
*> transformer-to-layer table; 2.3 the baby transform with V4 and its constructors; 2.4 the deformation constants; 2.5 the armor set ids.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-1-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEM2.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-ARM                 BINARY-LONG.
 01 WS-LEG                 BINARY-LONG.
 01 WS-HAT                 BINARY-LONG.
 01 WS-PNAME               PIC X(24).
 01 WS-PARENT              BINARY-LONG.
 01 WS-CUBES               BINARY-LONG.
 01 WS-POSE.
    05 WS-P                FLOAT-LONG OCCURS 9 TIMES.
 01 WS-OK                  BINARY-LONG.
 01 WS-SET                 PIC X(120).
 01 WS-MODE                BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-LAYER               PIC X(32).
 01 WS-KIND                PIC X(24).
 01 WS-G.
    05 WS-GV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-VARIANT             BINARY-LONG.
 01 WS-SCALE-HEAD          BINARY-LONG.
 01 WS-YH                  FLOAT-LONG.
 01 WS-ZH                  FLOAT-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ID                  PIC X(40).
 PROCEDURE DIVISION.
*> 2.1 replace rule: re-adding a name under the same parent keeps the old child's children.
     CALL "EM2-MESH-INIT" USING EM2-MESH
     MOVE 1 TO WS-PARENT
     MOVE "head" TO WS-PNAME
     MOVE 1 TO WS-CUBES
     MOVE 0 TO WS-P(1) WS-P(2) WS-P(3) WS-P(4) WS-P(5) WS-P(6)
     MOVE 1 TO WS-P(7) WS-P(8) WS-P(9)
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-CUBES WS-POSE WS-HEAD
     MOVE "hat" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-HEAD WS-PNAME WS-CUBES WS-POSE WS-HAT
     MOVE "root has one part plus children: three parts" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE MH-COUNT TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PNAME
     MOVE 4 TO WS-CUBES
     MOVE 5 TO WS-P(2)
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-CUBES WS-POSE WS-IDX
     MOVE "replacing returns the same slot" TO WS-NAME
     MOVE WS-HEAD TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-NUM
     MOVE "replace does not add a part" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE MH-COUNT TO WS-O
     PERFORM CHECK-NUM
     MOVE "replace takes the new cuboids and pose" TO WS-NAME
     COMPUTE WS-O = MH-CUBES(WS-HEAD) * 100 + MH-Y(WS-HEAD)
     COMPUTE WS-E = 4 * 100 + 5
     PERFORM CHECK-NUM
     MOVE "the old child's own child survives" TO WS-NAME
     MOVE WS-HEAD TO WS-E
     MOVE MH-PARENT(WS-HAT) TO WS-O
     PERFORM CHECK-NUM
*>   clearChild: same pose, no cuboids, children survive; a missing name is an error.
     MOVE "head" TO WS-PNAME
     CALL "EM2-CLEAR-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-OK
     MOVE "clearChild succeeds" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "clearChild empties cuboids and keeps pose" TO WS-NAME
     COMPUTE WS-O = MH-CUBES(WS-HEAD) * 100 + MH-Y(WS-HEAD)
     MOVE 5 TO WS-E
     PERFORM CHECK-NUM
     MOVE "clearChild keeps the subtree cuboids" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MH-CUBES(WS-HAT) TO WS-O
     PERFORM CHECK-NUM
     MOVE "wing" TO WS-PNAME
     CALL "EM2-CLEAR-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-OK
     MOVE "clearChild of a missing name fails" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
*>   clearRecursively: every descendant keeps its pose and loses its cuboids.
     MOVE 2 TO MH-CUBES(WS-HAT)
     CALL "EM2-CLEAR-ALL" USING EM2-MESH
     MOVE "clearRecursively empties every part" TO WS-NAME
     COMPUTE WS-O = MH-CUBES(WS-HEAD) + MH-CUBES(WS-HAT)
     MOVE 0 TO WS-E
     PERFORM CHECK-NUM
     MOVE "clearRecursively keeps the pose" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE MH-Y(WS-HEAD) TO WS-O
     PERFORM CHECK-NUM
*>   retainPartsAndChildren({head}): named part untouched with its subtree; unnamed ones emptied and recursed.
     PERFORM BUILD-HUMANOID
     MOVE 1 TO WS-MODE
     MOVE "head|right_arm" TO WS-SET
     CALL "EM2-RETAIN" USING EM2-MESH WS-MODE WS-SET
     MOVE "retainPartsAndChildren keeps head and its hat" TO WS-NAME
     COMPUTE WS-O = MH-CUBES(WS-HEAD) * 10 + MH-CUBES(WS-HAT)
     MOVE 11 TO WS-E
     PERFORM CHECK-NUM
     MOVE "retainPartsAndChildren empties body and leg" TO WS-NAME
     COMPUTE WS-O = MH-CUBES(WS-BODY) + MH-CUBES(WS-LEG)
     MOVE 0 TO WS-E
     PERFORM CHECK-NUM
     MOVE "retainPartsAndChildren keeps the right arm" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MH-CUBES(WS-ARM) TO WS-O
     PERFORM CHECK-NUM
*>   retainExactParts({head}): the named part keeps its cuboids, its descendants are emptied.
     PERFORM BUILD-HUMANOID
     MOVE 2 TO WS-MODE
     MOVE "head" TO WS-SET
     CALL "EM2-RETAIN" USING EM2-MESH WS-MODE WS-SET
     MOVE "retainExactParts keeps head, empties the hat" TO WS-NAME
     COMPUTE WS-O = MH-CUBES(WS-HEAD) * 10 + MH-CUBES(WS-HAT)
     MOVE 10 TO WS-E
     PERFORM CHECK-NUM
     MOVE "retainExactParts empties the unnamed parts" TO WS-NAME
     COMPUTE WS-O = MH-CUBES(WS-BODY) + MH-CUBES(WS-ARM) + MH-CUBES(WS-LEG)
     MOVE 0 TO WS-E
     PERFORM CHECK-NUM
*> 2.2 / V5: scaling(0.9375).
     CALL "EM2-MESH-INIT" USING EM2-MESH
     MOVE 0.9375 TO WS-S
     CALL "EM2-SCALING" USING EM2-MESH WS-S
     MOVE "V5 root position k = 1.5010" TO WS-NAME
     COMPUTE WS-E = 24.016 * 0.0625
     MOVE MH-Y(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "V5 root scale" TO WS-NAME
     COMPUTE WS-O = MH-XSCALE(1) + MH-YSCALE(1) * 10 + MH-ZSCALE(1) * 100
     COMPUTE WS-E = 0.9375 * 111
     PERFORM CHECK-NUM
     CALL "EM2-MESH-INIT" USING EM2-MESH
     MOVE 6 TO WS-S
     CALL "EM2-SCALING" USING EM2-MESH WS-S
     MOVE "giant factor 6 shifts down by -120.08" TO WS-NAME
     MOVE -120.08 TO WS-E
     MOVE MH-Y(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-S
     CALL "EM2-MESH-INIT" USING EM2-MESH
     CALL "EM2-SCALING" USING EM2-MESH WS-S
     MOVE "factor 1 is the identity" TO WS-NAME
     COMPUTE WS-O = MH-Y(1) * 100 + MH-YSCALE(1)
     MOVE 1 TO WS-E
     PERFORM CHECK-NUM
*>   the transformer to layer table.
     MOVE "villager" TO WS-LAYER
     PERFORM CHECK-FACTOR-0-9375
     MOVE "evoker" TO WS-LAYER
     PERFORM CHECK-FACTOR-0-9375
     MOVE "vindicator" TO WS-LAYER
     PERFORM CHECK-FACTOR-0-9375
     MOVE "witch" TO WS-LAYER
     PERFORM CHECK-FACTOR-0-9375
     MOVE "villager_no_hat" TO WS-LAYER
     PERFORM CHECK-FACTOR-0-9375
     MOVE "wandering_trader" TO WS-LAYER
     PERFORM CHECK-FACTOR-0-9375
     MOVE "cave_spider" TO WS-LAYER
     MOVE 0.7 TO WS-E
     PERFORM CHECK-FACTOR
     MOVE "giant_armor" TO WS-LAYER
     MOVE 6 TO WS-E
     PERFORM CHECK-FACTOR
     MOVE "giant" TO WS-LAYER
     PERFORM CHECK-FACTOR
     MOVE "horse_saddle" TO WS-LAYER
     MOVE 1.1 TO WS-E
     PERFORM CHECK-FACTOR
     MOVE "horse_armor" TO WS-LAYER
     PERFORM CHECK-FACTOR
     MOVE "husk_armor" TO WS-LAYER
     MOVE 1.0625 TO WS-E
     PERFORM CHECK-FACTOR
     MOVE "wither_skeleton_armor" TO WS-LAYER
     MOVE 1.2 TO WS-E
     PERFORM CHECK-FACTOR
     MOVE "horse_baby" TO WS-LAYER
     MOVE 1 TO WS-E
     PERFORM CHECK-FACTOR
     MOVE "husk_baby" TO WS-LAYER
     PERFORM CHECK-FACTOR
     MOVE "zombie" TO WS-LAYER
     PERFORM CHECK-FACTOR
*> 2.3 / V4: the humanoid baby transform.
     PERFORM BUILD-HUMANOID
     MOVE 1 TO WS-VARIANT
     MOVE 1 TO WS-SCALE-HEAD
     MOVE 16 TO WS-YH
     MOVE 0 TO WS-ZH
     CALL "EM2-BABY-PARAMS" USING WS-VARIANT WS-SCALE-HEAD WS-YH WS-ZH EM2-BABY
     MOVE "V4 parameters: head factor inputs 16, 0, 2, 2, 24" TO WS-NAME
     COMPUTE WS-O = BB-Y-HEAD * 10000 + BB-Z-HEAD * 1000 + BB-HEAD-SCALE * 100 + BB-BODY-SCALE * 10 + BB-BODY-Y * 0.01
     COMPUTE WS-E = 16 * 10000 + 0 + 2 * 100 + 2 * 10 + 24 * 0.01
     PERFORM CHECK-NUM
     MOVE "head" TO WS-SET
     CALL "EM2-BABY-MESH" USING EM2-MESH EM2-BABY WS-SET
     MOVE "V4 head pivot becomes (0, 12, 0) scale 0.75" TO WS-NAME
     COMPUTE WS-O = MH-Y(WS-HEAD) * 100 + MH-YSCALE(WS-HEAD)
     COMPUTE WS-E = 12 * 100 + 0.75
     PERFORM CHECK-NUM
     MOVE "V4 body becomes (0, 12, 0) scale 0.5" TO WS-NAME
     COMPUTE WS-O = MH-Y(WS-BODY) * 100 + MH-YSCALE(WS-BODY)
     COMPUTE WS-E = 12 * 100 + 0.5
     PERFORM CHECK-NUM
     MOVE "V4 right arm (-5, 2, 0) becomes (-2.5, 13, 0)" TO WS-NAME
     COMPUTE WS-O = MH-X(WS-ARM) * 10000 + MH-Y(WS-ARM) * 100 + MH-Z(WS-ARM)
     COMPUTE WS-E = -2.5 * 10000 + 13 * 100
     PERFORM CHECK-NUM
     MOVE "V4 right leg (-1.9, 12, 0) becomes (-0.95, 18, 0)" TO WS-NAME
     COMPUTE WS-O = MH-X(WS-LEG) * 10000 + MH-Y(WS-LEG) * 100 + MH-Z(WS-LEG)
     COMPUTE WS-E = -0.95 * 10000 + 18 * 100
     PERFORM CHECK-NUM
     MOVE "V4 leg ends on the ground (18 + 12 x 0.5 = 24)" TO WS-NAME
     COMPUTE WS-O = MH-Y(WS-LEG) + 12 * MH-YSCALE(WS-LEG)
     MOVE 24 TO WS-E
     PERFORM CHECK-NUM
     MOVE "V4 the hat child is untouched" TO WS-NAME
     COMPUTE WS-O = MH-Y(WS-HAT) * 10 + MH-YSCALE(WS-HAT)
     COMPUTE WS-E = 0 + 1
     PERFORM CHECK-NUM
*>   head-part-only constructor: defaults scaleHead false, 5, 2, 2, 2, 24 -> head (0, 5, 2) scale 1.
     PERFORM BUILD-HUMANOID
     MOVE 2 TO WS-VARIANT
     CALL "EM2-BABY-PARAMS" USING WS-VARIANT WS-SCALE-HEAD WS-YH WS-ZH EM2-BABY
     MOVE "default constructor values" TO WS-NAME
     COMPUTE WS-O = BB-SCALE-HEAD * 100000 + BB-Y-HEAD * 10000 + BB-Z-HEAD * 1000 + BB-HEAD-SCALE * 100 + BB-BODY-SCALE * 10 + BB-BODY-Y * 0.01
     COMPUTE WS-E = 0 + 5 * 10000 + 2 * 1000 + 2 * 100 + 2 * 10 + 24 * 0.01
     PERFORM CHECK-NUM
     CALL "EM2-BABY-MESH" USING EM2-MESH EM2-BABY WS-SET
     MOVE "without scaleHead the head factor is 1" TO WS-NAME
     COMPUTE WS-O = MH-Y(WS-HEAD) * 1000 + MH-Z(WS-HEAD) * 100 + MH-YSCALE(WS-HEAD)
     COMPUTE WS-E = 5 * 1000 + 2 * 100 + 1
     PERFORM CHECK-NUM
     MOVE "body of the default constructor" TO WS-NAME
     COMPUTE WS-O = MH-Y(WS-BODY) * 100 + MH-YSCALE(WS-BODY)
     COMPUTE WS-E = 12 * 100 + 0.5
     PERFORM CHECK-NUM
*>   (scaleHead, yHead, zHead, parts) constructor.
     MOVE 3 TO WS-VARIANT
     MOVE 1 TO WS-SCALE-HEAD
     MOVE 10 TO WS-YH
     MOVE 3 TO WS-ZH
     CALL "EM2-BABY-PARAMS" USING WS-VARIANT WS-SCALE-HEAD WS-YH WS-ZH EM2-BABY
     MOVE "four-argument constructor" TO WS-NAME
     COMPUTE WS-O = BB-SCALE-HEAD * 100000 + BB-Y-HEAD * 10000 + BB-Z-HEAD * 1000 + BB-HEAD-SCALE * 100 + BB-BODY-SCALE * 10 + BB-BODY-Y * 0.01
     COMPUTE WS-E = 100000 + 10 * 10000 + 3 * 1000 + 2 * 100 + 2 * 10 + 24 * 0.01
     PERFORM CHECK-NUM
*> 2.4 deformation constants.
     MOVE "fish_pattern" TO WS-KIND
     PERFORM CHECK-DEFORM-SINGLE
     MOVE 0.008 TO WS-E
     PERFORM CHECK-NUM
     MOVE "outer_armor" TO WS-KIND
     PERFORM CHECK-DEFORM-SINGLE
     MOVE 1 TO WS-E
     PERFORM CHECK-NUM
     MOVE "inner_armor" TO WS-KIND
     PERFORM CHECK-DEFORM-SINGLE
     MOVE 0.5 TO WS-E
     PERFORM CHECK-NUM
     MOVE "baby_outer_armor" TO WS-KIND
     CALL "EM2-DEFORM" USING WS-KIND WS-G
     MOVE "baby outer armor (-0.1, 0.5, 0.3)" TO WS-NAME
     COMPUTE WS-O = WS-GV(1) * 100 + WS-GV(2) * 10 + WS-GV(3)
     COMPUTE WS-E = -0.1 * 100 + 0.5 * 10 + 0.3
     PERFORM CHECK-NUM
     MOVE "baby_inner_armor" TO WS-KIND
     CALL "EM2-DEFORM" USING WS-KIND WS-G
     MOVE "baby inner armor (-0.1, 0.3, 0.3)" TO WS-NAME
     COMPUTE WS-O = WS-GV(1) * 100 + WS-GV(2) * 10 + WS-GV(3)
     COMPUTE WS-E = -0.1 * 100 + 0.3 * 10 + 0.3
     PERFORM CHECK-NUM
     MOVE "baby_piglin_inner" TO WS-KIND
     PERFORM CHECK-DEFORM-SINGLE
     MOVE 0.7 TO WS-E
     PERFORM CHECK-NUM
     MOVE "baby_piglin_outer" TO WS-KIND
     PERFORM CHECK-DEFORM-SINGLE
     PERFORM CHECK-NUM
     MOVE "piglin_inner" TO WS-KIND
     PERFORM CHECK-DEFORM-SINGLE
     MOVE 0.5 TO WS-E
     PERFORM CHECK-NUM
     MOVE "piglin_outer" TO WS-KIND
     PERFORM CHECK-DEFORM-SINGLE
     MOVE 1.02 TO WS-E
     PERFORM CHECK-NUM
     MOVE "baby_piglin_arm_offset" TO WS-KIND
     CALL "EM2-DEFORM" USING WS-KIND WS-G
     MOVE "baby piglin arm pose offset (0.5, -0.5, 0)" TO WS-NAME
     COMPUTE WS-O = WS-GV(1) * 100 + WS-GV(2) * 10 + WS-GV(3)
     COMPUTE WS-E = 50 - 5
     PERFORM CHECK-NUM
     MOVE "unknown" TO WS-KIND
     CALL "EM2-DEFORM" USING WS-KIND WS-G
     MOVE "unknown constant is none" TO WS-NAME
     COMPUTE WS-O = WS-GV(1) + WS-GV(2) + WS-GV(3)
     MOVE 0 TO WS-E
     PERFORM CHECK-NUM
*> 2.5 armor set ids.
     MOVE "zombie" TO WS-KIND
     MOVE 3 TO WS-SLOT
     CALL "EM2-ARMOR-ID" USING WS-KIND WS-SLOT WS-ID
     MOVE "armor set slot 3 is leggings" TO WS-NAME
     MOVE "minecraft:zombie#leggings" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-SLOT
     CALL "EM2-ARMOR-ID" USING WS-KIND WS-SLOT WS-ID
     MOVE "armor set slot 4 is boots" TO WS-NAME
     MOVE "minecraft:zombie#boots" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-SLOT
     CALL "EM2-ARMOR-ID" USING WS-KIND WS-SLOT WS-ID
     MOVE "armor set slot 1 is helmet" TO WS-NAME
     MOVE "minecraft:zombie#helmet" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-SLOT
     CALL "EM2-ARMOR-ID" USING WS-KIND WS-SLOT WS-ID
     MOVE "armor set slot 2 is chestplate" TO WS-NAME
     MOVE "minecraft:zombie#chestplate" TO TL-EXPECTED
     MOVE WS-ID TO TL-OBSERVED
     PERFORM CHECK-TEXT
     STOP RUN.

 BUILD-HUMANOID.
     CALL "EM2-MESH-INIT" USING EM2-MESH
     MOVE 1 TO WS-PARENT
     MOVE 1 TO WS-CUBES
     MOVE 0 TO WS-P(1) WS-P(2) WS-P(3) WS-P(4) WS-P(5) WS-P(6)
     MOVE 1 TO WS-P(7) WS-P(8) WS-P(9)
     MOVE "head" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-CUBES WS-POSE WS-HEAD
     MOVE "hat" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-HEAD WS-PNAME WS-CUBES WS-POSE WS-HAT
     MOVE "body" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-CUBES WS-POSE WS-BODY
     MOVE -5 TO WS-P(1)
     MOVE 2 TO WS-P(2)
     MOVE "right_arm" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-CUBES WS-POSE WS-ARM
     MOVE -1.9 TO WS-P(1)
     MOVE 12 TO WS-P(2)
     MOVE "right_leg" TO WS-PNAME
     CALL "EM2-ADD-CHILD" USING EM2-MESH WS-PARENT WS-PNAME WS-CUBES WS-POSE WS-LEG
     MOVE "head|hat" TO WS-SET
     MOVE "head" TO WS-SET.

 CHECK-FACTOR-0-9375.
     MOVE 0.9375 TO WS-E
     PERFORM CHECK-FACTOR.

 CHECK-FACTOR.
     CALL "EM2-SCALE-FACTOR" USING WS-LAYER WS-S
     MOVE SPACES TO WS-NAME
     STRING "factor of " FUNCTION TRIM(WS-LAYER) DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-S TO WS-O
     PERFORM CHECK-NUM.

 CHECK-DEFORM-SINGLE.
     CALL "EM2-DEFORM" USING WS-KIND WS-G
     MOVE SPACES TO WS-NAME
     STRING "deformation " FUNCTION TRIM(WS-KIND) " on every axis" DELIMITED BY SIZE INTO WS-NAME
     COMPUTE WS-O = WS-GV(1) + (WS-GV(2) - WS-GV(1)) * 1000 + (WS-GV(3) - WS-GV(1)) * 1000.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§2 Building a model: definitions, deformation, baby transform and scaling: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§2 Building a model: definitions, deformation, baby transform and scaling: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-1-2.
