*> Test of the engine's sliding window over the chunk cache (core/src/light-32g.cob L32-LIGHT-ROW, L32-BLOCK-CHANGED, L32-WINDOW-PASS, L32-SLOT-SYNC; T0697) on the cobolcraft world: the light the engine
*> keeps incrementally (a new chunk beside a lit one, a block change, cells changed behind its back, too many of them, a changed dimension or content set) is the light it computes from scratch for the same cells:
*> every case compares the light of the chunks in the cache with a rebuild of the window from empty (WN-VALID 0), which loads and lights the chunks as the first call of a run does.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-32-BRIDGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CELLS.
 COPY CBLOCKS.
 COPY L32WIN.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW0                BINARY-LONG.
 01 WS-ROW1                BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-DIM2                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SAVED-SKY           PIC X(53248).
 01 WS-SAVED-BLK           PIC X(53248).
 01 WS-SAVED-SKY1          PIC X(53248).
 01 WS-SAVED-BLK1          PIC X(53248).
 01 WS-LEVEL               BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-SHOW                PIC -(9)9.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM VARYING WS-CZ FROM -2 BY 1 UNTIL WS-CZ > 2
         PERFORM VARYING WS-CX FROM -2 BY 1 UNTIL WS-CX > 4
             CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW0
     MOVE 1 TO WS-CX
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW1

*>   Case 1: chunk (0, 0) is lit, then (1, 0) beside it: the second call loads only the new column of the window.
     CALL "L32-LIGHT-ROW" USING WS-ROW0
     CALL "L32-LIGHT-ROW" USING WS-ROW1
     MOVE "acceptance US12 32§8.3 a chunk lit after its neighbour: the light of both equals a rebuild of the window" TO TL-CASE
     PERFORM CHECK-BOTH

*>   Case 2: a lit glowtube placed and a stone roof laid over a column of the chunk, told to L32-BLOCK-CHANGED.
     MOVE 8 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE CR-GLOWTUBE-LIT TO WS-STATE
     PERFORM PUT-BLOCK
     MOVE 14 TO WS-X
     MOVE 90 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE CR-GREYSTONE TO WS-STATE
     PERFORM PUT-BLOCK
     MOVE "acceptance US12 32§8.1 block changes told to L32-BLOCK-CHANGED: the light equals a rebuild of the window" TO TL-CASE
     PERFORM CHECK-BOTH

*>   Case 3: the glowtube removed and the stone taken away again, a change next to the chunk border (x 16 of chunk (1, 0)).
     MOVE 8 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE 0 TO WS-STATE
     PERFORM PUT-BLOCK
     MOVE 14 TO WS-X
     MOVE 90 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 0 TO WS-STATE
     PERFORM PUT-BLOCK
     MOVE 15 TO WS-X
     MOVE 75 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE CR-GLOWTUBE-LIT TO WS-STATE
     PERFORM PUT-BLOCK
     MOVE "acceptance US12 32§8.1 removals and a source on the chunk border: the light equals a rebuild of the window" TO TL-CASE
     PERFORM CHECK-BOTH

*>   Case 4: cells changed in the cache without L32-BLOCK-CHANGED (an overflow written into a lit chunk): L32-LIGHT-ROW finds them against the loaded copy and redoes their light.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW0)
     MOVE CR-GLOWTUBE-LIT TO CE-STATE(60 * 256 + 2 * 16 + 2 + 1)
     MOVE CR-GREYSTONE TO CE-STATE(95 * 256 + 3 * 16 + 3 + 1)
     MOVE CR-GREYSTONE TO CE-STATE(95 * 256 + 3 * 16 + 4 + 1)
     CALL "L32-LIGHT-ROW" USING WS-ROW0
     MOVE "acceptance US12 32§8.1 cells changed behind the engine: L32-LIGHT-ROW redoes their light, equal to a rebuild of the window" TO TL-CASE
     PERFORM CHECK-BOTH

*>   Case 5: more cells than the window syncs one by one (2304: nine layers of the chunk): the window is rebuilt from empty and the light is the same.
     PERFORM VARYING WS-J FROM 100 BY 1 UNTIL WS-J > 108
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             MOVE CR-GREYSTONE TO CE-STATE(WS-J * 256 + WS-I)
         END-PERFORM
     END-PERFORM
     CALL "L32-LIGHT-ROW" USING WS-ROW0
     MOVE "acceptance US12 32§8.1 a chunk that differs in 2304 cells: the window is rebuilt, the light equals a rebuild of the window" TO TL-CASE
     PERFORM CHECK-BOTH

