*> The bed item (lane bugbeitem; docs/protocol/52 sections 5.3 to 5.5). The item definition of a bed is a `minecraft:composite` of two block models, so the generic icon path took only its first
*> member: the head half, drawn as a cube. SPECIAL-BED-QUADS builds the quads of the whole item for the code-drawn item pipelines (item-special-draw.cob: slot, ground, hand) from the real
*> models: block/<colour>_bed_head as it is and block/<colour>_bed_foot translated one block along z (52 5.4); the straw bed's two models are turned half a turn about Y first (x and z become
*> minus x and minus z), the head translated by (1, 0, 1) and the foot by (1, 0, 2) (52 5.5).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-BED-QUADS.
*> USING CLIENT-STATE, head model id (PIC X(80), "minecraft:block/<name>_head") and its length, foot model id and its length, straw (1 for the straw bed, else 0), SQ-TABLE (CLSQ.cpy): every face of
*> both models as one quad of SQ-TABLE in the unit cell the display transform acts on (ELEMENT-BAKE: corners clockwise seen from outside, y up, the texture coordinates of the face's sprite in the
*> block atlas), the outward unit normal, white tint. The quads that do not fit the table (48) are left out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODEL.
 COPY CLQUAD.
 01 WS-ID                  PIC X(80).
 01 WS-LEN                 BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-SIGN                FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-W                   FLOAT-LONG OCCURS 12 TIMES.
 01 WS-A                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-B                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CROSS               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NORM                FLOAT-LONG.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID1                  PIC X(80).
 01 L-LEN1                 BINARY-LONG.
 01 L-ID2                  PIC X(80).
 01 L-LEN2                 BINARY-LONG.
 01 L-STRAW                BINARY-LONG.
 COPY CLSQ.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID1 L-LEN1 L-ID2 L-LEN2 L-STRAW SQ-TABLE.
     MOVE 0 TO SQ-COUNT
     PERFORM VARYING WS-PART FROM 1 BY 1 UNTIL WS-PART > 2
         MOVE SPACES TO WS-ID
         IF WS-PART = 1
             MOVE L-ID1 TO WS-ID
             MOVE L-LEN1 TO WS-LEN
             MOVE 0 TO WS-TZ
         ELSE
             MOVE L-ID2 TO WS-ID
             MOVE L-LEN2 TO WS-LEN
             MOVE 1 TO WS-TZ
         END-IF
*>       The model's placement in the item definition: the colours keep x and shift the foot by one in z; the straw bed turns both half a turn about Y (52 5.5).
         MOVE 1 TO WS-SIGN
         MOVE 0 TO WS-TX
         IF L-STRAW = 1
             MOVE -1 TO WS-SIGN
             MOVE 1 TO WS-TX
             ADD 1 TO WS-TZ
         END-IF
         CALL "MODEL-RESOLVE" USING CLIENT-STATE WS-ID WS-LEN MODEL-RESOLVED
         IF MR-MISSING = 0
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > MR-ELEMENT-COUNT
                 PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
                     IF MF-PRESENT(WS-E, WS-F) = 1 AND SQ-COUNT < 48
                         CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED MF-TEXTURE(WS-E, WS-F) WS-SPRITE
                         CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-E WS-F WS-SPRITE QUAD
                         ADD 1 TO SQ-COUNT
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                             COMPUTE WS-W((WS-K - 1) * 3 + 1) = WS-SIGN * QD-X(WS-K) + WS-TX
                             COMPUTE WS-W((WS-K - 1) * 3 + 2) = QD-Y(WS-K)
                             COMPUTE WS-W((WS-K - 1) * 3 + 3) = WS-SIGN * QD-Z(WS-K) + WS-TZ
                             MOVE WS-W((WS-K - 1) * 3 + 1) TO SQ-C(SQ-COUNT, (WS-K - 1) * 3 + 1)
                             MOVE WS-W((WS-K - 1) * 3 + 2) TO SQ-C(SQ-COUNT, (WS-K - 1) * 3 + 2)
                             MOVE WS-W((WS-K - 1) * 3 + 3) TO SQ-C(SQ-COUNT, (WS-K - 1) * 3 + 3)
                             MOVE QD-U(WS-K) TO WS-U
                             MOVE QD-V(WS-K) TO WS-V
                             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U WS-V SQ-U(SQ-COUNT, WS-K) SQ-V(SQ-COUNT, WS-K)
                             MOVE 1 TO SQ-T(SQ-COUNT, 1) SQ-T(SQ-COUNT, 2) SQ-T(SQ-COUNT, 3)
                         END-PERFORM
*>                       The outward normal is minus the cross product of the first two edges (the quad winds clockwise seen from outside).
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                             COMPUTE WS-A(WS-K) = WS-W(3 + WS-K) - WS-W(WS-K)
                             COMPUTE WS-B(WS-K) = WS-W(6 + WS-K) - WS-W(3 + WS-K)
                         END-PERFORM
                         COMPUTE WS-CROSS(1) = WS-A(2) * WS-B(3) - WS-A(3) * WS-B(2)
                         COMPUTE WS-CROSS(2) = WS-A(3) * WS-B(1) - WS-A(1) * WS-B(3)
                         COMPUTE WS-CROSS(3) = WS-A(1) * WS-B(2) - WS-A(2) * WS-B(1)
                         COMPUTE WS-NORM = FUNCTION SQRT(WS-CROSS(1) * WS-CROSS(1) + WS-CROSS(2) * WS-CROSS(2) + WS-CROSS(3) * WS-CROSS(3))
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                             COMPUTE SQ-N(SQ-COUNT, WS-K) = 0 - WS-CROSS(WS-K) / WS-NORM
                         END-PERFORM
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPECIAL-BED-QUADS.
