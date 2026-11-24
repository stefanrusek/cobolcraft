from dragon7 import *
from prog6 import *
define()
hdr='''*> Entity models part 7 section 8 (Ender Dragon): the flight history (8.1), the state extraction and head offset (8.2), the 36 part mesh (8.3), setupAnim (8.4), pose stack and passes (8.5), death rays (8.6), the crystal beam (8.7), the flap time update (8.8).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)). The history is a group: head BINARY-LONG, 64 y FLOAT-LONG, 64 yRot FLOAT-LONG (client/src/entmodel-34-7-8.cob, EF7-HIST-*).
*>   EF7-HIST-INIT hist; EF7-HIST-RECORD hist y yRot; EF7-HIST-GET hist n(BINARY-LONG) y yRot (out FLOAT-LONG); EF7-HIST-GETI hist n t(FLOAT-LONG) y yRot (out): get(n, t) interpolated;
*>   EF7-DRAGON-OFFSET IN(i, a y, b y, landing or taking off, sitting, distance to egg) OUT(getHeadPartYOffset); EF7-DRAGON-STATE IN(partial, old flap, flap, dragonDeathTime, dying, hurtTime) OUT(flapTime, deathTime, red overlay, partialTicks);
*>   EF7-DRAGON-ANIM EMM-MODEL hist state(1 flapTime, 2 partialTicks, 3 landing or taking off, 4 sitting, 5 distanceToEgg): reset first, then steps 1 to 10 of 8.4 (root part 1 moved);
*>   EF7-DRAGON-POSE-OPS IN(yaw(7), y(5), y(10)) OUT(count, ops: code 1 translate, 2 scale, 3 rotate Y deg, 6 rotate X deg, values); EF7-DRAGON-PASSES IN(deathTime, red overlay, has beam) OUT(dissolve pass, alpha, overlay v, eyes pass, rays pass, ray p, beam);
*>   EF7-DRAGON-TEXTURE IN(0 dragon 1 exploding mask 2 eyes) path(out X(120)); EF7-DRAGON-RAY-COUNT IN(p) OUT(rays); EF7-DRAGON-RAY-COLOR IN(p) OUT(g, centre alpha); EF7-DRAGON-RAY IN(p, ray index from 1) OUT(six angles in radians, length, width) from the generator seeded 432;
*>   EF7-DRAGON-RAY-VERTS IN(L, W) OUT(nine vertices x y z); EF7-BEAM IN(x y z, age) OUT(h, len, rotate Y radians, rotate X radians, v0, v1); EF7-BEAM-QUAD IN(k 1 to 8, len, age) OUT(four vertices x y z colour u v);
*>   EF7-DRAGON-FLAP IN(sitting, in wall, horizontal speed, vertical velocity, flapTime) OUT(flapTime); EF7-DRAGON-BEAM-OFFSET IN(crystal x y z, crystal time + partial, dragon x y z) OUT(x y z); EF7-DRAGON-DIST IN(egg block x y z, dragon x y z) OUT(squared distance to the block centre).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HIST-INIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HIST.
    05 L-HEAD              BINARY-LONG.
    05 L-HY                FLOAT-LONG OCCURS 64 TIMES.
    05 L-HR                FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-HIST.
     MOVE -1 TO L-HEAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 0 TO L-HY(WS-I) L-HR(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM EF7-HIST-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HIST-RECORD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HIST.
    05 L-HEAD              BINARY-LONG.
    05 L-HY                FLOAT-LONG OCCURS 64 TIMES.
    05 L-HR                FLOAT-LONG OCCURS 64 TIMES.
 01 L-Y                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-HIST L-Y L-R.
     IF L-HEAD < 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
             MOVE L-Y TO L-HY(WS-I)
             MOVE L-R TO L-HR(WS-I)
         END-PERFORM
     END-IF
     ADD 1 TO L-HEAD
     IF L-HEAD = 64
         MOVE 0 TO L-HEAD
     END-IF
     MOVE L-Y TO L-HY(L-HEAD + 1)
     MOVE L-R TO L-HR(L-HEAD + 1)
     GOBACK.
 END PROGRAM EF7-HIST-RECORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HIST-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HIST.
    05 L-HEAD              BINARY-LONG.
    05 L-HY                FLOAT-LONG OCCURS 64 TIMES.
    05 L-HR                FLOAT-LONG OCCURS 64 TIMES.
 01 L-N                    BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-HIST L-N L-Y L-R.
     COMPUTE WS-I = FUNCTION MOD(L-HEAD - L-N, 64) + 1
     MOVE L-HY(WS-I) TO L-Y
     MOVE L-HR(WS-I) TO L-R
     GOBACK.
 END PROGRAM EF7-HIST-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HIST-GETI.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N1                  BINARY-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AR                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BR                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-HIST.
    05 L-HEAD              BINARY-LONG.
    05 L-HY                FLOAT-LONG OCCURS 64 TIMES.
    05 L-HR                FLOAT-LONG OCCURS 64 TIMES.
 01 L-N                    BINARY-LONG.
 01 L-T                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-HIST L-N L-T L-Y L-R.
     COMPUTE WS-N1 = L-N + 1
     CALL "EF7-HIST-GET" USING L-HIST WS-N1 WS-AY WS-AR
     CALL "EF7-HIST-GET" USING L-HIST L-N WS-BY WS-BR
     COMPUTE L-Y = WS-AY + L-T * (WS-BY - WS-AY)
     COMPUTE WS-D = FUNCTION REM(WS-BR - WS-AR, 360)
     IF WS-D >= 180
         COMPUTE WS-D = WS-D - 360
     END-IF
     IF WS-D < -180
         COMPUTE WS-D = WS-D + 360
     END-IF
     COMPUTE L-R = WS-AR + L-T * WS-D
     GOBACK.
 END PROGRAM EF7-HIST-GETI.

'''
extra+=prog('EF7-DRAGON-OFFSET','''     EVALUATE TRUE
         WHEN L-I(4) NOT = 0
             COMPUTE WS-Q = L-I(6) / 4
             IF WS-Q < 1
                 MOVE 1 TO WS-Q
             END-IF
             COMPUTE L-O(1) = L-I(1) / WS-Q
         WHEN L-I(5) NOT = 0
             MOVE L-I(1) TO L-O(1)
         WHEN L-I(1) = 6
             MOVE 0 TO L-O(1)
         WHEN OTHER
             COMPUTE L-O(1) = L-I(3) - L-I(2)
     END-EVALUATE
''',' 01 WS-Q                   FLOAT-LONG.\n')
extra+=prog('EF7-DRAGON-STATE','''     COMPUTE L-O(1) = L-I(2) + L-I(1) * (L-I(3) - L-I(2))
     MOVE 0 TO L-O(2) L-O(3)
     IF L-I(4) > 0
         COMPUTE L-O(2) = L-I(4) + L-I(1)
     END-IF
     IF L-I(6) > 0
         MOVE 1 TO L-O(3)
     END-IF
     MOVE L-I(1) TO L-O(4)
     IF L-I(5) NOT = 0
         MOVE 0 TO L-O(4)
     END-IF
''')
# the animation
anim=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-DRAGON-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-DIG                 PIC 99.
 01 WS-P                   BINARY-LONG.
 01 WS-JAW                 BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ACC                 FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AR                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BR                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CR                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TR                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-REF                 FLOAT-LONG.
 01 WS-WIN                 FLOAT-LONG.
 01 WS-WOUT                FLOAT-LONG.
 01 WS-OFF                 FLOAT-LONG.
 01 WS-OIN.
    05 WS-OI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OOUT.
    05 WS-OO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-PT                  FLOAT-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-SIDE                PIC X(5).
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-HIST.
    05 L-HEAD              BINARY-LONG.
    05 L-HY                FLOAT-LONG OCCURS 64 TIMES.
    05 L-HR                FLOAT-LONG OCCURS 64 TIMES.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-HIST L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE L-I(2) TO WS-PT
     COMPUTE WS-W = L-I(1) * 6.283185307179586
     MOVE "jaw" TO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CXROT(WS-P) = (FUNCTION SIN(WS-W) + 1) * 0.2
     COMPUTE WS-S = FUNCTION SIN(WS-W - 1) + 1
     COMPUTE WS-F = (WS-S * WS-S + 2 * WS-S) * 0.05
     COMPUTE MM-CY(1) = (WS-F - 2) * 16
     MOVE -48 TO MM-CZ(1)
     COMPUTE MM-CXROT(1) = WS-F * 2 * 0.017453292
     MOVE 0 TO WS-X
     MOVE 20 TO WS-Y
     MOVE -12 TO WS-Z
     MOVE 6 TO WS-N
     PERFORM GET-SAMPLE
     MOVE WS-TY TO WS-AY
     MOVE WS-TR TO WS-AR
     MOVE 5 TO WS-N
     PERFORM GET-SAMPLE
     MOVE WS-TR TO WS-BR
     MOVE 10 TO WS-N
     PERFORM GET-SAMPLE
     COMPUTE WS-WIN = WS-BR - WS-TR
     PERFORM WRAP-DEGREES
     MOVE WS-WOUT TO WS-D
     COMPUTE WS-WIN = WS-BR + WS-D / 2
     PERFORM WRAP-DEGREES
     MOVE WS-WOUT TO WS-REF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         COMPUTE WS-N = 5 - WS-I
         PERFORM GET-SAMPLE
         MOVE WS-TY TO WS-BY
         MOVE WS-TR TO WS-BR
         MOVE WS-I TO WS-DIG
         MOVE SPACES TO WS-NAME
         STRING "neck" WS-DIG(2:1) DELIMITED BY SIZE INTO WS-NAME
         PERFORM FIND-PART
         COMPUTE WS-WIN = WS-BR - WS-AR
         PERFORM WRAP-DEGREES
         COMPUTE MM-CYROT(WS-P) = WS-WOUT * 0.017453292 * 1.5
         MOVE WS-I TO WS-OI(1)
         MOVE WS-AY TO WS-OI(2)
         MOVE WS-BY TO WS-OI(3)
         PERFORM CALL-OFFSET
         COMPUTE MM-CXROT(WS-P) = FUNCTION COS(WS-I * 0.45 + WS-W) * 0.15 + WS-OFF * 0.017453292 * 1.5 * 5
         COMPUTE WS-WIN = WS-BR - WS-REF
         PERFORM WRAP-DEGREES
         COMPUTE MM-CZROT(WS-P) = 0 - WS-WOUT * 0.017453292 * 1.5
         MOVE WS-X TO MM-CX(WS-P)
         MOVE WS-Y TO MM-CY(WS-P)
         MOVE WS-Z TO MM-CZ(WS-P)
         COMPUTE WS-X = WS-X - FUNCTION SIN(MM-CYROT(WS-P)) * FUNCTION COS(MM-CXROT(WS-P)) * 10
         COMPUTE WS-Y = WS-Y + FUNCTION SIN(MM-CXROT(WS-P)) * 10
         COMPUTE WS-Z = WS-Z - FUNCTION COS(MM-CYROT(WS-P)) * FUNCTION COS(MM-CXROT(WS-P)) * 10
     END-PERFORM
     MOVE "head" TO WS-NAME
     PERFORM FIND-PART
     MOVE WS-X TO MM-CX(WS-P)
     MOVE WS-Y TO MM-CY(WS-P)
     MOVE WS-Z TO MM-CZ(WS-P)
     MOVE 0 TO WS-N
     PERFORM GET-SAMPLE
     MOVE WS-TY TO WS-CY
     MOVE WS-TR TO WS-CR
     COMPUTE WS-WIN = WS-CR - WS-AR
     PERFORM WRAP-DEGREES
     COMPUTE MM-CYROT(WS-P) = WS-WOUT * 0.017453292
     MOVE 6 TO WS-OI(1)
     MOVE WS-AY TO WS-OI(2)
     MOVE WS-CY TO WS-OI(3)
     PERFORM CALL-OFFSET
     MOVE WS-OFF TO WS-WIN
     PERFORM WRAP-DEGREES
     COMPUTE MM-CXROT(WS-P) = WS-WOUT * 0.017453292 * 1.5 * 5
     COMPUTE WS-WIN = WS-CR - WS-REF
     PERFORM WRAP-DEGREES
     COMPUTE MM-CZROT(WS-P) = 0 - WS-WOUT * 0.017453292
     MOVE "body" TO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CZROT(WS-P) = 0 - WS-D * 1.5 * 0.017453292
     MOVE "left_wing" TO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CXROT(WS-P) = 0.125 - FUNCTION COS(WS-W) * 0.2
     MOVE -0.25 TO MM-CYROT(WS-P)
     COMPUTE MM-CZROT(WS-P) = 0 - (FUNCTION SIN(WS-W) + 0.125) * 0.8
     MOVE WS-P TO WS-LEFT
     MOVE "left_wing_tip" TO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CZROT(WS-P) = (FUNCTION SIN(WS-W + 2) + 0.5) * 0.75
     MOVE "right_wing" TO WS-NAME
     PERFORM FIND-PART
     MOVE MM-CXROT(WS-LEFT) TO MM-CXROT(WS-P)
     COMPUTE MM-CYROT(WS-P) = 0 - MM-CYROT(WS-LEFT)
     COMPUTE MM-CZROT(WS-P) = 0 - MM-CZROT(WS-LEFT)
     MOVE "left_wing_tip" TO WS-NAME
     PERFORM FIND-PART
     MOVE WS-P TO WS-LEFT
     MOVE "right_wing_tip" TO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CZROT(WS-P) = 0 - MM-CZROT(WS-LEFT)
     MOVE "left" TO WS-SIDE
     PERFORM POSE-LIMBS
     MOVE "right" TO WS-SIDE
     PERFORM POSE-LIMBS
     MOVE 0 TO WS-ACC
     MOVE 0 TO WS-X
     MOVE 10 TO WS-Y
     MOVE 60 TO WS-Z
     MOVE 11 TO WS-N
     PERFORM GET-SAMPLE
     MOVE WS-TY TO WS-AY
     MOVE WS-TR TO WS-AR
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 11
         COMPUTE WS-N = 12 + WS-I
         PERFORM GET-SAMPLE
         MOVE WS-TY TO WS-BY
         MOVE WS-TR TO WS-BR
         COMPUTE WS-ACC = WS-ACC + FUNCTION SIN(WS-I * 0.45 + WS-W) * 0.05
         MOVE WS-I TO WS-DIG
         MOVE SPACES TO WS-NAME
         IF WS-I < 10
             STRING "tail" WS-DIG(2:1) DELIMITED BY SIZE INTO WS-NAME
         ELSE
             STRING "tail" WS-DIG DELIMITED BY SIZE INTO WS-NAME
         END-IF
         PERFORM FIND-PART
         COMPUTE WS-WIN = WS-BR - WS-AR
         PERFORM WRAP-DEGREES
         COMPUTE MM-CYROT(WS-P) = (WS-WOUT * 1.5 + 180) * 0.017453292
         COMPUTE MM-CXROT(WS-P) = WS-ACC + (WS-BY - WS-AY) * 0.017453292 * 1.5 * 5
         COMPUTE WS-WIN = WS-BR - WS-REF
         PERFORM WRAP-DEGREES
         COMPUTE MM-CZROT(WS-P) = WS-WOUT * 0.017453292 * 1.5
         MOVE WS-X TO MM-CX(WS-P)
         MOVE WS-Y TO MM-CY(WS-P)
         MOVE WS-Z TO MM-CZ(WS-P)
         COMPUTE WS-Y = WS-Y + FUNCTION SIN(MM-CXROT(WS-P)) * 10
         COMPUTE WS-Z = WS-Z - FUNCTION COS(MM-CYROT(WS-P)) * FUNCTION COS(MM-CXROT(WS-P)) * 10
         COMPUTE WS-X = WS-X - FUNCTION SIN(MM-CYROT(WS-P)) * FUNCTION COS(MM-CXROT(WS-P)) * 10
     END-PERFORM
     GO TO PROGRAM-DONE.

 FIND-PART.
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P.

 GET-SAMPLE.
     CALL "EF7-HIST-GETI" USING L-HIST WS-N WS-PT WS-TY WS-TR.

 WRAP-DEGREES.
     COMPUTE WS-WOUT = FUNCTION REM(WS-WIN, 360)
     IF WS-WOUT >= 180
         COMPUTE WS-WOUT = WS-WOUT - 360
     END-IF
     IF WS-WOUT < -180
         COMPUTE WS-WOUT = WS-WOUT + 360
     END-IF.

 CALL-OFFSET.
     MOVE L-I(3) TO WS-OI(4)
     MOVE L-I(4) TO WS-OI(5)
     MOVE L-I(5) TO WS-OI(6)
     MOVE WS-OI(1) TO WS-OFFI
     CALL "EF7-DRAGON-OFFSET" USING WS-OIN WS-OOUT
     MOVE WS-OO(1) TO WS-OFF.

 POSE-LIMBS.
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-SIDE) "_hind_leg" DELIMITED BY SIZE INTO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CXROT(WS-P) = 1.0 + WS-F * 0.1
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-SIDE) "_hind_leg_tip" DELIMITED BY SIZE INTO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CXROT(WS-P) = 0.5 + WS-F * 0.1
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-SIDE) "_hind_foot" DELIMITED BY SIZE INTO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CXROT(WS-P) = 0.75 + WS-F * 0.1
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-SIDE) "_front_leg" DELIMITED BY SIZE INTO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CXROT(WS-P) = 1.3 + WS-F * 0.1
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-SIDE) "_front_leg_tip" DELIMITED BY SIZE INTO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CXROT(WS-P) = -0.5 - WS-F * 0.1
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-SIDE) "_front_foot" DELIMITED BY SIZE INTO WS-NAME
     PERFORM FIND-PART
     COMPUTE MM-CXROT(WS-P) = 0.75 + WS-F * 0.1.

 PROGRAM-DONE.
     GOBACK.
 END PROGRAM EF7-DRAGON-ANIM.

