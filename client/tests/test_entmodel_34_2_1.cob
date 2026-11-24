*> Acceptance test of docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md section 1 (Shared pieces): 1.1 pose application, 1.2 the base
*> humanoid mesh, 1.3 the mesh transformers (worked examples 8 and 9 numbers), 1.4 the armor mesh sets, 1.5 the equipment layer rules, 1.6 held item and head
*> layers and 1.6.1 the skull models. Expected values are the document's tables and worked examples.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-2-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY CLEM1.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-PN                  PIC X(24).
 01 WS-PARTS               BINARY-LONG.
 01 WS-CUBES               BINARY-LONG.
 01 WS-PT.
    05 WS-PV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PO.
    05 WS-POV              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-SLOT                BINARY-LONG.
 01 WS-INNER               FLOAT-LONG.
 01 WS-OUTER               FLOAT-LONG.
 01 WS-GT.
    05 WS-GV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-OFF.
    05 WS-OV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-TYPE                PIC X(20).
 01 WS-BABY                BINARY-LONG.
 01 WS-STAND               BINARY-LONG.
 01 WS-PATH                PIC X(40).
 01 WS-TEXT                PIC X(100).
 01 WS-POS                 BINARY-LONG.
 01 WS-SLOT2               BINARY-LONG.
 01 WS-STYPE               PIC X(16).
 01 WS-LAYER               PIC X(22).
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-KIND                PIC X(10).
 01 WS-TEX                 PIC X(67).
 01 WS-FAMILY              PIC X(8).
 01 WS-TR.
    05 WS-TRV              FLOAT-LONG OCCURS 4 TIMES.
 01 WS-IN4.
    05 WS-I4               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-ROWTXT              PIC X(100).
 01 WS-C                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-SET                 PIC X(120).
 PROCEDURE DIVISION.
