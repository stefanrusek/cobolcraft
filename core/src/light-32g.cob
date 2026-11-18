*> The bridge between the chunk cache (CELLS.cpy, CORESTATE.cpy CK-*) and the light engine of docs/protocol/32-light-engine.md (core/src/light-32*.cob; T0697): a cached
*> chunk's block states go into a slot of the engine's sliding window (L32-LOAD-CHUNK), the engine lights the chunk with the loaded chunks around it (L32-LIGHT-ROW) and the light
*> it publishes for the chunk goes back into the cache's light tables (L32-STORE-LIGHT), which hold the 2048-byte arrays of the packets unchanged.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LOAD-CHUNK.
*> USING row (BINARY-LONG) of a loaded chunk: claims the chunk's slot of the window (L32-CLAIM-CHUNK), makes it available (L32-AVAIL-CHUNK) and copies its block states as engine
*> states (registry state + 2, 0 for an air state; L32-ENGINE-STATE), counting the non-air cells of each block section. The engine has been sized for the chunk's dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CELLS.
 COPY L32 REPLACING LEADING ==EN-== BY ==EL-==.
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
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE CK-X(L-ROW) TO WS-CX
     MOVE CK-Z(L-ROW) TO WS-CZ
     CALL "L32-CLAIM-CHUNK" USING WS-CX WS-CZ WS-CHANGED
     CALL "L32-AVAIL-CHUNK" USING WS-CX WS-CZ WS-ONE
     COMPUTE WS-COL = FUNCTION MOD(WS-CZ + 1, 4) * 4 + FUNCTION MOD(WS-CX + 1, 4) + 1
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= EL-NS
         COMPUTE WS-SEC = (WS-COL - 1) * EL-NS + WS-S + 1
         MOVE 0 TO EL-NONAIR(WS-SEC)
         COMPUTE WS-BASE = (WS-COL - 1) * EL-NS * 4096 + WS-S * 4096
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
     END-PERFORM
     GOBACK.
 END PROGRAM L32-LOAD-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-STORE-LIGHT.
*> USING row (BINARY-LONG) of a loaded chunk whose engine run is finished: copies the published block light and sky light of the chunk's light sections 0 to section count + 1
*> into the cache (a section the engine stores no layer for is all 15 for sky light when it is not below the column's top, else read cell by cell, 6.7; all 0 for block light;
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
 01 WS-N                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LAYER               BINARY-LONG VALUE 2.
 01 WS-HI                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE CK-X(L-ROW) TO WS-CX
     MOVE CK-Z(L-ROW) TO WS-CZ
     COMPUTE WS-COL = FUNCTION MOD(WS-CZ + 1, 4) * 4 + FUNCTION MOD(WS-CX + 1, 4) + 1
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
                     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N > 4095
                         COMPUTE WS-T = WS-N / 256
                         COMPUTE WS-Y = WS-SY * 16 + WS-T
                         COMPUTE WS-T = WS-N / 16
                         COMPUTE WS-Z = WS-CZ * 16 + FUNCTION MOD(WS-T, 16)
                         COMPUTE WS-X = WS-CX * 16 + FUNCTION MOD(WS-N, 16)
                         CALL "L32-GET-PUBLISHED" USING WS-LAYER WS-X WS-Y WS-Z WS-LEVEL
                         COMPUTE WS-T = WS-N / 2
                         COMPUTE WS-HI = WS-AT + WS-T
                         IF FUNCTION MOD(WS-N, 2) = 0
                             COMPUTE CE-SKY(WS-HI) = CE-SKY(WS-HI) + WS-LEVEL
                         ELSE
                             COMPUTE CE-SKY(WS-HI) = CE-SKY(WS-HI) + WS-LEVEL * 16
                         END-IF
                     END-PERFORM
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-STORE-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LIGHT-ROW.
*> USING row (BINARY-LONG) of a loaded chunk: lights the chunk with the engine: the engine starts empty for the chunk's dimension (L32-DIM-RESET; the registry is read when
*> the content set changed, L32-LOAD-REGISTRY), the chunk and the loaded chunks of its 3 x 3 neighbourhood are loaded (L32-LOAD-CHUNK, WORLD-CHUNK-PEEK), every chunk gets its
*> light sources (L32-INIT-LIGHT, L32-LIGHT-STAGE; the queued work runs after each step, L32-SERVER-RUN) and the chunk's published light goes into the cache (L32-STORE-LIGHT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-NS                  BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LOADED.
    05 WS-LOADED-ROW       BINARY-LONG OCCURS 9 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE CK-DIM(L-ROW) TO WS-DIM
     MOVE DM-SKYLIGHT(WS-DIM) TO WS-SKY
     COMPUTE WS-NS = DM-HEIGHT(WS-DIM) / 16
     COMPUTE WS-MIN = DM-MIN-Y(WS-DIM) / 16
     CALL "L32-DIM-RESET" USING WS-SKY WS-NS WS-MIN
     IF WS-EPOCH NOT = CB-EPOCH
         CALL "L32-LOAD-REGISTRY"
         MOVE CB-EPOCH TO WS-EPOCH
     END-IF
     MOVE 0 TO WS-N
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-CX = CK-X(L-ROW) + WS-DX
             COMPUTE WS-CZ = CK-Z(L-ROW) + WS-DZ
             CALL "WORLD-CHUNK-PEEK" USING WS-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0
                 CALL "L32-LOAD-CHUNK" USING WS-ROW
                 ADD 1 TO WS-N
                 MOVE WS-ROW TO WS-LOADED-ROW(WS-N)
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
         MOVE WS-LOADED-ROW(WS-K) TO WS-ROW
         MOVE CK-X(WS-ROW) TO WS-CX
         MOVE CK-Z(WS-ROW) TO WS-CZ
         CALL "L32-INIT-LIGHT" USING WS-CX WS-CZ WS-ZERO
     END-PERFORM
     CALL "L32-SERVER-RUN" USING WS-A WS-B
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N
         MOVE WS-LOADED-ROW(WS-K) TO WS-ROW
         MOVE CK-X(WS-ROW) TO WS-CX
         MOVE CK-Z(WS-ROW) TO WS-CZ
         CALL "L32-LIGHT-STAGE" USING WS-CX WS-CZ WS-ZERO
     END-PERFORM
     CALL "L32-SERVER-RUN" USING WS-A WS-B
     CALL "L32-STORE-LIGHT" USING L-ROW
     GOBACK.
 END PROGRAM L32-LIGHT-ROW.
