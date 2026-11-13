*> The render list (data-model §13; research R4; shim-abi.md §9): RENDER-LIST-BUILD writes the
*> frame's clear colour (the sky), projection and view matrices, the draws and the uploads. The
*> world is drawn on the world screen and behind the pause menu: the camera is the local player's
*> eye (1.6 above the feet, standin-content §3) turned by yaw (0 faces +Z, 90 faces -X) and pitch
*> (positive looks down); the projection is a 70 degree vertical perspective into Vulkan clip space
*> (y down, depth 0 to 1, near 0.05, far 512). Each section mesh is drawn with projection x view x
*> its offset from the eye (camera-relative, so float positions stay small): every opaque mesh,
*> then the entity figures (texture 1, built eye-relative by ENTITIES-MESH), then the translucent
*> meshes back to front by section centre, then the ground items (item-icon billboards built
*> eye-relative by GROUND-ITEMS-MESH, translucent on texture 0), then the weather quads (built
*> eye-relative by WEATHER-MESH, translucent on texture 3), then the particle quads (built eye-relative by
*> PARTICLES-MESH, translucent on texture 4), then the target highlight (an
*> outline around the targeted block, eye-relative, translucent on texture 2), then the UI mesh
*> (texture 2) with an orthographic window-pixel matrix, the item icons over it (texture 0) and the
*> UI drawn over the icons (the slot counts, texture 2), with the same matrix. Meshes changed since
*> the last frame, the entity, ground-item, weather, highlight, icon and UI meshes are listed as uploads (the frame-built ones while they
*> have vertices, and once more when they no longer have, which frees them); the slots of a
*> forgotten chunk's row are listed once with no vertices, which frees them (shim-abi §9).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RENDER-LIST-BUILD.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLTINT.
 COPY CCSHIM.
 01 WS-ATTRIBUTE           PIC X(64).
 01 WS-FOG                 BINARY-DOUBLE.
 01 WS-FOG-Q               BINARY-DOUBLE.
 01 WS-FOG-END             BINARY-LONG.
 01 WS-FOG-SPAN            FLOAT-LONG.
 01 WS-FOG-MUL             FLOAT-LONG VALUE 1.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PIPE                BINARY-LONG.
 01 WS-TEX                 BINARY-LONG.
 01 WS-WORLD               BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-ASPECT              FLOAT-LONG.
 01 WS-NEAR                FLOAT-LONG VALUE 0.05.
 01 WS-FAR                 FLOAT-LONG VALUE 512.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-FWD                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-RIGHT               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-UP                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PV-TABLE.
    05 WS-PV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-TANX                FLOAT-LONG.
 01 WS-TANY                FLOAT-LONG.
 01 WS-NORM                FLOAT-LONG.
 01 WS-PLANE-TABLE.
    05 WS-PLANE            FLOAT-LONG OCCURS 12 TIMES.
 01 WS-VIS                 BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-P3                  BINARY-LONG.
 01 WS-HALF-H              FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-TCOUNT              BINARY-LONG.
 01 WS-TSLOT               BINARY-LONG OCCURS 4096 TIMES.
 01 WS-TROW                BINARY-LONG OCCURS 4096 TIMES.
 01 WS-TSEC                BINARY-LONG OCCURS 4096 TIMES.
 01 WS-TDIST               FLOAT-LONG OCCURS 4096 TIMES.
 01 WS-HAND-PROJ-TABLE.
    05 WS-HAND-PROJ        FLOAT-LONG OCCURS 16 TIMES.
 01 WS-VIEW-YAW            FLOAT-LONG.
 01 WS-VIEW-PITCH          FLOAT-LONG.
 01 WS-SWAP-SLOT           BINARY-LONG.
 01 WS-SWAP-ROW            BINARY-LONG.
 01 WS-SWAP-SEC            BINARY-LONG.
 01 WS-SWAP-DIST           FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE SK-R TO RL-CLEAR(1)
     MOVE SK-G TO RL-CLEAR(2)
     MOVE SK-B TO RL-CLEAR(3)
     MOVE 1 TO RL-CLEAR(4)
*>   An eye in a fluid clears to its fog colour (12 section 3.3): lava #991900, water the water fog colour (#050533 unless a
*>   biome overrides it).
     EVALUATE TRUE
         WHEN PL-EYE-LAVA = 1
             COMPUTE RL-CLEAR(1) = 153 / 255
             COMPUTE RL-CLEAR(2) = 25 / 255
             MOVE 0 TO RL-CLEAR(3)
         WHEN PL-EYE-WATER = 1
             MOVE "minecraft:visual/water_fog_color" TO WS-ATTRIBUTE
             CALL "TINT-ATTRIBUTE-DEFAULT" USING WS-ATTRIBUTE WS-FOG
