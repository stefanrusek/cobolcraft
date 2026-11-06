*> Convergence acceptance tests of US3-4 and SC-007 (spec.md US3; standin-content §5.2 terrain,
*> §15.2 Subroutine terrain; 09 §3.3 Level Chunk With Light, Forget Level Chunk, chunk cache
*> center): a Player in a single-player world (view distance 2: the square of 5 x 5 chunks around the
*> player's chunk) travels, and the client's world replica holds terrain (the baseplate at y 0 of
*> every chunk) in every chunk of the view square and no chunk outside it.
*> US3-4: in creative mode the Player flies (Space twice, then W held) 200 blocks east, turns around
*> and flies back. SC-007: from the arrival point of each dimension (main, then the Subroutine) the
*> Player is moved by the relocate command (run from the chat line; the host is an operator) to every
*> point 80 blocks apart (the width of the 5-chunk view square, so the squares checked cover the
*> whole way) up to 1,040 blocks in each compass direction.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US3-STREAMING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us3-streaming".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 24.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Streaming".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 9.
 01 WS-CREATIVE            BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-VIEW                BINARY-LONG VALUE 2.
 01 WS-MISSING             BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-ORIGIN              BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-FIRST-BAD           PIC X(64).
 01 WS-SAY                 PIC X(64).
 01 WS-SAY-LENGTH          BINARY-LONG.
 01 WS-DIM-WORD            PIC X(16).
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-STEP-X              BINARY-LONG.
 01 WS-STEP-Z              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-CREATIVE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     PERFORM UNTIL-VIEW

*>   US3-4: up to y 70 at z 24.5 (clear of the marker pillars), fly 200 blocks east (yaw -90).
     MOVE "/relocate Alice at 4 70 24" TO WS-SAY
     PERFORM ALICE-SAYS
     MOVE CC-KEY-SPACE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE PL-FLYING TO WS-E4
     MOVE PL-X TO WS-X0
     MOVE -90 TO PL-YAW
     MOVE 0 TO PL-PITCH
     MOVE CC-KEY-W TO WS-KEY
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-KIND
     PERFORM UNTIL PL-X - WS-X0 >= 200
         CALL "CV-STEP" USING CONVH
     END-PERFORM
     MOVE CC-EV-KEY-UP TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-KIND
     PERFORM UNTIL-VIEW
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ORIGIN
     MOVE "acceptance US3-4 given the Player flies several hundred blocks east when they arrive "
         & "then the world is shown out to the view distance in every direction and the area they "
         & "left behind is no longer shown" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "flying 1 missing 0 outside 0 spawn chunk shown 0" TO TL-EXPECTED
     PERFORM OBSERVE-VIEW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Turn around (yaw 90: west) and fly back to the start.
     MOVE 90 TO PL-YAW
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-KIND
     PERFORM UNTIL PL-X <= WS-X0
         CALL "CV-STEP" USING CONVH
     END-PERFORM
     MOVE CC-EV-KEY-UP TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-KIND
     PERFORM UNTIL-VIEW
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ORIGIN
     MOVE "acceptance US3-4 given the Player turns around and flies back when they arrive then the "
         & "world is shown out to the view distance again, the spawn chunk included, and the far "
         & "area is no longer shown" TO TL-CASE
     MOVE "flying 1 missing 0 outside 0 spawn chunk shown 1" TO TL-EXPECTED
     PERFORM OBSERVE-VIEW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   SC-007: main (arrival at the world spawn), then the Subroutine.
     PERFORM VARYING WS-DIM FROM 1 BY 1 UNTIL WS-DIM > 2
         IF WS-DIM = 1
             MOVE "main" TO WS-DIM-WORD
         ELSE
             MOVE "subroutine" TO WS-DIM-WORD
         END-IF
         MOVE 0 TO WS-POINTS WS-BAD
         MOVE SPACES TO WS-FIRST-BAD
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
             EVALUATE WS-D
                 WHEN 1
                     MOVE 0 TO WS-STEP-X
                     MOVE -80 TO WS-STEP-Z
                 WHEN 2
                     MOVE 80 TO WS-STEP-X
                     MOVE 0 TO WS-STEP-Z
                 WHEN 3
                     MOVE 0 TO WS-STEP-X
                     MOVE 80 TO WS-STEP-Z
                 WHEN OTHER
                     MOVE -80 TO WS-STEP-X
                     MOVE 0 TO WS-STEP-Z
             END-EVALUATE
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 13
                 COMPUTE WS-PX = 4 + WS-I * WS-STEP-X
                 COMPUTE WS-PZ = 8 + WS-I * WS-STEP-Z
                 PERFORM RELOCATE-POINT
                 ADD 1 TO WS-POINTS
                 IF WS-MISSING > 0 OR WS-EXTRA > 0 OR PL-DIM-NAME(12:WS-SAY-LENGTH) NOT = WS-DIM-WORD
                     ADD 1 TO WS-BAD
                     IF WS-FIRST-BAD = SPACES
                         MOVE WS-PX TO WS-E1
                         MOVE WS-PZ TO WS-E2
                         MOVE WS-MISSING TO WS-E3
                         MOVE WS-EXTRA TO WS-E4
                         STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " missing "
                             FUNCTION TRIM(WS-E3) " outside " FUNCTION TRIM(WS-E4) " in "
                             FUNCTION TRIM(PL-DIM-NAME) DELIMITED BY SIZE INTO WS-FIRST-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "SC-007 given the arrival point of cobolcraft:" FUNCTION TRIM(WS-DIM-WORD)
             " when the Player travels 1,000 blocks in each compass direction then terrain is "
             "shown to the view distance at every point (56 points 80 blocks apart)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "points 56 bad 0" TO TL-EXPECTED
         MOVE WS-POINTS TO WS-E1
         MOVE WS-BAD TO WS-E2
         MOVE SPACES TO TL-OBSERVED
         STRING "points " FUNCTION TRIM(WS-E1) " bad " FUNCTION TRIM(WS-E2) " " WS-FIRST-BAD
             DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE FUNCTION TRIM(TL-OBSERVED TRAILING) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

*>   Frames (at most 100) until the view square is complete and nothing lies outside it.
 UNTIL-VIEW.
     MOVE 1 TO WS-MISSING
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 100 OR (WS-MISSING = 0 AND WS-EXTRA = 0)
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         CALL "VIEW-CHECK" USING CLIENT-STATE WS-VIEW WS-MISSING WS-EXTRA
     END-PERFORM.

 OBSERVE-VIEW.
     MOVE PL-FLYING TO WS-E1
     MOVE WS-MISSING TO WS-E2
     MOVE WS-EXTRA TO WS-E3
     MOVE 0 TO WS-E4
     IF WS-ORIGIN > 0
         MOVE 1 TO WS-E4
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "flying " FUNCTION TRIM(WS-E1) " missing " FUNCTION TRIM(WS-E2) " outside "
         FUNCTION TRIM(WS-E3) " spawn chunk shown " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED.

 RELOCATE-POINT.
     MOVE WS-PX TO WS-E1
     MOVE WS-PZ TO WS-E2
     MOVE SPACES TO WS-SAY
     STRING "/relocate Alice at " FUNCTION TRIM(WS-E1) " 70 " FUNCTION TRIM(WS-E2) " "
         FUNCTION TRIM(WS-DIM-WORD) DELIMITED BY SIZE INTO WS-SAY
     PERFORM ALICE-SAYS
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIM-WORD)) TO WS-SAY-LENGTH.

 ALICE-SAYS.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-SAY TRAILING)) TO WS-SAY-LENGTH
     CALL "SAY-LONG" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     PERFORM UNTIL-VIEW.
 END PROGRAM ACC-US3-STREAMING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIEW-CHECK.
