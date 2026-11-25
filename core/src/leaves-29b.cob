*> Leaves in the play path (lane bugleafdecay; docs/protocol/29b part 3 section 5, the decisions of growth-29b-3.cob wired into the block-update hooks): a leaves block (a block whose bare key ends in
*> "_leaves" with 28 states: distance 1 to 7, persistent, waterlogged; the state number is distance (outermost, 1 first), then persistent true before false, then waterlogged true before false) takes
*> four hook rows when a world opens (LEAF-RULES-OPEN): the randomly ticking marker (kind 11), the random tick (kind 8, effect 12, LEAF-RT: decay at distance 7 unless persistent, with the loot table of
*> the block and no tool), the scheduled tick (kind 7, effect 13, LEAF-TICK: the distance is recomputed, 5.3 ST) and the shape update (kind 4, effect 14, LEAF-SU: a tick after 1 game tick when the
*> neighbour that sent the update says the distance is not the block's, 5.3 SU). A leaves block placed from the item is persistent with its distance computed (LEAF-PLACE, 5.3 PL; called by
*> PLACE-STATE). The distance of a block to a log (5.2) is 0 for a block of the tag logs, the distance property for any leaves block and 7 for anything else.
*>
*> Entry points:
*>   LEAF-CLASS USING block id (0-based), class out (0 other, 1 in the block tag logs, 2 leaves)
*>   LEAF-STATE-DIST USING state, getDistanceAt out (0 for a log, the distance of a leaves state, 7 for other blocks)
*>   LEAF-DIST-AT USING dimension row, x, y, z, getDistanceAt out
*>   LEAF-UPDATE-DIST USING dimension row, x, y, z, leaves state, state out: updateDistance (5.2)
*>   LEAF-RULES-OPEN USING (nothing): the four rows of every leaves block of the open tables not already registered
*>   LEAF-RT, LEAF-TICK USING dimension row, x, y, z: the random tick and the scheduled tick of the block at the position
*>   LEAF-SU USING dimension row, x, y, z, receiver state, direction towards the neighbour, neighbour state: the shape update
*>   LEAF-PLACE USING PLACE-CONTEXT: the placed state of a leaves item

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAF-CLASS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-TABLE               PIC X(1400).
 01 WS-NAME                PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:logs".
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-CLASS.
*>   The class of each block is worked out once per table build (CB-EPOCH rises at every BLOCKS-OPEN).
     IF WS-EPOCH NOT = CB-EPOCH
         MOVE ALL "9" TO WS-TABLE
         MOVE CB-EPOCH TO WS-EPOCH
     END-IF
     COMPUTE WS-ID = L-BLOCK + 1
     IF WS-TABLE(WS-ID:1) = "9"
         MOVE "0" TO WS-TABLE(WS-ID:1)
         CALL "KEY-BARE" USING CB-KEY(WS-ID) WS-NAME
         COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-NAME))
         COMPUTE WS-FROM = WS-LENGTH - 6
         IF WS-FROM > 0 AND WS-NAME(WS-FROM:7) = "_leaves" AND CB-STATES(WS-ID) = 28
             MOVE "2" TO WS-TABLE(WS-ID:1)
         ELSE
             CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-BLOCK WS-HAS
             IF WS-HAS = 1
                 MOVE "1" TO WS-TABLE(WS-ID:1)
             END-IF
         END-IF
     END-IF
     COMPUTE L-CLASS = FUNCTION ORD(WS-TABLE(WS-ID:1)) - 49
     GOBACK.
 END PROGRAM LEAF-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAF-STATE-DIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-STRIDE              BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-DIST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIST.
     MOVE 7 TO L-DIST
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     CALL "LEAF-CLASS" USING WS-BLOCK WS-CLASS
     IF WS-CLASS = 1
         MOVE 0 TO L-DIST
     END-IF
     IF WS-CLASS = 2
         COMPUTE WS-STRIDE = CB-STATES(WS-BLOCK + 1) / 7
         COMPUTE WS-OFFSET = L-STATE - CB-FIRST-STATE(WS-BLOCK + 1)
         COMPUTE L-DIST = WS-OFFSET / WS-STRIDE + 1
     END-IF
     GOBACK.
 END PROGRAM LEAF-STATE-DIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAF-DIST-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DIST.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "LEAF-STATE-DIST" USING WS-STATE L-DIST
     GOBACK.
 END PROGRAM LEAF-DIST-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAF-UPDATE-DIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STRIDE              BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-WITHIN              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-NEW.
