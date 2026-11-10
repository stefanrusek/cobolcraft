*> Drawing the weather (standin-content §14.2, §14.5; docs/protocol/08-resource-packs.md §10.3,
*> §10.11): ENVIRONMENT-ATLAS-BUILD loads the environment atlas (texture 3): the images
*> textures/environment/drizzle.png and hailstorm.png, each from the top-most pack that has it, or
*> the missing-texture stripes at its stand-in size (16 x 16) when no pack has it, side by side in
*> that order from the left. The atlas is as tall as the least common multiple of the two heights
*> (at most 4096 rows; past that both images are stretched to the taller one's height),
*> each image repeated down its columns, and is sampled with repeat wrapping (cc_vk_texture_wrap,
*> shim-abi §9), so a v running over several images wraps seamlessly (08 §10.11).
*> WEATHER-MESH builds the frame's weather mesh, eye-relative, in drizzle and in a hailstorm (clear
*> draws nothing): with the camera in block column (cx, cz) at block y cy, every column (x, z) with
*> |x - cx| <= 8 and |z - cz| <= 8 in a loaded chunk whose biome at (x, top + 1, z) has
*> has_precipitation 1 in the biome registry (top: the column's highest non-void block; top + 1
*> taken at most at the world's last layer) gets two vertical quads 1 block wide, crossing at the
*> column centre (one in the plane z + 0.5 from x to x + 1, one in the plane x + 0.5 from z to
*> z + 1), from y0 = max(top + 1, cy - 8) to y1 = cy + 16 (none when y1 <= y0). u runs from 0 to 1
*> across a quad over the kind's columns; v is the block y above y0 plus the downward scroll (Time x
*> fall speed) mod 1, fall speed 0.25 blocks per tick for drizzle and 0.5 for hail, in images of
*> the kind (beyond the atlas height the sampler wraps).
*> Corners top-left, top-right, bottom-right, bottom-left; unlit (brightness 1), alpha 1 (the
*> texture's alpha shows through the translucent pipeline). A dimension without weather has the
*> biome ash_flats, without precipitation, so nothing is drawn there.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENVIRONMENT-ATLAS-BUILD.
*> USING CLIENT-STATE: fills XA-* and marks texture 3 for upload.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
*> Per image: path length, path.
 01 WS-SOURCE-DATA.
    05 FILLER PIC X(64) VALUE "50assets/cobolcraft/textures/environment/drizzle.png".
    05 FILLER PIC X(64) VALUE "52assets/cobolcraft/textures/environment/hailstorm.png".
 01 WS-SOURCE-TABLE REDEFINES WS-SOURCE-DATA.
    05 WS-SOURCE OCCURS 2 TIMES.
       10 WS-S-LENGTH        PIC 99.
       10 WS-S-PATH          PIC X(62).
 01 WS-SKIN-PATHS.
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/environment/rain.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/environment/snow.png".
 01 WS-SKIN-TABLE REDEFINES WS-SKIN-PATHS.
    05 WS-SKIN-PATH        PIC X(64) OCCURS 2 TIMES.
 01 WS-SKIN                BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-IMAGES.
    05 WS-IMAGE            PIC X(1048576) OCCURS 2 TIMES.
 01 WS-CAPACITY            BINARY-LONG VALUE 1048576.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-ROW-BYTES           BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-OLD-HEIGHTS.
    05 WS-OLD-H            BINARY-LONG OCCURS 2 TIMES.
 01 B-ATLAS                PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO XA-W XA-H WS-SKIN
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PK-COUNT
         IF PK-LEVEL(WS-K) = 2
             MOVE 1 TO WS-SKIN
         END-IF
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE 0 TO WS-FOUND
*>       With the skin on (level 2 of the stack), drizzle is the pack's rain and hailstorm its snow
*>       (faithful-pack-mapping 6.2); a pack that has neither leaves the built-in images.
         IF WS-SKIN = 1
             MOVE SPACES TO WS-PATH
             MOVE WS-SKIN-PATH(WS-K) TO WS-PATH
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
             CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMAGE(WS-K)
                 WS-CAPACITY WS-W WS-H WS-FOUND
         END-IF
         IF WS-FOUND = 0
             MOVE WS-S-PATH(WS-K) TO WS-PATH
             MOVE WS-S-LENGTH(WS-K) TO WS-PATH-LENGTH
             CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMAGE(WS-K)
                 WS-CAPACITY WS-W WS-H WS-FOUND
         END-IF
         IF WS-FOUND = 0
             MOVE 16 TO WS-W WS-H
             CALL "MISSING-TEXTURE" USING WS-W WS-H WS-IMAGE(WS-K)
         END-IF
         MOVE XA-W TO XA-IM-X(WS-K)
         MOVE WS-W TO XA-IM-W(WS-K)
         MOVE WS-H TO XA-IM-H(WS-K)
         ADD WS-W TO XA-W
     END-PERFORM
*>   The height: the least common multiple of the two image heights (Euclid's algorithm).
     MOVE XA-IM-H(1) TO WS-A
     MOVE XA-IM-H(2) TO WS-B
     PERFORM UNTIL WS-B = 0
         MOVE FUNCTION MOD(WS-A, WS-B) TO WS-REST
         MOVE WS-B TO WS-A
         MOVE WS-REST TO WS-B
     END-PERFORM
     DIVIDE XA-IM-H(1) BY WS-A GIVING XA-H
     MULTIPLY XA-IM-H(2) BY XA-H
     MOVE XA-IM-H(1) TO WS-OLD-H(1)
     MOVE XA-IM-H(2) TO WS-OLD-H(2)
*>   Heights with no small common multiple (co-prime heights, CC-0003) would make the atlas huge: past
*>   4096 rows both images are stretched to the taller one's height (nearest neighbour) and the atlas
*>   is that tall.
     IF XA-H > 4096
         MOVE FUNCTION MAX(XA-IM-H(1), XA-IM-H(2)) TO XA-H
         MOVE XA-H TO XA-IM-H(1) XA-IM-H(2)
     END-IF
     IF XA-ADDR NOT = NULL
         FREE XA-ADDR
     END-IF
     COMPUTE WS-BYTES = XA-W * XA-H * 4
     ALLOCATE WS-BYTES CHARACTERS RETURNING XA-ADDR
     SET ADDRESS OF B-ATLAS TO XA-ADDR
     MOVE LOW-VALUES TO B-ATLAS(1:WS-BYTES)
*>   Atlas row r of an image's columns is image row r mod its height.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         COMPUTE WS-ROW-BYTES = XA-IM-W(WS-K) * 4
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R >= XA-H
             COMPUTE WS-TO = (WS-R * XA-W + XA-IM-X(WS-K)) * 4 + 1
             IF WS-OLD-H(WS-K) = XA-IM-H(WS-K)
                 COMPUTE WS-FROM = FUNCTION MOD(WS-R, XA-IM-H(WS-K)) * WS-ROW-BYTES + 1
             ELSE
                 COMPUTE WS-FROM = (WS-R * WS-OLD-H(WS-K) / XA-H) * WS-ROW-BYTES + 1
             END-IF
             MOVE WS-IMAGE(WS-K)(WS-FROM:WS-ROW-BYTES) TO B-ATLAS(WS-TO:WS-ROW-BYTES)
         END-PERFORM
     END-PERFORM
     MOVE 1 TO AT-UPLOAD(4)
     GOBACK.
 END PROGRAM ENVIRONMENT-ATLAS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): RL-WX-VERTEX and RL-WX-COUNT for this frame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CELLS.
 01 WS-K                   BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-SCROLL              FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X-FROM              BINARY-LONG.
 01 WS-X-TO                BINARY-LONG.
 01 WS-Z-FROM              BINARY-LONG.
 01 WS-Z-TO                BINARY-LONG.
 01 WS-CHUNK-X             BINARY-LONG.
 01 WS-CHUNK-Z             BINARY-LONG.
 01 WS-LAST-X              BINARY-LONG.
 01 WS-LAST-Z              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LAYERS              BINARY-LONG.
 01 WS-COLUMN              BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X             FLOAT-SHORT.
       10 WS-C-Y             FLOAT-SHORT.
       10 WS-C-Z             FLOAT-SHORT.
       10 WS-C-U             FLOAT-SHORT.
       10 WS-C-V             FLOAT-SHORT.
*> The six vertices of a quad: corners 1, 2, 3, 1, 3, 4.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     MOVE 0 TO RL-WX-COUNT
     IF PL-WEATHER = WX-DRIZZLE OR PL-WEATHER = WX-HAILSTORM
         MOVE PL-WEATHER TO WS-K
         MOVE 25 TO WS-SPEED
         IF WS-K = WX-HAILSTORM
             MOVE 50 TO WS-SPEED
         END-IF
         COMPUTE WS-STEP = FUNCTION MOD(PL-TIME * WS-SPEED, 100)
         COMPUTE WS-SCROLL = WS-STEP / 100
         COMPUTE WS-CX = FUNCTION INTEGER(L-EYE(1))
         COMPUTE WS-CY = FUNCTION INTEGER(L-EYE(2))
         COMPUTE WS-CZ = FUNCTION INTEGER(L-EYE(3))
         COMPUTE WS-LAYERS = FUNCTION MIN(PL-HEIGHT, CL-MAX-SECTIONS * 16)
         MOVE 0 TO WS-ROW
         COMPUTE WS-LAST-X = WS-CX + 1000
         COMPUTE WS-X-FROM = WS-CX - 8
         COMPUTE WS-X-TO = WS-CX + 8
         COMPUTE WS-Z-FROM = WS-CZ - 8
         COMPUTE WS-Z-TO = WS-CZ + 8
         PERFORM VARYING WS-X FROM WS-X-FROM BY 1 UNTIL WS-X > WS-X-TO
             PERFORM VARYING WS-Z FROM WS-Z-FROM BY 1 UNTIL WS-Z > WS-Z-TO
*>               The column's chunk row (looked up again only when the chunk changes).
                 COMPUTE WS-CHUNK-X = FUNCTION INTEGER(WS-X / 16)
                 COMPUTE WS-CHUNK-Z = FUNCTION INTEGER(WS-Z / 16)
                 IF WS-CHUNK-X NOT = WS-LAST-X OR WS-CHUNK-Z NOT = WS-LAST-Z
                     MOVE WS-CHUNK-X TO WS-LAST-X
                     MOVE WS-CHUNK-Z TO WS-LAST-Z
                     CALL "WORLD-ROW" USING CLIENT-STATE WS-CHUNK-X WS-CHUNK-Z WS-ROW
                 END-IF
                 MOVE 255 TO WS-BIOME
                 IF WS-ROW > 0
                     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
                     COMPUTE WS-LX = WS-X - WS-CHUNK-X * 16
                     COMPUTE WS-LZ = WS-Z - WS-CHUNK-Z * 16
                     COMPUTE WS-COLUMN = WS-LZ * 16 + WS-LX + 1
*>                   The highest non-void block (-1 when the column is all void).
                     PERFORM VARYING WS-LY FROM WS-LAYERS BY -1 UNTIL WS-LY < 1
                         COMPUTE WS-CELL = (WS-LY - 1) * 256 + WS-COLUMN
                         IF CE-STATE(WS-CELL) NOT = 0
                             EXIT PERFORM
                         END-IF
                     END-PERFORM
                     SUBTRACT 1 FROM WS-LY
*>                   WS-LY is now top (local); the biome cell of top + 1.
                     COMPUTE WS-BY = FUNCTION MIN(WS-LY + 1, WS-LAYERS - 1)
                     DIVIDE WS-BY BY 4 GIVING WS-BY
                     DIVIDE WS-LX BY 4 GIVING WS-BX
                     DIVIDE WS-LZ BY 4 GIVING WS-BZ
                     COMPUTE WS-CELL = WS-BY * 16 + WS-BZ * 4 + WS-BX + 1
                     MOVE CE-BIOME(WS-CELL) TO WS-BIOME
                 END-IF
                 COMPUTE WS-Y0 = FUNCTION MAX(WS-LY + 1 + PL-MIN-Y, WS-CY - 8)
                 COMPUTE WS-Y1 = WS-CY + 16
                 IF WS-BIOME < CL-MAX-BIOMES AND WS-Y1 > WS-Y0
                     IF RG-BIOME-PRECIP(WS-BIOME + 1) = 1
                         PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > 2
*>                           Corner k: across 0 for 1 and 4, 1 for 2 and 3; y1 for 1 and 2, y0
*>                           for 3 and 4.
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                                 MOVE 0 TO WS-T
                                 IF WS-I = 2 OR WS-I = 3
                                     MOVE 1 TO WS-T
                                 END-IF
                                 MOVE WS-Y1 TO WS-Y
                                 IF WS-I >= 3
                                     MOVE WS-Y0 TO WS-Y
                                 END-IF
                                 IF WS-Q = 1
                                     COMPUTE WS-C-X(WS-I) = WS-X + WS-T - L-EYE(1)
                                     COMPUTE WS-C-Z(WS-I) = WS-Z + 0.5 - L-EYE(3)
                                 ELSE
                                     COMPUTE WS-C-X(WS-I) = WS-X + 0.5 - L-EYE(1)
                                     COMPUTE WS-C-Z(WS-I) = WS-Z + WS-T - L-EYE(3)
                                 END-IF
                                 COMPUTE WS-C-Y(WS-I) = WS-Y - L-EYE(2)
                                 COMPUTE WS-C-U(WS-I) = (XA-IM-X(WS-K) + WS-T * XA-IM-W(WS-K))
                                     / XA-W
                                 COMPUTE WS-C-V(WS-I) = (WS-SCROLL + WS-Y - WS-Y0) * XA-IM-H(WS-K)
                                     / XA-H
                             END-PERFORM
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                                 MOVE WS-ORD(WS-I) TO WS-N
                                 ADD 1 TO RL-WX-COUNT
                                 MOVE WS-C-X(WS-N) TO RL-WX-X(RL-WX-COUNT)
                                 MOVE WS-C-Y(WS-N) TO RL-WX-Y(RL-WX-COUNT)
                                 MOVE WS-C-Z(WS-N) TO RL-WX-Z(RL-WX-COUNT)
                                 MOVE WS-C-U(WS-N) TO RL-WX-U(RL-WX-COUNT)
                                 MOVE WS-C-V(WS-N) TO RL-WX-V(RL-WX-COUNT)
                                 MOVE 1 TO RL-WX-B(RL-WX-COUNT) RL-WX-A(RL-WX-COUNT)
                                 MOVE 0 TO RL-WX-SKY(RL-WX-COUNT)
                                 MOVE 1 TO RL-WX-R(RL-WX-COUNT) RL-WX-G(RL-WX-COUNT)
                                     RL-WX-BLUE(RL-WX-COUNT)
                             END-PERFORM
                         END-PERFORM
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM WEATHER-MESH.
