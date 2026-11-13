*> Entity models in the render path (docs/protocol/34-entity-models-1-shared-model-and-framework.md section 1.5 and 6, 34-7 sections
*> 1.1, 1.2 and 1.6; the model library client/src/entmodel-34-*.cob; the table is client/copy/CLMODELS.cpy).
*> ENTITY-MODEL-FIND maps an entity type key to its row of CL-MODELS (0 = no model). ENTITY-MODEL-BUILD builds the layer of a row
*> into an EMM-MODEL (client/copy/CLEMM.cpy) through the library of its family. ENTITY-MODEL-SLOTS gives every model the replica
*> shows a slot in the entity atlas (EA-MT, entities-render.cob ENTITY-ATLAS-BUILD) before the frame's vertices are made.
*> ENTITY-MODEL-EMIT appends the model of one replica row to RL-EN-VERTEX, eye-relative, 36 vertices (6 faces x 2 triangles) per
*> cuboid: the cached rest model is copied, the row's setupAnim program runs on the state the replica has (head pitch EN-PITCH,
*> head yaw relative to the body EN-HEAD-YAW - EN-YAW wrapped to -180..180; walk position and speed, age and every other state
*> are 0), then every visible part (itself and all its ancestors visible) with cuboids is drawn: a corner of a cuboid (EF7-BOX-CORNERS
*> of 34-7 1.2: origin, size, grow, mirror) is carried up the part chain (scale, rotate X then Y then Z, translate by the part's
*> current pose, each ancestor in turn, then / 16: 34-7 1.1) and through the render sequence of 34-7 1.6 as EF7-SETUP-ROTATIONS lists
*> it (rotate about Y by 180 - body yaw degrees, scale (-1, -1, 1), translate (0, -1.501, 0); the last listed acts first), then moved
*> to the entity position. Each face takes its four corners from EF7-FACE-VERTS and its four texels from EF7-BOX-RECTS and
*> EF7-VERTEX-UV (the box unwrap of 34-7 1.2), mapped onto the model's atlas rectangle: u = (rect x + u x rect w) / atlas w. The quad
*> is the triangles 1 2 3 and 1 3 4 of the slots. Brightness as the stand-in boxes: the face's direction factor in world space (the model
*> flips y, so DOWN is the visible top 1.0, UP the bottom 0.5, WEST and EAST 0.6, NORTH and SOUTH 0.8) times max(sky light x daylight,
*> block light) / 15 of the entity's cell, at least 0.1; tint 1, 1, 1 and alpha 1. A cuboid that no longer fits the entity vertex
*> capacity is left out. The tilt of a dying entity (deathTime) is not drawn: the replica holds no death time.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MODEL-FIND.
*> USING entity type key (PIC X(24)), row of CL-MODELS out (BINARY-LONG, 0 = none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-MODEL-COUNT
         IF CL-MD-KEY(WS-I) = L-KEY
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-MODEL-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MODEL-BUILD.
*> USING model (EMM-MODEL), row of CL-MODELS, ok out (1 when the family's library built the layer).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-LAYER               PIC X(32).
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-ROW L-OK.
     MOVE CL-MD-LAYER(L-ROW) TO WS-LAYER
     MOVE 0 TO L-OK
     EVALUATE CL-MD-FAMILY(L-ROW)
         WHEN 2
             CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 4
             CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 5
             CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 6
             CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN 7
             CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER L-OK
         WHEN OTHER
             CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-MODEL-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREEPER-SWELL.
*> USING CLIENT-STATE, replica row, swell out (FLOAT-LONG): the creeper's swell counter now (20 section 6.1: it runs 1 a tick, 50 ms, in the direction
*> EN-SWELL-DIR from its value EN-SWELL-BASE when the direction was set at EN-SWELL-MS; at least 0, at most 30 = maxSwell).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-SWELL                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SWELL.
     COMPUTE L-SWELL = EN-SWELL-BASE(L-ROW) + EN-SWELL-DIR(L-ROW) * (CL-NOW-MS - EN-SWELL-MS(L-ROW)) / 50
     COMPUTE L-SWELL = FUNCTION MAX(0, FUNCTION MIN(30, L-SWELL))
     GOBACK.
 END PROGRAM CREEPER-SWELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MODEL-SLOTS.
*> USING CLIENT-STATE: every used replica row with a model gets an atlas slot (EA-MT, at most 16: a model beyond them is not
*> drawn); the atlas is rebuilt once when a slot was added.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-NEW
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-MODEL(WS-R) > 0
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
                 IF EA-MT-MODEL(WS-S) = EN-MODEL(WS-R)
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0 AND EA-MT-COUNT < 16
                 ADD 1 TO EA-MT-COUNT
                 MOVE EN-MODEL(WS-R) TO EA-MT-MODEL(EA-MT-COUNT)
                 MOVE 1 TO WS-NEW
             END-IF
*>           The extra layer of the row's model (the sheep's wool) has its own slot.
             MOVE CL-MD-EXTRA(EN-MODEL(WS-R)) TO WS-X
             IF WS-X > 0
                 MOVE 0 TO WS-FOUND
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
                     IF EA-MT-MODEL(WS-S) = WS-X
                         MOVE 1 TO WS-FOUND
                     END-IF
                 END-PERFORM
                 IF WS-FOUND = 0 AND EA-MT-COUNT < 16
                     ADD 1 TO EA-MT-COUNT
                     MOVE WS-X TO EA-MT-MODEL(EA-MT-COUNT)
                     MOVE 1 TO WS-NEW
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-NEW = 1
         CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM ENTITY-MODEL-SLOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MODEL-EMIT.
