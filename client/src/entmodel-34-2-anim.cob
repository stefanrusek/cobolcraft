*> Entity models part 2 section 4 (docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md): the setupAnim of the humanoid-base models. Records:
*> client/copy/CLEMM.cpy (EMM-MODEL, whose current pose MM-C* the animation edits).
*> Entry point for the integrator (inputs):
*>   EMD-ANIM EMM-MODEL state(48 FLOAT-LONG) variant(BINARY-LONG: 1 zombie and giant, 2 skeleton (and bogged, stray, wither skeleton, parched), 3 piglin and piglin
*>     brute, 4 zombified piglin, 5 drowned): resets the pose, then runs 4.1 with the variant's attack animation and extras.
*>   The state table: 1 xRot degrees, 2 yRot degrees, 3 walk position, 4 walk speed, 5 speed value, 6 age in ticks, 7 swing progress, 8 fall flying, 9 passenger,
*>     10 crouching, 11 swim amount, 12 age scale, 13 main arm (1 right, 2 left), 14 right arm pose, 15 left arm pose (0 EMPTY 1 ITEM 2 BLOCK 3 BOW_AND_ARROW
*>     4 THROW_TRIDENT 5 CROSSBOW_CHARGE 6 CROSSBOW_HOLD 7 SPYGLASS 8 TOOT_HORN 9 BRUSH 10 SPEAR), 16 using an item, 17 arm of the use hand (1 right, 2 left),
*>     18 aggressive, 19 holding a bow, 20 swing type (0 none, 1 whack, 2 stab, 3 other), 21 swinging arm (1 right, 2 left), 22 main-hand stack empty, 23 baby,
*>     24 sheared (bogged), 25 piglin arm pose (0 ATTACKING_WITH_MELEE_WEAPON, 1 CROSSBOW_HOLD, 2 CROSSBOW_CHARGE, 3 ADMIRING_ITEM, 4 DANCING, 5 DEFAULT),
*>     26 maximum crossbow charge, 27 ticks using the item.
*>   Part index tables (PIX, BINARY-LONG x 8) hold head, body, right_arm, left_arm, right_leg, left_leg, left_ear, right_ear (0 when absent).
*>   The stab swing (SpearAnimations.thirdPersonAttackHand) is EM3-ATTACK-HAND of client/src/entmodel-34-1.cob; the integrator calls it after EMD-ANIM for stab swings.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-ROTLERP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-Q                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-T                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
*> USING t a b out: rotLerpRad(t, a, b) = a + t x d, d = b - a wrapped to [-pi, pi).
 PROCEDURE DIVISION USING L-T L-A L-B L-OUT.
     COMPUTE WS-D = L-B - L-A
     COMPUTE WS-Q = FUNCTION INTEGER-PART(WS-D / 6.283185307179586)
     COMPUTE WS-D = WS-D - 6.283185307179586 * WS-Q
     IF WS-D < -3.141592653589793
         COMPUTE WS-D = WS-D + 6.283185307179586
     END-IF
     IF WS-D >= 3.141592653589793
         COMPUTE WS-D = WS-D - 6.283185307179586
     END-IF
     COMPUTE L-OUT = L-A + L-T * WS-D
     GOBACK.
 END PROGRAM EMD-A-ROTLERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-BOB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-PIX.
    05 L-P                 BINARY-LONG OCCURS 8 TIMES.
 01 L-AGE                  FLOAT-LONG.
 01 L-SKIP-R               BINARY-LONG.
 01 L-SKIP-L               BINARY-LONG.
*> USING model pix age skip-right skip-left: AnimationUtils.bobArms (the right arm sign +1, the left -1); a skipped arm (spyglass) is left alone.
 PROCEDURE DIVISION USING EMM-MODEL L-PIX L-AGE L-SKIP-R L-SKIP-L.
     COMPUTE WS-Z = FUNCTION COS(L-AGE * 0.09) * 0.05 + 0.05
     COMPUTE WS-X = FUNCTION SIN(L-AGE * 0.067) * 0.05
     IF L-SKIP-R = 0
         COMPUTE MM-CZROT(L-P(3)) = MM-CZROT(L-P(3)) + WS-Z
         COMPUTE MM-CXROT(L-P(3)) = MM-CXROT(L-P(3)) + WS-X
     END-IF
     IF L-SKIP-L = 0
         COMPUTE MM-CZROT(L-P(4)) = MM-CZROT(L-P(4)) - WS-Z
         COMPUTE MM-CXROT(L-P(4)) = MM-CXROT(L-P(4)) - WS-X
     END-IF
     GOBACK.
 END PROGRAM EMD-A-BOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-CLAMP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V                    FLOAT-LONG.
 01 L-LOW                  FLOAT-LONG.
 01 L-HIGH                 FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
