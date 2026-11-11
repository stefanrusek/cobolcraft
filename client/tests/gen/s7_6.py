from wither7 import *
from prog6 import *
define()
hdr='''*> Entity models part 7 section 6 (The Wither): the WITHER and WITHER_ARMOR meshes and the skull mesh (6.1, 6.4), setupAnim (6.1), size, textures (6.2), the power swirl (6.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF7-WITHER-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 ageInTicks, 4 bodyRot, 5 yHeadRots[0], 6 xHeadRots[0], 7 yHeadRots[1], 8 xHeadRots[1]): reset first, heads, ribcage, tail (the armor model runs the same program);
*>   EF7-WITHER-SCALE IN(invulnerable ticks) OUT(uniform scale 2.0 reduced by ticks/220 x 0.5); EF7-WITHER-TEXTURE IN(invulnerable ticks, armor) path(out X(120)); EF7-WITHER-SWIRL IN(ageInTicks, powered) OUT(draw, u, v, tint, order);
*>   EF7-WITHER-INV IN(getInvulnerableTicks, partial) OUT(invulnerableTicks of the state); EF7-WITHER-SKULL-TEXTURE IN(dangerous) path(out X(120)); EF7-WITHER-RENDER IN() OUT(shadow radius, block light, skull block light).
*>   Layers WITHER, WITHER_ARMOR, WITHER_SKULL through EF7-LAYER.
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-WITHER-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-RH                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-RIB                 BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-CH                  BINARY-LONG.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "right_head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RH
     MOVE "left_head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LH
     MOVE "ribcage" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RIB
     MOVE "tail" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-TAIL
     MOVE "center_head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-CH
     COMPUTE WS-C = FUNCTION COS(L-I(3) * 0.1)
     COMPUTE MM-CYROT(WS-RH) = (L-I(5) - L-I(4)) * 0.017453292
     COMPUTE MM-CXROT(WS-RH) = L-I(6) * 0.017453292
     COMPUTE MM-CYROT(WS-LH) = (L-I(7) - L-I(4)) * 0.017453292
     COMPUTE MM-CXROT(WS-LH) = L-I(8) * 0.017453292
     COMPUTE MM-CXROT(WS-RIB) = (0.065 + 0.05 * WS-C) * 3.141592653589793
     COMPUTE MM-CY(WS-TAIL) = 6.9 + FUNCTION COS(MM-CXROT(WS-RIB)) * 10
     COMPUTE MM-CZ(WS-TAIL) = -0.5 + FUNCTION SIN(MM-CXROT(WS-RIB)) * 10
     COMPUTE MM-CXROT(WS-TAIL) = (0.265 + 0.1 * WS-C) * 3.141592653589793
     COMPUTE MM-CYROT(WS-CH) = L-I(2) * 0.017453292
     COMPUTE MM-CXROT(WS-CH) = L-I(1) * 0.017453292
     GOBACK.
 END PROGRAM EF7-WITHER-ANIM.

'''
extra+=prog('EF7-WITHER-SCALE','     MOVE 2 TO L-O(1)\n     IF L-I(1) > 0\n         COMPUTE L-O(1) = 2 - L-I(1) / 220 * 0.5\n     END-IF\n')
extra+=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-WITHER-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     IF L-I(2) NOT = 0
         MOVE "textures/entity/wither/wither_armor.png" TO L-PATH
         GOBACK
     END-IF
     COMPUTE WS-N = FUNCTION INTEGER(L-I(1))
     EVALUATE TRUE
         WHEN WS-N <= 0
             MOVE "textures/entity/wither/wither.png" TO L-PATH
         WHEN WS-N > 80
             MOVE "textures/entity/wither/wither_invulnerable.png" TO L-PATH
         WHEN FUNCTION MOD(FUNCTION INTEGER-PART(WS-N / 5), 2) = 1
             MOVE "textures/entity/wither/wither.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/wither/wither_invulnerable.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-WITHER-TEXTURE.

'''
extra+=prog('EF7-WITHER-SWIRL','''     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     MOVE -8355712 TO L-O(4)
     MOVE 1 TO L-O(5)
     IF L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
         COMPUTE L-O(2) = FUNCTION REM(FUNCTION COS(0.02 * L-I(1)) * 3, 1)
         COMPUTE L-O(3) = FUNCTION MOD(0.01 * L-I(1), 1)
     END-IF
''')
extra+=prog('EF7-WITHER-INV','     MOVE 0 TO L-O(1)\n     IF L-I(1) > 0\n         COMPUTE L-O(1) = L-I(1) - L-I(2)\n     END-IF\n')
extra+=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-WITHER-SKULL-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     IF L-I(1) NOT = 0
         MOVE "textures/entity/wither/wither_invulnerable.png" TO L-PATH
     ELSE
         MOVE "textures/entity/wither/wither.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF7-WITHER-SKULL-TEXTURE.

'''
extra+=prog('EF7-WITHER-RENDER','     MOVE 1 TO L-O(1)\n     MOVE 15 TO L-O(2) L-O(3)\n')
write_section_src(6,hdr,['WITHER','WITHER_ARMOR','WITHER_SKULL'],extra); write_layers(['WITHER','WITHER_ARMOR','WITHER_SKULL'])
