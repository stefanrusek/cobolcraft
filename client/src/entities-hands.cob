*> Held items of the mobs (34-3 section 1.4 ItemInHandLayer and CrossedArmsItemLayer). The renderer places the item by the transform chain of the arm part; the replica
*> finds the hand from the baked cuboid of the arm instead: ENTITY-HAND-FIND takes the eight corners of that cuboid, entity-relative with the pose and yaw applied.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-HAND-FIND.
*> USING the eight corners of an arm's cuboid (8 x X, Y, Z FLOAT-SHORT, in no particular order), kind (1 an arm: the hand is its end that hangs lowest, or when the arm lies
*> more along the ground the end farther from the entity's axis; 2 the crossed arms: the centre of the box, pointing down), hand point out (3 FLOAT-LONG), direction out (3
*> FLOAT-LONG, the unit vector from the shoulder end to the hand end), ok out (1 when found: always, the box has corners).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-D                   FLOAT-LONG OCCURS 8 TIMES.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-H1                  FLOAT-LONG.
 01 WS-H2                  FLOAT-LONG.
 01 WS-USED                BINARY-LONG OCCURS 8 TIMES.
 01 WS-LONGEST             FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-DOT1                FLOAT-LONG.
 01 WS-DOT2                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CORNERS.
    05 L-CP OCCURS 8 TIMES.
       10 L-CX               FLOAT-SHORT.
       10 L-CY               FLOAT-SHORT.
       10 L-CZ               FLOAT-SHORT.
 01 L-KIND                 BINARY-LONG.
 01 L-P.
    05 L-PV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-A.
    05 L-AV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CORNERS L-KIND L-P L-A L-OK.
     MOVE 1 TO L-OK
     MOVE 0 TO WS-CX WS-CY WS-CZ
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
         ADD L-CX(WS-K) TO WS-CX
         ADD L-CY(WS-K) TO WS-CY
         ADD L-CZ(WS-K) TO WS-CZ
     END-PERFORM
     COMPUTE WS-CX = WS-CX / 8
     COMPUTE WS-CY = WS-CY / 8
     COMPUTE WS-CZ = WS-CZ / 8
     MOVE WS-CX TO L-PV(1)
     MOVE WS-CY TO L-PV(2)
     MOVE WS-CZ TO L-PV(3)
     MOVE 0 TO L-AV(1) L-AV(3)
     MOVE -1 TO L-AV(2)
     IF L-KIND = 1
*>       The edges at corner 1: the nearest corner is on the shortest edge a; among the corners whose vector is at right angles to it the nearest is on the next
*>       edge b, and the one at right angles to both on the edge c (the corner order is not known, so the edges are found from the geometry); the longest of the
*>       three is the arm's axis.
         PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 8
             COMPUTE WS-D(WS-K) = (L-CX(WS-K) - L-CX(1)) * (L-CX(WS-K) - L-CX(1)) + (L-CY(WS-K) - L-CY(1)) * (L-CY(WS-K) - L-CY(1))
                 + (L-CZ(WS-K) - L-CZ(1)) * (L-CZ(WS-K) - L-CZ(1))
             MOVE 0 TO WS-USED(WS-K)
         END-PERFORM
         MOVE 0 TO WS-LONGEST WS-BEST
         MOVE 0 TO WS-AX WS-AY WS-AZ WS-BX WS-BY WS-BZ
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 3
             MOVE 0 TO WS-J
             MOVE 1000000 TO WS-MIN
             PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 8
                 COMPUTE WS-DOT1 = (L-CX(WS-K) - L-CX(1)) * WS-AX + (L-CY(WS-K) - L-CY(1)) * WS-AY + (L-CZ(WS-K) - L-CZ(1)) * WS-AZ
                 COMPUTE WS-DOT2 = (L-CX(WS-K) - L-CX(1)) * WS-BX + (L-CY(WS-K) - L-CY(1)) * WS-BY + (L-CZ(WS-K) - L-CZ(1)) * WS-BZ
                 IF WS-D(WS-K) < WS-MIN AND WS-D(WS-K) > 0.0000001
                         AND FUNCTION ABS(WS-DOT1) < 0.001 * WS-D(WS-K) AND FUNCTION ABS(WS-DOT2) < 0.001 * WS-D(WS-K)
                     MOVE WS-D(WS-K) TO WS-MIN
                     MOVE WS-K TO WS-J
                 END-IF
             END-PERFORM
             IF WS-N = 1
                 COMPUTE WS-AX = L-CX(WS-J) - L-CX(1)
                 COMPUTE WS-AY = L-CY(WS-J) - L-CY(1)
                 COMPUTE WS-AZ = L-CZ(WS-J) - L-CZ(1)
             END-IF
             IF WS-N = 2
                 COMPUTE WS-BX = L-CX(WS-J) - L-CX(1)
                 COMPUTE WS-BY = L-CY(WS-J) - L-CY(1)
                 COMPUTE WS-BZ = L-CZ(WS-J) - L-CZ(1)
             END-IF
             IF WS-D(WS-J) > WS-LONGEST
                 MOVE WS-D(WS-J) TO WS-LONGEST
                 MOVE WS-J TO WS-BEST
             END-IF
         END-PERFORM
         COMPUTE WS-EX = L-CX(WS-BEST) - L-CX(1)
         COMPUTE WS-EY = L-CY(WS-BEST) - L-CY(1)
         COMPUTE WS-EZ = L-CZ(WS-BEST) - L-CZ(1)
         COMPUTE WS-LEN = FUNCTION SQRT(WS-EX * WS-EX + WS-EY * WS-EY + WS-EZ * WS-EZ)