*> 1.2 base mesh, grow 0, y offset 0
     MOVE 0 TO WS-G WS-Y
     CALL "EMD-HUMANOID" USING EMM-MODEL WS-G WS-Y
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "seven parts, seven cuboids (zombie count of 9.4)" TO WS-NAME
     COMPUTE WS-O = WS-PARTS * 10 + WS-CUBES
     MOVE 77 TO WS-E
     PERFORM CHECK-NUM
     MOVE "texture size 64 x 64" TO WS-NAME
     COMPUTE WS-O = MM-TEXW * 100 + MM-TEXH
     MOVE 6464 TO WS-E
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right leg pivot (-1.9, 12, 0), tex (0, 16), box (-2, 0, -2) 4 x 12 x 4, not mirrored" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 10000 + MM-Y(WS-P) * 100 + MC-V(WS-P, 1) + MC-OX(WS-P, 1) * 0.1 + MC-H(WS-P, 1) * 0.001 + MC-MIRROR(WS-P, 1) * 0.0001
     COMPUTE WS-E = -1.9 * 10000 + 12 * 100 + 16 + -2 * 0.1 + 12 * 0.001
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left leg mirrors the right limb region" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 10 + MC-U(WS-P, 1) * 0.001 + MC-MIRROR(WS-P, 1)
     COMPUTE WS-E = 19 + 1
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left arm (5, 2, 0) box (-1, -2, -2) tex (40, 16) mirrored" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 10000 + MM-Y(WS-P) * 100 + MC-OX(WS-P, 1) * 10 + MC-U(WS-P, 1) * 0.01 + MC-MIRROR(WS-P, 1)
     COMPUTE WS-E = 50000 + 200 + -10 + 0.4 + 1
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right arm box (-3, -2, -2) tex (40, 16)" TO WS-NAME
     COMPUTE WS-O = MC-OX(WS-P, 1) * 10 + MC-U(WS-P, 1) * 0.01 + MC-V(WS-P, 1) * 0.0001
     COMPUTE WS-E = -30 + 0.4 + 0.0016
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "hat grows by 0.5 when grow is 0" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat tex (32, 0)" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MC-U(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.25 TO WS-G
     MOVE 3 TO WS-Y
     CALL "EMD-HUMANOID" USING EMM-MODEL WS-G WS-Y
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "grow 0.25 applies to the head cuboid" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE MC-GY(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "y offset 3 lifts the head pivot" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE MM-Y(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "the hat keeps its pivot y 0 and grows 0.75" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) * 10 + MC-GZ(WS-P, 1)
     MOVE 0.75 TO WS-E
     PERFORM CHECK-NUM
*> model rows: T sets the texture size, X empties a part, P takes a pose scale; EMM-CUBE-IN hands a cuboid to the baker.
     MOVE 0 TO WS-G WS-Y
     CALL "EMD-HUMANOID" USING EMM-MODEL WS-G WS-Y
     MOVE 0 TO WS-GV(1) WS-GV(2) WS-GV(3)
     MOVE "T 128 96" TO WS-ROWTXT
     CALL "EMM-ROW" USING EMM-MODEL WS-ROWTXT WS-GT
     MOVE "row T sets the texture size" TO WS-NAME
     COMPUTE WS-O = MM-TEXW * 1000 + MM-TEXH
     COMPUTE WS-E = 128096
     PERFORM CHECK-NUM
     MOVE "X hat" TO WS-ROWTXT
     CALL "EMM-ROW" USING EMM-MODEL WS-ROWTXT WS-GT
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "row X empties a part's cuboids (clearChild)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P tail root 1 2 3 0 0 0 2 3 4" TO WS-ROWTXT
     CALL "EMM-ROW" USING EMM-MODEL WS-ROWTXT WS-GT
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "row P with a scale sets the pose scale" TO WS-NAME
     COMPUTE WS-O = MM-XSCALE(WS-P) * 100 + MM-YSCALE(WS-P) * 10 + MM-ZSCALE(WS-P)
     COMPUTE WS-E = 234
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE 1 TO WS-C
     CALL "EMM-CUBE-IN" USING EMM-MODEL WS-P WS-C EM1-CUBE-IN
     CALL "EM1-CUBE" USING EM1-CUBE-IN EM1-CUBE-OUT
     MOVE "the head cuboid bakes to six faces over the model texture" TO WS-NAME
     COMPUTE WS-O = EF-COUNT * 1000 + EF-MAXU(4)
     COMPUTE WS-E = 6000 + 16
     PERFORM CHECK-NUM
*> 1.1 pose application through the chain: a head turned 90 degrees about Z at (0, 2, 0); the point (1, 0, 0) px of the hat lands at (0, 3, 0) px.
     MOVE 0 TO WS-G WS-Y
     CALL "EMD-HUMANOID" USING EMM-MODEL WS-G WS-Y
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE 2 TO MM-CY(WS-P)
     COMPUTE MM-CZROT(WS-P) = 3.141592653589793 / 2
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE 1 TO WS-PV(1)
     MOVE 0 TO WS-PV(2) WS-PV(3)
     CALL "EMM-CHAIN-POINT" USING EMM-MODEL WS-P WS-PT WS-PO
     MOVE "chain point of the hat through the head pose" TO WS-NAME
     COMPUTE WS-O = WS-POV(1) * 10000 + WS-POV(2) * 100 + WS-POV(3)
     COMPUTE WS-E = 0 * 10000 + 3 / 16 * 100 + 0
     PERFORM CHECK-NUM
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "resetPose restores the initial pose" TO WS-NAME
     COMPUTE WS-O = MM-CY(WS-P) + MM-CZROT(WS-P)
     MOVE 0 TO WS-E
     PERFORM CHECK-NUM
*> 1.3 scaling constants (worked example 8)
     MOVE 6 TO WS-S
     PERFORM SCALED
     MOVE "giant head pivot (0, -120.08, 0) scale 6" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) * 10 + MM-YSCALE(WS-P)
     COMPUTE WS-E = -1200.8 + 6
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "giant leg pivot y -48.08, foot line 23.92" TO WS-NAME
     MOVE MM-Y(WS-P) TO WS-O
     COMPUTE WS-E = -48.08
     PERFORM CHECK-NUM
     COMPUTE WS-O = MM-Y(WS-P) + 12 * MM-YSCALE(WS-P)
     MOVE 23.92 TO WS-E
     PERFORM CHECK-NUM
     MOVE 1.0625 TO WS-S
     PERFORM SCALED
     MOVE "husk head pivot -1.501" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE MM-Y(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "husk leg pivot 11.249, foot line 23.999" TO WS-NAME
     MOVE 11.249 TO WS-E
     MOVE MM-Y(WS-P) TO WS-O
     PERFORM CHECK-NUM
     COMPUTE WS-O = MM-Y(WS-P) + 12 * MM-YSCALE(WS-P)
     MOVE 23.999 TO WS-E
     PERFORM CHECK-NUM
     MOVE 1.2 TO WS-S
     PERFORM SCALED
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "wither skeleton leg pivot 9.5968, foot line 23.9968" TO WS-NAME
     MOVE 9.5968 TO WS-E
     MOVE MM-Y(WS-P) TO WS-O
     PERFORM CHECK-NUM
     COMPUTE WS-O = MM-Y(WS-P) + 12 * MM-YSCALE(WS-P)
     MOVE 23.9968 TO WS-E
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "only direct children of the root are scaled (hat untouched)" TO WS-NAME
     COMPUTE WS-O = MM-XSCALE(WS-P) * 10 + MM-Y(WS-P)
     MOVE 10 TO WS-E
     PERFORM CHECK-NUM
*> 1.3 baby transform
     MOVE 0 TO WS-G WS-Y
     CALL "EMD-HUMANOID" USING EMM-MODEL WS-G WS-Y
     CALL "EMD-BABY" USING EMM-MODEL
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "baby head (0, 12, 0) scale 0.75" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) * 100 + MM-YSCALE(WS-P)
     COMPUTE WS-E = 1200 + 0.75
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "baby leg (-0.95, 18, 0) scale 0.5, ends at 24" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 10000 + MM-Y(WS-P) * 100 + MM-YSCALE(WS-P) + (MM-Y(WS-P) + 12 * MM-YSCALE(WS-P)) * 0.001
     COMPUTE WS-E = -9500 + 1800 + 0.5 + 24 * 0.001
     PERFORM CHECK-NUM
