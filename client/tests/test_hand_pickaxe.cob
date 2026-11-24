*> T32301 (lane 002-lane-bugitems, operator try14 13.33.34: "tool in hand rendered wrong"): the first-person wooden pickaxe of the real generated vanilla pack
*> (CC_GENERATED_DIR; model chain wooden_pickaxe, handheld, generated) at rest: HAND-MESH holds the extruded sprite (08 section 5.7: front and back quad and
*> one quad for each side of an opaque texel next to a clear one, 74 quads, 444 vertices) posed by the arm transform and the model's firstperson_righthand
*> display (rotation 0 -90 25, translation 1.13 3.2 1.13, scale 0.68). The expected corners of the front quad and the quad count come from the independent script
*> client/tests/fixtures/gen_hand_flat.py (from the texture and the formulas of 12 section 6.3 and 8.2). The front quad (towards the camera at the origin)
*> is clockwise seen from the camera, the back quad is not.
*> T32900 (lane 002-lane-bughand, the same bug: "the wooden pickaxe in hand is a scrambled dark brown shape"): the hand pass of 12 section 6.9 culls back faces, so
*> the mesh holds only the 31 quads that face the camera at rest (1 front, 18 east, 6 up and 6 down walls: 12 section V21; 186 vertices), every one clockwise seen
*> from the eye (the terrain's winding); with CL-HAND-NOCULL 1 it is the whole 74-quad mesh of 6.8, whose back quad has u growing with +x like the front (a mirrored
*> back quad showed through the transparent texels of the front one) and whose walls take their texture coordinates inside their pixel (0.1 .. 0.9 of it). Expected
*> numbers: client/tests/fixtures/gen_hand_doc.py.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-PICKAXE.
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
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-PXU                 FLOAT-LONG OCCURS 4 TIMES.
 01 WS-PXV                 FLOAT-LONG OCCURS 4 TIMES.
 01 WS-EU                  FLOAT-LONG.
 01 WS-EV                  FLOAT-LONG.
 01 WS-MIN-U               FLOAT-LONG.
 01 WS-MAX-U               FLOAT-LONG.
 01 WS-MIN-V               FLOAT-LONG.
 01 WS-MAX-V               FLOAT-LONG.
 01 WS-EXPV.
    05 WS-EXPECT           FLOAT-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
