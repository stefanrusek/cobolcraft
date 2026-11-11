*> Implementation test of the frame budget of client/src/mesher.cob (MESH-DIRTY; operator playtest: a
*> frame meshed up to 64 sections, seconds long): MESH-DIRTY stops when the time budget of the frame
*> (MB-BUDGET-US microseconds) is spent, always meshes at least one dirty section, takes the sections
*> nearest the player first and, over several frames, meshes every dirty section. The clock is injectable
*> (MB-FAKE 1: it advances MB-FAKE-STEP microseconds per meshed section) so the cases are deterministic;
*> one case uses the real clock. An all-air section is skipped at once (MB-EMPTY counts it).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-BUDGET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BIG                 BINARY-LONG VALUE 64.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-N                   PIC Z(3)9.
 01 WS-N2                  PIC Z(3)9.
 01 WS-N3                  PIC Z(3)9.
 01 WS-TEXT                PIC X(1024).
 01 WS-MARKED              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 1000 TO SK-U
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-CX = WS-I - 1
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-ZERO WS-ROW(WS-I)
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW(WS-I))
         MOVE ALL X"FF" TO CE-SKYS
*>       Terrain in the sections 1 to 3 (a floor of 6 to 10 blocks with relief in each), air above.
         PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 2
             PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
                 PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                     COMPUTE WS-H = 6 + FUNCTION MOD(WS-X * 7 + WS-Z * 13 + WS-I, 5)
                     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= WS-H
                         COMPUTE WS-CELL = (WS-S * 16 + WS-Y) * 256 + WS-Z * 16 + WS-X + 1
                         MOVE 2 TO CE-STATE(WS-CELL)
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 1 TO MB-FAKE
     MOVE 8000 TO MB-BUDGET-US
     MOVE 4000 TO MB-FAKE-STEP

*>   Ten dirty terrain sections in the first frame: the fake clock reads 0, 4000 (both under 8000)
*>   and 8000 (spent): two sections.
     PERFORM MARK-TEN
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     PERFORM COUNT-DIRTY
     MOVE "mesher budget a frame of 8000 us with sections costing 4000 us meshes two of ten dirty sections"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "meshed 2 dirty 8" TO TL-EXPECTED
     MOVE MB-MESHED TO WS-N
     MOVE WS-DIRTY TO WS-N2
     MOVE SPACES TO TL-OBSERVED
     STRING "meshed " FUNCTION TRIM(WS-N) " dirty " FUNCTION TRIM(WS-N2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Over several frames every dirty section is meshed, never more than two in a frame.
     MOVE 1 TO WS-FRAMES
     MOVE 2 TO WS-MAX
     PERFORM UNTIL WS-DIRTY = 0 OR WS-FRAMES > 40
         MOVE 0 TO MB-FAKE-NOW
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
         IF MB-MESHED > WS-MAX
             MOVE MB-MESHED TO WS-MAX
         END-IF
         ADD 1 TO WS-FRAMES
         PERFORM COUNT-DIRTY
     END-PERFORM
     MOVE "mesher budget all dirty sections are meshed over the frames (5 frames of two), none "
         & "more than two in a frame" TO TL-CASE
     MOVE "frames 5 dirty 0 max 2" TO TL-EXPECTED
     MOVE WS-FRAMES TO WS-N
     MOVE WS-DIRTY TO WS-N2
     MOVE WS-MAX TO WS-N3
     MOVE SPACES TO TL-OBSERVED
     STRING "frames " FUNCTION TRIM(WS-N) " dirty " FUNCTION TRIM(WS-N2) " max "
         FUNCTION TRIM(WS-N3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A budget below the cost of one section still meshes one section (the frame always progresses).
     MOVE 1000 TO MB-BUDGET-US
     PERFORM MARK-TEN
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE "mesher budget a budget under the cost of one section meshes exactly one section" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MB-MESHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The section-count argument still caps the frame.
     MOVE 1000000 TO MB-BUDGET-US
     PERFORM MARK-TEN
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE "mesher budget the section-count argument caps a frame whose time budget is not spent"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MB-MESHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Nearest first: the player stands in the chunk of row 4 (chunk x 3); with one section a frame the
*>   first meshed is row 4's, then row 3's, 2's and 1's (section 1 of each is dirty).
     MOVE 1000 TO MB-BUDGET-US
     MOVE 56.5 TO PL-X
     MOVE 8.5 TO PL-Z
     MOVE 12 TO PL-Y
     PERFORM CLEAR-DIRTY
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
         MOVE 1 TO WR-DIRTY(WS-ROW(WS-R), 1)
         MOVE 0 TO WR-UPLOAD(WS-ROW(WS-R), 1)
     END-PERFORM
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-FRAMES FROM 1 BY 1 UNTIL WS-FRAMES > 4
         MOVE 0 TO MB-FAKE-NOW
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
             IF WR-DIRTY(WS-ROW(WS-R), 1) = 0 AND WR-UPLOAD(WS-ROW(WS-R), 1) = 1
                 MOVE WS-R TO WS-N
                 MOVE 0 TO WR-UPLOAD(WS-ROW(WS-R), 1)
                 MOVE SPACES TO WS-TEXT
                 STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-N) DELIMITED BY SIZE
                     INTO WS-TEXT
                 MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "mesher budget dirty sections are meshed nearest the player first" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "4 3 2 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An all-air section is skipped at once; a terrain section is not counted as empty.
     MOVE 0 TO MB-EMPTY
     MOVE 5 TO WS-S
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW(1) WS-S
     MOVE MB-EMPTY TO WS-N
     MOVE WR-OP-COUNT(WS-ROW(1), 5) TO WS-N2
     MOVE 1 TO WS-S
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW(1) WS-S
     MOVE MB-EMPTY TO WS-N3
     MOVE "mesher an all-air section is counted empty with no vertices, a terrain section is not"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "empty 1 vertices 0 then empty 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "empty " FUNCTION TRIM(WS-N) " vertices " FUNCTION TRIM(WS-N2) " then empty "
         FUNCTION TRIM(WS-N3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The real clock: a one microsecond budget is spent by the first section.
     MOVE 0 TO MB-FAKE
     MOVE 1 TO MB-BUDGET-US
     PERFORM MARK-TEN
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE "mesher budget with the real clock a one microsecond budget meshes exactly one section"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MB-MESHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 MARK-TEN.
     PERFORM CLEAR-DIRTY
     MOVE 56.5 TO PL-X
     MOVE 8.5 TO PL-Z
     MOVE 12 TO PL-Y
     MOVE 0 TO WS-MARKED
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
             IF WS-MARKED < 10
                 MOVE 1 TO WR-DIRTY(WS-ROW(WS-R), WS-S)
                 ADD 1 TO WS-MARKED
             END-IF
         END-PERFORM
     END-PERFORM
     EXIT PARAGRAPH.

 CLEAR-DIRTY.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
             MOVE 0 TO WR-DIRTY(WS-ROW(WS-R), WS-S)
         END-PERFORM
     END-PERFORM
     EXIT PARAGRAPH.

 COUNT-DIRTY.
     MOVE 0 TO WS-DIRTY
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
             IF WR-DIRTY(WS-ROW(WS-R), WS-S) = 1
                 ADD 1 TO WS-DIRTY
             END-IF
         END-PERFORM
     END-PERFORM
     EXIT PARAGRAPH.
 END PROGRAM TEST-MESHER-BUDGET.
 COPY CLTEST.
