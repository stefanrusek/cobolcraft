from mesh5 import *
IDS=['BEE','BEE_BABY','BEE_STINGER']
hdr='''*> Entity models part 5 section 9 (Bee): the meshes of the adult, the baby and the stinger (9.1), setupAnim (9.2), textures, shadow, on-ground rule and roll counter (9.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-BEE-ANIM EMM-MODEL state(1 ageInTicks, 2 hasStinger, 3 on ground, 4 angry, 5 rollAmount, 6 baby model): reset first, then the steps of 9.2; EF5-BEE-TEXTURE IN(angry, nectar, baby) path(out X(120));
*>   EF5-BEE-SHADOW IN() OUT(radius); EF5-BEE-ONGROUND IN(on ground, squared speed) OUT(1 when on ground and the squared speed < 1e-7); EF5-BEE-ROLL-LERP IN(partial, old, current) OUT(rollAmount);
*>   EF5-BEE-ROLL-TICK IN(roll, rolling) OUT(old roll, new roll): +0.2 (max 1) while rolling, else -0.24 (min 0).
'''
def mv(n,var): return '     MOVE "%s" TO WS-NAME\n     CALL "EMM-FIND" USING EMM-MODEL WS-NAME %s\n'%(n,var)
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEE-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-BONE                BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-RW                  BINARY-LONG.
 01 WS-LW                  BINARY-LONG.
 01 WS-FL                  BINARY-LONG.
 01 WS-ML                  BINARY-LONG.
 01 WS-BL                  BINARY-LONG.
 01 WS-LA                  BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-IN2.
    05 WS-IV2              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OUT2.
    05 WS-OV2              FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
'''
for n,v in (('bone','WS-BONE'),('stinger','WS-ST'),('right_wing','WS-RW'),('left_wing','WS-LW'),('front_legs','WS-FL'),('middle_legs','WS-ML'),('back_legs','WS-BL')): extra+=mv(n,v)
extra+=r'''     IF L-I(6) = 0
         MOVE "left_antenna" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LA
         MOVE "right_antenna" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RA
     END-IF
     MOVE 0 TO MM-VISIBLE(WS-ST)
     IF L-I(2) NOT = 0
         MOVE 1 TO MM-VISIBLE(WS-ST)
     END-IF
     IF L-I(3) = 0
         COMPUTE WS-W = L-I(1) * 120.32113 * 0.017453292
         MOVE 0 TO MM-CYROT(WS-RW)
         COMPUTE MM-CZROT(WS-RW) = FUNCTION COS(WS-W) * 3.141592653589793 * 0.15
         MOVE MM-CXROT(WS-RW) TO MM-CXROT(WS-LW)
         MOVE MM-CYROT(WS-RW) TO MM-CYROT(WS-LW)
         COMPUTE MM-CZROT(WS-LW) = 0 - MM-CZROT(WS-RW)
         MOVE 0.7853982 TO MM-CXROT(WS-FL) MM-CXROT(WS-ML) MM-CXROT(WS-BL)
         IF L-I(4) = 0
             COMPUTE WS-C = FUNCTION COS(0.18 * L-I(1))
             COMPUTE MM-CXROT(WS-BONE) = 0.1 + WS-C * 3.141592653589793 * 0.025
             COMPUTE MM-CY(WS-BONE) = MM-CY(WS-BONE) - FUNCTION COS(0.18 * L-I(1)) * 0.9
             COMPUTE MM-CXROT(WS-FL) = 0 - WS-C * 3.141592653589793 * 0.1 + 0.3926991
             COMPUTE MM-CXROT(WS-BL) = 0 - WS-C * 3.141592653589793 * 0.05 + 0.7853982
             IF L-I(6) = 0
                 COMPUTE MM-CXROT(WS-LA) = WS-C * 3.141592653589793 * 0.03
                 MOVE MM-CXROT(WS-LA) TO MM-CXROT(WS-RA)
             END-IF
         END-IF
     END-IF
     IF L-I(5) > 0
         MOVE L-I(5) TO WS-IV2(1)
         MOVE MM-CXROT(WS-BONE) TO WS-IV2(2)
         MOVE 3.0915928 TO WS-IV2(3)
         CALL "EF5-ROT-LERP-RAD" USING WS-IN2 WS-OUT2
         MOVE WS-OV2(1) TO MM-CXROT(WS-BONE)
     END-IF
     GOBACK.
 END PROGRAM EF5-BEE-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEE-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE SPACES TO L-PATH
     EVALUATE TRUE
         WHEN L-I(1) NOT = 0 AND L-I(2) NOT = 0
             MOVE "textures/entity/bee/bee_angry_nectar" TO L-PATH
         WHEN L-I(1) NOT = 0
             MOVE "textures/entity/bee/bee_angry" TO L-PATH
         WHEN L-I(2) NOT = 0
             MOVE "textures/entity/bee/bee_nectar" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/bee/bee" TO L-PATH
     END-EVALUATE
     IF L-I(3) NOT = 0
         STRING FUNCTION TRIM(L-PATH) "_baby.png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING FUNCTION TRIM(L-PATH) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-BEE-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEE-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0.4 TO L-O(1)
     GOBACK.
 END PROGRAM EF5-BEE-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEE-ONGROUND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0 AND L-I(2) < 0.0000001
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF5-BEE-ONGROUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEE-ROLL-LERP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(2) + L-I(1) * (L-I(3) - L-I(2))
     GOBACK.
 END PROGRAM EF5-BEE-ROLL-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEE-ROLL-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO L-O(1)
     IF L-I(2) NOT = 0
         COMPUTE L-O(2) = L-I(1) + 0.2
         IF L-O(2) > 1
             MOVE 1 TO L-O(2)
         END-IF
     ELSE
         COMPUTE L-O(2) = L-I(1) - 0.24
         IF L-O(2) < 0
             MOVE 0 TO L-O(2)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF5-BEE-ROLL-TICK.
'''
write_section_src(9,hdr,IDS,extra); write_layers(IDS)