*> USING CLIENT-STATE, replica row (with EN-MODEL > 0), eye (3 FLOAT-LONG): appends the row's model to RL-EN-VERTEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODELS.
 COPY CLEMM.
*> The models built so far, one per row of CL-MODELS (EMM-MODEL is 36660 bytes).
 01 WS-CACHE.
    05 WS-CM               PIC X(36700) OCCURS 16 TIMES.
 01 WS-HAVE-TABLE.
    05 WS-HAVE             PIC 9 OCCURS 16 TIMES VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-IN.
    05 WS-I                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-STATE.
    05 WS-ST               FLOAT-LONG OCCURS 48 TIMES.
 01 WS-VARIANT             BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
*> The render sequence (EF7-SETUP-ROTATIONS) and its rotations' sines and cosines.
 01 WS-SR-IN.
    05 WS-SRI              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-SR-OUT.
    05 WS-SRO              FLOAT-LONG OCCURS 64 TIMES.
 01 WS-OPS.
    05 WS-OP OCCURS 4 TIMES.
       10 WS-OP-SIN        FLOAT-LONG.
       10 WS-OP-COS        FLOAT-LONG.
 01 WS-NOPS                BINARY-LONG.
 01 WS-OB                  BINARY-LONG.
*> Per part: visibility and the sines and cosines of its current rotation about x, y, z.
 01 WS-PARTS.
    05 WS-PT OCCURS 40 TIMES.
       10 WS-SA            FLOAT-LONG OCCURS 3 TIMES.
       10 WS-CA            FLOAT-LONG OCCURS 3 TIMES.
 01 WS-VIS-TABLE.
    05 WS-VIS              PIC 9 OCCURS 41 TIMES.
 01 WS-ANG                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-P                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-BRIGHT              FLOAT-LONG.
 01 WS-SWELL               FLOAT-LONG.
 01 WS-KSWELL              FLOAT-LONG.
 01 WS-FSW                 FLOAT-LONG.
 01 WS-C4                  FLOAT-LONG.
 01 WS-HOOK-X              FLOAT-LONG.
 01 WS-HOOK-Y              FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
*> A cuboid: its box (EF7-BOX-CORNERS IN/OUT), unwrap rectangles (EF7-BOX-RECTS), face corners and texel pick.
 01 WS-BOX-IN.
    05 WS-BI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-BOX-OUT.
    05 WS-BO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-RC-IN.
    05 WS-RI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-RC-OUT.
    05 WS-RO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-FV-IN.
    05 WS-FI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-FV-OUT.
    05 WS-FO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-UV-IN.
    05 WS-UI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-UV-OUT.
    05 WS-UO               FLOAT-LONG OCCURS 64 TIMES.
*> The eight corners A..H in the eye-relative world, the four vertices of the face being made.
 01 WS-WORLD.
    05 WS-WC OCCURS 8 TIMES.
       10 WS-WX            FLOAT-SHORT.
       10 WS-WY            FLOAT-SHORT.
       10 WS-WZ            FLOAT-SHORT.
 01 WS-QUAD.
    05 WS-Q OCCURS 4 TIMES.
       10 WS-QX            FLOAT-SHORT.
       10 WS-QY            FLOAT-SHORT.
       10 WS-QZ            FLOAT-SHORT.
       10 WS-QU            FLOAT-SHORT.
       10 WS-QV            FLOAT-SHORT.
 01 WS-FACTOR-DATA.
    05 FILLER PIC 9V9 VALUE 1.0.
    05 FILLER PIC 9V9 VALUE 0.5.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.8.
 01 WS-FACTOR-TABLE REDEFINES WS-FACTOR-DATA.
    05 WS-FACTOR           PIC 9V9 OCCURS 6 TIMES.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE L-ROW TO WS-ROW
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = EN-MODEL(WS-ROW)
             MOVE WS-S TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0
         GOBACK
     END-IF
