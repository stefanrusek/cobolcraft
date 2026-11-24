*> Implementation test of formats/src/dirs.cob (DIR-ENSURE, DIR-RENAME, DIR-REMOVE-TREE; 22 §7.2, §7.5):
*> DIR-ENSURE makes a directory and the ones above it (mkdir -p: relative, absolute, with "./", a double
*> or a trailing slash), does nothing for one that exists, answers FM-EXISTS when a file is in the way and
*> FM-UNREADABLE when a folder cannot be written. DIR-RENAME moves a directory in one step (the swap of
*> the partial directory, 22 §7.5): FM-EXISTS when the target is there, FM-NOT-FOUND for no source.
*> DIR-REMOVE-TREE removes a directory with everything below it (a tree walk through cc_fs_list, also for a
*> directory whose names do not fit the first listing buffer), FM-NOT-FOUND for nothing and FM-EXISTS for a
*> file (left alone), FM-UNREADABLE when something cannot be removed. Scratch: build/formats-test/dirs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DIRS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FORMATS.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH2               PIC X(1100).
 01 WS-WORK                PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-AREA                PIC X(8) VALUE "contents".
 01 WS-LENGTH              BINARY-LONG.
 01 WS-HOME                PIC X(900).
 01 WS-COMMAND             PIC X(300).
 01 WS-CHECK-NAME          PIC X(80).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "mkdir -p build/formats-test && chmod -R u+rwx build/formats-test/dirs 2>/dev/null; rm -rf build/formats-test/dirs"
     CALL "SYSTEM" USING "mkdir build/formats-test/dirs"
     MOVE "N" TO TL-MODE

