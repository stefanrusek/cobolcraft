*> The execution stage of the command framework (docs/protocol/15a-brigadier-command-library.md §4; 15-commands-framework.md §10):
*> a parsed line is flattened into modifier contexts (a redirect or fork node, each with its modifier) and the executable
*> context (the last), and the chain is run over the list of sources (15a §4.3): without modifiers the command runs once on
*> the source; otherwise each modifier replaces the list by the concatenation of its results (no modifier: the source itself),
*> an empty list ends the chain with 0, and the command runs once per source, the result being the sum of the command results,
*> or the number of successful runs when any modifier forked. The result consumer is called once per command run, once per
*> failed modifier and once when a line cannot be flattened.
*>
*> The runner, the modifier and the consumer are passed as program pointers (SET ptr TO ENTRY "NAME"), so the chain can be run
*> by tests with their own programs; BR-EXECUTE passes the framework's own (BR-CMD-CALL, BR-MODIFY-CALL, BR-CONSUME). A runner
*> USING context index reads the source BR-SRC and the nodes of the context BR-RUN (core/copy/BRRUN.cpy) and sets BR-R-RESULT
*> and BR-R-FAILED (1: it raised the exception in BR-ERR); a modifier USING context index reads the same and fills BR-MOD
*> (BM-COUNT, BM-ENTRY: sources of BS-SIZE bytes) or sets BR-R-FAILED; BR-R-MODIFIER is the modifier id of the node; a consumer
*> USING context index, success (1 or 0), result is told each run.
*>
*> Entry points:
*>   BR-FILL-RUN USING trail, context index: the nodes of that context into BR-RUN (BR-R-COUNT, BR-R-ARG; BR-R-COMMAND is
*>     the command of the last node of the context)
*>   BR-CHAIN USING trail (a parse result with a command, BR-VERDICT 0), runner, modifier, consumer (program pointers),
*>     result out (sum or count), failed out (1: an exception is in BR-ERR and was not swallowed by a fork); the source is
*>     BR-SRC, left as it was; BR-R-LINE and BR-R-LENGTH hold the line
*>   BR-LINE USING level, line (PIC X(1024)), length, runner, modifier, consumer, result out, failed out: parse of
*>     the line (BR-PARSE) with the decision of 15a §4.1 (BR-VERDICT) and then BR-CHAIN; failed 1 = the exception of the
*>     parse (BR-ERR with its cursor), 2 = an exception of the execution; a line that parses but cannot be flattened calls the
*>     consumer once with (context, 0, 0)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-FILL-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRRUN.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY BRTRAIL.
 01 L-CTX                  BINARY-LONG.
 PROCEDURE DIVISION USING BT-TRAIL L-CTX.
     MOVE 0 TO BR-R-COUNT BR-R-COMMAND BR-R-MODIFIER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         IF BT-CTX(WS-I) = L-CTX AND BR-R-COUNT < BR-MAX-RUN-NODES
             ADD 1 TO BR-R-COUNT
             MOVE BT-NODE(WS-I) TO WS-NODE
             MOVE BR-N-NAME(WS-NODE) TO BA-NAME(BR-R-COUNT)
             MOVE BR-N-NAME-LENGTH(WS-NODE) TO BA-NAME-LENGTH(BR-R-COUNT)
             MOVE WS-NODE TO BA-NODE(BR-R-COUNT)
             MOVE 0 TO BA-TYPE(BR-R-COUNT) BA-ARG(BR-R-COUNT)
             IF BR-N-KIND(WS-NODE) = BR-ARGUMENT
                 MOVE BR-N-TYPE(WS-NODE) TO BA-TYPE(BR-R-COUNT)
                 MOVE 1 TO BA-ARG(BR-R-COUNT)
             END-IF
             MOVE BT-START(WS-I) TO BA-START(BR-R-COUNT)
             MOVE BT-END(WS-I) TO BA-END(BR-R-COUNT)
             MOVE BT-INF(WS-I) TO BA-INF(BR-R-COUNT)
             MOVE BT-IVAL(WS-I) TO BA-IVAL(BR-R-COUNT)
             MOVE BT-DVAL(WS-I) TO BA-DVAL(BR-R-COUNT)
             MOVE BT-AUX(WS-I) TO BA-AUX(BR-R-COUNT)
             MOVE BT-IVAL2(WS-I) TO BA-IVAL2(BR-R-COUNT)
             MOVE BT-DVAL2(WS-I) TO BA-DVAL2(BR-R-COUNT)
             MOVE BT-KIND(WS-I, 1) TO BA-KIND(BR-R-COUNT, 1)
             MOVE BT-KIND(WS-I, 2) TO BA-KIND(BR-R-COUNT, 2)
             MOVE BT-KIND(WS-I, 3) TO BA-KIND(BR-R-COUNT, 3)
             MOVE BT-NUM(WS-I, 1) TO BA-NUM(BR-R-COUNT, 1)
             MOVE BT-NUM(WS-I, 2) TO BA-NUM(BR-R-COUNT, 2)
             MOVE BT-NUM(WS-I, 3) TO BA-NUM(BR-R-COUNT, 3)
             MOVE BR-N-COMMAND(WS-NODE) TO BR-R-COMMAND
             MOVE BR-N-MODIFIER(WS-NODE) TO BR-R-MODIFIER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BR-FILL-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-CHAIN RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRRUN.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-2              BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LOCAL-STORAGE SECTION.
 01 LS-LIST.
    05 LS-LIST-COUNT        BINARY-LONG.
    05 LS-LIST-ENTRY        PIC X(96) OCCURS 1024 TIMES.
 01 LS-NEXT.
    05 LS-NEXT-COUNT        BINARY-LONG.
    05 LS-NEXT-ENTRY        PIC X(96) OCCURS 1024 TIMES.
 01 LS-ORIGINAL            PIC X(96).
 01 LS-N                   BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-J                   BINARY-LONG.
 01 LS-NODE                BINARY-LONG.
 01 LS-FORKED              BINARY-LONG.
 01 LS-STOP                BINARY-LONG.
 01 LS-RESULT              BINARY-LONG.
 01 LS-SUM                 BINARY-LONG.
 01 LS-KEY                 PIC X(48) VALUE "command.forkLimit".
 01 LS-LIMIT               PIC X(64) VALUE "1024".
 01 LS-LIMIT-LENGTH        BINARY-LONG VALUE 4.
 01 LS-NO-ARG              PIC X(64).
 01 LS-ARGS                BINARY-LONG VALUE 1.
 01 LS-RC                  BINARY-LONG VALUE -1.
 01 LS-NO-LENGTH           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY BRTRAIL.
 01 L-RUNNER               USAGE PROGRAM-POINTER.
 01 L-MODIFIER             USAGE PROGRAM-POINTER.
 01 L-CONSUMER             USAGE PROGRAM-POINTER.
 01 L-RESULT               BINARY-LONG.
 01 L-FAILED               BINARY-LONG.
 PROCEDURE DIVISION USING BT-TRAIL L-RUNNER L-MODIFIER L-CONSUMER L-RESULT L-FAILED.
     MOVE 0 TO L-RESULT L-FAILED LS-STOP LS-FORKED LS-SUM
     MOVE BR-SRC TO LS-ORIGINAL
     MOVE BT-CTX-COUNT TO LS-N
     MOVE 1 TO LS-LIST-COUNT
     MOVE BR-SRC TO LS-LIST-ENTRY(1)
     PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K >= LS-N OR LS-STOP = 1
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > BT-COUNT
             IF BT-CTX(LS-I) = LS-K
                 MOVE BT-NODE(LS-I) TO LS-NODE
             END-IF
         END-PERFORM
         IF BR-N-FORK(LS-NODE) = 1
             MOVE 1 TO LS-FORKED
         END-IF
         MOVE 0 TO LS-NEXT-COUNT
         PERFORM VARYING LS-J FROM 1 BY 1 UNTIL LS-J > LS-LIST-COUNT OR LS-STOP = 1
             IF BR-N-MODIFIER(LS-NODE) = 0
                 ADD 1 TO LS-NEXT-COUNT
                 MOVE LS-LIST-ENTRY(LS-J) TO LS-NEXT-ENTRY(LS-NEXT-COUNT)
             ELSE
                 MOVE LS-LIST-ENTRY(LS-J) TO BR-SRC
                 MOVE LS-FORKED TO BS-FORKED
                 CALL "BR-FILL-RUN" USING BT-TRAIL LS-K
                 MOVE 0 TO BR-R-FAILED BM-COUNT
                 CALL L-MODIFIER USING LS-K
                 EVALUATE TRUE
                     WHEN BR-R-FAILED = 1
                         CALL L-CONSUMER USING LS-K WS-ZERO WS-ZERO-2
                         IF LS-FORKED = 0
                             MOVE 1 TO L-FAILED LS-STOP
                         END-IF
                     WHEN LS-NEXT-COUNT + BM-COUNT > BR-MAX-SOURCES
                         MOVE 1 TO LS-STOP
                         IF LS-FORKED = 0
                             MOVE 1 TO L-FAILED
                             MOVE SPACES TO LS-NO-ARG
                             CALL "BR-RAISE" USING LS-KEY LS-ARGS LS-LIMIT LS-LIMIT-LENGTH LS-NO-ARG LS-NO-LENGTH LS-RC
                         END-IF
                     WHEN OTHER
                         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > BM-COUNT
                             ADD 1 TO LS-NEXT-COUNT
                             MOVE BM-ENTRY(LS-I) TO LS-NEXT-ENTRY(LS-NEXT-COUNT)
                         END-PERFORM
                 END-EVALUATE
             END-IF
         END-PERFORM
         MOVE LS-NEXT TO LS-LIST
         IF LS-NEXT-COUNT = 0
             MOVE 1 TO LS-STOP
         END-IF
     END-PERFORM
     IF LS-STOP = 0
         PERFORM VARYING LS-J FROM 1 BY 1 UNTIL LS-J > LS-LIST-COUNT OR L-FAILED = 1
             MOVE LS-LIST-ENTRY(LS-J) TO BR-SRC
             MOVE LS-FORKED TO BS-FORKED
             CALL "BR-FILL-RUN" USING BT-TRAIL LS-N
             MOVE 0 TO BR-R-RESULT BR-R-FAILED
             CALL L-RUNNER USING LS-N
             IF BR-R-FAILED = 0
                 MOVE BR-R-RESULT TO LS-RESULT
                 CALL L-CONSUMER USING LS-N WS-ONE LS-RESULT
                 IF LS-FORKED = 1
                     ADD 1 TO LS-SUM
                 ELSE
                     ADD LS-RESULT TO LS-SUM
                 END-IF
             ELSE
                 CALL L-CONSUMER USING LS-N WS-ZERO WS-ZERO-2
                 IF LS-FORKED = 0
                     MOVE 1 TO L-FAILED
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     IF L-FAILED = 0
         MOVE LS-SUM TO L-RESULT
     END-IF
     MOVE LS-ORIGINAL TO BR-SRC
     GOBACK.
 END PROGRAM BR-CHAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-LINE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRRUN.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-2              BINARY-LONG VALUE 0.
 LOCAL-STORAGE SECTION.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==LT-==.
 01 LS-VERDICT             BINARY-LONG.
 01 LS-COMMAND             BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-LINE                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-RUNNER               USAGE PROGRAM-POINTER.
 01 L-MODIFIER             USAGE PROGRAM-POINTER.
 01 L-CONSUMER             USAGE PROGRAM-POINTER.
 01 L-RESULT               BINARY-LONG.
 01 L-FAILED               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-LINE L-LENGTH L-RUNNER L-MODIFIER L-CONSUMER L-RESULT L-FAILED.
     MOVE 0 TO L-RESULT L-FAILED
     CALL "BR-PARSE" USING L-LEVEL L-LINE L-LENGTH LT-TRAIL
     CALL "BR-VERDICT" USING LT-TRAIL LS-VERDICT LS-COMMAND
     IF LS-VERDICT = 1
         MOVE 1 TO L-FAILED
         IF LT-CURSOR >= L-LENGTH
             CALL L-CONSUMER USING LT-CTX-COUNT WS-ZERO WS-ZERO-2
         END-IF
     ELSE
         MOVE L-LINE TO BR-R-LINE
         MOVE L-LENGTH TO BR-R-LENGTH
         CALL "BR-CHAIN" USING LT-TRAIL L-RUNNER L-MODIFIER L-CONSUMER L-RESULT L-FAILED
         IF L-FAILED = 1
             MOVE 2 TO L-FAILED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BR-LINE.
