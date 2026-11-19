*> Acceptance test (lane p49u; docs/protocol/20 section 16.4 and 16.5): the breeze's position helpers. The light score (0.5 minus the light-dependent magic value of the level: b = level / 15, v = b / (4 - 3 b),
*> Overworld ambient light 0), the 10-candidate selection of getPosAway (the highest score wins, strictly greater, the earliest wins ties, null candidates skipped), the stability test (the block below a
*> candidate is a full solid cube), the whole getPosAway pick on a flat floor (within 5 blocks, stable, away from the target), the jump cell snap (a ray 10 blocks down, else 10 up: BlockPos.containing(hit).above()),
*> the dangerous block below a jump cell (cactus, magma block, lava, fire, wither rose, sweet berry bush, powder snow), the line of sight (the straight collider ray, at most 50 blocks) and the
*> reachability of a walk target cell (not inside a solid block).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-16-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-SCORE               FLOAT-LONG.
 01 WS-OKS.
    05 WS-OK-A             BINARY-LONG OCCURS 10 TIMES.
 01 WS-SCORES.
    05 WS-SCORE-A          FLOAT-LONG OCCURS 10 TIMES.
 01 WS-BEST                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FROM-X              FLOAT-LONG.
 01 WS-FROM-Y              FLOAT-LONG.
 01 WS-FROM-Z              FLOAT-LONG.
 01 WS-TO-X                FLOAT-LONG.
 01 WS-TO-Y                FLOAT-LONG.
 01 WS-TO-Z                FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG VALUE 50.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BAD                 BINARY-LONG.
 01 WS-PICKED              BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LO-X                BINARY-LONG.
 01 WS-HI-X                BINARY-LONG.
 01 WS-LO-Z                BINARY-LONG.
 01 WS-HI-Z                BINARY-LONG.
 01 WS-DANGER              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LABEL               PIC X(160).
 01 WS-NAMES.
    05 FILLER              PIC X(40) VALUE "minecraft:cactus".
    05 FILLER              PIC X(40) VALUE "minecraft:magma_block".
    05 FILLER              PIC X(40) VALUE "minecraft:lava".
    05 FILLER              PIC X(40) VALUE "minecraft:fire".
    05 FILLER              PIC X(40) VALUE "minecraft:wither_rose".
    05 FILLER              PIC X(40) VALUE "minecraft:sweet_berry_bush".
    05 FILLER              PIC X(40) VALUE "minecraft:powder_snow".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(40) OCCURS 7 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:breeze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND

