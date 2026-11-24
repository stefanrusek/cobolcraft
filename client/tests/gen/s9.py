from mesh4 import *
IDS=['LLAMA','TRADER_LLAMA','LLAMA_BABY','TRADER_LLAMA_BABY','LLAMA_DECOR','LLAMA_BABY_DECOR','LLAMA_SPIT']
hdr='''*> Entity models part 4 section 9 (Llama and trader llama): the meshes of the llama, decor and spit layers (9.4, 9.5), variants and textures (9.1), the decor algorithm (9.3), setupAnim (9.2), spit pose (9.5).
*> Entry points for the integrator (inputs): EF4-LLAMA-VARIANT IN(id) OUT(ordinal 0 creamy 1 white 2 brown 3 gray, clamped); EF4-LLAMA-TEXTURE IN(ordinal, baby) path(out X(120)); EF4-LLAMA-CHEST IN(hasChest, baby) OUT(state hasChest);
*>   EF4-LLAMA-DECOR IN(body item has an equippable asset, baby, trader) OUT(mode 0 nothing 1 the item's asset 2 the trader carpet asset, baby decor model); EF4-LLAMA-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position,
*>   4 walk speed, 5 hasChest); EF4-SPIT-OPS IN(xRot deg, yRot deg) OUT(count, then code 1 translate 2 rotate Y deg 3 rotate Z deg and three values each); EF4-SPIT-TEXTURE path(out X(120)).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-LLAMA-VARIANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO L-O(1)
     IF L-I(1) < 0
         MOVE 0 TO L-O(1)
     END-IF
     IF L-I(1) > 3
         MOVE 3 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF4-LLAMA-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-LLAMA-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(8) VALUE "creamy".
    05 FILLER PIC X(8) VALUE "white".
    05 FILLER PIC X(8) VALUE "brown".
    05 FILLER PIC X(8) VALUE "gray".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(8) OCCURS 4 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     COMPUTE WS-K = L-I(1) + 1
     MOVE SPACES TO L-PATH
     IF L-I(2) NOT = 0
         STRING "textures/entity/llama/llama_" FUNCTION TRIM(WS-NAME(WS-K)) "_baby.png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING "textures/entity/llama/llama_" FUNCTION TRIM(WS-NAME(WS-K)) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-LLAMA-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-LLAMA-CHEST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0 AND L-I(2) = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF4-LLAMA-CHEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-LLAMA-DECOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     IF L-I(1) NOT = 0 AND L-I(2) = 0
         MOVE 1 TO L-O(1)
     ELSE
         IF L-I(3) NOT = 0
             MOVE 2 TO L-O(1)
             MOVE L-I(2) TO L-O(2)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF4-LLAMA-DECOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-LLAMA-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EF4-QUAD-POSE" USING EMM-MODEL L-IN
     MOVE "right_chest" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     MOVE 0 TO MM-VISIBLE(WS-P)
     IF L-I(5) NOT = 0
         MOVE 1 TO MM-VISIBLE(WS-P)
     END-IF
     MOVE "left_chest" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     MOVE 0 TO MM-VISIBLE(WS-P)
     IF L-I(5) NOT = 0
         MOVE 1 TO MM-VISIBLE(WS-P)
     END-IF
     GOBACK.
 END PROGRAM EF4-LLAMA-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-SPIT-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 3 TO L-O(1)
     MOVE 1 TO L-O(2)
     MOVE 0 TO L-O(3)
     MOVE 0.15 TO L-O(4)
     MOVE 0 TO L-O(5)
     MOVE 2 TO L-O(6)
     COMPUTE L-O(7) = L-I(2) - 90
     MOVE 0 TO L-O(8) L-O(9)
     MOVE 3 TO L-O(10)
     MOVE L-I(1) TO L-O(11)
     MOVE 0 TO L-O(12) L-O(13)
     GOBACK.
 END PROGRAM EF4-SPIT-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-SPIT-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-PATH.
     MOVE "textures/entity/llama/llama_spit.png" TO L-PATH
     GOBACK.
 END PROGRAM EF4-SPIT-TEXTURE.
'''
write_section_src(9,hdr,IDS,extra); write_layers(IDS)
