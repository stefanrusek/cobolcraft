*> The enchantment glint (54 section 19.3, 19.4; 12 section 8.3), client side. GLINT-TEXTURES-BUILD loads the two glint textures of the pack stack,
*> assets/minecraft/textures/misc/enchanted_glint_item.png (the item glint: held items, icons, entity models) into GT-ITEM and enchanted_glint_armor.png
*> (armour) into GT-ARMOR, and marks textures 5 and 6 (CC-TEX-GLINT, CC-TEX-GLINT-ARMOR, repeat wrapping, shim-abi section 9) for upload (AT-UPLOAD 6 and 7); an
*> image no pack has is not loaded (width 0): the glint is then not drawn. GLINT-OFFSET gives the translation of the glint texture matrix for the frame clock
*> (CL-NOW-MS) and the glint speed option: t = ms x speed x 8, u = -(t mod 110000) / 110000, v = (t mod 30000) / 30000 (the scale and the rotation of the matrix
*> are in the vertex coordinates of the glint meshes, GLINT-UV). GLINT-STRENGTH gives the glint strength option (0 to 1, default 0.75).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GLINT-TEXTURES-BUILD.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATHS.
    05 FILLER PIC X(64) VALUE "55assets/minecraft/textures/misc/enchanted_glint_item.png".
    05 FILLER PIC X(64) VALUE "56assets/minecraft/textures/misc/enchanted_glint_armor.png".
 01 WS-PATH-TABLE REDEFINES WS-PATHS.
    05 WS-PE OCCURS 2 TIMES.
       10 WS-PE-LENGTH       PIC 99.
       10 WS-PE-PATH         PIC X(62).
 01 WS-PATH                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-IMAGE               PIC X(1048576).
 01 WS-CAPACITY            BINARY-LONG VALUE 1048576.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-ADDR                USAGE POINTER.
 01 B-COPY                 PIC X(1048576) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE SPACES TO WS-PATH
         MOVE WS-PE-PATH(WS-K) TO WS-PATH
         MOVE WS-PE-LENGTH(WS-K) TO WS-LENGTH
         CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-LENGTH WS-IMAGE WS-CAPACITY WS-W WS-H WS-FOUND
         IF WS-K = 1 AND GT-ITEM-ADDR NOT = NULL
             FREE GT-ITEM-ADDR
         END-IF
         IF WS-K = 2 AND GT-ARMOR-ADDR NOT = NULL
             FREE GT-ARMOR-ADDR
         END-IF
         MOVE NULL TO WS-ADDR
         IF WS-FOUND = 0
             MOVE 0 TO WS-W WS-H
         ELSE
             COMPUTE WS-BYTES = WS-W * WS-H * 4
             ALLOCATE WS-BYTES CHARACTERS RETURNING WS-ADDR
             SET ADDRESS OF B-COPY TO WS-ADDR
             MOVE WS-IMAGE(1:WS-BYTES) TO B-COPY(1:WS-BYTES)
             COMPUTE WS-LENGTH = WS-K + 5
             MOVE 1 TO AT-UPLOAD(WS-LENGTH)
         END-IF
         IF WS-K = 1
             MOVE WS-W TO GT-ITEM-W
             MOVE WS-H TO GT-ITEM-H
             SET GT-ITEM-ADDR TO WS-ADDR
         ELSE
             MOVE WS-W TO GT-ARMOR-W
             MOVE WS-H TO GT-ARMOR-H
             SET GT-ARMOR-ADDR TO WS-ADDR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GLINT-TEXTURES-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GLINT-OFFSET.
*> USING CLIENT-STATE, u out, v out (FLOAT-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-T                   BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-U                    FLOAT-LONG.
 01 L-V                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-U L-V.
     MOVE "glintSpeed" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-FOUND
     MOVE 500 TO WS-SPEED
     IF WS-FOUND = 1 AND WS-LENGTH > 0
         COMPUTE WS-SPEED ROUNDED = FUNCTION NUMVAL(WS-VALUE(1:WS-LENGTH)) * 1000
     END-IF
*>   t in thousandths of a millisecond: whole numbers all the way, so that a clock of years still has exact moduli.
     COMPUTE WS-T = FUNCTION MOD(CL-NOW-MS * WS-SPEED * 8, 110000000)
     COMPUTE L-U = 0 - WS-T / 110000000
     COMPUTE WS-T = FUNCTION MOD(CL-NOW-MS * WS-SPEED * 8, 30000000)
     COMPUTE L-V = WS-T / 30000000
     GOBACK.
 END PROGRAM GLINT-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GLINT-STRENGTH.
*> USING CLIENT-STATE, strength out (FLOAT-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-STRENGTH             FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-STRENGTH.
     MOVE "glintStrength" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-FOUND
     MOVE 0.75 TO L-STRENGTH
     IF WS-FOUND = 1 AND WS-LENGTH > 0
         COMPUTE L-STRENGTH = FUNCTION MIN(FUNCTION MAX(FUNCTION NUMVAL(WS-VALUE(1:WS-LENGTH)), 0), 1)
     END-IF
     GOBACK.
 END PROGRAM GLINT-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GLINT-UV.
*> USING u, v (FLOAT-LONG, in and out), scale (FLOAT-LONG): a texture coordinate through the scale and the rotation about Z by 0.17453292 rad of the glint texture
*> matrix (12 section 8.3: translate x rotate x scale, so the point is scaled first and then rotated; the translation is the shim's cc_vk_glint_offset).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COS                 FLOAT-LONG VALUE 0.9848077.
 01 WS-SIN                 FLOAT-LONG VALUE 0.17364818.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-U                    FLOAT-LONG.
 01 L-V                    FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-U L-V L-SCALE.
     COMPUTE WS-X = L-U * L-SCALE
     COMPUTE WS-Y = L-V * L-SCALE
     COMPUTE L-U = WS-X * WS-COS - WS-Y * WS-SIN
     COMPUTE L-V = WS-X * WS-SIN + WS-Y * WS-COS
     GOBACK.
 END PROGRAM GLINT-UV.
