*> Acceptance test of docs/protocol/15a-brigadier-command-library.md §4 Execution (§4.1 execute, §4.2 flattening, §4.3 running the
*> chain, §4.4 the result consumer) on the tree of §9 (examples 1 to 31 of §9.1 as far as they concern execution). The command of a
*> node returns its own id (foo 1, n 2, bar 3, say msg 4, tp y 5, name s 6, d v 7, f v 8, b flag 9); run and each redirect to the
*> root (each is a fork). The modifier of each returns the sources of a case: 1 three sources (rows 10, 11, 12), 2 none, 3 raises,
*> 5 a thousand. The result reads "r=<result> f=<failed>" then " key=<exception key>@<cursor>" and " log=" the rows the runs saw
*> (R<row>), the runs of the modifier (M<row>) and the consumer calls (S<result> success, F failure).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15A-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 COPY BRRUN.
 01 TEST-STATE EXTERNAL.
    05 TS-LOG               PIC X(240).
    05 TS-POS               BINARY-LONG.
    05 TS-FAIL-ROW          BINARY-LONG.
    05 TS-FAIL-ALL          BINARY-LONG.
 01 WS-RUNNER              USAGE PROGRAM-POINTER.
 01 WS-MODIFIER            USAGE PROGRAM-POINTER.
 01 WS-CONSUMER            USAGE PROGRAM-POINTER.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FOO                 BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-EACH                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-LINE                PIC X(1024).
 01 WS-RUN-LINE            PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FAILED              BINARY-LONG.
 01 WS-TEXT                PIC X(400).
 01 WS-POS                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     SET WS-RUNNER TO ENTRY "TEST-RUNNER"
     SET WS-MODIFIER TO ENTRY "TEST-MODIFIER"
     SET WS-CONSUMER TO ENTRY "TEST-CONSUMER"
     PERFORM BUILD-TREE
     MOVE "foo$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E1 a command without modifiers runs once on the source and returns its result"
         TO TL-CASE
     MOVE "r=1 f=0 log=R99 S1" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "foo 5$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E2 the command of the last node runs (foo 5)" TO TL-CASE
     MOVE "r=2 f=0 log=R99 S2" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "foo 11$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E3 the one recorded exception is thrown and no command runs (foo 11)" TO TL-CASE
     MOVE "r=0 f=1 key=argument.integer.big@4 log=" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "foo 5x$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E4 the separator exception is thrown (foo 5x)" TO TL-CASE
     MOVE "r=0 f=1 key=command.expected.separator@5 log=" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "foo 5 $" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E5 unread input after a complete branch is Incorrect argument (foo 5 plus a space)"
         TO TL-CASE
     MOVE "r=0 f=1 key=command.unknown.argument@5 log=" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "foo 5 6$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E6 trailing arguments are Incorrect argument at the reader (foo 5 6)" TO TL-CASE
     MOVE "r=0 f=1 key=command.unknown.argument@6 log=" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "tp$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E7 a line that cannot be flattened calls the consumer once with failure and throws Unknown command (tp)"
         TO TL-CASE
     MOVE "r=0 f=1 key=command.unknown.command@2 log=F" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "bogus$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E8 nothing parsed is Unknown command at 0 and the consumer is not called (bogus)"
         TO TL-CASE
     MOVE "r=0 f=1 key=command.unknown.command@0 log=" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "tp 1 -2$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E9 the executable context is the last node (tp 1 -2)" TO TL-CASE
     MOVE "r=5 f=0 log=R99 S5" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "run foo 5$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E10 a redirect without modifier passes the source through (run foo 5)" TO TL-CASE
     MOVE "r=2 f=0 log=R99 S2" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "run$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E11 a redirect with no more text is Unknown command at 3 (run)" TO TL-CASE
     MOVE "r=0 f=1 key=command.unknown.command@3 log=F" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "run $" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E12 a redirect followed by a space that parses nothing is Unknown command at 4 (run plus a space)"
         TO TL-CASE
     MOVE "r=0 f=1 key=command.unknown.command@4 log=F" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE "each foo 5$" TO WS-LINE
     MOVE 1 TO BR-N-MODIFIER(WS-EACH)
     MOVE "acceptance US13 15a§4 Execution E13 a fork runs the command once per source and returns the number of successful runs (each foo 5)"
         TO TL-CASE
     MOVE "r=3 f=0 log=M99 R10 S2 R11 S2 R12 S2" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 2 TO BR-N-MODIFIER(WS-EACH)
     MOVE "acceptance US13 15a§4 Execution E14 a modifier that returns no sources ends the chain with 0 and the command never runs"
         TO TL-CASE
     MOVE "r=0 f=0 log=M99" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 3 TO BR-N-MODIFIER(WS-EACH)
     MOVE "acceptance US13 15a§4 Execution E15 a modifier that throws in a forked chain is a consumer failure and 0, not an error"
         TO TL-CASE
     MOVE "r=0 f=0 log=M99 F" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 1 TO BR-N-MODIFIER(WS-EACH)
     MOVE 11 TO TS-FAIL-ROW
     MOVE "acceptance US13 15a§4 Execution E16 a failing run of a forked chain counts nothing and the others still run"
         TO TL-CASE
     MOVE "r=2 f=0 log=M99 R10 S2 R11 F R12 S2" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 0 TO TS-FAIL-ROW
     MOVE 1 TO BR-N-MODIFIER(WS-RUN)
     MOVE "run foo 5$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E17 without a fork the result is the sum of the results of the runs (run foo 5, three sources)"
         TO TL-CASE
     MOVE "r=6 f=0 log=M99 R10 S2 R11 S2 R12 S2" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 11 TO TS-FAIL-ROW
     MOVE "acceptance US13 15a§4 Execution E18 a failing run of an unforked chain is rethrown and stops the chain"
         TO TL-CASE
     MOVE "r=0 f=2 key=commands.test.failed@-1 log=M99 R10 S2 R11 F" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 0 TO TS-FAIL-ROW
     MOVE 3 TO BR-N-MODIFIER(WS-RUN)
     MOVE "acceptance US13 15a§4 Execution E19 a modifier that throws in an unforked chain is rethrown" TO TL-CASE
     MOVE "r=0 f=2 key=commands.test.failed@-1 log=M99 F" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 5 TO BR-N-MODIFIER(WS-RUN)
     MOVE "run run foo 5$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E20 more sources than the fork limit is Maximum number of contexts (1024) reached"
         TO TL-CASE
     MOVE "r=0 f=2 key=command.forkLimit@-1 log=M99" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 5 TO BR-N-MODIFIER(WS-EACH)
     MOVE 0 TO BR-N-MODIFIER(WS-RUN)
     MOVE "each each foo 5$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E21 in a forked chain the fork limit ends the chain without an error"
         TO TL-CASE
     MOVE "r=0 f=0 log=M99" TO TL-EXPECTED
     PERFORM RUN-CASE
     MOVE 0 TO BR-N-MODIFIER(WS-EACH)
     MOVE "each foo 5$" TO WS-LINE
     MOVE "acceptance US13 15a§4 Execution E22 a fork with no modifier is the identity and still counts runs"
         TO TL-CASE
     MOVE "r=1 f=0 log=R99 S2" TO TL-EXPECTED
     PERFORM RUN-CASE
     GOBACK.