*>   The light score: 0.5 - b / (4 - 3 b), b = level / 15.
     MOVE 15 TO WS-LEVEL
     CALL "BREEZE-LIGHT-SCORE" USING WS-LEVEL WS-SCORE
     MOVE "acceptance US15 20§16.5 the score of a fully lit cell is -0.5" TO TL-CASE
     MOVE -500000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCORE * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LEVEL
     CALL "BREEZE-LIGHT-SCORE" USING WS-LEVEL WS-SCORE
     MOVE "acceptance US15 20§16.5 the score of a dark cell is 0.5" TO TL-CASE
     MOVE 500000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCORE * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-LEVEL
     CALL "BREEZE-LIGHT-SCORE" USING WS-LEVEL WS-SCORE
     MOVE "acceptance US15 20§16.5 the score of light 7 is 0.5 - 0.467 / 2.6 = 0.320513" TO TL-CASE
     MOVE 320513 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCORE * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The selection: strictly greater wins (the earliest of equal scores), a null candidate costs an attempt and is skipped.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE 1 TO WS-OK-A(WS-I)
         MOVE 0.1 TO WS-SCORE-A(WS-I)
     END-PERFORM
     CALL "BREEZE-AWAY-BEST" USING WS-OKS WS-SCORES WS-BEST
     MOVE "acceptance US15 20§16.5 equal scores: the earliest candidate wins" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-BEST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.3 TO WS-SCORE-A(4)
     MOVE 0.3 TO WS-SCORE-A(7)
     MOVE 0.2 TO WS-SCORE-A(9)
     CALL "BREEZE-AWAY-BEST" USING WS-OKS WS-SCORES WS-BEST
     MOVE "acceptance US15 20§16.5 the highest score wins, ties go to the earlier (4 of 4 and 7)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-BEST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-OK-A(4)
     CALL "BREEZE-AWAY-BEST" USING WS-OKS WS-SCORES WS-BEST
     MOVE "acceptance US15 20§16.5 a null candidate is skipped (7 wins)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-BEST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE 0 TO WS-OK-A(WS-I)
     END-PERFORM
     CALL "BREEZE-AWAY-BEST" USING WS-OKS WS-SCORES WS-BEST
     MOVE "acceptance US15 20§16.5 no candidate at all gives none (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BEST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Stability: the block below the cell is a full solid cube. The floor top is WS-FY; the cell above it is stable, the one above that is not, a cell inside the floor is not (air below? no: stone below).
     COMPUTE WS-BX = WS-FX + 20
     COMPUTE WS-BZ = WS-FZ + 20
     COMPUTE WS-BY = WS-FY + 1
     CALL "BREEZE-POS-STABLE" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     MOVE "acceptance US15 20§16.5 a cell on the floor is stable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-FY + 2
     CALL "BREEZE-POS-STABLE" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     MOVE "acceptance US15 20§16.5 a cell one above the floor cell (air below) is not stable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The whole pick: a breeze in the middle of the floor, the target 2 blocks east of it: 30 picks, each within 5 blocks, on the floor, and not toward the target.
     COMPUTE WS-X = WS-FX + 20.5
     COMPUTE WS-Z = WS-FZ + 20.5
     COMPUTE WS-Y = WS-FY + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     COMPUTE WS-TX = WS-X + 2
     MOVE WS-Z TO WS-TZ
     MOVE 0 TO WS-BAD WS-PICKED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "BREEZE-AWAY-PICK" USING WS-MOB WS-TX WS-TZ WS-OK WS-BX WS-BY WS-BZ
         IF WS-OK = 1
             COMPUTE WS-DOT = (WS-BX + 0.5 - WS-X) * (WS-X - WS-TX) + (WS-BZ + 0.5 - WS-Z) * (WS-Z - WS-TZ)
             IF WS-BY NOT = WS-FY + 1 OR WS-BX < WS-FX + 15 OR WS-BX > WS-FX + 25 OR WS-BZ < WS-FZ + 15 OR WS-BZ > WS-FZ + 25
                     OR WS-DOT < -1
                 ADD 1 TO WS-BAD
             END-IF
             ADD 1 TO WS-PICKED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§16.5 getPosAway(5, 5): every pick is a stable cell within 5 blocks, none toward the target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.5 getPosAway(5, 5): 10 candidates of which one in 11 has the floor's height, so most picks find a cell (at least 10 of 30)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PICKED >= 10
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB


*>   Water in the candidate cells is a malus (WATER is not 0): with the whole layer of water around the breeze no candidate is valid.
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     COMPUTE WS-Y = WS-FY + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     COMPUTE WS-LO-X = WS-FX + 12
     COMPUTE WS-HI-X = WS-FX + 28
     COMPUTE WS-LO-Z = WS-FZ + 12
     COMPUTE WS-HI-Z = WS-FZ + 28
     COMPUTE WS-BY = WS-FY + 1
     PERFORM VARYING WS-BX FROM WS-LO-X BY 1 UNTIL WS-BX > WS-HI-X
         PERFORM VARYING WS-BZ FROM WS-LO-Z BY 1 UNTIL WS-BZ > WS-HI-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-PICKED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "BREEZE-AWAY-PICK" USING WS-MOB WS-TX WS-TZ WS-OK WS-BX WS-BY WS-BZ
         ADD WS-OK TO WS-PICKED
     END-PERFORM
     MOVE "acceptance US15 20§16.5 water in every candidate cell is a malus: no pick" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PICKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-FY + 1
     PERFORM VARYING WS-BX FROM WS-LO-X BY 1 UNTIL WS-BX > WS-HI-X
         PERFORM VARYING WS-BZ FROM WS-LO-Z BY 1 UNTIL WS-BZ > WS-HI-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
         END-PERFORM
     END-PERFORM

