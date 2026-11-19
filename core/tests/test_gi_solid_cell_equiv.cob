*> Equivalence test (002-lane-bugvlag): GI-SOLID-CELL reads the cell table of the chunk it found; it must answer as the version that asked WORLD-GET-BLOCK (solid when the chunk is not loaded
*> or the block is solid, air outside the height). 300 drawn cells over the loaded chunks (stone, glass, a slab and a fence planted at drawn heights among the generated blocks), cells
*> above and below the dimension's height, and cells of a chunk that is not loaded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GI-SOLID-CELL-EQUIV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-KEYS.
    05 WS-KEY              PIC X(112) OCCURS 4 TIMES.
 01 WS-STATES.
    05 WS-STATE-OF         BINARY-LONG OCCURS 4 TIMES.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 20261122.
 01 WS-PICK                BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-REF                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-DIFFER              BINARY-LONG VALUE 0.
 01 WS-PLANTED.
    05 WS-PLANT            OCCURS 120 TIMES.
       10 WS-PLX           BINARY-LONG.
       10 WS-PLY           BINARY-LONG.
       10 WS-PLZ           BINARY-LONG.
 01 WS-SOLIDS              BINARY-LONG VALUE 0.
 01 WS-OPEN                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:stone" TO WS-KEY(1)
     MOVE "minecraft:glass" TO WS-KEY(2)
     MOVE "minecraft:oak_slab" TO WS-KEY(3)
     MOVE "minecraft:oak_fence" TO WS-KEY(4)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "BLOCKS-STATE-OF" USING WS-KEY(WS-I) WS-PAIRS WS-STATE
         MOVE WS-STATE TO WS-STATE-OF(WS-I)
     END-PERFORM
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
*>   planted blocks round the player, then the cells
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         PERFORM DRAW
         COMPUTE WS-X = WS-CX * 16 + FUNCTION MOD(WS-PICK, 40) - 12
         PERFORM DRAW
         COMPUTE WS-Z = WS-CZ * 16 + FUNCTION MOD(WS-PICK, 40) - 12
         PERFORM DRAW
         COMPUTE WS-Y = FUNCTION MOD(WS-PICK, 384) - 64
         PERFORM DRAW
         COMPUTE WS-STATE = FUNCTION MOD(WS-PICK, 4) + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE-OF(WS-STATE)
         MOVE WS-X TO WS-PLX(WS-I)
         MOVE WS-Y TO WS-PLY(WS-I)
         MOVE WS-Z TO WS-PLZ(WS-I)
     END-PERFORM
*>   the planted cells themselves, then drawn ones
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         MOVE WS-PLX(WS-I) TO WS-X
         MOVE WS-PLY(WS-I) TO WS-Y
         MOVE WS-PLZ(WS-I) TO WS-Z
         PERFORM COMPARE-CELL
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         PERFORM DRAW
         COMPUTE WS-X = WS-CX * 16 + FUNCTION MOD(WS-PICK, 40) - 12
         PERFORM DRAW
         COMPUTE WS-Z = WS-CZ * 16 + FUNCTION MOD(WS-PICK, 40) - 12
         PERFORM DRAW
         COMPUTE WS-Y = FUNCTION MOD(WS-PICK, 500) - 90
         PERFORM COMPARE-CELL
     END-PERFORM
*>   cells of a chunk that is not loaded (solid by the rule), the two heights beyond the dimension
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-X = (WS-CX + 30 + WS-I) * 16 + 2
         COMPUTE WS-Z = (WS-CZ - 31) * 16 + 7
         MOVE 70 TO WS-Y
         PERFORM COMPARE-CELL
     END-PERFORM
     COMPUTE WS-X = WS-CX * 16 + 1
     COMPUTE WS-Z = WS-CZ * 16 + 1
     MOVE 320 TO WS-Y
     PERFORM COMPARE-CELL
     MOVE -65 TO WS-Y
     PERFORM COMPARE-CELL
     MOVE 319 TO WS-Y
     PERFORM COMPARE-CELL
     MOVE -64 TO WS-Y
     PERFORM COMPARE-CELL
     MOVE "bugvlag GI-SOLID-CELL answers as the WORLD-GET-BLOCK version on 430 cells" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFFER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugvlag the cells hold solid and open ones (so the comparison is not vacuous)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SOLIDS > 20 AND WS-OPEN > 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The version that asked WORLD-GET-BLOCK, for the cell WS-X, WS-Y, WS-Z, against GI-SOLID-CELL (asked first: an unloaded chunk is still unloaded for it).
 COMPARE-CELL.
     CALL "GI-SOLID-CELL" USING WS-DIM WS-X WS-Y WS-Z WS-GOT
     COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
     COMPUTE WS-ROW = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
     MOVE 1 TO WS-REF
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-ROW WS-STATE
     IF WS-STATE > 0
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLK
         MOVE CB-SOLID(WS-BLK + 1) TO WS-REF
     END-IF
     IF WS-GOT NOT = WS-REF
         ADD 1 TO WS-DIFFER
     END-IF
     IF WS-REF = 1
         ADD 1 TO WS-SOLIDS
     ELSE
         ADD 1 TO WS-OPEN
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16).

 DRAW.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     COMPUTE WS-PICK = FUNCTION MOD(WS-SEED / 65536, 32768).
 END PROGRAM TEST-GI-SOLID-CELL-EQUIV.
 COPY CORETEST.
 COPY MOBSPTEST.
