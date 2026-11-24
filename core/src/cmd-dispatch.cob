*> The dispatcher of the command framework: the parse of 15a §3 (docs/protocol/15a-brigadier-command-
*> library.md; 15-commands-framework.md §4.4) and the decision of 15 §4.5 on its result.
*>
*> A parse result is a trail (core/copy/BRTRAIL.cpy): the parsed nodes with their ranges and parsed
*> values, the context each belongs to (a redirect starts a child context), the reader cursor and
*> the exceptions of the failing candidates of the level that ended the parse.
*>
*> Entry points:
*>   BR-PARSE USING source level (0 to 4), line (PIC X(1024), without a leading /), byte length, result
*>     out (a BRTRAIL group): parses the line from the root; a node whose requirement level the source
*>     does not hold is skipped (15a §3.1 step 1)
*>   BR-VERDICT USING result, verdict out (0 = the line parsed to a command, 1 = an exception, in
*>     BR-ERR), command out (BR-N-COMMAND of the last node of the last context): unread input with
*>     exactly one recorded exception is that exception; with none, an empty range is
*>     command.unknown.command and else command.unknown.argument, at the reader's cursor; all input
*>     read and a last context without a command is command.unknown.command (15 §4.5)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-PARSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==BW-==.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-LINE                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 COPY BRTRAIL.
 PROCEDURE DIVISION USING L-LEVEL L-LINE L-LENGTH BT-TRAIL.
     MOVE L-LEVEL TO BR-IN-LEVEL
     MOVE L-LINE TO BR-IN-TEXT
     MOVE L-LENGTH TO BR-IN-LENGTH
     MOVE 0 TO BR-IN-CURSOR
     INITIALIZE BW-TRAIL
     MOVE 1 TO BW-CTX-COUNT
     MOVE 0 TO BW-CTX-START(1)
     CALL "BR-STEP" USING BW-TRAIL BT-TRAIL WS-ROOT
     GOBACK.
 END PROGRAM BR-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-STEP RECURSIVE.
*> USING working trail (the context so far; restored to its entry state for every candidate), result
*> out, node: the recursive step of 15a §3.1 for one node with the reader at BR-IN-CURSOR. The result
*> is the best branch (the reader at the end first, then no exceptions, then discovery order, 15a §3.3);
*> a branch through a redirect is returned at once; with no branch, the context and reader as passed in
*> with the exceptions of the failed candidates.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-IVAL                BINARY-DOUBLE.
 01 WS-DVAL                FLOAT-LONG.
 01 WS-INF                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LOCAL-STORAGE SECTION.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==LB-==.
 01 LS-ERRS.
    05 LS-ERR-COUNT         BINARY-LONG.
    05 LS-ERR               OCCURS 4 TIMES.
       10 LS-ERR-KEY         PIC X(48).
       10 LS-ERR-ARGS        BINARY-LONG.
       10 LS-ERR-LEN1        BINARY-LONG.
       10 LS-ERR-ARG1        PIC X(64).
       10 LS-ERR-LEN2        BINARY-LONG.
       10 LS-ERR-ARG2        PIC X(64).
       10 LS-ERR-CURSOR      BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-LITERAL             BINARY-LONG.
 01 LS-CANDIDATE           BINARY-LONG.
 01 LS-CURSOR0             BINARY-LONG.
 01 LS-COUNT0              BINARY-LONG.
 01 LS-CTX0                BINARY-LONG.
 01 LS-WORD-END            BINARY-LONG.
 01 LS-WORD-LENGTH         BINARY-LONG.
 01 LS-START               BINARY-LONG.
 01 LS-REMAINING           BINARY-LONG.
 01 LS-NEED                BINARY-LONG.
 01 LS-CAND-END            BINARY-LONG.
 01 LS-BEST-END            BINARY-LONG.
 01 LS-BETTER              BINARY-LONG.
 01 LS-REDIRECT            BINARY-LONG.
 LINKAGE SECTION.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==LW-==.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==LR-==.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING LW-TRAIL LR-TRAIL L-NODE.
     GO TO MAIN-LINE.

*> The word at the cursor (up to a space or the end) as a literal child of the node, or 0 (15a §2.4).
 FIND-LITERAL.
     MOVE LS-CURSOR0 TO LS-WORD-END
     PERFORM UNTIL LS-WORD-END >= BR-IN-LENGTH OR BR-IN-TEXT(LS-WORD-END + 1:1) = SPACE
         ADD 1 TO LS-WORD-END
     END-PERFORM
     COMPUTE LS-WORD-LENGTH = LS-WORD-END - LS-CURSOR0
     MOVE BR-N-FIRST(L-NODE) TO LS-CANDIDATE
     PERFORM UNTIL LS-CANDIDATE = 0
         IF BR-N-KIND(LS-CANDIDATE) = BR-LITERAL AND BR-N-NAME-LENGTH(LS-CANDIDATE) = LS-WORD-LENGTH
                 AND LS-WORD-LENGTH > 0
                 AND BR-N-NAME(LS-CANDIDATE)(1:LS-WORD-LENGTH)
                     = BR-IN-TEXT(LS-CURSOR0 + 1:LS-WORD-LENGTH)
             MOVE LS-CANDIDATE TO LS-LITERAL
         END-IF
         MOVE BR-N-NEXT(LS-CANDIDATE) TO LS-CANDIDATE
     END-PERFORM.

