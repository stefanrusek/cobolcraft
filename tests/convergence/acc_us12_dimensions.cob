*> Convergence acceptance test of US12-1 to US12-4 and SC-012 (spec.md US12; standin-content §15
*> extra dimensions: the Subroutine, its generator, travel by goto_pad; FR-009 extra-dimensions): two
*> survival Players in one single-player world (the host's in-process core, the second client over a
*> further memory connection). The host's items, health and food are set with operator commands
*> (empty, supply, vitality, ration); everything else goes through the clients' controls: a goto_pad
*> placed and used with the right button, blocks placed, the pause menu's Disconnect and Quit World.
*> Outcomes are read from the clients: dimension name, position, sky, world replica, inventory
*> replica, health, food, game mode.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-DIMENSIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us12-dimensions".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Dimensions".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 10.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-WHO                 BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-RIGHT.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-BUTTON-UP.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BEFORE              PIC X(1024).
 01 WS-AFTER               PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED
     MOVE "/empty Alice" TO WS-LINE
     MOVE 12 TO WS-LINE-LENGTH
     PERFORM ALICE-SAYS
     MOVE "/supply Alice goto_pad 2" TO WS-LINE
     MOVE 24 TO WS-LINE-LENGTH
     PERFORM ALICE-SAYS
     MOVE "/supply Alice greystone 10" TO WS-LINE
     MOVE 26 TO WS-LINE-LENGTH
     PERFORM ALICE-SAYS
     MOVE "/supply Alice lucite 5" TO WS-LINE
     MOVE 22 TO WS-LINE-LENGTH
     PERFORM ALICE-SAYS
     MOVE "/vitality Alice 20" TO WS-LINE
     MOVE 18 TO WS-LINE-LENGTH
     PERFORM ALICE-SAYS
     MOVE "/ration Alice 15" TO WS-LINE
     MOVE 16 TO WS-LINE-LENGTH
     PERFORM ALICE-SAYS
*>   Bobby steps out of Alice's view (both start on the spawn point, inside each other's box).
     MOVE "/relocate Bobby at 2 56 12" TO WS-LINE
     MOVE 26 TO WS-LINE-LENGTH
     PERFORM ALICE-SAYS
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

*>   Alice places the goto_pad (held slot 0) on the turf two blocks ahead, at (6, 54, 8).
     MOVE WS-ALICE TO WS-WHO
     MOVE 6.5 TO WS-TX
     MOVE 53.99 TO WS-TY
     MOVE 8.5 TO WS-TZ
     PERFORM USE-AT
     MOVE "US12-1 setup given Alice holding a goto_pad when she uses it on the ground then both "
         & "Players see the goto_pad at (6, 54, 8)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Alice 16 Bobby 16" TO TL-EXPECTED
     MOVE 6 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E1
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "Alice " FUNCTION TRIM(WS-E1) " Bobby " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US12-1: she uses it and arrives in the Subroutine on a new goto_pad above the slag of column
*>   (6, 8) (floor height 34), unchanged otherwise.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "U12-PLAYER" USING CLIENT-STATE WS-BEFORE
     MOVE 6.9 TO WS-TX
     MOVE 54.99 TO WS-TY
     PERFORM USE-AT
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US12-1 given the Player uses the goto_pad when the travel completes then they "
         & "are in the Subroutine at the arrival point on its goto_pad, seeing its slag terrain, "
         & "no sky light and no weather" TO TL-CASE
     MOVE "cobolcraft:subroutine at 6.5/36.0/8.5 sky 0 weather 0 below 16 17" TO TL-EXPECTED
     CALL "U12-WHERE" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-1 the travel keeps the same inventory, health, food level and game mode"
         TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED
     CALL "U12-PLAYER" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US12-2: Bobby, in main, places greystone (held slot 0 of his starting items) on (3, 53, 12);
