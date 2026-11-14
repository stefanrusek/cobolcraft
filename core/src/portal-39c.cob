*> The teleport transition model and the inside-block sweep (docs/protocol/39-portals.md sections 2.2a and 6; tasks T1755, T1756):
*>   PORTAL-TRIG USING angle (radians), sine out, cosine out (FLOAT-LONG): Mth.sin and Mth.cos, the 65536-entry table (6.3).
*>   PORTAL-RESOLVE USING base (PORTALPMR.cpy), change (PORTALPMR.cpy), relatives (BINARY-LONG bit set, bits as 1.1: X 0, Y 1, Z 2, Y_ROT 3, X_ROT 4,
*>     DELTA_X 5, DELTA_Y 6, DELTA_Z 7, ROTATE_DELTA 8), result out (PORTALPMR.cpy): PositionMoveRotation.calculateAbsolute (6.3).
*>   PORTAL-FREE-POS USING dimension row, x, y, z (FLOAT-LONG in and out), width, height (FLOAT-LONG): PortalShape.findCollisionFreePosition (6.8).
*>   PORTAL-SWEEP USING player row, found out, x, y, z out (BINARY-LONG): the cells a player's box touched since the previous call along its movement
*>     path (2.2a), the first portal block among them.
*> Not done (open items of the entity model): passengers (6.7: no vehicles), the non-player cross-dimension teleport (6.6: items and mobs do not use
*> portals), the chunk ticket of 6.4 (the core has no tickets), the shape boxes are taken per cell whose column is inside the border (6.8 step 3), the
*> order of boxes of equal distance is the order the cells are visited (open question 2), the sweep takes straight per-axis legs of at most 16 blocks in
*> total and no block-step budget (a longer move counts as a teleport and tests only the current position).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-TRIG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   FLOAT-LONG VALUE 10430.378350470453.
 01 WS-QUARTER             FLOAT-LONG VALUE 16384.0.
 01 WS-T                   FLOAT-LONG.
 01 WS-I                   BINARY-DOUBLE.
 01 WS-IDX                 BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ANGLE                FLOAT-LONG.
 01 L-SIN                  FLOAT-LONG.
 01 L-COS                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-ANGLE L-SIN L-COS.
     COMPUTE WS-T = L-ANGLE * WS-K
     COMPUTE WS-I = FUNCTION INTEGER-PART(WS-T)
     COMPUTE WS-IDX = FUNCTION MOD(WS-I, 65536)
     COMPUTE WS-A = WS-IDX / WS-K
     COMPUTE WS-R = FUNCTION SIN(WS-A)
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-R L-SIN
     COMPUTE WS-T = L-ANGLE * WS-K + WS-QUARTER
     COMPUTE WS-I = FUNCTION INTEGER-PART(WS-T)
     COMPUTE WS-IDX = FUNCTION MOD(WS-I, 65536)
     COMPUTE WS-A = WS-IDX / WS-K
     COMPUTE WS-R = FUNCTION SIN(WS-A)
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-R L-COS
     GOBACK.
 END PROGRAM PORTAL-TRIG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-RESOLVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PI-180              FLOAT-LONG VALUE 0.017453292519943295.
 01 WS-Q                   BINARY-LONG.
 01 WS-Q2                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BITS.
    05 WS-BIT              BINARY-LONG OCCURS 9 TIMES.
 01 WS-D                   FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY PORTALPMR REPLACING ==PORTAL-PMR== BY ==L-BASE== LEADING ==PMR-== BY ==B-==.
 COPY PORTALPMR REPLACING ==PORTAL-PMR== BY ==L-CHANGE== LEADING ==PMR-== BY ==C-==.
 01 L-REL                  BINARY-LONG.
 COPY PORTALPMR REPLACING ==PORTAL-PMR== BY ==L-RESULT== LEADING ==PMR-== BY ==R-==.
 PROCEDURE DIVISION USING L-BASE L-CHANGE L-REL L-RESULT.
     MOVE L-REL TO WS-Q
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 9
         DIVIDE WS-Q BY 2 GIVING WS-Q2 REMAINDER WS-BIT(WS-N)
         MOVE WS-Q2 TO WS-Q
     END-PERFORM
