*> Convergence acceptance tests of US3-5 (spec.md US3; standin-content §3 operator figure, entity type
*> 0; 09 §3.3 Add Entity, Teleport/Move Entity, Remove Entities): two Players in one world (Alice
*> hosts the single-player world, Bobby joins over a further memory connection of the same core;
*> view distance 2). Each client's entity replica holds the other Player as an operator figure
*> (type 0) at their position and facing while they move; the figure disappears when that Player
*> moves out of view distance, changes dimension or disconnects (the relocate command, run by Alice
*> from the chat line: the host is an operator).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US3-OTHER-PLAYERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us3-other".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 20.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Others".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-JOINED2             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SAY                 PIC X(64).
 01 WS-SAY-LENGTH          BINARY-LONG.
 01 WS-FIGURES             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AYAW                FLOAT-SHORT.
 01 WS-DX                  FLOAT-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-LOG                 PIC X(4096).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-F1                  PIC -(4)9.99.
 01 WS-F2                  PIC -(4)9.99.
 01 WS-F3                  PIC -(4)9.99.
 01 WS-F4                  PIC -(4)9.9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED2
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

     MOVE "acceptance US3-5 given another player is connected in the same dimension within view "
         & "distance when the Player looks then they see them as the operator figure at their "
         & "position facing their way (each client sees the other)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Bobby sees 1 figure at 4.50/54.00/8.50 yaw -90.0; Alice sees 1" TO TL-EXPECTED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "FIGURES" USING CLIENT-STATE WS-FIGURES WS-ROW
     MOVE WS-FIGURES TO WS-E2
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     PERFORM OBSERVE-BOBBY
     STRING "; Alice sees " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Alice walks east (W) for 10 ticks, then turns to face south (yaw 0).
     MOVE CC-KEY-W TO WS-KEY
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-KIND
     MOVE 9 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-EV-KEY-UP TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-KIND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO PL-YAW
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-X TO WS-AX
     MOVE PL-Y TO WS-AY
     MOVE PL-Z TO WS-AZ
     MOVE PL-YAW TO WS-AYAW
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE "acceptance US3-5 given another player is in view when that player walks and turns then "
         & "the Player sees the figure at their current position facing the way they face" TO TL-CASE
     COMPUTE WS-DX = WS-AX - 4.5
     MOVE "moved east 1 same place 1 same facing 1" TO TL-EXPECTED
     CALL "FIGURES" USING CLIENT-STATE WS-FIGURES WS-ROW
     MOVE 0 TO WS-E1
     IF WS-DX > 1
         MOVE 1 TO WS-E1
     END-IF
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "moved east " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE 0 TO WS-E1
     IF WS-ROW > 0
         IF FUNCTION ABS(EN-X(WS-ROW) - WS-AX) < 0.01 AND FUNCTION ABS(EN-Y(WS-ROW) - WS-AY) < 0.01
                 AND FUNCTION ABS(EN-Z(WS-ROW) - WS-AZ) < 0.01
             MOVE 1 TO WS-E1
         END-IF
     END-IF
     STRING " same place " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     MOVE 0 TO WS-E1
     IF WS-ROW > 0
         IF FUNCTION ABS(EN-YAW(WS-ROW) - WS-AYAW) < 1.5
             MOVE 1 TO WS-E1
         END-IF
     END-IF
     STRING " same facing " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     IF TL-OBSERVED NOT = TL-EXPECTED
         PERFORM OBSERVE-BOBBY
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Out of view distance (2 chunks): Alice moves 200 blocks east; then back.
     MOVE "/relocate Alice at 200 60 8" TO WS-SAY
     MOVE 27 TO WS-SAY-LENGTH
     PERFORM ALICE-SAYS
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "FIGURES" USING CLIENT-STATE WS-FIGURES WS-ROW
     MOVE WS-FIGURES TO WS-E1
     MOVE "/relocate Alice at 6 60 8" TO WS-SAY
     MOVE 25 TO WS-SAY-LENGTH
     PERFORM ALICE-SAYS
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "FIGURES" USING CLIENT-STATE WS-FIGURES WS-ROW
     MOVE WS-FIGURES TO WS-E2
     MOVE "acceptance US3-5 given another player in view when they move out of view distance then "
         & "the Player no longer sees them, and sees them again when they come back" TO TL-CASE
     MOVE "away 0 back 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "away " FUNCTION TRIM(WS-E1) " back " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Another dimension: Alice goes to the Subroutine, then back to main.
     MOVE "/relocate Alice at 4 50 8 subroutine" TO WS-SAY
     MOVE 35 TO WS-SAY-LENGTH
     PERFORM ALICE-SAYS
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-DIM-NAME TO WS-SAY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "FIGURES" USING CLIENT-STATE WS-FIGURES WS-ROW
     MOVE WS-FIGURES TO WS-E1
     MOVE "acceptance US3-5 given another player in view when they change dimension then the "
         & "Player no longer sees them" TO TL-CASE
     MOVE "Alice in cobolcraft:subroutine; Bobby sees 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "Alice in " FUNCTION TRIM(WS-SAY) "; Bobby sees " FUNCTION TRIM(WS-E1)
         DELIMITED BY SIZE INTO TL-OBSERVED
     IF TL-OBSERVED NOT = TL-EXPECTED
         CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-LOG
         DISPLAY "Alice's chat: " FUNCTION TRIM(WS-LOG)
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "/relocate Alice at 6 60 8 main" TO WS-SAY
     MOVE 30 TO WS-SAY-LENGTH
     PERFORM ALICE-SAYS
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

