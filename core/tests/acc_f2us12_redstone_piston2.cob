*> Acceptance test (T29575, US12-4; docs/protocol/30-redstone-3-pistons.md sections 4.3, 4.4 and 5.1): the structure resolver over the world, called directly (no ticks): the collision of two
*> branches reorders the list (4.4, the expected list comes from an independent model of the section, checked by hand against the example of 4.4), the limit of 12 is met by the first cell of a
*> line (4.3 step 4), and isPushable's world edges and PUSH-only blocks (5.1). Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-PISTON2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY PSTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/p46h-piston2-world".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-FACE-N              BINARY-LONG.
 01 WS-FLAG-N              BINARY-LONG.
 01 WS-TYPE-N              BINARY-LONG.
 01 WS-EXTENDING           BINARY-LONG VALUE 1.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXP                 PIC X(160).
 01 WS-OBS                 PIC X(160).
 01 WS-LIST                PIC X(160).
 01 WS-I                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-N3                  PIC 999.
 01 WS-ALLOW               BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-BE-TYPE             BINARY-LONG.
 01 WS-PUSH-ONLY           BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone piston 2: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 14
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 16
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   4.4 two branches meet. The piston (1,102,5) faces east; slime at (2,102,5) starts the line; (2,103,5) stone, (3,103,5) honey, (2,102,6) slime, (2,103,6) slime, (3,103,6) stone.
*>   The model of section 4: the start line is [(2,102,5)]; its branching lists the stone above (2,103,5) with the honey in front of it (3,103,5), then the slime beside it (2,102,6) whose own
*>   branching reaches (2,103,6), the slime above it, whose forward scan meets the stone (3,103,6) listed before: the line is moved in front of the part it met.
     MOVE 1 TO WS-X MOVE 102 TO WS-Y MOVE 5 TO WS-Z
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N
     CALL "PST-STATE-OF" USING WS-CODE WS-FACE-N WS-FLAG-N WS-TYPE-N WS-ST
     PERFORM PUT-ST
     MOVE 2 TO WS-X MOVE 102 TO WS-Y MOVE 5 TO WS-Z MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE 103 TO WS-Y MOVE 5 TO WS-Z MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE 103 TO WS-Y MOVE 5 TO WS-Z MOVE "honey_block" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE 102 TO WS-Y MOVE 6 TO WS-Z MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE 103 TO WS-Y MOVE 6 TO WS-Z MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE 103 TO WS-Y MOVE 6 TO WS-Z MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 1 TO WS-PX MOVE 102 TO WS-PY MOVE 5 TO WS-PZ
     CALL "PST-RESOLVE" USING WS-DIM WS-PX WS-PY WS-PZ WS-FACE-N WS-EXTENDING WS-OK
     MOVE WS-OK TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 4.4 two branches meeting still resolve" TO WS-CASE
     MOVE "1" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
     PERFORM BUILD-LIST
     MOVE "acceptance US12-4 pistons 30-3 4.4 the line that met the other is moved in front of the part it met" TO WS-CASE
     MOVE "002,102,005;002,103,005;003,103,005;002,102,006;002,103,006;003,103,006;" TO WS-EXP
     MOVE WS-LIST TO WS-OBS
     PERFORM ASSERT-TEXT
*>   4.3 step 4: a line whose first cell meets 12 listed cells fails. Row z 10 at y 102: slime (2), ten stones (3 to 12), slime (13) is 12 cells, a stone beside the first slime is the 13th.
     MOVE 1 TO WS-X MOVE 102 TO WS-Y MOVE 10 TO WS-Z
     PERFORM PUT-STATE-PISTON
     MOVE 2 TO WS-X MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     PERFORM VARYING WS-NX FROM 3 BY 1 UNTIL WS-NX > 12
         MOVE WS-NX TO WS-X
         MOVE "stone" TO WS-K
         PERFORM PUT-DEF
     END-PERFORM
     MOVE 2 TO WS-X MOVE 9 TO WS-Z MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 10 TO WS-Z
     MOVE 1 TO WS-PX MOVE 102 TO WS-PY MOVE 10 TO WS-PZ
     CALL "PST-RESOLVE" USING WS-DIM WS-PX WS-PY WS-PZ WS-FACE-N WS-EXTENDING WS-OK
     MOVE WS-OK TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 4.3 eleven in the line and one beside the first slime is the limit of 12: resolves" TO WS-CASE
     MOVE "1" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
     MOVE 13 TO WS-X MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     CALL "PST-RESOLVE" USING WS-DIM WS-PX WS-PY WS-PZ WS-FACE-N WS-EXTENDING WS-OK
     MOVE WS-OK TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 4.3 twelve in the line and one beside the first slime is the 13th: the push fails" TO WS-CASE
     MOVE "0" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