*> USING v low high out: v limited to [low, high].
 PROCEDURE DIVISION USING L-V L-LOW L-HIGH L-OUT.
     MOVE L-V TO L-OUT
     IF L-OUT < L-LOW
         MOVE L-LOW TO L-OUT
     END-IF
     IF L-OUT > L-HIGH
         MOVE L-HIGH TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM EMD-A-CLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-POSE-ARM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-SIGN                FLOAT-LONG.
 01 WS-CLAMPED             FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-PIX.
    05 L-P                 BINARY-LONG OCCURS 8 TIMES.
 01 L-ARM                  BINARY-LONG.
 01 L-POSE                 BINARY-LONG.
*> USING model state pix arm(1 right, 2 left) pose: the arm pose effects of 4.2 (the crossbow poses are the piglin's, 4.9; SPEAR is the base of
*> SpearAnimations.thirdPersonHandUse).
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-PIX L-ARM L-POSE.
     MOVE MM-CXROT(L-P(1)) TO WS-HX
     MOVE MM-CYROT(L-P(1)) TO WS-HY
     COMPUTE WS-A = L-P(2 + L-ARM)
     MOVE 1 TO WS-SIGN
     IF L-ARM = 2
         MOVE -1 TO WS-SIGN
     END-IF
     EVALUATE L-POSE
         WHEN 0
             MOVE 0 TO MM-CYROT(WS-A)
         WHEN 1
             COMPUTE MM-CXROT(WS-A) = MM-CXROT(WS-A) * 0.5 - 0.31415927
             MOVE 0 TO MM-CYROT(WS-A)
         WHEN 4
             COMPUTE MM-CXROT(WS-A) = MM-CXROT(WS-A) * 0.5 - 3.1415927
             MOVE 0 TO MM-CYROT(WS-A)
         WHEN 9
             COMPUTE MM-CXROT(WS-A) = MM-CXROT(WS-A) * 0.5 - 0.62831855
             MOVE 0 TO MM-CYROT(WS-A)
         WHEN 2
             MOVE -1.3962634 TO WS-LOW
             MOVE 0.43633232 TO WS-HIGH
             CALL "EMD-A-CLAMP" USING WS-HX WS-LOW WS-HIGH WS-CLAMPED
             COMPUTE MM-CXROT(WS-A) = MM-CXROT(WS-A) * 0.5 - 0.9424779 + WS-CLAMPED
             MOVE -0.5235988 TO WS-LOW
             MOVE 0.5235988 TO WS-HIGH
             CALL "EMD-A-CLAMP" USING WS-HY WS-LOW WS-HIGH WS-CLAMPED
             COMPUTE MM-CYROT(WS-A) = WS-SIGN * -0.5235988 + WS-CLAMPED
         WHEN 7
             COMPUTE WS-V = WS-HX - 1.9198622
             IF L-S(10) NOT = 0
                 COMPUTE WS-V = WS-V - 0.2617994
             END-IF
             MOVE -2.4 TO WS-LOW
             MOVE 3.3 TO WS-HIGH
             CALL "EMD-A-CLAMP" USING WS-V WS-LOW WS-HIGH WS-CLAMPED
             MOVE WS-CLAMPED TO MM-CXROT(WS-A)
             COMPUTE MM-CYROT(WS-A) = WS-HY - 0.2617994
         WHEN 8
             MOVE -1.2 TO WS-LOW
             MOVE 1.2 TO WS-HIGH
             CALL "EMD-A-CLAMP" USING WS-HX WS-LOW WS-HIGH WS-CLAMPED
             COMPUTE MM-CXROT(WS-A) = WS-CLAMPED - 1.4835298
             COMPUTE MM-CYROT(WS-A) = WS-HY - 0.5235988
         WHEN 3
             IF L-S(13) = 1
                 COMPUTE MM-CYROT(L-P(3)) = -0.1 + WS-HY
                 COMPUTE MM-CYROT(L-P(4)) = 0.1 + WS-HY + 0.4
             ELSE
                 COMPUTE MM-CYROT(L-P(4)) = 0.1 + WS-HY
                 COMPUTE MM-CYROT(L-P(3)) = -0.1 + WS-HY - 0.4
             END-IF
             COMPUTE MM-CXROT(L-P(3)) = -1.5707964 + WS-HX
             COMPUTE MM-CXROT(L-P(4)) = -1.5707964 + WS-HX
         WHEN 10
             COMPUTE WS-V = -0.1 * WS-SIGN + WS-HY
             MOVE -60 TO WS-LOW
             MOVE 60 TO WS-HIGH
             COMPUTE WS-V = 57.295776 * WS-V
             CALL "EMD-A-CLAMP" USING WS-V WS-LOW WS-HIGH WS-CLAMPED
             COMPUTE MM-CYROT(WS-A) = 0.017453292 * WS-CLAMPED
             COMPUTE WS-V = -1.5707963267948966 + WS-HX + 0.8
             IF L-S(8) NOT = 0 OR L-S(11) > 0
                 COMPUTE WS-V = WS-V - 0.9599311
             END-IF
             MOVE -120 TO WS-LOW
             MOVE 30 TO WS-HIGH
             COMPUTE WS-V = 57.295776 * WS-V
             CALL "EMD-A-CLAMP" USING WS-V WS-LOW WS-HIGH WS-CLAMPED
             COMPUTE MM-CXROT(WS-A) = 0.017453292 * WS-CLAMPED
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-A-POSE-ARM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-POSES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-POSE-A              BINARY-LONG.
 01 WS-POSE-B              BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-PIX.
    05 L-P                 BINARY-LONG OCCURS 8 TIMES.
