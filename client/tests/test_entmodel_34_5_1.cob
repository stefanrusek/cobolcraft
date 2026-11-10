*> Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 1 (shared facts): 1.1 the table facts (MeshTransformer scaling users, PartPose scaling, texel to UV, baby selection and ageScale,
*> the shadow radius rule with the turtle exception, head look, the rotLerp quirk and rotLerpRad, the table Mth.sin and Mth.cos, the model-to-world frame), 1.2 the keyframe engine (sample index and fraction, walk time and scale, AnimationState
*> operations), 1.3 the quadruped base, 1.4 the dye colour table. Values are worked by an independent script from the formulas of the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-5-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.
 01 WS-LAYER              PIC X(32).
 01 WS-OK                 BINARY-LONG.
 01 WS-PARTS              BINARY-LONG.
 01 WS-CUBES              BINARY-LONG.
 01 WS-P                  BINARY-LONG.
 01 WS-PN                 PIC X(24).
 COPY EMCHKW.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-IV(1)
     CALL "EF5-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.1 Mth.sin(0) table value" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF5-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.1 Mth.cos(0) table value" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF5-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.1 Mth.sin(0.5) table value" TO WS-NAME
     MOVE 0.479409635 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF5-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.1 Mth.cos(0.5) table value" TO WS-NAME
     MOVE 0.877591252 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF5-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.1 Mth.sin(1) table value" TO WS-NAME
     MOVE 0.841451406 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF5-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.1 Mth.cos(1) table value" TO WS-NAME
     MOVE 0.540332854 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.5 TO WS-IV(1)
     CALL "EF5-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.1 Mth.sin(2.5) table value" TO WS-NAME
     MOVE 0.598544776 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.5 TO WS-IV(1)
     CALL "EF5-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.1 Mth.cos(2.5) table value" TO WS-NAME
     MOVE -0.801089346 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.14159 TO WS-IV(1)
     CALL "EF5-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.1 Mth.sin(3.14159) table value" TO WS-NAME
     MOVE 0.000095874 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.14159 TO WS-IV(1)
     CALL "EF5-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.1 Mth.cos(3.14159) table value" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.2 TO WS-IV(1)
     CALL "EF5-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.1 Mth.sin(-1.2) table value" TO WS-NAME
     MOVE -0.932023287 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.2 TO WS-IV(1)
     CALL "EF5-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.1 Mth.cos(-1.2) table value" TO WS-NAME
     MOVE 0.362308979 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF5-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.1 Mth.sin(10) table value" TO WS-NAME
     MOVE -0.543958068 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF5-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.1 Mth.cos(10) table value" TO WS-NAME
     MOVE -0.839112401 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100.3 TO WS-IV(1)
     CALL "EF5-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.1 Mth.sin(100.3) table value" TO WS-NAME
     MOVE -0.229005441 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100.3 TO WS-IV(1)
     CALL "EF5-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.1 Mth.cos(100.3) table value" TO WS-NAME
     MOVE 0.97342515 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -45.6 TO WS-IV(1)
     CALL "EF5-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.1 Mth.sin(-45.6) table value" TO WS-NAME
     MOVE -0.998901248 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -45.6 TO WS-IV(1)
     CALL "EF5-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.1 Mth.cos(-45.6) table value" TO WS-NAME
     MOVE -0.046865117 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cat" TO WS-X24
     CALL "EF5-MESH-SCALE" USING WS-X24 WS-IV(1)
     MOVE "1.1 mesh scaling factor of cat" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cat_collar" TO WS-X24
     CALL "EF5-MESH-SCALE" USING WS-X24 WS-IV(1)
     MOVE "1.1 mesh scaling factor of cat_collar" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cat_baby_collar" TO WS-X24
     CALL "EF5-MESH-SCALE" USING WS-X24 WS-IV(1)
     MOVE "1.1 mesh scaling factor of cat_baby_collar" TO WS-NAME
     MOVE 1.01 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "polar_bear" TO WS-X24
     CALL "EF5-MESH-SCALE" USING WS-X24 WS-IV(1)
     MOVE "1.1 mesh scaling factor of polar_bear" TO WS-NAME
     MOVE 1.2 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "wolf" TO WS-X24
     CALL "EF5-MESH-SCALE" USING WS-X24 WS-IV(1)
     MOVE "1.1 mesh scaling factor of wolf" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "panda" TO WS-X24
     CALL "EF5-MESH-SCALE" USING WS-X24 WS-IV(1)
     MOVE "1.1 mesh scaling factor of panda" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0.8 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE "1.1 root after scaling by 0.8 [1]" TO WS-NAME
     MOVE 4.8032 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 root after scaling by 0.8 [2]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1.2 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE "1.1 root after scaling by 1.2 [1]" TO WS-NAME
     MOVE -4.8032 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 root after scaling by 1.2 [2]" TO WS-NAME
     MOVE 1.2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1.01 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE "1.1 root after scaling by 1.01 [1]" TO WS-NAME
     MOVE -0.24016 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 root after scaling by 1.01 [2]" TO WS-NAME
     MOVE 1.01 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 2 TO WS-IV(7)
     MOVE 3 TO WS-IV(8)
     MOVE 4 TO WS-IV(9)
     CALL "EF5-POSE-SCALED" USING WS-IN WS-OUT
     MOVE "1.1 PartPose.scaled multiplies position and scale [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled multiplies position and scale [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled multiplies position and scale [3]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled multiplies position and scale [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled multiplies position and scale [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled multiplies position and scale [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE -2 TO WS-IV(1)
     MOVE 0.5 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0.5 TO WS-IV(7)
     MOVE 0.5 TO WS-IV(8)
     MOVE 2 TO WS-IV(9)
     CALL "EF5-POSE-SCALED" USING WS-IN WS-OUT
     MOVE "1.1 PartPose.scaled second case [1]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled second case [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled second case [3]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled second case [4]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled second case [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose.scaled second case [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 64 TO WS-IV(3)
     MOVE 64 TO WS-IV(4)
     CALL "EF5-TEXEL-UV" USING WS-IN WS-OUT
     MOVE "1.1 texel (0,0) in 64x64 is (U,V) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 texel (0,0) in 64x64 is (U,V) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 18 TO WS-IV(1)
     MOVE 14 TO WS-IV(2)
     MOVE 64 TO WS-IV(3)
     MOVE 32 TO WS-IV(4)
     CALL "EF5-TEXEL-UV" USING WS-IN WS-OUT
     MOVE "1.1 texel (18,14) in 64x32 is (U,V) [1]" TO WS-NAME
     MOVE 0.28125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 texel (18,14) in 64x32 is (U,V) [2]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE -2 TO WS-IV(1)
     MOVE -3 TO WS-IV(2)
     MOVE 16 TO WS-IV(3)
     MOVE 16 TO WS-IV(4)
     CALL "EF5-TEXEL-UV" USING WS-IN WS-OUT
     MOVE "1.1 texel (-2,-3) in 16x16 is (U,V) [1]" TO WS-NAME
     MOVE -0.125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 texel (-2,-3) in 16x16 is (U,V) [2]" TO WS-NAME
     MOVE -0.1875 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 30 TO WS-IV(1)
     MOVE 47 TO WS-IV(2)
     MOVE 128 TO WS-IV(3)
     MOVE 64 TO WS-IV(4)
     CALL "EF5-TEXEL-UV" USING WS-IN WS-OUT
     MOVE "1.1 texel (30,47) in 128x64 is (U,V) [1]" TO WS-NAME
     MOVE 0.234375 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 texel (30,47) in 128x64 is (U,V) [2]" TO WS-NAME
     MOVE 0.734375 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF5-AGE-SCALE" USING WS-IN WS-OUT
     MOVE "1.1 ageScale baby 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF5-AGE-SCALE" USING WS-IN WS-OUT
     MOVE "1.1 ageScale baby 1" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "wolf" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE 0.5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-SHADOW" USING WS-X24 WS-FL WS-IN WS-OUT
     MOVE "1.1 shadow radius wolf baby 0 radius 0.5 scale 1" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "wolf" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE 0.5 TO WS-IV(1)
     MOVE 1.5 TO WS-IV(2)
     CALL "EF5-SHADOW" USING WS-X24 WS-FL WS-IN WS-OUT
     MOVE "1.1 shadow radius wolf baby 1 radius 0.5 scale 1.5" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "turtle" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE 0.7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-SHADOW" USING WS-X24 WS-FL WS-IN WS-OUT
     MOVE "1.1 shadow radius turtle baby 0 radius 0.7 scale 1" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "turtle" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE 0.7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-SHADOW" USING WS-X24 WS-FL WS-IN WS-OUT
     MOVE "1.1 shadow radius turtle baby 1 radius 0.7 scale 1" TO WS-NAME
     MOVE 0.581 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "turtle" TO WS-X24
     MOVE 1 TO WS-FL
     MOVE 0.7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     CALL "EF5-SHADOW" USING WS-X24 WS-FL WS-IN WS-OUT
     MOVE "1.1 shadow radius turtle baby 1 radius 0.7 scale 2" TO WS-NAME
     MOVE 1.162 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bat" TO WS-X24
     MOVE 0 TO WS-FL
     MOVE 0.25 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-SHADOW" USING WS-X24 WS-FL WS-IN WS-OUT
     MOVE "1.1 shadow radius bat baby 0 radius 0.25 scale 1" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 50 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 20 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF5-HEAD-LOOK" USING WS-IN WS-OUT
     MOVE "1.1 head look yRot head 50 body 10 upside-down 0" TO WS-NAME
     MOVE 40 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -170 TO WS-IV(1)
     MOVE 170 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF5-HEAD-LOOK" USING WS-IN WS-OUT
     MOVE "1.1 head look yRot head -170 body 170 upside-down 0" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 30 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE -15 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF5-HEAD-LOOK" USING WS-IN WS-OUT
     MOVE "1.1 head look yRot head 30 body -30 upside-down 0" TO WS-NAME
     MOVE 60 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 200 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF5-HEAD-LOOK" USING WS-IN WS-OUT
     MOVE "1.1 head look yRot head 200 body 10 upside-down 0" TO WS-NAME
     MOVE -170 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 40 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF5-HEAD-LOOK" USING WS-IN WS-OUT
     MOVE "1.1 head look yRot head 40 body 10 upside-down 1" TO WS-NAME
     MOVE -30 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 0.2 TO WS-IV(2)
     MOVE 1.0 TO WS-IV(3)
     CALL "EF5-ROT-LERP" USING WS-IN WS-OUT
     MOVE "1.1 rotLerp t 0.5 0.2 to 1.0 (wrap in degrees)" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.25 TO WS-IV(1)
     MOVE -1 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF5-ROT-LERP" USING WS-IN WS-OUT
     MOVE "1.1 rotLerp t 0.25 -1 to 2 (wrap in degrees)" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 200 TO WS-IV(3)
     CALL "EF5-ROT-LERP" USING WS-IN WS-OUT
     MOVE "1.1 rotLerp t 0.5 0 to 200 (wrap in degrees)" TO WS-NAME
     MOVE -80.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.75 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE -170 TO WS-IV(3)
     CALL "EF5-ROT-LERP" USING WS-IN WS-OUT
     MOVE "1.1 rotLerp t 0.75 10 to -170 (wrap in degrees)" TO WS-NAME
     MOVE -125.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 359 TO WS-IV(3)
     CALL "EF5-ROT-LERP" USING WS-IN WS-OUT
     MOVE "1.1 rotLerp t 1 0 to 359 (wrap in degrees)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 0.2 TO WS-IV(2)
     MOVE 1.0 TO WS-IV(3)
     CALL "EF5-ROT-LERP-RAD" USING WS-IN WS-OUT
     MOVE "1.1 rotLerpRad t 0.5 0.2 to 1.0 (wrap to -pi..pi)" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF5-ROT-LERP-RAD" USING WS-IN WS-OUT
     MOVE "1.1 rotLerpRad t 0.5 0 to 5 (wrap to -pi..pi)" TO WS-NAME
     MOVE -0.641592654 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.25 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE -3 TO WS-IV(3)
     CALL "EF5-ROT-LERP-RAD" USING WS-IN WS-OUT
     MOVE "1.1 rotLerpRad t 0.25 3 to -3 (wrap to -pi..pi)" TO WS-NAME
     MOVE 3.070796327 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE -3 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF5-ROT-LERP-RAD" USING WS-IN WS-OUT
     MOVE "1.1 rotLerpRad t 0.5 -3 to 3 (wrap to -pi..pi)" TO WS-NAME
     MOVE -3.141592654 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 30 TO WS-IV(2)
     CALL "EF5-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [7]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [11]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [13]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [16]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 1 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 30 TO WS-IV(2)
     CALL "EF5-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [5]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [7]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [11]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [13]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [16]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 0.5 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 30 TO WS-IV(2)
     CALL "EF5-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [7]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [11]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [13]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [16]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 model-to-world frame for entity scale 2 (count, then code 1 translate 2 scale 3 rotate Y deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE -0.3 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=-0.3: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=-0.3: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=-0.3: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0.1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.1: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.1: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.1: i, j, f [3]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0.3 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.3: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.3: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.3: i, j, f [3]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0.5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.5: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.5: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.5: i, j, f [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0.75 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.75: i, j, f [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.75: i, j, f [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=0.75: i, j, f [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1.0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=1.0: i, j, f [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=1.0: i, j, f [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=1.0: i, j, f [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2.0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=2.0: i, j, f [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=2.0: i, j, f [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.5, 1] sampled at t=2.0: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE -0.3 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0.5 TO WS-IV(5)
     MOVE 1.5 TO WS-IV(6)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=-0.3: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=-0.3: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=-0.3: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0.5 TO WS-IV(5)
     MOVE 1.5 TO WS-IV(6)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0.1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0.5 TO WS-IV(5)
     MOVE 1.5 TO WS-IV(6)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.1: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.1: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.1: i, j, f [3]" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0.3 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0.5 TO WS-IV(5)
     MOVE 1.5 TO WS-IV(6)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.3: i, j, f [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.3: i, j, f [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.3: i, j, f [3]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0.5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0.5 TO WS-IV(5)
     MOVE 1.5 TO WS-IV(6)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.5: i, j, f [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.5: i, j, f [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.5: i, j, f [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0.75 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0.5 TO WS-IV(5)
     MOVE 1.5 TO WS-IV(6)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.75: i, j, f [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.75: i, j, f [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=0.75: i, j, f [3]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 1.0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0.5 TO WS-IV(5)
     MOVE 1.5 TO WS-IV(6)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=1.0: i, j, f [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=1.0: i, j, f [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=1.0: i, j, f [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 2.0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0.5 TO WS-IV(5)
     MOVE 1.5 TO WS-IV(6)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=2.0: i, j, f [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=2.0: i, j, f [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0, 0.25, 0.5, 1.5] sampled at t=2.0: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE -0.3 TO WS-IV(2)
     MOVE 0.1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=-0.3: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=-0.3: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=-0.3: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0.1 TO WS-IV(2)
     MOVE 0.1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.1: i, j, f [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.1: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.1: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0.3 TO WS-IV(2)
     MOVE 0.1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.3: i, j, f [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.3: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.3: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0.5 TO WS-IV(2)
     MOVE 0.1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.5: i, j, f [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.5: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.5: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0.75 TO WS-IV(2)
     MOVE 0.1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.75: i, j, f [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.75: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=0.75: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1.0 TO WS-IV(2)
     MOVE 0.1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=1.0: i, j, f [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=1.0: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=1.0: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 2.0 TO WS-IV(2)
     MOVE 0.1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     CALL "EF5-KF-INDEX" USING WS-IN WS-OUT
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=2.0: i, j, f [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=2.0: i, j, f [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 keyframes [0.1, 0.2] sampled at t=2.0: i, j, f [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0.5 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 2.5 TO WS-IV(4)
     CALL "EF5-WALK-TIME" USING WS-IN WS-OUT
     MOVE "1.2 applyWalk pos 2 speed 0.5 factors 2 2.5: seconds and k [1]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 applyWalk pos 2 speed 0.5 factors 2 2.5: seconds and k [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.5 TO WS-IV(1)
     MOVE 0.2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     CALL "EF5-WALK-TIME" USING WS-IN WS-OUT
     MOVE "1.2 applyWalk pos 1.5 speed 0.2 factors 1 3: seconds and k [1]" TO WS-NAME
     MOVE 0.075 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 applyWalk pos 1.5 speed 0.2 factors 1 3: seconds and k [2]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.75 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     CALL "EF5-WALK-TIME" USING WS-IN WS-OUT
     MOVE "1.2 applyWalk pos 0.75 speed 1 factors 2 2: seconds and k [1]" TO WS-NAME
     MOVE 0.075 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 applyWalk pos 0.75 speed 1 factors 2 2: seconds and k [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     MOVE 0.25 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 2.5 TO WS-IV(4)
     CALL "EF5-WALK-TIME" USING WS-IN WS-OUT
     MOVE "1.2 applyWalk pos 10 speed 0.25 factors 2 2.5: seconds and k [1]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 applyWalk pos 10 speed 0.25 factors 2 2.5: seconds and k [2]" TO WS-NAME
     MOVE 0.625 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     CALL "EF5-WALK-TIME" USING WS-IN WS-OUT
     MOVE "1.2 applyWalk pos 0 speed 0 factors 2 2: seconds and k [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 applyWalk pos 0 speed 0 factors 2 2: seconds and k [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE -2147483648 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState start [1]" TO WS-NAME
     MOVE 40 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState start [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState restart [1]" TO WS-NAME
     MOVE 40 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState restart [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE -2147483648 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState startIfStopped stopped [1]" TO WS-NAME
     MOVE 40 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState startIfStopped stopped [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState startIfStopped started [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState startIfStopped started [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState stop [1]" TO WS-NAME
     MOVE -2147483648 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState stop [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE -2147483648 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState animateWhen false [1]" TO WS-NAME
     MOVE -2147483648 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState animateWhen false [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE -2147483648 TO WS-IV(2)
     MOVE 55 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState animateWhen true from stopped [1]" TO WS-NAME
     MOVE 55 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState animateWhen true from stopped [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 55 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState animateWhen true started [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState animateWhen true started [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 100 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 10 TO WS-IV(4)
     MOVE 1.5 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState fastForward [1]" TO WS-NAME
     MOVE 85 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState fastForward [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE -2147483648 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 10 TO WS-IV(4)
     MOVE 1.5 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState fastForward stopped [1]" TO WS-NAME
     MOVE -2147483648 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState fastForward stopped [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 30.5 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF5-ANIM-STATE" USING WS-IN WS-OUT
     MOVE "1.2 AnimationState elapsed ms [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 AnimationState elapsed ms [2]" TO WS-NAME
     MOVE 1025 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 12 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.6 TO WS-IV(4)
     CALL "EF5-QUAD-POSE" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 12 pos 2.5 head.xrot" TO WS-NAME
     MOVE 0.209439504 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 12 pos 2.5 head.yrot" TO WS-NAME
     MOVE -0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 12 pos 2.5 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 12 pos 2.5 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 12 pos 2.5 right_front_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 12 pos 2.5 left_front_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF5-QUAD-POSE" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 0 pos 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 0 pos 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 0 pos 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 0 pos 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 0 pos 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch 0 pos 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -45 TO WS-IV(1)
     MOVE 80 TO WS-IV(2)
     MOVE 7.25 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF5-QUAD-POSE" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch -45 pos 7.25 head.xrot" TO WS-NAME
     MOVE -0.78539814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch -45 pos 7.25 head.yrot" TO WS-NAME
     MOVE 1.39626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch -45 pos 7.25 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch -45 pos 7.25 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch -45 pos 7.25 right_front_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.3 pitch -45 pos 7.25 left_front_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 0 opaque texture diffuse colour" TO WS-NAME
     MOVE 4294574078 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 1 opaque texture diffuse colour" TO WS-NAME
     MOVE 4294541341 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 2 opaque texture diffuse colour" TO WS-NAME
     MOVE 4291251901 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 3 opaque texture diffuse colour" TO WS-NAME
     MOVE 4282037210 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 4 opaque texture diffuse colour" TO WS-NAME
     MOVE 4294891581 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 5 opaque texture diffuse colour" TO WS-NAME
     MOVE 4286629663 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 6 opaque texture diffuse colour" TO WS-NAME
     MOVE 4294151082 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 7 opaque texture diffuse colour" TO WS-NAME
     MOVE 4282863442 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 8 opaque texture diffuse colour" TO WS-NAME
     MOVE 4288519575 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 9 opaque texture diffuse colour" TO WS-NAME
     MOVE 4279671964 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 10 opaque texture diffuse colour" TO WS-NAME
     MOVE 4287181496 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 11 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 11 opaque texture diffuse colour" TO WS-NAME
     MOVE 4282139818 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 12 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 12 opaque texture diffuse colour" TO WS-NAME
     MOVE 4286796850 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 13 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 13 opaque texture diffuse colour" TO WS-NAME
     MOVE 4284382230 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 14 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 14 opaque texture diffuse colour" TO WS-NAME
     MOVE 4289736230 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     CALL "EF5-DYE-RGB" USING WS-IN WS-OUT
     MOVE "1.4 dye 15 opaque texture diffuse colour" TO WS-NAME
     MOVE 4280098081 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-5§1 Shared facts used by every model below: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-5§1 Shared facts used by every model below: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-5-1.