*>       The end that hangs lower when the axis is more vertical than horizontal, else the end farther from the entity's axis.
         COMPUTE WS-H1 = FUNCTION SQRT(WS-EX * WS-EX + WS-EZ * WS-EZ)
         MOVE 1 TO WS-J
         IF FUNCTION ABS(WS-EY) > WS-H1
             IF WS-EY > 0
                 MOVE -1 TO WS-J
             END-IF
         ELSE
             COMPUTE WS-H1 = (WS-CX + WS-EX / 2) * (WS-CX + WS-EX / 2) + (WS-CZ + WS-EZ / 2) * (WS-CZ + WS-EZ / 2)
             COMPUTE WS-H2 = (WS-CX - WS-EX / 2) * (WS-CX - WS-EX / 2) + (WS-CZ - WS-EZ / 2) * (WS-CZ - WS-EZ / 2)
             IF WS-H2 > WS-H1
                 MOVE -1 TO WS-J
             END-IF
         END-IF
*>       WS-J is 1 when the end at the centre plus half the edge is the hand, -1 for the other end.
         COMPUTE L-PV(1) = WS-CX + WS-J * WS-EX / 2
         COMPUTE L-PV(2) = WS-CY + WS-J * WS-EY / 2
         COMPUTE L-PV(3) = WS-CZ + WS-J * WS-EZ / 2
         COMPUTE L-AV(1) = WS-J * WS-EX / WS-LEN
         COMPUTE L-AV(2) = WS-J * WS-EY / WS-LEN
         COMPUTE L-AV(3) = WS-J * WS-EZ / WS-LEN
     END-IF
     GOBACK.
 END PROGRAM ENTITY-HAND-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-HELD-EMIT.
*> USING CLIENT-STATE, replica row, hand (1 right arm, 2 left arm), item registry id, eye (3 FLOAT-LONG): appends the item held in the hand EN-HAND of the row to
*> RL-GI-VERTEX as its flat sprite, two quads (front and back, 12 vertices). The sprite is a square of 0.55 block (the 0.55 scale of the item display transform of
*> the third-person hand), its handle at the hand and its diagonal along the item direction: the arm's direction turned a quarter about the mob's right axis (hanging
*> arm: forwards, arm raised forwards: up, 34-3 1.4: rotate X -90 degrees), blade up-right. Lit by the light of the mob's cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TRG-1              FLOAT-LONG.
 01 WS-PIF                FLOAT-LONG VALUE 3.141592653589793.
 COPY CLCONST.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-UX                  FLOAT-LONG.
 01 WS-UY                  FLOAT-LONG.
 01 WS-UZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-S                   FLOAT-LONG VALUE 0.275.
 01 WS-SU                  FLOAT-LONG.
 01 WS-SV                  FLOAT-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X             FLOAT-SHORT.
       10 WS-C-Y             FLOAT-SHORT.
       10 WS-C-Z             FLOAT-SHORT.
       10 WS-C-U             FLOAT-SHORT.
       10 WS-C-V             FLOAT-SHORT.