*> USING model state pix: arm A = the arm of the use hand when using an item, else the arm opposite the main arm (a two-handed pose moves A to the main arm); pose
*> arm A, then the other arm unless pose(A) affects the offhand pose (4.2).
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-PIX.
     COMPUTE WS-OPP = 3 - L-S(13)
     MOVE WS-OPP TO WS-A
     IF L-S(16) NOT = 0
         COMPUTE WS-A = L-S(17)
     END-IF
     COMPUTE WS-POSE-A = L-S(13 + WS-A)
     IF WS-POSE-A = 3 OR WS-POSE-A = 5 OR WS-POSE-A = 6
         COMPUTE WS-A = L-S(13)
         COMPUTE WS-POSE-A = L-S(13 + WS-A)
     END-IF
     CALL "EMD-A-POSE-ARM" USING EMM-MODEL L-STATE L-PIX WS-A WS-POSE-A
     IF WS-POSE-A < 3 OR WS-POSE-A > 6
         COMPUTE WS-B = 3 - WS-A
         COMPUTE WS-POSE-B = L-S(13 + WS-B)
         CALL "EMD-A-POSE-ARM" USING EMM-MODEL L-STATE L-PIX WS-B WS-POSE-B
     END-IF
     GOBACK.
 END PROGRAM EMD-A-POSES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-BASE-SWING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-ARM                 BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-PIX.
    05 L-PI                BINARY-LONG OCCURS 8 TIMES.
*> USING model state pix: HumanoidModel.setupAttackAnimation (4.4): the body turn, the arm pivots around it and the whack swing.
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-PIX.
     MOVE L-S(7) TO WS-P
     IF WS-P > 0 AND L-S(20) NOT = 0
         MOVE L-S(12) TO WS-K
         COMPUTE WS-BY = FUNCTION SIN(FUNCTION SQRT(WS-P) * 6.283185307179586) * 0.2
         IF L-S(21) = 2
             COMPUTE WS-BY = -WS-BY
         END-IF
         MOVE WS-BY TO MM-CYROT(L-PI(2))
         COMPUTE MM-CZ(L-PI(3)) = FUNCTION SIN(WS-BY) * 5 * WS-K
         COMPUTE MM-CX(L-PI(3)) = -FUNCTION COS(WS-BY) * 5 * WS-K
         COMPUTE MM-CZ(L-PI(4)) = -FUNCTION SIN(WS-BY) * 5 * WS-K
         COMPUTE MM-CX(L-PI(4)) = FUNCTION COS(WS-BY) * 5 * WS-K
         COMPUTE MM-CYROT(L-PI(3)) = MM-CYROT(L-PI(3)) + WS-BY
         COMPUTE MM-CYROT(L-PI(4)) = MM-CYROT(L-PI(4)) + WS-BY
         COMPUTE MM-CXROT(L-PI(4)) = MM-CXROT(L-PI(4)) + WS-BY
         IF L-S(20) = 1
             COMPUTE WS-ARM = L-PI(2 + L-S(21))
             COMPUTE WS-Q = 1 - (1 - WS-P) * (1 - WS-P) * (1 - WS-P) * (1 - WS-P)
             COMPUTE WS-U = FUNCTION SIN(WS-Q * 3.141592653589793)
             COMPUTE WS-V = FUNCTION SIN(WS-P * 3.141592653589793) * -(MM-CXROT(L-PI(1)) - 0.7) * 0.75
             COMPUTE MM-CXROT(WS-ARM) = MM-CXROT(WS-ARM) - (WS-U * 1.2 + WS-V)
             COMPUTE MM-CYROT(WS-ARM) = MM-CYROT(WS-ARM) + WS-BY * 2
             COMPUTE MM-CZROT(WS-ARM) = MM-CZROT(WS-ARM) + FUNCTION SIN(WS-P * 3.141592653589793) * -0.4
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EMD-A-BASE-SWING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-ZOMBIE-ARMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAISED              BINARY-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-RP                  BINARY-LONG.
 01 WS-LP                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-PIX.
    05 L-PI                BINARY-LONG OCCURS 8 TIMES.
