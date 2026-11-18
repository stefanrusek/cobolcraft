*> The bridge between the chunk cache (CELLS.cpy, CORESTATE.cpy CK-*) and the light engine of docs/protocol/32-light-engine.md (core/src/light-32*.cob; T0697): the engine keeps a sliding window
*> of the loaded chunks between calls (L32WIN.cpy). A cached chunk is loaded into a slot once (L32-LOAD-CHUNK) and compared with the cache on every later call: when the cache changed
*> (a block change, an overflow written into a lit chunk) the differing cells go through L32-SET-BLOCK (L32-SLOT-SYNC), so only the light they change is redone; a chunk that is not in the
*> window is loaded and given its light sources, and the light of the chunk and its neighbours goes back into the cache's 2048-byte light arrays (L32-STORE-LIGHT).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LOAD-CHUNK.
*> USING row (BINARY-LONG) of a loaded chunk: claims the chunk's slot of the window (L32-CLAIM-CHUNK), makes it available (L32-AVAIL-CHUNK), copies its block states as engine states (registry
*> state + 2, 0 for an air state; L32-ENGINE-STATE; a block section that is all state 0 with state 0 an air state is skipped), counts the non-air cells of each block section and keeps
*> the cache's bytes in the slot's snapshot. The engine has been sized for the chunk's dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CELLS.
 COPY L32 REPLACING LEADING ==EN-== BY ==EL-==.
 COPY L32WIN.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-COL                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE CK-X(L-ROW) TO WS-CX
     MOVE CK-Z(L-ROW) TO WS-CZ
     CALL "L32-CLAIM-CHUNK" USING WS-CX WS-CZ WS-CHANGED
     CALL "L32-AVAIL-CHUNK" USING WS-CX WS-CZ WS-ONE
     COMPUTE WS-COL = EL-SLOTMAP(FUNCTION MOD(WS-CZ + 1, 6) * 6 + FUNCTION MOD(WS-CX + 1, 6) + 1)
     MOVE CE-STATES(1:EL-NS * 8192) TO WN-BYTES(WS-COL)(1:EL-NS * 8192)
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= EL-NS
         COMPUTE WS-SEC = (WS-COL - 1) * EL-NS + WS-S + 1
         MOVE 0 TO EL-NONAIR(WS-SEC)
         COMPUTE WS-BASE = (WS-COL - 1) * EL-NS * 4096 + WS-S * 4096
         COMPUTE WS-BYTE = WS-S * 8192 + 1
         COMPUTE WS-CELL = WS-BASE * 2 + 1
         MOVE LOW-VALUES TO EL-BLK-X(WS-CELL:8192)
         IF CE-STATES(WS-BYTE:8192) NOT = LOW-VALUES OR EL-ISAIR(1) NOT = 1
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4096
                 COMPUTE WS-CELL = WS-S * 4096 + WS-J
                 MOVE CE-STATE(WS-CELL) TO WS-STATE
                 COMPUTE WS-ID = WS-STATE + 2
                 IF WS-STATE < 40000
                     IF EL-ISAIR(WS-STATE + 1) = 1
                         MOVE 0 TO WS-ID
                     END-IF
                 END-IF
                 MOVE WS-ID TO EL-BLK(WS-BASE + WS-J)
                 IF WS-ID NOT = 0
                     ADD 1 TO EL-NONAIR(WS-SEC)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-LOAD-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-STORE-LIGHT.