*>   1. position
     MOVE C-X TO R-X
     MOVE C-Y TO R-Y
     MOVE C-Z TO R-Z
     IF WS-BIT(1) = 1
         COMPUTE R-X = B-X + C-X
     END-IF
     IF WS-BIT(2) = 1
         COMPUTE R-Y = B-Y + C-Y
     END-IF
     IF WS-BIT(3) = 1
         COMPUTE R-Z = B-Z + C-Z
     END-IF
*>   2. rotation: yaw without wrapping, pitch clamped to -90..90, both floats
     MOVE C-YAW TO WS-T
     IF WS-BIT(4) = 1
         COMPUTE WS-T = B-YAW + C-YAW
     END-IF
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T R-YAW
     MOVE C-PITCH TO WS-T
     IF WS-BIT(5) = 1
         COMPUTE WS-T = B-PITCH + C-PITCH
     END-IF
     IF WS-T > 90
         MOVE 90 TO WS-T
     END-IF
     IF WS-T < -90
         MOVE -90 TO WS-T
     END-IF
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T R-PITCH
*>   3. velocity: the base, rotated first about X by the pitch difference and then about Y by the yaw difference when ROTATE_DELTA is set
     MOVE B-DX TO WS-RX
     MOVE B-DY TO WS-RY
     MOVE B-DZ TO WS-RZ
     IF WS-BIT(9) = 1
         COMPUTE WS-T = B-PITCH - R-PITCH
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-D
         COMPUTE WS-T = WS-D * WS-PI-180
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-ANGLE
         CALL "PORTAL-TRIG" USING WS-ANGLE WS-S WS-C
         COMPUTE WS-T = WS-RY * WS-C + WS-RZ * WS-S
         COMPUTE WS-RZ = WS-RZ * WS-C - WS-RY * WS-S
         MOVE WS-T TO WS-RY
         COMPUTE WS-T = B-YAW - R-YAW
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-D
         COMPUTE WS-T = WS-D * WS-PI-180
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-ANGLE
         CALL "PORTAL-TRIG" USING WS-ANGLE WS-S WS-C
         COMPUTE WS-T = WS-RX * WS-C + WS-RZ * WS-S
         COMPUTE WS-RZ = WS-RZ * WS-C - WS-RX * WS-S
         MOVE WS-T TO WS-RX
     END-IF
     MOVE C-DX TO R-DX
     MOVE C-DY TO R-DY
     MOVE C-DZ TO R-DZ
     IF WS-BIT(6) = 1
         COMPUTE R-DX = WS-RX + C-DX
     END-IF
     IF WS-BIT(7) = 1
         COMPUTE R-DY = WS-RY + C-DY
     END-IF
     IF WS-BIT(8) = 1
         COMPUTE R-DZ = WS-RZ + C-DZ
     END-IF
     GOBACK.
 END PROGRAM PORTAL-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FREE-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY CTBSHAPE.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WS-EPS                 FLOAT-LONG VALUE 0.000001.
 01 WS-HALF-W              FLOAT-LONG.
 01 WS-HALF-H              FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-PROBE.
    05 WS-P                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-FREE-TABLE.
    05 WS-FR OCCURS 1024 TIMES.
       10 WS-FV            FLOAT-LONG OCCURS 6 TIMES.
       10 WS-FALIVE        BINARY-LONG.
 01 WS-FREE-COUNT          BINARY-LONG.
 01 WS-FREE-OLD            BINARY-LONG.
 01 WS-FB.
    05 WS-FBV              FLOAT-LONG OCCURS 6 TIMES.
 01 WS-PIECE.
    05 WS-PV               FLOAT-LONG OCCURS 6 TIMES.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-OVER                BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-CELL                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-BEST                FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-FOUND-X             FLOAT-LONG.
 01 WS-FOUND-Y             FLOAT-LONG.
 01 WS-FOUND-Z             FLOAT-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-WIDTH                FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-WIDTH L-HEIGHT.