*>   Alice, in the Subroutine, places lucite (key 3) on the slag of (5, 34, 8).
     MOVE WS-BOBBY TO WS-WHO
     MOVE 3.5 TO WS-TX
     MOVE 53.99 TO WS-TY
     MOVE 12.5 TO WS-TZ
     PERFORM USE-AT
     MOVE 8.5 TO WS-TZ
     MOVE CC-KEY-3 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE WS-ALICE TO WS-WHO
     MOVE 5.5 TO WS-TX
     MOVE 34.99 TO WS-TY
     PERFORM USE-AT
     MOVE "acceptance US12-2 given two Players in different dimensions when either changes the "
         & "world then the other does not see that change" TO TL-CASE
     MOVE "Bobby's greystone: Alice sees 0 | Alice's lucite: Bobby sees 2" TO TL-EXPECTED
     PERFORM CHANGES-SEEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Bobby is moved beside the main pad (the dimension named: Alice, who sends the command, is in
*>   the Subroutine). Alice goes back to main with her arrival pad; then Bobby, aiming at the main
*>   pad's west face (Alice now stands on it), travels to the Subroutine.
     MOVE "/relocate Bobby at 5 56 8 main" TO WS-LINE
     MOVE 30 TO WS-LINE-LENGTH
     PERFORM ALICE-SAYS
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "U12-PLAYER" USING CLIENT-STATE WS-BEFORE
     MOVE WS-ALICE TO WS-WHO
     MOVE 6.9 TO WS-TX
     MOVE 35.99 TO WS-TY
     MOVE 8.5 TO WS-TZ
     PERFORM USE-AT
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE WS-BOBBY TO WS-WHO
     MOVE 6.02 TO WS-TX
     MOVE 54.5 TO WS-TY
     PERFORM USE-AT
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "acceptance US12-2 when each Player is then in the other's dimension then they see the "
         & "change made there" TO TL-CASE
     MOVE "Bobby's greystone: Alice sees 2 | Alice's lucite: Bobby sees 12" TO TL-EXPECTED
     PERFORM CHANGES-SEEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "SC-012 given a Player who travelled to every extra dimension when they travel back to "
         & "the main dimension then they arrive on the goto_pad they left from" TO TL-CASE
     MOVE "cobolcraft:main at 6.5/55.0/8.5 sky 1 weather 0 below 16 4" TO TL-EXPECTED
     CALL "U12-WHERE" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "SC-012 travel to the Subroutine and back keeps inventory, health, food and game mode"
         TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED
     CALL "U12-PLAYER" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US12-3: Bobby, in the Subroutine, disconnects (pause menu) and rejoins.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-BOBBY WS-KEY
     MOVE ACT-DISCONNECT TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-BOBBY WS-ACTION WS-ARG WS-FOUND
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE SM-SCREEN TO WS-E1
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US12-3 given the Player is in an extra dimension when they disconnect and "
         & "rejoin then they are in that dimension at the position they left from" TO TL-CASE
     MOVE "left to screen 2 | cobolcraft:subroutine at 6.5/36.0/8.5 sky 0 weather 0 below 16 17"
         TO TL-EXPECTED
     CALL "U12-WHERE" USING CLIENT-STATE WS-AFTER
     MOVE SPACES TO TL-OBSERVED
     STRING "left to screen " FUNCTION TRIM(WS-E1) " | " WS-AFTER DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US12-4: the host quits; the world is reopened with extra dimensions off.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE ACT-QUIT-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 0 TO CS-EXTRA-DIMENSIONS
     MOVE CORE-SETTINGS TO SP-SETTINGS
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US12-4 given the extra-dimension setting off when a Player found in the "
         & "disabled dimension joins then they are placed at the world spawn point in main"
         TO TL-CASE
     MOVE "cobolcraft:main at 4.5/54.0/8.5 sky 1 weather 0 below 4 3" TO TL-EXPECTED
     CALL "U12-WHERE" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE WS-ALICE TO WS-WHO
     MOVE 6.9 TO WS-TX
     MOVE 54.99 TO WS-TY
     MOVE 8.5 TO WS-TZ
     PERFORM USE-AT
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "acceptance US12-4 given the extra-dimension setting off when a Player tries to travel "
         & "then they stay where they are" TO TL-CASE
     MOVE "cobolcraft:main at 6.5/55.0/8.5 sky 1 weather 0 below 16 4" TO TL-EXPECTED
     CALL "U12-WHERE" USING CLIENT-STATE TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ALICE-SAYS.
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     .

