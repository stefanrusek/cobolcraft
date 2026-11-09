*> Acceptance test (US1-extract; FR-001, FR-002; SC-012): after a real run (the operator's jar
*> tmp/minecraft-26.3-client.jar, git-ignored; the test FAILS loudly when it is absent), `git ls-files` lists no jar and no
*> generated file, `git status` shows nothing of the run, and the jar and the default generated folder are ignored.
*> Given the tool ran with its default generated directory (<game directory>/generated), When git is asked what
*> it tracks and what is new, Then no jar, no pack file, no manifest and no index is tracked or untracked.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US1-GIT-CLEAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 01 WS-NAME                PIC X(64).
 01 WS-ROOT                PIC X(1100).
 01 WS-JAR                 PIC X(1100).
 01 WS-LINE                PIC X(4000).
 01 WS-EXIT                BINARY-LONG.
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-NUMBER              BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "git-clean" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-ROOT
     MOVE "minecraft-26.3-client.jar" TO WS-NAME
     CALL "EXT-INPUT-PATH" USING WS-NAME WS-JAR
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--game-dir|" FUNCTION TRIM(WS-ROOT) "|--quiet" DELIMITED BY SIZE
         INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE WS-EXIT
     MOVE "acceptance US1-git Given the jar, When the tool runs with its default directory, Then exit 0 (input present)"
         TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-EXIT NOT = 0
         DISPLAY "the real jar is absent or not accepted: " FUNCTION TRIM(WS-JAR)
         STOP RUN
     END-IF
     MOVE "acceptance US1-git the default generated directory is <game directory>/generated" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "test -f " FUNCTION TRIM(WS-ROOT) "/generated/manifest.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Tracked files: no jar, nothing generated (the hand-made trees below a fixtures/ folder are the only pack-shaped files).
     MOVE "acceptance US1-git git ls-files lists no jar and no generated file" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "git ls-files | grep -v '/fixtures/' | grep -c -E "
         "'[.]jar$|(^|/)generated/|(^|/)[.]cobolcraft-generated$|(^|/)manifest[.]txt$|(^|/)index[.]txt$|"
         "(^|/)vanilla-(resources|data)/|(^|/)featurepacks/'" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-COUNT" USING WS-COMMAND WS-NUMBER
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NUMBER TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Untracked files: the run's output (below build/) and the jar (tmp/) are ignored.
     MOVE "acceptance US1-git git status lists nothing of the run" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "git status --porcelain --untracked-files=all | grep -c -E "
         "'[.]jar$|generated|cobolcraft-generated|manifest[.]txt|index[.]txt|vanilla-|featurepacks'"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-COUNT" USING WS-COMMAND WS-NUMBER
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NUMBER TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US1-git the generated folder and the jar are ignored by git" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "git check-ignore -q generated/manifest.txt && git check-ignore -q tmp/minecraft-26.3-client.jar && "
         "git check-ignore -q " FUNCTION TRIM(WS-ROOT) "/generated/manifest.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US1-GIT-CLEAN.

 COPY EXTEST.
