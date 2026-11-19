*> Entity models part 8, the adult axolotl animators (docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md 4.2 and 4.5): EF8-BINARY-TICK and EF8-BINARY-FACTOR (the BinaryAnimator of
*> length 10 with the ease in out sine), EF8-AXOLOTL-POSE (AdultAxolotlModel.setupAnim with the four factors) and EF8-AXOLOTL-STATE (the flags the four animators tick with).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BINARY-TICK.
*> USING ticks, old ticks (BINARY-LONG, in and out), flag (BINARY-LONG): BinaryAnimator.tick: the old value is the ticks; a true flag below 10 steps the ticks up, a false flag above 0 steps down.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKS L-OLD L-FLAG.
     MOVE L-TICKS TO L-OLD
     IF L-FLAG NOT = 0 AND L-TICKS < 10
         ADD 1 TO L-TICKS
     END-IF
     IF L-FLAG = 0 AND L-TICKS > 0
         SUBTRACT 1 FROM L-TICKS
     END-IF
     GOBACK.
 END PROGRAM EF8-BINARY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BINARY-FACTOR.
*> USING ticks, old ticks (BINARY-LONG), partial tick (FLOAT-LONG), factor out (FLOAT-LONG): getFactor(partial) = ease(lerp(partial, old, ticks) / 10) with ease(x) = -(cos(pi x) - 1) / 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-FACTOR               FLOAT-LONG.
 PROCEDURE DIVISION USING L-TICKS L-OLD L-PARTIAL L-FACTOR.
     COMPUTE WS-X = (L-OLD + (L-TICKS - L-OLD) * L-PARTIAL) / 10
     COMPUTE L-FACTOR = -(FUNCTION COS(FUNCTION PI * WS-X) - 1) / 2
     GOBACK.
 END PROGRAM EF8-BINARY-FACTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-AXOLOTL-STATE.
