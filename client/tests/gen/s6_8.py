from warden6 import *
import kfgen
define()
hdr='''*> Entity models part 6 section 8 (Warden): the mesh and the four emissive layer meshes (8.1, 8.5), setupAnim with the six WardenAnimation definitions as rows (8.2, 8.6), render state, heartbeat, events and pose changes (8.3), textures and the layer alpha rule (8.4, 8.5).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-WARDEN-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 ageInTicks, 6 tendrilAnimation, 7 attack start tick, 8 sonic boom start, 9 dig start, 10 emerge start, 11 roar start, 12 sniff start; -2147483648 is stopped):
*>   reset first, then the steps of 8.2 in order, the layer models run the same program; EF6-WARDEN-RENDER-STATE IN(partial, old tendril, tendril, old heart, heart) OUT(tendrilAnimation, heartAnimation) (each lerp / 10: the old and current counters);
*>   EF6-WARDEN-HEARTBEAT IN(anger level) OUT(delay in ticks); EF6-WARDEN-TICK IN(tickCount, delay, tendril, heart) OUT(old tendril, tendril, old heart, heart, beat); EF6-WARDEN-EVENT IN(event id, tickCount, tendril, roar start, attack start, sonic start) OUT(tendril, roar start, attack start, sonic start);
*>   EF6-WARDEN-POSE IN(pose 1 EMERGING 2 DIGGING 3 ROARING 4 SNIFFING, tickCount, emerge, dig, roar, sniff start) OUT(the four starts); EF6-WARDEN-TEXTURE IN(0 main, 1 to 5 layer) path(out X(120));
*>   EF6-WARDEN-LAYER-ALPHA IN(layer 1 to 5, ageInTicks, tendrilAnimation, heartAnimation, invisible) OUT(draw, alpha). Layers: WARDEN_BIOLUMINESCENT, WARDEN_PULSATING_SPOTS, WARDEN_TENDRILS, WARDEN_HEART through EF6-LAYER (EF6-RETAIN mode 1).
*>   Keyframes EF6W-ANIM-*: ordinals 1 WARDEN_EMERGE 2 WARDEN_DIG 3 WARDEN_ROAR 4 WARDEN_SNIFF 5 WARDEN_ATTACK 6 WARDEN_SONIC_BOOM; -DEF ordinal EM5-DEF ok(out), -NAME, -INFO IN(ordinal) OUT(length, looping, channels), -BONE, -EVAL IN(ordinal, channel, t, scale) OUT(x y z), -APPLY EMM-MODEL ordinal ms scale ok(out).
'''
kf=kfgen.gen('EF6W',NM,AN,[''])
def blk(nm,start):
    return '''     IF L-I(%d) NOT = -2147483648
         MOVE L-I(%d) TO WS-START
         MOVE L-I(5) TO WS-AV(1)
         CALL "EM5-STATE" USING WS-OP WS-START WS-A WS-R
         MOVE WS-R TO WS-MS
         MOVE %d TO WS-ORD
         CALL "EF6W-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-ONE WS-OK
     END-IF
'''%(start,start,NM.index(nm)+1)
def prog(name,body,ws=''):
    s=' IDENTIFICATION DIVISION.\n PROGRAM-ID. %s.\n DATA DIVISION.\n'%name
    if ws: s+=' WORKING-STORAGE SECTION.\n'+ws
    s+=' LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-OUT.\n    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.\n PROCEDURE DIVISION USING L-IN L-OUT.\n'+body+'     GOBACK.\n END PROGRAM %s.\n\n'%name
    return s
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-WARDEN-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-H                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-LA                  BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-LL                  BINARY-LONG.
 01 WS-RL                  BINARY-LONG.
 01 WS-LT                  BINARY-LONG.
 01 WS-RT                  BINARY-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-M2                  FLOAT-LONG.
 01 WS-AA                  FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-OP                  BINARY-LONG VALUE 6.
 01 WS-START               BINARY-LONG.
 01 WS-A.
    05 WS-AV               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-R                   FLOAT-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-ORD                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
