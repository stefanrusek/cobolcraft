*> T32901 to T32906 (lane 002-lane-bughand): the first-person hand against the worked examples of 12 section 9 (V21 to V26), real generated vanilla pack (CC_GENERATED_DIR).
*> The pass uses its own projection (6.9: vertical fov 70 whatever the fov option or the sprint modifier say, water and lava scale it by 0.857, near 0.05), so the
*> window fractions of the pickaxe's front quad are those of V21 (right 21.4 % of the width, lower 47.2 % of the height, 41 of 68 opaque texels on screen); the
*> mid-swing quad is V22's; the crafting table and the planks are V23's cube (UP and WEST drawn, the other four faces culled); the shade of a face follows 6.10 (the
*> LEVEL lights, normals in world orientation: V26) and so changes with the view angles. Expected numbers are the document's, checked by
*> client/tests/fixtures/gen_hand_doc.py. The matrix is column-major with y down for the Vulkan framebuffer, so its clip y is minus the document's.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-DOC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-TABLE-ITEM          BINARY-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-OPAQUE              BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-PROJ-TABLE.
    05 WS-PROJ             FLOAT-LONG OCCURS 16 TIMES.
 01 WS-V.
    05 WS-VV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-WIN-X               FLOAT-LONG.
 01 WS-WIN-Y               FLOAT-LONG.
 01 WS-MIN-X               FLOAT-LONG.
 01 WS-MAX-X               FLOAT-LONG.
 01 WS-MIN-Y               FLOAT-LONG.
 01 WS-MAX-Y               FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-EXPV.
    05 WS-EXPECT           FLOAT-LONG OCCURS 12 TIMES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FACING              FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-B1                  FLOAT-LONG.
*> M of the flat pickaxe at rest (V21 / 6.7.3: the 3 x 3 block by rows, then the constant column) and of a held cube (6.11).
 01 WS-M-FLAT.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE -0.68.
    05 FILLER              FLOAT-LONG VALUE 0.28738.
    05 FILLER              FLOAT-LONG VALUE 0.61629.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.61629.
    05 FILLER              FLOAT-LONG VALUE -0.28738.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.970625.
    05 FILLER              FLOAT-LONG VALUE -0.771835.
    05 FILLER              FLOAT-LONG VALUE -0.81383.
 01 WS-M-CUBE.
    05 FILLER              FLOAT-LONG VALUE 0.28284.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.28284.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.4.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE -0.28284.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.28284.
    05 FILLER              FLOAT-LONG VALUE 0.27716.
    05 FILLER              FLOAT-LONG VALUE -0.72.
    05 FILLER              FLOAT-LONG VALUE -0.72.
*> V26 rows: model-space normal of the face (x y z), then the shade at yaw 0, 90, 180, 270 (pitch 0) and yaw 0 with pitch 45 and -45 (9 = not in the table).
 01 WS-ROW-DATA.
    05 FILLER PIC X(60) VALUE "F 0 0 1 0.4970 0.7395 0.4970 0.7395 0.4970 0.4970".
    05 FILLER PIC X(60) VALUE "F 0 0 -1 0.4970 0.7395 0.4970 0.7395 0.4970 0.4970".
    05 FILLER PIC X(60) VALUE "F 0 1 0 1.0000 1.0000 1.0000 1.0000 0.8850 1.0000".
    05 FILLER PIC X(60) VALUE "F 0 -1 0 0.4000 0.4000 0.4000 0.4000 0.5532 0.4000".
    05 FILLER PIC X(60) VALUE "F 1 0 0 0.9127 0.8100 0.9127 0.8100 1.0000 0.5532".
    05 FILLER PIC X(60) VALUE "F -1 0 0 0.5027 0.4000 0.5027 0.4000 0.4000 0.8850".
    05 FILLER PIC X(60) VALUE "C 0 1 0 1.0000 1.0000 1.0000 1.0000 1.0000 9".
    05 FILLER PIC X(60) VALUE "C -1 0 0 0.7087 0.5715 0.7087 0.5715 0.8851 9".
    05 FILLER PIC X(60) VALUE "C 0 0 1 0.5715 0.7087 0.5715 0.7087 0.8851 9".
    05 FILLER PIC X(60) VALUE "C 0 0 -1 0.5715 0.7087 0.5715 0.7087 0.4000 9".
    05 FILLER PIC X(60) VALUE "C 1 0 0 0.7087 0.5715 0.7087 0.5715 0.4000 9".
    05 FILLER PIC X(60) VALUE "C 0 -1 0 0.4000 0.4000 0.4000 0.4000 0.4000 9".
 01 WS-ROWS REDEFINES WS-ROW-DATA.
    05 WS-ROW              PIC X(60) OCCURS 12 TIMES.
 01 WS-YAWS.
    05 WS-YAW-OF           FLOAT-LONG OCCURS 6 TIMES.
 01 WS-PITCHES.
    05 WS-PITCH-OF         FLOAT-LONG OCCURS 6 TIMES.
 01 WS-NUM                 FLOAT-LONG OCCURS 6 TIMES.
 01 WS-KIND                PIC X.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-TOKENS.
    05 WS-TOKEN            PIC X(12) OCCURS 10 TIMES.
 01 WS-SHADE               FLOAT-LONG.
 01 B-ATLAS                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE "N" TO TL-MODE