*>   The slide point (16.5): a target 3 blocks away (inside the inner circle): the away cell when in sight and farther from the target, else the point behind it or the middle-circle point; a target 6
*>   blocks away: the point behind it (head yaw 0: on its -z side) or the middle-circle point. 40 draws each: the point is always 4 to 8 blocks from the target (the away cell: farther than the breeze, within 5 blocks per axis of it: at most 10.2 from the target).
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         COMPUTE WS-TX = WS-X + 3 * WS-K
         MOVE WS-TX TO PL-X(WS-PLAYER)
         MOVE WS-Y TO PL-Y(WS-PLAYER)
         MOVE WS-Z TO PL-Z(WS-PLAYER)
         MOVE 0 TO PL-YAW(WS-PLAYER) WS-BAD
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
             CALL "BREEZE-SLIDE-POINT" USING WS-MOB WS-PLAYER WS-PX WS-PY WS-PZ
             COMPUTE WS-DIST = FUNCTION SQRT((WS-PX - WS-TX) ** 2 + (WS-PZ - WS-Z) ** 2)
             IF WS-DIST > 10.2 OR WS-DIST < 2.99 OR (WS-K = 2 AND (WS-DIST < 3.99 OR WS-DIST > 8.01))
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         MOVE "acceptance US15 20§16.5 40 slide points of a target 3 or 6 blocks away lie within the allowed band of it" TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   The snap: from 3 blocks above the floor top the ray down hits the top face (y = FY + 1): containing is the cell FY + 1, above is FY + 2. A point inside a ceiling block of the cell above: the ray down finds nothing in 10 blocks over air, then up.
     COMPUTE WS-FROM-X = WS-FX + 10.5
     COMPUTE WS-FROM-Z = WS-FZ + 10.5
     COMPUTE WS-FROM-Y = WS-FY + 4.3
     CALL "BREEZE-SNAP" USING WS-DIM WS-FROM-X WS-FROM-Y WS-FROM-Z WS-OK WS-BX WS-BY WS-BZ
     MOVE "acceptance US15 20§16.4 the ray down hits the floor top: the cell is FY + 2" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1000 + WS-FY + 2
     COMPUTE TL-OBSERVED-N = WS-OK * 1000 + WS-BY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.4 the snapped cell keeps the point's column" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (WS-FX + 10) * 1000 + WS-FZ + 10
     COMPUTE TL-OBSERVED-N = WS-BX * 1000 + WS-BZ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A column of air over the void: at 15 blocks above the floor the ray down (10 blocks) finds nothing; up finds nothing either: none.
     COMPUTE WS-FROM-Y = WS-FY + 15.5
     CALL "BREEZE-SNAP" USING WS-DIM WS-FROM-X WS-FROM-Y WS-FROM-Z WS-OK WS-BX WS-BY WS-BZ
     MOVE "acceptance US15 20§16.4 no block within 10 blocks down or up: no cell" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A point inside the floor: the down ray starts in the solid block (hit at the point), the cell above it.
     COMPUTE WS-FROM-Y = WS-FY + 0.5
     CALL "BREEZE-SNAP" USING WS-DIM WS-FROM-X WS-FROM-Y WS-FROM-Z WS-OK WS-BX WS-BY WS-BZ
     MOVE "acceptance US15 20§16.4 a point inside a block hits at once: the cell above that cell" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1000 + WS-FY + 1
     COMPUTE TL-OBSERVED-N = WS-OK * 1000 + WS-BY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Under a ceiling: a stone block 5 blocks above the point, the point in the air column whose floor is 20 blocks down: the ray down finds nothing, the ray up hits the ceiling bottom (y = block y): the cell is the block y + 1.
     COMPUTE WS-CX = WS-FX + 30
     COMPUTE WS-CZ = WS-FZ + 30
     COMPUTE WS-CY = WS-FY + 50
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STONE
     COMPUTE WS-FROM-X = WS-CX + 0.5
     COMPUTE WS-FROM-Z = WS-CZ + 0.5
     COMPUTE WS-FROM-Y = WS-CY - 5.5
     CALL "BREEZE-SNAP" USING WS-DIM WS-FROM-X WS-FROM-Y WS-FROM-Z WS-OK WS-BX WS-BY WS-BZ
     MOVE "acceptance US15 20§16.4 nothing below within 10 blocks: the ray up hits the ceiling, the cell is the block y + 1" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1000 + WS-CY + 1
     COMPUTE TL-OBSERVED-N = WS-OK * 1000 + WS-BY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR

