*> Acceptance test US17 (spec 002 FR-018; 13 section 5.1 F3+B, 34-1 section 7.5 hitbox display): F3 with B toggles the entity hitboxes and
*> swallows the overlay toggle (F3 released after a combination does not toggle the overlay; F3 alone still does, on release); with the
*> hitboxes on the render list draws the hitbox mesh (translucent, UI swatch). The mesh: per entity a white outline box (144 vertices) of the
*> bounding box, for a living entity a red thin box at the eye height (eye +- 0.01), vertex positions eye-relative; boats, minecarts, crystals
*> and loose items have no eye box; entities without a known box have none; a box that does not fit is left out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US17-HITBOXES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DRAW-PIPE           BINARY-LONG.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 4 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 01 WS-N                   BINARY-LONG.
 01 WS-EV-KIND             BINARY-LONG.
 01 WS-EV-KEY              BINARY-LONG.
 01 WS-F3                  BINARY-LONG VALUE CC-KEY-F3.
 01 WS-KB                  BINARY-LONG VALUE CC-KEY-B.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-RED                 FLOAT-SHORT.
 01 WS-GREEN               FLOAT-SHORT.
 01 WS-BLUE                FLOAT-SHORT.
 01 WS-HITS                BINARY-LONG.
 01 WS-MIN                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-MAX                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E                   PIC -9.99.
 01 WS-NUM                 PIC Z(4)9.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LO-TABLE.
    05 WS-LO               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HI-TABLE.
    05 WS-HI               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-RGB-TABLE.
    05 WS-RGB              FLOAT-SHORT OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US17 given the world screen when nothing was pressed then the hitboxes are off" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-HITBOXES TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   B alone does nothing.
     MOVE CC-EV-KEY-DOWN TO WS-EV-KIND
     MOVE WS-KB TO WS-EV-KEY
     MOVE 0 TO WS-N
     PERFORM ADD-EVENT
     MOVE CC-EV-KEY-UP TO WS-EV-KIND
     PERFORM ADD-EVENT
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     MOVE "acceptance US17 when B is pressed without F3 then the hitboxes stay off" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-HITBOXES TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   F3 down, B down, B up, F3 up within one frame.
     PERFORM F3-B-TAP
     MOVE "acceptance US17 when F3+B is pressed then the hitboxes are on and the overlay did not toggle (hitboxes 1 overlay 0)"
         TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CL-HITBOXES * 10 + CL-DEBUG
     PERFORM ASSERT-N
*>   F3 held over three frames: F3 down; B tapped; F3 up. B toggles back, the release does not toggle the overlay.
     MOVE CC-EV-KEY-DOWN TO WS-EV-KIND
     MOVE WS-F3 TO WS-EV-KEY
     MOVE 0 TO WS-N
     PERFORM ADD-EVENT
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     MOVE "acceptance US17 given F3 is held when no other key came then nothing toggled yet (hitboxes 1 overlay 0)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CL-HITBOXES * 10 + CL-DEBUG
     PERFORM ASSERT-N
     MOVE CC-EV-KEY-DOWN TO WS-EV-KIND
     MOVE WS-KB TO WS-EV-KEY
     MOVE 0 TO WS-N
     PERFORM ADD-EVENT
     MOVE CC-EV-KEY-UP TO WS-EV-KIND
     PERFORM ADD-EVENT
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     MOVE CC-EV-KEY-UP TO WS-EV-KIND
     MOVE WS-F3 TO WS-EV-KEY
     MOVE 0 TO WS-N
     PERFORM ADD-EVENT
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     MOVE "acceptance US17 when B is pressed while F3 is held and F3 is released later then the hitboxes are off and the overlay "
         & "stayed off (0 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CL-HITBOXES * 10 + CL-DEBUG
     PERFORM ASSERT-N