*>   4.3 branches: a slime beside the line whose own line runs back along the push axis to the piston's column. Piston (1,102,13) faces east; slime (2,102,13) starts the line; the slime above it (2,103,13)
*>   has the slime (1,103,13) behind it (the piston's cell is below that one: the branch of that slime reaches the piston itself, which is not part of the structure).
     MOVE 1 TO WS-X MOVE 102 TO WS-Y MOVE 13 TO WS-Z
     PERFORM PUT-STATE-PISTON
     MOVE 2 TO WS-X MOVE 102 TO WS-Y MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE 103 TO WS-Y MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 1 TO WS-X MOVE 103 TO WS-Y MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 1 TO WS-PX MOVE 102 TO WS-PY MOVE 13 TO WS-PZ
     CALL "PST-RESOLVE" USING WS-DIM WS-PX WS-PY WS-PZ WS-FACE-N WS-EXTENDING WS-OK
     MOVE WS-OK TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 4.3 a slime behind a branch that sits above the piston resolves" TO WS-CASE
     MOVE "1" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
     PERFORM BUILD-LIST
     MOVE "acceptance US12-4 pistons 30-3 4.3 and the piston itself is not in the list" TO WS-CASE
     MOVE "002,102,013;001,103,013;002,103,013;" TO WS-EXP
     MOVE WS-LIST TO WS-OBS
     PERFORM ASSERT-TEXT
*>   4.3 step 4 in the walk back along the push axis: the branch above the first slime is a line of 13 slimes (x 3 to 15 at y 103), the walk back from (15,103) passes the limit of 12 listed cells.
     MOVE 14 TO WS-X MOVE 102 TO WS-Y MOVE 14 TO WS-Z
     PERFORM PUT-STATE-PISTON
     MOVE 15 TO WS-X MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 103 TO WS-Y
     PERFORM VARYING WS-NX FROM 3 BY 1 UNTIL WS-NX > 15
         MOVE WS-NX TO WS-X
         MOVE "slime_block" TO WS-K
         PERFORM PUT-DEF
     END-PERFORM
     MOVE 14 TO WS-PX MOVE 102 TO WS-PY MOVE 14 TO WS-PZ
     CALL "PST-RESOLVE" USING WS-DIM WS-PX WS-PY WS-PZ WS-FACE-N WS-EXTENDING WS-OK
     MOVE WS-OK TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 4.3 a branch whose walk back along the axis passes 12 cells fails" TO WS-CASE
     MOVE "0" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
*>   4.4 the re-check after the reorder: the layout of the first 4.4 case at z 1 and 2, with a stone above the last slime and an unmovable block in front of that stone: the re-check branches the slime that met
*>   the other line, and its branch cannot move, so the whole push fails.
     MOVE 1 TO WS-X MOVE 102 TO WS-Y MOVE 1 TO WS-Z
     PERFORM PUT-STATE-PISTON
     MOVE 2 TO WS-X MOVE 102 TO WS-Y MOVE 1 TO WS-Z MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE 103 TO WS-Y MOVE 1 TO WS-Z MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE 103 TO WS-Y MOVE 1 TO WS-Z MOVE "honey_block" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE 102 TO WS-Y MOVE 2 TO WS-Z MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE 103 TO WS-Y MOVE 2 TO WS-Z MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE 103 TO WS-Y MOVE 2 TO WS-Z MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE 104 TO WS-Y MOVE 2 TO WS-Z MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE 104 TO WS-Y MOVE 2 TO WS-Z MOVE "obsidian" TO WS-K PERFORM PUT-DEF
     MOVE 1 TO WS-PX MOVE 102 TO WS-PY MOVE 1 TO WS-PZ
     CALL "PST-RESOLVE" USING WS-DIM WS-PX WS-PY WS-PZ WS-FACE-N WS-EXTENDING WS-OK
     MOVE WS-OK TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 4.4 a branch that cannot move found by the re-check fails the push" TO WS-CASE
     MOVE "0" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
*>   5.1 world edges: below the world, DOWN at the lowest layer, UP at the top layer
     MOVE 5 TO WS-X MOVE 12 TO WS-Z
     COMPUTE WS-Y = DM-MIN-Y(WS-DIM) - 1
     MOVE 1 TO WS-ALLOW MOVE 5 TO WS-PF MOVE 5 TO WS-DIR
     CALL "PST-PUSHABLE" USING WS-DIM WS-X WS-Y WS-Z WS-DIR WS-ALLOW WS-PF WS-RESULT
     MOVE WS-RESULT TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 5.1 a cell below the world is not pushable" TO WS-CASE
     MOVE "0" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
     MOVE DM-MIN-Y(WS-DIM) TO WS-Y
     MOVE 0 TO WS-DIR
     CALL "PST-PUSHABLE" USING WS-DIM WS-X WS-Y WS-Z WS-DIR WS-ALLOW WS-PF WS-RESULT
     MOVE WS-RESULT TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 5.1 a block on the lowest layer is not pushed DOWN" TO WS-CASE
     MOVE "0" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
     COMPUTE WS-TOP = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM) - 1
     MOVE WS-TOP TO WS-Y
     MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 1 TO WS-DIR
     CALL "PST-PUSHABLE" USING WS-DIM WS-X WS-Y WS-Z WS-DIR WS-ALLOW WS-PF WS-RESULT
     MOVE WS-RESULT TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 5.1 a block on the top layer is not pushed UP" TO WS-CASE
     MOVE "0" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