*> USING model state pix: AnimationUtils.animateZombieArms (4.3).
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-PIX.
     COMPUTE WS-RP = L-S(14)
     COMPUTE WS-LP = L-S(15)
     IF WS-RP = 10 OR WS-LP = 10
         GOBACK
     END-IF
     MOVE 1 TO WS-RAISED
     IF L-S(23) NOT = 0 AND L-S(22) = 0
         MOVE 0 TO WS-RAISED
     END-IF
     MOVE 0 TO WS-BASE
     IF WS-RAISED = 1
         COMPUTE WS-BASE = -3.141592653589793 / 2.25
         IF L-S(18) NOT = 0
             COMPUTE WS-BASE = -3.141592653589793 / 1.5
         END-IF
         COMPUTE WS-A = FUNCTION SIN(L-S(7) * 3.141592653589793)
     ELSE
         COMPUTE WS-A = -FUNCTION SIN(L-S(7) * 3.141592653589793)
     END-IF
     COMPUTE WS-B = FUNCTION SIN((1 - (1 - L-S(7)) * (1 - L-S(7))) * 3.141592653589793)
     COMPUTE WS-X = WS-BASE + WS-A * 1.2 - WS-B * 0.4
     COMPUTE WS-Y = 0.1 - WS-A * 0.6
     IF WS-RP NOT = 4
         MOVE WS-X TO MM-CXROT(L-PI(3))
         COMPUTE MM-CYROT(L-PI(3)) = WS-Y
         IF WS-RAISED = 1
             COMPUTE MM-CYROT(L-PI(3)) = -WS-Y
         END-IF
         MOVE 0 TO MM-CZROT(L-PI(3))
     END-IF
     IF WS-LP NOT = 4
         MOVE WS-X TO MM-CXROT(L-PI(4))
         COMPUTE MM-CYROT(L-PI(4)) = -WS-Y
         IF WS-RAISED = 1
             COMPUTE MM-CYROT(L-PI(4)) = WS-Y
         END-IF
         MOVE 0 TO MM-CZROT(L-PI(4))
     END-IF
     GOBACK.
 END PROGRAM EMD-A-ZOMBIE-ARMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-SWING-DOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-MAIN                BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-SKIP-R              BINARY-LONG VALUE 0.
 01 WS-SKIP-L              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-PIX.
    05 L-PI                BINARY-LONG OCCURS 8 TIMES.
*> USING model state pix: AnimationUtils.swingWeaponDown (4.9), then both arms bobbed.
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-PIX.
     COMPUTE WS-A = FUNCTION SIN(L-S(7) * 3.141592653589793)
     COMPUTE WS-B = FUNCTION SIN((1 - (1 - L-S(7)) * (1 - L-S(7))) * 3.141592653589793)
     MOVE 0 TO MM-CZROT(L-PI(3)) MM-CZROT(L-PI(4))
     MOVE 0.15707964 TO MM-CYROT(L-PI(3))
     MOVE -0.15707964 TO MM-CYROT(L-PI(4))
     COMPUTE WS-MAIN = L-PI(2 + L-S(13))
     COMPUTE WS-OTHER = L-PI(5 - L-S(13))
     COMPUTE MM-CXROT(WS-MAIN) = -1.8849558 + FUNCTION COS(L-S(6) * 0.09) * 0.15
     COMPUTE MM-CXROT(WS-OTHER) = FUNCTION COS(L-S(6) * 0.19) * 0.5
     COMPUTE MM-CXROT(WS-MAIN) = MM-CXROT(WS-MAIN) + WS-A * 2.2 - WS-B * 0.4
     COMPUTE MM-CXROT(WS-OTHER) = MM-CXROT(WS-OTHER) + WS-A * 1.2 - WS-B * 0.4
     CALL "EMD-A-BOB" USING EMM-MODEL L-PIX L-S(6) WS-SKIP-R WS-SKIP-L
     GOBACK.
 END PROGRAM EMD-A-SWING-DOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-SWIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SA                  FLOAT-LONG.
 01 WS-WP                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-SR                  FLOAT-LONG.
 01 WS-SL                  FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-PI                  FLOAT-LONG VALUE 3.141592653589793.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-MOD                 BINARY-DOUBLE.
 01 WS-HEAD-TARGET         FLOAT-LONG VALUE -0.7853982.
 01 WS-TX                  FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-PIX.
    05 L-P                 BINARY-LONG OCCURS 8 TIMES.
 01 L-VARIANT              BINARY-LONG.