*>   A joined player is alive (Login sets the health): a health of 0 would be the death roll of the view pose (12 section 6.1), which these cases do not test.
     MOVE 20 TO PL-HEALTH
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
     MOVE SPACES TO WS-KEY
     MOVE "wooden_pickaxe" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 0 TO CL-CAMERA CL-SWING-AT
     MOVE 1000000 TO CL-NOW-MS
     COMPUTE CL-HAND-ITEM = WS-ITEM + 1
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE WS-ITEM TO PL-SLOT-ITEM(PL-HELD + 1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "T32900 at rest only the 31 quads that face the camera are drawn (12 V21): 186 vertices" TO TL-CASE
     MOVE 186 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The front quad's top-left, top-right and bottom-right corners (independent script), in view space.
     MOVE 0.6094 TO WS-EXPECT(1) WS-EXPECT(4) WS-EXPECT(7)
     MOVE -0.1555 TO WS-EXPECT(2)
     MOVE -1.1012 TO WS-EXPECT(3)
     MOVE 0.1318 TO WS-EXPECT(5)
     MOVE -0.4849 TO WS-EXPECT(6)
     MOVE -0.4845 TO WS-EXPECT(8)
     MOVE -0.1975 TO WS-EXPECT(9)
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         IF FUNCTION ABS(RL-HAND-X(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 1)) > 0.002 OR FUNCTION ABS(RL-HAND-Y(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 2)) > 0.002
                 OR FUNCTION ABS(RL-HAND-Z(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 3)) > 0.002
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "T32301 the front quad's corners are where the arm transform and the handheld display put them (+-2 mm)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Every quad of the mesh is clockwise seen from the camera at the origin: cross(v2 - v1, v3 - v2) . v1 > 0.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 6 UNTIL WS-I > RL-HAND-COUNT
         CALL "TEST-QUAD-FACING" USING CLIENT-STATE WS-I WS-DOT
         IF WS-DOT <= 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "T32900 every quad of the hand mesh faces the camera (the back quad and the west walls are not drawn)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The first wall after the front quad: the east wall of the pixel (10, 2) (gen_hand_doc.py): its vertices in the client's order are the document's v0, v3, v2, v1,
*>   uv (x + 0.9, y + 0.1), (x + 0.1, y + 0.1), (x + 0.1, y + 0.9), (x + 0.9, y + 0.9) of the sprite, a 16 x 16 icon.
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SPRITE
     MOVE 10.9 TO WS-PXU(1) WS-PXU(4)
     MOVE 10.1 TO WS-PXU(2) WS-PXU(3)
     MOVE 2.1 TO WS-PXV(1) WS-PXV(2)
     MOVE 2.9 TO WS-PXV(3) WS-PXV(4)
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-EU = (AT-X(WS-SPRITE) + WS-PXU(WS-I)) / AT-W
         COMPUTE WS-EV = (AT-Y(WS-SPRITE) + WS-PXV(WS-I)) / AT-H
*>       The vertices of the quad are its corners 1 2 3 1 3 4: corner 4 is vertex 6 of the quad.
         COMPUTE WS-J = 6 + WS-I
         IF WS-I = 4
             MOVE 12 TO WS-J
         END-IF
         IF FUNCTION ABS(RL-HAND-U(WS-J) - WS-EU) > 0.00002 OR FUNCTION ABS(RL-HAND-V(WS-J) - WS-EV) > 0.00002
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "T32900 the first wall (east, pixel 10 2) takes its uv inside the pixel, 0.1 to 0.9 (12 6.8)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The whole mesh (back faces kept): 74 quads, 444 vertices.
     MOVE 1 TO CL-HAND-NOCULL
     MOVE 0 TO CL-HAND-KEY-COUNT
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T32900 without culling the mesh is the 74 quads of 12 6.8 (444 vertices)" TO TL-CASE
     MOVE 444 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The back quad (vertices 7 to 12): its corners are the front quad's at the same model x and y, so a corner has the front corner's texture coordinate:
*>   back v1 (x 1, y 1) = front v2, back v2 (x 0, y 1) = front v1, back v3 (x 0, y 0) = front v4 (bottom-left, vertex 6), back v4 (x 1, y 0) = front v3.
     MOVE 1 TO WS-OK
     IF RL-HAND-U(7) NOT = RL-HAND-U(2) OR RL-HAND-V(7) NOT = RL-HAND-V(2)
         MOVE 0 TO WS-OK
     END-IF
     IF RL-HAND-U(8) NOT = RL-HAND-U(1) OR RL-HAND-V(8) NOT = RL-HAND-V(1)
         MOVE 0 TO WS-OK
     END-IF
     IF RL-HAND-U(9) NOT = RL-HAND-U(6) OR RL-HAND-V(9) NOT = RL-HAND-V(6)
         MOVE 0 TO WS-OK
     END-IF
     IF RL-HAND-U(12) NOT = RL-HAND-U(3) OR RL-HAND-V(12) NOT = RL-HAND-V(3)
         MOVE 0 TO WS-OK
     END-IF
     MOVE "T32900 the back quad's u grows with +x like the front's (a mirrored back quad showed through the front's holes)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Every wall (quads 3 on) lies inside its pixel: 0.8 of a texel in u and in v.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 13 BY 6 UNTIL WS-I > RL-HAND-COUNT
         MOVE RL-HAND-U(WS-I) TO WS-MIN-U
         MOVE RL-HAND-U(WS-I) TO WS-MAX-U
         MOVE RL-HAND-V(WS-I) TO WS-MIN-V
         MOVE RL-HAND-V(WS-I) TO WS-MAX-V
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 5
             MOVE FUNCTION MIN(WS-MIN-U, RL-HAND-U(WS-I + WS-J)) TO WS-MIN-U
             MOVE FUNCTION MAX(WS-MAX-U, RL-HAND-U(WS-I + WS-J)) TO WS-MAX-U
             MOVE FUNCTION MIN(WS-MIN-V, RL-HAND-V(WS-I + WS-J)) TO WS-MIN-V
             MOVE FUNCTION MAX(WS-MAX-V, RL-HAND-V(WS-I + WS-J)) TO WS-MAX-V
         END-PERFORM
         IF FUNCTION ABS((WS-MAX-U - WS-MIN-U) * AT-W - 0.8) > 0.01 OR FUNCTION ABS((WS-MAX-V - WS-MIN-V) * AT-H - 0.8) > 0.01
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "T32900 every wall's texture coordinates span 0.8 of a texel each way (inside the pixel)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The 18 + 18 + 18 + 18 walls: the vertices of quads 3 on, by their normals' kind, are 72 quads: 432 vertices.
     MOVE "T32900 74 quads in all: 2 + 72 exposed edges" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 + 72
     COMPUTE TL-OBSERVED-N = RL-HAND-COUNT / 6
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-HAND-PICKAXE.

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

 COPY CLTEST.