*> 1.4 armor sets: grows and retained parts
     MOVE 0.5 TO WS-INNER
     MOVE 1.0 TO WS-OUTER
     MOVE 1 TO WS-SLOT
     CALL "EMD-ARMOR-SET" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "helmet keeps head and hat only" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "helmet head grow 1.0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "helmet hat grow 1.5" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "armor sets are 64 x 32" TO WS-NAME
     COMPUTE WS-O = MM-TEXW * 100 + MM-TEXH
     MOVE 6432 TO WS-E
     PERFORM CHECK-NUM
     MOVE 2 TO WS-SLOT
     CALL "EMD-ARMOR-SET" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "chestplate keeps body and both arms" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "chestplate body grow 1.0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-SLOT
     CALL "EMD-ARMOR-SET" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "leggings keep both legs and the body" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "leggings body grow 0.5 (inner)" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "leggings leg grow 0.4" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-SLOT
     CALL "EMD-ARMOR-SET" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "boots keep both legs only" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "boots leg grow 0.9, mirrored left leg" TO WS-NAME
     COMPUTE WS-O = MC-GX(WS-P, 1) * 10 + MC-MIRROR(WS-P, 1)
     COMPUTE WS-E = 9 + 1
     PERFORM CHECK-NUM
*>   baby armor mesh (64 x 64) with the baby zombie grow triple
     MOVE -0.1 TO WS-GV(1)
     MOVE 0.5 TO WS-GV(2)
     MOVE 0.3 TO WS-GV(3)
     MOVE 0 TO WS-OV(1) WS-OV(2) WS-OV(3)
     MOVE 3 TO WS-SLOT
     CALL "EMD-BABY-ARMOR" USING EMM-MODEL WS-SLOT WS-GT WS-OFF
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "baby leggings keep left leg, right leg and waist" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "waist" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "waist tex (0, 36) size 5.9 x 2 x 2.9 grow y 0.4 (0.5 - 0.1)" TO WS-NAME
     COMPUTE WS-O = MC-V(WS-P, 1) * 1000 + MC-W(WS-P, 1) * 10 + MC-GY(WS-P, 1)
     COMPUTE WS-E = 36000 + 59 + 0.4
     PERFORM CHECK-NUM
     MOVE "baby armor 64 x 64" TO WS-NAME
     COMPUTE WS-O = MM-TEXW * 100 + MM-TEXH
     MOVE 6464 TO WS-E
     PERFORM CHECK-NUM
     MOVE 4 TO WS-SLOT
     CALL "EMD-BABY-ARMOR" USING EMM-MODEL WS-SLOT WS-GT WS-OFF
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "baby boots keep the two feet" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_foot" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left foot tex (0, 29) mirrored box (-1, 2.9, -2) 3 x 1 x 3" TO WS-NAME
     COMPUTE WS-O = MC-V(WS-P, 1) * 1000 + MC-OY(WS-P, 1) * 10 + MC-MIRROR(WS-P, 1)
     COMPUTE WS-E = 29000 + 29 + 1
     PERFORM CHECK-NUM
     MOVE 1 TO WS-SLOT
     CALL "EMD-BABY-ARMOR" USING EMM-MODEL WS-SLOT WS-GT WS-OFF
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "baby helmet keeps the head" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-SLOT
     MOVE 0.5 TO WS-OV(1)
     MOVE -0.5 TO WS-OV(2)
     CALL "EMD-BABY-ARMOR" USING EMM-MODEL WS-SLOT WS-GT WS-OFF
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "baby piglin arm offset moves the right arm to (-4, 15, 0)" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 10000 + MM-Y(WS-P) * 100 + MM-Z(WS-P)
     COMPUTE WS-E = -40000 + 1500
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "and the left arm to (4, 15, 0)" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 10000 + MM-Y(WS-P) * 100 + MM-Z(WS-P)
     COMPUTE WS-E = 40000 + 1500
     PERFORM CHECK-NUM
