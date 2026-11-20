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
 PROGRAM-ID. PORTAL-BYTE.
*> USING value (FLOAT-LONG), byte out (BINARY-LONG): the value clamped to 0..1 and rounded to the nearest of 255 steps.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V                    FLOAT-LONG.
 01 L-I                    BINARY-LONG.
 PROCEDURE DIVISION USING L-V L-I.
     EVALUATE TRUE
         WHEN L-V <= 0
             MOVE 0 TO L-I
         WHEN L-V >= 1
             MOVE 255 TO L-I
         WHEN OTHER
             COMPUTE L-I = FUNCTION INTEGER(L-V * 255 + 0.5)
     END-EVALUATE
     GOBACK.
 END PROGRAM PORTAL-BYTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-RGB8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-R8                   BINARY-LONG.
 01 L-G8                   BINARY-LONG.
 01 L-B8                   BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-G L-B L-R8 L-G8 L-B8.
     CALL "PORTAL-BYTE" USING L-R L-R8
     CALL "PORTAL-BYTE" USING L-G L-G8
     CALL "PORTAL-BYTE" USING L-B L-B8
     GOBACK.
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-TEXELS-LOAD.
*> USING CLIENT-STATE: EP-SKY (end_sky.png, 128 x 128 in the jar), EP-PTX (end_portal.png, 256 x 256) and EP-BEAM (end_gateway_beam.png, 16 x 16) from the top-most
*> pack that has each (8.8); the sky and the portal image are held up to 256 x 256, the beam image up to 64 x 64. EP-TEX 1 when the sky and the portal image were
*> read, 2 when one is missing (PORTAL-COLOUR then gives the flat colour of 8.11); a missing beam image leaves EP-BEAM-W 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SKY-PATH            PIC X(256) VALUE "assets/minecraft/textures/environment/end_sky.png".
 01 WS-PTX-PATH            PIC X(256) VALUE "assets/minecraft/textures/entity/end_portal/end_portal.png".
 01 WS-BEAM-PATH           PIC X(256) VALUE "assets/minecraft/textures/entity/end_portal/end_gateway_beam.png".
 01 WS-SKY-LENGTH          BINARY-LONG VALUE 49.
 01 WS-PTX-LENGTH          BINARY-LONG VALUE 58.
 01 WS-BEAM-LENGTH         BINARY-LONG VALUE 64.
 01 WS-CAP                 BINARY-LONG VALUE 262144.
 01 WS-BEAM-CAP            BINARY-LONG VALUE 16384.
 01 WS-FOUND-SKY           BINARY-LONG.
 01 WS-FOUND-PTX           BINARY-LONG.
 01 WS-FOUND-BEAM          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO EP-SKY-W EP-SKY-H EP-PTX-W EP-PTX-H EP-BEAM-W EP-BEAM-H
     CALL "PACK-IMAGE" USING CLIENT-STATE WS-SKY-PATH WS-SKY-LENGTH EP-SKY WS-CAP EP-SKY-W EP-SKY-H WS-FOUND-SKY
     CALL "PACK-IMAGE" USING CLIENT-STATE WS-PTX-PATH WS-PTX-LENGTH EP-PTX WS-CAP EP-PTX-W EP-PTX-H WS-FOUND-PTX
     CALL "PACK-IMAGE" USING CLIENT-STATE WS-BEAM-PATH WS-BEAM-LENGTH EP-BEAM WS-BEAM-CAP EP-BEAM-W EP-BEAM-H WS-FOUND-BEAM
     MOVE 2 TO EP-TEX
     IF WS-FOUND-SKY = 1 AND WS-FOUND-PTX = 1 AND EP-SKY-W > 0 AND EP-SKY-H > 0 AND EP-PTX-W > 0 AND EP-PTX-H > 0
         MOVE 1 TO EP-TEX
     END-IF
     GOBACK.
 END PROGRAM PORTAL-TEXELS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-COLOUR.
*> USING CLIENT-STATE, layers (15 portal, 16 gateway), u0, v0 (the screen position 0..1 of the pixel), GameTime, r, g, b out: 8.7.4,
*> colour = T0(uv0) * COLORS[0] + the sum over the layers of T1(UV(L)) * COLORS[L - 1], each texel floor(UV * size) mod size (nearest, repeat, 8.8), channel
*> values / 255; the sum is not clamped (PORTAL-RGB8 does). Without the two images (EP-TEX not 1) the flat colour of 8.11: (6, 15, 24) / 255 for the portal,
*> (6, 16, 26) / 255 for the gateway.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-L                   BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-TR                  FLOAT-LONG.
 01 WS-TG                  FLOAT-LONG.
 01 WS-TB                  FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-SAMPLE              FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LAYERS               BINARY-LONG.
 01 L-U0                   FLOAT-LONG.
 01 L-V0                   FLOAT-LONG.
 01 L-GT                   FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LAYERS L-U0 L-V0 L-GT L-R L-G L-B.
     IF EP-TEX NOT = 1
         COMPUTE L-R = 6 / 255
         COMPUTE L-G = 15 / 255
         COMPUTE L-B = 24 / 255
         IF L-LAYERS > 15
             COMPUTE L-G = 16 / 255
             COMPUTE L-B = 26 / 255
         END-IF
         GOBACK
     END-IF
