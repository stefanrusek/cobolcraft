*> Entity models part 6 section 12 (Shulker): the SHULKER and SHULKER_BOX meshes (12.1), setupAnim (12.2), render offset, peek amount, attach face rotation, body rotation, dye textures and the cull box (12.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-SHULKER-ANIM EMM-MODEL state(1 xRot, 2 yHeadRot, 3 yBodyRot, 4 peekAmount, 5 ageInTicks): reset first, lid position and turn, head look; EF6-SHULKER-OFFSET IN(has old attach position, teleport interpolation, partial, scale, delta x y z (block - old block)) OUT(x y z);
*>   EF6-SHULKER-PEEK IN(current peek, raw data byte) OUT(new peek); EF6-SHULKER-ROT IN(attach face 0 DOWN 1 UP 2 NORTH 3 SOUTH 4 WEST 5 EAST) OUT(rotationXYZ x y z in radians, pivot x y z): the rotation of the opposite face about (0, 0.5, 0);
*>   EF6-SHULKER-BODYROT IN(bodyRot degrees) OUT(bodyRot + 180); EF6-SHULKER-TEXTURE IN(dye id 0 to 15, 16 none) path(out X(120)); EF6-SHULKER-CULLBOX IN(has render position, render x y z, block x y z, entity height, entity width) OUT(candidate, min xyz, max xyz).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-M-SHULKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P lid root 0 24 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C lid 0 0 -8 -16 -8 16 12 16 0 0".
    05 FILLER PIC X(100) VALUE "P base root 0 24 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C base 0 28 -8 -8 -8 16 8 16 0 0".
    05 FILLER PIC X(100) VALUE "P head root 0 12 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 52 -3 0 -3 6 6 6 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 74 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 6.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF6-M-SHULKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-M-SHULKER-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P lid root 0 24 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C lid 0 0 -8 -16 -8 16 12 16 0 0".
    05 FILLER PIC X(100) VALUE "P base root 0 24 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C base 0 28 -8 -8 -8 16 8 16 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 76 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 4.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF6-M-SHULKER-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SHULKER-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-LID                 BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-F3                  FLOAT-LONG.
 01 WS-F4                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "lid" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LID
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     COMPUTE WS-F2 = (0.5 + L-I(4)) * 3.1415927
     COMPUTE WS-F3 = -1 + FUNCTION SIN(WS-F2)
     MOVE 0 TO WS-F4
     IF WS-F2 > 3.1415927
         COMPUTE WS-F4 = FUNCTION SIN(L-I(5) * 0.1) * 0.7
     END-IF
     MOVE 0 TO MM-CX(WS-LID) MM-CZ(WS-LID)
     COMPUTE MM-CY(WS-LID) = 16 + FUNCTION SIN(WS-F2) * 8 + WS-F4
     MOVE 0 TO MM-CYROT(WS-LID)
     IF L-I(4) > 0.3
         COMPUTE MM-CYROT(WS-LID) = (WS-F3 * WS-F3 * WS-F3 * WS-F3) * 3.1415927 * 0.125
     END-IF
     COMPUTE MM-CXROT(WS-HEAD) = L-I(1) * 0.017453292
     COMPUTE MM-CYROT(WS-HEAD) = ((L-I(2) - 180) - L-I(3)) * 0.017453292
     GOBACK.
 END PROGRAM EF6-SHULKER-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SHULKER-OFFSET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-E                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     IF L-I(1) NOT = 0 AND L-I(2) > 0
         COMPUTE WS-E = ((L-I(2) - L-I(3)) / 6) * ((L-I(2) - L-I(3)) / 6) * L-I(4)
         COMPUTE L-O(1) = 0 - WS-E * L-I(5)
         COMPUTE L-O(2) = 0 - WS-E * L-I(6)
         COMPUTE L-O(3) = 0 - WS-E * L-I(7)
     END-IF
     GOBACK.
 END PROGRAM EF6-SHULKER-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SHULKER-PEEK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-T = L-I(2) * 0.01
     MOVE L-I(1) TO L-O(1)
     IF L-I(1) > WS-T
         COMPUTE L-O(1) = L-I(1) - 0.05
         IF L-O(1) < WS-T
             MOVE WS-T TO L-O(1)
         END-IF
         IF L-O(1) > 1
             MOVE 1 TO L-O(1)
         END-IF
     END-IF
     IF L-I(1) < WS-T
         COMPUTE L-O(1) = L-I(1) + 0.05
         IF L-O(1) > WS-T
             MOVE WS-T TO L-O(1)
         END-IF
         IF L-O(1) < 0
             MOVE 0 TO L-O(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF6-SHULKER-PEEK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SHULKER-ROT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4) L-O(6)
     MOVE 0.5 TO L-O(5)
     EVALUATE L-I(1)
         WHEN 0
             MOVE 0 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 0 TO L-O(3)
         WHEN 1
             MOVE 3.1415927 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 0 TO L-O(3)
         WHEN 2
             MOVE 1.5707964 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 0 TO L-O(3)
         WHEN 3
             MOVE 1.5707964 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 3.1415927 TO L-O(3)
         WHEN 4
             MOVE 1.5707964 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE -1.5707964 TO L-O(3)
         WHEN 5
             MOVE 1.5707964 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 1.5707964 TO L-O(3)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-SHULKER-ROT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SHULKER-BODYROT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) + 180
     GOBACK.
 END PROGRAM EF6-SHULKER-BODYROT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SHULKER-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE L-I(1)
         WHEN 0
             MOVE "textures/entity/shulker/shulker_white.png" TO L-PATH
         WHEN 1
             MOVE "textures/entity/shulker/shulker_orange.png" TO L-PATH
         WHEN 2
             MOVE "textures/entity/shulker/shulker_magenta.png" TO L-PATH
         WHEN 3
             MOVE "textures/entity/shulker/shulker_light_blue.png" TO L-PATH
         WHEN 4
             MOVE "textures/entity/shulker/shulker_yellow.png" TO L-PATH
         WHEN 5
             MOVE "textures/entity/shulker/shulker_lime.png" TO L-PATH
         WHEN 6
             MOVE "textures/entity/shulker/shulker_pink.png" TO L-PATH
         WHEN 7
             MOVE "textures/entity/shulker/shulker_gray.png" TO L-PATH
         WHEN 8
             MOVE "textures/entity/shulker/shulker_light_gray.png" TO L-PATH
         WHEN 9
             MOVE "textures/entity/shulker/shulker_cyan.png" TO L-PATH
         WHEN 10
             MOVE "textures/entity/shulker/shulker_purple.png" TO L-PATH
         WHEN 11
             MOVE "textures/entity/shulker/shulker_blue.png" TO L-PATH
         WHEN 12
             MOVE "textures/entity/shulker/shulker_brown.png" TO L-PATH
         WHEN 13
             MOVE "textures/entity/shulker/shulker_green.png" TO L-PATH
         WHEN 14
             MOVE "textures/entity/shulker/shulker_red.png" TO L-PATH
         WHEN 15
             MOVE "textures/entity/shulker/shulker_black.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/shulker/shulker.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-SHULKER-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SHULKER-CULLBOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AY                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4) L-O(5) L-O(6) L-O(7)
     IF L-I(1) NOT = 0
         MOVE 1 TO L-O(1)
         COMPUTE WS-AY = L-I(3) + L-I(8) / 2
         COMPUTE WS-BX = L-I(5) + 0.5
         COMPUTE WS-BY = L-I(6) + L-I(8) / 2
         COMPUTE WS-BZ = L-I(7) + 0.5
         MOVE L-I(2) TO L-O(2)
         IF WS-BX < L-O(2)
             MOVE WS-BX TO L-O(2)
         END-IF
         MOVE WS-AY TO L-O(3)
         IF WS-BY < L-O(3)
             MOVE WS-BY TO L-O(3)
         END-IF
         MOVE L-I(4) TO L-O(4)
         IF WS-BZ < L-O(4)
             MOVE WS-BZ TO L-O(4)
         END-IF
         MOVE L-I(2) TO L-O(5)
         IF WS-BX > L-O(5)
             MOVE WS-BX TO L-O(5)
         END-IF
         MOVE WS-AY TO L-O(6)
         IF WS-BY > L-O(6)
             MOVE WS-BY TO L-O(6)
         END-IF
         MOVE L-I(4) TO L-O(7)
         IF WS-BZ > L-O(7)
             MOVE WS-BZ TO L-O(7)
         END-IF
         COMPUTE L-O(2) = L-O(2) - L-I(9) / 2
         COMPUTE L-O(3) = L-O(3) - L-I(8) / 2
         COMPUTE L-O(4) = L-O(4) - L-I(9) / 2
         COMPUTE L-O(5) = L-O(5) + L-I(9) / 2
         COMPUTE L-O(6) = L-O(6) + L-I(8) / 2
         COMPUTE L-O(7) = L-O(7) + L-I(9) / 2
     END-IF
     GOBACK.
 END PROGRAM EF6-SHULKER-CULLBOX.