*> USING model state pix variant: HumanoidModel.setupSwimAnimation (4.5) and, for the drowned (variant 5), DrownedModel.setupSwimAnimation (4.6).
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-PIX L-VARIANT.
     MOVE L-S(11) TO WS-SA
     MOVE L-S(3) TO WS-WP
     COMPUTE WS-SIN = FUNCTION SIN(0.1 * L-S(6))
     IF L-VARIANT = 5
         MOVE -2.5132742 TO WS-TARGET
         CALL "EMD-A-ROTLERP" USING WS-SA MM-CXROT(L-P(3)) WS-TARGET WS-R1
         COMPUTE MM-CXROT(L-P(3)) = WS-R1 + WS-SA * 0.35 * WS-SIN
         CALL "EMD-A-ROTLERP" USING WS-SA MM-CXROT(L-P(4)) WS-TARGET WS-R1
         COMPUTE MM-CXROT(L-P(4)) = WS-R1 - WS-SA * 0.35 * WS-SIN
         MOVE -0.15 TO WS-TARGET
         CALL "EMD-A-ROTLERP" USING WS-SA MM-CZROT(L-P(3)) WS-TARGET WS-R1
         MOVE WS-R1 TO MM-CZROT(L-P(3))
         MOVE 0.15 TO WS-TARGET
         CALL "EMD-A-ROTLERP" USING WS-SA MM-CZROT(L-P(4)) WS-TARGET WS-R1
         MOVE WS-R1 TO MM-CZROT(L-P(4))
         COMPUTE MM-CXROT(L-P(6)) = MM-CXROT(L-P(6)) - WS-SA * 0.55 * WS-SIN
         COMPUTE MM-CXROT(L-P(5)) = MM-CXROT(L-P(5)) + WS-SA * 0.55 * WS-SIN
         MOVE 0 TO MM-CXROT(L-P(1))
         GOBACK
     END-IF
     IF L-S(8) = 0
         CALL "EMD-A-ROTLERP" USING WS-SA MM-CXROT(L-P(1)) WS-HEAD-TARGET WS-R1
         MOVE WS-R1 TO MM-CXROT(L-P(1))
     END-IF
     COMPUTE WS-MOD = FUNCTION INTEGER(WS-WP / 26)
     COMPUTE WS-T = WS-WP - 26 * WS-MOD
     MOVE WS-SA TO WS-SR WS-SL
     IF L-S(14) = 10 OR (L-S(20) NOT = 0 AND L-S(21) = 1)
         MOVE 0 TO WS-SR
     END-IF
     IF L-S(15) = 10 OR (L-S(20) NOT = 0 AND L-S(21) = 2)
         MOVE 0 TO WS-SL
     END-IF
     IF L-S(16) = 0
         EVALUATE TRUE
             WHEN WS-T < 14
                 COMPUTE WS-Q = (-65 * WS-T + WS-T * WS-T) / (-65 * 14 + 14 * 14)
                 CALL "EMD-A-ROTLERP" USING WS-SL MM-CXROT(L-P(4)) WS-ZERO WS-R1
                 MOVE WS-R1 TO MM-CXROT(L-P(4))
                 COMPUTE MM-CXROT(L-P(3)) = MM-CXROT(L-P(3)) + WS-SR * (0 - MM-CXROT(L-P(3)))
                 CALL "EMD-A-ROTLERP" USING WS-SL MM-CYROT(L-P(4)) WS-PI WS-R1
                 MOVE WS-R1 TO MM-CYROT(L-P(4))
                 COMPUTE MM-CYROT(L-P(3)) = MM-CYROT(L-P(3)) + WS-SR * (3.141592653589793 - MM-CYROT(L-P(3)))
                 COMPUTE WS-TARGET = 3.141592653589793 + 1.8707964 * WS-Q
                 CALL "EMD-A-ROTLERP" USING WS-SL MM-CZROT(L-P(4)) WS-TARGET WS-R1
                 MOVE WS-R1 TO MM-CZROT(L-P(4))
                 COMPUTE WS-TARGET = 3.141592653589793 - 1.8707964 * WS-Q
                 COMPUTE MM-CZROT(L-P(3)) = MM-CZROT(L-P(3)) + WS-SR * (WS-TARGET - MM-CZROT(L-P(3)))
             WHEN WS-T < 22
                 COMPUTE WS-U = (WS-T - 14) / 8
                 COMPUTE WS-TX = 1.5707964 * WS-U
                 CALL "EMD-A-ROTLERP" USING WS-SL MM-CXROT(L-P(4)) WS-TX WS-R1
                 MOVE WS-R1 TO MM-CXROT(L-P(4))
                 COMPUTE MM-CXROT(L-P(3)) = MM-CXROT(L-P(3)) + WS-SR * (WS-TX - MM-CXROT(L-P(3)))
                 CALL "EMD-A-ROTLERP" USING WS-SL MM-CYROT(L-P(4)) WS-PI WS-R1
                 MOVE WS-R1 TO MM-CYROT(L-P(4))
                 COMPUTE MM-CYROT(L-P(3)) = MM-CYROT(L-P(3)) + WS-SR * (3.141592653589793 - MM-CYROT(L-P(3)))
                 COMPUTE WS-TARGET = 5.012389 - 1.8707964 * WS-U
                 CALL "EMD-A-ROTLERP" USING WS-SL MM-CZROT(L-P(4)) WS-TARGET WS-R1
                 MOVE WS-R1 TO MM-CZROT(L-P(4))
                 COMPUTE WS-TARGET = 1.2707963 + 1.8707964 * WS-U
                 COMPUTE MM-CZROT(L-P(3)) = MM-CZROT(L-P(3)) + WS-SR * (WS-TARGET - MM-CZROT(L-P(3)))
             WHEN WS-T < 26
                 COMPUTE WS-U = (WS-T - 22) / 4
                 COMPUTE WS-TX = 1.5707964 - 1.5707964 * WS-U
                 CALL "EMD-A-ROTLERP" USING WS-SL MM-CXROT(L-P(4)) WS-TX WS-R1
                 MOVE WS-R1 TO MM-CXROT(L-P(4))
                 COMPUTE MM-CXROT(L-P(3)) = MM-CXROT(L-P(3)) + WS-SR * (WS-TX - MM-CXROT(L-P(3)))
                 CALL "EMD-A-ROTLERP" USING WS-SL MM-CYROT(L-P(4)) WS-PI WS-R1
                 MOVE WS-R1 TO MM-CYROT(L-P(4))
                 COMPUTE MM-CYROT(L-P(3)) = MM-CYROT(L-P(3)) + WS-SR * (3.141592653589793 - MM-CYROT(L-P(3)))
                 CALL "EMD-A-ROTLERP" USING WS-SL MM-CZROT(L-P(4)) WS-PI WS-R1
                 MOVE WS-R1 TO MM-CZROT(L-P(4))
                 COMPUTE MM-CZROT(L-P(3)) = MM-CZROT(L-P(3)) + WS-SR * (3.141592653589793 - MM-CZROT(L-P(3)))
         END-EVALUATE
     END-IF
     COMPUTE MM-CXROT(L-P(6)) = MM-CXROT(L-P(6)) + WS-SA * (0.3 * FUNCTION COS(WS-WP * 0.33333334 + 3.141592653589793) - MM-CXROT(L-P(6)))
     COMPUTE MM-CXROT(L-P(5)) = MM-CXROT(L-P(5)) + WS-SA * (0.3 * FUNCTION COS(WS-WP * 0.33333334) - MM-CXROT(L-P(5)))
     GOBACK.
 END PROGRAM EMD-A-SWIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-EARS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-AMP                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-PIX.
    05 L-P                 BINARY-LONG OCCURS 8 TIMES.