*>   The sky term: the unrotated screen position, once, with the tint of layer 1.
     MOVE 1 TO WS-L
     CALL "PORTAL-TINT" USING WS-L WS-TR WS-TG WS-TB
     COMPUTE WS-X = FUNCTION MOD(FUNCTION INTEGER(L-U0 * EP-SKY-W), EP-SKY-W)
     COMPUTE WS-Y = FUNCTION MOD(FUNCTION INTEGER(L-V0 * EP-SKY-H), EP-SKY-H)
     COMPUTE WS-AT = (WS-Y * EP-SKY-W + WS-X) * 4 + 1
     COMPUTE WS-BYTE = FUNCTION ORD(EP-SKY(WS-AT:1)) - 1
     COMPUTE L-R = WS-BYTE / 255 * WS-TR
     COMPUTE WS-BYTE = FUNCTION ORD(EP-SKY(WS-AT + 1:1)) - 1
     COMPUTE L-G = WS-BYTE / 255 * WS-TG
     COMPUTE WS-BYTE = FUNCTION ORD(EP-SKY(WS-AT + 2:1)) - 1
     COMPUTE L-B = WS-BYTE / 255 * WS-TB
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > L-LAYERS
         CALL "PORTAL-LAYER-UV" USING WS-L L-U0 L-V0 L-GT WS-U WS-V
         CALL "PORTAL-TINT" USING WS-L WS-TR WS-TG WS-TB
         COMPUTE WS-X = FUNCTION MOD(FUNCTION INTEGER(WS-U * EP-PTX-W), EP-PTX-W)
         COMPUTE WS-Y = FUNCTION MOD(FUNCTION INTEGER(WS-V * EP-PTX-H), EP-PTX-H)
         COMPUTE WS-AT = (WS-Y * EP-PTX-W + WS-X) * 4 + 1
         COMPUTE WS-BYTE = FUNCTION ORD(EP-PTX(WS-AT:1)) - 1
         COMPUTE L-R = L-R + WS-BYTE / 255 * WS-TR
         COMPUTE WS-BYTE = FUNCTION ORD(EP-PTX(WS-AT + 1:1)) - 1
         COMPUTE L-G = L-G + WS-BYTE / 255 * WS-TG
         COMPUTE WS-BYTE = FUNCTION ORD(EP-PTX(WS-AT + 2:1)) - 1
         COMPUTE L-B = L-B + WS-BYTE / 255 * WS-TB
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-COLOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BEAM-PARAMS.
*> USING age (BINARY-DOUBLE), teleport cooldown, partial tick (FLOAT-LONG), the dimension's highest block y, height out, r, g, b out (the beam colour 0..1), mode out:
*> 8.9 "per frame": while the gateway is spawning (age < 200) the spawn percent (age + partial) / 200 and the dimension's top y, mode 1, magenta 0xC74EBD; else while it
*> cools down (cooldown above 0) 1 - (cooldown - partial) / 40 and 50, mode 2, purple 0x8932B8; else no beam (height 0, mode 0). height = floor(sin(percent x pi) x top y).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PERCENT             FLOAT-LONG.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-DOUBLE.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-MAX-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-COOLDOWN L-PARTIAL L-MAX-Y L-HEIGHT L-R L-G L-B L-MODE.
     MOVE 0 TO L-HEIGHT L-MODE
     MOVE 0 TO L-R L-G L-B
     EVALUATE TRUE
         WHEN L-AGE < 200
             MOVE 1 TO L-MODE
             COMPUTE WS-PERCENT = FUNCTION MAX(0, FUNCTION MIN(1, (L-AGE + L-PARTIAL) / 200))
             MOVE L-MAX-Y TO WS-TOP
             COMPUTE L-R = 199 / 255
             COMPUTE L-G = 78 / 255
             COMPUTE L-B = 189 / 255
         WHEN L-COOLDOWN > 0
             MOVE 2 TO L-MODE
             COMPUTE WS-PERCENT = 1 - FUNCTION MAX(0, FUNCTION MIN(1, (L-COOLDOWN - L-PARTIAL) / 40))
             MOVE 50 TO WS-TOP
             COMPUTE L-R = 137 / 255
             COMPUTE L-G = 50 / 255
             COMPUTE L-B = 184 / 255
     END-EVALUATE
     IF L-MODE > 0
         COMPUTE L-HEIGHT = FUNCTION INTEGER(FUNCTION SIN(WS-PERCENT * FUNCTION PI) * WS-TOP)
     END-IF
     GOBACK.
 END PROGRAM PORTAL-BEAM-PARAMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-BEAM-MEAN.
*> USING CLIENT-STATE, r, g, b out (0..1): the mean colour of the beam image (end_gateway_beam.png, 16 x 16 and light blue-grey: 8.9). The beam's texture runs three
*> or more repeats a block along its length, far finer than a vertex grid, so the beam is drawn in the mean colour; without the image (148, 183, 180) / 255, the
*> image's texel (0, 0) (8.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SR                  BINARY-LONG.
 01 WS-SG                  BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-R L-G L-B.
     IF EP-BEAM-W = 0 OR EP-BEAM-H = 0
         COMPUTE L-R = 148 / 255
         COMPUTE L-G = 183 / 255
         COMPUTE L-B = 180 / 255
         GOBACK
     END-IF
     COMPUTE WS-N = EP-BEAM-W * EP-BEAM-H
     MOVE 0 TO WS-SR WS-SG WS-SB
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         COMPUTE WS-AT = WS-I * 4 + 1
         COMPUTE WS-SR = WS-SR + FUNCTION ORD(EP-BEAM(WS-AT:1)) - 1
         COMPUTE WS-SG = WS-SG + FUNCTION ORD(EP-BEAM(WS-AT + 1:1)) - 1
         COMPUTE WS-SB = WS-SB + FUNCTION ORD(EP-BEAM(WS-AT + 2:1)) - 1
     END-PERFORM
     COMPUTE L-R = WS-SR / WS-N / 255
     COMPUTE L-G = WS-SG / WS-N / 255
     COMPUTE L-B = WS-SB / WS-N / 255
     GOBACK.
 END PROGRAM PORTAL-BEAM-MEAN.
