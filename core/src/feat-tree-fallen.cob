*> The fallen tree feature (docs/protocol/35-worldgen-features-3-tree-placers.md section 7; feature type 16): FD-FALLEN-NODE compiles {"type": "minecraft:fallen_tree", ...} into a row of FD-TR
*> (the trunk provider's state, log_length, the stump and log decorators), FR-FALLEN places it: the stump at the origin, then log_length - 2 logs along a random horizontal direction
*> starting 2 or 3 cells from the origin on the ground the search of 7.3 finds, when the walk is supported (7.4).
*> Deviations: block entities and post-processing marks are not written; "face sturdy on UP" is approximated by a solid block (CB-SOLID, not air) below; decorators supported: attached_to_logs
*> (feat-tree-deco.cob), any other decorator type makes the feature unsupported.
*>
*> Entry points: FD-FALLEN-NODE USING doc, node, row out (0 and FD-BAD when unsupported); FR-FALLEN USING state, feature, x, y, z, result out (always 1, 7: place always returns true).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-FALLEN-NODE.
*> USING doc, node, row out: compiles a fallen_tree feature into a row of FD-TR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-K-TRUNK-PROVIDER    PIC X(40) VALUE "trunk_provider".
 01 WS-K-LENGTH            PIC X(40) VALUE "log_length".
 01 WS-K-STUMP             PIC X(40) VALUE "stump_decorators".
 01 WS-K-LOGD              PIC X(40) VALUE "log_decorators".
 01 WS-TAG-REPL            PIC X(112) VALUE "minecraft:replaceable_by_trees".
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-TR-COUNT >= 256
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-TR-COUNT
     MOVE FD-TR-COUNT TO WS-ROW
     INITIALIZE FD-TR(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-TRUNK-PROVIDER WS-E
     CALL "FD-TREE-STATE" USING JSON-DOC WS-E TR-LOG-STATE(WS-ROW) WS-BLOCK WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-LENGTH TR-FH(WS-ROW)
     COMPUTE TR-REPL-START(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-REPL TR-REPL-N(WS-ROW)
*>   the log decorators in the slots 1 to 5, the stump decorators from slot 6
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-LOGD WS-E
     IF WS-E > 0
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-E) OR WS-I >= 5
             CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
             ADD 1 TO TR-NDEC(WS-ROW)
             CALL "FD-DECO-NODE" USING JSON-DOC WS-N WS-ROW TR-NDEC(WS-ROW)
             IF TD-KIND(WS-ROW, TR-NDEC(WS-ROW)) NOT = 1
                 MOVE 1 TO FD-BAD
             END-IF
         END-PERFORM
         IF JN-COUNT(WS-E) > 5
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-STUMP WS-E
     IF WS-E > 0
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-E) OR WS-I >= 5
             CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
             COMPUTE WS-OK = 6 + TR-NSDEC(WS-ROW)
             CALL "FD-DECO-NODE" USING JSON-DOC WS-N WS-ROW WS-OK
             ADD 1 TO TR-NSDEC(WS-ROW)
             IF TD-KIND(WS-ROW, WS-OK) NOT = 1
                 MOVE 1 TO FD-BAD
             END-IF
         END-PERFORM
         IF JN-COUNT(WS-E) > 5
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-FALLEN-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FALLEN-SUPPORT.
*> USING x, y, z, flag out: the block below the cell is a solid one (the approximation of isFaceSturdy UP).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-Y                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE WS-Y = L-Y - 1
     CALL "FL-GET-STATE" USING L-X WS-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK > 0
         IF CB-SOLID(WS-BLOCK) = 1
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-FALLEN-SUPPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FALLEN-VALID.
*> USING row, x, y, z, flag out: validTreePos at the cell (air, or a block in replaceable_by_trees).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FLAG.
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FR-TREE-OK" USING TR-REPL-START(L-ROW) TR-REPL-N(L-ROW) WS-STATE L-FLAG
     GOBACK.
 END PROGRAM FR-FALLEN-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FALLEN.
*> USING state, feature, x, y, z, result out: placeFallenTree (7): 1 the stump at the origin (no test), then the stump decorators over {origin}; 2 a random horizontal direction, length
*> log_length - 2, and the first log cell 2 + nextInt(2) cells off in that direction; 3 the ground search (the cell above that cell, down for at most 6 cells to the first valid cell with a
*> solid block below; the cursor stays at the sixth cell when none is found); 4 the fit test (every cell of the walk is valid tree space; a cell without a solid block below adds one to the gap
*> counter, a supported one resets it, more than 2 fails: nothing more is placed); 5 the logs along the direction with the axis of that direction, then the log decorators over them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-GAP                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FIRST-STUMP         BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     MOVE 0 TO TW-NLOG
     CALL "FL-SET-STATE" USING L-X L-Y L-Z TR-LOG-STATE(WS-ROW) WS-FLAGS WS-OK
     ADD 1 TO TW-NLOG
     MOVE L-X TO TW-LOG-X(1)
     MOVE L-Y TO TW-LOG-Y(1)
     MOVE L-Z TO TW-LOG-Z(1)
     CALL "FR-DECORATE" USING L-STATE WS-ROW WS-FIRST-STUMP TR-NSDEC(WS-ROW)
     CALL "F353-RANDOM-DIRECTION" USING L-STATE WS-DIR
     CALL "F353-STEP" USING WS-DIR WS-DX WS-DY WS-DZ
     CALL "FR-INT-SAMPLE" USING L-STATE TR-FH(WS-ROW) WS-LEN
     SUBTRACT 2 FROM WS-LEN
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-DRAW
     COMPUTE WS-OFF = 2 + WS-DRAW
     COMPUTE WS-CX = L-X + WS-DX * WS-OFF
     COMPUTE WS-CY = L-Y + 1
     COMPUTE WS-CZ = L-Z + WS-DZ * WS-OFF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5 OR WS-FOUND = 1
         CALL "FR-FALLEN-VALID" USING WS-ROW WS-CX WS-CY WS-CZ WS-FLAG
         CALL "FR-FALLEN-SUPPORT" USING WS-CX WS-CY WS-CZ WS-OK
         IF WS-FLAG = 1 AND WS-OK = 1
             MOVE 1 TO WS-FOUND
         ELSE
             SUBTRACT 1 FROM WS-CY
         END-IF
     END-PERFORM
     MOVE 1 TO WS-OK
     MOVE 0 TO WS-GAP
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-LEN OR WS-OK = 0
         COMPUTE WS-STEP = WS-CX + WS-DX * WS-I
         COMPUTE WS-DRAW = WS-CZ + WS-DZ * WS-I
         CALL "FR-FALLEN-VALID" USING WS-ROW WS-STEP WS-CY WS-DRAW WS-FLAG
         IF WS-FLAG = 0
             MOVE 0 TO WS-OK
         END-IF
         CALL "FR-FALLEN-SUPPORT" USING WS-STEP WS-CY WS-DRAW WS-FLAG
         IF WS-FLAG = 1
             MOVE 0 TO WS-GAP
         ELSE
             ADD 1 TO WS-GAP
         END-IF
         IF WS-GAP > 2
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     IF WS-OK = 1 AND WS-LEN > 0
         MOVE 0 TO TW-NLOG
         CALL "FL-BLOCK-OF" USING TR-LOG-STATE(WS-ROW) WS-BLOCK
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-LEN
             COMPUTE WS-STEP = WS-CX + WS-DX * WS-I
             COMPUTE WS-DRAW = WS-CZ + WS-DZ * WS-I
             MOVE TR-LOG-STATE(WS-ROW) TO WS-STATE
*>           the axis of the direction: x is the state before the default (axis y), z the one after it
             IF CB-STATES(WS-BLOCK) = 3
                 IF WS-DX NOT = 0
                     COMPUTE WS-STATE = TR-LOG-STATE(WS-ROW) - 1
                 ELSE
                     COMPUTE WS-STATE = TR-LOG-STATE(WS-ROW) + 1
                 END-IF
             END-IF
             CALL "FL-SET-STATE" USING WS-STEP WS-CY WS-DRAW WS-STATE WS-FLAGS WS-FLAG
             ADD 1 TO TW-NLOG
             MOVE WS-STEP TO TW-LOG-X(TW-NLOG)
             MOVE WS-CY TO TW-LOG-Y(TW-NLOG)
             MOVE WS-DRAW TO TW-LOG-Z(TW-NLOG)
         END-PERFORM
         CALL "FR-DECORATE" USING L-STATE WS-ROW WS-ONE TR-NDEC(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM FR-FALLEN.
