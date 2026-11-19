*> The end portal and end gateway surface (docs/protocol/52 section 8; lane portalrender T54010 to T54019): the pure rules.
*> The client's world pipeline has no screen-space projective texture lookup (one shader, one atlas coordinate per vertex), so the vanilla layered shader of
*> 8.7 is evaluated on the CPU by PORTAL-COLOUR for a screen position and PORTAL-MESH (portal-mesh.cob) calls it at the vertices of a fine grid over each face
*> (the "per-vertex" approximation 8.11 allows): the colour function itself is exact (worked example 8.7.6), only the interpolation between vertices is not.
*>
*> Entry points:
*>   PORTAL-TINT USING layer 1..16, r, g, b out (FLOAT-LONG)           8.7.2 the 16 tints COLORS[layer - 1]
*>   PORTAL-GAME-TIME USING game time (BINARY-DOUBLE), partial tick (FLOAT-LONG), GameTime out    8.7.3
*>   PORTAL-LAYER-UV USING layer, u0, v0 (screen position 0..1), GameTime, u, v out    8.7.2 the coordinate UV(L) in the end_portal texture
*>   PORTAL-COLOUR USING CLIENT-STATE, layers (15 portal, 16 gateway), u0, v0, GameTime, r, g, b out (the sum of 8.7.4, 0..1 and more)
*>   PORTAL-RGB8 USING r, g, b (FLOAT-LONG), r, g, b out (BINARY-LONG 0..255)       8.7.5 clamp and round to the nearest of 255 steps
*>   PORTAL-TEXELS-LOAD USING CLIENT-STATE                              end_sky and end_portal texels from the pack stack (8.8)
*>   PORTAL-IN-RANGE USING type (14 portal, 22 gateway), dx, dy, dz (camera minus block centre), result out    8.3 point 3
*>   PORTAL-FACE-DRAWN USING type, direction 0..5 (DOWN UP NORTH SOUTH WEST EAST), neighbour face is the full block (1/0), result out    8.5
*>   PORTAL-FACE-QUAD USING type, direction, corners out (4 x 3 FLOAT-LONG, block coordinates)    8.4
*>   PORTAL-FACE-SEEN USING type, direction, ex, ey, ez (eye minus the block's minimum corner), result out    8.6 back faces are culled

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-TINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC 9V9(6) VALUE 0.022087.
    05 FILLER PIC 9V9(6) VALUE 0.098399.
    05 FILLER PIC 9V9(6) VALUE 0.110818.
    05 FILLER PIC 9V9(6) VALUE 0.011892.
    05 FILLER PIC 9V9(6) VALUE 0.095924.
    05 FILLER PIC 9V9(6) VALUE 0.089485.
    05 FILLER PIC 9V9(6) VALUE 0.027636.
    05 FILLER PIC 9V9(6) VALUE 0.101689.
    05 FILLER PIC 9V9(6) VALUE 0.100326.
    05 FILLER PIC 9V9(6) VALUE 0.046564.
    05 FILLER PIC 9V9(6) VALUE 0.109883.
    05 FILLER PIC 9V9(6) VALUE 0.114838.
    05 FILLER PIC 9V9(6) VALUE 0.064901.
    05 FILLER PIC 9V9(6) VALUE 0.117696.
    05 FILLER PIC 9V9(6) VALUE 0.097189.
    05 FILLER PIC 9V9(6) VALUE 0.063761.
    05 FILLER PIC 9V9(6) VALUE 0.086895.
    05 FILLER PIC 9V9(6) VALUE 0.123646.
    05 FILLER PIC 9V9(6) VALUE 0.084817.
    05 FILLER PIC 9V9(6) VALUE 0.111994.
    05 FILLER PIC 9V9(6) VALUE 0.166380.
    05 FILLER PIC 9V9(6) VALUE 0.097489.
    05 FILLER PIC 9V9(6) VALUE 0.154120.
    05 FILLER PIC 9V9(6) VALUE 0.091064.
    05 FILLER PIC 9V9(6) VALUE 0.106152.
    05 FILLER PIC 9V9(6) VALUE 0.131144.
    05 FILLER PIC 9V9(6) VALUE 0.195191.
    05 FILLER PIC 9V9(6) VALUE 0.097721.
    05 FILLER PIC 9V9(6) VALUE 0.110188.
    05 FILLER PIC 9V9(6) VALUE 0.187229.
    05 FILLER PIC 9V9(6) VALUE 0.133516.
    05 FILLER PIC 9V9(6) VALUE 0.138278.
    05 FILLER PIC 9V9(6) VALUE 0.148582.
    05 FILLER PIC 9V9(6) VALUE 0.070006.
    05 FILLER PIC 9V9(6) VALUE 0.243332.
    05 FILLER PIC 9V9(6) VALUE 0.235792.
    05 FILLER PIC 9V9(6) VALUE 0.196766.
    05 FILLER PIC 9V9(6) VALUE 0.142899.
    05 FILLER PIC 9V9(6) VALUE 0.214696.
    05 FILLER PIC 9V9(6) VALUE 0.047281.
    05 FILLER PIC 9V9(6) VALUE 0.315338.
    05 FILLER PIC 9V9(6) VALUE 0.321970.
    05 FILLER PIC 9V9(6) VALUE 0.204675.
    05 FILLER PIC 9V9(6) VALUE 0.390010.
    05 FILLER PIC 9V9(6) VALUE 0.302066.
    05 FILLER PIC 9V9(6) VALUE 0.080955.
    05 FILLER PIC 9V9(6) VALUE 0.314821.
    05 FILLER PIC 9V9(6) VALUE 0.661491.
 01 FILLER REDEFINES WS-TABLE.
    05 WS-ENTRY            PIC 9V9(6) OCCURS 48 TIMES.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-LAYER                BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-LAYER L-R L-G L-B.
     COMPUTE WS-AT = (L-LAYER - 1) * 3
     MOVE WS-ENTRY(WS-AT + 1) TO L-R
     MOVE WS-ENTRY(WS-AT + 2) TO L-G
     MOVE WS-ENTRY(WS-AT + 3) TO L-B
     GOBACK.
 END PROGRAM PORTAL-TINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-GAME-TIME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DAY                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-GAME                 BINARY-DOUBLE.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-GAME L-PARTIAL L-OUT.
     COMPUTE WS-DAY = FUNCTION MOD(L-GAME, 24000)
     COMPUTE L-OUT = (WS-DAY + L-PARTIAL) / 24000
     GOBACK.
 END PROGRAM PORTAL-GAME-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-LAYER-UV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INIT                BINARY-LONG VALUE 0.
 01 WS-TRIG.
    05 WS-ROT OCCURS 16 TIMES.
       10 WS-COS           FLOAT-LONG.
       10 WS-SIN           FLOAT-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-DEG                 BINARY-LONG.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LAYER                BINARY-LONG.
 01 L-U0                   FLOAT-LONG.
 01 L-V0                   FLOAT-LONG.
 01 L-GT                   FLOAT-LONG.
 01 L-U                    FLOAT-LONG.
 01 L-V                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-LAYER L-U0 L-V0 L-GT L-U L-V.
*>   theta(L) = 8642 L^2 + 18 L degrees, reduced modulo 360 exactly (8.7.2, Open question 16); the rotations are made once.
     IF WS-INIT = 0
         MOVE 1 TO WS-INIT
         PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 16
             COMPUTE WS-DEG = FUNCTION MOD(8642 * WS-L * WS-L + 18 * WS-L, 360)
             COMPUTE WS-RAD = WS-DEG * FUNCTION PI / 180
             COMPUTE WS-COS(WS-L) = FUNCTION COS(WS-RAD)
             COMPUTE WS-SIN(WS-L) = FUNCTION SIN(WS-RAD)
         END-PERFORM
     END-IF
     COMPUTE WS-SCALE = 4.5 - L-LAYER / 4
     COMPUTE WS-RX = L-U0 * WS-COS(L-LAYER) - L-V0 * WS-SIN(L-LAYER)
     COMPUTE WS-RY = L-U0 * WS-SIN(L-LAYER) + L-V0 * WS-COS(L-LAYER)
     COMPUTE L-U = WS-SCALE * WS-RX + 8.5 / L-LAYER + 0.25
     COMPUTE L-V = WS-SCALE * WS-RY + 0.5 * (3 + L-LAYER) * L-GT + 0.25
     GOBACK.
 END PROGRAM PORTAL-LAYER-UV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-RGB8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-R8                   BINARY-LONG.
 01 L-G8                   BINARY-LONG.
 01 L-B8                   BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-G L-B L-R8 L-G8 L-B8.
     MOVE L-R TO WS-V
     PERFORM CLAMP-ROUND
     MOVE WS-I TO L-R8
     MOVE L-G TO WS-V
     PERFORM CLAMP-ROUND
     MOVE WS-I TO L-G8
     MOVE L-B TO WS-V
     PERFORM CLAMP-ROUND
     MOVE WS-I TO L-B8
     GOBACK.

 CLAMP-ROUND.
     EVALUATE TRUE
         WHEN WS-V <= 0
             MOVE 0 TO WS-I
         WHEN WS-V >= 1
             MOVE 255 TO WS-I
         WHEN OTHER
             COMPUTE WS-I = FUNCTION INTEGER(WS-V * 255 + 0.5)
     END-EVALUATE.
 END PROGRAM PORTAL-RGB8.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-IN-RANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-DX L-DY L-DZ L-RESULT.
     MOVE 64 TO WS-LIMIT
     IF L-TYPE = 22
         MOVE 256 TO WS-LIMIT
     END-IF
     COMPUTE WS-D2 = L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ
     MOVE 0 TO L-RESULT
     IF WS-D2 < WS-LIMIT * WS-LIMIT
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM PORTAL-IN-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FACE-DRAWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-DIRECTION L-FULL L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-TYPE = 14
*>       The portal: the Y axis only, whatever the neighbour (8.5).
         IF L-DIRECTION < 2
             MOVE 1 TO L-RESULT
         END-IF
     ELSE
*>       The gateway: Block.shouldRenderFace; its own occlusion shape is empty, so only a neighbour whose face is the full block hides the face.
         IF L-FULL = 0
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PORTAL-FACE-DRAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FACE-QUAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
*> The unit cube's corners of each face in the order of 8.4 (FaceInfo), x y z each 0 or 1: DOWN, UP, NORTH, SOUTH, WEST, EAST.
 01 WS-CORNERS.
    05 FILLER PIC X(12) VALUE "001000100101".
    05 FILLER PIC X(12) VALUE "010011111110".
    05 FILLER PIC X(12) VALUE "110100000010".
    05 FILLER PIC X(12) VALUE "011001101111".
    05 FILLER PIC X(12) VALUE "010000001011".
    05 FILLER PIC X(12) VALUE "111101100110".
 01 FILLER REDEFINES WS-CORNERS.
    05 WS-FACE OCCURS 6 TIMES.
       10 WS-DIGIT         PIC 9 OCCURS 12 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-OUT.
    05 L-CORNER            FLOAT-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-TYPE L-DIRECTION L-OUT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-DIGIT(L-DIRECTION + 1, WS-I) TO L-CORNER(WS-I)
*>       The portal's transformation (8.4): translation (0, 0.375, 0), scale (1, 0.375, 1).
         IF L-TYPE = 14 AND FUNCTION MOD(WS-I, 3) = 2
             COMPUTE L-CORNER(WS-I) = 0.375 + 0.375 * L-CORNER(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-FACE-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FACE-SEEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PLANE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-EX                   FLOAT-LONG.
 01 L-EY                   FLOAT-LONG.
 01 L-EZ                   FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-DIRECTION L-EX L-EY L-EZ L-RESULT.
*>   A face is seen from the side its outward normal points to (counter-clockwise from outside, back faces culled).
     MOVE 0 TO L-RESULT
     EVALUATE L-DIRECTION
         WHEN 0
             MOVE 0 TO WS-PLANE
             IF L-TYPE = 14
                 MOVE 0.375 TO WS-PLANE
             END-IF
             IF L-EY < WS-PLANE
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 1
             MOVE 1 TO WS-PLANE
             IF L-TYPE = 14
                 MOVE 0.75 TO WS-PLANE
             END-IF
             IF L-EY > WS-PLANE
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 2
             IF L-EZ < 0
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 3
             IF L-EZ > 1
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 4
             IF L-EX < 0
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN OTHER
             IF L-EX > 1
                 MOVE 1 TO L-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PORTAL-FACE-SEEN.
