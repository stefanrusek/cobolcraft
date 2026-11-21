from mesh5 import *
IDS=['PARROT']
hdr='''*> Entity models part 5 section 7 (Parrot): the mesh (7.1), the pose choice and setupAnim (7.2), texture, flap angle and counters, shoulder layer (7.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-PARROT-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 ageInTicks, 6 pose 0 FLYING 1 STANDING 2 SITTING 3 PARTY 4 ON_SHOULDER, 7 flapAngle): prepare, head look, then the pose steps, reset first;
*>   EF5-PARROT-POSE IN(party, sitting, flying) OUT(pose); EF5-PARROT-TEXTURE IN(variant 0 red_blue 1 blue 2 green 3 yellow_blue 4 gray) path(out X(120)); EF5-PARROT-FLAP IN(partial, old flap, flap, old flap speed, flap speed) OUT(flapAngle);
*>   EF5-PARROT-FLAPPING IN(flapSpeed, flapping, flap, on ground, riding, airborne, delta movement y) OUT(flapSpeed, flapping, flap, delta movement y) after one tick; EF5-PARROT-SHOULDER IN(left shoulder, crouching) OUT(x, y, z) translation in blocks.
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PARROT-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-H                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-LW                  BINARY-LONG.
 01 WS-RW                  BINARY-LONG.
 01 WS-LL                  BINARY-LONG.
 01 WS-RL                  BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-CS                  FLOAT-LONG.
 01 WS-SN                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-B
     MOVE "tail" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T
     MOVE "left_wing" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LW
     MOVE "right_wing" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RW
     MOVE "left_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LL
     MOVE "right_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RL
     EVALUATE L-I(6)
         WHEN 0
             COMPUTE MM-CXROT(WS-LL) = MM-CXROT(WS-LL) + 0.6981317
             COMPUTE MM-CXROT(WS-RL) = MM-CXROT(WS-RL) + 0.6981317
         WHEN 2
             COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + 1.9
             COMPUTE MM-CY(WS-T) = MM-CY(WS-T) + 1.9
             COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + 1.9
             COMPUTE MM-CY(WS-LW) = MM-CY(WS-LW) + 1.9
             COMPUTE MM-CY(WS-RW) = MM-CY(WS-RW) + 1.9
             COMPUTE MM-CY(WS-LL) = MM-CY(WS-LL) + 1.9
             COMPUTE MM-CY(WS-RL) = MM-CY(WS-RL) + 1.9
             COMPUTE MM-CXROT(WS-T) = MM-CXROT(WS-T) + 0.5235988
             MOVE -0.0873 TO MM-CZROT(WS-LW)
             MOVE 0.0873 TO MM-CZROT(WS-RW)
             COMPUTE MM-CXROT(WS-LL) = MM-CXROT(WS-LL) + 1.5707964
             COMPUTE MM-CXROT(WS-RL) = MM-CXROT(WS-RL) + 1.5707964
         WHEN 3
             MOVE -0.34906584 TO MM-CZROT(WS-LL)
             MOVE 0.34906584 TO MM-CZROT(WS-RL)
     END-EVALUATE
     COMPUTE MM-CXROT(WS-H) = L-I(1) * 0.017453292
     COMPUTE MM-CYROT(WS-H) = L-I(2) * 0.017453292
     EVALUATE L-I(6)
         WHEN 2
             CONTINUE
         WHEN 3
             COMPUTE WS-CS = FUNCTION COS(L-I(5))
             COMPUTE WS-SN = FUNCTION SIN(L-I(5))
             COMPUTE MM-CX(WS-H) = MM-CX(WS-H) + WS-CS
             COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + WS-SN
             MOVE 0 TO MM-CXROT(WS-H) MM-CYROT(WS-H)
             COMPUTE MM-CZROT(WS-H) = FUNCTION SIN(L-I(5)) * 0.4
             COMPUTE MM-CX(WS-B) = MM-CX(WS-B) + WS-CS
             COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + WS-SN
             COMPUTE MM-CX(WS-T) = MM-CX(WS-T) + WS-CS
             COMPUTE MM-CY(WS-T) = MM-CY(WS-T) + WS-SN
             COMPUTE MM-CZROT(WS-LW) = -0.0873 - L-I(7)
             COMPUTE MM-CX(WS-LW) = MM-CX(WS-LW) + WS-CS
             COMPUTE MM-CY(WS-LW) = MM-CY(WS-LW) + WS-SN
             COMPUTE MM-CZROT(WS-RW) = 0.0873 + L-I(7)
             COMPUTE MM-CX(WS-RW) = MM-CX(WS-RW) + WS-CS
             COMPUTE MM-CY(WS-RW) = MM-CY(WS-RW) + WS-SN
         WHEN OTHER
             IF L-I(6) = 1
                 COMPUTE MM-CXROT(WS-LL) = MM-CXROT(WS-LL) + FUNCTION COS(0.6662 * L-I(3)) * 1.4 * L-I(4)
                 COMPUTE MM-CXROT(WS-RL) = MM-CXROT(WS-RL) + FUNCTION COS(0.6662 * L-I(3) + 3.141592653589793) * 1.4 * L-I(4)
             END-IF
             COMPUTE WS-V = L-I(7) * 0.3
             COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + WS-V
             COMPUTE MM-CXROT(WS-T) = MM-CXROT(WS-T) + FUNCTION COS(0.6662 * L-I(3)) * 0.3 * L-I(4)
             COMPUTE MM-CY(WS-T) = MM-CY(WS-T) + WS-V
             COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + WS-V
             COMPUTE MM-CZROT(WS-LW) = -0.0873 - L-I(7)
             COMPUTE MM-CY(WS-LW) = MM-CY(WS-LW) + WS-V
             COMPUTE MM-CZROT(WS-RW) = 0.0873 + L-I(7)
             COMPUTE MM-CY(WS-RW) = MM-CY(WS-RW) + WS-V
             COMPUTE MM-CY(WS-LL) = MM-CY(WS-LL) + WS-V
             COMPUTE MM-CY(WS-RL) = MM-CY(WS-RL) + WS-V
     END-EVALUATE
     GOBACK.
 END PROGRAM EF5-PARROT-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PARROT-POSE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     IF L-I(3) NOT = 0
         MOVE 0 TO L-O(1)
     END-IF
     IF L-I(2) NOT = 0
         MOVE 2 TO L-O(1)
     END-IF
     IF L-I(1) NOT = 0
         MOVE 3 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF5-PARROT-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PARROT-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE L-I(1)
         WHEN 0 MOVE "textures/entity/parrot/parrot_red_blue.png" TO L-PATH
         WHEN 1 MOVE "textures/entity/parrot/parrot_blue.png" TO L-PATH
         WHEN 2 MOVE "textures/entity/parrot/parrot_green.png" TO L-PATH
         WHEN 3 MOVE "textures/entity/parrot/parrot_yellow_blue.png" TO L-PATH
         WHEN OTHER MOVE "textures/entity/parrot/parrot_grey.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF5-PARROT-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PARROT-FLAP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = (FUNCTION SIN(L-I(2) + L-I(1) * (L-I(3) - L-I(2))) + 1) * (L-I(4) + L-I(1) * (L-I(5) - L-I(4)))
     GOBACK.
 END PROGRAM EF5-PARROT-FLAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PARROT-FLAPPING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 4 TO WS-F
     IF L-I(4) NOT = 0 OR L-I(5) NOT = 0
         MOVE -1 TO WS-F
     END-IF
     COMPUTE L-O(1) = FUNCTION MIN(1, FUNCTION MAX(0, L-I(1) + WS-F * 0.3))
     MOVE L-I(2) TO L-O(2)
     IF L-I(6) NOT = 0 AND L-I(2) < 1
         MOVE 1 TO L-O(2)
     END-IF
     COMPUTE L-O(2) = L-O(2) * 0.9
     MOVE L-I(7) TO L-O(4)
     IF L-I(6) NOT = 0 AND L-I(7) < 0
         COMPUTE L-O(4) = L-I(7) * 0.6
     END-IF
     COMPUTE L-O(3) = L-I(3) + L-O(2) * 2
     GOBACK.
 END PROGRAM EF5-PARROT-FLAPPING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PARROT-SHOULDER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE -0.4 TO L-O(1)
     IF L-I(1) NOT = 0
         MOVE 0.4 TO L-O(1)
     END-IF
     MOVE -1.5 TO L-O(2)
     IF L-I(2) NOT = 0
         MOVE -1.3 TO L-O(2)
     END-IF
     MOVE 0 TO L-O(3)
     GOBACK.
 END PROGRAM EF5-PARROT-SHOULDER.
'''
write_section_src(7,hdr,IDS,extra); write_layers(IDS)