*>   ---- the hand projection (6.9) ----
     MOVE 1920 TO IN-WIN-W
     MOVE 1080 TO IN-WIN-H
     MOVE 90 TO CL-FOV-DEG
     MOVE 1.15 TO PL-FOV-MOD
     MOVE 1 TO CL-FOV-EFFECT
     CALL "HAND-PROJECT" USING CLIENT-STATE WS-PROJ-TABLE
     MOVE 1 TO WS-OK
     IF FUNCTION ABS(WS-PROJ(1) - 0.803333) > 0.00001 OR FUNCTION ABS(WS-PROJ(6) + 1.428148) > 0.00001
         MOVE 0 TO WS-OK
     END-IF
     IF WS-PROJ(12) NOT = -1 OR WS-PROJ(2) NOT = 0 OR WS-PROJ(5) NOT = 0 OR WS-PROJ(16) NOT = 0
         MOVE 0 TO WS-OK
     END-IF
     MOVE "T32901 the hand's fov is 70 degrees whatever the fov option (90) and the sprint modifier (1.15) are: f / aspect 0.803333, f 1.428148" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-EYE-WATER
     CALL "HAND-PROJECT" USING CLIENT-STATE WS-PROJ-TABLE
     MOVE "T32901 an eye in water shrinks the hand's fov by 0.85714287 (60 degrees: f 1.7320508)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-PROJ(6) + 1.7320508) < 0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-EYE-WATER
     CALL "HAND-PROJECT" USING CLIENT-STATE WS-PROJ-TABLE
*>   ---- V21: the pickaxe at rest ----
     MOVE "wooden_pickaxe" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO WS-TABLE-ITEM(1)
     MOVE "crafting_table" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TABLE-ITEM(2) WS-ITEM-ROW WS-STATUS
     MOVE "oak_planks" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TABLE-ITEM(3) WS-ITEM-ROW WS-STATUS
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 0 TO CL-CAMERA CL-SWING-AT
     MOVE 1000000 TO CL-NOW-MS
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE WS-ITEM TO PL-SLOT-ITEM(PL-HELD + 1)
     CALL "TEST-HAND-SHOW" USING CLIENT-STATE WS-ITEM
     CALL "HAND-MESH" USING CLIENT-STATE
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SPRITE
*>   The window fractions of the front quad's corners (c1 top-left, c2 top-right, c3 bottom-right, c4 = vertex 6 bottom-left) against the V21 table.
     MOVE 0.7223 TO WS-EXPECT(1)
     MOVE 0.6009 TO WS-EXPECT(2)
     MOVE 1.0048 TO WS-EXPECT(3)
     MOVE 0.3059 TO WS-EXPECT(4)
     MOVE 1.7391 TO WS-EXPECT(5)
     MOVE 2.2512 TO WS-EXPECT(6)
     MOVE 0.8008 TO WS-EXPECT(7)
     MOVE 1.1772 TO WS-EXPECT(8)
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-I TO WS-J
         IF WS-I = 4
             MOVE 6 TO WS-J
         END-IF
         MOVE RL-HAND-X(WS-J) TO WS-VV(1)
         MOVE RL-HAND-Y(WS-J) TO WS-VV(2)
         MOVE RL-HAND-Z(WS-J) TO WS-VV(3)
         CALL "TEST-HAND-WINDOW" USING WS-PROJ-TABLE WS-V WS-WIN-X WS-WIN-Y