*> USING model state pix: the ear flap of every piglin-family model (4.9): the default ear angle is 30 degrees, 5 for a baby.
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-PIX.
     COMPUTE WS-BASE = 30 * 0.017453292
     IF L-S(23) NOT = 0
         COMPUTE WS-BASE = 5 * 0.017453292
     END-IF
     COMPUTE WS-T = L-S(6) * 0.1 + L-S(3) * 0.5
     COMPUTE WS-AMP = 0.08 + L-S(4) * 0.4
     COMPUTE MM-CZROT(L-P(7)) = -WS-BASE - FUNCTION COS(WS-T * 1.2) * WS-AMP
     COMPUTE MM-CZROT(L-P(8)) = WS-BASE + FUNCTION COS(WS-T) * WS-AMP
     GOBACK.
 END PROGRAM EMD-A-EARS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-PIGLIN-POSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-U                   FLOAT-LONG.
 01 WS-HOLD                BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-SIGN                FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG VALUE 0.
 01 WS-CLAMPED             FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-PIX.
    05 L-P                 BINARY-LONG OCCURS 8 TIMES.
*> USING model state pix: PiglinModel.setupAnim by the arm pose (4.9): dancing, melee idle, the two crossbow poses and admiring an item.
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-PIX.
     EVALUATE L-S(25)
         WHEN 4
             COMPUTE WS-U = L-S(6) / 60
             COMPUTE MM-CZROT(L-P(8)) = 0.5235988 + 0.017453292 * FUNCTION SIN(WS-U * 30) * 10
             COMPUTE MM-CZROT(L-P(7)) = -0.5235988 - 0.017453292 * FUNCTION COS(WS-U * 30) * 10
             COMPUTE MM-CX(L-P(1)) = MM-CX(L-P(1)) + FUNCTION SIN(WS-U * 10)
             COMPUTE MM-CY(L-P(1)) = MM-CY(L-P(1)) + FUNCTION SIN(WS-U * 40) + 0.4
             COMPUTE MM-CZROT(L-P(3)) = 0.017453292 * (70 + FUNCTION COS(WS-U * 40) * 10)
             COMPUTE MM-CZROT(L-P(4)) = -MM-CZROT(L-P(3))
             COMPUTE MM-CY(L-P(3)) = MM-CY(L-P(3)) + FUNCTION SIN(WS-U * 40) * 0.5 - 0.5
             COMPUTE MM-CY(L-P(4)) = MM-CY(L-P(4)) + FUNCTION SIN(WS-U * 40) * 0.5 + 0.5
             COMPUTE MM-CY(L-P(2)) = MM-CY(L-P(2)) + FUNCTION SIN(WS-U * 40) * 0.35
         WHEN 0
             IF L-S(7) = 0
                 IF L-S(13) = 2
                     MOVE -1.8 TO MM-CXROT(L-P(4))
                 ELSE
                     MOVE -1.8 TO MM-CXROT(L-P(3))
                 END-IF
             END-IF
         WHEN 1
             COMPUTE WS-HOLD = L-P(2 + L-S(13))
             COMPUTE WS-OTHER = L-P(5 - L-S(13))
             MOVE -0.3 TO WS-SIGN
             IF L-S(13) = 2
                 MOVE 0.3 TO WS-SIGN
             END-IF
             COMPUTE MM-CYROT(WS-HOLD) = MM-CYROT(WS-HOLD) + MM-CYROT(L-P(1)) + WS-SIGN
             COMPUTE MM-CYROT(WS-OTHER) = MM-CYROT(WS-OTHER) + MM-CYROT(L-P(1)) - WS-SIGN * 2
             COMPUTE MM-CXROT(WS-HOLD) = -1.5707963267948966 + MM-CXROT(L-P(1)) + 0.1
             COMPUTE MM-CXROT(WS-OTHER) = -1.5 + MM-CXROT(L-P(1))
         WHEN 2
             COMPUTE WS-HOLD = L-P(2 + L-S(13))
             COMPUTE WS-OTHER = L-P(5 - L-S(13))
             MOVE 1 TO WS-SIGN
             IF L-S(13) = 2
                 MOVE -1 TO WS-SIGN
             END-IF
             COMPUTE MM-CYROT(WS-HOLD) = -0.8 * WS-SIGN
             MOVE -0.97079635 TO MM-CXROT(WS-HOLD)
             MOVE -0.97079635 TO MM-CXROT(WS-OTHER)
             MOVE L-S(27) TO WS-D
             MOVE L-S(26) TO WS-HIGH
             CALL "EMD-A-CLAMP" USING WS-D WS-LOW WS-HIGH WS-CLAMPED
             COMPUTE WS-D = WS-CLAMPED / L-S(26)
             COMPUTE MM-CYROT(WS-OTHER) = (0.4 + WS-D * (0.85 - 0.4)) * WS-SIGN
             COMPUTE WS-X = -0.97079635 + WS-D * (-1.5707963267948966 + 0.97079635)
             MOVE WS-X TO MM-CXROT(WS-OTHER)
         WHEN 3
             MOVE 0.5 TO MM-CXROT(L-P(1))
             MOVE 0 TO MM-CYROT(L-P(1))
             IF L-S(13) = 2
                 MOVE -0.5 TO MM-CYROT(L-P(3))
                 MOVE -0.9 TO MM-CXROT(L-P(3))
             ELSE
                 MOVE 0.5 TO MM-CYROT(L-P(4))
                 MOVE -0.9 TO MM-CXROT(L-P(4))
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-A-PIGLIN-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-A-SKELETON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-SKIP-R              BINARY-LONG VALUE 0.
 01 WS-SKIP-L              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-PIX.
    05 L-P                 BINARY-LONG OCCURS 8 TIMES.
