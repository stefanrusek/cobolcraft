from mesh4 import *
IDS=['HORSE','SKELETON_HORSE','ZOMBIE_HORSE','HORSE_ARMOR','UNDEAD_HORSE_ARMOR','HORSE_SADDLE','SKELETON_HORSE_SADDLE','ZOMBIE_HORSE_SADDLE','HORSE_BABY','SKELETON_HORSE_BABY','ZOMBIE_HORSE_BABY','DONKEY','MULE','DONKEY_SADDLE','MULE_SADDLE','DONKEY_BABY','MULE_BABY']
hdr='''*> Entity models part 4 section 8 (Equines): the meshes of the horse, armor, saddle, baby, donkey and mule layers and their unscaled aliases (8.6), registrations and textures (8.2, 8.5), setupAnim (8.3, 8.4).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF4-EQUINE-REG entity(X(24)) saddle-layer-type(out X(40)) saddle-scale(out FLOAT-LONG) (8.2); EF4-EQUINE-TEXTURE entity baby path(out X(120)) for donkey, mule, skeleton_horse, zombie_horse (8.2);
*>   EF4-HORSE-VARIANT IN(id) OUT(ordinal, wraps modulo 7); EF4-HORSE-TEXTURE IN(ordinal, baby) path(out X(120)); EF4-HORSE-MARKING-ID IN(id) OUT(ordinal, wraps modulo 5);
*>   EF4-HORSE-MARKING IN(ordinal, baby) path(out X(120), spaces for none); EF4-MARKING-DRAW IN(texture present, invisible) OUT(drawn) (8.5).
*>   EF4-EQUINE-ANIM EMM-MODEL state(1 xRot deg, 2 yRot deg, 3 walk position, 4 walk speed, 5 eat, 6 stand, 7 feeding, 8 ageInTicks, 9 ageScale, 10 animate tail, 11 in water, 12 hook kind (0 adult horse, donkey and saddle models,
*>   1 baby horse, 2 baby donkey), 13 has chest, 14 is ridden, 15 donkey model (toggles the chests), 16 saddle model (toggles the reins)): the twelve steps of 8.3 and the overrides of 8.4, reset first.
*>   Pivot offsets of the scaled layers are carried in the root children (EMD-SCALE-ROOT), so every additive offset and constant of 8.3 is multiplied by the scale of the body part. IN(1) is overwritten by -30 for hook kind 2 (the shared state write).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-EQUINE-REG.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENT                  PIC X(24).
 01 L-TYPE                 PIC X(40).
 01 L-SCALE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ENT L-TYPE L-SCALE.
     MOVE SPACES TO L-TYPE
     MOVE 1 TO L-SCALE
     EVALUATE L-ENT
         WHEN "horse" MOVE "horse_saddle" TO L-TYPE MOVE 1.1 TO L-SCALE
         WHEN "donkey" MOVE "donkey_saddle" TO L-TYPE MOVE 0.87 TO L-SCALE
         WHEN "mule" MOVE "mule_saddle" TO L-TYPE MOVE 0.92 TO L-SCALE
         WHEN "skeleton_horse" MOVE "skeleton_horse_saddle" TO L-TYPE
         WHEN "zombie_horse" MOVE "zombie_horse_saddle" TO L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF4-EQUINE-REG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-EQUINE-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                PIC X(60).
 LINKAGE SECTION.
 01 L-ENT                  PIC X(24).
 01 L-BABY                 BINARY-LONG.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-ENT L-BABY L-PATH.
     MOVE SPACES TO L-PATH WS-BASE
     EVALUATE L-ENT
         WHEN "donkey" MOVE "textures/entity/horse/donkey" TO WS-BASE
         WHEN "mule" MOVE "textures/entity/horse/mule" TO WS-BASE
         WHEN "skeleton_horse" MOVE "textures/entity/horse/horse_skeleton" TO WS-BASE
         WHEN "zombie_horse" MOVE "textures/entity/horse/horse_zombie" TO WS-BASE
     END-EVALUATE
     IF L-BABY NOT = 0
         STRING FUNCTION TRIM(WS-BASE) "_baby.png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING FUNCTION TRIM(WS-BASE) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-EQUINE-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HORSE-VARIANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION MOD(L-I(1), 7)
     GOBACK.
 END PROGRAM EF4-HORSE-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HORSE-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(10) VALUE "white".
    05 FILLER PIC X(10) VALUE "creamy".
    05 FILLER PIC X(10) VALUE "chestnut".
    05 FILLER PIC X(10) VALUE "brown".
    05 FILLER PIC X(10) VALUE "black".
    05 FILLER PIC X(10) VALUE "gray".
    05 FILLER PIC X(10) VALUE "darkbrown".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(10) OCCURS 7 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     COMPUTE WS-K = FUNCTION MOD(L-I(1), 7) + 1
     MOVE SPACES TO L-PATH
     IF L-I(2) NOT = 0
         STRING "textures/entity/horse/horse_" FUNCTION TRIM(WS-NAME(WS-K)) "_baby.png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING "textures/entity/horse/horse_" FUNCTION TRIM(WS-NAME(WS-K)) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-HORSE-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HORSE-MARKING-ID.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION MOD(L-I(1), 5)
     GOBACK.
 END PROGRAM EF4-HORSE-MARKING-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HORSE-MARKING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(12) VALUE SPACES.
    05 FILLER PIC X(12) VALUE "white".
    05 FILLER PIC X(12) VALUE "whitefield".
    05 FILLER PIC X(12) VALUE "whitedots".
    05 FILLER PIC X(12) VALUE "blackdots".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(12) OCCURS 5 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     COMPUTE WS-K = FUNCTION MOD(L-I(1), 5) + 1
     MOVE SPACES TO L-PATH
     IF WS-K > 1
         IF L-I(2) NOT = 0
             STRING "textures/entity/horse/horse_markings_" FUNCTION TRIM(WS-NAME(WS-K)) "_baby.png" DELIMITED BY SIZE INTO L-PATH
         ELSE
             STRING "textures/entity/horse/horse_markings_" FUNCTION TRIM(WS-NAME(WS-K)) ".png" DELIMITED BY SIZE INTO L-PATH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF4-HORSE-MARKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-MARKING-DRAW.
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
 END PROGRAM EF4-MARKING-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-EQUINE-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-BODY                BINARY-LONG.
 01 WS-HP                  BINARY-LONG.
 01 WS-LHL                 BINARY-LONG.
 01 WS-RHL                 BINARY-LONG.
 01 WS-LFL                 BINARY-LONG.
 01 WS-RFL                 BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-SC                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-WATER               FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-LEG                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-GRAZ                FLOAT-LONG.
 01 WS-LSY                 FLOAT-LONG.
 01 WS-LSZ                 FLOAT-LONG.
 01 WS-ANG                 FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-STAND               FLOAT-LONG.
 01 WS-EAT                 FLOAT-LONG.
 01 WS-P2                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-BODY
     MOVE "head_parts" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HP
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LHL
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RHL
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LFL
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RFL
     MOVE "tail" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-TAIL
     MOVE MM-YSCALE(WS-BODY) TO WS-SC
     MOVE L-I(5) TO WS-EAT
     MOVE L-I(6) TO WS-STAND
     MOVE L-I(1) TO WS-P2
     COMPUTE WS-YAW = L-I(2)
     IF WS-YAW > 20
         MOVE 20 TO WS-YAW
     END-IF
     IF WS-YAW < -20
         MOVE -20 TO WS-YAW
     END-IF
     COMPUTE WS-PITCH = L-I(1) * 0.017453292
     IF L-I(4) > 0.2
         COMPUTE WS-PITCH = WS-PITCH + FUNCTION COS(0.8 * L-I(3)) * 0.15 * L-I(4)
     END-IF
     MOVE 1 TO WS-WATER
     IF L-I(11) NOT = 0
         MOVE 0.2 TO WS-WATER
     END-IF
     COMPUTE WS-C = FUNCTION COS(WS-WATER * L-I(3) * 0.6662 + 3.141592653589793)
     COMPUTE WS-LEG = WS-C * 0.8 * L-I(4)
     MOVE WS-STAND TO WS-MAX
     IF WS-EAT > WS-MAX
         MOVE WS-EAT TO WS-MAX
     END-IF
     COMPUTE WS-GRAZ = (1 - WS-MAX) * ((0.5235988 + WS-PITCH) + L-I(7) * FUNCTION SIN(L-I(8)) * 0.05)
     COMPUTE MM-CXROT(WS-HP) = WS-STAND * (0.2617994 + WS-PITCH) + WS-EAT * (2.1816616 + FUNCTION SIN(L-I(8)) * 0.05) + WS-GRAZ
     COMPUTE MM-CYROT(WS-HP) = WS-STAND * WS-YAW * 0.017453292 + (1 - WS-MAX) * (WS-YAW * 0.017453292)
     EVALUATE L-I(12)
         WHEN 0
             COMPUTE MM-CY(WS-HP) = MM-CY(WS-HP) + WS-SC * ((0 + WS-STAND * (-8 - 0)) + WS-EAT * (7 - (0 + WS-STAND * (-8 - 0))))
             COMPUTE MM-CZ(WS-HP) = MM-CZ(WS-HP) + WS-STAND * (-4 * WS-SC - MM-CZ(WS-HP))
         WHEN 1
             COMPUTE MM-CY(WS-HP) = MM-CY(WS-HP) + ((0 + WS-STAND * (-2 - 0)) + WS-EAT * (2 - (0 + WS-STAND * (-2 - 0))))
             COMPUTE MM-CZ(WS-HP) = MM-CZ(WS-HP) + WS-STAND * (-4 - MM-CZ(WS-HP))
         WHEN OTHER
             COMPUTE MM-CY(WS-HP) = MM-CY(WS-HP) + WS-EAT * (-1.2 - MM-CY(WS-HP))
             COMPUTE MM-CZ(WS-HP) = MM-CZ(WS-HP) + WS-STAND * (-3.6 - MM-CZ(WS-HP))
     END-EVALUATE
     COMPUTE MM-CXROT(WS-BODY) = WS-STAND * (-0.7853982) + (1 - WS-STAND) * MM-XROT(WS-BODY)
     EVALUATE L-I(12)
         WHEN 0 COMPUTE WS-LSY = 12 * WS-SC COMPUTE WS-LSZ = 4 * WS-SC MOVE 0.2617994 TO WS-ANG MOVE -1.0471976 TO WS-X0
         WHEN 1 MOVE 4 TO WS-LSY MOVE 0 TO WS-LSZ MOVE 0.2617994 TO WS-ANG MOVE -1.0471976 TO WS-X0
         WHEN OTHER MOVE 1 TO WS-LSY MOVE 0.5 TO WS-LSZ MOVE 1.0471976 TO WS-ANG MOVE 0 TO WS-X0
     END-EVALUATE
     COMPUTE MM-CY(WS-LFL) = MM-CY(WS-LFL) - WS-LSY * WS-STAND
     COMPUTE MM-CZ(WS-LFL) = MM-CZ(WS-LFL) + WS-LSZ * WS-STAND
     MOVE MM-CY(WS-LFL) TO MM-CY(WS-RFL)
     MOVE MM-CZ(WS-LFL) TO MM-CZ(WS-RFL)
     COMPUTE WS-ANG = WS-ANG * WS-STAND
     COMPUTE WS-W = FUNCTION COS(L-I(8) * 0.6 + 3.141592653589793)
     COMPUTE MM-CXROT(WS-LHL) = WS-ANG - (WS-C * 0.5 * L-I(4)) * (1 - WS-STAND)
     COMPUTE MM-CXROT(WS-RHL) = WS-ANG + (WS-C * 0.5 * L-I(4)) * (1 - WS-STAND)
     COMPUTE MM-CXROT(WS-LFL) = (WS-X0 + WS-W) * WS-STAND + WS-LEG * (1 - WS-STAND)
     COMPUTE MM-CXROT(WS-RFL) = (WS-X0 - WS-W) * WS-STAND - WS-LEG * (1 - WS-STAND)
     IF L-I(12) = 2
         COMPUTE MM-CY(WS-LHL) = MM-CY(WS-LHL) + WS-STAND * (-0.3 - MM-CY(WS-LHL))
         COMPUTE MM-CY(WS-RHL) = MM-CY(WS-LHL) + WS-STAND * (-0.3 - MM-CY(WS-LHL))
     END-IF
     EVALUATE L-I(12)
         WHEN 0 MOVE 0 TO WS-TX
         WHEN 1 MOVE -1.5707964 TO WS-TX
         WHEN OTHER MOVE -0.7853982 TO WS-TX
     END-EVALUATE
     COMPUTE MM-CXROT(WS-TAIL) = WS-TX + 0.5235988 + L-I(4) * 0.75
     COMPUTE MM-CY(WS-TAIL) = MM-CY(WS-TAIL) + L-I(4) * L-I(9)
     COMPUTE MM-CZ(WS-TAIL) = MM-CZ(WS-TAIL) + L-I(4) * 2 * L-I(9)
     MOVE 0 TO MM-CYROT(WS-TAIL)
     IF L-I(10) NOT = 0
         COMPUTE MM-CYROT(WS-TAIL) = FUNCTION COS(L-I(8) * 0.7)
     END-IF
     IF L-I(15) NOT = 0
         MOVE "left_chest" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE 0 TO MM-VISIBLE(WS-P)
         IF L-I(13) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-P)
         END-IF
         MOVE "right_chest" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE 0 TO MM-VISIBLE(WS-P)
         IF L-I(13) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-P)
         END-IF
     END-IF
     IF L-I(16) NOT = 0
         MOVE "left_saddle_line" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE 0 TO MM-VISIBLE(WS-P)
         IF L-I(14) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-P)
         END-IF
         MOVE "right_saddle_line" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE 0 TO MM-VISIBLE(WS-P)
         IF L-I(14) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-P)
         END-IF
     END-IF
     IF L-I(12) = 2
         MOVE -30 TO L-I(1)
         COMPUTE WS-P2 = -30 * 0.017453292
         COMPUTE MM-CXROT(WS-HP) = WS-STAND * (0.2617994 + WS-P2) + WS-EAT * (1.5707964 + FUNCTION SIN(L-I(8)) * 0.05) + (1 - WS-MAX) * ((0.5235988 + WS-P2) + L-I(7) * FUNCTION SIN(L-I(8)) * 0.05)
     END-IF
     GOBACK.
 END PROGRAM EF4-EQUINE-ANIM.
'''
write_section_src(8,hdr,IDS,extra); write_layers(IDS)
