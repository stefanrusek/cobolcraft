*> Implementation test of client/src/render-list.cob (RENDER-LIST-BUILD; data-model §13 render list;
*> research R4; shim-abi.md §9): perspective (70 degree vertical field of view, Vulkan clip space)
*> and view matrices from the local player's eye (1.6 above the feet), yaw and pitch; each draw's
*> matrix is projection x view x the section's offset from the eye; opaque draws, then translucent
*> draws back to front by section, then the UI draw last; meshes changed since the last frame are
*> listed as uploads once; the clear colour is the sky's.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RENDER-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CLTINT.
 COPY CELLS.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PATH                PIC X(256)
     VALUE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex".
 01 WS-ID                  BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG VALUE 1000.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-NEAR                FLOAT-LONG VALUE 0.05.
 01 WS-FAR                 FLOAT-LONG VALUE 512.
 01 WS-E                   PIC -9.9999.
 01 WS-E2                  PIC -9.9999.
 01 WS-E3                  PIC -9.9999.
 01 WS-N                   FLOAT-SHORT.
 01 WS-N2                  FLOAT-SHORT.
 01 WS-N3                  FLOAT-SHORT.
 01 WS-N4                  PIC 9.
 01 WS-NE                  PIC -(3)9.99.
 01 WS-NE2                 PIC -(3)9.99.
 01 WS-NE3                 PIC -(3)9.99.
 01 WS-PIPES               PIC X(64).
 01 WS-OK                  BINARY-LONG.
 01 WS-PS.
    05 WS-P                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-VS.
    05 WS-V                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-PVS.
    05 WS-PV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-TS.
    05 WS-T                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-MS.
    05 WS-M                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SECTION-Y           FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 800 TO IN-WIN-W
     MOVE 600 TO IN-WIN-H
     MOVE 256 TO PL-HEIGHT
     MOVE 3 TO RG-BIOMES
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 1 TO PL-HAS-SKY
     MOVE 6000 TO PL-TIME
     MOVE 4.5 TO PL-X
     MOVE 54 TO PL-Y
     MOVE 8.5 TO PL-Z
     MOVE -90 TO PL-YAW
     MOVE 0 TO PL-PITCH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "REPLICA-CHUNK-LOAD" USING CLIENT-STATE PB-BUFFER
*>   A second, farther lucite in chunk (2, 0), section 3.
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-TWO WS-ZERO WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE 12 TO CE-STATE(58 * 256 + 8 * 16 + 8 + 1)
     MOVE 1 TO WR-DIRTY(WS-ROW, 4)