*>   updateDistance (5.2): m = 7, then min(m, getDistanceAt(neighbour) + 1) for each direction of Direction.values() (down, up, north, south, west, east), the loop ending when m is 1.
     MOVE 7 TO WS-M
     PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 5 OR WS-M = 1
         CALL "BU-DIRECTION" USING WS-DIR WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NY = L-Y + WS-DY
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "LEAF-DIST-AT" USING L-DIM WS-NX WS-NY WS-NZ WS-D
         ADD 1 TO WS-D
         IF WS-D < WS-M
             MOVE WS-D TO WS-M
         END-IF
     END-PERFORM
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     COMPUTE WS-STRIDE = CB-STATES(WS-BLOCK + 1) / 7
     COMPUTE WS-OFFSET = L-STATE - CB-FIRST-STATE(WS-BLOCK + 1)
     COMPUTE WS-WITHIN = FUNCTION MOD(WS-OFFSET, WS-STRIDE)
     COMPUTE L-NEW = CB-FIRST-STATE(WS-BLOCK + 1) + (WS-M - 1) * WS-STRIDE + WS-WITHIN
     GOBACK.
 END PROGRAM LEAF-UPDATE-DIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAF-RULES-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BUSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BU-ENSURE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         COMPUTE WS-BLOCK = WS-I - 1
         CALL "LEAF-CLASS" USING WS-BLOCK WS-CLASS
         IF WS-CLASS = 2
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > BU-RULE-COUNT
                 IF BU-R-KIND(WS-R) = 8 AND BU-R-BLOCK(WS-R) = WS-BLOCK AND BU-R-EFFECT(WS-R) = 12
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0
                 MOVE 11 TO WS-KIND
                 MOVE 0 TO WS-EFFECT
                 CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
                 MOVE 8 TO WS-KIND
                 MOVE 12 TO WS-EFFECT
                 CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
                 MOVE 7 TO WS-KIND
                 MOVE 13 TO WS-EFFECT
                 CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
                 MOVE 4 TO WS-KIND
                 MOVE 14 TO WS-EFFECT
                 CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LEAF-RULES-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAF-RT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DIST                BINARY-LONG.
 01 WS-NAME                PIC X(24) VALUE "persistent".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
*>   LeavesBlock.randomTick (5.4): decaying = not persistent and distance 7: the loot table with no tool, then removeBlock (the fluid's block: water for a waterlogged leaf; no game event, no level event).
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "LEAF-STATE-DIST" USING WS-STATE WS-DIST
     IF WS-DIST = 7
         CALL "PS-GET" USING WS-STATE WS-NAME WS-TEXT WS-FOUND
         IF FUNCTION TRIM(WS-TEXT) = "false"
             CALL "BLOCK-DROPS-NO-TOOL" USING L-DIM L-X L-Y L-Z WS-STATE
             CALL "SUP-DESTROY-STATE" USING WS-STATE WS-NEW
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LEAF-RT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAF-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
*>   The scheduled tick (5.3 ST): setBlockAndUpdate(pos, updateDistance(state)); a state that does not change is not written (Level.setBlock).
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "LEAF-UPDATE-DIST" USING L-DIM L-X L-Y L-Z WS-STATE WS-NEW
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
     GOBACK.
 END PROGRAM LEAF-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAF-SU.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-NEIGHBOUR           BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 1.
 01 WS-NORMAL              BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-NSTATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-DIR L-NSTATE.
*>   5.3 SU (b): d = getDistanceAt(the neighbour that sent the update) + 1; unless d is 1 and the block's own distance is d, a block tick follows after 1 game tick. The state itself is not changed.
     CALL "LEAF-STATE-DIST" USING L-NSTATE WS-NEIGHBOUR
     CALL "LEAF-STATE-DIST" USING L-STATE WS-OWN
     COMPUTE WS-D = WS-NEIGHBOUR + 1
     IF WS-D NOT = 1 OR WS-OWN NOT = WS-D
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
         CALL "BT-SCHEDULE" USING L-DIM WS-TYPE WS-BLOCK L-X L-Y L-Z WS-DELAY WS-NORMAL WS-RESULT
     END-IF
     GOBACK.
 END PROGRAM LEAF-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEAF-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24) VALUE "persistent".
 01 WS-TEXT                PIC X(32) VALUE "true".
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
*>   getStateForPlacement (5.3 PL): persistent, then updateDistance at the clicked position (the waterlogged flag is the placement code's).
     CALL "PS-PUT" USING PC-STATE WS-NAME WS-TEXT
     CALL "LEAF-UPDATE-DIST" USING PC-DIM PC-X PC-Y PC-Z PC-STATE WS-STATE
     MOVE WS-STATE TO PC-STATE
     GOBACK.
 END PROGRAM LEAF-PLACE.
