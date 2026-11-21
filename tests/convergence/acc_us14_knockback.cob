*> Convergence acceptance test (lane p46f, T27503; docs/protocol/17 section 4 knockback, 05b 0x67 Set Entity Motion): a hit between two players moves the victim on screen. Two survival
*> Players share a single-player world (Alice the host and an operator, Bobby on a further memory connection). Alice stands 1.5 blocks west of Bobby on the turf, faces east and attacks
*> bare-handed through her attack control; the core sends Set Entity Motion for Bobby (the knockback) and Bobby's client carries him along +x and up: his position moves more
*> than half a block east, he has left the ground within two ticks and is back on it afterwards. Before the client applied the packet to the local player he stood still.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-KNOCKBACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us14-knockback".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-NAME                PIC X(16).
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Knock".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED-A            BINARY-LONG.
 01 WS-JOINED-B            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-LIFT                BINARY-LONG.
 01 WS-GEN                 PIC X(1024).
 01 WS-CREATE              BINARY-LONG VALUE SCR-CREATE-WORLD.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-BOBBY
*>   A default superflat world of the standard set (the tool rules of 17 section 4 give the knockback): the generated vanilla data, CC_GENERATED_DIR.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-GEN TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-GEN)) TO CL-GENERATED-DIR-LENGTH
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-CREATE
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED-A
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED-B
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE "/gamerule natural_health_regeneration false" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/gamerule pvp true" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/tp Alice 4.5 -60 8.5" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE "/tp Bobby 6.0 -60 8.5" TO WS-LINE
     CALL "SAY-LINE" USING CONVH WS-ALICE WS-LINE
     MOVE 120 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE -90 TO PL-YAW
     MOVE 0 TO PL-PITCH
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE PL-X TO WS-X0
     MOVE PL-Y TO WS-Y0
     CALL "ATTACK" USING CONVH WS-ALICE
     MOVE 0 TO WS-AIR
     PERFORM 3 TIMES
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
         IF PL-ON-GROUND = 0 AND PL-Y > WS-Y0 + 0.05
             MOVE 1 TO WS-AIR
         END-IF
     END-PERFORM
     MOVE 30 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE 0 TO WS-LIFT
     IF PL-X - WS-X0 > 0.5 AND PL-X - WS-X0 < 4
         MOVE 1 TO WS-LIFT
     END-IF
     MOVE "acceptance US14 17 section 4 given Alice hits Bobby bare-handed when the core sends the knockback then "
         & "Bobby's client carries him east (0.5 to 4 blocks), off the ground at first, and he stands on it again" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 111 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-LIFT * 100 + WS-AIR * 10 + PL-ON-GROUND
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US14-KNOCKBACK.

*> SAY-LINE USING CONVH, client, line (PIC X(64), trailing spaces dropped): the line sent through
*> the chat control, then five frames (test infrastructure).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SAY-LINE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 01 L-LINE                 PIC X(64).
 PROCEDURE DIVISION USING CONVH L-INDEX L-LINE.
     MOVE 64 TO WS-LENGTH
     PERFORM UNTIL WS-LENGTH = 0 OR L-LINE(WS-LENGTH:1) NOT = SPACE
         SUBTRACT 1 FROM WS-LENGTH
     END-PERFORM
     CALL "CV-SAY" USING CONVH L-INDEX L-LINE WS-LENGTH
     CALL "CV-STEPS" USING CONVH WS-FIVE
     GOBACK.
 END PROGRAM SAY-LINE.

*> ATTACK USING CONVH, client: the left mouse button pressed (one frame) and released (the next).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ATTACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-LEFT.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-BUTTON-UP.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX.
     CALL "CV-BUTTON-SET" USING CONVH L-INDEX WS-BUTTON WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH L-INDEX WS-BUTTON WS-UP
     GOBACK.
 END PROGRAM ATTACK.