*>   F3 alone toggles the overlay on release.
     MOVE CC-EV-KEY-DOWN TO WS-EV-KIND
     MOVE WS-F3 TO WS-EV-KEY
     MOVE 0 TO WS-N
     PERFORM ADD-EVENT
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     MOVE "acceptance US17 given F3 is held when it has not been released then the overlay is still off" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-DEBUG TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE CC-EV-KEY-UP TO WS-EV-KIND
     MOVE 0 TO WS-N
     PERFORM ADD-EVENT
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     MOVE "acceptance US17 when F3 is released without a combination then the overlay is on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CL-DEBUG TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "TEST-KEY" USING CLIENT-STATE WS-F3
     MOVE "acceptance US17 when F3 is tapped again then the overlay is off" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-DEBUG TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   With the hitboxes on and one sodgrazer in view the render list draws the hitbox mesh; with them off it does not.
     INITIALIZE EN-ENTITY(1)
     MOVE 1 TO EN-COUNT
     MOVE 1 TO EN-USED(1)
     MOVE 77 TO EN-ID(1)
     MOVE 2 TO EN-TYPE(1)
     MOVE 0.5 TO EN-X(1)
     MOVE 10 TO EN-Y(1)
     MOVE 4.5 TO EN-Z(1)
     PERFORM F3-B-TAP
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM FIND-DRAW
     MOVE "acceptance US17 given hitboxes on and a sodgrazer in front when a frame is built then the hitbox mesh (288 vertices) "
         & "is drawn on the translucent pipeline" TO TL-CASE
     MOVE 1288 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-HB-COUNT + 1000 * FUNCTION MIN(WS-DRAW, 1)
     PERFORM ASSERT-N
     MOVE "acceptance US17 the hitbox mesh uses the translucent pipeline" TO TL-CASE
     MOVE CC-PIPE-TRANSLUCENT TO TL-EXPECTED-N
     MOVE WS-DRAW-PIPE TO TL-OBSERVED-N
     PERFORM ASSERT-N
     PERFORM F3-B-TAP
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM FIND-DRAW
     MOVE "acceptance US17 given hitboxes off then no hitbox mesh is drawn" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-HB-COUNT + WS-DRAW
     PERFORM ASSERT-N

*>   The mesh itself; the eye of the test world is (0.5, 11.6, 0.5).
     MOVE 0.5 TO WS-EYE(1)
     MOVE 11.6 TO WS-EYE(2)
     MOVE 0.5 TO WS-EYE(3)
     CALL "HITBOX-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1 TO WS-FROM
     MOVE 144 TO WS-TO
     PERFORM BOUNDS
     MOVE "acceptance US17 a sodgrazer (0.9 x 0.9) at (0.5, 10, 4.5): the white box spans x -0.45..0.45, y -1.60..-0.70, z 3.55..4.45 eye-relative"
         TO TL-CASE
     MOVE "-0.45 -1.60 3.55 0.45 -0.70 4.45" TO TL-EXPECTED
     PERFORM ASSERT-BOUNDS
     MOVE 1 TO WS-RED
     MOVE 1 TO WS-GREEN
     MOVE 1 TO WS-BLUE
     PERFORM COUNT-COLOUR
     MOVE "acceptance US17 all 144 vertices of the entity box are white" TO TL-CASE
     MOVE 144 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 145 TO WS-FROM
     MOVE 288 TO WS-TO
     PERFORM BOUNDS
     MOVE "acceptance US17 the sodgrazer's eye box (eye 0.7) spans y -0.91..-0.89 over the same x and z" TO TL-CASE
     MOVE "-0.45 -0.91 3.55 0.45 -0.89 4.45" TO TL-EXPECTED
     PERFORM ASSERT-BOUNDS
     MOVE 1 TO WS-RED
     MOVE 0 TO WS-GREEN
     MOVE 0 TO WS-BLUE
     PERFORM COUNT-COLOUR
     MOVE "acceptance US17 all 144 vertices of the eye box are red" TO TL-CASE
     MOVE 144 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE "acceptance US17 a sodgrazer has two boxes (288 vertices)" TO TL-CASE
     MOVE 288 TO TL-EXPECTED-N
     MOVE RL-HB-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   A loose item (0.25 x 0.25): the box only, no eye box.
     MOVE 2 TO EN-COUNT
     INITIALIZE EN-ENTITY(2)
     MOVE 1 TO EN-USED(2)
     MOVE 1 TO EN-TYPE(2)
     MOVE 2.5 TO EN-X(2)
     MOVE 10 TO EN-Y(2)
     MOVE 4.5 TO EN-Z(2)
     CALL "HITBOX-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance US17 a loose item adds one box (432 vertices in all), no eye box" TO TL-CASE
     MOVE 432 TO TL-EXPECTED-N
     MOVE RL-HB-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 289 TO WS-FROM
     MOVE 432 TO WS-TO
     PERFORM BOUNDS
     MOVE "acceptance US17 the loose item box spans x 1.875..2.125, y -1.60..-1.35, z 3.875..4.125" TO TL-CASE
     MOVE "1.88 -1.60 3.88 2.13 -1.35 4.13" TO TL-EXPECTED
     PERFORM ASSERT-BOUNDS