*>   Entities beyond 64 blocks (horizontally) are not drawn: a cap standing in for the entity distance rule (13 section 9.2 Entity Distance option, 34-1 7.1 shadow fade 16 blocks), which the docs do not give as a number (open).
     COMPUTE WS-D = (EN-X(WS-ROW) - L-EYE(1)) * (EN-X(WS-ROW) - L-EYE(1))
         + (EN-Z(WS-ROW) - L-EYE(3)) * (EN-Z(WS-ROW) - L-EYE(3))
     IF WS-D > 4096
         GOBACK
     END-IF
*>   The model: built once per row of the table, then copied.
     MOVE EN-MODEL(WS-ROW) TO WS-K
     IF WS-HAVE(WS-K) = 0
         CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-K WS-OK
         MOVE EMM-MODEL TO WS-CM(WS-K)
         MOVE 1 TO WS-HAVE(WS-K)
     ELSE
         MOVE WS-CM(WS-K)(1:36660) TO EMM-MODEL
     END-IF
*>   setupAnim with the replica's state: x rotation = pitch, y rotation = head yaw relative to the body, wrapped.
     MOVE 0 TO WS-J
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16
         MOVE 0 TO WS-I(WS-J)
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 48
         MOVE 0 TO WS-ST(WS-J)
     END-PERFORM
     COMPUTE WS-D = EN-HEAD-YAW(WS-ROW) - EN-YAW(WS-ROW)
     COMPUTE WS-D = WS-D - 360 * FUNCTION INTEGER((WS-D + 180) / 360)
     MOVE EN-PITCH(WS-ROW) TO WS-I(1) WS-ST(1)
     MOVE WS-D TO WS-I(2) WS-ST(2)
     MOVE 1 TO WS-ST(5) WS-ST(12) WS-ST(13) WS-ST(22)
     EVALUATE CL-MD-ANIM(WS-K)
         WHEN "Q"
             CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
         WHEN "C"
             CALL "EF6-CREEPER-ANIM" USING EMM-MODEL WS-IN
         WHEN "Z"
             MOVE 1 TO WS-VARIANT
             CALL "EMD-ANIM" USING EMM-MODEL WS-STATE WS-VARIANT
         WHEN "K"
             MOVE 2 TO WS-VARIANT
             CALL "EMD-ANIM" USING EMM-MODEL WS-STATE WS-VARIANT
         WHEN OTHER
             CONTINUE
     END-EVALUATE