*> USING model state pix: SkeletonModel.setupAnim after the base animation (4.7): an aggressive skeleton without a bow raises both arms.
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-PIX.
     IF L-S(18) NOT = 0 AND L-S(19) = 0
         COMPUTE WS-A = FUNCTION SIN(L-S(7) * 3.141592653589793)
         COMPUTE WS-B = FUNCTION SIN((1 - (1 - L-S(7)) * (1 - L-S(7))) * 3.141592653589793)
         MOVE 0 TO MM-CZROT(L-P(3)) MM-CZROT(L-P(4))
         COMPUTE MM-CYROT(L-P(3)) = -(0.1 - WS-A * 0.6)
         COMPUTE MM-CYROT(L-P(4)) = 0.1 - WS-A * 0.6
         MOVE -1.5707964 TO MM-CXROT(L-P(3)) MM-CXROT(L-P(4))
         COMPUTE MM-CXROT(L-P(3)) = MM-CXROT(L-P(3)) - (WS-A * 1.2 - WS-B * 0.4)
         COMPUTE MM-CXROT(L-P(4)) = MM-CXROT(L-P(4)) - (WS-A * 1.2 - WS-B * 0.4)
         CALL "EMD-A-BOB" USING EMM-MODEL L-PIX L-S(6) WS-SKIP-R WS-SKIP-L
     END-IF
     GOBACK.
 END PROGRAM EMD-A-SKELETON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PIX.
    05 WS-P                BINARY-LONG OCCURS 8 TIMES.
 01 WS-NAMES.
    05 FILLER PIC X(24) VALUE "head".
    05 FILLER PIC X(24) VALUE "body".
    05 FILLER PIC X(24) VALUE "right_arm".
    05 FILLER PIC X(24) VALUE "left_arm".
    05 FILLER PIC X(24) VALUE "right_leg".
    05 FILLER PIC X(24) VALUE "left_leg".
    05 FILLER PIC X(24) VALUE "left_ear".
    05 FILLER PIC X(24) VALUE "right_ear".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(24) OCCURS 8 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-SKIP-R              BINARY-LONG.
 01 WS-SKIP-L              BINARY-LONG.
 01 WS-PHASE               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-STATE.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-VARIANT              BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-STATE L-VARIANT.
     CALL "EMM-RESET" USING EMM-MODEL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME(WS-K) WS-P(WS-K)
     END-PERFORM