*>   A cow of a standard world: its registry box, eye 0.85 x 1.4 = 1.19.
     MOVE 3 TO EN-COUNT
     PERFORM VANILLA-ROW-3
     MOVE "cow" TO EN-KEY(3)
     MOVE 0.45 TO EN-BOX-HALF(3)
     MOVE 1.4 TO EN-BOX-HEIGHT(3)
     MOVE -2.5 TO EN-X(3)
     MOVE 0.5 TO EN-Z(3)
     CALL "HITBOX-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 577 TO WS-FROM
     MOVE 720 TO WS-TO
     PERFORM BOUNDS
     MOVE "acceptance US17 a cow (0.9 x 1.4, default eye 0.85 x height) has a box and an eye box at y -0.42..-0.40" TO TL-CASE
     MOVE "-3.45 -0.42 -0.45 -2.55 -0.40 0.45" TO TL-EXPECTED
     PERFORM ASSERT-BOUNDS
     MOVE "acceptance US17 the cow adds two boxes (720 vertices in all)" TO TL-CASE
     MOVE 720 TO TL-EXPECTED-N
     MOVE RL-HB-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   A boat is not living: one box.
     MOVE 4 TO EN-COUNT
     INITIALIZE EN-ENTITY(4)
     MOVE 1 TO EN-USED(4)
     MOVE 1 TO EN-VANILLA(4)
     MOVE "oak_boat" TO EN-KEY(4)
     MOVE 1 TO EN-BOX-ATTACK(4)
     MOVE 0.7 TO EN-BOX-HALF(4)
     MOVE 0.5 TO EN-BOX-HEIGHT(4)
     CALL "HITBOX-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance US17 a boat has a box and no eye box (864 vertices in all)" TO TL-CASE
     MOVE 864 TO TL-EXPECTED-N
     MOVE RL-HB-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   A player: eye 1.62 (0.6 x 1.8 at the feet y 10: eye box y 0.01..0.03 above the camera).
     MOVE 5 TO EN-COUNT
     INITIALIZE EN-ENTITY(5)
     MOVE 1 TO EN-USED(5)
     MOVE 1 TO EN-VANILLA(5)
     MOVE "player" TO EN-KEY(5)
     MOVE 1 TO EN-BOX-ATTACK(5)
     MOVE 0.3 TO EN-BOX-HALF(5)
     MOVE 1.8 TO EN-BOX-HEIGHT(5)
     MOVE 10 TO EN-Y(5)
     CALL "HITBOX-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1009 TO WS-FROM
     MOVE 1152 TO WS-TO
     PERFORM BOUNDS
     MOVE "acceptance US17 a player (eye 1.62) has its eye box at y 0.01..0.03 and the count is 1152" TO TL-CASE
     MOVE "-0.30 0.01 -0.30 0.30 0.03 0.30" TO TL-EXPECTED
     PERFORM ASSERT-BOUNDS
     MOVE 1152 TO TL-EXPECTED-N
     MOVE RL-HB-COUNT TO TL-OBSERVED-N
     MOVE "acceptance US17 the player's two boxes bring the mesh to 1152 vertices" TO TL-CASE
     PERFORM ASSERT-N

*>   Without a box: a registry row with no size, a stand-in type outside the table, an unused row.
     MOVE 8 TO EN-COUNT
     INITIALIZE EN-ENTITY(6) EN-ENTITY(7) EN-ENTITY(8)
     MOVE 1 TO EN-USED(6)
     MOVE 1 TO EN-VANILLA(6)
     MOVE 1 TO EN-USED(7)
     MOVE 9 TO EN-TYPE(7)
     MOVE 1 TO EN-TYPE(8)
     CALL "HITBOX-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance US17 a row without a registry size, a stand-in type outside the table and an unused row have no box" TO TL-CASE
     MOVE 1152 TO TL-EXPECTED-N
     MOVE RL-HB-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-N