*> Steps 2 to 6 of 15a §3.1 for the candidate LS-CANDIDATE. LS-REDIRECT = 1 when the result was
*> produced through a redirect (to be returned at once).
 TRY-CANDIDATE.
     MOVE 0 TO LS-REDIRECT
     MOVE LS-COUNT0 TO LW-COUNT
     MOVE LS-CTX0 TO LW-CTX-COUNT
     MOVE LS-CURSOR0 TO BR-IN-CURSOR
     MOVE SPACES TO BR-E-KEY
     MOVE 0 TO WS-IVAL WS-DVAL WS-INF
     INITIALIZE BR-VAL
     MOVE LS-CURSOR0 TO LS-START
     IF BR-N-KIND(LS-CANDIDATE) = BR-LITERAL
         ADD BR-N-NAME-LENGTH(LS-CANDIDATE) TO BR-IN-CURSOR
     ELSE
         CALL "BR-ARG-PARSE" USING LS-CANDIDATE WS-IVAL WS-DVAL WS-INF
     END-IF
     IF BR-E-KEY = SPACES AND BR-IN-CURSOR < BR-IN-LENGTH
             AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = SPACE
         MOVE "command.expected.separator" TO WS-KEY
         CALL "BR-RAISE-PLAIN" USING WS-KEY BR-IN-CURSOR
     END-IF
     IF BR-E-KEY NOT = SPACES
         PERFORM RECORD-ERROR
     ELSE
         ADD 1 TO LW-COUNT
         MOVE LS-CANDIDATE TO LW-NODE(LW-COUNT)
         MOVE LS-START TO LW-START(LW-COUNT)
         MOVE BR-IN-CURSOR TO LW-END(LW-COUNT)
         MOVE LW-CTX-COUNT TO LW-CTX(LW-COUNT)
         MOVE WS-IVAL TO LW-IVAL(LW-COUNT)
         MOVE WS-DVAL TO LW-DVAL(LW-COUNT)
         MOVE WS-INF TO LW-INF(LW-COUNT)
         MOVE BR-V-AUX TO LW-AUX(LW-COUNT)
         MOVE BR-V-IVAL2 TO LW-IVAL2(LW-COUNT)
         MOVE BR-V-DVAL2 TO LW-DVAL2(LW-COUNT)
         PERFORM VARYING LS-NEED FROM 1 BY 1 UNTIL LS-NEED > 3
             MOVE BR-V-KIND(LS-NEED) TO LW-KIND(LW-COUNT, LS-NEED)
             MOVE BR-V-NUM(LS-NEED) TO LW-NUM(LW-COUNT, LS-NEED)
         END-PERFORM
         PERFORM CONTINUE-PAST
     END-IF.

 RECORD-ERROR.
     IF LS-ERR-COUNT < LB-MAX-ERRS
         ADD 1 TO LS-ERR-COUNT
         MOVE BR-E-KEY TO LS-ERR-KEY(LS-ERR-COUNT)
         MOVE BR-E-ARG-COUNT TO LS-ERR-ARGS(LS-ERR-COUNT)
         MOVE BR-E-ARG-LENGTH(1) TO LS-ERR-LEN1(LS-ERR-COUNT)
         MOVE BR-E-ARG(1) TO LS-ERR-ARG1(LS-ERR-COUNT)
         MOVE BR-E-ARG-LENGTH(2) TO LS-ERR-LEN2(LS-ERR-COUNT)
         MOVE BR-E-ARG(2) TO LS-ERR-ARG2(LS-ERR-COUNT)
         MOVE BR-E-CURSOR TO LS-ERR-CURSOR(LS-ERR-COUNT)
     END-IF.

*> Step 6: continue past the node only with at least 2 more characters (1 with a redirect).
 CONTINUE-PAST.
     COMPUTE LS-REMAINING = BR-IN-LENGTH - BR-IN-CURSOR
     MOVE 2 TO LS-NEED
     IF BR-N-REDIRECT(LS-CANDIDATE) > 0
         MOVE 1 TO LS-NEED
     END-IF
     IF LS-REMAINING < LS-NEED
         MOVE LW-TRAIL TO LR-TRAIL
         MOVE BR-IN-CURSOR TO LR-CURSOR
         MOVE 0 TO LR-ERR-COUNT
     ELSE
         ADD 1 TO BR-IN-CURSOR
         IF BR-N-REDIRECT(LS-CANDIDATE) > 0
             ADD 1 TO LW-CTX-COUNT
             MOVE BR-IN-CURSOR TO LW-CTX-START(LW-CTX-COUNT)
             MOVE BR-N-REDIRECT(LS-CANDIDATE) TO LS-NEED
             CALL "BR-STEP" USING LW-TRAIL LR-TRAIL LS-NEED
             MOVE 1 TO LS-REDIRECT
         ELSE
             CALL "BR-STEP" USING LW-TRAIL LR-TRAIL LS-CANDIDATE
         END-IF
     END-IF
     IF LS-REDIRECT = 0
         PERFORM KEEP-IF-BETTER
     END-IF.

