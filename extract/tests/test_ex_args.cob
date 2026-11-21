*> Implementation test for EX-ARGS (22 §7.1; T0293): the options of the command line, the defaults, and the
*> usage error (CCX-001, exit 1) for an unknown option, a missing value or an empty argument. The arguments
*> arrive as one text, separated by LF (EX-MAIN joins the real arguments that way, so a path may hold spaces).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EX-ARGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 01 WS-TEXT                PIC X(4000).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-LONG                PIC X(1200).
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LENGTH
     PERFORM RUN-ARGS
     MOVE "args: no arguments gives status 0" TO TL-CASE
     PERFORM ASSERT-STATUS-OK
     MOVE "args: game directory defaults to the working directory" TO TL-CASE
     MOVE "." TO TL-EXPECTED
     MOVE EXO-GAME TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "args: generated directory defaults to <game>/generated" TO TL-CASE
     MOVE "./generated" TO TL-EXPECTED
     MOVE EXO-GEN TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "args: no jar given" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EXO-JAR-GIVEN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "args: flags default to 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EXO-FORCE + EXO-VERIFY + EXO-DRY + EXO-QUIET
     PERFORM ASSERT-NUMBER

     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POINTER
     STRING "--jar" X"0A" "my jar.jar" X"0A" "--game-dir" X"0A" "game" X"0A" "--generated-dir" X"0A" "out dir" X"0A"
         "--force" X"0A" "--verify" X"0A" "--dry-run" X"0A" "--quiet" X"0A"
         DELIMITED BY SIZE INTO WS-TEXT POINTER WS-POINTER
     COMPUTE WS-LENGTH = WS-POINTER - 1
     PERFORM RUN-ARGS
     MOVE "args: every option, trailing LF: status 0" TO TL-CASE
     PERFORM ASSERT-STATUS-OK
     MOVE "args: --jar value keeps its space" TO TL-CASE
     MOVE "my jar.jar" TO TL-EXPECTED
     MOVE EXO-JAR TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "args: --jar given" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EXO-JAR-GIVEN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "args: --game-dir" TO TL-CASE
     MOVE "game" TO TL-EXPECTED
     MOVE EXO-GAME TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "args: --generated-dir wins over the default" TO TL-CASE
     MOVE "out dir" TO TL-EXPECTED
     MOVE EXO-GEN TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "args: --force --verify --dry-run --quiet all set" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EXO-FORCE + EXO-VERIFY + EXO-DRY + EXO-QUIET
     PERFORM ASSERT-NUMBER

     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POINTER
     STRING "--game-dir" X"0A" "g2" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-POINTER
     COMPUTE WS-LENGTH = WS-POINTER - 1
     PERFORM RUN-ARGS
     MOVE "args: generated directory follows --game-dir" TO TL-CASE
     MOVE "g2/generated" TO TL-EXPECTED
     MOVE EXO-GEN TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "args: a second run starts from the defaults (no jar, flags 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EXO-JAR-GIVEN + EXO-FORCE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-NUMBER

     MOVE SPACES TO WS-TEXT
     MOVE "--bogus" TO WS-TEXT
     MOVE 7 TO WS-LENGTH
     PERFORM RUN-ARGS
     MOVE "args: unknown option gives status 1" TO TL-CASE
     PERFORM ASSERT-STATUS-USAGE
     MOVE "args: CCX-001 text" TO TL-CASE
     MOVE "CCX-001 usage: cobolcraft-extract [--jar <file>] [--game-dir <dir>] [--generated-dir <dir>] [--force] [--verify] [--dry-run] [--quiet]"
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "args: CCX-001 exit status is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EXR-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

     MOVE SPACES TO WS-TEXT
     MOVE "--force" TO WS-TEXT
     MOVE 1 TO WS-POINTER
     STRING "--force" X"0A" "--jar" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-POINTER
     COMPUTE WS-LENGTH = WS-POINTER - 1
     PERFORM RUN-ARGS
     MOVE "args: --jar without a value gives status 1" TO TL-CASE
     PERFORM ASSERT-STATUS-USAGE

     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POINTER
     STRING "--game-dir" X"0A" X"0A" "--force" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-POINTER
     COMPUTE WS-LENGTH = WS-POINTER - 1
     PERFORM RUN-ARGS
     MOVE "args: an empty value gives status 1" TO TL-CASE
     PERFORM ASSERT-STATUS-USAGE

     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POINTER
     STRING "--force" X"0A" X"0A" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-POINTER
     COMPUTE WS-LENGTH = WS-POINTER - 1
     PERFORM RUN-ARGS
     MOVE "args: an empty argument gives status 1" TO TL-CASE
     PERFORM ASSERT-STATUS-USAGE

     MOVE ALL "x" TO WS-LONG
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POINTER
     STRING "--jar" X"0A" WS-LONG DELIMITED BY SIZE INTO WS-TEXT POINTER WS-POINTER
     COMPUTE WS-LENGTH = WS-POINTER - 1
     PERFORM RUN-ARGS
     MOVE "args: a path over 1000 bytes gives status 1" TO TL-CASE
     PERFORM ASSERT-STATUS-USAGE
     STOP RUN.

 RUN-ARGS.
     MOVE -1 TO WS-STATUS
     CALL "EX-ARGS" USING WS-TEXT WS-LENGTH WS-STATUS.

 ASSERT-STATUS-OK.
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 ASSERT-STATUS-USAGE.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-EX-ARGS.
