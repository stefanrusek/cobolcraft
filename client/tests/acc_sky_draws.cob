*> Acceptance test of the operator report "clouds, sun and moon don't render" (try13 play; bug lane bugsky; 12 section 3.4c sun, moon and stars,
*> section 3.6 clouds, section 3.4 skybox; docs/design/standin-content.md section 4.6 the sunless dimension has no sky): the render list of a
*> client in play in a dimension with sky light holds a draw of the sun, of the moon and of the clouds by day and by night, and a draw of the
*> stars by night only; a dimension without sky light (the Nether, the End, cobolcraft:subroutine) holds none of them. The sun and the moon are
*> drawn with the matrix of their own angle (12 section 3.4c; the angle tables of 12 section 3.2: the sun is straight overhead at tick 6000
*> and the moon at tick 18000, the sun then straight below), the clouds with the offset of the scrolled camera (12 section 3.6: the layer's
*> bottom at visual/cloud_height 192.33, the camera in cloud space at x + t x 0.03, z + 3.96 with t the game time). The option renderClouds
*> turns the clouds off ("false") or makes them one flat quad a cell ("fast") against a box a cell ("true"). Looking from under water draws none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SKY-DRAWS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FANCY               BINARY-LONG.
 01 WS-ED1                 PIC Z(5)9.
 01 WS-ED2                 PIC Z(5)9.
 01 WS-FAST                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-CELL-X              BINARY-LONG.
 01 WS-CELL-Z              BINARY-LONG.
 01 WS-EXPECT              FLOAT-LONG.
 01 WS-CLIP                FLOAT-LONG OCCURS 4 TIMES.
 01 WS-V                   FLOAT-LONG OCCURS 4 TIMES.
 01 WS-E1                  PIC -(6)9.99.
 01 WS-E2                  PIC -(6)9.99.
 01 WS-E3                  PIC -(6)9.99.
 01 WS-E4                  PIC -(6)9.99.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER

*>   Noon: the sun, the moon and the clouds; no stars (the star brightness is 0 from tick 627 to 11373).
     MOVE 6000 TO PL-TIME
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 0 TO WS-FANCY WS-FAST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) = MESH-SLOT-CLOUDS
             MOVE RL-U-COUNT(WS-I) TO WS-FANCY
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance sky: given a dimension with sky light at noon when the frame is built then the render list draws the sun, the moon "
         & "and the clouds (UI pipeline for the bodies, translucent for the clouds) and no stars" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "sun 1 moon 1 stars 0 clouds 1 pipes 2/2/1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Midnight: the stars are drawn as well.
     MOVE 18000 TO PL-TIME
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance sky: given a dimension with sky light at midnight when the frame is built then the render list draws the sun, the moon, "
         & "the stars and the clouds" TO TL-CASE
     MOVE "sun 1 moon 1 stars 1 clouds 1 pipes 2/2/1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The sun is straight below at midnight (angle 180: the centre (0, 100, 0) goes to (0, -100, 0)) and the moon straight above: looking
