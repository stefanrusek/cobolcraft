*> Implementation test for EX-RUN, EX-MAIN, EX-TOTALS, EX-PREPARE and EX-SWAP (22 §6.3, §7.4, §7.5; T0307): usage and
*> reject exit statuses over the fixtures, then over the operator's real jar (tmp/minecraft-26.3-client.jar,
*> git-ignored; the test fails when it is absent): --dry-run writes nothing, a run builds the packs and swaps
*> <generated>.partial in, a second run does nothing (CCX-100, a planted file survives), --force rebuilds with the
*> same index bytes, --verify passes, a directory the tool did not make is never replaced (CCX-051). EX-MAIN is run
*> by this program itself with real arguments (a child process), for its exit status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EX-MAIN.
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
 01 WS-OTHER               PIC X(1100).
 01 WS-PATH                PIC X(1100).
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 01 WS-EXPECT-LINE         PIC X(1024).
 01 WS-TOTALS-STATUS       BINARY-LONG.
 01 WS-EXPECTED-EXIT       BINARY-LONG.
 01 WS-ROW-NUMBER          BINARY-LONG.
 01 WS-LONG-A              PIC X(200).
 01 WS-LONG-B              PIC X(200).
 01 WS-LONG-C              PIC X(200).
 01 WS-LONG-D              PIC X(200).
 PROCEDURE DIVISION.
     ACCEPT WS-COUNT FROM ARGUMENT-NUMBER
     IF WS-COUNT > 0
*>       The child: the real program entry with the real arguments.
         CALL "EX-MAIN"
     END-IF
     MOVE "main" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-ROOT
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) " && mkdir -p " FUNCTION TRIM(WS-ROOT) "/foreign "
         FUNCTION TRIM(WS-ROOT) "/empty-game && touch " FUNCTION TRIM(WS-ROOT) "/foreign/mine.txt"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "minecraft-26.3-client.jar" TO WS-NAME
     CALL "EXT-INPUT-PATH" USING WS-NAME WS-JAR

*>   Usage and reject exits (22 §7.4).
     MOVE "--bogus" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-EXIT
     PERFORM RUN-CASE
     MOVE "main: an unknown option exits 1 (CCX-001)" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE SPACES TO WS-LINE
     STRING "--game-dir|" FUNCTION TRIM(WS-ROOT) "/empty-game" DELIMITED BY SIZE INTO WS-LINE
     MOVE 2 TO WS-EXPECTED-EXIT
     PERFORM RUN-CASE
     MOVE "main: no jar anywhere exits 2 (CCX-010)" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-ROOT) "/missing.jar" DELIMITED BY SIZE INTO WS-LINE
     PERFORM RUN-CASE
     MOVE "main: --jar of nothing exits 2 (CCX-011)" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE SPACES TO WS-GEN
     STRING FUNCTION TRIM(WS-ROOT) "/rejected" DELIMITED BY SIZE INTO WS-GEN
     MOVE SPACES TO WS-LINE
     STRING "--jar|contract/fixtures/extract/c-wrong-id.zip|--generated-dir|" FUNCTION TRIM(WS-GEN)
         DELIMITED BY SIZE INTO WS-LINE
     MOVE 3 TO WS-EXPECTED-EXIT
     PERFORM RUN-CASE
     MOVE "main: an unsupported jar exits 3 (CCX-030)" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE SPACES TO WS-LINE
     STRING "--jar|contract/fixtures/extract/c-right-id-wrong-digest.zip|--generated-dir|" FUNCTION TRIM(WS-GEN)
         DELIMITED BY SIZE INTO WS-LINE
     PERFORM RUN-CASE
     MOVE "main: another build of 26.3 exits 3 (CCX-031)" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE "main: a rejected jar writes nothing (no generated, no partial)" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "ls " FUNCTION TRIM(WS-GEN) " " FUNCTION TRIM(WS-GEN) ".partial 2>/dev/null | wc -l | tr -d ' ' | grep -q '^0$'"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-LINE
     STRING "--jar|contract/fixtures/extract/c-zip64.zip|--generated-dir|" FUNCTION TRIM(WS-GEN)
         DELIMITED BY SIZE INTO WS-LINE
     MOVE 4 TO WS-EXPECTED-EXIT
     PERFORM RUN-CASE
     MOVE "main: an archive this tool cannot read exits 4 (CCX-021)" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE SPACES TO WS-LINE
     STRING "--verify|--generated-dir|" FUNCTION TRIM(WS-ROOT) "/nothing" DELIMITED BY SIZE INTO WS-LINE
     MOVE 6 TO WS-EXPECTED-EXIT
     PERFORM RUN-CASE
     MOVE "main: --verify of nothing exits 6 (CCX-060), without a jar" TO TL-CASE
     PERFORM ASSERT-EXIT