*>   4.1 steps 2 to 4
     COMPUTE MM-CXROT(WS-P(1)) = L-S(1) * 0.017453292
     COMPUTE MM-CYROT(WS-P(1)) = L-S(2) * 0.017453292
     IF L-S(8) NOT = 0
         MOVE -0.7853982 TO MM-CXROT(WS-P(1))
     END-IF
     COMPUTE MM-CXROT(WS-P(3)) = FUNCTION COS(L-S(3) * 0.6662 + 3.141592653589793) * 2 * L-S(4) * 0.5 / L-S(5)
     COMPUTE MM-CXROT(WS-P(4)) = FUNCTION COS(L-S(3) * 0.6662) * 2 * L-S(4) * 0.5 / L-S(5)
     COMPUTE MM-CXROT(WS-P(5)) = FUNCTION COS(L-S(3) * 0.6662) * 1.4 * L-S(4) / L-S(5)
     COMPUTE MM-CXROT(WS-P(6)) = FUNCTION COS(L-S(3) * 0.6662 + 3.141592653589793) * 1.4 * L-S(4) / L-S(5)
     MOVE 0.005 TO MM-CYROT(WS-P(5)) MM-CZROT(WS-P(5))
     MOVE -0.005 TO MM-CYROT(WS-P(6)) MM-CZROT(WS-P(6))
     IF L-S(9) NOT = 0
         COMPUTE MM-CXROT(WS-P(3)) = MM-CXROT(WS-P(3)) - 0.62831855
         COMPUTE MM-CXROT(WS-P(4)) = MM-CXROT(WS-P(4)) - 0.62831855
         MOVE -1.4137167 TO MM-CXROT(WS-P(5)) MM-CXROT(WS-P(6))
         MOVE 0.31415927 TO MM-CYROT(WS-P(5))
         MOVE -0.31415927 TO MM-CYROT(WS-P(6))
         MOVE 0.07853982 TO MM-CZROT(WS-P(5))
         MOVE -0.07853982 TO MM-CZROT(WS-P(6))
     END-IF
*>   steps 5 and 6: arm poses and the attack animation
     CALL "EMD-A-POSES" USING EMM-MODEL L-STATE WS-PIX
     IF L-VARIANT NOT = 3 OR L-S(7) = 0 OR L-S(25) NOT = 0
         CALL "EMD-A-BASE-SWING" USING EMM-MODEL L-STATE WS-PIX
     END-IF
     EVALUATE L-VARIANT
         WHEN 1
             CALL "EMD-A-ZOMBIE-ARMS" USING EMM-MODEL L-STATE WS-PIX
         WHEN 4
             CALL "EMD-A-ZOMBIE-ARMS" USING EMM-MODEL L-STATE WS-PIX
         WHEN 5
             CALL "EMD-A-ZOMBIE-ARMS" USING EMM-MODEL L-STATE WS-PIX
         WHEN 3
             IF L-S(7) > 0 AND L-S(25) = 0
                 CALL "EMD-A-SWING-DOWN" USING EMM-MODEL L-STATE WS-PIX
             END-IF
     END-EVALUATE
*>   step 7 crouching, step 8 the arm bob, step 9 swimming
     IF L-S(10) NOT = 0
         MOVE 0.5 TO MM-CXROT(WS-P(2))
         COMPUTE MM-CXROT(WS-P(3)) = MM-CXROT(WS-P(3)) + 0.4
         COMPUTE MM-CXROT(WS-P(4)) = MM-CXROT(WS-P(4)) + 0.4
         COMPUTE MM-CZ(WS-P(5)) = MM-CZ(WS-P(5)) + 4
         COMPUTE MM-CZ(WS-P(6)) = MM-CZ(WS-P(6)) + 4
         COMPUTE MM-CY(WS-P(1)) = MM-CY(WS-P(1)) + 4.2
         COMPUTE MM-CY(WS-P(2)) = MM-CY(WS-P(2)) + 3.2
         COMPUTE MM-CY(WS-P(3)) = MM-CY(WS-P(3)) + 3.2
         COMPUTE MM-CY(WS-P(4)) = MM-CY(WS-P(4)) + 3.2
     END-IF
     MOVE 0 TO WS-SKIP-R WS-SKIP-L
     IF L-S(14) = 7
         MOVE 1 TO WS-SKIP-R
     END-IF
     IF L-S(15) = 7
         MOVE 1 TO WS-SKIP-L
     END-IF
     CALL "EMD-A-BOB" USING EMM-MODEL WS-PIX L-S(6) WS-SKIP-R WS-SKIP-L
     IF L-S(11) > 0
         CALL "EMD-A-SWIM" USING EMM-MODEL L-STATE WS-PIX L-VARIANT
     END-IF
*>   the variant extras
     IF L-VARIANT = 2
         CALL "EMD-A-SKELETON" USING EMM-MODEL L-STATE WS-PIX
     END-IF
     IF L-VARIANT = 3 OR L-VARIANT = 4
         CALL "EMD-A-EARS" USING EMM-MODEL L-STATE WS-PIX
     END-IF
     IF L-VARIANT = 3
         CALL "EMD-A-PIGLIN-POSE" USING EMM-MODEL L-STATE WS-PIX
     END-IF
     GOBACK.
 END PROGRAM EMD-ANIM.