*>   Capacity: a box that does not fit is left out.
     COMPUTE RL-HB-COUNT = CL-MAX-HB-VERTICES - 143
     MOVE -1 TO WS-LO(1) WS-LO(2) WS-LO(3)
     MOVE 1 TO WS-HI(1) WS-HI(2) WS-HI(3)
     MOVE 1 TO WS-RGB(1) WS-RGB(2) WS-RGB(3)
     CALL "HITBOX-BOX" USING CLIENT-STATE WS-LO-TABLE WS-HI-TABLE WS-RGB-TABLE
     COMPUTE TL-EXPECTED-N = CL-MAX-HB-VERTICES - 143
     MOVE RL-HB-COUNT TO TL-OBSERVED-N
     MOVE "acceptance US17 a box that would pass the capacity of the hitbox mesh is not added" TO TL-CASE
     PERFORM ASSERT-N
     STOP RUN.

 VANILLA-ROW-3.
     INITIALIZE EN-ENTITY(3)
     MOVE 1 TO EN-USED(3)
     MOVE 1 TO EN-VANILLA(3)
     MOVE 1 TO EN-BOX-ATTACK(3)
     MOVE 10 TO EN-Y(3).

 ADD-EVENT.
     ADD 1 TO WS-N
     MOVE WS-EV-KIND TO WS-KIND(WS-N)
     MOVE WS-EV-KEY TO WS-A(WS-N).

 F3-B-TAP.
     MOVE CC-EV-KEY-DOWN TO WS-EV-KIND
     MOVE WS-F3 TO WS-EV-KEY
     MOVE 0 TO WS-N
     PERFORM ADD-EVENT
     MOVE WS-KB TO WS-EV-KEY
     PERFORM ADD-EVENT
     MOVE CC-EV-KEY-UP TO WS-EV-KIND
     PERFORM ADD-EVENT
     MOVE WS-F3 TO WS-EV-KEY
     PERFORM ADD-EVENT
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N.

 FIND-DRAW.
     MOVE 0 TO WS-DRAW WS-DRAW-PIPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-HITBOX
             MOVE WS-I TO WS-DRAW
             MOVE RL-D-PIPELINE(WS-I) TO WS-DRAW-PIPE
         END-IF
     END-PERFORM.

*> Min and max of x, y, z over the vertices WS-FROM to WS-TO, as text "minx miny minz maxx maxy maxz" in TL-OBSERVED.
 BOUNDS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE 1000 TO WS-MIN(WS-I)
         MOVE -1000 TO WS-MAX(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM WS-FROM BY 1 UNTIL WS-I > WS-TO
         MOVE FUNCTION MIN(WS-MIN(1), RL-HB-X(WS-I)) TO WS-MIN(1)
         MOVE FUNCTION MIN(WS-MIN(2), RL-HB-Y(WS-I)) TO WS-MIN(2)
         MOVE FUNCTION MIN(WS-MIN(3), RL-HB-Z(WS-I)) TO WS-MIN(3)
         MOVE FUNCTION MAX(WS-MAX(1), RL-HB-X(WS-I)) TO WS-MAX(1)
         MOVE FUNCTION MAX(WS-MAX(2), RL-HB-Y(WS-I)) TO WS-MAX(2)
         MOVE FUNCTION MAX(WS-MAX(3), RL-HB-Z(WS-I)) TO WS-MAX(3)
     END-PERFORM
     MOVE SPACES TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     COMPUTE WS-E ROUNDED = WS-MIN(1)
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 3
         COMPUTE WS-E ROUNDED = WS-MIN(WS-I)
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-E ROUNDED = WS-MAX(WS-I)
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM.

 ASSERT-BOUNDS.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE.

*> How many vertices of WS-FROM to WS-TO carry the tint WS-RED, WS-GREEN, WS-BLUE with brightness 1 and alpha 1.
 COUNT-COLOUR.
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM WS-FROM BY 1 UNTIL WS-I > WS-TO
         IF RL-HB-R(WS-I) = WS-RED AND RL-HB-G(WS-I) = WS-GREEN AND RL-HB-BLUE(WS-I) = WS-BLUE
             AND RL-HB-B(WS-I) = 1 AND RL-HB-A(WS-I) = 1 AND RL-HB-SKY(WS-I) = 0
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US17-HITBOXES.
 COPY CLTEST.