*>   DIR-ENSURE.
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/a/b/c" TO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure a/b/c below an existing folder: FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "build/formats-test/dirs/a" TO WS-CHECK-NAME
     PERFORM ASSERT-IS-DIR
     MOVE "build/formats-test/dirs/a/b" TO WS-CHECK-NAME
     PERFORM ASSERT-IS-DIR
     MOVE "build/formats-test/dirs/a/b/c" TO WS-CHECK-NAME
     PERFORM ASSERT-IS-DIR
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure of a directory that exists: FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/t1/t2/" TO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure with a trailing slash: FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "build/formats-test/dirs/t1/t2" TO WS-CHECK-NAME
     PERFORM ASSERT-IS-DIR
     MOVE LOW-VALUES TO WS-PATH
     MOVE "./build/formats-test//dirs/p/./q" TO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure with ./ and a double slash: FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "build/formats-test/dirs/p/q" TO WS-CHECK-NAME
     PERFORM ASSERT-IS-DIR
     MOVE SPACES TO WS-HOME
     ACCEPT WS-HOME FROM ENVIRONMENT "PWD"
     MOVE LOW-VALUES TO WS-PATH
     STRING FUNCTION TRIM(WS-HOME) "/build/formats-test/dirs/abs/x" DELIMITED BY SIZE INTO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure of an absolute path: FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "build/formats-test/dirs/abs/x" TO WS-CHECK-NAME
     PERFORM ASSERT-IS-DIR
     MOVE SPACES TO WS-PATH
     MOVE "build/formats-test/dirs/spaced" TO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure of a space-padded path: FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/afile" TO WS-PATH
     MOVE 8 TO WS-LENGTH
     CALL "FILE-WRITE" USING WS-PATH WS-AREA WS-LENGTH WS-STATUS
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure of a path that is a file: FM-EXISTS" TO TL-CASE
     MOVE FM-EXISTS TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/afile/below" TO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure below a file: FM-EXISTS" TO TL-CASE
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "mkdir build/formats-test/dirs/ro && chmod 555 build/formats-test/dirs/ro"
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/ro/new" TO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure in a folder that is not writable: FM-UNREADABLE" TO TL-CASE
     MOVE FM-UNREADABLE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "chmod 755 build/formats-test/dirs/ro"
     MOVE ALL "a" TO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE "dirs ensure of a path with no end: FM-PATH-LONG" TO TL-CASE
     MOVE FM-PATH-LONG TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   DIR-RENAME: the partial directory takes the place of the generated one.
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/swap/gen.partial/sub" TO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/swap/gen.partial/sub/file.txt" TO WS-PATH
     MOVE 8 TO WS-LENGTH
     CALL "FILE-WRITE" USING WS-PATH WS-AREA WS-LENGTH WS-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/swap/gen.partial" TO WS-PATH
     MOVE LOW-VALUES TO WS-PATH2
     MOVE "build/formats-test/dirs/swap/gen" TO WS-PATH2
     CALL "DIR-RENAME" USING WS-PATH WS-PATH2 WS-STATUS
     MOVE "dirs rename of the partial directory to an absent name: FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "build/formats-test/dirs/swap/gen.partial" TO WS-CHECK-NAME
     PERFORM ASSERT-ABSENT
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/swap/gen/sub/file.txt" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "dirs rename carried the file below: it is at the new place" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
*>   The target is there: refused, nothing changes.
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/swap/second" TO WS-PATH
     CALL "DIR-ENSURE" USING WS-PATH WS-STATUS
     MOVE LOW-VALUES TO WS-PATH2
     MOVE "build/formats-test/dirs/swap/second" TO WS-PATH2
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/swap/gen" TO WS-PATH
     CALL "DIR-RENAME" USING WS-PATH WS-PATH2 WS-STATUS
     MOVE "dirs rename onto a directory that exists: FM-EXISTS" TO TL-CASE
     MOVE FM-EXISTS TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "build/formats-test/dirs/swap/gen" TO WS-CHECK-NAME
     PERFORM ASSERT-IS-DIR
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/swap/nothing" TO WS-PATH
     CALL "DIR-RENAME" USING WS-PATH WS-PATH2 WS-STATUS
     MOVE "dirs rename of a source that is absent: FM-NOT-FOUND" TO TL-CASE
     MOVE FM-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/swap/gen" TO WS-PATH
     MOVE LOW-VALUES TO WS-PATH2
     MOVE "build/formats-test/dirs/swap/absent-parent/gen" TO WS-PATH2
     CALL "DIR-RENAME" USING WS-PATH WS-PATH2 WS-STATUS
     MOVE "dirs rename into a folder that is absent: FM-UNREADABLE" TO TL-CASE
     MOVE FM-UNREADABLE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE ALL "a" TO WS-PATH
     CALL "DIR-RENAME" USING WS-PATH WS-PATH2 WS-STATUS
     MOVE "dirs rename of a source path with no end: FM-PATH-LONG" TO TL-CASE
     MOVE FM-PATH-LONG TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/swap/gen" TO WS-PATH
     MOVE ALL "a" TO WS-PATH2
     CALL "DIR-RENAME" USING WS-PATH WS-PATH2 WS-STATUS
     MOVE "dirs rename to a target path with no end: FM-PATH-LONG" TO TL-CASE
     PERFORM ASSERT-STATUS

*>   DIR-REMOVE-TREE of a tree with files, nested and empty directories, and a folder of 100 long names.
     CALL "SYSTEM" USING "mkdir -p build/formats-test/dirs/tree/sub/deep build/formats-test/dirs/tree/empty build/formats-test/dirs/tree/many"
     CALL "SYSTEM" USING "echo 1 > build/formats-test/dirs/tree/f1; echo 2 > build/formats-test/dirs/tree/sub/f2; echo 3 > build/formats-test/dirs/tree/sub/deep/f3"
     CALL "SYSTEM" USING "i=1; while [ $i -le 100 ]; do : > build/formats-test/dirs/tree/many/a-file-with-a-rather-long-name-number-$i.txt; i=$((i+1)); done"
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/tree" TO WS-PATH
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree of a tree of directories and 103 files: FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "build/formats-test/dirs/tree" TO WS-CHECK-NAME
     PERFORM ASSERT-ABSENT
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree of nothing: FM-NOT-FOUND" TO TL-CASE
     MOVE FM-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/afile" TO WS-PATH
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree of a file: FM-EXISTS" TO TL-CASE
     MOVE FM-EXISTS TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree left the file alone" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE ALL "a" TO WS-PATH
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree of a path with no end: FM-PATH-LONG" TO TL-CASE
     MOVE FM-PATH-LONG TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
