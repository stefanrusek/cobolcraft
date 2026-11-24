from mesh6 import *
setlayer('ENDERMAN',doc6.rows_from(6,'### 3.1'),64,32)
IDS=['ENDERMAN']
hdr='''*> Entity models part 6 section 3 (Enderman): the mesh (3.1), setupAnim on the humanoid base (3.2), texture, render offset, eyes layer texture and the carried block transform (3.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-ENDERMAN-ANIM EMM-MODEL state(48 FLOAT-LONG, the humanoid state of client/src/entmodel-34-2-anim.cob) carried(BINARY-LONG, a block is carried) creepy(BINARY-LONG): EMD-ANIM base (variant 0), head visible, limb swing x 0.5 clamped to +-0.4,
*>   the carried arms, the creepy head and hat; EF6-ENDERMAN-TEXTURE IN(eyes) path(out X(120)); EF6-ENDERMAN-OFFSET IN(creepy, gaussian 1, gaussian 2, scale, base x, y, z) OUT(x y z): getRenderOffset;
*>   EF6-ENDERMAN-BLOCK-OPS IN(carried) OUT(count, then code 1 translate 2 scale 3 rotate Y deg 6 rotate X deg and three values each): CarriedBlockLayer.
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-ENDERMAN-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-VARIANT             BINARY-LONG VALUE 0.
 01 WS-HEAD                BINARY-LONG.
 01 WS-HAT                 BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-LA                  BINARY-LONG.
 01 WS-RL                  BINARY-LONG.
 01 WS-LL                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PARTS.
    05 WS-PART             BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-ST.
    05 L-S                 FLOAT-LONG OCCURS 48 TIMES.
 01 L-CARRIED              BINARY-LONG.
 01 L-CREEPY               BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-ST L-CARRIED L-CREEPY.
     CALL "EMD-ANIM" USING EMM-MODEL L-ST WS-VARIANT
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     MOVE "hat" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HAT
     MOVE "right_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RA
     MOVE "left_arm" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LA
     MOVE "right_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RL
     MOVE "left_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LL
     MOVE 1 TO MM-VISIBLE(WS-HEAD)
     MOVE WS-RA TO WS-PART(1)
     MOVE WS-LA TO WS-PART(2)
     MOVE WS-RL TO WS-PART(3)
     MOVE WS-LL TO WS-PART(4)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE MM-CXROT(WS-PART(WS-K)) = MM-CXROT(WS-PART(WS-K)) * 0.5
         IF MM-CXROT(WS-PART(WS-K)) < -0.4
             MOVE -0.4 TO MM-CXROT(WS-PART(WS-K))
         END-IF
         IF MM-CXROT(WS-PART(WS-K)) > 0.4
             MOVE 0.4 TO MM-CXROT(WS-PART(WS-K))
         END-IF
     END-PERFORM
     IF L-CARRIED NOT = 0
         MOVE -0.5 TO MM-CXROT(WS-RA) MM-CXROT(WS-LA)
         MOVE 0.05 TO MM-CZROT(WS-RA)
         MOVE -0.05 TO MM-CZROT(WS-LA)
     END-IF
     IF L-CREEPY NOT = 0
         COMPUTE MM-CY(WS-HEAD) = MM-CY(WS-HEAD) - 5
         COMPUTE MM-CY(WS-HAT) = MM-CY(WS-HAT) + 5
     END-IF
     GOBACK.
 END PROGRAM EF6-ENDERMAN-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-ENDERMAN-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     IF L-I(1) NOT = 0
         MOVE "textures/entity/enderman/enderman_eyes.png" TO L-PATH
     ELSE
         MOVE "textures/entity/enderman/enderman.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF6-ENDERMAN-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-ENDERMAN-OFFSET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(5) TO L-O(1)
     MOVE L-I(6) TO L-O(2)
     MOVE L-I(7) TO L-O(3)
     IF L-I(1) NOT = 0
         COMPUTE L-O(1) = L-I(5) + L-I(2) * 0.02 * L-I(4)
         COMPUTE L-O(3) = L-I(7) + L-I(3) * 0.02 * L-I(4)
     END-IF
     GOBACK.
 END PROGRAM EF6-ENDERMAN-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-ENDERMAN-BLOCK-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0
         MOVE 6 TO L-O(1)
         MOVE 1 TO L-O(2)
         MOVE 0 TO L-O(3)
         MOVE 0.6875 TO L-O(4)
         MOVE -0.75 TO L-O(5)
         MOVE 6 TO L-O(6)
         MOVE 20 TO L-O(7)
         MOVE 0 TO L-O(8) L-O(9)
         MOVE 3 TO L-O(10)
         MOVE 45 TO L-O(11)
         MOVE 0 TO L-O(12) L-O(13)
         MOVE 1 TO L-O(14)
         MOVE 0.25 TO L-O(15)
         MOVE 0.1875 TO L-O(16)
         MOVE 0.25 TO L-O(17)
         MOVE 2 TO L-O(18)
         MOVE -0.5 TO L-O(19) L-O(20)
         MOVE 0.5 TO L-O(21)
         MOVE 3 TO L-O(22)
         MOVE 90 TO L-O(23)
         MOVE 0 TO L-O(24) L-O(25)
     END-IF
     GOBACK.
 END PROGRAM EF6-ENDERMAN-BLOCK-OPS.
'''
write_section_src(3,hdr,IDS,extra); write_layers(IDS)
