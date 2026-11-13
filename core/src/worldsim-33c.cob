*> World spawn search of docs/protocol/33 section 6 run against the world: the initial spawn of a new world (6.2) and the first-spawn search of a joining
*> player (6.4). The noise spawn finder of 6.3 needs the density machinery of the standard generator: the origin is chunk (0, 0), as the section says for a
*> generator without spawn targets. A dimension is taken to have no ceiling (its spawn height is the height of the highest non-void block).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-COLUMN-SPAWN.
*> USING dimension row, x, z (BINARY-LONG), found out, y out: getLevelRespawnPos (6.2) of one column: the top is the motion-blocking height (one above the highest
*> non-void block), a column whose surface is water over a lower floor is rejected, then the cells from the top down: a fluid rejects the column and a block with
*> collision returns the cell above it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-Y                   BINARY-LONG.
 01 WS-MOTION              BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-CEILING             BINARY-LONG VALUE 0.
 01 WS-SPAWN-HEIGHT        BINARY-LONG VALUE 64.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-SURFACE             BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-REJECTED            BINARY-LONG.
 01 WS-FLUID-FLAG          BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-FOUND L-Y.
     MOVE 0 TO L-FOUND L-Y
     MOVE DM-MIN-Y(L-DIM) TO WS-MIN-Y
     COMPUTE WS-Y = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     MOVE WS-MIN-Y TO WS-MOTION WS-FLOOR
     MOVE 0 TO WS-REJECTED
     PERFORM VARYING WS-Y FROM WS-Y BY -1 UNTIL WS-Y < WS-MIN-Y OR WS-MOTION > WS-MIN-Y
         CALL "FLUID-CELL" USING L-DIM L-X WS-Y L-Z WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         IF WS-STATE NOT = 0
             COMPUTE WS-MOTION = WS-Y + 1
         END-IF
     END-PERFORM
     MOVE WS-MOTION TO WS-SURFACE
     MOVE WS-MIN-Y TO WS-FLOOR
     IF WS-MOTION > WS-MIN-Y
         COMPUTE WS-Y = WS-MOTION - 1
         PERFORM UNTIL WS-Y < WS-MIN-Y
             CALL "FLUID-CELL" USING L-DIM L-X WS-Y L-Z WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
             IF WS-SOLID = 1
                 COMPUTE WS-FLOOR = WS-Y + 1
                 EXIT PERFORM
             END-IF
             SUBTRACT 1 FROM WS-Y
         END-PERFORM
     END-IF
     CALL "WP-LEVEL-RESPAWN" USING WS-CEILING WS-SPAWN-HEIGHT WS-MOTION WS-MIN-Y WS-SURFACE WS-FLOOR WS-TOP WS-REJECTED
     IF WS-REJECTED = 1
         GOBACK
     END-IF
     COMPUTE WS-Y = WS-TOP + 1
     PERFORM UNTIL WS-Y < WS-MIN-Y OR L-FOUND = 1
         CALL "FLUID-CELL" USING L-DIM L-X WS-Y L-Z WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         COMPUTE WS-FLUID-FLAG = FUNCTION MIN(WS-F, 1)
         MOVE WS-SOLID TO WS-FULL
         CALL "WP-LEVEL-COLUMN" USING WS-FLUID-FLAG WS-FULL WS-ACTION