*>   Client WS-WHO looks at (WS-TX, WS-TY, WS-TZ) and presses the right button (use / place).
 USE-AT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-WHO)
     CALL "U12-AIM" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     CALL "CV-STEP" USING CONVH
     CALL "CV-BUTTON-SET" USING CONVH WS-WHO WS-BUTTON WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-WHO WS-BUTTON WS-UP
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     .

*>   What Alice's replica holds at Bobby's change (3, 54, 12) and Bobby's at Alice's (5, 35, 8).
 CHANGES-SEEN.
     MOVE 3 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 12 TO WS-Z
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E1
     MOVE 5 TO WS-X
     MOVE 35 TO WS-Y
     MOVE 8 TO WS-Z
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "Bobby's greystone: Alice sees " FUNCTION TRIM(WS-E1) " | Alice's lucite: Bobby sees "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     .
 END PROGRAM ACC-US12-DIMENSIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U12-WHERE.
*> USING CLIENT-STATE, text out (PIC X(1024)): "<dimension> at <x>/<y>/<z> sky <PL-HAS-SKY> weather
*> <PL-WEATHER> below <state under the feet> <state under that>" (1 decimal).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F1                  PIC -(4)9.9.
 01 WS-F2                  PIC -(4)9.9.
 01 WS-F3                  PIC -(4)9.9.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE PL-WEATHER TO WS-E3
     COMPUTE WS-F1 ROUNDED = PL-X
     COMPUTE WS-F2 ROUNDED = PL-Y
     COMPUTE WS-F3 ROUNDED = PL-Z
     COMPUTE WS-X = FUNCTION INTEGER(PL-X)
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y + 0.001) - 1
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E1
     SUBTRACT 1 FROM WS-Y
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO L-TEXT
     STRING FUNCTION TRIM(PL-DIM-NAME) " at " FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/"
         FUNCTION TRIM(WS-F3) " sky " PL-HAS-SKY " weather " FUNCTION TRIM(WS-E3) " below "
         FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO L-TEXT
     GOBACK.
 END PROGRAM U12-WHERE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U12-PLAYER.
*> USING CLIENT-STATE, text out (PIC X(1024)): "mode <m> health <h> food <f> inventory" then
*> " <slot>:<count>x<item>" of every non-empty slot of the client's replica.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     MOVE PL-MODE TO WS-E1
     COMPUTE WS-E2 ROUNDED = PL-HEALTH
     MOVE PL-FOOD TO WS-E3
     STRING "mode " FUNCTION TRIM(WS-E1) " health " FUNCTION TRIM(WS-E2) " food "
         FUNCTION TRIM(WS-E3) " inventory" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-COUNT(WS-I) > 0
             COMPUTE WS-E1 = WS-I - 1
             MOVE PL-SLOT-COUNT(WS-I) TO WS-E2
             MOVE PL-SLOT-ITEM(WS-I) TO WS-E3
             STRING " " FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
                 DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM U12-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. U12-AIM.
*> USING CLIENT-STATE, x, y, z (FLOAT-LONG): turns the local player to look from the eye (feet + 1.6)
*> at that point (yaw 0 faces +Z, 90 faces -X: yaw = atan2(-dx, dz); positive pitch looks down).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     COMPUTE WS-DX = L-X - PL-X
     COMPUTE WS-DY = L-Y - (PL-Y + 1.6)
     COMPUTE WS-DZ = L-Z - PL-Z
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     EVALUATE TRUE
         WHEN WS-DZ > 0
             COMPUTE WS-YAW = FUNCTION ATAN(- WS-DX / WS-DZ)
         WHEN WS-DZ < 0
             COMPUTE WS-YAW = FUNCTION ATAN(- WS-DX / WS-DZ) + FUNCTION PI
         WHEN WS-DX < 0
             COMPUTE WS-YAW = FUNCTION PI / 2
         WHEN OTHER
             COMPUTE WS-YAW = - FUNCTION PI / 2
     END-EVALUATE
     COMPUTE PL-YAW = WS-YAW * 180 / FUNCTION PI
     COMPUTE PL-PITCH = FUNCTION ATAN(- WS-DY / WS-H) * 180 / FUNCTION PI
     GOBACK.
 END PROGRAM U12-AIM.