*>       v0 = c1, v3 = c2, v2 = c3, v1 = c4 of the document's table (rows: v0, v3, v2, v1 in the expectations above).
         IF FUNCTION ABS(WS-WIN-X - WS-EXPECT((WS-I - 1) * 2 + 1)) > 0.0005 OR FUNCTION ABS(WS-WIN-Y - WS-EXPECT((WS-I - 1) * 2 + 2)) > 0.0005
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "T32902 V21: the front quad's corners land at the document's window fractions (hand fov 70, 16:9)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Every opaque texel of the sprite: its centre on the front quad (a parallelogram: c1 + a (c2 - c1) + b (c4 - c1)) and its four corners, through the matrix.
     SET ADDRESS OF B-ATLAS TO AT-ADDR
     MOVE 0 TO WS-OPAQUE WS-INSIDE
     MOVE 9 TO WS-MIN-X WS-MIN-Y
     MOVE -9 TO WS-MAX-X WS-MAX-Y
     PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= AT-SW(WS-SPRITE)
         PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX >= AT-SW(WS-SPRITE)
             COMPUTE WS-OFF = ((AT-Y(WS-SPRITE) + WS-PY) * AT-W + AT-X(WS-SPRITE) + WS-PX) * 4 + 4
             IF FUNCTION ORD(B-ATLAS(WS-OFF:1)) > 1
                 ADD 1 TO WS-OPAQUE
                 COMPUTE WS-U = (WS-PX + 0.5) / AT-SW(WS-SPRITE)
                 COMPUTE WS-W = (WS-PY + 0.5) / AT-SW(WS-SPRITE)
                 CALL "TEST-HAND-POINT" USING CLIENT-STATE WS-U WS-W WS-V
                 CALL "TEST-HAND-WINDOW" USING WS-PROJ-TABLE WS-V WS-WIN-X WS-WIN-Y
                 IF WS-WIN-X >= 0 AND WS-WIN-X <= 1 AND WS-WIN-Y >= 0 AND WS-WIN-Y <= 1
                     ADD 1 TO WS-INSIDE
                 END-IF
                 PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 1
                     PERFORM VARYING WS-CY FROM 0 BY 1 UNTIL WS-CY > 1
                         COMPUTE WS-U = (WS-PX + WS-CX) / AT-SW(WS-SPRITE)
                         COMPUTE WS-W = (WS-PY + WS-CY) / AT-SW(WS-SPRITE)
                         CALL "TEST-HAND-POINT" USING CLIENT-STATE WS-U WS-W WS-V
                         CALL "TEST-HAND-WINDOW" USING WS-PROJ-TABLE WS-V WS-WIN-X WS-WIN-Y
                         MOVE FUNCTION MIN(WS-MIN-X, WS-WIN-X) TO WS-MIN-X
                         MOVE FUNCTION MAX(WS-MAX-X, WS-WIN-X) TO WS-MAX-X
                         MOVE FUNCTION MIN(WS-MIN-Y, WS-WIN-Y) TO WS-MIN-Y
                         MOVE FUNCTION MAX(WS-MAX-Y, WS-WIN-Y) TO WS-MAX-Y
                     END-PERFORM
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "T32902 V21: the sprite has 68 opaque texels" TO TL-CASE
     MOVE 68 TO TL-EXPECTED-N
     MOVE WS-OPAQUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T32902 V21: 41 of the 68 opaque texel centres are inside the window" TO TL-CASE
     MOVE 41 TO TL-EXPECTED-N
     MOVE WS-INSIDE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-OK
     IF FUNCTION ABS(WS-MIN-X - 0.7864) > 0.0005 OR FUNCTION ABS(WS-MAX-X - 1.2511) > 0.0005
             OR FUNCTION ABS(WS-MIN-Y - 0.5276) > 0.0005 OR FUNCTION ABS(WS-MAX-Y - 1.2551) > 0.0005
         MOVE 0 TO WS-OK
     END-IF
     MOVE "T32902 V21: the opaque texels span fx 0.7864 to 1.2511 and fy 0.5276 to 1.2551: the right 21.4 % and the lower 47.2 % of the window" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- V22: mid-swing (p = 0.5): the front quad ----
     COMPUTE CL-SWING-AT = CL-NOW-MS - CL-SWING-MS / 2
     CALL "HAND-MESH" USING CLIENT-STATE