*>       A fluid cell would reject the column (action 1, the end of the scan); the earlier surface test already rejects every column whose top is a fluid.
         IF WS-ACTION = 1 MOVE -1 TO WS-Y END-IF
         IF WS-ACTION = 2
             MOVE 1 TO L-FOUND
             COMPUTE L-Y = WS-Y + 1
         END-IF
         SUBTRACT 1 FROM WS-Y
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDSIM-COLUMN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-CHUNK-SCAN.
*> USING dimension row, chunk x, chunk z, column (BINARY-LONG, 1 to 256: the next column to scan, in/out), count (BINARY-LONG: at most that many columns
*> are scanned), found out: scans the columns of the chunk in the order of 33 section 6.2 (x outer, z inner; WP-COLUMN) with WORLDSIM-COLUMN-SPAWN; the first column
*> that has a respawn position becomes the world spawn, at the cell's centre (found 1). The column is left at the next one to scan (257 when the chunk is done).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MIN-X               BINARY-LONG.
 01 WS-MIN-Z               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-COLUMN               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-COLUMN L-COUNT L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE L-COUNT TO WS-LEFT
     COMPUTE WS-MIN-X = L-CX * 16
     COMPUTE WS-MIN-Z = L-CZ * 16
     PERFORM UNTIL L-COLUMN > 256 OR L-FOUND = 1 OR WS-LEFT <= 0
         CALL "WP-COLUMN" USING L-COLUMN WS-MIN-X WS-MIN-Z WS-X WS-Z
         CALL "WORLDSIM-COLUMN-SPAWN" USING L-DIM WS-X WS-Z WS-FOUND WS-Y
         IF WS-FOUND = 1
             COMPUTE CW-SPAWN-X = WS-X + 0.5
             MOVE WS-Y TO CW-SPAWN-Y
             COMPUTE CW-SPAWN-Z = WS-Z + 0.5
             MOVE 1 TO L-FOUND
         END-IF
         ADD 1 TO L-COLUMN
         SUBTRACT 1 FROM WS-LEFT
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDSIM-CHUNK-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-INITIAL-SPAWN.
*> No parameters: setInitialSpawn of the overworld (33 section 6.2): the provisional spawn (WP-PROVISIONAL, chunk (0, 0), height 64) is stored first; then the
*> 121 chunks of the square spiral around the origin (WP-SPIRAL) are searched, each chunk's 256 columns with x outer and z inner (WORLDSIM-CHUNK-SCAN); the first column
*> that has a respawn position (WORLDSIM-COLUMN-SPAWN) becomes the world spawn, at the cell's centre. This is the synchronous search; the asynchronous one
*> (GEN-SPAWN-BEGIN, GEN-SPAWN-TICK) finds the same column.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-COLUMN              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 64.
 01 WS-ALL                 BINARY-LONG VALUE 256.
 01 WS-DONE                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE CW-DIM(1) TO WS-DIM
     CALL "WP-PROVISIONAL" USING WS-ZERO WS-ZERO2 WS-HEIGHT WS-X WS-Y WS-Z
     MOVE WS-X TO CW-SPAWN-X
     MOVE WS-Y TO CW-SPAWN-Y
     MOVE WS-Z TO CW-SPAWN-Z
     MOVE 0 TO CW-SPAWN-YAW WS-DONE
     PERFORM VARYING WS-CHUNK FROM 1 BY 1 UNTIL WS-CHUNK > 121 OR WS-DONE = 1
         CALL "WP-SPIRAL" USING WS-CHUNK WS-CX WS-CZ
         MOVE 1 TO WS-COLUMN
         CALL "WORLDSIM-CHUNK-SCAN" USING WS-DIM WS-CX WS-CZ WS-COLUMN WS-ALL WS-FOUND
         IF WS-FOUND = 1
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDSIM-INITIAL-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-SPAWN-BEGIN.
*> No parameters: the asynchronous form of WORLDSIM-INITIAL-SPAWN (docs/design/generation-worker.md): the provisional spawn is stored and the search is left to
*> GEN-SPAWN-TICK (GQ-SP-STATE 1), so that opening the world generates nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENQUEUE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 64.
 PROCEDURE DIVISION.
     CALL "WP-PROVISIONAL" USING WS-ZERO WS-ZERO2 WS-HEIGHT WS-X WS-Y WS-Z
     MOVE WS-X TO CW-SPAWN-X
     MOVE WS-Y TO CW-SPAWN-Y
     MOVE WS-Z TO CW-SPAWN-Z
     MOVE 0 TO CW-SPAWN-YAW
     MOVE 1 TO GQ-SP-STATE GQ-SP-CHUNK GQ-SP-COLUMN
     MOVE 0 TO GQ-SP-DONE
     MOVE 121 TO GQ-SP-TOTAL
     GOBACK.
 END PROGRAM GEN-SPAWN-BEGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-SPAWN-TICK.
*> No parameters: one tick of the asynchronous spawn search (CORE-TICK, after the queue's share). The chunks of the spiral from the current one (as many ahead as
*> there are workers, at least one) are asked of the queue; when the current chunk is loaded, its next GQ-SP-COLUMNS columns are scanned (WORLDSIM-CHUNK-SCAN); a
*> chunk that is done without a spawn moves on to the next of the 121. The search ends at the first spawn or after the last chunk (the provisional spawn stays);
*> the connections held at the end of configuration then join (CONFIG-RELEASE-HELD).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENQUEUE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-AHEAD               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE GQ-SP-COLUMNS.
 PROCEDURE DIVISION.
     IF GQ-SP-STATE NOT = 1
         GOBACK
     END-IF
     MOVE CW-DIM(1) TO WS-DIM
     MOVE FUNCTION MAX(GQ-WORKERS, 1) TO WS-AHEAD
     COMPUTE WS-LAST = GQ-SP-CHUNK + WS-AHEAD - 1
     IF WS-LAST > 121
         MOVE 121 TO WS-LAST
     END-IF
     PERFORM VARYING WS-K FROM GQ-SP-CHUNK BY 1 UNTIL WS-K > WS-LAST
         CALL "WP-SPIRAL" USING WS-K WS-CX WS-CZ
         CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
     CALL "WP-SPIRAL" USING GQ-SP-CHUNK WS-CX WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     CALL "WORLDSIM-CHUNK-SCAN" USING WS-DIM WS-CX WS-CZ GQ-SP-COLUMN WS-COUNT WS-FOUND
     IF GQ-SP-COLUMN > 256 AND WS-FOUND = 0
         ADD 1 TO GQ-SP-DONE
         ADD 1 TO GQ-SP-CHUNK
         MOVE 1 TO GQ-SP-COLUMN
     END-IF
     IF WS-FOUND = 1
         ADD 1 TO GQ-SP-DONE
     END-IF
     IF WS-FOUND = 1 OR GQ-SP-CHUNK > 121
         MOVE 0 TO GQ-SP-STATE
         CALL "CONFIG-RELEASE-HELD"
     END-IF
     GOBACK.
 END PROGRAM GEN-SPAWN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-NEW-WORLD-SPAWN.
*> No parameters: CORE-WORLD-OPEN of a new world; a standard world gets the spawn search of 33 section 6.2: the asynchronous one (GEN-SPAWN-BEGIN) when generation
*> workers serve the standard chunks (a host asked for them and the terrain data are loaded), else WORLDSIM-INITIAL-SPAWN; the cobolcraft world keeps the
*> fixed spawn of standin-content.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENQUEUE.
 01 WS-DEBUG               BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 PROCEDURE DIVISION.
     IF CW-WORLD-TYPE = "standard"
         CALL "WORLD-IS-DEBUG" USING WS-DEBUG
         CALL "GEN-DATA-READY" USING WS-READY
         IF GQ-WORKERS > 0 AND WS-DEBUG = 0 AND WS-READY = 1
             CALL "GEN-SPAWN-BEGIN"
         ELSE
             CALL "WORLDSIM-INITIAL-SPAWN"
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WORLDSIM-NEW-WORLD-SPAWN.