*> USING CLIENT-STATE, view distance d, missing out, outside out: of the (2d + 1) x (2d + 1) chunks
*> around the player's chunk, those the replica lacks or whose baseplate (y 0, chunk centre) is not
*> there; and the chunks the replica holds outside that square.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PCX                 BINARY-LONG.
 01 WS-PCZ                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 0.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-D                    BINARY-LONG.
 01 L-MISSING              BINARY-LONG.
 01 L-OUTSIDE              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-D L-MISSING L-OUTSIDE.
     COMPUTE WS-PCX = FUNCTION INTEGER(PL-X / 16)
     COMPUTE WS-PCZ = FUNCTION INTEGER(PL-Z / 16)
     MOVE 0 TO L-MISSING L-OUTSIDE
     PERFORM VARYING WS-CX FROM WS-PCX BY 1 UNTIL WS-CX > WS-PCX + 2 * L-D
         PERFORM VARYING WS-CZ FROM WS-PCZ BY 1 UNTIL WS-CZ > WS-PCZ + 2 * L-D
             COMPUTE WS-X = (WS-CX - L-D) * 16 + 8
             COMPUTE WS-Z = (WS-CZ - L-D) * 16 + 8
             CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-LIGHT
             IF WS-STATE NOT = 1
                 ADD 1 TO L-MISSING
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             IF FUNCTION ABS(WR-CX(WS-R) - WS-PCX) > L-D OR FUNCTION ABS(WR-CZ(WS-R) - WS-PCZ) > L-D
                 ADD 1 TO L-OUTSIDE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VIEW-CHECK.

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
