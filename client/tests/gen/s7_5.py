from nether7 import *
from prog6 import *
hoglin()
hdr='''*> Entity models part 7 section 5 (Hoglin and zoglin): the adult and baby meshes (5.2, 5.3; the zoglin layers reuse them), setupAnim (5.4), textures, shadow and shaking (5.1).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF7-HOGLIN-ANIM EMM-MODEL state(1 yRot degrees, 2 walk position, 3 walk speed (not clamped), 4 attackAnimationRemainingTicks, 5 baby model): reset first, ears, head yaw, headbutt, legs;
*>   EF7-HOGLIN-TEXTURE IN(zoglin, baby) path(out X(120)); EF7-HOGLIN-SHADOW IN() OUT(0.7); EF7-HOGLIN-SHAKING IN(zoglin, base shaking rule, converting) OUT(1 shakes). Layers HOGLIN, HOGLIN_BABY, ZOGLIN, ZOGLIN_BABY through EF7-LAYER.
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HOGLIN-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-H                   BINARY-LONG.
 01 WS-RE                  BINARY-LONG.
 01 WS-LE                  BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-LF                  BINARY-LONG.
 01 WS-RH                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     MOVE "right_ear" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RE
     MOVE "left_ear" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LE
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RF
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LF
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RH
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LH
     COMPUTE MM-CZROT(WS-RE) = -0.6981317 - L-I(3) * FUNCTION SIN(L-I(2))
     COMPUTE MM-CZROT(WS-LE) = 0.6981317 + L-I(3) * FUNCTION SIN(L-I(2))
     COMPUTE MM-CYROT(WS-H) = L-I(1) * 0.017453292
     COMPUTE WS-D = FUNCTION ABS(10 - 2 * L-I(4))
     COMPUTE WS-F = 1 - WS-D / 10
     COMPUTE MM-CXROT(WS-H) = 0.87266463 + WS-F * (-0.34906584 - 0.87266463)
     IF L-I(5) NOT = 0
         COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + WS-F * 2.5
     END-IF
     COMPUTE MM-CXROT(WS-RF) = FUNCTION COS(L-I(2)) * 1.2 * L-I(3)
     COMPUTE MM-CXROT(WS-LF) = FUNCTION COS(L-I(2) + 3.141592653589793) * 1.2 * L-I(3)
     MOVE MM-CXROT(WS-LF) TO MM-CXROT(WS-RH)
     MOVE MM-CXROT(WS-RF) TO MM-CXROT(WS-LH)
     GOBACK.
 END PROGRAM EF7-HOGLIN-ANIM.

'''
extra+=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HOGLIN-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE TRUE
         WHEN L-I(1) NOT = 0 AND L-I(2) NOT = 0
             MOVE "textures/entity/hoglin/zoglin_baby.png" TO L-PATH
         WHEN L-I(1) NOT = 0
             MOVE "textures/entity/hoglin/zoglin.png" TO L-PATH
         WHEN L-I(2) NOT = 0
             MOVE "textures/entity/hoglin/hoglin_baby.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/hoglin/hoglin.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-HOGLIN-TEXTURE.

'''
extra+=prog('EF7-HOGLIN-SHADOW','     MOVE 0.7 TO L-O(1)\n')
extra+=prog('EF7-HOGLIN-SHAKING','     MOVE 0 TO L-O(1)\n     IF L-I(2) NOT = 0 OR (L-I(3) NOT = 0 AND L-I(1) = 0)\n         MOVE 1 TO L-O(1)\n     END-IF\n')
write_section_src(5,hdr,['HOGLIN','HOGLIN_BABY'],extra); write_layers(['HOGLIN','HOGLIN_BABY','ZOGLIN','ZOGLIN_BABY'])
