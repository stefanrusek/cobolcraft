*> Entity models part 3 (docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md): the setupAnim of the models of this document, in the current pose
*> (MM-C* of client/copy/CLEMM.cpy) of a model built by EM3-LAYER (client/src/entmodel-34-3-mesh.cob). Each program resets the pose first (0.1 item 3).
*> Entry points for the integrator (inputs; every state is IN of 16 FLOAT-LONG):
*>   EM3-VILLAGER-ANIM EMM-MODEL state(1 xRot degrees, 2 yRot degrees, 3 walk position, 4 walk speed, 5 age in ticks, 6 unhappy counter): 1.3 (the baby too).
*>   EM3-ZV-ARMS EMM-MODEL state(1 baby, 2 main-hand empty, 3 aggressive, 4 swing, 5 right arm pose, 6 left arm pose): the zombie arms of 2.3.
*>   EM3-WITCH-ANIM EMM-MODEL state(1 xRot degrees, 2 yRot degrees, 3 walk position, 4 walk speed, 5 age, 6 entity id, 7 holds an item): 3.2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-VILLAGER-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEAD                BINARY-LONG.
 01 WS-RLEG                BINARY-LONG.
 01 WS-LLEG                BINARY-LONG.
 01 WS-NAME                PIC X(24).
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     MOVE "right_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RLEG
     MOVE "left_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LLEG
     COMPUTE MM-CYROT(WS-HEAD) = L-I(2) * 0.017453292
     COMPUTE MM-CXROT(WS-HEAD) = L-I(1) * 0.017453292
     IF L-I(6) > 0
         COMPUTE MM-CZROT(WS-HEAD) = 0.3 * FUNCTION SIN(0.45 * L-I(5))
         MOVE 0.4 TO MM-CXROT(WS-HEAD)
     ELSE
         MOVE 0 TO MM-CZROT(WS-HEAD)
     END-IF
     COMPUTE MM-CXROT(WS-RLEG) = FUNCTION COS(L-I(3) * 0.6662) * 1.4 * L-I(4) * 0.5
     COMPUTE MM-CXROT(WS-LLEG) = FUNCTION COS(L-I(3) * 0.6662 + 3.1415927) * 1.4 * L-I(4) * 0.5
     MOVE 0 TO MM-CYROT(WS-RLEG) MM-CYROT(WS-LLEG)
     GOBACK.
 END PROGRAM EM3-VILLAGER-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ZARMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RARM                BINARY-LONG.
 01 WS-LARM                BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-BASE                FLOAT-LONG.
 01 WS-SIGN                FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
*> (no reset) USING model state(1 baby, 2 main-hand stack empty, 3 aggressive, 4 swing progress, 5 right arm pose, 6 left arm pose; poses as 34-2 section 4: 4 THROW_TRIDENT, 10 SPEAR):
*> AnimationUtils.animateZombieArms of 2.3 on the right_arm and left_arm parts (the pose is reset first), "raised" being: not a baby, or an empty main hand (the corrected 2.3 step 2).
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     IF L-I(5) = 10 OR L-I(6) = 10
         GOBACK
     END-IF
     MOVE "right_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RARM
     MOVE "left_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LARM
     MOVE 0 TO WS-BASE
     MOVE -1 TO WS-SIGN
     IF L-I(1) = 0 OR L-I(2) NOT = 0
         MOVE 1 TO WS-SIGN
         COMPUTE WS-BASE = -3.1415927 / 2.25
         IF L-I(3) NOT = 0
             COMPUTE WS-BASE = -3.1415927 / 1.5
         END-IF
     END-IF
     COMPUTE WS-A = WS-SIGN * FUNCTION SIN(L-I(4) * 3.1415927)
     COMPUTE WS-B = FUNCTION SIN((1 - (1 - L-I(4)) * (1 - L-I(4))) * 3.1415927)
     COMPUTE WS-X = WS-BASE + WS-A * 1.2 - WS-B * 0.4
     COMPUTE WS-Y = 0.1 - WS-A * 0.6
     IF L-I(5) NOT = 4
         MOVE WS-X TO MM-CXROT(WS-RARM)
         COMPUTE MM-CYROT(WS-RARM) = WS-Y * WS-SIGN * -1
         MOVE 0 TO MM-CZROT(WS-RARM)
     END-IF
     IF L-I(6) NOT = 4
         MOVE WS-X TO MM-CXROT(WS-LARM)
         COMPUTE MM-CYROT(WS-LARM) = WS-Y * WS-SIGN
         MOVE 0 TO MM-CZROT(WS-LARM)
     END-IF
     GOBACK.
 END PROGRAM EM3-ZARMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ZV-ARMS.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
