*> Edge-case test of the crack overlay (spec 002 edge cases; break-overlay.cob): several players breaking different
*> blocks at once each show their own stage (three blocks, 108 vertices, three different images); a breaker who
*> moves to another block leaves the first (the new position replaces the entry); progress interrupted (the local
*> break stopped) or ended by the server (stage 255) removes only that breaker's overlay; more breakers than the
*> table holds do not overflow it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OVERLAY-MANY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-overlay-many".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-NAMES               PIC X(256) VALUE "cracks".
 01 WS-IDS                 PIC X(256) VALUE "file/cracks".
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES VALUE 0.
 01 WS-B                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 4.
 01 WS-Z                   BINARY-LONG VALUE 5.
 01 WS-STAGE               BINARY-LONG.
 01 WS-DISTINCT            BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-SEEN                FLOAT-SHORT OCCURS 3 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "N" TO TL-MODE
     MOVE 1000 TO CL-NOW-MS
     MOVE 0 TO CT-BREAKING
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 3
         COMPUTE WS-X = WS-B * 2
         COMPUTE WS-STAGE = WS-B * 3 - 2
         CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-B WS-X WS-Y WS-Z WS-STAGE
     END-PERFORM
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay many three players on three blocks draw 108 vertices" TO TL-CASE
     MOVE 108 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The images differ block to block: the three blocks' first u values are all different.
     MOVE 0 TO WS-DISTINCT
     PERFORM VARYING WS-W FROM 0 BY 1 UNTIL WS-W > 2
         COMPUTE WS-V = WS-W * 36 + 1
         MOVE RL-BO-U(WS-V) TO WS-SEEN(WS-W + 1)
     END-PERFORM
     IF WS-SEEN(1) NOT = WS-SEEN(2) AND WS-SEEN(2) NOT = WS-SEEN(3) AND WS-SEEN(1) NOT = WS-SEEN(3)
         MOVE 1 TO WS-DISTINCT
     END-IF
     MOVE "overlay many each block shows the image of its own stage (1, 4, 7)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DISTINCT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Breaker 1 moves to another block: still three blocks, the old one is gone.
     MOVE 20 TO WS-X
     MOVE 2 TO WS-STAGE
     MOVE 1 TO WS-B
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-B WS-X WS-Y WS-Z WS-STAGE
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay many a breaker moving to another block replaces its entry" TO TL-CASE
     MOVE 108 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO TL-EXPECTED-N
     MOVE BDS-COUNT TO TL-OBSERVED-N
     MOVE "overlay many three entries after the move" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The server ends breaker 2's progress: only that block's overlay goes.
     MOVE 2 TO WS-B
     MOVE 255 TO WS-STAGE
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-B WS-X WS-Y WS-Z WS-STAGE
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay many a server stage 255 removes only that breaker's overlay" TO TL-CASE
     MOVE 72 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The local break interrupted (held item change, other target or another player's break aborts it: CT-BREAKING
*>   is cleared by CONTROLS-INPUT): the local overlay goes, the others stay.
     MOVE 50 TO PL-ENTITY-ID
     MOVE 1 TO CT-BREAKING
     MOVE 9 TO CT-BREAK-X
     MOVE 4 TO CT-BREAK-Y
     MOVE 5 TO CT-BREAK-Z
     MOVE 500 TO CT-BREAK-START
     MOVE 1000 TO CT-BREAK-MS
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay many the local break adds its block to the others" TO TL-CASE
     MOVE 108 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-BREAKING
     CALL "BREAK-OVERLAY-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "overlay many an interrupted local break leaves the others' overlays" TO TL-CASE
     MOVE 72 TO TL-EXPECTED-N
     MOVE RL-BO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   More breakers than the table holds: no overflow, the table stays at 16.
     PERFORM VARYING WS-B FROM 100 BY 1 UNTIL WS-B > 130
         MOVE 3 TO WS-STAGE
         CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-B WS-X WS-Y WS-Z WS-STAGE
     END-PERFORM
     MOVE "overlay many more breakers than the table holds keep it at 16 entries" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE BDS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OVERLAY-MANY.

 COPY CLTEST.
 COPY PACKTEST.
