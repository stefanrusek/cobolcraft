from mesh4 import *
IDS=['CHICKEN','COLD_CHICKEN','CHICKEN_BABY']
hdr='''*> Entity models part 4 section 6 (Chicken): the meshes of chicken, cold_chicken and chicken_baby (6.3), the flap interpolation (6.1) and setupAnim (6.2).
*> Entry points for the integrator (inputs): EF4-CHICKEN-FLAP IN(partial, old value, new value) OUT(lerp) for flap and flapSpeed (6.1);
*>   EF4-CHICKEN-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 flap, 6 flapSpeed): leg swings, wing flap and (adult, cold) head turn, reset first. Model choice: EF4-VARIANT-MODEL.
'''
extra=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-CHICKEN-FLAP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(2) + L-I(1) * (L-I(3) - L-I(2))
     GOBACK.
 END PROGRAM EF4-CHICKEN-FLAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-CHICKEN-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     COMPUTE WS-W = (FUNCTION SIN(L-I(5)) + 1) * L-I(6)
     MOVE "right_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     COMPUTE MM-CXROT(WS-P) = FUNCTION COS(0.6662 * L-I(3)) * 1.4 * L-I(4)
     MOVE "left_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     COMPUTE MM-CXROT(WS-P) = FUNCTION COS(0.6662 * L-I(3) + 3.141592653589793) * 1.4 * L-I(4)
     MOVE "right_wing" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     MOVE WS-W TO MM-CZROT(WS-P)
     MOVE "left_wing" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     COMPUTE MM-CZROT(WS-P) = 0 - WS-W
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     IF WS-P NOT = 0
         COMPUTE MM-CXROT(WS-P) = L-I(1) * 3.141592653589793 / 180
         COMPUTE MM-CYROT(WS-P) = L-I(2) * 3.141592653589793 / 180
     END-IF
     GOBACK.
 END PROGRAM EF4-CHICKEN-ANIM.
'''
write_section_src(6,hdr,IDS,extra); write_layers(IDS)