*> 1.5 equipment layers
     MOVE 1 TO WS-BABY
     MOVE 0 TO WS-STAND
     MOVE 3 TO WS-SLOT
     CALL "EMD-LAYER-TYPE" USING WS-BABY WS-STAND WS-SLOT WS-TYPE
     MOVE "a baby uses humanoid_baby" TO WS-NAME
     MOVE "humanoid_baby" TO TL-EXPECTED
     MOVE WS-TYPE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-STAND
     CALL "EMD-LAYER-TYPE" USING WS-BABY WS-STAND WS-SLOT WS-TYPE
     MOVE "a small stand's legs use humanoid_leggings" TO WS-NAME
     MOVE "humanoid_leggings" TO TL-EXPECTED
     MOVE WS-TYPE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-BABY
     MOVE 2 TO WS-SLOT
     CALL "EMD-LAYER-TYPE" USING WS-BABY WS-STAND WS-SLOT WS-TYPE
     MOVE "an adult chest piece uses humanoid" TO WS-NAME
     MOVE "humanoid" TO TL-EXPECTED
     MOVE WS-TYPE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "humanoid_leggings" TO WS-TYPE
     MOVE "diamond" TO WS-PATH
     CALL "EMD-EQUIP-TEXTURE" USING WS-TYPE WS-PATH WS-TEXT
     MOVE "equipment texture path" TO WS-NAME
     MOVE "textures/entity/equipment/humanoid_leggings/diamond.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "humanoid" TO WS-TYPE
     MOVE "sentry" TO WS-PATH
     CALL "EMD-TRIM-TEXTURE" USING WS-TYPE WS-PATH WS-TEXT
     MOVE "trim texture id" TO WS-NAME
     MOVE "trims/entity/humanoid/sentry" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "humanoid_baby" TO WS-TYPE
     CALL "EMD-TRIM-TEXTURE" USING WS-TYPE WS-PATH WS-TEXT
     MOVE "the baby layer type has no trim" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "draw order chest, legs, feet, head" TO WS-NAME
     MOVE 0 TO WS-E
     PERFORM VARYING WS-POS FROM 1 BY 1 UNTIL WS-POS > 4
         CALL "EMD-DRAW-SLOT" USING WS-POS WS-SLOT2
         COMPUTE WS-E = WS-E * 10 + WS-SLOT2
     END-PERFORM
     MOVE WS-E TO WS-O
     MOVE 2341 TO WS-E
     PERFORM CHECK-NUM
     MOVE 5 TO WS-POS
     CALL "EMD-DRAW-SLOT" USING WS-POS WS-SLOT2
     MOVE "no fifth piece" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-SLOT2 TO WS-O
     PERFORM CHECK-NUM
