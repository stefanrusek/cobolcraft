*> Implementation test of the order and the cost of the mesh queue (client/src/mesher.cob MESH-DIRTY; operator report "lots of blocks aren't rendering:
*> logs, leaves, paths, holes in the grass floor", try14 play at render distance 12: the sections a chunk brings were meshed so slowly that the
*> view stayed full of holes for minutes). The queue (1) meshes a section that was never meshed (a hole in the picture) before one that is only
*> meshed again (a neighbour arrived, a light changed: the old mesh is still drawn), whatever their distances; (2) takes no queue place and no
*> time for a section of only air (thousands of them are dirty after the chunks of a view arrive), so the sections with blocks are not kept
*> waiting behind them; (3) while a never meshed section lies within CL-MESH-NEAR (6 chunks) of the player works at twice the frame budget and
*> credit (MB-BOOSTED), and not for one farther away. The clock is injected (MB-FAKE: 4000 us per meshed section).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-QUEUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG OCCURS 12 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-RW                  BINARY-LONG.
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
 01 WS-N                   PIC Z(5)9.
 01 WS-N2                  PIC Z(5)9.
 01 WS-N3                  PIC Z(5)9.
 01 WS-CNUM                PIC -(9)9.
 01 WS-DIRTY-AIR           BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 384 TO PL-HEIGHT
     MOVE 1000 TO SK-U
*>   Twelve rows in a line (chunk x 0 to 11, z 0): terrain (6 to 10 blocks with relief) in the sections 1 to 3, air above.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         COMPUTE WS-CX = WS-I - 1
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-ZERO WS-ROW(WS-I)
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW(WS-I))
         MOVE ALL X"FF" TO CE-SKYS
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
*>   The player stands in the chunk of row 4 (chunk x 3), at section 1.
     MOVE 56.5 TO PL-X
     MOVE 8.5 TO PL-Z
     MOVE 8 TO PL-Y
     MOVE 0 TO PL-MIN-Y

