*> Entity models part 3 (docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md): the setupAnim of the models of this document, in the current pose
*> (MM-C* of client/copy/CLEMM.cpy) of a model built by EM3-LAYER (client/src/entmodel-34-3-mesh.cob). Each program resets the pose first (0.1 item 3).
*> Entry points for the integrator (inputs; every state is IN of 16 FLOAT-LONG):
*>   EM3-VILLAGER-ANIM EMM-MODEL state(1 xRot degrees, 2 yRot degrees, 3 walk position, 4 walk speed, 5 age in ticks, 6 unhappy counter): 1.3 (the baby too).
*>   EM3-ZV-ARMS EMM-MODEL state(1 baby, 2 main-hand empty, 3 aggressive, 4 swing, 5 right arm pose, 6 left arm pose): the zombie arms of 2.3.

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
 PROGRAM-ID. EM3-ZV-ARMS.
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
*> USING model state(1 baby, 2 main-hand stack empty, 3 aggressive, 4 swing progress, 5 right arm pose, 6 left arm pose; poses as 34-2 section 4: 4 THROW_TRIDENT, 10 SPEAR):
*> AnimationUtils.animateZombieArms of 2.3 on the right_arm and left_arm parts (the pose is reset first), "empty" being the baby or an empty main hand as this document states.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     IF L-I(5) = 10 OR L-I(6) = 10
         GOBACK
     END-IF
     MOVE "right_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RARM
     MOVE "left_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LARM
     MOVE 0 TO WS-BASE
     MOVE -1 TO WS-SIGN
     IF L-I(1) NOT = 0 OR L-I(2) NOT = 0
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
 END PROGRAM EM3-ZV-ARMS.