*>   1. a body wider or taller than 4 keeps its position
     IF L-WIDTH > 4.0 OR L-HEIGHT > 4.0
         GOBACK
     END-IF
*>   2. the probe: a (width, 0, width) box round the centre, extended upward by 1 and inflated by 1e-6
     COMPUTE WS-HALF-W = L-WIDTH / 2
     COMPUTE WS-HALF-H = L-HEIGHT / 2
     MOVE L-X TO WS-CX
     COMPUTE WS-CY = L-Y + WS-HALF-H
     MOVE L-Z TO WS-CZ
     COMPUTE WS-P(1) = WS-CX - WS-HALF-W - WS-EPS
     COMPUTE WS-P(2) = WS-CY - WS-EPS
     COMPUTE WS-P(3) = WS-CZ - WS-HALF-W - WS-EPS
     COMPUTE WS-P(4) = WS-CX + WS-HALF-W + WS-EPS
     COMPUTE WS-P(5) = WS-CY + 1 + WS-EPS
     COMPUTE WS-P(6) = WS-CZ + WS-HALF-W + WS-EPS
     MOVE 1 TO WS-FREE-COUNT
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 6
         MOVE WS-P(WS-A) TO WS-FV(1, WS-A)
     END-PERFORM
     MOVE 1 TO WS-FALIVE(1)