*>   5.1 rule 6: a PUSH-only block (CB-PUSH 1, no block entity, breakable) moves only in the direction the piston faces
     MOVE 0 TO WS-PUSH-ONLY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT OR WS-PUSH-ONLY > 0
         COMPUTE WS-B = WS-I - 1
         CALL "BE-BLOCK-TYPE" USING WS-B WS-BE-TYPE
         IF CB-PUSH(WS-I) = 1 AND WS-BE-TYPE < 0 AND CB-BREAK-MS(WS-I) NOT = -1 AND CB-CLASS(WS-I) NOT = 31 AND CB-CLASS(WS-I) NOT = 32
             MOVE WS-I TO WS-PUSH-ONLY
         END-IF
     END-PERFORM
     MOVE 5 TO WS-X MOVE 102 TO WS-Y MOVE 12 TO WS-Z
     MOVE CB-DEFAULT-STATE(WS-PUSH-ONLY) TO WS-ST
     PERFORM PUT-ST
     MOVE 5 TO WS-DIR MOVE 4 TO WS-PF
     CALL "PST-PUSHABLE" USING WS-DIM WS-X WS-Y WS-Z WS-DIR WS-ALLOW WS-PF WS-RESULT
     MOVE WS-RESULT TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 5.1 a PUSH-only block pushed sideways to the piston's facing does not move" TO WS-CASE
     MOVE "0" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
     MOVE 5 TO WS-PF
     CALL "PST-PUSHABLE" USING WS-DIM WS-X WS-Y WS-Z WS-DIR WS-ALLOW WS-PF WS-RESULT
     MOVE WS-RESULT TO WS-ED
     MOVE "acceptance US12-4 pistons 30-3 5.1 and moves along it" TO WS-CASE
     MOVE "1" TO WS-EXP
     MOVE FUNCTION TRIM(WS-ED) TO WS-OBS
     PERFORM ASSERT-TEXT
     STOP RUN.

 PUT-STATE-PISTON.
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N
     CALL "PST-STATE-OF" USING WS-CODE WS-FACE-N WS-FLAG-N WS-TYPE-N WS-ST
     PERFORM PUT-ST.

 BUILD-LIST.
*>   WS-LIST = the cells of toPush in list order as "x,y,z;"
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-NX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PS-NPUSH
         MOVE PS-P-X(WS-I) TO WS-N3
         STRING WS-N3 "," DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-NX
         MOVE PS-P-Y(WS-I) TO WS-N3
         STRING WS-N3 "," DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-NX
         MOVE PS-P-Z(WS-I) TO WS-N3
         STRING WS-N3 ";" DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-NX
     END-PERFORM.

 MAKE-DEF.
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 ASSERT-TEXT.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-F2US12-REDSTONE-PISTON2.

 COPY CORETEST.
 COPY PORTALTEST.
