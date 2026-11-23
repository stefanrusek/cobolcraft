*> Paintings (docs/protocol/34-entity-models-9-non-living-entities.md section 11, 44 part 9 section 5.4): the replica row of a painting keeps its direction (Set Entity Data entry 8,
*> DIRECTION, EN-FDIR as the item frames) and its variant (entry 9, PAINTING_VARIANT: the Holder VarInt n, n > 0 the registry id n - 1; EN-X1; 0, the registry's first entry, until told).
*> The registry (RG-PAINT, REGISTRY-READ) gives the variant's width and height in blocks and the asset id of its sprite textures/painting/<name>.png; the sprite and the back sprite
*> (textures/painting/back.png, the row's own image) are two images of the entity atlas (the slots of the model row "painting": texture code 0 the back, variant + 1 the front).
*>   ENTITY-PAINTING-SET   Set Entity Data entry 9 into EN-X1.
*>   PAINTING-TEX-PATH     the path of the front sprite of a texture code (relative to assets/minecraft/; spaces for none).
*>   PAINTING-DRAWN        1 when the painting's variant is in the registry with a size (otherwise it has no atlas slots and draws nothing: variant null, return).
*>   ENTITY-PAINTING-EMIT  the quads of every cell (EF9-PAINTING-FACE of entmodel-34-9-10.cob: front, back and the edges), turned about Y by EF9-PAINTING-ROT, brightness of the cell's own block
*>                         (EF9-PAINTING-BLOCK). Not done: the depth bias of the render type entitySolidZOffsetForward (the back sprite lies in the wall's plane; the front sprite covers it
*>                         from every side the back could be seen from, and the opaque entity pipeline has no bias to give), and the inline Holder form (n = 0), which PB-MX-SCAN rejects.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-PAINTING-SET.
*> USING CLIENT-STATE, replica row, entry index, serializer, data length, data (the entry's bytes): a painting's entry 9 (serializer 34) holds the Holder VarInt n; n above 0 sets EN-X1 to n - 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-SCALE               BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-DATA                 PIC X(512).
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-INDEX L-SERIALIZER L-LENGTH L-DATA.
     IF EN-KEY(L-ROW) = "painting" AND L-INDEX = 9 AND L-SERIALIZER = 34
         MOVE 0 TO WS-VALUE
         MOVE 1 TO WS-SCALE WS-MORE
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4 OR WS-K > L-LENGTH OR WS-MORE = 0
             COMPUTE WS-BYTE = FUNCTION ORD(L-DATA(WS-K:1)) - 1
             COMPUTE WS-VALUE = WS-VALUE + FUNCTION MOD(WS-BYTE, 128) * WS-SCALE
             COMPUTE WS-SCALE = WS-SCALE * 128
             IF WS-BYTE < 128
                 MOVE 0 TO WS-MORE
             END-IF
         END-PERFORM
         IF WS-VALUE > 0
             COMPUTE EN-X1(L-ROW) = WS-VALUE - 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-PAINTING-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PAINTING-TEX-PATH.
*> USING CLIENT-STATE, texture code (variant id + 1), path out (X(64)): "textures/painting/<name>.png" of the variant's asset id minecraft:<name>; spaces for a code outside the registry,
*> a variant without an asset and an asset of another namespace (the pack stack then gives the row's own image).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(48).
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CODE                 BINARY-LONG.
 01 L-PATH                 PIC X(64).
 PROCEDURE DIVISION USING CLIENT-STATE L-CODE L-PATH.
     MOVE SPACES TO L-PATH
     IF L-CODE >= 1 AND L-CODE <= RG-PAINT-COUNT
         IF RG-PAINT-ASSET(L-CODE)(1:10) = "minecraft:" AND RG-PAINT-ASSET(L-CODE)(11:1) NOT = SPACE
             MOVE SPACES TO WS-NAME
             MOVE RG-PAINT-ASSET(L-CODE)(11:38) TO WS-NAME
             MOVE 1 TO WS-PTR
             STRING "textures/painting/" DELIMITED BY SIZE FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE
                 ".png" DELIMITED BY SIZE INTO L-PATH WITH POINTER WS-PTR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PAINTING-TEX-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PAINTING-DRAWN.
*> USING CLIENT-STATE, replica row of a painting, drawn out (BINARY-LONG): 1 when its variant (EN-X1 + 1) is a row of RG-PAINT with a width and a height, else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-DRAWN.
     MOVE 0 TO L-DRAWN
     COMPUTE WS-V = EN-X1(L-ROW) + 1
     IF WS-V >= 1 AND WS-V <= RG-PAINT-COUNT
         IF RG-PAINT-W(WS-V) >= 1 AND RG-PAINT-H(WS-V) >= 1
             MOVE 1 TO L-DRAWN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PAINTING-DRAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-PAINTING-EMIT.
*> USING CLIENT-STATE, replica row of a painting with its CL-MODELS slots, eye (3 FLOAT-LONG): appends the painting's quads (34-9 section 11): for each cell (i, j) of the variant's w x h the faces
*> EF9-PAINTING-FACE gives (front from the variant's sprite, back and edges from the back sprite), turned about Y by EF9-PAINTING-ROT (180 - data2D x 90 degrees: south 180, west 90, north 0, east
*> -90) and moved to the entity, eye-relative; the brightness is that of the block EF9-PAINTING-BLOCK names for the cell: max(sky light x daylight, block light) / 15, at least 0.1. A painting whose
*> variant the registry does not hold (or holds as 0 x 0), or whose sprites have no atlas slot, draws nothing (variant null: return).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-FRONT               BINARY-LONG.
 01 WS-BACK                BINARY-LONG.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IN-V             FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OUT-V            FLOAT-LONG OCCURS 64 TIMES.
 01 WS-ROT-IN.
    05 WS-ROT-IN-V         FLOAT-LONG OCCURS 32 TIMES.
 01 WS-ROT-OUT.
    05 WS-ROT-OUT-V        FLOAT-LONG OCCURS 64 TIMES.
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
     CALL "PAINTING-DRAWN" USING CLIENT-STATE L-ROW WS-DRAWN
     IF WS-DRAWN = 0
         GOBACK
     END-IF
     COMPUTE WS-V = EN-X1(L-ROW) + 1
     MOVE RG-PAINT-W(WS-V) TO WS-W
     MOVE RG-PAINT-H(WS-V) TO WS-H
     MOVE 0 TO WS-FRONT WS-BACK
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = EN-MODEL(L-ROW)
             IF EA-MT-TEX(WS-S) = 0
                 MOVE WS-S TO WS-BACK
             END-IF
             IF EA-MT-TEX(WS-S) = WS-V
                 MOVE WS-S TO WS-FRONT
             END-IF
         END-IF
     END-PERFORM
     IF WS-FRONT = 0 OR WS-BACK = 0
         GOBACK
     END-IF
*>   The turn about Y (a quarter turn is exact: no sine of an inexact angle).
     MOVE EN-FDIR(L-ROW) TO WS-ROT-IN-V(1)
     CALL "EF9-PAINTING-ROT" USING WS-ROT-IN WS-ROT-OUT
     EVALUATE WS-ROT-OUT-V(1)
         WHEN 0
             MOVE 1 TO WS-COS
             MOVE 0 TO WS-SIN
         WHEN 90
             MOVE 0 TO WS-COS
             MOVE 1 TO WS-SIN
         WHEN 180
             MOVE -1 TO WS-COS
             MOVE 0 TO WS-SIN
         WHEN OTHER
             MOVE 0 TO WS-COS
             MOVE -1 TO WS-SIN
     END-EVALUATE
     MOVE EN-FDIR(L-ROW) TO WS-IN-V(1)
     MOVE WS-W TO WS-IN-V(2)
     MOVE WS-H TO WS-IN-V(3)
     MOVE EN-X(L-ROW) TO WS-IN-V(6)
     MOVE EN-Y(L-ROW) TO WS-IN-V(7)
     MOVE EN-Z(L-ROW) TO WS-IN-V(8)
     COMPUTE WS-IN-V(9) = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-IN-V(10) = FUNCTION INTEGER(EN-Z(L-ROW))
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-H
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-W
             MOVE WS-I TO WS-IN-V(4)
             MOVE WS-J TO WS-IN-V(5)
             CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
             COMPUTE WS-BX = WS-OUT-V(1)
             COMPUTE WS-BY = WS-OUT-V(2)
             COMPUTE WS-BZ = WS-OUT-V(3)
             CALL "WORLD-CELL" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STATE WS-SKY WS-BLOCK
             COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
             PERFORM VARYING WS-F FROM 0 BY 1 UNTIL WS-F > 5
                 MOVE WS-W TO WS-ROT-IN-V(1)
                 MOVE WS-H TO WS-ROT-IN-V(2)
                 MOVE WS-I TO WS-ROT-IN-V(3)
                 MOVE WS-J TO WS-ROT-IN-V(4)
                 MOVE WS-F TO WS-ROT-IN-V(5)
                 CALL "EF9-PAINTING-FACE" USING WS-ROT-IN WS-ROT-OUT
                 IF WS-ROT-OUT-V(1) = 1 AND RL-EN-COUNT + 6 <= CL-MAX-ENTITY-VERTICES
                     MOVE WS-BACK TO WS-SLOT
                     IF WS-F = 0
                         MOVE WS-FRONT TO WS-SLOT
                     END-IF
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         COMPUTE WS-B = WS-K * 5 - 3
                         COMPUTE WS-X = WS-ROT-OUT-V(WS-B) * WS-COS + WS-ROT-OUT-V(WS-B + 2) * WS-SIN
                         COMPUTE WS-Z = WS-ROT-OUT-V(WS-B + 2) * WS-COS - WS-ROT-OUT-V(WS-B) * WS-SIN
                         COMPUTE WS-C-X(WS-K) = EN-X(L-ROW) - L-EYE(1) + WS-X
                         COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + WS-ROT-OUT-V(WS-B + 1)
                         COMPUTE WS-C-Z(WS-K) = EN-Z(L-ROW) - L-EYE(3) + WS-Z
                         COMPUTE WS-C-U(WS-K) = (EA-MT-X(WS-SLOT) + WS-ROT-OUT-V(WS-B + 3) * EA-MT-W(WS-SLOT)) / EA-W
                         COMPUTE WS-C-V(WS-K) = (EA-MT-Y(WS-SLOT) + WS-ROT-OUT-V(WS-B + 4) * EA-MT-H(WS-SLOT)) / EA-H
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
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-PAINTING-EMIT.
