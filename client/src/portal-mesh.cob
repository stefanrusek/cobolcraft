*> The end portal and end gateway faces of a frame (docs/protocol/52 section 8.3 to 8.7; lane portalrender T54030). PORTAL-MESH walks the block entities of type 14
*> and 22 (EP-ENTRY, portal-be.cob) and, for each one closer than its draw distance (64 and 256 blocks, 8.3), makes the faces of 8.5 that face the eye (8.6: back
*> faces are culled, here on the CPU, because the opaque pipeline does not cull): the portal's UP and DOWN faces of the slab y 0.375 to 0.75, the gateway's six faces
*> except those against a full block.
*> The surface is the layered shader of 8.7, which reads the texture at the pixel's screen position. The world pipeline has no such lookup (one texture
*> coordinate per vertex), so each face is cut into a grid (8 x 8 quads near, 4 x 4 at 12 to 40 blocks, 2 x 2 beyond), PORTAL-COLOUR is evaluated at the screen
*> position of every grid vertex and the vertex colours are interpolated: the "per-vertex" approximation of 8.11. The quads are drawn opaque on the white
*> swatch of the UI atlas (brightness 1, no light: 8.6), with the frame's fog (the world shader applies it) and depth write, eye-relative like the entity figures.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG), projection x view (16 FLOAT-LONG, column-major, for eye-relative positions): fills RL-EP-VERTEX and RL-EP-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LAYERS              BINARY-LONG.
 01 WS-INRANGE             BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-REL.
    05 WS-EX               FLOAT-LONG.
    05 WS-EY               FLOAT-LONG.
    05 WS-EZ               FLOAT-LONG.
 01 WS-GT                  FLOAT-LONG.
 01 WS-PARTIAL             FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-PV-TABLE.
    05 L-PV                FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE L-PV-TABLE.
     MOVE 0 TO RL-EP-COUNT
     IF EP-COUNT = 0
         GOBACK
     END-IF
     IF EP-TEX = 0
         CALL "PORTAL-TEXELS-LOAD" USING CLIENT-STATE
     END-IF
*>   GameTime of 8.7.3: the level's game time and the fraction of the tick the frame is in.
     MOVE 0 TO WS-PARTIAL
     IF CL-NEXT-TICK > CL-NOW-MS
         COMPUTE WS-PARTIAL = 1 - (CL-NEXT-TICK - CL-NOW-MS) / 50
         IF WS-PARTIAL < 0
             MOVE 0 TO WS-PARTIAL
         END-IF
     END-IF
     CALL "PORTAL-GAME-TIME" USING PL-GAME-TIME WS-PARTIAL WS-GT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EP-COUNT
         MOVE EP-TYPE(WS-I) TO WS-TYPE
