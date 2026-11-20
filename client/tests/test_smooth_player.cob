*> Implementation test of lane bugsmooth (T60700-T60705; docs/protocol/53 section 7 (the camera eye lerps), section 15.2 (partial tick), 12 section 7.2 (the field of
*> view lerps): "despite 60 fps there is a little bit of jumpiness while moving around"): the local player moves once per 50 ms client tick, so the eye, the
*> field of view and the own model must be placed at lerp(partial, state one tick ago, state now) in the frames between ticks (smooth.cob, camera.cob,
*> render-list.cob). The eye, the field of view and the figure at partial 0, 0.5 and 1; the tick's own state when interpolation is off (CL-INTERP 0, what every other
*> client test runs with); no lerp across a join or a teleport; frames between ticks (a 60 fps clock against 20 Hz ticks) move the world draws every frame;
*> the wall clock of the frame loop has a resolution finer than the 10 ms of CURRENT-DATE.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SMOOTH-PLAYER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-TICKS               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-FRAME               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-DRAW-CHANGED        BINARY-LONG.
 01 WS-LAST                FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-MAX-STEP            FLOAT-LONG.
 01 WS-LAST-DRAW           FLOAT-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 FILLER              PIC X(16).
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-SAMPLE              BINARY-DOUBLE.
 01 WS-ODD                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-EDIT                PIC -(4)9.9(4).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO CL-INTERP
     MOVE 1.6 TO PL-OEYE
     MOVE 1.25 TO PL-EYE
     MOVE 1 TO PL-OSET
     MOVE 1.0 TO PL-OX
     MOVE 10 TO PL-OY PL-Y
     MOVE 3.0 TO PL-OZ
     MOVE 1.28 TO PL-X
     MOVE 3.28 TO PL-Z
     MOVE 0 TO CL-PARTIAL
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE "smooth: at partial 0 the eye is where the player stood a tick ago (x 1.0, y 10 + 1.6, z 3.0)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1.0000/11.6000/3.0000" TO TL-EXPECTED
     PERFORM EYE-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO CL-PARTIAL
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE "smooth: at partial 0.5 a player at 0.28 blocks a tick is half way (x 1.14, z 3.14) and the eye height half way (1.425)" TO TL-CASE
     MOVE "1.1400/11.4250/3.1400" TO TL-EXPECTED
     PERFORM EYE-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-PARTIAL
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE "smooth: at partial 1 the eye is the tick's own (x 1.28, y 10 + 1.25, z 3.28)" TO TL-CASE
     MOVE "1.2800/11.2500/3.2800" TO TL-EXPECTED
     PERFORM EYE-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.25 TO CL-PARTIAL
     MOVE 0 TO PL-OSET
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE "smooth: with no state one tick ago (a join or a teleport) the eye is the current one at any partial" TO TL-CASE
     MOVE "1.2800/11.2500/3.2800" TO TL-EXPECTED
     PERFORM EYE-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-OSET
     MOVE 0 TO PL-OEYE
     MOVE 0.5 TO CL-PARTIAL
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE "smooth: an eye height not set one tick ago (0) is not lerped from 0 (x half way, y with the current eye 1.25)" TO TL-CASE
     MOVE "1.1400/11.2500/3.1400" TO TL-EXPECTED
     PERFORM EYE-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The look direction stays the per-frame one (the mouse turns every frame): never lerped.
     MOVE 33 TO PL-YAW
     MOVE 12 TO PL-PITCH
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE "smooth: the view yaw and pitch are the current ones (turned every frame by the mouse)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 3312 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-YAW * 100 + WS-PITCH
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The tick clock: the frame is the part of the 50 ms tick it falls in (CL-NEXT-TICK is when the next tick is due).
     MOVE 1000000 TO CL-NOW-MS
     MOVE 1000050 TO CL-NEXT-TICK
     CALL "SMOOTH-PARTIAL" USING CLIENT-STATE
     MOVE "smooth: a frame at the tick that just ran (next tick 50 ms away) is at partial 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = CL-PARTIAL * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000030 TO CL-NOW-MS
     CALL "SMOOTH-PARTIAL" USING CLIENT-STATE
     MOVE "smooth: 30 ms into the tick is at partial 0.6" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = CL-PARTIAL * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000120 TO CL-NOW-MS
     CALL "SMOOTH-PARTIAL" USING CLIENT-STATE
     MOVE "smooth: a tick that is overdue (a paused world) shows the tick's own state, partial 1" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = CL-PARTIAL * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-INTERP
     MOVE 1000000 TO CL-NOW-MS
     CALL "SMOOTH-PARTIAL" USING CLIENT-STATE
     MOVE "smooth: with interpolation off the frame is always at partial 1" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = CL-PARTIAL * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Frames at 60 fps (17, 17, 16 ms) against 20 Hz ticks, W held: with interpolation the eye, and with it every section draw's offset from the eye, changes