*>   Case 6: L32-BLOCK-CHANGED for a cell the engine already holds does nothing more than the window check; for a chunk that is not in the window the window is loaded for it.
     MOVE 3 TO WS-X
     MOVE 62 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "L32-BLOCK-CHANGED" USING WS-ROW0 WS-X WS-Y WS-Z
     MOVE 3 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 50 TO WS-X
     MOVE 62 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "L32-BLOCK-CHANGED" USING WS-ROW WS-X WS-Y WS-Z
     MOVE "acceptance US12 32§8.1 a block change for a chunk outside the window loads the window for it: the chunk is lit" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE CK-LIT(WS-ROW) TO WS-SHOW
     MOVE FUNCTION TRIM(WS-SHOW) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Case 7: the dimension without sky light (cobolcraft:subroutine, extra dimensions on) rebuilds the window for its geometry: its chunk has no sky light at all, block light of its marker;
*>   going back to cobolcraft:main rebuilds it again, and a new content set (CB-EPOCH) rebuilds it once more.
     MOVE 2 TO WS-DIM2
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM2 WS-CX WS-CZ WS-ROW2
     CALL "L32-LIGHT-ROW" USING WS-ROW2
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW2)
     MOVE "acceptance US12 32§8.1 a dimension without sky light: the sky light of the chunk is all dark, the block light of its marker is stored" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     IF CE-SKYS = LOW-VALUES
         MOVE "dark" TO TL-OBSERVED
     ELSE
         MOVE "lit" TO TL-OBSERVED
     END-IF
     IF CE-BLOCK-LIGHTS = LOW-VALUES
         STRING FUNCTION TRIM(TL-OBSERVED) " no block light" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " block light" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "dark block light" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "L32-LIGHT-ROW" USING WS-ROW0
     MOVE "acceptance US12 32§8.1 back in the dimension with sky light: the light equals a rebuild of the window" TO TL-CASE
     PERFORM CHECK-BOTH
     ADD 1 TO CB-EPOCH
     CALL "L32-LIGHT-ROW" USING WS-ROW0
     MOVE "acceptance US12 32§8.1 a new content epoch rebuilds the window: the light equals a rebuild of the window" TO TL-CASE
     PERFORM CHECK-BOTH
     STOP RUN.

*> Puts block state WS-STATE at (WS-X, WS-Y, WS-Z) of the cached chunk (the dimension's lowest Y is 0) and tells the engine (L32-BLOCK-CHANGED), as WORLD-SET-BLOCK tells LIGHT-BLOCK-CHANGED.
 PUT-BLOCK.
     COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
     COMPUTE WS-CZ = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELL = WS-Y * 256 + FUNCTION MOD(WS-Z, 16) * 16 + FUNCTION MOD(WS-X, 16) + 1
     MOVE WS-STATE TO CE-STATE(WS-CELL)
     CALL "L32-BLOCK-CHANGED" USING WS-ROW WS-X WS-Y WS-Z
     .

*> Compares the light of the rows WS-ROW0 and WS-ROW1 with the light a rebuild of the window centred on each gives (the rebuild leaves the window as a first call would).
 CHECK-BOTH.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW0)
     MOVE CE-SKYS TO WS-SAVED-SKY
     MOVE CE-BLOCK-LIGHTS TO WS-SAVED-BLK
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW1)
     MOVE CE-SKYS TO WS-SAVED-SKY1
     MOVE CE-BLOCK-LIGHTS TO WS-SAVED-BLK1
     MOVE 0 TO WN-VALID
     CALL "L32-LIGHT-ROW" USING WS-ROW0
     MOVE 0 TO WS-BAD
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW0)
     IF CE-SKYS NOT = WS-SAVED-SKY
         ADD 1 TO WS-BAD
     END-IF
     IF CE-BLOCK-LIGHTS NOT = WS-SAVED-BLK
         ADD 2 TO WS-BAD
     END-IF
     MOVE 0 TO WN-VALID
     CALL "L32-LIGHT-ROW" USING WS-ROW1
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW1)
     IF CE-SKYS NOT = WS-SAVED-SKY1
         ADD 4 TO WS-BAD
     END-IF
     IF CE-BLOCK-LIGHTS NOT = WS-SAVED-BLK1
         ADD 8 TO WS-BAD
     END-IF
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-LIGHT-32-BRIDGE.

 COPY CORETEST.