*>   The render sequence of the body yaw (the replica's yaw): operations in the order EF7-SETUP-ROTATIONS lists them.
     MOVE 0 TO WS-SRI(1) WS-SRI(2) WS-SRI(4) WS-SRI(5)
     MOVE EN-YAW(WS-ROW) TO WS-SRI(3)
     CALL "EF7-SETUP-ROTATIONS" USING WS-SR-IN WS-SR-OUT
     MOVE WS-SRO(1) TO WS-NOPS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NOPS
         COMPUTE WS-OB = WS-J * 4 - 2
         COMPUTE WS-T = WS-SRO(WS-OB + 1) * FUNCTION PI / 180
         COMPUTE WS-OP-SIN(WS-J) = FUNCTION SIN(WS-T)
         COMPUTE WS-OP-COS(WS-J) = FUNCTION COS(WS-T)
     END-PERFORM
*>   Per part: visibility (WS-VIS(p + 1); entry 1 is the visible root's parent, so a hidden part hides its children, whose parents come
*>   first) and the trigonometry of its rotation.
     MOVE 1 TO WS-VIS(1)
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > MM-COUNT
         COMPUTE WS-VIS(WS-P + 1) = MM-VISIBLE(WS-P) * WS-VIS(MM-PARENT(WS-P) + 1)
         MOVE MM-CXROT(WS-P) TO WS-ANG(1)
         MOVE MM-CYROT(WS-P) TO WS-ANG(2)
         MOVE MM-CZROT(WS-P) TO WS-ANG(3)
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             MOVE 0 TO WS-SA(WS-P, WS-A)
             MOVE 1 TO WS-CA(WS-P, WS-A)
             IF WS-ANG(WS-A) NOT = 0
                 COMPUTE WS-SA(WS-P, WS-A) = FUNCTION SIN(WS-ANG(WS-A))
                 COMPUTE WS-CA(WS-P, WS-A) = FUNCTION COS(WS-ANG(WS-A))
             END-IF
         END-PERFORM
     END-PERFORM
*>   The light of the entity's cell.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE-ID WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15
*>   The creeper's swell scale (34-6 2): k = swell / 28, f = 1 + sin(100 k) k / 100, c = clamp(k, 0, 1): x and z (1 + c^4 0.4) f, y (1 + c^4 0.1) / f.
     MOVE 1 TO WS-HOOK-X WS-HOOK-Y
     IF CL-MD-ANIM(EN-MODEL(WS-ROW)) = "C"
         CALL "CREEPER-SWELL" USING CLIENT-STATE WS-ROW WS-SWELL
         COMPUTE WS-KSWELL = WS-SWELL / 28
         COMPUTE WS-FSW = 1 + FUNCTION SIN(WS-KSWELL * 100) * WS-KSWELL / 100
         COMPUTE WS-C4 = FUNCTION MIN(FUNCTION MAX(WS-KSWELL, 0), 1)
         COMPUTE WS-C4 = WS-C4 * WS-C4 * WS-C4 * WS-C4
         COMPUTE WS-HOOK-X = (1 + WS-C4 * 0.4) * WS-FSW
         COMPUTE WS-HOOK-Y = (1 + WS-C4 * 0.1) / WS-FSW
     END-IF
     MOVE MM-TEXW TO WS-RI(6)
     MOVE MM-TEXH TO WS-RI(7)
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > MM-COUNT
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > MM-NCUBES(WS-P) OR WS-VIS(WS-P + 1) = 0
             IF RL-EN-COUNT + 36 <= CL-MAX-ENTITY-VERTICES
                 MOVE MC-OX(WS-P, WS-C) TO WS-BI(1)
                 MOVE MC-OY(WS-P, WS-C) TO WS-BI(2)
                 MOVE MC-OZ(WS-P, WS-C) TO WS-BI(3)
                 MOVE MC-W(WS-P, WS-C) TO WS-BI(4)
                 MOVE MC-H(WS-P, WS-C) TO WS-BI(5)
                 MOVE MC-D(WS-P, WS-C) TO WS-BI(6)
                 MOVE MC-GX(WS-P, WS-C) TO WS-BI(7)
                 MOVE MC-GY(WS-P, WS-C) TO WS-BI(8)
                 MOVE MC-GZ(WS-P, WS-C) TO WS-BI(9)
                 MOVE MC-MIRROR(WS-P, WS-C) TO WS-BI(10)
                 CALL "EF7-BOX-CORNERS" USING WS-BOX-IN WS-BOX-OUT
                 MOVE MC-U(WS-P, WS-C) TO WS-RI(1)
                 MOVE MC-V(WS-P, WS-C) TO WS-RI(2)
                 MOVE MC-W(WS-P, WS-C) TO WS-RI(3)
                 MOVE MC-H(WS-P, WS-C) TO WS-RI(4)
                 MOVE MC-D(WS-P, WS-C) TO WS-RI(5)
                 CALL "EF7-BOX-RECTS" USING WS-RC-IN WS-RC-OUT
*>               The eight corners through the part chain and the render sequence, eye-relative.
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
                     COMPUTE WS-A = WS-K * 3 - 2
                     MOVE WS-BO(WS-A) TO WS-X
                     MOVE WS-BO(WS-A + 1) TO WS-Y
                     MOVE WS-BO(WS-A + 2) TO WS-Z
                     MOVE WS-P TO WS-NODE
                     PERFORM UNTIL WS-NODE < 1
                         COMPUTE WS-X = WS-X * MM-CXSCALE(WS-NODE)
                         COMPUTE WS-Y = WS-Y * MM-CYSCALE(WS-NODE)
                         COMPUTE WS-Z = WS-Z * MM-CZSCALE(WS-NODE)
                         COMPUTE WS-T = WS-Y * WS-CA(WS-NODE, 1) - WS-Z * WS-SA(WS-NODE, 1)
                         COMPUTE WS-Z = WS-Y * WS-SA(WS-NODE, 1) + WS-Z * WS-CA(WS-NODE, 1)
                         MOVE WS-T TO WS-Y
                         COMPUTE WS-T = WS-X * WS-CA(WS-NODE, 2) + WS-Z * WS-SA(WS-NODE, 2)
                         COMPUTE WS-Z = WS-Z * WS-CA(WS-NODE, 2) - WS-X * WS-SA(WS-NODE, 2)
                         MOVE WS-T TO WS-X
                         COMPUTE WS-T = WS-X * WS-CA(WS-NODE, 3) - WS-Y * WS-SA(WS-NODE, 3)
                         COMPUTE WS-Y = WS-X * WS-SA(WS-NODE, 3) + WS-Y * WS-CA(WS-NODE, 3)
                         MOVE WS-T TO WS-X
                         COMPUTE WS-X = WS-X + MM-CX(WS-NODE)
                         COMPUTE WS-Y = WS-Y + MM-CY(WS-NODE)
                         COMPUTE WS-Z = WS-Z + MM-CZ(WS-NODE)
                         MOVE MM-PARENT(WS-NODE) TO WS-NODE
                     END-PERFORM
                     COMPUTE WS-X = WS-X / 16
                     COMPUTE WS-Y = WS-Y / 16
                     COMPUTE WS-Z = WS-Z / 16
                     PERFORM VARYING WS-J FROM WS-NOPS BY -1 UNTIL WS-J < 1
                         COMPUTE WS-OB = WS-J * 4 - 2
                         EVALUATE WS-SRO(WS-OB)
                             WHEN 1
                                 COMPUTE WS-X = WS-X + WS-SRO(WS-OB + 1)
                                 COMPUTE WS-Y = WS-Y + WS-SRO(WS-OB + 2)
                                 COMPUTE WS-Z = WS-Z + WS-SRO(WS-OB + 3)
                             WHEN 2
*>                               The renderer's own scale (the creeper's swell, 34-6 2) acts after the translate and before this one.
                                 COMPUTE WS-X = WS-X * WS-HOOK-X
                                 COMPUTE WS-Y = WS-Y * WS-HOOK-Y
                                 COMPUTE WS-Z = WS-Z * WS-HOOK-X
                                 COMPUTE WS-X = WS-X * WS-SRO(WS-OB + 1)
                                 COMPUTE WS-Y = WS-Y * WS-SRO(WS-OB + 2)
                                 COMPUTE WS-Z = WS-Z * WS-SRO(WS-OB + 3)
                             WHEN OTHER
