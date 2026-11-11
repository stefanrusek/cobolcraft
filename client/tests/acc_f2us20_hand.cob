*> Acceptance test US20-1, US20-2 (spec 002 FR-021; 12 §6): in first person the hand is in the render list at the lower right holding the
*> selected item or block as a small 3D model (36 vertices) after a depth clear; breaking (left button) starts the swing, which moves the model
*> forward and down and is over after 300 ms; an empty hand, third person and the inventory screen draw none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US20-HAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CLEAR-AT            BINARY-LONG.
 01 WS-HAND-AT             BINARY-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-REST-Z              FLOAT-LONG.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-SPRITE-SAVED        BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 2 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 01 WS-VT-LAYER            PIC XX VALUE "HD".
 01 WS-VT-OK               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 1 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 0 TO CL-SWING-AT
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE "acceptance US20-1 a block in the selected slot: the hand is a cube of 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-MINX WS-MAXY
     MOVE 9 TO WS-MINZ
     MOVE -9 TO WS-MAXY
     MOVE 9 TO WS-MINX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-HAND-COUNT
         MOVE FUNCTION MIN(WS-MINX, RL-HAND-X(WS-I)) TO WS-MINX
         MOVE FUNCTION MAX(WS-MAXY, RL-HAND-Y(WS-I)) TO WS-MAXY
         MOVE FUNCTION MIN(WS-MINZ, RL-HAND-Z(WS-I)) TO WS-MINZ
     END-PERFORM
     MOVE WS-MINZ TO WS-REST-Z
     MOVE "acceptance US20-1 the hand is at the lower right in front of the view (x > 0, y < 0, z < 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MINX > 0.2 AND WS-MAXY < -0.1 AND WS-MINZ < -0.9
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-CLEAR-AT WS-HAND-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = -1
             MOVE WS-I TO WS-CLEAR-AT
         END-IF
         IF RL-D-SLOT(WS-I) = MESH-SLOT-HAND
             MOVE WS-I TO WS-HAND-AT
         END-IF
     END-PERFORM
     MOVE "acceptance US20-1 the hand is drawn right after a depth clear (draw record slot -1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CLEAR-AT > 0 AND WS-HAND-AT = WS-CLEAR-AT + 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A flat item (the pry bar, item 10) is a thin icon: 36 vertices of thickness 0.02.
     MOVE 10 TO PL-SLOT-ITEM(PL-HELD + 1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "acceptance US20-1 a tool in the slot: a flat icon, 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-SLOT-ITEM(PL-HELD + 1)

*>   Breaking: the left button pressed starts the swing; half way through the model is 0.2 nearer to forward and 0.15 lower.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-BUTTON-LEFT TO WS-A(1)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-ONE
     MOVE "acceptance US20-2 when the left button is pressed then the swing starts (now)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CL-SWING-AT = CL-NOW-MS AND CL-SWING-AT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE CL-NOW-MS = CL-SWING-AT + 150
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 9 TO WS-MINZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-HAND-COUNT
         MOVE FUNCTION MIN(WS-MINZ, RL-HAND-Z(WS-I)) TO WS-MINZ
     END-PERFORM
     MOVE "acceptance US20-2 half way through the swing the hand is 0.2 further forward" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MINZ < WS-REST-Z - 0.15
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE CL-NOW-MS = CL-SWING-AT + 300
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 9 TO WS-MINZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-HAND-COUNT
         MOVE FUNCTION MIN(WS-MINZ, RL-HAND-Z(WS-I)) TO WS-MINZ
     END-PERFORM
     MOVE "acceptance US20-2 after 300 ms the swing is over, the hand is back at rest" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MINZ > WS-REST-Z - 0.001 AND WS-MINZ < WS-REST-Z + 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Right button on a target (placing) swings too; an empty hand, third person and the inventory screen draw none.
     MOVE 0 TO CL-SWING-AT
     MOVE 1 TO TG-HIT
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-BUTTON-RIGHT TO WS-A(1)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-ONE
     MOVE "acceptance US20-2 when the right button is pressed on a target (placing) then the swing starts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CL-SWING-AT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SLOT-COUNT(PL-HELD + 1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "acceptance US20-1 an empty hand draws no model" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 1 TO CL-CAMERA
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "acceptance US20-1 third person draws no hand" TO TL-CASE
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-CAMERA
     MOVE SCR-INVENTORY TO SM-SCREEN
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "acceptance US20-1 the inventory screen draws no hand" TO TL-CASE
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 255 TO PL-SLOT-ITEM(PL-HELD + 1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "acceptance US20-1 an item outside the registry draws no model" TO TL-CASE
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE IT-SPRITE(2) TO WS-SPRITE-SAVED
     MOVE 0 TO IT-SPRITE(2)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "acceptance US20-1 an item whose icon is not loaded draws no model" TO TL-CASE
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SPRITE-SAVED TO IT-SPRITE(2)
*>   The swing ends at 300 ms and stays over (not a second, mirrored swing), and a click on the inventory screen starts none.
     MOVE 1 TO CL-SWING-AT
     COMPUTE CL-NOW-MS = CL-SWING-AT + 450
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 9 TO WS-MINZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-HAND-COUNT
         MOVE FUNCTION MIN(WS-MINZ, RL-HAND-Z(WS-I)) TO WS-MINZ
     END-PERFORM
     MOVE "acceptance US20-2 450 ms after the start the hand is at rest" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MINZ > WS-REST-Z - 0.001 AND WS-MINZ < WS-REST-Z + 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-SWING-AT
     MOVE SCR-INVENTORY TO SM-SCREEN
     MOVE 1 TO IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1)
     CALL "HAND-INPUT" USING CLIENT-STATE
     MOVE "acceptance US20-2 a left click on the inventory screen starts no swing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-SWING-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-VERTEX-TINTS" USING CLIENT-STATE WS-VT-LAYER WS-VT-OK
     MOVE "tint channel every vertex of the hand is untinted white (1, 1, 1) and has no sky term"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VT-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US20-HAND.

 COPY CLTEST.
