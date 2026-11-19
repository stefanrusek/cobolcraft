*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md sections 7 and 8: the arguments of ThrownItemRenderer for each type (the 1.1 table and Validation 2), the block light of a full bright item, the quad of the flat item model with
*> the scale and the firework's rotations, the fishing hook's quad (8 step 1), the fishing line vertices and normals (8 step 2, Validation 7), the swing factor, the holding arm and the hand position of the third person (the table sine and cosine of 34-9 section 2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-7.
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
 01 WS-KEY               PIC X(24).
 PROCEDURE DIVISION.
     MOVE "snowball" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 snowball is a thrown item" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 snowball scale" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 snowball full bright" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "egg" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 egg is a thrown item" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 egg scale" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 egg full bright" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ender_pearl" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 ender_pearl is a thrown item" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 ender_pearl scale" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 ender_pearl full bright" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "splash_potion" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 splash_potion is a thrown item" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 splash_potion scale" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 splash_potion full bright" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "lingering_potion" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 lingering_potion is a thrown item" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 lingering_potion scale" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 lingering_potion full bright" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "experience_bottle" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 experience_bottle is a thrown item" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 experience_bottle scale" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 experience_bottle full bright" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eye_of_ender" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 eye_of_ender is a thrown item" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 eye_of_ender scale" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 eye_of_ender full bright" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "fireball" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 fireball is a thrown item" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 fireball scale" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 fireball full bright" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "small_fireball" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 small_fireball is a thrown item" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 small_fireball scale" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 small_fireball full bright" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "pig" TO WS-KEY
     CALL "EF9-THROWN" USING WS-KEY WS-OUT
     MOVE "1.1 a pig is not a thrown item" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-THROWN-LIGHT" USING WS-IN WS-OUT
     MOVE "7.1 block light 0 full bright 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-THROWN-LIGHT" USING WS-IN WS-OUT
     MOVE "7.1 block light 7 full bright 0" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-THROWN-LIGHT" USING WS-IN WS-OUT
     MOVE "7.1 block light 7 full bright 1" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-THROWN-LIGHT" USING WS-IN WS-OUT
     MOVE "7.1 block light 15 full bright 0" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-THROWN-LIGHT" USING WS-IN WS-OUT
     MOVE "7.1 block light 0 full bright 1" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-THROWN-QUAD" USING WS-IN WS-OUT
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [1]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [2]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [4]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [5]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [7]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [8]" TO WS-NAME
     MOVE -0.125 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [10]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [11]" TO WS-NAME
     MOVE -0.125 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 0 (12 corner values) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-THROWN-QUAD" USING WS-IN WS-OUT
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [1]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [3]" TO WS-NAME
     MOVE -0.375 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [4]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [5]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [6]" TO WS-NAME
     MOVE -0.375 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [7]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [8]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [9]" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [10]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [11]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 1 shot at an angle 1 (12 corner values) [12]" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-THROWN-QUAD" USING WS-IN WS-OUT
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [1]" TO WS-NAME
     MOVE -0.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [2]" TO WS-NAME
     MOVE 1.125 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [4]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [5]" TO WS-NAME
     MOVE 1.125 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [7]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [8]" TO WS-NAME
     MOVE -0.375 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [10]" TO WS-NAME
     MOVE -0.75 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [11]" TO WS-NAME
     MOVE -0.375 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 0 (12 corner values) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-THROWN-QUAD" USING WS-IN WS-OUT
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [1]" TO WS-NAME
     MOVE -0.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [3]" TO WS-NAME
     MOVE -1.125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [4]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [5]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [6]" TO WS-NAME
     MOVE -1.125 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [7]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [8]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [9]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [10]" TO WS-NAME
     MOVE -0.75 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [11]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 3 shot at an angle 1 (12 corner values) [12]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.75 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-THROWN-QUAD" USING WS-IN WS-OUT
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [1]" TO WS-NAME
     MOVE -0.1875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [2]" TO WS-NAME
     MOVE 0.28125 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [4]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [5]" TO WS-NAME
     MOVE 0.28125 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [7]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [8]" TO WS-NAME
     MOVE -0.09375 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [10]" TO WS-NAME
     MOVE -0.1875 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [11]" TO WS-NAME
     MOVE -0.09375 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 0 (12 corner values) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.75 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-THROWN-QUAD" USING WS-IN WS-OUT
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [1]" TO WS-NAME
     MOVE -0.1875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [3]" TO WS-NAME
     MOVE -0.28125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [4]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [5]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [6]" TO WS-NAME
     MOVE -0.28125 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [7]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [8]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [9]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [10]" TO WS-NAME
     MOVE -0.1875 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [11]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.1/7.2 quad for scale 0.75 shot at an angle 1 (12 corner values) [12]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-HOOK-QUAD" USING WS-IN WS-OUT
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [1]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [2]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [5]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [6]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [7]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [8]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [9]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [10]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [11]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [13]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [14]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.1 hook quad (x, y, u, v of the four vertices) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, 0, 0) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 5 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 1.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, 0, 0) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 8 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 2.25 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, 0, 0) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 15 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 3.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, 0, 0) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE -2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 0.966485127 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE -0.256722612 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 0.18359375 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -0.966485127 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.256722612 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (4, -2, 0) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE -2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 5 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 1.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE -0.16015625 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 0.921364161 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE -0.388700505 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE -0.265625 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -0.921364161 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.388700505 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (4, -2, 0) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE -2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 8 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 0.888803167 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE -0.458289133 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 2.25 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE -0.62890625 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -0.888803167 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.458289133 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (4, -2, 0) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE -2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 15 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 3.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE -1.56640625 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 0.806004429 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE -0.591909503 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE -1.75 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -0.806004429 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.591909503 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (4, -2, 0) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.5 TO WS-IV(1)
     MOVE 0.75 TO WS-IV(2)
     MOVE 2.25 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE -0.548775297 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE 0.145768438 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.823162946 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE -0.09375 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 0.274902344 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.140625 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE 0.548775297 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE -0.145768438 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE -0.823162946 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.5 TO WS-IV(1)
     MOVE 0.75 TO WS-IV(2)
     MOVE 2.25 TO WS-IV(3)
     MOVE 5 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.403808594 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 0.703125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE -0.540108428 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE 0.227858243 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.810162642 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE -0.5625 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 0.443359375 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 0.84375 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE 0.540108428 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE -0.227858243 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE -0.810162642 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.5 TO WS-IV(1)
     MOVE 0.75 TO WS-IV(2)
     MOVE 2.25 TO WS-IV(3)
     MOVE 8 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE -0.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.53125 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 1.125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE -0.533314816 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE 0.274990452 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.799972224 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE -0.84375 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 0.579589844 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 1.265625 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE 0.533314816 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE -0.274990452 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE -0.799972224 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.5 TO WS-IV(1)
     MOVE 0.75 TO WS-IV(2)
     MOVE 2.25 TO WS-IV(3)
     MOVE 15 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE -1.40625 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.931152344 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE 2.109375 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE -0.51371249 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE 0.377257609 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE 0.770568734 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE 2.25 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE 0.51371249 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE -0.377257609 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (-1.5, 0.75, 2.25) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE -0.770568734 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.3 TO WS-IV(1)
     MOVE -3 TO WS-IV(2)
     MOVE -0.7 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 0.169840492 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE -0.902277613 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE -0.396294481 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 0.01875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE 0.150390625 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE -0.04375 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -0.169840492 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.902277613 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 0 for offset (0.3, -3, -0.7) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.396294481 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.3 TO WS-IV(1)
     MOVE -3 TO WS-IV(2)
     MOVE -0.7 TO WS-IV(3)
     MOVE 5 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE -0.365234375 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE -0.21875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 0.113492939 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE -0.957596671 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE -0.264816857 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 0.1125 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE -0.5234375 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE -0.2625 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -0.113492939 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.957596671 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 5 for offset (0.3, -3, -0.7) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.264816857 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.3 TO WS-IV(1)
     MOVE -3 TO WS-IV(2)
     MOVE -0.7 TO WS-IV(3)
     MOVE 8 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE -0.875 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE -0.35 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 0.094158744 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE -0.971012049 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE -0.219703736 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 0.16875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE -1.068359375 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE -0.39375 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -0.094158744 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.971012049 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 8 for offset (0.3, -3, -0.7) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.219703736 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.3 TO WS-IV(1)
     MOVE -3 TO WS-IV(2)
     MOVE -0.7 TO WS-IV(3)
     MOVE 15 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [1]" TO WS-NAME
     MOVE 0.28125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [2]" TO WS-NAME
     MOVE -2.474609375 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [3]" TO WS-NAME
     MOVE -0.65625 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [4]" TO WS-NAME
     MOVE 0.067090361 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [5]" TO WS-NAME
     MOVE -0.985389672 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [6]" TO WS-NAME
     MOVE -0.156544175 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [8]" TO WS-NAME
     MOVE -2.75 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [9]" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [10]" TO WS-NAME
     MOVE -0.067090361 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [11]" TO WS-NAME
     MOVE 0.985389672 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 line segment 15 for offset (0.3, -3, -0.7) (position, normal; both vertices) [12]" TO WS-NAME
     MOVE 0.156544175 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 8 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "Validation 7 P(0.5) for (4, 0, 0) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "Validation 7 P(0.5) for (4, 0, 0) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "Validation 7 P(0.5) for (4, 0, 0) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE -2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 15 TO WS-IV(4)
     CALL "EF9-HOOK-LINE" USING WS-IN WS-OUT
     MOVE "Validation 7 P(1) for (4, -2, 0) [7]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "Validation 7 P(1) for (4, -2, 0) [8]" TO WS-NAME
     MOVE -1.75 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "Validation 7 P(1) for (4, -2, 0) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-HOOK-SWING" USING WS-IN WS-OUT
     MOVE "8 swing factor of 0" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.01 TO WS-IV(1)
     CALL "EF9-HOOK-SWING" USING WS-IN WS-OUT
     MOVE "8 swing factor of 0.01" TO WS-NAME
     MOVE 0.308944046 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.25 TO WS-IV(1)
     CALL "EF9-HOOK-SWING" USING WS-IN WS-OUT
     MOVE "8 swing factor of 0.25" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF9-HOOK-SWING" USING WS-IN WS-OUT
     MOVE "8 swing factor of 0.5" TO WS-NAME
     MOVE 0.795720756 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.9 TO WS-IV(1)
     CALL "EF9-HOOK-SWING" USING WS-IN WS-OUT
     MOVE "8 swing factor of 0.9" TO WS-NAME
     MOVE 0.160561725 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-HOOK-SWING" USING WS-IN WS-OUT
     MOVE "8 swing factor of 1" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-HOOK-SIDE" USING WS-IN WS-OUT
     MOVE "8 holding arm: rod in main hand 1, main arm right 1 (side)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-HOOK-SIDE" USING WS-IN WS-OUT
     MOVE "8 holding arm: rod in main hand 1, main arm right 0 (side)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-HOOK-SIDE" USING WS-IN WS-OUT
     MOVE "8 holding arm: rod in main hand 0, main arm right 1 (side)" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-HOOK-SIDE" USING WS-IN WS-OUT
     MOVE "8 holding arm: rod in main hand 0, main arm right 0 (side)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 10 TO WS-IV(7)
     MOVE 65.62 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     CALL "EF9-HOOK-HAND" USING WS-IN WS-OUT
     MOVE "8 third-person hand for body yaw 0 to 0 partial 0.5 side 1 scale 1 crouch 0 [1]" TO WS-NAME
     MOVE 9.65 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 third-person hand for body yaw 0 to 0 partial 0.5 side 1 scale 1 crouch 0 [2]" TO WS-NAME
     MOVE 65.17 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 third-person hand for body yaw 0 to 0 partial 0.5 side 1 scale 1 crouch 0 [3]" TO WS-NAME
     MOVE 10.8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 90 TO WS-IV(1)
     MOVE 100 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE -1 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 1.62 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     CALL "EF9-HOOK-HAND" USING WS-IN WS-OUT
     MOVE "8 third-person hand for body yaw 90 to 100 partial 0.5 side -1 scale 1 crouch 1 [1]" TO WS-NAME
     MOVE -0.827454336 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 third-person hand for body yaw 90 to 100 partial 0.5 side -1 scale 1 crouch 1 [2]" TO WS-NAME
     MOVE 0.9825 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 third-person hand for body yaw 90 to 100 partial 0.5 side -1 scale 1 crouch 1 [3]" TO WS-NAME
     MOVE 0.278961185 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE -170 TO WS-IV(1)
     MOVE 170 TO WS-IV(2)
     MOVE 0.25 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 3.5 TO WS-IV(7)
     MOVE 7 TO WS-IV(8)
     MOVE -2 TO WS-IV(9)
     CALL "EF9-HOOK-HAND" USING WS-IN WS-OUT
     MOVE "8 third-person hand for body yaw -170 to 170 partial 0.25 side 1 scale 0.5 crouch 0 [1]" TO WS-NAME
     MOVE 3.883226749 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 third-person hand for body yaw -170 to 170 partial 0.25 side 1 scale 0.5 crouch 0 [2]" TO WS-NAME
     MOVE 6.775 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 third-person hand for body yaw -170 to 170 partial 0.25 side 1 scale 0.5 crouch 0 [3]" TO WS-NAME
     MOVE -1.790813254 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 30 TO WS-IV(1)
     MOVE 45 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE -1 TO WS-IV(4)
     MOVE 1.2 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE -8 TO WS-IV(7)
     MOVE 70 TO WS-IV(8)
     MOVE 8 TO WS-IV(9)
     CALL "EF9-HOOK-HAND" USING WS-IN WS-OUT
     MOVE "8 third-person hand for body yaw 30 to 45 partial 1 side -1 scale 1.2 crouch 1 [1]" TO WS-NAME
     MOVE -8.381744107 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 third-person hand for body yaw 30 to 45 partial 1 side -1 scale 1.2 crouch 1 [2]" TO WS-NAME
     MOVE 69.2725 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 third-person hand for body yaw 30 to 45 partial 1 side -1 scale 1.2 crouch 1 [3]" TO WS-NAME
     MOVE 8.975843995 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§7: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§7: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-7.
