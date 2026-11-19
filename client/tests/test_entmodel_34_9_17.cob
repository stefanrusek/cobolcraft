*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 17 (display entities): the billboard orientation table (the four constraints, Validation 11), the brightness override unpacked, the item display's Y rotation, the text display's flag bits,
*> layout (line height 10, height = lines x 10 - 1, translate (1 - width / 2, -height), the default background's alpha 63) and the lines' x for the three alignments, with the worked example of two lines of widths 40 and 60 centred, and the text colour.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-17.
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
     MOVE 90 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 0 entity (90, 0) camera (0, 0) (yaw, pitch) [1]" TO WS-NAME
     MOVE -1.57079628 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 0 entity (90, 0) camera (0, 0) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 30 TO WS-IV(3)
     MOVE 45 TO WS-IV(4)
     MOVE -20 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 0 entity (0, 30) camera (45, -20) (yaw, pitch) [1]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 0 entity (0, 30) camera (45, -20) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.52359876 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE -135 TO WS-IV(2)
     MOVE 15 TO WS-IV(3)
     MOVE 200 TO WS-IV(4)
     MOVE 60 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 0 entity (-135, 15) camera (200, 60) (yaw, pitch) [1]" TO WS-NAME
     MOVE 2.35619442 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 0 entity (-135, 15) camera (200, 60) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 270 TO WS-IV(2)
     MOVE -45 TO WS-IV(3)
     MOVE -90 TO WS-IV(4)
     MOVE 80 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 0 entity (270, -45) camera (-90, 80) (yaw, pitch) [1]" TO WS-NAME
     MOVE -4.71238884 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 0 entity (270, -45) camera (-90, 80) (yaw, pitch) [2]" TO WS-NAME
     MOVE -0.78539814 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 90 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 1 entity (90, 0) camera (0, 0) (yaw, pitch) [1]" TO WS-NAME
     MOVE 3.14159256 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 1 entity (90, 0) camera (0, 0) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 30 TO WS-IV(3)
     MOVE 45 TO WS-IV(4)
     MOVE -20 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 1 entity (0, 30) camera (45, -20) (yaw, pitch) [1]" TO WS-NAME
     MOVE 2.35619442 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 1 entity (0, 30) camera (45, -20) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.52359876 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE -135 TO WS-IV(2)
     MOVE 15 TO WS-IV(3)
     MOVE 200 TO WS-IV(4)
     MOVE 60 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 1 entity (-135, 15) camera (200, 60) (yaw, pitch) [1]" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 1 entity (-135, 15) camera (200, 60) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 270 TO WS-IV(2)
     MOVE -45 TO WS-IV(3)
     MOVE -90 TO WS-IV(4)
     MOVE 80 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 1 entity (270, -45) camera (-90, 80) (yaw, pitch) [1]" TO WS-NAME
     MOVE 4.71238884 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 1 entity (270, -45) camera (-90, 80) (yaw, pitch) [2]" TO WS-NAME
     MOVE -0.78539814 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 90 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 2 entity (90, 0) camera (0, 0) (yaw, pitch) [1]" TO WS-NAME
     MOVE -1.57079628 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 2 entity (90, 0) camera (0, 0) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 30 TO WS-IV(3)
     MOVE 45 TO WS-IV(4)
     MOVE -20 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 2 entity (0, 30) camera (45, -20) (yaw, pitch) [1]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 2 entity (0, 30) camera (45, -20) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE -135 TO WS-IV(2)
     MOVE 15 TO WS-IV(3)
     MOVE 200 TO WS-IV(4)
     MOVE 60 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 2 entity (-135, 15) camera (200, 60) (yaw, pitch) [1]" TO WS-NAME
     MOVE 2.35619442 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 2 entity (-135, 15) camera (200, 60) (yaw, pitch) [2]" TO WS-NAME
     MOVE -1.04719752 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 270 TO WS-IV(2)
     MOVE -45 TO WS-IV(3)
     MOVE -90 TO WS-IV(4)
     MOVE 80 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 2 entity (270, -45) camera (-90, 80) (yaw, pitch) [1]" TO WS-NAME
     MOVE -4.71238884 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 2 entity (270, -45) camera (-90, 80) (yaw, pitch) [2]" TO WS-NAME
     MOVE -1.39626336 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 90 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 3 entity (90, 0) camera (0, 0) (yaw, pitch) [1]" TO WS-NAME
     MOVE 3.14159256 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 3 entity (90, 0) camera (0, 0) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 30 TO WS-IV(3)
     MOVE 45 TO WS-IV(4)
     MOVE -20 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 3 entity (0, 30) camera (45, -20) (yaw, pitch) [1]" TO WS-NAME
     MOVE 2.35619442 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 3 entity (0, 30) camera (45, -20) (yaw, pitch) [2]" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE -135 TO WS-IV(2)
     MOVE 15 TO WS-IV(3)
     MOVE 200 TO WS-IV(4)
     MOVE 60 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 3 entity (-135, 15) camera (200, 60) (yaw, pitch) [1]" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 3 entity (-135, 15) camera (200, 60) (yaw, pitch) [2]" TO WS-NAME
     MOVE -1.04719752 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 270 TO WS-IV(2)
     MOVE -45 TO WS-IV(3)
     MOVE -90 TO WS-IV(4)
     MOVE 80 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17.1 constraint 3 entity (270, -45) camera (-90, 80) (yaw, pitch) [1]" TO WS-NAME
     MOVE 4.71238884 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 constraint 3 entity (270, -45) camera (-90, 80) (yaw, pitch) [2]" TO WS-NAME
     MOVE -1.39626336 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 90 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-DISPLAY-ORIENT" USING WS-IN WS-OUT
     MOVE "17 Validation 11: fixed with entityYRot 90 gives yaw -1.5707964, pitch 0 [1]" TO WS-NAME
     MOVE -1.5707964 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17 Validation 11: fixed with entityYRot 90 gives yaw -1.5707964, pitch 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-DISPLAY-LIGHT" USING WS-IN WS-OUT
     MOVE "17.1 override -1 level (3, 9) (block, sky) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 override -1 level (3, 9) (block, sky) [2]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15728880 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-DISPLAY-LIGHT" USING WS-IN WS-OUT
     MOVE "17.1 override 15728880 level (3, 9) (block, sky) [1]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 override 15728880 level (3, 9) (block, sky) [2]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 15 TO WS-IV(3)
     CALL "EF9-DISPLAY-LIGHT" USING WS-IN WS-OUT
     MOVE "17.1 override 0 level (15, 15) (block, sky) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 override 0 level (15, 15) (block, sky) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15728850 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-DISPLAY-LIGHT" USING WS-IN WS-OUT
     MOVE "17.1 override 15728850 level (1, 1) (block, sky) [1]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 override 15728850 level (1, 1) (block, sky) [2]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2097264 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-DISPLAY-LIGHT" USING WS-IN WS-OUT
     MOVE "17.1 override 2097264 level (0, 0) (block, sky) [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.1 override 2097264 level (0, 0) (block, sky) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-DISPLAY-ITEM-OPS" USING WS-IN WS-OUT
     MOVE "17.3 the item display rotates about Y by pi [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.3 the item display rotates about Y by pi [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.3 the item display rotates about Y by pi [3]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.3 the item display rotates about Y by pi [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.3 the item display rotates about Y by pi [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-DISPLAY-BLOCK-OPS" USING WS-IN WS-OUT
     MOVE "17.2 the block display adds no transform" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 0 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 0 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 0 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 0 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 1 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 1 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 1 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 1 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 2 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 2 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 2 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 2 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 4 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 4 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 4 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 4 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 8 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 8 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 8 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 8 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 16 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 16 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 16 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 16 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 3 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 3 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 3 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 3 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 5 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 5 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 5 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 5 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 9 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 9 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 9 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 9 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 17 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 17 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 17 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 17 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 17 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 24 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 24 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 24 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 24 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 31 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 31 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 31 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 31 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 6 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 6 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 6 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 6 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 12 TO WS-IV(1)
     CALL "EF9-TEXT-FLAGS" USING WS-IN WS-OUT
     MOVE "17.4 flags 12 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 12 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 12 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 flags 12 (see-through, shadow, default background, alignment 0 left 1 right 2 centre) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     CALL "EF9-TEXT-LAYOUT" USING WS-IN WS-OUT
     MOVE "17.4 layout flags 0 lines 1 width 40 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 0 lines 1 width 40 [2]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 0 lines 1 width 40 [3]" TO WS-NAME
     MOVE -19.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 0 lines 1 width 40 [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 0 lines 1 width 40 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 60 TO WS-IV(3)
     CALL "EF9-TEXT-LAYOUT" USING WS-IN WS-OUT
     MOVE "17.4 layout flags 4 lines 2 width 60 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 4 lines 2 width 60 [2]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 4 lines 2 width 60 [3]" TO WS-NAME
     MOVE -29.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 4 lines 2 width 60 [4]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 4 lines 2 width 60 [5]" TO WS-NAME
     MOVE 63 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 91 TO WS-IV(3)
     CALL "EF9-TEXT-LAYOUT" USING WS-IN WS-OUT
     MOVE "17.4 layout flags 1 lines 3 width 91 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 1 lines 3 width 91 [2]" TO WS-NAME
     MOVE 29 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 1 lines 3 width 91 [3]" TO WS-NAME
     MOVE -44.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 1 lines 3 width 91 [4]" TO WS-NAME
     MOVE -29 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 1 lines 3 width 91 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-TEXT-LAYOUT" USING WS-IN WS-OUT
     MOVE "17.4 layout flags 5 lines 5 width 7 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 5 lines 5 width 7 [2]" TO WS-NAME
     MOVE 49 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 5 lines 5 width 7 [3]" TO WS-NAME
     MOVE -2.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 5 lines 5 width 7 [4]" TO WS-NAME
     MOVE -49 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 layout flags 5 lines 5 width 7 [5]" TO WS-NAME
     MOVE 63 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 0 of width 40 in a block of 60, flags 0 (x, y) [1]" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 0 of width 40 in a block of 60, flags 0 (x, y) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 60 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 1 of width 60 in a block of 60, flags 0 (x, y) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 1 of width 60 in a block of 60, flags 0 (x, y) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 91 TO WS-IV(2)
     MOVE 17 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 2 of width 17 in a block of 91, flags 0 (x, y) [1]" TO WS-NAME
     MOVE 37.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 2 of width 17 in a block of 91, flags 0 (x, y) [2]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 3 of width 0 in a block of 10, flags 0 (x, y) [1]" TO WS-NAME
     MOVE 5.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 3 of width 0 in a block of 10, flags 0 (x, y) [2]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 0 of width 40 in a block of 60, flags 8 (x, y) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 0 of width 40 in a block of 60, flags 8 (x, y) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 60 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 1 of width 60 in a block of 60, flags 8 (x, y) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 1 of width 60 in a block of 60, flags 8 (x, y) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE 91 TO WS-IV(2)
     MOVE 17 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 2 of width 17 in a block of 91, flags 8 (x, y) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 2 of width 17 in a block of 91, flags 8 (x, y) [2]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 3 of width 0 in a block of 10, flags 8 (x, y) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 3 of width 0 in a block of 10, flags 8 (x, y) [2]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 0 of width 40 in a block of 60, flags 16 (x, y) [1]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 0 of width 40 in a block of 60, flags 16 (x, y) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 60 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 1 of width 60 in a block of 60, flags 16 (x, y) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 1 of width 60 in a block of 60, flags 16 (x, y) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 91 TO WS-IV(2)
     MOVE 17 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 2 of width 17 in a block of 91, flags 16 (x, y) [1]" TO WS-NAME
     MOVE 74 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 2 of width 17 in a block of 91, flags 16 (x, y) [2]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 3 of width 0 in a block of 10, flags 16 (x, y) [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 3 of width 0 in a block of 10, flags 16 (x, y) [2]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 0 of width 40 in a block of 60, flags 24 (x, y) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 0 of width 40 in a block of 60, flags 24 (x, y) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 60 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 1 of width 60 in a block of 60, flags 24 (x, y) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 1 of width 60 in a block of 60, flags 24 (x, y) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24 TO WS-IV(1)
     MOVE 91 TO WS-IV(2)
     MOVE 17 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 2 of width 17 in a block of 91, flags 24 (x, y) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 2 of width 17 in a block of 91, flags 24 (x, y) [2]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 line 3 of width 0 in a block of 10, flags 24 (x, y) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 line 3 of width 0 in a block of 10, flags 24 (x, y) [2]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 60 TO WS-IV(3)
     CALL "EF9-TEXT-LAYOUT" USING WS-IN WS-OUT
     MOVE "17.4 worked example layout [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 worked example layout [2]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 worked example layout [3]" TO WS-NAME
     MOVE -29 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 worked example layout [4]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 worked example layout [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 40 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 worked example first line [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 worked example first line [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 60 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-TEXT-LINE" USING WS-IN WS-OUT
     MOVE "17.4 worked example second line [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 worked example second line [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-TEXT-COLOR" USING WS-IN WS-OUT
     MOVE "17.4 text colour of opacity 0 (ARGB unsigned, narrowed byte) [1]" TO WS-NAME
     MOVE 16777215 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 text colour of opacity 0 (ARGB unsigned, narrowed byte) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 25 TO WS-IV(1)
     CALL "EF9-TEXT-COLOR" USING WS-IN WS-OUT
     MOVE "17.4 text colour of opacity 25 (ARGB unsigned, narrowed byte) [1]" TO WS-NAME
     MOVE 436207615 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 text colour of opacity 25 (ARGB unsigned, narrowed byte) [2]" TO WS-NAME
     MOVE 25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 26 TO WS-IV(1)
     CALL "EF9-TEXT-COLOR" USING WS-IN WS-OUT
     MOVE "17.4 text colour of opacity 26 (ARGB unsigned, narrowed byte) [1]" TO WS-NAME
     MOVE 452984831 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 text colour of opacity 26 (ARGB unsigned, narrowed byte) [2]" TO WS-NAME
     MOVE 26 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 127 TO WS-IV(1)
     CALL "EF9-TEXT-COLOR" USING WS-IN WS-OUT
     MOVE "17.4 text colour of opacity 127 (ARGB unsigned, narrowed byte) [1]" TO WS-NAME
     MOVE 2147483647 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 text colour of opacity 127 (ARGB unsigned, narrowed byte) [2]" TO WS-NAME
     MOVE 127 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 128 TO WS-IV(1)
     CALL "EF9-TEXT-COLOR" USING WS-IN WS-OUT
     MOVE "17.4 text colour of opacity 128 (ARGB unsigned, narrowed byte) [1]" TO WS-NAME
     MOVE 2164260863 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 text colour of opacity 128 (ARGB unsigned, narrowed byte) [2]" TO WS-NAME
     MOVE -128 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 200 TO WS-IV(1)
     CALL "EF9-TEXT-COLOR" USING WS-IN WS-OUT
     MOVE "17.4 text colour of opacity 200 (ARGB unsigned, narrowed byte) [1]" TO WS-NAME
     MOVE 3372220415 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 text colour of opacity 200 (ARGB unsigned, narrowed byte) [2]" TO WS-NAME
     MOVE -56 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 255 TO WS-IV(1)
     CALL "EF9-TEXT-COLOR" USING WS-IN WS-OUT
     MOVE "17.4 text colour of opacity 255 (ARGB unsigned, narrowed byte) [1]" TO WS-NAME
     MOVE 4294967295 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 text colour of opacity 255 (ARGB unsigned, narrowed byte) [2]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 256 TO WS-IV(1)
     CALL "EF9-TEXT-COLOR" USING WS-IN WS-OUT
     MOVE "17.4 text colour of opacity 256 (ARGB unsigned, narrowed byte) [1]" TO WS-NAME
     MOVE 16777215 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 text colour of opacity 256 (ARGB unsigned, narrowed byte) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     CALL "EF9-TEXT-COLOR" USING WS-IN WS-OUT
     MOVE "17.4 text colour of opacity -1 (ARGB unsigned, narrowed byte) [1]" TO WS-NAME
     MOVE 4294967295 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "17.4 text colour of opacity -1 (ARGB unsigned, narrowed byte) [2]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§17: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§17: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-17.