*>   every frame, by at most a third of a tick's walk; without it the world stands still for two frames of three.
     MOVE 1 TO WS-I
     PERFORM MEASURE-FRAMES
     MOVE "smooth: walking frames at 60 fps with interpolation on: the eye z changes in all 30 frames" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 30 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "smooth: ... and so does the translation of the section draws (the view is camera relative)" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE WS-DRAW-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "smooth: ... by at most 0.08 blocks a frame (a tick walks 0.2, 17 ms is a third of it)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAX-STEP < 0.08
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "BENCH smooth player: frames with a new eye position of 30, interpolation on: " WS-CHANGED
         " largest step " WS-MAX-STEP
     MOVE 0 TO WS-I
     PERFORM MEASURE-FRAMES
     DISPLAY "BENCH smooth player: frames with a new eye position of 30, interpolation off: " WS-CHANGED
         " largest step " WS-MAX-STEP
     MOVE "smooth: the same walk with interpolation off changes the eye in 10 of 30 frames only (once a tick)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The field of view modifier (sprinting) lerps too: half way between 1.0 and 1.2 is 1.1 (a vertical field of 70 x 1.1 = 77 degrees).
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO CL-INTERP
     MOVE 1 TO PL-OSET
     MOVE 1.0 TO PL-OFOV
     MOVE 1.2 TO PL-FOV-MOD
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     MOVE 1.0 TO PL-OFOV
     MOVE 1.2 TO PL-FOV-MOD
     MOVE 25 TO WS-MS
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ZERO WS-MS
     COMPUTE WS-F = 1 / FUNCTION TAN(77 / 2 * FUNCTION PI / 180)
     COMPUTE WS-DIFF = FUNCTION ABS(0 - RL-PROJ(6) - WS-F)
     MOVE "smooth: half way through a tick the projection uses the field of view modifier half way between the old 1.0 and the new 1.2 (77 degrees)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A teleport (Player Position) or a join has no old state: the next frames are not lerped from where the player was.
     MOVE 1 TO PL-OSET
     MOVE 1 TO WS-CONN
     MOVE "contract/fixtures/wire/play-s2c-49-player-position.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "smooth: a Player Position (teleport) clears the state of one tick ago, so the view does not slide from the old place" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-OSET TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-OSET
     CALL "DIMENSION-ENTER" USING CLIENT-STATE
     MOVE "smooth: entering a dimension (join, respawn) clears it too" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-OSET TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The frame loop's clock: milliseconds, not the 10 ms steps of CURRENT-DATE (a frame time quantised to 10 ms makes the partial tick jitter by 0.2).
     MOVE 0 TO WS-ODD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "CL-CLOCK" USING WS-SAMPLE
         IF FUNCTION MOD(WS-SAMPLE, 10) NOT = 0
             ADD 1 TO WS-ODD
         END-IF
         CALL "TEST-SLEEP"
     END-PERFORM
     MOVE "smooth: the frame clock has millisecond resolution (most of 40 samples about 10 ms apart are not multiples of 10 ms)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ODD > 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 EYE-TEXT.
     MOVE SPACES TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = WS-EYE(1)
     STRING FUNCTION TRIM(WS-EDIT) "/" DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = WS-EYE(2)
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-EDIT) "/" DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = WS-EYE(3)
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED.

*> Walks forward (+Z) for 10 ticks to settle, then 30 frames of 17, 17, 16 ms; WS-I is CL-INTERP. Counts the frames whose eye z (CAMERA-PLACE) and whose first world
*> draw's matrix translation z differ from the frame before, and the largest eye step.
 MEASURE-FRAMES.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE WS-I TO CL-INTERP
     INITIALIZE WS-EVENT
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     MOVE CC-KEY-W TO WS-A
     MOVE 17 TO WS-MS
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE WS-MS
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE WS-EYE(3) TO WS-LAST
     PERFORM DRAW-SUM
     MOVE WS-DRAW TO WS-LAST-DRAW
     MOVE 0 TO WS-CHANGED WS-DRAW-CHANGED WS-MAX-STEP
     PERFORM VARYING WS-FRAME FROM 1 BY 1 UNTIL WS-FRAME > 30
         EVALUATE FUNCTION MOD(WS-FRAME, 3)
             WHEN 0
                 MOVE 16 TO WS-MS
             WHEN OTHER
                 MOVE 17 TO WS-MS
         END-EVALUATE
         CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ZERO WS-MS
         CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
         COMPUTE WS-STEP = FUNCTION ABS(WS-EYE(3) - WS-LAST)
         IF WS-STEP > 0.000001
             ADD 1 TO WS-CHANGED
         END-IF
         IF WS-STEP > WS-MAX-STEP
             MOVE WS-STEP TO WS-MAX-STEP
         END-IF
         MOVE WS-EYE(3) TO WS-LAST
         PERFORM DRAW-SUM
         IF FUNCTION ABS(WS-DRAW - WS-LAST-DRAW) > 0.000001
             ADD 1 TO WS-DRAW-CHANGED
         END-IF
         MOVE WS-DRAW TO WS-LAST-DRAW
     END-PERFORM.

*> The sum of the z translations of the section draws of the frame's render list.
 DRAW-SUM.
     MOVE 0 TO WS-DRAW
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-J) >= MESH-SLOT-BASE AND RL-D-SLOT(WS-J) < MESH-SLOT-ENTITIES
             ADD RL-D-MATRIX(WS-J, 15) TO WS-DRAW
         END-IF
     END-PERFORM.
 END PROGRAM TEST-SMOOTH-PLAYER.
 COPY CLTEST.
