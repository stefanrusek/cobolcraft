*> Acceptance test US8-1 to US8-4 (spec 002 FR-023; SC-006; 12 §4): the crack overlay. Block Destruction stages 0
*> to 9 draw the crack on the block (six faces, 36 vertices, textured from the pack's break-stage image of that
*> stage), stage -1 (255) and a released button remove it, another player's stage draws too (the highest stage of a
*> block wins), and a block out of range (32 blocks) or an entry not updated for 20 s draws nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US8-OVERLAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-overlay".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-NAMES               PIC X(256) VALUE "cracks".
 01 WS-IDS                 PIC X(256) VALUE "file/cracks".
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES VALUE 0.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-BREAKER             BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STAGE               BINARY-LONG.
 01 WS-STAGE-TEXT          PIC 9.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "N" TO TL-MODE
     MOVE 1000 TO CL-NOW-MS
     MOVE 0 TO CT-BREAKING

*>   Every stage 0 to 9: 36 vertices whose texture coordinates lie in that stage's image.
     PERFORM VARYING WS-STAGE FROM 0 BY 1 UNTIL WS-STAGE > 9
         MOVE 7 TO WS-BREAKER
         MOVE 3 TO WS-X
         MOVE 4 TO WS-Y
         MOVE 5 TO WS-Z
         CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-BREAKER WS-X WS-Y WS-Z WS-STAGE
         CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
         MOVE WS-STAGE TO WS-STAGE-TEXT
         MOVE SPACES TO WS-ID
         STRING "minecraft:block/destroy_stage_" WS-STAGE-TEXT DELIMITED BY SIZE INTO WS-ID
         MOVE 31 TO WS-ID-LENGTH
         CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SPRITE
         MOVE 1 TO WS-INSIDE
         IF WS-SPRITE = 0
             MOVE 0 TO WS-INSIDE
         ELSE
             COMPUTE WS-U0 = AT-X(WS-SPRITE) / AT-W
             COMPUTE WS-U1 = (AT-X(WS-SPRITE) + AT-SW(WS-SPRITE)) / AT-W
             COMPUTE WS-V0 = AT-Y(WS-SPRITE) / AT-H
             COMPUTE WS-V1 = (AT-Y(WS-SPRITE) + AT-SH(WS-SPRITE)) / AT-H
             PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > RL-BO-COUNT
                 IF RL-BO-U(WS-V) < WS-U0 - 0.00001 OR RL-BO-U(WS-V) > WS-U1 + 0.00001
                         OR RL-BO-V(WS-V) < WS-V0 - 0.00001 OR RL-BO-V(WS-V) > WS-V1 + 0.00001
                     MOVE 0 TO WS-INSIDE
                 END-IF
             END-PERFORM
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "overlay stage " WS-STAGE-TEXT " draws the block's six faces from the pack's stage " WS-STAGE-TEXT
             " image" DELIMITED BY SIZE INTO TL-CASE
         MOVE 3600 TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = RL-BO-COUNT * 100 * WS-INSIDE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   Stage 255 (-1) removes it.
     MOVE 255 TO WS-STAGE
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-BREAKER WS-X WS-Y WS-Z WS-STAGE
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay stage -1 (255) removes the overlay" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The local survival break: stage 5 after 550 of 1000 ms, gone when the button is released.
     MOVE 1 TO PL-ENTITY-ID
     MOVE 1 TO CT-BREAKING
     MOVE 3 TO CT-BREAK-X
     MOVE 4 TO CT-BREAK-Y
     MOVE 5 TO CT-BREAK-Z
     MOVE 450 TO CT-BREAK-START
     MOVE 1000 TO CT-BREAK-MS
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay the local break draws its block at stage 5 of progress 0.55" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO TL-EXPECTED-N
     MOVE BDS-STAGE(1) TO TL-OBSERVED-N
     MOVE "overlay the local break's stage is int(progress * 10)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-BREAKING
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay a released button removes the local overlay" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Another player's break draws; on one block the highest stage wins (one block, 36 vertices).
     MOVE 9 TO WS-BREAKER
     MOVE 2 TO WS-STAGE
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-BREAKER WS-X WS-Y WS-Z WS-STAGE
     MOVE 8 TO WS-BREAKER
     MOVE 6 TO WS-STAGE
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-BREAKER WS-X WS-Y WS-Z WS-STAGE
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay two players on one block draw the block once, at the highest stage" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 255 TO WS-STAGE
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-BREAKER WS-X WS-Y WS-Z WS-STAGE
     MOVE 9 TO WS-BREAKER
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-BREAKER WS-X WS-Y WS-Z WS-STAGE

*>   Range: a block 40 blocks away is not drawn; an entry 20 s old is gone.
     MOVE 7 TO WS-BREAKER
     MOVE 43 TO WS-X
     MOVE 3 TO WS-STAGE
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-BREAKER WS-X WS-Y WS-Z WS-STAGE
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay a block beyond 32 blocks of the camera draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-X
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-BREAKER WS-X WS-Y WS-Z WS-STAGE
     ADD 20001 TO CL-NOW-MS
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay an entry not updated for 20 seconds is removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US8-OVERLAY.

 COPY CLTEST.
 COPY PACKTEST.
