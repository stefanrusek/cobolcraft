from mesh4 import *
IDS=['HAPPY_GHAST','HAPPY_GHAST_BABY','HAPPY_GHAST_HARNESS','HAPPY_GHAST_BABY_HARNESS','HAPPY_GHAST_ROPES','HAPPY_GHAST_BABY_ROPES']
hdr='''*> Entity models part 4 section 11 (Happy ghast): the meshes of the ghast, harness and ropes layers (11.3), textures, the culling box and the ropes rule (11.1), setupAnim of the ghast and of the harness model (11.2).
*> Entry points for the integrator (inputs): EF4-GHAST-TEXTURE IN(baby) path(out X(120)); EF4-ROPES-TEXTURE path(out X(120)); EF4-GHAST-CULL IN(box minimum y, entity height) OUT(minimum y lowered by half the height);
*>   EF4-ROPES-DRAW IN(is leash holder, body item is in the harnesses tag) OUT(drawn); EF4-GHAST-TENTACLE IN(ageInTicks, index) OUT(xRot); EF4-GHAST-ANIM EMM-MODEL state(1 ageInTicks, 2 body item not empty): the tentacles and the harness
*>   body scale 0.9375 (carried through the layer scaling: the part's initial scale times 0.9375); EF4-HARNESS-ANIM EMM-MODEL state(1 is ridden): goggles xRot and height (the height is a local value, carried through the layer scale of the goggles part).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-GHAST-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/ghast/happy_ghast.png" TO L-PATH
     IF L-I(1) NOT = 0
         MOVE "textures/entity/ghast/happy_ghast_baby.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-GHAST-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-ROPES-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-PATH.
     MOVE "textures/entity/ghast/happy_ghast_ropes.png" TO L-PATH
     GOBACK.
 END PROGRAM EF4-ROPES-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-GHAST-CULL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) - L-I(2) / 2
     GOBACK.
 END PROGRAM EF4-GHAST-CULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-ROPES-DRAW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0 AND L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF4-ROPES-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-GHAST-TENTACLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = 0.2 * FUNCTION SIN(L-I(1) * 0.3 + L-I(2)) + 0.4
     GOBACK.
 END PROGRAM EF4-GHAST-TENTACLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-GHAST-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   PIC 9.
 01 WS-T-IN.
    05 WS-TI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-T-OUT.
    05 WS-TO               FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     IF L-I(2) NOT = 0
         COMPUTE MM-CXSCALE(WS-P) = MM-XSCALE(WS-P) * 0.9375
         COMPUTE MM-CYSCALE(WS-P) = MM-YSCALE(WS-P) * 0.9375
         COMPUTE MM-CZSCALE(WS-P) = MM-ZSCALE(WS-P) * 0.9375
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-NAME
         MOVE WS-I TO WS-D
         STRING "tentacle" WS-D DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-I TO WS-TI(2)
         MOVE L-I(1) TO WS-TI(1)
         CALL "EF4-GHAST-TENTACLE" USING WS-T-IN WS-T-OUT
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE WS-TO(1) TO MM-CXROT(WS-P)
     END-PERFORM
     GOBACK.
 END PROGRAM EF4-GHAST-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HARNESS-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "goggles" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     IF L-I(1) NOT = 0
         MOVE 0 TO MM-CXROT(WS-P)
         MOVE 14 TO WS-Y
     ELSE
         MOVE -0.7854 TO MM-CXROT(WS-P)
         MOVE 9 TO WS-Y
     END-IF
     COMPUTE MM-CY(WS-P) = WS-Y * MM-YSCALE(WS-P) + 24.016 * (1 - MM-YSCALE(WS-P))
     GOBACK.
 END PROGRAM EF4-HARNESS-ANIM.
'''
write_section_src(11,hdr,IDS,extra); write_layers(IDS)