*> USING row (BINARY-LONG) of a loaded chunk whose engine run is finished: copies the published block light and sky light of the chunk's light sections 0 to section count + 1
*> into the cache (a section the engine stores no layer for is all 15 for sky light when it is not below the column's top, else the bottom Y row of the next stored section repeated 16 times, 6.7; all 0 for block light;
*> no sky light at all for a dimension without a sky engine).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CELLS.
 COPY L32 REPLACING LEADING ==EN-== BY ==EL-==.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ROWY                BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE CK-X(L-ROW) TO WS-CX
     MOVE CK-Z(L-ROW) TO WS-CZ
     COMPUTE WS-COL = EL-SLOTMAP(FUNCTION MOD(WS-CZ + 1, 6) * 6 + FUNCTION MOD(WS-CX + 1, 6) + 1)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= EL-NL
         COMPUTE WS-SID = (WS-COL - 1) * EL-NL + WS-I + 1
         COMPUTE WS-SY = EL-LOWL + WS-I
         COMPUTE WS-AT = WS-I * 2048 + 1
         IF LY-VP(1, WS-SID) = 1
             MOVE LY-VD(1, WS-SID) TO CE-BLOCK-LIGHTS(WS-AT:2048)
         ELSE
             MOVE LOW-VALUES TO CE-BLOCK-LIGHTS(WS-AT:2048)
         END-IF
         MOVE LOW-VALUES TO CE-SKYS(WS-AT:2048)
         IF EL-SKY-ON = 1
             EVALUATE TRUE
                 WHEN LY-VP(2, WS-SID) = 1
                     MOVE LY-VD(2, WS-SID) TO CE-SKYS(WS-AT:2048)
                 WHEN LY-VTOPSET(2, WS-COL) = 0 OR WS-SY >= LY-VTOP(2, WS-COL)
                     MOVE ALL X"FF" TO CE-SKYS(WS-AT:2048)
                 WHEN OTHER
                     MOVE 0 TO WS-FOUND
                     COMPUTE WS-S = WS-SY + 1
                     PERFORM UNTIL WS-S >= LY-VTOP(2, WS-COL) OR WS-FOUND = 1
                         COMPUTE WS-SRC = (WS-COL - 1) * EL-NL + WS-S - EL-LOWL + 1
                         IF LY-VP(2, WS-SRC) = 1
                             MOVE 1 TO WS-FOUND
                         ELSE
                             ADD 1 TO WS-S
                         END-IF
                     END-PERFORM
                     IF WS-FOUND = 1
                         PERFORM VARYING WS-ROWY FROM 0 BY 1 UNTIL WS-ROWY > 15
                             COMPUTE WS-OFF = WS-AT + WS-ROWY * 128
                             MOVE LY-VD(2, WS-SRC)(1:128) TO CE-SKYS(WS-OFF:128)
                         END-PERFORM
                     ELSE
                         MOVE ALL X"FF" TO CE-SKYS(WS-AT:2048)
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-STORE-LIGHT.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SLOT-SYNC.
*> USING row (BINARY-LONG) of a cached chunk that owns its slot, result (out): 0 when its block states are the ones loaded into the engine, 1 when they differ in at most 2000 cells (each goes through
*> L32-SET-BLOCK, the snapshot follows; the caller runs the light work), 2 when they differ in more (nothing changed: the window is to be rebuilt).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CELLS.
 COPY L32 REPLACING LEADING ==EN-== BY ==EL-==.
 COPY L32WIN.
 01 WS-COL                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LIST.
    05 WS-AT               BINARY-LONG OCCURS 2000 TIMES.
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RESULT.
     MOVE 0 TO L-RESULT
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-COL = EL-SLOTMAP(FUNCTION MOD(CK-Z(L-ROW) + 1, 6) * 6 + FUNCTION MOD(CK-X(L-ROW) + 1, 6) + 1)
     COMPUTE WS-TOTAL = EL-NS * 8192
     IF CE-STATES(1:WS-TOTAL) NOT = WN-BYTES(WS-COL)(1:WS-TOTAL)
         MOVE 0 TO WS-N
         COMPUTE WS-TOTAL = EL-NS * 4096
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TOTAL OR L-RESULT = 2
             IF CE-STATE(WS-I) NOT = WN-STATE(WS-COL, WS-I)
                 IF WS-N = 2000
                     MOVE 2 TO L-RESULT
                 ELSE
                     ADD 1 TO WS-N
                     MOVE WS-I TO WS-AT(WS-N)
                 END-IF
             END-IF
         END-PERFORM
         IF L-RESULT = 0
             MOVE 1 TO L-RESULT
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
                 MOVE WS-AT(WS-K) TO WS-I
                 MOVE CE-STATE(WS-I) TO WS-STATE
                 CALL "L32-ENGINE-STATE" USING WS-STATE WS-ID
                 COMPUTE WS-T = WS-I - 1
                 COMPUTE WS-Y = WS-T / 256
                 COMPUTE WS-REST = WS-T - WS-Y * 256
                 ADD EL-MINY TO WS-Y
                 COMPUTE WS-Z = WS-REST / 16
                 COMPUTE WS-X = WS-REST - WS-Z * 16
                 COMPUTE WS-X = CK-X(L-ROW) * 16 + WS-X
                 COMPUTE WS-Z = CK-Z(L-ROW) * 16 + WS-Z
                 CALL "L32-SET-BLOCK" USING WS-MODE WS-X WS-Y WS-Z WS-ID
                 MOVE WS-STATE TO WN-STATE(WS-COL, WS-I)
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-SLOT-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-WINDOW-PASS.
*> USING row (BINARY-LONG) of the chunk to light, result (out): the chunk and the loaded chunks of its 5 x 5 neighbourhood (the light of the 3 x 3 around it needs their blocks) are made current in the window: a chunk that owns its slot is
*> synchronised with the cache (L32-SLOT-SYNC), any other is loaded (L32-LOAD-CHUNK) and, once all are, given its light sources (L32-INIT-LIGHT, L32-LIGHT-STAGE) and the queued work runs
*> (L32-SERVER-RUN). The result is 1 when a chunk differed in too many cells, then nothing more is done and the caller rebuilds the window.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY L32 REPLACING LEADING ==EN-== BY ==EL-==.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-SYNC                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NEW.
    05 WS-NEW-ROW          BINARY-LONG OCCURS 25 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RESULT.
     MOVE 0 TO L-RESULT WS-N
     MOVE CK-DIM(L-ROW) TO WS-DIM
     PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2 OR L-RESULT = 1
         PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2 OR L-RESULT = 1
             COMPUTE WS-CX = CK-X(L-ROW) + WS-DX
             COMPUTE WS-CZ = CK-Z(L-ROW) + WS-DZ
             CALL "WORLD-CHUNK-PEEK" USING WS-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0
                 COMPUTE WS-COL = EL-SLOTMAP(FUNCTION MOD(WS-CZ + 1, 6) * 6 + FUNCTION MOD(WS-CX + 1, 6) + 1)
                 IF EL-OWN-X(WS-COL) = WS-CX AND EL-OWN-Z(WS-COL) = WS-CZ AND EL-AVAIL(WS-COL) = 1
                     CALL "L32-SLOT-SYNC" USING WS-ROW WS-SYNC
                     IF WS-SYNC = 2
                         MOVE 1 TO L-RESULT
                     END-IF
                 ELSE
                     CALL "L32-LOAD-CHUNK" USING WS-ROW
                     ADD 1 TO WS-N
                     MOVE WS-ROW TO WS-NEW-ROW(WS-N)
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     IF L-RESULT = 0
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
             MOVE WS-NEW-ROW(WS-K) TO WS-ROW
             MOVE CK-X(WS-ROW) TO WS-CX
             MOVE CK-Z(WS-ROW) TO WS-CZ
             CALL "L32-INIT-LIGHT" USING WS-CX WS-CZ WS-ZERO
         END-PERFORM
         CALL "L32-SERVER-RUN" USING WS-A WS-B
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
             MOVE WS-NEW-ROW(WS-K) TO WS-ROW
             MOVE CK-X(WS-ROW) TO WS-CX
             MOVE CK-Z(WS-ROW) TO WS-CZ
             CALL "L32-LIGHT-STAGE" USING WS-CX WS-CZ WS-ZERO
         END-PERFORM
         CALL "L32-SERVER-RUN" USING WS-A WS-B
     END-IF
     GOBACK.
 END PROGRAM L32-WINDOW-PASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LIGHT-ROW.