*>           The biome under the eye overrides the colour and multiplies the end distance (43 section 5).
             COMPUTE WS-EX = FUNCTION INTEGER(PL-X)
             COMPUTE WS-EY = FUNCTION INTEGER(PL-Y + 1.6)
             COMPUTE WS-EZ = FUNCTION INTEGER(PL-Z)
             CALL "TINT-BIOME-AT" USING CLIENT-STATE WS-EX WS-EY WS-EZ WS-BIOME
             COMPUTE WS-BIOME = WS-BIOME + 1
             IF TB-FOG(WS-BIOME) > 0
                 COMPUTE WS-FOG = FUNCTION MOD(TB-FOG(WS-BIOME), 16777216)
             END-IF
             MOVE 1 TO WS-FOG-MUL
             IF TB-FOG-END(WS-BIOME) > 0
                 MOVE TB-FOG-END(WS-BIOME) TO WS-FOG-MUL
             END-IF
             DIVIDE WS-FOG BY 65536 GIVING WS-FOG-Q
             COMPUTE RL-CLEAR(1) = FUNCTION MOD(WS-FOG-Q, 256) / 255
             DIVIDE WS-FOG BY 256 GIVING WS-FOG-Q
             COMPUTE RL-CLEAR(2) = FUNCTION MOD(WS-FOG-Q, 256) / 255
             COMPUTE RL-CLEAR(3) = FUNCTION MOD(WS-FOG, 256) / 255
     END-EVALUATE
     MOVE 0 TO RL-DRAW-COUNT RL-UPLOAD-COUNT
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-VIEW-YAW WS-VIEW-PITCH WS-EYE-TABLE
*>   Projection (column-major).
     COMPUTE WS-F = 1 / FUNCTION TAN(CL-FOV-DEG / 2 * FUNCTION PI / 180)
     COMPUTE WS-ASPECT = FUNCTION MAX(IN-WIN-W, 1) / FUNCTION MAX(IN-WIN-H, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO RL-PROJ(WS-I) RL-VIEW(WS-I)
     END-PERFORM
     COMPUTE RL-PROJ(1) = WS-F / WS-ASPECT
     COMPUTE RL-PROJ(6) = 0 - WS-F
     COMPUTE RL-PROJ(11) = WS-FAR / (WS-NEAR - WS-FAR)
     MOVE -1 TO RL-PROJ(12)
     COMPUTE RL-PROJ(15) = WS-NEAR * WS-FAR / (WS-NEAR - WS-FAR)
*>   The fog of an eye in a fluid (12 section 3.3 environments; cc_vk_fog): the fog colour is the clear colour set above, strength 1, lava
*>   from 0.25 to 1.0 blocks (no Fire Resistance), water from -8 to 96 (water vision 1); the focal terms of the projection.
     MOVE 0 TO RL-FOG(1) RL-FOG(2) RL-FOG(3) RL-FOG(4)
     MOVE 1000000000 TO RL-FOG(5)
     MOVE 2000000000 TO RL-FOG(6)
*>   The render-distance fog (cylindrical): end = view distance in blocks, start = end - clamp(end / 10, 4, 64); off until the view distance is known.
     MOVE 1000000000 TO RL-FOG(12)
     MOVE 2000000000 TO RL-FOG(13)
     IF PL-VIEW-DISTANCE > 0
         COMPUTE WS-FOG-END = PL-VIEW-DISTANCE * 16
         COMPUTE WS-FOG-SPAN = FUNCTION MAX(4, FUNCTION MIN(64, WS-FOG-END / 10))
         COMPUTE RL-FOG(12) = WS-FOG-END - WS-FOG-SPAN
         MOVE WS-FOG-END TO RL-FOG(13)
         MOVE RL-CLEAR(1) TO RL-FOG(1)
         MOVE RL-CLEAR(2) TO RL-FOG(2)
         MOVE RL-CLEAR(3) TO RL-FOG(3)
         MOVE 1 TO RL-FOG(4)
     END-IF
     MOVE RL-PROJ(1) TO RL-FOG(7)
     MOVE RL-PROJ(6) TO RL-FOG(8)
     IF PL-EYE-LAVA = 1 OR PL-EYE-WATER = 1
         MOVE RL-CLEAR(1) TO RL-FOG(1)
         MOVE RL-CLEAR(2) TO RL-FOG(2)
         MOVE RL-CLEAR(3) TO RL-FOG(3)
         MOVE 1 TO RL-FOG(4)
         MOVE -8 TO RL-FOG(5)
         COMPUTE RL-FOG(6) = 96 * WS-FOG-MUL
         IF PL-EYE-LAVA = 1
             MOVE 0.25 TO RL-FOG(5)
             MOVE 1 TO RL-FOG(6)
         END-IF
     END-IF
*>   View: rows right, up and -forward.
     COMPUTE WS-YAW = WS-VIEW-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = WS-VIEW-PITCH * FUNCTION PI / 180
     COMPUTE WS-FWD(1) = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-FWD(2) = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-FWD(3) = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-RIGHT(1) = 0 - FUNCTION COS(WS-YAW)
     MOVE 0 TO WS-RIGHT(2)
     COMPUTE WS-RIGHT(3) = 0 - FUNCTION SIN(WS-YAW)
     COMPUTE WS-UP(1) = WS-RIGHT(2) * WS-FWD(3) - WS-RIGHT(3) * WS-FWD(2)
     COMPUTE WS-UP(2) = WS-RIGHT(3) * WS-FWD(1) - WS-RIGHT(1) * WS-FWD(3)
     COMPUTE WS-UP(3) = WS-RIGHT(1) * WS-FWD(2) - WS-RIGHT(2) * WS-FWD(1)
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 3
         COMPUTE WS-I = (WS-C - 1) * 4 + 1
         MOVE WS-RIGHT(WS-C) TO RL-VIEW(WS-I)
         MOVE WS-UP(WS-C) TO RL-VIEW(WS-I + 1)
         COMPUTE RL-VIEW(WS-I + 2) = 0 - WS-FWD(WS-C)
     END-PERFORM
     MOVE 1 TO RL-VIEW(16)
     MOVE RL-VIEW(5) TO RL-FOG(9)
     MOVE RL-VIEW(6) TO RL-FOG(10)
     MOVE RL-VIEW(7) TO RL-FOG(11)
*>   Projection x view.
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 3
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 3
             MOVE 0 TO WS-SUM
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 3
                 COMPUTE WS-SUM = WS-SUM
                     + RL-PROJ(WS-K * 4 + WS-R + 1) * RL-VIEW(WS-C * 4 + WS-K + 1)
             END-PERFORM
             MOVE WS-SUM TO WS-PV(WS-C * 4 + WS-R + 1)
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-WORLD
     IF SM-SCREEN = SCR-WORLD OR SM-SCREEN = SCR-PAUSE
         MOVE 1 TO WS-WORLD
     END-IF
*>   The four side planes of the view frustum as unit normals in the world (inside: the normal dotted with the offset from the
*>   eye is not negative): left and right from the horizontal tangent, bottom and top from the vertical one. A chunk column
*>   wholly outside one is not drawn (its sections are still uploaded); this keeps the draws, the matrices and the sort to
*>   the few columns in view.
     COMPUTE WS-TANX = WS-ASPECT / WS-F
     COMPUTE WS-TANY = 1 / WS-F
     COMPUTE WS-NORM = FUNCTION SQRT(1 + WS-TANX * WS-TANX)
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 3
         COMPUTE WS-PLANE(WS-C) = (WS-RIGHT(WS-C) + WS-FWD(WS-C) * WS-TANX) / WS-NORM
         COMPUTE WS-PLANE(WS-C + 3) = (WS-FWD(WS-C) * WS-TANX - WS-RIGHT(WS-C)) / WS-NORM
     END-PERFORM
     COMPUTE WS-NORM = FUNCTION SQRT(1 + WS-TANY * WS-TANY)
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 3
         COMPUTE WS-PLANE(WS-C + 6) = (WS-UP(WS-C) + WS-FWD(WS-C) * WS-TANY) / WS-NORM
         COMPUTE WS-PLANE(WS-C + 9) = (WS-FWD(WS-C) * WS-TANY - WS-UP(WS-C)) / WS-NORM
     END-PERFORM
     COMPUTE WS-HALF-H = PL-HEIGHT / 2 + 1
*>   Uploads of changed meshes; opaque draws; translucent candidates.
     MOVE 0 TO WS-TCOUNT
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
*>       A forgotten chunk: every mesh slot of its row is freed (an upload with no vertices).
         IF WR-RELEASE(WS-R) = 1
                 AND RL-UPLOAD-COUNT <= CL-MAX-UPLOADS - CL-UPLOAD-RESERVE - 32
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 COMPUTE WS-SLOT = MESH-SLOT-BASE + ((WS-R - 1) * CL-MAX-SECTIONS + WS-S - 1) * 2
                 MOVE 0 TO WR-OP-COUNT(WS-R, WS-S) WR-TR-COUNT(WS-R, WS-S)
                     WR-UPLOAD(WS-R, WS-S)
                 ADD 1 TO RL-UPLOAD-COUNT
                 MOVE WS-SLOT TO RL-U-SLOT(RL-UPLOAD-COUNT)
                 SET RL-U-ADDR(RL-UPLOAD-COUNT) TO NULL
                 MOVE 0 TO RL-U-COUNT(RL-UPLOAD-COUNT)
                 ADD 1 TO RL-UPLOAD-COUNT
                 COMPUTE RL-U-SLOT(RL-UPLOAD-COUNT) = WS-SLOT + 1
                 SET RL-U-ADDR(RL-UPLOAD-COUNT) TO NULL
                 MOVE 0 TO RL-U-COUNT(RL-UPLOAD-COUNT)
             END-PERFORM
             MOVE 0 TO WR-RELEASE(WS-R)
         END-IF
*>       Is the column (a box of 18 x height x 18 blocks around the chunk) in view?
         MOVE 1 TO WS-VIS
         IF WS-WORLD = 1 AND WR-USED(WS-R) = 1
             COMPUTE WS-DX = WR-CX(WS-R) * 16 + 8 - WS-EYE(1)
             COMPUTE WS-DY = PL-MIN-Y + WS-HALF-H - 1 - WS-EYE(2)
             COMPUTE WS-DZ = WR-CZ(WS-R) * 16 + 8 - WS-EYE(3)
             PERFORM VARYING WS-P FROM 0 BY 3 UNTIL WS-P > 9 OR WS-VIS = 0
                 COMPUTE WS-P1 = WS-P + 1
                 COMPUTE WS-P2 = WS-P + 2
                 COMPUTE WS-P3 = WS-P + 3
                 MOVE WS-PLANE(WS-P1) TO WS-NX
                 MOVE WS-PLANE(WS-P2) TO WS-NY
                 MOVE WS-PLANE(WS-P3) TO WS-NZ
                 COMPUTE WS-SUM = WS-NX * WS-DX + WS-NY * WS-DY + WS-NZ * WS-DZ
                     + FUNCTION ABS(WS-NX) * 9 + FUNCTION ABS(WS-NY) * WS-HALF-H + FUNCTION ABS(WS-NZ) * 9
                 IF WS-SUM < 0
                     MOVE 0 TO WS-VIS
                 END-IF
             END-PERFORM
         END-IF
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
*>           Most sections of a column (the air above the ground) have no mesh and nothing to upload: they are passed over at once.
           IF WR-UPLOAD(WS-R, WS-S) = 1 OR WR-OP-COUNT(WS-R, WS-S) > 0 OR WR-TR-COUNT(WS-R, WS-S) > 0
             COMPUTE WS-SLOT = MESH-SLOT-BASE + ((WS-R - 1) * CL-MAX-SECTIONS + WS-S - 1) * 2
             IF WR-UPLOAD(WS-R, WS-S) = 1
                     AND RL-UPLOAD-COUNT <= CL-MAX-UPLOADS - CL-UPLOAD-RESERVE - 2
                 ADD 1 TO RL-UPLOAD-COUNT
                 MOVE WS-SLOT TO RL-U-SLOT(RL-UPLOAD-COUNT)
                 SET RL-U-ADDR(RL-UPLOAD-COUNT) TO WR-OP-ADDR(WS-R, WS-S)
                 MOVE WR-OP-COUNT(WS-R, WS-S) TO RL-U-COUNT(RL-UPLOAD-COUNT)
                 ADD 1 TO RL-UPLOAD-COUNT
                 COMPUTE RL-U-SLOT(RL-UPLOAD-COUNT) = WS-SLOT + 1
                 SET RL-U-ADDR(RL-UPLOAD-COUNT) TO WR-TR-ADDR(WS-R, WS-S)
                 MOVE WR-TR-COUNT(WS-R, WS-S) TO RL-U-COUNT(RL-UPLOAD-COUNT)
                 MOVE 0 TO WR-UPLOAD(WS-R, WS-S)
             END-IF
             IF WS-WORLD = 1 AND WR-USED(WS-R) = 1 AND WS-VIS = 1
                 IF WR-OP-COUNT(WS-R, WS-S) > 0
                         AND RL-DRAW-COUNT < CL-MAX-DRAWS - CL-DRAW-RESERVE
                     ADD 1 TO RL-DRAW-COUNT
                     MOVE WS-SLOT TO RL-D-SLOT(RL-DRAW-COUNT)
                     MOVE CC-PIPE-OPAQUE TO RL-D-PIPELINE(RL-DRAW-COUNT)
                     MOVE CC-TEX-BLOCKS TO RL-D-TEX(RL-DRAW-COUNT)
                     CALL "SECTION-MATRIX" USING CLIENT-STATE WS-PV-TABLE WS-EYE-TABLE WS-R WS-S
                 END-IF
                 IF WR-TR-COUNT(WS-R, WS-S) > 0 AND WS-TCOUNT < 4096
                     ADD 1 TO WS-TCOUNT
                     COMPUTE WS-TSLOT(WS-TCOUNT) = WS-SLOT + 1
                     MOVE WS-R TO WS-TROW(WS-TCOUNT)
                     MOVE WS-S TO WS-TSEC(WS-TCOUNT)
                     COMPUTE WS-DX = WR-CX(WS-R) * 16 + 8 - WS-EYE(1)
                     COMPUTE WS-DY = (WS-S - 1) * 16 + 8 + PL-MIN-Y - WS-EYE(2)
                     COMPUTE WS-DZ = WR-CZ(WS-R) * 16 + 8 - WS-EYE(3)
                     COMPUTE WS-TDIST(WS-TCOUNT) = WS-DX ** 2 + WS-DY ** 2 + WS-DZ ** 2
                 END-IF
             END-IF
           END-IF
         END-PERFORM
     END-PERFORM
*>   The entity figures (eye-relative, so drawn with projection x view alone), after the opaque
*>   sections; the slot is uploaded while it has vertices and once more when it no longer has
*>   (freed).
     MOVE 0 TO RL-EN-COUNT
     IF WS-WORLD = 1
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     END-IF
     IF RL-EN-COUNT > 0 OR RL-EN-UPLOADED > 0
         ADD 1 TO RL-UPLOAD-COUNT
         MOVE MESH-SLOT-ENTITIES TO RL-U-SLOT(RL-UPLOAD-COUNT)
         SET RL-U-ADDR(RL-UPLOAD-COUNT) TO ADDRESS OF RL-EN-VERTEX(1)
         MOVE RL-EN-COUNT TO RL-U-COUNT(RL-UPLOAD-COUNT)
         MOVE RL-EN-COUNT TO RL-EN-UPLOADED
     END-IF
     IF RL-EN-COUNT > 0
         ADD 1 TO RL-DRAW-COUNT
         MOVE MESH-SLOT-ENTITIES TO RL-D-SLOT(RL-DRAW-COUNT)
         MOVE CC-PIPE-OPAQUE TO RL-D-PIPELINE(RL-DRAW-COUNT)
         MOVE CC-TEX-ENTITIES TO RL-D-TEX(RL-DRAW-COUNT)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE WS-PV(WS-I) TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
         END-PERFORM
     END-IF
*>   Translucent sections back to front (insertion sort, farthest first).
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > WS-TCOUNT
         MOVE WS-TSLOT(WS-I) TO WS-SWAP-SLOT
         MOVE WS-TROW(WS-I) TO WS-SWAP-ROW
         MOVE WS-TSEC(WS-I) TO WS-SWAP-SEC
         MOVE WS-TDIST(WS-I) TO WS-SWAP-DIST
         COMPUTE WS-J = WS-I - 1
         PERFORM UNTIL WS-J < 1
             IF WS-TDIST(WS-J) >= WS-SWAP-DIST
                 EXIT PERFORM
             END-IF
             MOVE WS-TSLOT(WS-J) TO WS-TSLOT(WS-J + 1)
             MOVE WS-TROW(WS-J) TO WS-TROW(WS-J + 1)
             MOVE WS-TSEC(WS-J) TO WS-TSEC(WS-J + 1)
             MOVE WS-TDIST(WS-J) TO WS-TDIST(WS-J + 1)
             SUBTRACT 1 FROM WS-J
         END-PERFORM
         MOVE WS-SWAP-SLOT TO WS-TSLOT(WS-J + 1)
         MOVE WS-SWAP-ROW TO WS-TROW(WS-J + 1)
         MOVE WS-SWAP-SEC TO WS-TSEC(WS-J + 1)
         MOVE WS-SWAP-DIST TO WS-TDIST(WS-J + 1)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TCOUNT
             OR RL-DRAW-COUNT >= CL-MAX-DRAWS - CL-DRAW-RESERVE
         ADD 1 TO RL-DRAW-COUNT
         MOVE WS-TSLOT(WS-I) TO RL-D-SLOT(RL-DRAW-COUNT)
         MOVE CC-PIPE-TRANSLUCENT TO RL-D-PIPELINE(RL-DRAW-COUNT)
         MOVE CC-TEX-BLOCKS TO RL-D-TEX(RL-DRAW-COUNT)
         MOVE WS-TROW(WS-I) TO WS-R
         MOVE WS-TSEC(WS-I) TO WS-S
         CALL "SECTION-MATRIX" USING CLIENT-STATE WS-PV-TABLE WS-EYE-TABLE WS-R WS-S
     END-PERFORM
*>   The ground items (item-icon billboards, eye-relative, texture 0), after the translucent
*>   sections.
     MOVE 0 TO RL-GI-COUNT
     IF WS-WORLD = 1
         CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     END-IF
     MOVE MESH-SLOT-GROUND-ITEMS TO WS-SLOT
     MOVE CC-PIPE-TRANSLUCENT TO WS-PIPE
     MOVE CC-TEX-BLOCKS TO WS-TEX
     CALL "RENDER-MESH-ADD" USING CLIENT-STATE WS-SLOT RL-GI-VERTEX(1) RL-GI-COUNT RL-GI-UPLOADED
         WS-PIPE WS-TEX WS-PV-TABLE
*>   The weather quads (eye-relative, texture 3), alpha-blended after the opaque geometry.
     MOVE 0 TO RL-WX-COUNT
     IF WS-WORLD = 1
         CALL "WEATHER-MESH" USING CLIENT-STATE WS-EYE-TABLE
     END-IF
     MOVE MESH-SLOT-WEATHER TO WS-SLOT
     MOVE CC-TEX-ENVIRONMENT TO WS-TEX
     CALL "RENDER-MESH-ADD" USING CLIENT-STATE WS-SLOT RL-WX-VERTEX(1) RL-WX-COUNT RL-WX-UPLOADED
         WS-PIPE WS-TEX WS-PV-TABLE
*>   The particle quads (eye-relative, texture 4), alpha-blended after the weather.
     MOVE 0 TO RL-PT-COUNT
     IF WS-WORLD = 1
         CALL "PARTICLES-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-VIEW-YAW WS-VIEW-PITCH
     END-IF
     MOVE MESH-SLOT-PARTICLES TO WS-SLOT
     MOVE CC-TEX-PARTICLES TO WS-TEX
     CALL "RENDER-MESH-ADD" USING CLIENT-STATE WS-SLOT RL-PT-VERTEX(1) RL-PT-COUNT RL-PT-UPLOADED
         WS-PIPE WS-TEX WS-PV-TABLE
*>   The crack overlay (world screen, 12 section 4), after the translucent sections, before the highlight.
     MOVE 0 TO RL-BO-COUNT
     IF WS-WORLD = 1
         CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     END-IF
     MOVE MESH-SLOT-BREAK TO WS-SLOT
     MOVE CC-PIPE-CRUMBLING TO WS-PIPE
     MOVE CC-TEX-BLOCKS TO WS-TEX
     CALL "RENDER-MESH-ADD" USING CLIENT-STATE WS-SLOT RL-BO-VERTEX(1) RL-BO-COUNT RL-BO-UPLOADED
         WS-PIPE WS-TEX WS-PV-TABLE
*>   The target highlight (world screen), after the translucent sections.
     MOVE 0 TO RL-HL-COUNT
     IF SM-SCREEN = SCR-WORLD AND TG-HIT = 1
         CALL "HIGHLIGHT-MESH" USING CLIENT-STATE WS-EYE-TABLE
     END-IF
     MOVE MESH-SLOT-HIGHLIGHT TO WS-SLOT
     MOVE CC-PIPE-TRANSLUCENT TO WS-PIPE
     MOVE CC-TEX-UI TO WS-TEX
     CALL "RENDER-MESH-ADD" USING CLIENT-STATE WS-SLOT RL-HL-VERTEX(1) RL-HL-COUNT RL-HL-UPLOADED
         WS-PIPE WS-TEX WS-PV-TABLE
*>   The UI: uploaded every frame, drawn last with x' = 2x / w - 1, y' = 2y / h - 1.
*>   The hand (first person, world screen): a depth clear, then the held item in view space with the projection alone.
     CALL "HAND-MESH" USING CLIENT-STATE
     IF RL-HAND-COUNT > 0
         ADD 1 TO RL-DRAW-COUNT
         MOVE -1 TO RL-D-SLOT(RL-DRAW-COUNT)
         MOVE CC-PIPE-OPAQUE TO RL-D-PIPELINE(RL-DRAW-COUNT)
         MOVE CC-TEX-BLOCKS TO RL-D-TEX(RL-DRAW-COUNT)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE RL-PROJ(WS-I) TO WS-HAND-PROJ(WS-I)
     END-PERFORM
     MOVE MESH-SLOT-HAND TO WS-SLOT
     MOVE CC-PIPE-OPAQUE TO WS-PIPE
     MOVE CC-TEX-BLOCKS TO WS-TEX
     CALL "RENDER-MESH-ADD" USING CLIENT-STATE WS-SLOT RL-HAND-VERTEX(1) RL-HAND-COUNT RL-HAND-UPLOADED
         WS-PIPE WS-TEX WS-HAND-PROJ-TABLE
     ADD 1 TO RL-UPLOAD-COUNT
     MOVE MESH-SLOT-UI TO RL-U-SLOT(RL-UPLOAD-COUNT)
     SET RL-U-ADDR(RL-UPLOAD-COUNT) TO ADDRESS OF RL-UI-VERTEX(1)
     MOVE RL-UI-COUNT TO RL-U-COUNT(RL-UPLOAD-COUNT)
     ADD 1 TO RL-DRAW-COUNT
     MOVE MESH-SLOT-UI TO RL-D-SLOT(RL-DRAW-COUNT)
     MOVE CC-PIPE-UI TO RL-D-PIPELINE(RL-DRAW-COUNT)
     MOVE CC-TEX-UI TO RL-D-TEX(RL-DRAW-COUNT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
     END-PERFORM
     COMPUTE RL-D-MATRIX(RL-DRAW-COUNT, 1) = 2 / FUNCTION MAX(IN-WIN-W, 1)
     COMPUTE RL-D-MATRIX(RL-DRAW-COUNT, 6) = 2 / FUNCTION MAX(IN-WIN-H, 1)
     MOVE 1 TO RL-D-MATRIX(RL-DRAW-COUNT, 11) RL-D-MATRIX(RL-DRAW-COUNT, 16)
     MOVE -1 TO RL-D-MATRIX(RL-DRAW-COUNT, 13) RL-D-MATRIX(RL-DRAW-COUNT, 14)
*>   The item icons and the UI over them, with the UI's matrix.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE RL-D-MATRIX(RL-DRAW-COUNT, WS-I) TO WS-PV(WS-I)
     END-PERFORM
     MOVE MESH-SLOT-ICONS TO WS-SLOT
     MOVE CC-PIPE-UI TO WS-PIPE
     MOVE CC-TEX-BLOCKS TO WS-TEX
     CALL "RENDER-MESH-ADD" USING CLIENT-STATE WS-SLOT RL-IC-VERTEX(1) RL-IC-COUNT RL-IC-UPLOADED
         WS-PIPE WS-TEX WS-PV-TABLE
     MOVE MESH-SLOT-UI-TOP TO WS-SLOT
     MOVE CC-TEX-UI TO WS-TEX
     CALL "RENDER-MESH-ADD" USING CLIENT-STATE WS-SLOT RL-UT-VERTEX(1) RL-UT-COUNT RL-UT-UPLOADED
         WS-PIPE WS-TEX WS-PV-TABLE
     GOBACK.

 END PROGRAM RENDER-LIST-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SECTION-MATRIX.
*> USING CLIENT-STATE, projection x view (16 FLOAT-LONG), eye (3 FLOAT-LONG), row, section: the
*> last draw's matrix: projection x view x the translation by the section's lowest corner minus
*> the eye.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFF                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PV-TABLE.
    05 L-PV                FLOAT-LONG OCCURS 16 TIMES.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-ROW                  BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PV-TABLE L-EYE-TABLE L-ROW L-S.
     COMPUTE WS-OFF(1) = WR-CX(L-ROW) * 16 - L-EYE(1)
     COMPUTE WS-OFF(2) = (L-S - 1) * 16 + PL-MIN-Y - L-EYE(2)
     COMPUTE WS-OFF(3) = WR-CZ(L-ROW) * 16 - L-EYE(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE L-PV(WS-I) TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
     END-PERFORM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
         COMPUTE RL-D-MATRIX(RL-DRAW-COUNT, 12 + WS-R) = L-PV(WS-R) * WS-OFF(1)
             + L-PV(4 + WS-R) * WS-OFF(2) + L-PV(8 + WS-R) * WS-OFF(3) + L-PV(12 + WS-R)
     END-PERFORM
     GOBACK.
 END PROGRAM SECTION-MATRIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RENDER-MESH-ADD.
*> USING CLIENT-STATE, slot, first vertex, vertex count, count last uploaded (updated), pipeline,
*> texture, matrix (16 FLOAT-LONG): a mesh built this frame is uploaded while it has vertices and
*> once more when it no longer has (freed), and drawn while it has vertices.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 01 L-VERTICES             PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-UPLOADED             BINARY-LONG.
 01 L-PIPE                 BINARY-LONG.
 01 L-TEX                  BINARY-LONG.
 01 L-MATRIX-TABLE.
    05 L-MATRIX            FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT L-VERTICES L-COUNT L-UPLOADED L-PIPE L-TEX
         L-MATRIX-TABLE.
     IF L-COUNT > 0 OR L-UPLOADED > 0
         ADD 1 TO RL-UPLOAD-COUNT
         MOVE L-SLOT TO RL-U-SLOT(RL-UPLOAD-COUNT)
         SET RL-U-ADDR(RL-UPLOAD-COUNT) TO ADDRESS OF L-VERTICES
         MOVE L-COUNT TO RL-U-COUNT(RL-UPLOAD-COUNT)
         MOVE L-COUNT TO L-UPLOADED
     END-IF
     IF L-COUNT > 0
         ADD 1 TO RL-DRAW-COUNT
         MOVE L-SLOT TO RL-D-SLOT(RL-DRAW-COUNT)
         MOVE L-PIPE TO RL-D-PIPELINE(RL-DRAW-COUNT)
         MOVE L-TEX TO RL-D-TEX(RL-DRAW-COUNT)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE L-MATRIX(WS-I) TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM RENDER-MESH-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HIGHLIGHT-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): the target's outline (08 section 10.8.6; 51 block shapes): for each box of the outline shape of
*> the targeted state (a full cube when the tables hold none), on each of the six faces of the box, grown by 0.002 so it is not hidden
*> by the faces themselves, four strips 1/32 block wide along its edges: 24 quads, 144 vertices a box (at most 12 boxes),
*> eye-relative, on the white swatch of the UI atlas at brightness 0 (black) and alpha 0.6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-E                   FLOAT-LONG VALUE 0.002.
 01 WS-W                   FLOAT-LONG VALUE 0.03125.
 01 WS-A                   BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-STRIP               BINARY-LONG.
 01 WS-U-AXIS              BINARY-LONG.
 01 WS-V-AXIS              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-U0                  FLOAT-LONG.
 01 WS-U1                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-BLOCK               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-P                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-BLO                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-BHI                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CORNERS             PIC X(6) VALUE "123134".
 01 WS-TU                  FLOAT-SHORT.
 01 WS-TV                  FLOAT-SHORT.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-BOXES               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     MOVE TG-X TO WS-BLOCK(1) WS-CX
     MOVE TG-Y TO WS-BLOCK(2) WS-CY
     MOVE TG-Z TO WS-BLOCK(3) WS-CZ
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLK
     CALL "BSH-OUT-ID" USING WS-STATE WS-SHAPE
     MOVE BSH-N(WS-SHAPE + 1) TO WS-BOXES
     IF WS-BOXES = 0
         MOVE 1 TO WS-BOXES
     END-IF
     COMPUTE WS-TU = 4 / UA-W
     COMPUTE WS-TV = (UA-H - 4) / UA-H
     MOVE 0 TO RL-HL-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-BOXES
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             IF BSH-N(WS-SHAPE + 1) = 0
                 MOVE 0 TO WS-BLO(WS-A)
                 MOVE 1 TO WS-BHI(WS-A)
             ELSE
                 COMPUTE WS-BLO(WS-A) = BSH-V(WS-SHAPE + 1, WS-I, WS-A) / 16000
                 COMPUTE WS-BHI(WS-A) = BSH-V(WS-SHAPE + 1, WS-I, WS-A + 3) / 16000
             END-IF
             COMPUTE WS-BLO(WS-A) = WS-BLO(WS-A) - WS-E
             COMPUTE WS-BHI(WS-A) = WS-BHI(WS-A) + WS-E
         END-PERFORM
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-U-AXIS = FUNCTION MOD(WS-A, 3) + 1
             COMPUTE WS-V-AXIS = FUNCTION MOD(WS-A + 1, 3) + 1
             PERFORM VARYING WS-SIDE FROM 0 BY 1 UNTIL WS-SIDE > 1
                 PERFORM VARYING WS-STRIP FROM 1 BY 1 UNTIL WS-STRIP > 4
*>                   The strip's rectangle in the face's two other axes.
                     MOVE WS-BLO(WS-U-AXIS) TO WS-U0
                     MOVE WS-BHI(WS-U-AXIS) TO WS-U1
                     MOVE WS-BLO(WS-V-AXIS) TO WS-V0
                     MOVE WS-BHI(WS-V-AXIS) TO WS-V1
                     EVALUATE WS-STRIP
                         WHEN 1
                             COMPUTE WS-U1 = WS-U0 + WS-W
                         WHEN 2
                             COMPUTE WS-U0 = WS-U1 - WS-W
                         WHEN 3
                             COMPUTE WS-V1 = WS-V0 + WS-W
                         WHEN 4
                             COMPUTE WS-V0 = WS-V1 - WS-W
                     END-EVALUATE
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                         MOVE FUNCTION NUMVAL(WS-CORNERS(WS-K:1)) TO WS-C
                         COMPUTE WS-P(WS-A) = WS-BLO(WS-A) + WS-SIDE * (WS-BHI(WS-A) - WS-BLO(WS-A))
                         MOVE WS-U0 TO WS-P(WS-U-AXIS)
                         IF WS-C = 2 OR WS-C = 3
                             MOVE WS-U1 TO WS-P(WS-U-AXIS)
                         END-IF
                         MOVE WS-V0 TO WS-P(WS-V-AXIS)
                         IF WS-C >= 3
                             MOVE WS-V1 TO WS-P(WS-V-AXIS)
                         END-IF
                         ADD 1 TO RL-HL-COUNT
                         COMPUTE RL-HL-X(RL-HL-COUNT) = WS-BLOCK(1) + WS-P(1) - L-EYE(1)
                         COMPUTE RL-HL-Y(RL-HL-COUNT) = WS-BLOCK(2) + WS-P(2) - L-EYE(2)
                         COMPUTE RL-HL-Z(RL-HL-COUNT) = WS-BLOCK(3) + WS-P(3) - L-EYE(3)
                         MOVE WS-TU TO RL-HL-U(RL-HL-COUNT)
                         MOVE WS-TV TO RL-HL-V(RL-HL-COUNT)
                         MOVE 0 TO RL-HL-B(RL-HL-COUNT)
                         MOVE 0.6 TO RL-HL-A(RL-HL-COUNT)
                         MOVE 0 TO RL-HL-SKY(RL-HL-COUNT)
                         MOVE 1 TO RL-HL-R(RL-HL-COUNT) RL-HL-G(RL-HL-COUNT) RL-HL-BLUE(RL-HL-COUNT)
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM HIGHLIGHT-MESH.
