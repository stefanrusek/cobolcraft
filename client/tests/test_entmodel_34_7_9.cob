*> Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 9 (Dragon fireball): no model, the four vertices of the camera facing quad (positions and uvs in the order of the document), the scale of 2,
*> the outline pass when the outline colour is non-zero, the texture, block light level 15 and the shadow radius 0 (inferred in the document, example 11.10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-7-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "EF7-FIREBALL-QUAD" USING WS-IN WS-OUT
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [1]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [2]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [6]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [7]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [9]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [11]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [12]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [17]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [18]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [19]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 quad vertices (x, y, z, u, v) in order 1 to 4 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF7-FIREBALL-POSE" USING WS-IN WS-OUT
     MOVE "9 pose scale ops (count; code 2 scale; 2 2 2); the camera orientation rotation is applied by the caller after it [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 pose scale ops (count; code 2 scale; 2 2 2); the camera orientation rotation is applied by the caller after it [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 pose scale ops (count; code 2 scale; 2 2 2); the camera orientation rotation is applied by the caller after it [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 pose scale ops (count; code 2 scale; 2 2 2); the camera orientation rotation is applied by the caller after it [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 pose scale ops (count; code 2 scale; 2 2 2); the camera orientation rotation is applied by the caller after it [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF7-FIREBALL-PASSES" USING WS-IN WS-OUT
     MOVE "9 passes outline colour 0 (main pass, outline pass, vertex colour of the outline pass) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 passes outline colour 0 (main pass, outline pass, vertex colour of the outline pass) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 passes outline colour 0 (main pass, outline pass, vertex colour of the outline pass) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16711680 TO WS-IV(1)
     CALL "EF7-FIREBALL-PASSES" USING WS-IN WS-OUT
     MOVE "9 passes outline colour 16711680 (main pass, outline pass, vertex colour of the outline pass) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 passes outline colour 16711680 (main pass, outline pass, vertex colour of the outline pass) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 passes outline colour 16711680 (main pass, outline pass, vertex colour of the outline pass) [3]" TO WS-NAME
     MOVE 16711680 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     CALL "EF7-FIREBALL-PASSES" USING WS-IN WS-OUT
     MOVE "9 passes outline colour -1 (main pass, outline pass, vertex colour of the outline pass) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 passes outline colour -1 (main pass, outline pass, vertex colour of the outline pass) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 passes outline colour -1 (main pass, outline pass, vertex colour of the outline pass) [3]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-X120
     MOVE 0 TO WS-IV(1)
     CALL "EF7-FIREBALL-TEXTURE" USING WS-IN WS-X120
     MOVE "9 texture" TO WS-NAME
     MOVE "textures/entity/enderdragon/dragon_fireball.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF7-FIREBALL-RENDER" USING WS-IN WS-OUT
     MOVE "9 shadow radius and block light level [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9 shadow radius and block light level [2]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-7§9 Dragon fireball: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-7§9 Dragon fireball: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-7-9.
