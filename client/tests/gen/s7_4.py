from nether7 import *
from prog6 import *
strider()
hdr='''*> Entity models part 7 section 4 (Strider): the adult and baby meshes and the saddle layer (4.3, 4.4, 4.1), the shared and custom animation (4.2 to 4.4), texture, shadow, cold shaking and the saddle decision (4.1).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF7-STRIDER-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed (clamped to 0.25 inside), 5 ageInTicks, 6 ridden, 7 baby model): reset first, shared steps, then the adult or baby custom animation;
*>   EF7-STRIDER-TEXTURE IN(suffocating, baby) path(out X(120)); EF7-STRIDER-SHADOW IN(baby, scale) OUT(0.5 x scale, x 0.5 for the baby); EF7-STRIDER-SHAKING IN(fully frozen, suffocating) OUT(1 shakes);
*>   EF7-STRIDER-SADDLE IN(item has EQUIPPABLE, component has an asset id, baby) OUT(1 draws the saddle layer); EF7-STRIDER-SADDLE-TEXTURE IN() path(out X(120)). Layers STRIDER, STRIDER_BABY, STRIDER_SADDLE through EF7-LAYER.
'''
def brist(a,b,c,idx):
    return '''     COMPUTE MM-CXROT(WS-X) = MM-CXROT(WS-X)
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-STRIDER-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-B                   BINARY-LONG.
 01 WS-LL                  BINARY-LONG.
 01 WS-RL                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-M1                  BINARY-LONG.
 01 WS-B1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-M2                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-G                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-B
     MOVE "left_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LL
     MOVE "right_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RL
     MOVE L-I(4) TO WS-S
     IF WS-S > 0.25
         MOVE 0.25 TO WS-S
     END-IF
     IF L-I(6) = 0
         COMPUTE MM-CXROT(WS-B) = L-I(1) * 0.017453292
         COMPUTE MM-CYROT(WS-B) = L-I(2) * 0.017453292
     END-IF
     COMPUTE MM-CZROT(WS-B) = 0.1 * FUNCTION SIN(1.5 * L-I(3)) * 4 * WS-S
     COMPUTE MM-CXROT(WS-LL) = FUNCTION SIN(1.5 * L-I(3) * 0.5) * 2 * WS-S
     COMPUTE MM-CXROT(WS-RL) = FUNCTION SIN(1.5 * L-I(3) * 0.5 + 3.141592653589793) * 2 * WS-S
     COMPUTE MM-CZROT(WS-LL) = 0.17453292 * FUNCTION COS(1.5 * L-I(3) * 0.5) * WS-S
     COMPUTE MM-CZROT(WS-RL) = 0.17453292 * FUNCTION COS(1.5 * L-I(3) * 0.5 + 3.141592653589793) * WS-S
     COMPUTE WS-BASE = FUNCTION COS(1.5 * L-I(3) + 3.141592653589793) * WS-S
     IF L-I(7) = 0
         PERFORM ADULT-CUSTOM
     ELSE
         PERFORM BABY-CUSTOM
     END-IF
     GO TO PROGRAM-DONE.

 ADULT-CUSTOM.
     MOVE "right_top_bristle" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T1
     MOVE "right_middle_bristle" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-M1
     MOVE "right_bottom_bristle" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-B1
     MOVE "left_top_bristle" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T2
     MOVE "left_middle_bristle" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-M2
     MOVE "left_bottom_bristle" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-B2
     MOVE -0.87266463 TO MM-CZROT(WS-T1)
     MOVE -1.134464 TO MM-CZROT(WS-M1)
     MOVE -1.2217305 TO MM-CZROT(WS-B1)
     MOVE 0.87266463 TO MM-CZROT(WS-T2)
     MOVE 1.134464 TO MM-CZROT(WS-M2)
     MOVE 1.2217305 TO MM-CZROT(WS-B2)
     COMPUTE MM-CZROT(WS-T1) = MM-CZROT(WS-T1) + 0.6 * WS-BASE + 0.1 * FUNCTION SIN(0.4 * L-I(5))
     COMPUTE MM-CZROT(WS-M1) = MM-CZROT(WS-M1) + 1.2 * WS-BASE + 0.1 * FUNCTION SIN(0.2 * L-I(5))
     COMPUTE MM-CZROT(WS-B1) = MM-CZROT(WS-B1) + 1.3 * WS-BASE + 0.05 * FUNCTION SIN(-0.4 * L-I(5))
     COMPUTE MM-CZROT(WS-T2) = MM-CZROT(WS-T2) + 0.6 * WS-BASE + 0.1 * FUNCTION SIN(0.4 * L-I(5))
     COMPUTE MM-CZROT(WS-M2) = MM-CZROT(WS-M2) + 1.2 * WS-BASE + 0.1 * FUNCTION SIN(0.2 * L-I(5))
     COMPUTE MM-CZROT(WS-B2) = MM-CZROT(WS-B2) + 1.3 * WS-BASE + 0.05 * FUNCTION SIN(-0.4 * L-I(5))
     COMPUTE MM-CY(WS-B) = 2 - 2 * FUNCTION COS(1.5 * L-I(3)) * 2 * WS-S
     COMPUTE MM-CY(WS-LL) = 8 + 2 * FUNCTION SIN(1.5 * L-I(3) * 0.5 + 3.141592653589793) * 2 * WS-S
     COMPUTE MM-CY(WS-RL) = 8 + 2 * FUNCTION SIN(1.5 * L-I(3) * 0.5) * 2 * WS-S.

 BABY-CUSTOM.
     MOVE "bristle2" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T1
     MOVE "bristle1" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-M1
     MOVE "bristle0" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-B1
     COMPUTE MM-CY(WS-B) = 17.25 - 2 * FUNCTION COS(1.5 * L-I(3)) * WS-S
     COMPUTE MM-CY(WS-LL) = 20 + 2 * FUNCTION SIN(1.5 * L-I(3) * 0.5 + 3.141592653589793) * 2 * WS-S
     COMPUTE MM-CY(WS-RL) = 20 + 2 * FUNCTION SIN(1.5 * L-I(3) * 0.5) * 2 * WS-S
     COMPUTE MM-CXROT(WS-T1) = MM-CXROT(WS-T1) + 0.6 * WS-BASE + 0.1 * FUNCTION SIN(0.4 * L-I(5))
     COMPUTE MM-CXROT(WS-M1) = MM-CXROT(WS-M1) + 1.2 * WS-BASE + 0.1 * FUNCTION SIN(0.2 * L-I(5))
     COMPUTE MM-CXROT(WS-B1) = MM-CXROT(WS-B1) + 1.3 * WS-BASE + 0.05 * FUNCTION SIN(-0.4 * L-I(5)).

 PROGRAM-DONE.
     GOBACK.
 END PROGRAM EF7-STRIDER-ANIM.

'''
extra+=pathprog('EF7-STRIDER-TEXTURE',[],default='x') if False else ''
extra+=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-STRIDER-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE TRUE
         WHEN L-I(1) NOT = 0 AND L-I(2) NOT = 0
             MOVE "textures/entity/strider/strider_cold_baby.png" TO L-PATH
         WHEN L-I(1) NOT = 0
             MOVE "textures/entity/strider/strider_cold.png" TO L-PATH
         WHEN L-I(2) NOT = 0
             MOVE "textures/entity/strider/strider_baby.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/strider/strider.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-STRIDER-TEXTURE.