*> The line WS-LINE is run with a source of row 99; the result text is compared with TL-EXPECTED.
 RUN-CASE.
     MOVE SPACES TO TS-LOG
     MOVE 1 TO TS-POS
     MOVE 99 TO BS-ROW
     MOVE WS-LINE TO WS-RUN-LINE
     MOVE 0 TO WS-LENGTH
     INSPECT WS-RUN-LINE TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL "$"
     MOVE SPACE TO WS-RUN-LINE(WS-LENGTH + 1:1)
     CALL "BR-LINE" USING WS-LEVEL WS-RUN-LINE WS-LENGTH WS-RUNNER WS-MODIFIER WS-CONSUMER
         WS-RESULT WS-FAILED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     MOVE WS-RESULT TO WS-EDIT
     STRING "r=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE WS-FAILED TO WS-EDIT
     STRING " f=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF WS-FAILED > 0
         MOVE BR-E-CURSOR TO WS-EDIT
         STRING " key=" FUNCTION TRIM(BR-E-KEY) "@" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
             INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     STRING " log=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF TS-POS > 1
         STRING FUNCTION TRIM(TS-LOG) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ADD-NODE.
*> parent in WS-NODE, WS-KIND, WS-NAME (trimmed), WS-TYPE: the child id in WS-CHILD.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED.

 LITERAL-NODE.
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE
     PERFORM ADD-NODE.

 ARGUMENT-NODE.
     MOVE BR-ARGUMENT TO WS-KIND
     PERFORM ADD-NODE.