*> USING row (BINARY-LONG) of a loaded chunk: lights the chunk: the engine is started for the chunk's dimension when it is not (L32-DIM-RESET; the registry is read when the content set changed,
*> L32-LOAD-REGISTRY), the window is made current for the chunk's 5 x 5 neighbourhood (L32-WINDOW-PASS; the window is rebuilt from empty when a chunk differed in too many cells), the light of the chunk and of its
*> loaded neighbours (whose light the 5 x 5 blocks fix; the chunks beyond lack neighbours of their own) goes into the cache (L32-STORE-LIGHT) and those chunks are lit (CK-LIT 1). For a chunk that is lit already this is the relight after its cells changed behind the engine's back.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY L32 REPLACING LEADING ==EN-== BY ==EL-==.
 COPY L32WIN.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-NS                  BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-REBUILD             BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE CK-DIM(L-ROW) TO WS-DIM
     MOVE DM-SKYLIGHT(WS-DIM) TO WS-SKY
     COMPUTE WS-NS = DM-HEIGHT(WS-DIM) / 16
     COMPUTE WS-MIN = DM-MIN-Y(WS-DIM) / 16
     MOVE 0 TO WS-REBUILD
     IF WN-VALID = 0 OR WN-DIM NOT = WS-DIM OR WN-SKY NOT = WS-SKY OR WN-NS NOT = WS-NS
             OR WN-MIN NOT = WS-MIN OR WN-EPOCH NOT = CB-EPOCH
         MOVE 1 TO WS-REBUILD
     END-IF
     IF WS-REBUILD = 0
         CALL "L32-WINDOW-PASS" USING L-ROW WS-RESULT
         IF WS-RESULT = 1
             MOVE 1 TO WS-REBUILD
         END-IF
     END-IF
     IF WS-REBUILD = 1
         CALL "L32-DIM-RESET" USING WS-SKY WS-NS WS-MIN
         IF WN-VALID = 0 OR WN-EPOCH NOT = CB-EPOCH
             CALL "L32-LOAD-REGISTRY"
         END-IF
         MOVE 1 TO WN-VALID
         MOVE WS-DIM TO WN-DIM
         MOVE WS-SKY TO WN-SKY
         MOVE WS-NS TO WN-NS
         MOVE WS-MIN TO WN-MIN
         MOVE CB-EPOCH TO WN-EPOCH
         CALL "L32-WINDOW-PASS" USING L-ROW WS-RESULT
     END-IF
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-CX = CK-X(L-ROW) + WS-DX
             COMPUTE WS-CZ = CK-Z(L-ROW) + WS-DZ
             CALL "WORLD-CHUNK-PEEK" USING WS-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0
                 CALL "L32-STORE-LIGHT" USING WS-ROW
                 MOVE 1 TO CK-LIT(WS-ROW)
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 1 TO CK-LIT(L-ROW)
     GOBACK.
 END PROGRAM L32-LIGHT-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-BLOCK-CHANGED.