*>   And a third at middle distance in chunk (-1, 0), loaded last.
     MOVE -1 TO WS-I
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-I WS-ZERO WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE 12 TO CE-STATE(58 * 256 + 8 * 16 + 8 + 1)
     MOVE 1 TO WR-DIRTY(WS-ROW, 4)
     MOVE 1000000000 TO MB-BUDGET-US
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BUDGET
     CALL "SKY-UPDATE" USING CLIENT-STATE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "UI-RENDER" USING CLIENT-STATE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE

     COMPUTE WS-F = 1 / FUNCTION TAN(35 * FUNCTION PI / 180)
     COMPUTE WS-A = 800 / 600
     MOVE "render list perspective: f / aspect, -f, far / (near - far), -1, near far / (near - far)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     COMPUTE WS-E ROUNDED = WS-F / WS-A
     STRING WS-E DELIMITED BY SIZE INTO TL-EXPECTED
     COMPUTE WS-E ROUNDED = 0 - WS-F
     STRING FUNCTION TRIM(TL-EXPECTED) WS-E DELIMITED BY SIZE INTO TL-EXPECTED
     COMPUTE WS-E ROUNDED = WS-FAR / (WS-NEAR - WS-FAR)
     STRING FUNCTION TRIM(TL-EXPECTED) WS-E "-1.0000" DELIMITED BY SIZE INTO TL-EXPECTED
     COMPUTE WS-E ROUNDED = WS-NEAR * WS-FAR / (WS-NEAR - WS-FAR)
     STRING FUNCTION TRIM(TL-EXPECTED) WS-E DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-I = 1 OR WS-I = 6 OR WS-I = 11 OR WS-I = 12 OR WS-I = 15
             COMPUTE WS-E ROUNDED = RL-PROJ(WS-I)
             STRING FUNCTION TRIM(TL-OBSERVED) WS-E DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "render list view facing east (yaw -90, pitch 0): right is south, up is up, forward east"
         TO TL-CASE
     MOVE " 0.0000 0.0000-1.0000 0.0000 0.0000 1.0000 0.0000 0.0000 1.0000 0.0000 0.0000 0.0000"
         & " 0.0000 0.0000 0.0000 1.0000" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         COMPUTE WS-E ROUNDED = RL-VIEW(WS-I) + 0.00000001
         STRING WS-E DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "render list clear colour is the sky's (day: #8FB8E6)" TO TL-CASE
     COMPUTE WS-E ROUNDED = 143 / 255
     COMPUTE WS-E2 ROUNDED = RL-CLEAR(1)
     MOVE WS-E TO TL-EXPECTED
     MOVE WS-E2 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-PIPES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         MOVE RL-D-PIPELINE(WS-I) TO WS-K
         MOVE FUNCTION CHAR(WS-K + 49) TO WS-PIPES(WS-I:1)
     END-PERFORM
     MOVE "render list opaque draws, then three translucent draws, the UI draw last on texture 2"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-K
     INSPECT WS-PIPES TALLYING WS-K FOR ALL "1"
     MOVE WS-K TO WS-C
     STRING WS-PIPES(RL-DRAW-COUNT - 2:3) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE RL-D-TEX(RL-DRAW-COUNT) TO WS-K
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION CHAR(WS-K + 49) DELIMITED BY SIZE
         INTO TL-OBSERVED
     IF WS-C NOT = 3 OR WS-PIPES(1:RL-DRAW-COUNT - 4) NOT = ALL "0"
         MOVE "order broken" TO TL-OBSERVED
     END-IF
     MOVE "112 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "render list translucent sections are drawn back to front: chunk 2, then -1, then 0"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 3 BY -1 UNTIL WS-I < 1
         COMPUTE WS-ROW = (RL-D-SLOT(RL-DRAW-COUNT - WS-I) - MESH-SLOT-BASE) / 48 + 1
         COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + WR-CX(WS-ROW) + 1
     END-PERFORM
     MOVE 301 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The first opaque draw: chunk (0, 0), its lowest section with geometry (section 0).
     COMPUTE WS-ROW = (RL-D-SLOT(1) - MESH-SLOT-BASE) / 48 + 1
     COMPUTE WS-SECTION-Y = FUNCTION MOD(RL-D-SLOT(1) - MESH-SLOT-BASE, 48) / 2 * 16
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO WS-T(WS-I)
     END-PERFORM
     MOVE 1 TO WS-T(1) WS-T(6) WS-T(11) WS-T(16)
     COMPUTE WS-T(13) = WR-CX(WS-ROW) * 16 - PL-X
     COMPUTE WS-T(14) = WS-SECTION-Y - PL-Y - 1.6
     COMPUTE WS-T(15) = WR-CZ(WS-ROW) * 16 - PL-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE RL-PROJ(WS-I) TO WS-P(WS-I)
         MOVE RL-VIEW(WS-I) TO WS-V(WS-I)
     END-PERFORM
     CALL "TEST-MAT-MUL" USING WS-PS WS-VS WS-PVS
     CALL "TEST-MAT-MUL" USING WS-PVS WS-TS WS-MS
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF FUNCTION ABS(WS-M(WS-I) - RL-D-MATRIX(1, WS-I)) > 0.001
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "render list a draw's matrix is projection x view x the section's offset from the eye"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) > 1
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     MOVE WS-K TO WS-C
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE "render list changed meshes are uploaded once (opaque and translucent slot of each "
         & "meshed section, then none); the UI mesh every frame" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-C > 0 AND FUNCTION MOD(WS-C, 2) = 0 AND RL-UPLOAD-COUNT = 1
             AND RL-U-SLOT(1) = MESH-SLOT-UI
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A dimension change: 200 forgotten rows and every section of them changed in one frame, with
*>   every fixed mesh (entities, ground items, weather, highlight, UI, icons, UI text) pending too.
*>   The section uploads stop short so the fixed ones still fit; the rest wait for later frames.
     MOVE 200 TO WR-COUNT
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 200
         MOVE 0 TO WR-USED(WS-R)
         MOVE 1 TO WR-RELEASE(WS-R)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE 1 TO WR-UPLOAD(WS-R, WS-I)
         END-PERFORM
     END-PERFORM
     MOVE 1 TO RL-EN-UPLOADED RL-GI-UPLOADED RL-WX-UPLOADED RL-HL-UPLOADED RL-IC-UPLOADED
         RL-UT-UPLOADED
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE "render list a frame with more changed sections than uploads fit still lists every "
         & "fixed mesh and stays within the upload limit" TO TL-CASE
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) < MESH-SLOT-BASE OR RL-U-SLOT(WS-I) >= MESH-SLOT-ENTITIES
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-UPLOAD-COUNT <= CL-MAX-UPLOADS AND RL-UPLOAD-COUNT > CL-MAX-UPLOADS - 40 AND WS-K = 7
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A large view distance: 600 rows of 16 opaque sections (more draws than the list holds) and a
*>   block aimed at. The section draws stop short so the highlight and the UI draws still fit.
     MOVE 600 TO WR-COUNT
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 600
         MOVE 1 TO WR-USED(WS-R)
         MOVE 0 TO WR-RELEASE(WS-R)
         MOVE FUNCTION MOD(WS-R, 33) TO WR-CX(WS-R)
         COMPUTE WR-CZ(WS-R) = WS-R / 33
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE 0 TO WR-UPLOAD(WS-R, WS-I) WR-TR-COUNT(WS-R, WS-I)
             MOVE 6 TO WR-OP-COUNT(WS-R, WS-I)
         END-PERFORM
     END-PERFORM
     MOVE 1 TO TG-HIT
     MOVE 0 TO TG-X TG-Z
     MOVE 60 TO TG-Y
     MOVE 1 TO TG-FACE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE "render list a frame with more section draws than the list holds still draws the "
         & "highlight and the UI last, within the draw limit" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-DRAW-COUNT <= CL-MAX-DRAWS AND RL-D-SLOT(RL-DRAW-COUNT) = MESH-SLOT-UI
             AND RL-D-SLOT(RL-DRAW-COUNT - 1) = MESH-SLOT-HIGHLIGHT
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The camera's eye in a fluid (12 section 3.3, fog colour): the clear colour is the water fog colour #050533 under water, the lava
*>   fog colour #991900 in lava.
     MOVE 1 TO PL-EYE-WATER
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE "render list the eye under water clears to the water fog colour (#050533)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     COMPUTE WS-E ROUNDED = 5 / 255
     COMPUTE WS-E2 ROUNDED = 51 / 255
     STRING WS-E " " WS-E " " WS-E2 DELIMITED BY SIZE INTO TL-EXPECTED
     COMPUTE WS-E ROUNDED = RL-CLEAR(1)
     COMPUTE WS-E2 ROUNDED = RL-CLEAR(2)
     COMPUTE WS-E3 ROUNDED = RL-CLEAR(3)
     STRING WS-E " " WS-E2 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FOG-TEXT
     MOVE "render list the eye under water has fog: the water fog colour, strength 1, start -8, end 96, the projection's focal terms"
         TO TL-CASE
     MOVE "0.0196  0.0196  0.2000 1.00 -8.00 96.00 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The biome's attributes override it: the biome under the eye (here the unloaded plains) with fog colour #112244 and an end multiplier 0.85.
     MOVE 0 TO TT-PLAINS
     MOVE 4279312964 TO TB-FOG(1)
     MOVE 0.85 TO TB-FOG-END(1)
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     PERFORM FOG-TEXT
     MOVE "render list the eye under water in a biome with water_fog_color #112244 and end multiplier 0.85: that colour, end 81.60"
         TO TL-CASE
     MOVE "0.0666  0.1333  0.2666 1.00 -8.00 81.60 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO TB-FOG(1) TB-FOG-END(1)
     MOVE 0 TO PL-EYE-WATER
     MOVE 1 TO PL-EYE-LAVA
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE "render list the eye in lava clears to the lava fog colour (#991900)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     COMPUTE WS-E ROUNDED = 153 / 255
     COMPUTE WS-E2 ROUNDED = 25 / 255
     MOVE 0 TO WS-E3
     STRING WS-E " " WS-E2 " " WS-E3 DELIMITED BY SIZE INTO TL-EXPECTED
     COMPUTE WS-E ROUNDED = RL-CLEAR(1)
     COMPUTE WS-E2 ROUNDED = RL-CLEAR(2)
     COMPUTE WS-E3 ROUNDED = RL-CLEAR(3)
     STRING WS-E " " WS-E2 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FOG-TEXT
     MOVE "render list the eye in lava has fog: the lava fog colour, strength 1, start 0.25, end 1" TO TL-CASE
     MOVE "0.6000  0.0980  0.0000 1.00 0.25 1.00 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-EYE-LAVA
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE "render list an eye in no fluid has no fog (strength 0)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE RL-FOG(4) TO WS-E
     MOVE WS-E TO TL-OBSERVED
     MOVE " 0.0000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The render-distance fog (12 section 3.3, cylindrical): a view distance of 12 chunks gives end 192 and start 192 - clamp(19.2, 4, 64) = 172.8, in the sky colour at
