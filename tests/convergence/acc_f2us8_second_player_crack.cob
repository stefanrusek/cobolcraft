*> Convergence acceptance test of US8-3 and US8-2 (spec 002 FR-023; SC-006; 12 §4): two Players in one
*> single-player world (Alice hosts it in survival, Bobby joins over a further memory connection of the same
*> core; the same client and core code a server's loopback host runs). Alice holds the break button on a
*> block that Bobby can see; the Block Destruction packets of the core reach Bobby's client, whose crack
*> overlay table shows the stages 0 to 9 in order for that block, and when the block breaks (and again when
*> Alice only lets go) the overlay is gone and the block is gone from both replicas.
*> Spawn (4.5, 54, 8.5) facing east; Bobby walks two blocks south; the turf top at (6, 53, 8) is the block.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US8-SECOND-PLAYER-CRACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us8-crack".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 22.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Cracks".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED-A            BINARY-LONG.
 01 WS-JOINED-B            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-LEFT.
 01 WS-KIND                BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-X                   BINARY-LONG VALUE 6.
 01 WS-Y                   BINARY-LONG VALUE 53.
 01 WS-Z                   BINARY-LONG VALUE 8.
 01 WS-CORE                BINARY-LONG.
 01 WS-A-STATE             BINARY-LONG.
 01 WS-B-STATE             BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-STAGE               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-SEEN                PIC X(120).
 01 WS-PTR                 BINARY-LONG.
 01 WS-OWN                 PIC X(120).
 01 WS-OWN-PTR             BINARY-LONG.
 01 WS-OWN-STAGE           BINARY-LONG.
 01 WS-OWN-LAST            BINARY-LONG.
 01 WS-EXISTS-BEFORE       BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED-A
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED-B
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
*>   Bobby walks two blocks south (D, facing east) so that neither stands in the other's aim.
     MOVE CC-KEY-D TO WS-KEY
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-KIND
     MOVE 9 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-EV-KEY-UP TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-KIND
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

*>   Alice aims at the turf top and holds the break button; every frame the stage Bobby's overlay table holds
*>   for that block (and Alice's own) is noted whenever it changes.
     MOVE 6.5 TO WS-TX
     MOVE 53.5 TO WS-TY
     MOVE 8.5 TO WS-TZ
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "F2C8-AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM CELL-ALL
     MOVE WS-CORE TO WS-EXISTS-BEFORE
     MOVE SPACES TO WS-SEEN WS-OWN
     MOVE 1 TO WS-PTR WS-OWN-PTR
     MOVE -2 TO WS-LAST WS-OWN-LAST
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     PERFORM NOTE-STAGES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-CORE NOT = WS-EXISTS-BEFORE
         CALL "CV-STEP" USING CONVH
         PERFORM NOTE-STAGES
         PERFORM CELL-ALL
     END-PERFORM
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE 3 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "CV-STEP" USING CONVH
         PERFORM NOTE-STAGES
     END-PERFORM
     PERFORM CELL-ALL

     MOVE "acceptance US8-3 given Alice holds the break button on a block Bobby sees when the block "
         & "breaks then Bobby's overlay shows the stages 0 to 9 in order and then none" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 1 2 3 4 5 6 7 8 9 none" TO TL-EXPECTED
     MOVE WS-SEEN TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US8-1 given Alice breaks the block then her own overlay shows the same stages "
         & "and then none" TO TL-CASE
     MOVE "0 1 2 3 4 5 6 7 8 9 none" TO TL-EXPECTED
     MOVE WS-OWN TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US8-3 given the block broke when Bobby looks at his replica then the turf is "
         & "gone in the world and in both replicas (state 0)" TO TL-CASE
     MOVE "core 0 Alice 0 Bobby 0" TO TL-EXPECTED
     MOVE WS-CORE TO WS-E1
     MOVE WS-A-STATE TO WS-E2
     MOVE WS-B-STATE TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "core " FUNCTION TRIM(WS-E1) " Alice " FUNCTION TRIM(WS-E2) " Bobby "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US8-2 seen by the other Player: Alice starts on another block (the turf top at (5, 53, 7)) and lets go
*>   part way; Bobby's crack grows and then vanishes while the block stays.
     MOVE 5 TO WS-X
     MOVE 7 TO WS-Z
     MOVE 5.5 TO WS-TX
     MOVE 53.5 TO WS-TY
     MOVE 7.5 TO WS-TZ
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "F2C8-AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM CELL-ALL
     MOVE WS-CORE TO WS-EXISTS-BEFORE
     MOVE SPACES TO WS-SEEN WS-OWN
     MOVE 1 TO WS-PTR WS-OWN-PTR
     MOVE -2 TO WS-LAST WS-OWN-LAST
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     PERFORM NOTE-STAGES
     MOVE 6 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "CV-STEP" USING CONVH
         PERFORM NOTE-STAGES
     END-PERFORM
     MOVE WS-LAST TO WS-STAGE
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE 4 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "CV-STEP" USING CONVH
         PERFORM NOTE-STAGES
     END-PERFORM
     PERFORM CELL-ALL
     MOVE "acceptance US8-2 given Alice lets go of the break button part way when Bobby looks then "
         & "the crack grew from 0 and is gone while the block is still there" TO TL-CASE
     MOVE "starts 0 ends none block there 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     IF WS-SEEN(1:1) = "0"
         STRING "starts 0 " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         STRING "starts " WS-SEEN(1:8) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     IF WS-LAST = -1
         STRING "ends none " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         STRING "ends still " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     IF WS-CORE = WS-EXISTS-BEFORE AND WS-B-STATE = WS-CORE
         STRING "block there 1" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         STRING "block there 0" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   The stage Bobby's overlay table holds for the block (WS-X, WS-Y, WS-Z) and Alice's own; a change is
*>   appended to the text ("none" for no entry).
 NOTE-STAGES.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE -1 TO WS-STAGE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > BDS-COUNT
         IF BDS-X(WS-K) = WS-X AND BDS-Y(WS-K) = WS-Y AND BDS-Z(WS-K) = WS-Z
             MOVE BDS-STAGE(WS-K) TO WS-STAGE
         END-IF
     END-PERFORM
     IF WS-STAGE NOT = WS-LAST
         MOVE WS-STAGE TO WS-LAST
         PERFORM APPEND-SEEN
     END-IF
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE -1 TO WS-OWN-STAGE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > BDS-COUNT
         IF BDS-X(WS-K) = WS-X AND BDS-Y(WS-K) = WS-Y AND BDS-Z(WS-K) = WS-Z
             MOVE BDS-STAGE(WS-K) TO WS-OWN-STAGE
         END-IF
     END-PERFORM
     IF WS-OWN-STAGE NOT = WS-OWN-LAST
         MOVE WS-OWN-STAGE TO WS-OWN-LAST
         PERFORM APPEND-OWN
     END-IF.

 APPEND-SEEN.
     IF WS-STAGE = -1
         IF WS-PTR > 1
             STRING " none" DELIMITED BY SIZE INTO WS-SEEN WITH POINTER WS-PTR
         END-IF
     ELSE
         MOVE WS-STAGE TO WS-E1
         IF WS-PTR > 1
             STRING " " DELIMITED BY SIZE INTO WS-SEEN WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-SEEN WITH POINTER WS-PTR
     END-IF.

 APPEND-OWN.
     IF WS-OWN-STAGE = -1
         IF WS-OWN-PTR > 1
             STRING " none" DELIMITED BY SIZE INTO WS-OWN WITH POINTER WS-OWN-PTR
         END-IF
     ELSE
         MOVE WS-OWN-STAGE TO WS-E1
         IF WS-OWN-PTR > 1
             STRING " " DELIMITED BY SIZE INTO WS-OWN WITH POINTER WS-OWN-PTR
         END-IF
         STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-OWN WITH POINTER WS-OWN-PTR
     END-IF.

*>   The cell WS-X, WS-Y, WS-Z in the world and both replicas.
 CELL-ALL.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-CORE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-A-STATE WS-SKY WS-LIGHT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-B-STATE WS-SKY WS-LIGHT.
 END PROGRAM ACC-F2US8-SECOND-PLAYER-CRACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2C8-AIM-AT.
*> USING CLIENT-STATE, target x, y, z (FLOAT-LONG): the local player looks from the eye (feet + 1.6)
*> at that point (yaw 0 faces +Z, 90 faces -X; positive pitch looks down).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     COMPUTE WS-DX = L-X - PL-X
     COMPUTE WS-DY = L-Y - PL-Y - 1.6
     COMPUTE WS-DZ = L-Z - PL-Z
     COMPUTE WS-NX = 0 - WS-DX
     CALL "F2C8-ATAN2-DEG" USING WS-NX WS-DZ WS-A
     MOVE WS-A TO PL-YAW
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     CALL "F2C8-ATAN2-DEG" USING WS-DY WS-H WS-A
     COMPUTE PL-PITCH = 0 - WS-A
     GOBACK.
 END PROGRAM F2C8-AIM-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2C8-ATAN2-DEG.
*> USING y, x, angle out (FLOAT-LONG, degrees, -180 to 180).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-X L-A.
     EVALUATE TRUE
         WHEN L-X > 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X)
         WHEN L-X < 0 AND L-Y >= 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) + FUNCTION PI
         WHEN L-X < 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) - FUNCTION PI
         WHEN L-Y > 0
             COMPUTE WS-A = FUNCTION PI / 2
         WHEN L-Y < 0
             COMPUTE WS-A = 0 - FUNCTION PI / 2
         WHEN OTHER
             MOVE 0 TO WS-A
     END-EVALUATE
     COMPUTE L-A = WS-A * 180 / FUNCTION PI
     GOBACK.
 END PROGRAM F2C8-ATAN2-DEG.