*> USING row (BINARY-LONG) of the chunk in which a block changed, world x, cell y (world y minus the dimension's lowest Y) and world z: the cell goes through L32-SET-BLOCK when the chunk is in the
*> window and the engine holds another state there, then the window is made current as for L32-LIGHT-ROW, which finds nothing more to do when this was the only change.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CELLS.
 COPY DIMENSIONS.
 COPY L32 REPLACING LEADING ==EN-== BY ==EL-==.
 COPY L32WIN.
 01 WS-COL                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-WORLD-Y             BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     COMPUTE WS-COL = EL-SLOTMAP(FUNCTION MOD(CK-Z(L-ROW) + 1, 6) * 6 + FUNCTION MOD(CK-X(L-ROW) + 1, 6) + 1)
     IF WN-VALID = 1 AND WN-DIM = CK-DIM(L-ROW) AND EL-OWN-X(WS-COL) = CK-X(L-ROW)
             AND EL-OWN-Z(WS-COL) = CK-Z(L-ROW) AND EL-AVAIL(WS-COL) = 1
         SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
         COMPUTE WS-LX = FUNCTION MOD(L-X, 16)
         COMPUTE WS-LZ = FUNCTION MOD(L-Z, 16)
         COMPUTE WS-CELL = L-Y * 256 + WS-LZ * 16 + WS-LX + 1
         IF CE-STATE(WS-CELL) NOT = WN-STATE(WS-COL, WS-CELL)
             MOVE CE-STATE(WS-CELL) TO WS-STATE
             CALL "L32-ENGINE-STATE" USING WS-STATE WS-ID
             COMPUTE WS-WORLD-Y = L-Y + DM-MIN-Y(CK-DIM(L-ROW))
             CALL "L32-SET-BLOCK" USING WS-MODE L-X WS-WORLD-Y L-Z WS-ID
             MOVE WS-STATE TO WN-STATE(WS-COL, WS-CELL)
             CALL "L32-RUN-BOTH" USING WS-A
         END-IF
     END-IF
     CALL "L32-LIGHT-ROW" USING L-ROW
     GOBACK.
 END PROGRAM L32-BLOCK-CHANGED.