'''
anim=anim.replace("     MOVE WS-OI(1) TO WS-OFFI\n","")
extra+=anim
extra+=prog('EF7-DRAGON-POSE-OPS','''     MOVE 5 TO L-O(1)
     MOVE 3 TO L-O(2)
     COMPUTE L-O(3) = 0 - L-I(1)
     MOVE 0 TO L-O(4) L-O(5)
     MOVE 6 TO L-O(6)
     COMPUTE L-O(7) = (L-I(2) - L-I(3)) * 10
     MOVE 0 TO L-O(8) L-O(9)
     MOVE 1 TO L-O(10)
     MOVE 0 TO L-O(11) L-O(12)
     MOVE 1 TO L-O(13)
     MOVE 2 TO L-O(14)
     MOVE -1 TO L-O(15) L-O(16)
     MOVE 1 TO L-O(17)
     MOVE 1 TO L-O(18)
     MOVE 0 TO L-O(19) L-O(21)
     MOVE -1.501 TO L-O(20)
''')
extra+=prog('EF7-DRAGON-PASSES','''     MOVE 0 TO L-O(1) L-O(5)
     MOVE 1 TO L-O(2) L-O(4)
     MOVE 10 TO L-O(3)
     IF L-I(2) NOT = 0
         MOVE 3 TO L-O(3)
     END-IF
     MOVE 0 TO L-O(6)
     IF L-I(1) > 0
         MOVE 1 TO L-O(1) L-O(5)
         COMPUTE L-O(2) = 1 - L-I(1) / 200
         COMPUTE L-O(6) = L-I(1) / 200
     END-IF
     MOVE L-I(3) TO L-O(7)
