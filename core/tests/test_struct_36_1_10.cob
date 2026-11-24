*> Implementation test of the spawn overrides of docs/protocol/36-structures-1-model-placement-starts.md section 10 (T1314; core/src/struct-36-1-10.cob): STRUCT-SPAWN-SELECT takes the structures that reference
*> the chunk of the position in the caller's order (SPAWNSEL.cpy) and returns the first structure with a spawn_overrides entry for the category that has a qualifying start (its start valid, and for bounding_box
*> piece some piece box containing the position, for full the start's bounding box containing it, both inclusive on every axis); no structure qualifying returns 0 (the biome's list is used, which replaces
*> nothing: the override replaces the biome list only at positions it covers). STRUCT-ADJUST-BOX is adjustBoundingBox (5.4): the box itself for terrain_adaptation none, else inflated by 12 in every direction, used
*> for the full box of a start.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY SPAWNSEL.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WIN                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   structure 1: override piece mode, one start of two pieces (0..4 x 0..3 x 0..4 and 10..14 x 0..3 x 0..4), full box 0..14
     PERFORM CLEAR-ALL
     MOVE 1 TO SPS-COUNT
     MOVE 1 TO SPS-OVERRIDE(1)
     MOVE 0 TO SPS-MODE(1)
     PERFORM FILL-STRUCT-ONE
     MOVE 2 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 2 TO WS-Z
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: a position inside a piece qualifies a piece-mode start" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-X
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: a gap between two pieces does not qualify a piece-mode start (the biome's list is used)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO SPS-MODE(1)
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: the same gap qualifies a full-mode start (the start's bounding box contains it)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO WS-X
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: just outside the full box (x 15) does not qualify" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO WS-X
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: the box edge x 14 is inside (inclusive)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-Y
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: y is tested too (y 4 above the 0..3 boxes does not qualify)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a structure without an override for the category is skipped even when the position is inside it; the next structure with an override wins
     MOVE 2 TO SPS-COUNT
     MOVE 0 TO SPS-OVERRIDE(1)
     MOVE 1 TO SPS-OVERRIDE(2)
     MOVE 1 TO SPS-MODE(2)
     MOVE 1 TO SPS-STARTS(2)
     MOVE 1 TO SPS-VALID(2, 1)
     MOVE 0 TO SPS-PIECES(2, 1)
     MOVE -5 TO SPS-BX0(2, 1)
     MOVE -5 TO SPS-BY0(2, 1)
     MOVE -5 TO SPS-BZ0(2, 1)
     MOVE 20 TO SPS-BX1(2, 1)
     MOVE 20 TO SPS-BY1(2, 1)
     MOVE 20 TO SPS-BZ1(2, 1)
     MOVE 2 TO WS-X
     MOVE 1 TO WS-Y
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: a structure without an entry for the category is skipped, the next one with an entry and a covering start wins" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the first structure with a qualifying start wins, in the caller's order
     MOVE 1 TO SPS-OVERRIDE(1)
     MOVE 0 TO SPS-MODE(1)
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: the first structure (in order) with a qualifying start wins when two qualify" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   an invalid start (no pieces) does not count, a second start of the structure does
     MOVE 0 TO SPS-VALID(1, 1)
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: a start without pieces is not valid and is skipped (the covering start of structure 2 wins)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO SPS-STARTS(1)
     MOVE 1 TO SPS-VALID(1, 2)
     MOVE 1 TO SPS-PIECES(1, 2)
     MOVE 0 TO SPS-PX0(1, 2, 1)
     MOVE 0 TO SPS-PY0(1, 2, 1)
     MOVE 0 TO SPS-PZ0(1, 2, 1)
     MOVE 3 TO SPS-PX1(1, 2, 1)
     MOVE 3 TO SPS-PY1(1, 2, 1)
     MOVE 3 TO SPS-PZ1(1, 2, 1)
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: every referencing start is tested, a second start covering the position qualifies the structure" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   no structures at all: none
     MOVE 0 TO SPS-COUNT
     PERFORM RUN-SELECT
     MOVE "acceptance US12 36-1§10 Spawn overrides: no structure references the chunk, the biome's normal list is used" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   adjustBoundingBox (5.4): none keeps the box, every other mode inflates by 12 in every direction
     MOVE 0 TO WS-MODE
     PERFORM ADJUST-ONE
     MOVE "acceptance US12 36-1§10 Spawn overrides: adjustBoundingBox keeps the box for terrain_adaptation none" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-X0 + WS-Y0 + WS-Z0) * 1000 + WS-X1 * 100 + WS-Y1 * 10 + WS-Z1
     MOVE 434 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-MODE
     PERFORM ADJUST-ONE
     MOVE "acceptance US12 36-1§10 Spawn overrides: adjustBoundingBox inflates by 12 for beard_box (-12..16, -12..15, -12..16)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-X0 + 12) * 1000000 + (WS-X1 - 16) * 100000 + (WS-Y0 + 12) * 10000 + (WS-Y1 - 15) * 1000 + (WS-Z0 + 12) * 100 + (WS-Z1 - 16)
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-MODE
     PERFORM ADJUST-ONE
     MOVE "acceptance US12 36-1§10 Spawn overrides: adjustBoundingBox inflates for encapsulate too (maxX 16)" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-X1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADJUST-ONE.
     MOVE 0 TO WS-X0 WS-Y0 WS-Z0
     MOVE 4 TO WS-X1 WS-Z1
     MOVE 3 TO WS-Y1
     CALL "STRUCT-ADJUST-BOX" USING WS-MODE WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1
     .
 RUN-SELECT.
     CALL "STRUCT-SPAWN-SELECT" USING SPAWN-SELECT WS-X WS-Y WS-Z WS-WIN
     .
 CLEAR-ALL.
     INITIALIZE SPAWN-SELECT
     .
 FILL-STRUCT-ONE.
     MOVE 1 TO SPS-STARTS(1)
     MOVE 1 TO SPS-VALID(1, 1)
     MOVE 2 TO SPS-PIECES(1, 1)
     MOVE 0 TO SPS-BX0(1, 1) SPS-BY0(1, 1) SPS-BZ0(1, 1)
     MOVE 14 TO SPS-BX1(1, 1)
     MOVE 3 TO SPS-BY1(1, 1)
     MOVE 4 TO SPS-BZ1(1, 1)
     MOVE 0 TO SPS-PX0(1, 1, 1) SPS-PY0(1, 1, 1) SPS-PZ0(1, 1, 1)
     MOVE 4 TO SPS-PX1(1, 1, 1)
     MOVE 3 TO SPS-PY1(1, 1, 1)
     MOVE 4 TO SPS-PZ1(1, 1, 1)
     MOVE 10 TO SPS-PX0(1, 1, 2)
     MOVE 0 TO SPS-PY0(1, 1, 2) SPS-PZ0(1, 1, 2)
     MOVE 14 TO SPS-PX1(1, 1, 2)
     MOVE 3 TO SPS-PY1(1, 1, 2)
     MOVE 4 TO SPS-PZ1(1, 1, 2)
     .
 END PROGRAM TEST-STRUCT-36-1-10.