*>   Bobby disconnects (pause menu, disconnect control): Alice no longer sees him.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "FIGURES" USING CLIENT-STATE WS-FIGURES WS-ROW
     MOVE WS-FIGURES TO WS-E1
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-BOBBY WS-KEY
     MOVE ACT-DISCONNECT TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-BOBBY WS-ACTION WS-ARG WS-FOUND
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "FIGURES" USING CLIENT-STATE WS-FIGURES WS-ROW
     MOVE WS-FIGURES TO WS-E2
     MOVE "acceptance US3-5 given another player in view when they disconnect then the Player "
         & "sees them disappear" TO TL-CASE
     MOVE "before 1 disconnect found 1 after 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "before " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-FOUND TO WS-E1
     STRING " disconnect found " FUNCTION TRIM(WS-E1) " after " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ALICE-SAYS.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-SAY TRAILING)) TO WS-SAY-LENGTH
     CALL "SAY-LONG" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.

*>   "Bobby sees <n> figure at <x>/<y>/<z> yaw <yaw>" from Bobby's replica (CLIENT-STATE set).
 OBSERVE-BOBBY.
     CALL "FIGURES" USING CLIENT-STATE WS-FIGURES WS-ROW
     MOVE WS-FIGURES TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "Bobby sees " FUNCTION TRIM(WS-E1) " figure" DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     IF WS-ROW > 0
         COMPUTE WS-F1 ROUNDED = EN-X(WS-ROW)
         COMPUTE WS-F2 ROUNDED = EN-Y(WS-ROW)
         COMPUTE WS-F3 ROUNDED = EN-Z(WS-ROW)
         COMPUTE WS-F4 ROUNDED = EN-YAW(WS-ROW)
         STRING " at " FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/" FUNCTION TRIM(WS-F3)
             " yaw " FUNCTION TRIM(WS-F4) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF.
 END PROGRAM ACC-US3-OTHER-PLAYERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGURES.
*> USING CLIENT-STATE, count out, row out: the operator figures (entity type 0) of the client's
*> entity replica and the row of the last one (0 when none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-COUNT                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-COUNT L-ROW.
     MOVE 0 TO L-COUNT L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = 0
             ADD 1 TO L-COUNT
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FIGURES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SAY-LONG.
*> USING CONVH, index, text (PIC X(64)), length: CV-SAY for texts longer than the 32 code points a
*> client takes in one frame (IN-TEXT): chat opened (T), the text typed 30 bytes per frame, Enter.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-T                   BINARY-LONG VALUE CC-KEY-T.
 01 WS-ENTER               BINARY-LONG VALUE CC-KEY-ENTER.
 01 WS-PART                PIC X(64).
 01 WS-FROM                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT L-LENGTH.
     CALL "CV-KEY" USING CONVH L-INDEX WS-T
     PERFORM VARYING WS-FROM FROM 1 BY 30 UNTIL WS-FROM > L-LENGTH
         COMPUTE WS-N = FUNCTION MIN(30, L-LENGTH - WS-FROM + 1)
         MOVE SPACES TO WS-PART
         MOVE L-TEXT(WS-FROM:WS-N) TO WS-PART
         CALL "CV-TYPE" USING CONVH L-INDEX WS-PART WS-N
     END-PERFORM
     CALL "CV-KEY" USING CONVH L-INDEX WS-ENTER
     GOBACK.
 END PROGRAM SAY-LONG.