''')
extra+=pathprog('EF7-DRAGON-TEXTURE',[('1','textures/entity/enderdragon/dragon_exploding.png'),('2','textures/entity/enderdragon/dragon_eyes.png')],default='textures/entity/enderdragon/dragon.png')
extra+=prog('EF7-DRAGON-RAY-COUNT','     COMPUTE L-O(1) = FUNCTION INTEGER-PART(((L-I(1) + L-I(1) * L-I(1)) / 2) * 60)\n')
extra+=prog('EF7-DRAGON-RAY-COLOR','''     MOVE 0 TO L-O(1)
     IF L-I(1) > 0.8
         COMPUTE L-O(1) = (L-I(1) - 0.8) / 0.2
     END-IF
     IF L-O(1) > 1
         MOVE 1 TO L-O(1)
     END-IF
     COMPUTE L-O(2) = 1 - L-O(1)
''')
extra+=prog('EF7-DRAGON-RAY','''     MOVE 2 TO WS-IN(1)
     MOVE 432 TO WS-IN(2)
     MOVE 0 TO WS-IN(3)
     COMPUTE WS-IN(4) = 8 * (L-I(2) - 1)
     MOVE 8 TO WS-IN(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN-G WS-OUT-G
     MOVE 0 TO WS-G
     IF L-I(1) > 0.8
         COMPUTE WS-G = (L-I(1) - 0.8) / 0.2
     END-IF
     IF WS-G > 1
         MOVE 1 TO WS-G
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         COMPUTE L-O(WS-K) = WS-OV(WS-K) * 6.283185307179586
     END-PERFORM
     COMPUTE L-O(6) = L-O(6) + L-I(1) * 1.5707963267948966
     COMPUTE L-O(7) = WS-OV(7) * 20 + 5 + WS-G * 10
     COMPUTE L-O(8) = WS-OV(8) * 2 + 1 + WS-G * 2
''',' 01 WS-IN-G.\n    05 WS-IN              FLOAT-LONG OCCURS 16 TIMES.\n 01 WS-OUT-G.\n    05 WS-OV              FLOAT-LONG OCCURS 64 TIMES.\n 01 WS-G                   FLOAT-LONG.\n 01 WS-K                   BINARY-LONG.\n')
extra+=prog('EF7-DRAGON-RAY-VERTS','''     COMPUTE WS-Q = 0.8660254037844386 * L-I(2)
     COMPUTE WS-H = 0.5 * L-I(2)
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(10) L-O(11) L-O(12) L-O(19) L-O(20) L-O(21)
     COMPUTE L-O(4) = 0 - WS-Q
     COMPUTE L-O(25) = 0 - WS-Q
     MOVE WS-Q TO L-O(7) L-O(13)
     MOVE L-I(1) TO L-O(5) L-O(8) L-O(14) L-O(17) L-O(23) L-O(26)
     COMPUTE L-O(6) = 0 - WS-H
     COMPUTE L-O(9) = 0 - WS-H
     COMPUTE L-O(15) = 0 - WS-H
     COMPUTE L-O(27) = 0 - WS-H
     MOVE 0 TO L-O(16) L-O(22)
     MOVE L-I(2) TO L-O(18) L-O(24)
''',' 01 WS-Q                   FLOAT-LONG.\n 01 WS-H                   FLOAT-LONG.\n')
extra+=prog('EF7-BEAM','''     COMPUTE L-O(1) = FUNCTION SQRT(L-I(1) * L-I(1) + L-I(3) * L-I(3))
     COMPUTE L-O(2) = FUNCTION SQRT(L-I(1) * L-I(1) + L-I(2) * L-I(2) + L-I(3) * L-I(3))
     MOVE L-I(3) TO WS-AI(1)
     MOVE L-I(1) TO WS-AI(2)
     CALL "EF7-ATAN2" USING WS-IN2 WS-OUT2
     COMPUTE L-O(3) = 0 - WS-OV(1) - 1.5707963267948966
     MOVE L-O(1) TO WS-AI(1)
     MOVE L-I(2) TO WS-AI(2)
     CALL "EF7-ATAN2" USING WS-IN2 WS-OUT2
     COMPUTE L-O(4) = 0 - WS-OV(1) - 1.5707963267948966
     COMPUTE L-O(5) = 0 - L-I(4) * 0.01
     COMPUTE L-O(6) = L-O(2) / 32 - L-I(4) * 0.01
''',' 01 WS-IN2.\n    05 WS-AI               FLOAT-LONG OCCURS 16 TIMES.\n 01 WS-OUT2.\n    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.\n')
extra+=prog('EF7-BEAM-QUAD','''     COMPUTE WS-V0 = 0 - L-I(3) * 0.01
     COMPUTE WS-V1 = L-I(2) / 32 - L-I(3) * 0.01
     COMPUTE WS-A = L-I(1) * 6.283185307179586 / 8
     COMPUTE WS-X = FUNCTION SIN(WS-A) * 0.75
     COMPUTE WS-Y = FUNCTION COS(WS-A) * 0.75
     IF L-I(1) = 1
         MOVE 0 TO WS-XP
         MOVE 0.75 TO WS-YP
     ELSE
         COMPUTE WS-A = (L-I(1) - 1) * 6.283185307179586 / 8
         COMPUTE WS-XP = FUNCTION SIN(WS-A) * 0.75
         COMPUTE WS-YP = FUNCTION COS(WS-A) * 0.75
     END-IF
     COMPUTE WS-U1 = (L-I(1) - 1) / 8
     COMPUTE WS-U2 = L-I(1) / 8
     COMPUTE L-O(1) = WS-XP * 0.2
     COMPUTE L-O(2) = WS-YP * 0.2
     MOVE 0 TO L-O(3)
     MOVE -16777216 TO L-O(4)
     MOVE WS-U1 TO L-O(5)
     MOVE WS-V0 TO L-O(6)
     MOVE WS-XP TO L-O(7)
     MOVE WS-YP TO L-O(8)
     MOVE L-I(2) TO L-O(9)
     MOVE -1 TO L-O(10)
     MOVE WS-U1 TO L-O(11)
     MOVE WS-V1 TO L-O(12)
     MOVE WS-X TO L-O(13)
     MOVE WS-Y TO L-O(14)
     MOVE L-I(2) TO L-O(15)
     MOVE -1 TO L-O(16)
     MOVE WS-U2 TO L-O(17)
     MOVE WS-V1 TO L-O(18)
     COMPUTE L-O(19) = WS-X * 0.2
     COMPUTE L-O(20) = WS-Y * 0.2
     MOVE 0 TO L-O(21)
     MOVE -16777216 TO L-O(22)
     MOVE WS-U2 TO L-O(23)
     MOVE WS-V0 TO L-O(24)
''',' 01 WS-V0                  FLOAT-LONG.\n 01 WS-V1                  FLOAT-LONG.\n 01 WS-A                   FLOAT-LONG.\n 01 WS-X                   FLOAT-LONG.\n 01 WS-Y                   FLOAT-LONG.\n 01 WS-XP                  FLOAT-LONG.\n 01 WS-YP                  FLOAT-LONG.\n 01 WS-U1                  FLOAT-LONG.\n 01 WS-U2                  FLOAT-LONG.\n')
extra+=prog('EF7-DRAGON-FLAP','''     COMPUTE WS-F = 0.2 / (L-I(3) * 10 + 1)
     COMPUTE WS-F = WS-F * 2 ** L-I(4)
     IF L-I(1) NOT = 0
         COMPUTE L-O(1) = L-I(5) + 0.1
     ELSE
         IF L-I(2) NOT = 0
             COMPUTE L-O(1) = L-I(5) + WS-F * 0.5
         ELSE
             COMPUTE L-O(1) = L-I(5) + WS-F
         END-IF
     END-IF
''',' 01 WS-F                   FLOAT-LONG.\n')
extra+=prog('EF7-DRAGON-BEAM-OFFSET','''     COMPUTE WS-F = FUNCTION SIN(0.2 * L-I(4)) / 2 + 0.5
     COMPUTE WS-F = (WS-F * WS-F + WS-F) * 0.4
     COMPUTE L-O(1) = L-I(1) - L-I(5)
     COMPUTE L-O(2) = L-I(2) + (WS-F - 1.4) - L-I(6)
     COMPUTE L-O(3) = L-I(3) - L-I(7)
''',' 01 WS-F                   FLOAT-LONG.\n')
extra+=prog('EF7-DRAGON-DIST','''     COMPUTE L-O(1) = (L-I(1) + 0.5 - L-I(4)) * (L-I(1) + 0.5 - L-I(4)) + (L-I(2) + 0.5 - L-I(5)) * (L-I(2) + 0.5 - L-I(5)) + (L-I(3) + 0.5 - L-I(6)) * (L-I(3) + 0.5 - L-I(6))
''')
write_section_src(8,hdr,['ENDER_DRAGON'],extra); write_layers(['ENDER_DRAGON'])