*> The six vertices of a quad: corners 1, 2, 3, 1, 3, 4 (front) and 1, 3, 2, 1, 4, 3 (back).
 01 WS-ORDER-DATA          PIC X(12) VALUE "123134132143".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 12 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-HAND L-ITEM L-EYE-TABLE.
     IF RL-GI-COUNT + 12 > CL-MAX-GI-VERTICES
         GOBACK
     END-IF
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE L-ITEM WS-SPRITE
     MOVE FUNCTION MAX(WS-SPRITE, 1) TO WS-SPRITE
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
*>   The mob's forward F = (-sin yaw, 0, cos yaw), its right axis R = up x F = (Fz, 0, -Fx); the item direction D = axis x R.
     COMPUTE WS-TRG-1 = EN-YAW(L-ROW) * WS-PIF / 180
     COMPUTE WS-FX = - FUNCTION SIN(WS-TRG-1)
     COMPUTE WS-TRG-1 = EN-YAW(L-ROW) * WS-PIF / 180
     COMPUTE WS-FZ = FUNCTION COS(WS-TRG-1)
     MOVE WS-FZ TO WS-RX
     COMPUTE WS-RZ = - WS-FX
     COMPUTE WS-DX = EN-HAND-V(L-ROW, L-HAND, 5) * WS-RZ
     COMPUTE WS-DY = EN-HAND-V(L-ROW, L-HAND, 6) * WS-RX - EN-HAND-V(L-ROW, L-HAND, 4) * WS-RZ
     COMPUTE WS-DZ = - EN-HAND-V(L-ROW, L-HAND, 5) * WS-RX
*>   The sprite's up U = (D - axis) / sqrt 2 and its right V = (D + axis) / sqrt 2 (D and the axis are perpendicular unit vectors).
     COMPUTE WS-UX = (WS-DX - EN-HAND-V(L-ROW, L-HAND, 4)) * 0.70710678
     COMPUTE WS-UY = (WS-DY - EN-HAND-V(L-ROW, L-HAND, 5)) * 0.70710678
     COMPUTE WS-UZ = (WS-DZ - EN-HAND-V(L-ROW, L-HAND, 6)) * 0.70710678
     COMPUTE WS-VX = (WS-DX + EN-HAND-V(L-ROW, L-HAND, 4)) * 0.70710678
     COMPUTE WS-VY = (WS-DY + EN-HAND-V(L-ROW, L-HAND, 5)) * 0.70710678
     COMPUTE WS-VZ = (WS-DZ + EN-HAND-V(L-ROW, L-HAND, 6)) * 0.70710678
*>   Corner k: top-left (1), top-right (2), bottom-right (3), bottom-left (4) round the centre, a quarter of the item's diagonal ahead of the hand.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE 1 TO WS-SU
         MOVE -1 TO WS-SV
         MOVE 0 TO WS-U16 WS-V16
         IF WS-K = 2 OR WS-K = 3
             MOVE 1 TO WS-SV
             MOVE 16 TO WS-U16
         END-IF
         IF WS-K >= 3
             MOVE -1 TO WS-SU
             MOVE 16 TO WS-V16
         END-IF
         COMPUTE WS-C-X(WS-K) = EN-X(L-ROW) - L-EYE(1) + EN-HAND-V(L-ROW, L-HAND, 1) + WS-DX * 0.2 + (WS-SU * WS-UX + WS-SV * WS-VX) * WS-S
         COMPUTE WS-C-Y(WS-K) = EN-Y(L-ROW) - L-EYE(2) + EN-HAND-V(L-ROW, L-HAND, 2) + WS-DY * 0.2 + (WS-SU * WS-UY + WS-SV * WS-VY) * WS-S
         COMPUTE WS-C-Z(WS-K) = EN-Z(L-ROW) - L-EYE(3) + EN-HAND-V(L-ROW, L-HAND, 3) + WS-DZ * 0.2 + (WS-SU * WS-UZ + WS-SV * WS-VZ) * WS-S
         CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-C-U(WS-K) WS-C-V(WS-K)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-ORD(WS-I) TO WS-N
         ADD 1 TO RL-GI-COUNT
         MOVE WS-C-X(WS-N) TO RL-GI-X(RL-GI-COUNT)
         MOVE WS-C-Y(WS-N) TO RL-GI-Y(RL-GI-COUNT)
         MOVE WS-C-Z(WS-N) TO RL-GI-Z(RL-GI-COUNT)
         MOVE WS-C-U(WS-N) TO RL-GI-U(RL-GI-COUNT)
         MOVE WS-C-V(WS-N) TO RL-GI-V(RL-GI-COUNT)
         MOVE WS-LIGHT TO RL-GI-B(RL-GI-COUNT)
         MOVE 1 TO RL-GI-A(RL-GI-COUNT)
         MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
         MOVE 1 TO RL-GI-R(RL-GI-COUNT) RL-GI-G(RL-GI-COUNT) RL-GI-BLUE(RL-GI-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-HELD-EMIT.
