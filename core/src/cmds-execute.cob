*> The execute command (docs/protocol/15-commands-framework.md §11, 16 §10.2): the clauses that change the source (a modifier of the chain, core/src/cmd-exec.cob),
*> the conditions, and run. Implemented: run, as, at, positioned <pos>, positioned as, rotated <rot>, rotated as, facing <pos>, facing entity, align, anchored, in,
*> and if|unless with entity, dimension, block and loaded. BLOCKED: positioned over, summon and on, store, the other conditions (biome, score, blocks, predicate,
*> function, stopwatch, data, items, slots), entities that are not players as the executing entity (a source is a player row), and the properties of a block in a
*> condition (the blocks match by block). The modifier ids are the MX-* constants of BRCMD.cpy.
*>
*> Entry points:
*>   CX-MODIFY USING context index: the modifier of the node that ended the context (BR-R-MODIFIER) fills BM-ENTRY with the sources of BR-SRC after the clause
*>   CX-COND-TEST USING pass out, count out: the condition of the context (entity, dimension, block, loaded) for the source BR-SRC; the count is that of entity
*>   CX-EXECUTE-COND: the runner of a line that ends in a condition: Test passed or Test failed (with a count for entity)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-COND-TEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY BRIGADIER.
 COPY BRRUN.
 01 WS-NAME-ENTITY         PIC X(32) VALUE "entity".
 01 WS-NAME-DIMENSION      PIC X(32) VALUE "dimension".
 01 WS-NAME-BLOCK          PIC X(32) VALUE "block".
 01 WS-NAME-LOADED         PIC X(32) VALUE "loaded".
 01 WS-NAME-ENTITIES       PIC X(32) VALUE "entities".
 01 WS-NAME-POS            PIC X(32) VALUE "pos".
 01 WS-NAME-DIM-ARG        PIC X(32) VALUE "dimension".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-DIMENSION           BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LOADED              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-DIM-KEY             PIC X(32).
 01 WS-DIM-LENGTH          BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PASS                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-PASS L-COUNT.
     GO TO MAIN-LINE.

 MAIN-LINE.
     MOVE 0 TO L-PASS L-COUNT
     CALL "BX-LIT" USING WS-NAME-ENTITY WS-ENTITY
     CALL "BX-LIT" USING WS-NAME-DIMENSION WS-DIMENSION
     CALL "BX-LIT" USING WS-NAME-BLOCK WS-BLOCK
     CALL "BX-LIT" USING WS-NAME-LOADED WS-LOADED
     EVALUATE TRUE
         WHEN WS-ENTITY > 0
             CALL "BX-FIND" USING WS-NAME-ENTITIES WS-INDEX
             CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
             IF BR-R-FAILED = 1 AND BR-E-KEY(1:24) = "argument.entity.notfound"
                 MOVE 0 TO BR-R-FAILED
                 MOVE SPACES TO BR-E-KEY
                 MOVE 0 TO BX-COUNT
             END-IF
             IF BR-R-FAILED = 0
                 MOVE BX-COUNT TO L-COUNT
                 IF BX-COUNT > 0
                     MOVE 1 TO L-PASS
                 END-IF
             END-IF
         WHEN WS-DIMENSION > 0
             CALL "BX-FIND" USING WS-NAME-DIM-ARG WS-INDEX
             COMPUTE WS-LENGTH = BA-END(WS-INDEX) - BA-START(WS-INDEX)
             MOVE DM-KEY(BS-DIM) TO WS-DIM-KEY
             MOVE DM-KEY-LENGTH(BS-DIM) TO WS-DIM-LENGTH
             MOVE BA-START(WS-INDEX) TO WS-START
             ADD 1 TO WS-START
             IF WS-DIM-LENGTH = WS-LENGTH AND WS-DIM-KEY(1:WS-LENGTH) = BR-R-LINE(WS-START:WS-LENGTH)
                 MOVE 1 TO L-PASS
             END-IF
         WHEN WS-LOADED > 0 OR WS-BLOCK > 0
             CALL "BX-FIND" USING WS-NAME-POS WS-POS
             CALL "BX-POSITION" USING WS-POS WS-X WS-Y WS-Z
             COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
             COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
             COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
             COMPUTE WS-CX = FUNCTION INTEGER(WS-BX / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(WS-BZ / 16)
             CALL "WORLD-FIND" USING BS-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0
                 IF WS-LOADED > 0
                     MOVE 1 TO L-PASS
                 ELSE
                     CALL "BX-FIND" USING WS-NAME-BLOCK WS-INDEX
                     CALL "WORLD-GET-BLOCK" USING BS-DIM WS-BX WS-BY WS-BZ WS-OLD
                     IF BA-IVAL(WS-INDEX) >= 0 AND CB-S-BLOCK(WS-OLD + 1) = CB-S-BLOCK(BA-IVAL(WS-INDEX) + 1)
                         MOVE 1 TO L-PASS
                     END-IF
                 END-IF
             ELSE
                 IF WS-LOADED = 0
                     MOVE "argument.pos.unloaded" TO WS-KEY
                     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
                     MOVE SPACES TO WS-A1 WS-A2
                     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
                     MOVE 1 TO BR-R-FAILED
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-COND-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-MODIFY.
*> The modifier of the clause that ended the context (BR-R-MODIFIER, the MX-* ids of BRCMD.cpy): BM-ENTRY gets the sources that follow from the source BR-SRC:
*> as and the forks over targets give one source for each player target; at, positioned as and rotated as take the position or rotation of the target;
*> positioned, rotated, facing, align, anchored and in change the one source; if and unless keep the source or drop it (condition of CX-COND-TEST).
*> No target is no source (no error); a target that is not a player is skipped (BLOCKED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY BRCMD.
 COPY BRRUN.
 COPY BRIGADIER.
 01 WS-SAVE                PIC X(96).
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-POS            PIC X(32) VALUE "pos".
 01 WS-NAME-ROT            PIC X(32) VALUE "rot".
 01 WS-NAME-ANCHOR         PIC X(32) VALUE "anchor".
 01 WS-NAME-AXES           PIC X(32) VALUE "axes".
 01 WS-NAME-DIMENSION      PIC X(32) VALUE "dimension".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ANCHOR              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-EYE-Y               FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-W                   FLOAT-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WANT-PASS           BINARY-LONG.
 01 WS-NAME-UNLESS         PIC X(32) VALUE "unless".
 01 WS-UNLESS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DIM-KEY             PIC X(32).
 01 WS-DIM-LENGTH          BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-CTX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CTX.
     GO TO MAIN-LINE.

*> The targets of the clause as player rows (BX-ROW 1 to BX-COUNT); none is an empty list, not an error.
 TARGETS.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 1 AND BR-E-KEY(1:24) = "argument.entity.notfound"
         MOVE 0 TO BR-R-FAILED
         MOVE SPACES TO BR-E-KEY
         MOVE 0 TO BX-COUNT
     END-IF.

*> One fork over the targets: a source for each player target, changed by the clause.
 FORK-TARGETS.
     PERFORM TARGETS
     IF BR-R-FAILED = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             IF WS-ROW > 0
                 MOVE WS-SAVE TO BR-SRC
                 ADD 1 TO BM-COUNT
                 MOVE 1 TO BS-FORKED
                 EVALUATE BR-R-MODIFIER
                     WHEN MX-AS
                         MOVE WS-ROW TO BS-ROW
                         MOVE PL-NAME(WS-ROW) TO BS-NAME
                         MOVE PL-NAME-LENGTH(WS-ROW) TO BS-NAME-LENGTH
                     WHEN MX-AT
                         MOVE PL-DIM(WS-ROW) TO BS-DIM
                         MOVE PL-X(WS-ROW) TO BS-X
                         MOVE PL-Y(WS-ROW) TO BS-Y
                         MOVE PL-Z(WS-ROW) TO BS-Z
                         MOVE PL-YAW(WS-ROW) TO BS-YAW
                         MOVE PL-PITCH(WS-ROW) TO BS-PITCH
                     WHEN MX-POSITIONED-AS
                         MOVE PL-X(WS-ROW) TO BS-X
                         MOVE PL-Y(WS-ROW) TO BS-Y
                         MOVE PL-Z(WS-ROW) TO BS-Z
                     WHEN MX-ROTATED-AS
                         MOVE PL-YAW(WS-ROW) TO BS-YAW
                         MOVE PL-PITCH(WS-ROW) TO BS-PITCH
                     WHEN MX-FACING-ENTITY
                         CALL "BX-FIND" USING WS-NAME-ANCHOR WS-ANCHOR
                         MOVE BS-X TO WS-X
                         MOVE BS-Y TO WS-Y
                         MOVE BS-Z TO WS-Z
                         IF BS-ANCHOR = 1
                             ADD 1.62 TO WS-Y
                         END-IF
                         MOVE PL-Y(WS-ROW) TO WS-EYE-Y
                         IF WS-ANCHOR > 0 AND BA-IVAL(WS-ANCHOR) = 1
                             ADD 1.62 TO WS-EYE-Y
                         END-IF
                         CALL "BX-LOOK" USING WS-X WS-Y WS-Z PL-X(WS-ROW) WS-EYE-Y PL-Z(WS-ROW) WS-YAW WS-PITCH
                         MOVE WS-YAW TO BS-YAW
                         MOVE WS-PITCH TO BS-PITCH
                 END-EVALUATE
                 MOVE BR-SRC TO BM-ENTRY(BM-COUNT)
             END-IF
         END-PERFORM
     END-IF.

 MAIN-LINE.
     MOVE BR-SRC TO WS-SAVE
     MOVE 0 TO BM-COUNT
     EVALUATE BR-R-MODIFIER
         WHEN MX-AS
         WHEN MX-AT
         WHEN MX-POSITIONED-AS
         WHEN MX-ROTATED-AS
         WHEN MX-FACING-ENTITY
             PERFORM FORK-TARGETS
         WHEN MX-POSITIONED
             CALL "BX-FIND" USING WS-NAME-POS WS-INDEX
             MOVE BS-X TO WS-X
             MOVE BS-Y TO WS-Y
             MOVE BS-Z TO WS-Z
             CALL "BX-POSITION" USING WS-INDEX WS-X WS-Y WS-Z
             MOVE WS-X TO BS-X
             MOVE WS-Y TO BS-Y
             MOVE WS-Z TO BS-Z
             MOVE 1 TO BM-COUNT
             MOVE BR-SRC TO BM-ENTRY(1)
         WHEN MX-ROTATED
             CALL "BX-FIND" USING WS-NAME-ROT WS-INDEX
             MOVE BA-NUM(WS-INDEX, 1) TO WS-W
             IF BA-KIND(WS-INDEX, 1) = 1
                 ADD BS-YAW TO WS-W
             END-IF
             COMPUTE BS-YAW = FUNCTION MOD(WS-W + 180, 360) - 180
             MOVE BA-NUM(WS-INDEX, 2) TO WS-W
             IF BA-KIND(WS-INDEX, 2) = 1
                 ADD BS-PITCH TO WS-W
             END-IF
             IF WS-W < -90
                 MOVE -90 TO WS-W
             END-IF
             IF WS-W > 90
                 MOVE 90 TO WS-W
             END-IF
             MOVE WS-W TO BS-PITCH
             MOVE 1 TO BM-COUNT
             MOVE BR-SRC TO BM-ENTRY(1)
         WHEN MX-FACING
             CALL "BX-FIND" USING WS-NAME-POS WS-INDEX
             MOVE BS-X TO WS-X
             MOVE BS-Y TO WS-Y
             MOVE BS-Z TO WS-Z
             CALL "BX-POSITION" USING WS-INDEX WS-X WS-Y WS-Z
             MOVE BS-Y TO WS-EYE-Y
             IF BS-ANCHOR = 1
                 ADD 1.62 TO WS-EYE-Y
             END-IF
             CALL "BX-LOOK" USING BS-X WS-EYE-Y BS-Z WS-X WS-Y WS-Z WS-YAW WS-PITCH
             MOVE WS-YAW TO BS-YAW
             MOVE WS-PITCH TO BS-PITCH
             MOVE 1 TO BM-COUNT
             MOVE BR-SRC TO BM-ENTRY(1)
         WHEN MX-ALIGN
             CALL "BX-FIND" USING WS-NAME-AXES WS-INDEX
             COMPUTE WS-LENGTH = BA-END(WS-INDEX) - BA-START(WS-INDEX)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LENGTH
                 EVALUATE BR-R-LINE(BA-START(WS-INDEX) + WS-I:1)
                     WHEN "x"
                         COMPUTE BS-X = FUNCTION INTEGER(BS-X)
                     WHEN "y"
                         COMPUTE BS-Y = FUNCTION INTEGER(BS-Y)
                     WHEN "z"
                         COMPUTE BS-Z = FUNCTION INTEGER(BS-Z)
                 END-EVALUATE
             END-PERFORM
             MOVE 1 TO BM-COUNT
             MOVE BR-SRC TO BM-ENTRY(1)
         WHEN MX-ANCHORED
             CALL "BX-FIND" USING WS-NAME-ANCHOR WS-INDEX
             MOVE BA-IVAL(WS-INDEX) TO BS-ANCHOR
             MOVE 1 TO BM-COUNT
             MOVE BR-SRC TO BM-ENTRY(1)
         WHEN MX-IN
             CALL "BX-FIND" USING WS-NAME-DIMENSION WS-INDEX
             COMPUTE WS-LENGTH = BA-END(WS-INDEX) - BA-START(WS-INDEX)
             MOVE 0 TO WS-DIM
             MOVE BA-START(WS-INDEX) TO WS-START
             ADD 1 TO WS-START
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 MOVE DM-KEY(WS-I) TO WS-DIM-KEY
                 MOVE DM-KEY-LENGTH(WS-I) TO WS-DIM-LENGTH
                 IF (WS-I = 1 OR CW-DIM-COUNT > 1) AND WS-DIM-LENGTH = WS-LENGTH
                         AND WS-DIM-KEY(1:WS-LENGTH) = BR-R-LINE(WS-START:WS-LENGTH)
                     MOVE WS-I TO WS-DIM
                 END-IF
             END-PERFORM
             IF WS-DIM = 0
                 MOVE "argument.dimension.invalid" TO WS-KEY
                 MOVE 1 TO WS-N-ARGS
                 MOVE SPACES TO WS-A1 WS-A2
                 MOVE BR-R-LINE(BA-START(WS-INDEX) + 1:WS-LENGTH) TO WS-A1
                 MOVE WS-LENGTH TO WS-L1
                 MOVE 0 TO WS-L2
                 CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
                 MOVE 1 TO BR-R-FAILED
             ELSE
                 MOVE WS-DIM TO BS-DIM
                 MOVE 1 TO BM-COUNT
                 MOVE BR-SRC TO BM-ENTRY(1)
             END-IF
         WHEN MX-IF
             CALL "CX-COND-TEST" USING WS-PASS WS-COUNT
             MOVE 1 TO WS-WANT-PASS
             CALL "BX-LIT" USING WS-NAME-UNLESS WS-UNLESS
             IF WS-UNLESS > 0
                 MOVE 0 TO WS-WANT-PASS
             END-IF
             IF BR-R-FAILED = 0 AND WS-PASS = WS-WANT-PASS
                 MOVE 1 TO BM-COUNT
                 MOVE 1 TO BS-FORKED
                 MOVE BR-SRC TO BM-ENTRY(1)
             END-IF
     END-EVALUATE
     MOVE WS-SAVE TO BR-SRC
     GOBACK.
 END PROGRAM CX-MODIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-EXECUTE-COND.
*> The runner of `execute if|unless <condition>` as the whole line (16 §10.2): the condition of the source (CX-COND-TEST) against if or unless: passing is
*> commands.execute.conditional.pass (pass_count [count] for entity), not broadcast, with the result 1 (the count); failing is commands.execute.conditional.fail
*> (fail_count) as a failure with the result 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-PASS                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-NAME-ENTITY         PIC X(32) VALUE "entity".
 01 WS-NAME-UNLESS         PIC X(32) VALUE "unless".
 01 WS-UNLESS              BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "CX-COND-TEST" USING WS-PASS WS-COUNT
     IF BR-R-FAILED = 0
         MOVE 1 TO WS-WANT
         CALL "BX-LIT" USING WS-NAME-UNLESS WS-UNLESS
         IF WS-UNLESS > 0
             MOVE 0 TO WS-WANT
         END-IF
         CALL "BX-LIT" USING WS-NAME-ENTITY WS-ENTITY
         IF WS-PASS = WS-WANT
             IF WS-ENTITY > 0
                 MOVE "commands.execute.conditional.pass_count" TO WS-KEY
             ELSE
                 MOVE "commands.execute.conditional.pass" TO WS-KEY
             END-IF
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             IF WS-ENTITY > 0
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
             END-IF
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
             IF WS-ENTITY > 0
                 MOVE WS-COUNT TO BR-R-RESULT
             ELSE
                 MOVE 1 TO BR-R-RESULT
             END-IF
         ELSE
             IF WS-ENTITY > 0
                 MOVE "commands.execute.conditional.fail_count" TO WS-KEY
             ELSE
                 MOVE "commands.execute.conditional.fail" TO WS-KEY
             END-IF
             MOVE SPACES TO WS-A1 WS-A2
             MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
             IF WS-ENTITY > 0
                 MOVE 1 TO WS-N-ARGS
                 MOVE WS-COUNT TO WS-EDIT
                 MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
             END-IF
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-EXECUTE-COND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-EXECUTE.
*> The grammar of execute (15 §11): every clause redirects to the execute node so that the clauses chain in any order; run redirects to the root. The nodes that
*> end a clause carry the modifier id (and the fork flag); if|unless entity, dimension, block and loaded also end the command (BC-EXECUTE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRCMD.
 COPY BRREGLAST.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG VALUE BC-EXECUTE.
 01 WS-PATH                PIC X(256).
 01 WS-EXECUTE             BINARY-LONG.
 01 WS-MODIFIER            BINARY-LONG.
 01 WS-FORK                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-WORDS.
    05 FILLER               PIC X(8) VALUE "if".
    05 FILLER               PIC X(8) VALUE "unless".
 01 WS-WORD-TABLE REDEFINES WS-WORDS.
    05 WS-WORD              PIC X(8) OCCURS 2 TIMES.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> A clause: the nodes of the path, the last redirecting to the execute node with the modifier WS-MODIFIER (fork when WS-FORK is 1).
 CLAUSE.
     CALL "BR-REG" USING WS-LEVEL WS-ZERO WS-PATH
     MOVE BR-REG-LAST-NODE TO WS-NODE
     MOVE WS-EXECUTE TO BR-N-REDIRECT(WS-NODE)
     MOVE WS-MODIFIER TO BR-N-MODIFIER(WS-NODE)
     MOVE WS-FORK TO BR-N-FORK(WS-NODE).

*> A condition: the clause that also ends the command.
 ADD-CONDITION.
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE BR-REG-LAST-NODE TO WS-NODE
     MOVE WS-EXECUTE TO BR-N-REDIRECT(WS-NODE)
     MOVE WS-MODIFIER TO BR-N-MODIFIER(WS-NODE)
     MOVE WS-FORK TO BR-N-FORK(WS-NODE).

 MAIN-LINE.
     MOVE "execute" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-ZERO WS-PATH
     MOVE BR-REG-LAST-NODE TO WS-EXECUTE
     MOVE "execute run" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-ZERO WS-PATH
     MOVE BR-REG-LAST-NODE TO WS-NODE
     MOVE 1 TO BR-N-REDIRECT(WS-NODE)
     MOVE MX-AS TO WS-MODIFIER
     MOVE 1 TO WS-FORK
     MOVE "execute as <targets:entities>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-AT TO WS-MODIFIER
     MOVE "execute at <targets:entities>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-POSITIONED-AS TO WS-MODIFIER
     MOVE "execute positioned as <targets:entities>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-ROTATED-AS TO WS-MODIFIER
     MOVE "execute rotated as <targets:entities>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-FACING-ENTITY TO WS-MODIFIER
     MOVE "execute facing entity <targets:entities> <anchor:anchor>" TO WS-PATH
     PERFORM CLAUSE
     MOVE 0 TO WS-FORK
     MOVE MX-POSITIONED TO WS-MODIFIER
     MOVE "execute positioned <pos:vec3>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-ROTATED TO WS-MODIFIER
     MOVE "execute rotated <rot:rotation>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-FACING TO WS-MODIFIER
     MOVE "execute facing <pos:vec3>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-ALIGN TO WS-MODIFIER
     MOVE "execute align <axes:swizzle>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-ANCHORED TO WS-MODIFIER
     MOVE "execute anchored <anchor:anchor>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-IN TO WS-MODIFIER
     MOVE "execute in <dimension:dimension>" TO WS-PATH
     PERFORM CLAUSE
     MOVE MX-IF TO WS-MODIFIER
     MOVE 1 TO WS-FORK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE SPACES TO WS-PATH
         STRING "execute " FUNCTION TRIM(WS-WORD(WS-I)) " entity <entities:entities>" DELIMITED BY SIZE INTO WS-PATH
         PERFORM ADD-CONDITION
         MOVE SPACES TO WS-PATH
         STRING "execute " FUNCTION TRIM(WS-WORD(WS-I)) " dimension <dimension:dimension>" DELIMITED BY SIZE INTO WS-PATH
         PERFORM ADD-CONDITION
         MOVE SPACES TO WS-PATH
         STRING "execute " FUNCTION TRIM(WS-WORD(WS-I)) " block <pos:pos> <block:blockpred>" DELIMITED BY SIZE INTO WS-PATH
         PERFORM ADD-CONDITION
         MOVE SPACES TO WS-PATH
         STRING "execute " FUNCTION TRIM(WS-WORD(WS-I)) " loaded <pos:pos>" DELIMITED BY SIZE INTO WS-PATH
         PERFORM ADD-CONDITION
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-EXECUTE.