*>   Client order c1 c2 c3: the document's v0 (top-left), v3 (top-right), v2 (bottom-right).
     MOVE 0.26072 TO WS-EXPECT(1)
     MOVE -0.84294 TO WS-EXPECT(2)
     MOVE -1.43311 TO WS-EXPECT(3)
     MOVE -0.01000 TO WS-EXPECT(4)
     MOVE -0.22526 TO WS-EXPECT(5)
     MOVE -1.34608 TO WS-EXPECT(6)
     MOVE 0.13026 TO WS-EXPECT(7)
     MOVE -0.25742 TO WS-EXPECT(8)
     MOVE -0.68148 TO WS-EXPECT(9)
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         IF FUNCTION ABS(RL-HAND-X(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 1)) > 0.0005 OR FUNCTION ABS(RL-HAND-Y(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 2)) > 0.0005
                 OR FUNCTION ABS(RL-HAND-Z(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 3)) > 0.0005
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "T32903 V22: half way through the swing the front quad is where the document puts it (0.5 mm)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-QUAD-FACING" USING CLIENT-STATE WS-ONE WS-FACING
     MOVE "T32903 V22: the front quad still faces the camera at p = 0.5 (area 0.069, nearly edge-on)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FACING > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-SWING-AT
*>   ---- V23: the crafting table and the planks at rest ----
*>   The quads of a cube in the order south north east west up down; at rest west and up face the camera. The cube corners of the document's table, view space.
     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 3
         MOVE WS-TABLE-ITEM(WS-K) TO WS-ITEM
         MOVE WS-ITEM TO PL-SLOT-ITEM(PL-HELD + 1)
         CALL "TEST-HAND-SHOW" USING CLIENT-STATE WS-ITEM
         CALL "HAND-MESH" USING CLIENT-STATE
         MOVE "T32904 V23: a held cube draws two faces (west and up) of its six: 12 vertices" TO TL-CASE
         MOVE 12 TO TL-EXPECTED-N
         MOVE RL-HAND-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       West: (0,1,0) (0,1,1) (0,0,1) then (0,0,0); up: (0,1,0) (1,1,0) (1,1,1) then (0,1,1).
         MOVE 0.27716 TO WS-EXPECT(1)
         MOVE -0.32 TO WS-EXPECT(2)
         MOVE -0.72 TO WS-EXPECT(3)
         MOVE 0.56 TO WS-EXPECT(4)
         MOVE -0.32 TO WS-EXPECT(5)
         MOVE -0.43716 TO WS-EXPECT(6)
         MOVE 0.56 TO WS-EXPECT(7)
         MOVE -0.72 TO WS-EXPECT(8)
         MOVE -0.43716 TO WS-EXPECT(9)
         MOVE 1 TO WS-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             IF FUNCTION ABS(RL-HAND-X(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 1)) > 0.0002 OR FUNCTION ABS(RL-HAND-Y(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 2)) > 0.0002
                     OR FUNCTION ABS(RL-HAND-Z(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 3)) > 0.0002
                 MOVE 0 TO WS-OK
             END-IF
         END-PERFORM
         MOVE 0.27716 TO WS-EXPECT(1)
         MOVE -0.32 TO WS-EXPECT(2)
         MOVE -0.72 TO WS-EXPECT(3)
         MOVE 0.56 TO WS-EXPECT(4)
         MOVE -0.32 TO WS-EXPECT(5)
         MOVE -1.00284 TO WS-EXPECT(6)
         MOVE 0.84284 TO WS-EXPECT(7)
         MOVE -0.32 TO WS-EXPECT(8)
         MOVE -0.72 TO WS-EXPECT(9)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             COMPUTE WS-J = 6 + WS-I
             IF FUNCTION ABS(RL-HAND-X(WS-J) - WS-EXPECT((WS-I - 1) * 3 + 1)) > 0.0002 OR FUNCTION ABS(RL-HAND-Y(WS-J) - WS-EXPECT((WS-I - 1) * 3 + 2)) > 0.0002
                     OR FUNCTION ABS(RL-HAND-Z(WS-J) - WS-EXPECT((WS-I - 1) * 3 + 3)) > 0.0002
                 MOVE 0 TO WS-OK
             END-IF
         END-PERFORM
         MOVE "T32904 V23: the west and the up face are where the document's corner table puts them (0.2 mm)" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-OK TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       Window: the visible region of the cube is the top face fx 0.65 to 1.01, fy 0.73 to 1.02 (the up face's corners).
         MOVE 9 TO WS-MIN-X WS-MIN-Y
         MOVE -9 TO WS-MAX-X WS-MAX-Y
         PERFORM VARYING WS-I FROM 7 BY 1 UNTIL WS-I > 12
             MOVE RL-HAND-X(WS-I) TO WS-VV(1)
             MOVE RL-HAND-Y(WS-I) TO WS-VV(2)
             MOVE RL-HAND-Z(WS-I) TO WS-VV(3)
             CALL "TEST-HAND-WINDOW" USING WS-PROJ-TABLE WS-V WS-WIN-X WS-WIN-Y
             MOVE FUNCTION MIN(WS-MIN-X, WS-WIN-X) TO WS-MIN-X
             MOVE FUNCTION MAX(WS-MAX-X, WS-WIN-X) TO WS-MAX-X
             MOVE FUNCTION MIN(WS-MIN-Y, WS-WIN-Y) TO WS-MIN-Y
             MOVE FUNCTION MAX(WS-MAX-Y, WS-WIN-Y) TO WS-MAX-Y
         END-PERFORM
         MOVE 1 TO WS-OK
         IF FUNCTION ABS(WS-MIN-X - 0.6546) > 0.0005 OR FUNCTION ABS(WS-MAX-X - 1.0145) > 0.0005
                 OR FUNCTION ABS(WS-MIN-Y - 0.7279) > 0.0005 OR FUNCTION ABS(WS-MAX-Y - 1.0227) > 0.0005
             MOVE 0 TO WS-OK
         END-IF
         MOVE "T32904 V23: the up face of the held cube spans fx 0.6546 to 1.0145 and fy 0.7279 to 1.0227" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-OK TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The crafting table's west face is its front texture and its top is the top texture (V23); the planks use one texture on every face.
     MOVE WS-TABLE-ITEM(2) TO WS-ITEM
     MOVE WS-ITEM TO PL-SLOT-ITEM(PL-HELD + 1)
     CALL "TEST-HAND-SHOW" USING CLIENT-STATE WS-ITEM
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 5 TO WS-DIR
     CALL "ITEM-FACE-SPRITE" USING CLIENT-STATE WS-ITEM WS-DIR WS-SPRITE
     MOVE 1 TO WS-OK
     COMPUTE WS-U = AT-X(WS-SPRITE) / AT-W
     COMPUTE WS-W = AT-Y(WS-SPRITE) / AT-H
     IF FUNCTION ABS(RL-HAND-U(1) - WS-U) > 0.00001 OR FUNCTION ABS(RL-HAND-V(1) - WS-W) > 0.00001
         MOVE 0 TO WS-OK
     END-IF
     MOVE 2 TO WS-DIR
     CALL "ITEM-FACE-SPRITE" USING CLIENT-STATE WS-ITEM WS-DIR WS-SPRITE
     COMPUTE WS-U = AT-X(WS-SPRITE) / AT-W
     COMPUTE WS-W = AT-Y(WS-SPRITE) / AT-H
     IF FUNCTION ABS(RL-HAND-U(7) - WS-U) > 0.00001 OR FUNCTION ABS(RL-HAND-V(7) - WS-W) > 0.00001
         MOVE 0 TO WS-OK
     END-IF
     MOVE "T32904 V23: the held crafting table's west quad starts at the sprite of its west face and the up quad at that of its up face" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- V26: the shade of the faces, the matrix of V21 (flat item) and of 6.11 (cube) ----
     MOVE 0 TO WS-YAW-OF(1) WS-PITCH-OF(1) WS-PITCH-OF(2) WS-PITCH-OF(3) WS-PITCH-OF(4) WS-YAW-OF(5) WS-YAW-OF(6)
     MOVE 90 TO WS-YAW-OF(2)
     MOVE 180 TO WS-YAW-OF(3)
     MOVE 270 TO WS-YAW-OF(4)
     MOVE 45 TO WS-PITCH-OF(5)
     MOVE -45 TO WS-PITCH-OF(6)
     MOVE 1 TO CL-HAND-NOCULL
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE SPACES TO WS-TOKENS
         UNSTRING WS-ROW(WS-I) DELIMITED BY ALL SPACE INTO WS-KIND WS-TOKEN(1) WS-TOKEN(2) WS-TOKEN(3) WS-TOKEN(4)
             WS-TOKEN(5) WS-TOKEN(6) WS-TOKEN(7) WS-TOKEN(8) WS-TOKEN(9)
         COMPUTE WS-NX = FUNCTION NUMVAL(WS-TOKEN(1))
         COMPUTE WS-NY = FUNCTION NUMVAL(WS-TOKEN(2))
         COMPUTE WS-NZ = FUNCTION NUMVAL(WS-TOKEN(3))
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             COMPUTE WS-NUM(WS-J) = FUNCTION NUMVAL(WS-TOKEN(WS-J + 3))
         END-PERFORM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             IF WS-NUM(WS-K) < 5
                 IF WS-KIND = "F"
                     CALL "TEST-HAND-SHADE" USING CLIENT-STATE WS-M-FLAT WS-NX WS-NY WS-NZ WS-YAW-OF(WS-K) WS-PITCH-OF(WS-K) WS-SHADE
                 ELSE
                     CALL "TEST-HAND-SHADE" USING CLIENT-STATE WS-M-CUBE WS-NX WS-NY WS-NZ WS-YAW-OF(WS-K) WS-PITCH-OF(WS-K) WS-SHADE
                 END-IF
                 IF FUNCTION ABS(WS-SHADE - WS-NUM(WS-K)) > 0.0006
                     ADD 1 TO WS-BAD
                     DISPLAY "shade row " WS-I " column " WS-K " expected " WS-NUM(WS-K) " observed " WS-SHADE
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "T32905 V26: the shade of every face of the pickaxe and of the cube at the six view angles of the table (LEVEL lights, world normals)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The Nether's second light points down (6.10: normalize(-0.2, -1, 0.7)): the pickaxe's up wall at yaw 0 is 0.6962 there, 1.0 in the Overworld.
     MOVE "minecraft:the_nether" TO PL-DIM-NAME
     MOVE 0 TO WS-NX WS-NZ
     MOVE 1 TO WS-NY
     CALL "TEST-HAND-SHADE" USING CLIENT-STATE WS-M-FLAT WS-NX WS-NY WS-NZ WS-YAW-OF(1) WS-PITCH-OF(1) WS-SHADE
     MOVE "T32905 6.10: in the Nether the pickaxe's up wall is 0.6962 (the second light points down)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-SHADE - 0.6962) < 0.0006
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:overworld" TO PL-DIM-NAME
     MOVE 0 TO CL-HAND-NOCULL
*>   ---- the mesh follows the view angles: a turn re-shades it (the cache key holds yaw and pitch) ----
     MOVE WS-TABLE-ITEM(1) TO WS-ITEM
     MOVE WS-ITEM TO PL-SLOT-ITEM(PL-HELD + 1)
     CALL "TEST-HAND-SHOW" USING CLIENT-STATE WS-ITEM
     MOVE 0 TO PL-YAW
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE RL-HAND-B(1) TO WS-B1
     MOVE 90 TO PL-YAW
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T32905 a turn of the view rebuilds the mesh (not the one already uploaded) and lights the front face 0.7395 / 0.4970 as bright" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-HAND-SAME = 0 AND WS-B1 > 0.11 AND FUNCTION ABS(RL-HAND-B(1) / WS-B1 - 1.4879) < 0.002
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-HAND-DOC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-SHOW.
*> USING CLIENT-STATE, item id: the equip animation has run, so the hand shows the item at full height.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM.
     COMPUTE CL-HAND-ITEM = L-ITEM + 1
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE 0 TO CL-HAND-KEY-COUNT
     GOBACK.
 END PROGRAM TEST-HAND-SHOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-WINDOW.
*> USING projection (16, column-major), a view-space point (3), fx and fy out: the window fraction from the top-left corner (the matrix has y down).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CW                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PROJ.
    05 L-P                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-V.
    05 L-VV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-FX                   FLOAT-LONG.
 01 L-FY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-PROJ L-V L-FX L-FY.
     COMPUTE WS-CX = L-P(1) * L-VV(1) + L-P(5) * L-VV(2) + L-P(9) * L-VV(3) + L-P(13)
     COMPUTE WS-CY = L-P(2) * L-VV(1) + L-P(6) * L-VV(2) + L-P(10) * L-VV(3) + L-P(14)
     COMPUTE WS-CW = L-P(4) * L-VV(1) + L-P(8) * L-VV(2) + L-P(12) * L-VV(3) + L-P(16)
     COMPUTE L-FX = (WS-CX / WS-CW + 1) / 2
     COMPUTE L-FY = (WS-CY / WS-CW + 1) / 2
     GOBACK.
 END PROGRAM TEST-HAND-WINDOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-POINT.
*> USING CLIENT-STATE, a, b (0 to 1), view-space point out: c1 + a (c2 - c1) + b (c4 - c1) of the first quad of the hand (c1 top-left, c2 top-right: vertices 1 and 2; c4 bottom-left: vertex 6).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-V.
    05 L-VV                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-A L-B L-V.
     COMPUTE L-VV(1) = RL-HAND-X(1) + L-A * (RL-HAND-X(2) - RL-HAND-X(1)) + L-B * (RL-HAND-X(6) - RL-HAND-X(1))
     COMPUTE L-VV(2) = RL-HAND-Y(1) + L-A * (RL-HAND-Y(2) - RL-HAND-Y(1)) + L-B * (RL-HAND-Y(6) - RL-HAND-Y(1))
     COMPUTE L-VV(3) = RL-HAND-Z(1) + L-A * (RL-HAND-Z(2) - RL-HAND-Z(1)) + L-B * (RL-HAND-Z(6) - RL-HAND-Z(1))
     GOBACK.
 END PROGRAM TEST-HAND-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-QUAD-FACING.
*> USING CLIENT-STATE, the first vertex of a hand quad, the facing number out: cross(v2 - v1, v3 - v2) . v1 (positive: clockwise seen from the eye at the origin).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-B                   FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-AT                   BINARY-LONG.
 01 L-DOT                  FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-AT L-DOT.
     COMPUTE WS-A(1) = RL-HAND-X(L-AT + 1) - RL-HAND-X(L-AT)
     COMPUTE WS-A(2) = RL-HAND-Y(L-AT + 1) - RL-HAND-Y(L-AT)
     COMPUTE WS-A(3) = RL-HAND-Z(L-AT + 1) - RL-HAND-Z(L-AT)
     COMPUTE WS-B(1) = RL-HAND-X(L-AT + 2) - RL-HAND-X(L-AT + 1)
     COMPUTE WS-B(2) = RL-HAND-Y(L-AT + 2) - RL-HAND-Y(L-AT + 1)
     COMPUTE WS-B(3) = RL-HAND-Z(L-AT + 2) - RL-HAND-Z(L-AT + 1)
     COMPUTE L-DOT = (WS-A(2) * WS-B(3) - WS-A(3) * WS-B(2)) * RL-HAND-X(L-AT)
         + (WS-A(3) * WS-B(1) - WS-A(1) * WS-B(3)) * RL-HAND-Y(L-AT)
         + (WS-A(1) * WS-B(2) - WS-A(2) * WS-B(1)) * RL-HAND-Z(L-AT)
     GOBACK.
 END PROGRAM TEST-QUAD-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-SHADE.
*> USING CLIENT-STATE, M, a model-space normal (3 numbers), yaw and pitch (degrees), the shade out: HAND-QUAD's brightness of a quad with that normal at full light for the view angles.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q.
    05 WS-QV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES VALUE 0.
 01 WS-UV.
    05 WS-UVV              FLOAT-SHORT OCCURS 8 TIMES VALUE 0.
 01 WS-NORMAL.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LIGHT               FLOAT-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-NX                   FLOAT-LONG.
 01 L-NY                   FLOAT-LONG.
 01 L-NZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-SHADE                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-NX L-NY L-NZ L-YAW L-PITCH L-SHADE.
     CALL "HAND-VIEW-ROT" USING L-YAW L-PITCH WS-Q
     MOVE L-NX TO WS-NV(1)
     MOVE L-NY TO WS-NV(2)
     MOVE L-NZ TO WS-NV(3)
     MOVE 0 TO RL-HAND-COUNT
     CALL "HAND-QUAD" USING CLIENT-STATE L-M WS-CORNERS WS-UV WS-NORMAL WS-LIGHT WS-Q
     MOVE 0 TO L-SHADE
     IF RL-HAND-COUNT = 6
         MOVE RL-HAND-B(1) TO L-SHADE
     END-IF
     GOBACK.
 END PROGRAM TEST-HAND-SHADE.