*>   The totals check (22 §7.3 step 8).
     MOVE 11605 TO EXR-RESOURCE
     MOVE 9779 TO EXR-DATA
     MOVE 106 TO EXR-FEATURE
     MOVE 21490 TO EXR-TOTAL
     CALL "EX-TOTALS" USING WS-TOTALS-STATUS
     MOVE "totals: the counts of the table row pass" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TOTALS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 11604 TO EXR-RESOURCE
     CALL "EX-TOTALS" USING WS-TOTALS-STATUS
     MOVE "totals: one file fewer gives CCX-045" TO TL-CASE
     MOVE 45 TO TL-EXPECTED-N
     MOVE WS-TOTALS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "totals: CCX-045 text" TO TL-CASE
     MOVE "CCX-045 version.json or the file counts do not match the table for this jar: file counts 11604 resource, 9779 data and 106 feature-pack files, expected 11605, 9779 and 106."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   The real jar.
     MOVE SPACES TO WS-GEN
     STRING FUNCTION TRIM(WS-ROOT) "/generated" DELIMITED BY SIZE INTO WS-GEN
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(WS-GEN) "|--dry-run|--quiet"
         DELIMITED BY SIZE INTO WS-LINE
     MOVE 0 TO WS-EXPECTED-EXIT
     PERFORM RUN-CASE
     MOVE "main: --dry-run on the real jar exits 0 (input present)" TO TL-CASE
     PERFORM ASSERT-EXIT
     IF WS-EXIT NOT = 0
         DISPLAY "the real jar is absent or not accepted: " FUNCTION TRIM(WS-JAR)
         STOP RUN
     END-IF
     MOVE "main: --dry-run prints the counts (CCX-103)" TO TL-CASE
     MOVE "CCX-103 Dry run: 11605 resource files, 9779 data files and 106 feature-pack files would be written; 11391 jar entries skipped. Nothing was written."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "main: --dry-run creates no directory" TO TL-CASE
     PERFORM ASSERT-NOTHING-WRITTEN

     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(WS-GEN) "|--quiet"
         DELIMITED BY SIZE INTO WS-LINE
     PERFORM RUN-CASE
     MOVE "main: a run on the real jar exits 0" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE "main: CCX-101 final line, 21490 files, 16041701 bytes, 11391 skipped" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-101 Wrote 11605 resource files, 9779 data files and 106 feature-pack files (16041701 bytes) to "
         FUNCTION TRIM(WS-GEN) ". Skipped 11391 jar entries (code, signatures, markers)."
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "CONTENT-PACKS-CHECK" USING WS-GEN WS-STATUS WS-REASON
     MOVE "main: CONTENT-PACKS-CHECK returns ok on the output" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "main: no .partial directory is left" TO TL-CASE
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-GEN) ".partial" DELIMITED BY SIZE INTO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE FM-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   A second run does nothing: a planted file survives (22 §6.3).
     MOVE SPACES TO WS-COMMAND
     STRING "touch " FUNCTION TRIM(WS-GEN) "/planted.txt && cp " FUNCTION TRIM(WS-GEN) "/index.txt "
         FUNCTION TRIM(WS-ROOT) "/index-1.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     PERFORM RUN-CASE
     MOVE "main: a second run exits 0" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE "main: a second run says CCX-100" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-100 Generated packs are up to date (Minecraft 26.3, SHA-256 "
         "4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d). Nothing to do. Use --force to rebuild."
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "main: a second run rebuilds nothing (the planted file is still there)" TO TL-CASE
     PERFORM ASSERT-PLANTED

*>   --dry-run --force walks and writes nothing.
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(WS-GEN) "|--force|--dry-run|--quiet"
         DELIMITED BY SIZE INTO WS-LINE
     PERFORM RUN-CASE
     MOVE "main: --dry-run --force exits 0" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE "main: --dry-run --force leaves the generated directory alone" TO TL-CASE
     PERFORM ASSERT-PLANTED

*>   --force rebuilds from nothing: the planted file goes, the index has the same bytes.
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(WS-GEN) "|--force"
         DELIMITED BY SIZE INTO WS-LINE
     PERFORM RUN-CASE
     MOVE "main: --force (with progress lines) exits 0" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE "main: --force rebuilds from nothing (the planted file is gone)" TO TL-CASE
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-GEN) "/planted.txt" DELIMITED BY SIZE INTO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE FM-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "main: --force gives the same index bytes in the same order (T10)" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "cmp -s " FUNCTION TRIM(WS-ROOT) "/index-1.txt " FUNCTION TRIM(WS-GEN) "/index.txt"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   --verify needs no jar.
     MOVE SPACES TO WS-LINE
     STRING "--verify|--generated-dir|" FUNCTION TRIM(WS-GEN) DELIMITED BY SIZE INTO WS-LINE
     PERFORM RUN-CASE
     MOVE "main: --verify of the output exits 0" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE "main: --verify says CCX-102 with 21490 files" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-102 Verified 21490 files in " FUNCTION TRIM(WS-GEN) "." DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   A directory the tool did not make is never replaced (T12).
     MOVE SPACES TO WS-OTHER
     STRING FUNCTION TRIM(WS-ROOT) "/foreign" DELIMITED BY SIZE INTO WS-OTHER
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(WS-OTHER) "|--force|--quiet"
         DELIMITED BY SIZE INTO WS-LINE
     MOVE 5 TO WS-EXPECTED-EXIT
     PERFORM RUN-CASE
     MOVE "main: a foreign non-empty directory exits 5 (CCX-051)" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE "main: the foreign directory is untouched and no partial exists" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "test -f " FUNCTION TRIM(WS-OTHER) "/mine.txt && test ! -e " FUNCTION TRIM(WS-OTHER) ".partial"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   A foreign <generated>.partial is refused (CCX-051) and left alone.
     MOVE SPACES TO WS-OTHER
     STRING FUNCTION TRIM(WS-ROOT) "/pf-gen" DELIMITED BY SIZE INTO WS-OTHER
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p " FUNCTION TRIM(WS-OTHER) ".partial && touch " FUNCTION TRIM(WS-OTHER) ".partial/mine.txt"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(WS-OTHER) "|--quiet"
         DELIMITED BY SIZE INTO WS-LINE
     MOVE 5 TO WS-EXPECTED-EXIT
     PERFORM RUN-CASE
     MOVE "main: a foreign .partial exits 5 (CCX-051)" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE "main: the foreign .partial is not removed and no generated directory appears" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "test -f " FUNCTION TRIM(WS-OTHER) ".partial/mine.txt && test ! -e " FUNCTION TRIM(WS-OTHER)
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   A write that fails in the walk (a path past the operating system's limit): CCX-050, exit 5, the partial
*>   directory is removed and no generated directory appears.
     MOVE ALL "a" TO WS-LONG-A
     MOVE ALL "b" TO WS-LONG-B
     MOVE ALL "c" TO WS-LONG-C
     MOVE ALL "d" TO WS-LONG-D
     MOVE SPACES TO WS-OTHER
     STRING FUNCTION TRIM(WS-ROOT) "/" WS-LONG-A "/" WS-LONG-B "/" WS-LONG-C "/" WS-LONG-D "/gen"
         DELIMITED BY SIZE INTO WS-OTHER
     MOVE SPACES TO WS-LINE
     STRING "--jar|" FUNCTION TRIM(WS-JAR) "|--generated-dir|" FUNCTION TRIM(WS-OTHER) "|--quiet"
         DELIMITED BY SIZE INTO WS-LINE
     MOVE 5 TO WS-EXPECTED-EXIT
     PERFORM RUN-CASE
     MOVE "main: a path too long to write exits 5 (CCX-050)" TO TL-CASE
     PERFORM ASSERT-EXIT
     MOVE "main: CCX-050 says Cannot write" TO TL-CASE
     MOVE "CCX-050 Cannot write" TO TL-EXPECTED
     MOVE EXR-LINE(1:20) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "main: the failed run removed its partial directory and made no generated directory" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "test ! -e " FUNCTION TRIM(WS-OTHER) ".partial && test ! -e " FUNCTION TRIM(WS-OTHER) DELIMITED BY SIZE
         INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) "/" WS-LONG-A DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL

*>   EX-PREPARE: a leftover partial that holds the marker is removed and made again; a foreign one is refused.
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-ROOT) "/prep" DELIMITED BY SIZE INTO WS-PATH
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p " FUNCTION TRIM(WS-PATH) " && touch " FUNCTION TRIM(WS-PATH) "/.cobolcraft-generated "
         FUNCTION TRIM(WS-PATH) "/junk.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 1 TO WS-ROW-NUMBER
     CALL "CONTENT-ACCEPTED-JAR" USING WS-ROW-NUMBER EXC-ROW WS-TOTALS-STATUS
     CALL "EX-PREPARE" USING WS-PATH WS-STATUS
     MOVE "prepare: a leftover partial with the marker is rebuilt" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "prepare: the old content is gone, the new pack.mcmeta is there" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "test ! -e " FUNCTION TRIM(WS-PATH) "/junk.txt && test -f " FUNCTION TRIM(WS-PATH)
         "/vanilla-data/pack.mcmeta && test -f " FUNCTION TRIM(WS-PATH) "/.cobolcraft-generated"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-PATH) " && mkdir -p " FUNCTION TRIM(WS-PATH) " && touch " FUNCTION TRIM(WS-PATH)
         "/junk.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "EX-PREPARE" USING WS-PATH WS-STATUS
     MOVE "prepare: a leftover partial without the marker is refused (51)" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   A tree that cannot be removed (an unreadable folder in it) is CCX-050.
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-PATH) " && mkdir -p " FUNCTION TRIM(WS-PATH) "/locked && touch "
         FUNCTION TRIM(WS-PATH) "/.cobolcraft-generated && chmod 000 " FUNCTION TRIM(WS-PATH) "/locked"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "EX-PREPARE" USING WS-PATH WS-STATUS
     MOVE "prepare: a partial that cannot be removed gives CCX-050" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-COMMAND
     STRING "chmod 755 " FUNCTION TRIM(WS-PATH) "/locked && rm -rf " FUNCTION TRIM(WS-PATH)
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL

*>   EX-SWAP: the new directory replaces one with the marker; a foreign one is refused and the partial removed.
     MOVE SPACES TO WS-PATH WS-GEN
     STRING FUNCTION TRIM(WS-ROOT) "/swap-new" DELIMITED BY SIZE INTO WS-PATH
     STRING FUNCTION TRIM(WS-ROOT) "/swap-old" DELIMITED BY SIZE INTO WS-GEN
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p " FUNCTION TRIM(WS-PATH) " " FUNCTION TRIM(WS-GEN) " && touch " FUNCTION TRIM(WS-PATH)
         "/new.txt " FUNCTION TRIM(WS-GEN) "/old.txt " FUNCTION TRIM(WS-GEN) "/.cobolcraft-generated"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "EX-SWAP" USING WS-PATH WS-GEN WS-STATUS
     MOVE "swap: the new directory replaces one with the marker" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "swap: new.txt is in the generated directory, old.txt and the partial are gone" TO TL-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "test -f " FUNCTION TRIM(WS-GEN) "/new.txt && test ! -e " FUNCTION TRIM(WS-GEN) "/old.txt && test ! -e "
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Foreign target: refused, the partial removed.
     MOVE SPACES TO WS-PATH WS-GEN
     STRING FUNCTION TRIM(WS-ROOT) "/swap-new2" DELIMITED BY SIZE INTO WS-PATH
     STRING FUNCTION TRIM(WS-ROOT) "/foreign" DELIMITED BY SIZE INTO WS-GEN
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p " FUNCTION TRIM(WS-PATH) " && touch " FUNCTION TRIM(WS-PATH) "/new.txt" DELIMITED BY SIZE
         INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "EX-SWAP" USING WS-PATH WS-GEN WS-STATUS
     MOVE "swap: a foreign target is refused (51) and the partial is removed" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-COMMAND
     STRING "test -f " FUNCTION TRIM(WS-GEN) "/mine.txt && test ! -e " FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE
         INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   A target that cannot be removed (an unreadable folder in it): CCX-050.
     MOVE SPACES TO WS-PATH WS-GEN
     STRING FUNCTION TRIM(WS-ROOT) "/swap-new3" DELIMITED BY SIZE INTO WS-PATH
     STRING FUNCTION TRIM(WS-ROOT) "/swap-locked" DELIMITED BY SIZE INTO WS-GEN
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p " FUNCTION TRIM(WS-PATH) " " FUNCTION TRIM(WS-GEN) "/locked && touch " FUNCTION TRIM(WS-GEN)
         "/.cobolcraft-generated && chmod 000 " FUNCTION TRIM(WS-GEN) "/locked" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "EX-SWAP" USING WS-PATH WS-GEN WS-STATUS
     MOVE "swap: a target that cannot be removed gives CCX-050" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-COMMAND
     STRING "chmod 755 " FUNCTION TRIM(WS-GEN) "/locked && rm -rf " FUNCTION TRIM(WS-GEN) DELIMITED BY SIZE
         INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