*>   (1) Row 4 (the player's chunk) has a mesh in its section 1 and is dirty again; row 1 (three chunks away) was never meshed: one section
*>   a frame (budget 1000 us) goes to row 1 first.
     MOVE 1000 TO MB-BUDGET-US
     PERFORM CLEAR-DIRTY
     MOVE 1 TO WS-S
     CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW(4) WS-S
     MOVE 1 TO WR-DIRTY(WS-ROW(4), 1)
     MOVE 1 TO WR-DIRTY(WS-ROW(1), 1)
     MOVE 0 TO WR-MESHED(WS-ROW(1), 1)
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE WR-DIRTY(WS-ROW(4), 1) TO WS-N
     MOVE WR-DIRTY(WS-ROW(1), 1) TO WS-N2
     MOVE "mesher queue a section never meshed is meshed before one only to be meshed again, though that one is nearer" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "nearer one still dirty 1, never meshed one still dirty 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "nearer one still dirty " FUNCTION TRIM(WS-N) ", never meshed one still dirty " FUNCTION TRIM(WS-N2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The next frame does the redo.
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE WR-DIRTY(WS-ROW(4), 1) TO WS-N
     MOVE "mesher queue the section only to be meshed again is meshed when nothing never meshed waits" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   (2) The sections 4 to 24 of all twelve rows are dirty (252 sections of only air, nearer the player than any of the terrain) and the terrain
*>   sections 1 to 3 of rows 11 and 12 (chunk x 10 and 11, more than 6 chunks away: no boost): with the old candidates (the 64 nearest) a frame
*>   meshed 64 air sections and no terrain.
     MOVE 8000 TO MB-BUDGET-US
     PERFORM CLEAR-DIRTY
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 12
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             IF WS-S > 3 OR WS-R > 10
                 MOVE WS-ROW(WS-R) TO WS-RW
                 MOVE 1 TO WR-DIRTY(WS-RW, WS-S)
                 MOVE WS-ROW(WS-R) TO WS-RW
                 MOVE 0 TO WR-MESHED(WS-RW, WS-S)
                 MOVE WS-ROW(WS-R) TO WS-RW
                 MOVE 0 TO WR-KIND(WS-RW, WS-S)
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE 0 TO WS-DIRTY-AIR
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 12
         PERFORM VARYING WS-S FROM 4 BY 1 UNTIL WS-S > 24
             MOVE WS-ROW(WS-R) TO WS-RW
             IF WR-DIRTY(WS-RW, WS-S) = 1
                 ADD 1 TO WS-DIRTY-AIR
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "mesher queue one frame meshes every dirty section of only air" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIRTY-AIR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-DIRTY-AIR
     PERFORM VARYING WS-R FROM 11 BY 1 UNTIL WS-R > 12
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
             MOVE WS-ROW(WS-R) TO WS-RW
             IF WR-DIRTY(WS-RW, WS-S) = 0
                 ADD 1 TO WS-DIRTY-AIR
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "mesher queue the air does not take the place of the terrain: with the budget of two sections two terrain sections are meshed in the frame"
         TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-DIRTY-AIR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The two meshed are the nearest the player: the sections 1 and 2 of row 11.
     MOVE 0 TO WS-FIRST
     MOVE WS-ROW(11) TO WS-RW
     IF WR-DIRTY(WS-RW, 1) = 0
         ADD 1 TO WS-FIRST
     END-IF
     IF WR-DIRTY(WS-RW, 2) = 0
         ADD 1 TO WS-FIRST
     END-IF
     MOVE "mesher queue the two terrain sections meshed first are the nearest the player" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-FIRST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   (3) Boost: terrain sections never meshed within 6 chunks (row 4: the player's) double the budget of the frame (4 sections of 4000 us in
*>   16000, not 2 in 8000) and the credit; ones farther than 6 chunks (rows 11 and 12: chunk x 10 and 11, 7 and 8 chunks from chunk x 3) do not.
     MOVE 8000 TO MB-BUDGET-US
     PERFORM CLEAR-DIRTY
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
         MOVE 1 TO WR-DIRTY(WS-ROW(4), WS-S)
         MOVE 1 TO WR-DIRTY(WS-ROW(3), WS-S)
         MOVE 0 TO WR-MESHED(WS-ROW(4), WS-S)
         MOVE 0 TO WR-MESHED(WS-ROW(3), WS-S)
         MOVE 0 TO WR-KIND(WS-ROW(4), WS-S)
         MOVE 0 TO WR-KIND(WS-ROW(3), WS-S)
     END-PERFORM
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE "mesher queue never meshed sections near the player double the frame budget (4 sections in 16000 us)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     MOVE MB-MESHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mesher queue never meshed sections near the player set MB-BOOSTED" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MB-BOOSTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CLEAR-DIRTY
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
         MOVE 1 TO WR-DIRTY(WS-ROW(11), WS-S)
         MOVE 1 TO WR-DIRTY(WS-ROW(12), WS-S)
         MOVE 0 TO WR-MESHED(WS-ROW(11), WS-S)
         MOVE 0 TO WR-MESHED(WS-ROW(12), WS-S)
         MOVE 0 TO WR-KIND(WS-ROW(11), WS-S)
         MOVE 0 TO WR-KIND(WS-ROW(12), WS-S)
     END-PERFORM
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE "mesher queue never meshed sections far from the player keep the frame budget (2 sections in 8000 us)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE MB-MESHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mesher queue never meshed sections far from the player leave MB-BOOSTED 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MB-BOOSTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Near sections only to be meshed again (they have a mesh) do not boost.
     PERFORM CLEAR-DIRTY
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
         MOVE 1 TO WR-DIRTY(WS-ROW(4), WS-S)
         MOVE 1 TO WR-MESHED(WS-ROW(4), WS-S)
     END-PERFORM
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE "mesher queue near sections that only wait to be meshed again leave MB-BOOSTED 0 and the frame budget" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MB-BOOSTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The credit of the running client: a boosted frame earns the larger credit (14000), the cap is the same one.
     MOVE 1 TO MB-CREDIT-ON
     PERFORM CLEAR-DIRTY
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
         MOVE 1 TO WR-DIRTY(WS-ROW(4), WS-S)
         MOVE 0 TO WR-MESHED(WS-ROW(4), WS-S)
         MOVE 0 TO WR-KIND(WS-ROW(4), WS-S)
     END-PERFORM
     MOVE 1 TO MB-BOOSTED
     MOVE -50000 TO MB-CREDIT
     MOVE 0 TO MB-FAKE-NOW
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE MB-CREDIT TO WS-CNUM
     MOVE "mesher credit given a boosted frame and a credit of -50000 then the credit is -36000 and nothing is meshed" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "meshed 0 credit -36000" TO TL-EXPECTED
     MOVE MB-MESHED TO WS-N
     MOVE SPACES TO TL-OBSERVED
     STRING "meshed " FUNCTION TRIM(WS-N) " credit " FUNCTION TRIM(WS-CNUM) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO MB-CREDIT-ON
     STOP RUN.

 CLEAR-DIRTY.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 12
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             MOVE WS-ROW(WS-R) TO WS-RW
             MOVE 0 TO WR-DIRTY(WS-RW, WS-S)
         END-PERFORM
     END-PERFORM
     EXIT PARAGRAPH.
 END PROGRAM TEST-MESHER-QUEUE.
 COPY CLTEST.