*> USING model state (as EM3-ZARMS): resets the pose, then animateZombieArms of 2.3 (the zombie villager, 2.3).
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     CALL "EM3-ZARMS" USING EMM-MODEL L-IN
     GOBACK.
 END PROGRAM EM3-ZV-ARMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-WITCH-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEAD                BINARY-LONG.
 01 WS-RLEG                BINARY-LONG.
 01 WS-LLEG                BINARY-LONG.
 01 WS-NOSE                BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-F                   FLOAT-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
*> USING model state(1 xRot degrees, 2 yRot degrees, 3 walk position, 4 walk speed, 5 age in ticks, 6 entity id, 7 holds an item): WitchModel.setupAnim (3.2).
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     MOVE "right_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RLEG
     MOVE "left_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LLEG
     MOVE "nose" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-NOSE
     COMPUTE MM-CYROT(WS-HEAD) = L-I(2) * 0.017453292
     COMPUTE MM-CXROT(WS-HEAD) = L-I(1) * 0.017453292
     COMPUTE MM-CXROT(WS-RLEG) = FUNCTION COS(L-I(3) * 0.6662) * 1.4 * L-I(4) * 0.5
     COMPUTE MM-CXROT(WS-LLEG) = FUNCTION COS(L-I(3) * 0.6662 + 3.1415927) * 1.4 * L-I(4) * 0.5
     COMPUTE WS-ID = L-I(6)
     COMPUTE WS-F = 0.01 * FUNCTION MOD(WS-ID, 10)
     COMPUTE MM-CXROT(WS-NOSE) = FUNCTION SIN(L-I(5) * WS-F) * 4.5 * 0.017453292
     COMPUTE MM-CZROT(WS-NOSE) = FUNCTION COS(L-I(5) * WS-F) * 2.5 * 0.017453292
     IF L-I(7) NOT = 0
         MOVE 0 TO MM-CX(WS-NOSE)
         MOVE 1 TO MM-CY(WS-NOSE)
         MOVE -1.5 TO MM-CZ(WS-NOSE)
         MOVE -0.9 TO MM-CXROT(WS-NOSE)
     END-IF
     GOBACK.
 END PROGRAM EM3-WITCH-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ILLAGER-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEAD                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-RLEG                BINARY-LONG.
 01 WS-LLEG                BINARY-LONG.
 01 WS-ARMS                BINARY-LONG.
 01 WS-HAT                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-Z.
    05 WS-ZV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-SD-IN.
    05 WS-SI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-SD-OUT.
    05 WS-SO               FLOAT-LONG OCCURS 10 TIMES.
 01 WS-D                   FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