*>   A file that cannot be removed (its folder is not writable): FM-UNREADABLE, the file stays.
     CALL "SYSTEM" USING "mkdir -p build/formats-test/dirs/locked/inner && echo x > build/formats-test/dirs/locked/inner/f && chmod 555 build/formats-test/dirs/locked/inner"
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/locked" TO WS-PATH
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree where a file cannot be removed: FM-UNREADABLE" TO TL-CASE
     MOVE FM-UNREADABLE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/locked/inner/f" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "dirs the file that could not be removed is still there" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "chmod 755 build/formats-test/dirs/locked/inner"
*>   Symbolic links are removed as links, never followed: the sentinel file outside the tree must survive.
     CALL "SYSTEM" USING "mkdir -p build/formats-test/dirs/outside build/formats-test/dirs/victim/inner"
     CALL "SYSTEM" USING "echo keep > build/formats-test/dirs/outside/sentinel.txt; echo own > build/formats-test/dirs/victim/inner/own.txt"
     CALL "SYSTEM" USING "ln -s ../outside build/formats-test/dirs/victim/link; ln -s ../outside/sentinel.txt build/formats-test/dirs/victim/flink; ln -s nowhere build/formats-test/dirs/victim/dangle"
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/victim" TO WS-PATH
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree of a tree holding links to a directory, a file and nothing: FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "build/formats-test/dirs/victim" TO WS-CHECK-NAME
     PERFORM ASSERT-ABSENT
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/outside/sentinel.txt" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree did not follow a link: the sentinel outside the tree is still there" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "ln -s outside build/formats-test/dirs/toplink; ln -s nowhere build/formats-test/dirs/topdangle"
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/toplink" TO WS-PATH
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree of a link to a directory removes the link only: FM-OK" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "build/formats-test/dirs/toplink" TO WS-CHECK-NAME
     PERFORM ASSERT-ABSENT
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/outside/sentinel.txt" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "dirs the sentinel survives the removal of a link to its folder" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/topdangle" TO WS-PATH
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree of a dangling link removes it: FM-OK" TO TL-CASE
     PERFORM ASSERT-STATUS
*>   A directory below that cannot be listed (mode 000): FM-UNREADABLE.
     CALL "SYSTEM" USING "mkdir -p build/formats-test/dirs/hidden/sealed && chmod 000 build/formats-test/dirs/hidden/sealed"
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/hidden" TO WS-PATH
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree where a directory below cannot be listed: FM-UNREADABLE" TO TL-CASE
     MOVE FM-UNREADABLE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "chmod 755 build/formats-test/dirs/hidden/sealed"
*>   A directory that cannot be removed itself (no write access to its parent) after it is emptied.
     CALL "SYSTEM" USING "mkdir -p build/formats-test/dirs/guard/child && chmod 555 build/formats-test/dirs/guard"
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/dirs/guard/child" TO WS-PATH
     CALL "DIR-REMOVE-TREE" USING WS-PATH WS-STATUS
     MOVE "dirs remove-tree of a directory in a folder that is not writable: FM-UNREADABLE" TO TL-CASE
     MOVE FM-UNREADABLE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "chmod 755 build/formats-test/dirs/guard"
     STOP RUN.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-CHECK-NAME is a directory.
 ASSERT-IS-DIR.
     MOVE LOW-VALUES TO WS-WORK
     MOVE FUNCTION TRIM(WS-CHECK-NAME) TO WS-WORK
     CALL "FILE-EXISTS" USING WS-WORK WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "dirs " FUNCTION TRIM(WS-CHECK-NAME) " is a directory" DELIMITED BY SIZE INTO TL-CASE
     MOVE FM-IS-DIR TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS.

*> Nothing is at WS-CHECK-NAME.
 ASSERT-ABSENT.
     MOVE LOW-VALUES TO WS-WORK
     MOVE FUNCTION TRIM(WS-CHECK-NAME) TO WS-WORK
     CALL "FILE-EXISTS" USING WS-WORK WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "dirs " FUNCTION TRIM(WS-CHECK-NAME) " is gone" DELIMITED BY SIZE INTO TL-CASE
     MOVE FM-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS.
 END PROGRAM TEST-DIRS.