*>   strength 1, with the environment fog out of reach (start and end 1e9 and 2e9); the world up direction in view space is the second column of the view matrix.
     MOVE 12 TO PL-VIEW-DISTANCE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE "render list a view distance of 12 chunks: render-distance fog 172.8 to 192 at strength 1 in the sky colour, up = the view matrix's second column"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE RL-FOG(12) TO WS-N
     MOVE RL-FOG(13) TO WS-N2
     MOVE WS-N TO WS-NE
     MOVE WS-N2 TO WS-NE2
     MOVE 0 TO WS-N4
     IF RL-FOG(4) = 1 AND RL-FOG(1) = RL-CLEAR(1) AND RL-FOG(2) = RL-CLEAR(2) AND RL-FOG(3) = RL-CLEAR(3)
             AND RL-FOG(9) = RL-VIEW(5) AND RL-FOG(10) = RL-VIEW(6) AND RL-FOG(11) = RL-VIEW(7)
         MOVE 1 TO WS-N4
     END-IF
     STRING FUNCTION TRIM(WS-NE) " " FUNCTION TRIM(WS-NE2) " " WS-N4 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "172.80 192.00 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-VIEW-DISTANCE
     STOP RUN.

*> TL-OBSERVED: "r g b strength start end p00-and-p11-match" of the fog of the frame.
 FOG-TEXT.
     MOVE SPACES TO TL-OBSERVED
     MOVE RL-FOG(1) TO WS-E
     MOVE RL-FOG(2) TO WS-E2
     MOVE RL-FOG(3) TO WS-E3
     STRING WS-E " " WS-E2 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     MOVE RL-FOG(4) TO WS-N
     MOVE RL-FOG(5) TO WS-N2
     MOVE RL-FOG(6) TO WS-N3
     MOVE 0 TO WS-N4
     IF RL-FOG(7) = RL-PROJ(1) AND RL-FOG(8) = RL-PROJ(6)
         MOVE 1 TO WS-N4
     END-IF
     MOVE WS-N TO WS-NE
     MOVE WS-N2 TO WS-NE2
     MOVE WS-N3 TO WS-NE3
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-NE) " " FUNCTION TRIM(WS-NE2) " " FUNCTION TRIM(WS-NE3) " " WS-N4
         DELIMITED BY SIZE INTO TL-OBSERVED
     EXIT PARAGRAPH.
 END PROGRAM TEST-RENDER-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MAT-MUL.
*> USING a, b (16 FLOAT-LONG, column-major), product out: a x b.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-A.
    05 L-AV                FLOAT-LONG OCCURS 16 TIMES.
 01 L-B.
    05 L-BV                FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-OV                FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING L-A L-B L-OUT.
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 3
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 3
             MOVE 0 TO WS-SUM
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 3
                 COMPUTE WS-SUM = WS-SUM + L-AV(WS-K * 4 + WS-R + 1) * L-BV(WS-C * 4 + WS-K + 1)
             END-PERFORM
             MOVE WS-SUM TO L-OV(WS-C * 4 + WS-R + 1)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-MAT-MUL.
 COPY CLTEST.