*> The tree of 15a §9 (all requirements true); the command id of a node is the one named in the header.
 BUILD-TREE.
     CALL "BR-TREE-RESET"
     MOVE 1 TO WS-NODE
     MOVE "foo" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-FOO
     MOVE 1 TO BR-N-COMMAND(WS-FOO)
     MOVE WS-FOO TO WS-NODE
     MOVE "n" TO WS-NAME
     MOVE BR-P-INTEGER TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 2 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO BR-N-HAS-MAX(WS-CHILD)
     MOVE 1 TO BR-N-HAS-MIN(WS-CHILD)
     MOVE 1 TO BR-N-IMIN(WS-CHILD)
     MOVE 10 TO BR-N-IMAX(WS-CHILD)
     MOVE "bar" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE 3 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "say" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "msg" TO WS-NAME
     MOVE BR-P-STRING TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 4 TO BR-N-COMMAND(WS-CHILD)
     MOVE BR-S-GREEDY TO BR-N-STRING-KIND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "tp" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "x" TO WS-NAME
     MOVE BR-P-INTEGER TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "y" TO WS-NAME
     PERFORM ARGUMENT-NODE
     MOVE 5 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "run" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-RUN
     MOVE 1 TO BR-N-REDIRECT(WS-RUN)
     MOVE "each" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-EACH
     MOVE 1 TO BR-N-REDIRECT(WS-EACH)
     MOVE 1 TO BR-N-FORK(WS-EACH).

 END PROGRAM TEST-CMD-15A-4.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RUNNER.
*> The command of the tree: logs the row of its source, returns the id of its node, fails for the row TS-FAIL-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRRUN.
 01 TEST-STATE EXTERNAL.
    05 TS-LOG               PIC X(240).
    05 TS-POS               BINARY-LONG.
    05 TS-FAIL-ROW          BINARY-LONG.
    05 TS-FAIL-ALL          BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-KEY                 PIC X(48) VALUE "commands.test.failed".
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-A                   PIC X(64).
 01 WS-B                   PIC X(64).
 01 WS-NO-1                BINARY-LONG VALUE 0.
 01 WS-NO-2                BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-CTX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CTX.
     MOVE BS-ROW TO WS-EDIT
     STRING " R" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TS-LOG WITH POINTER TS-POS
     MOVE BR-R-COMMAND TO BR-R-RESULT
     IF BS-ROW = TS-FAIL-ROW
         MOVE 1 TO BR-R-FAILED
         MOVE SPACES TO WS-A
         CALL "BR-RAISE" USING WS-KEY WS-NO WS-A WS-NO-1 WS-B WS-NO-2 WS-RC
     END-IF
     GOBACK.
 END PROGRAM TEST-RUNNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MODIFIER.
*> The modifier of the tree: id 1 returns the rows 10 to 12, 2 none, 3 raises, 5 a thousand (rows 200 up).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRRUN.
 01 TEST-STATE EXTERNAL.
    05 TS-LOG               PIC X(240).
    05 TS-POS               BINARY-LONG.
    05 TS-FAIL-ROW          BINARY-LONG.
    05 TS-FAIL-ALL          BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-KEY                 PIC X(48) VALUE "commands.test.failed".
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-A                   PIC X(64).
 01 WS-B                   PIC X(64).
 01 WS-NO-1                BINARY-LONG VALUE 0.
 01 WS-NO-2                BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CTX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CTX.
     IF BS-ROW < 200
         MOVE BS-ROW TO WS-EDIT
         STRING " M" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TS-LOG WITH POINTER TS-POS
     END-IF
     EVALUATE BR-R-MODIFIER
         WHEN 1
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE BS-ROW = 9 + WS-I
                 MOVE BR-SRC TO BM-ENTRY(WS-I)
             END-PERFORM
             MOVE 3 TO BM-COUNT
         WHEN 3
             MOVE 1 TO BR-R-FAILED
             MOVE SPACES TO WS-A
             CALL "BR-RAISE" USING WS-KEY WS-NO WS-A WS-NO-1 WS-B WS-NO-2 WS-RC
         WHEN 5
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000
                 COMPUTE BS-ROW = 199 + WS-I
                 MOVE BR-SRC TO BM-ENTRY(WS-I)
             END-PERFORM
             MOVE 1000 TO BM-COUNT
         WHEN OTHER
             MOVE 0 TO BM-COUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM TEST-MODIFIER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONSUMER.
*> Logs S<result> for a successful run and F for a failure.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 TEST-STATE EXTERNAL.
    05 TS-LOG               PIC X(240).
    05 TS-POS               BINARY-LONG.
    05 TS-FAIL-ROW          BINARY-LONG.
    05 TS-FAIL-ALL          BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 LINKAGE SECTION.
 01 L-CTX                  BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CTX L-SUCCESS L-RESULT.
     IF L-SUCCESS = 1
         MOVE L-RESULT TO WS-EDIT
         STRING " S" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TS-LOG WITH POINTER TS-POS
     ELSE
         STRING " F" DELIMITED BY SIZE INTO TS-LOG WITH POINTER TS-POS
     END-IF
     GOBACK.
 END PROGRAM TEST-CONSUMER.
