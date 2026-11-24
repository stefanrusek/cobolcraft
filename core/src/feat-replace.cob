*> replace_single_block and the RuleTest family as a feature (docs/protocol/35-worldgen-features-4 section 7.5, T9807; feature type registry id 37). The rule tests are the structure
*> processors' (the tables SP-TEST of STRUCTPROC.cpy, compiled by SP-COMPILE-TEST: the ten types of 7.5.3), evaluated here with the feature's own random source (the Xoroshiro state of
*> XORO.cpy, WGR-NEXT-FLOAT) in place of the processors' per-block Java source. The feature has no geometry: only the origin is read and written (flags 2).
*>
*> Entry points:
*>   FD-REPLACE-NODE USING doc, node, first out, count out: compiles targets (a list of {target: RuleTest, state: block state}) into count pairs (rule test row, state) of FD-POOL from first on;
*>     FD-BAD (the caller makes the feature unsupported) for a missing or non-list targets, an entry without target or state, a rule test the processors' compiler refuses (SP-BAD) or an unknown block
*>   FEAT-RULE-TEST USING test row (SP-TEST), state, y, random state (XORO.cpy), result out: RuleTest.test(state, pos, random) (7.5.3)
*>   FR-REPLACE USING random state, feature, x, y, z, result out: ReplaceBlockFeature.place (7.5.1): the first target whose test accepts the origin's state writes its state; always true

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-REPLACE-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY STRUCTPROC.
 01 K-TARGETS              PIC X(40) VALUE "targets".
 01 K-TARGET               PIC X(40) VALUE "target".
 01 K-STATE                PIC X(40) VALUE "state".
 01 WS-LIST                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KIND-RULE           BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-FIRST L-COUNT.
     COMPUTE L-FIRST = FD-POOL-COUNT + 1
     MOVE 0 TO L-COUNT
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-TARGETS WS-LIST
     IF WS-LIST = 0 OR JN-TYPE(WS-LIST) NOT = JT-ARRAY
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-LIST)
         CALL "JSON-ELEMENT" USING JSON-DOC WS-LIST WS-I WS-E
         CALL "FD-J-MEMBER" USING JSON-DOC WS-E K-TARGET WS-T
         CALL "FD-J-MEMBER" USING JSON-DOC WS-E K-STATE WS-S
         IF WS-T = 0 OR WS-S = 0
             MOVE 1 TO FD-BAD
             GOBACK
         END-IF
         MOVE 0 TO SP-BAD
         CALL "SP-COMPILE-TEST" USING JSON-DOC WS-T WS-KIND-RULE WS-ROW
         IF SP-BAD = 1
             MOVE 0 TO SP-BAD
             MOVE 1 TO FD-BAD
             GOBACK
         END-IF
         CALL "FD-J-STATE" USING JSON-DOC WS-S WS-STATE WS-OK
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
             GOBACK
         END-IF
         CALL "FD-POOL-ADD" USING WS-ROW WS-INDEX
         CALL "FD-POOL-ADD" USING WS-STATE WS-INDEX
         ADD 1 TO L-COUNT
     END-PERFORM
     GOBACK.
 END PROGRAM FD-REPLACE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FEAT-RULE-TEST RECURSIVE.
*> The draw of random_block_match and random_blockstate_match is made only when the block (the state) matches, and passes when it is below the probability: the comparison is made on
*> the exact difference (a FLOAT-LONG comparison is fuzzy). all_of and any_of stop at the first false (true) child, the empty all_of is true and the empty any_of false, not keeps its child's draws.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY CBLOCKS.
 01 WS-U                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 LOCAL-STORAGE SECTION.
 01 LS-CHILD               BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEST                 BINARY-LONG.
 01 L-BSTATE                BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEST L-BSTATE L-Y L-STATE L-RESULT.
     MOVE 0 TO L-RESULT
     COMPUTE LS-BLOCK = CB-S-BLOCK(L-BSTATE + 1) + 1
     EVALUATE SPT-TYPE(L-TEST)
         WHEN 1
             MOVE 1 TO L-RESULT
         WHEN 2
             IF LS-BLOCK = SPT-A(L-TEST)
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 3
             IF L-BSTATE = SPT-A(L-TEST)
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 4
             CALL "SP-IN-SET" USING SPT-POOL(L-TEST) SPT-N(L-TEST) L-BSTATE L-RESULT
         WHEN 5
             IF LS-BLOCK = SPT-A(L-TEST)
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-U
                 MOVE SPT-F(L-TEST) TO WS-P
                 CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-U WS-P WS-D
                 IF WS-D < 0
                     MOVE 1 TO L-RESULT
                 END-IF
             END-IF
         WHEN 6
             IF L-BSTATE = SPT-A(L-TEST)
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-U
                 MOVE SPT-F(L-TEST) TO WS-P
                 CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-U WS-P WS-D
                 IF WS-D < 0
                     MOVE 1 TO L-RESULT
                 END-IF
             END-IF
         WHEN 7
             IF L-Y >= SPT-B(L-TEST) AND L-Y <= SPT-C(L-TEST)
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 8
             MOVE 1 TO L-RESULT
             MOVE SPT-CHILD(L-TEST) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0 OR L-RESULT = 0
                 CALL "FEAT-RULE-TEST" USING LS-CHILD L-BSTATE L-Y L-STATE LS-SUB
                 MOVE LS-SUB TO L-RESULT
                 MOVE SPT-NEXT(LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN 9
             MOVE SPT-CHILD(L-TEST) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0 OR L-RESULT = 1
                 CALL "FEAT-RULE-TEST" USING LS-CHILD L-BSTATE L-Y L-STATE LS-SUB
                 MOVE LS-SUB TO L-RESULT
                 MOVE SPT-NEXT(LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN OTHER
             CALL "FEAT-RULE-TEST" USING SPT-CHILD(L-TEST) L-BSTATE L-Y L-STATE LS-SUB
             IF LS-SUB = 0
                 MOVE 1 TO L-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FEAT-RULE-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-REPLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE 0 TO WS-HIT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= FT-B(L-FT) OR WS-HIT = 1
         COMPUTE WS-AT = FT-A(L-FT) + WS-I * 2
         MOVE FD-POOL(WS-AT) TO WS-TEST
         COMPUTE WS-AT = WS-AT + 1
         MOVE FD-POOL(WS-AT) TO WS-NEW
         CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
         CALL "FEAT-RULE-TEST" USING WS-TEST WS-STATE L-Y L-STATE WS-HIT
         IF WS-HIT = 1
             CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-NEW WS-FLAGS WS-OK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-REPLACE.