*>   A rename that fails: the generated directory's parent is not there.
     MOVE SPACES TO WS-PATH WS-GEN
     STRING FUNCTION TRIM(WS-ROOT) "/swap-new4" DELIMITED BY SIZE INTO WS-PATH
     STRING FUNCTION TRIM(WS-ROOT) "/no-parent/generated" DELIMITED BY SIZE INTO WS-GEN
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p " FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     CALL "EX-SWAP" USING WS-PATH WS-GEN WS-STATUS
     MOVE "swap: a rename that fails gives CCX-050" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   EX-MAIN itself, as a child with real arguments: its exit status is the one of EX-RUN.
     MOVE SPACES TO WS-COMMAND
     STRING FUNCTION TRIM(FUNCTION MODULE-PATH) " --bogus 2>/dev/null" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "main: EX-MAIN with an unknown option exits 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-COMMAND
     STRING FUNCTION TRIM(FUNCTION MODULE-PATH) " --verify --generated-dir " FUNCTION TRIM(WS-ROOT) "/generated"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "main: EX-MAIN --verify of the output exits 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-COMMAND
     STRING FUNCTION TRIM(FUNCTION MODULE-PATH) " --generated-dir ''" " 2>/dev/null" DELIMITED BY SIZE
         INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "main: EX-MAIN with an empty argument exits 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Arguments that do not fit the 4000 bytes of the joined text are a usage error too.
     MOVE SPACES TO WS-COMMAND
     STRING FUNCTION TRIM(FUNCTION MODULE-PATH) " --force $(head -c 1090 /dev/zero | tr '\0' x) $(head -c 1090 /dev/zero | tr '\0' x)"
         " $(head -c 1090 /dev/zero | tr '\0' x) $(head -c 1090 /dev/zero | tr '\0' x) 2>/dev/null"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "main: arguments over 4000 bytes in all exit 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 RUN-CASE.
     MOVE -1 TO WS-EXIT
     CALL "EXT-RUN" USING WS-LINE WS-EXIT.

 ASSERT-EXIT.
     MOVE WS-EXPECTED-EXIT TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 ASSERT-NOTHING-WRITTEN.
     MOVE SPACES TO WS-COMMAND
     STRING "test ! -e " FUNCTION TRIM(WS-GEN) " && test ! -e " FUNCTION TRIM(WS-GEN) ".partial"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 ASSERT-PLANTED.
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-GEN) "/planted.txt" DELIMITED BY SIZE INTO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE FM-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-EX-MAIN.

 COPY EXTEST.