*>   The block below the snapped cell must not be dangerous: stone is fine; each of the listed blocks is.
     COMPUTE WS-BX = WS-FX + 12
     COMPUTE WS-BZ = WS-FZ + 12
     COMPUTE WS-BY = WS-FY + 2
     CALL "BREEZE-DANGEROUS" USING WS-DIM WS-BX WS-BY WS-BZ WS-DANGER
     MOVE "acceptance US15 20§16.4 step 9: stone below the cell is not dangerous" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DANGER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-CY = WS-BY - 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE WS-NAME(WS-I) TO WS-KEY
         CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-STATE
         CALL "BREEZE-DANGEROUS" USING WS-DIM WS-BX WS-BY WS-BZ WS-DANGER
         MOVE SPACES TO WS-LABEL
         STRING "acceptance US15 20§16.4 step 9: " DELIMITED BY SIZE FUNCTION TRIM(WS-NAME(WS-I)) DELIMITED BY SIZE
             " below the cell is dangerous" DELIMITED BY SIZE INTO WS-LABEL
         MOVE WS-LABEL TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-DANGER TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-STONE

*>   Line of sight (the breeze's feet to the jump cell centre): open air passes; a stone block on the line blocks; more than 50 blocks fails.
     COMPUTE WS-FROM-X = WS-FX + 5.5
     COMPUTE WS-FROM-Y = WS-FY + 1
     COMPUTE WS-FROM-Z = WS-FZ + 20.5
     COMPUTE WS-TO-X = WS-FX + 15.5
     COMPUTE WS-TO-Y = WS-FY + 2.5
     COMPUTE WS-TO-Z = WS-FZ + 20.5
     CALL "BREEZE-LOS" USING WS-DIM WS-FROM-X WS-FROM-Y WS-FROM-Z WS-TO-X WS-TO-Y WS-TO-Z WS-LIMIT WS-OK
     MOVE "acceptance US15 20§16.4 step 10: a clear line passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BX = WS-FX + 10
     COMPUTE WS-BY = WS-FY + 1
     COMPUTE WS-BZ = WS-FZ + 20
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     CALL "BREEZE-LOS" USING WS-DIM WS-FROM-X WS-FROM-Y WS-FROM-Z WS-TO-X WS-TO-Y WS-TO-Z WS-LIMIT WS-OK
     MOVE "acceptance US15 20§16.4 step 10: a stone block on the line blocks it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-TO-Y = WS-FY + 60
     CALL "BREEZE-LOS" USING WS-DIM WS-FROM-X WS-FROM-Y WS-FROM-Z WS-TO-X WS-TO-Y WS-TO-Z WS-LIMIT WS-OK
     MOVE "acceptance US15 20§16.4 step 10: a point farther than 50 blocks fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Reachability of a walk target cell: an open cell above the floor is; a cell inside a solid block is not.
     COMPUTE WS-BX = WS-FX + 8
     COMPUTE WS-BZ = WS-FZ + 8
     COMPUTE WS-BY = WS-FY + 1
     CALL "BREEZE-REACHABLE" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     MOVE "acceptance US15 16.1 an open cell on the floor is reachable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-FY TO WS-BY
     CALL "BREEZE-REACHABLE" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     MOVE "acceptance US15 16.1 a cell inside the floor is not reachable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-16-7.
 COPY CORETEST.
 COPY MOBSPTEST.