*>   straight up (pitch -90) the moon's centre is on the view axis, 100 blocks ahead, and the sun's is behind the camera.
     MOVE -90 TO PL-PITCH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE MESH-SLOT-MOON TO WS-SLOT
     PERFORM FIND-DRAW
     PERFORM CENTRE-CLIP
     MOVE "acceptance sky: given midnight when the Player looks straight up then the moon's centre is on the view axis (clip x/w, y/w 0, w 100)"
         TO TL-CASE
     PERFORM CLIP-TEXT
     MOVE "0.00 0.00 100.00" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE MESH-SLOT-SUN TO WS-SLOT
     PERFORM FIND-DRAW
     PERFORM CENTRE-CLIP
     MOVE "acceptance sky: given midnight when the Player looks straight up then the sun's centre is behind the camera (clip w -100)"
         TO TL-CASE
     PERFORM CLIP-TEXT
     MOVE "behind -100.00" TO TL-EXPECTED
     IF WS-I > 0 AND WS-CLIP(4) < -99 AND WS-CLIP(4) > -101
         MOVE "behind -100.00" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Noon: the sun is the one overhead.
     MOVE 6000 TO PL-TIME
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE MESH-SLOT-SUN TO WS-SLOT
     PERFORM FIND-DRAW
     PERFORM CENTRE-CLIP
     MOVE "acceptance sky: given noon when the Player looks straight up then the sun's centre is on the view axis, 100 blocks ahead"
         TO TL-CASE
     PERFORM CLIP-TEXT
     MOVE "0.00 0.00 100.00" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Sunrise (tick 0): the sun is in the east (+x): looking east (yaw -90) at the horizon (pitch 0) it is about on the view axis.
     MOVE 0 TO PL-TIME
     MOVE -90 TO PL-YAW
     MOVE 0 TO PL-PITCH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE MESH-SLOT-SUN TO WS-SLOT
     PERFORM FIND-DRAW
     PERFORM CENTRE-CLIP
     MOVE "acceptance sky: given tick 0 when the Player looks east at the horizon then the sun is ahead, over the east horizon "
         & "(the track's ease puts it some degrees up), 100 blocks away" TO TL-CASE
     PERFORM CLIP-TEXT
     MOVE "ahead" TO TL-EXPECTED
     IF WS-I > 0 AND WS-CLIP(4) > 90 AND WS-CLIP(4) < 101
         COMPUTE WS-F = FUNCTION ABS(WS-CLIP(1) / WS-CLIP(4))
         IF WS-F < 0.05
             COMPUTE WS-F = FUNCTION ABS(WS-CLIP(2) / WS-CLIP(4))
             IF WS-F < 0.5
                 MOVE "ahead" TO TL-OBSERVED
             END-IF
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The clouds: the layer's bottom at 192.33 above the world, the eye at PL-Y + 1.62 or its pose height; the camera at (0.5, z 0.5) in
*>   cloud space (x + 0.5, z + 0.5 + 3.96) with the game time 0: the mesh origin is the camera's cell corner, (-0.5, -4.46) from the eye.
     MOVE 6000 TO PL-TIME
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 0 TO PL-GAME-TIME
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE MESH-SLOT-CLOUDS TO WS-SLOT
     PERFORM FIND-DRAW
     MOVE "acceptance sky: given a camera facing +z when the clouds are drawn then the layer origin is (-fx, 192.33 - eye, -fz) from "
         & "the eye, fx and fz the camera's place in its cloud cell (12 section 3.6): the draw matrix column 4" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     IF WS-I = 0
         MOVE "no draw" TO TL-OBSERVED
     ELSE
         COMPUTE WS-EXPECT = FUNCTION MOD(PL-GAME-TIME, 102400) * 0.03
         COMPUTE WS-CX = PL-X + WS-EXPECT
         COMPUTE WS-CZ = PL-Z + WS-EXPECT * 0 + 3.96
         COMPUTE WS-CELL-X = FUNCTION INTEGER(WS-CX / 12)
         COMPUTE WS-CELL-Z = FUNCTION INTEGER(WS-CZ / 12)
         COMPUTE WS-EXPECT = RL-PROJ(1) * (WS-CX - WS-CELL-X * 12)
         COMPUTE WS-E1 ROUNDED = WS-EXPECT
         COMPUTE WS-E2 ROUNDED = RL-D-MATRIX(WS-I, 13)
         COMPUTE WS-EXPECT = RL-PROJ(6) * (192.33 - (PL-Y + 1.6))
         COMPUTE WS-E3 ROUNDED = WS-EXPECT
         COMPUTE WS-E4 ROUNDED = RL-D-MATRIX(WS-I, 14)
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-EXPECTED
         STRING FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   renderClouds "fast": one flat quad a cell, fewer vertices than the boxes of "true" (fancy); "false": none.
     MOVE "renderClouds" TO WS-NAME
     MOVE SPACES TO WS-VALUE
     MOVE '"fast"' TO WS-VALUE
     MOVE 6 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-OK
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) = MESH-SLOT-CLOUDS
             MOVE RL-U-COUNT(WS-I) TO WS-FAST
         END-IF
     END-PERFORM
     MOVE "acceptance sky: given renderClouds fast when the clouds are drawn then the mesh is one quad a cell and smaller than the "
         & "fancy one (which was uploaded when the frames began)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE "fast < fancy" TO TL-EXPECTED
     IF WS-FAST > 0 AND WS-FAST < WS-FANCY AND FUNCTION MOD(WS-FAST, 6) = 0
         MOVE "fast < fancy" TO TL-OBSERVED
     ELSE
         MOVE WS-FAST TO WS-ED1
         MOVE WS-FANCY TO WS-ED2
         STRING "fast " WS-ED1 " fancy " WS-ED2 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE '"false"' TO WS-VALUE
     MOVE 7 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-OK
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance sky: given renderClouds false when the frame is built then there are no clouds and the sun and the moon stay"
         TO TL-CASE
     MOVE "sun 1 moon 1 stars 0 clouds 0 pipes 2/2/0" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '"true"' TO WS-VALUE
     MOVE 6 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-OK