*> USING model state(1 xRot degrees, 2 yRot degrees, 3 walk position, 4 walk speed, 5 age, 6 is riding, 7 arm pose (0 CROSSED, 1 ATTACKING, 2 SPELLCASTING, 3 BOW_AND_ARROW,
*> 4 CROSSBOW_HOLD, 5 CROSSBOW_CHARGE, 6 CELEBRATING, 7 NEUTRAL), 8 main-hand item empty, 9 swing progress, 10 main arm (1 right, 2 left), 11 maximum crossbow charge,
*> 12 ticks using the item, 13 right arm pose, 14 left arm pose (34-2 numbering), 15 hat visible (the illusioner)): IllagerModel.setupAnim (4.2) with 4.4.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     MOVE "right_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-R
     MOVE "left_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-L
     MOVE "right_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RLEG
     MOVE "left_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LLEG
     MOVE "arms" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-ARMS
     MOVE "hat" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HAT
     COMPUTE MM-CYROT(WS-HEAD) = L-I(2) * 0.017453292
     COMPUTE MM-CXROT(WS-HEAD) = L-I(1) * 0.017453292
     IF L-I(6) NOT = 0
         MOVE -0.62831855 TO MM-CXROT(WS-R) MM-CXROT(WS-L)
         MOVE 0 TO MM-CYROT(WS-R) MM-CYROT(WS-L) MM-CZROT(WS-R) MM-CZROT(WS-L)
         MOVE -1.4137167 TO MM-CXROT(WS-RLEG) MM-CXROT(WS-LLEG)
         MOVE 0.31415927 TO MM-CYROT(WS-RLEG)
         MOVE -0.31415927 TO MM-CYROT(WS-LLEG)
         MOVE 0.07853982 TO MM-CZROT(WS-RLEG)
         MOVE -0.07853982 TO MM-CZROT(WS-LLEG)
     ELSE
         COMPUTE MM-CXROT(WS-R) = FUNCTION COS(L-I(3) * 0.6662 + 3.1415927) * 2 * L-I(4) * 0.5
         COMPUTE MM-CXROT(WS-L) = FUNCTION COS(L-I(3) * 0.6662) * 2 * L-I(4) * 0.5
         COMPUTE MM-CXROT(WS-RLEG) = FUNCTION COS(L-I(3) * 0.6662) * 1.4 * L-I(4) * 0.5
         COMPUTE MM-CXROT(WS-LLEG) = FUNCTION COS(L-I(3) * 0.6662 + 3.1415927) * 1.4 * L-I(4) * 0.5
         MOVE 0 TO MM-CYROT(WS-R) MM-CYROT(WS-L) MM-CYROT(WS-RLEG) MM-CYROT(WS-LLEG)
         MOVE 0 TO MM-CZROT(WS-R) MM-CZROT(WS-L) MM-CZROT(WS-RLEG) MM-CZROT(WS-LLEG)
     END-IF
     EVALUATE L-I(7)
         WHEN 1
             PERFORM POSE-ATTACKING
         WHEN 2
             MOVE 0 TO MM-CZ(WS-R) MM-CZ(WS-L) MM-CYROT(WS-R) MM-CYROT(WS-L)
             MOVE -5 TO MM-CX(WS-R)
             MOVE 5 TO MM-CX(WS-L)
             COMPUTE WS-C = FUNCTION COS(L-I(5) * 0.6662) * 0.25
             MOVE WS-C TO MM-CXROT(WS-R) MM-CXROT(WS-L)
             MOVE 2.3561945 TO MM-CZROT(WS-R)
             MOVE -2.3561945 TO MM-CZROT(WS-L)
         WHEN 3
             COMPUTE MM-CYROT(WS-R) = -0.1 + MM-CYROT(WS-HEAD)
             COMPUTE MM-CXROT(WS-R) = -1.5707964 + MM-CXROT(WS-HEAD)
             COMPUTE MM-CXROT(WS-L) = -0.9424779 + MM-CXROT(WS-HEAD)
             COMPUTE MM-CYROT(WS-L) = MM-CYROT(WS-HEAD) - 0.4
             MOVE 1.5707964 TO MM-CZROT(WS-L)
         WHEN 4
             COMPUTE MM-CYROT(WS-R) = MM-CYROT(WS-R) + MM-CYROT(WS-HEAD) - 0.3
             COMPUTE MM-CYROT(WS-L) = MM-CYROT(WS-L) + MM-CYROT(WS-HEAD) + 0.6
             COMPUTE MM-CXROT(WS-R) = -1.5707964 + MM-CXROT(WS-HEAD) + 0.1
             COMPUTE MM-CXROT(WS-L) = -1.5 + MM-CXROT(WS-HEAD)
         WHEN 5
             PERFORM POSE-CHARGE
         WHEN 6
             MOVE 0 TO MM-CZ(WS-R) MM-CZ(WS-L) MM-CYROT(WS-R) MM-CYROT(WS-L)
             MOVE -5 TO MM-CX(WS-R)
             MOVE 5 TO MM-CX(WS-L)
             COMPUTE WS-C = FUNCTION COS(L-I(5) * 0.6662) * 0.05
             MOVE WS-C TO MM-CXROT(WS-R) MM-CXROT(WS-L)
             MOVE 2.670354 TO MM-CZROT(WS-R)
             MOVE -2.3561945 TO MM-CZROT(WS-L)
     END-EVALUATE
     MOVE 0 TO MM-VISIBLE(WS-ARMS)
     MOVE 1 TO MM-VISIBLE(WS-R) MM-VISIBLE(WS-L)
     IF L-I(7) = 0
         MOVE 1 TO MM-VISIBLE(WS-ARMS)
         MOVE 0 TO MM-VISIBLE(WS-R) MM-VISIBLE(WS-L)
     END-IF
     MOVE L-I(15) TO MM-VISIBLE(WS-HAT)
     GO TO PROGRAM-DONE.

 POSE-ATTACKING.
     IF L-I(8) NOT = 0
         MOVE 0 TO WS-ZV(1)
         MOVE L-I(8) TO WS-ZV(2)
         MOVE 1 TO WS-ZV(3)
         MOVE L-I(9) TO WS-ZV(4)
         MOVE L-I(13) TO WS-ZV(5)
         MOVE L-I(14) TO WS-ZV(6)
         CALL "EM3-ZARMS" USING EMM-MODEL WS-Z
         COMPUTE WS-BZ = FUNCTION COS(0.09 * L-I(5)) * 0.05 + 0.05
         COMPUTE WS-BX = FUNCTION SIN(0.067 * L-I(5)) * 0.05
         COMPUTE MM-CZROT(WS-R) = MM-CZROT(WS-R) + WS-BZ
         COMPUTE MM-CXROT(WS-R) = MM-CXROT(WS-R) + WS-BX
         COMPUTE MM-CZROT(WS-L) = MM-CZROT(WS-L) - WS-BZ
         COMPUTE MM-CXROT(WS-L) = MM-CXROT(WS-L) - WS-BX
     ELSE
         MOVE L-I(9) TO WS-SI(1)
         MOVE L-I(5) TO WS-SI(2)
         MOVE L-I(10) TO WS-SI(3)
         CALL "EM3-SWING-DOWN" USING WS-SD-IN WS-SD-OUT
         MOVE WS-SO(1) TO MM-CXROT(WS-R)
         MOVE WS-SO(2) TO MM-CYROT(WS-R)
         MOVE WS-SO(3) TO MM-CZROT(WS-R)
         MOVE WS-SO(4) TO MM-CXROT(WS-L)
         MOVE WS-SO(5) TO MM-CYROT(WS-L)
         MOVE WS-SO(6) TO MM-CZROT(WS-L)
     END-IF.

 POSE-CHARGE.
     MOVE -0.8 TO MM-CYROT(WS-R)
     MOVE -0.97079635 TO MM-CXROT(WS-R)
     MOVE L-I(12) TO WS-D
     IF WS-D < 0
         MOVE 0 TO WS-D
     END-IF
     IF WS-D > L-I(11)
         MOVE L-I(11) TO WS-D
     END-IF
     COMPUTE WS-D = WS-D / L-I(11)
     COMPUTE MM-CYROT(WS-L) = 0.4 + WS-D * (0.85 - 0.4)
     COMPUTE MM-CXROT(WS-L) = -0.97079635 + WS-D * (-1.5707964 + 0.97079635).

 PROGRAM-DONE.
     GOBACK.
 END PROGRAM EM3-ILLAGER-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-FANGS-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-BASE                BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-Q                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