*>       The block's minimum corner minus the eye; the camera minus the block's centre (8.3) is its negative less a half block.
         COMPUTE WS-EX = EP-X(WS-I) - L-EYE(1)
         COMPUTE WS-EY = EP-Y(WS-I) - L-EYE(2)
         COMPUTE WS-EZ = EP-Z(WS-I) - L-EYE(3)
         COMPUTE WS-DX = 0 - WS-EX - 0.5
         COMPUTE WS-DY = 0 - WS-EY - 0.5
         COMPUTE WS-DZ = 0 - WS-EZ - 0.5
         CALL "PORTAL-IN-RANGE" USING WS-TYPE WS-DX WS-DY WS-DZ WS-INRANGE
         IF WS-INRANGE = 1
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             MOVE 2 TO WS-N
             IF WS-D2 < 1600
                 MOVE 4 TO WS-N
             END-IF
             IF WS-D2 < 144
                 MOVE 8 TO WS-N
             END-IF
             MOVE 15 TO WS-LAYERS
             IF WS-TYPE = 22
                 MOVE 16 TO WS-LAYERS
             END-IF
             PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
                 CALL "PORTAL-FACE-MESH" USING CLIENT-STATE WS-I WS-D WS-N WS-LAYERS WS-GT WS-REL L-PV-TABLE
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-CLIP.
*> USING projection x view (16 FLOAT-LONG, column-major), x, y, z (eye-relative), clip out (4 FLOAT-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PV-TABLE.
    05 L-PV                FLOAT-LONG OCCURS 16 TIMES.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-CLIP-TABLE.
    05 L-CLIP              FLOAT-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-PV-TABLE L-X L-Y L-Z L-CLIP-TABLE.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
         COMPUTE L-CLIP(WS-R) = L-PV(WS-R) * L-X + L-PV(4 + WS-R) * L-Y + L-PV(8 + WS-R) * L-Z + L-PV(12 + WS-R)
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-CLIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-IN-VIEW.
*> USING projection x view, corners (4 x 3 FLOAT-LONG, block coordinates), the block's corner minus the eye (3 FLOAT-LONG), result out: 0 when the face is wholly
*> behind the eye or wholly outside one side of the view (its four corners' clip coordinates), else 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-CLIP-TABLE.
    05 WS-CLIP             FLOAT-LONG OCCURS 4 TIMES.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-BEHIND              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PV-TABLE.
    05 L-PV                FLOAT-LONG OCCURS 16 TIMES.
 01 L-CORNERS.
    05 L-CORNER            FLOAT-LONG OCCURS 12 TIMES.
 01 L-REL.
    05 L-EX                FLOAT-LONG.
    05 L-EY                FLOAT-LONG.
    05 L-EZ                FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-PV-TABLE L-CORNERS L-REL L-RESULT.
     MOVE 0 TO WS-LEFT WS-RIGHT WS-TOP WS-BOTTOM WS-BEHIND
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 3
         COMPUTE WS-X = L-EX + L-CORNER(WS-K * 3 + 1)
         COMPUTE WS-Y = L-EY + L-CORNER(WS-K * 3 + 2)
         COMPUTE WS-Z = L-EZ + L-CORNER(WS-K * 3 + 3)
         CALL "PORTAL-CLIP" USING L-PV-TABLE WS-X WS-Y WS-Z WS-CLIP-TABLE
         IF WS-CLIP(1) < 0 - WS-CLIP(4)
             ADD 1 TO WS-LEFT
         END-IF
         IF WS-CLIP(1) > WS-CLIP(4)
             ADD 1 TO WS-RIGHT
         END-IF
         IF WS-CLIP(2) < 0 - WS-CLIP(4)
             ADD 1 TO WS-TOP
         END-IF
         IF WS-CLIP(2) > WS-CLIP(4)
             ADD 1 TO WS-BOTTOM
         END-IF
         IF WS-CLIP(4) <= 0
             ADD 1 TO WS-BEHIND
         END-IF
     END-PERFORM
     MOVE 1 TO L-RESULT
     IF WS-LEFT = 4 OR WS-RIGHT = 4 OR WS-TOP = 4 OR WS-BOTTOM = 4 OR WS-BEHIND = 4
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM PORTAL-IN-VIEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-FACE-MESH.
*> USING CLIENT-STATE, entity row, direction 0..5, grid size N, layers, GameTime, the block's corner minus the eye (3 FLOAT-LONG), projection x view: the face when it is
*> drawn (8.5), faces the eye (8.6) and is in view, as a grid of N x N quads (two triangles each) with a colour per grid vertex: the vertex's position on the
*> screen (8.7.1: uv0 = 0.5 ndc + 0.5; a vertex at or behind the eye takes the nearest depth) through PORTAL-COLOUR. At most CL-MAX-PORTAL-VERTICES a frame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-VIEW                BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-REL-BACK.
    05 WS-BX               FLOAT-LONG.
    05 WS-BY               FLOAT-LONG.
    05 WS-BZ               FLOAT-LONG.
 01 WS-CORNERS.
    05 WS-CORNER           FLOAT-LONG OCCURS 12 TIMES.
 01 WS-GRID.
    05 WS-GRID-VERTEX OCCURS 81 TIMES.
       10 WS-GX            FLOAT-LONG.
       10 WS-GY            FLOAT-LONG.
       10 WS-GZ            FLOAT-LONG.
       10 WS-GR            FLOAT-LONG.
       10 WS-GG            FLOAT-LONG.
       10 WS-GB            FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-W0                  FLOAT-LONG.
 01 WS-W1                  FLOAT-LONG.
 01 WS-W2                  FLOAT-LONG.
 01 WS-W3                  FLOAT-LONG.
 01 WS-CLIP-TABLE.
    05 WS-CLIP             FLOAT-LONG OCCURS 4 TIMES.
 01 WS-W                   FLOAT-LONG.
 01 WS-NDC-X               FLOAT-LONG.
 01 WS-NDC-Y               FLOAT-LONG.
 01 WS-U0                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-TRI                 PIC X(6) VALUE "123134".
 01 WS-TU                  FLOAT-SHORT.
 01 WS-TV                  FLOAT-SHORT.
 01 WS-NEG-EX              FLOAT-LONG.
 01 WS-NEG-EY              FLOAT-LONG.
 01 WS-NEG-EZ              FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-LAYERS               BINARY-LONG.
 01 L-GT                   FLOAT-LONG.
 01 L-REL.
    05 L-EX                FLOAT-LONG.
    05 L-EY                FLOAT-LONG.
    05 L-EZ                FLOAT-LONG.
 01 L-PV-TABLE.
    05 L-PV                FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-D L-N L-LAYERS L-GT L-REL L-PV-TABLE.
     MOVE EP-TYPE(L-ROW) TO WS-TYPE
     MOVE 0 TO WS-FULL
     IF WS-TYPE = 22
         MOVE EP-X(L-ROW) TO WS-NX
         MOVE EP-Y(L-ROW) TO WS-NY
         MOVE EP-Z(L-ROW) TO WS-NZ
         EVALUATE L-D
             WHEN 0
                 SUBTRACT 1 FROM WS-NY
             WHEN 1
                 ADD 1 TO WS-NY
             WHEN 2
                 SUBTRACT 1 FROM WS-NZ
             WHEN 3
                 ADD 1 TO WS-NZ
             WHEN 4
                 SUBTRACT 1 FROM WS-NX
             WHEN OTHER
                 ADD 1 TO WS-NX
         END-EVALUATE
         CALL "WORLD-CELL" USING CLIENT-STATE WS-NX WS-NY WS-NZ WS-STATE WS-SKY WS-BLK
         IF WS-STATE >= 0 AND WS-STATE < ST-COUNT
             MOVE ST-OPAQUE(WS-STATE + 1) TO WS-FULL
         END-IF
     END-IF
     CALL "PORTAL-FACE-DRAWN" USING WS-TYPE L-D WS-FULL WS-DRAWN
     COMPUTE WS-NEG-EX = 0 - L-EX
     COMPUTE WS-NEG-EY = 0 - L-EY
     COMPUTE WS-NEG-EZ = 0 - L-EZ
     CALL "PORTAL-FACE-SEEN" USING WS-TYPE L-D WS-NEG-EX WS-NEG-EY WS-NEG-EZ WS-SEEN
     CALL "PORTAL-FACE-QUAD" USING WS-TYPE L-D WS-CORNERS
     MOVE L-REL TO WS-REL-BACK
     CALL "PORTAL-IN-VIEW" USING L-PV-TABLE WS-CORNERS WS-REL-BACK WS-VIEW
     IF WS-DRAWN = 0 OR WS-SEEN = 0 OR WS-VIEW = 0 OR RL-EP-COUNT + 6 * L-N * L-N > CL-MAX-PORTAL-VERTICES
         GOBACK
     END-IF
     COMPUTE WS-TU = 4 / UA-W
     COMPUTE WS-TV = (UA-H - 4) / UA-H
*>   The grid's vertices: bilinear over corners 0 to 3 (s from 0 to 1, t from 0 to 3).
     PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > L-N
         PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > L-N
             COMPUTE WS-S = WS-A / L-N
             COMPUTE WS-T = WS-B / L-N
             COMPUTE WS-W0 = (1 - WS-S) * (1 - WS-T)
             COMPUTE WS-W1 = WS-S * (1 - WS-T)
             COMPUTE WS-W2 = WS-S * WS-T
             COMPUTE WS-W3 = (1 - WS-S) * WS-T
             COMPUTE WS-IDX = WS-B * (L-N + 1) + WS-A + 1
             COMPUTE WS-GX(WS-IDX) = L-EX + WS-W0 * WS-CORNER(1) + WS-W1 * WS-CORNER(4) + WS-W2 * WS-CORNER(7) + WS-W3 * WS-CORNER(10)
             COMPUTE WS-GY(WS-IDX) = L-EY + WS-W0 * WS-CORNER(2) + WS-W1 * WS-CORNER(5) + WS-W2 * WS-CORNER(8) + WS-W3 * WS-CORNER(11)
             COMPUTE WS-GZ(WS-IDX) = L-EZ + WS-W0 * WS-CORNER(3) + WS-W1 * WS-CORNER(6) + WS-W2 * WS-CORNER(9) + WS-W3 * WS-CORNER(12)
             CALL "PORTAL-CLIP" USING L-PV-TABLE WS-GX(WS-IDX) WS-GY(WS-IDX) WS-GZ(WS-IDX) WS-CLIP-TABLE
             MOVE WS-CLIP(4) TO WS-W
             IF WS-W < 0.05
                 MOVE 0.05 TO WS-W
             END-IF
             COMPUTE WS-NDC-X = FUNCTION MAX(-3, FUNCTION MIN(3, WS-CLIP(1) / WS-W))
             COMPUTE WS-NDC-Y = FUNCTION MAX(-3, FUNCTION MIN(3, WS-CLIP(2) / WS-W))
             COMPUTE WS-U0 = 0.5 * WS-NDC-X + 0.5
             COMPUTE WS-V0 = 0.5 * WS-NDC-Y + 0.5
             CALL "PORTAL-COLOUR" USING CLIENT-STATE L-LAYERS WS-U0 WS-V0 L-GT WS-R WS-G WS-BLUE
             COMPUTE WS-GR(WS-IDX) = FUNCTION MAX(0, FUNCTION MIN(1, WS-R))
             COMPUTE WS-GG(WS-IDX) = FUNCTION MAX(0, FUNCTION MIN(1, WS-G))
             COMPUTE WS-GB(WS-IDX) = FUNCTION MAX(0, FUNCTION MIN(1, WS-BLUE))
         END-PERFORM
     END-PERFORM
*>   Two triangles for every quad of the grid (corner order 1 2 3, 1 3 4).
     PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B >= L-N
         PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A >= L-N
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 MOVE FUNCTION NUMVAL(WS-TRI(WS-K:1)) TO WS-C
                 COMPUTE WS-IDX = WS-B * (L-N + 1) + WS-A + 1
                 EVALUATE WS-C
                     WHEN 2
                         ADD 1 TO WS-IDX
                     WHEN 3
                         COMPUTE WS-IDX = WS-IDX + L-N + 2
                     WHEN 4
                         COMPUTE WS-IDX = WS-IDX + L-N + 1
                 END-EVALUATE
                 ADD 1 TO RL-EP-COUNT
                 COMPUTE RL-EP-X(RL-EP-COUNT) = WS-GX(WS-IDX)
                 COMPUTE RL-EP-Y(RL-EP-COUNT) = WS-GY(WS-IDX)
                 COMPUTE RL-EP-Z(RL-EP-COUNT) = WS-GZ(WS-IDX)
                 MOVE WS-TU TO RL-EP-U(RL-EP-COUNT)
                 MOVE WS-TV TO RL-EP-V(RL-EP-COUNT)
                 MOVE 1 TO RL-EP-B(RL-EP-COUNT)
                 MOVE 1 TO RL-EP-A(RL-EP-COUNT)
                 MOVE 0 TO RL-EP-SKY(RL-EP-COUNT)
                 COMPUTE RL-EP-R(RL-EP-COUNT) = WS-GR(WS-IDX)
                 COMPUTE RL-EP-G(RL-EP-COUNT) = WS-GG(WS-IDX)
                 COMPUTE RL-EP-BLUE(RL-EP-COUNT) = WS-GB(WS-IDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-FACE-MESH.