*>                               rotation about Y by the listed degrees
                                 COMPUTE WS-T = WS-X * WS-OP-COS(WS-J) + WS-Z * WS-OP-SIN(WS-J)
                                 COMPUTE WS-Z = WS-Z * WS-OP-COS(WS-J) - WS-X * WS-OP-SIN(WS-J)
                                 MOVE WS-T TO WS-X
                         END-EVALUATE
                     END-PERFORM
                     COMPUTE WS-WX(WS-K) = EN-X(WS-ROW) - L-EYE(1) + WS-X
                     COMPUTE WS-WY(WS-K) = EN-Y(WS-ROW) - L-EYE(2) + WS-Y
                     COMPUTE WS-WZ(WS-K) = EN-Z(WS-ROW) - L-EYE(3) + WS-Z
                 END-PERFORM
*>               The six faces: down, up, west, north, east, south.
                 PERFORM VARYING WS-F FROM 0 BY 1 UNTIL WS-F > 5
                     MOVE WS-F TO WS-FI(1)
                     MOVE MC-MIRROR(WS-P, WS-C) TO WS-FI(2)
                     CALL "EF7-FACE-VERTS" USING WS-FV-IN WS-FV-OUT
                     COMPUTE WS-A = WS-F * 4
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         COMPUTE WS-J = WS-FO(WS-K)
                         MOVE WS-WX(WS-J) TO WS-QX(WS-K)
                         MOVE WS-WY(WS-J) TO WS-QY(WS-K)
                         MOVE WS-WZ(WS-J) TO WS-QZ(WS-K)
                         COMPUTE WS-UI(1) = WS-K - 1
                         MOVE WS-RO(WS-A + 1) TO WS-UI(2)
                         MOVE WS-RO(WS-A + 2) TO WS-UI(3)
                         MOVE WS-RO(WS-A + 3) TO WS-UI(4)
                         MOVE WS-RO(WS-A + 4) TO WS-UI(5)
                         CALL "EF7-VERTEX-UV" USING WS-UV-IN WS-UV-OUT
                         COMPUTE WS-QU(WS-K) = (EA-MT-X(WS-SLOT) + WS-UO(1) * EA-MT-W(WS-SLOT)) / EA-W
                         COMPUTE WS-QV(WS-K) = (EA-MT-Y(WS-SLOT) + WS-UO(2) * EA-MT-H(WS-SLOT)) / EA-H
                     END-PERFORM
                     COMPUTE WS-BRIGHT = FUNCTION MAX(WS-FACTOR(WS-F + 1) * WS-LIGHT, 0.1)
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                         MOVE WS-ORD(WS-K) TO WS-N
                         ADD 1 TO RL-EN-COUNT
                         MOVE WS-QX(WS-N) TO RL-EN-X(RL-EN-COUNT)
                         MOVE WS-QY(WS-N) TO RL-EN-Y(RL-EN-COUNT)
                         MOVE WS-QZ(WS-N) TO RL-EN-Z(RL-EN-COUNT)
                         MOVE WS-QU(WS-N) TO RL-EN-U(RL-EN-COUNT)
                         MOVE WS-QV(WS-N) TO RL-EN-V(RL-EN-COUNT)
                         MOVE WS-BRIGHT TO RL-EN-B(RL-EN-COUNT)
                         MOVE 1 TO RL-EN-A(RL-EN-COUNT)
                         MOVE 0 TO RL-EN-SKY(RL-EN-COUNT)
                         MOVE 1 TO RL-EN-R(RL-EN-COUNT) RL-EN-G(RL-EN-COUNT) RL-EN-BLUE(RL-EN-COUNT)
                     END-PERFORM
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-MODEL-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ORB-EMIT.
*> USING CLIENT-STATE, replica row (an experience_orb with its CL-MODELS slot), eye (3 FLOAT-LONG): appends the orb's quad to RL-EN-VERTEX
*> (34-9 section 14): 0.3 wide from y + 0.025 to y + 0.325, across the camera's right, on the icon of its value (tiers 3, 7, 17, 37, 73, 149, 307, 617, 1237,
*> 2477 give icons 1 to 10, below 3 icon 0) of the 4 x 4 sheet of 16-pixel icons of the 64 x 64 image; tint r = (sin t + 1) / 2, g = 1,
*> b = (sin (t + 4.1887903) + 1) / 10 with t = ageInTicks / 2 (ticks from the clock, CL-NOW-MS / 50); lit by max(sky x daylight, min(block + 7, 15)) / 15.
*> The orb is opaque here and alpha 128 in the game (the entity pipeline has no blending): open.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODELS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ICON                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-U64                 FLOAT-LONG.
 01 WS-V64                 FLOAT-LONG.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X           FLOAT-SHORT.
       10 WS-C-Y           FLOAT-SHORT.
       10 WS-C-Z           FLOAT-SHORT.
       10 WS-C-U           FLOAT-SHORT.
       10 WS-C-V           FLOAT-SHORT.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = EN-MODEL(L-ROW)
             MOVE WS-S TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0 OR RL-EN-COUNT + 6 > CL-MAX-ENTITY-VERTICES
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN EN-VALUE(L-ROW) >= 2477 MOVE 10 TO WS-ICON
         WHEN EN-VALUE(L-ROW) >= 1237 MOVE 9 TO WS-ICON
         WHEN EN-VALUE(L-ROW) >= 617 MOVE 8 TO WS-ICON
         WHEN EN-VALUE(L-ROW) >= 307 MOVE 7 TO WS-ICON
         WHEN EN-VALUE(L-ROW) >= 149 MOVE 6 TO WS-ICON
         WHEN EN-VALUE(L-ROW) >= 73 MOVE 5 TO WS-ICON
         WHEN EN-VALUE(L-ROW) >= 37 MOVE 4 TO WS-ICON
         WHEN EN-VALUE(L-ROW) >= 17 MOVE 3 TO WS-ICON
         WHEN EN-VALUE(L-ROW) >= 7 MOVE 2 TO WS-ICON
         WHEN EN-VALUE(L-ROW) >= 3 MOVE 1 TO WS-ICON
         WHEN OTHER MOVE 0 TO WS-ICON
     END-EVALUATE
     COMPUTE WS-RX = - FUNCTION COS(PL-YAW * FUNCTION PI / 180)
     COMPUTE WS-RZ = - FUNCTION SIN(PL-YAW * FUNCTION PI / 180)
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-SKY * SK-U / 1000, FUNCTION MIN(WS-BLOCK + 7, 15)) / 15
     COMPUTE WS-T = CL-NOW-MS / 50 / 2