*>   3. the collision shapes in the probe inflated by (width, height, width), each box inflated by (width / 2, height / 2, width / 2) and subtracted
     COMPUTE WS-LO = WS-P(1) - L-WIDTH
     COMPUTE WS-X0 = FUNCTION INTEGER(WS-LO)
     COMPUTE WS-HI = WS-P(4) + L-WIDTH
     COMPUTE WS-X1 = FUNCTION INTEGER(WS-HI)
     COMPUTE WS-LO = WS-P(2) - L-HEIGHT
     COMPUTE WS-Y0 = FUNCTION INTEGER(WS-LO)
     COMPUTE WS-HI = WS-P(5) + L-HEIGHT
     COMPUTE WS-Y1 = FUNCTION INTEGER(WS-HI)
     COMPUTE WS-LO = WS-P(3) - L-WIDTH
     COMPUTE WS-Z0 = FUNCTION INTEGER(WS-LO)
     COMPUTE WS-HI = WS-P(6) + L-WIDTH
     COMPUTE WS-Z1 = FUNCTION INTEGER(WS-HI)
     PERFORM VARYING WS-BY FROM WS-Y0 BY 1 UNTIL WS-BY > WS-Y1
         PERFORM VARYING WS-BZ FROM WS-Z0 BY 1 UNTIL WS-BZ > WS-Z1
             PERFORM VARYING WS-BX FROM WS-X0 BY 1 UNTIL WS-BX > WS-X1
                 CALL "PORTAL-IN-BORDER" USING L-DIM WS-BX WS-BZ WS-INSIDE
                 IF WS-INSIDE = 1
                     CALL "WORLD-GET-BLOCK" USING L-DIM WS-BX WS-BY WS-BZ WS-STATE
                     IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
                         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLK
                         MOVE CB-SOLID(WS-BLK + 1) TO WS-SHAPE
                         IF WS-SHAPE = 1
                             CALL "BSH-ENSURE-CUBE"
                         END-IF
                     ELSE
                         CALL "BSH-COLL-ID" USING WS-STATE WS-SHAPE
                     END-IF
                     IF WS-SHAPE NOT = 0
                         MOVE WS-BX TO WS-CELL(1)
                         MOVE WS-BY TO WS-CELL(2)
                         MOVE WS-BZ TO WS-CELL(3)
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSH-N(WS-SHAPE + 1)
                             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                                 COMPUTE WS-FBV(WS-A) = WS-CELL(WS-A) + BSH-V(WS-SHAPE + 1, WS-I, WS-A) / 16000
                                 COMPUTE WS-FBV(WS-A + 3) = WS-CELL(WS-A) + BSH-V(WS-SHAPE + 1, WS-I, WS-A + 3) / 16000
                             END-PERFORM
                             COMPUTE WS-FBV(1) = WS-FBV(1) - WS-HALF-W
                             COMPUTE WS-FBV(4) = WS-FBV(4) + WS-HALF-W
                             COMPUTE WS-FBV(2) = WS-FBV(2) - WS-HALF-H
                             COMPUTE WS-FBV(5) = WS-FBV(5) + WS-HALF-H
                             COMPUTE WS-FBV(3) = WS-FBV(3) - WS-HALF-W
                             COMPUTE WS-FBV(6) = WS-FBV(6) + WS-HALF-W
                             PERFORM SUBTRACT-BOX
                         END-PERFORM
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   what remains: the point of the remaining boxes nearest to the centre (strictly nearer replaces)
     MOVE 0 TO WS-HAVE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-FREE-COUNT
         MOVE WS-CX TO WS-PX
         IF WS-PX < WS-FV(WS-I, 1)
             MOVE WS-FV(WS-I, 1) TO WS-PX
         END-IF
         IF WS-PX > WS-FV(WS-I, 4)
             MOVE WS-FV(WS-I, 4) TO WS-PX
         END-IF
         MOVE WS-CY TO WS-PY
         IF WS-PY < WS-FV(WS-I, 2)
             MOVE WS-FV(WS-I, 2) TO WS-PY
         END-IF
         IF WS-PY > WS-FV(WS-I, 5)
             MOVE WS-FV(WS-I, 5) TO WS-PY
         END-IF
         MOVE WS-CZ TO WS-PZ
         IF WS-PZ < WS-FV(WS-I, 3)
             MOVE WS-FV(WS-I, 3) TO WS-PZ
         END-IF
         IF WS-PZ > WS-FV(WS-I, 6)
             MOVE WS-FV(WS-I, 6) TO WS-PZ
         END-IF
         COMPUTE WS-D2 = (WS-PX - WS-CX) * (WS-PX - WS-CX) + (WS-PY - WS-CY) * (WS-PY - WS-CY) + (WS-PZ - WS-CZ) * (WS-PZ - WS-CZ)
         IF WS-HAVE = 0 OR WS-D2 < WS-BEST
             MOVE 1 TO WS-HAVE
             MOVE WS-D2 TO WS-BEST
             MOVE WS-PX TO WS-FOUND-X
             MOVE WS-PY TO WS-FOUND-Y
             MOVE WS-PZ TO WS-FOUND-Z
         END-IF
     END-PERFORM
*>   4. the found point less (0, height / 2, 0), else the position unchanged (a position that is already free keeps its exact value)
     IF WS-HAVE = 1 AND WS-BEST > 0.000000000001
         MOVE WS-FOUND-X TO L-X
         COMPUTE L-Y = WS-FOUND-Y - WS-HALF-H
         MOVE WS-FOUND-Z TO L-Z
     END-IF
     GOBACK.

*> Subtracts the box WS-FB from every live box of the free list: a box that overlaps it with positive volume is replaced by up to six pieces.
 SUBTRACT-BOX.
     MOVE WS-FREE-COUNT TO WS-FREE-OLD
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-FREE-OLD
         MOVE 1 TO WS-OVER
         PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 3
             COMPUTE WS-LO = FUNCTION MAX(WS-FV(WS-S, WS-V), WS-FBV(WS-V))
             COMPUTE WS-HI = FUNCTION MIN(WS-FV(WS-S, WS-V + 3), WS-FBV(WS-V + 3))
             IF WS-HI <= WS-LO
                 MOVE 0 TO WS-OVER
             END-IF
         END-PERFORM
         IF WS-OVER = 1 AND WS-FALIVE(WS-S) = 1
             MOVE 0 TO WS-FALIVE(WS-S)
             PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 6
                 MOVE WS-FV(WS-S, WS-V) TO WS-PV(WS-V)
             END-PERFORM
             PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 3
                 IF WS-PV(WS-V) < WS-FBV(WS-V)
                     PERFORM ADD-LOW-PIECE
                     MOVE WS-FBV(WS-V) TO WS-PV(WS-V)
                 END-IF
                 IF WS-PV(WS-V + 3) > WS-FBV(WS-V + 3)
                     PERFORM ADD-HIGH-PIECE
                     MOVE WS-FBV(WS-V + 3) TO WS-PV(WS-V + 3)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
