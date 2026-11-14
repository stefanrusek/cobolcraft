*> Edge-case test (T0310; spec edge case "the jar changes between runs"; 22 §7.5, §12 T11): a run killed before the swap leaves
*> the previous <generated> whole and a <generated>.partial behind; a jar whose SHA-256 is not the accepted one is
*> rejected before anything is written (the leftover partial is not even touched); the next run removes the
*> partial and rebuilds, and <generated> is never half-written (--verify passes at every step). Real jar:
*> tmp/minecraft-26.3-client.jar (git-ignored; the test fails when it is absent). The killed run is this program
*> itself, started with arguments (EX-MAIN) under a one-second alarm.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EX-PARTIAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 COPY CONTENT.
 COPY FORMATS.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LINE                PIC X(4000).
 01 WS-EXIT                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-ROOT                PIC X(1100).
 01 WS-JAR                 PIC X(1100).
 01 WS-GEN                 PIC X(1100).
 01 WS-PATH                PIC X(1100).
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 PROCEDURE DIVISION.
     ACCEPT WS-COUNT FROM ARGUMENT-NUMBER
     IF WS-COUNT > 0
         CALL "EX-MAIN"
     END-IF
     MOVE "partial" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-ROOT
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) " && mkdir -p " FUNCTION TRIM(WS-ROOT) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "minecraft-26.3-client.jar" TO WS-NAME
     CALL "EXT-INPUT-PATH" USING WS-NAME WS-JAR
     MOVE SPACES TO WS-GEN
     STRING FUNCTION TRIM(WS-ROOT) "/generated" DELIMITED BY SIZE INTO WS-GEN

*>   A good first run, and a file planted in it to tell the old directory from a new one.
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(WS-GEN) "|--quiet" DELIMITED BY SIZE
         INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE WS-EXIT
     MOVE "partial: the first run exits 0 (input present)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     IF WS-EXIT NOT = 0
         DISPLAY "the real jar is absent or not accepted: " FUNCTION TRIM(WS-JAR)
         STOP RUN
     END-IF
     MOVE SPACES TO WS-COMMAND
     STRING "touch " FUNCTION TRIM(WS-GEN) "/planted.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL

*>   A run killed one second in (--force: it rebuilds, so it is in the walk): the alarm ends the program.
     MOVE SPACES TO WS-COMMAND
     STRING "perl -MTime::HiRes=alarm -e 'alarm(0.8); exec @ARGV' " FUNCTION TRIM(FUNCTION MODULE-PATH)
         " --jar " FUNCTION TRIM(WS-JAR) " --generated-dir " FUNCTION TRIM(WS-GEN) " --force --quiet 2>/dev/null"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "partial: the killed run ended by the alarm (status 142)" TO TL-CASE
     MOVE 142 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "partial: the previous generated directory is unchanged (the planted file)" TO TL-CASE
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-GEN) "/planted.txt" DELIMITED BY SIZE INTO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE FM-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "partial: the interrupted run left a .partial directory with the marker" TO TL-CASE
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-GEN) ".partial/.cobolcraft-generated" DELIMITED BY SIZE INTO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE FM-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-COMMAND
     STRING "rm " FUNCTION TRIM(WS-GEN) "/planted.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE SPACES TO WS-LINE
     STRING "--verify|--generated-dir|" FUNCTION TRIM(WS-GEN) DELIMITED BY SIZE INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE WS-EXIT
     MOVE "partial: the generated directory was never half-written (--verify exits 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "CONTENT-PACKS-CHECK" USING WS-GEN WS-STATUS WS-REASON
     MOVE "partial: CONTENT-PACKS-CHECK still says ok" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   A jar whose SHA-256 differs: rejected before anything is written; the leftover partial is not touched.
     MOVE SPACES TO WS-COMMAND
     STRING "touch " FUNCTION TRIM(WS-GEN) "/planted.txt " FUNCTION TRIM(WS-GEN) ".partial/leftover.txt"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE SPACES TO WS-LINE
     STRING "--jar|contract/fixtures/extract/c-right-id-wrong-digest.zip|--generated-dir|" FUNCTION TRIM(WS-GEN)
         "|--force|--quiet" DELIMITED BY SIZE INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE WS-EXIT
     MOVE "partial: a jar with another SHA-256 exits 3 (CCX-031)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "partial: the rejection wrote and removed nothing (leftover partial and planted file stay)" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "test -f " FUNCTION TRIM(WS-GEN) ".partial/leftover.txt && test -f " FUNCTION TRIM(WS-GEN)
         "/planted.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   The next run removes the partial and rebuilds.
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(WS-GEN) "|--force|--quiet"
         DELIMITED BY SIZE INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE WS-EXIT
     MOVE "partial: the next run exits 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "partial: the .partial directory is gone and the rebuild replaced the old directory" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "test ! -e " FUNCTION TRIM(WS-GEN) ".partial && test ! -e " FUNCTION TRIM(WS-GEN) "/planted.txt"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-LINE
     STRING "--verify|--generated-dir|" FUNCTION TRIM(WS-GEN) DELIMITED BY SIZE INTO WS-LINE
     CALL "EXT-RUN" USING WS-LINE WS-EXIT
     MOVE "partial: the rebuilt directory verifies" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-EX-PARTIAL.

 COPY EXTEST.
