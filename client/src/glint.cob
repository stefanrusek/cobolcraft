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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STACK-FOIL.
*> USING PB-ITEMSTACK-X, foil out (1 when the stack has the glint): enchantment_glint_override 21 when present (its Boolean), else enchantments 13 non-empty (54 section 19.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-ENCHANTED           BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-FOIL                 BINARY-LONG.
 PROCEDURE DIVISION USING PB-ITEMSTACK-X L-FOIL.
     MOVE -1 TO WS-OVERRIDE
     MOVE 0 TO WS-ENCHANTED L-FOIL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-ISX-ADDED-COUNT
         IF PB-ISX-VALUE-LENGTH(WS-K) > 0
             COMPUTE WS-B = FUNCTION ORD(PB-ISX-VALUE(WS-K)(1:1)) - 1
             IF PB-ISX-TYPE(WS-K) = 21
                 MOVE WS-B TO WS-OVERRIDE
             END-IF
             IF PB-ISX-TYPE(WS-K) = 13 AND WS-B > 0
                 MOVE 1 TO WS-ENCHANTED
             END-IF
         END-IF
     END-PERFORM
     IF WS-OVERRIDE >= 0
         IF WS-OVERRIDE > 0
             MOVE 1 TO L-FOIL
         END-IF
     ELSE
         MOVE WS-ENCHANTED TO L-FOIL
     END-IF
     GOBACK.
 END PROGRAM STACK-FOIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STACK-CHARGED.
*> USING PB-ITEMSTACK-X, charged out (1 when the stack has charged_projectiles 51 with at least one projectile: a loaded crossbow, 54 section 25.4; the value starts with the VarInt count).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CHARGED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-ITEMSTACK-X L-CHARGED.
     MOVE 0 TO L-CHARGED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-ISX-ADDED-COUNT
         IF PB-ISX-TYPE(WS-K) = 51 AND PB-ISX-VALUE-LENGTH(WS-K) > 0
             IF FUNCTION ORD(PB-ISX-VALUE(WS-K)(1:1)) > 1
                 MOVE 1 TO L-CHARGED
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STACK-CHARGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GLINT-ICON.
*> USING CLIENT-STATE, sprite, x0, y0, x1, y1 (FLOAT-SHORT, window pixels of the icon's rectangle): the glint over an item icon (54 section 19.3). The glint is added only
*> where the icon has texels (the item shader discards the others), so quads cover the opaque texels (alpha 26 and up: 0.1) of the sprite, one per run of a row, into
*> RL-GC-VERTEX while it has room; their glint coordinates are the atlas coordinates of the corners through the item scale 8 (GLINT-UV), the brightness the glint strength.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CORNERS             PIC X(6) VALUE "123134".
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-ALPHA               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-OPAQUE              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 8.
 01 WS-STRENGTH            FLOAT-LONG.
 01 WS-STEP-X              FLOAT-LONG.
 01 WS-STEP-Y              FLOAT-LONG.
 01 WS-RUN-END             BINARY-LONG.
 01 B-PIXELS               PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SPRITE               BINARY-LONG.
 01 L-X0                   FLOAT-SHORT.
 01 L-Y0                   FLOAT-SHORT.
 01 L-X1                   FLOAT-SHORT.
 01 L-Y1                   FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-SPRITE L-X0 L-Y0 L-X1 L-Y1.
     CALL "GLINT-STRENGTH" USING CLIENT-STATE WS-STRENGTH
     SET ADDRESS OF B-PIXELS TO AT-ADDR
     COMPUTE WS-STEP-X = (L-X1 - L-X0) / AT-SW(L-SPRITE)
     COMPUTE WS-STEP-Y = (L-Y1 - L-Y0) / AT-SH(L-SPRITE)
     PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= AT-SH(L-SPRITE)
         MOVE 0 TO WS-PX
         PERFORM UNTIL WS-PX >= AT-SW(L-SPRITE)
             PERFORM TEXEL-OPAQUE
             IF WS-OPAQUE = 0
                 ADD 1 TO WS-PX
             ELSE
*>               The run: from WS-PX up to the first transparent texel or the sprite's edge.
                 MOVE WS-PX TO WS-RUN
                 PERFORM UNTIL WS-PX >= AT-SW(L-SPRITE) OR WS-OPAQUE = 0
                     ADD 1 TO WS-PX
                     IF WS-PX < AT-SW(L-SPRITE)
                         PERFORM TEXEL-OPAQUE
                     ELSE
                         MOVE 0 TO WS-OPAQUE
                     END-IF
                 END-PERFORM
                 MOVE WS-PX TO WS-RUN-END
                 PERFORM EMIT-RUN
             END-IF
         END-PERFORM
     END-PERFORM
     GO TO MAIN-EXIT.

*> WS-OPAQUE 1 when the texel (WS-PX, WS-PY) of the sprite has alpha 26 or more.
 TEXEL-OPAQUE.
     COMPUTE WS-POS = ((AT-Y(L-SPRITE) + WS-PY) * AT-W + AT-X(L-SPRITE) + WS-PX) * 4 + 4
     COMPUTE WS-ALPHA = FUNCTION ORD(B-PIXELS(WS-POS:1)) - 1
     MOVE 0 TO WS-OPAQUE
     IF WS-ALPHA >= 26
         MOVE 1 TO WS-OPAQUE
     END-IF.

*> The quad of the run WS-RUN to WS-RUN-END (exclusive) of row WS-PY.
 EMIT-RUN.
     IF RL-GC-COUNT + 6 <= 12288
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             ADD 1 TO RL-GC-COUNT
             MOVE FUNCTION NUMVAL(WS-CORNERS(WS-K:1)) TO WS-C
*>           Corner 1 top-left, 2 top-right, 3 bottom-right, 4 bottom-left.
             MOVE WS-RUN TO WS-CX
             IF WS-C = 2 OR WS-C = 3
                 MOVE WS-RUN-END TO WS-CX
             END-IF
             MOVE WS-PY TO WS-CY
             IF WS-C >= 3
                 COMPUTE WS-CY = WS-PY + 1
             END-IF
             COMPUTE RL-GC-X(RL-GC-COUNT) = L-X0 + WS-CX * WS-STEP-X
             COMPUTE RL-GC-Y(RL-GC-COUNT) = L-Y0 + WS-CY * WS-STEP-Y
             COMPUTE WS-U = (AT-X(L-SPRITE) + WS-CX) / AT-W
             COMPUTE WS-V = (AT-Y(L-SPRITE) + WS-CY) / AT-H
             CALL "GLINT-UV" USING WS-U WS-V WS-SCALE
             MOVE WS-U TO RL-GC-U(RL-GC-COUNT)
             MOVE WS-V TO RL-GC-V(RL-GC-COUNT)
             MOVE 0 TO RL-GC-Z(RL-GC-COUNT) RL-GC-SKY(RL-GC-COUNT)
             MOVE WS-STRENGTH TO RL-GC-B(RL-GC-COUNT)
             MOVE 1 TO RL-GC-A(RL-GC-COUNT) RL-GC-R(RL-GC-COUNT) RL-GC-G(RL-GC-COUNT) RL-GC-BLUE(RL-GC-COUNT)
         END-PERFORM
     END-IF.
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM GLINT-ICON.