*> USING in (playing dead, in water, on the ground, moving: BINARY-LONG each), flags out (4 BINARY-LONG: the flag of the playing dead, in water, on ground and moving animators): the adult's
*> exclusive state by priority (playing dead, in water, on the ground, else in the air) is the flag of the animator of that state; the moving animator ticks with the moving flag (4.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 BINARY-LONG OCCURS 4 TIMES.
 01 L-OUT.
    05 L-O                 BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     MOVE L-I(4) TO L-O(4)
     EVALUATE TRUE
         WHEN L-I(1) NOT = 0
             MOVE 1 TO L-O(1)
         WHEN L-I(2) NOT = 0
             MOVE 1 TO L-O(2)
         WHEN L-I(3) NOT = 0
             MOVE 1 TO L-O(3)
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF8-AXOLOTL-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-AXOLOTL-POSE.
*> USING model, state (16 FLOAT-LONG: 1 xRot, 2 yRot degrees, 3 movingFactor, 4 ageInTicks, 5 playingDeadFactor, 6 inWaterFactor, 7 onGroundFactor): AdultAxolotlModel.setupAnim (4.2): body.yRot,
*> swim(min(mv, iw)), hover(min(1 - mv, iw)), crawl(min(mv, og)), layStill(min(1 - mv, og)), playDead(pd), then mirrorLegs(1 - min(og, mv)); a sub-animation of a weight of 1.0E-5 or less is skipped.
*> Every addition is to the current value. Reset first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-BODY                BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-LG                  BINARY-LONG.
 01 WS-RG                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-RH                  BINARY-LONG.
 01 WS-LF                  BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-LAY                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-BODY
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     MOVE "top_gills" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-TOP
     MOVE "left_gills" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LG
     MOVE "right_gills" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RG
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LH
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RH
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LF
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RF
     MOVE "tail" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-TAIL
     COMPUTE MM-CYROT(WS-BODY) = MM-CYROT(WS-BODY) + L-I(2) * 0.017453292
*>   swim(A, xRot, min(mv, iw))
     MOVE FUNCTION MIN(L-I(3), L-I(6)) TO WS-W
     IF WS-W > 0.00001
         COMPUTE WS-T = L-I(4) * 0.33
         COMPUTE WS-S = FUNCTION SIN(WS-T)
         COMPUTE WS-C = FUNCTION COS(WS-T)
         COMPUTE WS-K = 0.13 * WS-S
         COMPUTE MM-CXROT(WS-BODY) = MM-CXROT(WS-BODY) + (L-I(1) * 0.017453292 + WS-K) * WS-W
         COMPUTE MM-CXROT(WS-HEAD) = MM-CXROT(WS-HEAD) - WS-K * 1.8 * WS-W
         COMPUTE MM-CY(WS-BODY) = MM-CY(WS-BODY) - 0.45 * WS-C * WS-W
         COMPUTE MM-CXROT(WS-TOP) = MM-CXROT(WS-TOP) + (-0.5 * WS-S - 0.8) * WS-W
         COMPUTE WS-G = (0.3 * WS-S + 0.9) * WS-W
         COMPUTE MM-CYROT(WS-LG) = MM-CYROT(WS-LG) + WS-G
         COMPUTE MM-CYROT(WS-RG) = MM-CYROT(WS-RG) - WS-G
         COMPUTE MM-CYROT(WS-TAIL) = MM-CYROT(WS-TAIL) + 0.3 * FUNCTION COS(WS-T * 0.9) * WS-W
         COMPUTE MM-CXROT(WS-LH) = MM-CXROT(WS-LH) + 1.8849558 * WS-W
         COMPUTE MM-CYROT(WS-LH) = MM-CYROT(WS-LH) - 0.4 * WS-S * WS-W
         COMPUTE MM-CZROT(WS-LH) = MM-CZROT(WS-LH) + 1.5707964 * WS-W
         COMPUTE MM-CXROT(WS-LF) = MM-CXROT(WS-LF) + 1.8849558 * WS-W
         COMPUTE MM-CYROT(WS-LF) = MM-CYROT(WS-LF) + (-0.2 * WS-C - 0.1) * WS-W
         COMPUTE MM-CZROT(WS-LF) = MM-CZROT(WS-LF) + 1.5707964 * WS-W
     END-IF
*>   hover(A, min(1 - mv, iw))
     COMPUTE WS-W = FUNCTION MIN(1 - L-I(3), L-I(6))
     IF WS-W > 0.00001
         COMPUTE WS-T = L-I(4) * 0.075
         COMPUTE WS-C = FUNCTION COS(WS-T)
         COMPUTE WS-S = FUNCTION SIN(WS-T) * 0.15
         COMPUTE WS-K = (-0.15 + 0.075 * WS-C) * WS-W
         COMPUTE MM-CXROT(WS-BODY) = MM-CXROT(WS-BODY) + WS-K
         COMPUTE MM-CY(WS-BODY) = MM-CY(WS-BODY) - WS-S * WS-W
         COMPUTE MM-CXROT(WS-HEAD) = MM-CXROT(WS-HEAD) - WS-K
         COMPUTE MM-CXROT(WS-TOP) = MM-CXROT(WS-TOP) + 0.2 * WS-C * WS-W
         COMPUTE WS-G = (-0.3 * WS-C - 0.19) * WS-W
         COMPUTE MM-CYROT(WS-LG) = MM-CYROT(WS-LG) + WS-G
         COMPUTE MM-CYROT(WS-RG) = MM-CYROT(WS-RG) - WS-G
         COMPUTE MM-CXROT(WS-LH) = MM-CXROT(WS-LH) + (2.3561945 - 0.11 * WS-C) * WS-W
         COMPUTE MM-CYROT(WS-LH) = MM-CYROT(WS-LH) + 0.47123894 * WS-W
         COMPUTE MM-CZROT(WS-LH) = MM-CZROT(WS-LH) + 1.7278761 * WS-W
         COMPUTE MM-CXROT(WS-LF) = MM-CXROT(WS-LF) + (0.7853982 - 0.2 * WS-C) * WS-W
         COMPUTE MM-CYROT(WS-LF) = MM-CYROT(WS-LF) + 2.042035 * WS-W
         COMPUTE MM-CYROT(WS-TAIL) = MM-CYROT(WS-TAIL) + 0.5 * WS-C * WS-W
     END-IF
*>   crawl(A, min(mv, og))
     MOVE FUNCTION MIN(L-I(3), L-I(7)) TO WS-W
     IF WS-W > 0.00001
         COMPUTE WS-T = L-I(4) * 0.11
         COMPUTE WS-C = FUNCTION COS(WS-T)
         COMPUTE WS-Q = (WS-C * WS-C - 2 * WS-C) / 5
         COMPUTE WS-R = 0.7 * WS-C
         COMPUTE WS-K = 0.09 * WS-C * WS-W
         COMPUTE MM-CYROT(WS-HEAD) = MM-CYROT(WS-HEAD) + WS-K
         COMPUTE MM-CYROT(WS-TAIL) = MM-CYROT(WS-TAIL) + WS-K
         COMPUTE WS-G = (0.6 - 0.08 * (WS-C * WS-C + 2 * FUNCTION SIN(WS-T))) * WS-W
         COMPUTE MM-CXROT(WS-TOP) = MM-CXROT(WS-TOP) + WS-G
         COMPUTE MM-CYROT(WS-LG) = MM-CYROT(WS-LG) - WS-G
         COMPUTE MM-CYROT(WS-RG) = MM-CYROT(WS-RG) + WS-G
         COMPUTE MM-CXROT(WS-LH) = MM-CXROT(WS-LH) + 0.9424779 * WS-W
         COMPUTE MM-CYROT(WS-LH) = MM-CYROT(WS-LH) + (1.5 - WS-Q) * WS-W
         COMPUTE MM-CZROT(WS-LH) = MM-CZROT(WS-LH) - 0.1 * WS-W
         COMPUTE MM-CXROT(WS-LF) = MM-CXROT(WS-LF) + 1.0995574 * WS-W
         COMPUTE MM-CYROT(WS-LF) = MM-CYROT(WS-LF) + (1.5707964 - WS-R) * WS-W
         COMPUTE MM-CXROT(WS-RH) = MM-CXROT(WS-RH) + 0.9424779 * WS-W
         COMPUTE MM-CYROT(WS-RH) = MM-CYROT(WS-RH) + (-1 - WS-Q) * WS-W
         COMPUTE MM-CXROT(WS-RF) = MM-CXROT(WS-RF) + 1.0995574 * WS-W
         COMPUTE MM-CYROT(WS-RF) = MM-CYROT(WS-RF) + (-1.5707964 - WS-R) * WS-W
     END-IF
*>   layStill(A, min(1 - mv, og))
     COMPUTE WS-W = FUNCTION MIN(1 - L-I(3), L-I(7))
     IF WS-W > 0.00001
         COMPUTE WS-T = L-I(4) * 0.09
         COMPUTE WS-S = FUNCTION SIN(WS-T)
         COMPUTE WS-C = FUNCTION COS(WS-T)
         COMPUTE WS-M = WS-S * WS-S - 2 * WS-S
         COMPUTE WS-N = WS-C * WS-C - 3 * WS-S
         COMPUTE MM-CXROT(WS-HEAD) = MM-CXROT(WS-HEAD) - 0.09 * WS-M * WS-W
         COMPUTE MM-CZROT(WS-HEAD) = MM-CZROT(WS-HEAD) - 0.2 * WS-W
         COMPUTE MM-CYROT(WS-TAIL) = MM-CYROT(WS-TAIL) + (-0.1 + 0.1 * WS-M) * WS-W
         COMPUTE WS-G = (0.6 + 0.05 * WS-N) * WS-W
         COMPUTE MM-CXROT(WS-TOP) = MM-CXROT(WS-TOP) + WS-G
         COMPUTE MM-CYROT(WS-LG) = MM-CYROT(WS-LG) - WS-G
         COMPUTE MM-CYROT(WS-RG) = MM-CYROT(WS-RG) + WS-G
         COMPUTE MM-CXROT(WS-LH) = MM-CXROT(WS-LH) + 1.1 * WS-W
         COMPUTE MM-CYROT(WS-LH) = MM-CYROT(WS-LH) + WS-W
         COMPUTE MM-CXROT(WS-LF) = MM-CXROT(WS-LF) + 0.8 * WS-W
         COMPUTE MM-CYROT(WS-LF) = MM-CYROT(WS-LF) + 2.3 * WS-W
         COMPUTE MM-CZROT(WS-LF) = MM-CZROT(WS-LF) - 0.5 * WS-W
     END-IF
*>   playDead(pd)
     MOVE L-I(5) TO WS-W
     IF WS-W > 0.00001
         COMPUTE MM-CXROT(WS-LH) = MM-CXROT(WS-LH) + 1.4137167 * WS-W
         COMPUTE MM-CYROT(WS-LH) = MM-CYROT(WS-LH) + 1.0995574 * WS-W
         COMPUTE MM-CZROT(WS-LH) = MM-CZROT(WS-LH) + 0.7853982 * WS-W
         COMPUTE MM-CXROT(WS-LF) = MM-CXROT(WS-LF) + 0.7853982 * WS-W
         COMPUTE MM-CYROT(WS-LF) = MM-CYROT(WS-LF) + 2.042035 * WS-W
         COMPUTE MM-CXROT(WS-BODY) = MM-CXROT(WS-BODY) - 0.15 * WS-W
         COMPUTE MM-CZROT(WS-BODY) = MM-CZROT(WS-BODY) + 0.35 * WS-W
     END-IF
*>   mirrorLegs(1 - min(og, mv))
     COMPUTE WS-LAY = 1 - FUNCTION MIN(L-I(7), L-I(3))
     IF WS-LAY > 0.00001
         COMPUTE MM-CXROT(WS-RH) = MM-CXROT(WS-RH) + MM-CXROT(WS-LH) * WS-LAY
         COMPUTE MM-CYROT(WS-RH) = MM-CYROT(WS-RH) - MM-CYROT(WS-LH) * WS-LAY
         COMPUTE MM-CZROT(WS-RH) = MM-CZROT(WS-RH) - MM-CZROT(WS-LH) * WS-LAY
         COMPUTE MM-CXROT(WS-RF) = MM-CXROT(WS-RF) + MM-CXROT(WS-LF) * WS-LAY
         COMPUTE MM-CYROT(WS-RF) = MM-CYROT(WS-RF) - MM-CYROT(WS-LF) * WS-LAY
         COMPUTE MM-CZROT(WS-RF) = MM-CZROT(WS-RF) - MM-CZROT(WS-LF) * WS-LAY
     END-IF
     GOBACK.
 END PROGRAM EF8-AXOLOTL-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-BABY-AXOLOTL-ANIM.
*> USING model, state (16 FLOAT-LONG: 1 walk position, 2 walk speed, 3 ageInTicks, 4 the started animation state (0 none, 1 swim, 2 walk, 3 walk underwater, 4 idle underwater, 5 idle
*> underwater on the ground, 6 idle on the ground, 7 play dead), 5 the tick at which it started): BabyAxolotlModel.setupAnim (4.4) after the reset: the walk state plays AXOLOTL_WALK_FLOOR with
*> applyWalk(pos, speed, 15, 30) and WALK_FLOOR_UNDERWATER from the same state (open question 3: the underwater walk state is not read, so underwater walking plays nothing), the swim,
*> idle underwater, idle on ground underwater, idle on ground and play dead states their animation at ms = trunc((age - start) x 50), scale 1. The animations are EM3-ANIM-DEF ordinals 12 to 18.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MS                  BINARY-LONG.
 01 WS-ORD                 BINARY-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     IF L-I(4) = 2
         COMPUTE WS-MS = FUNCTION INTEGER-PART(L-I(1) * 50 * 15)
         COMPUTE WS-SCALE = FUNCTION MIN(L-I(2) * 30, 1)
         MOVE 13 TO WS-ORD
         CALL "EM3-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
     END-IF
     MOVE 0 TO WS-ORD
     EVALUATE L-I(4)
         WHEN 1
             MOVE 12 TO WS-ORD
         WHEN 2
             MOVE 14 TO WS-ORD
         WHEN 4
             MOVE 15 TO WS-ORD
         WHEN 5
             MOVE 16 TO WS-ORD
         WHEN 6
             MOVE 17 TO WS-ORD
         WHEN 7
             MOVE 18 TO WS-ORD
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     IF WS-ORD > 0
         COMPUTE WS-MS = FUNCTION INTEGER-PART((L-I(3) - L-I(5)) * 50)
         MOVE 1 TO WS-SCALE
         CALL "EM3-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
     END-IF
     GOBACK.
 END PROGRAM EF8-BABY-AXOLOTL-ANIM.
