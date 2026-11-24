*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 16 (cushion): the model (texture 64 x 64, offset (23, 4, -7), cuboid (-31, -4, -1) size 16 x 4 x 16 with deformation -0.005), the texture of each of the 16 dye colours and the submit
*> (rotate Y by 180 - the direction's yaw, rotate X by 180, translate (0, -0.25, 0); Direction.fromYRot of 24-4 section 2 for the yaw).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-16.
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
 01 WS-X60               PIC X(60).
 PROCEDURE DIVISION.
     MOVE "CUSHION" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer CUSHION is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-9§16 Cushion 16 CUSHION" TO CK-PREFIX
     MOVE "P cushion root 23 4 -7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C cushion 0 0 -31 -4 -1 16 4 16 -0.005 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "16 CUSHION: parts below the root" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 CUSHION: cuboids" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 CUSHION: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 CUSHION: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 0 (white)" TO WS-NAME
     MOVE "entity/cushion/white_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 1 (orange)" TO WS-NAME
     MOVE "entity/cushion/orange_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 2 (magenta)" TO WS-NAME
     MOVE "entity/cushion/magenta_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 3 (light_blue)" TO WS-NAME
     MOVE "entity/cushion/light_blue_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 4 (yellow)" TO WS-NAME
     MOVE "entity/cushion/yellow_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 5 (lime)" TO WS-NAME
     MOVE "entity/cushion/lime_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 6 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 6 (pink)" TO WS-NAME
     MOVE "entity/cushion/pink_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 7 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 7 (gray)" TO WS-NAME
     MOVE "entity/cushion/gray_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 8 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 8 (light_gray)" TO WS-NAME
     MOVE "entity/cushion/light_gray_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 9 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 9 (cyan)" TO WS-NAME
     MOVE "entity/cushion/cyan_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 10 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 10 (purple)" TO WS-NAME
     MOVE "entity/cushion/purple_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 11 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 11 (blue)" TO WS-NAME
     MOVE "entity/cushion/blue_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 12 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 12 (brown)" TO WS-NAME
     MOVE "entity/cushion/brown_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 13 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 13 (green)" TO WS-NAME
     MOVE "entity/cushion/green_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 14 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 14 (red)" TO WS-NAME
     MOVE "entity/cushion/red_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 15 TO WS-IV(1)
     MOVE SPACES TO WS-X60
     CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60
     MOVE "16 texture of dye 15 (black)" TO WS-NAME
     MOVE "entity/cushion/black_cushion.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [3]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 0 (direction data 0) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 44 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [3]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 44 (direction data 0) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 45 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [3]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 45 (direction data 1) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 90 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [3]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 90 (direction data 1) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 134 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [3]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 134 (direction data 1) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 135 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 135 (direction data 2) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 180 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 180 (direction data 2) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 224 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 224 (direction data 2) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 225 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [3]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 225 (direction data 3) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 270 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [3]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 270 (direction data 3) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE -90 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [3]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -90 (direction data 3) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE -45 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [3]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -45 (direction data 0) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE -46 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [3]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -46 (direction data 3) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 360 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [3]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot 360 (direction data 0) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE -180 TO WS-IV(1)
     CALL "EF9-CUSHION-OPS" USING WS-IN WS-OUT
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [7]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [12]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "16 submit ops for the entity yRot -180 (direction data 2) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "NO_SUCH_LAYER" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "16 a layer that is not of this part is not known" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§16 Cushion: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§16 Cushion: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-16.
