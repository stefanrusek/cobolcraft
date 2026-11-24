from mesh5 import *
IDS=['TURTLE','TURTLE_BABY']
hdr='''*> Entity models part 5 section 13 (Turtle): the adult and baby meshes (13.1), setupAnim on the quadruped base (13.2), textures, shadow and state flags (13.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-TURTLE-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 on land, 6 laying an egg, 7 has egg, 8 baby model): the quadruped base (resets first), then land gait or water paddle, then the egg belly of the adult;
*>   EF5-TURTLE-TEXTURE IN(baby) path(out X(120)); EF5-TURTLE-SHADOW IN(baby, scale) OUT(0.7 x scale, x 0.83 for the baby); EF5-TURTLE-STATE IN(in water, on ground, laying, has egg, baby) OUT(isOnLand, isLayingEgg, hasEgg).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-TURTLE-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-RH                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-LF                  BINARY-LONG.
 01 WS-EB                  BINARY-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-C1                  FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EF5-QUAD-POSE" USING EMM-MODEL L-IN
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RH
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LH
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RF
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LF
     IF L-I(5) NOT = 0
         MOVE 1 TO WS-F1 WS-F2
         IF L-I(6) NOT = 0
             MOVE 4 TO WS-F1
             MOVE 2 TO WS-F2
         END-IF
         COMPUTE WS-Q = 5 * L-I(3)
         COMPUTE WS-C1 = FUNCTION COS(WS-F1 * WS-Q)
         COMPUTE WS-C2 = FUNCTION COS(WS-Q)
         COMPUTE MM-CYROT(WS-RF) = 0 - WS-C1 * 8 * L-I(4) * WS-F2
         COMPUTE MM-CYROT(WS-LF) = WS-C1 * 8 * L-I(4) * WS-F2
         COMPUTE MM-CYROT(WS-RH) = 0 - WS-C2 * 3 * L-I(4)
         COMPUTE MM-CYROT(WS-LH) = WS-C2 * 3 * L-I(4)
     ELSE
         COMPUTE WS-M = 0.5 * L-I(4)
         COMPUTE WS-U = FUNCTION COS(0.6662 * 0.6 * L-I(3)) * WS-M
         MOVE WS-U TO MM-CXROT(WS-RH)
         COMPUTE MM-CXROT(WS-LH) = 0 - WS-U
         COMPUTE MM-CZROT(WS-RF) = 0 - WS-U
         MOVE WS-U TO MM-CZROT(WS-LF)
     END-IF
     IF L-I(8) = 0
         MOVE "egg_belly" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-EB
         MOVE 0 TO MM-VISIBLE(WS-EB)
         IF L-I(7) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-EB)
             COMPUTE MM-CY(1) = MM-CY(1) - 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF5-TURTLE-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-TURTLE-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     IF L-I(1) NOT = 0
         MOVE "textures/entity/turtle/turtle_baby.png" TO L-PATH
     ELSE
         MOVE "textures/entity/turtle/turtle.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-TURTLE-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-TURTLE-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = 0.7 * L-I(2)
     IF L-I(1) NOT = 0
         COMPUTE L-O(1) = L-O(1) * 0.83
     END-IF
     GOBACK.
 END PROGRAM EF5-TURTLE-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-TURTLE-STATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(3)
     IF L-I(1) = 0 AND L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
     END-IF
     MOVE L-I(3) TO L-O(2)
     IF L-I(4) NOT = 0 AND L-I(5) = 0
         MOVE 1 TO L-O(3)
     END-IF
     GOBACK.
 END PROGRAM EF5-TURTLE-STATE.
'''
write_section_src(13,hdr,IDS,extra); write_layers(IDS)