*>   Under water the fog hides the sky: none drawn (the frame is built by itself: a step finds the eye's block again).
     MOVE 1 TO PL-EYE-WATER
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance sky: given the camera under water when the frame is built then no sky body and no cloud is drawn" TO TL-CASE
     MOVE "sun 0 moon 0 stars 0 clouds 0 pipes 0/0/0" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-EYE-WATER

*>   A dimension without sky light (the Nether, the End, cobolcraft:subroutine): none of it, by day or by night.
     MOVE 0 TO PL-HAS-SKY
     MOVE 18000 TO PL-TIME
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance sky: given a dimension without sky light (the Nether, the End) at midnight when the frame is built then no sun, "
         & "moon, star or cloud is drawn" TO TL-CASE
     MOVE "sun 0 moon 0 stars 0 clouds 0 pipes 0/0/0" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6000 TO PL-TIME
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance sky: given a dimension without sky light at noon when the frame is built then none is drawn either" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIND-DRAW.
     MOVE 0 TO WS-I
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-J) = WS-SLOT
             MOVE WS-J TO WS-I
         END-IF
     END-PERFORM.

*> The clip coordinates of the point (0, 100, 0) of the draw WS-I (the centre of a body's quad in its own frame) under its matrix.
 CENTRE-CLIP.
     MOVE 0 TO WS-V(1) WS-V(3)
     MOVE 100 TO WS-V(2)
     MOVE 1 TO WS-V(4)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
         MOVE 0 TO WS-CLIP(WS-J)
     END-PERFORM
     IF WS-I > 0
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             COMPUTE WS-CLIP(WS-J) = RL-D-MATRIX(WS-I, WS-J) * WS-V(1) + RL-D-MATRIX(WS-I, 4 + WS-J) * WS-V(2)
                 + RL-D-MATRIX(WS-I, 8 + WS-J) * WS-V(3) + RL-D-MATRIX(WS-I, 12 + WS-J) * WS-V(4)
         END-PERFORM
     END-IF.

 CLIP-TEXT.
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     IF WS-I = 0
         MOVE "no draw" TO TL-OBSERVED
     ELSE
         COMPUTE WS-E1 ROUNDED = WS-CLIP(1) / WS-CLIP(4) + 0.0001
         COMPUTE WS-E2 ROUNDED = WS-CLIP(2) / WS-CLIP(4) + 0.0001
         COMPUTE WS-E3 ROUNDED = WS-CLIP(4)
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 END PROGRAM ACC-SKY-DRAWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SKY-DRAWS.
*> USING CLIENT-STATE, text out: "sun <n> moon <n> stars <n> clouds <n> pipes <sun>/<moon>/<clouds>": the number of draws of each slot and the pipeline of the sun's, the moon's and the
*> clouds' last draw (0 when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   PIC 9 OCCURS 4 TIMES.
 01 WS-P                   PIC 9 OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO WS-N(WS-I) WS-P(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         EVALUATE RL-D-SLOT(WS-I)
             WHEN MESH-SLOT-SUN
                 ADD 1 TO WS-N(1)
                 MOVE RL-D-PIPELINE(WS-I) TO WS-P(1)
             WHEN MESH-SLOT-MOON
                 ADD 1 TO WS-N(2)
                 MOVE RL-D-PIPELINE(WS-I) TO WS-P(2)
             WHEN MESH-SLOT-STARS
                 ADD 1 TO WS-N(3)
             WHEN MESH-SLOT-CLOUDS
                 ADD 1 TO WS-N(4)
                 MOVE RL-D-PIPELINE(WS-I) TO WS-P(4)
         END-EVALUATE
     END-PERFORM
     MOVE SPACES TO L-TEXT
     STRING "sun " WS-N(1) " moon " WS-N(2) " stars " WS-N(3) " clouds " WS-N(4) " pipes " WS-P(1) "/" WS-P(2) "/" WS-P(4)
         DELIMITED BY SIZE INTO L-TEXT
     GOBACK.
 END PROGRAM TEST-SKY-DRAWS.
 COPY CLTEST.
