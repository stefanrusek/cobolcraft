*> Entity models part 2 (docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md) section 4.10: the armor stand's own setupAnim, on a model built by EMD-LAYER
*> ("ARMOR_STAND" or "ARMOR_STAND_SMALL"; current pose MM-C* of client/copy/CLEMM.cpy).
*> Entry point for the integrator (inputs): EMD-ARMORSTAND-ANIM EMM-MODEL state(FLOAT-LONG, 21): 1 to 3 head, 4 to 6 body, 7 to 9 left arm, 10 to 12 right arm, 13 to 15 left leg,
*>   16 to 18 right leg (the state Rotations x y z in degrees), 19 the state yRot (degrees), 20 show arms, 21 show base plate. The pose is reset, the six parts take the Rotations (the base
*>   animation of 4.1 is overwritten for them), base_plate.yRot = -yRot, the arms are visible when show arms, the base plate when show base plate, the three sticks copy the body rotations.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-ARMORSTAND-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER              PIC X(24) VALUE "head".
    05 FILLER              PIC X(24) VALUE "body".
    05 FILLER              PIC X(24) VALUE "left_arm".
    05 FILLER              PIC X(24) VALUE "right_arm".
    05 FILLER              PIC X(24) VALUE "left_leg".
    05 FILLER              PIC X(24) VALUE "right_leg".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(24) OCCURS 6 TIMES.
 01 WS-STICKS.
    05 FILLER              PIC X(24) VALUE "right_body_stick".
    05 FILLER              PIC X(24) VALUE "left_body_stick".
    05 FILLER              PIC X(24) VALUE "shoulder_stick".
 01 WS-STICKS-R REDEFINES WS-STICKS.
    05 WS-STICK            PIC X(24) OCCURS 3 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-PN                  PIC X(24).
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME(WS-K) WS-P
         COMPUTE MM-CXROT(WS-P) = L-I(WS-K * 3 - 2) * 0.017453292
         COMPUTE MM-CYROT(WS-P) = L-I(WS-K * 3 - 1) * 0.017453292
         COMPUTE MM-CZROT(WS-P) = L-I(WS-K * 3) * 0.017453292
         IF WS-K = 3 OR WS-K = 4
             MOVE 0 TO MM-VISIBLE(WS-P)
             IF L-I(20) NOT = 0
                 MOVE 1 TO MM-VISIBLE(WS-P)
             END-IF
         END-IF
     END-PERFORM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-BODY
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         CALL "EMM-FIND" USING EMM-MODEL WS-STICK(WS-K) WS-P
         MOVE MM-CXROT(WS-BODY) TO MM-CXROT(WS-P)
         MOVE MM-CYROT(WS-BODY) TO MM-CYROT(WS-P)
         MOVE MM-CZROT(WS-BODY) TO MM-CZROT(WS-P)
     END-PERFORM
     MOVE "base_plate" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     COMPUTE MM-CYROT(WS-P) = 0.017453292 * -L-I(19)
     MOVE 0 TO MM-VISIBLE(WS-P)
     IF L-I(21) NOT = 0
         MOVE 1 TO MM-VISIBLE(WS-P)
     END-IF
     GOBACK.
 END PROGRAM EMD-ARMORSTAND-ANIM.
