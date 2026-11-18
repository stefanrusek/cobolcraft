*> The light engine of docs/protocol/32-light-engine.md, sections 4 and 5.1 (T0686, T0688): the update cycle and the block-light rules (the
*> propagation programs L32-PROP-INC and L32-PROP-DEC serve both layers; layer 1 is block light, layer 2 sky light, core/copy/L32.cpy).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CHECK-BLOCK.
*> USING layer, x, y, z: checkBlock: adds the position to the set of positions to check (a position already in the set is not added twice) (4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > QU-CK-N(L-K)
         IF QU-CKX(L-K, WS-I) = L-X AND QU-CKY(L-K, WS-I) = L-Y AND QU-CKZ(L-K, WS-I) = L-Z
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         ADD 1 TO QU-CK-N(L-K)
         MOVE L-X TO QU-CKX(L-K, QU-CK-N(L-K))
         MOVE L-Y TO QU-CKY(L-K, QU-CK-N(L-K))
         MOVE L-Z TO QU-CKZ(L-K, QU-CK-N(L-K))
     END-IF
     GOBACK.
 END PROGRAM L32-CHECK-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-HAS-WORK.
*> USING layer; gives hasLightWork: the storage has inconsistencies, the check set is not empty or either queue is not empty (4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-FLAG.
     MOVE 0 TO L-FLAG
     IF LY-INCONS(L-K) = 1 OR QU-CK-N(L-K) > 0 OR QU-INC-HEAD(L-K) <= QU-INC-TAIL(L-K)
             OR QU-DEC-HEAD(L-K) <= QU-DEC-TAIL(L-K)
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM L32-HAS-WORK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-PUSH-INC.
*> USING layer, x, y, z, entry: appends a pair to the increase queue (3, 4); a full table (50000) first moves the pairs still waiting to the front.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-ENTRY.
     IF QU-INC-TAIL(L-K) = 50000 AND QU-INC-HEAD(L-K) > 1
         PERFORM VARYING WS-I FROM QU-INC-HEAD(L-K) BY 1 UNTIL WS-I > QU-INC-TAIL(L-K)
             COMPUTE WS-J = WS-I - QU-INC-HEAD(L-K) + 1
             MOVE QU-INC(L-K, WS-I) TO QU-INC(L-K, WS-J)
         END-PERFORM
         COMPUTE QU-INC-TAIL(L-K) = QU-INC-TAIL(L-K) - QU-INC-HEAD(L-K) + 1
         MOVE 1 TO QU-INC-HEAD(L-K)
     END-IF
     ADD 1 TO QU-INC-TAIL(L-K)
     MOVE L-X TO QU-INC-X(L-K, QU-INC-TAIL(L-K))
     MOVE L-Y TO QU-INC-Y(L-K, QU-INC-TAIL(L-K))
     MOVE L-Z TO QU-INC-Z(L-K, QU-INC-TAIL(L-K))
     MOVE L-ENTRY TO QU-INC-E(L-K, QU-INC-TAIL(L-K))
     GOBACK.
 END PROGRAM L32-PUSH-INC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-PUSH-DEC.
*> USING layer, x, y, z, entry: appends a pair to the decrease queue (3, 4); a full table (50000) first moves the pairs still waiting to the front.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-ENTRY.
     IF QU-DEC-TAIL(L-K) = 50000 AND QU-DEC-HEAD(L-K) > 1
         PERFORM VARYING WS-I FROM QU-DEC-HEAD(L-K) BY 1 UNTIL WS-I > QU-DEC-TAIL(L-K)
             COMPUTE WS-J = WS-I - QU-DEC-HEAD(L-K) + 1
             MOVE QU-DEC(L-K, WS-I) TO QU-DEC(L-K, WS-J)
         END-PERFORM
         COMPUTE QU-DEC-TAIL(L-K) = QU-DEC-TAIL(L-K) - QU-DEC-HEAD(L-K) + 1
         MOVE 1 TO QU-DEC-HEAD(L-K)
     END-IF
     ADD 1 TO QU-DEC-TAIL(L-K)
     MOVE L-X TO QU-DEC-X(L-K, QU-DEC-TAIL(L-K))
     MOVE L-Y TO QU-DEC-Y(L-K, QU-DEC-TAIL(L-K))
     MOVE L-Z TO QU-DEC-Z(L-K, QU-DEC-TAIL(L-K))
     MOVE L-ENTRY TO QU-DEC-E(L-K, QU-DEC-TAIL(L-K))
     GOBACK.
 END PROGRAM L32-PUSH-DEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-QUEUE-ENTRY.
*> USING layer, queue (1 increase, 2 decrease), position 1 up (0 for the count only); gives the queue length, then x, y, z and entry of the pair.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-WHICH L-I L-COUNT L-X L-Y L-Z L-ENTRY.
     MOVE 0 TO L-X L-Y L-Z L-ENTRY
     IF L-WHICH = 1
         COMPUTE L-COUNT = QU-INC-TAIL(L-K) - QU-INC-HEAD(L-K) + 1
         COMPUTE WS-AT = QU-INC-HEAD(L-K) + L-I - 1
         IF L-I > 0
             MOVE QU-INC-X(L-K, WS-AT) TO L-X
             MOVE QU-INC-Y(L-K, WS-AT) TO L-Y
             MOVE QU-INC-Z(L-K, WS-AT) TO L-Z
             MOVE QU-INC-E(L-K, WS-AT) TO L-ENTRY
         END-IF
     ELSE
         COMPUTE L-COUNT = QU-DEC-TAIL(L-K) - QU-DEC-HEAD(L-K) + 1
         COMPUTE WS-AT = QU-DEC-HEAD(L-K) + L-I - 1
         IF L-I > 0
             MOVE QU-DEC-X(L-K, WS-AT) TO L-X
             MOVE QU-DEC-Y(L-K, WS-AT) TO L-Y
             MOVE QU-DEC-Z(L-K, WS-AT) TO L-Z
             MOVE QU-DEC-E(L-K, WS-AT) TO L-ENTRY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-QUEUE-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-EMISSION.
*> USING x, y, z; gives getEmission of the block engine: the state's emission when it is above 0 and the cell's chunk column has light
*> enabled, else 0 (5.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-STATE               BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-EMISSION             BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-EMISSION.
     CALL "L32-STATE-AT" USING L-X L-Y L-Z WS-STATE
     MOVE EN-EMIT(WS-STATE + 1) TO L-EMISSION
     IF L-EMISSION > 0
         CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
         IF LY-ON(1, WS-COL) = 0
             MOVE 0 TO L-EMISSION
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-EMISSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-BLOCK-CHECK.
*> USING x, y, z: BlockLightEngine.checkNode (5.1): nothing when the section stores no light; e = emission, s = stored level; e < s stores 0
*> and queues decreaseAllDirections(s), else queues PULL_LIGHT_IN_ENTRY; e > 0 queues increaseLightFromEmission(e, isEmptyShape).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LAYER               BINARY-LONG VALUE 1.
 01 WS-STORES              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-DIR                 BINARY-LONG VALUE 0.
 01 WS-PULL                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     CALL "L32-STORES" USING WS-LAYER L-X L-Y L-Z WS-STORES
     IF WS-STORES = 1
         CALL "L32-EMISSION" USING L-X L-Y L-Z WS-E
         CALL "L32-GET-STORED" USING WS-LAYER L-X L-Y L-Z WS-S
         IF WS-E < WS-S
             CALL "L32-SET-STORED" USING WS-LAYER L-X L-Y L-Z WS-ZERO
             MOVE 1 TO WS-KIND
             CALL "L32-ENTRY" USING WS-KIND WS-S WS-ZERO WS-DIR WS-ENTRY
         ELSE
             CALL "L32-ENTRY-CONST" USING WS-PULL WS-ENTRY
         END-IF
         CALL "L32-PUSH-DEC" USING WS-LAYER L-X L-Y L-Z WS-ENTRY
         IF WS-E > 0
             CALL "L32-STATE-AT" USING L-X L-Y L-Z WS-STATE
             CALL "L32-IS-EMPTY-SHAPE" USING WS-STATE WS-EMPTY
             MOVE 3 TO WS-KIND
             CALL "L32-ENTRY" USING WS-KIND WS-E WS-EMPTY WS-DIR WS-ENTRY
             CALL "L32-PUSH-INC" USING WS-LAYER L-X L-Y L-Z WS-ENTRY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-BLOCK-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-PROP-INC.
*> USING layer, x, y, z, entry, level (the stored level of the cell at dequeue): propagateIncrease (5.1): for each direction of the entry whose
*> neighbour stores light, is lower than level - 1 and than level - opacity, and is not occluded by the shapes (the source state is air when the entry
*> has the from-empty-shape flag), store the new level and queue increaseSkipOneDirection (when above 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FROM                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-FROM-EMPTY          BINARY-LONG.
 01 WS-EMISSION            BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-POW                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STORES              BINARY-LONG.
 01 WS-NS                  BINARY-LONG.
 01 WS-NSTATE              BINARY-LONG.
 01 WS-OPACITY             BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-OCCLUDED            BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 4.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-KE                  BINARY-LONG.
 01 WS-INCREASE            BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-ENTRY L-LEVEL.
     CALL "L32-ENTRY-DECODE" USING L-ENTRY WS-FROM WS-BITS WS-FROM-EMPTY WS-EMISSION
     MOVE 0 TO WS-READY WS-KE
     IF L-K = 2
         CALL "L32-EMPTY-BELOW" USING L-X L-Y L-Z WS-KE
     END-IF
     MOVE 1 TO WS-POW
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
         DIVIDE WS-BITS BY WS-POW GIVING WS-T
         DIVIDE WS-T BY 2 GIVING WS-Q REMAINDER WS-R
         COMPUTE WS-POW = WS-POW * 2
         IF WS-R = 1
             CALL "L32-DIRECTION" USING WS-D WS-DX WS-DY WS-DZ WS-OPP
             COMPUTE WS-NX = L-X + WS-DX
             COMPUTE WS-NY = L-Y + WS-DY
             COMPUTE WS-NZ = L-Z + WS-DZ
             CALL "L32-STORES" USING L-K WS-NX WS-NY WS-NZ WS-STORES
             IF WS-STORES = 1
                 CALL "L32-GET-STORED" USING L-K WS-NX WS-NY WS-NZ WS-NS
                 IF L-LEVEL - 1 > WS-NS
                     CALL "L32-STATE-AT" USING WS-NX WS-NY WS-NZ WS-NSTATE
                     CALL "L32-OPACITY" USING WS-NSTATE WS-OPACITY
                     COMPUTE WS-NEW = L-LEVEL - WS-OPACITY
                     IF WS-NEW > WS-NS
                         IF WS-READY = 0
                             MOVE 0 TO WS-SOURCE
                             IF WS-FROM-EMPTY = 0
                                 CALL "L32-STATE-AT" USING L-X L-Y L-Z WS-SOURCE
                             END-IF
                             MOVE 1 TO WS-READY
                         END-IF
                         CALL "L32-OCCLUDES" USING WS-SOURCE WS-NSTATE WS-D WS-OCCLUDED
                         IF WS-OCCLUDED = 0
                             CALL "L32-SET-STORED" USING L-K WS-NX WS-NY WS-NZ WS-NEW
                             IF WS-NEW > 1
                                 CALL "L32-IS-EMPTY-SHAPE" USING WS-NSTATE WS-EMPTY
                                 CALL "L32-ENTRY" USING WS-KIND WS-NEW WS-EMPTY WS-OPP WS-ENTRY
                                 CALL "L32-PUSH-INC" USING L-K WS-NX WS-NY WS-NZ WS-ENTRY
                             END-IF
                             IF L-K = 2
                                 CALL "L32-FROM-EMPTY" USING WS-NX WS-NY WS-NZ WS-D WS-NEW WS-INCREASE WS-KE
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-PROP-INC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-PROP-DEC.
*> USING layer, x, y, z, entry: propagateDecrease (5.1): for each direction of the entry whose neighbour stores light and is lit: a neighbour with level
*> <= from - 1 was lit from here: store 0, queue a decrease when its emission is below its level and an increase from emission when above 0; a brighter
*> neighbour queues increaseOnlyOneDirection back toward this cell. The sky layer has no emission.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FROM                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-FROM-EMPTY          BINARY-LONG.
 01 WS-EMISSION            BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-POW                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STORES              BINARY-LONG.
 01 WS-NS                  BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-NSTATE              BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-KE                  BINARY-LONG.
 01 WS-DECREASE            BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-ENTRY.
     CALL "L32-ENTRY-DECODE" USING L-ENTRY WS-FROM WS-BITS WS-FROM-EMPTY WS-EMISSION
     COMPUTE WS-LIMIT = WS-FROM - 1
     MOVE 0 TO WS-KE
     IF L-K = 2
         CALL "L32-EMPTY-BELOW" USING L-X L-Y L-Z WS-KE
     END-IF
     MOVE 1 TO WS-POW
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
         DIVIDE WS-BITS BY WS-POW GIVING WS-T
         DIVIDE WS-T BY 2 GIVING WS-Q REMAINDER WS-R
         COMPUTE WS-POW = WS-POW * 2
         IF WS-R = 1
             CALL "L32-DIRECTION" USING WS-D WS-DX WS-DY WS-DZ WS-OPP
             COMPUTE WS-NX = L-X + WS-DX
             COMPUTE WS-NY = L-Y + WS-DY
             COMPUTE WS-NZ = L-Z + WS-DZ
             CALL "L32-STORES" USING L-K WS-NX WS-NY WS-NZ WS-STORES
             MOVE 0 TO WS-NS
             IF WS-STORES = 1
                 CALL "L32-GET-STORED" USING L-K WS-NX WS-NY WS-NZ WS-NS
             END-IF
             IF WS-NS > 0
                 IF WS-NS <= WS-LIMIT
                     MOVE 0 TO WS-E
                     IF L-K = 1
                         CALL "L32-EMISSION" USING WS-NX WS-NY WS-NZ WS-E
                     END-IF
                     CALL "L32-SET-STORED" USING L-K WS-NX WS-NY WS-NZ WS-ZERO
                     IF WS-E < WS-NS
                         MOVE 2 TO WS-KIND
                         CALL "L32-ENTRY" USING WS-KIND WS-NS WS-ZERO WS-OPP WS-ENTRY
                         CALL "L32-PUSH-DEC" USING L-K WS-NX WS-NY WS-NZ WS-ENTRY
                     END-IF
                     IF WS-E > 0
                         CALL "L32-STATE-AT" USING WS-NX WS-NY WS-NZ WS-NSTATE
                         CALL "L32-IS-EMPTY-SHAPE" USING WS-NSTATE WS-EMPTY
                         MOVE 3 TO WS-KIND
                         CALL "L32-ENTRY" USING WS-KIND WS-E WS-EMPTY WS-ZERO WS-ENTRY
                         CALL "L32-PUSH-INC" USING L-K WS-NX WS-NY WS-NZ WS-ENTRY
                     END-IF
                     IF L-K = 2
                         CALL "L32-FROM-EMPTY" USING WS-NX WS-NY WS-NZ WS-D WS-NS WS-DECREASE WS-KE
                     END-IF
                 ELSE
                     MOVE 5 TO WS-KIND
                     CALL "L32-ENTRY" USING WS-KIND WS-NS WS-ZERO WS-OPP WS-ENTRY
                     CALL "L32-PUSH-INC" USING L-K WS-NX WS-NY WS-NZ WS-ENTRY
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-PROP-DEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-RUN-UPDATES.
*> USING layer; gives the number of queue pairs processed: runLightUpdates (4): checkNode for every position of the check set, then the set is
*> cleared; the decrease queue is drained, then the increase queue (an emission entry first raises the stored level to its from level; the entry
*> is processed only when the stored level equals the from level); then markNewInconsistencies and swapSectionMap (6.3, 6.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-I                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-EMISSION            BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-STORES              BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > QU-CK-N(L-K)
         MOVE QU-CKX(L-K, WS-I) TO WS-X
         MOVE QU-CKY(L-K, WS-I) TO WS-Y
         MOVE QU-CKZ(L-K, WS-I) TO WS-Z
         IF L-K = 1
             CALL "L32-BLOCK-CHECK" USING WS-X WS-Y WS-Z
         ELSE
             CALL "L32-SKY-CHECK" USING WS-X WS-Y WS-Z
         END-IF
     END-PERFORM
     MOVE 0 TO QU-CK-N(L-K)
     PERFORM UNTIL QU-DEC-HEAD(L-K) > QU-DEC-TAIL(L-K)
         MOVE QU-DEC-HEAD(L-K) TO WS-H
         MOVE QU-DEC-X(L-K, WS-H) TO WS-X
         MOVE QU-DEC-Y(L-K, WS-H) TO WS-Y
         MOVE QU-DEC-Z(L-K, WS-H) TO WS-Z
         MOVE QU-DEC-E(L-K, WS-H) TO WS-E
         ADD 1 TO QU-DEC-HEAD(L-K)
         ADD 1 TO L-COUNT
         CALL "L32-PROP-DEC" USING L-K WS-X WS-Y WS-Z WS-E
     END-PERFORM
     MOVE 1 TO QU-DEC-HEAD(L-K)
     MOVE 0 TO QU-DEC-TAIL(L-K)
     PERFORM UNTIL QU-INC-HEAD(L-K) > QU-INC-TAIL(L-K)
         MOVE QU-INC-HEAD(L-K) TO WS-H
         MOVE QU-INC-X(L-K, WS-H) TO WS-X
         MOVE QU-INC-Y(L-K, WS-H) TO WS-Y
         MOVE QU-INC-Z(L-K, WS-H) TO WS-Z
         MOVE QU-INC-E(L-K, WS-H) TO WS-E
         ADD 1 TO QU-INC-HEAD(L-K)
         ADD 1 TO L-COUNT
         CALL "L32-ENTRY-DECODE" USING WS-E WS-FROM WS-BITS WS-EMPTY WS-EMISSION
         CALL "L32-GET-STORED" USING L-K WS-X WS-Y WS-Z WS-LEVEL
         IF WS-EMISSION = 1 AND WS-LEVEL < WS-FROM
             CALL "L32-STORES" USING L-K WS-X WS-Y WS-Z WS-STORES
             IF WS-STORES = 1
                 CALL "L32-SET-STORED" USING L-K WS-X WS-Y WS-Z WS-FROM
                 MOVE WS-FROM TO WS-LEVEL
             END-IF
         END-IF
         IF WS-LEVEL = WS-FROM
             CALL "L32-PROP-INC" USING L-K WS-X WS-Y WS-Z WS-E WS-LEVEL
         END-IF
     END-PERFORM
     MOVE 1 TO QU-INC-HEAD(L-K)
     MOVE 0 TO QU-INC-TAIL(L-K)
     CALL "L32-STORAGE-FINISH" USING L-K
     GOBACK.
 END PROGRAM L32-RUN-UPDATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CHUNK-START-BLOCK.
*> USING chunk x, chunk z: BlockLightEngine.propagateLightSources (5.1): enables light for the column, then queues increaseLightFromEmission for every
*> cell whose state emits (emission /= 0), in storage index order (lowest section, Y, then Z, then X ascending).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LAYER               BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     COMPUTE WS-COL = EN-SLOTMAP(FUNCTION MOD(L-CZ + 1, 6) * 6 + FUNCTION MOD(L-CX + 1, 6) + 1)
     MOVE 1 TO LY-ON(1, WS-COL)
     COMPUTE WS-BASE = (WS-COL - 1) * EN-NS * 4096
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= EN-NS
         COMPUTE WS-SEC = (WS-COL - 1) * EN-NS + WS-S + 1
         IF EN-NONAIR(WS-SEC) > 0
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4096
                 COMPUTE WS-I = WS-S * 4096 + WS-J
                 COMPUTE WS-ID = EN-BLK(WS-BASE + WS-I)
                 MOVE EN-EMIT(WS-ID + 1) TO WS-E
                 IF WS-E NOT = 0
                     COMPUTE WS-Y = (WS-I - 1) / 256
                     COMPUTE WS-REST = WS-I - 1 - WS-Y * 256
                     ADD EN-MINY TO WS-Y
                     COMPUTE WS-Z = WS-REST / 16
                     COMPUTE WS-X = L-CX * 16 + WS-REST - WS-Z * 16
                     COMPUTE WS-Z = L-CZ * 16 + WS-Z
                     CALL "L32-IS-EMPTY-SHAPE" USING WS-ID WS-EMPTY
                     CALL "L32-ENTRY" USING WS-KIND WS-E WS-EMPTY WS-NONE WS-ENTRY
                     CALL "L32-PUSH-INC" USING WS-LAYER WS-X WS-Y WS-Z WS-ENTRY
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-CHUNK-START-BLOCK.