'''
for n,v in (('head','WS-H'),('body','WS-B'),('left_arm','WS-LA'),('right_arm','WS-RA'),('left_leg','WS-LL'),('right_leg','WS-RL'),('left_tendril','WS-LT'),('right_tendril','WS-RT')):
    extra+='     MOVE "%s" TO WS-NAME\n     CALL "EMM-FIND" USING EMM-MODEL WS-NAME %s\n'%(n,v)
extra+=r'''     COMPUTE MM-CXROT(WS-H) = L-I(1) * 0.017453292
     COMPUTE MM-CYROT(WS-H) = L-I(2) * 0.017453292
     COMPUTE WS-P = L-I(3) * 0.8662
     COMPUTE WS-M = 3 * L-I(4)
     IF WS-M > 0.5
         MOVE 0.5 TO WS-M
     END-IF
     MOVE WS-M TO WS-M2
     IF WS-M2 > 0.35
         MOVE 0.35 TO WS-M2
     END-IF
     COMPUTE MM-CZROT(WS-H) = MM-CZROT(WS-H) + 0.3 * FUNCTION SIN(WS-P) * WS-M
     COMPUTE MM-CXROT(WS-H) = MM-CXROT(WS-H) + 1.2 * FUNCTION COS(WS-P + 1.5707964) * WS-M2
     COMPUTE MM-CZROT(WS-B) = 0.1 * FUNCTION SIN(WS-P) * WS-M
     COMPUTE MM-CXROT(WS-B) = 1.0 * FUNCTION COS(WS-P) * WS-M2
     COMPUTE MM-CXROT(WS-LL) = FUNCTION COS(WS-P) * WS-M
     COMPUTE MM-CXROT(WS-RL) = FUNCTION COS(WS-P + 3.1415927) * WS-M
     COMPUTE MM-CXROT(WS-LA) = 0 - (0.8 * FUNCTION COS(WS-P) * WS-M)
     MOVE 0 TO MM-CZROT(WS-LA)
     COMPUTE MM-CXROT(WS-RA) = 0 - (0.8 * FUNCTION SIN(WS-P) * WS-M)
     MOVE 0 TO MM-CZROT(WS-RA)
     MOVE 0 TO MM-CYROT(WS-LA) MM-CYROT(WS-RA)
     MOVE 1 TO MM-CZ(WS-LA) MM-CZ(WS-RA)
     MOVE 13 TO MM-CX(WS-LA)
     MOVE -13 TO MM-CY(WS-LA) MM-CY(WS-RA) MM-CX(WS-RA)
     COMPUTE WS-AA = L-I(5) * 0.1
     COMPUTE MM-CZROT(WS-H) = MM-CZROT(WS-H) + 0.06 * FUNCTION COS(WS-AA)
     COMPUTE MM-CXROT(WS-H) = MM-CXROT(WS-H) + 0.06 * FUNCTION SIN(WS-AA)
     COMPUTE MM-CZROT(WS-B) = MM-CZROT(WS-B) + 0.025 * FUNCTION SIN(WS-AA)
     COMPUTE MM-CXROT(WS-B) = MM-CXROT(WS-B) + 0.025 * FUNCTION COS(WS-AA)
     COMPUTE WS-V = L-I(6) * (FUNCTION COS(L-I(5) * 2.25) * 3.141592653589793 * 0.10000000149011612)
     MOVE WS-V TO MM-CXROT(WS-LT)
     COMPUTE MM-CXROT(WS-RT) = 0 - WS-V
'''
for nm,st in (('WARDEN_ATTACK',7),('WARDEN_SONIC_BOOM',8),('WARDEN_DIG',9),('WARDEN_EMERGE',10),('WARDEN_ROAR',11),('WARDEN_SNIFF',12)): extra+=blk(nm,st)
extra+=r'''     GOBACK.
 END PROGRAM EF6-WARDEN-ANIM.

'''
extra+=prog('EF6-WARDEN-RENDER-STATE','''     COMPUTE L-O(1) = (L-I(2) + L-I(1) * (L-I(3) - L-I(2))) / 10
     COMPUTE L-O(2) = (L-I(4) + L-I(1) * (L-I(5) - L-I(4))) / 10