*>   Corner k: left (-0.15) for 1 and 4, right (+0.15) for 2 and 3; top (y + 0.325) for 1 and 2, bottom (y + 0.025) for 3 and 4.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE -0.15 TO WS-SIDE
         MOVE 0 TO WS-U64
         IF WS-K = 2 OR WS-K = 3
             MOVE 0.15 TO WS-SIDE
             MOVE 1 TO WS-U64
         END-IF
         COMPUTE WS-C-X(WS-K) = EN-X(L-ROW) - L-EYE(1) + WS-SIDE * WS-RX
         COMPUTE WS-C-Z(WS-K) = EN-Z(L-ROW) - L-EYE(3) + WS-SIDE * WS-RZ
         COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + 0.325
         MOVE 0 TO WS-V64
         IF WS-K >= 3
             COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + 0.025
             MOVE 1 TO WS-V64
         END-IF
*>       The icon's rectangle in the image, in fractions of 64: x (icon mod 4) / 4, y (icon div 4) / 4, 1/4 each.
         COMPUTE WS-C-U(WS-K) = (EA-MT-X(WS-SLOT) + (FUNCTION MOD(WS-ICON, 4) / 4 + WS-U64 / 4) * EA-MT-W(WS-SLOT)) / EA-W
         COMPUTE WS-C-V(WS-K) = (EA-MT-Y(WS-SLOT) + (FUNCTION INTEGER(WS-ICON / 4) / 4 + WS-V64 / 4) * EA-MT-H(WS-SLOT)) / EA-H
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE WS-ORD(WS-K) TO WS-N
         ADD 1 TO RL-EN-COUNT
         MOVE WS-C-X(WS-N) TO RL-EN-X(RL-EN-COUNT)
         MOVE WS-C-Y(WS-N) TO RL-EN-Y(RL-EN-COUNT)
         MOVE WS-C-Z(WS-N) TO RL-EN-Z(RL-EN-COUNT)
         MOVE WS-C-U(WS-N) TO RL-EN-U(RL-EN-COUNT)
         MOVE WS-C-V(WS-N) TO RL-EN-V(RL-EN-COUNT)
         MOVE WS-LIGHT TO RL-EN-B(RL-EN-COUNT)
         MOVE 1 TO RL-EN-A(RL-EN-COUNT)
         MOVE 0 TO RL-EN-SKY(RL-EN-COUNT)
         COMPUTE RL-EN-R(RL-EN-COUNT) = FUNCTION INTEGER((FUNCTION SIN(WS-T) + 1) * 0.5 * 255) / 255
         MOVE 1 TO RL-EN-G(RL-EN-COUNT)
         COMPUTE RL-EN-BLUE(RL-EN-COUNT) = FUNCTION INTEGER((FUNCTION SIN(WS-T + 4.1887903) + 1) * 0.1 * 255) / 255
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-ORB-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ARROW-EMIT.
*> USING CLIENT-STATE, replica row (an arrow with its CL-MODELS slot), eye (3 FLOAT-LONG): appends the arrow's six quads (34-9 section 4): the shaft
*> planes cross_1 and cross_2 (16 x 4 pixels, x from -12 to 4, turned about x by 45 and 135 degrees; texels u 0 to 16 on the front, 16 to 32 on the
*> back, v 0 to 4 of 25.6) and the fletching plane (5 x 5 pixels at x = -11, turned 45 degrees, scale 0.8; texels 0 to 5 by 5 to 10), each drawn from
*> both sides (the pipeline culls no face); the model's own scale 0.9 / 16 a pixel; turned about z by the pitch EN-PITCH and about y by yaw - 90
*> (the tip along +x before the turns; the server gives yaw = atan2(vx, vz), pitch = atan(vy / horizontal speed)); a stuck arrow keeps its angles.
*> The shake of a fresh hit (34-9 4.1 setupAnim) is not drawn: the client is told no shake time (open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODELS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PI                  FLOAT-LONG.
 01 WS-SPITCH              FLOAT-LONG.
 01 WS-CPITCH              FLOAT-LONG.
 01 WS-SYAW                FLOAT-LONG.
 01 WS-CYAW                FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-CPL                 FLOAT-LONG.
 01 WS-SPL                 FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X           FLOAT-SHORT.
       10 WS-C-Y           FLOAT-SHORT.
       10 WS-C-Z           FLOAT-SHORT.
       10 WS-C-U           FLOAT-SHORT.
       10 WS-C-V           FLOAT-SHORT.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-TILT                FLOAT-LONG.
 01 WS-LENGTH-A            FLOAT-LONG.
 01 WS-MODEL-X             FLOAT-LONG.
 01 WS-MODEL-Y             FLOAT-LONG.
 01 WS-MODEL-Z             FLOAT-LONG.
 01 WS-CORNER-X            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CORNER-Y            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CORNER-U            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-CORNER-V            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-SIDE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = EN-MODEL(L-ROW)
             MOVE WS-S TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0 OR RL-EN-COUNT + 36 > CL-MAX-ENTITY-VERTICES
         GOBACK
     END-IF
     MOVE FUNCTION PI TO WS-PI
     COMPUTE WS-SPITCH = FUNCTION SIN(EN-PITCH(L-ROW) * WS-PI / 180)
     COMPUTE WS-CPITCH = FUNCTION COS(EN-PITCH(L-ROW) * WS-PI / 180)
     COMPUTE WS-SYAW = FUNCTION SIN((EN-YAW(L-ROW) - 90) * WS-PI / 180)
     COMPUTE WS-CYAW = FUNCTION COS((EN-YAW(L-ROW) - 90) * WS-PI / 180)
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
*>   Quads 1 to 6: shaft plane 1 (front, back), shaft plane 2 (front, back), fletching (front, back).
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > 6
         COMPUTE WS-KIND = FUNCTION INTEGER((WS-Q + 1) / 2)
         COMPUTE WS-SIDE = FUNCTION MOD(WS-Q - 1, 2)
         IF WS-KIND = 3
*>           The fletching plane: 5 x 5 at x = -11 (scaled 0.8: 4 x 4), tilted 45 degrees about x, corners (y, z) = (+-2, +-2) before the tilt.
             MOVE 45 TO WS-TILT
             MOVE -11 TO WS-MODEL-X
         ELSE
             IF WS-KIND = 1
                 MOVE 45 TO WS-TILT
             ELSE
                 MOVE 135 TO WS-TILT
             END-IF
         END-IF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             IF WS-KIND = 3
*>               Corner k in the plane x = -11: 1 (y 2, z -2), 2 (y 2, z 2), 3 (y -2, z 2), 4 (y -2, z -2) of the 4 x 4 plane, seen from +x for the front.
                 MOVE -11 TO WS-MODEL-X
                 MOVE 2 TO WS-MODEL-Y
                 MOVE -2 TO WS-MODEL-Z
                 IF WS-K = 2 OR WS-K = 3
                     MOVE 2 TO WS-MODEL-Z
                 END-IF
                 IF WS-K >= 3
                     MOVE -2 TO WS-MODEL-Y
                 END-IF
                 MOVE 0 TO WS-U
                 IF WS-K = 2 OR WS-K = 3
                     MOVE 5 TO WS-U
                 END-IF
                 MOVE 5 TO WS-V
                 IF WS-K >= 3
                     MOVE 10 TO WS-V
                 END-IF
                 COMPUTE WS-T = WS-MODEL-Y * FUNCTION COS(WS-TILT * WS-PI / 180) - WS-MODEL-Z * FUNCTION SIN(WS-TILT * WS-PI / 180)
                 COMPUTE WS-Z = WS-MODEL-Y * FUNCTION SIN(WS-TILT * WS-PI / 180) + WS-MODEL-Z * FUNCTION COS(WS-TILT * WS-PI / 180)
                 MOVE WS-T TO WS-Y
                 MOVE WS-MODEL-X TO WS-X
                 COMPUTE WS-U = WS-U / 32
                 COMPUTE WS-V = WS-V / 32
             ELSE
*>               Corner k of the shaft plane: 1 (-12, 2), 2 (4, 2), 3 (4, -2), 4 (-12, -2); u 0 to 16 (front) or 16 to 32 (back), v 0 to 4 of 25.6.
                 MOVE -12 TO WS-X
                 MOVE 0 TO WS-U
                 IF WS-K = 2 OR WS-K = 3
                     MOVE 4 TO WS-X
                     MOVE 16 TO WS-U
                 END-IF
                 MOVE 2 TO WS-MODEL-Y
                 MOVE 0 TO WS-V
                 IF WS-K >= 3
                     MOVE -2 TO WS-MODEL-Y
                     MOVE 4 TO WS-V
                 END-IF
                 COMPUTE WS-Y = WS-MODEL-Y * FUNCTION COS(WS-TILT * WS-PI / 180)
                 COMPUTE WS-Z = WS-MODEL-Y * FUNCTION SIN(WS-TILT * WS-PI / 180)
                 COMPUTE WS-U = (WS-U + WS-SIDE * 16) / 32
                 COMPUTE WS-V = WS-V / 25.6
             END-IF
*>           The model's scale: 0.9 / 16 a pixel; then about z by the pitch, then about y by yaw - 90, then to the entity.
             COMPUTE WS-X = WS-X * 0.9 / 16
             COMPUTE WS-Y = WS-Y * 0.9 / 16
             COMPUTE WS-Z = WS-Z * 0.9 / 16
             COMPUTE WS-T = WS-X * WS-CPITCH - WS-Y * WS-SPITCH
             COMPUTE WS-Y = WS-X * WS-SPITCH + WS-Y * WS-CPITCH
             MOVE WS-T TO WS-X
             COMPUTE WS-T = WS-X * WS-CYAW + WS-Z * WS-SYAW
             COMPUTE WS-Z = WS-Z * WS-CYAW - WS-X * WS-SYAW
             MOVE WS-T TO WS-X
             COMPUTE WS-C-X(WS-K) = EN-X(L-ROW) - L-EYE(1) + WS-X
             COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + WS-Y
             COMPUTE WS-C-Z(WS-K) = EN-Z(L-ROW) - L-EYE(3) + WS-Z
             COMPUTE WS-C-U(WS-K) = (EA-MT-X(WS-SLOT) + WS-U * EA-MT-W(WS-SLOT)) / EA-W
             COMPUTE WS-C-V(WS-K) = (EA-MT-Y(WS-SLOT) + WS-V * EA-MT-H(WS-SLOT)) / EA-H
         END-PERFORM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             MOVE WS-ORD(WS-K) TO WS-N
             ADD 1 TO RL-EN-COUNT
             MOVE WS-C-X(WS-N) TO RL-EN-X(RL-EN-COUNT)
             MOVE WS-C-Y(WS-N) TO RL-EN-Y(RL-EN-COUNT)
             MOVE WS-C-Z(WS-N) TO RL-EN-Z(RL-EN-COUNT)
             MOVE WS-C-U(WS-N) TO RL-EN-U(RL-EN-COUNT)
             MOVE WS-C-V(WS-N) TO RL-EN-V(RL-EN-COUNT)
             MOVE WS-LIGHT TO RL-EN-B(RL-EN-COUNT)
             MOVE 1 TO RL-EN-A(RL-EN-COUNT)
             MOVE 0 TO RL-EN-SKY(RL-EN-COUNT)
             MOVE 1 TO RL-EN-R(RL-EN-COUNT) RL-EN-G(RL-EN-COUNT) RL-EN-BLUE(RL-EN-COUNT)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-ARROW-EMIT.