*>   compact: keep the live boxes
     MOVE 0 TO WS-J
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-FREE-COUNT
         IF WS-FALIVE(WS-S) = 1
             ADD 1 TO WS-J
             IF WS-J NOT = WS-S
                 MOVE WS-FR(WS-S) TO WS-FR(WS-J)
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-J TO WS-FREE-COUNT.

*> The part of WS-PV below WS-FBV on axis WS-V, appended live.
 ADD-LOW-PIECE.
     IF WS-FREE-COUNT < 1024
         ADD 1 TO WS-FREE-COUNT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             MOVE WS-PV(WS-K) TO WS-FV(WS-FREE-COUNT, WS-K)
         END-PERFORM
         MOVE WS-FBV(WS-V) TO WS-FV(WS-FREE-COUNT, WS-V + 3)
         MOVE 1 TO WS-FALIVE(WS-FREE-COUNT)
     END-IF.

*> The part of WS-PV above WS-FBV on axis WS-V, appended live.
 ADD-HIGH-PIECE.
     IF WS-FREE-COUNT < 1024
         ADD 1 TO WS-FREE-COUNT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             MOVE WS-PV(WS-K) TO WS-FV(WS-FREE-COUNT, WS-K)
         END-PERFORM
         MOVE WS-FBV(WS-V + 3) TO WS-FV(WS-FREE-COUNT, WS-V)
         MOVE 1 TO WS-FALIVE(WS-FREE-COUNT)
     END-IF.
 END PROGRAM PORTAL-FREE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-SWEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-OLD-TABLE.
    05 WS-O OCCURS 64 TIMES.
       10 WS-O-OWNER       BINARY-LONG.
       10 WS-O-DIM         BINARY-LONG.
       10 WS-O-HAS         BINARY-LONG.
       10 WS-O-X           FLOAT-LONG.
       10 WS-O-Y           FLOAT-LONG.
       10 WS-O-Z           FLOAT-LONG.
 01 WS-EPS                 FLOAT-LONG VALUE 0.00001.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-CUR.
    05 WS-C                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NEXT.
    05 WS-N                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-TARGET.
    05 WS-T                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-ORDER.
    05 WS-AX               BINARY-LONG OCCURS 3 TIMES.
 01 WS-LEG                 BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-MIN-X               BINARY-LONG.
 01 WS-MAX-X               BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-MAX-Y               BINARY-LONG.
 01 WS-MIN-Z               BINARY-LONG.
 01 WS-MAX-Z               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FOUND L-X L-Y L-Z.
     MOVE 0 TO L-FOUND
     IF WS-O-OWNER(L-ROW) NOT = PL-ENTITY-ID(L-ROW)
         INITIALIZE WS-O(L-ROW)
         MOVE PL-ENTITY-ID(L-ROW) TO WS-O-OWNER(L-ROW)
     END-IF
     MOVE PL-X(L-ROW) TO WS-T(1)
     MOVE PL-Y(L-ROW) TO WS-T(2)
     MOVE PL-Z(L-ROW) TO WS-T(3)