'''
extra+=prog('EF7-STRIDER-SHADOW','     COMPUTE L-O(1) = 0.5 * L-I(2)\n     IF L-I(1) NOT = 0\n         COMPUTE L-O(1) = L-O(1) * 0.5\n     END-IF\n')
extra+=prog('EF7-STRIDER-SHAKING','     MOVE 0 TO L-O(1)\n     IF L-I(1) NOT = 0 OR L-I(2) NOT = 0\n         MOVE 1 TO L-O(1)\n     END-IF\n')
extra+=prog('EF7-STRIDER-SADDLE','     MOVE 0 TO L-O(1)\n     IF L-I(1) NOT = 0 AND L-I(2) NOT = 0 AND L-I(3) = 0\n         MOVE 1 TO L-O(1)\n     END-IF\n')
extra+=' IDENTIFICATION DIVISION.\n PROGRAM-ID. EF7-STRIDER-SADDLE-TEXTURE.\n DATA DIVISION.\n LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-PATH                 PIC X(120).\n PROCEDURE DIVISION USING L-IN L-PATH.\n     MOVE "textures/entity/equipment/strider_saddle/saddle.png" TO L-PATH\n     GOBACK.\n END PROGRAM EF7-STRIDER-SADDLE-TEXTURE.\n\n'
write_section_src(4,hdr,['STRIDER','STRIDER_BABY'],extra); write_layers(['STRIDER','STRIDER_BABY','STRIDER_SADDLE'])