''')
extra+=prog('EF6-WARDEN-HEARTBEAT','''     COMPUTE WS-C = L-I(1) / 80
     IF WS-C < 0
         MOVE 0 TO WS-C
     END-IF
     IF WS-C > 1
         MOVE 1 TO WS-C
     END-IF
     COMPUTE L-O(1) = 40 - FUNCTION INTEGER(WS-C * 30)
''',' 01 WS-C                   FLOAT-LONG.\n')
extra+=prog('EF6-WARDEN-TICK','''     MOVE 0 TO L-O(5)
     MOVE L-I(4) TO L-O(4)
     IF FUNCTION MOD(L-I(1), L-I(2)) = 0
         MOVE 10 TO L-O(4)
         MOVE 1 TO L-O(5)
     END-IF
     MOVE L-I(3) TO L-O(1) L-O(2)
     IF L-O(2) > 0
         COMPUTE L-O(2) = L-O(2) - 1
     END-IF
     MOVE L-O(4) TO L-O(3)
     IF L-O(4) > 0
         COMPUTE L-O(4) = L-O(4) - 1
     END-IF
''')
extra+=prog('EF6-WARDEN-EVENT','''     MOVE L-I(3) TO L-O(1)
     MOVE L-I(4) TO L-O(2)
     MOVE L-I(5) TO L-O(3)
     MOVE L-I(6) TO L-O(4)
     EVALUATE L-I(1)
         WHEN 4
             MOVE -2147483648 TO L-O(2)
             MOVE L-I(2) TO L-O(3)
         WHEN 61
             MOVE 10 TO L-O(1)
         WHEN 62
             MOVE L-I(2) TO L-O(4)
     END-EVALUATE
''')
extra+=prog('EF6-WARDEN-POSE','''     MOVE L-I(3) TO L-O(1)
     MOVE L-I(4) TO L-O(2)
     MOVE L-I(5) TO L-O(3)
     MOVE L-I(6) TO L-O(4)
     IF L-I(1) >= 1 AND L-I(1) <= 4
         COMPUTE WS-IDX = L-I(1)
         MOVE L-I(2) TO L-O(WS-IDX)
     END-IF
''',' 01 WS-IDX                 BINARY-LONG.\n')
extra+=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-WARDEN-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE L-I(1)
         WHEN 1
             MOVE "textures/entity/warden/warden_bioluminescent_layer.png" TO L-PATH
         WHEN 2
             MOVE "textures/entity/warden/warden_pulsating_spots_1.png" TO L-PATH
         WHEN 3
             MOVE "textures/entity/warden/warden_pulsating_spots_2.png" TO L-PATH
         WHEN 4
             MOVE "textures/entity/warden/warden.png" TO L-PATH
         WHEN 5
             MOVE "textures/entity/warden/warden_heart.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/warden/warden.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-WARDEN-TEXTURE.

'''
extra+=prog('EF6-WARDEN-LAYER-ALPHA','''     MOVE 0 TO L-O(1) L-O(2)
     IF L-I(5) = 0
         EVALUATE L-I(1)
             WHEN 1
                 MOVE 1 TO WS-AL
             WHEN 2
                 COMPUTE WS-AL = FUNCTION COS(L-I(2) * 0.045) * 0.25
             WHEN 3
                 COMPUTE WS-AL = FUNCTION COS(L-I(2) * 0.045 + 3.1415927) * 0.25
             WHEN 4
                 MOVE L-I(3) TO WS-AL
             WHEN OTHER
                 MOVE L-I(4) TO WS-AL
         END-EVALUATE
         IF WS-AL < 0
             MOVE 0 TO WS-AL
         END-IF
         IF WS-AL > 0.00001
             MOVE 1 TO L-O(1)
             MOVE WS-AL TO L-O(2)
         END-IF
     END-IF
''',' 01 WS-AL                  FLOAT-LONG.\n')
write_section_src(8,hdr,IDS,extra+'\n'+kf); write_layers(IDS)