*>   no earlier position, another dimension or a move of more than 16 blocks (a teleport): only the cells of the current box
     MOVE WS-O-X(L-ROW) TO WS-C(1)
     MOVE WS-O-Y(L-ROW) TO WS-C(2)
     MOVE WS-O-Z(L-ROW) TO WS-C(3)
     COMPUTE WS-DX = WS-T(1) - WS-C(1)
     COMPUTE WS-DY = WS-T(2) - WS-C(2)
     COMPUTE WS-DZ = WS-T(3) - WS-C(3)
     COMPUTE WS-LEN = FUNCTION ABS(WS-DX) + FUNCTION ABS(WS-DY) + FUNCTION ABS(WS-DZ)
     IF WS-O-HAS(L-ROW) = 0 OR WS-O-DIM(L-ROW) NOT = PL-DIM(L-ROW) OR WS-LEN > 16
         MOVE WS-T(1) TO WS-C(1)
         MOVE WS-T(2) TO WS-C(2)
         MOVE WS-T(3) TO WS-C(3)
         MOVE 0 TO WS-DX WS-DY WS-DZ
     END-IF
*>   Direction.axisStepOrder: y first, then z before x when |dx| < |dz|, else x before z
     MOVE 2 TO WS-AX(1)
     IF FUNCTION ABS(WS-DX) < FUNCTION ABS(WS-DZ)
         MOVE 3 TO WS-AX(2)
         MOVE 1 TO WS-AX(3)
     ELSE
         MOVE 1 TO WS-AX(2)
         MOVE 3 TO WS-AX(3)
     END-IF
     PERFORM VARYING WS-LEG FROM 1 BY 1 UNTIL WS-LEG > 3
         MOVE WS-C(1) TO WS-N(1)
         MOVE WS-C(2) TO WS-N(2)
         MOVE WS-C(3) TO WS-N(3)
         MOVE WS-T(WS-AX(WS-LEG)) TO WS-N(WS-AX(WS-LEG))
         PERFORM SCAN-LEG
         MOVE WS-N(1) TO WS-C(1)
         MOVE WS-N(2) TO WS-C(2)
         MOVE WS-N(3) TO WS-C(3)
     END-PERFORM
     MOVE 1 TO WS-O-HAS(L-ROW)
     MOVE PL-DIM(L-ROW) TO WS-O-DIM(L-ROW)
     MOVE WS-T(1) TO WS-O-X(L-ROW)
     MOVE WS-T(2) TO WS-O-Y(L-ROW)
     MOVE WS-T(3) TO WS-O-Z(L-ROW)
     GOBACK.

*> The cells the box (0.6 x 1.8, shrunk by 1e-5) touches along the straight leg WS-C to WS-N: the first portal block is the answer.
 SCAN-LEG.
     COMPUTE WS-F = FUNCTION MIN(WS-C(1), WS-N(1)) - 0.3 + WS-EPS
     COMPUTE WS-MIN-X = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = FUNCTION MAX(WS-C(1), WS-N(1)) + 0.3 - WS-EPS
     COMPUTE WS-MAX-X = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = FUNCTION MIN(WS-C(2), WS-N(2)) + WS-EPS
     COMPUTE WS-MIN-Y = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = FUNCTION MAX(WS-C(2), WS-N(2)) + 1.8 - WS-EPS
     COMPUTE WS-MAX-Y = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = FUNCTION MIN(WS-C(3), WS-N(3)) - 0.3 + WS-EPS
     COMPUTE WS-MIN-Z = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = FUNCTION MAX(WS-C(3), WS-N(3)) + 0.3 - WS-EPS
     COMPUTE WS-MAX-Z = FUNCTION INTEGER(WS-F)
     PERFORM VARYING WS-X FROM WS-MIN-X BY 1 UNTIL WS-X > WS-MAX-X
         PERFORM VARYING WS-Y FROM WS-MIN-Y BY 1 UNTIL WS-Y > WS-MAX-Y
             PERFORM VARYING WS-Z FROM WS-MIN-Z BY 1 UNTIL WS-Z > WS-MAX-Z
                 CALL "PORTAL-CELL-KIND" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-KIND
                 IF WS-KIND = 2 AND L-FOUND = 0
                     MOVE 1 TO L-FOUND
                     MOVE WS-X TO L-X
                     MOVE WS-Y TO L-Y
                     MOVE WS-Z TO L-Z
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 END PROGRAM PORTAL-SWEEP.
