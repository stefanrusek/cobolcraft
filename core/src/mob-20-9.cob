*> Silverfish and infested blocks (002-lane-mobsfull-h8; docs/protocol/20 section 9).
*>
*> Entry points:
*>   STDMOB-INFESTED-BREAK USING dim, x, y, z, block id (CB-S-BLOCK, 0-based): a broken block of that id; an infested block lets a silverfish out at its centre
*>     (9.2). The tool's silk touch and the block_drops rule are not read (open item).
*>   STDMOB-INFESTED-AT USING dim, x, y, z, found out: 1 when the cell holds an infested block.
*>   STDMOB-SILVERFISH-HURT USING tracker row, attacker player row: a silverfish hurt by an attacker starts its wake-up-friends timer at 20 (9.1 hurtServer).
*>   STDMOB-SILVERFISH-WAKE USING tracker row: one tick of the timer (STDMOB-STEP). At 0 the cells of the box x and z within 10, y within 5, are scanned in
*>     layers of growing distance; each infested block found is destroyed (the mob-griefing rule is taken as true, it is not modelled) and lets a silverfish
*>     out, and after each block the scan stops with probability 1/2 (a hash of the entity id, the time and the layer). Merge with stone is open.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-INFESTED-BREAK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:silverfish".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK.
     MOVE 0 TO WS-N
     INSPECT CB-KEY(L-BLOCK + 1) TALLYING WS-N FOR ALL "infested_"
     IF WS-N = 0
         GOBACK
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     COMPUTE WS-FX = L-X + 0.5
     MOVE L-Y TO WS-FY
     COMPUTE WS-FZ = L-Z + 0.5
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     GOBACK.
 END PROGRAM STDMOB-INFESTED-BREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-INFESTED-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FOUND.
     MOVE 0 TO L-FOUND
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0
         COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE 0 TO WS-N
         INSPECT CB-KEY(WS-BLOCK) TALLYING WS-N FOR ALL "infested_"
         IF WS-N > 0
             MOVE 1 TO L-FOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STDMOB-INFESTED-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SILVERFISH-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0 AND L-ATTACKER > 0
         IF SM-KEY(WS-M) = "silverfish"
             MOVE 20 TO EN-WAKE(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STDMOB-SILVERFISH-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SILVERFISH-WAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHX                 BINARY-LONG.
 01 WS-CHZ                 BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-WAKE(L-ROW) = 0
         GOBACK
     END-IF
     SUBTRACT 1 FROM EN-WAKE(L-ROW)
     IF EN-WAKE(L-ROW) > 0
         GOBACK
     END-IF
     MOVE EN-DIM(L-ROW) TO WS-DIM
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE 0 TO WS-STOP
     PERFORM VARYING WS-LAYER FROM 0 BY 1 UNTIL WS-LAYER > 10 OR WS-STOP = 1
         PERFORM VARYING WS-DX FROM -10 BY 1 UNTIL WS-DX > 10 OR WS-STOP = 1
             PERFORM VARYING WS-DY FROM -5 BY 1 UNTIL WS-DY > 5 OR WS-STOP = 1
                 PERFORM VARYING WS-DZ FROM -10 BY 1 UNTIL WS-DZ > 10 OR WS-STOP = 1
                     COMPUTE WS-D = FUNCTION MAX(FUNCTION ABS(WS-DX), FUNCTION ABS(WS-DY), FUNCTION ABS(WS-DZ))
                     IF WS-D = WS-LAYER
                         COMPUTE WS-CX = WS-BX + WS-DX
                         COMPUTE WS-CY = WS-BY + WS-DY
                         COMPUTE WS-CZ = WS-BZ + WS-DZ
                         COMPUTE WS-CHX = FUNCTION INTEGER(WS-CX / 16)
                         COMPUTE WS-CHZ = FUNCTION INTEGER(WS-CZ / 16)
                         CALL "STDMOB-READY" USING WS-DIM WS-CHX WS-CHZ WS-READY
                         MOVE 0 TO WS-FOUND
                         IF WS-READY = 1
                             CALL "STDMOB-INFESTED-AT" USING WS-DIM WS-CX WS-CY WS-CZ WS-FOUND
                         END-IF
                         IF WS-FOUND = 1
                             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
                             COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1)
                             CALL "BLOCK-CHANGE" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
                             CALL "STDMOB-INFESTED-BREAK" USING WS-DIM WS-CX WS-CY WS-CZ WS-BLOCK
                             MOVE EN-ID(L-ROW) TO WS-ARG(1)
                             MOVE CW-TIME TO WS-ARG(2)
                             COMPUTE WS-ARG(3) = WS-CX * 7919 + WS-CY * 104729 + WS-CZ
                             MOVE 23 TO WS-ARG(4)
                             CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
                             IF FUNCTION MOD(WS-R, 2) = 0
                                 MOVE 1 TO WS-STOP
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-SILVERFISH-WAKE.