*> USING model state(1 bite progress p, 0 to 1): EvokerFangsModel.setupAnim (4.8).
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "base" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-BASE
     MOVE "upper_jaw" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-UP
     MOVE "lower_jaw" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LOW
     COMPUTE WS-Q = L-I(1) * 2
     IF WS-Q > 1
         MOVE 1 TO WS-Q
     END-IF
     COMPUTE WS-Q = 1 - WS-Q * WS-Q * WS-Q
     COMPUTE MM-CZROT(WS-UP) = 3.1415927 - WS-Q * 0.35 * 3.1415927
     COMPUTE MM-CZROT(WS-LOW) = 3.1415927 + WS-Q * 0.35 * 3.1415927
     COMPUTE MM-CY(WS-BASE) = MM-CY(WS-BASE) - (L-I(1) + FUNCTION SIN(L-I(1) * 2.7)) * 7.2
     MOVE 1 TO WS-R
     IF L-I(1) > 0.9
         COMPUTE WS-R = (1 - L-I(1)) / 0.1
     END-IF
     COMPUTE MM-CY(WS-ROOT) = 24 - 20 * WS-R
     MOVE WS-R TO MM-CXSCALE(WS-ROOT) MM-CYSCALE(WS-ROOT) MM-CZSCALE(WS-ROOT)
     GOBACK.
 END PROGRAM EM3-FANGS-ANIM.
