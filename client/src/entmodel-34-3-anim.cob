*> Entity models part 3 (docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md): the setupAnim of the models of this document, in the current pose
*> (MM-C* of client/copy/CLEMM.cpy) of a model built by EM3-LAYER (client/src/entmodel-34-3-mesh.cob). Each program resets the pose first (0.1 item 3).
*> Entry points for the integrator (inputs; every state is IN of 16 FLOAT-LONG):
*>   EM3-VILLAGER-ANIM EMM-MODEL state(1 xRot degrees, 2 yRot degrees, 3 walk position, 4 walk speed, 5 age in ticks, 6 unhappy counter): 1.3 (the baby too).

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