*> The comparator of 15a §3.3 against the best branch so far (a stable choice: only a strictly better
*> branch replaces the first).
 KEEP-IF-BETTER.
     MOVE 0 TO LS-BETTER
     IF LS-FOUND = 0
         MOVE 1 TO LS-BETTER
     ELSE
         MOVE 0 TO LS-CAND-END LS-BEST-END
         IF LR-CURSOR >= BR-IN-LENGTH
             MOVE 1 TO LS-CAND-END
         END-IF
         IF LB-CURSOR >= BR-IN-LENGTH
             MOVE 1 TO LS-BEST-END
         END-IF
         IF LS-CAND-END > LS-BEST-END
             MOVE 1 TO LS-BETTER
         END-IF
         IF LS-CAND-END = LS-BEST-END AND LR-ERR-COUNT = 0 AND LB-ERR-COUNT > 0
             MOVE 1 TO LS-BETTER
         END-IF
     END-IF
     IF LS-BETTER = 1
         MOVE LR-TRAIL TO LB-TRAIL
         MOVE 1 TO LS-FOUND
     END-IF.

 MAIN-LINE.
     MOVE BR-IN-CURSOR TO LS-CURSOR0
     MOVE LW-COUNT TO LS-COUNT0
     MOVE LW-CTX-COUNT TO LS-CTX0
     MOVE 0 TO LS-FOUND LS-ERR-COUNT LS-LITERAL
     PERFORM FIND-LITERAL
     MOVE BR-N-FIRST(L-NODE) TO LS-CANDIDATE
     PERFORM UNTIL LS-CANDIDATE = 0
         IF (LS-LITERAL > 0 AND LS-CANDIDATE = LS-LITERAL)
                 OR (LS-LITERAL = 0 AND BR-N-KIND(LS-CANDIDATE) = BR-ARGUMENT)
             IF BR-N-LEVEL(LS-CANDIDATE) <= BR-IN-LEVEL
                 PERFORM TRY-CANDIDATE
                 IF LS-REDIRECT = 1
                     GOBACK
                 END-IF
             END-IF
         END-IF
         MOVE BR-N-NEXT(LS-CANDIDATE) TO LS-CANDIDATE
     END-PERFORM
     IF LS-FOUND = 1
         MOVE LB-TRAIL TO LR-TRAIL
     ELSE
         MOVE LW-TRAIL TO LR-TRAIL
         MOVE LS-COUNT0 TO LR-COUNT
         MOVE LS-CTX0 TO LR-CTX-COUNT
         MOVE LS-CURSOR0 TO LR-CURSOR
         MOVE LS-ERR-COUNT TO LR-ERR-COUNT
         PERFORM VARYING LS-START FROM 1 BY 1 UNTIL LS-START > LS-ERR-COUNT
             MOVE LS-ERR(LS-START) TO LR-ERR(LS-START)
         END-PERFORM
     END-IF.
 END PROGRAM BR-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-VERDICT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 COPY BRTRAIL.
 01 L-VERDICT              BINARY-LONG.
 01 L-COMMAND              BINARY-LONG.
 PROCEDURE DIVISION USING BT-TRAIL L-VERDICT L-COMMAND.
     MOVE 0 TO L-VERDICT L-COMMAND
     MOVE SPACES TO BR-E-KEY
     IF BT-CURSOR < BR-IN-LENGTH
         MOVE 1 TO L-VERDICT
         EVALUATE TRUE
             WHEN BT-ERR-COUNT = 1
                 MOVE BT-ERR-KEY(1) TO BR-E-KEY
                 MOVE BT-ERR-ARGS(1) TO BR-E-ARG-COUNT
                 MOVE BT-ERR-LEN1(1) TO BR-E-ARG-LENGTH(1)
                 MOVE BT-ERR-ARG1(1) TO BR-E-ARG(1)
                 MOVE BT-ERR-LEN2(1) TO BR-E-ARG-LENGTH(2)
                 MOVE BT-ERR-ARG2(1) TO BR-E-ARG(2)
                 MOVE BT-ERR-CURSOR(1) TO BR-E-CURSOR
             WHEN BT-COUNT = 0
                 MOVE "command.unknown.command" TO WS-KEY
                 CALL "BR-RAISE-PLAIN" USING WS-KEY BT-CURSOR
             WHEN OTHER
                 MOVE "command.unknown.argument" TO WS-KEY
                 CALL "BR-RAISE-PLAIN" USING WS-KEY BT-CURSOR
         END-EVALUATE
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
             IF BT-CTX(WS-I) = BT-CTX-COUNT
                 MOVE BR-N-COMMAND(BT-NODE(WS-I)) TO L-COMMAND
             END-IF
         END-PERFORM
         IF L-COMMAND = 0
             MOVE 1 TO L-VERDICT
             MOVE "command.unknown.command" TO WS-KEY
             CALL "BR-RAISE-PLAIN" USING WS-KEY BT-CURSOR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BR-VERDICT.