*> 1.6 head transforms
     MOVE "default" TO WS-FAMILY
     CALL "EMD-HEAD-TRANSFORM" USING WS-FAMILY WS-TR
     MOVE "default head transform (0, 0, 1, 1)" TO WS-NAME
     COMPUTE WS-O = WS-TRV(3) * 10 + WS-TRV(4)
     MOVE 11 TO WS-E
     PERFORM CHECK-NUM
     MOVE "piglin" TO WS-FAMILY
     CALL "EMD-HEAD-TRANSFORM" USING WS-FAMILY WS-TR
     MOVE "piglin head transform scales x and z by 1.0019531" TO WS-NAME
     MOVE 1.0019531 TO WS-E
     MOVE WS-TRV(3) TO WS-O
     PERFORM CHECK-NUM
*> 1.6.1 skull table, meshes and animation
     MOVE "skeleton" TO WS-STYPE
     CALL "EMD-SKULL" USING WS-STYPE WS-LAYER WS-W WS-H WS-KIND WS-TEX
     MOVE "skeleton skull layer" TO WS-NAME
     MOVE "SKELETON_SKULL" TO TL-EXPECTED
     MOVE WS-LAYER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "skeleton skull is 64 x 32 with the mob head" TO WS-NAME
     COMPUTE WS-O = WS-W * 100 + WS-H
     MOVE 6432 TO WS-E
     PERFORM CHECK-NUM
     MOVE "mob" TO TL-EXPECTED
     MOVE WS-KIND TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "textures/entity/skeleton/skeleton.png" TO TL-EXPECTED
     MOVE WS-TEX TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "piglin" TO WS-STYPE
     CALL "EMD-SKULL" USING WS-STYPE WS-LAYER WS-W WS-H WS-KIND WS-TEX
     MOVE "piglin skull uses PiglinHeadModel" TO WS-NAME
     MOVE "piglin" TO TL-EXPECTED
     MOVE WS-KIND TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie" TO WS-STYPE
     CALL "EMD-SKULL" USING WS-STYPE WS-LAYER WS-W WS-H WS-KIND WS-TEX
     MOVE "zombie skull is a 64 x 64 humanoid head" TO WS-NAME
     MOVE "humanoid" TO TL-EXPECTED
     MOVE WS-KIND TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wither_skeleton" TO WS-STYPE
     CALL "EMD-SKULL" USING WS-STYPE WS-LAYER WS-W WS-H WS-KIND WS-TEX
     MOVE "wither skeleton skull layer" TO WS-NAME
     MOVE "WITHER_SKELETON_SKULL" TO TL-EXPECTED
     MOVE WS-LAYER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "creeper" TO WS-STYPE
     CALL "EMD-SKULL" USING WS-STYPE WS-LAYER WS-W WS-H WS-KIND WS-TEX
     MOVE "creeper head layer" TO WS-NAME
     MOVE "CREEPER_HEAD" TO TL-EXPECTED
     MOVE WS-LAYER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "player" TO WS-STYPE
     CALL "EMD-SKULL" USING WS-STYPE WS-LAYER WS-W WS-H WS-KIND WS-TEX
     MOVE "player head layer" TO WS-NAME
     MOVE "PLAYER_HEAD" TO TL-EXPECTED
     MOVE WS-LAYER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "dragon" TO WS-STYPE
     CALL "EMD-SKULL" USING WS-STYPE WS-LAYER WS-W WS-H WS-KIND WS-TEX
     MOVE "dragon skull is out of scope (kind dragon, size 0)" TO WS-NAME
     MOVE "dragon" TO TL-EXPECTED
     MOVE WS-KIND TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "ghast" TO WS-STYPE
     CALL "EMD-SKULL" USING WS-STYPE WS-LAYER WS-W WS-H WS-KIND WS-TEX
     MOVE "an unknown skull type has nothing" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-LAYER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "mob" TO WS-KIND
     CALL "EMD-SKULL-MESH" USING EMM-MODEL WS-KIND
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "mob head mesh: one part, one cuboid, 64 x 32" TO WS-NAME
     COMPUTE WS-O = WS-PARTS * 1000 + WS-CUBES * 100 + MM-TEXH
     COMPUTE WS-E = 1000 + 100 + 32
     PERFORM CHECK-NUM
     MOVE "humanoid" TO WS-KIND
     CALL "EMD-SKULL-MESH" USING EMM-MODEL WS-KIND
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "humanoid head mesh: head and hat, two cuboids" TO WS-NAME
     COMPUTE WS-O = WS-PARTS * 10 + WS-CUBES
     MOVE 22 TO WS-E
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "humanoid skull hat grow 0.25" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "piglin" TO WS-KIND
     CALL "EMD-SKULL-MESH" USING EMM-MODEL WS-KIND
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "piglin head mesh: head with 4 cuboids plus two ears, no hat" TO WS-NAME
     COMPUTE WS-O = WS-PARTS * 10 + WS-CUBES
     MOVE 36 TO WS-E
     PERFORM CHECK-NUM
     MOVE "left_ear" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "piglin left ear (4.5, -6, 0) rotated z -0.5235988" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 100000 + MM-Y(WS-P) * 1000 + MM-ZROT(WS-P)
     COMPUTE WS-E = 450000 - 6000 - 0.5235988
     PERFORM CHECK-NUM
     MOVE 20 TO WS-I4(1)
     MOVE 10 TO WS-I4(2)
     MOVE 0 TO WS-I4(3) WS-I4(4)
     CALL "EMD-SKULL-ANIM" USING EMM-MODEL WS-IN4
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "skull head rotation is state degrees x 0.017453292" TO WS-NAME
     COMPUTE WS-O = MM-CYROT(WS-P) * 100 + MM-CXROT(WS-P)
     COMPUTE WS-E = 20 * 0.017453292 * 100 + 10 * 0.017453292
     PERFORM CHECK-NUM
     MOVE 0 TO WS-I4(1) WS-I4(2) WS-I4(3)
     MOVE 1 TO WS-I4(4)
     CALL "EMD-SKULL-ANIM" USING EMM-MODEL WS-IN4
     MOVE "left_ear" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "piglin ear flap at q = 0 gives -0.7 and +0.7" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_ear" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE 0.7 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.5 TO WS-I4(3)
     CALL "EMD-SKULL-ANIM" USING EMM-MODEL WS-IN4
     MOVE "left_ear" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "ear flap at animation pos 2.5: q = 0.5 pi" TO WS-NAME
     COMPUTE WS-E = -(FUNCTION COS(2.5 * 3.141592653589793 * 0.2 * 1.2) + 2.5) * 0.2
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 SCALED.
     MOVE 0 TO WS-G WS-Y
     CALL "EMD-HUMANOID" USING EMM-MODEL WS-G WS-Y
     CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§1 Shared pieces: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 10000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§1 Shared pieces: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-2-1.
