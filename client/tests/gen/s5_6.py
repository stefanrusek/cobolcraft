from mesh5 import *
IDS=['POLAR_BEAR','POLAR_BEAR_BABY']
hdr='''*> Entity models part 5 section 6 (Polar bear): the meshes of the adult (scaled 1.2) and the baby, the pose after the quadruped base, textures, stand scale and counter.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-BEAR-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 standScale, 6 ageScale): the quadruped base then the standing pose (pixel offsets are multiplied by the scale of the body part,
*>   the layer scale carried by the root children); EF5-BEAR-STAND IN(partial, old counter, counter) OUT(standScale: the lerp divided by 6); EF5-BEAR-COUNTER IN(counter, standing) OUT(counter after a tick, 0 to 6);
*>   EF5-BEAR-TEXTURE IN(baby) path(out X(120)).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEAR-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-B                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-LF                  BINARY-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-SC                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EF5-QUAD-POSE" USING EMM-MODEL L-IN
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-B
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RF
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LF
     MOVE MM-YSCALE(WS-B) TO WS-SC
     COMPUTE WS-E = L-I(5) * L-I(5)
     COMPUTE MM-CXROT(WS-B) = MM-CXROT(WS-B) - WS-E * 3.141592653589793 * 0.35
     COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + WS-E * L-I(6) * 2 * WS-SC
     COMPUTE MM-CY(WS-RF) = MM-CY(WS-RF) - WS-E * L-I(6) * 20 * WS-SC
     COMPUTE MM-CZ(WS-RF) = MM-CZ(WS-RF) + WS-E * L-I(6) * 4 * WS-SC
     COMPUTE MM-CXROT(WS-RF) = MM-CXROT(WS-RF) - WS-E * 3.141592653589793 * 0.45
     MOVE MM-CY(WS-RF) TO MM-CY(WS-LF)
     MOVE MM-CZ(WS-RF) TO MM-CZ(WS-LF)
     COMPUTE MM-CXROT(WS-LF) = MM-CXROT(WS-LF) - WS-E * 3.141592653589793 * 0.45
     COMPUTE MM-CY(WS-H) = MM-CY(WS-H) - WS-E * 24 * WS-SC
     COMPUTE MM-CZ(WS-H) = MM-CZ(WS-H) + WS-E * 13 * WS-SC
     COMPUTE MM-CXROT(WS-H) = MM-CXROT(WS-H) + WS-E * 3.141592653589793 * 0.15
     GOBACK.
 END PROGRAM EF5-BEAR-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEAR-STAND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = (L-I(2) + L-I(1) * (L-I(3) - L-I(2))) / 6
     GOBACK.
 END PROGRAM EF5-BEAR-STAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEAR-COUNTER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(2) NOT = 0
         COMPUTE L-O(1) = FUNCTION MIN(6, L-I(1) + 1)
     ELSE
         COMPUTE L-O(1) = FUNCTION MAX(0, L-I(1) - 1)
     END-IF
     GOBACK.
 END PROGRAM EF5-BEAR-COUNTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEAR-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/bear/polarbear.png" TO L-PATH
     IF L-I(1) NOT = 0
         MOVE "textures/entity/bear/polarbear_baby.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-BEAR-TEXTURE.
'''
write_section_src(6,hdr,IDS,extra); write_layers(IDS)
